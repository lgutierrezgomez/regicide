# Phase 5 — Game table (perspective layout)

**Status:** Solo playtest complete; multiplayer table UX step complete (paused); full 2–4p playtest + art/animations pending  
**Last updated:** 2026-05-20

## Module layout (edit table look here)

All perspective table code lives under one folder. **`GamePage` only imports `GameTableArea`** from this module.

```
front/lib/presentation/game/table/
  table.dart                      # barrel export + library doc
  table_layout.dart               # page padding around table
  table_perspective_geometry.dart # trapezoid math + TablePerspective tuning
  table_size_calculator.dart      # fit table in available height
  poker_table_surface.dart        # wood + felt CustomPaint
  poker_table_frame.dart          # clip felt, rails, center HUD slot
  felt_hud_layout.dart            # HUD bottom anchor + max width on felt
  perspective_poker_table.dart    # visual-only table (no GameBloc)
  game_table_area.dart            # wires game state → table + hand
  opponent_seat_layout.dart       # 2–4 player seat positions
  table_opponent_rails.dart       # opponent widgets on rails
  castle_enemy_card.dart          # enemy placeholder (person icon)
  opponent_seat_card.dart         # opponent rail chip (name / hand / n·max, turn border)
```

### What to change for visual tweaks

| Goal | File(s) |
|------|---------|
| Trapezoid shape, rail width, corner radius | `table_perspective_geometry.dart` → `TablePerspective` |
| Side opponent height (3p) | `TablePerspective.leftRailEdgeT` / `rightRailEdgeT` in `poker_table_frame.dart` (no rotation; cards use `CardOrientation` only) |
| Wood/felt colors, shadow, grain | `poker_table_surface.dart`, `app_colors.dart` |
| Felt HUD vertical position / max width | `felt_hud_layout.dart` (`bottomAtFraction` = 0.75), `poker_table_frame.dart` |
| Gap between HUD cards | `widgets/game_table_center.dart` → `_kHudCardGap` (24px) |
| HUD card fonts (enemy / fight) | `widgets/game_enemy_panel.dart`, `widgets/game_fight_panel.dart` (`feltHud: true`) |
| Table size vs viewport | `table_size_calculator.dart` |
| Enemy card placeholder art | `castle_enemy_card.dart` (person icon; stats in `widgets/game_enemy_panel.dart`) |
| Opponent rail seats | `opponent_seat_card.dart` via `widgets/game_opponent_seat.dart` (no card column) |

### Outside the table module (do not need edits for table shape)

| Area | Path |
|------|------|
| Felt HUD (three stacked cards) | `widgets/game_table_center.dart` — enemy, fight, piles; 24px between cards |
| Your hand + Play / solo jester | `widgets/game_hand_*.dart` (right of hand strip) |
| Turn bar (phase, Yield, Discard, connection, table talk) | `widgets/game_turn_app_bar.dart` |
| Page background | `app_colors.dart` → `AppColors.gameScaffold` (`#E8EDE4`) |
| Card size / tilt on rails | `widgets/play_card_layout.dart`, `standing_card_transform.dart` |

## Perspective design

- **Seated view** — narrow **far** edge (opponents), wide **near** edge (you).
- **Wood** — outer trapezoid, rounded corners (`woodCornerRadius`).
- **Felt** — same trapezoid, uniformly inset toward center (`railInsetFraction`); parallel rails on all four sides.
- **Your hand** — below the table, centered strip; not on the felt.
- **Turn UI** — `GameTurnAppBar` (phase, Yield, Discard, connection + communication in bar); Play + solo jester on hand strip right.
- **Scaffold** — light green-gray `gameScaffold` behind the table.

## Felt HUD (solo playtested)

Center column on the felt, bottom-anchored at **75%** of felt height (`FeltHudLayout.bottomAtFraction`). Width capped to trapezoid at that depth (`feltHudMaxWidth`).

Three separate **`_HudCard`** panels (Material surface, 10px radius, light elevation), **24px** vertical gap between each:

| Card | Widget | Content |
|------|--------|---------|
| 1 | `GameEnemyPanel` (`feltHud: true`) | `CastleEnemyCard` + rank/stats/ability (larger type) |
| 2 | `GameFightPanel` (`feltHud: true`, compact, centered) | Damage / shields / attack lines (15px) |
| 3 | `GamePilesRow` (compact, centered) | Tavern, discard, solo jester counts |

Piles are no longer a loose row below fight; they share the same card chrome and spacing as enemy and fight.

## Opponent rails

Compact seat cards (name, hand, `n / max`, green/gray border), counts from `handCounts`:

| Players | Placement |
|---------|-----------|
| 2 | 1 on far (top) |
| 3 | left + right |
| 4+ | far + left + right |

## Layout fixes (2026-05-20)

- Removed `FittedBox` (zero-size table on web).
- `GameHandActions`: `IntrinsicWidth` (fixes infinite width in `Row`).
- `CommunicationReminderCard(compact: true)` on game screen (replaces duplicate inline widget).
- Deleted unused `GameActionBar`, `GamePhaseHint` (superseded by app bar + hand actions).
- Renamed tuning type to `TablePerspective`; split `PlayCardLayout` for card chrome.

## Tests

```powershell
cd front && flutter test test/table_perspective_geometry_test.dart test/game_table_layout_test.dart
```

## Related

- Phase 5 overview: `docs/front/PHASE5.md`
- Changelog: `docs/CHANGELOG.md` (2026-05-20 table module entry)
