// Identidade da empresa para papel timbrado (relatórios/PDF). Sobrescreva por env
// se um dia houver seletor de empresa / white-label.
export const EMPRESA = {
  razaoSocial: process.env.NEXT_PUBLIC_EMPRESA_RAZAO || "LEMONCAPS INDÚSTRIA E COMÉRCIO LTDA",
  nomeFantasia: process.env.NEXT_PUBLIC_EMPRESA_FANTASIA || "Lemoncaps",
  cnpj: process.env.NEXT_PUBLIC_EMPRESA_CNPJ || "55.836.075/0001-07",
  email: process.env.NEXT_PUBLIC_EMPRESA_EMAIL || "lemoncapsencapsulados@gmail.com",
  sistema: "GLOP — Global Logistics Platform",
  sigla: "GLOP",
};
