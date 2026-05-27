import { createServer as createHttpServer, type Server as HttpServer } from "node:http";
import type { Express } from "express";
import type { Server as SocketServer } from "socket.io";
import { GameService } from "./game/gameService.js";
import { createBaseApp, mountNotFound } from "./app.js";
import { createRoomsRouter } from "./routes/rooms.js";
import { RoomStore } from "./services/roomStore.js";
import { PresenceService } from "./services/presence.js";
import { GameHub } from "./socket/gameHub.js";
import { LobbyHub } from "./socket/lobbyHub.js";
import { config } from "./config.js";
import { createIdleRoomCleanup } from "./services/idleRoomCleanup.js";
import { createSocketServer, registerSocketHandlers } from "./socket/socketServer.js";

export interface AppContext {
  app: Express;
  httpServer: HttpServer;
  io: SocketServer;
  roomStore: RoomStore;
  presence: PresenceService;
  gameService: GameService;
  lobbyHub: LobbyHub;
  gameHub: GameHub;
}

export function createAppContext(): AppContext {
  const roomStore = new RoomStore();
  const presence = new PresenceService();
  const gameService = new GameService(roomStore);
  const app = createBaseApp();
  const httpServer = createHttpServer(app);
  const io = createSocketServer(httpServer);
  const lobbyHub = new LobbyHub(io, roomStore, presence);
  const gameHub = new GameHub(io, gameService);

  app.use("/rooms", createRoomsRouter(roomStore, presence, lobbyHub, gameService, gameHub));
  mountNotFound(app);

  const idleCleanup =
    config.roomIdleCleanupMs > 0
      ? createIdleRoomCleanup({
          store: roomStore,
          presence,
          gameService,
          idleMs: config.roomIdleCleanupMs,
        })
      : undefined;

  registerSocketHandlers(
    io,
    roomStore,
    presence,
    lobbyHub,
    gameService,
    gameHub,
    idleCleanup,
  );

  return { app, httpServer, io, roomStore, presence, gameService, lobbyHub, gameHub };
}
