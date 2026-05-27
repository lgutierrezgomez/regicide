import { afterEach, beforeEach, describe, expect, it } from "vitest";
import {
  createTestContext,
  httpRequest,
  stopTestServer,
  type TestServer,
} from "./helpers/testServer.js";

describe("Rooms API", () => {
  let server: TestServer;

  beforeEach(() => {
    server = createTestContext();
  });

  afterEach(async () => {
    await stopTestServer(server);
  });

  it("creates a room with a 6-character code and host player", async () => {
    const res = await httpRequest(server)
      .post("/rooms")
      .send({ displayName: "Alice" });

    expect(res.status).toBe(201);
    expect(res.body.room.code).toMatch(/^[A-Z2-9]{6}$/);
    expect(res.body.room.status).toBe("lobby");
    expect(res.body.room.playerCount).toBe(1);
    expect(res.body.room.maxPlayers).toBe(4);
    expect(res.body.room.players[0].displayName).toBe("Alice");
    expect(res.body.playerId).toBe(res.body.room.hostPlayerId);
  });

  it("allows another player to join by code", async () => {
    const created = await httpRequest(server)
      .post("/rooms")
      .send({ displayName: "Alice" });
    const code = created.body.room.code;

    const joined = await httpRequest(server)
      .post(`/rooms/${code}/join`)
      .send({ displayName: "Bob" });

    expect(joined.status).toBe(200);
    expect(joined.body.room.playerCount).toBe(2);
    expect(joined.body.room.players.map((p: { displayName: string }) => p.displayName)).toEqual([
      "Alice",
      "Bob",
    ]);
  });

  it("join is case-insensitive on room code", async () => {
    const created = await httpRequest(server)
      .post("/rooms")
      .send({ displayName: "Alice" });
    const code = created.body.room.code;

    const joined = await httpRequest(server)
      .post(`/rooms/${code.toLowerCase()}/join`)
      .send({ displayName: "Bob" });

    expect(joined.status).toBe(200);
    expect(joined.body.room.playerCount).toBe(2);
  });

  it("GET /rooms/:code returns lobby state with connected flags", async () => {
    const created = await httpRequest(server)
      .post("/rooms")
      .send({ displayName: "Alice" });
    const code = created.body.room.code;

    const res = await httpRequest(server).get(`/rooms/${code}`);

    expect(res.status).toBe(200);
    expect(res.body.room.code).toBe(code);
    expect(res.body.room.players).toHaveLength(1);
    expect(res.body.room.players[0].connected).toBe(false);
  });

  it("rejects join when room is full", async () => {
    const created = await httpRequest(server)
      .post("/rooms")
      .send({ displayName: "P1" });
    const code = created.body.room.code;

    for (const name of ["P2", "P3", "P4"]) {
      await httpRequest(server).post(`/rooms/${code}/join`).send({ displayName: name });
    }

    const fifth = await httpRequest(server)
      .post(`/rooms/${code}/join`)
      .send({ displayName: "P5" });

    expect(fifth.status).toBe(409);
    expect(fifth.body.code).toBe("ROOM_FULL");
  });

  it("returns 404 for unknown room", async () => {
    const res = await httpRequest(server).get("/rooms/ZZZZZZ");

    expect(res.status).toBe(404);
    expect(res.body.code).toBe("ROOM_NOT_FOUND");
  });

  it("rejects empty displayName", async () => {
    const res = await httpRequest(server).post("/rooms").send({ displayName: "   " });

    expect(res.status).toBe(400);
    expect(res.body.code).toBe("INVALID_NAME");
  });

  it("host can start game via REST", async () => {
    const created = await httpRequest(server)
      .post("/rooms")
      .send({ displayName: "Host" });
    const code = created.body.room.code;
    const hostId = created.body.playerId;

    const res = await httpRequest(server)
      .post(`/rooms/${code}/start`)
      .send({ playerId: hostId });

    expect(res.status).toBe(200);
    expect(res.body.room.status).toBe("in_game");
  });

  it("non-host cannot start game via REST", async () => {
    const created = await httpRequest(server)
      .post("/rooms")
      .send({ displayName: "Host" });
    const code = created.body.room.code;

    const guest = await httpRequest(server)
      .post(`/rooms/${code}/join`)
      .send({ displayName: "Guest" });

    const res = await httpRequest(server)
      .post(`/rooms/${code}/start`)
      .send({ playerId: guest.body.playerId });

    expect(res.status).toBe(403);
    expect(res.body.code).toBe("NOT_HOST");
  });
});
