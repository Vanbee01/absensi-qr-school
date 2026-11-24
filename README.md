# Sistem Informasi Absensi Siswa Berbasis QR Code

Next.js, TypeScript, Prisma, PostgreSQL, and ZXing browser QR reader.

## Setup
1. Copy `.env.example` to `.env` and configure `DATABASE_URL` and a 32+ character `AUTH_SECRET`.
2. Install dependencies with `npm install`.
3. Generate Prisma client: `npm run db:generate`.
4. Apply schema in development: `npm run db:push` (production should use committed migrations and `npm run db:migrate`).
5. Run `npm run dev`.

## QR identity
The `Student.qrValue` field stores the existing QR payload exactly as supplied by the school. The app does not generate replacement QR codes. Scanning checks this value against the database.

## Security
Passwords are stored as bcrypt hashes. Session tokens are signed and stored in HTTP-only cookies. Attendance uniqueness is enforced by a database unique constraint on student, session, and date; writes and audit records use a transaction.

## Initial data
No demo students, QR identities, or default credentials are included. Create the first administrator through a trusted seed/bootstrap process before opening the app to users. Never expose production credentials in the repository.
