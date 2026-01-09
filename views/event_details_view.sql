CREATE OR REPLACE VIEW event_details_view AS
SELECT
    e.id AS event_id,
    e.title,
    e.description,
    e.cost,
    e.city,
    e.address,
    e.status,
    e.format,
    e.creator_id,
    u.last_name || ' ' || u.first_name || COALESCE(' ' || u.middle_name, '') AS creator_full_name,

    COUNT(ts.id) AS slot_count,

    MIN(ts.date_start) AS earliest_date_start,
    MAX(ts.date_end) AS latest_date_end,

    CASE
        WHEN BOOL_AND(ts.capacity IS NOT NULL) THEN SUM(ts.capacity)
        ELSE NULL
    END AS total_capacity,

    COUNT(r.id) AS total_registrations,

    CASE
        WHEN BOOL_AND(ts.capacity IS NOT NULL) THEN
            GREATEST(0, SUM(ts.capacity) - COUNT(r.id))
        ELSE NULL
    END AS available_seats,

    BOOL_OR(e.status = 'open' AND ts.date_start + COALESCE(ts.time_start, TIME '00:00') > NOW()) AS has_open_future_slots

FROM events e
JOIN users u ON e.creator_id = u.id
LEFT JOIN time_slots ts ON e.id = ts.event_id
LEFT JOIN registrations r ON ts.id = r.time_slot_id
GROUP BY
    e.id,
    e.title,
    e.description,
    e.cost,
    e.city,
    e.address,
    e.status,
    e.format,
    e.creator_id,
    u.last_name,
    u.first_name,
    u.middle_name;