-- Sistema de Gobernanza y Cumplimiento Legal
-- Para poder hacer los ejercicios vamos a: 1. Crear las Tablas, 2.Llenar con datos

-- 1. Crear las tablas:

-- Se crea esta tabla para poder referenciar las 3 tablas principales
CREATE TABLE areas (
    id_area INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_area VARCHAR(100) NOT NULL UNIQUE
);

--Creacion de tabla Contratos 
CREATE TABLE contratos (
    id_contrato       INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    proveedor         VARCHAR(150) NOT NULL,
    fecha_inicio      DATE NOT NULL,
    fecha_fin         DATE NOT NULL,
    estado            VARCHAR(50) NOT NULL DEFAULT 'Activo',
    id_area           INTEGER NOT NULL,
    fecha_creacion    DATE NOT NULL DEFAULT CURRENT_DATE,

    CONSTRAINT fk_contrato_area
        FOREIGN KEY (id_area)
        REFERENCES areas(id_area),

    CONSTRAINT chk_fechas
        CHECK (fecha_fin >= fecha_inicio)
);

--Creacion de tabla Derechos Arco
CREATE TABLE derechos_arco (
    id_solicitud     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tipo_derecho     VARCHAR(50) NOT NULL,
    fecha_recepcion  DATE NOT NULL,
    estado           VARCHAR(50) NOT NULL DEFAULT 'Pendiente',
    id_area          INTEGER NOT NULL,
    fecha_creacion   DATE NOT NULL DEFAULT CURRENT_DATE,

    CONSTRAINT fk_derecho_area
        FOREIGN KEY (id_area)
        REFERENCES areas(id_area),

    CONSTRAINT chk_tipo_derecho
        CHECK (tipo_derecho IN ('Acceso', 'Rectificación', 'Cancelación', 'Oposición')),

    CONSTRAINT chk_estado_derecho
        CHECK (estado IN ('Pendiente', 'En proceso', 'Resuelto', 'Rechazado'))
);

--Creacion de tabla Brechas de seguridad
CREATE TABLE brechas_seguridad (
    id_brecha          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fecha              DATE NOT NULL,
    severidad          VARCHAR(20) NOT NULL,
    notificada_aepd    BOOLEAN NOT NULL DEFAULT FALSE,
    id_area            INTEGER NOT NULL,
    fecha_creacion     DATE NOT NULL DEFAULT CURRENT_DATE,

    CONSTRAINT fk_brecha_area
        FOREIGN KEY (id_area)
        REFERENCES areas(id_area),

    CONSTRAINT chk_severidad
        CHECK (severidad IN ('Baja', 'Media', 'Alta', 'Crítica'))
);


--Tablas hijas - tomando en cuenta las 3FN - Se crean estas tablas complementarias

-- Tabla de políticas internas
CREATE TABLE politicas (
    id_politica       INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_politica   VARCHAR(150) NOT NULL,
    id_area           INTEGER NOT NULL,
    estado            VARCHAR(50) NOT NULL DEFAULT 'Pendiente',
    fecha_aprobacion  DATE,
    fecha_creacion    DATE NOT NULL DEFAULT CURRENT_DATE,

    CONSTRAINT fk_politica_area
        FOREIGN KEY (id_area)
        REFERENCES areas(id_area),

    CONSTRAINT chk_estado_politica
        CHECK (estado IN ('Pendiente', 'Aprobada', 'En revisión', 'Obsoleta'))
);

CREATE TABLE revisiones_contrato (
    id_revision     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_contrato     INTEGER NOT NULL,
    fecha_revision  DATE NOT NULL,
    resultado       VARCHAR(50) NOT NULL,
    observaciones   TEXT,

    CONSTRAINT fk_revision_contrato
        FOREIGN KEY (id_contrato)
        REFERENCES contratos(id_contrato)
);

CREATE TABLE evidencias_arco (
    id_evidencia    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_solicitud    INTEGER NOT NULL,
    tipo_evidencia  VARCHAR(100) NOT NULL,
    fecha_registro  DATE NOT NULL DEFAULT CURRENT_DATE,
    descripcion     TEXT,

    CONSTRAINT fk_evidencia_arco
        FOREIGN KEY (id_solicitud)
        REFERENCES derechos_arco(id_solicitud)
);

