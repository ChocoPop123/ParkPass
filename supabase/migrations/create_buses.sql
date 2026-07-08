CREATE TABLE IF NOT EXISTS buses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    operator_id UUID NOT NULL
        REFERENCES operators(id)
        ON DELETE CASCADE,

    plate_number TEXT UNIQUE NOT NULL,

    bus_name TEXT,

    capacity INTEGER NOT NULL CHECK (capacity > 0),

    created_at TIMESTAMPTZ DEFAULT NOW()
);