# Contributing

Thanks for helping make these skills better. Keep it simple:

## Adding a skill

1. Create `skills/<skill-name>/SKILL.md` — the name must be kebab-case and match the folder.
2. Frontmatter first, exactly this shape:

   ```yaml
   ---
   name: <skill-name>
   description: Use when ... (3rd person, say WHEN to use it)
   ---
   ```

3. Body must include, in order:
   - **What this skill does** (2–4 lines)
   - **Workflow** — numbered steps the agent follows
   - **Checklist** — what "done" looks like
   - **Examples** — at least one concrete input → output example
   - **Pitfalls** — what to avoid, including safety limits
4. Keep it 80–200 lines. Concrete commands and real examples, not vague advice.
5. Add the skill to `skills.json` and to the table in `README.md`.
6. If the skill ships a helper script, put it under `skills/<name>/scripts/`, make it executable, and test it before submitting.

## Fixing a skill

- Fix the example, not just the prose. If a command is wrong, run the corrected one.
- Keep the description in sync: if the skill now covers a new case, say so in the frontmatter.
- Don't rename a skill in a fix — renames break installed copies.

## Style

- English-first. Code comments in English; Bangla examples only inside `bangla-content` and `bangla-llm-train`.
- No placeholders. If a section can't be completed, leave the skill out of the PR.
- One skill per pull request, so each one can be reviewed on its own.
