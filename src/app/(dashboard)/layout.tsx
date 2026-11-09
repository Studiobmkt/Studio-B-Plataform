import { Sidebar } from "@/components/layout/sidebar";
import { Topbar } from "@/components/layout/topbar";
import { requireUser } from "@/lib/auth";

export const instant = false;

export default async function DashboardLayout({ children }: { children: React.ReactNode }) {
  const { supabase, user } = await requireUser();
  const { data: profile } = await supabase.from("profiles").select("full_name").eq("id", user.id).single();
  const { data: assignments } = await supabase.from("user_roles").select("roles(slug)").eq("user_id", user.id);
  const role = assignments?.find(Boolean)?.roles as unknown as { slug: string } | null;
  return <div className="app-shell"><Sidebar role={role?.slug}/><div className="app-main"><Topbar name={profile?.full_name} email={user.email ?? ""}/><main className="page-content">{children}</main></div></div>;
}
