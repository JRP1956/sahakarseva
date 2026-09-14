import { cookies } from "next/headers";

export const API = process.env.API_URL ?? "http://localhost:8000/api/v1";

export async function token() {
  return (await cookies()).get("token")?.value;
}

export async function apiFetch<T>(path: string, init: RequestInit = {}): Promise<T> {
  const t = await token();
  const res = await fetch(`${API}${path}`, {
    ...init,
    cache: "no-store",
    headers: { "content-type": "application/json", ...(t ? { authorization: `Bearer ${t}` } : {}), ...(init.headers ?? {}) },
  });
  if (!res.ok) throw new Error(`${path} → ${res.status} ${await res.text()}`);
  return res.json();
}

export const inr = (n: number | string) => "₹" + Number(n).toLocaleString("en-IN", { maximumFractionDigits: 0 });
export const fmtDate = (s: string) => new Date(s).toLocaleString("en-IN", { day: "2-digit", month: "short", hour: "2-digit", minute: "2-digit" });