CREATE TABLE acciones_brecha (
    id_accion     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_brecha     INTEGER NOT NULL,
    descripcion   TEXT NOT NULL,
    responsable   VARCHAR(100) NOT NULL,
    fecha_limite  DATE,
    estado        VARCHAR(50) NOT NULL DEFAULT 'Pendiente',

    CONSTRAINT fk_accion_brecha
        FOREIGN KEY (id_brecha)
        REFERENCES brechas_seguridad(id_brecha)
);

-- Tabla de evidencias asociadas a políticas
CREATE TABLE evidencias_politicas (
    id_evidencia    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_politica     INTEGER NOT NULL,
    fecha_entrega   DATE NOT NULL,
    estado          VARCHAR(50) NOT NULL DEFAULT 'Pendiente',
    descripcion     TEXT,

    CONSTRAINT fk_evidencia_politica
        FOREIGN KEY (id_politica)
        REFERENCES politicas(id_politica),

    CONSTRAINT chk_estado_evidencia_politica
        CHECK (estado IN ('Pendiente', 'Entregada', 'Rechazada', 'En revisión'))
);

-- Tabla de incidencias legales o de compliance
CREATE TABLE incidencias (
    id_incidencia    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_area          INTEGER NOT NULL,
    tipo_incidencia  VARCHAR(100) NOT NULL,
    gravedad         VARCHAR(20) NOT NULL,
    estado           VARCHAR(50) NOT NULL DEFAULT 'Abierta',
    fecha_registro   DATE NOT NULL DEFAULT CURRENT_DATE,

    CONSTRAINT fk_incidencia_area
        FOREIGN KEY (id_area)
        REFERENCES areas(id_area),

    CONSTRAINT chk_gravedad_incidencia
        CHECK (gravedad IN ('Baja', 'Media', 'Alta', 'Crítica')),

    CONSTRAINT chk_estado_incidencia
        CHECK (estado IN ('Abierta', 'En proceso', 'Cerrada', 'Escalada'))
);

-- Tabla de riesgos legales
CREATE TABLE riesgos (
    id_riesgo      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_area        INTEGER NOT NULL,
    categoria      VARCHAR(100) NOT NULL,
    nivel_riesgo   VARCHAR(20) NOT NULL,
    estado         VARCHAR(50) NOT NULL DEFAULT 'Abierto',
    fecha_creacion DATE NOT NULL DEFAULT CURRENT_DATE,

    CONSTRAINT fk_riesgo_area
        FOREIGN KEY (id_area)
        REFERENCES areas(id_area),

    CONSTRAINT chk_nivel_riesgo
        CHECK (nivel_riesgo IN ('Bajo', 'Medio', 'Alto', 'Crítico')),

    CONSTRAINT chk_estado_riesgo
        CHECK (estado IN ('Abierto', 'En seguimiento', 'Mitigado', 'Cerrado'))
);


-- 1.1 Verificacion de Tablas
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
    'areas',
    'contratos',
    'derechos_arco',
    'brechas_seguridad',
    'acciones_brecha',
    'evidencias_arco',
    'revisiones_contrato',
    'politicas',
    'evidencias_politicas',
    'incidencias',
    'riesgos'
  )
ORDER BY table_name;

-- 1.2 Ver estructura de una tabla (Ejemplo: Contratos)
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'contratos'
ORDER BY ordinal_position;


-- 2. Cargar datos a las tablas


INSERT INTO areas (nombre_area) VALUES
('Legal'),
('Compliance'),
('Gobernanza'),
('Auditoría Interna'),
('Protección de Datos'),
('Seguridad de la Información'),
('Riesgos'),
('Finanzas'),
('Compras'),
('Operaciones')
RETURNING id_area, nombre_area;

INSERT INTO contratos (
    proveedor,
    fecha_inicio,
    fecha_fin,
    estado,
    id_area
) VALUES
('Accenture', '2024-01-01', '2026-12-31', 'Activo', 1),
('Deloitte', '2023-06-15', '2025-06-14', 'Activo', 2),
('PwC', '2022-03-01', '2024-03-01', 'Vencido', 3),
('KPMG', '2024-09-01', '2027-08-31', 'Activo', 4),
('Telefónica Tech', '2023-11-01', '2026-10-31', 'Activo', 6),
('Indra', '2022-05-10', '2025-05-09', 'Activo', 7),
('IBM', '2024-02-01', '2026-01-31', 'Activo', 6),
('Microsoft', '2023-01-01', '2024-12-31', 'Vencido', 6),
('Capgemini', '2024-07-01', '2027-06-30', 'Activo', 8),
('Everis', '2023-03-15', '2026-03-14', 'En revisión', 9)
RETURNING id_contrato, proveedor, estado;

