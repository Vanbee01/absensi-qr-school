import { NextResponse } from "next/server";
import { Prisma } from "@prisma/client";
import { z } from "zod";
import { prisma } from "@/lib/prisma";
import { getSession } from "@/lib/auth";

const schema = z.object({ code: z.string().trim().min(1).max(2048) });
export async function POST(req: Request) {
  const actor = await getSession();
  if (!actor || !["ADMIN", "TEACHER"].includes(actor.role)) return NextResponse.json({ error: "Tidak memiliki akses." }, { status: 403 });
  try {
    const { code } = schema.parse(await req.json());
    const student = await prisma.student.findFirst({ where: { qrValue: code, status: "ACTIVE" }, include: { classroom: true } });
    if (!student) return NextResponse.json({ error: "QR Code tidak terdaftar atau siswa tidak aktif." }, { status: 404 });
    const now = new Date();
    const date = new Date(now); date.setHours(0,0,0,0);
    const session = await prisma.attendanceSession.findFirst({ where: { active: true, type: "CHECK_IN", startsAt: { lte: now }, endsAt: { gte: now } }, orderBy: { startsAt: "desc" } });
    if (!session) return NextResponse.json({ error: "Tidak ada sesi absensi yang sedang berlangsung." }, { status: 409 });
    try {
      const attendance = await prisma.$transaction(async tx => {
        const created = await tx.attendance.create({
          data: { studentId: student.id, sessionId: session.id, date, status: now > session.lateAfter ? "LATE" : "PRESENT", method: "QR", recordedBy: actor.id }
        });
        await tx.attendanceLog.create({ data: { attendanceId: created.id, actorId: actor.id, action: "QR_CHECK_IN", after: { status: created.status, method: "QR", sessionId: session.id } } });
        return created;
      }, { isolationLevel: Prisma.TransactionIsolationLevel.Serializable });
      return NextResponse.json({ ok: true, attendance: { id: attendance.id, status: attendance.status, scannedAt: attendance.scannedAt }, student: { name: student.name, nis: student.nis, classroom: student.classroom.name, photoUrl: student.photoUrl } });
    } catch (e) {
      if (e instanceof Prisma.PrismaClientKnownRequestError && e.code === "P2002") return NextResponse.json({ error: "Siswa sudah melakukan absensi pada sesi ini." }, { status: 409 });
      throw e;
    }
  } catch (e) {
    if (e instanceof z.ZodError) return NextResponse.json({ error: "Kode QR tidak valid." }, { status: 400 });
    return NextResponse.json({ error: "Gagal menyimpan absensi." }, { status: 500 });
  }
}