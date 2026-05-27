# Regicide Web — Roadmap

Check items off in `STATUS.md` as they complete. Order is intentional (dependencies first).

## Phase 0 — Foundation (current)

- [x] Project brief (`PROJECT_BRIEF.md`)
- [x] Roadmap (`ROADMAP.md`)
- [x] Game rules — human (`rules/REGICIDE_RULES.md`) + machine (`rules/regicide_rules.json`)
- [x] Tech stack notes (`TECH_NOTES.md`)
- [x] Confirm target: **web-only MVP**; **Clean Architecture** on client for future mobile pages/views

## Phase 1 — Server skeleton

- [x] Initialize `back/` (Node, Express, TypeScript)
- [x] Health endpoint + env/config pattern
- [x] Room model: create room, join by **short code** (canonical id), list players in lobby
- [x] Client: deep link / `?room=CODE` reads same code (Flutter 4A — `initial_room_code.dart`)
- [x] Persist rooms in memory first; optional Redis/DB later if needed
- [x] Automated tests (`npm test`) — see `docs/back/PHASE1.md`

## Phase 2 — Real-time transport

- [x] Protocol: **Socket.IO** on same port as Express
- [x] Events: `room:created`, `room:joined`, `lobby:updated`, `game:started`, disconnect → `connected: false`
- [x] Auth: `handshake.auth` with `roomCode` + `playerId` (from REST join)
- [x] Tests + docs: `docs/back/PHASE2.md`

## Phase 3 — Game engine (server-authoritative)

- [x] Setup from `regicide_rules.json` (player count → jesters, hand size, decks)
- [x] Turn pipeline: Step 1 → 2 → 3 → 4 (yield, combos, aces, jester, immunity)
- [x] Cumulative damage, spade shields, exact defeat → tavern top
- [x] Communication restrictions in UI (Flutter 4D reminder card; server never leaks hands in public)
- [x] Win/lose + **solo mode** (jesters aside, victory tiers)
- [x] Docs: `docs/back/PHASE3.md`

## Phase 4 — Flutter client

Plan: [`front/PHASE4_PLAN.md`](front/PHASE4_PLAN.md) · Scan: [`front/ENVIRONMENT_SCAN.md`](front/ENVIRONMENT_SCAN.md)

- [x] **4A Home** — Clean Architecture bootstrap, BLoC, REST create/join, `?room=`, solo test — `docs/front/PHASE4A.md`
- [x] **4B Lobby** — theme + `AppStrings`, Socket.IO, `lobby:updated`, host `game:start` — `docs/front/PHASE4B.md`
- [x] **4C Game table** — `game:state`, minimal cards, **solo** play loop — `docs/front/PHASE4C.md` (post-4C fixes in `CHANGELOG.md` are still solo UX/rules, not 4D)
- [x] **4D** — multiplayer polish — `docs/front/PHASE4D.md`
- [x] Screen folders: `page/` + `widgets/` (home, lobby, game — one widget per file)
- [x] Communication restrictions in UI (reminder card; server never leaks hands)

## Phase 5 — Polish & deploy

- [x] Error states (room full, game started, reconnect) — `docs/front/PHASE5.md`
- [x] Game table layout (perspective trapezoid, felt HUD, rails) — `docs/front/PHASE5_TABLE.md`
- [x] Opponent rails: compact seat cards (name / hand / n·max, turn border) — `opponent_seat_card.dart`
- [x] Multiplayer turn bar + discard on hand (step paused 2026-05-20) — `CHANGELOG.md`
- [ ] Card animations / image assets — deferred
- [ ] Deploy back + front (hosting TBD) — deferred
- [x] Playtest solo end-to-end (perspective table + felt HUD) — 2026-05-20
- [ ] Playtest 2–4 players end-to-end on same layout

## Phase 5B — Onboarding, reference UI, security (attack one-by-one)

Doc hub: [`front/PHASE5B_ONBOARDING.md`](front/PHASE5B_ONBOARDING.md)

- [x] **Jester / choose next** — `ChooseNextPlayerDialog`; doc [`front/JESTER_CHOOSE_NEXT.md`](front/JESTER_CHOOSE_NEXT.md)
- [x] **Paginated instructions dialog** — `assets/instructions/rules_pages.json`, `PaginatedInstructionsDialog`
- [x] **Instructions entry points** — home + game app bar (`InstructionsLaunchButton`)
- [x] **Symbol legend** — `GameSymbolLegendPanel` right of table (or below on narrow)
- [x] **Security pass** — [`SECURITY.md`](SECURITY.md), `.env.example` back/front, `API_BASE_URL` dart-define

## Phase 6 — Optional later

- [ ] Accounts / persistence
- [ ] Spectators
- [ ] Regicide Companion–style helpers (damage tracker) built-in
- [ ] **Mobile** targets (reuse domain/data; new presentation pages/views)
