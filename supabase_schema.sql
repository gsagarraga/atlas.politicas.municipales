-- Esquema del Atlas de Políticas Municipales.
-- Copiá y pegá todo este archivo en el SQL Editor de tu proyecto de Supabase
-- (Supabase → SQL Editor → New query → pegar → Run). Se ejecuta una sola vez.

-- Tabla principal: cada fila es una política pública.
create table if not exists public.policies (
  id text primary key,
  titulo text not null,
  ciudad text not null,
  pais text,
  categoria text not null,
  anio text,
  resumen text,
  resultados text,
  fuente_nombre text,
  fuente_url text,
  evidencia_nivel text,
  evidencia_nota text,
  created_at timestamptz not null default now()
);

-- Tabla de administradores: qué usuarios (por su id de Supabase Auth)
-- pueden agregar, editar o borrar políticas.
create table if not exists public.admins (
  user_id uuid primary key references auth.users (id) on delete cascade,
  created_at timestamptz not null default now()
);

-- Activamos seguridad a nivel de fila en ambas tablas. A partir de acá,
-- nadie puede leer ni escribir nada salvo lo que permitan las políticas
-- de abajo (por eso el orden importa: primero se activa, después se
-- define qué se permite).
alter table public.policies enable row level security;
alter table public.admins enable row level security;

-- Cualquier persona (incluso sin haber iniciado sesión) puede LEER
-- las políticas públicas. Es lo que necesita el sitio para mostrarse.
create policy "cualquiera_puede_leer_politicas"
  on public.policies
  for select
  using (true);

-- Solo alguien logueado que además figure en la tabla admins puede
-- insertar una política nueva.
create policy "solo_admins_insertan_politicas"
  on public.policies
  for insert
  to authenticated
  with check (
    exists (select 1 from public.admins where admins.user_id = auth.uid())
  );

-- Solo un admin puede editar una política existente.
create policy "solo_admins_actualizan_politicas"
  on public.policies
  for update
  to authenticated
  using (
    exists (select 1 from public.admins where admins.user_id = auth.uid())
  )
  with check (
    exists (select 1 from public.admins where admins.user_id = auth.uid())
  );

-- Solo un admin puede borrar una política.
create policy "solo_admins_borran_politicas"
  on public.policies
  for delete
  to authenticated
  using (
    exists (select 1 from public.admins where admins.user_id = auth.uid())
  );

-- Un usuario logueado puede consultar ÚNICAMENTE si su propio id
-- está en la tabla admins (para que la app sepa si mostrarle el botón
-- "Agregar política"). No puede ver la lista completa de admins.
create policy "un_usuario_ve_si_el_mismo_es_admin"
  on public.admins
  for select
  to authenticated
  using (user_id = auth.uid());
