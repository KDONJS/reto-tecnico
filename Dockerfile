# Etapa 1: Construcción
FROM maven:3.8.8-eclipse-temurin-21 AS build

# Establecemos el directorio de trabajo
WORKDIR /app

# Copiamos los archivos de proyecto y descargamos las dependencias
COPY pom.xml .
RUN mvn dependency:go-offline

# Copiamos el resto de los archivos y construimos la aplicación
COPY src ./src
RUN mvn clean package -DskipTests

# Etapa 2: Imagen de ejecución
FROM eclipse-temurin:21-jre-alpine

# Establecemos el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiamos el JAR generado desde la etapa de construcción
COPY --from=build /app/target/reto-tecnico-0.0.1-SNAPSHOT.jar app.jar

# Exponemos el puerto en el que correrá la aplicación (por defecto, Spring Boot usa el 8080)
EXPOSE 8080

# Comando para ejecutar la aplicación
ENTRYPOINT ["java", "-jar", "app.jar"]
