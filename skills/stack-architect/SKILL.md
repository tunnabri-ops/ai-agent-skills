---
name: stack-architect
description: Use when choosing a technology stack, framework, database, or software architecture for a new project, when comparing stacks or architectures, or when writing a stack decision document before coding starts.
---

# Stack Architect

Choose the stack and architecture from requirements, not from trends.
A stack that fits the team, the budget, and the scale beats a fashionable
stack that nobody on the team can operate in production. Decide first,
document the decision, then build. Never start coding before the decision
is written down and the trade-offs are explicit.

## Step 1 — Gather Requirements First

Do not recommend anything until these questions are answered. If the user
cannot answer them, ask, and record the answers in the decision document.

- What is the product? Web app, API, realtime service, mobile app,
  desktop app, AI service, e-commerce store, or SaaS platform?
- Who are the users, and how many? 10 users, 1,000, or 1,000,000?
- What is the read/write ratio? Mostly reads, mostly writes, or balanced?
- Is it realtime? Chat, live scores, collaboration, and notifications
  need websockets or server-sent events, not polling.
- What data matters? Relational data, documents, files, search, time
  series, or vectors for AI features?
- What is the team skill? A Python team should not be forced onto Go,
  and a JavaScript team should not be forced onto Django, without a
  clear, quantified reason.
- What is the hosting budget? Free tier, 10 dollars a month, or a
  production budget with managed services?
- What is the deadline? An MVP in two weeks and a five-year platform
  get different answers.
- What are the hard constraints? Compliance, offline use, app-store
  rules, payment rules, or an existing system to integrate with?

## Step 2 — Decision Matrix by Project Type

Score each option 1 to 5 on fit, team skill, cost, and time to market.
The highest total wins. Record the scores; do not decide by gut feeling.

| Project type | Default choice | Strong alternative | Avoid |
|---|---|---|---|
| Marketing site / blog | Next.js static | Astro, plain HTML | A full backend |
| Web app, CRUD + auth | Next.js + PostgreSQL | MERN, PERN | Microservices |
| REST / GraphQL API | NestJS or FastAPI | Go + Gin, Express | A framework the team does not know |
| Realtime (chat, live) | Node.js + WebSocket + Redis | Go + NATS | Polling every second |
| Mobile app | Flutter | React Native | Two separate native apps for an MVP |
| Desktop app | Electron.js | Tauri | A web app wrapped without offline support |
| AI service | FastAPI + Python | Node.js + Python workers | Putting model code inside the web server |
| E-commerce | Next.js + Stripe + PostgreSQL | Shopify, WooCommerce | A custom cart for a standard store |
| SaaS, multi-tenant | NestJS + PostgreSQL + Redis | Django + PostgreSQL | MongoDB for billing and ledger data |
| MVP, validate fast | The stack the team already ships | Next.js + Supabase | Microservices, Kubernetes |

## Step 3 — Compare the Stacks Honestly

### Frontend and full-stack frameworks

- Next.js: server rendering, routing, and API routes in one place.
  Best for SEO, dashboards, and SaaS. Cost: Node.js hosting required.
- MERN (MongoDB, Express, React, Node.js): flexible documents, fast
  to start. Weak for relational data, transactions, and reporting.
- PERN (PostgreSQL, Express, React, Node.js): same shape as MERN
  with real relations, joins, and transactions. Prefer it when data
  is relational, which is most business software.
- NestJS: structured, typed, dependency injection, good for large
  teams and long-lived APIs. Heavier to start than Express.
- Django: batteries included, admin panel, ORM, strong security
  defaults. Best when the team knows Python and wants speed.
- Laravel: the same idea in PHP, with a large ecosystem and cheap
  shared hosting. Best when the team knows PHP.
- FastAPI: the best Python API framework, typed, fast, with automatic
  OpenAPI docs. Best for AI services and data APIs.
- Go: fast, small binaries, excellent concurrency. Best for high
  throughput services. Slower to write CRUD than NestJS or Django.
- Flutter: one codebase for iOS, Android, web, and desktop. Best
  for a small team shipping mobile first.
- Electron.js: web technology as a desktop app. Best for a desktop
  app that reuses a web UI. Watch the install size and memory use.

### Backend runtimes and frameworks

