import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

export async function requireUser() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  return { supabase, user };
}

export async function requireAdmin() {
  const { supabase, user } = await requireUser();
  const { data: roles } = await supabase
    .from("user_roles")
    .select("roles(slug)")
    .eq("user_id", user.id);
  const isAdmin = roles?.some((row) => {
    const role = row.roles as unknown as { slug: string } | null;
    return role?.slug === "admin";
  });
  if (!isAdmin) redirect("/dashboard");
  return { supabase, user };
}
