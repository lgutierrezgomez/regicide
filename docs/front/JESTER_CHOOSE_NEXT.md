# Jester — choose next player (3–4 players)

**Last updated:** 2026-05-20

## Question

When a player selects and plays a **Jester**, is there UI to pick who plays next in 3–4 player games?

## Answer: yes (server + client)

### Server (`back/src/game/gameEngine.ts`)

1. Playing a lone jester sets `phase = CHOOSE_NEXT_PLAYER` and `pendingJesterBy =` that player.
2. Turn stays on the jester player until they send `game:chooseNext` with `nextPlayerId`.
3. `chooseNext` validates: phase, and only `pendingJesterBy` may act.

### Client

| Piece | Role |
|-------|------|
| `GamePhase.chooseNextPlayer` | Parsed from `CHOOSE_NEXT_PLAYER` |
| `pendingChooseNext` | `true` when phase is choose-next (`gameView.ts`) |
| `GameState.canChooseNext` | My turn + phase + `pendingChooseNext` |
| `ChooseNextPlayerDialog` | Modal list of players (bordered rows); opens automatically |
| App bar | **No** choose-next controls — phase hint only |
| Hand strip | **No** choose-next controls |

### Flow for testers

1. On your turn, select **only** a jester card → **Play**.
2. **Who plays next?** dialog opens with one row per player.
3. Tap a row → `game:chooseNext` → dialog closes → turn moves to them at Step 1.

### Solo

Solo dialog title: **Continue your turn** — single row (you).

### If buttons are missing

- Confirm you are the player who **played** the jester (not another client).
- Hot-restart Flutter after pull; re-run Chrome script with cache clear.
- Check socket error banner for `NOT_HOST` / phase errors.
