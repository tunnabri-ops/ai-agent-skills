---
name: sdlc-planner
description: Use when planning a software project from start to finish, when the user asks for a project plan, roadmap, or timeline, or when work must be organised into research, requirements, design, implementation, testing, deployment, and maintenance phases.
---

# SDLC Planner

Plan before building. A project without a plan is a list of guesses that runs out of time, money, or
motivation halfway through. This skill walks the full Software Development Life Cycle, phase by
phase, and produces a single written plan the user can read, approve, and follow. Research comes
before coding. Design comes before implementation. Testing comes before deployment. No phase is
skipped because it feels slow; skipping a phase only moves the cost later, with interest.

## How to Use This Skill

1. Ask the user for the project idea in one or two sentences, the
target users, the deadline, and the budget or hosting limits.
2. Work through the phases below in order. Do not start phase 4
until phases 1 to 3 have written deliverables.
3. Write `PROJECT_PLAN.md` at the end, covering every phase, with a
timeline, milestones, owners, and risks. The user gets the whole process in a file before coding
starts.
4. If the user changes scope, update the plan first, then the code.
A plan that is out of date is worse than no plan, because it lies.

## Phase 1 — Research and Discovery

Goal: prove the idea is worth building, and learn from what exists. Inputs: the project idea, the
target audience, the deadline. Work: search for existing products, open-source projects, and
competitors. List what they do well and where they fail. Read their documentation, pricing, and user
reviews where available. Check technical feasibility: is there an API, a library, or a data source
for the hard part? Build a one-day spike or a small proof of concept for the single riskiest
technical unknown only. Talk to real users if possible; five short conversations beat fifty guesses.
Outputs: a research note listing competitors, gaps, feasibility findings, and the riskiest
assumption. Exit criteria: the top three competitors are named, the gap this product fills is
written in one sentence, and the riskiest technical unknown has a tested answer. Common mistakes:
researching for weeks without a decision; copying a competitor feature for feature; assuming an API
exists without checking.

## Phase 2 — Requirements

Goal: write down exactly what the software must do, and what it must not do, so success can be
checked later. Inputs: research note, user conversations, constraints. Work: write functional
requirements as user stories in this form: `As a <user>, I want <action> so that <benefit>.` Give
every story an ID, such as `US-01`, and a priority: Must, Should, or Could. Write non-functional
requirements: performance targets, security rules, accessibility, supported devices and browsers,
uptime, data retention, and privacy rules. Write acceptance criteria for every Must story, in plain
language a non-technical user can check. Example: "Given a valid email and password, when the user
signs in, then the dashboard loads within two seconds." Define what is out of scope, explicitly. Out
of scope is a decision, not an accident. Outputs: a requirements list with prioritised user stories,
acceptance criteria, non-functional requirements, and an explicit out-of-scope list. Exit criteria:
every Must story has acceptance criteria, the user has approved the scope, and the out-of-scope list
is written down. Common mistakes: vague requirements such as "fast" with no number attached; no
out-of-scope list, so scope grows every week.

## Phase 3 — Design

Goal: decide how the system works before writing production code. Inputs: approved requirements,
stack decision, constraints. Work: choose the stack and architecture. Load the stack-architect skill
and write `STACK_DECISION.md` if it does not exist yet. Design the database schema: every table or
collection, its fields, types, keys, and relationships. Note which fields are indexed and why, and
plan migrations from day one. Design the API contract: every endpoint with method, path, request
body, response body, and error codes, as an OpenAPI file or a table in the plan, frozen before
coding. Draw UI wireframes, even as simple boxes and labels, for every screen, noting the happy path
and the error state for each screen. A screen with no error state is an unfinished design. Define
the folder structure, naming rules, and environments: local, staging, and production. Outputs:
architecture description, database schema, API contract, wireframes, folder structure, environment
plan. Exit criteria: the schema, the API contract, and the wireframes are written down and reviewed;
a developer who was not in the room could start building from them. Common mistakes: designing the
UI before the data model; an API contract that changes daily; no error states in the design.

## Phase 4 — Implementation

Goal: build the product in small, shippable, vertical slices. Inputs: approved design, API contract,
wireframes, plan. Work: break the work into milestones, each one to two weeks long. Each milestone
ends with something the user can run and test. Build in vertical slices, not horizontal layers. One
slice delivers one user story end to end: database, API, UI, and tests. A slice that is only a
database, or only a UI, is not shippable. Order slices by risk and value, building the riskiest
slice first, while there is still time to change direction. Commit small and often, with messages
that say what changed and why. Keep the main branch working at all times; a broken main branch
blocks everyone. Outputs: working software per milestone, with tests. Exit criteria: every Must
story is implemented, the app runs from a clean checkout with documented commands, and no slice is
left half finished. Common mistakes: building all the UI first and the API last; one giant branch
merged at the end; no definition of done per story.

