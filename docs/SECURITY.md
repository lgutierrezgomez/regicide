# Security — Regicide MVP scope

**Last updated:** 2026-05-20

This project is a **friends-and-LAN** MVP: short room codes, no accounts, in-memory rooms. The goal is safe defaults and no accidental secret leaks—not production-grade anti-abuse.

## Secrets and configuration

### Backend (`back/`)

| Variable | Required | Purpose |
|----------|----------|---------|
| `PORT` | No (default 3000) | HTTP + Socket.IO port |
| `CORS_ORIGINS` | No (dev: allow all) | Comma-separated origins in production |
| `ROOM_IDLE_CLEANUP_MS` | No (default 5 min) | Idle room purge; `0` disables |

**There are no API keys** in the server today. Copy `back/.env.example` → `back/.env` for local overrides. `.env` is gitignored.

### Frontend (`front/`)

Flutter web does **not** load `.env` at runtime. Use **compile-time** defines:

```powershell
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
```

See `front/.env.example` as a human-readable template (not read by the app).

**Never** put private API keys in the Flutter client—they ship to the browser.

## Measures in place

| Area | Implementation |
|------|----------------|
| **Rules** | Server-authoritative; clients send intents only |
| **Hidden information** | Hands per-player in `game:state`; public view has counts only |
| **Room join** | `playerId` from REST join + socket `handshake.auth` |
| **CORS** | Configurable via `CORS_ORIGINS` for deploy |
| **Idle cleanup** | Rooms removed after all players offline (limits memory growth) |
| **Error surface** | Generic messages to clients; no stack traces in API body |

## Worth doing before public deploy

1. **Restrict CORS** to your front-end origin(s).
2. **HTTPS** termination (reverse proxy or host TLS).
3. **Rate limiting** on `POST /rooms` and join (express-rate-limit or proxy).
4. **Room code entropy** — already random; keep length ≥ 6 alphanumeric.
5. **Input validation** — display names length; `cardIds` must be in hand (server already checks).
6. **Do not commit** `.env`, Chrome profiles, or logs with tokens.

## Out of scope for MVP

- User accounts / OAuth
- JWT sessions (current model: opaque `playerId` per join)
- Anti-cheat beyond server validation
- E2E encryption of game traffic (TLS at transport layer is enough for casual play)

## Reporting

If you add third-party services (analytics, error reporting), document keys in `.env.example` only and list them here.
