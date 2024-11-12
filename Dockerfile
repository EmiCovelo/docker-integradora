# Usamos la imagen base de Alpine Linux
FROM alpine:latest

# Actualizamos los paquetes e instalamos Node.js y Yarn directamente desde los repositorios oficiales
RUN apk add --no-cache nodejs yarn

# Establecemos el directorio de trabajo
WORKDIR /app

# Copiamos los archivos de administración de paquetes
COPY /app/package.json /app/yarn.lock .

# Instalamos las dependencias del proyecto
RUN yarn install --production

# Copiamos los archivos del proyecto al contenedor
COPY ./app .

# Exponemos el puerto de la aplicación (ejemplo: 3000)
EXPOSE 3000

# Comando por defecto para ejecutar la aplicación
CMD ["node", "src/index.js"]