# 🐾 Huellitas Callejeras - Base de Datos (PI-2)

## 📋 Descripción General

Este repositorio contiene la base de datos del proyecto **Huellitas Callejeras**, un sistema integral de gestión de refugios de animales. La base de datos está diseñada en **PostgreSQL** y utiliza un enfoque de **versionado mediante migraciones** para mantener la integridad y trazabilidad de los cambios.

---

## 🏗️ Arquitectura y Justificación del Diseño

### Principios de Diseño

La base de datos ha sido diseñada siguiendo estos principios fundamentales:

1. **Normalización Relacional (3NF)**: Minimiza redundancia de datos
2. **Integridad Referencial**: Foreign keys para mantener consistencia
3. **Validación en Base de Datos**: Constraints para garantizar calidad de datos
4. **Escalabilidad**: Estructura preparada para crecimiento
5. **Auditoria**: Timestamps y trazabilidad de cambios
6. **Seguridad**: Tipos ENUM para evitar inyección de datos inválidos

---

## 📊 Diagrama de Entidades y Relaciones (E-R)

```
┌─────────────────────────────────────────────────────┐
│                    Estructura Lógica                 │
├─────────────────────────────────────────────────────┤
│
│  ┌──────────────┐
│  │   REFUGIOS   │
│  ├──────────────┤
│  │ id_refugio   │◄────────────────────┐
│  │ nombre       │                     │
│  │ capacidad    │                     │
│  │ ubicación    │                     │
│  └──────────────┘                     │
│        ▲                              │
│        │ 1:N                          │
│        │                              │
│  ┌──────────────┐              ┌──────────────┐
│  │  ROLES       │              │  USUARIOS    │
│  ├──────────────┤              ├──────────────┤
│  │ id_roles     │              │ id_usuario   │
│  │ nombre       │              │ nombre       │
│  │ refugio_id   │◄─────────────┤ apellido_p   │
│  └──────────────┘ 1:N          │ apellido_m   │
│        ▲                       │ email        │
│        │ 1:1                   │ activo       │
│        │                       │ rol_id       │
│        │                       │ refugio_id   │
│        │                       └──────────────┘
│        │                              ▲
│        │                              │ 1:N
│        │                              │
│        │                       ┌──────────────┐
│        │                       │  ANIMALES    │
│        └───────────────────────┤ id_animal    │
│                                │ nombre       │
│                                │ especie      │
│                                │ tamano       │
│                                │ sexo         │
│                                │ edad         │
│                                │ peso         │
│                                │ características
│                                │ refugio_id   │
│                                │ lugar        │
│                                └──────────────┘
│                                       ▲
│                                       │ 1:N
│                                       │
│                                ┌──────────────┐
│                                │ MOVIMIENTOS  │
│                                ├──────────────┤
│                                │ id_movimiento│
│                                │ tipo         │
│                                │ fecha        │
│                                │ motivo       │
│                                │ animal_id    │
│                                └──────────────┘
```

---

## 📑 Estructura de Tablas

### 1️⃣ Tabla: `ROLES`

**Propósito**: Gestionar los roles de usuario en el sistema (ej: administrador, cuidador, etc.)

**Justificación**:
- Permite control granular de permisos
- Vinculado a refugios para roles específicos por instancia
- Facilita escalabilidad del sistema

| Campo | Tipo | Restricciones | Justificación |
|-------|------|---------------|---------------|
| `id_roles` | UUID | PK, DEFAULT gen_random_uuid() | IDs inmutables y únicos globalmente |
| `nombre` | VARCHAR(100) | NOT NULL | Identifica el rol (admin, cuidador, etc.) |
| `refugio_id` | UUID | FK → refugios, NOT NULL | Un rol pertenece a un refugio específico |

**Relaciones**:
- 1:N con `USUARIOS` → Un rol puede tener múltiples usuarios
- N:1 con `REFUGIOS` → Un rol pertenece a un refugio

---

### 2️⃣ Tabla: `REFUGIOS`

**Propósito**: Almacenar información de los refugios/organizaciones

