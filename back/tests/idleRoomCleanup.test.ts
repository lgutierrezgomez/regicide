import { describe, expect, it, vi } from "vitest";
import { GameService } from "../src/game/gameService.js";
import { createIdleRoomCleanup } from "../src/services/idleRoomCleanup.js";
import { PresenceService } from "../src/services/presence.js";
import { RoomStore } from "../src/services/roomStore.js";

describe("idleRoomCleanup", () => {
  it("removes room and game when all players stay offline", () => {
    vi.useFakeTimers();
    const store = new RoomStore();
    const presence = new PresenceService();
    const gameService = new GameService(store);
    const { room, playerId } = store.create("Solo");
    const code = room.code;

    gameService.start(code, playerId);
    expect(gameService.hasGame(code)).toBe(true);

    presence.register(playerId, "sock-1");
    presence.unregister("sock-1");
    const cleanup = createIdleRoomCleanup({
      store,
      presence,
      gameService,
      idleMs: 60_000,
    });

    cleanup.onDisconnected(code);
    vi.advanceTimersByTime(60_000);

    expect(store.hasRoom(code)).toBe(false);
    expect(gameService.hasGame(code)).toBe(false);
    vi.useRealTimers();
  });

  it("cancels cleanup when player reconnects", () => {
    vi.useFakeTimers();
    const store = new RoomStore();
    const presence = new PresenceService();
    const gameService = new GameService(store);
    const { room, playerId } = store.create("Solo");
    const code = room.code;

    const cleanup = createIdleRoomCleanup({
      store,
      presence,
      gameService,
      idleMs: 60_000,
    });

    cleanup.onDisconnected(code);
    vi.advanceTimersByTime(30_000);
    presence.register(playerId, "sock-2");
    cleanup.onConnected(code);
    vi.advanceTimersByTime(60_000);

    expect(store.hasRoom(code)).toBe(true);
    vi.useRealTimers();
  });
});
