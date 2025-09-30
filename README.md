# Condominium Management System - Frontend

Interfaz web moderna para el sistema de gestión de condominios desarrollada con React y Vite.

## 🚀 Características

- **Dashboard Administrativo**: Panel completo para administradores
- **Dashboard de Residente**: Interfaz específica para residentes
- **Gestión de Mascotas**: CRUD completo con información de propietarios
- **Autenticación por Roles**: Acceso basado en roles de usuario
- **Interfaz Responsiva**: Diseño adaptable a dispositivos móviles
- **Componentes Reutilizables**: Arquitectura modular y escalable

## 🛠️ Tecnologías

- **React 19.1.1**
- **Vite 7.1.2** (Build tool)
- **Tailwind CSS 4.1.13** (Styling)
- **React Router** (Navegación)
- **JWT Authentication**
- **Axios** (Cliente HTTP)

## ⚙️ Instalación

### Prerrequisitos
- Node.js 18 o superior
- npm o yarn

### Pasos de instalación

1. **Clonar el repositorio**
```bash
git clone https://github.com/Fivoryu/Frontend-GC.git
cd Frontend-GC
```

2. **Instalar dependencias**
```bash
npm install
```

3. **Configurar variables de entorno**
```bash
# Copiar archivo de ejemplo
cp .env.example .env

# Editar .env con tu configuración
```

4. **Ejecutar en modo desarrollo**
```bash
npm run dev
```

5. **Acceder a la aplicación**
```
http://localhost:5173
```

## 🏗️ Scripts Disponibles

```bash
# Desarrollo
npm run dev

# Build para producción
npm run build

# Preview del build
npm run preview

# Linting
npm run lint
```

## 🔧 Configuración

### Variables de Entorno

Crear un archivo `.env` en la raíz del proyecto:

```env
VITE_API_URL=http://localhost:8000
VITE_APP_NAME=Condominium Management
```

### Para Producción

```env
VITE_API_URL=https://tu-api-backend.com
VITE_APP_NAME=Condominium Management
```

## 📱 Funcionalidades

### Para Administradores
- **Dashboard Principal**: Resumen general del condominio
- **Gestión de Residentes**: CRUD completo de residentes
- **Gestión de Mascotas**: Control de mascotas con datos de propietarios
- **Gestión de Vehículos**: Registro y control de vehículos
- **Control de Visitantes**: Registro de visitas
- **Gestión de Áreas**: Administración de áreas comunes
- **Control de Personal**: Gestión de empleados

### Para Residentes
- **Dashboard Personal**: Vista específica del residente
- **Información Personal**: Consulta de datos personales
- **Mascotas**: Vista de mascotas registradas
- **Vehículos**: Vista de vehículos registrados
- **Visitantes**: Historial de visitantes

## 🎨 Estructura de Componentes

```
src/
├── components/
│   ├── dashboard/       # Componentes específicos del dashboard
│   ├── tabla/          # Componente de tabla inteligente
│   └── ui/             # Componentes de interfaz
├── layouts/            # Layouts principales
├── pages/              # Páginas de la aplicación
├── routes/             # Configuración de rutas
├── services/           # Servicios y API client
└── utils/              # Utilidades
```

## 🎯 Rutas Principales

### Públicas
- `/login` - Página de inicio de sesión

### Administrador
- `/admin` - Dashboard administrativo
- `/admin/residentes` - Gestión de residentes
- `/admin/mascotas` - Gestión de mascotas
- `/admin/vehiculos` - Gestión de vehículos
- `/admin/visitantes` - Gestión de visitantes

### Residente
- `/residente` - Dashboard del residente
- `/residente/perfil` - Perfil personal
- `/residente/mascotas` - Mascotas del residente

## 🔐 Autenticación

El sistema utiliza JWT para la autenticación:

1. **Login**: El usuario ingresa credenciales
2. **Token**: Se recibe un JWT del backend
3. **Almacenamiento**: Token se guarda en localStorage
4. **Validación**: Cada request incluye el token
5. **Roles**: Redirección basada en el rol del usuario

## 🚀 Despliegue

### Vercel (Recomendado)
1. Conectar repositorio a Vercel
2. Configurar variables de entorno
3. Deploy automático en cada push

### Netlify
1. Conectar repositorio a Netlify
2. Configurar build command: `npm run build`
3. Configurar publish directory: `dist`
4. Agregar variables de entorno

### Build Manual
```bash
npm run build
```

Los archivos estáticos se generan en la carpeta `dist/`

## 📋 Configuración de Deployment

### vercel.json
```json
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
```

### _redirects (Netlify)
```
/*    /index.html   200
```

## 🤝 Contribuir

1. Fork el proyecto
2. Crear rama para feature (`git checkout -b feature/AmazingFeature`)
3. Commit cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 👥 Autores

- **Tu Nombre** - *Desarrollo inicial* - [Fivoryu](https://github.com/Fivoryu)

## 🆘 Soporte

Si tienes problemas o preguntas:
1. Revisa la documentación
2. Busca en los issues existentes
3. Crea un nuevo issue

## 📚 Recursos Adicionales

- [React Documentation](https://react.dev/)
- [Vite Documentation](https://vite.dev/)
- [Tailwind CSS](https://tailwindcss.com/)
- [React Router](https://reactrouter.com/)+ Vite

This template provides a minimal setup to get React working in Vite with HMR and some ESLint rules.

Currently, two official plugins are available:

- [@vitejs/plugin-react](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react) uses [Babel](https://babeljs.io/) for Fast Refresh
- [@vitejs/plugin-react-swc](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react-swc) uses [SWC](https://swc.rs/) for Fast Refresh

## Expanding the ESLint configuration

If you are developing a production application, we recommend using TypeScript with type-aware lint rules enabled. Check out the [TS template](https://github.com/vitejs/vite/tree/main/packages/create-vite/template-react-ts) for information on how to integrate TypeScript and [`typescript-eslint`](https://typescript-eslint.io) in your project.