INSERT INTO brechas_seguridad (
    fecha,
    severidad,
    notificada_aepd,
    id_area
) VALUES
('2024-01-15', 'Alta', TRUE, 6),
('2024-02-10', 'Media', FALSE, 6),
('2024-03-05', 'Crítica', TRUE, 5),
('2024-03-20', 'Baja', FALSE, 7),
('2024-04-12', 'Alta', TRUE, 6),
('2024-05-01', 'Media', FALSE, 8),
('2024-05-18', 'Crítica', TRUE, 5),
('2024-06-07', 'Alta', FALSE, 6),
('2024-06-25', 'Baja', FALSE, 9),
('2024-07-10', 'Media', TRUE, 6)
RETURNING id_brecha, severidad, notificada_aepd;

INSERT INTO derechos_arco (
    tipo_derecho,
    fecha_recepcion,
    estado,
    id_area
) VALUES
('Acceso', '2024-01-10', 'Resuelto', 5),
('Rectificación', '2024-01-25', 'En proceso', 5),
('Cancelación', '2024-02-05', 'Pendiente', 5),
('Oposición', '2024-02-18', 'Resuelto', 6),
('Acceso', '2024-03-02', 'En proceso', 5),
('Rectificación', '2024-03-15', 'Rechazado', 5),
('Cancelación', '2024-04-01', 'Pendiente', 6),
('Acceso', '2024-04-20', 'Resuelto', 5),
('Oposición', '2024-05-05', 'En proceso', 5),
('Rectificación', '2024-05-22', 'Pendiente', 6)
RETURNING id_solicitud, tipo_derecho, estado;

INSERT INTO revisiones_contrato (
    id_contrato,
    fecha_revision,
    resultado,
    observaciones
) VALUES
(1, '2024-02-01', 'Aprobado', 'Contrato conforme a normativa vigente'),
(1, '2025-01-15', 'Observado', 'Se recomienda actualizar cláusulas de protección de datos'),
(2, '2024-07-10', 'Aprobado', 'Sin incidencias detectadas'),
(3, '2023-03-01', 'Rechazado', 'Falta documentación obligatoria'),
(4, '2024-10-05', 'Aprobado', 'Contrato revisado y validado'),
(5, '2024-01-20', 'Observado', 'Revisar anexos técnicos'),
(6, '2023-12-15', 'Aprobado', 'Cumple requisitos legales'),
(7, '2024-03-10', 'Aprobado', 'Sin observaciones'),
(8, '2023-11-01', 'Observado', 'Pendiente revisión de seguridad'),
(10, '2024-04-22', 'Aprobado', 'Validación completa')
RETURNING id_revision, id_contrato, resultado;

INSERT INTO evidencias_arco (
    id_solicitud,
    tipo_evidencia,
    fecha_registro,
    descripcion
) VALUES
(1, 'Email respuesta', '2024-01-12', 'Respuesta enviada al solicitante'),
(2, 'Documento adjunto', '2024-01-28', 'Se solicita documentación adicional'),
(3, 'Registro sistema', '2024-02-07', 'Solicitud registrada en sistema interno'),
(4, 'Email respuesta', '2024-02-20', 'Resolución comunicada al usuario'),
(5, 'Informe legal', '2024-03-05', 'Evaluación jurídica realizada'),
(6, 'Documento adjunto', '2024-03-18', 'Rechazo documentado con justificación'),
(7, 'Registro sistema', '2024-04-02', 'Solicitud en proceso pendiente'),
(8, 'Email respuesta', '2024-04-22', 'Confirmación de cierre enviada'),
(9, 'Informe legal', '2024-05-07', 'Análisis de oposición realizado'),
(10, 'Documento adjunto', '2024-05-25', 'Solicitud aún en revisión')
RETURNING id_evidencia, id_solicitud, tipo_evidencia;

