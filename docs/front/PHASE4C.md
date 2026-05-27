# Phase 4C — Game table (solo)

**Status:** Complete (including post-milestone fixes in [`CHANGELOG.md`](../CHANGELOG.md)). Solo **UI** is now the Phase 5 perspective table + three-card felt HUD — playtest signed off 2026-05-20; see [`PHASE5_TABLE.md`](PHASE5_TABLE.md).

## Run

```powershell
cd back && npm run dev
cd front && flutter run -d chrome
```

Solo: home → create room → lobby → **Start game** → game table.

Two players on one PC: [`MULTIPLAYER_LOCAL.md`](MULTIPLAYER_LOCAL.md) or `.\scripts\run-multiplayer-chrome.ps1`.

## What was built

| Layer | Files |
|-------|--------|
| Socket | `room_socket.dart` — lobby + `game:state` + game actions (replaces `lobby_socket.dart`) |
| Domain | `game_card.dart`, `game_public_state.dart`, `game_state_view.dart`, `game_repository.dart`, `card_rules.dart`, `enemy_stats.dart` |
| Data | `game_state_dto.dart`, `game_repository_impl.dart` |
| Presentation | `GameBloc`, `GamePage`, widgets (`minimal_card`, enemy/fight/hand/action bar, …) |
| Bootstrap | `startup_route.dart` — restore lobby/game after reload |

### Socket events (client)

| Direction | Event | Purpose |
|-----------|--------|---------|
| Server → client | `game:state` | Private hand + public table state |
| Client → server | `game:play` | `{ cardIds }` |
| Client → server | `game:yield` | Skip to damage step |
| Client → server | `game:discard` | `{ cardIds }` — defend (may be `[]` if damage is 0) |
| Client → server | `game:chooseNext` | After jester (solo: self) |
| Client → server | `game:soloJester` | Redraw hand (solo) |

### Socket lifecycle

- **`RoomSocket` ref-count** — lobby → game does not kill the connection.
- **Cached `game:state`** — replayed when game screen reuses connection.
- **Hot reload** — `prepareForHotReload()` + `StartupRouteResolver` in `app.dart`.

### UI behaviour

- Tap cards to select; **Play**, **Yield**, **Discard**, **Continue**, **Use solo jester**
- Phase hint (including “Discard (0)” when spades block all damage)
- **This fight:** `Damage dealt: 10/20`, `Shields active: −10 | Current attack: 3`
- `MinimalCard` — rank + suit letter, red/black suits
- Error banner + progress while action is in flight

### Step 4 — discard rules (client + server)

Per `regicide_rules.json` → `damageToPlayer = enemy.attack − cumulativeSpadeShield`.

- If net damage is **0**, player may confirm **Discard (0)** with no cards selected.
- Otherwise discard total must be ≥ pending damage.

### Step 1 — animal companions (server)

Ace is **not** a rank combo:

- Ace alone, ace + one other card, or two aces — valid.
- 2–4 same-rank **numbers only** — combo (no aces).

See `validatePlay` in `back/src/game/gameEngine.ts` and [`CHANGELOG.md`](../CHANGELOG.md).

## Tests

```powershell
cd back && npm test
cd front && flutter test
```

## Next

**4D** — 2–4 players in lobby/game UI, polish, communication UX.
