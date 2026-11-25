---
name: quality-gate
description: Use when code must be reviewed and tested before delivery, when running a final quality gate, pre-release check, or acceptance review, or when deciding whether a change is safe to ship.
---

# Quality Gate

Nothing ships with known failing tests, skipped checks, or unreviewed code. This skill is the final
gate before delivery. It runs after the feature is built and before the user is told it is done. If
the gate fails, fix the problems and run the gate again from the top. A gate that is waived is not a
gate; it is a wish. Load the code-reviewer skill first for the review pass, and load the test-writer
skill first for the testing pass. This skill coordinates both and records the verdict. It does not
replace either of them.

## Gate Rule

- PASS means every check below passed, or was explicitly marked not applicable with a reason. A check that was skipped for convenience is a FAIL.
- FAIL means at least one Blocking finding, one failing test, one skipped required check, or one unreviewed file in the delivery.
- On FAIL: fix, re-test, re-review, and re-run the whole gate. Do not ship the parts that passed and hide the parts that failed.
- On PASS: write `QUALITY_REPORT.md`, state the verdict, and only then tell the user the work is delivered.

## Step 1 — Load the Review and Test Skills

1. Load the code-reviewer skill. Run its full review workflow on
every file in the delivery, not only the files that look risky.
2. Load the test-writer skill. Run its test patterns for every new
behaviour and every fixed bug in the delivery.
3. Load the security-audit skill when the change touches auth,
payments, file uploads, or user data of any kind.
4. Record which skills were loaded, and which files each one covered,
in the quality report. A file covered by no skill is unreviewed.

## Step 2 — Code Review Checklist

Run the code-reviewer checklist in full. These are the gate items; each one must pass or be marked
not applicable with a reason.

### Correctness

- [ ] The code does what the task, the user story, and the tests say.
- [ ] Every acceptance criterion from the plan has a visible result.
- [ ] Edge cases are handled: empty input, null, zero, duplicates, concurrent calls, time zones, and large input.
- [ ] No off-by-one error in loops, pagination, slices, or ranges.
- [ ] Errors are handled, not swallowed. A failed call logs enough context to reproduce it, and retries are idempotent where used.
- [ ] Migrations are reversible and safe on existing production data.

### Security — OWASP

- [ ] Authorisation is enforced server-side on every endpoint and mutation. A client-side check alone is not authorisation.
- [ ] All untrusted input is validated and encoded for its sink: SQL, HTML, shell, file path, and redirect.
- [ ] No SQL injection, cross-site scripting, or path traversal path is open. Parameterised queries and safe output encoding are used.
- [ ] No secrets, tokens, passwords, or API keys are hard-coded, logged, committed, or returned in responses or error messages.
- [ ] File uploads are checked for type, size, and content, and are stored outside the web root where the framework requires it.
- [ ] Dependencies are pinned and checked for known vulnerabilities with `npm audit`, `pip-audit`, or the project equivalent.
- [ ] Sessions expire, passwords are hashed with a modern algorithm, and sensitive actions require re-authentication where required.

### Performance

- [ ] No N+1 query, no query inside a loop, and no unbounded list.
- [ ] Large payloads are paginated, streamed, or capped. Page size, upload size, and result count all have limits.
- [ ] The hot path has no repeated work that could be hoisted or batched, and no synchronous network call that blocks a request.
- [ ] Caching, where used, invalidates on write and is scoped per user where the data is private.

### Error handling, readability, and cleanliness

- [ ] Every external call has a timeout, a failure path, and a user-facing message that does not leak internals or a stack trace.
- [ ] Logs contain no secrets, no passwords, and no full tokens.
- [ ] Names are honest. Functions do one thing. Duplicated logic is extracted, not copied with small changes.
- [ ] No dead code, no commented-out code blocks, and no unused imports, variables, or dependencies in the delivery.
- [ ] No debug prints, no console logging left in production paths, and no temporary files committed.
- [ ] No fake, mock, or placeholder implementation in a production path. A demo stub, a hard-coded response, or a function that returns a fixed value instead of doing the work is a FAIL.
- [ ] Comments explain why, not what. Public functions and API endpoints describe their inputs and outputs.

## Step 3 — Testing Gate

Run the test-writer workflow. These targets are the minimum; a critical path such as auth or
payments needs more, never less.

