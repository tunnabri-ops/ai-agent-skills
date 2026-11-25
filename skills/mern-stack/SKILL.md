---
name: mern-stack
description: Use when building a production MERN application with MongoDB, Express, React, and Node.js, including project scaffolding, JWT authentication with refresh tokens, validation, pagination, file uploads, testing, and deployment to Vercel and Render or Railway.
---

# MERN Stack
Build a production MERN application the way a senior team would: one
repository, a clear server/client split, typed boundaries between layers,
real authentication, validated input, consistent errors, and tests that
run before every deploy. No feature ships without its route, its model,
its validation, and its test.
## When to Use This Skill
- The user asks for a full-stack app with MongoDB, Express, React, Node.js.
- A new MERN project needs scaffolding, structure, or a production setup.
- An existing MERN app needs auth, pagination, uploads, or deployment.
## When Not to Use It
- The data is strongly relational with complex joins: use PERN instead.
- The backend is Python-only: use the FastAPI skill instead.
- The app is a static site with no server state or database.
## Tech Choices
- Node.js 20 LTS, Express 4 or 5, Mongoose 8, React 18 or 19, Vite.
- TypeScript on both sides for any project living longer than a month.
- MongoDB Atlas for hosted data, Compass for local inspection.
- JWT access tokens (15 minutes) plus rotating refresh tokens (7 days).
- Zod or Joi for validation, never hand-rolled string checks.
- Vitest plus Supertest on the server; Vitest plus Testing Library on
  the client; Playwright for one end-to-end happy path.
## 1. Scaffold the Project
```bash
mkdir my-app && cd my-app
mkdir -p server/src/{config,models,routes,controllers,services,middleware,utils}
mkdir -p server/tests
npm create vite@latest client -- --template react-ts
cd server && npm install express mongoose dotenv cors helmet morgan jsonwebtoken bcryptjs zod multer express-rate-limit
npm install -D nodemon vitest supertest typescript tsx
cd ../client && npm install react-router-dom axios zustand
npm install -D vitest @testing-library/react @testing-library/jest-dom
```
Pin exact versions in `package.json`, commit `package-lock.json`, add
`.env.example` with every variable the app needs, and never commit a
real `.env` file.
## 2. Starter File Tree
```text
my-app/
  client/src/ api/client.ts components/ features/auth/ features/items/
    pages/ routes/ hooks/ lib/ App.tsx main.tsx
  server/src/ config/db.ts config/env.ts models/User.ts models/Item.ts
    routes/auth.routes.ts routes/items.routes.ts
    controllers/auth.controller.ts controllers/items.controller.ts
    services/auth.service.ts services/items.service.ts
    middleware/auth.ts middleware/errorHandler.ts middleware/validate.ts
    utils/pagination.ts utils/apiError.ts app.ts server.ts
  server/tests/ auth.test.ts items.test.ts
  .env.example README.md
```
Rules: routes map URLs to controllers; controllers parse request and
response only; services hold business logic; models hold schema and
indexes only. A controller that queries the database directly is a
defect, not a shortcut.
## 3. Server and Database
```ts
// server/src/config/db.ts
import mongoose from "mongoose";
export async function connectDb(uri: string) {
  mongoose.set("strictQuery", true);
  await mongoose.connect(uri, { maxPoolSize: 10, serverSelectionTimeoutMS: 5000 });
}
```
```ts
// server/src/app.ts
import express from "express"; import cors from "cors"; import helmet from "helmet";
const app = express();
app.use(helmet());
app.use(cors({ origin: process.env.CLIENT_URL, credentials: true }));
app.use(express.json({ limit: "1mb" }));
app.use("/api/auth", authRoutes); app.use("/api/items", itemsRoutes);
app.get("/api/health", (_req, res) => res.json({ ok: true }));
app.use(errorHandler); export default app;
```
Start the server only after the database connects, and exit loudly on failure instead of serving requests against a dead database.
## 4. Models and Indexes
```ts
// server/src/models/Item.ts
import { Schema, model } from "mongoose";
const itemSchema = new Schema({
  owner: { type: Schema.Types.ObjectId, ref: "User", required: true, index: true },
  title: { type: String, required: true, trim: true, maxlength: 200 },
  status: { type: String, enum: ["draft", "published", "archived"], default: "draft", index: true },
}, { timestamps: true });
itemSchema.index({ owner: 1, createdAt: -1 });
export const Item = model("Item", itemSchema);
```
Add an index for every field used in a filter or sort, set `maxlength`
on user text, and use `timestamps: true` on every model. Never store a
plain-text password or a raw refresh token in the database.
## 5. Authentication: JWT Plus Refresh Tokens
- Register: hash the password with bcrypt (cost 12), never log it.
- Login: verify the password, issue a short access token and a refresh
  token. Store the refresh token hashed in the database with an expiry.
- Access token: 15 minutes, signed with `JWT_ACCESS_SECRET`, payload
  holds only `userId` and `role`, nothing sensitive.
