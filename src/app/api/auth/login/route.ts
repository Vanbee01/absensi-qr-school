import { NextResponse } from "next/server";
import bcrypt from "bcryptjs";
import { z } from "zod";
import { prisma } from "@/lib/prisma";
import { createSession } from "@/lib/auth";

const schema = z.object({ email: z.string().email(), password: z.string().min(1) });
export async function POST(req: Request) {
  try {
    const body = schema.parse(await req.json());
    const user = await prisma.user.findUnique({ where: { email: body.email } });
    if (!user || !user.active || !(await bcrypt.compare(body.password, user.passwordHash))) {
      return NextResponse.json({ error: "Email atau password tidak valid." }, { status: 401 });
    }
    await createSession({ id: user.id, name: user.name, role: user.role });
    return NextResponse.json({ ok: true, role: user.role });
  } catch (e) {
    if (e instanceof z.ZodError) return NextResponse.json({ error: "Format login tidak valid." }, { status: 400 });
    return NextResponse.json({ error: "Terjadi kesalahan server." }, { status: 500 });
  }
}