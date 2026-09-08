-- -----------------------------------------------------------------------------
-- 1. EVENTS TABLE
-- Core event record ("Den") mapping to CreateEventDraft from the frontend.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organizer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Basic Details
    title VARCHAR(120) NOT NULL,
    category VARCHAR(50) NOT NULL, -- e.g., 'party', 'event', 'fitness', etc.
    description TEXT,
    banner_url VARCHAR(512),
    gallery_urls JSONB, -- Array of strings
    
    -- Date & Time
    event_date DATE,
    start_time VARCHAR(20),
    end_time VARCHAR(20),
    
    -- Location
    venue_name VARCHAR(120),
    venue_address VARCHAR(256),
    latitude NUMERIC(9, 6),
    longitude NUMERIC(9, 6),
    google_maps_url VARCHAR(512),
    location_mode VARCHAR(50) NOT NULL DEFAULT 'searchedAddress',
    venue_visibility VARCHAR(50) NOT NULL DEFAULT 'alwaysVisible',
    
    -- Audience & Capacity
    exclusivity VARCHAR(50) NOT NULL DEFAULT 'approvedOnly',
    capacity INTEGER, -- null = no limit
    capacity_men INTEGER,
    capacity_women INTEGER,
    capacity_non_binary INTEGER,
    gender_requirement VARCHAR(50) NOT NULL DEFAULT 'all',
    
    -- Rules & Settings
    require_instagram BOOLEAN NOT NULL DEFAULT FALSE,
    require_verification BOOLEAN NOT NULL DEFAULT FALSE,
    alcohol_available BOOLEAN NOT NULL DEFAULT TRUE,
    allow_cancellation BOOLEAN NOT NULL DEFAULT FALSE,
    search_engine_visible BOOLEAN NOT NULL DEFAULT TRUE,
    contact_info VARCHAR(256),
    
    -- Pricing State
    pricing_type VARCHAR(50) NOT NULL DEFAULT 'paid',
    
    -- Status
    status VARCHAR(30) NOT NULL DEFAULT 'draft' 
        CHECK (status IN ('draft', 'published', 'cancelled', 'completed')),
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_events_organizer ON events(organizer_id);
CREATE INDEX IF NOT EXISTS idx_events_date ON events(event_date);
CREATE INDEX IF NOT EXISTS idx_events_status ON events(status);

-- -----------------------------------------------------------------------------
-- 2. EVENT_TICKET_TIERS TABLE
-- Maps to EventTicketTier in CreateEventDraft.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS event_ticket_tiers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    name VARCHAR(120) NOT NULL,
    badge VARCHAR(50) DEFAULT 'SINGLE',
    note VARCHAR(256),
    price NUMERIC(10, 2) NOT NULL DEFAULT 0.0,
    is_limited BOOLEAN NOT NULL DEFAULT FALSE,
    quantity_limit INTEGER,
    quantity_sold INTEGER NOT NULL DEFAULT 0,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_ticket_tiers_event ON event_ticket_tiers(event_id);

-- -----------------------------------------------------------------------------
-- 3. EVENT_COUPONS TABLE
-- Maps to EventCoupon in CreateEventDraft.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS event_coupons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    code VARCHAR(30) NOT NULL,
    discount_type VARCHAR(30) NOT NULL, -- 'percentage' or 'fixedAmount'
    discount_value NUMERIC(10, 2) NOT NULL,
    usage_limit INTEGER,
    used_count INTEGER NOT NULL DEFAULT 0,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(event_id, code)
);

CREATE INDEX IF NOT EXISTS idx_coupons_event ON event_coupons(event_id);

-- -----------------------------------------------------------------------------
-- 4. CHATS TABLE
-- Supports both 1:1 and group chats.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS chats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    is_group BOOLEAN NOT NULL DEFAULT FALSE,
    name VARCHAR(120), -- Used for group chats
    image_url VARCHAR(512),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 5. CHAT_PARTICIPANTS TABLE
-- Join table connecting users to chats.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS chat_participants (
    chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    joined_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (chat_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_chat_participants_user ON chat_participants(user_id);

-- -----------------------------------------------------------------------------
-- 6. CHAT_MESSAGES TABLE
-- Individual messages within a chat.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_delivered BOOLEAN NOT NULL DEFAULT FALSE,
    is_seen BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_chat_messages_chat ON chat_messages(chat_id, created_at DESC);

-- -----------------------------------------------------------------------------
-- 7. TICKET_ORDERS TABLE
-- Scaffolding for future payments phase.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ticket_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    ticket_tier_id UUID NOT NULL REFERENCES event_ticket_tiers(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL DEFAULT 1,
    total_amount NUMERIC(10, 2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'pending' 
        CHECK (status IN ('pending', 'paid', 'refunded', 'cancelled')),
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_ticket_orders_user ON ticket_orders(user_id);
CREATE INDEX IF NOT EXISTS idx_ticket_orders_tier ON ticket_orders(ticket_tier_id);
