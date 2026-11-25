---
name: laravel-development
description: Build, secure, test and deploy Laravel applications using PHP, Eloquent, queues, caching, authentication, authorization, APIs and the Laravel ecosystem. Use for new or existing Laravel projects.
---

# Laravel Development

## Mission

Build Laravel applications that follow the conventions of the installed framework version while keeping business rules, authorization, database behavior and operational requirements explicit.

## 1. Inspect before changing

1. Read `composer.json`, `composer.lock`, PHP version constraints, Laravel version, existing routes, providers, middleware, tests, CI and deployment files.
2. Preserve the project's established MVC, API, Blade, Livewire, Inertia or SPA approach unless the task calls for a deliberate migration.
3. Check current Laravel and PHP support requirements and official version-specific docs before using APIs. Do not copy examples from a different major release.
4. Inspect existing dependencies and project conventions before installing packages or creating new architectural layers.

## 2. Application structure and HTTP boundaries

- Use routes and controllers for HTTP concerns; keep controllers small and move multi-step business workflows into focused action/service classes when that improves clarity or testability.
- Use route model binding intentionally. Apply authentication middleware and route-level throttles to appropriate routes.
- Validate untrusted input with Form Requests or the project's established validation approach. Validate again at non-HTTP boundaries such as jobs and CLI commands.
- Use middleware for cross-cutting request concerns, not hidden business workflows.
- Return explicit API Resources or response DTOs; do not expose internal model fields by serializing Eloquent models blindly.
- Use API versioning and stable error shapes when building a public or independently deployed API.
- Keep secrets in environment-backed configuration; do not call `env()` throughout application code outside configuration files.

## 3. Eloquent and data integrity

- Model relationships and database constraints to represent business invariants; do not rely only on request validation.
- Use eager loading (`with`, `load`) to prevent N+1 queries. Select only required columns for large or sensitive records.
- Wrap multi-step writes in `DB::transaction` and enforce uniqueness, ownership and inventory constraints at the database boundary where practical.
- Use optimistic locking or row locks when concurrent updates could violate an invariant.
- Generate migrations, inspect them, and plan safe forward/backward deployment behavior. Do not run destructive migrations against production without authorization, backup and recovery plans.
- Use factories and seeders for deterministic test data; avoid depending on a developer's local database state.
- Profile slow queries and use indexes based on measured query patterns. Do not add indexes or cache layers without considering write cost and invalidation.

## 4. Authentication and authorization

Choose the authentication mechanism based on the client and trust boundary:

- **Browser application:** start with Laravel's built-in session and cookie authentication and an official starter kit when its scaffold fits the product. Keep CSRF protection enabled.
- **First-party SPA or mobile API:** consider Sanctum for cookie-based SPA authentication or scoped personal access tokens, matching the documented mode to the actual client.
- **OAuth 2.0 authorization server:** use Passport when the application must issue OAuth access tokens to third-party clients and needs a full OAuth server.
- **Social login:** use the maintained Socialite ecosystem or a vetted OIDC provider integration; verify provider and package support.

Do not treat Sanctum, Passport and browser session auth as interchangeable. Avoid custom password hashing, token signing or OAuth protocol implementations. Use Laravel's password hashing, session, password reset and rate-limiting facilities.

- Authentication answers who the user is; authorization decides what that user may do.
- Use policies and gates for resource and action authorization. Verify tenant, ownership and role constraints on every protected read and write.
- Apply authorization to controllers, queued jobs, API endpoints and administrative actions—not just the UI.
- Return only fields the caller is allowed to see. Do not expose password hashes, secrets or internal tokens in API resources or logs.
- Test guest, authenticated, unauthorized, cross-tenant and privilege-escalation cases.

## 5. Transactions, events and queues

