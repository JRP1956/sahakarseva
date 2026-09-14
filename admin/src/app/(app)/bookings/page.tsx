import { Zap } from "@/components/icons";
import { Badge, Card, Filters, Footer, PageHeader, Table } from "@/components/ui";
import { apiFetch, fmtDate, inr } from "@/lib/api";

const STATUSES = ["", "requested", "assigned", "accepted", "in_progress", "completed", "paid", "rated", "cancelled"];
type B = { id: number; service_name: string; status: string; address: string; scheduled_at: string; is_emergency: boolean; customer_price: string;
  worker_wage: string; customer: { name: string }; worker: { name: string; coop_name: string } | null };

export default async function Bookings({ searchParams }: { searchParams: Promise<{ status?: string }> }) {
  const { status = "" } = await searchParams;
  const bs = await apiFetch<B[]>(`/admin/bookings${status ? `?status=${status}` : ""}`);
  return (
    <>
      <PageHeader title="Bookings" sub={`${bs.length} ${status ? status.replace("_", " ") : "total"}`} />
      <Filters items={STATUSES} current={status} href={(s) => (s ? `/bookings?status=${s}` : "/bookings")} />
      <Card><Table empty={`No ${status.replace("_", " ")} bookings right now.`} head={["#", "Service", "Customer", "Worker", "When", "Price / wage", "Status"]} rows={bs.map((b) => [
        <span key="i" className="tnum text-fg-2">{b.id}</span>,
        <span key="s" className="font-medium inline-flex items-center gap-2">{b.service_name}{b.is_emergency && <Badge tone="error"><Zap />Emergency</Badge>}</span>, b.customer.name,
        b.worker ? `${b.worker.name}, ${b.worker.coop_name.replace(" Labour Cooperative Society", "")}` : <span className="text-fg-3">Unassigned</span>,
        <span key="w">{fmtDate(b.scheduled_at)}<div className="text-xs text-fg-2">{b.address}</div></span>,
        <span key="p" className="tnum">{inr(b.customer_price)} <span className="text-fg-2">/ {inr(b.worker_wage)}</span></span>,
        <Badge key="b" tone={b.status}>{b.status.replace("_", " ")}</Badge>])} /></Card>
      <Footer>Price is what the customer pays; wage is the worker's 80% share. Emergency bookings are priced at 1.5x.</Footer>
    </>
  );
}
