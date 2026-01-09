CREATE OR REPLACE FUNCTION prevent_event_deletion_with_registrations()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM registrations r
        JOIN time_slots ts ON r.time_slot_id = ts.id
        WHERE ts.event_id = OLD.id
    ) THEN
        RAISE EXCEPTION 'Cannot delete event with existing registrations';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_event_deletion
BEFORE DELETE ON events
FOR EACH ROW EXECUTE FUNCTION prevent_event_deletion_with_registrations();