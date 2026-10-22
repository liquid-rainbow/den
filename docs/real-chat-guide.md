# Real matched-user chat: a plain-language guide

## What changed

Previously, the Chat tab was a picture of a conversation: the people and messages were written directly in the app. Pressing Send only added text on that device. Nobody else received it.

Now, two signed-in, active users can like each other by their profile usernames. One like is not enough. When both people like each other, the server creates one shared conversation. Both people see it in Chats. Messages are saved in PostgreSQL, so reopening the conversation loads the saved history.

This is a working first version of text chat. The app asks the server for updates every three seconds (called polling), rather than holding a WebSocket connection. It has no push notifications, attachments, typing indicators or read receipts. A saved message does not prove the recipient has read it. Existing Explore cards remain separate sample content; use Find a match in Chats for this matching flow.

## The pieces, explained

- **Flutter app:** the screens you touch. It displays conversations and sends your typed text.
- **Backend/server:** the trusted middleman. It checks who is signed in and whether they belong to a conversation.
- **API:** the addresses the app calls to ask the server for a list, send a like, or send a message.
- **PostgreSQL database:** the permanent notebook storing users, likes, conversations and messages.
- **Session token:** the sign-in proof already used by the app. The server uses it to identify the sender. The app cannot choose another sender just by supplying an ID.
- **Migration:** a file of instructions adding storage tables to an existing database.

## What happens when Ragh and Tejb match

1. Ragh signs in through the existing phone/OTP flow and finishes their profile.
2. Tejb does the same in a separate app session.
3. Ragh opens Chats, enters Tejb's profile username, and taps Like.
4. The server remembers Ragh's like. No conversation is created yet.
5. Tejb enters Ragh's username and taps Like.
6. The server sees both likes and creates their shared conversation. Repeated likes reuse it.
7. The conversation appears for both users on the next refresh.
8. Ragh opens it and sends Hello. The app submits the message to the server.
9. The server checks Ragh's session and conversation membership, then saves Hello.
10. Tejb's screen checks for updates and displays Hello, normally within about three seconds plus network time.
11. Tejb replies using the same process. Closing and reopening the app does not delete saved messages, although the existing sign-in system may require signing in again.

The app uses the existing profile username stored as instagram_username. Enter the username, not the full name or phone number. Use distinct usernames. Creating database rows alone does not sign users in; they need valid sessions and active profiles.

## Before testing on your database

The new tables must exist on the SAME database used by the backend. Review backend/migrations/003_chat.sql, then run that file in pgAdmin's Query Tool on the intended development database. It only adds tables and indexes; it does not create Ragh or Tejb, change credentials, or alter existing user records. The rollback file is backend/migrations/down/003_chat.sql and deletes chat data, so do not run it during normal setup.

The existing backend migration command also runs top-level SQL migration files, but it attempts to connect to the postgres database and create the configured database. For an already existing RDS database, applying just the reviewed new SQL file in pgAdmin is more direct.

Restart the backend after updating the code. The app must point to the backend API, not to PostgreSQL or your pgAdmin tunnel. The backend and app now default to port 5001. A Mac browser uses http://localhost:5001 and an Android emulator uses http://10.0.2.2:5001. A physical phone needs a reachable backend address. For ECS use --dart-define=DEN_API_BASE_URL=https://YOUR_BACKEND_HOST, without /api at the end. Existing .env values can override the server's defaults.

Database TLS now defaults to verify-full using DB_SSL_ROOT_CERT (the Docker image includes the Mumbai RDS CA bundle). For local disposable PostgreSQL only, explicitly set DB_SSL_MODE=disable. The SSM tunnel on port 15432 is for database access. If a locally running backend uses it, its database host/port must be configured accordingly. The mobile app always talks to the backend, never directly to RDS.

## Test with two people

1. Start the backend and open two independent app sessions, such as Chrome and an incognito window, or two simulators/devices. Sign in as a different user in each. Each user needs their own phone number and a distinct profile username.
2. Send a like from Ragh to Tejb. Confirm no conversation exists yet.
3. Send a like from Tejb to Ragh. Confirm both now see the conversation.
4. Open it on both devices, send messages in both directions, and wait a few seconds for updates.
5. Leave the conversation and reopen it. Messages should still be there.
6. Test an unrelated third account: it must not see or access their conversation.
7. Disconnect the backend and try sending: an error should appear and the draft should remain. If the connection fails after the server saves a message, check the conversation before retrying; this first version does not deduplicate retries.

## Storage and access

user_likes stores who liked whom. conversations stores the two matched participants. chat_messages stores the conversation, sender, message and timestamp. Deleting a user deletes their related conversations, likes and messages through database relationships. Only active participants can use these chat APIs. Messages are stored as readable database text; this implementation does not provide end-to-end encryption. Use HTTPS when deploying the API.

Latest messages are loaded in batches of 100. Load older messages retrieves earlier history. Automatic background/mobile delivery is not included; open the app to refresh. There is no unmatch/block/report flow or per-user message rate limiting in this first version; add those before a broad public rollout.

## Developer verification

backend/test/chat_flow_test.dart exercises the real PostgreSQL tables and HTTP routes. It is skipped unless CHAT_TEST_DB=1 is set. Run it only against an explicitly configured disposable database with migrations applied, never against production. It intentionally does not load .env.
