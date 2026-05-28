-- =============================================================
-- Helpdesk Ticket System - Seed Data
-- =============================================================

-- Insert de datos
INSERT INTO ticket_statuses (id) VALUES
    ('open'), ('in_progress'), ('pending'), ('resolved'), ('closed');

INSERT INTO ticket_priorities (id) VALUES
    ('low'), ('medium'), ('high'), ('critical');

INSERT INTO user_roles (id) VALUES
    ('end_user'), ('technician'), ('admin');


INSERT INTO categories (name, description, sla_hours) VALUES
    ('Hardware',         'PC, monitors, peripherals, printers',        8),
    ('Software',         'OS issues, app installs, crashes',           12),
    ('Network',          'Connectivity, VPN, WiFi access',             4),
    ('Access & Accounts','Password resets, permissions, new accounts', 2),
    ('Email',            'Outlook, distribution lists, spam',          8),
    ('Other',            'Anything not covered above',                 24);


INSERT INTO users (full_name, email, role, department) VALUES
    ('Laura Gómez',     'lgomez@company.com',    'admin',       'IT'),
    ('Marcos Díaz',     'mdiaz@company.com',     'admin',       'IT'),
    ('Paula Suárez',    'psuarez@company.com',   'technician',  'IT'),
    ('Nicolás Romero',  'nromero@company.com',   'technician',  'IT'),
    ('Carla Vega',      'cvega@company.com',     'technician',  'IT'),
    ('Tomás Pereyra',   'tpereyra@company.com',  'technician',  'IT'),
    ('Sofía Herrera',   'sherrera@company.com',   'technician',  'IT'),
    ('Julián Castro',   'jcastro@company.com',   'end_user',    'Finance'),
    ('Ana Moreno',      'amoreno@company.com',   'end_user',    'Finance'),
    ('Diego Ruiz',      'druiz@company.com',     'end_user',    'HR'),
    ('Valentina Torres','vtorres@company.com',   'end_user',    'HR'),
    ('Ezequiel Blanco', 'eblanco@company.com',   'end_user',    'Sales'),
    ('Camila Flores',   'cflores@company.com',   'end_user',    'Sales'),
    ('Rodrigo Medina',  'rmedina@company.com',   'end_user',    'Legal'),
    ('Lucía Fernández', 'lfernandez@company.com','end_user',    'Legal'),
    ('Ignacio Sosa',    'isosa@company.com',     'end_user',    'Marketing'),
    ('Agustina Luna',   'aluna@company.com',     'end_user',    'Marketing'),
    ('Fernando Ponce',  'fponce@company.com',    'end_user',    'Operations'),
    ('Natalia Ríos',    'nrios@company.com',     'end_user',    'Operations'),
    ('Hernán Giménez',  'hgimenez@company.com',  'end_user',    'Finance');


