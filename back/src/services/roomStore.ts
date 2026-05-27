import { randomUUID } from "node:crypto";
import { config } from "../config.js";
import type { Player, Room, RoomPublicView } from "../types.js";
import { generateRoomCode } from "./roomCode.js";

export class RoomStoreError extends Error {
  constructor(
    message: string,
    readonly code:
      | "ROOM_NOT_FOUND"
      | "ROOM_FULL"
      | "GAME_STARTED"
      | "INVALID_NAME"
      | "NOT_HOST"
      | "NOT_IN_ROOM"
      | "INTERNAL",
  ) {
    super(message);
    this.name = "RoomStoreError";
  }
}

function normalizeDisplayName(name: unknown): string {
  if (typeof name !== "string") {
    throw new RoomStoreError("displayName must be a string", "INVALID_NAME");
  }
  const trimmed = name.trim();
  if (trimmed.length < 1 || trimmed.length > 32) {
    throw new RoomStoreError("displayName must be 1–32 characters", "INVALID_NAME");
  }
  return trimmed;
}

function toPublicView(room: Room, connected: (id: string) => boolean = () => false): RoomPublicView {
  return {
    code: room.code,
    status: room.status,
    hostPlayerId: room.hostPlayerId,
    players: room.players.map((p) => ({
      id: p.id,
      displayName: p.displayName,
      connected: connected(p.id),
    })),
    playerCount: room.players.length,
    maxPlayers: config.maxPlayersPerRoom,
  };
}

export class RoomStore {
  private readonly rooms = new Map<string, Room>();

  create(displayNameRaw: unknown): { room: RoomPublicView; playerId: string } {
    const displayName = normalizeDisplayName(displayNameRaw);
    const code = this.allocateUniqueCode();
    const playerId = randomUUID();
    const now = new Date().toISOString();

    const room: Room = {
      code,
      status: "lobby",
      hostPlayerId: playerId,
      players: [{ id: playerId, displayName, joinedAt: now }],
      createdAt: now,
    };

    this.rooms.set(code, room);
    return { room: toPublicView(room), playerId };
  }

  join(
    codeRaw: string,
    displayNameRaw: unknown,
  ): { room: RoomPublicView; playerId: string } {
    const code = codeRaw.toUpperCase();
    const room = this.rooms.get(code);
    if (!room) {
      throw new RoomStoreError(`Room ${code} not found`, "ROOM_NOT_FOUND");
    }
    if (room.status !== "lobby") {
      throw new RoomStoreError("Game already started", "GAME_STARTED");
    }
    if (room.players.length >= config.maxPlayersPerRoom) {
      throw new RoomStoreError("Room is full", "ROOM_FULL");
    }

    const displayName = normalizeDisplayName(displayNameRaw);
    const playerId = randomUUID();
    const player: Player = {
      id: playerId,
      displayName,
      joinedAt: new Date().toISOString(),
    };
    room.players.push(player);

    return { room: toPublicView(room), playerId };
  }

  get(codeRaw: string, connected: (id: string) => boolean = () => false): RoomPublicView {
    const code = codeRaw.toUpperCase();
    const room = this.requireRoom(code);
    return toPublicView(room, connected);
  }

  hasRoom(codeRaw: string): boolean {
    return this.rooms.has(codeRaw.toUpperCase());
  }

  hasPlayer(codeRaw: string, playerId: string): boolean {
    const code = codeRaw.toUpperCase();
    const room = this.rooms.get(code);
    if (!room) {
      return false;
    }
    return room.players.some((p) => p.id === playerId);
  }

  /** Drop room from memory (after idle cleanup or tests). */
  remove(codeRaw: string): boolean {
    return this.rooms.delete(codeRaw.toUpperCase());
  }

  getRoom(codeRaw: string): Room {
    return this.requireRoom(codeRaw.toUpperCase());
  }

  markInGame(codeRaw: string): void {
    const room = this.requireRoom(codeRaw.toUpperCase());
    room.status = "in_game";
  }

  resetToLobby(codeRaw: string): void {
    const room = this.requireRoom(codeRaw.toUpperCase());
    room.status = "lobby";
  }

  getPlayerDisplayName(codeRaw: string, playerId: string): string | undefined {
    const code = codeRaw.toUpperCase();
    const room = this.rooms.get(code);
    return room?.players.find((p) => p.id === playerId)?.displayName;
  }

  /** Test helper — clear all rooms */
  clear(): void {
    this.rooms.clear();
  }

  private requireRoom(code: string): Room {
    const room = this.rooms.get(code);
    if (!room) {
      throw new RoomStoreError(`Room ${code} not found`, "ROOM_NOT_FOUND");
    }
    return room;
  }

  private allocateUniqueCode(): string {
    for (let attempt = 0; attempt < 20; attempt++) {
      const code = generateRoomCode();
      if (!this.rooms.has(code)) {
        return code;
      }
    }
    throw new RoomStoreError(
      "Failed to allocate unique room code",
      "INTERNAL",
    );
  }
}
