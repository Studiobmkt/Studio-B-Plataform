import Link from "next/link";
import { requestPasswordReset } from "../login/actions";

export const instant = false;

export default function ResetRequestPage() {
  return <main className="auth-shell"><section className="auth-brand"><p className="eyebrow">STUDIO B MARKETING</p><h1>Vamos recuperar seu acesso.</h1></section><section className="auth-card"><div className="brand-mark">B</div><h2>Recuperar senha</h2><p className="muted">Enviaremos um link seguro para o seu e-mail.</p><form action={requestPasswordReset} className="form-stack"><label>E-mail<input name="email" type="email" required autoComplete="email" /></label><button className="button button-primary">Enviar instruções</button></form><Link className="text-link" href="/login">Voltar ao login</Link></section></main>;
}