INSERT INTO tickets (title, description, status, priority, category_id, created_by, assigned_to, created_at, updated_at, resolved_at, due_at) VALUES
    ('PC no enciende', 'La PC del escritorio no da señal al arrancar.', 'open', 'high', 1, 8, 3, NOW() - INTERVAL '2 hours', NOW() - INTERVAL '2 hours', NULL, NOW() + INTERVAL '6 hours'),
    ('Sin acceso a VPN', 'Desde ayer no puedo conectarme a la VPN corporativa.', 'open', 'critical', 3, 11, NULL, NOW() - INTERVAL '30 minutes', NOW() - INTERVAL '30 minutes', NULL, NOW() + INTERVAL '3.5 hours'),
    ('Instalar Adobe Reader', 'Necesito Adobe Reader para abrir contratos en PDF.', 'open', 'low', 2, 14, 4, NOW() - INTERVAL '5 hours', NOW() - INTERVAL '5 hours', NULL, NOW() + INTERVAL '7 hours'),
    ('Reset de contraseña urgente', 'Bloqueé mi usuario al intentar entrar 3 veces.', 'open', 'high', 4, 9, 5, NOW() - INTERVAL '1 hour', NOW() - INTERVAL '1 hour', NULL, NOW() + INTERVAL '1 hour'),
    ('Monitor con líneas verticales', 'El monitor secundario tiene líneas de colores.', 'open', 'medium', 1, 16, NULL, NOW() - INTERVAL '3 hours', NOW() - INTERVAL '3 hours', NULL, NOW() + INTERVAL '5 hours'),
    ('Outlook no sincroniza', 'El correo deja de recibir mensajes nuevos cada pocas horas.', 'in_progress', 'high', 5, 12, 3, NOW() - INTERVAL '6 hours', NOW() - INTERVAL '1 hour', NULL, NOW() + INTERVAL '2 hours'),
    ('Impresora no imprime en red', 'La impresora del piso 3 no aparece disponible.', 'in_progress', 'medium', 1, 10, 6, NOW() - INTERVAL '1 day', NOW() - INTERVAL '4 hours', NULL, NOW() - INTERVAL '16 hours'),
    ('Error al abrir Excel', 'Excel se cierra solo al abrir archivos con macros.', 'in_progress', 'medium', 2, 13, 4, NOW() - INTERVAL '2 days', NOW() - INTERVAL '6 hours', NULL, NOW() - INTERVAL '1.5 days'),
    ('WiFi no funciona en sala de reuniones', 'Sala B2 sin señal WiFi hace 2 días.', 'in_progress', 'high', 3, 18, 7, NOW() - INTERVAL '2 days', NOW() - INTERVAL '3 hours', NULL, NOW() - INTERVAL '1.9 days'),
    ('Permisos en carpeta compartida', 'No puedo escribir en la carpeta del equipo de Ventas.', 'in_progress', 'medium', 4, 12, 5, NOW() - INTERVAL '3 days', NOW() - INTERVAL '8 hours', NULL, NOW() - INTERVAL '2.9 days'),
    ('Licencia de software vencida', 'Aviso de expiración al abrir AutoCAD.', 'pending', 'medium', 2, 19, 3, NOW() - INTERVAL '4 days', NOW() - INTERVAL '1 day', NULL, NOW() - INTERVAL '3.5 days'),
    ('Teclado con tecla trabada', 'La tecla Enter se queda apretada sola.', 'pending', 'low', 1, 8, 6, NOW() - INTERVAL '5 days', NOW() - INTERVAL '2 days', NULL, NOW() - INTERVAL '4.7 days'),
    ('Sin internet en PC de contabilidad', 'Resuelto: cable de red suelto.', 'resolved', 'high', 3, 20, 4, NOW() - INTERVAL '3 days', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day', NOW() - INTERVAL '2.9 days'),
    ('Nuevo usuario para pasante', 'Usuario creado con permisos de lectura.', 'resolved', 'medium', 4, 2, 5, NOW() - INTERVAL '5 days', NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days', NOW() - INTERVAL '4.9 days'),
    ('Actualización de Windows bloqueada', 'Se deshabilitó la actualización automática por GPO.', 'resolved', 'low', 2, 15, 7, NOW() - INTERVAL '7 days', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days', NOW() - INTERVAL '6.5 days'),
    ('Migración de archivos al nuevo servidor', 'Migración completada sin pérdida de datos.', 'resolved', 'critical', 2, 1, 3, NOW() - INTERVAL '10 days', NOW() - INTERVAL '8 days', NOW() - INTERVAL '8 days', NOW() - INTERVAL '9.6 days'),
    ('PC lenta al arrancar', 'Se limpió inicio y se desinstalaron programas.', 'resolved', 'medium', 2, 17, 6, NOW() - INTERVAL '8 days', NOW() - INTERVAL '7 days', NOW() - INTERVAL '7 days', NOW() - INTERVAL '7.3 days'),
    ('Configurar firma de correo corporativa', 'Firma configurada en Outlook.', 'resolved', 'low', 5, 9, 4, NOW() - INTERVAL '6 days', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5.3 days'),
    ('Solicitud de segundo monitor', 'Monitor instalado y configurado.', 'closed', 'low', 1, 11, 7, NOW() - INTERVAL '15 days', NOW() - INTERVAL '14 days', NOW() - INTERVAL '14 days', NOW() - INTERVAL '14.6 days'),
    ('Error de DNS en sucursal', 'Se corrigió la configuración del servidor DNS secundario.', 'closed', 'critical', 3, 2, 3, NOW() - INTERVAL '20 days', NOW() - INTERVAL '19 days', NOW() - INTERVAL '19 days', NOW() - INTERVAL '19.8 days');


INSERT INTO ticket_updates (ticket_id, author_id, note, old_status, new_status) VALUES
    (6,  3, 'Revisé configuración de Exchange. Veo que el perfil de Outlook está corrupto. Voy a recrearlo.', 'open', 'in_progress'),
    (7,  6, 'La impresora tiene la IP mal asignada. Actualizando en el servidor de impresión.', 'open', 'in_progress'),
    (8,  4, 'El problema es con macros firmados. Revisando política de seguridad de Office.', 'open', 'in_progress'),
    (9,  7, 'Access point del piso 2 resetado. Esperando confirmación del usuario.', 'open', 'in_progress'),
    (10, 5, 'Permisos revisados. Falta aprobación del manager de Ventas para continuar.', 'open', 'in_progress'),
    (11, 3, 'Se contactó al proveedor para renovación de licencia. Esperando respuesta.', 'in_progress', 'pending'),
    (12, 6, 'Teclado enviado a reemplazo. Usuario confirmó recepción del teclado nuevo pero aún no lo probó.', 'in_progress', 'pending'),
    (13, 4, 'Cable de red suelto en patch panel. Reconectado y verificada la conexión.', 'in_progress', 'resolved'),
    (14, 5, 'Usuario creado: druiz_pasante. Contraseña enviada por teléfono.', 'open', 'resolved'),
    (16, 3, 'Migración completada. Se validaron 4.200 archivos sin errores.', 'in_progress', 'resolved'),
    (20, 3, 'Corregido registro DNS PTR faltante. Conectividad restaurada en toda la sucursal.', 'in_progress', 'resolved');
