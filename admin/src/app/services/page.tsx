import { Card, H1, Table } from "@/components/ui";
import { apiFetch, inr } from "@/lib/api";

export default async function Services() {
  const ss = await apiFetch<{ id: number; name: string; category: string; base_price: string; worker_share_pct: number; coop_share_pct: number }[]>("/admin/services");
  return (<><H1>Services</H1><Card><Table head={["Service", "Category", "Base price", "Worker share", "Cooperative share", "Emergency price"]}
    rows={ss.map((s) => [s.name, s.category, inr(s.base_price), `${s.worker_share_pct}%`, `${s.coop_share_pct}%`, inr(Number(s.base_price) * 1.5)])} /></Card></>);
}
