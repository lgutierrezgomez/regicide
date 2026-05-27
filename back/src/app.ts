import cors from "cors";
import express from "express";
import { config } from "./config.js";
import { healthRouter } from "./routes/health.js";

/** Express app without room routes (mounted in `server.ts` after Socket.IO hub exists). */
export function createBaseApp() {
  const app = express();

  app.use(
    cors({
      origin: config.corsOrigins,
    }),
  );
  app.use(express.json());
  app.use("/health", healthRouter);

  return app;
}

export function mountNotFound(app: express.Application) {
  app.use((_req, res) => {
    res.status(404).json({ error: "Not found" });
  });
}
