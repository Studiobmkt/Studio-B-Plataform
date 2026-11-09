"use server";
import { revalidatePath } from "next/cache";
import { requireUser } from "@/lib/auth";

export async function createClient(formData: FormData) {
  const { supabase, user } = await requireUser();
  const name = String(formData.get("name") || "").trim();
  if (name.length < 2) return;
  await supabase.from("clients").insert({ name, contact_name: String(formData.get("contact_name") || "").trim() || null, contact_email: String(formData.get("contact_email") || "").trim() || null, status: String(formData.get("status") || "lead"), created_by: user.id });
  revalidatePath("/clientes");
}
