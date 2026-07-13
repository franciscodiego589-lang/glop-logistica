import { redirect } from "next/navigation";
import Sidebar from "@/components/Sidebar";
import Topbar from "@/components/Topbar";
import { createClient } from "@/lib/supabase/server";

export default async function AppLayout({ children }: { children: React.ReactNode }) {
  const supabase = createClient();
  // Se o banco está conectado, exige login. Sem banco = modo vitrine (livre).
  if (supabase) {
    const { data } = await supabase.auth.getUser();
    if (!data.user) redirect("/login");
  }
  return (
    <div className="flex h-screen overflow-hidden">
      <Sidebar />
      <div className="flex-1 flex flex-col min-w-0">
        <Topbar />
        <main className="flex-1 overflow-y-auto p-3">{children}</main>
      </div>
    </div>
  );
}
