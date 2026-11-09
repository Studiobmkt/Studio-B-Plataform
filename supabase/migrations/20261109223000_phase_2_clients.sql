create table public.clients (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(trim(name)) >= 2),
  legal_name text,
  status text not null default 'active' check (status in ('lead','active','inactive')),
  contact_name text,
  contact_email text,
  contact_phone text,
  website text,
  notes text,
  created_by uuid not null references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.brands (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.clients(id) on delete cascade,
  name text not null check (char_length(trim(name)) >= 2),
  segment text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(client_id, name)
);

create index clients_status_name_idx on public.clients(status, name);
create index brands_client_id_idx on public.brands(client_id);
alter table public.clients enable row level security;
alter table public.brands enable row level security;
grant select, insert, update, delete on public.clients, public.brands to authenticated;
create policy clients_read on public.clients for select to authenticated using (true);
create policy clients_write on public.clients for insert to authenticated with check (created_by=(select auth.uid()) or (select private.is_admin()));
create policy clients_update on public.clients for update to authenticated using ((select private.is_admin())) with check ((select private.is_admin()));
create policy brands_read on public.brands for select to authenticated using (true);
create policy brands_write on public.brands for insert to authenticated with check ((select private.is_admin()));
create policy brands_update on public.brands for update to authenticated using ((select private.is_admin())) with check ((select private.is_admin()));
