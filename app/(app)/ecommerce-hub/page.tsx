import EcommerceHubWorkbench from "@/components/ecommerce-hub/EcommerceHubWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function EcommerceHubPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">E-commerce — Lojas &amp; Chaves API</h1><VitrineBanner /></div>;
  }

  // SEGURANÇA: nunca selecionar webhook_token / colunas secretas para o client.
  const [connectorsRes, ordersRes] = await Promise.all([
    supabase.from("store_connectors")
      .select("id,name,platform,producer_ref,status,categoria,metadata,last_event_at")
      .eq("company_id", company).eq("categoria", "ecommerce").is("deleted_at", null)
      .order("name", { ascending: true }).limit(200),
    supabase.from("store_orders")
      .select("platform").eq("company_id", company).is("deleted_at", null).limit(2000),
  ]);

  // Contagem de pedidos por plataforma (loja) — agregada no server.
  const pedidosPorLoja: Record<string, number> = {};
  for (const o of (ordersRes.data ?? []) as { platform: string | null }[]) {
    const p = o.platform ?? "—";
    pedidosPorLoja[p] = (pedidosPorLoja[p] ?? 0) + 1;
  }

  return <EcommerceHubWorkbench
    connectors={connectorsRes.data ?? []}
    pedidosPorLoja={pedidosPorLoja}
  />;
}
