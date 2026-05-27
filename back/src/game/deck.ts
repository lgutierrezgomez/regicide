import { randomUUID } from "node:crypto";
import { setupForPlayerCount, SUITS } from "./rules.js";
import type { Card, CastleRank, Suit } from "./types.js";

export function shuffle<T>(items: T[]): T[] {
  const arr = [...items];
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}

function makeNumberCard(suit: Suit, rank: number): Card {
  return { id: randomUUID(), kind: "number", suit, rank };
}

function makeAce(suit: Suit): Card {
  return { id: randomUUID(), kind: "ace", suit, rank: "A" };
}

function makeJester(): Card {
  return { id: randomUUID(), kind: "jester", suit: "hearts", rank: "JOKER" };
}

function makeCastleCard(suit: Suit, rank: CastleRank): Card {
  return { id: randomUUID(), kind: "enemy", suit, rank };
}

/** Top of stack = index 0 (jacks drawn first). */
export function buildCastleDeck(): Card[] {
  const kings = shuffle(SUITS.map((suit) => makeCastleCard(suit, "KING")));
  const queens = shuffle(SUITS.map((suit) => makeCastleCard(suit, "QUEEN")));
  const jacks = shuffle(SUITS.map((suit) => makeCastleCard(suit, "JACK")));
  return [...jacks, ...queens, ...kings];
}

export function buildTavernDeck(playerCount: number): { tavern: Card[]; soloAside: Card[] } {
  const setup = setupForPlayerCount(playerCount);
  const tavern: Card[] = [];
  for (const suit of SUITS) {
    for (let rank = 2; rank <= 10; rank++) {
      tavern.push(makeNumberCard(suit, rank));
    }
    tavern.push(makeAce(suit));
  }
  for (let i = 0; i < setup.jestersInTavern; i++) {
    tavern.push(makeJester());
  }
  const soloAside: Card[] = [];
  if (playerCount === 1 && "soloJestersAside" in setup) {
    const count = setup.soloJestersAside ?? 0;
    for (let i = 0; i < count; i++) {
      soloAside.push(makeJester());
    }
  }
  return { tavern: shuffle(tavern), soloAside };
}

export function dealHands(
  tavern: Card[],
  playerOrder: string[],
  maxHandSize: number,
): { hands: Record<string, Card[]>; remainingTavern: Card[] } {
  const deck = [...tavern];
  const hands: Record<string, Card[]> = {};
  for (const pid of playerOrder) {
    hands[pid] = [];
  }
  for (let c = 0; c < maxHandSize; c++) {
    for (const pid of playerOrder) {
      const card = deck.shift();
      if (card) {
        hands[pid].push(card);
      }
    }
  }
  return { hands, remainingTavern: deck };
}