INSERT INTO acciones_brecha (
    id_brecha,
    descripcion,
    responsable,
    fecha_limite,
    estado
) VALUES
(1, 'Notificación a AEPD y análisis inicial del incidente', 'Equipo Legal', '2024-01-20', 'Completada'),
(2, 'Revisión de accesos no autorizados y actualización de credenciales', 'IT Seguridad', '2024-02-20', 'En proceso'),
(3, 'Activación de protocolo de crisis y comunicación a afectados', 'Compliance', '2024-03-07', 'Completada'),
(4, 'Evaluación de impacto y documentación de incidente menor', 'Riesgos', '2024-03-25', 'Pendiente'),
(5, 'Revisión de políticas de seguridad y formación interna', 'IT Seguridad', '2024-04-20', 'En proceso'),
(6, 'Auditoría interna tras incidente de nivel medio', 'Auditoría Interna', '2024-05-10', 'Pendiente'),
(7, 'Notificación urgente a AEPD y mitigación inmediata', 'Legal', '2024-05-20', 'Completada'),
(8, 'Implementación de doble factor de autenticación', 'IT Seguridad', '2024-06-15', 'En proceso'),
(9, 'Revisión de logs y análisis forense', 'IT Seguridad', '2024-07-01', 'Pendiente'),
(10, 'Actualización de procedimientos y reporte final', 'Compliance', '2024-07-20', 'Pendiente')
RETURNING id_accion, id_brecha, estado;


INSERT INTO politicas (
    nombre_politica,
    id_area,
    estado,
    fecha_aprobacion
) VALUES
('Política de Protección de Datos', 5, 'Aprobada', '2024-01-15'),
('Política de Seguridad de la Información', 6, 'Aprobada', '2024-02-01'),
('Código Ético Corporativo', 1, 'Aprobada', '2023-11-20'),
('Política de Prevención de Riesgos Legales', 7, 'En revisión', NULL),
('Política de Compras Responsables', 9, 'Aprobada', '2024-03-10'),
('Política de Auditoría Interna', 4, 'Aprobada', '2024-04-05'),
('Política de Gobierno Corporativo', 3, 'En revisión', NULL),
('Política de Compliance Penal', 2, 'Aprobada', '2024-01-30'),
('Política Financiera Interna', 8, 'Pendiente', NULL),
('Política Operativa de Continuidad', 10, 'Obsoleta', '2022-06-15')
RETURNING id_politica, nombre_politica, estado;

INSERT INTO evidencias_politicas (
    id_politica,
    fecha_entrega,
    estado,
    descripcion
) VALUES
(1, '2024-01-20', 'Entregada', 'Documento aprobado y publicado internamente'),
(2, '2024-02-05', 'Entregada', 'Evidencia de comunicación al personal'),
(3, '2023-11-25', 'Entregada', 'Acta de aprobación del comité'),
(4, '2024-04-15', 'En revisión', 'Pendiente validación por área de riesgos'),
(5, '2024-03-15', 'Entregada', 'Registro de aceptación de proveedores'),
(6, '2024-04-10', 'Entregada', 'Informe de auditoría asociado'),
(7, '2024-05-01', 'Pendiente', 'Pendiente entrega de documentación final'),
(8, '2024-02-03', 'Entregada', 'Evidencia de formación en compliance'),
(9, '2024-05-20', 'Pendiente', 'Pendiente revisión financiera'),
(10, '2024-06-01', 'Rechazada', 'Documento desactualizado')
RETURNING id_evidencia, id_politica, estado;

INSERT INTO incidencias (
    id_area,
    tipo_incidencia,
    gravedad,
    estado,
    fecha_registro
) VALUES
(1, 'Incumplimiento contractual', 'Alta', 'Abierta', '2024-01-18'),
(2, 'Posible incumplimiento normativo', 'Crítica', 'Escalada', '2024-02-12'),
(5, 'Solicitud RGPD fuera de plazo', 'Alta', 'En proceso', '2024-03-03'),
(6, 'Acceso no autorizado', 'Crítica', 'Abierta', '2024-03-18'),
(4, 'Hallazgo de auditoría', 'Media', 'En proceso', '2024-04-08'),
(7, 'Riesgo no mitigado', 'Alta', 'Abierta', '2024-04-25'),
(9, 'Falta de documentación contractual', 'Media', 'Cerrada', '2024-05-10'),
(8, 'Error en validación financiera', 'Baja', 'Cerrada', '2024-05-28'),
(10, 'Incidencia operativa con impacto legal', 'Media', 'Abierta', '2024-06-15'),
(3, 'Falta de aprobación de política interna', 'Alta', 'En proceso', '2024-07-01')
RETURNING id_incidencia, tipo_incidencia, gravedad, estado;

