---
name: dotnet-development
description: Design, build, secure, test and operate C#/.NET applications, including ASP.NET Core APIs, MVC, Blazor, EF Core, authentication, authorization, background services and observability. Use for new or existing .NET projects.
---

# C# / .NET Development

## Mission

Deliver maintainable .NET applications using supported SDKs and idiomatic C#. Choose the application model and hosting approach from requirements, then make security, data access, reliability and operational behavior verifiable.

## 1. Inspect the solution and support policy

1. Inspect `.sln`/`.slnx`, project files, `global.json`, `Directory.Build.*`, NuGet lock files, CI, tests and deployment configuration.
2. Verify target frameworks, installed SDK/runtime, C# language version, package versions and end-of-support dates against Microsoft's current support policy.
3. Preserve the existing application style and framework version unless an upgrade is in scope. Do not blindly set `LangVersion` beyond the target SDK's supported compiler.
4. Check official documentation for APIs and behaviors that depend on the target framework; avoid mixing .NET Framework, modern .NET and ASP.NET Core instructions.

## 2. Select the application model

- **ASP.NET Core Minimal APIs:** concise HTTP APIs and services where endpoint handlers, filters and conventions remain understandable.
- **ASP.NET Core controllers / MVC:** controller organization, filters, model binding or established conventions are valuable.
- **Razor Pages:** page-oriented server-rendered applications.
- **Blazor:** interactive web UI in C# when its hosting mode, client capabilities and deployment trade-offs fit.
- **Worker Service / BackgroundService:** long-running consumers, scheduled processing and background integration work.
- **gRPC:** typed service-to-service RPC or streaming where clients and infrastructure support it.
- **SignalR:** real-time bidirectional web communication where polling or ordinary requests are insufficient.

Do not select a framework because it is labeled high-performance. Validate hosting, team skills, client needs, dependency compatibility, observability and lifecycle cost.

## 3. C# and application design

- Enable nullable reference types and treat compiler warnings as useful feedback; use `required`, records, pattern matching and newer language features only when supported by the target.
- Prefer async APIs for I/O and pass `CancellationToken` through request, database and outbound HTTP operations.
- Avoid `.Result`, `.Wait()` and `async void` in request/business code. Do not use `Task.Run` to disguise synchronous blocking I/O.
- Use dependency injection with appropriate lifetimes: singleton services must not capture scoped services or request-specific state.
- Organize around features or domain boundaries. Use interfaces where they support a real boundary, testing seam or replaceable dependency, not mechanically for every class.
- Keep HTTP concerns in endpoints/controllers and business rules in application/domain code as complexity requires.
- Use the Options pattern for validated configuration. Keep secrets in an approved secret store or environment injection, never in source or committed settings.
- Use structured logging and propagate trace/correlation context; redact credentials, tokens and sensitive personal data.

## 4. ASP.NET Core HTTP APIs

- Validate input at boundaries using endpoint binding, data annotations or a suitable validation layer; do not trust client-side checks.
- Define stable status codes, problem details/error formats, pagination and API versioning when needed.
- Set request size, timeout, rate limit, CORS and forwarded-header behavior intentionally for the deployment.
- Order middleware deliberately. Ensure authentication runs before authorization and before endpoints that depend on the principal; verify CORS placement for the chosen pipeline.
- Use typed `HttpClient`/`IHttpClientFactory` for outbound HTTP, with explicit timeout, resilience, retry and idempotency policy.
- Use output caching only for safe responses; key variation and invalidation must account for auth, tenant, culture and other request dimensions.
- Publish OpenAPI with accurate schemas and auth requirements; do not expose development diagnostics in production.

## 5. Authentication and authorization

Choose an established mechanism based on clients:

- **Browser application:** use ASP.NET Core Identity or a maintained OIDC identity provider with secure cookie sessions.
- **API called by a first-party or third-party client:** validate bearer tokens issued by a trusted authority using the supported JWT/OIDC handler; validate issuer, audience, signature, expiry and signing key rotation.
- **Enterprise SSO or external identity:** use OpenID Connect/OAuth integration with a trusted identity provider. Do not implement protocol flows or token cryptography yourself.
- **Service-to-service:** use a workload identity or short-lived client credentials mechanism supported by the platform; avoid shared long-lived secrets where possible.

Authentication establishes identity; authorization must still be configured. In server-side apps, consider a fallback authorization policy that requires an authenticated user, then mark public endpoints explicitly. Use policy-based authorization for permissions and resource-based checks for ownership/tenant boundaries.

