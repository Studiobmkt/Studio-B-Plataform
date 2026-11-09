-- Studio B Marketing App 2.0: isolated Phase 1 foundation
create schema if not exists private;

create table public.roles (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique check (slug in ('admin','gestor','colaborador')),
  name text not null,
  description text,
  created_at timestamptz not null default now()
);
create table public.permissions (
  id uuid primary key default gen_random_uuid(),
  resource text not null,
  action text not null check (action in ('create','read','update','delete','manage')),
  description text,
  unique(resource, action)
);
create table public.role_permissions (
  role_id uuid not null references public.roles(id) on delete cascade,
  permission_id uuid not null references public.permissions(id) on delete cascade,
  primary key(role_id, permission_id)
);
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  full_name text,
  phone text,
  avatar_path text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table public.user_roles (
  user_id uuid not null references public.profiles(id) on delete cascade,
  role_id uuid not null references public.roles(id) on delete restrict,
  assigned_at timestamptz not null default now(),
  assigned_by uuid references public.profiles(id) on delete set null,
  primary key(user_id, role_id)
);
create table public.agency_settings (
  id smallint primary key default 1 check (id = 1),
  name text not null default 'Studio B Marketing',
  logo_path text,
  email text,
  phone text,
  website text,
  primary_color text not null default '#D4AF37',
  secondary_color text not null default '#171510',
  updated_at timestamptz not null default now(),
  updated_by uuid references public.profiles(id) on delete set null
);
create table public.activity_logs (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references public.profiles(id) on delete set null,
  action text not null,
  entity_type text not null,
  entity_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  body text,
  read_at timestamptz,
  created_at timestamptz not null default now()
);
create table public.attachments (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete restrict,
  storage_path text not null unique,
  file_name text not null,
  mime_type text,
  size_bytes bigint check (size_bytes >= 0),
  created_at timestamptz not null default now()
);
create index profiles_email_idx on public.profiles(email);
create index user_roles_user_id_idx on public.user_roles(user_id);
create index notifications_user_unread_idx on public.notifications(user_id, read_at) where read_at is null;
create index activity_logs_created_at_idx on public.activity_logs(created_at desc);
create index attachments_owner_id_idx on public.attachments(owner_id);

insert into public.roles(slug,name,description) values
  ('admin','Administrador','Controle total da plataforma'),
  ('gestor','Gestor','Gerencia operações; financeiro depende de permissão'),
  ('colaborador','Colaborador','Acesso a atividades atribuídas')
on conflict (slug) do nothing;
insert into public.permissions(resource,action,description) values
  ('dashboard','read','Visualizar painel'),('team','manage','Gerenciar equipe'),
  ('agency','manage','Gerenciar agência'),('finance','read','Visualizar financeiro'),
  ('contracts','read','Visualizar contratos'),('projects','manage','Gerenciar projetos')
on conflict (resource,action) do nothing;
insert into public.role_permissions(role_id,permission_id)
select r.id,p.id from public.roles r cross join public.permissions p where r.slug='admin'
on conflict do nothing;
insert into public.role_permissions(role_id,permission_id)
select r.id,p.id from public.roles r join public.permissions p on p.resource in ('dashboard','projects') where r.slug='gestor'
on conflict do nothing;
insert into public.role_permissions(role_id,permission_id)
select r.id,p.id from public.roles r join public.permissions p on p.resource='dashboard' and p.action='read' where r.slug='colaborador'
on conflict do nothing;

create or replace function private.is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select exists(select 1 from public.user_roles ur join public.roles r on r.id=ur.role_id where ur.user_id=(select auth.uid()) and r.slug='admin')
$$;
create or replace function private.has_permission(target_resource text, target_action text)
returns boolean language sql stable security definer set search_path = public as $$
  select exists(select 1 from public.user_roles ur join public.role_permissions rp on rp.role_id=ur.role_id join public.permissions p on p.id=rp.permission_id where ur.user_id=(select auth.uid()) and p.resource=target_resource and (p.action=target_action or p.action='manage'))
$$;
revoke all on function private.is_admin() from public;
revoke all on function private.has_permission(text,text) from public;
grant usage on schema private to authenticated;
grant execute on function private.is_admin() to authenticated;
grant execute on function private.has_permission(text,text) to authenticated;

