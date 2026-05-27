# Phase 5 — Error states (partial)

**Status:** Error UX complete (2026-05-20). Animations and deploy deferred.

## Delivered

### API errors (home)

- `AppErrorMessages.fromApi` maps `ROOM_FULL`, `GAME_STARTED`, `ROOM_NOT_FOUND`, `NOT_HOST`, `NOT_IN_ROOM`, `INVALID_NAME`
- `HomeBloc` shows friendly copy instead of raw server text when code is known

### Socket errors (lobby / game)

- `AppErrorMessages.fromSocket` for `NOT_HOST`, `GAME_STARTED`, turn/phase errors
- Repository maps socket `error` events before BLoC

### Reconnect

- `RoomSocket` emits `connectionLost` on disconnect while session is active
- Lobby / game: **Reconnect** button on connection banner
- `LobbyReconnectRequested` / `GameReconnectRequested` re-call `connect(session)`

## Key paths

```
front/lib/core/l10n/app_error_messages.dart
front/lib/presentation/shared/widgets/connection_status_banner.dart
front/lib/data/datasources/room_socket.dart  # onDisconnect
```

## Deferred

- Dedicated “session expired” home banner after startup `ROOM_NOT_FOUND`
- Auto-retry backoff (manual Reconnect only)
