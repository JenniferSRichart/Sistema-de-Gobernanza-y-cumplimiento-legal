-- Sistema de Gobernanza y Cumplimiento Legal

--Ejemplo de queries que podemos hacer con los datos

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


