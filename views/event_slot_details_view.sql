CREATE OR REPLACE VIEW event_slot_details_view AS
SELECT
    ts.id AS slot_id,
    e.id AS event_id,
    e.title AS event_title,
    e.status AS event_status,
    e.city AS event_city,
    e.address AS event_address,
    e.format AS event_format,

    ts.date_start,
    ts.date_end,
    ts.time_start,
    ts.time_end,
    ts.capacity,

    COUNT(r.id) AS registrations_count,

    CASE
        WHEN ts.capacity IS NOT NULL THEN
            GREATEST(0, ts.capacity - COUNT(r.id))
        ELSE NULL
    END AS available_seats,

    (e.status = 'open' AND (ts.date_start + COALESCE(ts.time_start, TIME '00:00')) > NOW()) AS is_open_for_registration,

    (ts.date_start + COALESCE(ts.time_start, TIME '00:00')) <= NOW() AS has_started

FROM time_slots ts
JOIN events e ON ts.event_id = e.id
LEFT JOIN registrations r ON ts.id = r.time_slot_id
GROUP BY
    ts.id,
    e.id,
    e.title,
    e.status,
    e.city,
    e.address,
    e.format,
    ts.date_start,
    ts.date_end,
    ts.time_start,
    ts.time_end,
    ts.capacity;