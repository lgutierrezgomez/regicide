# Local multiplayer testing (1–4 Chrome windows)

Solo play on the perspective table + three-card felt HUD is signed off (2026-05-20). Use this doc for **2–4 player** regression on the same layout — see [`PHASE5_TABLE.md`](PHASE5_TABLE.md).

## Quick start

From the repo root (PowerShell):

```powershell
# Default: 2 players
.\scripts\run-multiplayer-chrome.ps1

# 3 or 4 players
.\scripts\run-multiplayer-chrome.ps1 -Players 4

# Solo smoke test (one profile)
.\scripts\run-multiplayer-chrome.ps1 -Players 1

# After host created a room, reopen guests with prefilled join URL
.\scripts\run-multiplayer-chrome.ps1 -ChromeOnly -Players 3 -RoomCode ABC123
```

The script will:

1. Start the backend on `http://localhost:3000` (unless already running or `-SkipBackend`)
2. Start Flutter web on `http://localhost:8080` (unless already running or `-SkipFlutter`)
3. Open **1–4 Chrome windows** with separate profiles under `.chrome-profiles/player1` … `player4`

## Parameters

| Flag | Description |
|------|-------------|
| `-Players` (1–4) | Number of isolated Chrome windows (default **2**) |
| `-RoomCode` | Windows 2+ open `?room=CODE` on the app URL |
| `-ChromeOnly` | Only open Chrome; do not start backend/Flutter |
| `-SkipBackend` | Do not start `npm run dev` |
| `-SkipFlutter` | Do not start `flutter run` |
| `-AppUrl` | Flutter web URL (default `http://localhost:8080`) |
| `-ApiUrl` | Backend URL (default `http://localhost:3000`) |
| `-KeepStorage` | Do **not** clear profile cache (may show an old UI build) |
| `-ResetProfiles` | Delete each `player*` profile folder (cache **and** saved name/room session) |

## Stale UI in Chrome windows

Isolated profiles under `.chrome-profiles/` keep **HTTP cache** and can show an older Flutter build even when the dev server has recompiled.

**Default (recommended):** each run clears cache folders under each profile, opens with a `?cb=` timestamp, and launches Chrome with `--disable-cache`. **Close** any open player Chrome windows first so files are not locked.

```powershell
# Fresh assets, keep saved player name / last room in profile
.\scripts\run-multiplayer-chrome.ps1

# Nuclear: wipe profiles entirely (new names, no auto-restore)
.\scripts\run-multiplayer-chrome.ps1 -ResetProfiles

# Reopen quickly without cache clear (may be stale)
.\scripts\run-multiplayer-chrome.ps1 -ChromeOnly -KeepStorage
```

If the UI is still wrong after cache clear, **hot restart** Flutter (`Shift+R` in the `flutter run` terminal), then re-run the script. The `cb` query param is ignored by the app (only `room` is read).

## Test flow

1. **Player 1**: enter name → **Create room** → copy **invite link** in lobby
2. **Players 2–N**: join (manual code or re-run script with `-RoomCode`)
3. **Host**: start when 2–4 players are connected
4. In-game: check turn labels, player list; after jester a **Who plays next?** dialog must appear

## Why separate Chrome profiles?

- Same URL (`localhost:8080`) but **different** `--user-data-dir` folders
- Each window has its own `SharedPreferences` / session
- No `--disable-web-security` flags; CORS is configured for local dev

## Manual setup

```powershell
# Terminal 1
cd back
npm run dev

# Terminal 2
cd front
flutter run -d web-server --web-hostname=localhost --web-port=8080
```

Open Chrome manually:

```powershell
$chrome = "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe"
$app = "http://localhost:8080"
for ($i = 1; $i -le 4; $i++) {
  $p = "$PWD\.chrome-profiles\player$i"
  New-Item -ItemType Directory -Force -Path $p | Out-Null
  Start-Process $chrome "--user-data-dir=$p --no-first-run --no-default-browser-check $app"
  Start-Sleep -Seconds 1
}
```

## Hot reload

Hot reload rebuilds the Flutter app; re-run the script (cache clear is automatic) or hard-refresh each window. Use `-KeepStorage` only when you intentionally keep an old cached build. Use `-ResetProfiles` to drop saved sessions.

## Server cleanup

Rooms are removed when **all** players are offline for 5 minutes (`ROOM_IDLE_CLEANUP_MS`). Short disconnects during hot reload are fine if you reconnect in time.
