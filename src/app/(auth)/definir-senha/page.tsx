"use client";

import Link from "next/link";
import { FormEvent, useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

export default function SetPasswordPage() {
  const router = useRouter();
  const [isReady, setIsReady] = useState(false);
  const [error, setError] = useState("");
  const [message, setMessage] = useState("");

  useEffect(() => {
    const supabase = createClient();
    supabase.auth.getSession().then(({ data, error: sessionError }) => {
      if (sessionError || !data.session) {
        setError("Este link é inválido ou expirou. Solicite um novo convite ou recupere sua senha.");
        return;
      }
      window.history.replaceState(null, "", window.location.pathname);
      setIsReady(true);
    });
  }, []);

  async function setPassword(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const form = new FormData(event.currentTarget);
    const password = String(form.get("password") || "");
    const confirmation = String(form.get("confirmation") || "");
    if (password.length < 8) return setError("A senha precisa ter pelo menos 8 caracteres.");
    if (password !== confirmation) return setError("As senhas não conferem.");

    setError("");
    const { error: updateError } = await createClient().auth.updateUser({ password });
    if (updateError) return setError("Não foi possível salvar a senha. Abra um novo link de acesso.");
    setMessage("Senha criada com sucesso. Redirecionando para o painel...");
    window.setTimeout(() => router.replace("/dashboard"), 900);
  }

  return <main className="auth-shell"><section className="auth-brand"><p className="eyebrow">STUDIO B MARKETING</p><h1>Seu acesso começa aqui.</h1><p>Defina uma senha segura para entrar no painel.</p></section><section className="auth-card"><div className="brand-mark">B</div><h2>Definir senha</h2><p className="muted">Crie sua senha para concluir o acesso.</p>{error && <p className="form-error">{error}</p>}{message && <p className="form-success">{message}</p>}{isReady && <form onSubmit={setPassword} className="form-stack"><label>Nova senha<input name="password" type="password" minLength={8} required autoComplete="new-password" /></label><label>Confirmar senha<input name="confirmation" type="password" minLength={8} required autoComplete="new-password" /></label><button className="button button-primary">Concluir acesso</button></form>}<Link className="text-link" href="/login">Voltar ao login</Link></section></main>;
}
