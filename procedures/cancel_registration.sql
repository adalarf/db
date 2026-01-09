CREATE OR REPLACE FUNCTION cancel_registration(
    p_user_id BIGINT,
    p_registration_id BIGINT
)
RETURNS void AS $$
DECLARE
    v_slot_start TIMESTAMPTZ;
    v_now TIMESTAMPTZ := NOW();
BEGIN
    SELECT
        (ts.date_start + COALESCE(ts.time_start, TIME '00:00:00'))::TIMESTAMPTZ
    INTO v_slot_start
    FROM registrations r
    JOIN time_slots ts ON r.time_slot_id = ts.id
    WHERE r.id = p_registration_id AND r.user_id = p_user_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Registration % not found or does not belong to user %', p_registration_id, p_user_id;
    END IF;

    IF v_now >= v_slot_start THEN
        RAISE EXCEPTION 'Cannot cancel registration: slot has already started or passed';
    END IF;

    DELETE FROM registrations WHERE id = p_registration_id;
END;
$$ LANGUAGE plpgsql;