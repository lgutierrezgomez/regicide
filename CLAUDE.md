# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**Regicide Web** — online play for the cooperative card game Regicide. Web-only MVP; mobile is a later phase that should reuse `domain/` + `data/` and add new `presentation/` views.

Repository is a monorepo with two apps:

| Folder   | Stack                            | Purpose |
|----------|----------------------------------|---------|
| `back/`  | Node + Express + TypeScript + Socket.IO | REST for room lifecycle, Socket.IO for lobby + gameplay. Server-authoritative rules. |
| `front/` | Flutter (web target) + BLoC      | Clean Architecture client (`domain`/`data`/`presentation`/`di`/`core`). |
| `docs/`  | Markdown + JSON                  | Source of truth for phase plans, status, rules, decisions. |

Read `docs/PROJECT_BRIEF.md` + `docs/STATUS.md` at the start of a session — they're the canonical "where we are / what's next" and exist to keep prompts short.

## Common commands

All commands assume PowerShell on Windows (the dev environment). The repo is not a git repo at the root; both apps have their own.

### Backend (`back/`)

```powershell
cd back
npm install
npm run dev          # tsx watch — http://localhost:3000 (Express + Socket.IO on same port)
npm run build        # tsc → dist/
npm start            # node dist/index.js (after build)
npm test             # vitest run (one-shot)
npm run test:watch
npx vitest run tests/gameEngine.test.ts          # single file
npx vitest run -t "name fragment"                # single test by name
```

Env (all optional, see `back/.env.example`): `PORT` (3000), `CORS_ORIGINS` (comma list; unset = allow all in dev), `ROOM_IDLE_CLEANUP_MS` (300000; `0` disables idle purge).

### Frontend (`front/`)

```powershell
cd front
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
flutter test
flutter test test/path/to/file_test.dart        # single file
flutter analyze
```

Flutter web has **no runtime `.env`** — backend URL is a compile-time `--dart-define=API_BASE_URL=...` (default `http://localhost:3000`, see `front/lib/core/config/app_config.dart`). `front/.env.example` is a human-readable template only.

Deep link: `http://localhost:<port>/?room=CODE` — `core/web/initial_room_code.dart` reads `?room=` and pre-fills join.

### Local multiplayer (1–4 Chrome windows on one machine)

```powershell
.\scripts\run-multiplayer-chrome.ps1 -Players 4
.\scripts\run-multiplayer-chrome.ps1 -ChromeOnly -Players 3 -RoomCode ABC123
```

Each window uses an isolated Chrome profile under `.chrome-profiles/player*` so storage doesn't cross-contaminate. See `docs/front/MULTIPLAYER_LOCAL.md`.

## Architecture

### Server-authoritative game engine

The single most important invariant: **the server owns all game state and validates every action**. Clients send intents only (`play`, `yield`, `discard`, `chooseNext`, `soloJester`); the server applies rules from `back/src/game/regicide_rules.json` and broadcasts new state.