INSERT INTO incidencias (
    id_area,
    tipo_incidencia,
    gravedad,
    estado,
    fecha_registro
) VALUES
(1, 'Incumplimiento contractual', 'Alta', 'Abierta', '2024-01-18'),
(2, 'Posible incumplimiento normativo', 'Crítica', 'Escalada', '2024-02-12'),
(5, 'Solicitud RGPD fuera de plazo', 'Alta', 'En proceso', '2024-03-03'),
(6, 'Acceso no autorizado', 'Crítica', 'Abierta', '2024-03-18'),
(4, 'Hallazgo de auditoría', 'Media', 'En proceso', '2024-04-08'),
(7, 'Riesgo no mitigado', 'Alta', 'Abierta', '2024-04-25'),
(9, 'Falta de documentación contractual', 'Media', 'Cerrada', '2024-05-10'),
(8, 'Error en validación financiera', 'Baja', 'Cerrada', '2024-05-28'),
(10, 'Incidencia operativa con impacto legal', 'Media', 'Abierta', '2024-06-15'),
(3, 'Falta de aprobación de política interna', 'Alta', 'En proceso', '2024-07-01')
RETURNING id_incidencia, tipo_incidencia, gravedad, estado;




--1. Listado de áreas
SELECT id_area, nombre_area
FROM areas;
--2. Políticas aprobadas
SELECT nombre_politica, id_area, fecha_aprobacion
FROM politicas
WHERE estado = 'Aprobada';
--3. Contratos activos
SELECT proveedor, fecha_inicio, fecha_fin, id_area
FROM contratos
WHERE estado = 'Activo';
--4. Brechas críticas no notificadas
SELECT id_brecha, fecha, severidad, notificada_aepd
FROM brechas_seguridad
WHERE severidad = 'Crítica'
  AND notificada_aepd = FALSE;
--5. Derechos ARCO pendientes
SELECT id_solicitud, tipo_derecho, fecha_recepcion, id_area
FROM derechos_arco
WHERE estado = 'Pendiente';
--6. Riesgos legales altos abiertos
SELECT id_riesgo, id_area, categoria, nivel_riesgo, estado
FROM riesgos
WHERE nivel_riesgo = 'Alto'
  AND estado <> 'Cerrado';
--7. Políticas con nombre de área
SELECT p.nombre_politica, p.estado, a.nombre_area
FROM politicas p
JOIN areas a
  ON p.id_area = a.id_area;
--8. Contratos con área responsable
SELECT c.proveedor, c.estado, c.fecha_fin, a.nombre_area
FROM contratos c
JOIN areas a
  ON c.id_area = a.id_area;
--9. Incidencias abiertas por área
SELECT i.tipo_incidencia, i.gravedad, i.fecha_registro, a.nombre_area
FROM incidencias i
JOIN areas a
  ON i.id_area = a.id_area
WHERE i.estado = 'Abierta';
--10. Revisiones de contratos
SELECT c.proveedor, r.fecha_revision, r.resultado, r.observaciones
FROM contratos c
JOIN revisiones_contrato r
  ON c.id_contrato = r.id_contrato;
--11. Acciones asociadas a brechas
SELECT b.id_brecha, b.severidad, a.descripcion, a.responsable, a.estado
FROM brechas_seguridad b
JOIN acciones_brecha a
  ON b.id_brecha = a.id_brecha;
--12. Evidencias asociadas a solicitudes ARCO
SELECT d.id_solicitud, d.tipo_derecho, d.estado, e.tipo_evidencia, e.fecha_registro
FROM derechos_arco d
JOIN evidencias_arco e
  ON d.id_solicitud = e.id_solicitud;
--13. Contratos sin revisión legal
SELECT c.id_contrato, c.proveedor, c.estado
FROM contratos c
LEFT JOIN revisiones_contrato r
  ON c.id_contrato = r.id_contrato
WHERE r.id_revision IS NULL;
--14. Políticas sin evidencia
SELECT p.id_politica, p.nombre_politica, p.estado
FROM politicas p
LEFT JOIN evidencias_politicas e
  ON p.id_politica = e.id_politica
WHERE e.id_evidencia IS NULL;
--15. Número de contratos por área
SELECT a.nombre_area, COUNT(c.id_contrato) AS total_contratos
FROM areas a
JOIN contratos c
  ON a.id_area = c.id_area
