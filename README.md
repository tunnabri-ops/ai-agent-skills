# AI Agent Skills

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Skills: 12](https://img.shields.io/badge/Skills-12-blue.svg)](#skills)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-purple.svg)](#install)
[![Codex](https://img.shields.io/badge/Codex-Compatible-green.svg)](#install)

**12 production-ready skills for your AI coding agent.** Bug hunting, security audits, test writing, Bangla LLM training, stream checking, video downloading, and making your own repos go viral — each one a complete, self-contained playbook your agent can follow without guessing.

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
| 1 | `bug-hunter` | You want to hunt security bugs — OWASP Top 10, injection, IDOR, SSRF — and get severity + fix, not just a warning. |
| 2 | `code-reviewer` | You want a thorough code review: correctness, security, performance, readability, with actionable comments. |
| 3 | `security-audit` | You want a full security audit: threat model, secrets, headers, auth, dependencies, with a findings report. |
| 4 | `test-writer` | You want real tests — unit, integration, e2e — with edge cases, mocks, and TDD flow (Python + JS/TS). |
| 5 | `iptv-stream-check` | You want to verify live m3u8 / DASH streams and tell dead vs geo-blocked vs tokenized apart. |
| 6 | `bangla-content` | You want natural Bangla writing — grammar, formal vs casual, Banglish ↔ Bangla, headlines and posts. |
| 7 | `bangla-llm-train` | You want to train a small Bangla LLM from scratch in PyTorch — tokenizer, pretrain, SFT, LoRA, eval. |
| 8 | `video-downloader` | You want to download videos correctly — yt-dlp, HLS/m3u8 + ffmpeg, resume, quality picker. |
| 9 | `github-viral` | You want to make a repo go viral — README, topics, demo, release notes, launch checklist. |
| 10 | `web-research` | You want deep web research with verification — primary sources, cross-checks, real citations. |
| 11 | `api-tester` | You want to test a REST API — auth, errors, rate limits, contracts — with a reproducible script. |
| 12 | `docs-writer` | You want great docs — README, guides, API docs, Mermaid diagrams, changelogs that stay in sync. |

## Install

### One command (macOS / Linux)

```bash
git clone https://github.com/tunnabri-ops/ai-agent-skills.git
cd ai-agent-skills
./install.sh
```

`install.sh` detects Claude Code (`~/.claude/skills`), Codex (`~/.codex/skills`), Cursor (`~/.cursor/skills`), and OpenCode, and copies the skills into each one it finds.

```bash
./install.sh --list            # show the 12 skills without installing
./install.sh --skill bug-hunter # install one skill only
./install.sh --dry-run          # show what would happen, change nothing
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
