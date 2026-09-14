import ForecastBars, { FRow } from "@/components/ForecastBars";
import RunForecastButton from "@/components/RunForecastButton";
import { Card, H1 } from "@/components/ui";
import { apiFetch } from "@/lib/api";

type F = { rows: FRow[]; recommendations: string[]; generated_at: string | null };

export default async function Forecast({ searchParams }: { searchParams: Promise<{ date?: string }> }) {
  const f = await apiFetch<F>("/admin/forecast");
  const dates = [...new Set(f.rows.map((r) => r.date))];
  const { date = dates[0] } = await searchParams;
  const areas = [...new Set(f.rows.map((r) => r.area))];
  return (
    <>
      <div className="flex items-center justify-between mb-6">
        <div><h1 className="text-2xl font-semibold">AI demand forecast</h1>
          <p className="text-sm text-gray-500">XGBoost on 18 months of booking history · {f.generated_at ? `generated ${new Date(f.generated_at).toLocaleString("en-IN")}` : "not run yet"}</p></div>
        <RunForecastButton />
      </div>
      {dates.length > 0 && (
        <>
          <div className="flex gap-2 mb-4 flex-wrap">{dates.map((d) => (
            <a key={d} href={`/forecast?date=${d}`} className={`text-sm px-3 py-1 rounded-full border ${d === date ? "bg-emerald-700 text-white" : "bg-white"}`}>
              {new Date(d).toLocaleDateString("en-IN", { weekday: "short", day: "numeric", month: "short" })}</a>))}</div>
          <div className="grid md:grid-cols-2 gap-4 mb-6">
            {areas.map((a) => <Card key={a} title={a}><ForecastBars rows={f.rows.filter((r) => r.date === date && r.area === a)} /></Card>)}
          </div>
          <p className="text-xs text-gray-500 mb-6">Light bar: available workers · dark bar: predicted demand · ▲ shortage</p>
          <Card title={`Workforce recommendations (${f.recommendations.length})`}>
            <ul className="space-y-1 text-sm columns-2">{f.recommendations.map((r) => <li key={r}>⚠ {r}</li>)}</ul>
          </Card>
        </>
      )}
    </>
  );
}
