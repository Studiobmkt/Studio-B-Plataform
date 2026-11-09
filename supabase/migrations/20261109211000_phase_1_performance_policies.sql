drop policy agency_admin on public.agency_settings;
create policy agency_admin_insert on public.agency_settings for insert to authenticated with check ((select private.is_admin()));
create policy agency_admin_update on public.agency_settings for update to authenticated using ((select private.is_admin())) with check ((select private.is_admin()));
create policy agency_admin_delete on public.agency_settings for delete to authenticated using ((select private.is_admin()));

drop policy profile_self_update on public.profiles;
drop policy profile_admin_update on public.profiles;
create policy profile_update_self_or_admin on public.profiles for update to authenticated using (id=(select auth.uid()) or (select private.is_admin())) with check (id=(select auth.uid()) or (select private.is_admin()));

create index activity_logs_actor_id_idx on public.activity_logs(actor_id);
create index agency_settings_updated_by_idx on public.agency_settings(updated_by);
create index attachments_owner_id_idx on public.attachments(owner_id);
create index role_permissions_permission_id_idx on public.role_permissions(permission_id);
create index user_roles_assigned_by_idx on public.user_roles(assigned_by);
create index user_roles_role_id_idx on public.user_roles(role_id);
