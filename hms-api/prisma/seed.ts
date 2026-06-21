import "dotenv/config";
import { randomUUID } from "node:crypto";
import { hashPassword } from "better-auth/crypto";
import { PrismaClient } from "../lib/generated/prisma/client";
import { PrismaPg } from "@prisma/adapter-pg";

const adapter = new PrismaPg({
  connectionString: process.env.DATABASE_URL!,
});

const prisma = new PrismaClient({ adapter });

const HOTEL_ID = "technortal";
const ADMIN_EMAIL = "admin@technortal.hotel";
const ADMIN_PASSWORD = "Admin123!";

async function seedAdminUser() {
  const userId = randomUUID();
  const hashedPassword = await hashPassword(ADMIN_PASSWORD);

  const user = await prisma.user.upsert({
    where: { email: ADMIN_EMAIL },
    update: {
      name: "Admin User",
      emailVerified: true,
      twoFactorEnabled: true,
    },
    create: {
      id: userId,
      name: "Admin User",
      email: ADMIN_EMAIL,
      emailVerified: true,
      twoFactorEnabled: true,
      accounts: {
        create: {
          id: randomUUID(),
          accountId: userId,
          providerId: "credential",
          password: hashedPassword,
        },
      },
    },
  });

  const account = await prisma.account.findFirst({
    where: { userId: user.id, providerId: "credential" },
  });

  if (!account) {
    await prisma.account.create({
      data: {
        id: randomUUID(),
        accountId: user.id,
        providerId: "credential",
        userId: user.id,
        password: hashedPassword,
      },
    });
  } else {
    await prisma.account.update({
      where: { id: account.id },
      data: { password: hashedPassword },
    });
  }

  await prisma.twoFactor.upsert({
    where: { userId: user.id },
    update: {
      secret: "otp",
      backupCodes: "[]",
      verified: true,
    },
    create: {
      id: randomUUID(),
      userId: user.id,
      secret: "otp",
      backupCodes: "[]",
      verified: true,
    },
  });

  await prisma.staffMember.upsert({
    where: { userId: user.id },
    update: {
      role: "ADMIN",
      isActive: true,
    },
    create: {
      userId: user.id,
      role: "ADMIN",
      isActive: true,
    },
  });

  console.log("Seeded admin staff user:");
  console.log(`  Email: ${ADMIN_EMAIL}`);
  console.log(`  Password: ${ADMIN_PASSWORD}`);

  return user;
}

async function main() {
  const hotel = await prisma.hotelProfile.upsert({
    where: { id: HOTEL_ID },
    update: {},
    create: {
      id: HOTEL_ID,
      name: "Technortal Hotel",
      address: "123 Technortal Street",
      city: "Yangon",
      country: "Myanmar",
      timezone: "Asia/Yangon",
      currency: "USD",
      phone: "+95-1-234-5678",
      email: "info@technortal.hotel",
    },
  });

  const standard = await prisma.roomType.upsert({
    where: { name: "Standard" },
    update: {},
    create: {
      name: "Standard",
      description: "Comfortable room with essential amenities",
      maxOccupancy: 2,
      baseOccupancy: 2,
      amenities: ["WiFi", "Air Conditioning", "TV"],
    },
  });

  const deluxe = await prisma.roomType.upsert({
    where: { name: "Deluxe" },
    update: {},
    create: {
      name: "Deluxe",
      description: "Spacious room with premium amenities and city view",
      maxOccupancy: 3,
      baseOccupancy: 2,
      amenities: ["WiFi", "Air Conditioning", "TV", "Mini Bar", "City View"],
    },
  });

  await prisma.ratePlan.upsert({
    where: { id: "seed-rate-standard" },
    update: {},
    create: {
      id: "seed-rate-standard",
      roomTypeId: standard.id,
      name: "Standard Best Available",
      nightlyRate: 89.0,
      isActive: true,
    },
  });

  await prisma.ratePlan.upsert({
    where: { id: "seed-rate-deluxe" },
    update: {},
    create: {
      id: "seed-rate-deluxe",
      roomTypeId: deluxe.id,
      name: "Deluxe Best Available",
      nightlyRate: 129.0,
      isActive: true,
    },
  });

  const rooms = [
    { number: "101", floor: 1, roomTypeId: standard.id },
    { number: "102", floor: 1, roomTypeId: standard.id },
    { number: "103", floor: 1, roomTypeId: standard.id },
    { number: "201", floor: 2, roomTypeId: deluxe.id },
    { number: "202", floor: 2, roomTypeId: deluxe.id },
    { number: "203", floor: 2, roomTypeId: deluxe.id },
  ];

  for (const room of rooms) {
    await prisma.room.upsert({
      where: { number: room.number },
      update: {},
      create: room,
    });
  }

  const outlets = [
    { name: "Restaurant", type: "RESTAURANT" as const },
    { name: "Bar", type: "BAR" as const },
    { name: "Spa", type: "SPA" as const },
  ];

  for (const outlet of outlets) {
    await prisma.pOSOutlet.upsert({
      where: { name: outlet.name },
      update: {},
      create: outlet,
    });
  }

  await seedAdminUser();

  console.log("Seeded Technortal Hotel:", {
    hotel: hotel.name,
    roomTypes: [standard.name, deluxe.name],
    rooms: rooms.length,
    outlets: outlets.length,
  });
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (error) => {
    console.error(error);
    await prisma.$disconnect();
    process.exit(1);
  });
