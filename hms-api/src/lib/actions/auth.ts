"use server";

import { auth } from "@lib/auth";
import prisma from "@lib/prisma";
import { headers } from "next/headers";

type ActionResult = {
  success: boolean;
  error?: string;
};

export async function verifyStaffAccess(): Promise<ActionResult> {
  const session = await auth.api.getSession({
    headers: await headers(),
  });

  if (!session) {
    return { success: false, error: "Not authenticated." };
  }

  const staffMember = await prisma.staffMember.findUnique({
    where: { userId: session.user.id },
    select: { isActive: true, role: true },
  });

  if (!staffMember?.isActive) {
    return {
      success: false,
      error: "Access denied. An active staff account is required.",
    };
  }

  return { success: true };
}
