---
name: agent-memory
description: Use when an agent needs persistent memory across sessions, including capturing decisions and facts, compressing long notes, indexing and retrieving relevant memory at session start, deciding what to remember versus forget, and keeping a MEMORY.md file private and free of secrets.
---

# Agent Memory

Keep what matters across sessions, forget the rest, and never store a
secret. Memory is a plain-text file the agent reads at session start and
updates at session end — not a database, not a log dump, not a place for
credentials. A good memory file lets a fresh session pick up exactly
where the last one stopped, without re-reading the whole history.

## File Layout

One project keeps one memory file at the project root, plus dated notes
only when the detail is worth keeping:

```text
project/
  MEMORY.md            # curated, current facts (the file that matters)
  memory/
    2026-11-25.md      # raw daily notes, optional
    2026-11-24.md
```

Rules for the layout:

- `MEMORY.md` is the single source of truth. Dated notes are evidence,
  not a second copy of the truth.
- Keep `MEMORY.md` under 200 lines. If it grows past that, compress it (see Workflow step 5).
- One fact in one place. If a fact moves, update it in place; do not add a second entry that contradicts the first.
- Every dated entry carries its date in `YYYY-MM-DD` form, so a later
  session can tell fresh facts from stale ones.
- Never commit memory files with personal data to a public repo unless
  the user explicitly asked for it.

## What to Remember vs Forget

Remember:

- Decisions and the reason behind them: "chose Cloudflare Pages
  because free hosting, no VPS" — the reason matters more than the choice.
- Durable facts: names, accounts, project URLs, repo names, domains,
  preferences, standing instructions.
- Commitments and pending work: what was promised, what is blocked, and
  what the user still needs to decide.
- Mistakes and the lesson: "mono.ts links fail sandbox checks but play
  on the user's device — never remove them" is worth more than the fix.
- Corrections the user made: record the correction, not the error.

Forget:

- One-off chatter, greetings, and intermediate reasoning that led nowhere.
- Exact tool outputs, long logs, and full transcripts — keep the
  conclusion, drop the raw text.
- Facts that were superseded: delete the old version instead of keeping both.
- Anything time-sensitive once it expires: a one-time code, a meeting time from last week, a workaround that is no longer needed.

## Privacy: Never Store Secrets

Never write any of these into memory, notes, or any file:

- Passwords, API keys, tokens, session cookies, private keys.
- One-time codes, recovery codes, or password-reset links.
- Card numbers, bank account numbers, government ID numbers.
- Full addresses or phone numbers, unless the user explicitly asked
  that one be kept (for example, a business contact number).
- Raw credentials copied from a chat message, screenshot, or email.

If a secret appears in a session, record only that it exists and where
it lives, never the value: "GitHub token stored in the secure vault" —
not the token itself. If you find a secret already in a memory file,
delete the value immediately, rotate the secret if it was shared, and
note the deletion with the date.

## Workflow

1. Start the session by reading `MEMORY.md` first, before doing any other work.
   If the file does not exist, create an empty one with the headings below and note that it is new.
2. Retrieve the relevant slice. Scan the whole file, then pull out only
   the facts that bear on the current task: the project, the people, the
   pending items, and any standing instructions. Work from the shortlist;
   do not paste the whole file into your reasoning.
3. Work, and note new facts as you go in a scratch list, not in the
   file yet. A fact earns a note when it would change what a future
   session does: a decision, a correction, a commitment, a lesson.
4. Before ending the session, write the notes into `MEMORY.md`. Put
   each fact under the right heading, dated, in one or two sentences.
   Delete or update any entry the new facts contradict.
5. Compress when the file grows. Every 10 sessions, or when the file
   passes 200 lines, rewrite it: merge duplicates, delete expired
   items, turn long stories into one-line lessons, and move raw detail
   into a dated note under `memory/`.
6. Index for retrieval. Keep a short keyword line at the top of each
   dated note (for example, `Keywords: deploy, vercel, 403`) so a
   later search finds it without reading every file. Search with
   `grep -ri` over the memory directory, not from memory alone.

## Session-Start Retrieval Routine

Run this at the start of every session, in order:

```bash
# 1. Read the curated memory file
cat MEMORY.md

# 2. Search dated notes for keywords from the current task
grep -ri "deploy" memory/ | head -20
grep -ri "payment" memory/ | head -20

# 3. Check what is pending or blocked
grep -i "pending\|blocked" MEMORY.md
```

Then answer three questions before acting:

1. What decisions already exist for this task?
2. What is still pending, and who is waiting on whom?
3. What mistake has already been made once, that I must not repeat?

If the memory file contradicts the current request, say so and ask the user which one wins.
Never silently follow stale memory over a fresh instruction.

## Example MEMORY.md Layout

```markdown
# MEMORY.md

## Facts
- 2026-11-25: Project "rahman-tv" is a YouTube-style web app and
  Android APK; repo tunnabri-ops/rahman-tv, public.
- 2026-11-25: User prefers free hosting only: Cloudflare Pages,
  Vercel, GitHub Pages. No purchased VPS.

## Preferences
- Prefers English-first READMEs, public repos, world-visible work.
- Wants complete working apps in one session, no demos or placeholders.

## Commitments
- 2026-11-25: Daily 10-repo job, summary emailed to two addresses every morning at 09:00 Dhaka.

## Lessons
- 2026-11-25: mono.ts.m3u8 links fail sandbox checks but play on
  the user's device. Never check, judge, or remove them.
- 2026-11-25: Shrinking the player and feed made the app less
  user-friendly; the user wants full-width player, single-column
  large cards. Do not shrink again without asking.
```

## Checklist

- [ ] `MEMORY.md` read at session start, before other work.
- [ ] Only task-relevant facts pulled out; whole file not pasted around.
- [ ] New decisions, corrections, commitments, and lessons noted.
- [ ] Contradicted entries updated or deleted, not duplicated.
- [ ] File under 200 lines; compressed if it grew past that.
- [ ] No secrets, keys, passwords, tokens, or codes anywhere in it.
- [ ] Pending and blocked items still accurate at session end.

## Examples

Input: user says "we decided to use Stripe webhooks for payment
verification, never success-page redirects."

Output: add to `MEMORY.md` under Facts or Lessons:

```text
- 2026-11-25: Payment is verified only through signed Stripe
  webhook events. An order is never marked Paid on a success-page
  redirect, and browser-sent prices are never trusted.
```

Input: user corrects you — "that link plays on my phone, stop
removing it."

Output: add a Lesson, restore the link first, then write:

```text
- 2026-11-25: The user's device is ground truth for stream links.
  A sandbox failure does not prove a link is dead.
```

Input: session ends after building a feature that is tested but not deployed. Output: add a Commitment so the next session knows the state:

```text
- 2026-11-25: Feature X built and locally tested, NOT deployed.
  Needs the user's go-ahead before pushing.
```

## Pitfalls

- Do not treat the memory file as a transcript. A 500-line dump hides the facts that matter.
- Do not keep both the old and the new version of a changed fact. Update in place.
- Do not store a secret "just for now" or "temporarily". There is no temporary in a file that persists.
- Do not trust memory over the user. If the user says the opposite of what memory says, the user wins — record the change.
- Do not skip the end-of-session write. Memory written a week later from a summary is half-remembered and half-wrong.
- Do not index secrets. A keyword line that names a credential is the same leak as the file itself.
