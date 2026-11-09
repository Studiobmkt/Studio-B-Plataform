"use server";
import { revalidatePath } from "next/cache";
import { requireUser } from "@/lib/auth";

export async function createClient(formData: FormData) {
  const { supabase, user } = await requireUser();
  const name = String(formData.get("name") || "").trim();
  if (name.length < 2) return;
  await supabase.from("clients").insert({ name, legal_name: String(formData.get("legal_name") || "").trim() || null, contact_name: String(formData.get("contact_name") || "").trim() || null, contact_email: String(formData.get("contact_email") || "").trim() || null, contact_phone: String(formData.get("contact_phone") || "").trim() || null, website: String(formData.get("website") || "").trim() || null, status: String(formData.get("status") || "lead"), created_by: user.id });
  revalidatePath("/clientes");
}

export async function saveContract(formData: FormData) {
  const { supabase, user } = await requireUser();
  const client_id = String(formData.get("client_id") || "");
  if (!client_id) return;
  const status = String(formData.get("contract_status") || "draft");
  await supabase.from("client_contracts").upsert({
    client_id, service_type: String(formData.get("service_type") || "").trim() || null,
    service_title: String(formData.get("service_title") || "").trim() || null,
    monthly_value: Number(formData.get("monthly_value") || 0) || null,
    due_day: Number(formData.get("due_day") || 0) || null,
    payment_method: String(formData.get("payment_method") || "").trim() || null,
    periodicity: String(formData.get("periodicity") || "Mensal"), contract_status: status,
    financial_status: String(formData.get("financial_status") || "Em dia"),
    starts_at: String(formData.get("starts_at") || "") || null, ends_at: String(formData.get("ends_at") || "") || null,
    financial_contact: String(formData.get("financial_contact") || "").trim() || null,
    financial_email: String(formData.get("financial_email") || "").trim() || null,
    deliverables: String(formData.get("deliverables") || "").trim() || null,
    payment_terms: String(formData.get("payment_terms") || "").trim() || null,
    cancellation_terms: String(formData.get("cancellation_terms") || "").trim() || null,
    venue_city: String(formData.get("venue_city") || "").trim() || null, created_by: user.id
  }, { onConflict: "client_id" });
  if (status === "active") await supabase.from("clients").update({ status: "active" }).eq("id", client_id);
  revalidatePath("/clientes"); revalidatePath(`/clientes/${client_id}`); revalidatePath("/onboarding");
}
