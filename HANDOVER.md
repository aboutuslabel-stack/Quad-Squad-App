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

## ✅ Added since first handover
- **🎡 Spin-wheel — live on every phone** — admin taps Spin (Admin → Spin a Mystery) and the two-stage wheel (race → horse) pops up and spins in sync on everyone's open app (Supabase Realtime broadcast, no DB rows). Only spins onto races still open with a field loaded; asks before a re-spin. Anyone who closes it or misses it sees the result in Games → Mysteries.
- **Runner fields in-app** — Admin → each race → paste the field → **Load / update field**. Scratch runners there too; scratched bets refund (0 pts).
- **Quaddie scoring** — 10 pts per correct leg to the picker's team, plus the Sportsbet return (entered in Admin) minus stake once all 4 legs are run. Mixed quaddie splits 50/50.
- **Team-bet odds** — Admin sets horse + odds for Feature, Get Out of Jail and Mysteries. Settling skips and flags any team bet with no horse/odds instead of scoring it a loss.
- Odds now required on every bet; max 5 individual bets; live updates no longer wipe what you're typing.
- Get Out of Jail moved to its own **Get Out** tab.

## ⚠️ Still open
1. **Runner fields not loaded yet** — picks are by number until you load them (Admin, per race).
2. **Feature each-way payout** — approximated (place ≈ ¼ of win odds). Sanity-check the number after R8.
3. **Live wheel needs the app open** — phones that are locked or have the app closed miss the animation (they still see the result in Mysteries).
4. **Push notifications / alerts** — not built.
5. **No full click-through test** — plumbing verified (site serves, DB reads, code checks), game flows not tested end to end.
6. **Player photos** still to come (Ellie's spelling confirmed).

## 🕹️ How to run it on the day (Admin = Liam / Blake)
1. **Before 2:30pm:** Admin tab →
   - **Load the field** for each race (paste runners → Load / update field)
   - **Draw Pick-of-the-Day races** (assigns each person a POD race)
   - **Draw Flem quaddie splits** (random 4+4 per gender)
2. **Mysteries:** Admin → **Spin** → wheel spins race, then horse. Needs that race's field loaded and still open.
3. **Team bets:** Admin → *Group bets — horse & odds* → enter the odds you took on Sportsbet (Feature horse comes from the locked vote; **Lock feature votes** before R8, 5:10pm).
4. **Each race result:** Admin → the race → **Winner #** (+ placed #s for e/w) → **Settle**. Bets settle, board moves. Fix any flagged team bet missing odds, then re-settle.
5. **Quaddies:** once all 4 legs are settled, enter the $ returned in *Quaddie returns* (0 if it missed).
6. **Group P&L:** enter total $ returned from Sportsbet as you go.

## 📋 TODO before 2:30pm tomorrow
1. **Load runner fields** for all 12 races — biggest.
2. **Run the draws** (POD + quaddie splits).
3. **Quick test**: place a bet, settle a race, spin a mystery, watch the board. **There's no in-app reset** — settling marks the race resulted and locks it — so after testing, the test data has to be wiped from the database (ask Claude) before the real day.
4. Player photos.

## 🛠️ Making changes
Edit `index.html` (or `supabase/schema.sql` for data) → commit → push to `main` → Railway redeploys in ~1 min. Full game design is in **BRIEF.md**.
