import { applyAction, createInitialState } from "./gameEngine.js";
import { GameError } from "./gameError.js";
import type { GameAction, GameState } from "./types.js";
import type { RoomStore } from "../services/roomStore.js";
import { RoomStoreError } from "../services/roomStore.js";

export class GameService {
  private readonly games = new Map<string, GameState>();

  constructor(private readonly roomStore: RoomStore) {}

  hasGame(roomCode: string): boolean {
    return this.games.has(roomCode.toUpperCase());
  }

  getState(roomCode: string): GameState | undefined {
    return this.games.get(roomCode.toUpperCase());
  }

  start(roomCodeRaw: string, hostPlayerId: string): GameState {
    const code = roomCodeRaw.toUpperCase();
    const room = this.roomStore.getRoom(code);
    if (room.status !== "lobby") {
      throw new RoomStoreError("Game already started", "GAME_STARTED");
    }
    if (room.hostPlayerId !== hostPlayerId) {
      throw new RoomStoreError("Only the host can start the game", "NOT_HOST");
    }
    const playerOrder = room.players.map((p) => p.id);
    const state = createInitialState(code, playerOrder);
    this.games.set(code, state);
    this.roomStore.markInGame(code);
    return state;
  }

  act(roomCodeRaw: string, playerId: string, action: GameAction): GameState {
    const code = roomCodeRaw.toUpperCase();
    const state = this.games.get(code);
    if (!state) {
      throw new GameError("No active game for room", "GAME_NOT_FOUND");
    }
    if (!this.roomStore.hasPlayer(code, playerId)) {
      throw new GameError("Player not in room", "NOT_YOUR_TURN");
    }
    applyAction(state, playerId, action);
    return state;
  }

  returnToLobby(roomCodeRaw: string, hostPlayerId: string): void {
    const code = roomCodeRaw.toUpperCase();
    const room = this.roomStore.getRoom(code);
    if (room.hostPlayerId !== hostPlayerId) {
      throw new RoomStoreError("Only the host can return to lobby", "NOT_HOST");
    }
    this.clear(code);
    this.roomStore.resetToLobby(code);
  }

  restart(roomCodeRaw: string, hostPlayerId: string): GameState {
    this.returnToLobby(roomCodeRaw, hostPlayerId);
    return this.start(roomCodeRaw, hostPlayerId);
  }

  clear(roomCode?: string): void {
    if (roomCode) {
      this.games.delete(roomCode.toUpperCase());
    } else {
      this.games.clear();
    }
  }
}
