import { attackValue, discardValue, enemyAttack, enemyHealth, isCastleEnemy, suitsForPowers } from "./cards.js";
import { buildCastleDeck, buildTavernDeck, dealHands, shuffle } from "./deck.js";
import { GameError } from "./gameError.js";
import { setupForPlayerCount } from "./rules.js";
import type { Card, GameAction, GameState, Suit } from "./types.js";

export function createInitialState(roomCode: string, playerOrder: string[]): GameState {
  const count = playerOrder.length;
  const setup = setupForPlayerCount(count);
  const castle = buildCastleDeck();
  const { tavern: tavernRaw, soloAside } = buildTavernDeck(count);
  const { hands, remainingTavern } = dealHands(tavernRaw, playerOrder, setup.maxHandSize);
  const currentEnemy = castle.shift() ?? null;

  const lastTurnYielded: Record<string, boolean> = {};
  for (const pid of playerOrder) {
    lastTurnYielded[pid] = false;
  }

  return {
    roomCode,
    playerOrder,
    turnIndex: 0,
    phase: "STEP1_PLAY_OR_YIELD",
    outcome: "playing",
    maxHandSize: setup.maxHandSize,
    hands,
    castle,
    tavern: remainingTavern,
    discard: [],
    currentEnemy,
    fightDamage: 0,
    fightSpadeShield: 0,
    fightPlayed: [],
    immunityCancelled: false,
    lastTurnYielded,
    pendingDamage: null,
    pendingJesterBy: null,
    soloJestersAside: soloAside,
    soloJestersUsed: 0,
  };
}

export function currentPlayerId(state: GameState): string {
  return state.playerOrder[state.turnIndex];
}

function assertPlaying(state: GameState): void {
  if (state.outcome !== "playing") {
    throw new GameError("Game is over", "GAME_OVER");
  }
}

function assertTurn(state: GameState, playerId: string): void {
  if (currentPlayerId(state) !== playerId) {
    throw new GameError("Not your turn", "NOT_YOUR_TURN");
  }
}

/** Returns the card objects for the given ids without mutating `hand`.
 * Throws "Card not in hand" if any id is missing or the same physical card
 * is referenced twice. The caller is responsible for calling
 * [removeFromHand] only after every validation that could throw has passed,
 * so a failed action leaves the hand untouched. */
function peekHandCards(hand: Card[], cardIds: string[]): Card[] {
  const usedIdx = new Set<number>();
  const cards: Card[] = [];
  for (const id of cardIds) {
    const idx = hand.findIndex((c, i) => c.id === id && !usedIdx.has(i));
    if (idx === -1) {
      throw new GameError("Card not in hand", "INVALID_PLAY");
    }
    usedIdx.add(idx);
    cards.push(hand[idx]);
  }
  return cards;
}

function removeFromHand(hand: Card[], cards: Card[]): void {
  const indices: number[] = [];
  for (const card of cards) {
    const idx = hand.indexOf(card);
    if (idx >= 0 && !indices.includes(idx)) {
      indices.push(idx);
    }
  }
  indices.sort((a, b) => b - a).forEach((i) => hand.splice(i, 1));
}

function validatePlay(cards: Card[]): void {
  if (cards.length === 0) {
    throw new GameError("No cards played", "INVALID_PLAY");
  }
  if (cards.length === 1 && cards[0].kind === "jester") {
    return;
  }
  if (cards.some((c) => c.kind === "jester")) {
    throw new GameError("Jester must be played alone", "INVALID_PLAY");
  }

  const nonJester = cards.filter((c) => c.kind !== "jester");
  const aceCount = nonJester.filter((c) => c.kind === "ace").length;

  // Single card (number, ace alone, or defeated enemy in hand).
  if (nonJester.length === 1) {
    return;
  }

  // Animal companion: two aces (ace pair).
  if (nonJester.length === 2 && aceCount === 2) {
    return;
  }

  // Animal companion + one other non-jester card — not a rank combo.
  if (nonJester.length === 2 && aceCount === 1) {
    return;
  }

  if (aceCount > 0) {
    throw new GameError("Invalid ace play", "INVALID_PLAY");
  }

  // Rank combo: 2–4 number cards, same rank, no aces (per regicide_rules.json).
  if (![2, 3, 4].includes(cards.length)) {
    throw new GameError("Combo must be 2, 3, or 4 cards", "INVALID_PLAY");
  }
  if (!nonJester.every((c) => c.kind === "number")) {
    throw new GameError("Combo must be same rank numbers only", "INVALID_PLAY");
  }
  const rank = nonJester[0].rank;
  if (!nonJester.every((c) => c.rank === rank)) {
    throw new GameError("Combo cards must match rank", "INVALID_PLAY");
  }
  if (attackValue(cards) > 10) {
    throw new GameError("Combo total cannot exceed 10", "INVALID_PLAY");
  }
}

