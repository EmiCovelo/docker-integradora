# Fundamentos y usos prácticos de Docker

## Entregable trabajo integrador: Emiliano Covelo


## Parte 1 - Conteinerizar una Aplicación


### Creando la imágen

- Ejecute el comando correspondiente para buildear la imágen. Elija un nombre de imágen y un tag acorde. 

    ```bash
    docker build -t entrega_final:v1.0 .
    ```
- Muestre cuánto espacio ocupa la imaǵen una vez creada.

    ```bash
    docker images
    ```
- ¿Puede hacer algo para optimizar o mejorar la imágen?. Describa qué modificaciones puede hacer para optimizar la imágen.

    Para optimizar el comando `COPY ./app .` se puede dividir en dos. Primero, copiamos los archivos de administración de paquetes (/app/package.jsony /app/yarn.lock). 
    Luego, instalamos las dependencias. 
    Por último, copiamos el código fuente del proyecto, que está sujeto a cambios frecuentes.
    El código final quedaría: 
    ```bash
    # Copiamos los archivos de administración de paquetes
    COPY /app/package.json /app/yarn.lock .

    # Instalamos las dependencias del proyecto
    RUN yarn install --production

    # Copiamos los archivos del proyecto al contenedor
    COPY ./app .
    ```



### Correr la aplicación

Una vez creada la imágen, debería ser capaz de correr la aplicación.


- Ejecute un comando para poder correr la aplicación.
    ```bash
    docker run -d -p 8080:3000 entrega_final:v1.0
    ```
- Explique el comando y cada parámetro enviado.

    Se utiliza el comando `docker run` para correr la aplicación. Los paramétros que se le pasan al comando son:

        -d: Indica que el contenedor se ejecutará como daemon.
        -p: Indica que se publicarán puertos hacia afuera del contenedor. En este caso, 8080:30000 mapea el puerto 8080 de nuestra PC al puerto 30000 del contenedor.

- Muestre una captura de pantalla o un copy-paste del contenedor corriendo.

    _(Inserte aquí la captura de pantalla o los la salida de la shell con el contenedor corriendo)_

- Adjunte una captura de pantalla con la aplicación funcionando con la URL utilizada para acceder.

    ![Screenshot](./imgs/img_placeholder.png)


## Parte 2 - Actualizar aplicación (imágen)

### 1. Actualizar el código fuente

- Ejecutemos los comando necesarios para que la aplicación tome los cambios. Realice un etiquetado (tag) coherente respecto a los cambios en la imágen
    
    ```bash
    docker build -t entrega_final:v1.1-primeros_cambios .
    docker run -d -p 8080:3000 entrega_final:v1.1-primeros_cambios
    ```

- Mostrar captura de pantalla con la app corriendo con las modificaciones realizadas.

    ![Screenshot](./imgs/img_placeholder.png)

> La actualizaciones realizadas, dejan a la primera versión obsoleta

### 2. Elimine el contenedor e imágen anterior

- Elimine la imágen y el contenedor hecho en el punto anterior

    ```bash
    docker stop cranky_zhukovsky
    docker rm cranky_zhukovsky
    docker image prune -a
    ```

- Liste las imágenes y contenedores para ver que ya no existen.

    ```bash
    docker ps
    docker images
    ```

## Parte 3 - Compartir app

