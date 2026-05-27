# Backend — Phase 3 (game engine)

**Status:** Complete (server-authoritative rules in monolith; communication rules are client-side).

## Run & test

```powershell
cd back
npm test          # 29 tests (gameEngine, idle cleanup, rooms, socket, health)
npm run dev
```

Rules source of truth: `back/src/game/regicide_rules.json` (copy of `docs/rules/regicide_rules.json`).

## Module layout (`back/src/game/`)

| File | Role |
|------|------|
| `regicide_rules.json` | Machine-readable rules |
| `rules.ts` | Loaded constants (hand size, enemy stats) |
| `deck.ts` | Build castle/tavern, shuffle, deal |
| `cards.ts` | Attack/discard values, suit powers list |
| `gameEngine.ts` | Setup + `applyAction` (turn pipeline) |
| `gameView.ts` | Public state + per-player hand |
| `gameService.ts` | `roomCode` → `GameState` map |
| `gameError.ts` | Typed errors |

Broadcast: `socket/gameHub.ts` → `game:state` (each player gets own hand).

## Starting a game

Host triggers start (same as Phase 2):

- Socket: `game:start`
- REST: `POST /rooms/:code/start` `{ "playerId": "..." }`

Server deals hands, flips first Jack, sets turn to first player in join order.

## Socket actions (during `in_game`)

| Client event | Body | Phase |
|--------------|------|--------|
| `game:play` | `{ cardIds: string[] }` | Step 1 — single card, **animal companion** (ace ±1 card), ace pair, or number combo |
| `game:yield` | — | Step 1 |
| `game:discard` | `{ cardIds: string[] }` | Step 4 — defend (`[]` allowed if `pendingDamage === 0`) |
| `game:chooseNext` | `{ nextPlayerId }` | After jester |
| `game:soloJester` | — | Solo only — refill hand (uses aside jester) |

After each action, server emits **`game:state`** to every connected player (private hand per socket).

## `game:state` payload

```json
{
  "public": {
    "outcome": "playing",
    "phase": "STEP1_PLAY_OR_YIELD",
    "currentPlayerId": "...",
    "currentEnemy": { "id", "kind", "suit", "rank" },
    "fightDamage": 12,
    "fightSpadeShield": 0,
    "pendingDamage": null,
    "handCounts": { "playerId": 5 },
    "tavernCount": 30,
    "canYield": true,
    "soloJestersRemaining": 2
  },
  "hand": [ { "id", "kind", "suit", "rank" } ]
}
```

Phases: `STEP1_PLAY_OR_YIELD` | `STEP4_DISCARD` | `CHOOSE_NEXT_PLAYER` | `GAME_OVER`.

## Play validation (`validatePlay`)

Aligned with `docs/rules/regicide_rules.json`:

| Play | Allowed |
|------|---------|
| Single number / enemy in hand | Yes |
| Ace alone | Yes |
| Ace + **one** other non-jester card | Yes (animal companion — **not** a rank combo) |
| Two aces | Yes (ace pair) |
| 2–4 same-rank **numbers**, no aces | Yes (combo, total attack ≤ 10) |
| Ace in a 3–4 card combo | No |
| Jester | Alone only |

## Room idle cleanup

If every player is offline for **`ROOM_IDLE_CLEANUP_MS`** (default 5 minutes, `0` disables), the server deletes the room and game. See `src/services/idleRoomCleanup.ts` and [`../CHANGELOG.md`](../CHANGELOG.md).

## Implemented rules

- [x] Setup (player count → jesters, hand size, castle + tavern)
- [x] Turn steps 1–4 (play, yield, suit powers, damage, discard defense)
- [x] Combos (numbers only), animal companions / ace pairs, jester (immunity + choose next)
- [x] Cumulative damage, spade shield, exact defeat → enemy on tavern top
- [x] Win / lose detection
- [x] Solo jesters aside + victory tiers (gold/silver/bronze)
- [ ] **Communication restrictions** — enforced in Flutter UI, not server (no hand data in public events)

## Win / lose

- **Win:** last King defeated (`outcome: "won"`, optional `victoryTier` in solo).
- **Lose:** cannot pay Step 4 damage, or on Step 1 cannot play and cannot yield.

## Next phase

Phase 4: Flutter web client (Clean Architecture) consuming REST + Socket.IO. See `../ROADMAP.md`.
