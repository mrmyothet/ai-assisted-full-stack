import { Resend } from "resend";

const resend = new Resend(process.env.RESEND_API_KEY);

type SendOtpEmailInput = {
  to: string;
  otp: string;
};

export async function sendOtpEmail({ to, otp }: SendOtpEmailInput) {
  if (!process.env.RESEND_API_KEY || !process.env.RESEND_FROM_EMAIL) {
    console.warn("Resend is not configured. OTP:", otp);
    return;
  }

  void resend.emails.send({
    from: process.env.RESEND_FROM_EMAIL,
    to,
    subject: "Your Technortal login code",
    html: `
      <div style="font-family: sans-serif; max-width: 480px; margin: 0 auto;">
        <h2>Technortal Hotel</h2>
        <p>Your verification code is:</p>
        <p style="font-size: 32px; font-weight: bold; letter-spacing: 4px;">${otp}</p>
        <p>This code expires in 5 minutes.</p>
      </div>
    `,
  });
}
