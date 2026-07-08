CREATE TABLE IF NOT EXISTS cargo_bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    trip_id UUID NOT NULL
        REFERENCES trips(id)
        ON DELETE CASCADE,

    sender_id UUID NOT NULL
        REFERENCES profiles(id)
        ON DELETE CASCADE,

    receiver_name TEXT NOT NULL,

    receiver_phone TEXT NOT NULL,

    item_description TEXT NOT NULL,

    weight_kg NUMERIC(6,2),

    amount NUMERIC(10,2) NOT NULL,

    cargo_status TEXT DEFAULT 'pending'
        CHECK (
            cargo_status IN (
                'pending',
                'received',
                'in_transit',
                'delivered',
                'cancelled'
            )
        ),

    created_at TIMESTAMPTZ DEFAULT NOW()
);