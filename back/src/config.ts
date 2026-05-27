const DEFAULT_PORT = 3000;

function parsePort(value: string | undefined): number {
  if (value === undefined || value === "") {
    return DEFAULT_PORT;
  }
  const port = Number.parseInt(value, 10);
  if (!Number.isInteger(port) || port < 1 || port > 65535) {
    throw new Error(`Invalid PORT: ${value}`);
  }
  return port;
}

function parseCorsOrigins(value: string | undefined): string[] | true {
  if (value === undefined || value.trim() === "") {
    return true;
  }
  return value.split(",").map((o) => o.trim()).filter(Boolean);
}

function parsePositiveMs(value: string | undefined, fallback: number): number {
  if (value === undefined || value.trim() === "") {
    return fallback;
  }
  const ms = Number.parseInt(value, 10);
  if (!Number.isFinite(ms) || ms < 0) {
    throw new Error(`Invalid ROOM_IDLE_CLEANUP_MS: ${value}`);
  }
  return ms;
}

export const config = {
  port: parsePort(process.env.PORT),
  corsOrigins: parseCorsOrigins(process.env.CORS_ORIGINS),
  maxPlayersPerRoom: 4,
  roomCodeLength: 6,
  /** Remove room + game when all players disconnected for this long (0 = disabled). */
  roomIdleCleanupMs: parsePositiveMs(process.env.ROOM_IDLE_CLEANUP_MS, 5 * 60 * 1000),
} as const;
