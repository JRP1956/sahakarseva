"use client";
import { useRouter } from "next/navigation";
import { useState } from "react";

export default function RunForecastButton() {
  const r = useRouter();
  const [busy, setBusy] = useState(false);
  return (
    <button disabled={busy} onClick={async () => { setBusy(true); await fetch("/api/forecast-run", { method: "POST" }); r.refresh(); setBusy(false); }}
      className="bg-emerald-700 text-white rounded px-4 py-2 disabled:opacity-50">{busy ? "Training model…" : "Run 7-day forecast"}</button>
  );
}
