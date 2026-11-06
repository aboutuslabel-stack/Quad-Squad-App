# 🥩 QUAD SQUAD — STEAKS DAY 2026 · Handover Brief
_Last updated: 6 Nov 2026 (night before)_

## 🔗 The app (LIVE)
**https://quad-squad-app-production.up.railway.app**
- Open on phone → **tap your name** → "Are you X?" → in. No password. Remembers you on the device.
- Admins (Liam, Blake) also see a **🛠️ Admin** tab.

## 🧱 Infrastructure (all on Liam's accounts)
| Piece | Detail |
|---|---|
| **Hosting** | Railway · project `quad-squad` · service `quad-squad-app` · workspace "Liams Railway" |
| **Deploy flow** | Push to GitHub `main` → Railway auto-builds (`npm install` → `node server.js`, a zero-dep static server) |
| **Code** | GitHub `aboutuslabel-stack/Quad-Squad-App` (branch `main`) |
| **Database** | Supabase project `quad-squad` · ref `odpexghueerscbvdkjjy` · region Sydney · URL `https://odpexghueerscbvdkjjy.supabase.co` |
| **DB key** | anon/publishable `sb_publishable_Fo8aqLCTsxlDLmmTSfy0iA_v5EaHVk2` (public-safe; embedded in the app) |
| **Live working copy** | `/home/user/quad-squad` in this cloud session (**ephemeral** — source of truth is GitHub/Railway/Supabase) |

## 🏗️ Architecture
- **Frontend:** one self-contained `index.html` (vanilla JS + Supabase JS from CDN), mobile-first, served static by `server.js`.
- **Backend:** Supabase Postgres + **Realtime** (board syncs live across all phones) + open row-level security (trusted-friends app).
- **PWA:** `manifest.webmanifest` + icons → "Add to Home Screen" works. (Push notifications NOT built.)

## ✅ What works
- **Login** (tap name)
- **Board** — Group P&L, 👔 Guys vs 👗 Girls bar, leaderboard with **Players / Couples / Guys-v-Girls** tabs, live 🥄 Mug Punter (lowest)
- **Races** — 12-race timeline, live countdowns, lock-at-jump
- **My Bets** — 5 × $10 individual + Pick-of-the-Day ($25, ×2), **enter-your-own-odds**, no-double-dip (hides your group races)
- **Games** — Quaddies (pick entry, all 3), Feature (team vote), Mysteries (shows spun result), Get Out (team bets)
- **Admin** — run POD & Flem-quaddie **random draws**, **spin** mysteries, **lock** feature votes, **settle results** (auto-scores individual + POD + group bets and updates the board), edit Group P&L
- **Realtime** sync across devices

## ⚠️ Gaps / NOT built yet (be honest with the group)
1. **🎡 Spin-wheel animation** — not built. Mysteries are spun by an instant Admin button, no visual wheel.
2. **Runner fields** — not loaded. Picks are **by number** until the fields go in. **There is currently NO in-app screen to enter runners/scratchings** — they're loaded via the database (Claude/dev). _Recommended next build: an Admin "add runners" screen._
3. **Quaddie scoring** — entries are captured, but quaddie **payouts/points are NOT auto-calculated** yet. Needs building or manual scoring.
4. **Feature each-way payout** — approximated (place ≈ ¼ odds) at settle time; sanity-check the number.
5. **Push notifications / alerts** — not built (app works as a normal web link + add-to-home).
6. **No full test pass** — plumbing verified (serves + DB reads), but game flows not click-tested end to end.
7. **Elly's surname/spelling** — unconfirmed (shown as "Elly").
8. **Player photos** — not added (initials shown).

## 🕹️ How to run it on the day (Admin = Liam / Blake)
1. **Before 2:30pm:** Admin tab →
   - **Draw Pick-of-the-Day races** (assigns each person a POD race)
   - **Draw Flem quaddie splits** (random 4+4 per gender)
   - Once people have voted, **Lock feature votes** (before R8, 5:10pm)
2. **Each race result:** Admin → find the race → enter **Winner #** (+ placed #s for e/w) → **Settle** → all bets settle, leaderboard moves.
3. **Mysteries:** Admin → **Spin** each one (random race + horse).
4. **Group P&L:** Admin → enter total $ returned from Sportsbet as you go.

## 📋 TODO before 2:30pm tomorrow (priority order)
1. **Load runner fields** (Sportsbet screenshots → horses by name) — biggest.
2. Decide/handle **quaddie scoring**.
3. **Run the draws** (POD + quaddie splits) in Admin.
4. Add **player photos** + confirm **Elly's spelling**.
5. **Quick test pass** (place a bet, settle a race, watch the board).
6. _Optional:_ build the **spin-wheel animation** and an **Admin runner-entry screen**.

## 🛠️ Making changes
Edit `index.html` (or `supabase/schema.sql` for data) → commit → push to `main` → Railway redeploys in ~1 min. Full game design is in **BRIEF.md**.
