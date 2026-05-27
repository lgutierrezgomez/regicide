# Backend — Phase 2 (real-time transport)

**Status:** Complete. Uses **Socket.IO** on the same port as Express.

## Run & test

```powershell
cd back
npm install
npm test          # 17 tests (8 REST + 9 socket-related)
npm run dev
```

## Architecture

```
HTTP + WebSocket (same port)
├── REST (Phase 1)     POST/GET /rooms…
└── Socket.IO          auth → join room channel → events
```

| Module | Role |
|--------|------|
| `src/server.ts` | Wires Express + Socket.IO + `LobbyHub` |
| `src/socket/socketServer.ts` | Auth middleware, connection handlers |
| `src/socket/lobbyHub.ts` | Broadcast helpers |
| `src/services/presence.ts` | Maps `playerId` ↔ socket (for `connected` flag) |

## Client connection

After **REST** create/join (save `playerId` + `room.code`):

```javascript
import { io } from "socket.io-client";

const socket = io("http://localhost:3000", {
  auth: { roomCode: "ABC123", playerId: "<uuid-from-rest>" },
});
```

Invalid/missing auth → connection rejected (`connect_error`).

## Socket events

### Server → client

| Event | When |
|-------|------|
| `room:created` | Host’s **first** socket connection (to that socket only) |
| `room:joined` | Someone joined via REST `{ playerId, displayName, room }` |
| `lobby:updated` | Lobby snapshot changed `{ room }` — players include `connected` |
| `game:started` | Game moved to `in_game` `{ room }` |
| `error` | Failed action `{ message, code }` (e.g. `NOT_HOST`) |

### Client → server

| Event | Who | Effect |
|-------|-----|--------|
| `game:start` | Host only | Sets `status: in_game`, broadcasts `game:started` |

## REST additions (Phase 2)

### `POST /rooms/:code/start`

Body: `{ "playerId": "<host-uuid>" }`  
Response `200`: `{ room }` — same as socket start, also broadcasts `game:started`.

## Recommended client flow

1. `POST /rooms` or `POST /rooms/:code/join` → store `playerId`, `room.code`
2. Connect Socket.IO with `auth`
3. Listen for `lobby:updated` (and `room:joined` for toasts)
4. Host emits `game:start` or calls REST start
5. On tab close, socket disconnects → others see `connected: false` (player stays in lobby for reconnect)

## Manual socket smoke test

Use browser devtools or a small script with `socket.io-client`. With server running:

1. Create room via REST, note `code` + `playerId`
2. Connect with auth
3. Join second player via REST → first client should get `room:joined` + `lobby:updated`

## Next phase

Phase 3: server-authoritative game engine (decks, turns, damage). See `../ROADMAP.md`.
