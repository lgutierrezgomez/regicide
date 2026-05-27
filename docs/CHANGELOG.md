# Changelog — Regicide (dev)

Reverse-chronological log of notable implementation changes after the initial phase milestones. For milestone scope, see `docs/front/PHASE4A.md` … `PHASE4C.md` and `docs/back/PHASE*.md`.

**Last updated:** 2026-05-20

---

## 2026-05-20 — Jester choose-next: player dialog (not app bar)

- **`ChooseNextPlayerDialog`** — auto-opens when `canChooseNext`; vertical bordered rows per player
- Removed **`GameChooseNextBar`** from app bar and hand strip
- **Docs:** `JESTER_CHOOSE_NEXT.md`, `PHASE5B_ONBOARDING.md`, `PHASE4D.md`

---

## 2026-05-20 — Phase 5B: rules dialog, symbol legend, security

| Area | Detail |
|------|--------|
| **Jester** | Choose-next via `ChooseNextPlayerDialog` (see `JESTER_CHOOSE_NEXT.md`) |
| **Instructions** | Paginated dialog from `assets/instructions/rules_pages.json`; home + game app bar |
| **Legend** | `GameSymbolLegendPanel` beside table (H/D/C/S, A, J) |
| **Security** | `docs/SECURITY.md`; `back/.env.example`, `front/.env.example`; `API_BASE_URL` dart-define |

**Docs:** `ROADMAP.md` Phase 5B, `PHASE5B_ONBOARDING.md`, `STATUS.md`.

---

## 2026-05-20 — Multiplayer table UX (step complete, paused)

### Flutter — opponents, app bar, discard

| Area | Detail |
|------|--------|
| **Opponent rails** | `OpponentSeatCard` replaces card-column placeholders: name, `hand`, `n / max`, green/gray rounded border for turn |
| **Side rails** | No rotation; `leftRailEdgeT` / `rightRailEdgeT` positioning |
| **App bar** | `Turn:` line restored; `toolbarHeight` matches content; table talk = icon + dialog only |
| **Discard** | Button on hand strip + app bar during step 4; `requiredDiscardTotal` fallback |

**Dev:** `run-multiplayer-chrome.ps1` parse fixes (ASCII only), cache clear on launch.

**Docs:** `STATUS.md`, `ROADMAP.md`, `PHASE5_TABLE.md`.

---

## 2026-05-20 — Multiplayer Chrome script: avoid stale Flutter web

`scripts/run-multiplayer-chrome.ps1` — by default clears profile cache dirs before launch, adds `?cb=` URL bust, passes `--disable-cache` to Chrome. `-KeepStorage` opts out; `-ResetProfiles` wipes entire player profiles. Warns when Flutter is already serving (hot restart hint).

**Docs:** `front/MULTIPLAYER_LOCAL.md`.

---

## 2026-05-20 — Felt HUD cards + solo playtest sign-off

### Flutter — felt HUD (`game_table_center.dart` + panels)

| Area | Detail |
|------|--------|
| **Layout** | Three `_HudCard` stacks: enemy → fight → piles (tavern / discard / solo jester) |
| **Spacing** | `_kHudCardGap` = **24px** between all three cards |
| **Typography** | `feltHud: true` on enemy + fight panels; `CastleEnemyCard.largeLabels` on felt |
| **Placement** | HUD bottom at **75%** of felt (`felt_hud_layout.dart`); width from trapezoid at that depth |
| **Chrome** | Turn bar: connection + table talk; Play + solo jester on hand strip; `AppColors.gameScaffold` page tint |

**Playtest:** Solo loop (create → start → play / yield / discard / solo jester) verified on this layout. **Next:** 2–4 player playtest (`MULTIPLAYER_LOCAL.md`).

**Docs:** `STATUS.md`, `ROADMAP.md`, `PHASE5_TABLE.md`.

---

## 2026-05-20 — Perspective table module + layout cleanup

### Flutter — `front/lib/presentation/game/table/`

