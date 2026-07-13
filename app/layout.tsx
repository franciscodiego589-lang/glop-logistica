import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "ERP Logístico Mundial",
  description: "ERP de logística Enterprise — WMS · TMS · YMS · MRP · PCP · BI · LOGIA",
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
    <html lang="pt-BR" suppressHydrationWarning>
      <head><script dangerouslySetInnerHTML={{ __html: themeScript }} /></head>
      <body className="font-sans antialiased">{children}</body>
    </html>
  );
}
