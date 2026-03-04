#!/bin/bash
set -e

echo "================================"
echo "Inicializando base de datos HC..."
echo "================================"

DB_USER="${POSTGRES_USER:-postgres}"
DB_NAME="${POSTGRES_DB:-postgres}"

# Ejecutar el schema principal
if [ -f /docker-entrypoint-initdb.d/01-schema_HC-1.2.sql ]; then
    echo "Ejecutando schema principal (01-schema_HC-1.2.sql)..."
    psql -v ON_ERROR_STOP=1 -U "$DB_USER" -d "$DB_NAME" -f /docker-entrypoint-initdb.d/01-schema_HC-1.2.sql
    echo "✓ Schema principal ejecutado"
fi

# Ejecutar todas las migraciones en orden
MIGRATIONS_DIR="/docker-entrypoint-initdb.d/migrations"
if [ -d "$MIGRATIONS_DIR" ]; then
    echo ""
    echo "Ejecutando migraciones..."
    
    # Listar todas las carpetas de migraciones en orden alfabético
    for migration_folder in $(find "$MIGRATIONS_DIR" -mindepth 1 -maxdepth 1 -type d | sort); do
        migration_name=$(basename "$migration_folder")
        migration_file="$migration_folder/migration.sql"
        
        if [ -f "$migration_file" ]; then
            echo "Ejecutando migración: $migration_name..."
            psql -v ON_ERROR_STOP=1 -U "$DB_USER" -d "$DB_NAME" -f "$migration_file"
            echo "✓ Migración $migration_name completada"
        fi
    done
    
    echo ""
    echo "✓ Todas las migraciones ejecutadas correctamente"
else
    echo "⚠ El directorio de migraciones no se encontró en $MIGRATIONS_DIR"
fi

echo ""
echo "================================"
echo "Base de datos inicializada ✓"
echo "================================"
