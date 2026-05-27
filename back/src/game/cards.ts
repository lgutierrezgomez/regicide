import { enemyStats } from "./rules.js";
import type { Card, CastleRank, Suit } from "./types.js";

export function isCastleEnemy(card: Card): card is Card & { rank: CastleRank } {
  return card.kind === "enemy";
}

export function attackValue(cards: Card[]): number {
  if (cards.length === 0) {
    return 0;
  }
  if (cards.length === 1 && cards[0].kind === "jester") {
    return 0;
  }
  let total = 0;
  let aces = 0;
  for (const c of cards) {
    if (c.kind === "ace") {
      aces++;
      continue;
    }
    if (c.kind === "number") {
      total += c.rank as number;
    } else if (c.kind === "enemy") {
      total += enemyStats(c.rank as CastleRank).inHandValue;
    }
  }
  if (aces > 0) {
    total += aces === cards.length ? aces : 1;
  }
  return total;
}

export function discardValue(card: Card): number {
  if (card.kind === "jester") {
    return 0;
  }
  if (card.kind === "ace") {
    return 1;
  }
  if (card.kind === "number") {
    return card.rank as number;
  }
  return enemyStats(card.rank as CastleRank).inHandValue;
}

export function enemyAttack(card: Card): number {
  return enemyStats(card.rank as CastleRank).attack;
}

export function enemyHealth(card: Card): number {
  return enemyStats(card.rank as CastleRank).health;
}

export function suitsForPowers(cards: Card[]): Suit[] {
  const suits: Suit[] = [];
  const nonJester = cards.filter((c) => c.kind !== "jester");
  if (nonJester.length === 2 && nonJester.every((c) => c.kind === "ace")) {
    if (nonJester[0].suit === nonJester[1].suit) {
      return [nonJester[0].suit];
    }
    return nonJester.map((c) => c.suit);
  }
  const seen = new Set<Suit>();
  for (const c of nonJester) {
    if (c.kind === "ace" && nonJester.length > 1) {
      const partner = nonJester.find((x) => x !== c && x.kind !== "ace");
      if (partner && partner.suit === c.suit) {
        if (!seen.has(c.suit)) {
          suits.push(c.suit);
          seen.add(c.suit);
        }
        continue;
      }
    }
    if (!seen.has(c.suit)) {
      suits.push(c.suit);
      seen.add(c.suit);
    }
  }
  return suits;
}

export function toCardPublic(card: Card) {
  return {
    id: card.id,
    kind: card.kind,
    suit: card.suit,
    rank: card.rank,
  };
}
