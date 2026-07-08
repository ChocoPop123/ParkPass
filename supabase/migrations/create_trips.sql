CREATE TABLE IF NOT EXISTS trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    route_id UUID NOT NULL
        REFERENCES routes(id),

    bus_id UUID NOT NULL
        REFERENCES buses(id),

    departure_time TIMESTAMPTZ NOT NULL,

    arrival_time TIMESTAMPTZ,

    fare NUMERIC(10,2) NOT NULL,

    status TEXT DEFAULT 'scheduled'
        CHECK (
            status IN (
                'scheduled',
                'boarding',
                'departed',
                'completed',
                'cancelled'
            )
        ),

    created_at TIMESTAMPTZ DEFAULT NOW()
);