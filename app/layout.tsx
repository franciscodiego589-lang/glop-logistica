import type { Metadata, Viewport } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import PWARegister from "@/components/PWARegister";

const inter = Inter({ subsets: ["latin"], display: "swap", variable: "--font-inter" });

export const metadata: Metadata = {
  title: "Cargyon — Enterprise ERP",
  description: "Cargyon — plataforma corporativa: Supply Chain, WMS, TMS, Comex, Financeiro, Comercial, RH, BPM, BI e IA.",
  manifest: "/manifest.webmanifest",
  applicationName: "Cargyon",
  appleWebApp: { capable: true, statusBarStyle: "black-translucent", title: "Cargyon" },
  icons: { icon: "/icon.svg", apple: "/icon.svg" },
};

export const viewport: Viewport = {
  themeColor: "#2f56e6",
  width: "device-width",
  initialScale: 1,
  viewportFit: "cover",
};

// Evita flash de tema: aplica o tema salvo antes da hidratação.
const themeScript = `
try {
  var t = localStorage.getItem('theme');
  if (t === 'dark' || (!t && window.matchMedia('(prefers-color-scheme: dark)').matches))
    document.documentElement.classList.add('dark');
} catch (e) {}
`;

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="pt-BR" className={inter.variable} suppressHydrationWarning>
      <head><script dangerouslySetInnerHTML={{ __html: themeScript }} /></head>
      <body className="font-sans antialiased">{children}<PWARegister /></body>
    </html>
  );
}
