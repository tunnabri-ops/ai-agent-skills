---
name: mern-pern-development
description: Design, implement, test and review React and Node.js applications using MERN, PERN, Express, NestJS, Fastify, Hono and related TypeScript tooling. Use for JavaScript or TypeScript full-stack projects.
---

# MERN / PERN / Node.js Development

## Select the variant

- Choose PERN/PostgreSQL for relational entities, constraints, transactions, reporting and complex joins.
- Choose MERN/MongoDB for document aggregates and flexible document structures where cross-document relational queries are limited.
- Choose Express for a small, intentionally lightweight API.
- Choose NestJS for a larger modular backend, dependency injection, consistent conventions and team-scale maintainability.
- Choose Fastify for schema-oriented high-throughput HTTP needs when ecosystem fit is verified.
- Choose Hono for small multi-runtime/edge services after checking runtime-specific library support.
- Do not combine frameworks without a clear boundary and operational reason.

## Baseline

- Prefer TypeScript for maintained production applications unless constraints justify JavaScript.
- Pin runtime/package manager expectations and commit the lockfile.
- Validate configuration at startup; fail fast on missing required variables.
- Separate route/controller, application/service, domain and persistence concerns as complexity requires.
- Centralize error mapping, request validation, logging and authentication/authorization.
- Use parameterized SQL or safe ORM query APIs.
- Use explicit pagination, filtering and sorting limits.
- Avoid leaking database entities or secrets directly in API responses.

## React frontend

- Organize by feature/domain when the application has multiple workflows.
- Keep reusable UI components separate from feature-specific components.
- Separate server state from local UI state; avoid global state by default.
- Handle loading, empty, error, success and unauthorized states.
- Use semantic HTML, keyboard support, accessible labels and focus management.
- Validate forms on client and server; client validation is not a security boundary.
- Avoid unnecessary effects and duplicated derived state.
- Add error boundaries and route-level loading behavior where appropriate.

## Backend

- Keep controllers/handlers thin.
- Put business rules in application/domain services, not request handlers.
- Validate input at trust boundaries.
- Enforce authorization on every protected operation and resource access.
- Use transactions for multi-step invariants.
- Make retries safe with idempotency where needed.
- Apply rate limits and body/file size limits.
- Use secure cookie/session settings or a well-designed token flow.
- Configure CORS narrowly; never treat CORS as authorization.
- Avoid blocking the event loop with CPU-heavy tasks; use workers/queues or another runtime when justified.

## Database and ORM

- Choose Prisma, Drizzle, or a query builder based on query complexity, type safety, migration workflow and team familiarity.
- Review generated migrations before applying them.
- Add constraints and indexes based on access patterns.
- Use transactions deliberately; avoid N+1 query patterns.
- For MongoDB, model around access patterns and aggregate boundaries; validate schema and indexes.
- Never assume ORM use removes the need to understand SQL/query plans.

## Quality checks

- Lint, format, typecheck, unit and integration tests.
- API contract/OpenAPI checks where relevant.
- Playwright E2E tests for critical user journeys.
- Dependency and secret scanning in CI.
- Test authz failures, malformed input, concurrency and pagination boundaries.
- Run production build and inspect bundle/runtime configuration.

## Suggested project layout

Adapt to framework conventions; do not force a template onto an existing codebase.

```text
apps/
  web/
  api/
packages/
  shared/
docs/
  adr/
```

Within an API, use feature/module folders with explicit public interfaces. Do not create a `shared` dumping ground.
