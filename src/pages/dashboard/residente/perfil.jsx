import React, { useEffect, useState } from "react";
import { api } from "../../../services/apiClient.js";
import { getUser } from "../../../services/auth.js";

export default function ResidentePerfil() {
  const [loading, setLoading] = useState(true);
  const [residente, setResidente] = useState(null);
  const [userInfo, setUserInfo] = useState(null);

  useEffect(() => {
    const user = getUser();
    setUserInfo(user);
    cargarPerfil();
  }, []);

  const cargarPerfil = async () => {
    try {
      setLoading(true);
      const response = await api.get("/api/cuenta/perfil/");
      setResidente(response);
    } catch (error) {
      console.error("Error cargando perfil:", error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <h2 className="text-2xl font-bold text-gray-900 mb-6">Mi Perfil</h2>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Información Personal</h3>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Nombre</label>
                <p className="text-gray-900">{userInfo?.nombre || 'No especificado'}</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Apellido</label>
                <p className="text-gray-900">{userInfo?.apellido || 'No especificado'}</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Correo Electrónico</label>
                <p className="text-gray-900">{userInfo?.correo}</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Rol</label>
                <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                  {userInfo?.rol}
                </span>
              </div>
            </div>
          </div>

          <div>
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Información de Residencia</h3>
            <div className="space-y-4">
              {residente?.residente_info ? (
                <>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Residencia</label>
                    <p className="text-gray-900">
                      Residencia #{residente.residente_info.residencia}
                    </p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Nombre Completo</label>
                    <p className="text-gray-900">
                      {residente.residente_info.nombre} {residente.residente_info.apellidos}
                    </p>
                  </div>
                </>
              ) : (
                <p className="text-gray-500">No hay información de residencia asociada</p>
              )}
            </div>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Acciones</h3>
        <div className="flex space-x-4">
          <button className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
            Actualizar Información
          </button>
          <button className="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors">
            Cambiar Contraseña
          </button>
        </div>
      </div>
    </div>
  );
}