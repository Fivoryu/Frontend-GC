# Script de despliegue para AWS S3 + CloudFront (Windows)
# Asegúrate de tener AWS CLI configurado

param(
    [string]$BucketName = "condominium-frontend-$(Get-Random)",
    [string]$Region = "us-east-1",
    [string]$DomainName = "",
    [switch]$CreateInfrastructure = $false
)

Write-Host "==========================================" -ForegroundColor Green
Write-Host "  DESPLEGANDO FRONTEND EN AWS S3" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Verificar que estemos en el directorio correcto
if (-not (Test-Path "package.json")) {
    Write-Host "Error: No se encontró package.json. Ejecuta desde el directorio del frontend." -ForegroundColor Red
    exit 1
}

# Verificar que AWS CLI esté instalado y configurado
try {
    $awsIdentity = aws sts get-caller-identity 2>$null | ConvertFrom-Json
    Write-Host "AWS CLI configurado para: $($awsIdentity.Arn)" -ForegroundColor Green
} catch {
    Write-Host "Error: AWS CLI no está configurado. Ejecuta 'aws configure' primero." -ForegroundColor Red
    exit 1
}

# Instalar dependencias si no existen
if (-not (Test-Path "node_modules")) {
    Write-Host "Instalando dependencias..." -ForegroundColor Yellow
    npm install
}

Write-Host "==========================================" -ForegroundColor Green
Write-Host "  CONSTRUYENDO APLICACIÓN" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Construir la aplicación para producción
Write-Host "Construyendo aplicación React..." -ForegroundColor Yellow
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Falló la construcción de la aplicación." -ForegroundColor Red
    exit 1
}

Write-Host "¡Construcción exitosa!" -ForegroundColor Green

if ($CreateInfrastructure) {
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "  CREANDO INFRAESTRUCTURA AWS" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    
    # Crear stack de CloudFormation
    Write-Host "Creando infraestructura con CloudFormation..." -ForegroundColor Yellow
    aws cloudformation create-stack `
        --stack-name "condominium-frontend-stack" `
        --template-body file://aws-cloudformation.json `
        --parameters ParameterKey=BucketName,ParameterValue=$BucketName ParameterKey=DomainName,ParameterValue=$DomainName `
        --region $Region
    
    Write-Host "Esperando a que se complete la creación del stack..." -ForegroundColor Yellow
    aws cloudformation wait stack-create-complete --stack-name "condominium-frontend-stack" --region $Region
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "¡Infraestructura creada exitosamente!" -ForegroundColor Green
        
        # Obtener outputs del stack
        $outputs = aws cloudformation describe-stacks --stack-name "condominium-frontend-stack" --region $Region --query "Stacks[0].Outputs" | ConvertFrom-Json
        $BucketName = ($outputs | Where-Object {$_.OutputKey -eq "BucketName"}).OutputValue
        $WebsiteURL = ($outputs | Where-Object {$_.OutputKey -eq "WebsiteURL"}).OutputValue
        $CloudFrontURL = ($outputs | Where-Object {$_.OutputKey -eq "CloudFrontURL"}).OutputValue
        
        Write-Host "Bucket S3: $BucketName" -ForegroundColor Cyan
        Write-Host "Website URL: $WebsiteURL" -ForegroundColor Cyan
        Write-Host "CloudFront URL: https://$CloudFrontURL" -ForegroundColor Cyan
    } else {
        Write-Host "Error: Falló la creación de la infraestructura." -ForegroundColor Red
        exit 1
    }
} else {
    # Verificar si el bucket existe
    try {
        aws s3 ls "s3://$BucketName" 2>$null
        Write-Host "Usando bucket existente: $BucketName" -ForegroundColor Green
    } catch {
        Write-Host "Creando bucket S3: $BucketName" -ForegroundColor Yellow
        aws s3 mb "s3://$BucketName" --region $Region
        
        # Configurar el bucket para hosting web
        aws s3 website "s3://$BucketName" --index-document index.html --error-document index.html
        
        # Aplicar política de bucket
        $policy = Get-Content "aws-s3-policy.json" | ForEach-Object { $_ -replace "condominium-frontend", $BucketName }
        $policy | Out-File -FilePath "temp-policy.json" -Encoding UTF8
        aws s3api put-bucket-policy --bucket $BucketName --policy file://temp-policy.json
        Remove-Item "temp-policy.json"
        
        Write-Host "¡Bucket configurado para hosting web!" -ForegroundColor Green
    }
}

Write-Host "==========================================" -ForegroundColor Green
Write-Host "  SUBIENDO ARCHIVOS A S3" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Subir archivos al bucket S3
Write-Host "Subiendo archivos al bucket S3..." -ForegroundColor Yellow
aws s3 sync ./dist "s3://$BucketName" --delete --region $Region

if ($LASTEXITCODE -eq 0) {
    Write-Host "¡Archivos subidos exitosamente!" -ForegroundColor Green
} else {
    Write-Host "Error: Falló la subida de archivos." -ForegroundColor Red
    exit 1
}

Write-Host "==========================================" -ForegroundColor Green
Write-Host "  CONFIGURACIÓN DE CACHE" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Configurar headers de cache para diferentes tipos de archivos
Write-Host "Configurando headers de cache..." -ForegroundColor Yellow

# JavaScript y CSS con cache largo
aws s3 cp ./dist "s3://$BucketName" --recursive --exclude "*" --include "*.js" --cache-control "max-age=31536000" --region $Region
aws s3 cp ./dist "s3://$BucketName" --recursive --exclude "*" --include "*.css" --cache-control "max-age=31536000" --region $Region

# HTML sin cache
aws s3 cp ./dist "s3://$BucketName" --recursive --exclude "*" --include "*.html" --cache-control "no-cache" --region $Region

Write-Host "==========================================" -ForegroundColor Green
Write-Host "  DESPLIEGUE COMPLETADO" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

$websiteUrl = "http://$BucketName.s3-website-$Region.amazonaws.com"
Write-Host "✅ Frontend desplegado exitosamente!" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 URLs de acceso:" -ForegroundColor Cyan
Write-Host "   S3 Website: $websiteUrl" -ForegroundColor White
if ($CloudFrontURL) {
    Write-Host "   CloudFront: https://$CloudFrontURL" -ForegroundColor White
}
Write-Host ""
Write-Host "📋 Próximos pasos:" -ForegroundColor Cyan
Write-Host "   1. Configura tu dominio personalizado (opcional)" -ForegroundColor White
Write-Host "   2. Configura SSL/TLS con AWS Certificate Manager" -ForegroundColor White
Write-Host "   3. Actualiza las variables de entorno del backend con la nueva URL" -ForegroundColor White
Write-Host ""
Write-Host "💡 Para futuras actualizaciones:" -ForegroundColor Cyan
Write-Host "   .\deploy-aws.ps1 -BucketName $BucketName" -ForegroundColor White

# Abrir en el navegador
$confirm = Read-Host "¿Quieres abrir la aplicación en el navegador? (y/n)"
if ($confirm -eq "y" -or $confirm -eq "Y" -or $confirm -eq "yes" -or $confirm -eq "Yes") {
    Start-Process $websiteUrl
}