CREATE OR REPLACE FUNCTION delete_event_if_no_registrations(p_event_id BIGINT)
RETURNS void AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM registrations r
    JOIN time_slots ts ON r.time_slot_id = ts.id
    WHERE ts.event_id = p_event_id;

    IF v_count > 0 THEN
        RAISE EXCEPTION 'Cannot delete event %: it has % registration(s)', p_event_id, v_count;
    END IF;

    DELETE FROM events WHERE id = p_event_id;
END;
$$ LANGUAGE plpgsql;