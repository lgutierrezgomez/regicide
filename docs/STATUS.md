# Project status

**Last updated:** 2026-05-20

## Current phase

**Phase 5 — Polish & deploy** (in progress, **paused** on table UX). **Phase 4 (4A–4D)** complete. **Solo playtest** signed off. **Multiplayer table UX** iteration done. **Phase 5B** done: jester choose-next doc, paginated rules dialog, symbol legend, security notes — `docs/front/PHASE5B_ONBOARDING.md`. Resume with **2–4 player** playtest or art / deploy. Table code: `front/lib/presentation/game/table/` — `docs/front/PHASE5_TABLE.md`.

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

When resuming: full **2–4 player** playtest on the current layout (`run-multiplayer-chrome.ps1`), then card art / animations / deploy. No blockers for this pause.

## Workflow knowledge base

[`workflow_learnings.json`](workflow_learnings.json) — reusable architecture, UI alternatives, code strategies, prompt patterns (append over time).

## Open questions

None.

## Blockers

None.
