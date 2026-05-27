import type { Server } from "socket.io";
import type { PresenceService } from "../services/presence.js";
import type { RoomStore } from "../services/roomStore.js";
import type { RoomPublicView } from "../types.js";

export function roomChannel(code: string): string {
  return `room:${code.toUpperCase()}`;
}

export class LobbyHub {
  constructor(
    private readonly io: Server,
    private readonly store: RoomStore,
    private readonly presence: PresenceService,
  ) {}

  buildLobbyView(code: string): RoomPublicView {
    const room = this.store.get(code);
    return {
      ...room,
      players: room.players.map((p) => ({
        id: p.id,
        displayName: p.displayName,
        connected: this.presence.isConnected(p.id),
      })),
    };
  }

  emitLobbyUpdated(code: string): void {
    const room = this.buildLobbyView(code);
    this.io.to(roomChannel(code)).emit("lobby:updated", { room });
  }

  emitRoomCreated(code: string, socketId: string): void {
    const room = this.buildLobbyView(code);
    this.io.to(socketId).emit("room:created", { room });
  }

  emitRoomJoined(code: string, playerId: string, displayName: string): void {
    const room = this.buildLobbyView(code);
    this.io.to(roomChannel(code)).emit("room:joined", {
      playerId,
      displayName,
      room,
    });
    this.emitLobbyUpdated(code);
  }

  emitGameStarted(code: string): void {
    const room = this.buildLobbyView(code);
    this.io.to(roomChannel(code)).emit("game:started", { room });
  }
}
