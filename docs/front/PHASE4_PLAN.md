# Phase 4 — Flutter client plan

**Prerequisites:** Environment scan in [`ENVIRONMENT_SCAN.md`](ENVIRONMENT_SCAN.md). Backend Phases 1–3 complete.

## Architecture decisions (locked)

| Topic | Choice |
|-------|--------|
| Location | Existing `front/` project |
| Structure | **Clean Architecture** — `domain`, `data`, `presentation` |
| State | **BLoC** (`flutter_bloc`) per screen / feature |
| Screens | Each screen = folder with **`page/`** (layout) + **`widgets/`** (one widget per file) |
| Cards UI | **Minimal** representation (text/color/suit) — art later |
| MVP platform | **Web** (`flutter run -d chrome`) |
| First test path | **Solo (1 player)** only, then 2–4 players |

## Folder layout (target)

```
lib/
  main.dart
  app.dart                    # MaterialApp, routes, DI bootstrap
  core/
    config/app_config.dart    # API base URL
    theme/                    # app_colors.dart, app_theme.dart (single ThemeData)
    l10n/app_strings.dart     # all user-visible copy
    router/                   # optional go_router
    widgets/                  # shared minimal card, buttons
  domain/
    entities/                 # Room, Player, GameState, Card
    repositories/             # abstract RoomRepository, GameRepository
    usecases/                 # CreateRoom, JoinRoom, ConnectLobby, ...
  data/
    models/                   # JSON DTOs
    datasources/
      room_api.dart           # REST
      game_socket.dart        # Socket.IO
    repositories/             # impls
  presentation/
    home/
      bloc/
      page/home_page.dart
      widgets/
        home_title.dart
        create_room_button.dart
        join_room_form.dart
    lobby/
      bloc/
      page/lobby_page.dart
      widgets/...
    game/
      bloc/
      page/game_page.dart
      widgets/
        enemy_panel.dart
        hand_row.dart
        minimal_card.dart
        action_bar.dart
        ...
```

**Rules:**

- `page/*_page.dart` — `Scaffold`, `BlocProvider`, composes widgets only.
- `widgets/*.dart` — one public widget per file; no business logic (BLoC in parent page or via `context.read`).

## Incremental delivery (test after each)

### Milestone 4A — Home (solo create + join) ✓

**Goal:** Create or join a room via REST; persist `playerId` + `roomCode`; open lobby route.

- [x] `pubspec`: `flutter_bloc`, `equatable`, `http`, `socket_io_client`
- [x] `core/config` — `http://localhost:3000`
- [x] `core/theme` + `core/l10n/app_strings.dart`
- [x] Domain + data for create/join room
- [x] `HomeBloc` + `HomePage` + widgets
- [x] Parse `?room=` on web for join prefill
- [x] Docs: `PHASE4A.md`

### Milestone 4B — Lobby (solo) ✓

**Goal:** Socket connect, show lobby state, host starts game, go to game screen.

- [x] `LobbyBloc` listens: `lobby:updated`, `game:started`
- [x] Emit `game:start` as host (solo = always host)
- [x] `LobbyPage` + widgets (player list, connected dots, start button)
- [x] Game route stub until 4C
- [x] Docs: `PHASE4B.md`

### Milestone 4C — Game table (solo) ✓

**Goal:** Play a full solo turn loop against backend.

- [x] `GameBloc` on `game:state`; actions: `game:play`, `game:yield`, `game:discard`, `game:soloJester`
- [x] `minimal_card.dart` — rank + suit color/icon
- [x] Widgets: enemy, fight damage, hand, phase hint, action bar
- [x] Docs: `PHASE4C.md`

### Milestone 4D — Multiplayer polish (later)

- [ ] 2–4 players in lobby UI
- [ ] Deep-link share copy
- [ ] Communication UX (no hand hints in UI copy)

## Minimal card widget (spec)

```dart
// Example: 7♥ → bordered tile, text "7", red accent for hearts
MinimalCard({ required CardView card, bool selected, VoidCallback? onTap })
```

No images; `Container` + `Text` + suit letter (`H/D/C/S`) or icon.

## BLoC conventions

- One bloc folder per screen: `home_bloc.dart`, `home_event.dart`, `home_state.dart`
- Repository injected via constructor (manual DI in `app.dart` for now)
- Socket subscriptions cancelled in `bloc.close()`

## Docs to update per milestone

- `docs/STATUS.md` — current milestone
- `docs/ROADMAP.md` — check off Phase 4 sub-items
- `docs/front/PHASE4A.md`, `PHASE4B.md`, `PHASE4C.md` — per-milestone notes
- `docs/CHANGELOG.md` — post-milestone fixes (socket, rules, UX, multiplayer script)

## Not in first milestones

- PostgreSQL / auth accounts
- Fancy animations
- Full Regicide communication enforcement (UI copy only at first)
