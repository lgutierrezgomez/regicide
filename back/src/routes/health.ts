import { Router } from "express";

export const healthRouter = Router();

healthRouter.get("/", (_req, res) => {
  res.json({
    status: "ok",
    service: "regicide-back",
    timestamp: new Date().toISOString(),
  });
});