- Express vs Hono vs Fastify vs NestJS: Express is the safe default
  with the largest ecosystem. Hono is light and runs on edge runtimes.
  Fastify is faster than Express with schema validation built in.
  NestJS is the choice for a large, structured, long-lived API.
- Deno vs Node.js: Node.js has the larger ecosystem and more hosting
  options. Deno has better defaults for security and TypeScript.
  Choose Node.js unless the team already uses Deno.

### Databases

- PostgreSQL vs MongoDB vs MySQL: PostgreSQL is the default for
  relational data, JSON support, full-text search, and extensions.
  MySQL is a solid alternative where the team or host requires it.
  MongoDB fits document-shaped data with changing schemas, and is a
  poor fit for money, inventory, and anything needing transactions.
- Redis: cache, sessions, queues, rate limiting, and pub/sub. Add it
  only when there is a measured need, not by default.
- Docker: use it for reproducible local development and deployment.
  Every service gets a `Dockerfile` and a documented local command.
  Do not adopt Kubernetes for a small product; a single container on
  a managed platform is enough until traffic forces a change.
- SQLite: excellent for a single-user desktop app, a CLI tool, or a
  prototype. Not a choice for a multi-user web service.

## Step 4 — Compare the Architectures

- Modular monolith: one deployable unit, split into clear modules
  with explicit boundaries. The default choice for almost every
  product. Easy to test, deploy, and debug.
- Layered architecture: presentation, application, domain, and
  infrastructure layers. Good inside a modular monolith.
- Repository pattern: data access behind an interface, so the
  database can change without rewriting business logic. Use it for
  the core domain, not for every trivial query.
- Clean architecture / hexagonal architecture: business logic in the
  centre, adapters at the edges. Worth the ceremony for a complex
  domain that must outlive its frameworks. Overkill for simple CRUD.
- MVC: model, view, controller. Fine for a small server-rendered
  app. It breaks down when business logic leaks into controllers.
- Microservices: separate deployable services per bounded context.
  Use them only when teams, scale, or independent deployment truly
  require it. Never use them for an MVP, a solo project, or a small
  team. They multiply deployment, testing, monitoring, and debugging
  cost. A modular monolith with clear module boundaries can be split
  later, when a real boundary has proven itself.

## Step 5 — Compare the Data Tools

- Prisma vs Drizzle vs SQLAlchemy: Prisma is productive and typed
  for TypeScript, with migrations built in. Drizzle is lighter and
  closer to SQL. SQLAlchemy is the standard for Python. Pick the one
  that matches the language, not the one with the most stars.
## Step 6 — Write STACK_DECISION.md

The agent MUST write this file for the user before coding starts.
Keep it to one or two pages. Use this exact structure:

```markdown
# Stack Decision — <project name>

## Decision
- Stack: <frameworks, language, database, cache, hosting>
- Architecture: <modular monolith / layered / clean / other>
- Repository layout: <monorepo / single repo, folder names>

## Why this stack
- <requirement> -> <choice> -> <benefit>
- <requirement> -> <choice> -> <benefit>

## What was rejected and why
- <rejected option>: <reason, e.g. team has no experience, cost, overkill>
- <rejected option>: <reason>

## Trade-offs accepted
- <trade-off and its cost, e.g. slower cold start, larger bundle>

## Risks
- <risk> — mitigation: <concrete action>

## Costs
- Hosting: <estimate per month>
- Services: <estimate per month>

## Next steps
1. <first concrete build step>
2. <second concrete build step>
```

## Rules

- Never pick a stack because it is trendy, popular on social media,
  or new. Pick by requirements, team skill, scale, and hosting cost.
- Never pick two tools that do the same job. One database, one ORM,
  one queue, one cache, unless a measured need proves otherwise.
- Never design for a million users on day one. Design for the first
  thousand, with a clear path to scale.
- Never choose a stack the team cannot debug at 2 a.m. in production.
- If the user insists on a stack that does not fit, say so plainly,
  record the risk in the decision document, and proceed only with
  their explicit confirmation.

## Pitfalls

- Choosing microservices for a three-person team.
- Choosing MongoDB for billing, ledgers, or inventory.
- Adding Redis, a queue, and a search engine before the first user.
- No migrations: schema changes applied by hand and lost.
- Copying a large company's stack without its team or its budget.
