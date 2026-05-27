/** Tracks live socket connections per player (for lobby `connected` flags). */
export class PresenceService {
  /** playerId → set of socket ids (supports multiple tabs) */
  private readonly byPlayer = new Map<string, Set<string>>();
  /** socketId → playerId */
  private readonly bySocket = new Map<string, string>();

  register(playerId: string, socketId: string): void {
    this.bySocket.set(socketId, playerId);
    let sockets = this.byPlayer.get(playerId);
    if (!sockets) {
      sockets = new Set();
      this.byPlayer.set(playerId, sockets);
    }
    sockets.add(socketId);
  }

  unregister(socketId: string): string | undefined {
    const playerId = this.bySocket.get(socketId);
    if (!playerId) {
      return undefined;
    }
    this.bySocket.delete(socketId);
    const sockets = this.byPlayer.get(playerId);
    if (sockets) {
      sockets.delete(socketId);
      if (sockets.size === 0) {
        this.byPlayer.delete(playerId);
      }
    }
    return playerId;
  }

  isConnected(playerId: string): boolean {
    const sockets = this.byPlayer.get(playerId);
    return sockets !== undefined && sockets.size > 0;
  }

  clear(): void {
    this.byPlayer.clear();
    this.bySocket.clear();
  }
}
