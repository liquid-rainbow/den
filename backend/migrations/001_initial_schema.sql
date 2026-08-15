-- Enable UUID extension for secure, unguessable primary keys
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- -----------------------------------------------------------------------------
-- 1. USERS TABLE
-- Stores core user identity, onboarding state, and profile metadata.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    full_name VARCHAR(120),
    dob DATE,
    gender VARCHAR(30),
    height_cm INTEGER CHECK (height_cm IS NULL OR (height_cm >= 120 AND height_cm <= 230)),
    location VARCHAR(120),
    instagram_username VARCHAR(30),
    status VARCHAR(30) NOT NULL DEFAULT 'pending_onboarding' 
        CHECK (status IN ('pending_onboarding', 'active', 'suspended', 'deactivated')),
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    role VARCHAR(30) NOT NULL DEFAULT 'user' 
        CHECK (role IN ('user', 'host', 'admin')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone_number);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);

-- -----------------------------------------------------------------------------
-- 2. USER_PHOTOS TABLE
-- Manages S3 photo keys, ordering, and primary photo designations.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_photos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    object_key VARCHAR(512) NOT NULL,
    public_url VARCHAR(1024) NOT NULL,
    position INTEGER NOT NULL DEFAULT 0,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_user_photos_user_id ON user_photos(user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_one_primary_photo_per_user ON user_photos(user_id) WHERE is_primary = true;

-- -----------------------------------------------------------------------------
-- 3. AUTH_OTPS TABLE
-- Tracks short-lived 6-digit OTP verification challenges for SMS login.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS auth_otps (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number VARCHAR(20) NOT NULL,
    otp_hash VARCHAR(64) NOT NULL, -- SHA-256 hash of 6-digit OTP
    attempts INTEGER NOT NULL DEFAULT 0,
    expires_at TIMESTAMPTZ NOT NULL,
    verified_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_auth_otps_phone ON auth_otps(phone_number, expires_at);

-- -----------------------------------------------------------------------------
-- 4. USER_SESSIONS TABLE
-- Stores authenticated sessions using hashed session tokens.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_token_hash VARCHAR(64) UNIQUE NOT NULL, -- SHA-256 hash of session token
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_active_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_user_sessions_hash ON user_sessions(session_token_hash);
CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON user_sessions(user_id);

-- -----------------------------------------------------------------------------
-- 5. FACE_LIVENESS_SESSIONS TABLE
-- Audits biometric verification sessions with AWS Rekognition.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS face_liveness_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    aws_session_id VARCHAR(128) UNIQUE NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'created' 
        CHECK (status IN ('created', 'passed', 'failed', 'expired')),
    confidence_score NUMERIC(5,2),
    similarity_score NUMERIC(5,2),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_liveness_user_id ON face_liveness_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_liveness_aws_session ON face_liveness_sessions(aws_session_id);

-- -----------------------------------------------------------------------------
-- 6. USER_AUDIT_LOGS TABLE
-- Security audit trail for key identity & state transitions (no PII logged).
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(64) NOT NULL, -- e.g., 'OTP_SENT', 'OTP_VERIFIED', 'FACE_VERIFIED'
    ip_address VARCHAR(45),
    user_agent VARCHAR(256),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON user_audit_logs(user_id);
