# Script de despliegue para Firebase Hosting - PowerShell
# Condominium Management System - Frontend

param(
    [string]$ProjectId = $env:FIREBASE_PROJECT_ID,
    [string]$BackendUrl = "https://condominium-api.run.app",
    [string]$Environment = "production",
    [string]$CustomDomain = "",
    [switch]$SkipTests,
    [switch]$Help
)

# Configuración de colores
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Blue"

# Funciones de utilidad
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor $Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Red
}

# Mostrar ayuda
if ($Help) {
    Write-Host "Condominium Management System - Despliegue Frontend" -ForegroundColor $Green
    Write-Host "================================================="
    Write-Host ""
    Write-Host "Uso: .\deploy-gcp.ps1 [parametros]"
    Write-Host ""
    Write-Host "Parámetros:"
    Write-Host "  -ProjectId      ID del proyecto Firebase"
    Write-Host "  -BackendUrl     URL del backend en Cloud Run"
    Write-Host "  -Environment    Entorno (development/staging/production)"
    Write-Host "  -CustomDomain   Dominio personalizado (opcional)"
    Write-Host "  -SkipTests      Omitir tests"
    Write-Host ""
    Write-Host "Variables de entorno opcionales:"
    Write-Host "  GA_TRACKING_ID         ID de Google Analytics"
    Write-Host "  CLOUDINARY_CLOUD_NAME  Nombre del cloud de Cloudinary"
    Write-Host "  STRIPE_PUBLISHABLE_KEY Clave pública de Stripe"
    Write-Host ""
    Write-Host "Ejemplo:"
    Write-Host "  .\deploy-gcp.ps1 -ProjectId 'mi-proyecto' -BackendUrl 'https://mi-api.run.app'"
    exit 0
}

# Verificar parámetros requeridos
if (-not $ProjectId) {
    Write-Error "ProjectId es requerido. Use -ProjectId 'su-proyecto-id'"
    exit 1
}

Write-Host "🚀 Iniciando despliegue del frontend en Firebase Hosting..." -ForegroundColor $Green
Write-Host "========================================================="

# Verificar dependencias
function Test-Dependencies {
    Write-Status "Verificando dependencias..."
    
    # Verificar Node.js
    try {
        $null = Get-Command node -ErrorAction Stop
        $nodeVersion = node --version
        Write-Success "Node.js encontrado: $nodeVersion"
    }
    catch {
        Write-Error "Node.js no está instalado."
        exit 1
    }
    
    # Verificar npm
    try {
        $null = Get-Command npm -ErrorAction Stop
        $npmVersion = npm --version
        Write-Success "npm encontrado: $npmVersion"
    }
    catch {
        Write-Error "npm no está instalado."
        exit 1
    }
    
    # Verificar Firebase CLI
    try {
        $null = Get-Command firebase -ErrorAction Stop
        $firebaseVersion = firebase --version
        Write-Success "Firebase CLI encontrado: $firebaseVersion"
    }
    catch {
        Write-Error "Firebase CLI no está instalado. Instálalo con: npm install -g firebase-tools"
        exit 1
    }
    
    Write-Success "Todas las dependencias están instaladas."
}

# Configurar autenticación de Firebase
function Set-FirebaseAuth {
    Write-Status "Configurando autenticación de Firebase..."
    
    # Verificar si ya está autenticado
    $projects = firebase projects:list --json 2>$null | ConvertFrom-Json
    $projectExists = $projects | Where-Object { $_.projectId -eq $ProjectId }
    
    if (-not $projectExists) {
        Write-Status "Iniciando autenticación con Firebase..."
        firebase login
    }
    
    # Usar proyecto específico
    firebase use $ProjectId
    
    Write-Success "Autenticación de Firebase configurada."
}

# Instalar dependencias del proyecto
function Install-Dependencies {
    Write-Status "Instalando dependencias del proyecto..."
    
    # Limpiar cache de npm
    npm cache clean --force
    
    # Eliminar node_modules y reinstalar
    if (Test-Path "node_modules") {
        Remove-Item -Recurse -Force "node_modules"
    }
    if (Test-Path "package-lock.json") {
        Remove-Item -Force "package-lock.json"
    }
    
    npm install
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Error al instalar dependencias."
        exit 1
    }
    
    Write-Success "Dependencias instaladas."
}

# Configurar variables de entorno para build
function Set-Environment {
    Write-Status "Configurando variables de entorno para $Environment..."
    
    # Crear archivo .env.local para el build
    $envContent = @"
VITE_API_BASE=$BackendUrl
VITE_ENVIRONMENT=$Environment
VITE_APP_NAME=Condominium Management
VITE_APP_VERSION=1.0.0
"@
    
    if ($Environment -eq "production") {
        # Variables específicas de producción
        $envContent += @"

VITE_GA_TRACKING_ID=$env:GA_TRACKING_ID
VITE_CLOUDINARY_CLOUD_NAME=$env:CLOUDINARY_CLOUD_NAME
VITE_STRIPE_PUBLISHABLE_KEY=$env:STRIPE_PUBLISHABLE_KEY
"@
    }
    
    $envContent | Out-File -FilePath ".env.local" -Encoding UTF8
    
    Write-Success "Variables de entorno configuradas."
}

