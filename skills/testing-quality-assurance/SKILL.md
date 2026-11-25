---
name: testing-quality-assurance
description: Create risk-based test strategies and execute unit, integration, contract, end-to-end, regression, accessibility, security and performance testing for software projects.
---

# Testing and Quality Assurance

## Quality philosophy

Testing is a design and risk-control activity, not a final checkbox. Choose tests based on user impact, failure likelihood and cost of detection. Test externally observable behavior and important invariants.

## Test pyramid and coverage

- Unit: deterministic business rules, calculations, validation and state transitions.
- Integration: database, filesystem, queues, caches and external adapters.
- Contract: API schemas, event schemas and consumer/provider compatibility.
- End-to-end: critical user journeys across real application boundaries.
- Regression: previously fixed defects and high-risk workflows.
- Non-functional: performance, accessibility, reliability, security and recovery.

Do not optimize for a coverage percentage alone. Critical paths and branches matter more than raw line coverage.

## Test design

For each requirement, identify:
- Happy path.
- Invalid and missing inputs.
- Boundary values and limits.
- Authentication and authorization failures.
- Duplicate/retry behavior.
- Dependency outage and timeout behavior.
- Concurrency/race conditions where relevant.
- Data migration and compatibility behavior.
- Accessibility and responsive behavior for UI.

Use equivalence partitions, boundary-value analysis and state-transition testing where useful.

## Test quality

- Keep tests deterministic and isolated.
- Avoid arbitrary sleeps; use controllable clocks and synchronization.
- Use factories/builders and realistic fixtures.
- Do not mock the behavior under test.
- Use disposable real databases for database semantics.
- Reset external state between tests.
- Make test names describe behavior.
- Preserve failing output and investigate root causes; do not weaken assertions merely to make tests pass.

## Tool suggestions

Choose based on the stack:
- TypeScript: Vitest or Jest; Playwright for browser E2E.
- Python: pytest and suitable async/client fixtures.
- Go: standard `testing`, httptest, race detector and fuzzing.
- Flutter: `flutter_test`, widget and integration tests.
- Electron: unit/integration tests plus packaged-app smoke tests.

Verify current compatibility before adding test dependencies.

## Execution sequence

1. Run focused tests for the changed behavior.
2. Run module integration tests.
3. Run full test suite.
4. Run formatter, linter, type checker and static analysis.
5. Build production artifacts.
6. Run E2E for critical journeys.
7. Run security/dependency scans.
8. Run performance checks only against a defined workload and threshold.
9. Inspect flaky tests and repeat only to diagnose—not to hide instability.

## Test report

Write `docs/TEST_REPORT.md` with commit/build identifier, environment, commands, pass/fail/skip counts, relevant logs, acceptance criteria evidence, known gaps and residual risks. Never report a test as passed if it was not executed.
