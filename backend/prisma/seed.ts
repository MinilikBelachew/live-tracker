import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  await prisma.driver.createMany({
    data: [
      {
        firstName: "Abanezer",
        middleInitial: "W",
        lastName: "Alemneh",
        dateOfBirth: new Date("1997-12-10"),
        mdtUsername: "AAAbanezer",
        driverLicenseNumber: "13-196-0484",
        driverLicenseIssuingState: "CO",
        driverLicenseExpirationDate: new Date("2026-12-28"),
        hireDate: new Date("2023-02-06"),
        terminationDate: new Date("2025-09-11"),
        note: "national sex offender exp 9/11/2025",
        provider: "ABENEZER HOLDING",
        skill: "Average",
        passwordHash: await bcrypt.hash("password123", 10),
      },
      // Add more drivers
    ]
  });
}

main()
  .then(() => {
    console.log("Seeded drivers");
    prisma.$disconnect();
  })
  .catch(e => {
    console.error(e);
    prisma.$disconnect();
    process.exit(1);
  });