- Use events for meaningful domain or integration events, not as an opaque substitute for direct business flow.
- Send slow work (mail, exports, media processing, third-party calls) to queues when latency and operational complexity justify it.
- Make jobs idempotent where retries are possible. Set retry/backoff, timeout and failure behavior explicitly; avoid serializing large or sensitive payloads.
- Dispatch jobs after a transaction commits when they depend on committed records. Use unique jobs, locks or database constraints for concurrency-sensitive work.
- Use queue monitoring appropriate to the selected backend; document worker count, scaling, graceful restarts and failed-job recovery.
- Use the scheduler for recurring work and make scheduled commands safe to repeat and observable.
- Consider broadcasting and Laravel Reverb for real-time requirements; use it only when the user experience needs server-pushed updates.

## 6. Caching and performance

- Measure the request or query first. Select cache store and key based on deployment topology, eviction policy and data freshness.
- Use `Cache::remember` or tagged caches where the selected store supports tags. Define explicit TTL and invalidation on writes.
- Never share user-specific or tenant-specific cached results under a global key. Include authorization-relevant identity in the key or avoid caching.
- Use atomic locks for concurrency coordination only when the chosen cache backend supports the required shared-lock semantics.
- Keep database query count, pagination, response size, asset handling and queue latency in view before optimizing.
- For long-lived workers or Octane, review singleton state, static state, request-scoped services and memory growth; do not assume normal request lifecycle behavior.

## 7. Advanced ecosystem choices

Adopt these only when the application needs their capability and the deployment can support them:

- **Livewire / Inertia / Blade:** choose the frontend integration that matches team skills, UX and API/client boundaries.
- **Scout:** add search abstraction only after choosing and operating a compatible search engine.
- **Horizon:** use for Redis queue supervision and visibility where appropriate.
- **Pulse / Telescope:** use for observability or local debugging with access controls and data-retention policies suitable for the environment.
- **Pennant:** use for managed feature flags; define cleanup and exposure rules.
- **Octane:** consider for measured throughput needs and test long-lived worker safety before rollout.
- **Reverb / broadcasting:** use for real-time updates with authenticated channels and authorization.
- **Cashier:** use for supported Stripe or Paddle billing integration; verify webhooks, idempotency and server-side payment state transitions.
- **Sail:** use for reproducible local containers when consistent with the team workflow.

Verify current package compatibility, maintenance, licensing and security advisories. Avoid installing multiple packages that overlap without a clear need.

## 8. Testing and delivery

- Follow the repository's PHPUnit or Pest conventions. Test behavior, not framework internals.
- Cover validation, authorization, transactions, model scopes, API resources, queue dispatch and webhook behavior.
- Use feature tests with isolated databases; test migrations against the supported database engine.
- Fake mail, notifications, events and queues selectively, while retaining integration tests for critical wiring.
- Run the repository's test suite, static analysis, formatter/linter and production build or startup check.
- Common checks include `php artisan test`, `vendor/bin/pint --test`, and the project's configured PHPStan or Larastan command. Confirm each command exists before reporting it.
- Verify production configuration, PHP extensions, queue workers, scheduler, storage permissions, HTTPS, trusted proxies, health checks and log/secret redaction.

## Definition of done

- Framework/PHP versions and architecture are verified.
- Authentication and per-resource authorization match the client model and are covered by tests.
- Database invariants, transactions, migrations and queue retry behavior are intentional.
- Cache freshness and invalidation do not leak data across users or tenants.
- Relevant tests, static checks and deployment smoke checks were run and reported accurately.

## Official references

- [Laravel documentation](https://laravel.com/docs)
- [Laravel authentication](https://laravel.com/docs/authentication)
- [Laravel authorization](https://laravel.com/docs/authorization)
- [Laravel database and Eloquent](https://laravel.com/docs/eloquent)
- [Laravel migrations](https://laravel.com/docs/migrations)
- [Laravel cache](https://laravel.com/docs/cache)
- [Laravel queues](https://laravel.com/docs/queues)
- [Laravel testing](https://laravel.com/docs/testing)
- [Laravel deployment](https://laravel.com/docs/deployment)
