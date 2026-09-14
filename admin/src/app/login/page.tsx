"use client";
import { useRouter } from "next/navigation";
import { useState } from "react";

export default function Login() {
  const r = useRouter();
  const [phone, setPhone] = useState("9999999999");
  const [password, setPassword] = useState("pass123");
  const [err, setErr] = useState("");
  async function submit(e: React.FormEvent) {
    e.preventDefault();
    const res = await fetch("/api/login", { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify({ phone, password }) });
    if (res.ok) r.push("/"); else setErr((await res.json()).error);
  }
  return (
    <main className="min-h-screen grid place-items-center bg-emerald-50">
      <form onSubmit={submit} className="bg-white p-8 rounded-xl shadow w-80 space-y-4">
        <h1 className="text-xl font-semibold">Federation Admin</h1>
        <p className="text-sm text-gray-500">Cooperative Gig Services Platform</p>
        <input className="border rounded w-full p-2" value={phone} onChange={(e) => setPhone(e.target.value)} placeholder="Phone" />
        <input className="border rounded w-full p-2" type="password" value={password} onChange={(e) => setPassword(e.target.value)} placeholder="Password" />
        {err && <p className="text-red-600 text-sm">{err}</p>}
        <button className="w-full bg-emerald-700 text-white rounded p-2">Sign in</button>
      </form>
    </main>
  );
}
