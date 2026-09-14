import { Card, H1 } from "@/components/ui";
import { apiFetch } from "@/lib/api";

type C = { id: number; name: string; area: string; workers: number; children: C[] };
const Node = ({ c, depth = 0 }: { c: C; depth?: number }) => (
  <div style={{ marginLeft: depth * 24 }} className="py-2 border-b last:border-0">
    <span className="font-medium">{c.name}</span> <span className="text-gray-500 text-sm">· {c.area} · {c.workers} workers</span>
    {c.children.map((ch) => <Node key={ch.id} c={ch} depth={depth + 1} />)}
  </div>
);

export default async function Cooperatives() {
  const cs = await apiFetch<C[]>("/admin/cooperatives");
  return (<><H1>Cooperatives</H1><Card>{cs.map((c) => <Node key={c.id} c={c} />)}</Card></>);
}
