# Guía de GitHub Actions para la Construcción, Publicación y Despliegue en ECS

Este workflow de GitHub Actions está diseñado para construir una imagen Docker de la aplicación, publicarla en Amazon ECR y desplegarla en Amazon ECS. Sigue este paso a paso para comprender cada sección del archivo YAML.

## 1. Configuración del Desencadenador (Trigger)

```yaml
yaml
on:
  push:
    branches:
      - master
    paths-ignore:
      - 'infra/**'
      - 'documentation/**'
      - '*.md'
```

**Descripción:**
- El workflow se ejecutará cuando haya un push a la rama `master`.
- Las rutas que se ignoran (`paths-ignore`) incluyen la carpeta `infra`, `documentation`, y cualquier archivo `.md`. Esto significa que si solo se realizan cambios en estas rutas, no se activará el workflow.

## 2. Job: build_and_push

```yaml
yaml
jobs:
  build_and_push:
    name: Build and Push Docker Image
    runs-on: ubuntu-latest
```

**Descripción:**
- Este job se encarga de construir la imagen Docker y subirla al repositorio de Amazon ECR.
- Se ejecuta en un contenedor con el sistema operativo `ubuntu-latest`.

**Variables de Entorno:**

```yaml
yaml
env:
  ECR_REPOSITORY: reto-tecnico-repo 
  AWS_REGION: us-east-1
  IMAGE_TAG: latest
```

- **ECR_REPOSITORY**: Nombre del repositorio de Amazon ECR donde se subira la imagen.
- **AWS_REGION**: Región de AWS donde está configurado el repositorio.
- **IMAGE_TAG**: Tag para identificar la imagen (en este caso, `latest`).

**Pasos:**

1. **Clonar el repositorio:**

   ```yaml
   - name: Check out the repo
     uses: actions/checkout@v3
   ```
   Este paso descarga el contenido del repositorio para poder construir la imagen.

2. **Configurar Credenciales de AWS:**

   ```yaml
   - name: Configure AWS Credentials
     uses: aws-actions/configure-aws-credentials@v1
     with:
       aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
       aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
       aws-region: ${{ env.AWS_REGION }}
   ```
   Utiliza credenciales secretas almacenadas en GitHub para autenticarte con AWS.

3. **Iniciar sesión en Amazon ECR:**

   ```yaml
   - name: Log in to Amazon ECR
     id: ecr_login
     uses: aws-actions/amazon-ecr-login@v1
     with:
       region: ${{ env.AWS_REGION }}
   ```
   Este paso inicia sesión en Amazon ECR, lo cual es necesario para poder subir la imagen Docker.

4. **Construir la Imagen Docker:**

   ```yaml
   - name: Build Docker image
     run: |
       docker build -t $ECR_REPOSITORY:$IMAGE_TAG .
   ```
   Construye la imagen Docker usando el Dockerfile en el repositorio.

5. **Etiquetar la Imagen:**

   ```yaml
   - name: Tag Docker image
     run: |
       docker tag $ECR_REPOSITORY:$IMAGE_TAG ${{ steps.ecr_login.outputs.registry }}/$ECR_REPOSITORY:$IMAGE_TAG
   ```
   Etiqueta la imagen Docker para que pueda ser empujada al registro ECR.

6. **Subir la Imagen a Amazon ECR:**

   ```yaml
   - name: Push to Amazon ECR
     run: |
       docker push ${{ steps.ecr_login.outputs.registry }}/$ECR_REPOSITORY:$IMAGE_TAG
   ```
   Sube la imagen Docker a Amazon ECR.

## 3. Job: deploy_to_ecs

```yaml
yaml
deploy_to_ecs:
  name: Deploy to ECS
  runs-on: ubuntu-latest
  needs: build_and_push
```

**Descripción:**
- Este job se ejecuta una vez que finalice el `build_and_push` con éxito.
- Se encarga de actualizar el servicio en Amazon ECS para desplegar la nueva imagen.

**Variables de Entorno:**

```yaml
yaml
env:
  CLUSTER_NAME: reto-tecnico-cluster
  SERVICE_NAME: reto-tecnico-service 
  CONTAINER_NAME: reto-tecnico-container
  AWS_REGION: us-east-1
  ECR_REPOSITORY: reto-tecnico-repo
```

- **CLUSTER_NAME**: Nombre del clúster ECS.
- **SERVICE_NAME**: Nombre del servicio ECS.
- **CONTAINER_NAME**: Nombre del contenedor en el servicio ECS.

**Pasos:**

1. **Actualizar el Servicio en ECS:**

   ```yaml
   - name: Update ECS service with new image
     run: |
       aws ecs update-service \
         --cluster $CLUSTER_NAME \
         --service $SERVICE_NAME \
         --force-new-deployment \
         --region $AWS_REGION \
         --desired-count 1
     env:
       AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
       AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
   ```
   Utiliza el comando `aws ecs update-service` para forzar el redeployment del servicio ECS con la nueva imagen Docker.
