<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0D1117&height=240&section=header&text=AI%20AGENT%20SKILLS&fontSize=70&fontColor=00FF9C" width="100%" />

<img src="https://readme-typing-svg.herokuapp.com?font=JetBrains+Mono&weight=700&size=22&duration=2800&pause=900&color=00FF9C&center=true&vCenter=true&width=760&lines=Choose+the+right+stack;Plan+the+whole+SDLC;Build+production+software;Ship+only+what+passes+the+gate" />

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE) [![Skills: 30](https://img.shields.io/badge/Skills-30-blue.svg)](#skills) [![Version: 1.3.1](https://img.shields.io/badge/Version-1.3.1-green.svg)](#skills)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-purple.svg)](#install) [![Codex](https://img.shields.io/badge/Codex-Compatible-green.svg)](#install) [![Cursor](https://img.shields.io/badge/Cursor-Compatible-blue.svg)](#install)

</div>

| **30** | **7** | **7** | **3** | **5** | **MIT** |
|:---:|:---:|:---:|:---:|:---:|:---:|
| SKILLS | STACK SKILLS | SDLC PHASES | HELPER SCRIPTS | EXAMPLE SESSIONS | LICENSE |

# ai-agent-skills

A self-contained bundle of 30 production-ready skills for your AI coding agent — stack and architecture choice, a full 7-phase SDLC, production builds with MERN, PERN, FastAPI, Go, Flutter, Electron.js and NestJS, and a strict quality gate of code review plus testing before anything ships — alongside bug hunting, security audits, agent memory, anti-slop UI design, MCP servers, Bangla LLM training, IPTV stream checks, video downloading, and free deployment. Each skill is a complete, runnable playbook with a workflow, a checklist, real examples, and explicit safety limits, so the agent follows a proven process instead of guessing.

Built by [tunnabri-ops](https://github.com/tunnabri-ops) — software built to production standard, not as demos.

**No API keys. No servers. No subscriptions. Copy the skills into your agent and go.**

> Works with **Claude Code, Codex, Cursor, Gemini CLI, OpenCode**, and any agent that reads `SKILL.md` files.

---

## What is this?

An [Agent Skill](https://code.claude.com/docs/en/skills.md) is a folder with a `SKILL.md` file: a name, a description of *when* to use it, and step-by-step instructions the agent follows. Your agent loads a skill only when the task matches, so a focused skill beats a vague system prompt every time.

Every skill in this repo is:

- **Complete** — workflow, checklist, examples, and pitfalls. No placeholders.
- **Concrete** — commands you can run, outputs you can check, verdicts you can trust.
- **Safe** — explicit limits (never exploit live production, only download content you have rights to, never delete a stream on one failed check).

## Skills

| # | Skill | Use it when… |
|---|-------|--------------|
| 1 | `agent-memory` | Your agent needs to remember decisions and facts across sessions, and retrieve them at session start. |
| 2 | `api-tester` | You want to test a REST API — auth, errors, rate limits, contracts — with a reproducible script. |
| 3 | `app-store-compliance` | You want to pass App Store / Play Store review — rejections, privacy labels, pre-submit checklist. |
| 4 | `bangla-content` | You want natural Bangla writing — grammar, formal vs casual, Banglish ↔ Bangla, headlines and posts. |
| 5 | `bangla-llm-train` | You want to train a small Bangla LLM from scratch in PyTorch — tokenizer, pretrain, SFT, LoRA, eval. |
| 6 | `browser-automation` | You want to automate a browser — Playwright, click/fill/read, screenshots, honest login handling. |
| 7 | `bug-hunter` | You want to hunt security bugs — OWASP Top 10, injection, IDOR, SSRF — and get severity + fix, not just a warning. |
| 8 | `code-reviewer` | You want a thorough code review: correctness, security, performance, readability, with actionable comments. |
| 9 | `deploy-free` | You want to deploy a web app free — Vercel, Cloudflare Pages, GitHub Pages, Netlify, serverless API. |
| 10 | `diagram-design` | You want a clear diagram — Mermaid flowchart, sequence, or ER — that explains instead of confusing. |
| 11 | `docs-writer` | You want great docs — README, guides, API docs, Mermaid diagrams, changelogs that stay in sync. |
| 12 | `electron-app` | You want a production Electron desktop app — secure main/renderer/preload, IPC, auto-updater, packaging. |
| 13 | `fastapi-stack` | You want a production FastAPI backend — Pydantic v2, SQLAlchemy, Alembic, JWT, pytest, Docker. |
| 14 | `flutter-app` | You want a production Flutter app — clean architecture, Riverpod/Bloc, Dio, Play Store build. |
| 15 | `git-worktree` | You want to work on several branches at once, in parallel, without stashing or losing work. |
| 16 | `github-viral` | You want to make a repo go viral — README, topics, demo, release notes, launch checklist. |
| 17 | `go-backend` | You want a production Go backend — Gin/Fiber, layered architecture, PostgreSQL, JWT, graceful shutdown. |
| 18 | `iptv-stream-check` | You want to verify live m3u8 / DASH streams and tell dead vs geo-blocked vs tokenized apart. |
| 19 | `mcp-builder` | You want to build an MCP server from scratch — tools, resources, prompts, stdio vs HTTP. |
| 20 | `mern-stack` | You want a production MERN app — MongoDB, Express, React, Node.js, JWT auth, deployment. |
| 21 | `nestjs-backend` | You want a production NestJS backend — modules, guards, JWT + RBAC, Swagger, Jest, Docker. |
| 22 | `pern-stack` | You want a production PERN app — PostgreSQL + Prisma, Express, React, migrations, transactions. |
| 23 | `quality-gate` | Your code must pass a final review + testing gate before delivery — with a PASS/FAIL verdict. |
| 24 | `sdlc-planner` | You want a full project plan — research, requirements, design, testing, deployment, maintenance. |
| 25 | `security-audit` | You want a full security audit: threat model, secrets, headers, auth, dependencies, with a findings report. |
| 26 | `stack-architect` | You want to choose the right stack and architecture — decision matrix, trade-offs, `STACK_DECISION.md`. |
| 27 | `test-writer` | You want real tests — unit, integration, e2e — with edge cases, mocks, and TDD flow (Python + JS/TS). |
| 28 | `ui-design` | Your interface looks AI-generated and needs real typography, spacing, color, content, and accessibility. |
| 29 | `video-downloader` | You want to download videos correctly — yt-dlp, HLS/m3u8 + ffmpeg, resume, quality picker. |
| 30 | `web-research` | You want deep web research with verification — primary sources, cross-checks, real citations. |

## What's new in v1.3.1

- **Community files** — `SECURITY.md` (how to report a vulnerability), `CODE_OF_CONDUCT.md`, bug-report and new-skill issue templates, and a pull-request template, so the repo's community profile is complete.

## What's new in v1.3.0

- **BugHunter-style README** — dark hero banner, big-numbers row, and a one-paragraph description up front, with the full 30-skill table and install instructions kept intact below it.
- **Expanded CONTRIBUTING** — step-by-step rules for adding a skill, updating one, running the validator, PR process, commit style, and what gets rejected.

## Release history

- **v1.2.0** — the professional coding pack: `stack-architect`, `sdlc-planner`, seven stack skills (MERN, PERN, FastAPI, Go, Flutter, Electron.js, NestJS), and `quality-gate` with a PASS/FAIL verdict and `QUALITY_REPORT.md`.
- **v1.1.0** — `agent-memory`, `ui-design`, `diagram-design`, `mcp-builder`, `git-worktree`, `browser-automation`, `app-store-compliance`, `deploy-free`; `install.sh` gained `--verify` and `--uninstall`, Gemini CLI detection, and backups; `scripts/validate-skills.sh` added.

## Install

### One command (macOS / Linux)

```bash
git clone https://github.com/tunnabri-ops/ai-agent-skills.git
cd ai-agent-skills
./install.sh
```

`install.sh` detects Claude Code (`~/.claude/skills`), Codex (`~/.codex/skills`), Cursor (`~/.cursor/skills`), Gemini CLI (`~/.gemini/skills`), and OpenCode, and copies the skills into each one it finds. Existing folders with the same name are backed up to `<name>.bak` first.

```bash
./install.sh --list            # show the 30 skills without installing
./install.sh --skill bug-hunter # install one skill only
./install.sh --dry-run          # show what would happen, change nothing
./install.sh --verify           # check installed skills are valid, per agent dir
./install.sh --uninstall        # remove only the skills this pack installed
```

Validate the repo itself before a release: `./scripts/validate-skills.sh` — checks frontmatter, skills.json match, `bash -n`, and no placeholders.

### Windows (PowerShell)

```powershell
git clone https://github.com/tunnabri-ops/ai-agent-skills.git
cd ai-agent-skills
.\install.ps1
```

### Manual (any agent)

Copy any `skills/<name>/` folder into your agent's skills directory — `cp -r skills/bug-hunter ~/.claude/skills/` — that's it. No build step, no config file.

## Quick start

Once installed, just describe the task in plain words — the agent picks the skill:

```
You: "Review this login route for security bugs."
Agent: [loads bug-hunter] → triages findings by severity, with a proof-of-concept and a fix for each one.

You: "Check whether these 40 m3u8 links are still live."
Agent: [loads iptv-stream-check] → runs the checker script, reports LIVE / DEAD / NEEDS-DEVICE-CHECK per link.

You: "I need an e-commerce API. Research it, choose the stack, plan it, build it."
Agent: [loads web-research → stack-architect → sdlc-planner → pern-stack → quality-gate] → writes STACK_DECISION.md and PROJECT_PLAN.md, builds it, then PASS/FAIL in QUALITY_REPORT.md.
```

See [`examples/usage.md`](examples/usage.md) for five full example sessions.

## How a skill is structured

```
skills/bug-hunter/
└── SKILL.md        # frontmatter (name + when to use) + instructions

skills/iptv-stream-check/
├── SKILL.md
└── scripts/check-stream.sh    # curl-based LIVE/DEAD/UNKNOWN checker
```

Some skills also ship a helper script, e.g. `skills/api-tester/scripts/api-smoke.sh` (smoke-test a REST API base URL).

## Contributing

Found a gap, a wrong example, or a skill worth adding? See [CONTRIBUTING.md](CONTRIBUTING.md). New skills need the same shape: frontmatter with a `Use when…` description, workflow steps, checklist, examples, and pitfalls — and every claim must be runnable, not aspirational.

## License

[MIT](LICENSE) © 2026 tunnabri-ops
