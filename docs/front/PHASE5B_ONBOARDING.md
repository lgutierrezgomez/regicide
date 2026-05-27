# Phase 5B — Onboarding & reference UI

**Status:** Implemented 2026-05-20  
**Roadmap:** `docs/ROADMAP.md` Phase 5B items

## Delivered

### Paginated rules dialog

- Asset: `front/assets/instructions/rules_pages.json` (8 pages; derived from `docs/rules/REGICIDE_RULES.md`)
- Loader: `lib/core/rules/game_instructions.dart`
- UI: `lib/presentation/shared/widgets/paginated_instructions_dialog.dart`
- Launcher: `instructions_launch_button.dart`

**Entry points:** Home (compact button under title); game app bar (book icon).

### Symbol legend

- `lib/presentation/game/widgets/game_symbol_legend_panel.dart`
- Wide layout: panel to the **right** of the table (`GameTableArea`)
- Narrow layout: panel **below** the table

### Jester choose-next

- Documented: `docs/front/JESTER_CHOOSE_NEXT.md`
- UX: `ChooseNextPlayerDialog` — auto-opens; bordered player rows; not in app bar or hand

### Security

- `docs/SECURITY.md`
- `back/.env.example`, `front/.env.example`
- `AppConfig` reads `API_BASE_URL` via `--dart-define`

## Maintenance

When rules change, update **both** `docs/rules/REGICIDE_RULES.md` and `front/assets/instructions/rules_pages.json` (keep pages reasonably sized).
