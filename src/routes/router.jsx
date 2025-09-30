import React from "react";
import {
  createBrowserRouter,
} from "react-router-dom";

import MainLayout from "../layouts/mainLayout.jsx";
import AdminLayout from "../layouts/AdminLayout.jsx";
import ResidenteLayout from "../layouts/ResidenteLayout.jsx";

import Home from "../pages/Home.jsx";
import Login from "../pages/Login.jsx";
import Register from "../pages/Register.jsx";
import RecuperarPassword from "../pages/RecuperarPassword.jsx";

import DashboardHome from "../pages/dashboard/home.jsx";
import ResidenteDashboardHome from "../pages/dashboard/residente/home.jsx";
import ResidentesPage from "../pages/dashboard/residentes/residentes.jsx";
import PersonalPage from "../pages/dashboard/personal/personal.jsx";
import TareasPage from "../pages/dashboard/personal/tareas.jsx";
import AreasPage from "../pages/dashboard/areas/areas.jsx";
import ReglasPage from "../pages/dashboard/areas/reglas.jsx";
import CuentasPage from "../pages/dashboard/usuarios/cuentas.jsx";
import RolesPage from "../pages/dashboard/usuarios/roles.jsx";
import RolCreatePage from "../pages/dashboard/usuarios/RolCreatePage.jsx";
import RolEditPage from "../pages/dashboard/usuarios/RolEditPage.jsx";
import BitacoraPage from "../pages/dashboard/usuarios/bitacora.jsx";
import MascotasPage from "../pages/dashboard/residentes/mascotas.jsx";
import VehiculosPage from "../pages/dashboard/residentes/vehiculos.jsx";
import VisitantesPage from "../pages/dashboard/residentes/visitantes.jsx";
import ResidenciasPage from "../pages/dashboard/residentes/residencias.jsx";
import HorariosPage from "../pages/dashboard/areas/horarios.jsx";
import AvisosPage from "../pages/dashboard/usuarios/avisos.jsx";
import PagosPage from "../pages/dashboard/reserva_pagos/pagos.jsx";
import FacturasPage from "../pages/dashboard/reserva_pagos/facturas.jsx";
import ConceptoPagoPage from "../pages/dashboard/reserva_pagos/conceptosPago.jsx";
import ReservasPage from "../pages/dashboard/reserva_pagos/reservas.jsx";

import ErrorBoundaryPage from "../pages/ErrorBoundaryPage.jsx";
import ProtectedRoute from "../components/routing/ProtectedRoute.jsx";

const router = createBrowserRouter([
  {
    path: "/",
    element: <MainLayout />,
    errorElement: <ErrorBoundaryPage />,
    children: [
      { index: true, element: <Home /> },
      { path: "login", element: <Login /> },
      { path: "register", element: <Register /> },
    ]
  },
  {
    path: "/dashboard",
    element: (
      <ProtectedRoute roles={['Admin', 'Administrador']}>
        <AdminLayout />
      </ProtectedRoute>
    ),
    errorElement: <ErrorBoundaryPage />,
    children: [
      { index: true, element: <DashboardHome /> },
      { path: "residentes", element: <ResidentesPage /> },
      { path: "personal", element: <PersonalPage /> },
      { path: "tareas", element: <TareasPage /> },
      { path: "areas", element: <AreasPage /> },
      { path: "areas/reglas", element: <ReglasPage /> },
      { path: "usuarios", element: <CuentasPage /> },
      { path: "usuarios/roles", element: <RolesPage /> },
      { path: "usuarios/roles/nuevo", element: <RolCreatePage /> },
      { path: "usuarios/roles/:id/editar", element: <RolEditPage /> },
      { path: "usuarios/bitacora", element: <BitacoraPage /> },
      { path: "mascotas", element: <MascotasPage /> },
      { path: "vehiculos", element: <VehiculosPage /> },
      { path: "visitantes", element: <VisitantesPage /> },
      { path: "residencias", element: <ResidenciasPage /> },
      { path: "areas/horarios", element: <HorariosPage /> },
      { path: "avisos", element: <AvisosPage /> },
      { path: "reservas", element: <ReservasPage /> },
      { path: "pagos", element: <PagosPage /> },
      { path: "facturas", element: <FacturasPage /> },
      { path: "conceptos-pago", element: <ConceptoPagoPage /> },
    ]
  },
  {
    path: "/residente",
    element: (
      <ProtectedRoute roles={['Residente']}>
        <ResidenteLayout />
      </ProtectedRoute>
    ),
    errorElement: <ErrorBoundaryPage />,
    children: [
      { index: true, element: <ResidenteDashboardHome /> },
      // Aquí se pueden agregar más rutas específicas para residentes
      // { path: "perfil", element: <ResidentePerfilPage /> },
      // { path: "vehiculos", element: <ResidenteVehiculosPage /> },
      // { path: "reservas", element: <ResidenteReservasPage /> },
      // etc.
    ]
  },
  {
    path: "/recuperar-password",
    element: <RecuperarPassword />
  },
  { path: "*", element: <ErrorBoundaryPage /> }
]);

export { router };
