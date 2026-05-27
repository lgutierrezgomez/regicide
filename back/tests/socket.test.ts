import { afterEach, beforeEach, describe, expect, it } from "vitest";
import {
  connectToRoom,
  createClient,
  createTestContext,
  httpRequest,
  listen,
  stopTestServer,
  waitForEvent,
  type TestServer,
} from "./helpers/testServer.js";

describe("Socket.IO lobby", () => {
  let server: TestServer;

  beforeEach(async () => {
    server = createTestContext();
    await listen(server);
  });

  afterEach(async () => {
    await stopTestServer(server);
  });

  it("rejects connection without auth", async () => {
    const socket = createClient(server);
    await expect(
      new Promise((resolve, reject) => {
        socket.on("connect", () => reject(new Error("should not connect")));
        socket.on("connect_error", () => resolve("rejected"));
        socket.connect();
        setTimeout(() => reject(new Error("timeout")), 3000);
      }),
    ).resolves.toBe("rejected");
    socket.close();
  });

  it("sends lobby:updated on connect with connected player", async () => {
    const created = await httpRequest(server)
      .post("/rooms")
      .send({ displayName: "Alice" });
    const { code } = created.body.room;
    const { playerId } = created.body;

    const socket = await connectToRoom(server, code, playerId);
    const res = await httpRequest(server).get(`/rooms/${code}`);
    expect(res.body.room.players[0].connected).toBe(true);
    socket.close();
  });

  it("emits room:created to host on first socket connect", async () => {
    const created = await httpRequest(server)
      .post("/rooms")
      .send({ displayName: "Host" });
    const { code } = created.body.room;
    const { playerId } = created.body;

    const socket = createClient(server);
    const createdP = waitForEvent<{ room: { code: string } }>(socket, "room:created");
    socket.auth = { roomCode: code, playerId };
    socket.connect();
    await new Promise<void>((r) => socket.on("connect", r));

    const payload = await createdP;
    expect(payload.room.code).toBe(code);
    socket.close();
  });

  it("broadcasts room:joined and lobby:updated when REST join", async () => {
    const created = await httpRequest(server)
      .post("/rooms")
      .send({ displayName: "Alice" });
    const code = created.body.room.code;
    const hostId = created.body.playerId;

    const hostSocket = await connectToRoom(server, code, hostId);

    const joinedPromise = waitForEvent<{ playerId: string; displayName: string }>(
      hostSocket,
      "room:joined",
    );
    const lobbyPromise = waitForEvent<{ room: { playerCount: number } }>(
      hostSocket,
      "lobby:updated",
    );

    await httpRequest(server)
      .post(`/rooms/${code}/join`)
      .send({ displayName: "Bob" });

    const joined = await joinedPromise;
    const lobby = await lobbyPromise;

    expect(joined.displayName).toBe("Bob");
    expect(lobby.room.playerCount).toBe(2);
    hostSocket.close();
  });

  it("marks player disconnected after socket disconnect", async () => {
    const created = await httpRequest(server)
      .post("/rooms")
      .send({ displayName: "Alice" });
    const code = created.body.room.code;
    const playerId = created.body.playerId;

    await connectToRoom(server, code, playerId);

    const bob = await httpRequest(server)
      .post(`/rooms/${code}/join`)
      .send({ displayName: "Bob" });

    const bobSocket = await connectToRoom(server, code, bob.body.playerId);
    bobSocket.close();

    await new Promise((r) => setTimeout(r, 50));

    const res = await httpRequest(server).get(`/rooms/${code}`);
    const bobPlayer = res.body.room.players.find(
      (p: { displayName: string }) => p.displayName === "Bob",
    );
    expect(bobPlayer?.connected).toBe(false);
  });

  it("host can start game via socket game:start", async () => {
    const created = await httpRequest(server)
      .post("/rooms")
      .send({ displayName: "Host" });
    const code = created.body.room.code;
    const hostId = created.body.playerId;

    const socket = await connectToRoom(server, code, hostId);

    socket.emit("game:start");
    const started = await waitForEvent<{ room: { status: string } }>(socket, "game:started");
    expect(started.room.status).toBe("in_game");
    socket.close();
  });

  it("non-host game:start returns error event", async () => {
    const created = await httpRequest(server)
      .post("/rooms")
      .send({ displayName: "Host" });
    const code = created.body.room.code;

    const guest = await httpRequest(server)
      .post(`/rooms/${code}/join`)
      .send({ displayName: "Guest" });

    const socket = await connectToRoom(server, code, guest.body.playerId);

    const errPromise = waitForEvent<{ code: string }>(socket, "error");
    socket.emit("game:start");
    const err = await errPromise;
    expect(err.code).toBe("NOT_HOST");
    socket.close();
  });

  it("host can return to lobby after game started", async () => {
    const created = await httpRequest(server)
      .post("/rooms")
      .send({ displayName: "Host" });
    const code = created.body.room.code;
    const hostId = created.body.playerId;

    const socket = await connectToRoom(server, code, hostId);
    socket.emit("game:start");
    await waitForEvent(socket, "game:started");

    const lobbyPromise = waitForEvent<{ room: { status: string } }>(socket, "lobby:updated");
    socket.emit("game:returnToLobby");
    const lobby = await lobbyPromise;
    expect(lobby.room.status).toBe("lobby");
    socket.close();
  });

  it("host can restart game with same players", async () => {
    const created = await httpRequest(server)
      .post("/rooms")
      .send({ displayName: "Host" });
    const code = created.body.room.code;
    const hostId = created.body.playerId;

    const socket = await connectToRoom(server, code, hostId);
    socket.emit("game:start");
    await waitForEvent(socket, "game:started");

    const restartPromise = waitForEvent<{ room: { status: string } }>(socket, "game:started");
    socket.emit("game:restart");
    const restarted = await restartPromise;
    expect(restarted.room.status).toBe("in_game");
    socket.close();
  });
});
