import React, { useEffect, useState } from "react";
import { Link, Outlet, useLocation } from "react-router-dom";
import { clearAuth, getUser } from "../services/auth.js";

const menuResidente = [
	{
		grupo: "Mi Información",
		icono: "👤",
		opciones: [
			{ nombre: "Mi Perfil", ruta: "/residente/perfil" },
			{ nombre: "Mi Residencia", ruta: "/residente/residencia" },
		],
	},
	{
		grupo: "Mis Propiedades",
		icono: "🏠",
		opciones: [
			{ nombre: "Mis Vehículos", ruta: "/residente/vehiculos" },
			{ nombre: "Mis Mascotas", ruta: "/residente/mascotas" },
			{ nombre: "Mis Visitantes", ruta: "/residente/visitantes" },
		],
	},
	{
		grupo: "Servicios",
		icono: "🛠️",
		opciones: [
			{ nombre: "Reservas", ruta: "/residente/reservas" },
			{ nombre: "Áreas Comunes", ruta: "/residente/areas" },
		],
	},
	{
		grupo: "Finanzas",
		icono: "💳",
		opciones: [
			{ nombre: "Mis Facturas", ruta: "/residente/facturas" },
			{ nombre: "Mis Pagos", ruta: "/residente/pagos" },
		],
	},
	{
		grupo: "Comunicación",
		icono: "📢",
		opciones: [
			{ nombre: "Avisos", ruta: "/residente/avisos" },
		],
	},
];

export default function ResidenteLayout() {
	const [sidebarOpen, setSidebarOpen] = useState(false);
	const [userInfo, setUserInfo] = useState(null);
	const location = useLocation();

	useEffect(() => {
		const user = getUser();
		setUserInfo(user);
	}, []);

	const handleLogout = () => {
		clearAuth();
		window.location.href = "/login";
	};

	return (
		<div className="min-h-screen bg-gray-50 flex">
			{/* Sidebar */}
			<div
				className={`fixed inset-y-0 left-0 z-50 w-80 bg-white shadow-xl transform transition-transform duration-300 ease-in-out ${
					sidebarOpen ? "translate-x-0" : "-translate-x-full"
				} lg:translate-x-0 lg:static lg:inset-0`}
			>
				<div className="flex items-center justify-between h-16 px-6 bg-blue-600 text-white">
					<h1 className="text-lg font-bold">Portal Residente</h1>
					<button
						onClick={() => setSidebarOpen(false)}
						className="lg:hidden"
					>
						<svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
						</svg>
					</button>
				</div>

				<nav className="flex-1 px-4 py-6 overflow-y-auto">
					{menuResidente.map((grupo, idx) => (
						<div key={idx} className="mb-8">
							<h3 className="flex items-center mb-3 text-sm font-semibold text-gray-500 uppercase tracking-wider">
								<span className="mr-2">{grupo.icono}</span>
								{grupo.grupo}
							</h3>
							<ul className="space-y-1">
								{grupo.opciones.map((opcion, opcionIdx) => (
									<li key={opcionIdx}>
										<Link
											to={opcion.ruta}
											className={`flex items-center px-4 py-2 text-sm font-medium rounded-lg transition-colors ${
												location.pathname === opcion.ruta
													? "bg-blue-100 text-blue-700 border-r-2 border-blue-700"
													: "text-gray-700 hover:bg-gray-100"
											}`}
										>
											{opcion.nombre}
										</Link>
									</li>
								))}
							</ul>
						</div>
					))}
				</nav>

				{/* User info y logout */}
				<div className="border-t border-gray-200 p-4">
					<div className="flex items-center mb-3">
						<div className="w-8 h-8 bg-blue-600 rounded-full flex items-center justify-center text-white text-sm font-bold">
							{userInfo?.nombre?.charAt(0) || "U"}
						</div>
						<div className="ml-3">
							<p className="text-sm font-medium text-gray-700">
								{userInfo?.nombre} {userInfo?.apellido}
							</p>
							<p className="text-xs text-gray-500">{userInfo?.rol}</p>
						</div>
					</div>
					<button
						onClick={handleLogout}
						className="w-full flex items-center px-4 py-2 text-sm text-red-600 hover:bg-red-50 rounded-lg transition-colors"
					>
						<svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
						</svg>
						Cerrar Sesión
					</button>
				</div>
			</div>

			{/* Overlay para móvil */}
			{sidebarOpen && (
				<div
					className="fixed inset-0 z-40 bg-black bg-opacity-50 lg:hidden"
					onClick={() => setSidebarOpen(false)}
				></div>
			)}

			{/* Contenido principal */}
			<div className="flex-1 lg:ml-0">
				{/* Header */}
				<header className="bg-white shadow-sm border-b border-gray-200">
					<div className="flex items-center justify-between h-16 px-6">
						<div className="flex items-center">
							<button
								onClick={() => setSidebarOpen(true)}
								className="lg:hidden mr-3"
							>
								<svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
									<path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
								</svg>
							</button>
							<h1 className="text-xl font-semibold text-gray-800">
								Dashboard Residente
							</h1>
						</div>
						<div className="flex items-center space-x-4">
							<span className="text-sm text-gray-600">
								Bienvenido, {userInfo?.nombre}
							</span>
						</div>
					</div>
				</header>

				{/* Contenido */}
				<main className="flex-1 p-6">
					<Outlet />
				</main>
			</div>
		</div>
	);
}