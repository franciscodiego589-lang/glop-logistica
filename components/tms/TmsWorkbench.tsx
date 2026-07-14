"use client";
import { useState } from "react";
import CrudPanel from "@/components/ui/CrudPanel";
import ShipmentsPanel from "./ShipmentsPanel";
import FreightCalculator from "./FreightCalculator";

const MODALS: [string, string][] = [
  ["road", "Rodoviário"], ["air", "Aéreo"], ["sea", "Marítimo"], ["rail", "Ferroviário"], ["courier", "Courier"], ["pipeline", "Duto"],
];
const CNH: [string, string][] = [["A", "A"], ["B", "B"], ["C", "C"], ["D", "D"], ["E", "E"], ["AB", "AB"], ["AC", "AC"], ["AD", "AD"], ["AE", "AE"]];

const TABS = ["Embarques", "Transportadoras", "Frota", "Motoristas", "Tabelas de Frete", "Calculadora"] as const;

export default function TmsWorkbench({ data }: { data: any }) {
  const [tab, setTab] = useState<(typeof TABS)[number]>("Embarques");
  return (
    <div className="space-y-4">
      <div className="flex gap-1 flex-wrap">
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>

      {tab === "Embarques" && <ShipmentsPanel shipments={data.shipments} carriers={data.carriers} />}

      {tab === "Transportadoras" && (
        <CrudPanel table="carriers" title="Transportadoras" rows={data.carriers}
          fields={[
            { key: "name", label: "Nome", required: true },
            { key: "code", label: "Código" },
            { key: "document", label: "CNPJ" },
            { key: "modal", label: "Modal", type: "select", options: MODALS, default: "road" },
            { key: "phone", label: "Telefone" },
            { key: "email", label: "E-mail" },
            { key: "rating", label: "Nota (0-5)", type: "number" },
          ]}
          columns={[
            { key: "name", label: "Nome" }, { key: "modal", label: "Modal", fmt: (v) => MODALS.find(([x]) => x === v)?.[1] ?? v },
            { key: "document", label: "CNPJ" }, { key: "phone", label: "Telefone" }, { key: "rating", label: "Nota" },
          ]} />
      )}

      {tab === "Frota" && (
        <CrudPanel table="vehicles" title="Frota (veículos)" rows={data.vehicles}
          fields={[
            { key: "plate", label: "Placa", required: true },
            { key: "vehicle_type", label: "Tipo", placeholder: "truck, carreta, van…" },
            { key: "brand", label: "Marca" },
            { key: "model", label: "Modelo" },
            { key: "carrier_id", label: "Transportadora", type: "fk", fkTable: "carriers" },
            { key: "max_weight_kg", label: "Cap. peso (kg)", type: "number" },
            { key: "max_volume_m3", label: "Cap. volume (m³)", type: "number" },
            { key: "max_pallets", label: "Cap. pallets", type: "number" },
          ]}
          columns={[
            { key: "plate", label: "Placa" }, { key: "vehicle_type", label: "Tipo" },
            { key: "brand", label: "Marca" }, { key: "model", label: "Modelo" },
            { key: "carrier_id", label: "Transportadora", fmt: () => "" },
            { key: "max_weight_kg", label: "Cap. (kg)" },
          ]} />
      )}

      {tab === "Motoristas" && (
        <CrudPanel table="drivers" title="Motoristas" rows={data.drivers}
          fields={[
            { key: "name", label: "Nome", required: true },
            { key: "document", label: "CPF" },
            { key: "license_number", label: "CNH" },
            { key: "license_category", label: "Categoria", type: "select", options: CNH },
            { key: "carrier_id", label: "Transportadora", type: "fk", fkTable: "carriers" },
            { key: "phone", label: "Telefone" },
          ]}
          columns={[
            { key: "name", label: "Nome" }, { key: "license_number", label: "CNH" },
            { key: "license_category", label: "Cat." },
            { key: "carrier_id", label: "Transportadora", fmt: () => "" }, { key: "phone", label: "Telefone" },
          ]} />
      )}

      {tab === "Tabelas de Frete" && (
        <CrudPanel table="freight_rates" title="Tabelas de frete" rows={data.rates}
          emptyHint="Cadastre faixas de frete (transportadora + UF destino + faixa de peso + preço). A calculadora usa estas tabelas."
          fields={[
            { key: "carrier_id", label: "Transportadora", type: "fk", fkTable: "carriers", required: true },
            { key: "origin_uf", label: "UF origem" },
            { key: "dest_uf", label: "UF destino" },
            { key: "weight_from_kg", label: "Peso de (kg)", type: "number", default: "0" },
            { key: "weight_to_kg", label: "Peso até (kg)", type: "number" },
            { key: "price_per_kg", label: "R$/kg", type: "number" },
            { key: "price_fixed", label: "Frete mínimo (R$)", type: "number" },
            { key: "gris_percent", label: "GRIS %", type: "number" },
            { key: "advalorem_percent", label: "Ad valorem %", type: "number" },
            { key: "lead_time_days", label: "Prazo (dias)", type: "number" },
          ]}
          columns={[
            { key: "carrier_id", label: "Transportadora", fmt: () => "" },
            { key: "dest_uf", label: "UF dest" },
            { key: "weight_to_kg", label: "Até kg" }, { key: "price_per_kg", label: "R$/kg" },
            { key: "gris_percent", label: "GRIS%" }, { key: "advalorem_percent", label: "AdVal%" },
            { key: "lead_time_days", label: "Prazo" },
          ]} />
      )}

      {tab === "Calculadora" && <FreightCalculator rates={data.rates} carriers={data.carriers} />}
    </div>
  );
}
