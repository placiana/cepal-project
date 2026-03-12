# cepal-project

## Proyectos intervinientes

* Simulador: https://github.com/TobiasCarreira/cepal-tdp
* Dashboard: https://github.com/sistemasmarcelocastro/cepal-dashboard


## Clonar este proyecto
Clonamos el proyecto con todos sus submodulos

```
git clone --recurse-submodules git@github.com:placiana/cepal-project.git
```

## Actualizar los submodulos a su último commit en main

```
git submodule update --remote --recursive
```

## Construir las imagenes

```
docker compose build
```

Este paso puede demorar mucho tiempo.

## Levantar los servicios

```bash
docker compose up -d
```
*(Nota: Se usa el flag `-d` para correr en segundo plano en producción).*

## Bajar los servicios

```bash
docker compose down -v
```

El flag `-v` es importante para reiniciar los volúmenes montados si se desea limpiar los datos.

## Autoinicio en el Host (Producción)

Para asegurar que los servicios se levanten automáticamente tras un reinicio del servidor, se recomienda una de las siguientes opciones:

### Opción 1: Docker Restart Policy (Recomendado)

Los servicios ya están configurados con `restart: unless-stopped` en `docker-compose.yml`. Para que esto funcione, asegúrate de que el servicio de Docker esté habilitado para iniciar con el sistema:

```bash
sudo systemctl enable docker
```

Con esto, cualquier contenedor que estuviera corriendo antes del reinicio (o que no haya sido detenido manualmente con `docker compose stop/down`) se levantará solo.

### Opción 2: Systemd Unit (Más robusto)

Si prefieres gestionar el proyecto completo como un servicio del sistema, puedes crear un archivo en `/etc/systemd/system/cepal.service`:

```ini
[Unit]
Description=CEPAL Project Services
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/placiana/workspace/cepal-project
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
StandardOutput=journal

[Install]
WantedBy=multi-user.target
```

Luego, habilita e inicia el servicio:

```bash
sudo systemctl daemon-reload
sudo systemctl enable cepal.service
sudo systemctl start cepal.service
```

---

## Como levantar los servicios sin docker

### Cepal tdp

1. Clonar el proyecto
1. Crear entorno virtual y activarlo
1. `pip install -r requirements.txt`
1. ejecutar `flask --app api_simulador --debug run`

### Cepal dashboard
1. Clonar el proyecto
1. Crear entorno virtual y activarlo
1. `pip install -r requirements.txt`
1. `cd demo2`
1. `python index.py`

## Base de Datos y Backups

La base de datos PostgreSQL utiliza un **named volume** llamado `db_data` para garantizar la persistencia de los datos de forma eficiente y segura.

### Backups

Se ha configurado un **bind mount** que vincula el directorio local `./backups` con el directorio `/backups` dentro del contenedor de la base de datos. Esto permite realizar volcados (dumps) de la base de datos que serán accesibles directamente desde el host.

Para realizar un backup manual, puedes ejecutar el siguiente comando:

```bash
docker exec -t cepal-project-db-1 pg_dump -U postgres appdb > ./backups/backup_$(date +%Y%m%d_%H%M%S).sql
```
*(Nota: Asegúrate de que el nombre del contenedor sea el correcto, usualmente `cepal-project-db-1` o simplemente `db` si usas identificadores internos).*

O bien, generando el archivo directamente dentro del volumen montado:

```bash
docker exec -t cepal-project-db-1 pg_dump -U postgres -f /backups/backup.sql appdb
```
Esto dejará el archivo `backup.sql` en tu carpeta local `./backups`.

### Automatización con cron

Se proporciona un script `backup_db.sh` que automatiza la generación del dump, su copia a un directorio del sistema (ej: `/var/local/backups/cepal`) y la eliminación de backups antiguos (por defecto, mantiene los últimos 7 días).

#### Configuración del script

1. Asegúrate de que el script tiene permisos de ejecución: `chmod +x backup_db.sh`.
2. Edita las variables al inicio de `backup_db.sh` si necesitas cambiar las rutas o el tiempo de retención.
3. Asegúrate de tener permisos de escritura en el directorio de sistema elegido.

#### Programar en Crontab

Para ejecutar el backup automáticamente todos los días a las 03:00 AM, añade la siguiente línea a tu crontab (`crontab -e`):

```bash
0 3 * * * /ruta/absoluta/al/proyecto/backup_db.sh >> /ruta/absoluta/al/proyecto/backups/log_backup.txt 2>&1
```