**Justificación**:
- Centro de la operación; todas las entidades se vinculan a un refugio
- Permite multi-tenancia: cada refugio puede ser independiente
- Captura ubicación geográfica para operaciones logísticas

| Campo | Tipo | Restricciones | Justificación |
|-------|------|---------------|---------------|
| `id_refugio` | UUID | PK | Identificador único |
| `nombre` | VARCHAR(100) | NOT NULL | Nombre del refugio |
| `capacidad_max` | INTEGER | NOT NULL, CHECK > 1 | Validación en BD para integridad |
| `estado` | VARCHAR(100) | NOT NULL | Provincia/estado donde opera |
| `municipio` | VARCHAR(100) | NOT NULL | Localización específica |
| `colonia` | TEXT | NOT NULL | Barrio/zona |
| `calle` | TEXT | NOT NULL | Vía pública |
| `num_exterior` | INTEGER | NULLABLE | Número de referencia |
| `num_interior` | INTEGER | NULLABLE | Departamento/interior |

**Validaciones**:
- ✅ `CHECK (capacidad_max > 1)` → Impide capacidades lógicamente inválidas
- ✅ Ubicación completa para mapeo y logística

---

### 3️⃣ Tabla: `USUARIOS`

**Propósito**: Gestionar acceso y personal del sistema

**Justificación**:
- Separación de identidad (nombre/apellidos) del acceso (email/contraseña)
- Campo `activo` permite desactivar sin perder datos
- Email validado mediante CHECK CONSTRAINT

| Campo | Tipo | Restricciones | Justificación |
|-------|------|---------------|---------------|
| `id_usuario` | UUID | PK | Identificador único |
| `nombre` | VARCHAR(100) | NOT NULL | Primer nombre |
| `apellido_p` | VARCHAR(100) | NOT NULL | Apellido paterno |
| `apellido_m` | VARCHAR(100) | NOT NULL | Apellido materno |
| `contrasena` | VARCHAR(100) | NOT NULL | Hash/encriptación recomendada en APP |
| `email` | TEXT | NOT NULL, CHECK LIKE '%@%' | Validación básica en BD |
| `activo` | BOOLEAN | NOT NULL | Desactivación lógica sin eliminar |
| `rol_id` | UUID | FK → roles, NOT NULL | Cada usuario tiene un rol |
| `refugio_id` | UUID | FK → refugios, NOT NULL | Un usuario pertenece a un refugio |

**Validaciones**:
- ✅ `CHECK (email LIKE '%@%')` → Validación de formato mínimo
- ✅ Campo `activo` para cumplimiento de GDPR

---

### 4️⃣ Tabla: `ANIMALES`

**Propósito**: Registro completo de todos los animales en el sistema

**Justificación**:
- Información médica y de comportamiento para cuidado apropiado
- Campos de enfermedad, discapacidad y agresividad para manejo seguro
- Descripción detallada para adopciones
- Imagen para publicación web

| Campo | Tipo | Restricciones | Justificación |
|-------|------|---------------|---------------|
| `id_animal` | UUID | PK | Identificador único |
| `nombre` | VARCHAR(100) | NOT NULL | Nombre del animal |
| `especie` | VARCHAR(100) | NOT NULL | Gato, perro, etc. |
| `raza` | VARCHAR(100) | NOT NULL | Información para adopción |
| `edad` | INTEGER | NOT NULL, CHECK > 0 | Años de vida |
| `peso` | NUMERIC(10,2) | NOT NULL, CHECK > 0 | Precisión de 2 decimales para medicación |
| `sexo` | sexo_animal (ENUM) | NOT NULL | Macho/Hembra |
| `imagen` | TEXT | NULLABLE | URL/path de foto |
| `tamano` | tamano_lista (ENUM) | NOT NULL | pequeño/mediano/grande |
| `enfermedad_no_tratable` | BOOLEAN | NOT NULL | Indica eutanasia posible |
| `discapacidad` | BOOLEAN | NOT NULL | Para manejo especial |
| `es_agresivo` | BOOLEAN | NOT NULL | Riesgos de comportamiento |
| `lugar` | TEXT | NOT NULL | Ubicación en refugio |
| `descripcion` | TEXT | NOT NULL | Comportamiento, características |
| `refugio_id` | UUID | FK → refugios, NOT NULL | Animal pertenece a un refugio |

