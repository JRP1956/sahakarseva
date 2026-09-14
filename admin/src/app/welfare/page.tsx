import { Card, H1, Table, Tile } from "@/components/ui";
import { apiFetch } from "@/lib/api";

type Wf = { total: number; insured: number; accident_cover: number; members: number; per_coop: { coop: string; total: number; insured: number; accident_cover: number; members: number }[] };
const pct = (a: number, b: number) => `${a} (${b ? Math.round((a / b) * 100) : 0}%)`;

export default async function Welfare() {
  const w = await apiFetch<Wf>("/admin/welfare");
  return (
    <>
      <H1>Worker welfare</H1>
      <div className="grid grid-cols-4 gap-4 mb-6">
        <Tile label="Workers" value={w.total} /><Tile label="Insured" value={pct(w.insured, w.total)} />
        <Tile label="Accident cover" value={pct(w.accident_cover, w.total)} /><Tile label="Cooperative members" value={pct(w.members, w.total)} />
      </div>
      <Card title="Coverage per society"><Table head={["Society", "Workers", "Insured", "Accident cover", "Members"]}
        rows={w.per_coop.map((c) => [c.coop, c.total, pct(c.insured, c.total), pct(c.accident_cover, c.total), pct(c.members, c.total)])} /></Card>
    </>
  );
}
