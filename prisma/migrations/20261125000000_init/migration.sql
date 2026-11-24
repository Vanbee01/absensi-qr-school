CREATE TYPE "Role" AS ENUM ('ADMIN', 'TEACHER', 'STUDENT');
CREATE TYPE "StudentStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'GRADUATED');
CREATE TYPE "AttendanceStatus" AS ENUM ('PRESENT', 'LATE', 'PERMISSION', 'SICK', 'ABSENT');
CREATE TYPE "SessionType" AS ENUM ('CHECK_IN', 'CHECK_OUT');

CREATE TABLE "User" (
 "id" TEXT NOT NULL, "name" TEXT NOT NULL, "email" TEXT NOT NULL, "passwordHash" TEXT NOT NULL,
 "role" "Role" NOT NULL DEFAULT 'STUDENT', "active" BOOLEAN NOT NULL DEFAULT true,
 "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "updatedAt" TIMESTAMP(3) NOT NULL,
 CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);
CREATE TABLE "ClassRoom" (
 "id" TEXT NOT NULL, "name" TEXT NOT NULL, "major" TEXT, "grade" TEXT, "homeroomId" TEXT,
 "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, CONSTRAINT "ClassRoom_pkey" PRIMARY KEY ("id")
);
CREATE TABLE "Teacher" (
 "id" TEXT NOT NULL, "userId" TEXT NOT NULL, "employeeNo" TEXT,
 CONSTRAINT "Teacher_pkey" PRIMARY KEY ("id")
);
CREATE TABLE "Student" (
 "id" TEXT NOT NULL, "userId" TEXT, "nis" TEXT NOT NULL, "nisn" TEXT, "name" TEXT NOT NULL,
 "gender" TEXT, "phone" TEXT, "address" TEXT, "photoUrl" TEXT, "qrValue" TEXT NOT NULL,
 "status" "StudentStatus" NOT NULL DEFAULT 'ACTIVE', "classId" TEXT NOT NULL,
 "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "updatedAt" TIMESTAMP(3) NOT NULL,
 CONSTRAINT "Student_pkey" PRIMARY KEY ("id")
);
CREATE TABLE "AttendanceSession" (
 "id" TEXT NOT NULL, "name" TEXT NOT NULL, "type" "SessionType" NOT NULL DEFAULT 'CHECK_IN',
 "startsAt" TIMESTAMP(3) NOT NULL, "endsAt" TIMESTAMP(3) NOT NULL, "lateAfter" TIMESTAMP(3) NOT NULL,
 "active" BOOLEAN NOT NULL DEFAULT true, "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT "AttendanceSession_pkey" PRIMARY KEY ("id")
);
CREATE TABLE "Attendance" (
 "id" TEXT NOT NULL, "studentId" TEXT NOT NULL, "sessionId" TEXT NOT NULL, "date" DATE NOT NULL,
 "status" "AttendanceStatus" NOT NULL, "scannedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
 "method" TEXT NOT NULL DEFAULT 'QR', "recordedBy" TEXT, "note" TEXT,
 "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "updatedAt" TIMESTAMP(3) NOT NULL,
 CONSTRAINT "Attendance_pkey" PRIMARY KEY ("id")
);
CREATE TABLE "AttendanceLog" (
 "id" TEXT NOT NULL, "attendanceId" TEXT NOT NULL, "actorId" TEXT, "action" TEXT NOT NULL,
 "before" JSONB, "after" JSONB, "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT "AttendanceLog_pkey" PRIMARY KEY ("id")
);
CREATE TABLE "SchoolSetting" (
 "id" TEXT NOT NULL, "key" TEXT NOT NULL, "value" JSONB NOT NULL,
 "updatedAt" TIMESTAMP(3) NOT NULL, CONSTRAINT "SchoolSetting_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "User_email_key" ON "User"("email");
CREATE UNIQUE INDEX "ClassRoom_name_major_key" ON "ClassRoom"("name","major");
CREATE UNIQUE INDEX "Teacher_userId_key" ON "Teacher"("userId");
CREATE UNIQUE INDEX "Teacher_employeeNo_key" ON "Teacher"("employeeNo");
CREATE UNIQUE INDEX "Student_userId_key" ON "Student"("userId");
CREATE UNIQUE INDEX "Student_nis_key" ON "Student"("nis");
CREATE UNIQUE INDEX "Student_nisn_key" ON "Student"("nisn");
CREATE UNIQUE INDEX "Student_qrValue_key" ON "Student"("qrValue");
CREATE INDEX "Student_classId_status_idx" ON "Student"("classId","status");
CREATE INDEX "Student_name_idx" ON "Student"("name");
CREATE UNIQUE INDEX "Attendance_studentId_sessionId_date_key" ON "Attendance"("studentId","sessionId","date");
CREATE INDEX "Attendance_date_status_idx" ON "Attendance"("date","status");
CREATE INDEX "Attendance_sessionId_date_idx" ON "Attendance"("sessionId","date");
CREATE UNIQUE INDEX "SchoolSetting_key_key" ON "SchoolSetting"("key");

ALTER TABLE "ClassRoom" ADD CONSTRAINT "ClassRoom_homeroomId_fkey" FOREIGN KEY ("homeroomId") REFERENCES "Teacher"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Teacher" ADD CONSTRAINT "Teacher_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Student" ADD CONSTRAINT "Student_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Student" ADD CONSTRAINT "Student_classId_fkey" FOREIGN KEY ("classId") REFERENCES "ClassRoom"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Attendance" ADD CONSTRAINT "Attendance_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "Student"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Attendance" ADD CONSTRAINT "Attendance_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "AttendanceSession"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "AttendanceLog" ADD CONSTRAINT "AttendanceLog_attendanceId_fkey" FOREIGN KEY ("attendanceId") REFERENCES "Attendance"("id") ON DELETE CASCADE ON UPDATE CASCADE;