GROUP BY a.nombre_area;
--16. Brechas por severidad
SELECT severidad, COUNT(*) AS total_brechas
FROM brechas_seguridad
GROUP BY severidad;
--17. Solicitudes ARCO por tipo de derecho
SELECT tipo_derecho, COUNT(*) AS total_solicitudes
FROM derechos_arco
GROUP BY tipo_derecho;
--18. Riesgos por categoría
SELECT categoria, COUNT(*) AS total_riesgos
FROM riesgos
GROUP BY categoria;
--19. Evidencias ARCO por tipo
SELECT tipo_evidencia, COUNT(*) AS total_evidencias
FROM evidencias_arco
GROUP BY tipo_evidencia;
--20. Evidencias de políticas por estado
SELECT estado, COUNT(*) AS total_evidencias
FROM evidencias_politicas
GROUP BY estado;
--21. Revisiones de contrato por resultado
SELECT resultado, COUNT(*) AS total_revisiones
FROM revisiones_contrato
GROUP BY resultado;
--22. Acciones de brecha por responsable
SELECT responsable, COUNT(*) AS total_acciones
FROM acciones_brecha
GROUP BY responsable;
--23. Áreas con más de una incidencia abierta
SELECT a.nombre_area, COUNT(i.id_incidencia) AS incidencias_abiertas
FROM areas a
JOIN incidencias i
  ON a.id_area = i.id_area
WHERE i.estado = 'Abierta'
GROUP BY a.nombre_area
HAVING COUNT(i.id_incidencia) > 1;
--24. Proveedores con más de un contrato activo
SELECT proveedor, COUNT(*) AS contratos_activos
FROM contratos
WHERE estado = 'Activo'
GROUP BY proveedor
HAVING COUNT(*) > 1;
--25. Áreas con riesgos altos o críticos abiertos
SELECT a.nombre_area, COUNT(r.id_riesgo) AS riesgos_relevantes
FROM areas a
JOIN riesgos r
  ON a.id_area = r.id_area
WHERE r.nivel_riesgo IN ('Alto', 'Crítico')
  AND r.estado <> 'Cerrado'
GROUP BY a.nombre_area
HAVING COUNT(r.id_riesgo) >= 1;
--26. Áreas con políticas aprobadas y evidencias pendientes
SELECT a.nombre_area, COUNT(e.id_evidencia) AS evidencias_pendientes
FROM areas a
JOIN politicas p
  ON a.id_area = p.id_area
JOIN evidencias_politicas e
  ON p.id_politica = e.id_politica
WHERE p.estado = 'Aprobada'
  AND e.estado = 'Pendiente'
GROUP BY a.nombre_area;
--27. Brechas con acciones pendientes
SELECT b.id_brecha, b.severidad, COUNT(a.id_accion) AS acciones_no_completadas
FROM brechas_seguridad b
JOIN acciones_brecha a
  ON b.id_brecha = a.id_brecha
WHERE a.estado IN ('Pendiente', 'En proceso')
GROUP BY b.id_brecha, b.severidad;
--28. Solicitudes ARCO no resueltas con evidencias
SELECT d.id_solicitud, d.tipo_derecho, d.estado, COUNT(e.id_evidencia) AS total_evidencias
FROM derechos_arco d
LEFT JOIN evidencias_arco e
  ON d.id_solicitud = e.id_solicitud
WHERE d.estado <> 'Resuelto'
GROUP BY d.id_solicitud, d.tipo_derecho, d.estado;
--29. Ranking de áreas con incidencias críticas
SELECT a.nombre_area, COUNT(i.id_incidencia) AS incidencias_criticas
FROM areas a
JOIN incidencias i
  ON a.id_area = i.id_area
WHERE i.gravedad = 'Crítica'
GROUP BY a.nombre_area
ORDER BY incidencias_criticas DESC;
--30. Consulta final: semáforo de cumplimiento por área
SELECT a.nombre_area,
       COUNT(DISTINCT c.id_contrato) AS contratos_activos,
       COUNT(DISTINCT b.id_brecha) AS brechas_criticas,
       COUNT(DISTINCT d.id_solicitud) AS derechos_arco_pendientes,
       COUNT(DISTINCT i.id_incidencia) AS incidencias_abiertas,
       COUNT(DISTINCT r.id_riesgo) AS riesgos_relevantes
FROM areas a
LEFT JOIN contratos c
  ON a.id_area = c.id_area
 AND c.estado = 'Activo'
LEFT JOIN brechas_seguridad b
  ON a.id_area = b.id_area
 AND b.severidad = 'Crítica'
LEFT JOIN derechos_arco d
  ON a.id_area = d.id_area
 AND d.estado = 'Pendiente'
LEFT JOIN incidencias i
  ON a.id_area = i.id_area
 AND i.estado = 'Abierta'
LEFT JOIN riesgos r
  ON a.id_area = r.id_area
 AND r.nivel_riesgo IN ('Alto', 'Crítico')
 AND r.estado <> 'Cerrado'
GROUP BY a.nombre_area
ORDER BY a.nombre_area;