### Coverage targets

| Area | Target |
|---|---|
| New code, overall | 80% lines or higher |
| Payment, auth, validation logic | 90% branches or higher |
| Critical user journeys, end to end | Every Must story covered |
| Bug fixes | One regression test per fix, failing before the fix |

### Required test types

- [ ] Unit tests pass: `pytest -q` or `npx vitest run`, clean run.
- [ ] Integration tests pass against a real database or test server.
- [ ] End-to-end tests pass for the critical journeys, or the reason they cannot run is recorded and the manual smoke test covers them.
- [ ] Edge cases are tested: empty, invalid, duplicate, boundary, and error-path inputs for every new input handler.
- [ ] No test depends on order, wall-clock time, randomness, or the live network. Flaky tests are fixed or removed, never ignored.

### Manual smoke-test script

Run this by hand on the real built app, and record each line as pass or fail. Do not claim a smoke
test passed without running it.

```text
Smoke test — <project name> — <date>
[ ] App starts from a clean checkout with the documented commands.
[ ] Sign up, sign in, and sign out work with valid credentials.
[ ] Wrong password shows a clear error and does not sign the user in.
[ ] The main feature works end to end on the happy path.
[ ] The main feature shows a clear error on invalid input.
[ ] Data survives a restart: create, reload, and confirm it is there.
[ ] Mobile layout: no horizontal scroll, no clipped button, no
    overlapping text at 360 pixels wide.
[ ] No console errors and no failed network requests on the main flow.
[ ] The app works after a hard refresh, with an empty cache.
```

## Step 4 — Delivery Checklist

- [ ] The build passes from a clean checkout, with no manual fix.
- [ ] Lint and format pass with the project configuration.
- [ ] No secret was added to the repository. Search for keys, tokens, and passwords in the diff before delivery.
- [ ] Documentation is updated: README, setup steps, and any changed API or configuration. A feature with no docs is unfinished.
- [ ] The changelog, where the project keeps one, lists the change.
- [ ] Every file in the delivery was reviewed by the code-reviewer skill, and every review comment is resolved.
- [ ] The test suite was run after the last code change. A test run from before the last change does not count.

## Step 5 — Write QUALITY_REPORT.md

Write this file in the project root, or next to the delivery, before telling the user the work is
done. Use this exact structure.

```markdown
# Quality Report — <project or feature name>

## Verdict: PASS / FAIL
- Date: <date>
- Reviewer skills loaded: code-reviewer, test-writer
- Scope: <files and features reviewed>

## Findings
| # | Severity | Location | Issue | Fix applied |
|---|---|---|---|---|
| 1 | Blocking / Major / Minor | <file:line> | <issue> | <fix or "open"> |

## Test results
- Unit: <passed / total> — command: <command>
- Integration: <passed / total> — command: <command>
- End to end: <passed / total> — command: <command>
- Coverage: <percentage, and the tool used>
- Smoke test: <passed / total items, with the script above>

## Checks skipped
- <check> — reason: <why it does not apply>

## Verdict rationale
- <one paragraph: why this is a PASS or a FAIL>
```

Severity means: Blocking stops the release, Major must be fixed before merge, Minor should be fixed
now if it is a small change. A report with zero findings and zero test failures is expected only for
a trivial change; if a large change has zero findings, re-check that the review actually ran, and
say so in the report.

## Rules

- If the gate fails, fix and re-run. Nothing ships with known failing tests, skipped checks, or unreviewed code.
- Never mark a check passed that was not run. "Probably fine" is a FAIL until the check has run and its output is recorded.
- Never ship a placeholder, a hard-coded demo response, or a mock in a production path and call it done.
- Never approve your own unreviewed code. The gate is a second pair of eyes, even when that pair is a skill.
- Never hide a failing test by deleting it, skipping it, or lowering the target. Fix the code, or fix the test with a written reason and a new test that proves the behaviour.

## Pitfalls

- Running the tests before the last change and calling it a pass.
- Reviewing only the new files and missing a change in shared code.
- Treating coverage as proof: 100% coverage with weak assertions proves nothing. Read the assertions.
- Approving a change with a secret in it because the code works.
- A smoke test that was planned but never run on the real app.
- A quality report written after telling the user it is done.
