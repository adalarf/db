CREATE OR REPLACE FUNCTION update_event(
    p_event_id BIGINT,
    p_user_id BIGINT,
    p_title VARCHAR(50) DEFAULT NULL,
    p_description TEXT DEFAULT NULL,
    p_cost NUMERIC(10,2) DEFAULT NULL,
    p_address VARCHAR(50) DEFAULT NULL,
    p_status VARCHAR(50) DEFAULT NULL,
    p_format VARCHAR(50) DEFAULT NULL
)
RETURNS void AS $$
DECLARE
    v_creator_id BIGINT;
BEGIN
    SELECT creator_id INTO v_creator_id
    FROM events
    WHERE id = p_event_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Event % not found', p_event_id;
    END IF;

    IF v_creator_id != p_user_id THEN
        RAISE EXCEPTION 'Only the creator can update this event';
    END IF;

    IF p_status IS NOT NULL AND p_status NOT IN ('open', 'close') THEN
        RAISE EXCEPTION 'Status must be "open" or "close"';
    END IF;

    UPDATE events
    SET
        title = COALESCE(p_title, title),
        description = COALESCE(p_description, description),
        cost = COALESCE(p_cost, cost),
        address = COALESCE(p_address, address),
        status = COALESCE(p_status, status),
        format = COALESCE(p_format, format)
    WHERE id = p_event_id;
END;
$$ LANGUAGE plpgsql;