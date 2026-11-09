"use server";
import { revalidatePath } from "next/cache";
import { requireUser } from "@/lib/auth";

export async function updateProfile(formData: FormData) { const { supabase, user } = await requireUser(); await supabase.from("profiles").update({ full_name: String(formData.get("full_name") || "").trim(), phone: String(formData.get("phone") || "").trim() || null }).eq("id", user.id); revalidatePath("/configuracoes"); }
export async function changePassword(formData: FormData) { const { supabase } = await requireUser(); const password = String(formData.get("password") || ""); if (password.length < 8) return; await supabase.auth.updateUser({ password }); }
