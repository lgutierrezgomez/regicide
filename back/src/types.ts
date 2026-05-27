export type RoomStatus = "lobby" | "in_game";

export interface Player {
  id: string;
  displayName: string;
  joinedAt: string;
}

export interface Room {
  code: string;
  status: RoomStatus;
  hostPlayerId: string;
  players: Player[];
  createdAt: string;
}

export interface PlayerPublicView {
  id: string;
  displayName: string;
  connected: boolean;
}

/** Public view returned by GET /rooms/:code and socket events */
export interface RoomPublicView {
  code: string;
  status: RoomStatus;
  hostPlayerId: string;
  players: PlayerPublicView[];
  playerCount: number;
  maxPlayers: number;
}

export interface CreateRoomBody {
  displayName: string;
}

export interface JoinRoomBody {
  displayName: string;
}

export interface RoomActionResponse {
  room: RoomPublicView;
  playerId: string;
}
