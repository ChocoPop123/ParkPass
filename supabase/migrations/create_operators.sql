
CREATE TABLE IF NOT EXISTS operators (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    profile_id UUID NOT NULL UNIQUE
        REFERENCES profiles(id)
        ON DELETE CASCADE,

    company_name TEXT NOT NULL,

    registration_number TEXT UNIQUE,

    company_email TEXT UNIQUE,

    company_phone TEXT,

    address TEXT,

    logo_url TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW()
);