# Contributing

Thanks for helping improve these software-engineering skills. Keep changes focused, evidence-based and consistent with the modular layout.

## Before you start

- Check `skills/` and the skill table in `README.md` to avoid adding a duplicate.
- Check open issues and pull requests before starting substantial work.
- Keep each change focused. Explain any change that affects multiple skills or shared references.

## Adding a skill

1. Create `skills/<skill-name>/SKILL.md`. Use a short kebab-case folder name and make it match the `name` in the YAML frontmatter.
2. Include a clear `description` that explains the skill's purpose and when it is useful. Keep the frontmatter valid and put it at the beginning of the file:

   ```yaml
   ---
   name: example-skill
   description: Explain the task this skill supports and when to use it.
   ---
   ```

3. Give the skill actionable guidance: a suitable workflow, checks or completion criteria, concrete examples where useful, and relevant limitations or safety boundaries. Prefer verified commands and current official sources; do not add length without useful content.
4. Add the skill name, description and path to `skills.json`; add its name and purpose to `skills/skills-inventory.json` and the table in `README.md`. Keep the lists alphabetized by skill name.
5. Add shared supporting material under `skills/references/` only when it is useful to more than one skill. Update `skills/skills-inventory.json` to list each reference file.
6. Put helper scripts under the skill's `scripts/` directory. Make shell scripts executable and validate them with their real, safe inputs before submitting.

## Updating a skill

- Check the skill instructions and any related reference files before editing.
- Keep the frontmatter, both inventories and README consistent if the skill's name or purpose changes.
- Do not rename a skill as part of an unrelated fix; installed folder names are part of its public interface.
- Verify changed commands and examples. Do not claim checks passed unless you ran them.

## Validate before submitting

Run the repository validator from the root:

```bash
./scripts/validate-skills.sh
```

For installer changes, also check the list and preview behavior:

```bash
./install.sh --list
./install.sh --dry-run
```

If you install into a temporary directory, verify the installed copies with `./install.sh --dest <directory> --verify` and remove only the temporary directory you created. Run any helper script you changed with safe test inputs. Include the exact commands and results in your pull request.

## Pull request process

1. Create a branch named for the focused change.
2. Explain what changed and why, and report exact validation commands and results.
3. Note anything that could not be verified and any follow-up work.

## What gets rejected

- Unfinished placeholders or unsupported claims.
- Fabricated test results, compatibility claims or source citations.
- Copied content that you do not have permission to contribute.
- Secrets, private URLs or personal data.
- Instructions to bypass access controls, exploit live systems or delete data without authorization.
- Unnecessary scope creep or duplicate skills.

## Code of conduct and license

Be respectful and constructive in issues, reviews and pull requests. By contributing, you agree your contribution is released under the repository's [MIT License](LICENSE).
