-- =============================================================
-- Helpdesk Ticket System - Business Logic
-- Stored Procedures, Triggers, Views
-- =============================================================

-- =============================================================
-- VIEWS
-- =============================================================

-- Full ticket detail (joins all related tables)
CREATE OR REPLACE VIEW v_tickets_full AS
SELECT
    t.id,
    t.title,
    t.status,
    t.priority,
    c.name                                      AS category,
    c.sla_hours,
    u_req.full_name                             AS requester,
    u_req.department,
    u_tech.full_name                            AS technician,
    t.created_at,
    t.updated_at,
    t.resolved_at,
    t.due_at,
    -- SLA breach flag
    CASE
        WHEN t.status IN ('resolved', 'closed') THEN
            t.resolved_at > t.due_at
        ELSE
            NOW() > t.due_at
    END                                         AS sla_breached,
    -- Resolution time in hours (NULL if not resolved)
    ROUND(
        EXTRACT(EPOCH FROM (t.resolved_at - t.created_at)) / 3600.0, 1
    )                                           AS resolution_hours
FROM tickets t
JOIN users      u_req  ON u_req.id  = t.created_by
LEFT JOIN users u_tech ON u_tech.id = t.assigned_to
LEFT JOIN categories c ON c.id      = t.category_id;

-- Technician workload summary
CREATE OR REPLACE VIEW v_technician_workload AS
SELECT
    u.id,
    u.full_name,
    COUNT(t.id)                                                        AS total_assigned,
    COUNT(t.id) FILTER (WHERE t.status = 'open')                       AS open_tickets,
    COUNT(t.id) FILTER (WHERE t.status = 'in_progress')               AS in_progress_tickets,
    COUNT(t.id) FILTER (WHERE t.status = 'pending')                    AS pending_tickets,
    COUNT(t.id) FILTER (WHERE t.priority = 'critical'
                          AND t.status NOT IN ('resolved','closed'))   AS active_critical,
    ROUND(AVG(
        EXTRACT(EPOCH FROM (t.resolved_at - t.created_at)) / 3600.0
    ) FILTER (WHERE t.resolved_at IS NOT NULL), 1)                     AS avg_resolution_hours
FROM users u
LEFT JOIN tickets t ON t.assigned_to = u.id
WHERE u.role IN ('technician', 'admin')
GROUP BY u.id, u.full_name;

-- =============================================================
-- STORED PROCEDURES
-- =============================================================

-- Create a new ticket (calculates due_at from SLA automatically)
CREATE OR REPLACE PROCEDURE sp_create_ticket(
    p_title        VARCHAR,
    p_description  TEXT,
    p_priority     ticket_priority,
    p_category_id  INTEGER,
    p_created_by   INTEGER,
    OUT p_ticket_id INTEGER
)
LANGUAGE plpgsql AS $$
DECLARE
    v_sla_hours INTEGER;
BEGIN
    -- Get SLA hours for category (default 24 if category not found)
    SELECT COALESCE(sla_hours, 24)
    INTO v_sla_hours
    FROM categories
    WHERE id = p_category_id;

    INSERT INTO tickets (title, description, priority, category_id, created_by, due_at)
    VALUES (p_title, p_description, p_priority, p_category_id, p_created_by, NOW() + (v_sla_hours || ' hours')::INTERVAL)
    RETURNING id INTO p_ticket_id;

    RAISE NOTICE 'Ticket #% created. Due at: %', p_ticket_id, NOW() + (v_sla_hours || ' hours')::INTERVAL;
END;
$$;

-- Assign ticket to a technician (logs the change)
CREATE OR REPLACE PROCEDURE sp_assign_ticket(
    p_ticket_id    INTEGER,
    p_technician_id INTEGER,
    p_assigned_by  INTEGER
)
LANGUAGE plpgsql AS $$
DECLARE
    v_old_status ticket_status;
BEGIN
    SELECT status INTO v_old_status FROM tickets WHERE id = p_ticket_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Ticket #% not found', p_ticket_id;
    END IF;

    UPDATE tickets
    SET assigned_to = p_technician_id,
        status      = CASE WHEN status = 'open' THEN 'in_progress' ELSE status END,
        updated_at  = NOW()
    WHERE id = p_ticket_id;

    INSERT INTO ticket_updates (ticket_id, author_id, note, old_status, new_status)
    VALUES (
        p_ticket_id,
        p_assigned_by,
        'Ticket assigned to technician ID ' || p_technician_id,
        v_old_status,
        CASE WHEN v_old_status = 'open' THEN 'in_progress' ELSE v_old_status END
    );
END;
$$;

-- Resolve a ticket
CREATE OR REPLACE PROCEDURE sp_resolve_ticket(
    p_ticket_id  INTEGER,
    p_author_id  INTEGER,
    p_note       TEXT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_old_status ticket_status;
BEGIN
    SELECT status INTO v_old_status FROM tickets WHERE id = p_ticket_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Ticket #% not found', p_ticket_id;
    END IF;

    IF v_old_status IN ('resolved', 'closed') THEN
        RAISE EXCEPTION 'Ticket #% is already %', p_ticket_id, v_old_status;
    END IF;

    UPDATE tickets
    SET status      = 'resolved',
        resolved_at = NOW(),
        updated_at  = NOW()
    WHERE id = p_ticket_id;

    INSERT INTO ticket_updates (ticket_id, author_id, note, old_status, new_status)
    VALUES (p_ticket_id, p_author_id, p_note, v_old_status, 'resolved');
END;
$$;

-- =============================================================
-- TRIGGERS
-- =============================================================

-- Auto-update updated_at on every ticket change
CREATE OR REPLACE FUNCTION trg_tickets_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_tickets_updated_at
BEFORE UPDATE ON tickets
FOR EACH ROW EXECUTE FUNCTION trg_tickets_updated_at();

-- Auto-log status changes to ticket_updates (when done via direct UPDATE)
CREATE OR REPLACE FUNCTION trg_tickets_log_status_change()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO ticket_updates (ticket_id, author_id, note, old_status, new_status)
        VALUES (
            NEW.id,
            NEW.assigned_to,
            'Status changed automatically',
            OLD.status,
            NEW.status
        );
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_tickets_log_status_change
AFTER UPDATE OF status ON tickets
FOR EACH ROW EXECUTE FUNCTION trg_tickets_log_status_change();
