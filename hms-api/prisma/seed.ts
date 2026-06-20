import "dotenv/config";
import { PrismaClient } from "../app/generated/prisma/client";
import { PrismaPg } from "@prisma/adapter-pg";

const adapter = new PrismaPg({
  connectionString: process.env.DATABASE_URL!,
});

const prisma = new PrismaClient({ adapter });

const HOTEL_ID = "technortal";

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
