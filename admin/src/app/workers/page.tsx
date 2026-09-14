import { revalidatePath } from "next/cache";
import { Badge, Card, Check, H1, Table } from "@/components/ui";
import { apiFetch } from "@/lib/api";

type W = { id: number; name: string; phone: string; coop_name: string; area: string; skills: string[]; rating_avg: number; rating_count: number;
  jobs_this_week: number; is_available: boolean; has_insurance: boolean; has_accident_cover: boolean; is_coop_member: boolean;
  certifications: { id: number; name: string; verified: boolean }[] };

async function verify(fd: FormData) {
  "use server";
  await apiFetch(`/admin/workers/${fd.get("w")}/certifications/${fd.get("c")}/verify`, { method: "POST" });
  revalidatePath("/workers");
}

export default async function Workers() {
  const ws = await apiFetch<W[]>("/admin/workers");
  return (
    <>
      <H1>Workers ({ws.length})</H1>
      <Card>
        <Table head={["Name", "Society", "Skills", "Rating", "Jobs/wk", "Welfare", "Certifications"]} rows={ws.map((w) => [
          <div key="n"><div className="font-medium">{w.name}</div><div className="text-xs text-gray-500">{w.phone} · {w.is_available ? <Badge tone="bg-emerald-100 text-emerald-800">available</Badge> : <Badge>offline</Badge>}</div></div>,
          w.area,
          w.skills.join(", "),
          `⭐ ${w.rating_avg} (${w.rating_count})`,
          w.jobs_this_week,
          <div key="w"><Check on={w.has_insurance} label="Insured" /><Check on={w.has_accident_cover} label="Accident" /><Check on={w.is_coop_member} label="Member" /></div>,
          <div key="c" className="space-y-1">{w.certifications.map((c) => (
            <div key={c.id} className="flex items-center gap-2">{c.name}{c.verified ? <Badge tone="bg-emerald-100 text-emerald-800">verified</Badge> :
              <form action={verify}><input type="hidden" name="w" value={w.id} /><input type="hidden" name="c" value={c.id} /><button className="text-xs text-emerald-700 underline">Verify</button></form>}</div>))}</div>,
        ])} />
      </Card>
    </>
  );
}
