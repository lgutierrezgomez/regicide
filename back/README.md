# Regicide — backend

Node + Express + TypeScript. Phase 1: in-memory rooms.

## Quick start

```bash
cd back
npm install
npm test          # 29 automated checks
npm run dev       # http://localhost:3000 (REST + Socket.IO)
```

Env: `ROOM_IDLE_CLEANUP_MS` (default `300000`) — remove abandoned rooms after all players offline.

## Docs

- Phase 1 REST: [`../docs/back/PHASE1.md`](../docs/back/PHASE1.md)
- Phase 2 WebSockets: [`../docs/back/PHASE2.md`](../docs/back/PHASE2.md)
- Phase 3 Game engine: [`../docs/back/PHASE3.md`](../docs/back/PHASE3.md)
- Changelog: [`../docs/CHANGELOG.md`](../docs/CHANGELOG.md)