export function canYield(state: GameState, playerId: string): boolean {
  const others = state.playerOrder.filter((id) => id !== playerId);
  return !others.every((id) => state.lastTurnYielded[id] === true);
}

function suitPowerActive(state: GameState, suit: Suit): boolean {
  if (!state.currentEnemy || !isCastleEnemy(state.currentEnemy)) {
    return false;
  }
  if (state.immunityCancelled) {
    return true;
  }
  return state.currentEnemy.suit !== suit;
}

function applyHearts(state: GameState, amount: number): void {
  if (amount <= 0 || state.discard.length === 0) {
    return;
  }
  const pile = shuffle(state.discard);
  const move = pile.splice(0, Math.min(amount, pile.length));
  state.tavern = [...state.tavern, ...move];
  state.discard = pile;
}

function drawOne(state: GameState, playerId: string): void {
  if (state.tavern.length === 0) {
    return;
  }
  const hand = state.hands[playerId];
  if (hand.length >= state.maxHandSize) {
    return;
  }
  const card = state.tavern.shift();
  if (card) {
    hand.push(card);
  }
}

function applyDiamonds(state: GameState, _playerId: string, amount: number): void {
  if (amount <= 0) {
    return;
  }
  const order = [
    ...state.playerOrder.slice(state.turnIndex),
    ...state.playerOrder.slice(0, state.turnIndex),
  ];
  let drawn = 0;
  let idx = 0;
  const maxAttempts = amount * order.length * 2;
  while (drawn < amount && idx < maxAttempts) {
    const pid = order[idx % order.length];
    idx++;
    const before = state.hands[pid].length;
    drawOne(state, pid);
    if (state.hands[pid].length > before) {
      drawn++;
    }
    if (state.tavern.length === 0) {
      break;
    }
  }
}

function resetFight(state: GameState): void {
  state.fightDamage = 0;
  state.fightSpadeShield = 0;
  state.fightPlayed = [];
  state.immunityCancelled = false;
}

function revealNextEnemy(state: GameState): boolean {
  const next = state.castle.shift() ?? null;
  state.currentEnemy = next;
  resetFight(state);
  if (!next) {
    state.outcome = "won";
    state.phase = "GAME_OVER";
    if (state.playerOrder.length === 1) {
      const used = state.soloJestersUsed;
      state.victoryTier = used === 0 ? "gold" : used === 1 ? "silver" : "bronze";
    }
    return false;
  }
  return true;
}

function handleEnemyDefeat(state: GameState, exact: boolean): void {
  const enemy = state.currentEnemy;
  if (!enemy) {
    return;
  }
  for (const entry of state.fightPlayed) {
    state.discard.push(...entry.cards);
  }
  state.fightPlayed = [];
  if (exact) {
    state.tavern = [enemy, ...state.tavern];
  } else {
    state.discard.push(enemy);
  }
  revealNextEnemy(state);
}

function applySpadeShield(state: GameState, cards: Card[]): void {
  const atk = attackValue(cards);
  for (const suit of suitsForPowers(cards)) {
    if (suit === "spades" && suitPowerActive(state, "spades")) {
      state.fightSpadeShield += atk;
    }
  }
}

