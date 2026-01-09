CREATE OR REPLACE FUNCTION create_time_slot_for_event(
    p_event_id BIGINT,
    p_date_start DATE,
    p_date_end DATE,
    p_time_start TIME DEFAULT NULL,
    p_time_end TIME DEFAULT NULL,
    p_capacity INTEGER DEFAULT NULL
)
RETURNS BIGINT AS $$
DECLARE
    v_event_exists BOOLEAN;
    v_slot_id BIGINT;
BEGIN
    SELECT EXISTS (SELECT 1 FROM events WHERE id = p_event_id) INTO v_event_exists;
    IF NOT v_event_exists THEN
        RAISE EXCEPTION 'Event with id % does not exist', p_event_id;
    END IF;

    IF p_date_start > p_date_end THEN
        RAISE EXCEPTION 'date_start must be <= date_end';
    END IF;

    IF p_date_start = p_date_end THEN
        IF p_time_start IS NOT NULL AND p_time_end IS NOT NULL THEN
            IF p_time_start > p_time_end THEN
                RAISE EXCEPTION 'On the same day, time_end must be >= time_start';
            END IF;
        END IF;
    END IF;

    IF p_capacity IS NOT NULL AND p_capacity <= 0 THEN
        RAISE EXCEPTION 'Capacity must be > 0 if specified';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM time_slots ts
        WHERE ts.event_id = p_event_id
          AND ts.date_start <= p_date_end
          AND ts.date_end >= p_date_start
          AND (
              (ts.time_start IS NULL OR ts.time_end IS NULL OR p_time_start IS NULL OR p_time_end IS NULL)
              OR
              (ts.time_start <= p_time_end AND ts.time_end >= p_time_start)
          )
    ) THEN
        RAISE EXCEPTION 'New slot overlaps with an existing slot for event %', p_event_id;
    END IF;

    INSERT INTO time_slots (
        event_id,
        date_start,
        date_end,
        time_start,
        time_end,
        capacity
    ) VALUES (
        p_event_id,
        p_date_start,
        p_date_end,
        p_time_start,
        p_time_end,
        p_capacity
    )
    RETURNING id INTO v_slot_id;

    RETURN v_slot_id;
END;
$$ LANGUAGE plpgsql;