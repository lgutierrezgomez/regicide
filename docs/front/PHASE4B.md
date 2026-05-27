# Phase 4B — Lobby (Socket.IO)

**Status:** Complete (socket later unified — see [`CHANGELOG.md`](../CHANGELOG.md)).

## Run

```powershell
cd back && npm run dev
cd front && flutter run -d chrome
```

## What was built

| Layer | Files |
|-------|--------|
| Core (theme) | `lib/core/theme/app_colors.dart`, `app_theme.dart` — `AppTheme.light` in `app.dart` |
| Core (strings) | `lib/core/l10n/app_strings.dart` — all UI copy |
| Data | `room_socket.dart` (was `lobby_socket.dart`) — Socket.IO `auth: { roomCode, playerId }` |
| Domain | `lobby_repository.dart` |
| Data | `lobby_repository_impl.dart` |
| Presentation | `LobbyBloc`, `LobbyPage`, lobby widgets (one per file) |

### Socket events

| Direction | Event | Purpose |
|-----------|--------|---------|
| Server → client | `lobby:updated` | Live player list, `connected` flags |
| Server → client | `game:started` | Navigate to game route |
| Server → client | `error` | Show banner (e.g. start failed) |
| Client → server | `game:start` | Host starts game |

### Lobby widgets

- `lobby_connection_banner.dart`
- `lobby_room_code_card.dart`
- `lobby_player_list.dart` / `lobby_player_row.dart`
- `lobby_start_button.dart`
- `lobby_solo_hint.dart`, `lobby_waiting_label.dart`

### DI

`app_dependencies.dart` — shared `RoomSocket` for lobby and game; `createLobbyBloc()`.

### Post-4B fixes (documented in changelog)

- **Ref-counted socket** so navigating to the game screen does not disconnect.
- **Game state replay** when reusing the same connection.

## Manual test (solo)

1. Home → display name → **Create room (solo)**
2. Lobby: **Connected to server**
3. **Start game** → game table (4C)

## Manual test (2 players)

[`MULTIPLAYER_LOCAL.md`](MULTIPLAYER_LOCAL.md)

## Tests

```powershell
cd front
flutter analyze
flutter test
```

## Theming & copy

- **Theme:** `app_colors.dart`, `app_theme.dart`
- **Text:** `app_strings.dart` only in widgets

## Next

**4C** — see `PHASE4C.md`.
