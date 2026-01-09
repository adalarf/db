CREATE OR REPLACE FUNCTION register_user_for_slot(
    p_user_id BIGINT,
    p_time_slot_id BIGINT
)
RETURNS BIGINT AS $$
DECLARE
    v_event_status VARCHAR(50);
    v_capacity INT;
    v_current_registrations INT;
    v_slot_start TIMESTAMPTZ;
    v_now TIMESTAMPTZ := NOW();
    v_registration_id BIGINT;
BEGIN
    SELECT
        e.status,
        ts.capacity,
        (ts.date_start + COALESCE(ts.time_start, TIME '00:00:00'))::TIMESTAMPTZ
    INTO
        v_event_status,
        v_capacity,
        v_slot_start
    FROM time_slots ts
    JOIN events e ON ts.event_id = e.id
    WHERE ts.id = p_time_slot_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Time slot % does not exist', p_time_slot_id;
    END IF;

    IF v_event_status != 'open' THEN
        RAISE EXCEPTION 'Registration is not allowed: event is not open';
    END IF;

    IF v_now >= v_slot_start THEN
        RAISE EXCEPTION 'Cannot register: slot has already started';
    END IF;

    PERFORM 1 FROM registrations
    WHERE user_id = p_user_id AND time_slot_id = p_time_slot_id;
    IF FOUND THEN
        RAISE EXCEPTION 'User % is already registered for slot %', p_user_id, p_time_slot_id;
    END IF;

    IF v_capacity IS NOT NULL THEN
        SELECT COUNT(*) INTO v_current_registrations
        FROM registrations
        WHERE time_slot_id = p_time_slot_id;

        IF v_current_registrations >= v_capacity THEN
            RAISE EXCEPTION 'No available seats in slot %', p_time_slot_id;
        END IF;
    END IF;

    INSERT INTO registrations (user_id, event_id, time_slot_id)
    SELECT p_user_id, e.id, p_time_slot_id
    FROM events e
    JOIN time_slots ts ON e.id = ts.event_id
    WHERE ts.id = p_time_slot_id
    RETURNING id INTO v_registration_id;

    RETURN v_registration_id;
END;
$$ LANGUAGE plpgsql;