---
name: go-backend
description: Use when building a production Go backend API or service with Gin or Fiber, PostgreSQL, JWT authentication, migrations, structured logging, graceful shutdown, table-driven tests, and a Docker multi-stage build.
---

# Go Backend

Build a production Go backend that is easy to test, easy to deploy, and
safe to change. Prefer the standard library where it is enough, add a
framework only for routing and middleware, and keep business rules out of
HTTP handlers. Every endpoint must have a handler, a service, a repository,
a test, and a documented response shape before it is called done.

## When to Use This Skill

- The user asks for a Go API, REST service, backend, or microservice.
- An existing Go service needs auth, database access, logging, or tests.
- A prototype must be turned into a deployable production service.
- The user asks for Gin, Fiber, PostgreSQL, sqlc, pgx, or JWT in Go.

## Stack Decisions

- Language: Go 1.22 or newer. Use modules, `go vet`, and `gofmt` on every change.
- Framework: Gin for a large ecosystem, Fiber for Fasthttp speed. Pick one; do not mix both.
- Database: PostgreSQL 15 or newer, accessed with pgx and sqlc.
- Migrations: golang-migrate, one numbered file pair per change.
- Auth: JWT access tokens (15 minutes) plus refresh tokens (7 days).
- Logging: structured JSON logging with `log/slog`, never plain `fmt.Println`.
- Configuration: environment variables only, loaded once at startup.
- Deployment: Docker multi-stage build, one static binary, no shell in the image.

## Project Layout

```text
cmd/api/main.go                 # entry point only: wire config, DB, server
internal/config/config.go       # env parsing and validation
internal/handler/user_handler.go
internal/handler/middleware.go  # auth, logging, recovery, CORS, rate limit
internal/service/user_service.go
internal/repository/user_repository.go
internal/model/user.go
internal/db/queries/users.sql   # sqlc input, one file per table
internal/db/migrations/0001_create_users.up.sql
internal/db/migrations/0001_create_users.down.sql
pkg/errors/errors.go            # typed errors: NotFound, Validation, Conflict
pkg/jwt/jwt.go                  # sign, verify, and parse tokens
api/openapi.yaml                # contract for every endpoint
Dockerfile
docker-compose.yml
Makefile
```

Rules: `main.go` stays under 120 lines and holds no business logic.
Handlers parse input, call one service method, and render the response.
Services hold business rules and call repositories; they never import Gin
or Fiber. Repositories hold SQL only, through sqlc-generated code.
Models are plain structs with JSON tags.

## Setup Commands

```bash
go mod init example.com/shop
go get github.com/gin-gonic/gin github.com/jackc/pgx/v5
go get github.com/golang-jwt/jwt/v5 github.com/golang-migrate/migrate/v4
go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest
go install github.com/golang-migrate/migrate/v4/cmd/migrate@latest
cp .env.example .env
docker compose up -d db
make migrate-up
make run
```

Required variables: `DATABASE_URL`, `JWT_SECRET`, `JWT_ACCESS_TTL_MINUTES=15`, `JWT_REFRESH_TTL_DAYS=7`, `PORT=8080`, `LOG_LEVEL=info`. No secret is committed. Fail fast at startup when a required variable is missing or invalid: print its name, then exit non-zero.

## Database and Migrations

Write migrations as small, reversible, forward-only changes, for example `0001_create_users.up.sql` creating a `users` table with `id UUID PRIMARY KEY DEFAULT gen_random_uuid()`, `email CITEXT NOT NULL UNIQUE`, `password_hash TEXT NOT NULL`, `name TEXT NOT NULL`, and `created_at` / `updated_at TIMESTAMPTZ NOT NULL DEFAULT now()`. Rules: never edit a migration that has already run in production; add a new one. Every change gets an `up` and a `down` file with the same number. Add an index in the same migration that adds the column it covers. Use `CITEXT` for emails so `User@Example.com` and `user@example.com` match. Run migrations before the HTTP server starts, and log the applied version. Define sqlc queries in `internal/db/queries/users.sql` (`GetUserByEmail`, `CreateUser` with `RETURNING`), run `sqlc generate` after every query change, and commit the generated code.

## HTTP Layer

Register routes in one place, grouped by resource, with middleware in order: request ID, logger, recovery, rate limit, then auth on protected groups. Example: `GET /health`, `POST /api/v1/auth/register`, `/login`, `/refresh`, and protected `GET /api/v1/users/me` and `PUT /api/v1/users/me` behind `RequireAuth`. Response rules: success is `200` for reads and updates, `201` for creates,
`204` for deletes. Errors use one shape everywhere:
`{"error": {"code": "not_found", "message": "User not found"}}`.
Validation failures return `400` with one entry per bad field. Missing or
invalid tokens return `401`; a valid user without permission returns `403`.
Unknown IDs return `404`, never `500`. List endpoints paginate with
`?page=1&limit=20`, cap `limit` at 100, and return `total`.

