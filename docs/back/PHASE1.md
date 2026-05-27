# Backend — Phase 1 (server skeleton)

**Status:** Complete (in-memory rooms, no PostgreSQL yet).

## What was built

| Piece | Location |
|-------|----------|
| Express app factory | `back/src/app.ts` |
| Config from env | `back/src/config.ts` |
| Health check | `GET /health` |
| Room store (memory) | `back/src/services/roomStore.ts` |
| Room routes | `back/src/routes/rooms.ts` |
| Automated tests | `back/tests/*.test.ts` |

## Run locally

```powershell
cd back
npm install
npm test          # 8 tests — run this to verify everything works
npm run dev       # server on http://localhost:3000
```

Optional: copy `.env.example` to `.env` and set `PORT` / `CORS_ORIGINS`.

Production-style run:

```powershell
npm run build
npm start
```

## Manual smoke test (with server running)

```powershell
# Terminal 1
npm run dev

# Terminal 2 — create room
curl -X POST http://localhost:3000/rooms -H "Content-Type: application/json" -d "{\"displayName\":\"Alice\"}"

# Join (replace CODE from response)
curl -X POST http://localhost:3000/rooms/CODE/join -H "Content-Type: application/json" -d "{\"displayName\":\"Bob\"}"

# Lobby state
curl http://localhost:3000/rooms/CODE
```

PowerShell alternative for POST:

```powershell
Invoke-RestMethod -Method Post -Uri http://localhost:3000/rooms -ContentType "application/json" -Body '{"displayName":"Alice"}'
```

## API reference

### `GET /health`

Response `200`:

```json
{
  "status": "ok",
  "service": "regicide-back",
  "timestamp": "2026-05-20T12:00:00.000Z"
}
```

### `POST /rooms`

Create a room; creator is host and first player.

Body:

```json
{ "displayName": "Alice" }
```

Response `201`:

```json
{
  "room": {
    "code": "K7M2NP",
    "status": "lobby",
    "hostPlayerId": "<uuid>",
    "players": [{ "id": "<uuid>", "displayName": "Alice" }],
    "playerCount": 1,
    "maxPlayers": 4
  },
  "playerId": "<uuid>"
}
```

**Keep `playerId` on the client** (local storage later) for reconnect in Phase 2.

### `POST /rooms/:code/join`

Body: `{ "displayName": "Bob" }`  
Response `200`: same shape as create (`room` + `playerId`).  
Room codes are **case-insensitive** on the server.

| Status | `code` | Meaning |
|--------|--------|---------|
| 404 | `ROOM_NOT_FOUND` | Unknown code |
| 409 | `ROOM_FULL` | Already 4 players |
| 409 | `GAME_STARTED` | Reserved for when status is `in_game` |
| 400 | `INVALID_NAME` | Missing/empty/too long name |

### `GET /rooms/:code`

Response `200`:

```json
{ "room": { ... } }
```

Public lobby only (no secrets). Same errors as join for unknown room.

## Design notes

- **In-memory** `Map` — rooms disappear when the process restarts (by design for Phase 1).
- **Room codes:** 6 chars, uppercase + digits (ambiguous chars like `0/O/1/I` omitted).
- **Max players:** 4 (official Regicide cap); solo (1 player) allowed in lobby for v1.
- **PostgreSQL:** not used yet; add in a later phase for persistence.
- **WebSockets:** Phase 2; REST only for now.

## Test coverage (automated)

`npm test` runs Vitest + Supertest:

1. Health returns `ok`
2. Create room → valid code + host
3. Join second player
4. Case-insensitive join
5. GET lobby state
6. Reject 5th player (`ROOM_FULL`)
7. Unknown room → 404
8. Empty display name → 400

## Next phase

Phase 2: Socket.IO (or `ws`) for lobby updates and `game:started` events. See `../ROADMAP.md`.
