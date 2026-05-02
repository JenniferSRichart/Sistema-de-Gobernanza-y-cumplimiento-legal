
# 📊 Sistema de Gobernanza y Cumplimiento Legal

## 🧠 Descripción

Modelo de base de datos relacional orientado a la **gestión de gobernanza, cumplimiento legal y control de riesgos**, integrando contratos, políticas, incidencias, brechas de seguridad, derechos ARCO y evidencias.

Permite análisis, trazabilidad y auditoría mediante SQL en un entorno corporativo.

---

## 🧩 Diagrama del modelo (ERD)

```mermaid
erDiagram

AREAS {
    int id_area PK
    string nombre_area
}

CONTRATOS {
    int id_contrato PK
    string proveedor
    date fecha_inicio
    date fecha_fin
    string estado
    int id_area FK
}

REVISIONES_CONTRATO {
    int id_revision PK
    int id_contrato FK
    date fecha_revision
    string resultado
    string observaciones
}

BRECHAS_SEGURIDAD {
    int id_brecha PK
    date fecha
    string severidad
    boolean notificada_aepd
    int id_area FK
}

ACCIONES_BRECHA {
    int id_accion PK
    int id_brecha FK
    string descripcion
    string responsable
    date fecha_limite
    string estado
}

DERECHOS_ARCO {
    int id_solicitud PK
    string tipo_derecho
    date fecha_recepcion
    string estado
    int id_area FK
}

EVIDENCIAS_ARCO {
    int id_evidencia PK
    int id_solicitud FK
    string tipo_evidencia
    date fecha_registro
    string descripcion
}

POLITICAS {
    int id_politica PK
    string nombre_politica
    int id_area FK
    string estado
    date fecha_aprobacion
}

EVIDENCIAS_POLITICAS {
    int id_evidencia PK
    int id_politica FK
    date fecha_entrega
    string estado
}

INCIDENCIAS {
    int id_incidencia PK
    int id_area FK
    string tipo_incidencia
    string gravedad
    string estado
    date fecha_registro
}

RIESGOS {
    int id_riesgo PK
    int id_area FK
    string categoria
    string nivel_riesgo
    string estado
}

%% RELACIONES

AREAS ||--o{ CONTRATOS : "gestiona"
AREAS ||--o{ BRECHAS_SEGURIDAD : "afecta"
AREAS ||--o{ DERECHOS_ARCO : "gestiona"
AREAS ||--o{ POLITICAS : "define"
AREAS ||--o{ INCIDENCIAS : "registra"
AREAS ||--o{ RIESGOS : "evalua"

CONTRATOS ||--o{ REVISIONES_CONTRATO : "tiene"
BRECHAS_SEGURIDAD ||--o{ ACCIONES_BRECHA : "genera"
DERECHOS_ARCO ||--o{ EVIDENCIAS_ARCO : "documenta"
POLITICAS ||--o{ EVIDENCIAS_POLITICAS : "requiere"
```

---

## 🧠 Interpretación del modelo

* **AREAS** es la tabla central (equivalente a departamentos)

* Cada área gestiona:

  * contratos
  * riesgos
  * incidencias
  * políticas
  * solicitudes ARCO

* Relaciones clave:

  * Un contrato tiene múltiples revisiones
  * Una brecha genera múltiples acciones
  * Una solicitud ARCO tiene múltiples evidencias
  * Una política tiene evidencias de cumplimiento

---

## 🔍 Casos de uso del modelo

Este sistema permite responder preguntas como:

* ¿Qué áreas tienen más riesgos abiertos?
* ¿Existen brechas críticas sin acciones correctivas?
* ¿Hay solicitudes ARCO sin evidencia?
* ¿Qué contratos presentan problemas legales?
* ¿Qué políticas no tienen evidencia de cumplimiento?

---

## 🚀 Ejemplo de consulta

```sql
SELECT a.nombre_area, COUNT(*) AS riesgos_altos
FROM riesgos r
JOIN areas a ON r.id_area = a.id_area
WHERE r.nivel_riesgo = 'Alto'
AND r.estado != 'Cerrado'
GROUP BY a.nombre_area;
```

---

## 💼 Aplicación real

Este modelo es aplicable a:

* Compliance corporativo
* Auditoría interna
* Protección de datos (RGPD)
* Gestión de riesgos
* Departamentos legales

---

## 🎯 Valor del proyecto

* Modelado de datos profesional
* Uso de SQL en escenarios reales
* Enfoque en gobernanza y cumplimiento
* Capacidad analítica aplicada a negocio



---

## 👩‍💻 Autor

Jennifer Sanchez Richart — BI & Data aplicada a gobernanza y compliance




