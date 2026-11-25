# Example workflows

These are illustrative prompts showing how the current skills can be combined. They are not reports of work performed or guaranteed outputs.

---

## 1. Plan a new project

**User:**

> I want to build a booking platform for a small clinic. Help me plan it before implementation.

**Possible workflow:**

1. `software-engineering-orchestrator` inspects the existing repository and coordinates the work.
2. `project-discovery-research` clarifies users, booking rules, privacy needs, constraints and acceptance criteria, then verifies relevant technical assumptions against primary sources.
3. `technology-stack-selector` and `architecture-selector` compare viable options and record the selected stack and system boundaries.
4. `database-engineering` reviews the data model, constraints, indexes and transaction needs for availability and bookings.
5. `technical-documentation` helps create the project brief, requirements, architecture notes and decision records.

The team should agree on the requirements and consequential decisions before implementation starts.

---

## 2. Choose a database

**User:**

> This app stores orders, inventory and customer details. Should I use PostgreSQL or MongoDB?

**Possible response shape:**

| Consideration | Questions to resolve |
|---|---|
| Data relationships | How are orders, customers and inventory queried together? |
| Consistency | Which updates must succeed or fail atomically? |
| Access patterns | What reads and writes are expected, and how will they grow? |
| Operations | Which database can the team deploy, back up and maintain? |

`project-discovery-research`, `technology-stack-selector`, `architecture-selector` and `database-engineering` can help gather constraints, compare the options, and document a decision. The result should depend on verified requirements rather than a universal rule.

---

## 3. Review a change before merging

**User:**

> Review my branch against the base branch and tell me what must be fixed before merge.

**Possible workflow:**

1. `code-review-security` inspects the complete diff and relevant surrounding code for correctness, authorization, data integrity, security and maintainability.
2. It reports only actionable findings, with severity, affected location, impact and a concrete remediation.
3. `testing-quality-assurance` identifies focused tests for the changed behavior and runs the repository's relevant checks.
4. The orchestrator summarizes fixed findings, remaining risks and the exact checks that were run.

Review only code and systems the user is authorized to assess. Do not claim a test or security check passed unless it was actually run.

---

## 4. Document an existing service

**User:**

> Write a setup guide and API overview for this service, but first verify what the code actually does.

**Possible workflow:**

1. `technical-documentation` inspects the repository, configuration, routes and existing tests.
2. It records confirmed setup steps and API behavior, distinguishing verified details from unknowns.
3. It updates the appropriate README or documentation pages and links to source or generated API specifications where useful.
4. The orchestrator checks that the documentation matches the implementation and reports any gaps it could not verify.

---

## 5. Build a Next.js app with caching and authentication

**User:**

> Build a product catalog and account dashboard in Next.js. The catalog should stay fast but update after edits; account data must never leak between users.

**Possible workflow:**

1. `nextjs-development` checks the installed Next.js version, router, deployment runtime and whether Cache Components are enabled.
2. `project-discovery-research` clarifies catalog freshness, user/session requirements, identity provider needs and data sensitivity.
3. Cache public catalog data with an explicit lifetime and tag; invalidate after admin edits. Use immediate `updateTag` behavior for user-facing Server Action writes that require read-your-own-writes, and stale-while-revalidate for suitable webhook updates.
4. Choose a maintained auth library or managed OIDC provider based on the product's SSO, MFA, account recovery, deployment and operational requirements. Avoid custom protocol or cryptographic code.
5. Keep session checks and record-level authorization in a server-only data access layer. Treat Proxy checks as early redirects only, and authorize every Server Action and Route Handler independently.
6. Stream request-specific account UI behind Suspense. Do not put private account data in a cache shared across users; if private data is cached, prove identity/tenant isolation and invalidation behavior with tests.

The implementation should verify cache isolation, freshness, mutation invalidation, denied access, loading states and the production build.

---

## 6. Choose Laravel or .NET for a business application

**User:**

> We need an internal business API with a relational database, background jobs and role-based access. Our team has experience with both PHP and C#.

**Possible workflow:**

1. `project-discovery-research` clarifies hosting, integrations, team ownership, support lifecycle, security and operational constraints.
2. `technology-stack-selector` compares Laravel and ASP.NET Core against those requirements rather than assuming either framework is universally better.
3. If Laravel is selected, `laravel-development` guides Eloquent data modeling, policies, session/API authentication, queues, migrations and deployment.
4. If .NET is selected, `dotnet-development` guides the ASP.NET Core API style, authentication schemes, policy/resource authorization, EF Core, hosted services and deployment.
5. `database-engineering` and `testing-quality-assurance` help validate transaction boundaries, background-job retry behavior and authorization tests.

Record the selected framework, supported runtime versions, authentication model, database, queue backend and deployment evidence in the project's decision documents.
