# Stack Selection Matrix

Use this as a starting point, not an automatic decision table. Verify current support and compatibility before adoption.

| Project shape | Candidate stack | Important decision checks |
|---|---|---|
| Relational SaaS web app | React + TypeScript + Node (NestJS/Express) + PostgreSQL + Prisma/Drizzle | Domain complexity, transactions, team conventions |
| Document-centric web app | React + Node + MongoDB | Aggregate boundaries, reporting, consistency |
| SEO/content-heavy React app | Next.js + suitable backend/data layer | Rendering needs, caching, hosting and server/client boundaries |
| Typed API service | FastAPI + PostgreSQL + SQLAlchemy/SQLModel | Async library compatibility, migration workflow |
| Integrated admin/business platform | Django + PostgreSQL | Built-in admin/auth fit and customization needs |
| Lightweight Python service | Flask + chosen persistence layer | Team discipline for validation, structure and extensions |
| Convention-driven PHP web app | Laravel + PostgreSQL/MySQL | PHP/Laravel support, team familiarity, queue/cache operations |
| C# business API/service | ASP.NET Core + EF Core + PostgreSQL/SQL Server | .NET support lifecycle, provider compatibility, hosting and team fit |
| High-concurrency service | Go + stdlib/Chi + PostgreSQL | Actual workload, operational simplicity, profiling |
| Cross-platform mobile | Flutter + API backend | Native integration, offline mode, store requirements |
| Desktop with web team | Electron + React/Vue | Memory footprint, OS integration, security boundaries |
| Edge/serverless HTTP API | Hono or platform-native runtime | Runtime APIs, package compatibility, vendor lock-in |

## Selection scorecard

Score 1–5 and explain each score. Weights should reflect project priorities.

| Criterion | Suggested weight |
|---|---:|
| Requirement fit | 25% |
| Maintainability and team fit | 20% |
| Security and support | 15% |
| Operational/deployment fit | 15% |
| Performance for expected workload | 10% |
| Ecosystem and testing | 10% |
| Cost and lock-in | 5% |

A score is a decision aid, not objective truth. Reject a candidate if it fails a hard constraint regardless of total score.
