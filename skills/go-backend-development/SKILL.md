---
name: go-backend-development
description: Design and implement reliable Go APIs, workers and services with idiomatic packages, concurrency, persistence, testing and observability.
---

# Go Backend Development

## Framework choice

Start with the standard library when it meets the requirements. Consider Chi, Gin or Echo only when routing, middleware or team conventions provide meaningful value. Use gRPC for typed service-to-service communication when appropriate.

## Design principles

- Use a supported Go version and record it in `go.mod`.
- Keep packages cohesive and avoid oversized `utils` or `common` packages.
- Prefer small interfaces defined by consumers.
- Make dependencies explicit through constructors.
- Pass `context.Context` for cancellation, deadlines and request-scoped values.
- Propagate errors with context; wrap using `%w` where callers need inspection.
- Avoid panics for ordinary error handling.
- Keep concurrency bounded and cancellation-aware.
- Protect shared state with appropriate synchronization; do not assume goroutines are free.
- Use channels for communication/ownership transfer, mutexes for shared mutable state when simpler.
- Close resources and handle shutdown gracefully.

## HTTP services

- Separate transport handlers from business logic and persistence.
- Validate input and enforce authorization at the boundary.
- Set request/body/time limits.
- Use explicit JSON response/error shapes.
- Support graceful shutdown and health/readiness checks.
- Avoid leaking internal error details.
- Use structured logging and request correlation.

## Persistence

- Use `database/sql` or a suitable driver/query tool; consider sqlc for generated typed SQL.
- Use transactions for invariants and always handle commit/rollback errors.
- Manage connection pools and context deadlines.
- Review query plans and indexes.
- Use migrations with a clear deployment strategy.

## Testing and quality

- Use standard `testing` package; table-driven tests where they improve clarity.
- Test handlers, services and persistence boundaries separately.
- Use httptest for HTTP behavior.
- Run `go test ./...`, `go vet ./...` and race detection where feasible.
- Run benchmarks only for identified hot paths.
- Fuzz parsers and input boundaries where useful.
- Test cancellation, timeouts, retries and concurrent access.
- Keep tests deterministic; avoid sleeps and uncontrolled shared external state.

## Delivery

Document configuration, ports, health endpoints, migrations, worker behavior, concurrency assumptions and shutdown behavior. Verify container builds and production binary configuration.
