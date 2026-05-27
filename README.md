# Regicide Web

Online play for the cooperative card game **Regicide**. Web-only MVP; mobile is a later phase.

Monorepo:

| Folder   | Stack                                          | Purpose                                                                 |
|----------|------------------------------------------------|-------------------------------------------------------------------------|
| `back/`  | Node + Express + TypeScript + Socket.IO        | REST for room lifecycle, Socket.IO for lobby + gameplay. Server-authoritative rules. |
| `front/` | Flutter (web target) + BLoC                    | Clean Architecture client (`domain` / `data` / `presentation` / `di` / `core`). |
| `docs/`  | Markdown + JSON                                | Phase plans, status, rules, decisions.                                  |

## Quick start

Backend:

```powershell
cd back
npm install
npm run dev          # http://localhost:3000
```

Frontend:

```powershell
cd front
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
```

Deep link a room directly: `http://localhost:<port>/?room=CODE`.

Local multi-window testing (1–4 Chrome windows on one machine):

```powershell
.\scripts\run-multiplayer-chrome.ps1 -Players 4
```

## Where to read next

- [`docs/PROJECT_BRIEF.md`](docs/PROJECT_BRIEF.md) — project vision and repo layout.
- [`docs/STATUS.md`](docs/STATUS.md) — current phase and what's next.
- [`docs/ROADMAP.md`](docs/ROADMAP.md) — phased checklist.
- [`docs/rules/REGICIDE_RULES.md`](docs/rules/REGICIDE_RULES.md) — human-readable rules.
- [`CLAUDE.md`](CLAUDE.md) — guidance for Claude Code sessions.
