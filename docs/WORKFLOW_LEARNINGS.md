# Workflow learnings (index)

**Machine-readable source of truth:** [`workflow_learnings.json`](workflow_learnings.json)

Use that file for agents, scripts, and future append-only notes on:

- What to **reuse** vs **improve** vs do **differently** when digitizing another board game
- **Board UI** options (asset-first Flutter, panels-first, Flame, etc.)
- **Code-building strategies** (evidence-backed)
- **Prompt patterns** and anti-patterns

## How to extend

1. Edit `workflow_learnings.json` only (keep valid JSON).
2. Add entries under `codeBuildingStrategies.entries` or `promptPatterns.entries` with a unique `id` and `date` (ISO `YYYY-MM-DD`).
3. Set top-level `lastUpdated`.
4. Optionally add a one-line note in `CHANGELOG.md` if the learning changed team practice.

## Human summary

Derived from Regicide Phase 5 (2026-05-20): keep authoritative Node + Socket.IO + Clean Architecture + docs rhythm; improve protocol (`legalActions`, layout JSON); avoid custom-painted perspective tables as the first UI—prefer panels-first, then asset-backed `Stack` layout.
