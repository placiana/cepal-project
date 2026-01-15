# cepal-project

## Proyectos intervinientes

* Simulador: git@github.com:TobiasCarreira/cepal-tdp.git
* Dashboard: git@github.com:sistemasmarcelocastro/cepal-dashboard.git


## Clonar este proyecto
Clonamos el proyecto con todos sus submodulos

```
git clone --recurse-submodules git@github.com:placiana/cepal-project.git
```

## Construir las imagenes

```
docker compose build
```

## Levantar los servicios

```
docker compose up
```


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

Si el simulador está corriendo en otro host, podemos definir la variable de ambiente
`API_BASE_URL=http://otro_hostname:5000`



