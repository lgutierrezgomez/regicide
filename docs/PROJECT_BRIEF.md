# Regicide Web — Project Brief

> **Purpose:** Single source of truth for project goals and constraints. Read this at the start of each session instead of re-explaining in chat.

## Vision

Build a **web experience** to play **Regicide** (cooperative card game):

1. A player **creates a room**.
2. Other players **join the room**.
3. When ready, players **start a game** and play Regicide together online.

## Repository layout

| Folder   | Role                                      | Stack (planned)      |
|----------|-------------------------------------------|----------------------|
| `front/` | Client UI (web)                           | **Flutter**          |
| `back/`  | Real-time multiplayer + game logic server | **Node + Express**   |
| `docs/`  | Rules, roadmap, status, machine-readable data | Markdown + JSON |

## Constraints & preferences

- **Incremental delivery** — small steps; do not build everything at once.
- **Flutter for the client** — author has Flutter experience; use it for the webpage.
- **Node + Express for the server** — chosen stack; author is new to Node; see `TECH_NOTES.md` for stack rationale.
- **Do not start application code** until the current increment explicitly says so (planning/docs phase first).
- **Keep `docs/` updated** — especially `STATUS.md` and this brief, to minimize tokens in future prompts.

## Product decisions (confirmed)

| Topic | Decision |
|-------|----------|
| **MVP platform** | **Web-only** first (Flutter web). Structure the client with **Clean Architecture** (domain / data / presentation) so a future mobile build mainly adds platform-specific pages/views and wiring—not a rewrite. |
| **Solo mode** | **In scope for v1** — 1-player games using official solo rules (`regicide_rules.json` → `soloMode`). |
| **Room join** | **Short room code** as the canonical identifier (easiest to implement first). **Shareable link** uses the same code (e.g. `/?room=ABC123`) — implement both when the link is only a URL wrapper around the code (no extra server model). |
| **Player count** | 1–4 per official Regicide rules (lobby + engine must support solo through 4-player). |

## Communication rules (product)

- Players in a room need **shared game state** (hands are private; table/enemy/damage are public).
- Room flow: create → join (enter code or open link) → lobby → start game → play turns in order.

## References

- **Workflow learnings (machine-readable):** `docs/workflow_learnings.json` — index: `docs/WORKFLOW_LEARNINGS.md`
- **Security (MVP):** `docs/SECURITY.md`
- **Phase 5B (rules dialog, legend):** `docs/front/PHASE5B_ONBOARDING.md`
- **Jester choose-next:** `docs/front/JESTER_CHOOSE_NEXT.md`
- Official rules PDF: https://www.regicidegame.com/site_files/33132/upload_files/RegicideRulesA4.pdf
- Human rules: `rules/REGICIDE_RULES.md`
- Logic-oriented rules: `rules/regicide_rules.json`
- Step list: `ROADMAP.md`
- Current progress: `STATUS.md`
- Change log (post-milestone fixes): `CHANGELOG.md`
- Server stack notes: `TECH_NOTES.md`
- Backend Phase 1 (REST): `docs/back/PHASE1.md`
- Backend Phase 2 (Socket.IO): `docs/back/PHASE2.md`
- Backend Phase 3 (game engine): `docs/back/PHASE3.md`
- Flutter Phase 4 plan: `docs/front/PHASE4_PLAN.md`
- Flutter 4A Home: `docs/front/PHASE4A.md`
- Flutter 4B Lobby: `docs/front/PHASE4B.md`
- Flutter 4C Game table: `docs/front/PHASE4C.md`
- Flutter theme: `front/lib/core/theme/` (`app_colors.dart`, `app_theme.dart`)
- Flutter strings: `front/lib/core/l10n/app_strings.dart`
- Flutter environment scan: `docs/front/ENVIRONMENT_SCAN.md`
- Local 2-player testing: `docs/front/MULTIPLAYER_LOCAL.md` · `scripts/run-multiplayer-chrome.ps1`

## How to use this file (agents & humans)

1. Read `PROJECT_BRIEF.md` + `STATUS.md` + relevant slice of `ROADMAP.md`.
2. Implement only the **next unchecked** roadmap item unless the user redirects.
3. After each increment, update `STATUS.md` (and rules/roadmap if scope changed).
