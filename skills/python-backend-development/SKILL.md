---
name: python-backend-development
description: Build maintainable Python APIs and backend services with FastAPI, Django or Flask, including validation, persistence, async behavior, testing and deployment.
---

# Python Backend Development

## Framework choice

- FastAPI: typed API-first services, automatic OpenAPI and async-compatible I/O.
- Django: integrated ORM, admin, auth and a cohesive full-stack application.
- Flask: minimal services and explicit extension selection.
- Do not choose async solely because it is fashionable; use it when the I/O workload and libraries support it.

## Engineering baseline

- Pin a supported Python version and dependency lock strategy.
- Use isolated environments and reproducible installs.
- Add type hints to public interfaces and core business logic.
- Use Pydantic or framework-native validation at input boundaries.
- Separate routers/views, application services, domain rules and persistence as justified.
- Keep configuration external and validate it at startup.
- Use structured logging and avoid logging secrets or sensitive payloads.
- Use timezone-aware datetimes and explicit serialization formats.
- Define consistent exception-to-HTTP mapping.

## FastAPI

- Use routers by domain/feature.
- Use dependency injection for request-scoped resources and auth context.
- Keep route functions thin.
- Define request/response schemas separately where they have different security or compatibility needs.
- Use async endpoints only when called dependencies are async-compatible; do not block the event loop.
- Configure OpenAPI metadata and security schemes accurately.
- Test dependency overrides and authorization paths.

## Django

- Use apps aligned to business domains.
- Keep models focused; move complex workflows into explicit services when helpful.
- Review ORM query counts, prefetch/select-related behavior and transaction boundaries.
- Enforce permissions server-side.
- Use migrations carefully and inspect generated operations.
- Protect admin, CSRF and session settings in production.
- Avoid turning signals into invisible business workflow orchestration.

## Flask

- Use application factory and blueprints for non-trivial systems.
- Centralize configuration and error handlers.
- Choose extensions deliberately and verify maintenance.
- Avoid global mutable request state.

## Testing and delivery

- Use pytest or the framework's supported test tools.
- Test validation, authz, transactions, error mapping and integration boundaries.
- Use a real disposable test database for database behavior.
- Test async code with compatible test infrastructure.
- Run format, lint, type checks, tests and production startup smoke tests.
- Document environment variables, migrations, worker processes and deployment topology.
