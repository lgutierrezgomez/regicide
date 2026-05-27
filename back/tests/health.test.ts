import { afterEach, beforeEach, describe, expect, it } from "vitest";
import {
  createTestContext,
  httpRequest,
  stopTestServer,
  type TestServer,
} from "./helpers/testServer.js";

describe("GET /health", () => {
  let server: TestServer;

  beforeEach(() => {
    server = createTestContext();
  });

  afterEach(async () => {
    await stopTestServer(server);
  });

  it("returns ok status", async () => {
    const res = await httpRequest(server).get("/health");

    expect(res.status).toBe(200);
    expect(res.body).toMatchObject({
      status: "ok",
      service: "regicide-back",
    });
    expect(res.body.timestamp).toBeDefined();
  });
});
