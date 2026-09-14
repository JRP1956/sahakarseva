import { Card, Footer, PageHeader, Stat, Table } from "@/components/ui";
import { apiFetch } from "@/lib/api";

type Wf = { total: number; insured: number; accident_cover: number; members: number; per_coop: { coop: string; total: number; insured: number; accident_cover: number; members: number }[] };
const pct = (a: number, b: number) => (b ? Math.round((a / b) * 100) : 0);
const Cov = ({ a, b }: { a: number; b: number }) => (
  <span className="inline-flex items-center gap-3 tnum">
    <span className="w-24 h-1.5 rounded-full bg-sunken overflow-hidden"><span className="block h-full bg-primary" style={{ width: `${pct(a, b)}%` }} /></span>
    {a} <span className="text-fg-2">({pct(a, b)}%)</span>
  </span>
);

export default async function Welfare() {
  const w = await apiFetch<Wf>("/admin/welfare");
  return (
    <>
      <PageHeader title="Worker welfare" sub="Coverage the cooperative provides that private gig platforms do not." />
      <div className="grid md:grid-cols-[2fr_3fr] gap-6 mb-8">
        <Stat lead label="Workers insured" value={`${pct(w.insured, w.total)}%`} hint={`${w.insured} of ${w.total} workers`} />
        <div className="grid grid-cols-2 gap-6 content-center border-l border-line pl-6">
          <Stat label="Accident cover" value={`${pct(w.accident_cover, w.total)}%`} />
          <Stat label="Cooperative members" value={`${pct(w.members, w.total)}%`} />
        </div>
      </div>
      <Card title="Coverage per society"><Table head={["Society", "Workers", "Insured", "Accident cover", "Members"]}
        rows={w.per_coop.map((c) => [<span key="n" className="font-medium">{c.coop}</span>, <span key="t" className="tnum">{c.total}</span>, <Cov key="i" a={c.insured} b={c.total} />, <Cov key="a" a={c.accident_cover} b={c.total} />, <Cov key="m" a={c.members} b={c.total} />])} /></Card>
      <Footer>Welfare flags are set per worker by the society and shown to customers in the app.</Footer>
    </>
  );
}
