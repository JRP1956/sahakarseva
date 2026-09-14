# admin/CLAUDE.md

Next.js **16** (App Router, TypeScript, Tailwind v4) · react-leaflet · no state library, no component library.
Read the root `CLAUDE.md` first.

## Run

```bash
npm install
npm run dev              # http://localhost:3000 — backend must be on :8000 (or set API_URL in .env.local)
npx next build           # must pass before committing
```
Login `9999999999` / `pass123` (only `role == "admin"` accounts are accepted).

## How it works

- **Auth:** `POST /api/login` (route handler) forwards to FastAPI `/auth/login`, rejects non-admins, stores the
  15-minute access token in an `httpOnly` cookie `token`. `src/proxy.ts` (Next 16's middleware) redirects to `/login`
  when the cookie is missing. `POST /api/logout` clears it. No refresh — re-login if a demo runs long
  (`ponytail:` comment in `route.ts`).
- **Data fetching:** every page is a **server component** calling `apiFetch<T>(path)` from `src/lib/api.ts`, which
  reads the cookie via `await cookies()` and hits FastAPI with `cache: "no-store"`. Throws on non-2xx (Next shows
  the error boundary). No client-side fetching except the two buttons below.
- **Mutations:** cert Verify is a **server action** (`verify()` in `workers/page.tsx` + `revalidatePath`).
  Run-forecast is a client button posting to `/api/forecast-run` then `router.refresh()`.
- **Map:** `DemandMap.tsx` is a client component; `MapClient.tsx` wraps it in `next/dynamic({ ssr: false })`
  because Leaflet touches `window`. Leaflet CSS is imported in `layout.tsx`. Tiles from OSM (no key).
- **Charts:** none — `ForecastBars.tsx` is CSS bars (light = available workers, dark = predicted, red when shortage).
- **UI primitives:** `components/ui.tsx` — `Card`, `Tile`, `Table(head, rows)`, `Badge(tone=status)`, `Check`, `H1`.
  Use them; don't add shadcn.
- **Styling:** `globals.css` is light-only on purpose (dark `prefers-color-scheme` broke the browser-pane screenshots).
  Palette: emerald-900 sidebar, emerald-700 primary, gray-50 background.

## Pages → endpoints

| Route | Endpoints |
|---|---|
| `/` | `/admin/stats`, `/admin/demand-map`, `/admin/forecast` (Andheri/tomorrow slice + top 6 recommendations) |
| `/workers` | `/admin/workers`, `POST /admin/workers/{id}/certifications/{cid}/verify` |
| `/customers` | `/admin/customers` |
| `/bookings?status=` | `/admin/bookings?status=` |
| `/cooperatives` | `/admin/cooperatives` (tree) |
| `/services` | `/admin/services` |
| `/payments` | `/admin/payments` (settlements per society + recent) |
| `/welfare` | `/admin/welfare` |
| `/forecast?date=` | `/admin/forecast`, `POST /api/forecast-run` → `/admin/forecast/run` |

## Adding a page

1. `src/app/<name>/page.tsx` — `export default async function X() { const d = await apiFetch<T>("/admin/…"); return <>…</> }`
2. Add `["/<name>", "Label"]` to `NAV` in `layout.tsx`.
3. `searchParams` is a Promise in Next 16: `const { q } = await searchParams`.
4. Types: declare a local `type` for the response shape at the top of the page; there is no shared types file
   (YAGNI until two pages need the same type).

## Gotchas

- `apiFetch` must only be called server-side (it uses `next/headers`). For client components go through a
  `/api/*` route handler like `forecast-run`.
- Leaflet in dev double-renders under React strict mode; harmless.
- `.env.local` (`API_URL`) is git-ignored; the default is `http://localhost:8000/api/v1`.
