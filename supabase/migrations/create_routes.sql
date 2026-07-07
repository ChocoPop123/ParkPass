CREATE TABLE IF NOT EXISTS routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    origin TEXT NOT NULL,

    destination TEXT NOT NULL,

    estimated_duration INTERVAL,

    distance_km NUMERIC,

    created_at TIMESTAMPTZ DEFAULT NOW()
);