## Phase 5 — Testing

Goal: prove the software works, including when things go wrong. Inputs: working software, acceptance
criteria, requirements. Work: write unit tests for business logic, integration tests for the API and
database, and end-to-end tests for the critical user journeys. Load the test-writer skill for the
test patterns. Test the edge cases: empty input, invalid input, duplicate submissions, expired
sessions, slow networks, and large files. Run user acceptance testing with real users against the
acceptance criteria from phase 2, recording every failure with steps to reproduce it. Test on the
real target devices and browsers, not only on the developer machine, and test the slow path, not
only the fast one. Outputs: a test suite with coverage results, a UAT checklist with pass or fail
per criterion, and a bug list with severity. Exit criteria: all Must acceptance criteria pass, no
open Blocking or Major bugs, and the test suite passes from a clean run. Common mistakes: testing
only the happy path; manual testing with no written checklist; fixing bugs without a regression
test.

## Phase 6 — Deployment

Goal: ship safely, and be able to undo a bad ship quickly. Inputs: tested software, hosting
accounts, environment variables. Work: set up three environments: local, staging, and production.
Staging must match production as closely as possible, including the database version and the
environment variables. Set up CI/CD: every push runs lint, tests, and a build, and a failing
pipeline blocks the deploy; nobody deploys around it. Write the deploy checklist: build, migrate,
deploy, smoke test, monitor. Write the rollback plan before the first deploy: how to restore the
previous version and the previous database state, and who decides to roll back. Keep secrets in the
hosting provider or a secret manager, never in the repository, and never in a chat message. Outputs:
a CI/CD pipeline, environment documentation, a deploy checklist, a rollback plan, and a smoke-test
script. Exit criteria: a deploy to staging and production has been run end to end, the smoke test
passes, and a rollback has been rehearsed at least once. Common mistakes: deploying straight to
production; no staging; secrets in the repository; no rollback plan.

## Phase 7 — Maintenance

Goal: keep the software working, secure, and improving after launch. Inputs: production logs, user
feedback, bug reports, roadmap. Work: set up monitoring and alerts for uptime, errors, and slow
requests. An error nobody sees is an error nobody fixes. Triage bugs by severity: Blocking, Major,
Minor. Fix Blocking bugs first, and write a regression test for each one. Update dependencies on a
schedule, and check for security advisories. Keep a changelog so users know what changed. Review the
roadmap every month, and promote Could stories to Should only when the Must stories are stable in
production. Outputs: monitoring dashboard and alerts, a bug triage list, a changelog, and an updated
roadmap. Exit criteria: monitoring is live, the first month of bug triage is scheduled, and the
roadmap for the next milestone is written. Common mistakes: launching and never checking the logs;
letting dependencies go stale for a year; adding features while Blocking bugs stay open; no
changelog.

## Writing PROJECT_PLAN.md

The agent MUST write this file for the user before coding starts. Use this structure, and fill in
every section. Do not leave a section blank or marked as undecided without a date for deciding it.

```markdown
# Project Plan — <project name>

## 1. Summary
- Problem: <one sentence>
- Users: <who, how many>
- Success looks like: <measurable outcome>

## 2. Research findings
- Competitors: <name — strength — gap>
- Riskiest assumption: <assumption — how it was tested>

## 3. Requirements
- Must stories: <US-01 ... with acceptance criteria>
- Should stories: <list>
- Could stories: <list>
- Out of scope: <list>
- Non-functional: <performance, security, devices>

## 4. Design
- Stack: <from STACK_DECISION.md>
- Database schema: <tables and relationships>
- API contract: <endpoints or link to OpenAPI file>
- Wireframes: <screens and their error states>

## 5. Timeline and milestones
| Milestone | Scope | Due | Done when |
|---|---|---|---|
| M1 | <slice> | <date> | <testable outcome> |

## 6. Testing plan
- Unit / integration / end-to-end targets
- UAT checklist and owners

## 7. Deployment plan
- Environments, CI/CD, rollback steps

## 8. Risks
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| <risk> | <Low/Med/High> | <Low/Med/High> | <action> |

## 9. Maintenance
- Monitoring, bug triage, roadmap review cadence
```

## Rules

- Never skip research because the idea feels obvious.
- Never start implementation without written requirements and design.
- Never treat a phase as done until its exit criteria are met.
- Never let scope change without updating the plan and the timeline.
- Never promise a date without naming what is cut if the date slips.
