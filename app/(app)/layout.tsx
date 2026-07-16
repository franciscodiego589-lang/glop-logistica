import { redirect } from "next/navigation";
import Sidebar from "@/components/Sidebar";
import Topbar from "@/components/Topbar";
import HelpBar from "@/components/HelpBar";
import CommandPalette from "@/components/CommandPalette";
import { createClient } from "@/lib/supabase/server";

export default async function AppLayout({ children }: { children: React.ReactNode }) {
  const supabase = createClient();
  let email: string | null = null;
  // Se o banco está conectado, exige login. Sem banco = modo vitrine (livre).
  if (supabase) {
    const { data } = await supabase.auth.getUser();
    if (!data.user) redirect("/login");
    email = data.user.email ?? null;
  }
  return (
    <div className="flex h-screen overflow-hidden">
      <Sidebar />
      <div className="flex-1 flex flex-col min-w-0">
        <CommandPalette />
        <Topbar email={email} />
        <main className="flex-1 overflow-y-auto px-4 sm:px-6 py-6">
          <div className="mx-auto max-w-[1400px] animate-in">
            <HelpBar />
            {children}
          </div>
        </main>
      </div>
    </div>
  );
}
