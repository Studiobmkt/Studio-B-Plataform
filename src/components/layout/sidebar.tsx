import Link from "next/link";
import { BarChart3, Building2, ChevronDown, ClipboardList, FileText, FolderKanban, LayoutDashboard, Settings, Users } from "lucide-react";

const main = [["/dashboard", "Painel inicial", LayoutDashboard], ["/solicitacoes", "Solicitações ao time", ClipboardList], ["/clientes", "Clientes & marcas", Building2], ["/onboarding", "Onboarding", FileText], ["/projetos", "Projetos", FolderKanban], ["/relatorios", "Relatórios & performance", BarChart3]] as const;
const admin = [["/admin/equipe", "Equipe", Users], ["/admin/agencia", "Gestão da agência", Settings]] as const;

export function Sidebar({ role = "colaborador" }: { role?: string }) {
  return <aside className="sidebar"><Link href="/dashboard" className="sidebar-logo"><span className="logo-square">B</span><span><strong>Studio B</strong><small>MARKETING APP 2.0</small></span></Link><nav>{main.map(([href, label, Icon]) => <Link href={href} key={href}><Icon size={18}/>{label}</Link>)}{role === "admin" && <><p className="nav-label">ADMINISTRAÇÃO <ChevronDown size={13}/></p>{admin.map(([href, label, Icon]) => <Link href={href} key={href}><Icon size={18}/>{label}</Link>)}</>}</nav><div className="sidebar-footer"><Link href="/configuracoes"><Settings size={18}/>Configurações</Link><p>Studio B Marketing<br/><span>Ambiente de testes</span></p></div></aside>;
}
