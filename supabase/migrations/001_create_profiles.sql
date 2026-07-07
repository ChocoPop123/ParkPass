CREATE TABLE profiles (
    id uuid PRIMARY KEY REFRENCES auth.users ON DELETE CASCADE,
    full_name text not null,
    email text unique not null,
    phone_number text unique,
    role text not null check(
        role in ('passenger', 'operator', 'conductor', 'admin')
    ),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
);