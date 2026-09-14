import { Card, Footer, PageHeader, Stat, Table } from "@/components/ui";
import { apiFetch, fmtDate, inr } from "@/lib/api";

type P = { settlements: { coop: string; jobs: number; worker_wages: number; coop_contribution: number }[];
  recent: { booking_id: number; service: string; worker: string; coop: string; customer_price: string; worker_wage: string; coop_contribution: string; date: string }[] };

export default async function Payments() {
  const p = await apiFetch<P>("/admin/payments");
  const wages = p.settlements.reduce((n, s) => n + s.worker_wages, 0);
  const coop = p.settlements.reduce((n, s) => n + s.coop_contribution, 0);
  return (
    <>
      <PageHeader title="Payments and settlements" sub="Paid bookings only. Settlement is owed to each society for its workers." />
      <div className="grid md:grid-cols-[2fr_3fr] gap-6 mb-8">
        <Stat lead label="Paid to workers" value={inr(wages)} hint={`${p.settlements.reduce((n, s) => n + s.jobs, 0)} paid jobs`} />
        <div className="grid grid-cols-2 gap-6 content-center border-l border-line pl-6">
          <Stat label="Cooperative contribution" value={inr(coop)} />
          <Stat label="Societies to settle" value={p.settlements.length} />
        </div>
      </div>
      <Card title="Settlement per society" className="mb-6">
        <Table head={["Society", "Jobs", "Worker wages (80%)", "Cooperative contribution (20%)"]} rows={p.settlements.map((s) => [<span key="n" className="font-medium">{s.coop}</span>, <span key="j" className="tnum">{s.jobs}</span>, <span key="w" className="tnum">{inr(s.worker_wages)}</span>, <span key="c" className="tnum">{inr(s.coop_contribution)}</span>])} />
      </Card>
      <Card title="Recent payments">
        <Table head={["#", "Service", "Worker", "Date", "Customer paid", "Worker", "Cooperative"]} rows={p.recent.map((r) => [<span key="i" className="tnum text-fg-2">{r.booking_id}</span>, r.service, r.worker, fmtDate(r.date), <span key="a" className="tnum font-medium">{inr(r.customer_price)}</span>, <span key="b" className="tnum">{inr(r.worker_wage)}</span>, <span key="c" className="tnum">{inr(r.coop_contribution)}</span>])} />
      </Card>
      <Footer>Razorpay settlement to society bank accounts is not part of this prototype.</Footer>
    </>
  );
}
