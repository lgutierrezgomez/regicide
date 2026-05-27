import type { AddressInfo } from "node:net";
import request from "supertest";
import { io as ioClient, type Socket as ClientSocket } from "socket.io-client";
import type { AppContext } from "../../src/server.js";
import { createAppContext } from "../../src/server.js";

export interface TestServer extends AppContext {
  url: string;
  port: number;
}

/** In-memory app + Socket.IO (not listening). Use for REST/supertest. */
export function createTestContext(): TestServer {
  const ctx = createAppContext();
  return { ...ctx, port: 0, url: "" };
}

/** Start HTTP server for Socket.IO client connections. */
export async function listen(server: TestServer): Promise<void> {
  if (server.httpServer.listening) {
    return;
  }
  await new Promise<void>((resolve, reject) => {
    server.httpServer.once("error", reject);
    server.httpServer.listen(0, "127.0.0.1", () => {
      const addr = server.httpServer.address() as AddressInfo;
      server.port = addr.port;
      server.url = `http://127.0.0.1:${server.port}`;
      resolve();
    });
  });
}

export function httpRequest(server: TestServer) {
  return request(server.app);
}

export async function stopTestServer(server: TestServer): Promise<void> {
  await new Promise<void>((resolve) => server.io.close(() => resolve()));
  if (server.httpServer.listening) {
    await new Promise<void>((resolve, reject) => {
      server.httpServer.close((err) => (err ? reject(err) : resolve()));
    });
  }
}

export function createClient(server: TestServer): ClientSocket {
  if (!server.url) {
    throw new Error("Call listen(server) before Socket.IO client tests");
  }
  return ioClient(server.url, {
    autoConnect: false,
    forceNew: true,
    transports: ["websocket", "polling"],
  });
}

export function waitForEvent<T>(socket: ClientSocket, event: string): Promise<T> {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error(`Timeout waiting for ${event}`)), 5000);
    socket.once(event, (payload: T) => {
      clearTimeout(timer);
      resolve(payload);
    });
  });
}

export async function connectToRoom(
  server: TestServer,
  roomCode: string,
  playerId: string,
): Promise<ClientSocket> {
  const socket = createClient(server);
  const lobbyPromise = waitForEvent(socket, "lobby:updated");

  await new Promise<void>((resolve, reject) => {
    socket.on("connect", () => resolve());
    socket.on("connect_error", (err: Error) => reject(err));
    socket.auth = { roomCode, playerId };
    socket.connect();
  });

  await lobbyPromise;
  return socket;
}
