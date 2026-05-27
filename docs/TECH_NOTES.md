# Tech notes — Node + Express for this project

**Status:** Living notes for the Regicide stack (backend + Flutter web). Written for a developer strong in Flutter, new to Node.

**Cross-project workflow (board-game digitization):** append learnings to [`workflow_learnings.json`](workflow_learnings.json) — see [`WORKFLOW_LEARNINGS.md`](WORKFLOW_LEARNINGS.md).

**Flutter game table (perspective UI):** shape/colors/rails under `front/lib/presentation/game/table/`; felt HUD content (enemy / fight / piles cards) in `widgets/game_table_center.dart` — see `docs/front/PHASE5_TABLE.md`. Solo playtest on this layout is complete (2026-05-20); multiplayer playtest is next.

## Is Node + Express a good fit?

**Yes, for this project** — with one important addition: **WebSockets** (or Socket.IO), not HTTP alone.

| Need | Why Node works |
|------|----------------|
| Rooms + lobby | Simple REST on Express is enough |
| Live game updates | Event-driven I/O fits WebSockets well |
| Shared turn-based state | One server process can own authoritative game state per room |
| You're learning backend | Large ecosystem, many tutorials, fast to prototype |

Express alone handles **create room / join room / health check**. Playing Regicide requires **pushing state to all clients** when someone plays a card, so plan:

```
Express  →  REST (rooms, maybe start game)
WebSocket layer  →  gameplay events (play card, yield, damage, next turn)
```

Common pattern: `express` + `socket.io` (easiest beginner DX) or `express` + `ws` (lighter, slightly more manual).

## Alternatives (when you might pick something else)

| Stack | Tradeoff |
|-------|----------|
| **Firebase / Supabase** | Less backend code; realtime built-in; game rules still need a Cloud Function or client-trust issues unless you add server logic |
| **Dart Frog / Shelf (Dart server)** | Same language as Flutter; smaller community for realtime multiplayer examples |
| **Go / Rust** | Strong for scale; steeper learning curve for your first backend |

Sticking with **Node + Express** is reasonable: you'll learn standard backend skills that transfer everywhere.

## Suggested learning path (when you start coding)

1. Minimal Express app: one `GET /health` route.
2. In-memory `Map` of rooms (id → `{ players, status }`).
3. Add Socket.IO: on `join`, broadcast lobby; on `start`, lock room and emit game state.
4. Move **all rule validation** to the server (clients only send intents like `playCard`).

## Pitfalls to avoid

- **Client-authoritative rules** — cheaters or desync; always validate on server using `regicide_rules.json`.
- **Storing full hands in broadcasts** — send each player only their hand; public state for enemy, damage pile, etc.
- **No reconnect story** — plan a `playerId` cookie or token early so refresh doesn't break the room.

## TypeScript

Recommend **TypeScript** on the server even if you're new — it pairs well with a JSON rules file and reduces bugs in turn logic. Flutter side stays Dart.

## Deployment (later)

- API + WebSocket need a host that supports long-lived connections (Railway, Render, Fly.io, a VPS). Serverless-only (pure Lambda) is awkward for WebSockets unless you use a managed realtime service.

## Alignment with Flutter web

Flutter web compiles to JS and runs in the browser. It can use:

- `http` / `dio` for REST
- `socket_io_client` or `web_socket_channel` for realtime

No structural conflict with Node/Express.

## Room join (product decision)

- **Server:** One identifier — a short **room code** (e.g. 6 alphanumeric chars). `POST /rooms` returns code; `POST /rooms/:code/join` (or equivalent) joins.
- **Link:** No separate “invite id”. Flutter web reads `Uri.base.queryParameters['room']` (or path segment) and pre-fills join — same join API. Copy link = copy URL with `?room=CODE`.
- **Why:** Code-only is simplest; URL is free once code exists. Avoid a second UUID or invite table unless requirements change.

## Flutter client structure (product decision)

- **MVP:** Flutter **web** only.
- **Clean Architecture:** `domain` (entities, use cases), `data` (API/socket repos), `presentation` (pages/widgets). Web-specific routing lives in presentation; later **mobile** adds screens that call the same use cases.
- **Solo:** Lobby may allow 1 player to start; server applies `soloMode` from `regicide_rules.json`.

## Server memory (rooms / sockets)

- **Presence** (`playerId` ↔ `socketId`) — entry removed on Socket.IO `disconnect`.
- **Socket.IO channels** — client leaves the room channel on disconnect automatically.
- **In-memory room + game** — kept while anyone might reconnect. If **all** players are offline for `ROOM_IDLE_CLEANUP_MS` (default **5 minutes**, `0` = disabled), the server deletes the room and clears game state.
- **Hot reload / refresh** — browser drops the WebSocket; server marks you offline until you reconnect (within the idle window, your room/game still exist).

## Flutter web hot reload

- Hot reload rebuilds the widget tree; the app **restores lobby/game** from `SharedPreferences` + `GET /rooms/:code`.
- The client **resets the local socket** on hot reload and reconnects when lobby/game screens mount.
- Prefer **hot restart** (`Shift+R`) if behavior looks stale.

## Game rules enforcement (server)

All Step 1 plays are validated in `back/src/game/gameEngine.ts` → `validatePlay` against `docs/rules/regicide_rules.json`:

- **Animal companion (Ace):** alone, with one other non-jester card, or as two aces — **not** treated as a same-rank combo.
- **Combo:** 2–4 cards, same rank, **numbers only**, no aces, total attack ≤ 10.
- **Step 4 discard:** sum of discard values ≥ `enemy.attack − fightSpadeShield`; empty `cardIds` when that value is 0.

See [`CHANGELOG.md`](CHANGELOG.md) for recent rule/UX fixes.

## Local multiplayer (two browsers)

- Script: `scripts/run-multiplayer-chrome.ps1`
- Doc: [`front/MULTIPLAYER_LOCAL.md`](front/MULTIPLAYER_LOCAL.md)
