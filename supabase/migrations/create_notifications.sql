CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    profile_id UUID NOT NULL
        REFERENCES profiles(id)
        ON DELETE CASCADE,

    title TEXT NOT NULL,

    message TEXT NOT NULL,

    is_read BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMPTZ DEFAULT NOW()
);