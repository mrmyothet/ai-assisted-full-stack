-- CreateEnum
CREATE TYPE "StaffRole" AS ENUM ('ADMIN', 'FRONT_DESK', 'HOUSEKEEPING', 'MAINTENANCE', 'MANAGER');

-- CreateEnum
CREATE TYPE "RoomStatus" AS ENUM ('VACANT', 'OCCUPIED', 'DIRTY', 'CLEANING', 'INSPECTED', 'OUT_OF_ORDER', 'READY');

-- CreateEnum
CREATE TYPE "ReservationStatus" AS ENUM ('PENDING', 'CONFIRMED', 'CHECKED_IN', 'CHECKED_OUT', 'CANCELLED', 'NO_SHOW');

-- CreateEnum
CREATE TYPE "BookingChannel" AS ENUM ('DIRECT', 'PHONE', 'WALK_IN', 'OTA');

-- CreateEnum
CREATE TYPE "HousekeepingTaskStatus" AS ENUM ('PENDING', 'IN_PROGRESS', 'COMPLETED', 'SKIPPED');

-- CreateEnum
CREATE TYPE "MaintenanceTicketStatus" AS ENUM ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED');

-- CreateEnum
CREATE TYPE "FolioChargeType" AS ENUM ('ROOM', 'SPA', 'RESTAURANT', 'BAR', 'MINIBAR', 'LAUNDRY', 'OTHER');

-- CreateEnum
CREATE TYPE "FolioStatus" AS ENUM ('OPEN', 'CLOSED');

-- CreateEnum
CREATE TYPE "PaymentMethod" AS ENUM ('CASH', 'CARD', 'BANK_TRANSFER');

-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('PENDING', 'COMPLETED', 'FAILED', 'REFUNDED');

-- CreateEnum
CREATE TYPE "CommunicationType" AS ENUM ('PRE_ARRIVAL', 'POST_STAY', 'REVIEW_REQUEST', 'MARKETING');

-- CreateEnum
CREATE TYPE "CommunicationStatus" AS ENUM ('SCHEDULED', 'SENT', 'FAILED');

-- CreateEnum
CREATE TYPE "GroupBookingStatus" AS ENUM ('INQUIRY', 'CONFIRMED', 'ACTIVE', 'COMPLETED', 'CANCELLED');

