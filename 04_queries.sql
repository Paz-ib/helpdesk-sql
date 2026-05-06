-- =============================================================
-- Helpdesk Ticket System - Analytical Queries
-- =============================================================

-- ------------------------------------------------------------
-- 1. Dashboard: ticket count by status
-- ------------------------------------------------------------
SELECT
    status,
    COUNT(*)                                                AS total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1)    AS pct
FROM tickets
GROUP BY status
ORDER BY total DESC;

-- ------------------------------------------------------------
-- 2. SLA compliance rate per category
-- ------------------------------------------------------------
SELECT
    c.name                                                  AS category,
    COUNT(t.id)                                             AS total_tickets,
    COUNT(t.id) FILTER (WHERE
        t.resolved_at IS NOT NULL
        AND t.resolved_at <= t.due_at)                      AS resolved_within_sla,
    ROUND(
        COUNT(t.id) FILTER (WHERE
            t.resolved_at IS NOT NULL
            AND t.resolved_at <= t.due_at) * 100.0
        / NULLIF(COUNT(t.id) FILTER (WHERE t.resolved_at IS NOT NULL), 0),
        1)                                                  AS sla_compliance_pct
FROM tickets t
JOIN categories c ON c.id = t.category_id
GROUP BY c.name
ORDER BY sla_compliance_pct DESC NULLS LAST;

-- ------------------------------------------------------------
-- 3. Technician performance: avg resolution time and count
-- ------------------------------------------------------------
SELECT
    u.full_name                                             AS technician,
    COUNT(t.id)                                             AS tickets_handled,
    ROUND(AVG(
        EXTRACT(EPOCH FROM (t.resolved_at - t.created_at)) / 3600.0
    ), 1)                                                   AS avg_resolution_hours,
    MIN(ROUND(
        EXTRACT(EPOCH FROM (t.resolved_at - t.created_at)) / 3600.0, 1)
    )                                                       AS fastest_hours,
    MAX(ROUND(
        EXTRACT(EPOCH FROM (t.resolved_at - t.created_at)) / 3600.0, 1)
    )                                                       AS slowest_hours
FROM tickets t
JOIN users u ON u.id = t.assigned_to
WHERE t.resolved_at IS NOT NULL
GROUP BY u.full_name
ORDER BY avg_resolution_hours ASC;

-- ------------------------------------------------------------
-- 4. Overdue open tickets (SLA breached)
-- ------------------------------------------------------------
SELECT
    t.id,
    t.title,
    t.priority,
    c.name                                                  AS category,
    u.full_name                                             AS requester,
    u_tech.full_name                                        AS technician,
    t.due_at,
    ROUND(
        EXTRACT(EPOCH FROM (NOW() - t.due_at)) / 3600.0, 1
    )                                                       AS hours_overdue
FROM tickets t
JOIN users       u      ON u.id      = t.created_by
LEFT JOIN users  u_tech ON u_tech.id = t.assigned_to
LEFT JOIN categories c  ON c.id      = t.category_id
WHERE t.status NOT IN ('resolved', 'closed')
  AND t.due_at < NOW()
ORDER BY t.due_at ASC;

-- ------------------------------------------------------------
-- 5. Weekly ticket volume (last 8 weeks)
-- ------------------------------------------------------------
SELECT
    DATE_TRUNC('week', created_at)::DATE                   AS week_start,
    COUNT(*)                                               AS tickets_created,
    COUNT(*) FILTER (WHERE priority = 'critical')          AS critical,
    COUNT(*) FILTER (WHERE priority = 'high')              AS high,
    COUNT(*) FILTER (WHERE status IN ('resolved','closed')) AS resolved_same_week
FROM tickets
WHERE created_at >= NOW() - INTERVAL '8 weeks'
GROUP BY DATE_TRUNC('week', created_at)
ORDER BY week_start DESC;

-- ------------------------------------------------------------
-- 6. Top departments generating tickets
-- ------------------------------------------------------------
SELECT
    u.department,
    COUNT(t.id)                                            AS tickets_opened,
    COUNT(t.id) FILTER (WHERE t.priority IN ('high','critical')) AS high_priority,
    ROUND(AVG(
        EXTRACT(EPOCH FROM (t.resolved_at - t.created_at)) / 3600.0
    ), 1)                                                  AS avg_resolution_hours
FROM tickets t
JOIN users u ON u.id = t.created_by
WHERE u.department IS NOT NULL
GROUP BY u.department
ORDER BY tickets_opened DESC;

-- ------------------------------------------------------------
-- 7. Unassigned open tickets older than 2 hours (escalation candidates)
-- ------------------------------------------------------------
SELECT
    t.id,
    t.title,
    t.priority,
    c.name                                                 AS category,
    u.full_name                                            AS requester,
    t.created_at,
    ROUND(
        EXTRACT(EPOCH FROM (NOW() - t.created_at)) / 3600.0, 1
    )                                                      AS hours_open
FROM tickets t
JOIN users u        ON u.id = t.created_by
LEFT JOIN categories c ON c.id = t.category_id
WHERE t.assigned_to IS NULL
  AND t.status = 'open'
  AND t.created_at < NOW() - INTERVAL '2 hours'
ORDER BY
    CASE t.priority
        WHEN 'critical' THEN 1
        WHEN 'high'     THEN 2
        WHEN 'medium'   THEN 3
        ELSE 4
    END,
    t.created_at ASC;

-- ------------------------------------------------------------
-- 8. Full audit trail for a specific ticket (change log)
-- ------------------------------------------------------------
SELECT
    tu.created_at,
    u.full_name                                            AS author,
    tu.note,
    tu.old_status,
    tu.new_status
FROM ticket_updates tu
JOIN users u ON u.id = tu.author_id
WHERE tu.ticket_id = 6   -- replace with any ticket ID
ORDER BY tu.created_at ASC;
