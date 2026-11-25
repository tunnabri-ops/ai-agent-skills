---
name: pern-stack
description: Use when building a production PERN application with PostgreSQL, Express, React, and Node.js using Prisma, including schema design, migrations, relations, transactions, indexing, connection pooling, JWT authentication, validation, pagination, file uploads, testing, and deployment.
---

# PERN Stack
Build a production PERN application the way a senior team would: one repository, a clear server/client split, a typed Prisma layer between the code and PostgreSQL, real authentication, validated input, consistent errors, and tests that run before every deploy. No feature ships without its route, its model, its migration, and its test.
## When to Use This Skill
- The user asks for a full-stack app with PostgreSQL, Express, React, Node.js.
- A new PERN project needs scaffolding, Prisma setup, or a production setup.
- An existing PERN app needs auth, relations, transactions, or deployment.
- The data is relational: users, orders, invoices, joins, and constraints.
## When Not to Use It
- The data is schemaless documents with no joins: use MERN instead.
- The backend is Python-only: use the FastAPI skill instead.
- The app is a static site with no server state or database.
## Tech Choices
- Node.js 20 LTS, Express 4 or 5, Prisma 5 or 6, PostgreSQL 16, React 18 or 19, Vite.
- TypeScript on both sides for any project living longer than a month.
- PostgreSQL hosted on Neon, Supabase, or Railway; local Postgres in Docker.
- JWT access tokens (15 minutes) plus rotating refresh tokens (7 days).
- Zod for validation, never hand-rolled string checks.
- Vitest plus Supertest on the server; Vitest plus Testing Library on
the client; Playwright for one end-to-end happy path.
## 1. Scaffold the Project
```bash
mkdir my-app && cd my-app
mkdir -p server/src/{config,routes,controllers,services,middleware,utils}
mkdir -p server/prisma server/tests
npm create vite@latest client -- --template react-ts
cd server && npm install express dotenv cors helmet morgan jsonwebtoken bcryptjs zod multer express-rate-limit @prisma/client
npm install -D prisma nodemon vitest supertest typescript tsx
npx prisma init --datasource-provider postgresql
docker run --name pern-db -e POSTGRES_PASSWORD=devpass -e POSTGRES_DB=myapp -p 5432:5432 -d postgres:16
cd ../client && npm install react-router-dom axios zustand
npm install -D vitest @testing-library/react @testing-library/jest-dom
```
Pin exact versions in `package.json`, commit `package-lock.json`, add `.env.example` with every variable the app needs, and never commit a real `.env` file. Set `DATABASE_URL` in `.env` before the first migration.
## 2. Starter File Tree
```text
my-app/
  client/src/ api/client.ts components/ features/auth/ features/items/
    pages/ routes/ hooks/ lib/ App.tsx main.tsx
  server/
    prisma/schema.prisma prisma/migrations/ prisma/seed.ts
    src/ config/env.ts lib/prisma.ts routes/auth.routes.ts routes/items.routes.ts
      controllers/auth.controller.ts controllers/items.controller.ts
      services/auth.service.ts services/items.service.ts
      middleware/auth.ts middleware/errorHandler.ts middleware/validate.ts
      utils/pagination.ts utils/apiError.ts app.ts server.ts
    tests/ auth.test.ts items.test.ts
  .env.example README.md
```
Rules: routes map URLs to controllers; controllers parse request and response only; services hold business logic and Prisma calls; the schema is the single source of truth for the database. Never write raw SQL in a controller, and never query Prisma from a route handler directly.
## 3. Prisma Schema and Migrations
```prisma
model User {
  id String @id @default(uuid()); email String @unique; password String
  role Role @default(USER); items Item[]
  createdAt DateTime @default(now()); updatedAt DateTime @updatedAt
}
model Item {
  id String @id @default(uuid()); ownerId String
  owner User @relation(fields: [ownerId], references: [id], onDelete: Cascade)
  title String @db.VarChar(200); status Status @default(DRAFT)
  createdAt DateTime @default(now()); updatedAt DateTime @updatedAt
  @@index([ownerId, createdAt(sort: Desc)]); @@index([status])
}
enum Role { USER ADMIN }
enum Status { DRAFT PUBLISHED ARCHIVED }
```
```bash
npx prisma migrate dev --name add_items
npx prisma generate
npx prisma studio   # inspect data in the browser
npx prisma db seed  # run prisma/seed.ts after seeding is configured
```
Create a migration for every schema change, review the generated SQL before applying it, and never edit an applied migration in place. Commit migrations to version control; a deploy that skips `prisma migrate deploy` will fail against the real database.
## 4. Prisma Client, Pooling, and Transactions
```ts
// server/src/lib/prisma.ts
import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient({ log: ["error", "warn"] });
export default prisma;
```
Use one shared Prisma Client for the whole server, never a new client per request. PostgreSQL allows about 100 connections by default, so set the pool in the connection string: append `?connection_limit=10& pool_timeout=20` to `DATABASE_URL` on a small server, and use PgBouncer in transaction mode when the app scales past one server instance. Always call `await prisma.$disconnect()` on shutdown, and verify the pool with a health check that runs a cheap `SELECT 1` through Prisma. Wrap multi-step writes in a transaction so a partial write can never survive: `await prisma.$transaction(async (tx) => { ... })`. Example: creating an order and decrementing stock must succeed or fail together; if the second step throws, the first step rolls back. Fetch relations with `include` or `select`, never with N+1 queries in a loop, and use `select` to return only the fields the client needs.
## 5. Relations, Indexing, and Query Rules
- Add `@@index` for every field used in a `where`, `orderBy`, or join,
and a `@@unique` constraint for every business rule that must hold, such as one email per user or one slug per item.
- Use `onDelete: Cascade` only where deleting the parent should delete
the children; use `Restrict` for records that must never vanish, such as invoices. Check slow queries with `EXPLAIN ANALYZE` in `psql` before adding an index you cannot justify.
- Prefer `findUnique` for lookups by id or unique field, `findMany`
with `take` and `skip` for lists, and `count` with the same `where` clause for totals. Never fetch all rows and filter in JavaScript.
- Use cursor pagination (`cursor` plus `take`) for large feeds, and
offset pagination for admin tables where jumping to a page matters.
## 6. Authentication: JWT Plus Refresh Tokens
- Register: hash the password with bcrypt (cost 12), never log it.
- Login: verify the password, issue a short access token and a refresh
token. Store the refresh token hashed in a `RefreshToken` table with an expiry and a `userId` foreign key.
- Access token: 15 minutes, signed with `JWT_ACCESS_SECRET`, payload
holds only `userId` and `role`, nothing sensitive.
- Refresh: client calls `POST /api/auth/refresh` with the refresh token
in an `httpOnly`, `secure`, `sameSite=strict` cookie. Rotate the token on every use; reuse of an old token revokes the whole token family.
- Logout: delete the stored refresh token row and clear the cookie.
- Protect routes with middleware that verifies the access token and
attaches `req.user`; check ownership in the service layer with a Prisma `where: { id, ownerId: req.user.id }` clause, so an id in the URL can never leak another user's data.
## 7. Validation and Error Handling
Validate every body, query string, and route parameter with Zod before the controller runs:
```ts
import { z } from "zod";
export const createItemSchema = z.object({
  body: z.object({ title: z.string().trim().min(1).max(200),
    status: z.enum(["DRAFT", "PUBLISHED"]).optional() }),
});
```
Return one error shape everywhere: `{ "error": { "code": "VALIDATION_ERROR", "message": "Title is required", "details": [...] } }`. Use 400 for bad input, 401 for missing or expired auth, 403 for a forbidden owner, 404 for a missing resource, 409 for a duplicate (Prisma error `P2002`), and 500 only for real server failures. Map Prisma errors in the error handler: `P2002` to 409, `P2025` to 404. Log 500s with a request id; never leak a stack trace or a database error to the client.
## 8. Pagination, Filtering, and Sorting
```text
GET /api/items?page=2&limit=20&status=PUBLISHED&sort=-createdAt&q=search
```
Response shape: `{ "data": [...], "page": 2, "limit": 20, "total": 137, "totalPages": 7 }`. Clamp `limit` to a maximum of 100, default 20, and reject negative pages. Implement it with one `findMany` plus one `count` inside a single `Promise.all`, both sharing the same `where` clause. Use `contains` with `mode: "insensitive"` for search, and add a full-text index when search is a core feature. Always scope list queries to the logged-in owner unless the route is explicitly public.
## 9. File Uploads and React Client
- Accept uploads with Multer, limit size to 5 MB per file, allow only an
explicit list of MIME types, and rename files with a UUID, never the user-supplied filename. Store the file URL in a Prisma `String` field.
- Store files in Cloudinary or S3 in production, never on the server's
local disk on a hosted platform. Delete the old file when a record is updated or removed, and serve uploads through a signed URL or a CDN.
- Client: one axios instance with a base URL from `VITE_API_URL` and an
interceptor that attaches the access token and retries once after a 401 by calling the refresh endpoint.
- Auth state in a small Zustand store, with a `ProtectedRoute` that
redirects to `/login`. Every list shows loading, error, and empty states; forms are controlled, server errors show next to their field, and the submit button is disabled while a request is in flight.
## 10. Testing
```bash
cd server && npx vitest run
cd ../client && npx vitest run
npx playwright test   # end-to-end: register, login, create, list
```
Cover at minimum: duplicate-email register returns 409, wrong-password login returns 401, an unauthenticated protected request returns 401, a user cannot read another user's item, validation rejects an empty title, a transaction rolls back when the second step fails, and pagination returns the correct `total`. Run server tests against a dedicated test database, reset with `prisma migrate reset --force` in the test setup, never against production data. Keep coverage above 70 percent on services and auth; a passing suite is required before any deploy.
## 11. Deployment
- Client on Vercel: set `VITE_API_URL` to the server URL, build command
`npm run build`, output directory `dist`. Check the deploy preview on every pull request before merging.
- Server on Render or Railway as a Web Service, database on Neon or
Supabase: build command `npm install && npx prisma generate && npm run build`, start command `npx prisma migrate deploy && node dist/server.js`. Set `DATABASE_URL`, `JWT_ACCESS_SECRET`, `JWT_REFRESH_SECRET`, and `CLIENT_URL` in the dashboard, never in code.
- Before going live: confirm CORS allows only the real client origin,
rate-limit auth routes to 5 attempts per 15 minutes per IP, enable Helmet, run migrations against production once, and verify the live build with `curl` on `/api/health`.
## Checklist
- [ ] Prisma schema is the single source of truth; migrations committed.
- [ ] One shared Prisma Client; pool sized; PgBouncer planned for scale.
- [ ] Indexes on filtered, sorted, and joined fields; uniques enforced.
- [ ] Multi-step writes wrapped in `prisma.$transaction`.
- [ ] Passwords hashed with bcrypt; refresh tokens hashed and rotated.
- [ ] Zod validation on every write route; Prisma errors mapped to HTTP codes.
- [ ] Pagination clamped, `total` returned, search bounded.
- [ ] Uploads size-limited, type-checked, stored off the server disk.
- [ ] Tests pass: auth, ownership, validation, pagination, rollback.
- [ ] Deployed with `prisma migrate deploy`; health endpoint live.
## Pitfalls
- **Editing an applied migration.** Create a new migration instead;
editing history breaks every other environment.
- **A new Prisma Client per request.** It exhausts the Postgres pool
fast; share one client and size the pool explicitly.
- **N+1 queries in a loop.** Use `include` or `select` once; a loop of
queries is slow at 10 rows and fatal at 10,000.
- **Trusting the client for ownership.** Always add `ownerId` to the
Prisma `where` clause on the server.
- **Deploying without `migrate deploy`.** The code and the database
drift apart, and the first real request fails with a missing column.
