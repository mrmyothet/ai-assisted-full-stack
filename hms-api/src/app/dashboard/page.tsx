import { redirect } from "next/navigation";
import { getSession } from "@/lib/session";
import prisma from "@lib/prisma";
import { SignOutButton } from "./sign-out-button";

export default async function DashboardPage() {
  const session = await getSession();

  if (!session) {
    redirect("/login");
  }

  const staffMember = await prisma.staffMember.findUnique({
    where: { userId: session.user.id },
    select: { role: true, isActive: true },
  });

  if (!staffMember?.isActive) {
    redirect("/login");
  }

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-5xl flex-col gap-6 px-6 py-10">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-semibold text-neutral-900">
            Technortal Hotel Admin
          </h1>
          <p className="mt-1 text-neutral-600">
            Signed in as {session.user.email} ({staffMember.role})
          </p>
        </div>
        <SignOutButton />
      </div>

      <section className="rounded-xl border border-neutral-200 bg-white p-6 shadow-sm">
        <h2 className="text-lg font-medium text-neutral-900">Dashboard</h2>
        <p className="mt-2 text-neutral-600">
          Welcome to the Technortal Hotel management dashboard. Reservation,
          housekeeping, and billing modules will be added here.
        </p>
      </section>
    </main>
  );
}
