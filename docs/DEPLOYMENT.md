# Deployment

Target for SIH: **Railway** (backend + Postgres), **Vercel or Railway** (admin), **APK** for the mobile app
(or the Flutter web build hosted as a static site for judges without Android). Nothing is deployed yet; this is
the runbook.

## Backend on Railway

1. New project → **Add PostgreSQL** → in its shell: `CREATE EXTENSION postgis;` (Railway's Postgres image ships
   PostGIS; if not, use the `postgis/postgis` template).
2. **Add service from GitHub** `JRP1956/sahakarseva`, root directory `backend`.
3. Build: Railway detects `pyproject.toml`; set the start command
   `uv run alembic upgrade head && uv run python seed.py && uv run uvicorn app.main:app --host 0.0.0.0 --port $PORT`
   (seed is idempotent; drop it after first boot if you prefer).
4. Variables:

| var | value |
|---|---|
| `DATABASE_URL` | Railway's `postgresql://…` **rewritten to** `postgresql+psycopg://…` |
| `JWT_SECRET` | long random string |
| `DEMO_MARK_PAID` | `true` for the hackathon demo |
| `RAZORPAY_KEY_ID` / `RAZORPAY_KEY_SECRET` | test-mode keys from dashboard.razorpay.com (optional) |
| `UPLOAD_DIR` | `/data/uploads` with a Railway volume mounted at `/data` (else uploads vanish on redeploy) |

5. Verify `https://<app>.railway.app/api/v1/health` → `{"ok":true}` and `/docs`.

CORS is `*` in `main.py`; tighten to the admin origin for anything beyond the demo.

## Admin

- **Vercel:** import the repo, root `admin`, env `API_URL=https://<backend>/api/v1`. Next 16 builds as-is.
- **Railway:** same, start command `npm run build && npm start`, `PORT` provided.
- Cookie is `sameSite=lax`, not `secure` — set `secure: true` in `src/app/api/login/route.ts` when on HTTPS.

## Mobile

### Android APK
```bash
flutter doctor --android-licenses
cd mobile
flutter build apk --release --dart-define=API_URL=https://<backend>/api/v1
# → build/app/outputs/flutter-apk/app-release.apk
```
Android blocks cleartext HTTP by default — use the HTTPS backend URL, or add
`android:usesCleartextTraffic="true"` to `AndroidManifest.xml` for LAN testing.

### Web build (fallback for judges)
```bash
flutter build web --release --dart-define=API_URL=https://<backend>/api/v1
# → build/web — host on Vercel/Netlify/Railway static; add a phone-frame wrapper page if desired
```

### Razorpay (optional, Android only)
1. `flutter pub add razorpay_flutter`.
2. In `booking_detail.dart` replace the demo-pay button when `!kIsWeb`: call `POST /payments/create-order`,
   open Razorpay checkout with `key_id`, `order_id`, `amount`, then `POST /payments/verify` with the returned
   `razorpay_payment_id` + `razorpay_signature`.
3. Set the keys on the backend; set `DEMO_MARK_PAID=false` to hide the shortcut.

## Local Docker (backend only)

There is no Dockerfile yet. Minimal one if needed:
```dockerfile
FROM python:3.12-slim
RUN pip install uv
WORKDIR /app
COPY backend/ .
RUN uv sync --frozen --no-dev
CMD ["uv","run","uvicorn","app.main:app","--host","0.0.0.0","--port","8000"]
```

## Checklist before a live demo

- [ ] Backend `/health` OK, `/docs` loads
- [ ] Seed present (`GET /services` returns 8)
- [ ] Forecast run once (`/admin/forecast` non-empty)
- [ ] Admin login works, map tiles load (OSM needs outbound internet)
- [ ] Mobile pointed at the deployed `API_URL`
- [ ] A fresh booking at Andheri returns ≥ 3 plumbers (fair-workload story)
- [ ] Backup: `docs/DEMO-SCRIPT.md` screenshots on the laptop
