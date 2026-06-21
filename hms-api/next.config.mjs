/** @type {import('next').NextConfig} */
const nextConfig = {
  serverExternalPackages: [
    "better-auth",
    "@better-auth/core",
    "@better-auth/prisma-adapter",
    "@better-auth/kysely-adapter",
    "kysely",
  ],
};

export default nextConfig;
