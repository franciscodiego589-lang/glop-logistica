"use client";
import { useMemo, useState } from "react";
import { createClient } from "@/lib/supabase/client";

const COMPANY = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_ID as string;

// Upload real de foto para o Storage (bucket 'products') + registro em product_media.
export default function MediaUploader({ productId, tenantId }: { productId: string; tenantId: string | null }) {
  const supabase = useMemo(() => createClient(), []);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  async function onFile(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file || !supabase || !tenantId) return;
    setBusy(true); setErr(null);
    const safe = file.name.replace(/[^a-zA-Z0-9._-]/g, "_");
    const path = `${COMPANY}/${productId}/${Date.now()}-${safe}`;
    const { error: upErr } = await supabase.storage.from("products").upload(path, file, { upsert: true });
    if (upErr) { setErr(upErr.message); setBusy(false); return; }
    const { data: pub } = supabase.storage.from("products").getPublicUrl(path);
    const { error } = await supabase.from("product_media").insert({
      tenant_id: tenantId, company_id: COMPANY, product_id: productId,
      media_kind: "main", url: pub.publicUrl, storage_path: path, title: file.name,
    });
    setBusy(false);
    if (error) { setErr(error.message); return; }
    window.location.reload();
  }

  return (
    <div className="card p-4">
      <div className="font-semibold mb-2">Upload de foto (Storage)</div>
      <label className="inline-flex items-center gap-2 px-3 py-2 rounded-lg bg-brand-600 hover:bg-brand-700 text-white text-sm font-semibold cursor-pointer">
        {busy ? "Enviando…" : "Escolher imagem"}
        <input type="file" accept="image/*" className="hidden" onChange={onFile} disabled={busy} />
      </label>
      {err && <div className="text-sm text-red-500 mt-2">{err}</div>}
    </div>
  );
}
