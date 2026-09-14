import { Card, Footer, PageHeader, Table } from "@/components/ui";
import { apiFetch, inr } from "@/lib/api";

export default async function Services() {
  const ss = await apiFetch<{ id: number; name: string; category: string; base_price: string; worker_share_pct: number; coop_share_pct: number }[]>("/admin/services");
  return (<>
    <PageHeader title="Services" sub={`${ss.length} services. Every price splits ${ss[0]?.worker_share_pct ?? 80}% to the worker and ${ss[0]?.coop_share_pct ?? 20}% to the cooperative.`} />
    <Card><Table head={["Service", "Category", "Base price", "Worker share", "Cooperative share", "Emergency price"]}
      rows={ss.map((s) => [<span key="n" className="font-medium">{s.name}</span>, s.category, <span key="p" className="tnum">{inr(s.base_price)}</span>, `${s.worker_share_pct}%`, `${s.coop_share_pct}%`, <span key="e" className="tnum">{inr(Number(s.base_price) * 1.5)}</span>])} /></Card>
    <Footer>Emergency price is 1.5x the base price. The split is applied to the final price, so workers earn more on emergency jobs too.</Footer>
  </>);
}
