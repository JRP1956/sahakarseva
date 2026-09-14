import Link from "next/link";
import MapClient from "@/components/MapClient";
import ForecastBars, { FRow } from "@/components/ForecastBars";
import { Card, H1, Tile } from "@/components/ui";
import { apiFetch, inr } from "@/lib/api";
import type { Point } from "@/components/DemandMap";

type Stats = { workers: number; active_workers: number; customers: number; todays_jobs: number; bookings_by_status: Record<string, number>; revenue_coop: number };
type Forecast = { rows: FRow[]; recommendations: string[]; generated_at: string | null };

export default async function Dashboard() {
  const [stats, points, fc] = await Promise.all([apiFetch<Stats>("/admin/stats"), apiFetch<Point[]>("/admin/demand-map"), apiFetch<Forecast>("/admin/forecast")]);
  const tomorrow = fc.rows.length ? fc.rows.filter((r) => r.date === fc.rows[0].date && r.area === "Andheri") : [];
  return (
    <>
      <H1>Mumbai Labour Cooperative Federation</H1>
      <div className="grid grid-cols-2 md:grid-cols-5 gap-4 mb-6">
        <Tile label="Workers" value={stats.workers} />
        <Tile label="Available now" value={stats.active_workers} />
        <Tile label="Today's jobs" value={stats.todays_jobs} />
        <Tile label="In progress" value={stats.bookings_by_status.in_progress ?? 0} />
        <Tile label="Cooperative income" value={inr(stats.revenue_coop)} />
      </div>
      <div className="grid lg:grid-cols-[2fr_1fr] gap-4">
        <Card title="Service demand map (last 30 days)"><MapClient points={points} />
          <p className="text-xs text-gray-500 mt-2">● blue: open · ● green: paid/rated · ● red: emergency</p></Card>
        <Card title="AI workforce forecast — Andheri, tomorrow">
          {tomorrow.length ? <ForecastBars rows={tomorrow} /> : <p className="text-sm text-gray-500">No forecast yet.</p>}
          <ul className="mt-4 space-y-1 text-sm">
            {fc.recommendations.slice(0, 6).map((r) => <li key={r} className="text-red-700">⚠ {r}</li>)}
          </ul>
          <Link href="/forecast" className="text-emerald-700 text-sm underline mt-3 inline-block">Full forecast →</Link>
        </Card>
      </div>
    </>
  );
}
