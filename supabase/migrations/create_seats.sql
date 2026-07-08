CREATE TABLE IF NOT EXISTS seats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    trip_id UUID NOT NULL
        REFERENCES trips(id)
        ON DELETE CASCADE,

    seat_number TEXT NOT NULL,

    status TEXT DEFAULT 'available'
        CHECK (
            status IN (
                'available',
                'reserved',
                'booked'
            )
        ),

    created_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(trip_id, seat_number)
);