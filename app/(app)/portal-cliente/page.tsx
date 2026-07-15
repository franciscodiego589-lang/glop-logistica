import CXPWorkbench from "@/components/portal/CXPWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function PortalClientePage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Portal do Cliente (CXP)</h1><VitrineBanner /></div>;
  }
  const [dash, tickets, messages, rma, users, documents, articles, accounts] = await Promise.all([
    supabase.rpc("cxp_dashboard", { p_company: company }),
    supabase.from("support_tickets").select("*").eq("company_id", company).is("deleted_at", null).order("ticket_number", { ascending: false }).limit(300),
    supabase.from("ticket_messages").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: true }).limit(1000),
    supabase.from("cxp_rma_requests").select("*").eq("company_id", company).is("deleted_at", null).order("rma_number", { ascending: false }).limit(200),
    supabase.from("portal_users").select("*").eq("company_id", company).is("deleted_at", null).order("name").limit(300),
    supabase.from("customer_documents").select("*").eq("company_id", company).is("deleted_at", null).order("issued_at", { ascending: false }).limit(300),
    supabase.from("knowledge_articles").select("*").eq("company_id", company).is("deleted_at", null).order("title").limit(300),
    supabase.from("crm_accounts").select("id, name").eq("company_id", company).is("deleted_at", null).order("name").limit(500),
  ]);
  return <CXPWorkbench dash={dash.data ?? {}} tickets={tickets.data ?? []} messages={messages.data ?? []} rma={rma.data ?? []}
    users={users.data ?? []} documents={documents.data ?? []} articles={articles.data ?? []} accounts={accounts.data ?? []} />;
}
