# Phase 4D — Multiplayer polish

**Status:** Complete (2026-05-20)

## Scope

Client-only polish for 2–4 players. Backend/socket protocol unchanged.

## Delivered

### Lobby

- **Host badge** inline next to player name (`You · Host` / `Host`), not far-right chip
- **Invite link** — copy full `?room=CODE` URL (`join_invite_url.dart`, lobby card)
- **Multiplayer vs solo** host hint (`LobbyHostHint`)
- **Communication reminder** card (table-talk rules from `regicide_rules.json`)

### Game

- **Player roster** when 2+ players (`GamePlayersPanel`) — turn highlight, hand counts
- **Turn copy** — “Your turn” / “Waiting for {name}…”
- **Choose next** — `ChooseNextPlayerDialog` after jester (listed players); solo uses Continue
- **Player names** loaded from `GET /rooms/:code` on game start (`GameBloc` + `playerDisplayNames`)
- Communication reminder on game screen

### Dev tooling

- `scripts/run-multiplayer-chrome.ps1` — **1–4** Chrome profiles, `-RoomCode`, `-ChromeOnly`, skip flags, test checklist

## Key paths

```
front/lib/core/web/join_invite_url.dart
front/lib/presentation/lobby/widgets/lobby_player_row.dart
front/lib/presentation/lobby/widgets/lobby_room_code_card.dart
front/lib/presentation/game/widgets/game_players_panel.dart
front/lib/presentation/game/widgets/choose_next_player_dialog.dart
front/lib/presentation/shared/widgets/communication_reminder_card.dart
scripts/run-multiplayer-chrome.ps1
```

## Tests

- `front/test/join_invite_url_test.dart`
- `game_bloc_test.dart` — room fetch for display names

## Next (roadmap)

Phase **5** — error states, assets, deploy, full E2E playtest.
