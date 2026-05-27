import type { Server } from "socket.io";
import { buildViewForPlayer } from "../game/gameView.js";
import type { GameService } from "../game/gameService.js";
import { roomChannel } from "./lobbyHub.js";

export class GameHub {
  constructor(
    private readonly io: Server,
    private readonly gameService: GameService,
  ) {}

  async emitState(roomCode: string): Promise<void> {
    const state = this.gameService.getState(roomCode);
    if (!state) {
      return;
    }
    const sockets = await this.io.in(roomChannel(roomCode)).fetchSockets();
    for (const socket of sockets) {
      const playerId = socket.data.playerId as string | undefined;
      if (!playerId) {
        continue;
      }
      const view = buildViewForPlayer(state, playerId);
      socket.emit("game:state", view);
    }
  }
}