| Area | Detail |
|------|--------|
| **Module** | Table visuals isolated under `table/`; `GamePage` uses `GameTableArea` only |
| **Tuning** | `TablePerspective` (trapezoid fractions, rail inset, corner radii) |
| **Felt** | Green trapezoid = uniform inset of wood toward center |
| **Hand** | Centered strip; `PlayCardLayout` split from table chrome |
| **Enemy** | `CastleEnemyCard` — `Icons.person` placeholder for castle art |
| **Cleanup** | Removed `GameActionBar`, `GamePhaseHint`, `GameTableBody`, duplicate comm widget; dropped `FittedBox` table sizing |

**Docs:** `docs/front/PHASE5_TABLE.md` (file map + what to edit for look tweaks).

---

## 2026-05-20 — Phase 4D multiplayer polish

### Flutter — lobby & game

| Area | Detail |
|------|--------|
| **Host badge** | Inline `You` / `Host` chips beside player name (not trailing `ListTile` chip) |
| **Invite link** | `buildRoomInviteUrl`, copy link + code in lobby |
| **Game roster** | `GamePlayersPanel` — order, current turn, hand counts (2+ players) |
| **Turn copy** | Waiting for named player; choose-next bar per player after jester |
| **Communication** | `CommunicationReminderCard` on lobby + game (`AppStrings.communication*`) |

### Dev — `scripts/run-multiplayer-chrome.ps1`

- **1–4** Chrome profiles (`-Players`)
- `-RoomCode` prefills `?room=` for guests
- `-ChromeOnly`, `-SkipBackend`, `-SkipFlutter`
- Printed test checklist

**Docs:** `docs/front/PHASE4D.md`, updated `MULTIPLAYER_LOCAL.md`, `ROADMAP.md`, `STATUS.md`.

---

## 2026-05-20 — Game rules, UX fixes, multiplayer dev tooling

### Backend — game engine (`back/src/game/gameEngine.ts`)

| Change | Rules basis | Detail |
|--------|-------------|--------|
| **Animal companion ≠ combo** | `regicide_rules.json` → `step1.animalCompanion`, `combo.acesInCombo: false` | `validatePlay` now allows **ace + one** other non-jester card (and ace alone, two aces). Combos apply only to 2–4 **same-rank number** cards with **no aces**. Fixes erroneous “Combo must be same rank numbers only” when pairing an Ace with e.g. a 7. |
| **Zero-card discard** | `step4.discardTotalAtLeast` = attack − spade shield | Already supported server-side (`pendingDamage === 0`). Documented and covered by tests. |

**Tests:** `gameEngine.test.ts` — ace+number play, ace+combo rejected, zero-card discard.

### Backend — room lifecycle (`back/src/services/`)

| Change | Detail |
|--------|--------|
| **Idle room cleanup** | `idleRoomCleanup.ts` — when **all** players are offline for `ROOM_IDLE_CLEANUP_MS` (default **5 min**, env `0` = off), server removes room and clears game state. Prevents unbounded in-memory growth from abandoned sessions. |
| **`RoomStore.remove` / `hasRoom`** | Used by cleanup; wired from `socketServer.ts` on connect (cancel timer) / disconnect (schedule timer). |

**Tests:** `idleRoomCleanup.test.ts`

**Config:** `back/src/config.ts` → `roomIdleCleanupMs` from `ROOM_IDLE_CLEANUP_MS`.

### Flutter — theming & copy (4A+)

| Path | Purpose |
|------|---------|
| `lib/core/theme/app_colors.dart` | Palette tokens |
| `lib/core/theme/app_theme.dart` | Single `AppTheme.light` for `MaterialApp` |
| `lib/core/l10n/app_strings.dart` | All user-visible strings (home, lobby, game, errors) |

Edit theme/colors in theme files only; edit copy in `AppStrings` only.

### Flutter — shared socket (`lib/data/datasources/room_socket.dart`)

Replaces `lobby_socket.dart`. One Socket.IO connection for **lobby + game**.

| Feature | Why |
|---------|-----|
| **Reference counting** | Lobby → game navigation no longer drops the socket when `LobbyBloc` disposes. |
| **`_lastGameState` + replay** | Game screen receives state after reusing the lobby connection. |
| **`resetForHotReload()`** | Clears socket on Flutter hot reload without closing stream controllers. |
| **Emit guard** | Surfaces “Not connected” if actions run with no live socket. |

