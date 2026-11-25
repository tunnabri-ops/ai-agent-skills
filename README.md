# AI Agent Skills

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Skills: 20](https://img.shields.io/badge/Skills-20-blue.svg)](#skills)
[![Version: 1.1.0](https://img.shields.io/badge/Version-1.1.0-green.svg)](#skills)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-purple.svg)](#install)
[![Codex](https://img.shields.io/badge/Codex-Compatible-green.svg)](#install)

**20 production-ready skills for your AI coding agent.** Bug hunting, security audits, test writing, Bangla LLM training, stream checking, video downloading, agent memory, anti-slop UI design, MCP servers, free deployment, and making your own repos go viral — each one a complete, self-contained playbook your agent can follow without guessing.

No API keys. No servers. No subscriptions. Copy the skills into your agent and go.

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
| 12 | `git-worktree` | You want to work on several branches at once, in parallel, without stashing or losing work. |
| 13 | `github-viral` | You want to make a repo go viral — README, topics, demo, release notes, launch checklist. |
| 14 | `iptv-stream-check` | You want to verify live m3u8 / DASH streams and tell dead vs geo-blocked vs tokenized apart. |
| 15 | `mcp-builder` | You want to build an MCP server from scratch — tools, resources, prompts, stdio vs HTTP. |
| 16 | `security-audit` | You want a full security audit: threat model, secrets, headers, auth, dependencies, with a findings report. |
| 17 | `test-writer` | You want real tests — unit, integration, e2e — with edge cases, mocks, and TDD flow (Python + JS/TS). |
| 18 | `ui-design` | Your interface looks AI-generated and needs real typography, spacing, color, content, and accessibility. |
| 19 | `video-downloader` | You want to download videos correctly — yt-dlp, HLS/m3u8 + ffmpeg, resume, quality picker. |
| 20 | `web-research` | You want deep web research with verification — primary sources, cross-checks, real citations. |

## What's new in v1.1.0

- **8 new skills:** `agent-memory`, `ui-design`, `diagram-design`, `mcp-builder`, `git-worktree`, `browser-automation`, `app-store-compliance`, `deploy-free` — 12 → 20 skills.
- **`install.sh` now has `--verify` and `--uninstall`**, detects Gemini CLI (`~/.gemini/skills`), backs up any existing skill folder to `<name>.bak` before overwriting, and prints a summary.
- **New validator:** `scripts/validate-skills.sh` checks every skill's frontmatter, that `skills.json` matches the folders exactly, that every helper script passes `bash -n`, and that no placeholder text slipped in. Run it before every release.

## Install

### One command (macOS / Linux)

```bash
git clone https://github.com/tunnabri-ops/ai-agent-skills.git
cd ai-agent-skills
./install.sh
```

`install.sh` detects Claude Code (`~/.claude/skills`), Codex (`~/.codex/skills`), Cursor (`~/.cursor/skills`), Gemini CLI (`~/.gemini/skills`), and OpenCode, and copies the skills into each one it finds. Existing folders with the same name are backed up to `<name>.bak` first.

```bash
./install.sh --list            # show the 20 skills without installing
./install.sh --skill bug-hunter # install one skill only
./install.sh --dry-run          # show what would happen, change nothing
./install.sh --verify           # check installed skills are valid, per agent dir
./install.sh --uninstall        # remove only the skills this pack installed
```

Validate the repo itself before a release:

```bash
./scripts/validate-skills.sh   # frontmatter, skills.json match, bash -n, no placeholders
```

### Windows (PowerShell)

```powershell
git clone https://github.com/tunnabri-ops/ai-agent-skills.git
cd ai-agent-skills
.\install.ps1
```

### Manual (any agent)

Copy any `skills/<name>/` folder into your agent's skills directory, e.g.:

```bash
cp -r skills/bug-hunter ~/.claude/skills/
```

That's it. No build step, no config file.

## Quick start

Once installed, just describe the task in plain words — the agent picks the skill:

```
You: "Review this login route for security bugs."
Agent: [loads bug-hunter] → triages findings by severity,
        gives a proof-of-concept and a fix for each one.

You: "Check whether these 40 m3u8 links are still live."
Agent: [loads iptv-stream-check] → runs the checker script,
        reports LIVE / DEAD / NEEDS-DEVICE-CHECK per link.

You: "Write a launch post for my new repo."
Agent: [loads github-viral] → follows the pre-publish checklist,
        then drafts the post from the template.
```

See [`examples/usage.md`](examples/usage.md) for three full example sessions.

## How a skill is structured

```
skills/bug-hunter/
└── SKILL.md        # frontmatter (name + when to use) + instructions
```

Some skills ship a helper script next to the instructions:

```
skills/iptv-stream-check/
├── SKILL.md
└── scripts/check-stream.sh    # curl-based LIVE/DEAD/UNKNOWN checker

skills/api-tester/
├── SKILL.md
└── scripts/api-smoke.sh       # smoke-test a REST API base URL
```

## Contributing

Found a gap, a wrong example, or a skill worth adding? See [CONTRIBUTING.md](CONTRIBUTING.md). New skills need the same shape: frontmatter with a `Use when…` description, workflow steps, checklist, examples, and pitfalls — and every claim must be runnable, not aspirational.

## License

[MIT](LICENSE) © 2026 tunnabri-ops