**Tipos ENUM utilizados**:
- `sexo_animal`: 'Macho', 'Hembra'
- `tamano_lista`: 'pequeño', 'mediano', 'grande'

**Validaciones**:
- ✅ `CHECK (edad > 0)` → Previene datos ilógicos
- ✅ `CHECK (peso > 0.0)` → Validación de peso
- ✅ Booleans para atributos de sí/no

---

### 5️⃣ Tabla: `MOVIMIENTOS`

**Propósito**: Auditoría completa de cada evento de un animal (rescate, adopción, etc.)

**Justificación**:
- **Trazabilidad**: Historial inmutable de cada animal
- **Métricas**: Análisis de rescates, adopciones, etc.
- **Auditoría Legal**: Necesario para regulaciones de bienestar animal
- **Movimiento por "extravio"**: Agregado recientemente para casos de animales extraviados

| Campo | Tipo | Restricciones | Justificación |
|-------|------|---------------|---------------|
| `id_movimiento` | UUID | PK | Identificador único |
| `tipo_movimiento` | movimiento_tipo (ENUM) | NOT NULL | rescate/retorno/adopcion/defuncion/extravio |
| `fecha_movimiento` | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Marca temporal automática |
| `motivo` | TEXT | NOT NULL | Descripción del motivo |
| `animal_id` | UUID | FK → animales, NOT NULL | Qué animal se movió |

**Tipos ENUM**:
- `movimiento_tipo`: 'rescate', 'retorno', 'adopcion', 'defuncion', 'extravio'

**Justificación de restricciones**:
- ✅ ON DELETE CASCADE → Si se elimina un animal, sus movimientos se eliminan
- ✅ TIMESTAMP automático → Imposible falsificar fechas

---

## 🔑 Relaciones y Restricciones de Integridad Referencial

### Diagrama de Foreign Keys

```
ROLES
  ├─ FK: refugio_id → REFUGIOS (1:N)

USUARIOS
  ├─ FK: rol_id → ROLES (N:1)
  └─ FK: refugio_id → REFUGIOS (N:1)

ANIMALES
  ├─ FK: refugio_id → REFUGIOS (N:1)

MOVIMIENTOS
  └─ FK: animal_id → ANIMALES (N:1)
```

### Restricciones de Eliminación

| Relación | ON DELETE | Justificación |
|----------|-----------|---------------|
| animales → usuarios | **RESTRICT** | Previene pérdida de datos de quién registró |
| animales → refugios | **RESTRICT** | Previene eliminación accidental de refugio con animales |
| movimientos → animales | **CASCADE** | Si se elimina animal, se eliminan sus movimientos |
| usuarios → roles | **CASCADE** | Si se elimina rol, usuarios se eliminan |
| usuarios → refugios | **CASCADE** | Si se elimina refugio, usuarios se eliminan |
| roles → refugios | **RESTRICT** | Protege roles de refugios operativos |

---

## 📇 Índices y Optimización

### Índices Implícitos (Automáticos)

PostgreSQL crea automáticamente índices para:
- **PRIMARY KEYS**: Índice B-tree en `id_*` de todas las tablas
- **FOREIGN KEYS**: Índices implícitos para búsquedas rápidas en JOINs

### Índices Recomendados (No Implementados Aún)

Para optimizar consultas frecuentes:

```sql
-- Buscar animales por refugio (muy frecuente)
CREATE INDEX idx_animales_refugio_id ON animales(refugio_id);

-- Buscar movimientos de un animal
CREATE INDEX idx_movimientos_animal_id ON movimientos(animal_id);

-- Buscar usuarios por email (login)
CREATE INDEX idx_usuarios_email ON usuarios(email);

-- Buscar usuarios por refugio
CREATE INDEX idx_usuarios_refugio_id ON usuarios(refugio_id);

-- Buscar movimientos por rango de fechas
CREATE INDEX idx_movimientos_fecha ON movimientos(fecha_movimiento DESC);

-- Buscar animales por características (filtros de búsqueda)
CREATE INDEX idx_animales_especie_tamano ON animales(especie, tamano);

-- Búsquedas de animales activos en refugio
CREATE INDEX idx_animales_refugio_activos ON animales(refugio_id, id_animal);
```

