---
name: nextjs-development
description: Build, optimize, secure and deploy production Next.js applications, including App Router architecture, Cache Components, data caching and revalidation, authentication, authorization, Server Actions, Route Handlers and streaming. Use for new or existing Next.js projects.
---

# Next.js Development

## Mission

Deliver fast, secure and maintainable Next.js applications using the conventions supported by the project's installed version. Treat caching, rendering, authentication and authorization as explicit design decisions, not framework defaults to guess at.

## 1. Inspect the project and documentation

1. Read the package manifest, lockfile, `next.config.*`, route tree, deployment target, tests and existing project instructions.
2. Record the installed Next.js, React and Node.js versions and whether the app uses App Router, Pages Router, or both.
3. Check current official documentation for the installed major version before using APIs or migration guidance. Do not copy examples from a different caching model.
4. Preserve established conventions. Propose migration separately when changing router, runtime, authentication provider or cache model.

## 2. Choose the rendering and caching model

### App Router and Cache Components

For Next.js 16 projects, first determine whether `cacheComponents` is enabled. New apps may start with Cache Components, while older projects may use the previous caching model. Do not combine advice from both models.

When adopting Cache Components, explicitly review `cacheComponents` and `partialPrefetching` configuration and test build and navigation behavior before rollout.

- Use `'use cache'` around a pure function or component whose output is safe to reuse.
- Set `cacheLife(...)` in the same cache scope to make freshness expectations explicit.
- Add `cacheTag(...)` to cached data that needs targeted invalidation.
- Use `<Suspense>` around request-time work and runtime APIs such as `cookies()`, `headers()`, `searchParams`, or uncached data so static content can render and dynamic content can stream.
- Keep static shell content, shared cached content and request-specific content in distinct components when that improves clarity.
- `use cache: remote` may be appropriate for persistent, shared cache storage when configured and supported by the deployment.
- `use cache: private` has distinct browser-side semantics. Use it only after confirming the data sensitivity and cache behavior meet the product's privacy requirements.

Do not cache a response containing a session, access token, secret, or user-specific data under a key shared between users. If caching authorized data is justified, authenticate first, authorize ownership in a server-side data layer, include every relevant tenant/user/permission input in the cache key, and define invalidation for permission and data changes. If isolation is uncertain, do not cache it.

Example of explicitly caching shared, public catalog data:

```ts
import { cacheLife, cacheTag } from 'next/cache'

export async function getCatalog(category: string) {
  'use cache'
  cacheLife('hours')
  cacheTag(`catalog:${category}`)

  return db.product.findMany({
    where: { category },
    select: { id: true, name: true, price: true },
  })
}
```

The database client and schema are project-specific. Keep cache scope and tag close to the data function that owns them.

### Previous caching model

For an existing app without Cache Components, consult the official previous-model guide for that installed Next.js version. Its `fetch` cache options, `next.revalidate`, route segment settings and legacy cache helpers do not have interchangeable semantics with `'use cache'`, `cacheLife` and `cacheTag`.

Avoid adding deprecated or legacy APIs to a new Cache Components implementation. Make migration incremental and verify generated output, freshness and invalidation behavior in production-like builds.

## 3. Design cache freshness and invalidation

Choose a policy for each data category:

| Data | Typical policy |
|---|---|
| Public, rarely changed content | Cache with an explicit longer lifetime |
| Public catalog or editorial content | Cache with an appropriate lifetime and tags |
| Frequently changing public data | Short lifetime or request-time fetch; consider streaming |
| User dashboard or private record | Request-time authorization; cache only with strict identity isolation |
| Payment, inventory reservation or other critical state | Read authoritative storage; never rely on stale cached values for decisions |

Use the invalidation API that matches the consistency requirement:

- `updateTag(tag)` in a Server Action when the user must immediately read their own write.
- `revalidateTag(tag, 'max')` for webhook or background updates where stale-while-revalidate is acceptable.
- `revalidatePath(path)` when the affected route or layout, rather than shared tagged data, is the target.
- Combine tag and path invalidation only when the data model requires both.

Treat cache tags as an invalidation index, not an authorization boundary. Protect webhook revalidation endpoints with signature verification, replay protection where applicable, and narrow tag/path allowlists. Document cache lifetime, stale tolerance, invalidation triggers and multi-instance behavior.

## 4. Use server and client boundaries deliberately

- Prefer Server Components for data access, server-rendered UI and code that does not need browser APIs or local interactivity.
- Add `'use client'` only at the smallest interactive boundary; keep secrets and privileged data access in server-only modules.
- Keep serializable props small. Return explicit DTOs rather than database records or session payloads.
- Use `loading.tsx`, `<Suspense>`, `error.tsx`, `not-found.tsx` and route layouts to define loading and failure behavior.
- Use route groups, parallel routes and intercepting routes when they solve a real navigation or layout requirement; do not add them for novelty.
- Use metadata APIs and `generateMetadata` for page metadata. Use `next/image` and `next/font` with verified configuration and measured needs.
- Choose Node.js or Edge runtime based on dependency compatibility, database connectivity and deployment requirements; do not assume every package works in every runtime.

## 5. Authentication: choose a maintained solution

There is no single best provider for every product. For most applications, use a maintained authentication library or managed identity provider rather than implementing authentication protocols, password storage, token signing or session cryptography yourself.

Choose based on requirements:

- **Managed OIDC/identity provider:** prefer when social login, enterprise SSO, MFA/passkeys, compliance features, account recovery or reduced identity operations are priorities.
- **Maintained auth library:** prefer when the team needs more control over hosting, user storage and application integration, and can operate updates, email delivery, abuse controls and account recovery safely.
- **Custom auth/session code:** only when there is a specific reviewed requirement the maintained options cannot meet, and the team can own the security design and ongoing maintenance. Do not invent cryptography.

