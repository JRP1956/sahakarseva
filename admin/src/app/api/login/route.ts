import { NextResponse } from "next/server";
import { API } from "@/lib/api";

export async function POST(req: Request) {
  const body = await req.json();
  const r = await fetch(`${API}/auth/login`, { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify(body) });
  if (!r.ok) return NextResponse.json({ error: "Invalid credentials" }, { status: 401 });
  const data = await r.json();
  if (data.role !== "admin") return NextResponse.json({ error: "Admin account required" }, { status: 403 });
  const res = NextResponse.json({ ok: true });
  // ponytail: 15-min access token only; add refresh when a demo session outlives it
  res.cookies.set("token", data.access_token, { httpOnly: true, sameSite: "lax", path: "/" });
  return res;
}
