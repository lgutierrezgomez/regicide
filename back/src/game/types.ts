export type Suit = "hearts" | "diamonds" | "clubs" | "spades";
export type CastleRank = "JACK" | "QUEEN" | "KING";
export type CardKind = "number" | "ace" | "jester" | "enemy";

export interface Card {
  id: string;
  kind: CardKind;
  suit: Suit;
  /** Number 2–10, "A", "JOKER", or castle rank when enemy in hand */
  rank: number | "A" | "JOKER" | CastleRank;
}

export type GamePhase =
  | "STEP1_PLAY_OR_YIELD"
  | "STEP4_DISCARD"
  | "CHOOSE_NEXT_PLAYER"
  | "GAME_OVER";

export type GameOutcome = "playing" | "won" | "lost";

export interface PlayedCardsEntry {
  playerId: string;
  cards: Card[];
}

export interface GameState {
  roomCode: string;
  playerOrder: string[];
  turnIndex: number;
  phase: GamePhase;
  outcome: GameOutcome;
  victoryTier?: "gold" | "silver" | "bronze";
  maxHandSize: number;
  hands: Record<string, Card[]>;
  castle: Card[];
  tavern: Card[];
  discard: Card[];
  currentEnemy: Card | null;
  fightDamage: number;
  fightSpadeShield: number;
  fightPlayed: PlayedCardsEntry[];
  immunityCancelled: boolean;
  /** Last turn action was yield (per player, reset when they take a non-yield turn) */
  lastTurnYielded: Record<string, boolean>;
  pendingDamage: number | null;
  pendingJesterBy: string | null;
  soloJestersAside: Card[];
  soloJestersUsed: number;
}

export type GameAction =
  | { type: "yield" }
  | { type: "play"; cardIds: string[] }
  | { type: "discard"; cardIds: string[] }
  | { type: "chooseNext"; nextPlayerId: string }
  | { type: "soloJester" };

export interface CardPublic {
  id: string;
  kind: CardKind;
  suit: Suit;
  rank: number | string;
}

export interface GamePublicState {
  roomCode: string;
  outcome: GameOutcome;
  victoryTier?: "gold" | "silver" | "bronze";
  phase: GamePhase;
  currentPlayerId: string;
  playerOrder: string[];
  maxHandSize: number;
  handCounts: Record<string, number>;
  tavernCount: number;
  discardCount: number;
  castleCount: number;
  currentEnemy: CardPublic | null;
  fightDamage: number;
  fightSpadeShield: number;
  immunityCancelled: boolean;
  playedAgainstEnemy: Array<{ playerId: string; cards: CardPublic[] }>;
  pendingDamage: number | null;
  pendingChooseNext: boolean;
  soloJestersRemaining: number | null;
  canYield: boolean;
}

export interface GameStateView {
  public: GamePublicState;
  hand: CardPublic[];
}
