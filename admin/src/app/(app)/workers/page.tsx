import { revalidatePath } from "next/cache";
import { Star } from "@/components/icons";
import { Badge, Card, Check, Footer, PageHeader, Table, btn } from "@/components/ui";
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
  const pending = ws.reduce((n, w) => n + w.certifications.filter((c) => !c.verified).length, 0);
  return (
    <>
      <PageHeader title="Workers" sub={`${ws.length} registered across ${new Set(ws.map((w) => w.coop_name)).size} societies. ${pending} certification${pending === 1 ? "" : "s"} awaiting verification.`} />
      <Card>
        <Table head={["Name", "Area", "Skills", "Rating", "Jobs this week", "Welfare", "Certifications"]} rows={ws.map((w) => [
          <div key="n"><div className="font-medium">{w.name}</div><div className="text-xs text-fg-2 mt-0.5 flex items-center gap-2">{w.phone}{w.is_available ? <Badge tone="success">Available</Badge> : <Badge>Offline</Badge>}</div></div>,
          w.area,
          w.skills.join(", "),
          <span key="r" className="inline-flex items-center gap-1 tnum"><span className="text-warning-icon"><Star /></span>{w.rating_avg} <span className="text-fg-2">({w.rating_count})</span></span>,
          <span key="j" className="tnum">{w.jobs_this_week}</span>,
          <div key="w" className="whitespace-nowrap"><Check on={w.has_insurance} label="Insured" /><Check on={w.has_accident_cover} label="Accident" /><Check on={w.is_coop_member} label="Member" /></div>,
          <div key="c" className="space-y-1">{w.certifications.map((c) => (
            <div key={c.id} className="flex items-center gap-2">{c.name}{c.verified ? <Badge tone="success">Verified</Badge> :
              <form action={verify}><input type="hidden" name="w" value={w.id} /><input type="hidden" name="c" value={c.id} /><button className={btn.link}>Verify</button></form>}</div>))}</div>,
        ])} />
      </Card>
      <Footer>Rating is the running average of customer ratings. Jobs this week counts assigned or later bookings scheduled in the current week.</Footer>
    </>
  );
}
