import { Request, Response } from "express";
import { PrismaClient } from "@prisma/client";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";

const prisma = new PrismaClient();
const JWT_SECRET = process.env.JWT_SECRET || "supersecret";

export const registerDriver = async (req: Request, res: Response) => {
  try {
    const data = req.body;
    data.passwordHash = await bcrypt.hash(data.password, 10);
    delete data.password;
    const driver = await prisma.driver.create({ data });
    res.json({ driver });
  } catch (err: any) {
    res.status(400).json({ error: err.message });
  }
};

export const loginDriver = async (req: Request, res: Response) => {
  const { mdtUsername, password } = req.body;
  const driver = await prisma.driver.findUnique({ where: { mdtUsername } });
  if (!driver) return res.status(401).json({ error: "No such user" });
  const valid = await bcrypt.compare(password, driver.passwordHash);
  if (!valid) return res.status(401).json({ error: "Invalid password" });
  const token = jwt.sign({ driverId: driver.id }, JWT_SECRET, {
    expiresIn: "7d",
  });
  res.json({
    token,
    driverId: driver.id,
    name: driver.firstName + " " + driver.lastName,
  });
};

export const listDrivers = async (_: Request, res: Response) => {
  const drivers = await prisma.driver.findMany();
  res.json(drivers);
};
