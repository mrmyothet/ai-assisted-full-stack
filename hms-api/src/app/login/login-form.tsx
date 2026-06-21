"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { authClient } from "@/lib/auth-client";
import { verifyStaffAccess } from "@/lib/actions/auth";
import {
  loginOtpSchema,
  loginPasswordSchema,
  type LoginOtpInput,
  type LoginPasswordInput,
} from "@/lib/validations/auth";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";

type LoginStep = "credentials" | "otp";

export function LoginForm() {
  const router = useRouter();
  const [step, setStep] = useState<LoginStep>("credentials");
  const [email, setEmail] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [isPending, startTransition] = useTransition();

  const credentialsForm = useForm<LoginPasswordInput>({
    resolver: zodResolver(loginPasswordSchema),
    defaultValues: { email: "", password: "" },
  });

  const otpForm = useForm<LoginOtpInput>({
    resolver: zodResolver(loginOtpSchema),
    defaultValues: { code: "" },
  });

  const handleCredentialsSubmit = credentialsForm.handleSubmit((values) => {
    startTransition(async () => {
      setError(null);
      setEmail(values.email);

      await authClient.signIn.email(
        {
          email: values.email,
          password: values.password,
        },
        {
          onSuccess: async (context) => {
            if (context.data.twoFactorRedirect) {
              setStep("otp");
              const sendResult = await authClient.twoFactor.sendOtp();
              if (sendResult.error) {
                setError(
                  sendResult.error.message ?? "Failed to send verification code."
                );
              }
              return;
            }

            const access = await verifyStaffAccess();
            if (!access.success) {
              await authClient.signOut();
              setError(access.error ?? "Access denied.");
              return;
            }

            router.push("/dashboard");
            router.refresh();
          },
          onError: (context) => {
            setError(context.error.message ?? "Invalid email or password.");
          },
        }
      );
    });
  });

  const handleOtpSubmit = otpForm.handleSubmit((values) => {
    startTransition(async () => {
      setError(null);

      const verifyResult = await authClient.twoFactor.verifyOtp({
        code: values.code,
      });

      if (verifyResult.error) {
        setError(verifyResult.error.message ?? "Invalid verification code.");
        return;
      }

      const access = await verifyStaffAccess();
      if (!access.success) {
        await authClient.signOut();
        setError(access.error ?? "Access denied.");
        setStep("credentials");
        return;
      }

      router.push("/dashboard");
      router.refresh();
    });
  });

  const handleResendOtp = () => {
    startTransition(async () => {
      setError(null);
      const sendResult = await authClient.twoFactor.sendOtp();
      if (sendResult.error) {
        setError(sendResult.error.message ?? "Failed to resend verification code.");
      }
    });
  };

  const stepNumber = step === "credentials" ? 1 : 2;

  return (
    <Card className="w-full max-w-md">
      <CardHeader>
        <CardTitle>Technortal Hotel</CardTitle>
        <CardDescription>
          Staff sign in — step {stepNumber} of 2
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        {error ? (
          <p className="rounded-md bg-red-50 px-3 py-2 text-sm text-red-700">
            {error}
          </p>
        ) : null}

        {step === "credentials" ? (
          <Form {...credentialsForm}>
            <form onSubmit={handleCredentialsSubmit} className="space-y-4">
              <FormField
                control={credentialsForm.control}
                name="email"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Email</FormLabel>
                    <FormControl>
                      <Input
                        type="email"
                        autoComplete="email"
                        placeholder="admin@technortal.hotel"
                        {...field}
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <FormField
                control={credentialsForm.control}
                name="password"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Password</FormLabel>
                    <FormControl>
                      <Input
                        type="password"
                        autoComplete="current-password"
                        placeholder="Enter your password"
                        {...field}
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <Button type="submit" className="w-full" disabled={isPending}>
                {isPending ? "Signing in..." : "Continue"}
              </Button>
            </form>
          </Form>
        ) : null}

        {step === "otp" ? (
          <Form {...otpForm}>
            <form onSubmit={handleOtpSubmit} className="space-y-4">
              <p className="text-sm text-neutral-600">
                Enter the 6-digit code sent to {email}
              </p>
              <FormField
                control={otpForm.control}
                name="code"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Verification code</FormLabel>
                    <FormControl>
                      <Input
                        inputMode="numeric"
                        autoComplete="one-time-code"
                        placeholder="123456"
                        maxLength={6}
                        {...field}
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <div className="flex gap-2">
                <Button
                  type="button"
                  variant="outline"
                  className="w-full"
                  onClick={() => setStep("credentials")}
                  disabled={isPending}
                >
                  Back
                </Button>
                <Button type="submit" className="w-full" disabled={isPending}>
                  {isPending ? "Verifying..." : "Verify"}
                </Button>
              </div>
              <Button
                type="button"
                variant="ghost"
                className="w-full"
                onClick={handleResendOtp}
                disabled={isPending}
              >
                Resend code
              </Button>
            </form>
          </Form>
        ) : null}
      </CardContent>
    </Card>
  );
}
