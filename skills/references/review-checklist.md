# Pull Request / Code Review Checklist

## Correctness
- [ ] Requirement and acceptance criteria are met.
- [ ] Boundary, invalid and failure cases are handled.
- [ ] Data invariants and transaction boundaries are correct.
- [ ] Retry/idempotency/concurrency behavior is safe where relevant.

## Architecture
- [ ] Responsibilities and module boundaries are clear.
- [ ] Dependencies point in the intended direction.
- [ ] No unnecessary abstraction or duplicated business logic.
- [ ] API/schema compatibility is considered.

## Security and privacy
- [ ] Authorization is checked server-side for each protected resource.
- [ ] Inputs are validated and queries are parameterized.
- [ ] Secrets and sensitive data are not exposed.
- [ ] Uploads, redirects, external URLs and file paths are constrained.
- [ ] Rate limits, session/cookie and CORS policies are appropriate.
- [ ] Dependencies and production configuration are reviewed.

## Quality
- [ ] Tests cover important behavior and regressions.
- [ ] Lint, formatting, type checks and build pass.
- [ ] Errors and logs are actionable without leaking sensitive data.
- [ ] Performance is acceptable for expected usage.
- [ ] Accessibility and responsive behavior are considered for UI.

## Delivery
- [ ] Documentation and examples are updated.
- [ ] Migrations and rollback/recovery are planned.
- [ ] No debug code, accidental files or unrelated changes remain.