`LobbyRepositoryImpl` and `GameRepositoryImpl` share one `RoomSocket` instance in `AppDependencies`.

### Flutter — session restore & hot reload (`lib/app.dart`, `lib/core/session/startup_route.dart`)

| Feature | Detail |
|---------|--------|
| **`StartupRouteResolver`** | On launch / hot reload: read `SharedPreferences` session → `GET /rooms/:code` → route to **home**, **lobby**, or **game** by `room.status`. |
| **`reassemble()`** | Debug hot reload: reset socket + re-resolve route (no longer stuck on home with a valid session). |
| **`RoomApi.fetchRoom`** | REST lookup for restore. |

### Flutter — home bugfix (`lib/presentation/home/`)

| Bug | Fix |
|-----|-----|
| **Create room button stayed disabled** | `DisplayNameField` now calls `HomeDisplayNameChanged` on `onChanged` so `HomeState.canSubmit` updates while typing (same pattern as room code field). |

### Flutter — game table (4C + follow-ups)

**Core implementation:** `GameBloc`, `GamePage`, `game_state_dto.dart`, widgets — see `docs/front/PHASE4C.md`.

| Change | Detail |
|--------|--------|
| **Play / solo jester actions** | Fixed via socket ref-count + reconnect (see `room_socket.dart`). |
| **Discard (0)** | `GameState.canDiscard` when `selectedDiscardTotal >= pendingDamage` (including 0/0). Hint when spades fully block attack. |
| **Fight panel** | `Damage dealt: {dealt}/{maxHealth}`; `Shields active: −{shield} \| Current attack: {net}`. Stats from `lib/domain/game/enemy_stats.dart` (matches `regicide_rules.json` enemy HP/attack). |
| **Action pending UI** | Progress bar while waiting for server; errors stay visible. |

**Tests:** `game_bloc_test.dart`, `game_state_test.dart`, `game_state_dto_test.dart`

### Flutter — dependency injection (`lib/di/app_dependencies.dart`)

- Single `RoomSocket` shared by lobby and game repositories.
- `StartupRouteResolver` for bootstrap routing.
- `prepareForHotReload()` for debug.

### Tooling — local multiplayer (`scripts/`, `docs/front/`)

| Asset | Purpose |
|-------|---------|
| `scripts/run-multiplayer-chrome.ps1` | Starts backend (if needed), Flutter `web-server` on `:8080`, opens **two Chrome profiles** (`.chrome-profiles/player1|2`) for two players on one machine. |
| `docs/front/MULTIPLAYER_LOCAL.md` | Full instructions and manual Chrome commands. |

No `--disable-web-security`; separate profiles isolate `SharedPreferences` / sessions.

### Documentation touched in this pass

- This file (`CHANGELOG.md`)
- `STATUS.md`, `TECH_NOTES.md`, `PROJECT_BRIEF.md`
- `docs/front/PHASE4A.md`, `PHASE4B.md`, `PHASE4C.md`
- `docs/back/PHASE3.md` (engine validation notes)
- `ROADMAP.md` (deep link client item)

---

## Earlier milestones (summary)

| Phase | Doc | Delivered |
|-------|-----|-----------|
| 0 | `PROJECT_BRIEF.md`, `ROADMAP.md` | Rules JSON + human rules, stack decisions |
| 1 | `docs/back/PHASE1.md` | REST rooms, in-memory store |
| 2 | `docs/back/PHASE2.md` | Socket.IO lobby events |
| 3 | `docs/back/PHASE3.md` | Server game engine, solo mode |
| 4A | `docs/front/PHASE4A.md` | Flutter home, REST, session, `?room=` |
| 4B | `docs/front/PHASE4B.md` | Lobby UI, theme, strings, start game |
| 4C | `docs/front/PHASE4C.md` | Game table, `game:state`, minimal cards |

**Next (roadmap):** Phase **5** — polish & deploy.
