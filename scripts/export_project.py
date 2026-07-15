#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Exporta o projeto Cargyon em JSON + PDF (relatório executivo/técnico)."""
import os, re, json, glob, subprocess, datetime, html

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "deliverables")
os.makedirs(OUT, exist_ok=True)
GEN_DATE = "2026-07-15"

# ── 1) Módulos a partir de lib/nav.ts ───────────────────────────────────────
nav_src = open(os.path.join(ROOT, "lib", "nav.ts"), encoding="utf-8").read()
item_re = re.compile(
    r'\{\s*slug:\s*"([^"]+)",\s*label:\s*"([^"]+)",\s*icon:\s*"([^"]*)",\s*'
    r'group:\s*"([^"]+)",\s*vol:\s*(\d+),\s*description:\s*"([^"]*)"\s*\}')
modules = []
for m in item_re.finditer(nav_src):
    slug, label, icon, group, vol, desc = m.groups()
    modules.append({"slug": slug, "label": label, "icon": icon,
                    "group": group, "vol": int(vol), "description": desc})

groups = {}
for mod in modules:
    groups.setdefault(mod["group"], []).append(mod)

# ── 2) Inventário de migrations (tabelas + funções + RPCs) ───────────────────
mig_files = sorted(glob.glob(os.path.join(ROOT, "supabase", "migrations", "*.sql")))
tbl_re = re.compile(r'create table (?:if not exists )?public\.([a-z_]+)', re.I)
fn_re = re.compile(r'create or replace function public\.([a-z_]+)', re.I)
migrations = []
all_tables, all_fns = set(), set()
for f in mig_files:
    src = open(f, encoding="utf-8", errors="ignore").read()
    tbls = sorted(set(tbl_re.findall(src)))
    fns = sorted(set(fn_re.findall(src)))
    all_tables.update(tbls)
    all_fns.update(fns)
    migrations.append({
        "file": os.path.basename(f),
        "tables": tbls,
        "functions": fns,
        "statements": src.count(";"),
        "bytes": len(src.encode("utf-8")),
    })

insight_engines = sorted([fn for fn in all_fns if fn.endswith("_insights")
                          or fn.startswith("detect_") or fn.startswith("audit_")])

project = {
    "name": "Cargyon",
    "tagline": "Enterprise ERP — Logística, Supply Chain & Governança Corporativa",
    "generated_at": GEN_DATE,
    "stack": {
        "database": "Supabase (PostgreSQL)",
        "frontend": "Next.js 14 (App Router) + TypeScript + Tailwind",
        "auth": "Supabase Auth (JWT) + RLS + RBAC",
        "ai_brain": "LAIOS (multiagente, insights auto-descobertos, pg_cron 24/7)",
        "pwa": "instalável + offline (service worker)",
    },
    "architecture": {
        "multi_tenant": "tenant → company → branch → membership",
        "rls": "habilitado em 100% das tabelas de negócio",
        "rbac": "app.has_permission('<recurso>.<ação>', company_id)",
        "audit": "app.tg_write_audit() em toda tabela (quem/quando/antes/depois)",
        "soft_delete": "deleted_at / reason_deleted (sem DELETE físico)",
    },
    "totals": {
        "modules": len(modules),
        "groups": len(groups),
        "migrations": len(migrations),
        "tables": len(all_tables),
        "functions_rpc": len(all_fns),
        "insight_engines": len(insight_engines),
    },
    "groups": [{"name": g, "modules": mods} for g, mods in groups.items()],
    "modules": modules,
    "migrations": migrations,
    "insight_engines": insight_engines,
    "supabase_project_ref": "ittbmqnwomhkxnvlqjvl",
    "repo": "~/Downloads/erp-logistica",
}

json_path = os.path.join(OUT, "cargyon-project.json")
with open(json_path, "w", encoding="utf-8") as fp:
    json.dump(project, fp, ensure_ascii=False, indent=2)
print("JSON:", json_path, f"({os.path.getsize(json_path)} bytes)")

