CREATE TABLE IF NOT EXISTS bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    passenger_id UUID NOT NULL
        REFERENCES profiles(id)
        ON DELETE CASCADE,

    trip_id UUID NOT NULL
        REFERENCES trips(id)
        ON DELETE CASCADE,

    seat_id UUID NOT NULL
        REFERENCES seats(id)
        ON DELETE CASCADE,

    booking_reference TEXT UNIQUE NOT NULL,

    qr_token UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),

    booking_status TEXT DEFAULT 'pending'
        CHECK (
            booking_status IN (
                'pending',
                'confirmed',
                'cancelled',
                'completed'
            )
        ),

    amount_paid NUMERIC(10,2) DEFAULT 0,

    booked_at TIMESTAMPTZ DEFAULT NOW()
);