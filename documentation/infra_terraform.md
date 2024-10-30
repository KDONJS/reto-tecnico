# Guía de GitHub Actions para la Implementación de Infraestructura con Terraform

Este workflow de GitHub Actions está diseñado para automatizar el despliegue de infraestructura usando Terraform. Se activa cuando se realizan cambios en la carpeta `infra`, permitiendo la implementación de cambios en la infraestructura de manera rápida y eficiente. Sigue este paso a paso para comprender cada sección del archivo YAML.

## 1. Configuración del Desencadenador (Trigger)
```yaml
on:
  push:
    paths:
      - 'infra/**'
```
### Descripción:
- El workflow se ejecutará cuando haya un `push` que afecte a cualquier archivo dentro de la carpeta `infra`. Esto asegura que solo los cambios en la infraestructura desencadenen el flujo de trabajo.

## 2. Job: `terraform`
```yaml
jobs:
  terraform:
    name: Terraform Apply
    runs-on: ubuntu-latest
```
### Descripción:
- El job `terraform` se encarga de inicializar, planificar y aplicar los cambios de infraestructura usando Terraform.
- Se ejecuta en un contenedor con el sistema operativo `ubuntu-latest`.

### Pasos del Job `terraform`:

1. **Clonar el Repositorio**:
   ```yaml
   - name: Check out the repo
     uses: actions/checkout@v3
   ```
   Este paso descarga el contenido del repositorio para que Terraform pueda aplicar los cambios.

2. **Configurar Terraform**:
   ```yaml
   - name: Set up Terraform
     uses: hashicorp/setup-terraform@v2
     with:
       terraform_version: 1.4.0
   ```
   Establece Terraform en la versión `1.4.0` para asegurarse de que la ejecución sea consistente con el entorno deseado.

3. **Inicializar Terraform**:
   ```yaml
   - name: Initialize Terraform
     working-directory: infra
     env:
       AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
       AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
     run: terraform init
   ```
   - `terraform init` inicializa el directorio de trabajo especificado (`infra`) descargando los plugins necesarios.
   - Utiliza las credenciales secretas almacenadas en GitHub para autenticar la conexión con AWS.

4. **Planificar los Cambios de Terraform**:
   ```yaml
   - name: Terraform Plan
     working-directory: infra
     env:
       AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
       AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
     run: terraform plan
   ```
   - `terraform plan` muestra los cambios que se aplicarán a la infraestructura, permitiendo revisar antes de aplicar.
   - Ayuda a detectar errores potenciales antes de realizar cambios en el entorno real.

5. **Aplicar los Cambios de Terraform**:
   ```yaml
   - name: Terraform Apply
     working-directory: infra
     env:
       AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
       AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
       AWS_REGION: us-east-1
     run: terraform apply -auto-approve
   ```
   - `terraform apply` aplica los cambios especificados en el plan.
   - La opción `-auto-approve` aplica los cambios sin necesidad de confirmación manual, permitiendo la automatización completa.
   - Se especifica la región de AWS (`us-east-1`) donde se realizará el despliegue.

