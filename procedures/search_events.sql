CREATE OR REPLACE FUNCTION search_events(
    p_city VARCHAR(50) DEFAULT NULL,
    p_format VARCHAR(50) DEFAULT NULL,
    p_status VARCHAR(50) DEFAULT NULL,
    p_title_pattern VARCHAR(50) DEFAULT NULL,
    p_from_date DATE DEFAULT NULL,
    p_to_date DATE DEFAULT NULL
)
RETURNS TABLE (
    event_id BIGINT,
    title VARCHAR(50),
    description TEXT,
    cost NUMERIC(10,2),
    event_city VARCHAR(50),
    address VARCHAR(50),
    status VARCHAR(50),
    format VARCHAR(50),
    creator_id BIGINT,
    slot_id BIGINT,
    date_start DATE,
    date_end DATE,
    time_start TIME,
    time_end TIME,
    capacity INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id,
        e.title,
        e.description,
        e.cost,
        e.city,
        e.address,
        e.status,
        e.format,
        e.creator_id,
        ts.id,
        ts.date_start,
        ts.date_end,
        ts.time_start,
        ts.time_end,
        ts.capacity
    FROM events e
    JOIN time_slots ts ON e.id = ts.event_id
    WHERE
        (p_city IS NULL OR e.city ILIKE p_city)
        AND (p_format IS NULL OR e.format ILIKE p_format)
        AND (p_status IS NULL OR e.status = p_status)
        AND (p_title_pattern IS NULL OR e.title ILIKE ('%' || p_title_pattern || '%'))
        AND (p_from_date IS NULL OR ts.date_end >= p_from_date)
        AND (p_to_date IS NULL OR ts.date_start <= p_to_date);
END;
$$ LANGUAGE plpgsql;