function resolveDamageStep(state: GameState, cards: Card[], attack: number): boolean {
  let damage = attack;
  for (const suit of suitsForPowers(cards)) {
    if (suit === "clubs" && suitPowerActive(state, "clubs")) {
      damage *= 2;
    }
  }
  state.fightDamage += damage;
  const enemy = state.currentEnemy;
  if (!enemy || !isCastleEnemy(enemy)) {
    return false;
  }
  const health = enemyHealth(enemy);
  if (state.fightDamage >= health) {
    handleEnemyDefeat(state, state.fightDamage === health);
    return true;
  }
  return false;
}

function maxDiscardFromHand(hand: Card[]): number {
  return hand.reduce((sum, card) => sum + discardValue(card), 0);
}

/** Rules: cannot pay required discard → everyone loses (checked when Step 4 begins). */
function applyCannotPayDamageOrLose(
  state: GameState,
  playerId: string,
  required: number,
): boolean {
  if (required <= 0) {
    return false;
  }
  const hand = state.hands[playerId];
  if (maxDiscardFromHand(hand) < required) {
    state.outcome = "lost";
    state.phase = "GAME_OVER";
    state.pendingDamage = null;
    return true;
  }
  return false;
}

function beginStep4(state: GameState): void {
  const enemy = state.currentEnemy;
  if (!enemy || !isCastleEnemy(enemy)) {
    return;
  }
  const raw = enemyAttack(enemy);
  const damage = Math.max(0, raw - state.fightSpadeShield);
  const pid = currentPlayerId(state);
  if (applyCannotPayDamageOrLose(state, pid, damage)) {
    return;
  }
  state.pendingDamage = damage;
  state.phase = "STEP4_DISCARD";
}

function advanceTurn(state: GameState): void {
  state.turnIndex = (state.turnIndex + 1) % state.playerOrder.length;
  state.phase = "STEP1_PLAY_OR_YIELD";
  state.pendingDamage = null;
  checkMustActOrLose(state);
}

function setTurnTo(state: GameState, playerId: string): void {
  const idx = state.playerOrder.indexOf(playerId);
  if (idx === -1) {
    throw new GameError("Player not in game", "INVALID_PLAY");
  }
  state.turnIndex = idx;
  state.phase = "STEP1_PLAY_OR_YIELD";
  state.pendingDamage = null;
  state.pendingJesterBy = null;
  checkMustActOrLose(state);
}

function checkMustActOrLose(state: GameState): void {
  if (state.outcome !== "playing" || state.phase !== "STEP1_PLAY_OR_YIELD") {
    return;
  }
  const pid = currentPlayerId(state);
  const hand = state.hands[pid];
  const yieldOk = canYield(state, pid);
  if (hand.length === 0 && !yieldOk) {
    state.outcome = "lost";
    state.phase = "GAME_OVER";
  }
}

function resolvePlay(state: GameState, playerId: string, cards: Card[]): void {
  state.lastTurnYielded[playerId] = false;
  const attack = attackValue(cards);
  state.fightPlayed.push({ playerId, cards: [...cards] });

  if (cards.length === 1 && cards[0].kind === "jester") {
    state.immunityCancelled = true;
    state.pendingJesterBy = playerId;
    state.phase = "CHOOSE_NEXT_PLAYER";
    return;
  }

  const powerSuits = suitsForPowers(cards);
  const ordered: Suit[] = [];
  if (powerSuits.includes("hearts")) {
    ordered.push("hearts");
  }
  if (powerSuits.includes("diamonds")) {
    ordered.push("diamonds");
  }
  for (const s of powerSuits) {
    if (s !== "hearts" && s !== "diamonds" && !ordered.includes(s)) {
      ordered.push(s);
    }
  }

  for (const suit of ordered) {
    if (!suitPowerActive(state, suit)) {
      continue;
    }
    if (suit === "hearts") {
      applyHearts(state, attack);
    } else if (suit === "diamonds") {
      applyDiamonds(state, playerId, attack);
    }
  }

  applySpadeShield(state, cards);

  const defeated = resolveDamageStep(state, cards, attack);
  if (defeated) {
    if (state.outcome === "won") {
      return;
    }
    state.phase = "STEP1_PLAY_OR_YIELD";
    checkMustActOrLose(state);
    return;
  }

  beginStep4(state);
}

