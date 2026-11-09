import Link from "next/link";
import { Bell, Menu } from "lucide-react";

export function Topbar({ name, email }: { name?: string | null; email: string }) {
  const initial = (name || email).charAt(0).toUpperCase();
  return <header className="topbar"><button className="mobile-menu" aria-label="Abrir menu"><Menu size={21}/></button><div><p className="eyebrow">PAINEL DE OPERAÇÕES</p><p className="today">Studio B Marketing App</p></div><div className="topbar-actions"><button className="icon-button" aria-label="Notificações"><Bell size={19}/><span className="notification-dot"/></button><Link href="/configuracoes" className="user-pill"><span className="avatar">{initial}</span><span><strong>{name || "Meu perfil"}</strong><small>{email}</small></span></Link></div></header>;
}
