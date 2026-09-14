import { Card, H1, Table } from "@/components/ui";
import { apiFetch } from "@/lib/api";

export default async function Customers() {
  const cs = await apiFetch<{ id: number; name: string; phone: string; lang: string }[]>("/admin/customers");
  return (<><H1>Customers ({cs.length})</H1><Card><Table head={["ID", "Name", "Phone", "Language"]} rows={cs.map((c) => [c.id, c.name, c.phone, c.lang])} /></Card></>);
}
