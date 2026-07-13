import Link from "next/link";
import ProductForm from "@/components/produtos/ProductForm";

export default function NovoProdutoPage() {
  return (
    <div className="space-y-4 max-w-4xl">
      <div className="flex items-center gap-3">
        <Link href="/produtos" className="muted hover:underline text-sm">← Cadastro Mestre</Link>
        <h1 className="text-xl font-bold">Novo produto</h1>
      </div>
      <ProductForm productId={null} initial={{}} />
    </div>
  );
}
