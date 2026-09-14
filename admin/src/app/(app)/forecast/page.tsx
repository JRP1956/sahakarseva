import ForecastBars, { FRow } from "@/components/ForecastBars";
import RunForecastButton from "@/components/RunForecastButton";
import { Alert } from "@/components/icons";
import { Card, Empty, Filters, Footer, PageHeader, Stat } from "@/components/ui";
import { apiFetch } from "@/lib/api";

type F = { rows: FRow[]; recommendations: string[]; generated_at: string | null };
const day = (d: string) => new Date(d).toLocaleDateString("en-IN", { weekday: "short", day: "numeric", month: "short" });

export default async function Forecast({ searchParams }: { searchParams: Promise<{ date?: string }> }) {
  const f = await apiFetch<F>("/admin/forecast");
  const dates = [...new Set(f.rows.map((r) => r.date))];
  const { date = dates[0] } = await searchParams;
  const areas = [...new Set(f.rows.map((r) => r.area))];
  const todays = f.rows.filter((r) => r.date === date);
  const short = todays.reduce((n, r) => n + r.shortage, 0);
  return (
    <>
      <PageHeader title="AI demand forecast" action={<RunForecastButton />}
        sub={`XGBoost on 18 months of booking history. ${f.generated_at ? `Generated ${new Date(f.generated_at).toLocaleString("en-IN")}.` : "Not run yet."}`} />
      {dates.length === 0 ? (
        <Card><Empty>No forecast has been generated yet. Run the 7-day forecast to see predicted demand and worker shortages per area.</Empty></Card>
      ) : (
        <>
          <Filters items={dates} current={date} href={(d) => `/forecast?date=${d}`} label={day} />
          <div className="grid md:grid-cols-[2fr_3fr] gap-6 mb-8">
            <Stat lead label={`Worker shortage, ${day(date)}`} value={short} hint={`across ${todays.filter((r) => r.shortage > 0).length} service and area cells`} />
            <div className="grid grid-cols-2 gap-6 content-center border-l border-line pl-6">
              <Stat label="Predicted jobs" value={Math.round(todays.reduce((n, r) => n + r.predicted, 0))} />
              <Stat label="Available workers" value={todays.reduce((n, r) => n + r.available_workers, 0)} />
            </div>
          </div>
          <div className="grid md:grid-cols-2 gap-6 mb-6">
            {areas.map((a) => <Card key={a} title={a}><ForecastBars rows={todays.filter((r) => r.area === a)} /></Card>)}
          </div>
          <Card title={`Workforce recommendations (${f.recommendations.length})`}>
            {f.recommendations.length ? (
              <ol className="divide-y divide-line md:columns-2 md:gap-10">{f.recommendations.map((r) => <li key={r} className="py-2 text-sm flex gap-2 break-inside-avoid"><span className="text-warning-icon shrink-0 mt-0.5"><Alert /></span>{r}</li>)}</ol>
            ) : <p className="text-sm text-fg-2">Supply covers predicted demand everywhere this week.</p>}
          </Card>
          <Footer>Light bar: available workers. Dark bar: predicted demand. Shortage is predicted demand minus available workers, never below zero.</Footer>
        </>
      )}
    </>
  );
}