- `gameEngine.ts` — pure functions: `createInitialState`, `applyAction`, `validatePlay`. Rule edge cases (animal companion ace pairing, combo constraints, Step 4 discard math, jester immunity, solo mode) all live here. Do **not** duplicate this logic in the Flutter client.
- `gameService.ts` — wraps the engine, owns `Map<roomCode, GameState>`, enforces host-only operations (`start`, `restart`, `returnToLobby`).
- `gameView.ts` — per-player view of state (hides other players' hands; public counts only).
- `rules.ts` / `cards.ts` / `deck.ts` — derive setup, attack/discard values, deck construction from the JSON rules.

### Wiring (request → state → broadcast)

`back/src/server.ts` is the single composition root:

1. `RoomStore` (in-memory rooms) + `PresenceService` (`playerId` ↔ `socketId`) + `GameService` are constructed once.
2. Express app gets `/health` and `/rooms` (REST: create + join → returns `playerId`).
3. Socket.IO mounts on the same HTTP server. Handshake auth requires `roomCode` + `playerId`; the middleware rejects unknown players (`socketServer.ts`).
4. `LobbyHub` and `GameHub` are the only places that emit room-channel events (`room:created`, `lobby:updated`, `game:started`, `game:state`). New events should go through a hub.
5. `idleRoomCleanup` deletes a room + game when all of its players have been offline for `ROOM_IDLE_CLEANUP_MS`.

Tests construct their own context via `tests/helpers/testServer.ts` — mirror that pattern for new integration tests instead of importing `index.ts`.

### Flutter — Clean Architecture + BLoC

`front/lib/` is organized strictly by layer; **dependencies flow inward** (`presentation → domain ← data`, glued by `di/`):

- `domain/` — entities (`Room`, `Player`, `GameStateView`, `GameCard`), repository interfaces, use cases. Pure Dart; no Flutter or HTTP imports.
- `data/` — `RoomApi` (HTTP), `RoomSocket` (socket_io_client), repository implementations that map DTOs ↔ entities.
- `presentation/` — `home/`, `lobby/`, `game/`, `shared/`. Each feature has `bloc/`, `page/`, `widgets/` (one widget per file — see roadmap convention).
- `core/` — config (`app_config.dart`), theming (`theme/`), strings (`l10n/app_strings.dart`, `l10n/app_error_messages.dart`), routing, web URL helpers, startup-route resolution.
- `di/app_dependencies.dart` — single composition root. `main.dart` builds it; `app.dart` uses it to construct blocs per route. There is no service locator package — keep DI explicit through this class.

`RoomSocket` is a singleton inside `AppDependencies`; `prepareForHotReload()` resets it because hot reload otherwise leaks a stale socket.

### Game table rendering

The trapezoid "felt" perspective table lives in `front/lib/presentation/game/table/`. Geometry (`table_perspective_geometry.dart`, `table_size_calculator.dart`) is separated from content (`game_table_center.dart`, `castle_enemy_card.dart`, `opponent_seat_card.dart`). Phase 5 doc: `docs/front/PHASE5_TABLE.md`.

### Communication restrictions

Per Regicide rules, players may not reveal exact card values. The UI shows a reminder card; the server simply never includes other players' hands in public state (`gameView.ts`). Don't add a "show all hands" debug toggle on the client — if you need it for testing, do it server-side behind an env flag.

## Conventions

- **Backend uses ESM with `.js` import specifiers** (e.g. `import { config } from "./config.js"`) because `package.json` is `"type": "module"` and `tsc` emits ESM. TypeScript resolves these to `.ts` at build time; don't drop the `.js` extension.
- **Room codes are uppercased on the server boundary.** All `GameService` / `RoomStore` lookups call `.toUpperCase()`; respect that when adding new endpoints.
- **Rule changes** must update `back/src/game/regicide_rules.json` *and* the human doc `docs/rules/REGICIDE_RULES.md` together.
- **One widget per file** in `front/lib/presentation/.../widgets/`.
- **Strings** for Flutter UI live in `front/lib/core/l10n/app_strings.dart`; don't inline literals in widgets.
- After completing a roadmap increment, update `docs/STATUS.md` and (if scope changed) `docs/ROADMAP.md`. Append cross-project lessons to `docs/workflow_learnings.json` (indexed by `docs/WORKFLOW_LEARNINGS.md`).
- Default workflow: implement the **next unchecked item** in `docs/ROADMAP.md` unless the user redirects.

## Phase docs (where to look first)

| Area | Doc |
|------|-----|
| Project vision / repo layout | `docs/PROJECT_BRIEF.md` |
| Current phase + what's next | `docs/STATUS.md` |
| Roadmap (phased checklist) | `docs/ROADMAP.md` |
| Backend REST (Phase 1) | `docs/back/PHASE1.md` |
| Backend Socket.IO (Phase 2) | `docs/back/PHASE2.md` |
| Backend game engine (Phase 3) | `docs/back/PHASE3.md` |
| Flutter pre-split plan | `docs/front/PHASE4_PLAN.md` |
| Flutter Home / Lobby / Game | `docs/front/PHASE4A.md`, `PHASE4B.md`, `PHASE4C.md` |
| Multiplayer polish | `docs/front/PHASE4D.md` |
| Phase 5 overview | `docs/front/PHASE5.md` |
| Perspective table | `docs/front/PHASE5_TABLE.md` |
| Onboarding / rules dialog / legend | `docs/front/PHASE5B_ONBOARDING.md` |
| Jester choose-next | `docs/front/JESTER_CHOOSE_NEXT.md` |
| Local multiplayer (Chrome profiles) | `docs/front/MULTIPLAYER_LOCAL.md` |
| Flutter environment scan | `docs/front/ENVIRONMENT_SCAN.md` |
| Android Studio setup | `docs/front/ANDROID_STUDIO.md` |
| Regicide rules (human doc) | `docs/rules/REGICIDE_RULES.md` |
| Security posture (MVP) | `docs/SECURITY.md` |
| Stack rationale | `docs/TECH_NOTES.md` |
| Workflow learnings index | `docs/WORKFLOW_LEARNINGS.md` |
| Post-milestone fixes | `docs/CHANGELOG.md` |
