-- Destructive rollback: deletes all chat history and likes. Run only deliberately.
DROP TABLE IF EXISTS chat_messages;
DROP TABLE IF EXISTS conversations;
DROP TABLE IF EXISTS user_likes;
