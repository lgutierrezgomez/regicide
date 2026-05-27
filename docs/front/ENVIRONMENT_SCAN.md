# Flutter environment scan — 2026-05-21

Scan of `front/` and local toolchain before Phase 4 implementation.

## Toolchain (this machine)

| Tool | Version | Path |
|------|---------|------|
| Flutter | **3.24.2** (stable) | `C:\src\flutter` |
| Dart | **3.5.2** | Bundled with Flutter |
| DevTools | 2.37.2 | — |

`flutter doctor`: **ready for web** (Chrome, Edge, Windows desktop). Android toolchain has minor issues (cmdline-tools, licenses) — **not needed for web MVP**.

**Run web app:**

```powershell
cd front
flutter run -d chrome
# or
flutter run -d edge
```

## Project `front/` (initialized template)

| Item | Status |
|------|--------|
| Type | Flutter **app** (all platforms scaffolded: web, windows, android, ios, linux, macos) |
| Package name | `front` |
| SDK constraint | `^3.5.2` (matches installed Dart) |
| `lib/` | Default **counter demo** only (`lib/main.dart` ~125 lines) |
| Dependencies | `flutter`, `cupertino_icons` only |
| Dev | `flutter_test`, `flutter_lints` ^4.0.0 |
| Analyzer | `flutter analyze` — **no issues** |
| Assets / routing / state | **None** yet |

**Not yet added** (will need for Regicide):

- `flutter_bloc` (state management)
- `equatable` (BLoC states/events)
- HTTP client (`http` or `dio`)
- `socket_io_client` (lobby + `game:state`)
- Optional: `go_router` or `auto_route` for URLs (`?room=CODE`)
- Optional: `shared_preferences` or `flutter_secure_storage` for `playerId` persistence

## Backend integration (available APIs)

Server at `http://localhost:3000` (see `docs/back/PHASE1.md`–`PHASE3.md`).

| Layer | Use in Flutter |
|-------|----------------|
| REST | Create/join room, optional start |
| Socket.IO | `auth: { roomCode, playerId }`, lobby events, `game:*` actions, `game:state` |

## Web-specific notes

- `web/index.html` present; title/description mention Regicide.
- Deep link `?room=CODE` can be read via `dart:html` / `go_router` query params on web.
- CORS: backend allows configurable origins (`CORS_ORIGINS`); for local dev use `http://localhost:<flutter_port>` or default permissive dev.

## Solo-first incremental testing

Backend supports **1 player** (solo jesters aside, 8-card hand). Recommended client order:

1. **Home** — create room (solo), store `playerId` + `code`, navigate to lobby
2. **Lobby** — socket connect, host start, navigate to game on `game:started` / `game:state`
3. **Game table** — render `game:state`, minimal cards, `game:play` / `game:yield` / etc.

Multiplayer (2–4) reuses same screens; enable after solo path works.

## Gaps / risks

| Risk | Mitigation |
|------|------------|
| Two Dart installs (`C:\src\flutter` vs `C:\tools\dart-sdk`) | Use **Flutter’s** `dart`/`flutter` from `C:\src\flutter\bin` in terminal |
| Node shell may use different Node version than user’s Node 22 | Backend already runs; front only needs HTTP URL config |
| No env config in Flutter yet | Add `lib/core/config/app_config.dart` with `baseUrl` |

## Verdict

**Ready to start Phase 4.** Template is clean; web target works; architecture can be added without fighting existing code (replace counter demo incrementally).
