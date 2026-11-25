<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0D1117&height=220&section=header&text=AI%20AGENT%20SKILLS&fontSize=64&fontColor=00FF9C" width="100%" />

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE) [![Skills: 16](https://img.shields.io/badge/Skills-16-blue.svg)](#skills) [![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-purple.svg)](#install) [![Codex](https://img.shields.io/badge/Codex-Compatible-green.svg)](#install)

</div>

# ai-agent-skills

A portable set of 16 software-engineering skills for AI coding agents. Use the orchestrator to guide a project from discovery through architecture, implementation, testing, security review, documentation and handover, or install individual skills for focused work.

The skills cover project discovery, research, stack and architecture selection, backend and application development, database engineering, testing, code review and security, and technical documentation. Shared reference material lives under [`skills/references/`](skills/references/).

> Skills use the portable `SKILL.md` format and can be adapted for coding agents that support it.

## What is an Agent Skill?

An Agent Skill is a folder containing a `SKILL.md` file with metadata and instructions. An agent can load the skill when a task matches its purpose. This repository keeps skills modular: start with the orchestrator for end-to-end work, or copy a specialist skill for a specific task.

## Skills

| Skill | Purpose |
|---|---|
| `architecture-selector` | Select and document architecture, module boundaries and design patterns |
| `code-review-security` | Review code and assess security, correctness and maintainability |
| `database-engineering` | Design and work with relational, document and cache data systems |
| `dotnet-development` | Build and operate secure C#/.NET and ASP.NET Core applications |
| `electron-development` | Build and test secure cross-platform Electron applications |
| `flutter-development` | Plan, build and ship Flutter applications |
| `go-backend-development` | Design and implement Go APIs, workers and services |
| `laravel-development` | Build secure and maintainable PHP Laravel applications |
| `mern-pern-development` | Build React and Node.js applications with suitable frameworks and data stores |
| `nextjs-development` | Build Next.js apps with advanced caching, routing and secure authentication |
| `project-discovery-research` | Discover requirements, research current technologies and assess feasibility |
| `python-backend-development` | Build Python APIs and backend services with FastAPI, Django or Flask |
| `software-engineering-orchestrator` | Coordinate end-to-end software projects and specialist skills |
| `technical-documentation` | Create accurate project documentation, references and handover materials |
| `technology-stack-selector` | Choose technologies based on project requirements and constraints |
| `testing-quality-assurance` | Plan and perform risk-based software testing and quality checks |

The machine-readable skill list is [`skills.json`](skills.json); the detailed inventory, including shared reference files, is [`skills/skills-inventory.json`](skills/skills-inventory.json).

## Install

### macOS / Linux

```bash
git clone https://github.com/tunnabri-ops/ai-agent-skills.git
cd ai-agent-skills
./install.sh
```

The installer detects supported agent skill directories and copies each skill folder it finds. It backs up an existing same-named folder before replacing it.

```bash
./install.sh --list                         # list available skills
./install.sh --skill software-engineering-orchestrator
./install.sh --skill nextjs-development
./install.sh --skill laravel-development
./install.sh --skill dotnet-development
./install.sh --dry-run                      # preview without changing files
./install.sh --dest ~/.claude/skills        # install into one custom directory
./install.sh --verify                       # verify installed skill copies
./install.sh --uninstall                    # remove copies marked as installed by this pack
```

### Windows (PowerShell)

```powershell
git clone https://github.com/tunnabri-ops/ai-agent-skills.git
cd ai-agent-skills
.\install.ps1
```

To install one skill or preview the operation, use `.\install.ps1 -Skill laravel-development`, `.\install.ps1 -Skill dotnet-development` or `.\install.ps1 -DryRun`. Use `-Dest <directory>` to choose a custom destination.

### Manual

Copy a skill folder such as `skills/software-engineering-orchestrator/` into the skills directory used by your agent. The shared reference files in `skills/references/` are maintained as supporting repository material; the current skills do not require them to be copied for installation.

## Quick start

For end-to-end work, ask your agent to use `software-engineering-orchestrator`. It coordinates the relevant skills as the project moves through discovery, research, architecture, implementation, testing, review, release and documentation.

For focused tasks, request a specialist directly:

```text
Help me compare PostgreSQL and MongoDB for this application.
```

An agent can use `project-discovery-research`, `technology-stack-selector`, and `database-engineering` where appropriate. See [`examples/usage.md`](examples/usage.md) for illustrative workflows.

## Validate

Run the repository checks before submitting changes:

```bash
./scripts/validate-skills.sh
```

The validator checks skill frontmatter, both skill inventories, referenced files, and shell scripts.

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for skill conventions, validation steps and the pull-request process.

## License

[MIT](LICENSE)
