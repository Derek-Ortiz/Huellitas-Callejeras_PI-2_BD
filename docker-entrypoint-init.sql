-- Script de inicialización idempotente para PostgreSQL
-- Solo crea tipos y tablas si no existen

-- Crear ENUMs si no existen
DO $$ BEGIN
    CREATE TYPE tamano_lista AS ENUM ('miniatura', 'pequeño', 'mediano', 'grande', 'gigante');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE sexo_animal AS ENUM ('Macho', 'Hembra');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE movimiento_motivo AS ENUM ('rescate', 'retorno', 'adopcion', 'defuncion', 'extravio');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE movimiento_tipo AS ENUM ('entrada', 'salida');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE "EstadoAnimal" AS ENUM ('adoptado', 'adopcion', 'recuperacion', 'defuncion', 'extraviado');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Crear tabla roles si no existe
CREATE TABLE IF NOT EXISTS roles (
    id_roles UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    refugio_id UUID NOT NULL
);

-- Crear tabla refugios si no existe
CREATE TABLE IF NOT EXISTS refugios (
    id_refugio UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    capacidad_max INTEGER NOT NULL,
    estado VARCHAR(100) NOT NULL,
    municipio VARCHAR(100) NOT NULL,
    colonia TEXT NOT NULL,
    calle TEXT NOT NULL,
    num_exterior INTEGER,
    num_interior INTEGER
);

-- Agregar FK en roles si no existe
DO $$ BEGIN
    ALTER TABLE roles ADD CONSTRAINT fk_roles_refugios 
        FOREIGN KEY (refugio_id) REFERENCES refugios(id_refugio) ON DELETE RESTRICT;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Crear tabla usuarios si no existe
CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido_p VARCHAR(100) NOT NULL,
    apellido_m VARCHAR(100) NOT NULL,
    contrasena VARCHAR(100) NOT NULL,
    email TEXT NOT NULL,
    activo BOOLEAN NOT NULL,
    rol_id UUID NOT NULL,
    refugio_id UUID NOT NULL
);

-- Agregar FKs en usuarios si no existen
DO $$ BEGIN
    ALTER TABLE usuarios ADD CONSTRAINT fk_usuarios_roles 
        FOREIGN KEY (rol_id) REFERENCES roles(id_roles) ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    ALTER TABLE usuarios ADD CONSTRAINT fk_usuarios_refugios 
        FOREIGN KEY (refugio_id) REFERENCES refugios(id_refugio) ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Crear tabla animales si no existe
CREATE TABLE IF NOT EXISTS animales (
    id_animal UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    estado "EstadoAnimal" DEFAULT 'adopcion',
    especie VARCHAR(100) NOT NULL,
    raza VARCHAR(100) NOT NULL,
    edad INTEGER NOT NULL,
    peso NUMERIC(10,2) NOT NULL,
    sexo sexo_animal NOT NULL,
    imagen TEXT,
    tamano tamano_lista NOT NULL,
    enfermedad_no_tratable BOOLEAN NOT NULL,
    discapacidad BOOLEAN NOT NULL,
    es_agresivo BOOLEAN NOT NULL,
    lugar TEXT NOT NULL,
    descripcion TEXT NOT NULL,
    usuario_id UUID,
    refugio_id UUID NOT NULL
);

-- Agregar FKs en animales si no existen
DO $$ BEGIN
    ALTER TABLE animales ADD CONSTRAINT fk_animales_refugios 
        FOREIGN KEY (refugio_id) REFERENCES refugios(id_refugio) ON DELETE RESTRICT;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Crear tabla movimientos si no existe
CREATE TABLE IF NOT EXISTS movimientos (
    id_movimiento UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    tipo_movimiento movimiento_tipo NOT NULL,
    fecha_movimiento TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    motivo movimiento_motivo NOT NULL,
    animal_id UUID NOT NULL
);

-- Agregar FK en movimientos si no existe
DO $$ BEGIN
    ALTER TABLE movimientos ADD CONSTRAINT fk_movimientos_animales 
        FOREIGN KEY (animal_id) REFERENCES animales(id_animal) ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
