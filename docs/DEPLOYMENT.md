# Deployment and first administrator

## Required Railway variables
- DATABASE_URL: Railway PostgreSQL connection URL (prefer private networking reference).
- AUTH_SECRET: cryptographically random secret, at least 32 characters.
- BOOTSTRAP_SECRET: one-time secret used only to create the first administrator. Remove it after bootstrap.
- APP_TIMEZONE: Asia/Jakarta.

The service is configured by railway.json to run `npm run build`, `npx prisma migrate deploy`, and `npm start`. The health check is `/api/health`.

## Bootstrap
After setting the required variables and deploying the service, call POST /api/bootstrap with header `x-bootstrap-secret: <BOOTSTRAP_SECRET>` and JSON body `{"name":"Administrator","email":"admin@school.example","password":"use-a-unique-password-of-12-chars-or-more"}`. Use a real school email and a unique password. Once the first admin is created, remove BOOTSTRAP_SECRET from Railway variables and redeploy. The endpoint refuses to create a second admin.

## Existing QR values
Import each student's existing QR payload unchanged in the QR Code field. Do not encode a new identifier or expose the QR payload in public exports. Treat the QR payload as a lookup credential, not proof of identity; scanner access is limited to authenticated staff.

## Camera
Camera scanning requires HTTPS and browser permission. Use a secure Railway domain and grant camera access. Upload-image decoding and manual input are fallback options.

## Database
Production schema changes are managed with Prisma migrations. Back up PostgreSQL before future schema changes.
