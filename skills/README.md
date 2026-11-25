# Professional Software Engineering Agent Skills

A modular, stack-aware software engineering skill system for compatible AI coding agents.

## Design goals

- Research before implementation; prefer official, current documentation.
- Select technology and architecture from requirements, not popularity.
- Build maintainable, secure, observable, tested software.
- Treat code review and quality assurance as release gates.
- Keep project decisions and delivery evidence in Markdown.
- Prefer the simplest architecture that satisfies current and reasonably foreseeable requirements.

## Installation

Copy the skill directories into a skills directory supported by your coding agent. The exact discovery path depends on the agent product. Keep each directory name aligned with its `name` frontmatter value.

Start by enabling `software-engineering-orchestrator`. Enable relevant specialist skills as well. The files in `references/` are supplementary materials for maintainers and agents; consult them when useful, but they are not automatically loaded by a skill.

## Included skills

| Skill | Purpose |
|---|---|
| `architecture-selector` | Architecture and design-pattern selection |
| `code-review-security` | Deep code review and security verification |
| `database-engineering` | Relational, document, cache and data-access design |
| `dotnet-development` | C#/.NET and ASP.NET Core applications |
| `electron-development` | Cross-platform desktop applications |
| `flutter-development` | Cross-platform Flutter applications |
| `go-backend-development` | Go services, APIs and distributed systems |
| `laravel-development` | PHP Laravel applications and ecosystem |
| `mern-pern-development` | React/Node.js/MongoDB/PostgreSQL applications |
| `nextjs-development` | Next.js App Router, caching, auth and production features |
| `project-discovery-research` | Discovery, requirements, research and feasibility |
| `python-backend-development` | FastAPI, Django and Flask services |
| `software-engineering-orchestrator` | End-to-end SDLC control and skill coordination |
| `technical-documentation` | Project documentation and handover |
| `technology-stack-selector` | Stack, framework and library selection |
| `testing-quality-assurance` | Test strategy and release quality gates |

## Expected project documentation

At minimum, create and maintain:

- `README.md`
- `docs/PROJECT_BRIEF.md`
- `docs/REQUIREMENTS.md`
- `docs/RESEARCH.md`
- `docs/TECH_STACK.md`
- `docs/ARCHITECTURE.md`
- `docs/adr/` — Architecture Decision Records
- `docs/DATABASE.md` or schema documentation
- `docs/API.md` or generated OpenAPI documentation
- `docs/TEST_PLAN.md`
- `docs/TEST_REPORT.md`
- `docs/SECURITY_REVIEW.md`
- `docs/DEPLOYMENT.md`
- `docs/CHANGELOG.md`
- `docs/FINAL_HANDOVER.md`

Do not create empty documents merely to satisfy a checklist. Mark unknowns explicitly and update documents as decisions become verified.

## Operating principles

1. Never claim a test, build, migration, deployment or security scan passed unless it was actually run and its result inspected.
2. Never invent benchmark results, package versions, API behavior or documentation facts.
3. Never expose secrets. Use environment variables and secret managers.
4. Never run destructive commands, production migrations or deployments without explicit authorization and a recovery plan.
5. Do not add dependencies without a reason. Check maintenance status, license, compatibility and security.
6. Do not overengineer. A modular monolith is usually a safer starting point than premature microservices.
7. Preserve existing conventions when they are sound; explain and plan any breaking change.
8. If requirements are ambiguous and materially affect architecture, ask focused questions. Otherwise state assumptions and proceed conservatively.

## Skill format

Each skill uses the portable `SKILL.md` folder format with YAML frontmatter. Supporting references are kept in `references/`.
