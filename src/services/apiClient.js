import { getToken, clearAuth } from "./auth.js";

// Configuración simple y directa
const API_BASE = import.meta.env.VITE_API_BASE || "http://localhost:8000";


export async function apiFetch(url, options = {}) {
  const token = getToken();
  const headers = {
    'Content-Type': 'application/json',
    ...(options.headers || {})
  };
  if (token) headers['Authorization'] = `Bearer ${token}`;

  // En desarrollo local: usar proxy (/api)
  // En producción: usar URL completa
  const isDev = import.meta.env.DEV;
  const isLocal = window.location.hostname === 'localhost';
  
  let fullUrl;
  if (isDev && isLocal) {
    // Desarrollo local: usar rutas relativas (proxy se encarga)
    fullUrl = url;
  } else {
    // Producción: URL completa
    fullUrl = url.startsWith('http') ? url : `${API_BASE}${url}`;
  }
  
  console.log("🌐 Haciendo petición a:", fullUrl);
  console.log("📋 Headers:", headers);
  console.log("📦 Options:", options);

  const res = await fetch(fullUrl, { ...options, headers });
  console.log("📨 Respuesta status:", res.status);

  let data = null;
  try {
    const text = await res.text();
    data = text ? JSON.parse(text) : null;
    console.log("📄 Data recibida:", data);
  } catch (e) {
    console.error('❌ Error parsing JSON:', e);
  }

  if (res.status === 401) {
    clearAuth();
    if (!url.includes('/login')) window.location.href = '/login';
  }
  
  if (!res.ok) {
    const error = new Error(data?.detail || data?.error || `HTTP ${res.status}`);
    error.status = res.status;
    error.data = data;
    throw error;
  }
  
  return data;
}

export const api = {
  get: (u) => apiFetch(u),
  post: (u, b) => apiFetch(u, { method: 'POST', body: JSON.stringify(b) }),
  put: (u, b) => apiFetch(u, { method: 'PUT', body: JSON.stringify(b) }),
  patch: (u, b) => apiFetch(u, { method: 'PATCH', body: JSON.stringify(b) }),
  del: (u) => apiFetch(u, { method: 'DELETE' })
};