-- CreateTable
CREATE TABLE "Hotel" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "address" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "country" TEXT NOT NULL,
    "timezone" TEXT NOT NULL DEFAULT 'UTC',
    "currency" TEXT NOT NULL DEFAULT 'USD',
    "phone" TEXT,
    "email" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Hotel_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RoomType" (
    "id" TEXT NOT NULL,
    "hotelId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "maxOccupancy" INTEGER NOT NULL,
    "baseOccupancy" INTEGER NOT NULL DEFAULT 2,
    "amenities" JSONB,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "RoomType_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Room" (
    "id" TEXT NOT NULL,
    "hotelId" TEXT NOT NULL,
    "roomTypeId" TEXT NOT NULL,
    "number" TEXT NOT NULL,
    "floor" INTEGER NOT NULL,
    "status" "RoomStatus" NOT NULL DEFAULT 'VACANT',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Room_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RatePlan" (
    "id" TEXT NOT NULL,
    "hotelId" TEXT NOT NULL,
    "roomTypeId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "nightlyRate" DECIMAL(10,2) NOT NULL,
    "validFrom" DATE,
    "validTo" DATE,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "RatePlan_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StaffMember" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "hotelId" TEXT NOT NULL,
    "role" "StaffRole" NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "StaffMember_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Guest" (
    "id" TEXT NOT NULL,
    "userId" TEXT,
    "email" TEXT NOT NULL,
    "phone" TEXT,
    "firstName" TEXT NOT NULL,
    "lastName" TEXT NOT NULL,
    "dateOfBirth" DATE,
    "nationality" TEXT,
    "address" TEXT,
    "preferences" JSONB,
    "notes" TEXT,
    "marketingOptIn" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Guest_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "GroupBooking" (
    "id" TEXT NOT NULL,
    "hotelId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "contactGuestId" TEXT NOT NULL,
    "blockCheckIn" DATE NOT NULL,
    "blockCheckOut" DATE NOT NULL,
    "roomsBlocked" INTEGER NOT NULL,
    "status" "GroupBookingStatus" NOT NULL DEFAULT 'INQUIRY',
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "GroupBooking_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Reservation" (
    "id" TEXT NOT NULL,
    "confirmationCode" TEXT NOT NULL,
    "hotelId" TEXT NOT NULL,
    "guestId" TEXT NOT NULL,
    "groupBookingId" TEXT,
    "channel" "BookingChannel" NOT NULL DEFAULT 'DIRECT',
    "status" "ReservationStatus" NOT NULL DEFAULT 'PENDING',
    "checkInDate" DATE NOT NULL,
    "checkOutDate" DATE NOT NULL,
    "adults" INTEGER NOT NULL DEFAULT 1,
    "children" INTEGER NOT NULL DEFAULT 0,
    "specialRequests" TEXT,
    "notes" TEXT,
    "checkedInAt" TIMESTAMP(3),
    "checkedOutAt" TIMESTAMP(3),
    "checkedInById" TEXT,
    "checkedOutById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Reservation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ReservationRoom" (
    "id" TEXT NOT NULL,
    "reservationId" TEXT NOT NULL,
    "roomTypeId" TEXT NOT NULL,
    "roomId" TEXT,
    "ratePlanId" TEXT,
    "nightlyRate" DECIMAL(10,2) NOT NULL,
    "guestsCount" INTEGER NOT NULL DEFAULT 1,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ReservationRoom_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DigitalKey" (
    "id" TEXT NOT NULL,
    "reservationId" TEXT NOT NULL,
    "roomId" TEXT NOT NULL,
    "accessCode" TEXT NOT NULL,
    "validFrom" TIMESTAMP(3) NOT NULL,
    "validUntil" TIMESTAMP(3) NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "DigitalKey_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "HousekeepingTask" (
    "id" TEXT NOT NULL,
    "roomId" TEXT NOT NULL,
    "assignedToId" TEXT,
    "status" "HousekeepingTaskStatus" NOT NULL DEFAULT 'PENDING',
    "priority" INTEGER NOT NULL DEFAULT 0,
    "notes" TEXT,
    "startedAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "HousekeepingTask_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MaintenanceTicket" (
    "id" TEXT NOT NULL,
    "roomId" TEXT NOT NULL,
    "reportedById" TEXT,
    "assignedToId" TEXT,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "status" "MaintenanceTicketStatus" NOT NULL DEFAULT 'OPEN',
    "priority" INTEGER NOT NULL DEFAULT 0,
    "resolvedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "MaintenanceTicket_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RoomStatusLog" (
    "id" TEXT NOT NULL,
    "roomId" TEXT NOT NULL,
    "fromStatus" "RoomStatus",
    "toStatus" "RoomStatus" NOT NULL,
    "changedById" TEXT,
    "note" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "RoomStatusLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "POSOutlet" (
    "id" TEXT NOT NULL,
    "hotelId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "type" "FolioChargeType" NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "POSOutlet_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Folio" (
    "id" TEXT NOT NULL,
    "reservationId" TEXT NOT NULL,
    "guestId" TEXT NOT NULL,
    "hotelId" TEXT NOT NULL,
    "status" "FolioStatus" NOT NULL DEFAULT 'OPEN',
    "openedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "closedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Folio_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FolioCharge" (
    "id" TEXT NOT NULL,
    "folioId" TEXT NOT NULL,
    "outletId" TEXT,
    "type" "FolioChargeType" NOT NULL,
    "description" TEXT NOT NULL,
    "quantity" INTEGER NOT NULL DEFAULT 1,
    "unitPrice" DECIMAL(10,2) NOT NULL,
    "taxRate" DECIMAL(5,4) NOT NULL DEFAULT 0,
    "totalAmount" DECIMAL(10,2) NOT NULL,
    "postedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "postedById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "FolioCharge_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Invoice" (
    "id" TEXT NOT NULL,
    "folioId" TEXT NOT NULL,
    "invoiceNumber" TEXT NOT NULL,
    "subtotal" DECIMAL(10,2) NOT NULL,
    "taxAmount" DECIMAL(10,2) NOT NULL,
    "totalAmount" DECIMAL(10,2) NOT NULL,
    "issuedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "dueAt" TIMESTAMP(3),
    "pdfUrl" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Invoice_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Payment" (
    "id" TEXT NOT NULL,
    "folioId" TEXT NOT NULL,
    "invoiceId" TEXT,
    "method" "PaymentMethod" NOT NULL,
    "status" "PaymentStatus" NOT NULL DEFAULT 'PENDING',
    "amount" DECIMAL(10,2) NOT NULL,
    "reference" TEXT,
    "paidAt" TIMESTAMP(3),
    "processedById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Payment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CommunicationLog" (
    "id" TEXT NOT NULL,
    "guestId" TEXT NOT NULL,
    "reservationId" TEXT,
    "type" "CommunicationType" NOT NULL,
    "status" "CommunicationStatus" NOT NULL DEFAULT 'SCHEDULED',
    "subject" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "scheduledAt" TIMESTAMP(3),
    "sentAt" TIMESTAMP(3),
    "failureReason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CommunicationLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ShiftReport" (
    "id" TEXT NOT NULL,
    "hotelId" TEXT NOT NULL,
    "staffMemberId" TEXT NOT NULL,
    "shiftStart" TIMESTAMP(3) NOT NULL,
    "shiftEnd" TIMESTAMP(3) NOT NULL,
    "summary" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ShiftReport_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AuditLog" (
    "id" TEXT NOT NULL,
    "hotelId" TEXT NOT NULL,
    "staffMemberId" TEXT,
    "entityType" TEXT NOT NULL,
    "entityId" TEXT NOT NULL,
    "action" TEXT NOT NULL,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "RoomType_hotelId_idx" ON "RoomType"("hotelId");

-- CreateIndex
CREATE UNIQUE INDEX "RoomType_hotelId_name_key" ON "RoomType"("hotelId", "name");

-- CreateIndex
CREATE INDEX "Room_hotelId_status_idx" ON "Room"("hotelId", "status");

-- CreateIndex
CREATE INDEX "Room_roomTypeId_idx" ON "Room"("roomTypeId");

-- CreateIndex
CREATE UNIQUE INDEX "Room_hotelId_number_key" ON "Room"("hotelId", "number");

-- CreateIndex
CREATE INDEX "RatePlan_roomTypeId_validFrom_validTo_idx" ON "RatePlan"("roomTypeId", "validFrom", "validTo");

-- CreateIndex
CREATE INDEX "RatePlan_hotelId_idx" ON "RatePlan"("hotelId");

-- CreateIndex
CREATE UNIQUE INDEX "StaffMember_userId_key" ON "StaffMember"("userId");

-- CreateIndex
CREATE INDEX "StaffMember_hotelId_role_idx" ON "StaffMember"("hotelId", "role");

-- CreateIndex
CREATE UNIQUE INDEX "Guest_userId_key" ON "Guest"("userId");

-- CreateIndex
CREATE INDEX "Guest_email_idx" ON "Guest"("email");

-- CreateIndex
CREATE INDEX "Guest_phone_idx" ON "Guest"("phone");

-- CreateIndex
CREATE INDEX "GroupBooking_hotelId_idx" ON "GroupBooking"("hotelId");

-- CreateIndex
CREATE INDEX "GroupBooking_contactGuestId_idx" ON "GroupBooking"("contactGuestId");

-- CreateIndex
CREATE UNIQUE INDEX "Reservation_confirmationCode_key" ON "Reservation"("confirmationCode");

-- CreateIndex
CREATE INDEX "Reservation_hotelId_checkInDate_checkOutDate_idx" ON "Reservation"("hotelId", "checkInDate", "checkOutDate");

-- CreateIndex
CREATE INDEX "Reservation_guestId_idx" ON "Reservation"("guestId");

-- CreateIndex
CREATE INDEX "Reservation_status_idx" ON "Reservation"("status");

-- CreateIndex
CREATE INDEX "Reservation_groupBookingId_idx" ON "Reservation"("groupBookingId");

-- CreateIndex
CREATE INDEX "ReservationRoom_reservationId_idx" ON "ReservationRoom"("reservationId");

-- CreateIndex
CREATE INDEX "ReservationRoom_roomId_idx" ON "ReservationRoom"("roomId");

-- CreateIndex
CREATE INDEX "ReservationRoom_roomTypeId_idx" ON "ReservationRoom"("roomTypeId");

-- CreateIndex
CREATE INDEX "DigitalKey_reservationId_idx" ON "DigitalKey"("reservationId");

-- CreateIndex
CREATE INDEX "DigitalKey_roomId_idx" ON "DigitalKey"("roomId");

-- CreateIndex
CREATE INDEX "HousekeepingTask_roomId_status_idx" ON "HousekeepingTask"("roomId", "status");

-- CreateIndex
CREATE INDEX "HousekeepingTask_assignedToId_status_idx" ON "HousekeepingTask"("assignedToId", "status");

-- CreateIndex
CREATE INDEX "MaintenanceTicket_roomId_status_idx" ON "MaintenanceTicket"("roomId", "status");

-- CreateIndex
CREATE INDEX "RoomStatusLog_roomId_createdAt_idx" ON "RoomStatusLog"("roomId", "createdAt");

-- CreateIndex
CREATE INDEX "POSOutlet_hotelId_idx" ON "POSOutlet"("hotelId");

-- CreateIndex
CREATE UNIQUE INDEX "POSOutlet_hotelId_name_key" ON "POSOutlet"("hotelId", "name");

-- CreateIndex
CREATE UNIQUE INDEX "Folio_reservationId_key" ON "Folio"("reservationId");

-- CreateIndex
CREATE INDEX "Folio_guestId_idx" ON "Folio"("guestId");

-- CreateIndex
CREATE INDEX "Folio_hotelId_idx" ON "Folio"("hotelId");

-- CreateIndex
CREATE INDEX "FolioCharge_folioId_idx" ON "FolioCharge"("folioId");

-- CreateIndex
CREATE UNIQUE INDEX "Invoice_invoiceNumber_key" ON "Invoice"("invoiceNumber");

-- CreateIndex
CREATE INDEX "Invoice_folioId_idx" ON "Invoice"("folioId");

-- CreateIndex
CREATE INDEX "Payment_folioId_idx" ON "Payment"("folioId");

-- CreateIndex
CREATE INDEX "CommunicationLog_guestId_type_idx" ON "CommunicationLog"("guestId", "type");

-- CreateIndex
CREATE INDEX "CommunicationLog_status_scheduledAt_idx" ON "CommunicationLog"("status", "scheduledAt");

-- CreateIndex
CREATE INDEX "ShiftReport_hotelId_shiftStart_idx" ON "ShiftReport"("hotelId", "shiftStart");

-- CreateIndex
CREATE INDEX "AuditLog_hotelId_createdAt_idx" ON "AuditLog"("hotelId", "createdAt");

-- CreateIndex
CREATE INDEX "AuditLog_entityType_entityId_idx" ON "AuditLog"("entityType", "entityId");

-- AddForeignKey
ALTER TABLE "RoomType" ADD CONSTRAINT "RoomType_hotelId_fkey" FOREIGN KEY ("hotelId") REFERENCES "Hotel"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Room" ADD CONSTRAINT "Room_hotelId_fkey" FOREIGN KEY ("hotelId") REFERENCES "Hotel"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Room" ADD CONSTRAINT "Room_roomTypeId_fkey" FOREIGN KEY ("roomTypeId") REFERENCES "RoomType"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RatePlan" ADD CONSTRAINT "RatePlan_hotelId_fkey" FOREIGN KEY ("hotelId") REFERENCES "Hotel"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RatePlan" ADD CONSTRAINT "RatePlan_roomTypeId_fkey" FOREIGN KEY ("roomTypeId") REFERENCES "RoomType"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StaffMember" ADD CONSTRAINT "StaffMember_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StaffMember" ADD CONSTRAINT "StaffMember_hotelId_fkey" FOREIGN KEY ("hotelId") REFERENCES "Hotel"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Guest" ADD CONSTRAINT "Guest_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "GroupBooking" ADD CONSTRAINT "GroupBooking_hotelId_fkey" FOREIGN KEY ("hotelId") REFERENCES "Hotel"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "GroupBooking" ADD CONSTRAINT "GroupBooking_contactGuestId_fkey" FOREIGN KEY ("contactGuestId") REFERENCES "Guest"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Reservation" ADD CONSTRAINT "Reservation_hotelId_fkey" FOREIGN KEY ("hotelId") REFERENCES "Hotel"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Reservation" ADD CONSTRAINT "Reservation_guestId_fkey" FOREIGN KEY ("guestId") REFERENCES "Guest"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Reservation" ADD CONSTRAINT "Reservation_groupBookingId_fkey" FOREIGN KEY ("groupBookingId") REFERENCES "GroupBooking"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Reservation" ADD CONSTRAINT "Reservation_checkedInById_fkey" FOREIGN KEY ("checkedInById") REFERENCES "StaffMember"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Reservation" ADD CONSTRAINT "Reservation_checkedOutById_fkey" FOREIGN KEY ("checkedOutById") REFERENCES "StaffMember"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ReservationRoom" ADD CONSTRAINT "ReservationRoom_reservationId_fkey" FOREIGN KEY ("reservationId") REFERENCES "Reservation"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ReservationRoom" ADD CONSTRAINT "ReservationRoom_roomTypeId_fkey" FOREIGN KEY ("roomTypeId") REFERENCES "RoomType"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ReservationRoom" ADD CONSTRAINT "ReservationRoom_roomId_fkey" FOREIGN KEY ("roomId") REFERENCES "Room"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ReservationRoom" ADD CONSTRAINT "ReservationRoom_ratePlanId_fkey" FOREIGN KEY ("ratePlanId") REFERENCES "RatePlan"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DigitalKey" ADD CONSTRAINT "DigitalKey_reservationId_fkey" FOREIGN KEY ("reservationId") REFERENCES "Reservation"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DigitalKey" ADD CONSTRAINT "DigitalKey_roomId_fkey" FOREIGN KEY ("roomId") REFERENCES "Room"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "HousekeepingTask" ADD CONSTRAINT "HousekeepingTask_roomId_fkey" FOREIGN KEY ("roomId") REFERENCES "Room"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "HousekeepingTask" ADD CONSTRAINT "HousekeepingTask_assignedToId_fkey" FOREIGN KEY ("assignedToId") REFERENCES "StaffMember"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MaintenanceTicket" ADD CONSTRAINT "MaintenanceTicket_roomId_fkey" FOREIGN KEY ("roomId") REFERENCES "Room"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MaintenanceTicket" ADD CONSTRAINT "MaintenanceTicket_reportedById_fkey" FOREIGN KEY ("reportedById") REFERENCES "StaffMember"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MaintenanceTicket" ADD CONSTRAINT "MaintenanceTicket_assignedToId_fkey" FOREIGN KEY ("assignedToId") REFERENCES "StaffMember"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RoomStatusLog" ADD CONSTRAINT "RoomStatusLog_roomId_fkey" FOREIGN KEY ("roomId") REFERENCES "Room"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RoomStatusLog" ADD CONSTRAINT "RoomStatusLog_changedById_fkey" FOREIGN KEY ("changedById") REFERENCES "StaffMember"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "POSOutlet" ADD CONSTRAINT "POSOutlet_hotelId_fkey" FOREIGN KEY ("hotelId") REFERENCES "Hotel"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Folio" ADD CONSTRAINT "Folio_reservationId_fkey" FOREIGN KEY ("reservationId") REFERENCES "Reservation"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Folio" ADD CONSTRAINT "Folio_guestId_fkey" FOREIGN KEY ("guestId") REFERENCES "Guest"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Folio" ADD CONSTRAINT "Folio_hotelId_fkey" FOREIGN KEY ("hotelId") REFERENCES "Hotel"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FolioCharge" ADD CONSTRAINT "FolioCharge_folioId_fkey" FOREIGN KEY ("folioId") REFERENCES "Folio"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FolioCharge" ADD CONSTRAINT "FolioCharge_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "POSOutlet"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FolioCharge" ADD CONSTRAINT "FolioCharge_postedById_fkey" FOREIGN KEY ("postedById") REFERENCES "StaffMember"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Invoice" ADD CONSTRAINT "Invoice_folioId_fkey" FOREIGN KEY ("folioId") REFERENCES "Folio"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_folioId_fkey" FOREIGN KEY ("folioId") REFERENCES "Folio"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES "Invoice"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_processedById_fkey" FOREIGN KEY ("processedById") REFERENCES "StaffMember"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CommunicationLog" ADD CONSTRAINT "CommunicationLog_guestId_fkey" FOREIGN KEY ("guestId") REFERENCES "Guest"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CommunicationLog" ADD CONSTRAINT "CommunicationLog_reservationId_fkey" FOREIGN KEY ("reservationId") REFERENCES "Reservation"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ShiftReport" ADD CONSTRAINT "ShiftReport_hotelId_fkey" FOREIGN KEY ("hotelId") REFERENCES "Hotel"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ShiftReport" ADD CONSTRAINT "ShiftReport_staffMemberId_fkey" FOREIGN KEY ("staffMemberId") REFERENCES "StaffMember"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_hotelId_fkey" FOREIGN KEY ("hotelId") REFERENCES "Hotel"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_staffMemberId_fkey" FOREIGN KEY ("staffMemberId") REFERENCES "StaffMember"("id") ON DELETE SET NULL ON UPDATE CASCADE;

