---
name: project-discovery-research
description: Discover software requirements, analyze feasibility, research current technologies and produce evidence-backed project plans. Use before starting a new project or making consequential technical choices.
---

# Project Discovery and Research

## 1. Understand the problem

Identify:
- Business objective and measurable success criteria.
- User groups, roles, workflows and pain points.
- Core user journeys and edge cases.
- Existing systems, data sources and integrations.
- Platforms: web, mobile, desktop, API, embedded or mixed.
- Expected users, traffic, data volume, latency and growth.
- Budget, timeline, team skills and operational capacity.
- Privacy, data residency, compliance and accessibility needs.

Ask only questions whose answers materially change scope, architecture, safety or cost. If the user cannot answer, state a conservative assumption and mark it for validation.

## 2. Requirements

Separate:
- Functional requirements: what the system does.
- Non-functional requirements: performance, availability, scalability, security, accessibility, maintainability, portability and observability.
- Constraints: mandated language, hosting, vendors, deadlines or integrations.
- Out-of-scope items.
- Risks and unresolved decisions.

Write requirements as uniquely identified statements. Each feature should have acceptance criteria with observable outcomes. Include negative and permission-related cases.

## 3. Research protocol

Research before selecting technologies. Prefer:
1. Official product documentation and release notes.
2. Official language/runtime documentation.
3. Official security advisories and vulnerability databases.
4. Maintainer repositories and issue trackers.
5. Standards and recognized engineering references.
6. Community reports as supporting—not sole—evidence.

For each candidate, verify:
- Current supported/stable version and runtime compatibility.
- Installation and deployment model.
- Type safety, validation and migration capabilities.
- Testing ecosystem and debugging support.
- Maintenance activity, governance and bus factor.
- License suitability and dependency footprint.
- Security posture and upgrade path.
- Hosting options, cost and vendor lock-in.
- Operational complexity for the actual team.

Do not infer popularity equals quality. Do not copy version numbers from memory; verify at decision time.

## 4. Feasibility

Evaluate technical, operational, economic, schedule and legal feasibility. Identify proof-of-concept needs for high-risk areas such as realtime scale, offline sync, complex authorization, media processing or third-party APIs.

Use a time-boxed spike when evidence is insufficient. Define the question, experiment, success threshold and result before running it.

## 5. Required documentation

Create `docs/PROJECT_BRIEF.md`, `docs/REQUIREMENTS.md` and `docs/RESEARCH.md`.

Research log format:

| Candidate / topic | Source URL | Verified finding | Date checked | Impact / confidence |
|---|---|---|---|---|

Clearly label assumptions, unknowns and facts. Include alternatives considered and why they were rejected.

## 6. Exit criteria

Do not finalize architecture until:
- The core problem and users are understood.
- Scope and acceptance criteria are written.
- Critical non-functional requirements are identified.
- Major technology risks and compatibility questions are researched.
- The remaining uncertainty is acceptable or covered by a spike.
