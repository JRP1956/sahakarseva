export type FRow = { date: string; service: string; area: string; predicted: number; available_workers: number; shortage: number };

export default function ForecastBars({ rows }: { rows: FRow[] }) {
  const max = Math.max(1, ...rows.map((r) => Math.max(r.predicted, r.available_workers)));
  return (
    <div className="space-y-2">
      {rows.map((r, i) => (
        <div key={i} className="grid grid-cols-[8rem_1fr_7rem] items-center gap-3 text-sm">
          <span className="truncate">{r.service}</span>
          <div className="relative h-5 bg-sunken rounded-sm" role="img" aria-label={`${r.service}: ${r.predicted.toFixed(0)} predicted, ${r.available_workers} available`}>
            <div className="absolute h-5 rounded-sm bg-selected" style={{ width: `${(r.available_workers / max) * 100}%` }} />
            <div className={`absolute h-2 top-1.5 rounded-sm ${r.shortage ? "bg-error-icon" : "bg-primary"}`} style={{ width: `${(r.predicted / max) * 100}%` }} />
          </div>
          <span className="text-right tnum">{r.predicted.toFixed(0)} <span className="text-fg-2">/ {r.available_workers}</span>{r.shortage > 0 && <span className="text-error-fg font-medium ml-2">short {r.shortage}</span>}</span>
        </div>
      ))}
    </div>
  );
}
