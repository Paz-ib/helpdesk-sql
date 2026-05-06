-- =============================================================
-- Helpdesk Ticket System Simulator - Schema / diagram
-- PostgreSQL 14+
-- =============================================================

-- Enums
CREATE TYPE ticket_status   AS ENUM ('open', 'in_progress', 'pending', 'resolved', 'closed');
CREATE TYPE ticket_priority AS ENUM ('low', 'medium', 'high', 'critical');
CREATE TYPE user_role       AS ENUM ('end_user', 'technician', 'admin');

-- Categories
CREATE TABLE categories (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    sla_hours   INTEGER NOT NULL DEFAULT 24  -- SLA target in hours
);

-- Users (both end-users and technicians share this table)
CREATE TABLE users (
    id           SERIAL PRIMARY KEY,
    full_name    VARCHAR(150) NOT NULL,
    email        VARCHAR(255) NOT NULL UNIQUE,
    role         user_role    NOT NULL DEFAULT 'end_user',
    department   VARCHAR(100),
    is_active    BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- Tickets
CREATE TABLE tickets (
    id              SERIAL PRIMARY KEY,
    title           VARCHAR(255)     NOT NULL,
    description     TEXT             NOT NULL,
    status          ticket_status    NOT NULL DEFAULT 'open',
    priority        ticket_priority  NOT NULL DEFAULT 'medium',
    category_id     INTEGER          REFERENCES categories(id) ON DELETE SET NULL,
    created_by      INTEGER          NOT NULL REFERENCES users(id),
    assigned_to     INTEGER          REFERENCES users(id),
    created_at      TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    resolved_at     TIMESTAMPTZ,
    due_at          TIMESTAMPTZ      -- calculated from SLA on insert
);

-- Ticket update log (all comments and status changes)
CREATE TABLE ticket_updates (
    id          SERIAL PRIMARY KEY,
    ticket_id   INTEGER      NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
    author_id   INTEGER      NOT NULL REFERENCES users(id),
    note        TEXT         NOT NULL,
    old_status  ticket_status,
    new_status  ticket_status,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- =============================================================
-- Indexes for common query patterns
-- =============================================================
CREATE INDEX idx_tickets_status        ON tickets(status);
CREATE INDEX idx_tickets_assigned_to   ON tickets(assigned_to);
CREATE INDEX idx_tickets_created_at    ON tickets(created_at DESC);
CREATE INDEX idx_tickets_category      ON tickets(category_id);
CREATE INDEX idx_ticket_updates_ticket ON ticket_updates(ticket_id);

-- Partial index: only open/in-progress tickets (most queried subset)
CREATE INDEX idx_tickets_open ON tickets(assigned_to, priority)
    WHERE status IN ('open', 'in_progress');
