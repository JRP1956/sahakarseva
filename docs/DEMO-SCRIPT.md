# Demo script (≈5 minutes)

Accounts — password for all: `pass123`
- Federation admin `9999999999` → http://localhost:3000
- Customer `9100000000` (Rahul Gaikwad) → mobile app
- Worker `9800000001` (Ganesh Kumar, Andheri LCS, plumber) → mobile app

Have the admin open on the laptop and the app on a phone/emulator (or a second browser window at 390×844).

## 0. Setup (before judges arrive)
Reseed (see `DEVELOPMENT.md`), run the forecast in admin, log both apps in.

## 1. The problem → the federation view (admin, 60 s)
- **Dashboard:** "1 federation, 5 societies, 60 workers, 50 available. Every pin on this map is a real
  booking from the last 30 days — blue open, green paid, red emergency."
- Point at the **AI workforce forecast** panel: "The model already says Andheri is short 1 electrician and
  1 cleaner tomorrow. We'll come back to this."

## 2. Customer books a plumber (app, 90 s)
- Home → tap **Plumbing** → "Address, pin on the map, when. Notice the price is transparent *before* booking:
  ₹500 to us, ₹400 to the worker, ₹100 to the cooperative fund. No hidden commission."
- **Find workers** → matched list: "Four verified plumbers from Andheri and Bandra societies. Look at #1 and #2:
  Prakash is closer — 0.96 km vs 1.5 km — but Ganesh has done 1 job this week and Prakash 10. Our fair-workload
  factor ranks Ganesh first. A private platform would always send Prakash."
- Show badges: **Insured · Accident cover · Co-op member**. → **Choose** Ganesh → timeline shows *Worker assigned*.

## 3. Worker accepts and completes (app as Ganesh, 60 s)
- Sign out → sign in as `9800000001`. **Jobs:** the request shows **Estimated earnings ₹400** before accepting.
  → **Accept**.
- **Bookings** tab → **Start job** → **Mark complete**. "The invoice is generated at this moment."
- **Profile:** welfare card, verified certification, skills. **Earnings:** month total.
- Optional: toggle the **Available** switch — "he disappears from matching instantly."

## 4. Customer pays and rates (app as customer, 30 s)
- Sign back in → booking → **Pay ₹500** (Razorpay test mode / demo) → **Rate** 5★ → *Rated* → **View invoice**
  shows the 80/20 split.

## 5. Back to the federation (admin, 60 s)
- **Bookings** filter *rated* — the new booking is there. **Payments:** Andheri society's settlement grew by
  ₹100 cooperative contribution and ₹400 worker wages.
- **AI Forecast → Run 7-day forecast:** "XGBoost on 18 months of history, per service per area. Light bar =
  available workers, dark = predicted demand. Every red triangle becomes a sentence the federation can act on:
  *'2 additional cleaning workers recommended in Bandra on Tuesday.'* That is workforce planning, not surge pricing."
- **Welfare:** coverage percentages per society. "This is what makes it a cooperative platform."

## 6. Close (15 s)
"Three interfaces, one backend, PostGIS for matching, XGBoost for planning, and every rupee visible to the
worker. Built for Labour Cooperative Federations to run themselves."

## Emergency demo variant (if asked)
Home → red **Emergency** button → pick a service → the app skips the match screen: top-scored worker is
auto-assigned at 1.5× price. Show the ⚡ badge in the admin bookings table.

## If something breaks
- No workers matched → pin was moved too far; re-open Plumbing (default pin is Andheri).
- 401 in admin → session expired (15 min); sign in again.
- Forecast empty → click **Run 7-day forecast**.
- App stuck on a stale list → switch tabs (refetches) or pull to refresh on Home.
