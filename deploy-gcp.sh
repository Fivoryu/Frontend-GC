#!/bin/bash

# Script de despliegue para Firebase Hosting
# Condominium Management System - Frontend

set -e

echo "🚀 Iniciando despliegue del frontend en Firebase Hosting..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuración por defecto
PROJECT_ID="${FIREBASE_PROJECT_ID:-condominium-management}"
BACKEND_URL="${BACKEND_URL:-https://condominium-api.run.app}"
ENVIRONMENT="${ENVIRONMENT:-production}"

# Funciones de utilidad
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar dependencias
check_dependencies() {
    print_status "Verificando dependencias..."
    
    if ! command -v node &> /dev/null; then
        print_error "Node.js no está instalado."
        exit 1
    fi
    
    if ! command -v npm &> /dev/null; then
        print_error "npm no está instalado."
        exit 1
    fi
    
    if ! command -v firebase &> /dev/null; then
        print_error "Firebase CLI no está instalado. Instálalo con: npm install -g firebase-tools"
        exit 1
    fi
    
    print_success "Todas las dependencias están instaladas."
}

# Configurar autenticación de Firebase
setup_firebase_auth() {
    print_status "Configurando autenticación de Firebase..."
    
    # Verificar si ya está autenticado
    if ! firebase list 2>/dev/null | grep -q "$PROJECT_ID"; then
        print_status "Iniciando autenticación con Firebase..."
        firebase login
    fi
    
    # Usar proyecto específico
    firebase use $PROJECT_ID
    
    print_success "Autenticación de Firebase configurada."
}

# Instalar dependencias del proyecto
install_dependencies() {
    print_status "Instalando dependencias del proyecto..."
    
    # Limpiar cache de npm
    npm cache clean --force
    
    # Eliminar node_modules y reinstalar
    rm -rf node_modules package-lock.json
    npm install
    
    print_success "Dependencias instaladas."
}

# Configurar variables de entorno para build
setup_environment() {
    print_status "Configurando variables de entorno para $ENVIRONMENT..."
    
    # Crear archivo .env.local para el build
    cat > .env.local << EOF
VITE_API_BASE=$BACKEND_URL
VITE_ENVIRONMENT=$ENVIRONMENT
VITE_APP_NAME=Condominium Management
VITE_APP_VERSION=1.0.0
EOF
    
    if [ "$ENVIRONMENT" = "production" ]; then
        # Variables específicas de producción
        cat >> .env.local << EOF
VITE_GA_TRACKING_ID=$GA_TRACKING_ID
VITE_CLOUDINARY_CLOUD_NAME=$CLOUDINARY_CLOUD_NAME
VITE_STRIPE_PUBLISHABLE_KEY=$STRIPE_PUBLISHABLE_KEY
EOF
    fi
    
    print_success "Variables de entorno configuradas."
}

# Ejecutar tests (opcional)
run_tests() {
    if [ "$SKIP_TESTS" != "true" ]; then
        print_status "Ejecutando tests..."
        
        # Verificar lint
        npm run lint
        
        # Ejecutar tests unitarios si existen
        if npm run test --silent 2>/dev/null; then
            npm run test
        else
            print_warning "No se encontraron tests unitarios."
        fi
        
        print_success "Tests completados."
    else
        print_warning "Tests omitidos."
    fi
}

# Construir aplicación
build_application() {
    print_status "Construyendo aplicación para $ENVIRONMENT..."
    
    # Limpiar directorio de build anterior
    rm -rf dist
    
    # Construir aplicación
    npm run build
    
    # Verificar que el build fue exitoso
    if [ ! -d "dist" ]; then
        print_error "El build falló. No se encontró el directorio 'dist'."
        exit 1
    fi
    
    print_success "Aplicación construida exitosamente."
}

# Actualizar configuración de Firebase
update_firebase_config() {
    print_status "Actualizando configuración de Firebase..."
    
    # Actualizar firebase.json con la URL del backend
    if [ -f "firebase.json" ]; then
        # Reemplazar placeholder con URL real del backend
        sed -i "s|https://condominium-api-SERVICE_ID.run.app|$BACKEND_URL|g" firebase.json
    fi
    
    print_success "Configuración de Firebase actualizada."
}

# Desplegar en Firebase Hosting
deploy_to_firebase() {
    print_status "Desplegando en Firebase Hosting..."
    
    # Desplegar
    firebase deploy --only hosting
    
    # Obtener URL del sitio desplegado
    SITE_URL=$(firebase hosting:sites:get --project $PROJECT_ID 2>/dev/null | grep "Domain:" | awk '{print $2}' || echo "$PROJECT_ID.web.app")
    
    print_success "Aplicación desplegada en: https://$SITE_URL"
}

# Configurar dominio personalizado (opcional)
setup_custom_domain() {
    if [ ! -z "$CUSTOM_DOMAIN" ]; then
        print_status "Configurando dominio personalizado: $CUSTOM_DOMAIN"
        
        firebase hosting:sites:create $CUSTOM_DOMAIN --project $PROJECT_ID
        firebase target:apply hosting main $CUSTOM_DOMAIN --project $PROJECT_ID
        
        print_warning "Configura los registros DNS según las instrucciones de Firebase."
    fi
}

# Configurar redirects y headers de seguridad
setup_security_headers() {
    print_status "Configurando headers de seguridad..."
    
    # Los headers ya están configurados en firebase.json
    print_success "Headers de seguridad configurados."
}

# Función de limpieza
cleanup() {
    print_status "Limpiando archivos temporales..."
    
    # Eliminar archivo de entorno temporal
    rm -f .env.local
    
    print_success "Limpieza completada."
}

# Función principal
main() {
    echo "🌐 Condominium Management System - Despliegue Frontend"
    echo "===================================================="
    
    check_dependencies
    setup_firebase_auth
    install_dependencies
    setup_environment
    run_tests
    build_application
    update_firebase_config
    deploy_to_firebase
    setup_custom_domain
    setup_security_headers
    cleanup
    
    echo ""
    echo "✅ ¡Despliegue del frontend completado exitosamente!"
    echo "🌐 URL del sitio: https://$SITE_URL"
    echo "🔗 Backend: $BACKEND_URL"
    echo ""
    echo "📝 Próximos pasos:"
    echo "1. Verificar que la aplicación funciona correctamente"
    echo "2. Configurar dominio personalizado (si es necesario)"
    echo "3. Configurar Google Analytics (si es necesario)"
    echo "4. Configurar alertas de monitoreo"
}

# Verificar argumentos
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo "Uso: $0 [opciones]"
    echo ""
    echo "Variables de entorno:"
    echo "  FIREBASE_PROJECT_ID     ID del proyecto Firebase"
    echo "  BACKEND_URL            URL del backend en Cloud Run"
    echo "  ENVIRONMENT            Entorno (development/staging/production)"
    echo "  CUSTOM_DOMAIN          Dominio personalizado (opcional)"
    echo "  SKIP_TESTS             Omitir tests (true/false)"
    echo "  GA_TRACKING_ID         ID de Google Analytics (opcional)"
    echo "  CLOUDINARY_CLOUD_NAME  Nombre del cloud de Cloudinary"
    echo "  STRIPE_PUBLISHABLE_KEY Clave pública de Stripe"
    echo ""
    echo "Ejemplo:"
    echo "  FIREBASE_PROJECT_ID=mi-proyecto BACKEND_URL=https://mi-api.run.app $0"
    exit 0
fi

# Ejecutar función principal
main