---

## 👀 Views (Vistas Recomendadas)

### Vista 1: `v_animales_disponibles`

```sql
CREATE VIEW v_animales_disponibles AS
SELECT 
  a.id_animal,
  a.nombre,
  a.especie,
  a.tamano,
  a.edad,
  r.nombre as refugio,
  COUNT(m.id_movimiento) as total_movimientos
FROM animales a
JOIN refugios r ON a.refugio_id = r.id_refugio
LEFT JOIN movimientos m ON a.id_animal = m.id_movimiento
WHERE m.tipo_movimiento NOT IN ('adopcion', 'defuncion', 'extravio')
GROUP BY a.id_animal, r.id_refugio;
```

**Justificación**: Muestra solo animales aún en el refugio (no adoptados ni fallecidos)

### Vista 2: `v_estadisticas_refugios`

```sql
CREATE VIEW v_estadisticas_refugios AS
SELECT 
  r.nombre as refugio,
  COUNT(DISTINCT a.id_animal) as total_animales,
  COUNT(DISTINCT u.id_usuario) as total_usuarios,
  r.capacidad_max,
  ROUND(COUNT(DISTINCT a.id_animal)::FLOAT / r.capacidad_max * 100, 2) as ocupacion_porcentaje
FROM refugios r
LEFT JOIN animales a ON r.id_refugio = a.refugio_id
LEFT JOIN usuarios u ON r.id_refugio = u.refugio_id
GROUP BY r.id_refugio, r.nombre, r.capacidad_max;
```

**Justificación**: Dashboard de ocupación y recursos por refugio

### Vista 3: `v_historial_movimientos`

```sql
CREATE VIEW v_historial_movimientos AS
SELECT 
  m.id_movimiento,
  a.nombre as animal,
  m.tipo_movimiento,
  m.fecha_movimiento,
  m.motivo,
  r.nombre as refugio
FROM movimientos m
JOIN animales a ON m.animal_id = a.id_animal
JOIN refugios r ON a.refugio_id = r.id_refugio
ORDER BY m.fecha_movimiento DESC;
```

**Justificación**: Auditoría completa de eventos de animales

---

## 🔐 Validaciones y Constraints

### Validaciones en la Base de Datos

| Tabla | Constraint | Tipo | Justificación |
|-------|-----------|------|---------------|
| refugios | capacidad_max > 1 | CHECK | Evita refugios con capacidad 0 o negativa |
| usuarios | email LIKE '%@%' | CHECK | Validación básica de email |
| animales | edad > 0 | CHECK | Animales con edad válida |
| animales | peso > 0.0 | CHECK | Peso positivo |
| animales | tamano IN ENUM | DOMAIN | Solo tamaños predefinidos |
| movimientos | tipo IN ENUM | DOMAIN | Solo tipos de movimiento válidos |

**Ventajas**:
- ✅ Integridad a nivel de base de datos
- ✅ Imposible insertar datos inválidos desde cualquier cliente
- ✅ Rendimiento mejorado

---

## 🔄 Sistema de Migraciones

El proyecto utiliza **Prisma Migrations** para versionado de base de datos.

### Historial de Migraciones

| Fecha | Migración | Cambios |
|-------|-----------|---------|
| 2026-02-19 | `20260219012425_init` | Creación inicial de schema |
| 2026-02-19 | `20260219034825_add_movimiento_motivo_enum` | Agregar enums de movimiento |
| 2026-02-21 | `20260221204429_estado_animal` | Campos de estado del animal |
| 2026-02-22 | `20260222042239_estado_animalactualizado` | Ajustes en campos de estado |
| 2026-02-24 | `20260224042122_enummastamanos` | Refinamiento de tamaños |
| 2026-02-24 | `20260224042729_estadoextraviado` | Agregación de estado "extraviado" |
| 2026-03-04 | `20260304000000_align_with_prisma_schema` | Alineación final con Prisma |

### Ventajas del Sistema de Migraciones

