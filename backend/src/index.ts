import dotenv from 'dotenv';
dotenv.config();
import express, { Express, Request, Response } from 'express';
import http from 'http';
import cors from 'cors';
import { configureSocket, driverLocations } from './socket';
import * as driverController from './controllers/driverController';

const app: Express = express();
app.use(cors());
app.use(express.json());

// Route handlers
app.post("/drivers", async (req: Request, res: Response) => {
  await driverController.registerDriver(req, res);
});

app.post("/drivers/login", async (req: Request, res: Response) => {
  await driverController.loginDriver(req, res);
});

app.get("/drivers", async (req: Request, res: Response) => {
  await driverController.listDrivers(req, res);
});

app.get('/driverLocations', (_: Request, res: Response) => {
  res.json(driverLocations);
});

const server = http.createServer(app);
const io = require("socket.io")(server, { cors: { origin: "*" } });
configureSocket(io);

const PORT = 4000;
server.listen(PORT, () => console.log(`Server running on port ${PORT}`));