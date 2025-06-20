-- CreateTable
CREATE TABLE "Driver" (
    "id" SERIAL NOT NULL,
    "firstName" TEXT NOT NULL,
    "middleInitial" TEXT,
    "lastName" TEXT NOT NULL,
    "dateOfBirth" TIMESTAMP(3),
    "mdtUsername" TEXT NOT NULL,
    "streetNumber" TEXT,
    "street" TEXT,
    "city" TEXT,
    "state" TEXT,
    "zipCode" TEXT,
    "phone" TEXT,
    "phoneExtension" TEXT,
    "employeeNumber" TEXT,
    "driverLicenseNumber" TEXT,
    "driverLicenseIssuingState" TEXT,
    "driverLicenseExpirationDate" TIMESTAMP(3),
    "hireDate" TIMESTAMP(3),
    "seniority" TEXT,
    "terminationDate" TIMESTAMP(3),
    "note" TEXT,
    "emergencyContactName" TEXT,
    "emergencyContactRelation" TEXT,
    "emergencyContactPhone" TEXT,
    "emergencyContactPhoneExt" TEXT,
    "emergencyContactNote" TEXT,
    "deletedAt" TIMESTAMP(3),
    "provider" TEXT,
    "skill" TEXT,
    "vehicle" TEXT,
    "passwordHash" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Driver_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Driver_mdtUsername_key" ON "Driver"("mdtUsername");
