import { Card, H1, Table } from "@/components/ui";
import { apiFetch, fmtDate, inr } from "@/lib/api";

type P = { settlements: { coop: string; jobs: number; worker_wages: number; coop_contribution: number }[];
  recent: { booking_id: number; service: string; worker: string; coop: string; customer_price: string; worker_wage: string; coop_contribution: string; date: string }[] };

export default async function Payments() {
  const p = await apiFetch<P>("/admin/payments");
  return (
    <>
      <H1>Payments & settlements</H1>
      <Card title="Settlement per society (paid bookings)" className="mb-4">
        <Table head={["Society", "Jobs", "Worker wages (80%)", "Cooperative contribution (20%)"]} rows={p.settlements.map((s) => [s.coop, s.jobs, inr(s.worker_wages), inr(s.coop_contribution)])} />
      </Card>
      <Card title="Recent payments">
        <Table head={["#", "Service", "Worker", "Date", "Customer paid", "Worker", "Cooperative"]} rows={p.recent.map((r) => [r.booking_id, r.service, r.worker, fmtDate(r.date), inr(r.customer_price), inr(r.worker_wage), inr(r.coop_contribution)])} />
      </Card>
    </>
  );
}
