import type { Server as HttpServer } from "node:http";
import { Server } from "socket.io";
import { config } from "../config.js";
import { GameError } from "../game/gameError.js";
import type { GameAction } from "../game/types.js";
import type { GameService } from "../game/gameService.js";
import type { PresenceService } from "../services/presence.js";
import { RoomStoreError } from "../services/roomStore.js";
import type { RoomStore } from "../services/roomStore.js";
import type { GameHub } from "./gameHub.js";
import type { LobbyHub } from "./lobbyHub.js";
import { roomChannel } from "./lobbyHub.js";
import type { createIdleRoomCleanup } from "../services/idleRoomCleanup.js";

type IdleRoomCleanup = ReturnType<typeof createIdleRoomCleanup>;

export interface SocketAuth {
  roomCode?: string;
  playerId?: string;
}

export function createSocketServer(httpServer: HttpServer): Server {
  return new Server(httpServer, {
    cors: {
      origin: config.corsOrigins,
      methods: ["GET", "POST"],
    },
  });
}

function emitError(socket: { emit: (event: string, data: unknown) => void }, err: GameError | RoomStoreError): void {
  socket.emit("error", { message: err.message, code: err.code });
}

export function registerSocketHandlers(
  io: Server,
  store: RoomStore,
  presence: PresenceService,
  hub: LobbyHub,
  gameService: GameService,
  gameHub: GameHub,
  idleCleanup?: IdleRoomCleanup,
): void {
  io.use((socket, next) => {
    const auth = socket.handshake.auth as SocketAuth;
    const roomCode = typeof auth.roomCode === "string" ? auth.roomCode.trim() : "";
    const playerId = typeof auth.playerId === "string" ? auth.playerId.trim() : "";

    if (!roomCode || !playerId) {
      next(new Error("AUTH_REQUIRED"));
      return;
    }

    if (!store.hasPlayer(roomCode, playerId)) {
      next(new Error("NOT_IN_ROOM"));
      return;
    }

    socket.data.roomCode = roomCode.toUpperCase();
    socket.data.playerId = playerId;
    next();
  });

  io.on("connection", (socket) => {
    const roomCode = socket.data.roomCode as string;
    const playerId = socket.data.playerId as string;
    const room = store.get(roomCode);

    presence.register(playerId, socket.id);
    socket.join(roomChannel(roomCode));
    idleCleanup?.onConnected(roomCode);

    if (playerId === room.hostPlayerId) {
      hub.emitRoomCreated(roomCode, socket.id);
    }

    hub.emitLobbyUpdated(roomCode);

    if (gameService.hasGame(roomCode)) {
      void gameHub.emitState(roomCode);
    }

    const runGameAction = async (action: GameAction) => {
      try {
        gameService.act(roomCode, playerId, action);
        await gameHub.emitState(roomCode);
      } catch (err) {
        if (err instanceof GameError || err instanceof RoomStoreError) {
          emitError(socket, err);
          return;
        }
        throw err;
      }
    };

    const runHostGameControl = async (fn: () => void | Promise<void>) => {
      try {
        await fn();
      } catch (err) {
        if (err instanceof GameError || err instanceof RoomStoreError) {
          emitError(socket, err);
          return;
        }
        throw err;
      }
    };

    socket.on("game:start", async () => {
      await runHostGameControl(async () => {
        gameService.start(roomCode, playerId);
        hub.emitGameStarted(roomCode);
        await gameHub.emitState(roomCode);
      });
    });

    socket.on("game:returnToLobby", async () => {
      await runHostGameControl(() => {
        gameService.returnToLobby(roomCode, playerId);
        hub.emitLobbyUpdated(roomCode);
      });
    });

    socket.on("game:restart", async () => {
      await runHostGameControl(async () => {
        gameService.restart(roomCode, playerId);
        hub.emitGameStarted(roomCode);
        await gameHub.emitState(roomCode);
      });
    });

    socket.on("game:yield", () => void runGameAction({ type: "yield" }));
    socket.on("game:play", (payload: { cardIds?: string[] }) => {
      const cardIds = Array.isArray(payload?.cardIds) ? payload.cardIds : [];
      void runGameAction({ type: "play", cardIds });
    });
    socket.on("game:discard", (payload: { cardIds?: string[] }) => {
      const cardIds = Array.isArray(payload?.cardIds) ? payload.cardIds : [];
      void runGameAction({ type: "discard", cardIds });
    });
    socket.on("game:chooseNext", (payload: { nextPlayerId?: string }) => {
      const nextPlayerId = payload?.nextPlayerId;
      if (typeof nextPlayerId !== "string") {
        socket.emit("error", { message: "nextPlayerId required", code: "INVALID_PLAY" });
        return;
      }
      void runGameAction({ type: "chooseNext", nextPlayerId });
    });
    socket.on("game:soloJester", () => void runGameAction({ type: "soloJester" }));

    socket.on("disconnect", () => {
      presence.unregister(socket.id);
      hub.emitLobbyUpdated(roomCode);
      idleCleanup?.onDisconnected(roomCode);
    });
  });
}
