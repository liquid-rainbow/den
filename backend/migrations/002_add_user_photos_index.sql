-- -----------------------------------------------------------------------------
-- MIGRATION: 002_add_user_photos_index
-- DESCRIPTION: Adds a composite index to user_photos to optimize the 
-- fetchPhotosForUser query which filters by user_id and sorts by position and created_at.
-- -----------------------------------------------------------------------------

CREATE INDEX IF NOT EXISTS idx_user_photos_user_pos_created 
ON user_photos(user_id, position, created_at);
