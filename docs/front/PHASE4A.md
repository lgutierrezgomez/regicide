# Phase 4A — Home screen

**Status:** Complete (see [`CHANGELOG.md`](../CHANGELOG.md) for follow-up fixes).

## Run

```powershell
cd back && npm run dev
cd front && flutter pub get && flutter run -d chrome
```

**Android Studio:** open **`front/`** only — [`ANDROID_STUDIO.md`](ANDROID_STUDIO.md).

Join link: `http://localhost:<port>/?room=ABC123` (pre-fills room code).

## What was built

| Layer | Files |
|-------|--------|
| Core | `app_config.dart`, `app_routes.dart`, `initial_room_code.dart`, `app_theme.dart`, `app_colors.dart`, `app_strings.dart` |
| Domain | `Room`, `Player`, `RoomSession`, repos, `CreateRoom`, `JoinRoom` |
| Data | `RoomApi` (create, join, **fetchRoom** for session restore), DTOs, `SessionRepositoryImpl` |
| Presentation | `HomeBloc`, `HomePage`, widgets (one per file) |

## Dependencies

`flutter_bloc`, `equatable`, `http`, `shared_preferences`, `socket_io_client`.

## Manual test (solo)

1. Enter display name → **Create room (solo)** (button enables as you type)
2. Lobby shows room code + host
3. Session persists in browser storage

## Bugfix (post-4A)

**Create room disabled after typing name** — `DisplayNameField` did not sync text to `HomeBloc`; fixed with `onChanged` → `HomeDisplayNameChanged` (same as room code field).

## Theming & strings

- **Theme:** `lib/core/theme/` → `AppTheme.light` in `app.dart`
- **Copy:** `lib/core/l10n/app_strings.dart`

## Tests

```powershell
cd front && flutter test
```

Includes `enables submit when display name is set` in `home_bloc_test.dart`.

## Next

**4B** — `PHASE4B.md` · **4C** — `PHASE4C.md`
