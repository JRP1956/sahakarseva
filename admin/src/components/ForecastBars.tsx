export type FRow = { date: string; service: string; area: string; predicted: number; available_workers: number; shortage: number };

export default function ForecastBars({ rows }: { rows: FRow[] }) {
  const max = Math.max(1, ...rows.map((r) => Math.max(r.predicted, r.available_workers)));
  return (
    <div className="space-y-2">
      {rows.map((r, i) => (
        <div key={i} className="grid grid-cols-[9rem_1fr_7rem] items-center gap-3 text-sm">
          <span>{r.service}</span>
          <div className="relative h-5 bg-gray-100 rounded">
            <div className="absolute h-5 rounded bg-emerald-200" style={{ width: `${(r.available_workers / max) * 100}%` }} />
            <div className={`absolute h-2 top-1.5 rounded ${r.shortage ? "bg-red-500" : "bg-emerald-700"}`} style={{ width: `${(r.predicted / max) * 100}%` }} />
          </div>
          <span className="text-right tabular-nums">
            {r.predicted.toFixed(0)} / {r.available_workers}{r.shortage > 0 && <span className="text-red-600 ml-1">▲{r.shortage}</span>}
          </span>
        </div>
      ))}
    </div>
  );
}
