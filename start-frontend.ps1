# Script para iniciar el frontend del Sistema de Condominios
Write-Host "Iniciando el frontend del Sistema de Condominios..." -ForegroundColor Green
Write-Host ""

# Verificar si Node.js está instalado
try {
    $nodeVersion = node --version
    Write-Host "Node.js detectado: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Node.js no está instalado o no está en el PATH" -ForegroundColor Red
    Write-Host "Por favor, instala Node.js desde https://nodejs.org/" -ForegroundColor Yellow
    Read-Host "Presiona Enter para salir"
    exit 1
}

# Verificar si estamos en el directorio correcto
if (-not (Test-Path "package.json")) {
    Write-Host "ERROR: No se encontró package.json" -ForegroundColor Red
    Write-Host "Asegúrate de ejecutar este script desde el directorio condominium-web" -ForegroundColor Yellow
    Read-Host "Presiona Enter para salir"
    exit 1
}

# Verificar si las dependencias están instaladas
if (-not (Test-Path "node_modules")) {
    Write-Host "Instalando dependencias por primera vez..." -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Falló la instalación de dependencias" -ForegroundColor Red
        Read-Host "Presiona Enter para salir"
        exit 1
    }
}

# Crear archivo .env si no existe
if (-not (Test-Path ".env")) {
    Write-Host "Creando archivo de configuración .env..." -ForegroundColor Yellow
    "VITE_API_BASE=http://localhost:8000" | Out-File -FilePath ".env" -Encoding UTF8
}

Write-Host ""
Write-Host "===================================" -ForegroundColor Cyan
Write-Host " Frontend iniciándose en:" -ForegroundColor Cyan
Write-Host " http://localhost:5173" -ForegroundColor Yellow
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para detener el servidor, presiona Ctrl+C" -ForegroundColor Magenta
Write-Host ""

# Iniciar el servidor de desarrollo
npm run dev