# ── 3) HTML → PDF ────────────────────────────────────────────────────────────
def esc(s): return html.escape(str(s))
t = project["totals"]
group_rows = ""
for g in project["groups"]:
    rows = "".join(
        f"<tr><td class='ic'>{esc(mod['icon'])}</td><td><b>{esc(mod['label'])}</b>"
        f"<div class='muted'>{esc(mod['description'])}</div></td>"
        f"<td class='slug'>/{esc(mod['slug'])}</td></tr>"
        for mod in g["modules"])
    group_rows += (f"<h3 class='grp'>{esc(g['name'])} "
                   f"<span class='cnt'>{len(g['modules'])}</span></h3>"
                   f"<table class='mods'>{rows}</table>")

mig_rows = "".join(
    f"<tr><td class='mono'>{esc(m['file'].replace('20260713',''))}</td>"
    f"<td class='num'>{len(m['tables'])}</td><td class='num'>{len(m['functions'])}</td>"
    f"<td class='mono small'>{esc(', '.join(m['tables'][:6]))}"
    f"{'…' if len(m['tables'])>6 else ''}</td></tr>"
    for m in project["migrations"] if m["tables"] or m["functions"])

html_doc = f"""<!doctype html><html lang="pt-BR"><head><meta charset="utf-8">
<style>
  * {{ box-sizing: border-box; }}
  body {{ font-family: -apple-system, 'Segoe UI', Roboto, Arial, sans-serif; color:#1a2233; margin:0; font-size:12px; }}
  .page {{ padding: 30px 38px; }}
  .cover {{ background: linear-gradient(135deg,#1b2a6b,#2f56e6 60%,#5b8bff); color:#fff; padding:60px 40px 46px; }}
  .cover h1 {{ font-size:48px; margin:0 0 6px; letter-spacing:-1px; }}
  .cover .sub {{ font-size:15px; opacity:.9; margin-bottom:26px; }}
  .cover .mark {{ font-size:13px; opacity:.75; }}
  .kpis {{ display:flex; flex-wrap:wrap; gap:10px; margin-top:24px; }}
  .kpi {{ background:rgba(255,255,255,.14); border:1px solid rgba(255,255,255,.25); border-radius:12px; padding:12px 16px; min-width:104px; }}
  .kpi .v {{ font-size:26px; font-weight:800; }}
  .kpi .l {{ font-size:10px; opacity:.85; text-transform:uppercase; letter-spacing:.5px; }}
  h2 {{ color:#2f56e6; border-bottom:2px solid #e6ebfa; padding-bottom:6px; margin:26px 0 12px; font-size:17px; }}
  h3.grp {{ margin:16px 0 4px; font-size:13px; color:#28324a; }}
  h3 .cnt {{ background:#eef2fe; color:#2f56e6; border-radius:20px; padding:1px 9px; font-size:11px; margin-left:6px; }}
  table {{ width:100%; border-collapse:collapse; }}
  table.mods td {{ padding:5px 8px; border-bottom:1px solid #f0f2f7; vertical-align:top; }}
  td.ic {{ width:22px; font-size:15px; }}
  td.slug {{ text-align:right; color:#2f56e6; font-family:ui-monospace,Menlo,monospace; font-size:10px; white-space:nowrap; }}
  .muted {{ color:#6b7690; font-size:10.5px; margin-top:1px; }}
  table.mig th {{ text-align:left; background:#f5f7fd; padding:5px 8px; font-size:10px; text-transform:uppercase; letter-spacing:.4px; color:#54607a; }}
  table.mig td {{ padding:4px 8px; border-bottom:1px solid #f2f4f9; }}
  .mono {{ font-family:ui-monospace,Menlo,monospace; font-size:10px; }}
  .small {{ color:#6b7690; }}
  .num {{ text-align:center; width:44px; font-weight:700; }}
  .grid2 {{ display:flex; gap:20px; flex-wrap:wrap; }}
  .card {{ flex:1; min-width:230px; background:#f8faff; border:1px solid #e6ebfa; border-radius:10px; padding:12px 14px; }}
  .card b {{ color:#2f56e6; }}
  .card div {{ margin:3px 0; font-size:11px; }}
  .foot {{ margin-top:28px; color:#8a93a8; font-size:10px; border-top:1px solid #eef0f5; padding-top:8px; }}
  .badge {{ display:inline-block; background:#eaf7ee; color:#1a7a3c; border-radius:6px; padding:1px 7px; font-size:10px; font-weight:600; }}
</style></head><body>
<div class="cover">
  <div class="mark">◈ RELATÓRIO DE ARQUITETURA · {esc(GEN_DATE)}</div>
  <h1>Cargyon</h1>
  <div class="sub">{esc(project['tagline'])}</div>
  <div class="kpis">
    <div class="kpi"><div class="v">{t['modules']}</div><div class="l">Módulos</div></div>
    <div class="kpi"><div class="v">{t['migrations']}</div><div class="l">Migrations</div></div>
    <div class="kpi"><div class="v">{t['tables']}</div><div class="l">Tabelas</div></div>
    <div class="kpi"><div class="v">{t['functions_rpc']}</div><div class="l">Funções/RPC</div></div>
    <div class="kpi"><div class="v">{t['insight_engines']}</div><div class="l">Motores IA</div></div>
    <div class="kpi"><div class="v">{t['groups']}</div><div class="l">Áreas</div></div>
  </div>
</div>
<div class="page">
  <h2>Visão geral</h2>
  <div class="grid2">
    <div class="card"><b>Stack</b>
      <div>🗄 {esc(project['stack']['database'])}</div>
      <div>⚛ {esc(project['stack']['frontend'])}</div>
      <div>🔐 {esc(project['stack']['auth'])}</div>
      <div>✦ {esc(project['stack']['ai_brain'])}</div>
      <div>📱 PWA {esc(project['stack']['pwa'])}</div>
    </div>
    <div class="card"><b>Arquitetura</b>
      <div>🏢 Multi-tenant: {esc(project['architecture']['multi_tenant'])}</div>
      <div>🛡 RLS: {esc(project['architecture']['rls'])}</div>
      <div>👤 RBAC: <span class="mono">{esc(project['architecture']['rbac'])}</span></div>
      <div>📝 Auditoria: {esc(project['architecture']['audit'])}</div>
      <div>♻️ Soft delete: {esc(project['architecture']['soft_delete'])}</div>
    </div>
  </div>
  <p style="margin-top:12px"><span class="badge">RLS 100%</span> &nbsp;
  Backend único Supabase (projeto <span class="mono">{esc(project['supabase_project_ref'])}</span>),
  cérebro LAIOS roda {t['insight_engines']} motores de insight auto-descobertos via pg_cron a cada 15 min.</p>

  <h2>Módulos por área ({t['modules']})</h2>
  {group_rows}

  <h2>Migrations com schema ({sum(1 for m in project['migrations'] if m['tables'] or m['functions'])} de {t['migrations']})</h2>
  <table class="mig"><thead><tr><th>Arquivo</th><th class="num">Tab.</th><th class="num">Fn.</th><th>Tabelas (amostra)</th></tr></thead>
  <tbody>{mig_rows}</tbody></table>

  <div class="foot">Cargyon · gerado automaticamente de lib/nav.ts + supabase/migrations · {esc(GEN_DATE)} ·
  {t['tables']} tabelas · {t['functions_rpc']} funções · repositório {esc(project['repo'])}</div>
</div>
</body></html>"""

html_path = os.path.join(OUT, "cargyon-project.html")
open(html_path, "w", encoding="utf-8").write(html_doc)
pdf_path = os.path.join(OUT, "cargyon-project.pdf")

chrome = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
subprocess.run([chrome, "--headless", "--disable-gpu", "--no-pdf-header-footer",
                f"--print-to-pdf={pdf_path}", "file://" + html_path],
               check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
print("PDF :", pdf_path, f"({os.path.getsize(pdf_path)} bytes)")