- Refresh: client calls `POST /api/auth/refresh` with the refresh token
  in an `httpOnly`, `secure`, `sameSite=strict` cookie. Rotate the token
  on every use; reuse of an old token revokes the whole token family.
- Logout: delete the stored refresh token and clear the cookie.
- Protect routes with middleware that verifies the access token and
  attaches `req.user`; check ownership in the service layer, not only
  in the route, so an id in the URL can never leak another user's data.
## 6. Validation and Error Handling
Validate every body, query string, and route parameter with Zod before
the controller runs:
```ts
import { z } from "zod";
export const createItemSchema = z.object({
  body: z.object({ title: z.string().trim().min(1).max(200),
    status: z.enum(["draft", "published"]).optional() }),
});
```
Return one error shape everywhere: `{ "error": { "code": "VALIDATION_ERROR",
"message": "Title is required", "details": [...] } }`. Use 400 for bad
input, 401 for missing or expired auth, 403 for a forbidden owner, 404
for a missing resource, 409 for a duplicate, and 500 only for real server
failures. Log 500s with a request id; never leak a stack trace or a
database error string to the client.
## 7. Pagination, Filtering, and Sorting
```text
GET /api/items?page=2&limit=20&status=published&sort=-createdAt&q=search
```
Response shape: `{ "data": [...], "page": 2, "limit": 20, "total": 137,
"totalPages": 7 }`. Clamp `limit` to a maximum of 100, default 20, and
reject negative pages. Apply search with a text index or a bounded
regex, never an unbounded `$regex` on an unindexed field. Always scope
list queries to the logged-in owner unless the route is explicitly
public, and always return `total` so the client can render real page
controls.
## 8. File Uploads
Accept uploads with Multer, limit size to 5 MB per file, allow only an
explicit list of MIME types, and rename files with a UUID, never the
user-supplied filename. Store files in Cloudinary or S3 in production,
never on the server's local disk on a hosted platform. Validate the file
type from its magic bytes when the file matters, delete the old file when
a record is updated or removed, and serve uploads through a signed URL
or a CDN, never through a public writable folder.
## 9. React Client Structure
- One axios instance with a base URL from `VITE_API_URL` and an
  interceptor that attaches the access token and retries once after a
  401 by calling the refresh endpoint.
- Auth state in a small Zustand store: user, access token, login,
  logout, and a `ProtectedRoute` component that redirects to `/login`.
- Every list shows loading, error, and empty states; never render a
  blank page while data loads. Keep forms controlled, show server
  validation errors next to the field they belong to, and disable the
  submit button while a request is in flight to prevent double submits.
## 10. Testing
```bash
cd server && npx vitest run
cd ../client && npx vitest run
npx playwright test   # end-to-end: register, login, create, list
```
Cover at minimum: duplicate-email register returns 409, wrong-password
login returns 401, an unauthenticated protected request returns 401, a
user cannot read another user's item, validation rejects an empty title,
and pagination returns the correct `total`. Run server tests against an
in-memory MongoDB or a dedicated test database, never production data.
Keep coverage above 70 percent on services and auth; a passing suite is
required before any deploy.
## 11. Deployment: Vercel Plus Render or Railway
- Client on Vercel: set `VITE_API_URL` to the server URL, build command
  `npm run build`, output directory `dist`. Check the deploy preview on
  every pull request before merging.
- Server on Render or Railway as a Web Service: start command
  `node dist/server.js` after a TypeScript build. Set `MONGODB_URI`,
  `JWT_ACCESS_SECRET`, `JWT_REFRESH_SECRET`, and `CLIENT_URL` in the
  dashboard, never in code. Enable health checks on `/api/health` and
  auto-deploy from the main branch only.
- Before going live: confirm CORS allows only the real client origin,
  rate-limit auth routes to 5 attempts per 15 minutes per IP, enable
  Helmet, and verify the live build with `curl` on `/api/health`.
## Checklist
- [ ] Client and server split; routes/controllers/services separated.
- [ ] Env validated at startup; `.env.example` complete; no secrets committed.
- [ ] Passwords hashed with bcrypt; refresh tokens hashed and rotated.
- [ ] Zod validation on every write route; one error shape everywhere.
- [ ] Indexes on filtered and sorted fields; ownership checked in services.
- [ ] Pagination clamped, `total` returned, search bounded.
- [ ] Uploads size-limited, type-checked, stored off the server disk.
- [ ] Client handles loading, error, empty, and 401-refresh states.
- [ ] Tests pass: auth, ownership, validation, pagination.
- [ ] Deployed to Vercel plus Render/Railway; health endpoint live.
## Pitfalls
- **Storing the JWT in localStorage.** Use httpOnly cookies for refresh
  tokens and short-lived access tokens kept in memory.
- **Trusting the client for ownership.** Always re-check the owner on
  the server; a user id from the request body is not proof.
- **No indexes on list queries.** A full collection scan feels fine with
  100 documents and fails in production with 100,000.
- **Returning the whole user object.** Strip password hashes and tokens
  from every response with a `toJSON` transform.
- **Deploying without a health check.** A server that boots but cannot
  reach MongoDB must fail loudly, not serve 500s silently.
