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
- [x] **Deploy back + front (2026-05-27)** — front on GitHub Pages (`/regicide/` subpath), back on Render free Web Service. See `CHANGELOG.md` and Phase 5C below for live-use follow-ups.
- [x] Playtest solo end-to-end (perspective table + felt HUD) — 2026-05-20
- [ ] Playtest 2–4 players end-to-end on same layout

## Phase 5B — Onboarding, reference UI, security

Doc hub: [`front/PHASE5B_ONBOARDING.md`](front/PHASE5B_ONBOARDING.md)

- [x] **Jester / choose next** — `ChooseNextPlayerDialog`; doc [`front/JESTER_CHOOSE_NEXT.md`](front/JESTER_CHOOSE_NEXT.md)
- [x] **Paginated instructions dialog** — `assets/instructions/rules_pages.json`, `PaginatedInstructionsDialog`
- [x] **Instructions entry points** — home + game app bar (`InstructionsLaunchButton`)
- [x] **Symbol legend** — `GameSymbolLegendPanel` right of table (or below on narrow)
- [x] **Security pass** — [`SECURITY.md`](SECURITY.md), `.env.example` back/front, `API_BASE_URL` dart-define

## Phase 5C — Live-use polish (post-deploy)

Issues observed once the MVP went live on real devices and real browsers (2026-05-27).

### Responsive layout

- [x] **Home page — scroll when content overflows.** Confirmed fine in code — `home_page.dart` already wraps the column in `SingleChildScrollView` (verified 2026-05-27, no fix needed).
- [x] **Lobby page — scroll when content overflows (2026-05-27).** Replaced outer `Padding` with `SingleChildScrollView` in `lobby_page.dart` so roster + invite card + communication reminder + host hint + start button stay reachable on mobile portrait.
- [x] **Game page — mobile layout (2026-05-27).** Below a 600px width breakpoint, `game_page.dart` now dispatches to `MobileGameBody` (`lib/presentation/game/mobile/`) — a vertical stack with enemy card + pile chips + fight stats always visible, secondary panels (teammates, played-this-fight, symbol legend) behind collapsibles, hand horizontally scrollable, and a sticky bottom action bar. Reuses existing `EnemyCardCell`, `PlayedThisFightCell`, `TeammatesPanel`, `SymbolLegendPanel`, `PlayerHandStrip`, `GameOverPanel`. Switches live on viewport resize via `LayoutBuilder`.

### Step 4 — one-at-a-time discard

- [x] **Discard one card at a time during Step 4 (2026-05-27).** Engine now enforces single-card discards: `pendingDamage > 0` requires `cardIds.length === 1`, the card's discard value subtracts from `pendingDamage`, step 4 ends only when `pendingDamage` reaches 0 (or empty `cardIds` when shields already blocked the attack). Client bloc enforces single-select during step 4 and the Discard button now shows "Continue" when shields fully blocked. Rules JSON + human rules doc updated. New engine + state tests cover partial discard, exact-cover, over-cover, multi-card rejection, and empty-discard rejection.

## Phase 6 — Optional later

- [ ] Accounts / persistence
- [ ] Spectators
- [ ] Regicide Companion–style helpers (damage tracker) built-in
- [ ] **Mobile** targets (reuse domain/data; new presentation pages/views)
