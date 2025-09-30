@echo off
echo Iniciando el frontend del Sistema de Condominios...
echo.

REM Verificar si Node.js está instalado
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Node.js no está instalado o no está en el PATH
    echo Por favor, instala Node.js desde https://nodejs.org/
    pause
    exit /b 1
)

REM Verificar si estamos en el directorio correcto
if not exist package.json (
    echo ERROR: No se encontró package.json
    echo Asegúrate de ejecutar este script desde el directorio condominium-web
    pause
    exit /b 1
)

REM Verificar si las dependencias están instaladas
if not exist node_modules (
    echo Instalando dependencias por primera vez...
    npm install
    if %errorlevel% neq 0 (
        echo ERROR: Falló la instalación de dependencias
        pause
        exit /b 1
    )
)

REM Crear archivo .env si no existe
if not exist .env (
    echo Creando archivo de configuración .env...
    echo VITE_API_BASE=http://localhost:8000 > .env
)

echo.
echo ===================================
echo  Frontend iniciándose en:
echo  http://localhost:5173
echo ===================================
echo.
echo Para detener el servidor, presiona Ctrl+C
echo.

REM Iniciar el servidor de desarrollo
npm run dev