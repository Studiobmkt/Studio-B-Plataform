"use server";
import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";

export async function inviteMember(formData: FormData) {
  await requireAdmin();
  const email = String(formData.get("email") || "").trim().toLowerCase();
  const fullName = String(formData.get("full_name") || "").trim();
  const role = String(formData.get("role") || "colaborador");
  if (!email || !["admin", "gestor", "colaborador"].includes(role)) return;
  const admin = createAdminClient();
  const { data, error } = await admin.auth.admin.inviteUserByEmail(email, {
    data: { full_name: fullName },
    redirectTo: `${process.env.NEXT_PUBLIC_SITE_URL ?? "http://localhost:3000"}/definir-senha`,
  });
  if (error || !data.user) throw new Error(error?.message || "Não foi possível enviar o convite.");
  const { data: roleData } = await admin.from("roles").select("id").eq("slug", role).single();
  if (roleData) await admin.from("user_roles").upsert({ user_id: data.user.id, role_id: roleData.id }, { onConflict: "user_id,role_id" });
  await admin.from("activity_logs").insert({ actor_id: (await requireAdmin()).user.id, action: "team_member_invited", entity_type: "profile", entity_id: data.user.id, metadata: { email, role } });
  revalidatePath("/admin/equipe");
}
