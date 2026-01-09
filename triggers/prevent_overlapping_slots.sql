CREATE OR REPLACE FUNCTION prevent_overlapping_slots()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM time_slots ts
        WHERE ts.event_id = NEW.event_id
          AND ts.id != NEW.id
          AND ts.date_start <= NEW.date_end
          AND ts.date_end >= NEW.date_start
          AND (
              ts.date_start != ts.date_end
              OR NEW.date_start != NEW.date_end
              OR (ts.time_start IS NULL AND ts.time_end IS NULL)
              OR (NEW.time_start IS NULL AND NEW.time_end IS NULL)
              OR (ts.time_start <= NEW.time_end AND ts.time_end >= NEW.time_start)
          )
    ) THEN
        RAISE EXCEPTION 'Overlapping time slot detected for event %', NEW.event_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_overlapping_slots
BEFORE INSERT OR UPDATE ON time_slots
FOR EACH ROW EXECUTE FUNCTION prevent_overlapping_slots();