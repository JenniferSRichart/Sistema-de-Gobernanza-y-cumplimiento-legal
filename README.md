
# 📊 Sistema de Gobernanza y Cumplimiento Legal

## 🧠 Descripción

Este proyecto implementa un modelo de base de datos relacional orientado a la **gestión de gobernanza, cumplimiento legal y auditoría**, integrando información sobre contratos, riesgos, brechas de seguridad, derechos ARCO y evidencias.

El objetivo es facilitar la **trazabilidad, control y análisis del cumplimiento normativo** mediante consultas SQL estructuradas.

---

## 🎯 Objetivos del proyecto

* Centralizar información legal y de compliance
* Garantizar trazabilidad de procesos (auditoría)
* Identificar riesgos y posibles incumplimientos
* Facilitar análisis mediante SQL
* Simular un entorno real corporativo

---

## 🏗️ Modelo de datos

El modelo se basa en una arquitectura relacional donde la tabla **`areas`** actúa como eje central.

### 🔗 Relaciones principales

```
AREAS
│
├── CONTRATOS ──── REVISIONES_CONTRATO
│
├── BRECHAS_SEGURIDAD ──── ACCIONES_BRECHA
│
└── DERECHOS_ARCO ──── EVIDENCIAS_ARCO
```

---

## 📘 Tablas principales

### 🏢 AREAS

Define las áreas responsables dentro de la organización.

* id_area (PK)
* nombre_area

---

### 📄 CONTRATOS

Gestión de contratos con proveedores.

* id_contrato (PK)
* proveedor
* fecha_inicio
* fecha_fin
* estado
* id_area (FK)

---

### 📝 REVISIONES_CONTRATO

Histórico de revisiones legales de contratos.

* id_revision (PK)
* id_contrato (FK)
* fecha_revision
* resultado
* observaciones

---

### 🔐 BRECHAS_SEGURIDAD

Registro de incidentes de seguridad.

* id_brecha (PK)
* fecha
* severidad
* notificada_aepd
* id_area (FK)

---

### ⚙️ ACCIONES_BRECHA

Acciones correctivas asociadas a brechas.

* id_accion (PK)
* id_brecha (FK)
* descripcion
* responsable
* fecha_limite
* estado

---

### ⚖️ DERECHOS_ARCO

Gestión de solicitudes de derechos de los usuarios.

* id_solicitud (PK)
* tipo_derecho
* fecha_recepcion
* estado
* id_area (FK)

---

### 📎 EVIDENCIAS_ARCO

Evidencias asociadas a solicitudes ARCO.

* id_evidencia (PK)
* id_solicitud (FK)
* tipo_evidencia
* fecha_registro
* descripcion

---

## 🔍 Funcionalidades del modelo

El sistema permite:

* Seguimiento de contratos y su estado legal
* Control de revisiones jurídicas
* Gestión de brechas de seguridad y su mitigación
* Trazabilidad de solicitudes ARCO
* Registro de evidencias para auditoría
* Análisis de riesgos por área

---

## 🧠 Ejemplos de análisis (SQL)

### 🔥 Contratos activos por área

```sql
SELECT a.nombre_area, COUNT(*)
FROM contratos c
JOIN areas a ON c.id_area = a.id_area
WHERE c.estado = 'Activo'
GROUP BY a.nombre_area;
```

---

### 🔐 Brechas críticas no gestionadas

```sql
SELECT b.id_brecha
FROM brechas_seguridad b
JOIN acciones_brecha a ON b.id_brecha = a.id_brecha
WHERE b.severidad = 'Crítica'
AND a.estado != 'Completada';
```

---

### ⚖️ Solicitudes ARCO sin evidencia

```sql
SELECT d.id_solicitud
FROM derechos_arco d
LEFT JOIN evidencias_arco e
ON d.id_solicitud = e.id_solicitud
WHERE e.id_evidencia IS NULL;
```

---

## 🚀 Tecnologías utilizadas

* SQL (PostgreSQL)
* Modelado relacional
* Diseño de base de datos
* Consultas analíticas

---

## 💼 Aplicación en el mundo real

Este modelo está inspirado en entornos corporativos como:

* Departamentos legales
* Compliance / Gobernanza
* Protección de datos (RGPD)
* Auditoría interna
* Gestión de riesgos

---

## 🎯 Valor del proyecto

Este proyecto demuestra:

* Capacidad de modelado de datos
* Pensamiento analítico
* Aplicación de SQL a casos reales
* Enfoque en cumplimiento normativo

---

## 📌 Posibles mejoras

* Incorporar timestamps de auditoría
* Añadir usuarios/responsables
* Crear vistas analíticas
* Integración con Power BI
* Automatización de alertas

---

## 👩‍💻 Autor

Proyecto desarrollado por Jennifer como parte de su formación en SQL y modelado de datos aplicado a entornos reales de gobernanza y compliance.


