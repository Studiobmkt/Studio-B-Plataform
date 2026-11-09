create table public.client_contracts (
  id uuid primary key default gen_random_uuid(), client_id uuid not null unique references public.clients(id) on delete cascade,
  service_type text, service_title text, monthly_value numeric(12,2), due_day smallint check (due_day between 1 and 31), payment_method text, periodicity text not null default 'Mensal',
  contract_status text not null default 'draft' check (contract_status in ('draft','awaiting_signature','active','ended','cancelled')),
  financial_status text not null default 'Em dia', starts_at date, ends_at date, financial_contact text, financial_email text,
  deliverables text, payment_terms text, cancellation_terms text, venue_city text, created_by uuid not null references public.profiles(id), created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create index client_contracts_status_end_idx on public.client_contracts(contract_status, ends_at);
alter table public.client_contracts enable row level security;
grant select, insert, update, delete on public.client_contracts to authenticated;
create policy client_contracts_read on public.client_contracts for select to authenticated using (true);
create policy client_contracts_write on public.client_contracts for insert to authenticated with check ((select private.is_admin()));
create policy client_contracts_update on public.client_contracts for update to authenticated using ((select private.is_admin())) with check ((select private.is_admin()));
