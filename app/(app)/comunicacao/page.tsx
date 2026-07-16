import ComunicacaoWorkbench from "@/components/comunicacao/ComunicacaoWorkbench";
import { VitrineBanner } from "@/components/VitrineBanner";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function ComunicacaoPage() {
  const supabase = createClient();
  const company = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID;
  if (!supabase || !company) {
    return <div className="space-y-4"><h1 className="text-xl font-bold">Comunicação (Email/WhatsApp)</h1><VitrineBanner /></div>;
  }
  const [emailLogs, whatsappLogs, emailTemplate, whatsappTemplate, carteiroTemplate] = await Promise.all([
    supabase.from("email_envios_log").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.from("whatsapp_envios_log").select("*").eq("company_id", company).is("deleted_at", null).order("created_at", { ascending: false }).limit(200),
    supabase.from("email_template_rastreio").select("*").eq("company_id", company).is("deleted_at", null).limit(1),
    supabase.from("whatsapp_template").select("*").eq("company_id", company).is("deleted_at", null).limit(1),
    supabase.from("whatsapp_template_carteiro").select("*").eq("company_id", company).is("deleted_at", null).limit(1),
  ]);
  return <ComunicacaoWorkbench
    emailLogs={emailLogs.data ?? []}
    whatsappLogs={whatsappLogs.data ?? []}
    emailTemplate={(emailTemplate.data ?? [])[0] ?? null}
    whatsappTemplate={(whatsappTemplate.data ?? [])[0] ?? null}
    carteiroTemplate={(carteiroTemplate.data ?? [])[0] ?? null}
  />;
}
