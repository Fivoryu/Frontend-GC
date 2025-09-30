/* eslint-disable no-undef */
import { defineConfig, loadEnv } from "vite";
import react from "@vitejs/plugin-react-swc";
import tailwindcss from "@tailwindcss/vite";

// https://vite.dev/config/
export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '');
  const backendUrl = env.VITE_API_BASE || "http://localhost:8000";
  return {
    plugins: [react(), tailwindcss()],
    build: {
      // Optimización para AWS S3 + CloudFront
      rollupOptions: {
        output: {
          // Separar dependencias grandes en chunks separados
          manualChunks: {
            vendor: ['react', 'react-dom'],
            router: ['react-router-dom']
          },
          // Nombres de archivo con hash para cache busting
          assetFileNames: 'assets/[name].[hash].[ext]',
          chunkFileNames: 'assets/[name].[hash].js',
          entryFileNames: 'assets/[name].[hash].js'
        }
      },
      // Optimización de tamaño
      minify: 'esbuild',
      target: 'es2015',
      // Generar sourcemaps para debug en producción (opcional)
      sourcemap: false
    },
    server: {
      port: 5173,
      host: true,
      proxy: {
        "/api": {
          target: backendUrl,
          changeOrigin: true,
          secure: false,
        },
      },
    },
    // Configuración para preview
    preview: {
      port: 4173,
      host: true
    }
  };
});
