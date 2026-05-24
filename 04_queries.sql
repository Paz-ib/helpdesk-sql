-- =============================================================
-- Helpdesk Ticket System - Queries
-- =============================================================

-- 1.- Mostrar todos los usuarios registrados en el sistema.

SELECT * FROM users;

-- 2.- Consultar todos los tickets abiertos.
SELECT * FROM tickets
WHERE status = 'open';

-- 3.- Buscar un usuario específico por su nombre completo
SELECT * FROM users
WHERE full_name = 'Agustina Luna';

-- 4.- Listar todos los usuarios que pertenecen al departamento Operations.
SELECT * FROM users
WHERE department = 'Operations';

--5 .- Traer todos los tickets que tengan prioridad 'high' o 'critical' y cuyo estado no sea 'closed'.
SELECT * FROM tickets
WHERE status <> 'closed' 
  AND priority IN ('high', 'critical');

-- 2.- Listar todos los tickets abiertos, mostrando su título, prioridad y el nombre del solicitante.
