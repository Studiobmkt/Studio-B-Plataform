"use client";
import { LogOut } from "lucide-react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

export function SignOutButton() { const router = useRouter(); return <button className="sign-out" onClick={async () => { await createClient().auth.signOut(); router.push("/login"); router.refresh(); }}><LogOut size={17}/>Sair</button>; }
