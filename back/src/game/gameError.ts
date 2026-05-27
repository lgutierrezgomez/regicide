export class GameError extends Error {
  constructor(
    message: string,
    readonly code:
      | "GAME_NOT_FOUND"
      | "NOT_YOUR_TURN"
      | "INVALID_PHASE"
      | "INVALID_PLAY"
      | "CANNOT_YIELD"
      | "INSUFFICIENT_DISCARD"
      | "INVALID_DISCARD"
      | "NOT_HOST"
      | "GAME_OVER",
  ) {
    super(message);
    this.name = "GameError";
  }
}
