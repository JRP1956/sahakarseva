import Link from "next/link";
import MapClient from "@/components/MapClient";
import ForecastBars, { FRow } from "@/components/ForecastBars";
import { Alert, ArrowRight } from "@/components/icons";
import { Card, Footer, PageHeader, Stat, btn } from "@/components/ui";
import { apiFetch, inr } from "@/lib/api";
import type { Point } from "@/components/DemandMap";

type Stats = { workers: number; active_workers: number; customers: number; todays_jobs: number; bookings_by_status: Record<string, number>; revenue_coop: number };
type Forecast = { rows: FRow[]; recommendations: string[]; generated_at: string | null };

export default async function Dashboard() {
  const [stats, points, fc] = await Promise.all([apiFetch<Stats>("/admin/stats"), apiFetch<Point[]>("/admin/demand-map"), apiFetch<Forecast>("/admin/forecast")]);
  const tomorrow = fc.rows.length ? fc.rows.filter((r) => r.date === fc.rows[0].date && r.area === "Andheri") : [];
  const today = new Date().toLocaleDateString("en-IN", { weekday: "long", day: "numeric", month: "long" });
  return (
    <>
      <PageHeader title="Mumbai Labour Cooperative Federation" sub={today} />
      <div className="grid md:grid-cols-[2fr_3fr] gap-6 mb-8">
        <Stat lead label="Jobs today" value={stats.todays_jobs} hint={`${stats.bookings_by_status.in_progress ?? 0} in progress right now`} />
        <div className="grid grid-cols-2 sm:grid-cols-3 gap-6 content-center border-l border-line pl-6">
          <Stat label="Workers" value={stats.workers} />
          <Stat label="Available now" value={stats.active_workers} />
          <Stat label="Customers" value={stats.customers} />
          <Stat label="Cooperative income" value={inr(stats.revenue_coop)} />
          <Stat label="Completed" value={(stats.bookings_by_status.completed ?? 0) + (stats.bookings_by_status.paid ?? 0) + (stats.bookings_by_status.rated ?? 0)} />
          <Stat label="Awaiting worker" value={stats.bookings_by_status.requested ?? 0} />
        </div>
      </div>
      <div className="grid lg:grid-cols-[7fr_5fr] gap-6">
        <Card title="Service demand, last 30 days">
          <MapClient points={points} />
          <p className="text-xs text-fg-2 mt-3">Teal: open. Green: paid or rated. Red: emergency.</p>
        </Card>
        <Card title="Workforce forecast, Andheri, tomorrow" action={<Link href="/forecast" className={btn.link}>Full forecast <ArrowRight /></Link>}>
          {tomorrow.length ? <ForecastBars rows={tomorrow} /> : <p className="text-sm text-fg-2">No forecast yet. Run one from the AI Forecast page.</p>}
          {fc.recommendations.length > 0 && (
            <ol className="mt-6 divide-y divide-line border-t border-line">
              {fc.recommendations.slice(0, 5).map((r) => <li key={r} className="py-2 text-sm flex gap-2"><span className="text-warning-icon shrink-0 mt-0.5"><Alert /></span>{r}</li>)}
            </ol>
          )}
        </Card>
      </div>
      <Footer>Figures are live from the federation database. Forecast {fc.generated_at ? `generated ${new Date(fc.generated_at).toLocaleString("en-IN")}` : "not run yet"}.</Footer>
    </>
  );
}