function resolveYield(state: GameState, playerId: string): void {
  if (!canYield(state, playerId)) {
    throw new GameError("Cannot yield — all others yielded last turn", "CANNOT_YIELD");
  }
  state.lastTurnYielded[playerId] = true;
  beginStep4(state);
}

/** Throws if the discard request doesn't match the Regicide step 4 rule:
 * `pendingDamage === 0` must be empty (acknowledge), otherwise exactly one. */
function validateDiscardCount(pendingDamage: number, count: number): void {
  if (pendingDamage === 0) {
    if (count !== 0) {
      throw new GameError("Nothing to discard", "INVALID_DISCARD");
    }
    return;
  }
  if (count !== 1) {
    throw new GameError("Discard one card at a time", "INVALID_DISCARD");
  }
}

/** Step 4 discard: one card at a time. Stop immediately when cumulative
 * discards meet or exceed `pendingDamage` (Regicide rule).
 *
 * Caller must have validated `cards.length` via [validateDiscardCount] and
 * already removed the card(s) from the player's hand. */
function resolveDiscard(state: GameState, _playerId: string, cards: Card[]): void {
  if (cards.length === 0) {
    state.pendingDamage = null;
    advanceTurn(state);
    return;
  }

  state.discard.push(cards[0]);
  const required = state.pendingDamage ?? 0;
  const newPending = Math.max(0, required - discardValue(cards[0]));
  if (newPending === 0) {
    state.pendingDamage = null;
    advanceTurn(state);
  } else {
    state.pendingDamage = newPending;
  }
}

export function applyAction(state: GameState, playerId: string, action: GameAction): GameState {
  assertPlaying(state);

  if (action.type === "soloJester") {
    if (state.playerOrder.length !== 1) {
      throw new GameError("Solo jester only in 1-player mode", "INVALID_PLAY");
    }
    assertTurn(state, playerId);
    if (state.phase !== "STEP1_PLAY_OR_YIELD" && state.phase !== "STEP4_DISCARD") {
      throw new GameError("Solo jester at step 1 or before damage only", "INVALID_PHASE");
    }
    if (state.soloJestersAside.length === 0) {
      throw new GameError("No solo jesters left", "INVALID_PLAY");
    }
    state.soloJestersAside.pop();
    state.soloJestersUsed++;
    state.hands[playerId] = [];
    while (state.hands[playerId].length < state.maxHandSize && state.tavern.length > 0) {
      const c = state.tavern.shift();
      if (c) {
        state.hands[playerId].push(c);
      }
    }
    return state;
  }

  if (action.type === "chooseNext") {
    if (state.phase !== "CHOOSE_NEXT_PLAYER" || state.pendingJesterBy !== playerId) {
      throw new GameError("Not choosing next player", "INVALID_PHASE");
    }
    setTurnTo(state, action.nextPlayerId);
    return state;
  }

  if (action.type === "discard") {
    if (state.phase !== "STEP4_DISCARD") {
      throw new GameError("Not in discard phase", "INVALID_PHASE");
    }
    assertTurn(state, playerId);
    validateDiscardCount(state.pendingDamage ?? 0, action.cardIds.length);
    const hand = state.hands[playerId];
    const cards = peekHandCards(hand, action.cardIds);
    removeFromHand(hand, cards);
    resolveDiscard(state, playerId, cards);
    return state;
  }

  if (state.phase !== "STEP1_PLAY_OR_YIELD") {
    throw new GameError("Cannot play or yield now", "INVALID_PHASE");
  }
  assertTurn(state, playerId);

  if (action.type === "yield") {
    resolveYield(state, playerId);
    return state;
  }

  const hand = state.hands[playerId];
  const cards = peekHandCards(hand, action.cardIds);
  validatePlay(cards);
  removeFromHand(hand, cards);
  resolvePlay(state, playerId, cards);
  return state;
}
