# Contributing

Thanks for helping make these skills better. This repo holds up a high bar on purpose: people install these skills into their coding agents and trust them on real projects. A skill that is vague, untested, or copied from somewhere else does more harm than no skill at all. Read this guide before opening a pull request.

## Before you start

- **Check the skill list first.** Open `skills/` and the table in `README.md`. If a skill already covers your idea, improve that skill instead of adding a near-duplicate.
- **Check open issues and pull requests** so two people do not build the same skill.
- **One change per pull request.** One new skill, or one fix to one skill. A PR that touches five skills is hard to review and will be asked to split.

## Adding a new skill

1. **Create the folder** `skills/<skill-name>/` — the name must be kebab-case, short, and descriptive (for example `stack-architect`, not `my-cool-helper-v2`). The folder name and the skill name must match exactly.
2. **Write `skills/<skill-name>/SKILL.md`** with YAML frontmatter first, exactly this shape:

   ```yaml
   ---
   name: <skill-name>
   description: Use when ... (3rd person, say WHEN to use it)
   ---
   ```

   The description is how the agent decides to load the skill, so make it specific: name the task, the tools, and the situation. A description like "Use when you need help" is too vague and will be rejected.
3. **Body, in this order:**
   - **What this skill does** (2–4 lines, plain English)
   - **Workflow** — numbered steps the agent follows, in the order it should do them
   - **Checklist** — what "done" looks like, so the agent can verify its own work
   - **Examples** — at least one concrete input → output example with real commands, file names, and expected results
   - **Pitfalls** — what to avoid, including safety limits (never exploit live production, never store secrets, never download content without rights)
4. **Length: 150–200 lines.** Concrete commands and real examples, not vague advice. If you cannot fill 150 lines with real, tested content, the skill is not ready yet — keep it out of the PR.
5. **English only.** All prose and code comments in English. The only exceptions are the two Bangla skills (`bangla-content`, `bangla-llm-train`), where Bangla examples are the point.
6. **Add the skill to `skills.json`** (name, description, path) and to the **table in `README.md`**, keeping both in alphabetical order by skill name.
7. **Helper scripts, if any,** go under `skills/<name>/scripts/`, must be executable (`chmod +x`), and must be tested before submitting. A script that has never been run will be rejected. Keep scripts small and dependency-free where possible (bash + curl, or plain Python).
8. **Update `examples/usage.md`** only if your skill changes how a documented example session works. Do not add a new example session for every skill.

## Updating an existing skill

- **Fix the example, not just the prose.** If a command is wrong, run the corrected command yourself before submitting.
- **Keep the description in sync.** If the skill now covers a new case, say so in the frontmatter description.
- **Do not rename a skill in a fix.** Renames break installed copies and the `skills.json` manifest — a rename is a separate, discussed change, never a drive-by.
- **Do not shrink a skill to make it "simpler".** If a section is out of date, rewrite it with current, correct content.

## Validate before you submit

Run these two checks from the repo root. Both must pass, with zero failures, before a PR is opened:

```bash
./scripts/validate-skills.sh   # frontmatter, skills.json match, bash -n, no placeholders
./install.sh --dest /tmp/skill-check --verify   # install all skills to a temp dir and verify them
```

If the validator fails, fix the cause — do not weaken the validator to make it pass. Also run any helper script your change touches with a real input (for example, run `check-stream.sh` against a real m3u8 URL and `api-smoke.sh` against a real API base URL) and paste the output in the PR description.

## Pull request process

1. Fork the repo, create a branch named after the change (`skill/<name>` for a new skill, `fix/<name>` for a fix).
2. Make the change, run the checks above, and commit with a clear message:
   - `skill: add <name> — one-line summary`
   - `fix: <skill-name> — what was wrong and what changed`
   - `docs: <what changed>`
3. Open the PR with a short description: what the skill does, how you tested it (commands run, outputs seen), and anything you could not verify. A PR that says "tested" without showing how will be asked for evidence.
4. Expect review comments on accuracy, not just style. A claim the reviewer cannot reproduce will be removed or the PR will be held until it can be reproduced.

## What gets rejected

- **Placeholders** — unfinished markers, "coming soon", or sections that say "add examples here".
- **Fake claims** — star counts, download counts, benchmark numbers, or "works with X" that you have not verified yourself.
- **Copied content** — skills must be written in your own words. Do not copy another repo's skill text, README, or branding, and do not copy content from a closed-source product.
- **Secrets** — API keys, tokens, passwords, or private URLs. If an example needs a key, use an obvious placeholder such as `YOUR_API_KEY` and say where the user gets a real one.
- **Unsafe instructions** — bypassing logins, CAPTCHAs, paywalls, or license checks; exploiting live systems; deleting data the user did not ask to delete.
- **Scope creep** — a skill that tries to do everything. A focused skill that does one job well beats a broad one that does five jobs badly.

## After your PR is merged

The skill ships in the next release, and the README table, `skills.json`, and version badge are updated together. If your skill is the first of a new category, say so in the PR — the README's "What's new" section should mention it by name.

## Code of conduct

Be respectful in issues, reviews, and pull requests. Disagree about the work, not about the person. No harassment, no insults, no spam, no self-promotion unrelated to the skill being discussed. Maintainers may close or hide comments that cross that line, and repeat behaviour leads to a ban from the repo.

## License

By contributing, you agree your contribution is released under the same [MIT License](LICENSE) as the rest of this repo.
