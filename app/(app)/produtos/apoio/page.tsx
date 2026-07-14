"use client";
import { useState } from "react";
import Link from "next/link";
import SimpleCrud from "@/components/produtos/SimpleCrud";

const TABS = ["Marcas", "Categorias", "Unidades", "Fornecedores"] as const;

export default function ApoioPage() {
  const [tab, setTab] = useState<(typeof TABS)[number]>("Marcas");
  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <Link href="/produtos" className="muted hover:underline text-sm">← Cadastro Mestre</Link>
        <h1 className="text-xl font-bold">Cadastros de apoio</h1>
      </div>
      <div className="flex gap-1 flex-wrap">
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-3 py-1.5 rounded-lg text-sm ${tab === t ? "bg-brand-600 text-white" : "card hover:bg-black/5 dark:hover:bg-white/5"}`}>{t}</button>
        ))}
      </div>

      {tab === "Marcas" && (
        <SimpleCrud table="product_brands"
          fields={[{ key: "name", label: "Marca" }, { key: "code", label: "Código" }, { key: "manufacturer", label: "Fabricante" }]}
          listCols={["name", "code", "manufacturer"]} />
      )}
      {tab === "Categorias" && (
        <SimpleCrud table="product_categories"
          fields={[{ key: "name", label: "Categoria" }, { key: "code", label: "Código" }]}
          listCols={["name", "code"]} />
      )}
      {tab === "Unidades" && (
        <SimpleCrud table="units_of_measure"
          fields={[{ key: "code", label: "Código (un, cx…)" }, { key: "name", label: "Nome" }, { key: "uom_kind", label: "Tipo", type: "select", options: [["count","Contagem"],["weight","Peso"],["volume","Volume"],["length","Comprimento"],["area","Área"],["time","Tempo"]] }]}
          listCols={["code", "name", "uom_kind"]} />
      )}
      {tab === "Fornecedores" && (
        <SimpleCrud table="suppliers"
          fields={[{ key: "name", label: "Fornecedor" }, { key: "document", label: "CNPJ/CPF" }, { key: "phone", label: "Telefone" }, { key: "email", label: "E-mail" }]}
          listCols={["name", "document", "phone", "email"]} />
      )}
    </div>
  );
}