# Ejecutar tests
function Invoke-Tests {
    if (-not $SkipTests) {
        Write-Status "Ejecutando tests..."
        
        # Verificar lint
        npm run lint
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Errores de linting encontrados."
            exit 1
        }
        
        # Ejecutar tests unitarios si existen
        $testScript = (Get-Content "package.json" | ConvertFrom-Json).scripts.test
        if ($testScript) {
            npm run test
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Tests fallaron."
                exit 1
            }
        }
        else {
            Write-Warning "No se encontraron tests unitarios."
        }
        
        Write-Success "Tests completados."
    }
    else {
        Write-Warning "Tests omitidos."
    }
}

# Construir aplicación
function Build-Application {
    Write-Status "Construyendo aplicación para $Environment..."
    
    # Limpiar directorio de build anterior
    if (Test-Path "dist") {
        Remove-Item -Recurse -Force "dist"
    }
    
    # Construir aplicación
    npm run build
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "El build falló."
        exit 1
    }
    
    # Verificar que el build fue exitoso
    if (-not (Test-Path "dist")) {
        Write-Error "El build falló. No se encontró el directorio 'dist'."
        exit 1
    }
    
    Write-Success "Aplicación construida exitosamente."
}

# Actualizar configuración de Firebase
function Update-FirebaseConfig {
    Write-Status "Actualizando configuración de Firebase..."
    
    # Actualizar firebase.json con la URL del backend
    if (Test-Path "firebase.json") {
        $firebaseConfig = Get-Content "firebase.json" -Raw
        $firebaseConfig = $firebaseConfig -replace "https://condominium-api-SERVICE_ID.run.app", $BackendUrl
        $firebaseConfig | Out-File -FilePath "firebase.json" -Encoding UTF8
    }
    
    Write-Success "Configuración de Firebase actualizada."
}

# Desplegar en Firebase Hosting
function Deploy-ToFirebase {
    Write-Status "Desplegando en Firebase Hosting..."
    
    # Desplegar
    firebase deploy --only hosting
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Error durante el despliegue."
        exit 1
    }
    
    # Obtener URL del sitio desplegado
    $SiteUrl = "$ProjectId.web.app"
    
    Write-Success "Aplicación desplegada en: https://$SiteUrl"
    return $SiteUrl
}

# Configurar dominio personalizado
function Set-CustomDomain {
    param([string]$Domain)
    
    if ($Domain) {
        Write-Status "Configurando dominio personalizado: $Domain"
        
        firebase hosting:sites:create $Domain --project $ProjectId
        firebase target:apply hosting main $Domain --project $ProjectId
        
        Write-Warning "Configura los registros DNS según las instrucciones de Firebase."
    }
}

# Función de limpieza
function Invoke-Cleanup {
    Write-Status "Limpiando archivos temporales..."
    
    # Eliminar archivo de entorno temporal
    if (Test-Path ".env.local") {
        Remove-Item -Force ".env.local"
    }
    
    Write-Success "Limpieza completada."
}

# Función principal
function Main {
    try {
        Write-Host "🌐 Condominium Management System - Despliegue Frontend" -ForegroundColor $Green
        Write-Host "====================================================="
        Write-Host ""
        Write-Host "📋 Configuración:" -ForegroundColor $Blue
        Write-Host "   Proyecto: $ProjectId"
        Write-Host "   Backend: $BackendUrl"
        Write-Host "   Entorno: $Environment"
        if ($CustomDomain) {
            Write-Host "   Dominio: $CustomDomain"
        }
        Write-Host ""
        
        Test-Dependencies
        Set-FirebaseAuth
        Install-Dependencies
        Set-Environment
        Invoke-Tests
        Build-Application
        Update-FirebaseConfig
        $SiteUrl = Deploy-ToFirebase
        Set-CustomDomain -Domain $CustomDomain
        Invoke-Cleanup
        
        Write-Host ""
        Write-Host "✅ ¡Despliegue del frontend completado exitosamente!" -ForegroundColor $Green
        Write-Host "🌐 URL del sitio: https://$SiteUrl" -ForegroundColor $Blue
        Write-Host "🔗 Backend: $BackendUrl" -ForegroundColor $Blue
        Write-Host ""
        Write-Host "📝 Próximos pasos:" -ForegroundColor $Yellow
        Write-Host "1. Verificar que la aplicación funciona correctamente"
        Write-Host "2. Configurar dominio personalizado (si es necesario)"
        Write-Host "3. Configurar Google Analytics (si es necesario)"
        Write-Host "4. Configurar alertas de monitoreo"
    }
    catch {
        Write-Error "Error durante el despliegue: $($_.Exception.Message)"
        Invoke-Cleanup
        exit 1
    }
}

# Ejecutar función principal
Main