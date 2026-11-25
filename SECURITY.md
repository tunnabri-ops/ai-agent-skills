# Security Policy

## Supported versions

| Version | Supported |
| ------- | --------- |
| 1.3.x   | Yes       |
| < 1.3.0 | No — please upgrade to the latest release |

Security fixes are made on the latest release only.

## Reporting a vulnerability

**Do not open a public issue for a security vulnerability.**

Instead, report it privately:

1. Open a [private vulnerability report](https://github.com/tunnabri-ops/ai-agent-skills/security/advisories/new) on this repo (GitHub Security Advisories), **or**
2. Open an issue titled "Security report — please contact me" with no details, and a maintainer will reach out for a private channel.

Include in your report:

- What the problem is and where it lives (skill name, file, line if you have it)
- Steps to reproduce, or a minimal proof of concept
- What you think the impact is (for example: a skill telling the agent to run an unsafe command, leak a secret, or bypass a login)
- Whether the issue is already public anywhere

## What happens next

- We acknowledge your report within **7 days**.
- We confirm the issue, fix it, and release a patched version.
- We credit you in the release notes, unless you ask to stay anonymous.
- Please give us a reasonable time to fix the issue before disclosing it publicly — **90 days** is the default.

## What NOT to do

- Do not exploit the vulnerability against real users, repos, or production systems.
- Do not run a skill's unsafe instruction to "prove" it on someone else's machine or account.
- Do not publish the vulnerability before a fix is released.

## Scope

This policy covers this repo only: the skills, helper scripts, installer, and documentation in `tunnabri-ops/ai-agent-skills`. It does not cover GitHub itself, Claude Code, Codex, Cursor, or any third-party service a skill talks to — report those to their own vendors.

## A note on skills and safety

Skills in this repo are instructions for AI coding agents. A skill must never tell an agent to bypass logins, CAPTCHAs, or paywalls, exploit live systems, exfiltrate secrets, or delete data the user did not ask to delete. If you find a skill that does, that is a security issue — report it as above.
