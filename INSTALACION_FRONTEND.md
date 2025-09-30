# 🚀 Instalación y Configuración del Frontend

## ✅ Estado de la Instalación

El frontend del Sistema de Condominios ha sido **instalado correctamente** y está listo para usar.

## 📋 Requisitos Previos

- ✅ **Node.js v22.14.0** (instalado)
- ✅ **npm v11.3.0** (instalado)
- ✅ **Dependencias del proyecto** (240 packages instalados)

## 🛠️ Configuración Actual

### Variables de Entorno
- ✅ Archivo `.env` creado con configuración para desarrollo local
- ✅ Backend configurado en: `http://localhost:8000`

### Dependencias Principales
- ✅ React 19.1.1
- ✅ Vite 7.1.2  
- ✅ React Router DOM 7.8.2
- ✅ Tailwind CSS 4.1.13
- ✅ jsPDF para generación de reportes

## 🚀 Comandos de Inicio

### Opción 1: Comando directo
```bash
npm run dev
```

### Opción 2: Script de Windows (.bat)
```bash
./start-frontend.bat
```

### Opción 3: Script de PowerShell
```powershell
./start-frontend.ps1
```

## 🌐 URLs del Sistema

- **Frontend:** http://localhost:5173
- **Backend API:** http://localhost:8000

## 📁 Estructura del Proyecto

```
condominium-web/
├── src/
│   ├── components/     # Componentes reutilizables
│   ├── pages/         # Páginas de la aplicación
│   ├── layouts/       # Layouts principales
│   ├── routes/        # Configuración de rutas
│   ├── services/      # Servicios y API client
│   └── utils/         # Utilidades
├── public/            # Archivos públicos
├── .env              # Variables de entorno
└── package.json      # Configuración del proyecto
```

## 🔧 Comandos Disponibles

| Comando | Descripción |
|---------|-------------|
| `npm run dev` | Inicia el servidor de desarrollo |
| `npm run build` | Construye la aplicación para producción |
| `npm run preview` | Previsualiza el build de producción |
| `npm run lint` | Ejecuta el linter de código |

## 🔐 Funcionalidades Implementadas

- ✅ Sistema de autenticación JWT
- ✅ Dashboard administrativo completo
- ✅ Gestión de usuarios y roles
- ✅ Módulos de residentes, personal, áreas comunes
- ✅ Sistema de reservas y pagos
- ✅ Generación de reportes PDF
- ✅ Diseño responsivo con Tailwind CSS

## 🚨 Solución de Problemas

### El servidor no inicia
1. Verificar que estás en el directorio correcto (`condominium-web`)
2. Ejecutar `npm install` para reinstalar dependencias
3. Verificar que Node.js esté instalado: `node --version`

### Error de conexión con el backend
1. Verificar que el backend esté ejecutándose en puerto 8000
2. Revisar el archivo `.env` para confirmar la URL del backend
3. Verificar la configuración del proxy en `vite.config.js`

### Problemas con permisos
- En Windows: Ejecutar PowerShell como administrador
- Verificar permisos de ejecución: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

## 📞 Próximos Pasos

1. **Iniciar el backend:** Asegúrate de que la API de Django esté ejecutándose
2. **Acceder al sistema:** Navega a http://localhost:5173
3. **Crear usuarios:** Usa el panel de administración para crear cuentas
4. **Configurar datos:** Agrega residentes, áreas comunes, etc.

---

**✅ Instalación completada el 30 de Septiembre, 2025**