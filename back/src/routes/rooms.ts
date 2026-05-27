import { Router } from "express";
import { GameError } from "../game/gameError.js";
import type { GameService } from "../game/gameService.js";
import type { PresenceService } from "../services/presence.js";
import { RoomStore, RoomStoreError } from "../services/roomStore.js";
import type { GameHub } from "../socket/gameHub.js";
import type { LobbyHub } from "../socket/lobbyHub.js";

function statusForRoomError(err: RoomStoreError): number {
  switch (err.code) {
    case "ROOM_NOT_FOUND":
      return 404;
    case "ROOM_FULL":
    case "GAME_STARTED":
      return 409;
    case "INVALID_NAME":
      return 400;
    case "NOT_HOST":
      return 403;
    case "NOT_IN_ROOM":
      return 403;
    case "INTERNAL":
      return 500;
    default:
      return 500;
  }
}

function statusForGameError(err: GameError): number {
  switch (err.code) {
    case "GAME_NOT_FOUND":
      return 404;
    case "NOT_YOUR_TURN":
    case "INVALID_PHASE":
    case "INVALID_PLAY":
    case "CANNOT_YIELD":
    case "INSUFFICIENT_DISCARD":
      return 400;
    case "GAME_OVER":
      return 409;
    default:
      return 500;
  }
}

export function createRoomsRouter(
  store: RoomStore,
  presence?: PresenceService,
  lobbyHub?: LobbyHub,
  gameService?: GameService,
  gameHub?: GameHub,
) {
  const router = Router();

  const connected = (id: string) => presence?.isConnected(id) ?? false;

  router.post("/", (req, res) => {
    try {
      const result = store.create(req.body?.displayName);
      res.status(201).json(result);
    } catch (err) {
      if (err instanceof RoomStoreError) {
        res.status(statusForRoomError(err)).json({ error: err.message, code: err.code });
        return;
      }
      throw err;
    }
  });

  router.get("/:code", (req, res) => {
    try {
      const room = store.get(req.params.code, connected);
      res.json({ room });
    } catch (err) {
      if (err instanceof RoomStoreError) {
        res.status(statusForRoomError(err)).json({ error: err.message, code: err.code });
        return;
      }
      throw err;
    }
  });

  router.post("/:code/join", (req, res) => {
    try {
      const result = store.join(req.params.code, req.body?.displayName);
      const code = result.room.code;
      const displayName = store.getPlayerDisplayName(code, result.playerId) ?? "";
      lobbyHub?.emitRoomJoined(code, result.playerId, displayName);
      res.status(200).json(result);
    } catch (err) {
      if (err instanceof RoomStoreError) {
        res.status(statusForRoomError(err)).json({ error: err.message, code: err.code });
        return;
      }
      throw err;
    }
  });

  router.post("/:code/start", async (req, res) => {
    const playerId = req.body?.playerId;
    if (typeof playerId !== "string" || !playerId.trim()) {
      res.status(400).json({ error: "playerId is required", code: "INVALID_REQUEST" });
      return;
    }
    try {
      if (!gameService) {
        res.status(500).json({ error: "Game service unavailable" });
        return;
      }
      gameService.start(req.params.code, playerId.trim());
      lobbyHub?.emitGameStarted(req.params.code);
      await gameHub?.emitState(req.params.code);
      const room = store.get(req.params.code, connected);
      res.status(200).json({ room });
    } catch (err) {
      if (err instanceof RoomStoreError) {
        res.status(statusForRoomError(err)).json({ error: err.message, code: err.code });
        return;
      }
      if (err instanceof GameError) {
        res.status(statusForGameError(err)).json({ error: err.message, code: err.code });
        return;
      }
      throw err;
    }
  });

  return router;
}
