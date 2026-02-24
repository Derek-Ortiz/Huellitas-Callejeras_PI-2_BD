
--CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE DATABASE huellitas_callejeras;


\c huellitas_callejeras;

CREATE TABLE roles (
    id_roles UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE refugios (
    id_refugio UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    capacidad_max INTEGER NOT NULL CHECK (capacidad_max > 1),
    estado VARCHAR(100) NOT NULL,
    municipio VARCHAR(100) NOT NULL,
    colonia TEXT NOT NULL,
    calle TEXT NOT NULL,
    num_exterior INTEGER,  
    num_interior INTEGER
);

CREATE TABLE usuarios (
    id_usuario UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido_p VARCHAR(100) NOT NULL,
    apellido_m VARCHAR(100) NOT NULL,
    contrasena VARCHAR(100) NOT NULL,
    email TEXT NOT NULL CHECK (email LIKE '%@%'),  
    activo BOOLEAN NOT NULL,
    rol_id UUID NOT NULL,
    refugio_id UUID NOT NULL,
    CONSTRAINT fk_roles_usuarios FOREIGN KEY (rol_id) 
        REFERENCES roles(id_roles) ON DELETE CASCADE, --creo que queda mejor que sea update cascade
    CONSTRAINT fk_refugios_usuarios FOREIGN KEY (refugio_id) 
        REFERENCES refugios(id_refugio) ON DELETE CASCADE
);


CREATE TYPE tamano_lista AS ENUM ('pequeño', 'mediano', 'grande');


CREATE TYPE sexo_animal AS ENUM ('Macho', 'Hembra');

CREATE TABLE animales (
    id_animal UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    especie VARCHAR(100) NOT NULL,
    raza VARCHAR(100) NOT NULL,
    edad INTEGER NOT NULL CHECK (edad > 0),
    peso NUMERIC(10,2) NOT NULL CHECK (peso > 0.0),  
    sexo sexo_animal NOT NULL,
    imagen TEXT,
    tamano tamano_lista NOT NULL,
    enfermedad_no_tratable BOOLEAN NOT NULL,
    discapacidad BOOLEAN NOT NULL,
    es_agresivo BOOLEAN NOT NULL,
    lugar TEXT NOT NULL,
    descripcion TEXT NOT NULL,
    usuario_id UUID NOT NULL,
    refugio_id UUID NOT NULL,
    CONSTRAINT fk_usuarios_animales FOREIGN KEY (usuario_id) 
        REFERENCES usuarios(id_usuario) ON DELETE RESTRICT,
    CONSTRAINT fk_refugios_animales FOREIGN KEY (refugio_id) 
        REFERENCES refugios(id_refugio) ON DELETE RESTRICT
);


CREATE TYPE movimiento_tipo AS ENUM ('rescate', 'retorno', 'adopcion', 'defuncion');

CREATE TABLE movimientos (
    id_movimiento UUID DEFAULT gen_random_uuid() PRIMARY KEY,  
    tipo_movimiento movimiento_tipo NOT NULL,
    fecha_movimiento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    motivo TEXT NOT NULL,
    animal_id UUID NOT NULL,
    CONSTRAINT fk_animales_movimientos FOREIGN KEY (animal_id) 
        REFERENCES animales(id_animal) ON DELETE CASCADE
);
