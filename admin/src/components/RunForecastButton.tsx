"use client";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { Loader } from "./icons";
import { btn } from "./ui";

export default function RunForecastButton() {
  const r = useRouter();
  const [busy, setBusy] = useState(false);
  return (
    <button aria-busy={busy} disabled={busy} className={btn.primary}
      onClick={async () => { setBusy(true); await fetch("/api/forecast-run", { method: "POST" }); r.refresh(); setBusy(false); }}>
      {busy && <Loader />}{busy ? "Training model" : "Run 7-day forecast"}</button>
  );
}