- Apply `[Authorize]`, endpoint authorization metadata or policies to every protected endpoint.
- Verify authorization close to data access as well as at the HTTP boundary for sensitive operations.
- Keep cookie settings, antiforgery protection, redirect allowlists, token storage and logout/revocation behavior explicit.
- Do not put access tokens in browser local storage. For browser-to-API architectures, evaluate a backend-for-frontend or secure cookie design.
- Test anonymous requests, wrong roles/claims, cross-tenant access, resource ownership and token validation failures.

## 6. Data access with EF Core or alternatives

- Choose EF Core, Dapper or direct ADO.NET based on query complexity, mapping needs, team familiarity and measured performance.
- Register `DbContext` with an appropriate scoped lifetime; never share a context concurrently across operations.
- Project only required fields, paginate large sets, avoid accidental client evaluation and inspect generated SQL for important queries.
- Avoid lazy-loading surprises and N+1 queries. Use explicit loading/projection and no-tracking reads where appropriate.
- Use database constraints and transactions for invariants. Handle optimistic concurrency and retry only operations that are safe to repeat.
- Generate and review EF migrations. Apply production schema changes through a deliberate deployment process; do not auto-migrate production at app startup without an explicit, reviewed operational design.
- Use provider-specific tests for behavior that differs across database engines. EF's in-memory provider is not a substitute for relational integration testing.

## 7. Advanced platform capabilities

Use the following when requirements justify them, verifying support in the target framework:

- **Hosted services and queues:** bounded concurrency, graceful shutdown, retries, dead-letter/failure handling and idempotent consumers.
- **Caching:** `IMemoryCache` for process-local data; distributed cache for shared instances. Define TTL, key isolation, invalidation and stampede protection.
- **Resilience:** bounded retries, timeouts, circuit breakers and bulkheads for remote dependencies; avoid retrying non-idempotent operations blindly.
- **Rate limiting:** partition by a suitable identity/IP and protect expensive or abuse-prone endpoints.
- **SignalR / gRPC:** design authorization, connection lifecycle, backpressure and deployment scaling explicitly.
- **Health checks:** distinguish liveness from readiness; avoid leaking dependency details publicly.
- **Observability:** use built-in logging, metrics and tracing/OpenTelemetry as appropriate; correlate traces across database and HTTP calls.
- **Performance:** measure allocations, query plans, GC, startup and request latency with representative workloads before optimizing.
- **Container/cloud deployment:** use non-root images, minimal runtime images where suitable, graceful termination, externalized configuration and secret injection.
- **Blazor:** verify server/WebAssembly/auto hosting behavior, client bundle exposure, prerendering and authentication data boundaries.

## 8. Testing and release

- Use the solution's existing test framework (commonly xUnit, NUnit or MSTest) and keep tests deterministic.
- Unit-test domain rules and policy handlers; integration-test the actual HTTP pipeline, database provider and authentication configuration.
- Use `WebApplicationFactory` or the supported test host for API integration tests.
- Test cancellation, timeout, retries, concurrency, malformed input, auth failures and migration behavior where relevant.
- Run `dotnet test`, `dotnet build` and configured analyzers/format checks against the repository's target frameworks. Do not assume one command covers every solution project or configuration.
- Review NuGet dependency health, licenses and security advisories; produce and inspect deployment artifacts.
- Verify environment-specific configuration, TLS, reverse proxy headers, database connectivity, health probes, logs and graceful shutdown in a staging-like environment.

## Definition of done

- Supported SDK, target frameworks and package compatibility are verified.
- The application model and dependency lifetimes are appropriate.
- Authentication and authorization are applied to every protected operation and tested.
- Database migrations, concurrency behavior, caching and background processing are deliberate.
- Tests, analyzers, build and deployment checks are reported with exact results.

## Official references

- [.NET support policy](https://dotnet.microsoft.com/platform/support/policy/dotnet-core)
- [ASP.NET Core overview](https://learn.microsoft.com/aspnet/core/overview)
- [ASP.NET Core Minimal APIs](https://learn.microsoft.com/aspnet/core/fundamentals/minimal-apis)
- [ASP.NET Core authentication](https://learn.microsoft.com/aspnet/core/security/authentication/)
- [ASP.NET Core authorization](https://learn.microsoft.com/aspnet/core/security/authorization/introduction)
- [ASP.NET Core configuration](https://learn.microsoft.com/aspnet/core/fundamentals/configuration/)
- [ASP.NET Core testing](https://learn.microsoft.com/aspnet/core/test/)
- [Entity Framework Core](https://learn.microsoft.com/ef/core/)
- [.NET dependency injection](https://learn.microsoft.com/dotnet/core/extensions/dependency-injection)
