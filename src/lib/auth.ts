import { SignJWT, jwtVerify } from "jose";
import { cookies } from "next/headers";
import { prisma } from "@/lib/prisma";

const COOKIE = "absensi_session";
const secret = new TextEncoder().encode(process.env.AUTH_SECRET ?? "");
export type SessionUser = { id: string; role: "ADMIN" | "TEACHER" | "STUDENT"; name: string };

export async function createSession(user: SessionUser) {
  if (!process.env.AUTH_SECRET || process.env.AUTH_SECRET.length < 32) throw new Error("AUTH_SECRET must be at least 32 characters");
  const token = await new SignJWT(user).setProtectedHeader({ alg: "HS256" }).setIssuedAt().setExpirationTime("8h").sign(secret);
  (await cookies()).set(COOKIE, token, { httpOnly: true, secure: process.env.NODE_ENV === "production", sameSite: "lax", path: "/", maxAge: 60 * 60 * 8 });
}
export async function getSession(): Promise<SessionUser | null> {
  const token = (await cookies()).get(COOKIE)?.value;
  if (!token || secret.length < 32) return null;
  try {
    const { payload } = await jwtVerify(token, secret);
    if (typeof payload.id !== "string" || typeof payload.role !== "string" || typeof payload.name !== "string") return null;
    const user = await prisma.user.findUnique({ where: { id: payload.id }, select: { id: true, name: true, role: true, active: true } });
    if (!user?.active) return null;
    return { id: user.id, name: user.name, role: user.role };
  } catch { return null; }
}
export async function destroySession() {
  (await cookies()).set(COOKIE, "", { httpOnly: true, secure: process.env.NODE_ENV === "production", sameSite: "lax", path: "/", maxAge: 0 });
}
