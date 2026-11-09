import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = { title: "Studio B Marketing App 2.0", description: "Painel de operações da Studio B Marketing" };

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return <html lang="pt-BR"><body>{children}</body></html>;
}
