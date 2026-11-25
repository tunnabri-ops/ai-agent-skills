---
name: technology-stack-selector
description: Choose frontend, backend, database, runtime, framework, ORM, testing and infrastructure technologies based on project constraints. Use before implementation or when evaluating a stack change.
---

# Technology Stack Selector

## Selection principles

Never select a stack from habit or trend. First inspect project constraints, team competence, hosting, integrations, data shape, security, performance and maintenance horizon. Prefer a coherent stack with fewer moving parts.

## Decision dimensions

Score candidates qualitatively or with a documented weighted matrix:
- Requirement fit and developer productivity.
- Runtime and ecosystem maturity.
- Type safety and tooling.
- Performance under the expected workload.
- Security and supported release policy.
- Testing, observability and debugging.
- Deployment and hosting fit.
- Hiring/team familiarity.
- Total cost of ownership and license.
- Migration and lock-in risk.

Do not invent benchmark numbers. Benchmark only the actual workload when performance is decisive.

## Stack families

### JavaScript / TypeScript web

- MERN: MongoDB, Express, React, Node.js. Consider for document-oriented data and a JS/TS end-to-end team.
- PERN: PostgreSQL, Express, React, Node.js. Prefer when relational integrity, joins, transactions and reporting matter.
- NestJS: choose for structured modules, dependency injection, conventions and larger teams; it can use Express or Fastify adapters.
- Express: choose for a minimal, flexible Node HTTP layer when the team can establish its own structure.
- Hono: consider lightweight, multi-runtime HTTP services and edge/serverless targets; verify adapter and library compatibility.
- Deno: consider when its runtime/tooling/security model fits; verify ecosystem and deployment constraints.
- Next.js: consider when React applications need integrated server rendering, routing and server capabilities; define boundaries carefully. For Next.js-specific architecture, caching or authentication work, activate `nextjs-development` and verify the installed version and cache model.
- Fastify: consider when schema-driven APIs and low-overhead HTTP handling matter.

### Python backend

- FastAPI: typed API services, async I/O and OpenAPI-first workflows.
- Django: integrated ORM, admin, authentication and convention-rich full-stack applications.
- Flask: small services or teams wanting a minimal framework and explicit extension choices.

### Go backend

- Go standard library: small-to-medium HTTP services where simplicity and low dependency count are priorities.
- Chi: lightweight composable routing.
- Gin / Echo: choose only when their ecosystem/conventions provide clear value.
- gRPC: service-to-service contracts where typed RPC and streaming are appropriate.
- Avoid framework selection based on microbenchmarks alone.

### PHP web applications

- Laravel: choose for convention-driven PHP applications that benefit from its routing, middleware, Eloquent, validation, queues, scheduler, and integrated web tooling.
- Verify the supported PHP/Laravel versions, database/cache/queue drivers, hosting model and required Laravel packages before selecting it.
- For a Laravel implementation, activate `laravel-development` for authentication, authorization, Eloquent, queues, caching, testing and deployment guidance.

### C# / .NET applications

- ASP.NET Core: choose for cross-platform web APIs and services with integrated hosting, dependency injection, configuration and security middleware.
- Minimal APIs suit compact HTTP APIs; controllers/MVC, Razor Pages or Blazor may better fit application structure and UI needs.
- Use Worker Services for background processes, SignalR for real-time communication and gRPC for suitable service-to-service contracts.
- Verify the target framework's support lifecycle, runtime and NuGet compatibility before choosing. For implementation, activate `dotnet-development`.

### Mobile

- Flutter: cross-platform UI with consistent rendering and Dart ecosystem.
- Native Swift/Kotlin: choose when deep platform integration, platform-specific UX or native capabilities dominate.
- Consider offline storage, push, deep links, accessibility, app signing and store release constraints early.

### Desktop

- Electron: web technology reuse, broad ecosystem and mature desktop integration; account for bundled runtime and memory footprint.
- Tauri: consider smaller native shell and web frontend where plugin/platform constraints fit.
- Native desktop frameworks: prefer when platform integration or performance demands it.

## Data technology

- PostgreSQL: default candidate for relational business data, transactions and complex querying.
- MongoDB: document-shaped aggregates and flexible document evolution when relational constraints are not central.
- Redis: cache, ephemeral coordination, rate limits and queues only with explicit persistence/eviction semantics.
- SQLite: local-first, embedded or single-node storage where concurrency/deployment constraints fit.
- Prisma / Drizzle / SQLAlchemy / Django ORM / GORM: select based on language, query control, migration quality, type safety and team needs.
- Do not add an ORM automatically. Raw SQL can be appropriate for complex or performance-critical queries.

## Supporting tools

Select deliberately:
- Validation: Zod, Valibot, Pydantic, framework-native validators.
- API contracts: OpenAPI, generated clients, protobuf for gRPC.
- Testing: Vitest/Jest, pytest, Go testing, Flutter test, PHPUnit/Pest, xUnit/NUnit/MSTest, Playwright.
- Build: Vite, framework-native build, esbuild where appropriate.
- Auth: trusted OIDC/OAuth provider or mature library; do not roll custom cryptography.
- Observability: structured logs, metrics, traces and error monitoring.
- CI/CD: platform-native pipelines with reproducible build and test steps.

## Required decision record

Write `docs/TECH_STACK.md` with:
- Chosen technology and exact verified version/range.
- Role in the system.
- Why it fits the requirements.
- Alternatives considered and rejection reasons.
- Compatibility evidence and official documentation URLs.
- License/security/maintenance concerns.
- Upgrade and migration strategy.

Verify current releases and compatibility from official sources immediately before implementation. A list in this skill is a decision guide, not a claim that every listed tool is currently the best or latest.
