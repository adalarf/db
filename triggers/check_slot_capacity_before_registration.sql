CREATE OR REPLACE FUNCTION check_slot_capacity_before_registration()
RETURNS TRIGGER AS $$
DECLARE
    current_count INT;
    max_capacity INT;
BEGIN
    SELECT COUNT(*) INTO current_count
    FROM registrations
    WHERE time_slot_id = NEW.time_slot_id;

    SELECT capacity INTO max_capacity
    FROM time_slots
    WHERE id = NEW.time_slot_id;

    IF max_capacity IS NOT NULL AND current_count >= max_capacity THEN
        RAISE EXCEPTION 'No available seats in time slot %', NEW.time_slot_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_slot_capacity
BEFORE INSERT ON registrations
FOR EACH ROW EXECUTE FUNCTION check_slot_capacity_before_registration();