Compare current provider/library support for the installed Next.js and React versions, App Router and Server Actions, deployment runtime, database adapter, session revocation, MFA, passkeys, OAuth/OIDC, account recovery, rate limiting, data residency, pricing, maintenance and exit strategy. Check official documentation and current security advisories before choosing.

**Practical default:** for a typical production web app, use an established identity provider or maintained auth library for sign-in and session lifecycle, prefer OIDC when integrating with an external identity provider, and keep authorization in your own server-side DAL. Choose a managed provider when you do not want to operate identity infrastructure; choose a self-hostable library when data/control requirements justify operating it. Confirm the provider's integration fits the installed Next.js version before committing.

For a first-party web application, a server-managed session in an `HttpOnly`, `Secure` production cookie with an intentional `SameSite`, `Path` and expiry policy is usually a safer default than exposing bearer tokens to browser JavaScript. Use OAuth/OIDC bearer tokens when required by an API, mobile client or service integration; do not store long-lived access or refresh tokens in `localStorage`.

## 6. Enforce authorization near the data

- Separate authentication (who is signed in) from authorization (what they may do).
- Put session verification and resource authorization in a server-only Data Access Layer (DAL).
- Check ownership, tenant boundaries, roles and current permissions for every protected read and mutation.
- Repeat authorization in each Server Action and Route Handler; they are callable server endpoints, not trusted because a button or page is hidden.
- Use the `proxy.ts` convention where supported (older versions may use `middleware.ts`) for inexpensive optimistic redirects or coarse pre-filtering only. It must not be the only authorization check and should not perform database work on every prefetched route.
- Return the minimum authorized DTO. Never pass secrets, password hashes, internal tokens or unrestricted records to Client Components.
- Use parameterized queries, validate input on the server, rate-limit sensitive actions, and add CSRF/origin protections appropriate to the auth mechanism and framework version.
- Make login, logout, password reset, email verification and account linking safe against enumeration, replay and abuse. Delegate protocol details to the chosen provider/library when possible.

## 7. Build mutations and APIs safely

- Use Server Actions for UI-bound mutations when they simplify the interaction; validate all untrusted `FormData` on the server.
- Keep Server Actions focused. Authenticate and authorize before writing, use database transactions for invariants, and make retries safe with idempotency where needed.
- Use Route Handlers for explicit HTTP APIs, webhooks and integrations. Validate method, content type, size, input schema and authentication.
- Verify webhook signatures against the raw request body according to provider guidance; never trust a client redirect as proof of payment.
- Keep credentials in server-only environment variables. Do not prefix secrets with `NEXT_PUBLIC_`.
- Handle expected validation/auth errors explicitly and let unexpected infrastructure failures remain observable; do not silently return success-shaped fallbacks.

## 8. Advanced platform capabilities

Adopt these where the product benefits from them and verify support in the installed version:

- **Streaming and partial prerendering:** separate fast shell UI from request-time work with Suspense and supported Cache Components configuration.
- **Advanced routing:** nested layouts, route groups, parallel/intercepting routes, dynamic segments, loading/error boundaries and typed routes where available.
- **Server Actions and Route Handlers:** form submissions, mutations, APIs, webhook processing and cache invalidation.
- **Metadata and assets:** metadata/OG generation, optimized images, fonts and static assets with suitable cache headers.
- **Internationalization and localization:** locale routing, translated metadata and explicit formatting/time-zone behavior.
- **Observability:** `instrumentation.ts`, structured server logs, traces and error monitoring; redact cookies, tokens and personal data.
- **Performance:** measure Core Web Vitals, server timings, bundle size, image delivery, database query count, prefetching and cache hit/freshness behavior.
- **Deployment:** verify output mode, runtime support, environment variables, static/dynamic routes, image optimization, cache handler, CDN, database connection pooling and multi-instance invalidation on the actual host.
- **Testing:** unit-test domain logic and DAL authorization, integration-test data and cache invalidation, and use browser tests for navigation, loading/error states, sign-in, sign-out and access denial.

Do not add a queue, edge runtime, custom cache backend, client state library or speculative optimization without a measurable requirement.

## 9. Definition of done

- Installed versions, router and caching model are verified and documented.
- Cache lifetimes, tags, invalidation and user-data isolation are explicit and tested.
- Authentication uses a justified, maintained solution; protected reads and writes authorize at the data boundary.
- Server/client boundaries expose no secrets or unnecessary personal data.
- Loading, error, empty, unauthorized and not-found states are handled.
- Focused tests, lint, type-check and production build are run where available.
- Deployment/runtime and cache behavior are verified for the target host.
- The final report lists exact checks, decisions, limitations and any unverified behavior.

## Official references

- [Next.js Authentication](https://nextjs.org/docs/app/guides/authentication)
- [Authentication with Cache Components](https://nextjs.org/docs/app/guides/authentication-with-cache-components)
- [Caching with Cache Components](https://nextjs.org/docs/app/getting-started/caching)
- [Caching and Revalidating: Previous Model](https://nextjs.org/docs/app/guides/caching-without-cache-components)
- [Revalidating cached data](https://nextjs.org/docs/app/getting-started/revalidating)
- [Next.js Data Security](https://nextjs.org/docs/app/guides/data-security)
- [Next.js Server Actions and Mutations](https://nextjs.org/docs/app/getting-started/mutating-data)
- [Next.js Proxy](https://nextjs.org/docs/app/api-reference/file-conventions/proxy)
