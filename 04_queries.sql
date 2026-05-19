-- =============================================================
-- Helpdesk Ticket System - Queries
-- =============================================================

-- 1.- Mostrar todos los usuarios registrados en el sistema.

SELECT * FROM users;

--2 Consultar todos los tickets abiertos.
SELECT * FROM tickets
WHERE status = 'open';


-- 2.- Listar todos los tickets abiertos, mostrando su título, prioridad y el nombre del solicitante.
