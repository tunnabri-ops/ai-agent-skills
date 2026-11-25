---
name: github-viral
description: Use when preparing a GitHub repository to go viral, including writing an English-first README, choosing topics, recording a demo GIF or video, writing release notes, drafting a launch post, and running a pre-publish checklist before making the repo public.
---

# GitHub Viral

Make a repository go viral: a clear English-first README, the right topics,
a demo people can watch in ten seconds, a real release, and a launch post
that reaches the right audience. Virality is not luck alone — it is a
discoverable repo, a working demo, and a story worth sharing.

## When to Use This Skill

- The user wants a repo to get stars, forks, or trending-page visibility.
- The user asks for a README, launch post, release notes, or repo polish.
- A project is about to be published and needs a pre-publish check.
- An existing repo is underperforming and needs a visibility review.

## What Makes Repos Trend

1. **Solves a visible pain in one sentence.** A visitor must understand the
   value in five seconds: what it does, for whom, and why it is better.
2. **Works immediately.** A one-command install or a live demo beats a long
   setup guide. Broken first-run experiences kill sharing.
3. **Looks alive.** Recent commits, a release, screenshots, and a demo GIF
   signal a maintained project, not an abandoned upload.
4. **Is discoverable.** English README, good topics, a clear name, and a
   description that contains the keywords people actually search for.
5. **Is shareable.** A short demo video, a before/after, or a surprising
   result gives people a reason to repost it.

## Workflow

### 1. Name and position the repo

1. Pick a short, memorable, searchable name — avoid generic names like `app`
   or `project-v2`.
2. Write the one-sentence pitch first: "X lets Y do Z without W."
3. Test the pitch on a stranger: if they cannot repeat it back, rewrite it.
4. Write the repo description from the pitch, under 120 characters.
5. Add a website link: live demo, docs, or the release page — never leave it blank.

### 2. Write the English-first README

Structure every README in this exact order:

1. **Title + one-line pitch** — name, what it does, who it is for.
2. **Badges** — build status, release version, license. Keep it to 3–5 badges.
3. **Demo** — a GIF or screenshot at the top, before any installation steps.
4. **Features** — 5–8 bullet points, each starting with a verb, no marketing fluff.
5. **Quick start** — copy-paste commands that work on a fresh machine.
6. **Usage** — one minimal example and one realistic example.
7. **Screenshots / video** — real output, not mockups.
8. **Contributing** — how to run tests, how to submit a PR.
9. **License** — state it clearly; MIT or Apache 2.0 for maximum reuse.

Rules for the README:

- English first; a Bangla section may follow, never lead.
- Every command must have been run exactly as written on a clean machine.
- No placeholder text, no fake screenshots, no promised features.
- Keep the README under 300 lines; move detail into `docs/`.

### 3. Choose topics

1. Add 8–10 topics: the language, the framework, the domain, and the use case.
2. Include at least one high-traffic topic (for example `python`, `ai`, `cli`).
3. Include at least one specific topic (for example `bangla`, `m3u8`, `lofi`).
4. Remove topics that do not match the code — wrong topics hurt search trust.
5. Re-check topics after every major feature change.

### 4. Record the demo GIF or video

1. Record a real run of the tool, not a slideshow — 15–30 seconds maximum.
2. Show the input, the action, and the visible result in that order.
3. Keep the GIF under 5 MB so it loads fast on the README.
4. Add a 60-second video link (YouTube or the release assets) for deeper demos.
5. Put the GIF directly under the pitch, not at the bottom of the README.

### 5. Publish a real release

1. Tag a version: `v1.0.0` for the first stable release, `v0.1.0` for an early one.
2. Write release notes with three sections: Added, Fixed, Known issues.
3. Attach built artifacts (binary, zip, model weights) when the repo promises them.
4. Verify the download link works from a logged-out browser before announcing.
5. Never announce a release whose main artifact is missing or broken.

### 6. Write the launch post

Use this template and fill every bracket — never post it with brackets left in:

```text
I built [name] — [one-sentence pitch].

It [does X] in [time / steps], unlike [existing option] which [pain].

Demo: [GIF or video link]
Try it: [repo link]
Docs: [docs or release link]

[One surprising detail or result, e.g. "runs on CPU" / "81 MB exe" / "loss 6.4 → 2.2"]

Built with [stack]. Feedback welcome — what should I add next?
```

Post it where the audience already is: the relevant subreddit, Hacker News
(Show HN), X, Dev.to, or a focused Discord. Post once per platform, on a
weekday morning in the audience's timezone, and reply to every comment in
the first 24 hours.

### 7. After launch

1. Reply to every issue and comment within 24 hours for the first week.
2. Fix the first reported bug fast and mention the reporter in the release notes.
3. Merge good PRs quickly — contributors who wait a week rarely return.
4. Ship a small follow-up release within 7 days to show the project is alive.
5. Track stars, forks, clones, and referrers weekly; note which post drove traffic.

## Checklist Before Publish

- [ ] One-sentence pitch is clear and repeated in the description and README.
- [ ] README is English-first, under 300 lines, with a demo GIF at the top.
- [ ] Quick-start commands verified on a clean machine, copy-paste exact.
- [ ] 8–10 accurate topics added; repo description and website link filled in.
- [ ] License file present (MIT or Apache 2.0).
- [ ] `.gitignore` covers build output, secrets, and local environment files.
- [ ] Demo GIF under 5 MB; video link works when logged out.
- [ ] `v1.0.0` (or `v0.1.0`) release published with notes and working artifacts.
- [ ] Launch post drafted with every bracket filled and links checked.
- [ ] Repo is public and the README renders correctly on github.com.

## Pitfalls

- Publishing with a Bangla-only README — most of the world cannot read it.
- Announcing before the quick start works; the first 100 visitors will leave.
- Adding 20 topics hoping for reach — irrelevant topics damage search ranking.
- A demo GIF that shows a slideshow instead of the real tool running.
- Release notes that say "bug fixes" with no detail and no attached artifact.
- Posting the launch and then ignoring comments for days.
- Claiming features that are not built yet; visitors check, and trust is lost.
