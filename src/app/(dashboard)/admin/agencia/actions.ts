"use server";
import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/auth";
export async function saveAgency(formData: FormData) { const { supabase } = await requireAdmin(); await supabase.from("agency_settings").upsert({ id: 1, name: String(formData.get("name") || "Studio B Marketing"), email: String(formData.get("email") || "").trim() || null, phone: String(formData.get("phone") || "").trim() || null, primary_color: String(formData.get("primary_color") || "#D4AF37") }); revalidatePath("/admin/agencia"); }
