# Regicide — Rules (human-readable)

Source: [official rules PDF](https://www.regicidegame.com/site_files/33132/upload_files/RegicideRulesA4.pdf).  
Machine-oriented version: `regicide_rules.json`.

## Aim

Cooperative game: players defeat **12 enemies** (4 Jacks, 4 Queens, 4 Kings). Win by defeating the last King. Lose if any player cannot satisfy enemy damage, or cannot play a card or yield on their turn.

## Components (standard deck mapping)

| Regicide | Standard deck |
|----------|-----------------|
| Jacks, Queens, Kings | Castle enemies |
| 2–10 | Number cards |
| Animal Companions | Aces |
| Jesters | Jokers |

## Setup

1. **Castle deck:** Shuffle 4 Kings face-down → 4 Queens on top → 4 Jacks on top. Center of table; flip top Jack face-up = first enemy.
2. **Tavern deck:** Shuffle 2–10 + 4 Aces + Jesters (count by player count, see table). Draw pile; shared **discard** beside it.
3. **Deal** to each player up to max hand size (see table).
4. First player: “most recently committed regicide” (house rule / random online).

### Player count table

| Players | Jesters in Tavern | Max hand |
|---------|-------------------|----------|
| 1 | 0 | 8 |
| 2 | 0 | 7 |
| 3 | 1 | 6 |
| 4 | 2 | 5 |

### Enemy stats

| Enemy | Attack | Health |
|-------|--------|--------|
| Jack | 10 | 20 |
| Queen | 15 | 30 |
| King | 20 | 40 |

## Turn structure (four steps)

### Step 1 — Play a card or yield

- Play from hand to table; **number = attack value** (e.g. 7♥ → 7).
- **Yield:** say “Yield”, skip Steps 2–3, go to Step 4. Cannot yield if every *other* player yielded on their last turn.

**Special plays in Step 1:**

- **Animal Companion (Ace):** alone or paired with one other card (not Jester). Adds +1 attack; both suit powers apply at total attack value. Two Aces together = pair only (one suit power if same suit). Ace+same-suit card = suit power once.
- **Combos:** 2, 3, or 4 cards of the **same rank**, combined value ≤ 10. All suit powers at total attack value. Aces cannot be in combos except as ace-pair rules above.
- **Jester:** played alone; attack 0; **cancels enemy immunity**; skip Steps 3–4; chooser picks **any** player to go next. Temporary relaxed communication until next turn starts (see Communication).

**Defeated enemies in hand** (after drawn from Tavern): Jack=10, Queen=15, King=20 for attack or discard defense; suit power normal when played.

### Step 2 — Suit power (mandatory)

| Suit | Power |
|------|--------|
| ♥ Hearts | Shuffle discard; without peeking, take cards equal to attack value facedown under Tavern; return rest face-up to discard. |
| ♦ Diamonds | Current player draws, then clockwise one card at a time until attack value cards drawn. Skip players at max hand. Empty Tavern: no penalty. |
| ♣ Clubs | In Step 3, damage from this play is **doubled**. |
| ♠ Spades | In Step 4, reduce enemy attack by this play’s value. **Cumulative** for all spades vs this enemy until defeated. |

**Order:** If ♥ and ♦ both apply, resolve Hearts before Diamonds.

**Enemy immunity:** Enemy immune to suit powers matching **its suit** (damage number still counts). Jester removes immunity for that enemy.

### Step 3 — Damage and defeat check

- Deal damage = attack value (×2 for clubs in this step).
- **Cumulative** damage vs current enemy from all players this fight.
- If total ≥ enemy health → defeated:
  1. Enemy → discard (if damage **exactly** equals health → enemy face-down on **top of Tavern** instead).
  2. All cards played vs enemy → discard.
  3. Flip next Castle card.
  4. Player who defeated enemy **skips Step 4**, starts new turn at Step 1 vs new enemy.

### Step 4 — Suffer damage

- If enemy not defeated: current player **discards cards one at a time** until cumulative discard value reaches the enemy's attack (minus cumulative spade shield). You must **stop immediately** the moment the threshold is met — you cannot keep discarding once the damage is absorbed. Over-discarding by a single card is allowed (e.g. needing 5 with a single 7 in hand spends the 7), but you may not keep adding cards after the threshold.
- Ace = 1 when discarding; Jester = 0.
- Cannot pay → player dies, **everyone loses**.
- Empty hand is OK if you can still act on future turns. Next player clockwise, Step 1.

## Communication

- **Forbidden:** anything revealing or suggesting hand contents.
- **Allowed:** public info (e.g. hand size, Tavern count).
- **After Jester:** until next turn starts, vague “I want to go next” / “good play” OK; still no hand contents.

## Game end

- **Win:** last King defeated.
- **Lose:** cannot pay damage; or on your turn cannot play a card **or** yield.

## Solo mode (optional variant)

- 0 Jesters in Tavern; 2 Jesters set aside as flip powers: discard hand, refill to 8 (not “draw” for diamond immunity). Usable start of Step 1 or Step 4. Max 2 uses. Victories: 0 jesters = Gold, 1 = Silver, 2 = Bronze.

## Design credit

Paul Abrahams, Luke Badger, Andy Richdale — art Sketchgoblin.
