CREATE OR REPLACE FUNCTION check_event_open_for_registration()
RETURNS TRIGGER AS $$
DECLARE
    event_status TEXT;
BEGIN
    SELECT e.status INTO event_status
    FROM events e
    JOIN time_slots ts ON e.id = ts.event_id
    WHERE ts.id = NEW.time_slot_id;

    IF event_status != 'open' THEN
        RAISE EXCEPTION 'Registration is not allowed: event is not open';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_event_open_before_registration
BEFORE INSERT OR UPDATE ON registrations
FOR EACH ROW EXECUTE FUNCTION check_event_open_for_registration();