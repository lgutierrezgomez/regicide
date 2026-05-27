import { config } from "./config.js";
import { createAppContext } from "./server.js";

const { httpServer } = createAppContext();

httpServer.listen(config.port, () => {
  console.log(`regicide-back listening on http://localhost:${config.port}`);
  console.log(`WebSocket (Socket.IO) on same port`);
});
