# Atlas de Políticas Municipales

App para explorar políticas públicas municipales de todo el mundo, ordenadas por
temática, con mapa interactivo y un nivel de evidencia honesto para cada resultado
citado.

Tiene un backend real (no guarda nada solo en el navegador): cualquier visitante
puede ver y filtrar las políticas, pero solo las cuentas que vos apruebes pueden
agregar o borrar. Usa [Supabase](https://supabase.com) — una base de datos
Postgres con login incluido, con un plan gratuito que alcanza de sobra para esto.

## Requisitos

- [Node.js](https://nodejs.org/) versión 18 o superior (incluye `npm`).
- Una cuenta de [GitHub](https://github.com/).
- Una cuenta gratuita de [Supabase](https://supabase.com).

## 1. Crear el backend en Supabase

1. Entrá a [supabase.com](https://supabase.com) → **New project**. Elegí
   cualquier nombre y una contraseña de base de datos (guardala, no la vas a
   necesitar para esta app, pero por las dudas).
2. Cuando el proyecto esté listo, andá a **SQL Editor** (ícono de la izquierda)
   → **New query**.
3. Copiá y pegá **todo** el contenido de `supabase_schema.sql` (está en esta
   carpeta) y tocá **Run**. Esto crea las tablas `policies` y `admins`, y las
   reglas de quién puede leer/escribir cada una.
4. Repetí el paso con `supabase_seed.sql` (primera tanda, 50 políticas) y
   después con `supabase_seed_batch2.sql` (segunda tanda, 50 políticas más,
   con foco en países emergentes): una query nueva por archivo, pegar,
   **Run**. **Ejecutá cada uno una sola vez** — si corrés el mismo archivo
   dos veces vas a duplicar todo.
5. Andá a **Project Settings → API**. Vas a necesitar dos datos de ahí en el
   paso 3: **Project URL** y la clave **anon public**.

## 2. Crear tu usuario administrador

1. Andá a **Authentication → Users → Add user → Create new user**. Cargá tu
   email y una contraseña. Dejá tildado "Auto Confirm User" si te lo ofrece
   (así no depende de que llegue un mail de confirmación).
2. Copiá el **UID** (identificador) de ese usuario que te queda listado.
3. Volvé al **SQL Editor**, abrí una query nueva y ejecutá (reemplazando por
   el UID que copiaste):
   ```sql
   insert into public.admins (user_id) values ('PEGÁ-ACÁ-EL-UID');
   ```
4. Repetí este paso (Add user + insert en `admins`) por cada persona del
   equipo a la que quieras darle permiso de agregar o borrar políticas.
   Para sacarle el permiso a alguien más adelante, simplemente borrá su fila
   de la tabla `admins` (podés hacerlo a mano desde **Table Editor**).

## 3. Configurar el proyecto en tu computadora

```bash
npm install
cp .env.example .env
```

Abrí el `.env` que se creó y completá con los dos datos del paso 1.5:

```
VITE_SUPABASE_URL=https://tu-proyecto.supabase.co
VITE_SUPABASE_ANON_KEY=tu-clave-anon-publica
```

> La clave "anon" está pensada para ser pública — no es un secreto. La
> seguridad real la da la Seguridad a Nivel de Fila (RLS) que ya quedó
> configurada en el paso 1.3: sin estar en la tabla `admins`, nadie puede
> escribir nada aunque tenga esta clave.

Después, probalo en tu computadora:

```bash
npm run dev
```

Abrí la URL que te muestra la terminal (normalmente `http://localhost:5173`),
tocá "Iniciar sesión" arriba a la derecha y entrá con el email/contraseña que
creaste en el paso 2.

## 4. Subir el proyecto a GitHub

```bash
git init
git add .
git commit -m "Primera versión del Atlas de Políticas Municipales"
```

Creá un repositorio nuevo y vacío en GitHub (sin README, sin licencia) y
seguí las instrucciones que te muestra bajo "…or push an existing repository
from the command line":

```bash
git remote add origin https://github.com/TU-USUARIO/NOMBRE-DEL-REPO.git
git branch -M main
git push -u origin main
```

El archivo `.env` con tus claves **no se sube** (está en `.gitignore`), así
que el paso siguiente es configurar esas mismas dos variables en el servicio
donde publiques el sitio.

## 5. Publicar el sitio

### Opción recomendada — Vercel o Netlify

1. Creá una cuenta gratuita en [vercel.com](https://vercel.com) o
   [netlify.com](https://netlify.com) e iniciá sesión con GitHub.
2. Importá el repositorio que acabás de subir.
3. Build command: `npm run build` — Output directory: `dist` (ambos lo
   detectan solos).
4. Antes de desplegar (o justo después, en Settings → Environment Variables),
   agregá las mismas dos variables del `.env`:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
5. Desplegar. Te dan una URL pública al toque, y cada `git push` la actualiza
   sola.

### Alternativa — GitHub Pages

1. `npm install --save-dev gh-pages`
2. En `package.json`, agregá `"homepage": "https://TU-USUARIO.github.io/NOMBRE-DEL-REPO"`
   y, dentro de `"scripts"`, `"deploy": "vite build && gh-pages -d dist"`.
3. GitHub Pages no tiene una pantalla para cargar variables de entorno en el
   build de la misma forma que Vercel/Netlify, así que para esta opción hay
   que crear el archivo `.env` en tu computadora antes de correr
   `npm run deploy` (Vite lo toma en el momento de compilar). Esto significa
   que tenés que tener el `.env` completo localmente antes de publicar.
4. `npm run deploy`, y después en GitHub Settings → Pages confirmá que la
   fuente sea la rama `gh-pages`.

## Cómo administrar el contenido después de publicado

- **Agregar una política**: iniciá sesión con una cuenta admin y usá el botón
  "Agregar política".
- **Borrar una política**: con sesión admin iniciada, aparece un enlace
  "eliminar" en cada tarjeta.
- **Dar o quitar permisos de administrador**: se hace desde el
  **Table Editor** de Supabase, agregando o quitando filas en la tabla
  `admins` (ver paso 2).
- **Ver todo el contenido en una tabla**: **Table Editor → policies**, dentro
  de Supabase.

## Estructura del proyecto

```
atlas-politicas-municipales/
├── index.html            # página raíz
├── package.json           # dependencias y scripts
├── vite.config.js         # configuración del empaquetador (Vite)
├── supabase_schema.sql    # tablas + seguridad a nivel de fila (correr 1 vez)
├── supabase_seed.sql      # primera tanda: 50 políticas (correr 1 vez)
├── supabase_seed_batch2.sql # segunda tanda: 50 políticas más (correr 1 vez)
├── .env.example           # plantilla de variables de entorno
└── src/
    ├── main.jsx            # arranca React
    ├── supabaseClient.js   # conexión a Supabase
    └── App.jsx             # toda la app: mapa, filtros, formulario, login
```
