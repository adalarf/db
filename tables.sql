CREATE TABLE users (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    email VARCHAR(50) NOT NULL UNIQUE,
    date_of_birth DATE NOT NULL CHECK (date_of_birth < CURRENT_DATE),
    city VARCHAR(50),
    phone VARCHAR(12),
    company_name VARCHAR(100),
    vk_profile VARCHAR(50),
    telegram_link VARCHAR(50)
);


CREATE TABLE events (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    title VARCHAR(50) NOT NULL,
    description TEXT,
    cost NUMERIC(10, 2) CHECK (cost >= 0),
    city VARCHAR(50),
    address VARCHAR(50),
    status VARCHAR(50) NOT NULL CHECK (status IN ('open', 'close')),
    format VARCHAR(50),
    creator_id BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT
);


CREATE TABLE time_slots (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    event_id BIGINT NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    date_start DATE NOT NULL,
    date_end DATE NOT NULL,
    time_start TIME,
    time_end TIME,
    capacity INTEGER CHECK (capacity > 0),

    CONSTRAINT valid_date_range CHECK (date_start <= date_end),

    CONSTRAINT valid_time_range CHECK (
        date_start != date_end OR
        (time_start IS NOT NULL AND time_end IS NOT NULL AND time_start <= time_end)
    )
);


CREATE TABLE registrations (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    event_id BIGINT NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    time_slot_id BIGINT NOT NULL REFERENCES time_slots(id) ON DELETE CASCADE,

    UNIQUE (user_id, time_slot_id)
);