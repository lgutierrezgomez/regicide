import type { GameService } from "../game/gameService.js";
import type { PresenceService } from "./presence.js";
import type { RoomStore } from "./roomStore.js";

/** Removes room + game state when every player has been offline for [idleMs]. */
export function createIdleRoomCleanup(deps: {
  store: RoomStore;
  presence: PresenceService;
  gameService: GameService;
  idleMs: number;
}) {
  const timers = new Map<string, ReturnType<typeof setTimeout>>();

  function cancel(roomCode: string): void {
    const code = roomCode.toUpperCase();
    const timer = timers.get(code);
    if (timer) {
      clearTimeout(timer);
      timers.delete(code);
    }
  }

  function onConnected(roomCode: string): void {
    cancel(roomCode);
  }

  function onDisconnected(roomCode: string): void {
    const code = roomCode.toUpperCase();
    cancel(code);
    timers.set(
      code,
      setTimeout(() => {
        timers.delete(code);
        if (!deps.store.hasRoom(code)) {
          return;
        }
        const room = deps.store.getRoom(code);
        const anyOnline = room.players.some((p) => deps.presence.isConnected(p.id));
        if (!anyOnline) {
          deps.gameService.clear(code);
          deps.store.remove(code);
        }
      }, deps.idleMs),
    );
  }

  function dispose(): void {
    for (const timer of timers.values()) {
      clearTimeout(timer);
    }
    timers.clear();
  }

  return { onConnected, onDisconnected, dispose };
}
