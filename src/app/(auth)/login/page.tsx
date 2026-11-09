import Link from "next/link";
import { signIn } from "./actions";

export const instant = false;

export default async function LoginPage({ searchParams }: { searchParams: Promise<{ error?: string; message?: string }> }) {
  const params = await searchParams;
  return <main className="auth-shell"><section className="auth-brand"><p className="eyebrow">STUDIO B MARKETING</p><h1>O painel que move a agência.</h1><p>Operação, equipe e gestão em um único lugar.</p></section><section className="auth-card"><div className="brand-mark">B</div><h2>Bem-vinda de volta</h2><p className="muted">Entre com seu e-mail corporativo.</p>{params.error && <p className="form-error">{params.error}</p>}{params.message && <p className="form-success">{params.message}</p>}<form action={signIn} className="form-stack"><label>E-mail<input name="email" type="email" required autoComplete="email" placeholder="voce@studiob.com.br" /></label><label>Senha<input name="password" type="password" required autoComplete="current-password" placeholder="••••••••" /></label><button className="button button-primary">Entrar</button></form><Link className="text-link" href="/recuperar-senha">Esqueci minha senha</Link><p className="fine-print">O acesso é concedido somente por convite de administradores.</p></section></main>;
}
