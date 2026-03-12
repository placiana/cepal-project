#!/bin/bash

# Configuración
CONTAINER_NAME="cepal-project-db-1"
DB_USER="postgres"
DB_NAME="appdb"
PROJECT_BACKUP_DIR="$(pwd)/backups"
SYSTEM_BACKUP_DIR="/var/local/backups/cepal"
RETENTION_DAYS=7

# Crear directorios si no existen (puede requerir sudo para el directorio del sistema)
mkdir -p "$PROJECT_BACKUP_DIR"
if [ ! -d "$SYSTEM_BACKUP_DIR" ]; then
    echo "Intentando crear $SYSTEM_BACKUP_DIR..."
    mkdir -p "$SYSTEM_BACKUP_DIR" 2>/dev/null || echo "Advertencia: No se pudo crear $SYSTEM_BACKUP_DIR. ¿Tienes permisos?"
fi

# Nombre del archivo con marca de tiempo
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILENAME="backup_${DB_NAME}_${TIMESTAMP}.sql"

echo "Iniciando backup de $DB_NAME..."

# 1. Ejecutar pg_dump dentro del contenedor (vuelca al bind mount)
docker exec -t "$CONTAINER_NAME" pg_dump -U "$DB_USER" -f "/backups/$BACKUP_FILENAME" "$DB_NAME"

if [ $? -eq 0 ]; then
    echo "Dump generado con éxito en $PROJECT_BACKUP_DIR/$BACKUP_FILENAME"
    
    # 2. Copiar al directorio del sistema (si existe/es accesible)
    if [ -d "$SYSTEM_BACKUP_DIR" ]; then
        cp "$PROJECT_BACKUP_DIR/$BACKUP_FILENAME" "$SYSTEM_BACKUP_DIR/"
        echo "Copia de seguridad guardada en $SYSTEM_BACKUP_DIR"
        
        # 3. Rotación: Eliminar backups más antiguos que RETENTION_DAYS
        echo "Limpiando backups antiguos en $SYSTEM_BACKUP_DIR..."
        find "$SYSTEM_BACKUP_DIR" -type f -name "backup_${DB_NAME}_*.sql" -mtime +$RETENTION_DAYS -exec rm {} \;
    fi
    
    # También limpiamos el directorio local del proyecto para no acumular basura
    find "$PROJECT_BACKUP_DIR" -type f -name "backup_${DB_NAME}_*.sql" -mtime +$RETENTION_DAYS -exec rm {} \;
else
    echo "Error: Falló la generación del dump."
    exit 1
fi

echo "Proceso de backup finalizado."
