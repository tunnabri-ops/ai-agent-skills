---
name: database-engineering
description: Design, implement, migrate and optimize relational, document and cache data systems, including PostgreSQL, MongoDB, Redis, Prisma, Drizzle and SQL tooling.
---

# Database Engineering

## Choose by data and consistency needs

- PostgreSQL: strong default for relational business data, transactions, constraints, joins and reporting.
- MongoDB: document aggregates and flexible document evolution where access patterns fit.
- Redis: cache, ephemeral coordination, rate limiting or queue primitives with explicit durability and eviction semantics.
- SQLite: embedded/local-first/single-node workloads where concurrency constraints fit.

Do not choose a database based on a vague claim that it scales better. Define workload and consistency requirements.

## Data modeling

1. Identify entities, ownership, relationships and invariants.
2. Define transaction boundaries and consistency expectations.
3. Model access patterns before adding indexes.
4. Use constraints for invariants the database can enforce.
5. Define retention, deletion, privacy and audit requirements.
6. Plan schema evolution and backfills.

## ORM and query layer

Choose Prisma, Drizzle, SQLAlchemy, Django ORM, GORM, sqlc or direct SQL based on language, query complexity, migration reliability, type safety and team skills. Review generated SQL and migrations. Avoid generic repositories that conceal useful query capabilities.

## Reliability and performance

- Use parameterized queries.
- Set connection pool limits and timeouts.
- Use pagination; prefer cursor pagination for large/changing datasets where appropriate.
- Detect N+1 queries and unbounded reads.
- Use transactions intentionally; keep them short.
- Design idempotency for retried writes.
- Add indexes from measured query patterns and inspect query plans.
- Define backup, restore and disaster recovery procedures.
- Test restore, not merely backup creation.
- Define cache invalidation, TTL and stampede protection.
- Avoid storing secrets or unnecessary personal data.

## Migrations

- Review migration scripts manually.
- Prefer backward-compatible expand/migrate/contract changes for zero-downtime deployments.
- Back up and verify before destructive production migrations.
- Define rollback or forward-fix strategy.
- Never run destructive migrations against production without explicit authorization.
- Test migrations against realistic disposable data.

## Documentation

Maintain schema diagrams, ownership, constraints, indexes, migration policy, backup/restore instructions, data retention and operational runbooks.
