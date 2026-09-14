import { Card, Footer, PageHeader } from "@/components/ui";
import { apiFetch } from "@/lib/api";

type C = { id: number; name: string; area: string; workers: number; children: C[] };
const Node = ({ c, depth = 0 }: { c: C; depth?: number }) => (
  <li>
    <div className={`flex items-baseline justify-between gap-4 py-3 border-b border-line ${depth === 0 ? "" : "pl-8"}`}>
      <div><span className={depth === 0 ? "text-lg font-semibold" : "font-medium"}>{c.name}</span><span className="text-fg-2 text-sm ml-2">{c.area}</span></div>
      <span className="tnum text-sm text-fg-2 whitespace-nowrap">{c.workers} workers</span>
    </div>
    {c.children.length > 0 && <ul>{c.children.map((ch) => <Node key={ch.id} c={ch} depth={depth + 1} />)}</ul>}
  </li>
);

export default async function Cooperatives() {
  const cs = await apiFetch<C[]>("/admin/cooperatives");
  const total = (c: C): number => c.workers + c.children.reduce((n, x) => n + total(x), 0);
  return (<>
    <PageHeader title="Cooperatives" sub={`${cs.length} federation${cs.length === 1 ? "" : "s"}, ${cs.reduce((n, c) => n + c.children.length, 0)} member societies, ${cs.reduce((n, c) => n + total(c), 0)} workers`} />
    <Card><ul className="-mt-3">{cs.map((c) => <Node key={c.id} c={c} />)}</ul></Card>
    <Footer>Societies are indented under the federation they belong to.</Footer>
  </>);
}
