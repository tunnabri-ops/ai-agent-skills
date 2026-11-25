---
name: architecture-selector
description: Select and document software architecture, module boundaries and design patterns based on project requirements and quality attributes. Use when designing a new system or restructuring an existing one.
---

# Architecture Selector

## Governing rule

Choose architecture from domain complexity, team structure, deployment needs, change frequency, reliability and scaling requirements. Prefer the least complex design that satisfies them. Architecture is a means to control change, not a badge of sophistication.

## Decision sequence

1. Identify business domains and bounded contexts.
2. Identify runtime/deployment boundaries and integration requirements.
3. Rank quality attributes: maintainability, performance, availability, security, testability, delivery speed and cost.
4. Map likely change axes and ownership boundaries.
5. Compare candidate architectures and operational consequences.
6. Define dependency rules and enforceable boundaries.
7. Record the decision in an ADR.

## Architecture options

| Pattern | Suitable when | Cautions |
|---|---|---|
| Simple layered | Small CRUD or conventional business apps | Layers can become pass-through ceremony |
| Modular monolith | Multiple cohesive domains, one deployable unit | Enforce module boundaries; avoid shared internals |
| Clean Architecture | Domain rules should be independent of frameworks and I/O | Can add needless indirection to simple apps |
| Hexagonal | Many external adapters or replaceable infrastructure | Keep ports meaningful and narrow |
| MVC | Request/view-oriented applications | Avoid placing all business logic in controllers |
| MVVM | UI state and presentation logic need separation | Do not duplicate domain rules in view models |
| Repository pattern | Persistence abstraction or query complexity warrants it | Do not create generic repositories that hide useful database features |
| DDD | Complex domain language, invariants and domain collaboration | Tactical DDD is not mandatory for simple CRUD |
| Microservices | Independent deployment/scaling, team ownership and bounded contexts justify distribution | Network failures, data consistency, observability and ops cost |
| Event-driven | Asynchronous workflows and loose coupling are valuable | Event ordering, retries, idempotency and schema evolution |
| CQRS | Read/write models have materially different needs | Adds synchronization and operational complexity |
| Serverless | Event-driven, bursty workloads and managed operations fit | Cold starts, limits, vendor coupling and local testing |

## Default guidance

- Start with a modular monolith for most medium-sized business systems.
- Use simple layered design for small systems.
- Introduce Clean/Hexagonal boundaries around complex domain logic or volatile external dependencies.
- Introduce microservices only with clear service ownership, deployment independence and operational maturity.
- Use CQRS only when read/write asymmetry or scale justifies it.
- Use event sourcing only when the business requires durable event history/reconstruction—not merely because events exist.

## Boundary rules

- Keep domain rules independent from HTTP/UI and database frameworks where the complexity warrants it.
- Depend inward on stable abstractions only when they provide real value.
- Avoid circular dependencies and cross-module writes to internal tables.
- Define explicit contracts for module/service communication.
- Keep transactions and consistency boundaries explicit.
- Make side effects visible and testable.
- Do not create abstractions for hypothetical future needs.

## Required outputs

`docs/ARCHITECTURE.md` must include:
- Context and container/component views (diagram where useful).
- Module responsibilities and allowed dependencies.
- Main request/data flows.
- Trust boundaries and security controls.
- Data ownership and consistency model.
- Deployment topology and operational dependencies.
- Scaling and failure assumptions.
- Known trade-offs.

Create ADRs for consequential choices. Format: Status, Context, Decision, Alternatives, Consequences, Evidence and Date.

## Review questions

Can a developer locate a feature? Can modules be tested independently? Are boundaries enforced? What happens when a dependency is unavailable? Can the system be deployed and operated by the actual team? Is the design simpler than the problem requires?
