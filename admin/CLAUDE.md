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
  15-minute access token in cookie `token` and the 30-day refresh token in cookie `refresh` (both `httpOnly`).
  `src/proxy.ts` (Next 16's middleware) runs before every page: no cookies → `/login`; access token expiring within
  60 s → `POST /auth/refresh`, new `token` cookie set on both the response and the in-flight request so server
  components see it; refresh rejected → clear both and `/login`. `POST /api/logout` clears both. The backend does
  not rotate refresh tokens, so the `refresh` cookie is written once at login.
- **Data fetching:** every page is a **server component** calling `apiFetch<T>(path)` from `src/lib/api.ts`, which
  reads the cookie via `await cookies()` and hits FastAPI with `cache: "no-store"`. Throws on non-2xx (Next shows
  the error boundary). No client-side fetching except the two buttons below.
- **Mutations:** cert Verify is a **server action** (`verify()` in `workers/page.tsx` + `revalidatePath`).
  Run-forecast is a client button posting to `/api/forecast-run` then `router.refresh()`.
- **Map:** `DemandMap.tsx` is a client component; `MapClient.tsx` wraps it in `next/dynamic({ ssr: false })`
  because Leaflet touches `window`. Leaflet CSS is imported in `layout.tsx`. Tiles from OSM (no key).
- **Charts:** none — `ForecastBars.tsx` is CSS bars (light = available workers, dark = predicted, red when shortage).
- **UI primitives:** `components/ui.tsx` — `Card`, `Stat(lead)`, `Table(head, rows, empty)`, `Badge(tone=status)`,
  `Check`, `PageHeader`, `Filters`, `Footer`, `Empty`, and the `btn` class map. `components/icons.tsx` holds lucide
  icons as inline SVG. Use them; don't add shadcn, don't add emoji.
- **Styling (design tokens):** `src/app/theme.css` is **generated** from the repo-root `tokens/*.json` by
  `node scripts/build_tokens.mjs --out admin/src/app/theme.css` (then rename `--space-N.5` to `--space-N-5`; Turbopack
  rejects the dot). `globals.css` imports it and maps the semantic vars into Tailwind v4 `@theme inline` names:
  `bg-page`, `bg-card`, `text-fg`, `text-fg-2`, `border-line`, `bg-primary`, `bg-danger`, `bg-success-bg`, etc.
  Never write a hex, px, or Tailwind palette class (`emerald-700`, `gray-50`) in a page; `python3 scripts/lint_hardcodes.py admin/src` must stay clean.
- **Dark mode:** a one-line script in the root `layout.tsx` sets `data-theme` from `prefers-color-scheme`; the token
  layer switches at `[data-theme="dark"]`. Every page must read correctly in both (check with the browser pane).
- **Layout:** pages live in `src/app/(app)/` under a sidebar layout; `/login` sits outside it (full-screen split).
- **Composition rules (from the kit):** one lead element per page (`Stat lead` or the H1), lucide icons only,
  loading keeps the button at full strength (`aria-busy`), tables get `Empty` when rows are `[]`, every page ends
  with a `Footer` line.

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
