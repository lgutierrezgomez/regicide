import rulesJson from "./regicide_rules.json" with { type: "json" };
import type { CastleRank, Suit } from "./types.js";

export const RULES = rulesJson;

export type PlayerCountKey = "1" | "2" | "3" | "4";

export function setupForPlayerCount(count: number) {
  const key = String(Math.min(4, Math.max(1, count))) as PlayerCountKey;
  return RULES.playerCountSetup[key];
}

export function enemyStats(rank: CastleRank) {
  return RULES.enemies[rank];
}

export const SUITS: Suit[] = ["hearts", "diamonds", "clubs", "spades"];
export const CASTLE_RANKS: CastleRank[] = ["JACK", "QUEEN", "KING"];
