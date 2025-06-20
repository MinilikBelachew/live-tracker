import { Server, Socket } from "socket.io";
import jwt from "jsonwebtoken";
import { PrismaClient } from "@prisma/client";

const JWT_SECRET = process.env.JWT_SECRET || 'supersecret';
const prisma = new PrismaClient();

interface DriverLocation {
  lat: number;
  lng: number;
  timestamp: number;
}

const driverLocations: Record<number, DriverLocation> = {};

export function configureSocket(io: Server) {
  io.on("connection", (socket: Socket) => {
    console.log("Socket connected:", socket.id);

    socket.on("driverLocation", async (data) => {
      try {
        const decoded = jwt.verify(data.token, JWT_SECRET) as { driverId: number };

        if (decoded.driverId !== data.driverId) {
          throw new Error("Driver ID mismatch");
        }

        const driver = await prisma.driver.findUnique({
          where: { id: data.driverId },
          select: { firstName: true, lastName: true },
        });

        if (!driver) {
          throw new Error("Driver not found for ID: " + data.driverId);
        }

        driverLocations[data.driverId] = {
          lat: data.lat,
          lng: data.lng,
          timestamp: Date.now(),
        };

        // Emit to frontend
        io.emit("updateLocation", {
          driverId: data.driverId,
          lat: data.lat,
          lng: data.lng,
          firstName: driver.firstName,
          lastName: driver.lastName,
        });

        // ✅ Log driver info
        console.log(
          `Driver ID: ${data.driverId}, Name: ${driver.firstName} ${driver.lastName}, Lat: ${data.lat}, Lng: ${data.lng}`
        );
      } catch (err: any) {
        console.log("Location update error:", err.message);
      }
    });

    socket.on('disconnect', () => {
      console.log('Socket disconnected:', socket.id);
    });
  });
}

export { driverLocations };



// // backend/src/socket.ts
// import { Server, Socket } from "socket.io";
// import jwt from "jsonwebtoken";
// import { PrismaClient } from "@prisma/client"; // Import PrismaClient

// const JWT_SECRET = process.env.JWT_SECRET || 'supersecret';
// const prisma = new PrismaClient(); // Initialize Prisma Client

// interface DriverLocation {
//   lat: number;
//   lng: number;
//   timestamp: number;
// }

// const driverLocations: Record<number, DriverLocation> = {};

// export function configureSocket(io: Server) {
//   io.on("connection", (socket: Socket) => {
//     console.log("Socket connected:", socket.id);

//     socket.on("driverLocation", async (data) => { // Make the callback async
//       try {
//         const decoded = jwt.verify(data.token, JWT_SECRET) as { driverId: number };
//         if (decoded.driverId !== data.driverId) throw new Error("Driver ID mismatch");

//         // Fetch driver's details from the database
//         const driver = await prisma.driver.findUnique({
//           where: { id: data.driverId },
//           select: { firstName: true, lastName: true } // Select only needed fields
//         });

//         if (!driver) {
//           throw new Error("Driver not found for ID: " + data.driverId);
//         }

//         driverLocations[data.driverId] = {
//           lat: data.lat,
//           lng: data.lng,
//           timestamp: Date.now()
//         };

//         // Emit updateLocation with driver's first and last name
//         io.emit("updateLocation", {
//           driverId: data.driverId,
//           lat: data.lat,
//           lng: data.lng,
//           firstName: driver.firstName, // Include first name
//           lastName: driver.lastName // Include last name
//         });
//       } catch (err: any) {
//         console.log("Location update error:", err.message);
//       }
//     });

//     socket.on('disconnect', () => {
//       console.log('Socket disconnected:', socket.id);
//     });
//   });
// }

// export { driverLocations };

// import { Server, Socket } from "socket.io";
// import jwt from "jsonwebtoken";

// const JWT_SECRET = process.env.JWT_SECRET || 'supersecret';

// interface DriverLocation {
//   lat: number;
//   lng: number;
//   timestamp: number;
// }

// const driverLocations: Record<number, DriverLocation> = {};

// export function configureSocket(io: Server) {
//   io.on("connection", (socket: Socket) => {
//     console.log("Socket connected:", socket.id);

//     socket.on("driverLocation", (data) => {
//       try {
//         const decoded = jwt.verify(data.token, JWT_SECRET) as { driverId: number };
//         if (decoded.driverId !== data.driverId) throw new Error("Driver ID mismatch");
//         driverLocations[data.driverId] = {
//           lat: data.lat,
//           lng: data.lng,
//           timestamp: Date.now()
//         };
//         console.log(driverLocations);

//         io.emit("updateLocation", { driverId: data.driverId, lat: data.lat, lng: data.lng });
//       } catch (err: any) {
//         console.log("Location update error:", err.message);
        
//       }
//     });

//     socket.on('disconnect', () => {
//       console.log('Socket disconnected:', socket.id);
//     });
//   });
// }

// export { driverLocations };