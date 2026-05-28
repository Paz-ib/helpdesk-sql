# Helpdesk Ticket System — Proyecto SQL

Base de datos de tickets de soporte IT diseñada con **PostgreSQL** para demostrar habilidades SQL: diseño de esquema, relaciones, claves foráneas, índices y consultas analíticas.

---

## Esquema de la base de datos

```
users ──────────────────────────────────────────┐
  id, full_name, email, role, department,        │
  is_active, created_at                          │
                                                 │
categories                                       │
  id, name, description, sla_hours               │
         │                                       │
         ▼                                       │
tickets ◄────────────────────────────────────────┘
  id, title, description, status, priority,
  category_id (FK), created_by (FK),
  assigned_to (FK), created_at, updated_at,
  resolved_at, due_at
         │
         ▼
ticket_updates
  id, ticket_id (FK), author_id (FK),
  note, old_status, new_status, created_at
```

**Tablas maestras** (reemplazan ENUMs): `ticket_statuses`, `ticket_priorities`, `user_roles` — contienen los valores permitidos como datos reales, visibles con `SELECT`.

---

## Archivos

| Archivo | Contenido |
|---------|-----------|
| `01_schema.sql` | Definición de tablas, claves foráneas, índices (incluye índice parcial) |
| `02_seed.sql` | Datos de prueba: 20 usuarios, 6 categorías, 20 tickets, 11 actualizaciones |
| `04_queries.sql` | Consultas SQL: filtros por estado/prioridad, búsquedas por usuario/departamento |

---

## Consultas destacadas

- Tickets abiertos sin técnico asignado
- Tickets vencidos (SLA breached)
- Tickets por estado con porcentaje
- Usuarios por departamento
- Historial de cambios de un ticket
- Filtros combinados (prioridad + estado)

---

## Cómo ejecutar

### Requisitos
- PostgreSQL 14 o superior
- `psql` CLI

### En macOS

```bash
# Crear la base de datos
createdb helpdesk

# Cargar schema y datos
psql -d helpdesk -f 01_schema.sql
psql -d helpdesk -f 02_seed.sql

# Probar consultas
psql -d helpdesk -f 04_queries.sql

# O entrar al modo interactivo
psql helpdesk
```

Dentro de `psql`:
```sql
\pset pager off   -- evita paginación
SELECT * FROM users;
```

---

## Decisiones de diseño

**Tablas maestras en vez de ENUMs** — los valores permitidos (estados, prioridades, roles) viven en tablas físicas. Esto hace el esquema más portable entre bases de datos y más didáctico: podés consultar los valores con `SELECT * FROM ticket_statuses`.

**Una sola tabla `users`** — tanto usuarios finales como técnicos comparten la misma tabla, diferenciados por el campo `role`. Simplifica joins y evita duplicación.

**Índice parcial en tickets activos** — `idx_tickets_open` solo indexa tickets con estado `open` o `in_progress`, que son el subconjunto más consultado. Ahorra espacio y acelera búsquedas.

**`due_at` calculado al insertar** — la fecha límite SLA se guarda como columna, permitiendo detectar vencimientos con un simple `WHERE due_at < NOW()`.
