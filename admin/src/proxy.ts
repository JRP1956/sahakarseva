import { NextRequest, NextResponse } from "next/server";

const API = process.env.API_URL ?? "http://localhost:8000/api/v1";
const expSoon = (jwt: string) => {
  try { return JSON.parse(atob(jwt.split(".")[1])).exp * 1000 < Date.now() + 60_000; } catch { return true; }
};

export async function proxy(req: NextRequest) {
  const { pathname } = req.nextUrl;
  if (pathname.startsWith("/login") || pathname.startsWith("/api/")) return NextResponse.next();
  const token = req.cookies.get("token")?.value;
  const refresh = req.cookies.get("refresh")?.value;
  if (!token && !refresh) return NextResponse.redirect(new URL("/login", req.url));
  if (token && !expSoon(token)) return NextResponse.next();
  // access token expired or about to: swap it using the 30-day refresh token, before the page renders
  const r = refresh && await fetch(`${API}/auth/refresh`, { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify({ refresh_token: refresh }) });
  if (!r || !r.ok) {
    const out = NextResponse.redirect(new URL("/login", req.url));
    out.cookies.delete("token"); out.cookies.delete("refresh");
    return out;
  }
  const data = await r.json();
  req.cookies.set("token", data.access_token); // so this request's server components see the new token
  const res = NextResponse.next({ request: { headers: req.headers } });
  res.cookies.set("token", data.access_token, { httpOnly: true, sameSite: "lax", path: "/" });
  return res; // the refresh cookie stays; the backend does not rotate it
}

export const config = { matcher: ["/((?!_next|favicon.ico).*)"] };
