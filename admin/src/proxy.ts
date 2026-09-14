import { NextRequest, NextResponse } from "next/server";

const API = process.env.API_URL ?? "http://localhost:8000/api/v1";
export const TOKEN_COOKIE = { httpOnly: true, sameSite: "lax" as const, path: "/", maxAge: 14 * 60 }; // browser drops it before the 15-min JWT dies

export async function proxy(req: NextRequest) {
  const { pathname } = req.nextUrl;
  if (pathname.startsWith("/login") || pathname.startsWith("/api/")) return NextResponse.next();
  if (req.cookies.get("token")) return NextResponse.next();
  // access token gone: swap it using the 30-day refresh token, before the page renders
  const refresh = req.cookies.get("refresh")?.value;
  const r = refresh && await fetch(`${API}/auth/refresh`, { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify({ refresh_token: refresh }) });
  if (!r || !r.ok) return NextResponse.redirect(new URL("/login", req.url));
  const { access_token } = await r.json();
  req.cookies.set("token", access_token); // so this request's server components see the new token
  const res = NextResponse.next({ request: { headers: req.headers } });
  res.cookies.set("token", access_token, TOKEN_COOKIE);
  return res; // the refresh cookie stays; the backend does not rotate it
}

export const config = { matcher: ["/((?!_next|favicon.ico).*)"] };
