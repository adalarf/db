CREATE OR REPLACE FUNCTION create_event(
    p_title VARCHAR(50),
    p_creator_id BIGINT,
    p_slot_date_start DATE,
    p_slot_date_end DATE,
    p_slot_time_start TIME DEFAULT NULL,
    p_slot_time_end TIME DEFAULT NULL,
    p_slot_capacity INTEGER DEFAULT NULL,
    p_description TEXT DEFAULT NULL,
    p_cost NUMERIC(10,2) DEFAULT NULL,
    p_city VARCHAR(50) DEFAULT NULL,
    p_address VARCHAR(50) DEFAULT NULL,
    p_format VARCHAR(50) DEFAULT NULL
)
RETURNS BIGINT AS $$
DECLARE
    v_event_id BIGINT;
BEGIN
    IF p_cost IS NOT NULL AND p_cost < 0 THEN
        RAISE EXCEPTION 'Cost must be non-negative';
    END IF;

    IF p_slot_date_start > p_slot_date_end THEN
        RAISE EXCEPTION 'Slot: date_start must be <= date_end';
    END IF;

    IF p_slot_date_start = p_slot_date_end THEN
        IF p_slot_time_start IS NOT NULL AND p_slot_time_end IS NOT NULL THEN
            IF p_slot_time_start > p_slot_time_end THEN
                RAISE EXCEPTION 'Slot: time_end must be >= time_start on same day';
            END IF;
        END IF;
    END IF;

    IF p_slot_capacity IS NOT NULL AND p_slot_capacity <= 0 THEN
        RAISE EXCEPTION 'Slot capacity must be > 0 if specified';
    END IF;

    INSERT INTO events (
        title, description, cost, city, address, status, format, creator_id
    ) VALUES (
        p_title,
        p_description,
        p_cost,
        p_city,
        p_address,
        'open',
        p_format,
        p_creator_id
    )
    RETURNING id INTO v_event_id;

    INSERT INTO time_slots (
        event_id,
        date_start,
        date_end,
        time_start,
        time_end,
        capacity
    ) VALUES (
        v_event_id,
        p_slot_date_start,
        p_slot_date_end,
        p_slot_time_start,
        p_slot_time_end,
        p_slot_capacity
    );

    RETURN v_event_id;
END;
$$ LANGUAGE plpgsql;