create or replace function private.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
declare collaborator_role uuid;
begin
  insert into public.profiles(id,email,full_name) values(new.id,new.email,coalesce(new.raw_user_meta_data->>'full_name','')) on conflict(id) do update set email=excluded.email;
  select id into collaborator_role from public.roles where slug='colaborador';
  insert into public.user_roles(user_id,role_id) values(new.id,collaborator_role) on conflict do nothing;
  return new;
end $$;
revoke all on function private.handle_new_user() from public;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure private.handle_new_user();

create or replace function private.touch_updated_at()
returns trigger language plpgsql security invoker set search_path = public as $$ begin new.updated_at=now(); return new; end $$;
create trigger profiles_touch_updated_at before update on public.profiles for each row execute procedure private.touch_updated_at();
create trigger agency_touch_updated_at before update on public.agency_settings for each row execute procedure private.touch_updated_at();

alter table public.roles enable row level security;
alter table public.permissions enable row level security;
alter table public.role_permissions enable row level security;
alter table public.profiles enable row level security;
alter table public.user_roles enable row level security;
alter table public.agency_settings enable row level security;
alter table public.activity_logs enable row level security;
alter table public.notifications enable row level security;
alter table public.attachments enable row level security;

create policy roles_read on public.roles for select to authenticated using (true);
create policy permissions_read on public.permissions for select to authenticated using (true);
create policy role_permissions_read on public.role_permissions for select to authenticated using (true);
create policy profiles_read on public.profiles for select to authenticated using (true);
create policy profiles_update_self on public.profiles for update to authenticated using (id=(select auth.uid())) with check (id=(select auth.uid()) and email=(select email from public.profiles where id=(select auth.uid())));
create policy profiles_admin_update on public.profiles for update to authenticated using ((select private.is_admin())) with check ((select private.is_admin()));
create policy user_roles_read_self_or_admin on public.user_roles for select to authenticated using (user_id=(select auth.uid()) or (select private.is_admin()));
create policy agency_read on public.agency_settings for select to authenticated using (true);
create policy agency_admin_write on public.agency_settings for all to authenticated using ((select private.is_admin())) with check ((select private.is_admin()));
create policy logs_admin_read on public.activity_logs for select to authenticated using ((select private.is_admin()));
create policy notifications_own on public.notifications for select to authenticated using (user_id=(select auth.uid()));
create policy notifications_update_own on public.notifications for update to authenticated using (user_id=(select auth.uid())) with check (user_id=(select auth.uid()));
create policy attachments_owner_or_admin_read on public.attachments for select to authenticated using (owner_id=(select auth.uid()) or (select private.is_admin()));
create policy attachments_owner_insert on public.attachments for insert to authenticated with check (owner_id=(select auth.uid()));
create policy attachments_owner_update on public.attachments for update to authenticated using (owner_id=(select auth.uid())) with check (owner_id=(select auth.uid()));

grant select on public.roles,public.permissions,public.role_permissions,public.profiles,public.user_roles,public.agency_settings,public.notifications,public.attachments to authenticated;
grant update(full_name,phone,avatar_path) on public.profiles to authenticated;
grant insert,update,delete on public.agency_settings to authenticated;
grant insert,update on public.notifications to authenticated;
grant insert,update on public.attachments to authenticated;

insert into storage.buckets(id,name,public) values('attachments','attachments',false) on conflict(id) do nothing;
create policy attachment_storage_read on storage.objects for select to authenticated using (bucket_id='attachments' and (owner_id=(select auth.uid())::text or (select private.is_admin())));
create policy attachment_storage_insert on storage.objects for insert to authenticated with check (bucket_id='attachments' and owner_id=(select auth.uid())::text);
create policy attachment_storage_update on storage.objects for update to authenticated using (bucket_id='attachments' and owner_id=(select auth.uid())::text) with check (bucket_id='attachments' and owner_id=(select auth.uid())::text);
create policy attachment_storage_delete on storage.objects for delete to authenticated using (bucket_id='attachments' and owner_id=(select auth.uid())::text);

insert into public.agency_settings(id,name) values(1,'Studio B Marketing') on conflict(id) do nothing;