- ✅ **Versionado**: Cada cambio queda registrado
- ✅ **Reproducibilidad**: Mismo schema en dev/test/prod
- ✅ **Reversibilidad**: Posibilidad de rollback (en desarrollo)
- ✅ **Auditoría**: Quién cambió qué y cuándo

---

## 🐳 Configuración Docker

### Estructura `docker-compose.yml`

```yaml
services:
  database:
    image: postgres:15-alpine
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app-network
```

**Justificación de decisiones**:

| Decisión | Razón |
|----------|-------|
| `postgres:15-alpine` | Imagen ligera (~150MB) vs ~300MB standard |
| Puerto 5432 | Puerto estándar de PostgreSQL |
| Volumen persistente | Datos persisten entre contenedores |
| Red bridge | Aislamiento y comunicación entre servicios |
| Variables de entorno | Seguridad: no hardcodear credenciales |

### Inicialización

El script `docker-entrypoint-init.sql` se ejecuta automáticamente:

```bash
# Ejecutar en contenedor
docker-compose exec database psql -U $POSTGRES_USER -d $POSTGRES_DB -f init-migrations.sh
```

---

## 🚀 Cómo Usar

### 1. Levantar la Base de Datos

```bash
docker-compose up -d
```

### 2. Ejecutar Migraciones

```bash
npx prisma migrate deploy
```

### 3. Acceder a la BD

```bash
# Usar pgAdmin o psql
psql -h localhost -U user -d huellitas_callejeras -p 5432
```

### 4. Agregar Datos Iniciales

```bash
# Insertar roles base
INSERT INTO roles (nombre, refugio_id) VALUES 
  ('Administrador', 'refugio-uuid'),
  ('Cuidador', 'refugio-uuid'),
  ('Voluntario', 'refugio-uuid');
```

---

## 📈 Escalabilidad y Mejoras Futuras

### Mejoras Recomendadas

1. **Indices Adicionales** (en archivo de migración)
   - Email de usuarios para login rápido
   - Fechas de movimientos para reportes

2. **Views para Reportes**
   - Adopciones por mes
   - Animales por especie/raza
   - Ocupación de refugios

3. **Triggers para Auditoría**
   ```sql
   CREATE TABLE audit_log (
     id SERIAL PRIMARY KEY,
     tabla VARCHAR(100),
     operacion VARCHAR(20),
     fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
     usuario_id UUID
   );
   ```

4. **Particionamiento de Movimientos**
   - Para bases de datos muy grandes
   - Por rango de fechas

5. **Encriptación de Contraseñas**
   - Implementar bcrypt en aplicación
   - Considerar pgcrypto para BD

---

## 📝 Notas de Diseño

### Decisiones Clave

1. **UUID en lugar de SERIAL**
   - ✅ Distribuido globalmente
   - ✅ No expone secuencia de IDs
   - ✅ Mejor para replicación

2. **Foreign Key en RESTRICT**
   - ✅ Previene pérdida de datos accidental
   - ✅ Obliga a limpiar datos relacionados

3. **ENUM en lugar de lookup tables**
   - ✅ Menos queries para datos estáticos
   - ✅ Validación automática
   - ✅ Mejor rendimiento

4. **TIMESTAMP automático en movimientos**
   - ✅ Imposible manipular fechas
   - ✅ Auditoría confiable

5. **Multi-tenancia por refugio**
   - ✅ Escalable a múltiples organizaciones
   - ✅ Seguridad de datos aislados

---

## 📚 Referencias y Estándares

- **SQL Standard**: Cumplimiento con ISO/IEC 9075
- **PostgreSQL Best Practices**: Documentación oficial v15
- **Normalization**: 3NF (Third Normal Form)
- **GDPR Compliance**: Campos para derecho al olvido

---

## 👥 Autores y Contacto

**Proyecto**: Huellitas Callejeras - Período Integrador 2
**Base de Datos**: v1.2
**Última Actualización**: Marzo 2026

---

## 📄 Licencia

Este proyecto es parte de un trabajo académico de la universidad.

---

**¡Gracias por usar Huellitas Callejeras! 🐾**
