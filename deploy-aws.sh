#!/bin/bash

# Script de despliegue para AWS S3 + CloudFront (Linux/Mac)
# Asegúrate de tener AWS CLI configurado

# Configuración por defecto
BUCKET_NAME=${1:-"condominium-frontend-$(date +%s)"}
REGION=${2:-"us-east-1"}
DOMAIN_NAME=${3:-""}
CREATE_INFRASTRUCTURE=${4:-false}

echo "=========================================="
echo "  DESPLEGANDO FRONTEND EN AWS S3"
echo "=========================================="

# Verificar que estemos en el directorio correcto
if [ ! -f "package.json" ]; then
    echo "Error: No se encontró package.json. Ejecuta desde el directorio del frontend."
    exit 1
fi

# Verificar que AWS CLI esté instalado y configurado
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI no está instalado."
    exit 1
fi

# Verificar configuración de AWS
if ! aws sts get-caller-identity &> /dev/null; then
    echo "Error: AWS CLI no está configurado. Ejecuta 'aws configure' primero."
    exit 1
fi

echo "AWS CLI configurado correctamente."

# Instalar dependencias si no existen
if [ ! -d "node_modules" ]; then
    echo "Instalando dependencias..."
    npm install
fi

echo "=========================================="
echo "  CONSTRUYENDO APLICACIÓN"
echo "=========================================="

# Construir la aplicación para producción
echo "Construyendo aplicación React..."
npm run build

if [ $? -ne 0 ]; then
    echo "Error: Falló la construcción de la aplicación."
    exit 1
fi

echo "¡Construcción exitosa!"

if [ "$CREATE_INFRASTRUCTURE" = "true" ]; then
    echo "=========================================="
    echo "  CREANDO INFRAESTRUCTURA AWS"
    echo "=========================================="
    
    # Crear stack de CloudFormation
    echo "Creando infraestructura con CloudFormation..."
    aws cloudformation create-stack \
        --stack-name "condominium-frontend-stack" \
        --template-body file://aws-cloudformation.json \
        --parameters ParameterKey=BucketName,ParameterValue="$BUCKET_NAME" ParameterKey=DomainName,ParameterValue="$DOMAIN_NAME" \
        --region "$REGION"
    
    echo "Esperando a que se complete la creación del stack..."
    aws cloudformation wait stack-create-complete --stack-name "condominium-frontend-stack" --region "$REGION"
    
    if [ $? -eq 0 ]; then
        echo "¡Infraestructura creada exitosamente!"
        
        # Obtener outputs del stack
        BUCKET_NAME=$(aws cloudformation describe-stacks --stack-name "condominium-frontend-stack" --region "$REGION" --query "Stacks[0].Outputs[?OutputKey=='BucketName'].OutputValue" --output text)
        WEBSITE_URL=$(aws cloudformation describe-stacks --stack-name "condominium-frontend-stack" --region "$REGION" --query "Stacks[0].Outputs[?OutputKey=='WebsiteURL'].OutputValue" --output text)
        CLOUDFRONT_URL=$(aws cloudformation describe-stacks --stack-name "condominium-frontend-stack" --region "$REGION" --query "Stacks[0].Outputs[?OutputKey=='CloudFrontURL'].OutputValue" --output text)
        
        echo "Bucket S3: $BUCKET_NAME"
        echo "Website URL: $WEBSITE_URL"
        echo "CloudFront URL: https://$CLOUDFRONT_URL"
    else
        echo "Error: Falló la creación de la infraestructura."
        exit 1
    fi
else
    # Verificar si el bucket existe
    if aws s3 ls "s3://$BUCKET_NAME" &> /dev/null; then
        echo "Usando bucket existente: $BUCKET_NAME"
    else
        echo "Creando bucket S3: $BUCKET_NAME"
        aws s3 mb "s3://$BUCKET_NAME" --region "$REGION"
        
        # Configurar el bucket para hosting web
        aws s3 website "s3://$BUCKET_NAME" --index-document index.html --error-document index.html
        
        # Aplicar política de bucket
        sed "s/condominium-frontend/$BUCKET_NAME/g" aws-s3-policy.json > temp-policy.json
        aws s3api put-bucket-policy --bucket "$BUCKET_NAME" --policy file://temp-policy.json
        rm temp-policy.json
        
        echo "¡Bucket configurado para hosting web!"
    fi
fi

echo "=========================================="
echo "  SUBIENDO ARCHIVOS A S3"
echo "=========================================="

# Subir archivos al bucket S3
echo "Subiendo archivos al bucket S3..."
aws s3 sync ./dist "s3://$BUCKET_NAME" --delete --region "$REGION"

if [ $? -eq 0 ]; then
    echo "¡Archivos subidos exitosamente!"
else
    echo "Error: Falló la subida de archivos."
    exit 1
fi

echo "=========================================="
echo "  CONFIGURACIÓN DE CACHE"
echo "=========================================="

# Configurar headers de cache para diferentes tipos de archivos
echo "Configurando headers de cache..."

# JavaScript y CSS con cache largo
aws s3 cp ./dist "s3://$BUCKET_NAME" --recursive --exclude "*" --include "*.js" --cache-control "max-age=31536000" --region "$REGION"
aws s3 cp ./dist "s3://$BUCKET_NAME" --recursive --exclude "*" --include "*.css" --cache-control "max-age=31536000" --region "$REGION"

# HTML sin cache
aws s3 cp ./dist "s3://$BUCKET_NAME" --recursive --exclude "*" --include "*.html" --cache-control "no-cache" --region "$REGION"

echo "=========================================="
echo "  DESPLIEGUE COMPLETADO"
echo "=========================================="

WEBSITE_URL="http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com"
echo "✅ Frontend desplegado exitosamente!"
echo ""
echo "🌐 URLs de acceso:"
echo "   S3 Website: $WEBSITE_URL"
if [ -n "$CLOUDFRONT_URL" ]; then
    echo "   CloudFront: https://$CLOUDFRONT_URL"
fi
echo ""
echo "📋 Próximos pasos:"
echo "   1. Configura tu dominio personalizado (opcional)"
echo "   2. Configura SSL/TLS con AWS Certificate Manager"
echo "   3. Actualiza las variables de entorno del backend con la nueva URL"
echo ""
echo "💡 Para futuras actualizaciones:"
echo "   ./deploy-aws.sh $BUCKET_NAME"

# Preguntar si abrir en el navegador
read -p "¿Quieres abrir la aplicación en el navegador? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v open &> /dev/null; then
        open "$WEBSITE_URL"
    elif command -v xdg-open &> /dev/null; then
        xdg-open "$WEBSITE_URL"
    else
        echo "Abre manualmente: $WEBSITE_URL"
    fi
fi