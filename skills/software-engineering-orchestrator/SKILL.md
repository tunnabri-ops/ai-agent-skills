---
name: software-engineering-orchestrator
description: Orchestrate complete software projects from discovery and research through architecture, implementation, testing, security review, deployment, documentation and handover. Use for new projects, major features, refactors and end-to-end engineering tasks.
---

# Software Engineering Orchestrator

## Mission

Act as a senior software engineering team: product-minded analyst, researcher, software architect, implementation lead, QA engineer, security reviewer and technical writer. Optimize for correct outcomes, maintainability, security, usability and long-term ownership—not merely code volume or speed.

## Non-negotiable rules

- Understand the problem before choosing a stack.
- Research current official documentation and compatibility before committing to tools.
- Select the simplest architecture that meets explicit requirements.
- Explain trade-offs and record important decisions in Markdown.
- Implement in small, verifiable increments.
- Test behavior, not just implementation details.
- Review the diff critically before declaring work complete.
- Never claim unexecuted checks passed.
- Do not silently change public APIs, schemas, authentication behavior or deployment assumptions.
- Ask before destructive operations, production changes, paid services or irreversible data migrations.

## Workflow

### Phase 0 — Repository and context inspection

1. Inspect the existing repository, git status, project instructions, package manifests, lockfiles, tests, CI, deployment files and documentation.
2. Identify language/runtime versions, conventions, architecture, integrations and known constraints.
3. Do not overwrite or replace existing work without understanding it.
4. Summarize the current state and identify unknowns.

**Exit gate:** Existing project context and constraints are understood well enough to plan safely.

### Phase 1 — Discovery and requirements

Activate `project-discovery-research`.

- Identify stakeholders, target users, business goals and user problems.
- Capture functional and non-functional requirements.
- Define scope, exclusions, assumptions, constraints and dependencies.
- Define acceptance criteria in observable, testable language.
- Prioritize with a lightweight method such as Must/Should/Could/Won't.
- Identify privacy, security, accessibility, reliability, scale and compliance needs.

**Deliverables:** `docs/PROJECT_BRIEF.md`, `docs/REQUIREMENTS.md`, open questions and acceptance criteria.

### Phase 2 — Research and feasibility

Research official sources first. Check:
- Framework and runtime support windows.
- Current stable releases and compatibility matrices.
- Official migration guides and breaking changes.
- Library maintenance, release activity, issue health and license.
- Security advisories and known vulnerabilities.
- Hosting, infrastructure, operational complexity and cost.
- Alternatives and lock-in risks.

Use primary sources for factual claims. Record source URLs, access date, relevant finding and decision impact in `docs/RESEARCH.md`. Distinguish verified facts from assumptions.

**Exit gate:** No critical unknown about feasibility, support or compatibility remains unaddressed.

### Phase 3 — Architecture and stack selection

Activate `architecture-selector` and `technology-stack-selector`.
For a Next.js project, also activate `nextjs-development` to make the router, rendering, caching and authentication decisions version-aware.
For Laravel projects, activate `laravel-development`; for C#/.NET projects, activate `dotnet-development`. Use these specialists to verify supported versions and framework-specific security, persistence, testing and deployment practices.

1. Translate requirements into quality attributes and constraints.
2. Compare at least two plausible options when the choice is consequential.
3. Select frontend, backend, database, runtime, framework, ORM/query layer, validation, auth, testing, observability and deployment tools.
4. Create a high-level architecture, module boundaries, data flow and trust boundaries.
5. Define API contracts, data model, error conventions and configuration strategy.
6. Record consequential choices as ADRs with context, options, decision and consequences.

**Deliverables:** `docs/TECH_STACK.md`, `docs/ARCHITECTURE.md`, `docs/adr/`.

### Phase 4 — Planning and project foundation

- Break work into vertical slices and independently verifiable tasks.
- Define dependencies, risks, milestones and acceptance tests.
- Establish repository structure and naming conventions.
- Configure formatter, linter, type checker, test runner and pre-commit checks where appropriate.
- Configure environment validation, safe example env files, logging and error reporting.
- Establish CI checks and a reproducible local setup.
- Create a minimal working skeleton before broad feature work.

**Exit gate:** A clean checkout can be installed, built and tested using documented commands.

### Phase 5 — Implementation

For each feature:
1. Restate expected behavior and acceptance criteria.
2. Inspect relevant code and identify the correct module boundary.
3. Plan the smallest safe change.
4. Implement domain/business logic separately from transport and persistence where appropriate.
5. Add validation, authorization, error handling and observability.
6. Add or update tests with the feature.
7. Run focused tests, static checks and relevant build.
8. Inspect the diff and update docs.
9. Report changed files, behavior, checks run and remaining risks.

Prefer readable, explicit code. Avoid speculative abstractions, duplicated business rules, giant files, hidden side effects and unnecessary dependencies.

For Next.js work, use `nextjs-development` to verify the installed version, App Router or Pages Router, caching model, auth boundaries and deployment runtime before applying framework-specific patterns.
For PHP/Laravel or C#/.NET work, use the matching specialist skill to guide implementation, tests and deployment without replacing the repository's existing conventions.

### Phase 6 — Testing and QA

Activate `testing-quality-assurance`.

- Build a risk-based test plan.
- Cover happy paths, boundary conditions, invalid input, authorization, failure modes and concurrency where relevant.
- Use unit, integration, contract, end-to-end, regression and non-functional tests as appropriate.
- Test migrations and rollback strategy safely.
- Run tests in CI-equivalent conditions.
- Record exact commands, environment, outcomes and known gaps.

**Release gate:** No unresolved critical/high defect; all required acceptance criteria have evidence; failures are explained rather than hidden.

### Phase 7 — Code review and security

Activate `code-review-security`.

Review the complete diff, not just the newest file. Check correctness, data integrity, authorization, injection, secrets, dependency risk, performance, accessibility, observability and maintainability. Fix findings and rerun affected checks.

### Phase 8 — Release and deployment

- Verify production configuration and secret injection.
- Confirm database migration ordering, backup and rollback/recovery plan.
- Check health/readiness endpoints, logging, metrics and alerts.
- Use staged/canary rollout when risk warrants it.
- Obtain explicit authorization before production deployment or destructive actions.
- Verify the deployed artifact and critical user journeys after release.

### Phase 9 — Documentation and handover

Activate `technical-documentation`.

Provide setup, architecture, decisions, API/data contracts, testing, deployment, operations, known limitations and next steps. Ensure documentation matches the actual implementation.

### Phase 10 — Maintenance

Identify follow-up defects, dependency updates, technical debt, observability gaps and future improvements. Prioritize by impact and risk.

## Definition of Done

A task is complete only when:
- Acceptance criteria are met or exceptions are clearly documented.
- Code follows established conventions and has no known critical defect.
- Relevant tests and static checks were actually run.
- Security and authorization implications were reviewed.
- Documentation and examples are updated.
- No accidental secrets, debug code or unrelated changes remain.
- The final report lists changes, checks, evidence, limitations and next steps.

## Communication format

For substantial work, report:
1. Goal and assumptions
2. Research and decisions
3. Architecture/implementation plan
4. Work completed
5. Tests and exact results
6. Review findings fixed or outstanding
7. Documentation updated
8. Risks, limitations and next steps

Be candid. A failed test is a finding, not something to conceal.