## Authentication and Security

- Hash passwords with bcrypt, cost 12; never store or log a plain password.
- Sign JWTs with HS256 and a secret of at least 32 random bytes, or RS256 with a key file.
- Put only the user ID, role, and expiry in the token; fetch the rest from the database.
- Store refresh tokens hashed in the database, rotate them on every use, and revoke all on logout and on password change.
- Validate the `Authorization: Bearer <token>` header in middleware, not in each handler.
- Set security headers: `X-Content-Type-Options: nosniff` and `X-Frame-Options: DENY`.
- Limit request bodies to 1 MB by default, and validate every field before use.
- Use parameterised queries only; never build SQL by concatenating user input.
- Rate-limit login to 5 attempts per minute per IP, then return `429` with `Retry-After`.

## Structured Logging and Errors

Log one JSON line per request, with the same fields every time: request ID,
method, path, status, and duration in milliseconds. Log errors with the
error, the request ID, and the operation name, never with a password or
token. Return a request ID in the `X-Request-ID` response header on every
response. Map typed errors to status codes in one place: `NotFound` to 404,
`Validation` to 400, `Conflict` to 409, `Unauthorized` to 401, `Forbidden`
to 403. Do not log a stack trace for an expected client error; log it only
for a 500.

## Graceful Shutdown

Shut down in order: stop accepting new requests, finish in-flight requests, close the database pool, then exit. Give in-flight work 30 seconds. Implementation: run `ListenAndServe` in a goroutine, wait on `SIGINT`/`SIGTERM` in a channel, then call `server.Shutdown` with a 30-second context timeout and close the pool. A deploy must not drop a request that started before the shutdown signal.

## Testing

Write table-driven tests for services and handlers; test the repository against a real PostgreSQL container, never a mock database. Example table for `CreateUser`: valid `a@example.com` (no error), empty email (error), `not-an-email` (error); loop with `t.Run` and fail when `(err != nil) != wantErr`. Test checklist: every service method has a table-driven test, including the
error cases. Auth middleware rejects a missing, expired, and tampered token.
Register rejects a duplicate email with `409` and a weak password with `400`.
List endpoints respect `page`, `limit`, and the 100-item cap. Health returns
`200` with database status, and `503` when the database is down.
`go test ./...`, `go vet ./...`, and `gofmt -l .` all pass with no output.
Race detector passes: `go test -race ./...`.

## Docker Multi-Stage Build

Build stage: `golang:1.22-alpine`, copy `go.mod`/`go.sum`, run `go mod download`, copy the source, then `CGO_ENABLED=0 GOOS=linux go build -o /api ./cmd/api`. Final stage: `gcr.io/distroless/static-debian12:nonroot`, copy `/api` from the build stage, run as `nonroot:nonroot`, expose 8080, and set `ENTRYPOINT ["/api"]`. Rules: the final image contains only the binary, runs as a non-root user, and has no shell. Tag images with the Git commit SHA, never with `latest` alone. Run migrations as a separate one-shot job, not inside the web container startup.

## Pre-Ship Checklist

- [ ] `go test ./...`, `go vet ./...`, and `gofmt -l .` pass.
- [ ] Migrations run cleanly on an empty database and on the current schema.
- [ ] No secret, token, or password is committed; `.env` is in `.gitignore`.
- [ ] Health endpoint reports database status and the deployed version.
- [ ] Graceful shutdown finishes in-flight requests within 30 seconds.
- [ ] Docker image builds, runs as non-root, and answers `/health` in under 2 seconds.
- [ ] API contract in `api/openapi.yaml` matches the running server.

## Example: Register Flow

1. Handler binds JSON and validates email format, name length, and password strength.
2. Service checks for an existing user by email; a duplicate returns `409`.
3. Service hashes the password with bcrypt and calls the repository to insert the user.
4. Repository runs the sqlc `CreateUser` query inside a transaction and returns the new row.
5. Handler returns `201` with the user ID, email, and name, never the password hash.
6. Service issues an access token and a hashed refresh token, stored in the database.
7. Log the registration with the request ID and user ID, with no password or token.
8. A test registers the same email twice and expects the second call to fail with `409`.

## Pitfalls

- Putting business rules in handlers makes them untestable; keep handlers thin.
- Returning the database error directly leaks table and column names to clients.
- Using `latest` as the only image tag makes rollbacks impossible.
- Skipping the `down` migration leaves a bad deploy with no way back.
- Logging a token or password once puts it in every log store that copies it.
- Forgetting `context` timeouts lets one slow query hold a connection forever.