Para compartir la imágen de la aplicación usaremos la registry de [DockerHub](https://hub.docker.com/).

> [!TIP]
> Repase lo realizado en el [Laboratorio 2.3](https://github.com/kity-linuxero/docker_410_practicas/blob/main/labs/02-conceptos-basicos/23-images-push.md#3-subimos-a-la-registry).


- Escriba los comandos necesarios para que sea posible subir la imaǵen correctamente.

    ```bash
    docker image tag entrega_final:v1.1-primeros_cambios emicovelo/entrega_final:v1.1-primeros_cambios
    docker login
    docker push emicovelo/entrega_final:v1.1-primeros_cambios
    ```

- Comparta la URL de DockerHub para que pueda ser posible probar y descargar su imágen.

    https://hub.docker.com/repository/docker/emicovelo/entrega_final/general

- Agregue un _overview_ para el repositorio de Dockerhub con instrucciones para correr la imágen y todo lo que considere necesario para que un tercero pueda ejecutar la imágen.

> [!TIP]
> Utilice el formato [markdown](https://docs.github.com/es/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax) para darle formato al overview.


## Parte 4 - Persistencia de datos

Los datos en esta APP se guardan en un archivo `/etc/todos/todo.db`.

- Escriba los comandos utilizados para realizar lo solicitado con la explicación correspondiente.

    ```bash
    docker volume create volumen_app
    docker run -d -p 8080:3000 -v volumen_app:/etc/todos/ entrega_final:v1.1-primeros_cambios
    ```
    El primer comando crea un volumen para poder montarlo dentro del contenedor
    El segundo comando crea un nueco contenedor de la misma forma que lo veníamos haciendo y además, con el comando `-v volumen_app:/etc/todos/` montamos el volumen recién creado en el directorio /etc/todos/ dentro del contenedor

- Decida que tipo de persistencia es la adecuada para la app.

> [!TIP]
> Repase [volúmenes y persistencia](https://docker.idepba.com.ar/clase4.html#/volumenes) de datos.


## Parte 5 - Aplicaciones multicontainer


- [Crear una red](https://docker.idepba.com.ar/clase4.html#/network_create) para conexión entre los contenedores que servirá también para conectar a la aplicación.

    ```bash
    docker network create nueva_red
    ```
- [Crear un nuevo volumen](https://docker.idepba.com.ar/clase4.html#/volume_create) para persistir los datos de la base MySQL. El path donde se almacenan los datos en el contenedor MySQL es `/var/lib/mysql`.
    
    ```bash
    docker volume create volumen_myqsl
    ```
- Iniciar el contenedor de la aplicación utilizando el comando `docker run` enviando las variables de entornos necesarias para la conexión con la base de datos.

    ```bash
    docker run --name contenedor-mysql  -h contenedor-mysql -v volumen_mysql:/var/lib/mysql --network nueva_red -e MYSQL_ROOT_PASSWORD=pwd123 -e MYSQL_DATABASE=todos_db -d mysql:8.0
    docker run -d -p 8080:3000 -v volumen_app:/etc/todos/ --name contenedor-app --network nueva_red --env MYSQL_HOST=contenedor-mysql --env MYSQL_USER=root --env MYSQL_PASSWORD=pwd123 --env MYSQL_DB=todos_db entrega_final:v1.1-primeros_cambios
    ```

> [!TIP]
> Set environments variables (-e, --env) [Docker Docs](https://docs.docker.com/reference/cli/docker/container/run/#env).




## Parte 6 - Utilizando Docker Compose

En la carpeta raíz del proyecto, cree un archivo de docker compose `compose.yml` o `docker-compose.yml`. Adicionalmente pégue el contenido del archivo `compose` en este lugar:

```compose
    services:
        app:
            image: emicovelo/entrega_final:v1.1-primeros_cambios
            container_name: contenedor-app
            ports:
                - "8080:3000"
            volumes:
                - volumen_app:/etc/todos/
            networks:
                - nueva_red
        db:
            image: mysql:8.0
            container_name: contenedor-mysql
            volumes:
                - volumen_mysql:/var/lib/mysql
            networks:
                - nueva_red
            environment:            
                MYSQL_DATABASE: todos_db
                MYSQL_ROOT_PASSWORD: pwd123
    networks:
        nueva_red:
    volumes:
        volumen_app:
        volumen_mysql:
```

> [!IMPORTANT]  
> El instructor debe ejecutar el comando `docker compose up` y la aplicación debe descargarse y ejecutarse correctamente.

----


<p align="center">
  <img src="./imgs/logos.footer.gray.webp">
</p>




