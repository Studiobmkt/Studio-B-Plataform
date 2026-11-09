create table public.client_onboardings (
  id uuid primary key default gen_random_uuid(), client_id uuid not null unique references public.clients(id) on delete cascade,
  status text not null default 'in_progress' check (status in ('in_progress','blocked','waiting_client','ready')),
  responsible_name text, niche text, company_type text, services text[] not null default '{}',
  briefing jsonb not null default '{}', access_details jsonb not null default '{}', structure_details jsonb not null default '{}', planning_details jsonb not null default '{}',
  contract_value numeric(12,2), contract_start date, contract_end date, monthly_budget numeric(12,2), daily_budget numeric(12,2),
  created_by uuid not null references public.profiles(id), created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.onboarding_tasks (
  id uuid primary key default gen_random_uuid(), onboarding_id uuid not null references public.client_onboardings(id) on delete cascade,
  stage smallint not null check (stage between 1 and 4), title text not null, completed_at timestamptz, completed_by uuid references public.profiles(id), notes text, position smallint not null default 0
);
create index onboarding_tasks_stage_idx on public.onboarding_tasks(onboarding_id, stage, position);
alter table public.client_onboardings enable row level security; alter table public.onboarding_tasks enable row level security;
grant select, insert, update, delete on public.client_onboardings, public.onboarding_tasks to authenticated;
create policy onboarding_read on public.client_onboardings for select to authenticated using (true);
create policy onboarding_write on public.client_onboardings for all to authenticated using ((select private.is_admin())) with check ((select private.is_admin()));
create policy onboarding_tasks_read on public.onboarding_tasks for select to authenticated using (true);
create policy onboarding_tasks_write on public.onboarding_tasks for all to authenticated using ((select private.is_admin())) with check ((select private.is_admin()));
