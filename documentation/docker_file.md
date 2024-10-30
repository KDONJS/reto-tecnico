# Dockerfile para Construcción y Ejecución de Aplicación Spring Boot

Este Dockerfile define un proceso multi-stage para construir y ejecutar una aplicación de Spring Boot. Se compone de dos etapas: la primera para la construcción del proyecto usando Maven y la segunda para crear una imagen ligera de ejecución. A continuación se presenta la documentación detallada del Dockerfile:

## Etapa 1: Construcción

```dockerfile
FROM maven:3.8.8-eclipse-temurin-21 AS build
```
- **Base Image:** Utiliza la imagen oficial de Maven 3.8.8 basada en Eclipse Temurin JDK 21 para compilar el proyecto. Esta imagen ya tiene Maven y el JDK, lo que facilita la construcción del código Java.

```dockerfile
WORKDIR /app
```
- **Directorio de Trabajo:** Se define `/app` como el directorio de trabajo donde se almacenarán los archivos del proyecto dentro del contenedor.

```dockerfile
COPY pom.xml .
RUN mvn dependency:go-offline
```
- **Copia de `pom.xml` y Descarga de Dependencias:** Se copia el archivo `pom.xml` al contenedor y se ejecuta el comando `mvn dependency:go-offline` para descargar todas las dependencias requeridas. Esto permite que las dependencias estén disponibles sin necesidad de una conexión constante durante la construcción completa del proyecto.

```dockerfile
COPY src ./src
RUN mvn clean package -DskipTests
```
- **Copia del Código Fuente y Construcción:** Se copian todos los archivos fuente al contenedor y se ejecuta `mvn clean package -DskipTests` para compilar el código y generar el archivo `.jar` del proyecto, omitiendo las pruebas unitarias para reducir el tiempo de construcción.

## Etapa 2: Imagen de Ejecución

```dockerfile
FROM eclipse-temurin:21-jre-alpine
```
- **Base Image de Ejecución:** Utiliza la imagen de Eclipse Temurin JRE 21 basada en Alpine Linux, que es ligera y adecuada para la ejecución de la aplicación sin incluir las herramientas de desarrollo.

```dockerfile
WORKDIR /app
```
- **Directorio de Trabajo:** Nuevamente se define `/app` como el directorio de trabajo dentro del contenedor para la imagen de ejecución.

```dockerfile
COPY --from=build /app/target/reto-tecnico-0.0.1-SNAPSHOT.jar app.jar
```
- **Copia del JAR Generado:** Se copia el archivo `.jar` generado en la etapa de construcción (etapa `build`) al contenedor de ejecución. Esto asegura que la imagen de producción solo contenga lo necesario para ejecutar la aplicación.

```dockerfile
EXPOSE 8080
```
- **Exponer el Puerto 8080:** Expone el puerto 8080, que es el puerto predeterminado que usa Spring Boot para servir la aplicación.

```dockerfile
ENTRYPOINT ["java", "-jar", "app.jar"]
```
- **Comando de Ejecución:** Define el comando de ejecución que se ejecuta cuando se inicia el contenedor. En este caso, inicia la aplicación con `java -jar app.jar`.

## Resumen
Este Dockerfile está diseñado para optimizar el proceso de construcción y ejecución de una aplicación Spring Boot usando Docker. La utilización de multi-stage builds reduce el tamaño de la imagen final, ya que solo se incluye lo necesario para la ejecución, manteniendo las herramientas de desarrollo en una etapa separada.

Si tienes alguna duda o deseas ajustar alguna parte del proceso de construcción o ejecución, estaré encantado de ayudarte.

