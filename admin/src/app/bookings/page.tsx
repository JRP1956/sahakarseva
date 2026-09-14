import Link from "next/link";
import { Badge, Card, H1, Table } from "@/components/ui";
import { apiFetch, fmtDate, inr } from "@/lib/api";

const STATUSES = ["", "requested", "assigned", "accepted", "in_progress", "completed", "paid", "rated", "cancelled"];
type B = { id: number; service_name: string; status: string; address: string; scheduled_at: string; is_emergency: boolean; customer_price: string;
  worker_wage: string; customer: { name: string }; worker: { name: string; coop_name: string } | null };

export default async function Bookings({ searchParams }: { searchParams: Promise<{ status?: string }> }) {
  const { status = "" } = await searchParams;
  const bs = await apiFetch<B[]>(`/admin/bookings${status ? `?status=${status}` : ""}`);
  return (
    <>
      <H1>Bookings ({bs.length})</H1>
      <div className="flex gap-2 mb-4 flex-wrap">{STATUSES.map((s) => (
        <Link key={s} href={s ? `/bookings?status=${s}` : "/bookings"} className={`text-sm px-3 py-1 rounded-full border ${s === status ? "bg-emerald-700 text-white" : "bg-white"}`}>{s || "all"}</Link>))}</div>
      <Card><Table head={["#", "Service", "Customer", "Worker", "When", "Price / Wage", "Status"]} rows={bs.map((b) => [
        b.id, <span key="s">{b.service_name}{b.is_emergency && <Badge tone="bg-red-100 text-red-800"> emergency</Badge>}</span>, b.customer.name,
        b.worker ? `${b.worker.name} · ${b.worker.coop_name.replace(" Labour Cooperative Society", "")}` : "—",
        <span key="w">{fmtDate(b.scheduled_at)}<div className="text-xs text-gray-500">{b.address}</div></span>,
        `${inr(b.customer_price)} / ${inr(b.worker_wage)}`, <Badge key="b" tone={b.status}>{b.status}</Badge>])} /></Card>
    </>
  );
}
