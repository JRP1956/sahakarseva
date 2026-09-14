import { Card, Footer, PageHeader, Table } from "@/components/ui";
import { apiFetch } from "@/lib/api";

const LANG: Record<string, string> = { en: "English", hi: "Hindi", mr: "Marathi" };
export default async function Customers() {
  const cs = await apiFetch<{ id: number; name: string; phone: string; lang: string }[]>("/admin/customers");
  return (<>
    <PageHeader title="Customers" sub={`${cs.length} households registered`} />
    <Card><Table head={["ID", "Name", "Phone", "Language"]} rows={cs.map((c) => [<span key="i" className="tnum text-fg-2">{c.id}</span>, <span key="n" className="font-medium">{c.name}</span>, c.phone, LANG[c.lang] ?? c.lang])} /></Card>
    <Footer>Language is the customer's app preference and drives which locale the app opens in.</Footer>
  </>);
}
