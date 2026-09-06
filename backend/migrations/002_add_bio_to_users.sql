-- Adds a short public bio to user profiles.
-- Down path:
--   ALTER TABLE users DROP COLUMN IF EXISTS bio;

ALTER TABLE users
    ADD COLUMN IF NOT EXISTS bio VARCHAR(280) NOT NULL DEFAULT '';
