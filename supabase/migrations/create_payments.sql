CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    booking_id UUID NOT NULL
        REFERENCES bookings(id)
        ON DELETE CASCADE,

    payment_method TEXT NOT NULL
        CHECK (
            payment_method IN (
                'mobile_money',
                'card',
                'cash'
            )
        ),

    transaction_reference TEXT UNIQUE,

    amount NUMERIC(10,2) NOT NULL,

    payment_status TEXT DEFAULT 'pending'
        CHECK (
            payment_status IN (
                'pending',
                'successful',
                'failed',
                'refunded'
            )
        ),

    paid_at TIMESTAMPTZ DEFAULT NOW()
);