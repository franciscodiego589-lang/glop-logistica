"use client";
import { useState } from "react";
import CrudPanel from "@/components/ui/CrudPanel";
import SamplesPanel from "./SamplesPanel";
import { TEST_KIND } from "./shared";

const TABS = ["Amostras", "Especificações", "Métodos", "Reagentes", "Instrumentos", "Estabilidade"] as const;

export default function LimsWorkbench({ data }: { data: any }) {
  const [tab, setTab] = useState<(typeof TABS)[number]>("Amostras");
  return (
    <div className="space-y-4">
      <div className="flex gap-1 flex-wrap">
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>

      {tab === "Amostras" && <SamplesPanel samples={data.samples} products={data.products} lots={data.lots} prodName={data.prodName} />}

      {tab === "Especificações" && (
        <CrudPanel table="product_specifications" title="Especificações por produto" rows={data.specs}
          emptyHint="Defina os limites (mín/máx) por parâmetro e produto. Os ensaios comparam o resultado com estes limites."
          fields={[
            { key: "product_id", label: "Produto", type: "fk", fkTable: "products", required: true },
            { key: "parameter", label: "Parâmetro", required: true },
            { key: "test_kind", label: "Tipo", type: "select", options: TEST_KIND, default: "chemical" },
            { key: "min_value", label: "Mínimo", type: "number" },
            { key: "max_value", label: "Máximo", type: "number" },
            { key: "unit", label: "Unidade" },
            { key: "method_id", label: "Método", type: "fk", fkTable: "lab_methods" },
          ]}
          columns={[
            { key: "product_id", label: "Produto", fmt: () => "" }, { key: "parameter", label: "Parâmetro" },
            { key: "test_kind", label: "Tipo" }, { key: "min_value", label: "Mín" }, { key: "max_value", label: "Máx" }, { key: "unit", label: "Un." },
          ]} />
      )}

      {tab === "Métodos" && (
        <CrudPanel table="lab_methods" title="Métodos analíticos (POP)" rows={data.methods}
          emptyHint="Cadastre os métodos/POPs usados nos ensaios."
          fields={[
            { key: "name", label: "Nome", required: true },
            { key: "code", label: "Código" },
            { key: "technique", label: "Técnica", placeholder: "HPLC, titulação…" },
            { key: "test_kind", label: "Tipo", type: "select", options: TEST_KIND, default: "chemical" },
            { key: "version_label", label: "Versão" },
            { key: "status", label: "Status", type: "select", options: [["draft", "Rascunho"], ["approved", "Aprovado"], ["obsolete", "Obsoleto"]], default: "draft" },
          ]}
          columns={[
            { key: "code", label: "Código" }, { key: "name", label: "Nome" }, { key: "technique", label: "Técnica" },
            { key: "test_kind", label: "Tipo" }, { key: "version_label", label: "Versão" }, { key: "status", label: "Status" },
          ]} />
      )}

      {tab === "Reagentes" && (
        <CrudPanel table="lab_reagents" title="Reagentes" rows={data.reagents}
          emptyHint="Controle reagentes com lote e validade."
          fields={[
            { key: "name", label: "Nome", required: true },
            { key: "manufacturer", label: "Fabricante" },
            { key: "lot_number", label: "Lote" },
            { key: "expiry_date", label: "Validade", type: "date" },
            { key: "quantity", label: "Quantidade", type: "number" },
            { key: "unit", label: "Unidade" },
            { key: "location", label: "Localização" },
            { key: "responsible", label: "Responsável" },
          ]}
          columns={[
            { key: "name", label: "Nome" }, { key: "manufacturer", label: "Fabricante" }, { key: "lot_number", label: "Lote" },
            { key: "expiry_date", label: "Validade" }, { key: "quantity", label: "Qtd" }, { key: "location", label: "Local" },
          ]} />
      )}

      {tab === "Instrumentos" && (
        <CrudPanel table="lab_instruments" title="Instrumentos" rows={data.instruments}
          emptyHint="Cadastre os equipamentos de laboratório e o vencimento da calibração."
          fields={[
            { key: "name", label: "Nome", required: true },
            { key: "code", label: "Código" },
            { key: "instrument_type", label: "Tipo", placeholder: "HPLC, balança, pHmetro…" },
            { key: "manufacturer", label: "Fabricante" },
            { key: "model", label: "Modelo" },
            { key: "last_calibration", label: "Última calibração", type: "date" },
            { key: "calibration_due", label: "Próxima calibração", type: "date" },
            { key: "responsible", label: "Responsável" },
          ]}
          columns={[
            { key: "code", label: "Código" }, { key: "name", label: "Nome" }, { key: "instrument_type", label: "Tipo" },
            { key: "calibration_due", label: "Calibração até" }, { key: "responsible", label: "Responsável" },
          ]} />
      )}

      {tab === "Estabilidade" && (
        <CrudPanel table="stability_studies" title="Estudos de estabilidade" rows={data.stability}
          emptyHint="Estudos de estabilidade (longa duração, acelerado, fotoestabilidade)."
          fields={[
            { key: "product_id", label: "Produto", type: "fk", fkTable: "products", required: true },
            { key: "code", label: "Código" },
            { key: "study_kind", label: "Tipo", type: "select", options: [["long_term", "Longa duração"], ["accelerated", "Acelerado"], ["photostability", "Fotoestabilidade"], ["in_use", "Em uso"]], default: "long_term" },
            { key: "condition_temp", label: "Temperatura", placeholder: "25°C / 40°C" },
            { key: "condition_humidity", label: "Umidade", placeholder: "60% / 75%" },
            { key: "start_date", label: "Início", type: "date" },
            { key: "end_date", label: "Fim previsto", type: "date" },
            { key: "status", label: "Status", type: "select", options: [["ongoing", "Em andamento"], ["completed", "Concluído"], ["canceled", "Cancelado"]], default: "ongoing" },
          ]}
          columns={[
            { key: "product_id", label: "Produto", fmt: () => "" }, { key: "code", label: "Código" }, { key: "study_kind", label: "Tipo" },
            { key: "condition_temp", label: "Temp." }, { key: "condition_humidity", label: "Umidade" }, { key: "status", label: "Status" },
          ]} />
      )}
    </div>
  );
}
