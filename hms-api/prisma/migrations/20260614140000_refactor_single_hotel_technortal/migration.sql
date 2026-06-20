-- AlterEnum
BEGIN;
CREATE TYPE "BookingChannel_new" AS ENUM ('DIRECT', 'PHONE', 'WALK_IN');
ALTER TABLE "public"."Reservation" ALTER COLUMN "channel" DROP DEFAULT;
ALTER TABLE "Reservation" ALTER COLUMN "channel" TYPE "BookingChannel_new" USING ("channel"::text::"BookingChannel_new");
ALTER TYPE "BookingChannel" RENAME TO "BookingChannel_old";
ALTER TYPE "BookingChannel_new" RENAME TO "BookingChannel";
DROP TYPE "public"."BookingChannel_old";
ALTER TABLE "Reservation" ALTER COLUMN "channel" SET DEFAULT 'DIRECT';
COMMIT;

-- DropForeignKey
ALTER TABLE "AuditLog" DROP CONSTRAINT "AuditLog_hotelId_fkey";

-- DropForeignKey
ALTER TABLE "Folio" DROP CONSTRAINT "Folio_hotelId_fkey";

-- DropForeignKey
ALTER TABLE "GroupBooking" DROP CONSTRAINT "GroupBooking_hotelId_fkey";

-- DropForeignKey
ALTER TABLE "POSOutlet" DROP CONSTRAINT "POSOutlet_hotelId_fkey";

-- DropForeignKey
ALTER TABLE "RatePlan" DROP CONSTRAINT "RatePlan_hotelId_fkey";

-- DropForeignKey
ALTER TABLE "Reservation" DROP CONSTRAINT "Reservation_hotelId_fkey";

-- DropForeignKey
ALTER TABLE "Room" DROP CONSTRAINT "Room_hotelId_fkey";

-- DropForeignKey
ALTER TABLE "RoomType" DROP CONSTRAINT "RoomType_hotelId_fkey";

-- DropForeignKey
ALTER TABLE "ShiftReport" DROP CONSTRAINT "ShiftReport_hotelId_fkey";

-- DropForeignKey
ALTER TABLE "StaffMember" DROP CONSTRAINT "StaffMember_hotelId_fkey";

-- DropIndex
DROP INDEX "AuditLog_hotelId_createdAt_idx";

-- DropIndex
DROP INDEX "Folio_hotelId_idx";

-- DropIndex
DROP INDEX "GroupBooking_hotelId_idx";

-- DropIndex
DROP INDEX "POSOutlet_hotelId_idx";

-- DropIndex
DROP INDEX "POSOutlet_hotelId_name_key";

-- DropIndex
DROP INDEX "RatePlan_hotelId_idx";

-- DropIndex
DROP INDEX "Reservation_hotelId_checkInDate_checkOutDate_idx";

-- DropIndex
DROP INDEX "Room_hotelId_number_key";

-- DropIndex
DROP INDEX "Room_hotelId_status_idx";

-- DropIndex
DROP INDEX "RoomType_hotelId_idx";

-- DropIndex
DROP INDEX "RoomType_hotelId_name_key";

-- DropIndex
DROP INDEX "ShiftReport_hotelId_shiftStart_idx";

-- DropIndex
DROP INDEX "StaffMember_hotelId_role_idx";

-- AlterTable
ALTER TABLE "AuditLog" DROP COLUMN "hotelId";

-- AlterTable
ALTER TABLE "Folio" DROP COLUMN "hotelId";

-- AlterTable
ALTER TABLE "GroupBooking" DROP COLUMN "hotelId";

-- AlterTable
ALTER TABLE "POSOutlet" DROP COLUMN "hotelId";

-- AlterTable
ALTER TABLE "RatePlan" DROP COLUMN "hotelId";

-- AlterTable
ALTER TABLE "Reservation" DROP COLUMN "hotelId";

-- AlterTable
ALTER TABLE "Room" DROP COLUMN "hotelId";

-- AlterTable
ALTER TABLE "RoomType" DROP COLUMN "hotelId";

-- AlterTable
ALTER TABLE "ShiftReport" DROP COLUMN "hotelId";

-- AlterTable
ALTER TABLE "StaffMember" DROP COLUMN "hotelId";

-- DropTable
DROP TABLE "Hotel";

-- CreateTable
CREATE TABLE "HotelProfile" (
    "id" TEXT NOT NULL DEFAULT 'technortal',
    "name" TEXT NOT NULL DEFAULT 'Technortal Hotel',
    "address" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "country" TEXT NOT NULL,
    "timezone" TEXT NOT NULL DEFAULT 'Asia/Yangon',
    "currency" TEXT NOT NULL DEFAULT 'USD',
    "phone" TEXT,
    "email" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "HotelProfile_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "AuditLog_createdAt_idx" ON "AuditLog"("createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "POSOutlet_name_key" ON "POSOutlet"("name");

-- CreateIndex
CREATE INDEX "Reservation_checkInDate_checkOutDate_idx" ON "Reservation"("checkInDate", "checkOutDate");

-- CreateIndex
CREATE UNIQUE INDEX "Room_number_key" ON "Room"("number");

-- CreateIndex
CREATE INDEX "Room_status_idx" ON "Room"("status");

-- CreateIndex
CREATE UNIQUE INDEX "RoomType_name_key" ON "RoomType"("name");

-- CreateIndex
CREATE INDEX "ShiftReport_shiftStart_idx" ON "ShiftReport"("shiftStart");

-- CreateIndex
CREATE INDEX "StaffMember_role_idx" ON "StaffMember"("role");

