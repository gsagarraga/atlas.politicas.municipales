import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// base: "./" hace que los archivos generados usen rutas relativas,
// así el sitio funciona tanto en la raíz de un dominio (Vercel, Netlify)
// como en una subcarpeta de GitHub Pages (usuario.github.io/nombre-repo/).
export default defineConfig({
  plugins: [react()],
  base: "./",
});
