-- Migration 002: Add auto-generated sequential username column and case-insensitive unique index

CREATE SEQUENCE IF NOT EXISTS username_seq START 1;

ALTER TABLE users ADD COLUMN IF NOT EXISTS username VARCHAR(30);

-- Backfill any existing rows first if the table isn't empty:
UPDATE users SET username = ('den' || lpad(nextval('username_seq')::text, 3, '0')) WHERE username IS NULL;

ALTER TABLE users ALTER COLUMN username SET DEFAULT 
    ('den' || lpad(nextval('username_seq')::text, 3, '0'));
ALTER TABLE users ALTER COLUMN username SET NOT NULL;

-- Case-insensitive uniqueness (den123 and Den123 must not both exist)
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_username_lower ON users (lower(username));
