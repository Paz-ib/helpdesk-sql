# Helpdesk Ticket System — SQL Portfolio Project

A realistic helpdesk/ticketing database built with **PostgreSQL**, designed to demonstrate
SQL skills relevant to IT Support roles: schema design, stored procedures, triggers, views,
indexes, and analytical reporting queries.

---

## Database Schema

```
users ──────────────────────────────────────────────────────────┐
  id, full_name, email, role (end_user/technician/admin),       │
  department, is_active, created_at                             │
                                                                │
categories                                                      │
  id, name, description, sla_hours                              │
         │                                                      │
         ▼                                                      │
tickets ◄───────────────────────────────────────────────────────┘
  id, title, description, status, priority,                     │
  category_id (FK), created_by (FK), assigned_to (FK),          │
  created_at, updated_at, resolved_at, due_at                   │
         │                                                      │
         ▼                                                      │
ticket_updates                                                  │
  id, ticket_id (FK), author_id (FK),                           │
  note, old_status, new_status, created_at                      │
```

**Enums:** `ticket_status` (open → in_progress → pending → resolved → closed),
`ticket_priority` (low / medium / high / critical), `user_role`.

---

## Files

| File | Contents |
|------|----------|
| `01_schema.sql` | Table definitions, enums, indexes (including a partial index) |
| `02_seed.sql` | Realistic sample data: 20 users, 5 technicians, 20 tickets |
| `03_logic.sql` | Views, stored procedures, triggers |
| `04_queries.sql` | Analytical queries: SLA compliance, technician performance, escalation detection |

---

## Highlights

### Stored Procedures
- `sp_create_ticket` — creates a ticket and auto-calculates `due_at` from the category SLA
- `sp_assign_ticket` — assigns a technician, transitions status to `in_progress`, logs the event
- `sp_resolve_ticket` — closes a ticket with validation and audit log entry

### Triggers
- `trg_tickets_updated_at` — auto-updates `updated_at` on every row change
- `trg_tickets_log_status_change` — auto-inserts into `ticket_updates` on status transitions

### Views
- `v_tickets_full` — complete ticket details including SLA breach flag and resolution time
- `v_technician_workload` — per-technician counts by status and average resolution time

### Analytical Queries
- SLA compliance rate per category
- Technician performance (avg/min/max resolution hours)
- Overdue tickets with hours elapsed past SLA
- Weekly ticket volume trend (last 8 weeks)
- Escalation candidates: unassigned tickets open for more than 2 hours

---

## How to Run

### Prerequisites
- PostgreSQL 14 or later
- `psql` CLI (installed with PostgreSQL)

### macOS — Quick Setup

```bash
# Install PostgreSQL via Homebrew
brew install postgresql@16
brew services start postgresql@16

# Create the database
createdb helpdesk

# Run scripts in order
psql -d helpdesk -f 01_schema.sql
psql -d helpdesk -f 02_seed.sql
psql -d helpdesk -f 03_logic.sql

# Try a query
psql -d helpdesk -f 04_queries.sql
```

### Try the stored procedures

```sql
-- Create a new ticket
CALL sp_create_ticket(
    'Laptop won''t connect to docking station',
    'USB-C dock not detected after Windows update.',
    'high',
    1,   -- category: Hardware
    8,   -- created_by: user ID 8
    NULL -- OUT param
);

-- Assign it (use the ID returned above)
CALL sp_assign_ticket(21, 3, 1);  -- ticket, technician, assigned_by

-- Resolve it
CALL sp_resolve_ticket(21, 3, 'Driver rolled back. Dock now detected correctly.');
```

---

## Design Decisions

**Partial index on open tickets** — `idx_tickets_open` covers only `status IN ('open', 'in_progress')`,
the most frequently queried subset. Reduces index size and speeds up technician dashboards.

**Single `users` table for all roles** — simplifies joins and avoids duplication.
Role-based access control would be enforced at the application layer.

**`due_at` computed at insert time** — SLA deadline is stored rather than calculated at query time,
making overdue detection a simple `WHERE due_at < NOW()` with index support.

**Audit log via trigger + procedure** — status changes are recorded both when using stored
procedures (explicit insert) and direct UPDATEs (via trigger), ensuring no transition is missed.
