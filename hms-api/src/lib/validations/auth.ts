import { z } from "zod";

export const loginPasswordSchema = z.object({
  email: z.string().email("Enter a valid email address"),
  password: z.string().min(8, "Password must be at least 8 characters"),
});

export const loginOtpSchema = z.object({
  code: z
    .string()
    .length(6, "Enter the 6-digit code")
    .regex(/^\d+$/, "Code must contain only numbers"),
});

export type LoginPasswordInput = z.infer<typeof loginPasswordSchema>;
export type LoginOtpInput = z.infer<typeof loginOtpSchema>;
