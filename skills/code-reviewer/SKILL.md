---
name: code-reviewer
description: Use when reviewing a pull request, diff, or codebase for correctness, security, performance, and readability, and when actionable review comments with severity labels and concrete fixes are needed.
---

# Code Reviewer

Review code the way a careful senior engineer would: verify it does what it
claims, catch real defects, and leave comments the author can act on
without guessing. Be thorough on logic and security, restrained on style.

## Review Workflow

1. Read the change description first. Understand the intent before judging
   the implementation. If the intent is unclear, say so and ask one
   specific question.
2. Read the full diff, not only the changed lines. Check callers, tests,
   migrations, configuration, and documentation touched by the change.
3. Run the tests mentally, then check the real ones. Note missing tests for
   new branches, error paths, and edge cases.
4. Trace the happy path and the failure path. What happens on invalid
   input, empty input, a failed network call, a timeout, or a null?
5. Check security and data handling. Follow untrusted input to its sink
   and confirm ownership checks, validation, and encoding are present.
6. Check performance for the hot path. Look for N+1 queries, unbounded
   loops, repeated work inside loops, and large allocations.
7. Write comments that are actionable. Each comment names the location,
   the problem, the impact, and a suggested fix or a concrete question.
8. Give a verdict: Approve, Request Changes, or Comment. Request Changes
   only for correctness, security, data-loss, or breaking-change issues.

## Review Checklist

### Correctness

- Does the code do what the description and tests claim?
- Are edge cases handled: empty lists, nulls, zero, negative numbers,
  duplicate keys, concurrent writes, time zones, and daylight saving?
- Are off-by-one errors possible in loops, slices, pagination, and ranges?
- Are errors handled or silently swallowed? Is a failed call retried
  safely, and is the retry idempotent?
- Are migrations reversible and safe on existing data? Does a rename or
  column drop break old clients?

### Security

- Is authorization enforced server-side on every endpoint and mutation?
- Is user input validated and encoded for its sink (SQL, HTML, shell,
  file path, redirect)?
- Are secrets, tokens, or passwords hard-coded, logged, or returned in
  responses or error messages?
- Are dependencies pinned and free of known vulnerabilities?
- Are file uploads checked for type, size, and path traversal?

### Performance

- Is there an N+1 query, a query inside a loop, or a full-table scan on a
  growing table? Is the needed index present?
- Is work repeated inside a loop that could be hoisted or batched?
- Are large payloads paginated, streamed, or limited? Is there a cap on
  page size, upload size, and result count?
- Is caching used correctly, with invalidation on write? Is a cache key
  scoped per user where it must be?

### Readability and Maintainability

- Are names honest about what a function or variable holds?
- Is a function doing one thing, or three things that should be split?
- Is duplicated logic extracted instead of copied with small changes?
- Is the public API backwards compatible, or is the breaking change
  documented and versioned?
- Are comments explaining why, not restating what the code already says?

## Severity Labels

| Label | When to use it |
|-------|----------------|
| Blocking | Wrong behaviour, data loss, security hole, or breaking change. Must fix before merge. |
| Major | Real defect or risk that is likely to cause a bug in production. Should fix before merge. |
| Minor | Small correctness or clarity issue. Fix now if it is a one-line change. |
| Nit | Style or wording preference. Only mention if it aids readability. |
| Question | Genuine uncertainty, not a disguised demand. The author may answer and resolve it. |

Use Blocking sparingly. If everything is Blocking, nothing is.

## How to Write Actionable Comments

Good comment format:

```text
[Blocking] `getOrder` returns another user's order.

In `orders.ts:42`, the query filters by `id` only. A caller can pass any
order ID and read another user's address and items.

Suggested fix: scope the query to the current user:
`db.orders.find({ id, userId: ctx.user.id })` and return 404 on miss.
Add a test where user A requests user B's order ID.
```

Rules for comments:

- Quote the exact line or symbol, so the author finds it without hunting.
- Explain the impact in one sentence: what breaks, leaks, or slows down.
- Offer a concrete fix, a code snippet, or a precise question.
- Prefer one comment per issue. Do not repeat the same point on ten lines;
  make one comment and list the other locations.
- Praise a genuinely good solution in one line when you see it; it tells
  the author what to keep doing.

## What NOT to Nitpick

- Personal style preferences when the project has no rule for them.
- Renaming a clear variable to a different clear name.
- Reformatting code the project's formatter already accepts.
- Demanding a design pattern where a simple function is sufficient.
- Rewriting working code to match your taste without a defect to fix.
- Commenting on lines the change did not touch, unless they are broken by
  this change.
- Asking for tests of trivial getters, or for documentation of obvious code.

## Verdict Guide

- Approve: no Blocking or Major issues. Minor issues may be left as
  follow-ups the author can address after merge.
- Request Changes: at least one Blocking issue, or several Major issues
  that together make the change unsafe to merge.
- Comment: questions or Minor issues only, with no merge blocker.

## Pitfalls

- Do not approve a change you did not read. Skimming the description and
  the test names is not a review.
- Do not invent a bug. If you are unsure whether a path is reachable,
  mark it as a Question and name the caller you checked.
- Do not review in a vacuum: check the project's existing patterns first
  and prefer consistency with them over your own preference.
- Do not leave a vague comment such as "this looks wrong" without saying
  what is wrong and what would be right.
- Do not block on a hypothetical future requirement; review the change in
  front of you.
