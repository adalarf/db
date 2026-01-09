CREATE INDEX idx_users_email ON users (email);
CREATE INDEX idx_users_city ON users (city);


CREATE INDEX idx_events_status ON events (status);
CREATE INDEX idx_events_creator_id ON events (creator_id);
CREATE INDEX idx_events_city ON events (city);


CREATE INDEX idx_time_slots_event_id ON time_slots (event_id);
CREATE INDEX idx_time_slots_dates ON time_slots (date_start, date_end);


CREATE INDEX idx_registrations_user_id ON registrations (user_id);
CREATE INDEX idx_registrations_event_id ON registrations (event_id);
CREATE INDEX idx_registrations_time_slot_id ON registrations (time_slot_id);
CREATE UNIQUE INDEX idx_registrations_user_slot ON registrations (user_id, time_slot_id);