-- =============================================================
-- Helpdesk Ticket System - 
-- PostgreSQL 14+ 
-- =============================================================

-- Tablas

CREATE TABLE ticket_statuses (
    id VARCHAR(20) PRIMARY KEY
);

CREATE TABLE ticket_priorities (
    id VARCHAR(20) PRIMARY KEY
);

CREATE TABLE user_roles (
    id VARCHAR(20) PRIMARY KEY
);


CREATE TABLE categories (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    sla_hours   INTEGER NOT NULL DEFAULT 24
);


CREATE TABLE users (
    id           SERIAL PRIMARY KEY,
    full_name    VARCHAR(150) NOT NULL,
    email        VARCHAR(255) NOT NULL UNIQUE,
    role         VARCHAR(20)  NOT NULL DEFAULT 'end_user',
    department   VARCHAR(100),
    is_active    BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_user_role FOREIGN KEY (role) REFERENCES user_roles(id)
);


CREATE TABLE tickets (
    id              SERIAL PRIMARY KEY,
    title           VARCHAR(255)    NOT NULL,
    description     TEXT            NOT NULL,
    status          VARCHAR(20)     NOT NULL DEFAULT 'open',
    priority        VARCHAR(20)     NOT NULL DEFAULT 'medium',
    category_id     INTEGER         REFERENCES categories(id) ON DELETE SET NULL,
    created_by      INTEGER         NOT NULL REFERENCES users(id),
    assigned_to     INTEGER         REFERENCES users(id),
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    resolved_at     TIMESTAMPTZ,
    due_at          TIMESTAMPTZ,
    CONSTRAINT fk_ticket_status     FOREIGN KEY (status)   REFERENCES ticket_statuses(id),
    CONSTRAINT fk_ticket_priority   FOREIGN KEY (priority) REFERENCES ticket_priorities(id)
);


CREATE TABLE ticket_updates (
    id          SERIAL PRIMARY KEY,
    ticket_id   INTEGER      NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
    author_id   INTEGER      NOT NULL REFERENCES users(id),
    note        TEXT         NOT NULL,
    old_status  VARCHAR(20),
    new_status  VARCHAR(20),
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_update_old_status FOREIGN KEY (old_status) REFERENCES ticket_statuses(id),
    CONSTRAINT fk_update_new_status FOREIGN KEY (new_status) REFERENCES ticket_statuses(id)
);

