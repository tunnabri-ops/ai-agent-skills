---
name: technical-documentation
description: Produce accurate Markdown project documentation, architecture records, setup guides, API references, operational runbooks and final handover reports.
---

# Technical Documentation

## Principles

Documentation is part of the deliverable. It must describe the actual implementation, not an aspirational design. Prefer concise, actionable instructions with tested commands and clear ownership.

## Required documents

- `README.md`: overview, prerequisites, quick start, commands, links and support.
- `docs/PROJECT_BRIEF.md`: problem, users, goals, scope and constraints.
- `docs/REQUIREMENTS.md`: functional/non-functional requirements and acceptance criteria.
- `docs/RESEARCH.md`: sources, findings, date checked, alternatives and assumptions.
- `docs/TECH_STACK.md`: selected technologies, versions, rationale and compatibility.
- `docs/ARCHITECTURE.md`: diagrams, components, boundaries, flows, deployment and trade-offs.
- `docs/adr/`: significant architecture decision records.
- `docs/DATABASE.md`: schema, ownership, migrations, indexes and recovery.
- `docs/API.md`: endpoints, auth, errors, pagination and examples, or link to generated OpenAPI.
- `docs/TEST_PLAN.md` and `docs/TEST_REPORT.md`.
- `docs/SECURITY_REVIEW.md`.
- `docs/DEPLOYMENT.md`: environments, configuration, migrations, rollout and rollback.
- `docs/CHANGELOG.md`.
- `docs/FINAL_HANDOVER.md`: delivered scope, setup, checks, limitations and next steps.

Adapt the list to the project; do not create irrelevant documents.

## Documentation quality

- Use relative links that work in the repository.
- Include prerequisites and exact commands.
- Explain required environment variables without including real secrets.
- Include `.env.example` with safe placeholders only.
- Label assumptions and unverified items.
- Keep diagrams synchronized with actual boundaries.
- Include troubleshooting and recovery guidance.
- Document breaking changes and migration requirements.
- Verify setup instructions from a clean environment when feasible.

## Final handover

Summarize:
1. What was requested and delivered.
2. Important technical decisions.
3. How to install, configure, run and test.
4. Deployment and rollback procedure.
5. Test commands and actual results.
6. Security review status.
7. Known limitations and accepted risks.
8. Recommended next steps.

Never claim documentation is complete if key commands or operational steps remain unverified.
