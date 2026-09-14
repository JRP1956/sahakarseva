"use client";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { Loader } from "@/components/icons";
import { btn } from "@/components/ui";

const INPUT = "block w-full h-10 px-3 rounded-input bg-input-bg border border-input-border text-fg placeholder:text-fg-3 hover:border-line-strong focus:border-input-border-focus focus:outline-none focus-visible:shadow-focus transition-colors";

export default function Login() {
  const r = useRouter();
  const [phone, setPhone] = useState("9999999999");
  const [password, setPassword] = useState("pass123");
  const [err, setErr] = useState("");
  const [busy, setBusy] = useState(false);
  async function submit(e: React.FormEvent) {
    e.preventDefault(); setBusy(true); setErr("");
    const res = await fetch("/api/login", { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify({ phone, password }) });
    if (res.ok) r.push("/"); else { setErr((await res.json()).error ?? "Sign in failed. Check the phone number and password."); setBusy(false); }
  }
  return (
    <main className="min-h-screen grid lg:grid-cols-[5fr_7fr]">
      <section className="hidden lg:flex flex-col justify-between bg-primary text-on-action p-12">
        <div className="font-semibold tracking-tight">SahakarSeva</div>
        <div>
          <h2 className="text-5xl font-semibold tracking-tight leading-none max-w-[14ch]">Cooperative work, fairly shared.</h2>
          <p className="mt-6 max-w-md opacity-80">Federation view of every society, worker, booking and settlement. Wages split 80/20, matching by fair workload, demand forecast seven days out.</p>
        </div>
        <div className="text-xs opacity-70">Ministry of Cooperation, NCCT. SIH 2026, PS 26089.</div>
      </section>
      <section className="flex flex-col justify-start lg:justify-center px-6 pt-20 pb-12 lg:px-24 lg:py-16">
        <form onSubmit={submit} className="w-full max-w-sm space-y-5" aria-busy={busy}>
          <div><h1 className="text-2xl font-semibold tracking-tight">Sign in</h1><p className="text-sm text-fg-2 mt-1">Federation administrators only.</p></div>
          <label className="block text-sm"><span className="text-fg-2">Phone</span>
            <input className={`${INPUT} mt-1`} value={phone} onChange={(e) => setPhone(e.target.value)} autoComplete="username" inputMode="tel" /></label>
          <label className="block text-sm"><span className="text-fg-2">Password</span>
            <input className={`${INPUT} mt-1${err ? " border-error-icon" : ""}`} type="password" value={password} onChange={(e) => setPassword(e.target.value)} autoComplete="current-password" /></label>
          {err && <p role="alert" className="text-sm text-error-fg">{err}</p>}
          <button className={`${btn.primary} w-full h-10`} disabled={busy} aria-busy={busy}>{busy && <Loader />}{busy ? "Signing in" : "Sign in"}</button>
        </form>
      </section>
    </main>
  );
}
