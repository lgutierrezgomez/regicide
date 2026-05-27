# Project status

**Last updated:** 2026-05-27

## Current phase

**Phase 5 — Polish & deploy:** ✅ deploy done (2026-05-27). MVP is live: **frontend** at https://lgutierrezgomez.github.io/regicide/ (GitHub Pages) and **backend** at https://regicide-back.onrender.com (Render free Web Service). Live-use issues now tracked under **Phase 5C — Live-use polish** in `ROADMAP.md`. Phase 4 (4A–4D), 5 table UX, and 5B onboarding all signed off earlier.

## Completed

- Backend Phases 1–3
- **4A:** Home + REST + session + theme + strings + `?room=` deep link
- **4B:** Lobby Socket.IO, live roster, host start → game
- **4C:** Game table — `GameBloc`, `game:state`, solo play loop
- **4D:** Multiplayer polish — invite link, host badges, game roster/turns, choose-next, communication UX — `docs/front/PHASE4D.md`
- **Post-4C:** See [changelog](CHANGELOG.md) — socket lifecycle, rules fixes, idle cleanup
- **Dev:** `run-multiplayer-chrome.ps1` supports **1–4** Chrome profiles, cache bust on launch — `docs/front/MULTIPLAYER_LOCAL.md`
- **5 table UX (2026-05-20):** Felt HUD (3 cards), `OpponentSeatCard` on rails, discard in hand + app bar — `CHANGELOG.md`
- **5B onboarding (2026-05-20):** Rules dialog, symbol legend, jester doc, `SECURITY.md` — `PHASE5B_ONBOARDING.md`
- **Deploy (2026-05-27):** GitHub repo `lgutierrezgomez/regicide`; `.github/workflows/deploy-frontend.yml` builds Flutter web with `--base-href=/regicide/` and `--dart-define=API_BASE_URL=<vars.API_BASE_URL>` and publishes to GH Pages; backend auto-deployed from `back/` on Render free tier with `CORS_ORIGINS=https://lgutierrezgomez.github.io`

## Verify (solo) — playtest complete

```powershell
cd back && npm run dev
cd front && flutter run -d chrome
```

Create room → lobby → start → play / yield / discard / solo jester on the felt HUD (three stacked cards). Regression check only; UX signed off for solo.

## Verify (2–4 players, one machine)

```powershell
.\scripts\run-multiplayer-chrome.ps1 -Players 4
# or after room exists:
.\scripts\run-multiplayer-chrome.ps1 -ChromeOnly -Players 3 -RoomCode YOURCODE
```

See [`front/MULTIPLAYER_LOCAL.md`](front/MULTIPLAYER_LOCAL.md).

## Tests

```powershell
cd back && npm test
cd front && flutter test
```

## Next recommended step

**Phase 5C — Live-use polish** (`ROADMAP.md`): responsive home/lobby scroll, mobile layout for the game page, and one-at-a-time discard during Step 4. Pick whichever has higher player impact first.

## Production caveats

- Render free Web Service **sleeps after 15 min idle** → ~50s cold start on the first player of a new session.
- In-memory `RoomStore` is wiped on every redeploy or cold-start restart. Don't merge to `main` while a real game is in progress.
- Flutter web is compile-time, so any change to `API_BASE_URL` requires a workflow rerun (manual dispatch or any commit to `front/**`).

## Workflow knowledge base

[`workflow_learnings.json`](workflow_learnings.json) — reusable architecture, UI alternatives, code strategies, prompt patterns (append over time).

## Open questions

None.

## Blockers

None.
