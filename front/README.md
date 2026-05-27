# Regicide — Flutter client

Web-first Flutter app (Clean Architecture + BLoC).

## Run (with backend)

```powershell
# Terminal 1
cd ../back
npm run dev

# Terminal 2
flutter pub get
flutter run -d chrome
```

Join via link: `http://localhost:<flutter-port>/?room=YOURCODE`

## Two players (one machine)

```powershell
cd ..
.\scripts\run-multiplayer-chrome.ps1
```

See [`../docs/front/MULTIPLAYER_LOCAL.md`](../docs/front/MULTIPLAYER_LOCAL.md).

## Docs

| Topic | Doc |
|-------|-----|
| Status | [`../docs/STATUS.md`](../docs/STATUS.md) |
| Changelog | [`../docs/CHANGELOG.md`](../docs/CHANGELOG.md) |
| 4A Home | [`../docs/front/PHASE4A.md`](../docs/front/PHASE4A.md) |
| 4B Lobby | [`../docs/front/PHASE4B.md`](../docs/front/PHASE4B.md) |
| 4C Game | [`../docs/front/PHASE4C.md`](../docs/front/PHASE4C.md) |
| Theme | `lib/core/theme/` |
| Strings | `lib/core/l10n/app_strings.dart` |

## Test

```powershell
flutter test
flutter analyze
```
