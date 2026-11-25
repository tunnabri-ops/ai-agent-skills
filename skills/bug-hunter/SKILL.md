---
name: bug-hunter
description: Use when hunting security bugs in a codebase, API, or web application, including OWASP Top 10 issues, authentication and authorization flaws, injection, SSRF, IDOR, and leaked secrets, and when a triaged finding with severity, proof-of-concept, and a fix suggestion is needed.
---

# Bug Hunter

Hunt security bugs systematically. Find real, demonstrable flaws, rank them
by impact, and report each one with evidence and a concrete fix. Never
exploit a live production system. Work read-only against source code, or
against a local test target the user owns and controls.

## Scope Rules

- Read-only on production: inspect code, configuration, and responses. Do
  not modify data, delete records, send destructive requests, or brute-force
  credentials.
- Local test targets only for active testing: run the app locally, in a
  staging environment, or against a target the user explicitly named.
- Stop and ask before touching authentication, payments, or user data in a
  shared environment.
- Record the exact target, version, commit, and request that produced each
  finding so it can be reproduced.

## Workflow

1. Map the attack surface first. List entry points: routes, API endpoints,
   forms, file uploads, query parameters, headers, cookies, webhooks, and
   background jobs. Note which ones require authentication.
2. Trace data flow. Follow untrusted input from its source to its sink:
   database query, shell command, file path, HTML output, redirect, or
   outbound HTTP request. A bug exists where input reaches a sink unsafely.
3. Check authentication and authorization. Can an unauthenticated caller
   reach a protected endpoint? Can one user read or change another user's
   object by changing an ID in the URL or body?
4. Check injection points. Test SQL, NoSQL, command, LDAP, XPath, template,
   and log injection with safe, non-destructive payloads on local targets.
5. Check SSRF and outbound requests. Where the app fetches a user-supplied
   URL, test whether internal addresses, cloud metadata endpoints
   (`169.254.169.254`), or private networks are reachable.
6. Check secrets and sensitive data. Search for hard-coded keys, tokens,
   passwords, private keys, and credentials in code, config, logs, error
   messages, and client-side bundles.
7. Verify every candidate finding. Reproduce it twice. A finding without a
   reproduction is a hypothesis, not a bug.
8. Write the report. One finding per entry, with severity, proof, impact,
   and fix. Order findings by severity, not by discovery order.

## OWASP Top 10 Checklist

- Broken Access Control: missing checks, IDOR, privilege escalation,
  forced browsing to admin or other-user resources.
- Cryptographic Failures: weak hashing, plain-text secrets, missing TLS,
  predictable tokens, sensitive data in URLs or logs.
- Injection: SQL, NoSQL, command, template, and XSS (stored, reflected,
  DOM). Check both input validation and output encoding.
- Insecure Design: missing rate limits, no account lockout, unsafe
  password reset, business-logic flaws such as negative prices.
- Security Misconfiguration: debug mode on, default credentials, verbose
  errors, open directory listings, unnecessary services exposed.
- Vulnerable Components: outdated libraries with known CVEs; check the
  lockfile, not only the manifest.
- Identification and Authentication Failures: weak passwords, session
  fixation, tokens that never expire, missing multi-factor enforcement.
- Software and Data Integrity Failures: unsigned updates, unpinned
  dependencies, deserialization of untrusted data.
- Security Logging and Monitoring Failures: no audit trail for login,
  password change, or admin actions; logs that omit the attacker IP.
- Server-Side Request Forgery: user-controlled URLs fetched server-side
  without an allowlist or private-network block.

## Severity Guide

| Severity | Meaning | Example |
|----------|---------|---------|
| Critical | Direct compromise, data breach, or full account takeover | SQL injection dumping users, auth bypass, SSRF to cloud metadata |
| High | Serious impact with realistic exploitation | Stored XSS, IDOR exposing private records, missing auth on admin API |
| Medium | Limited impact or needs extra conditions | Reflected XSS needing a click, verbose errors leaking stack traces |
| Low | Minor hardening issue | Missing security header, weak rate limit, information disclosure |

Assign severity by impact first, then by ease of exploitation. A hard-to-
exploit Critical impact stays High at most; an easy Low impact stays Low.

## Proof-of-Concept Format

For each finding, include:

- Title and severity.
- Location: file and line, or endpoint and parameter.
- Steps to reproduce: exact request, payload, and observed response.
- Expected behaviour versus actual behaviour.
- Impact: what an attacker gains, in one or two sentences.
- Fix suggestion: specific code or configuration change, not general advice.

Example:

```text
Title: IDOR on order details (High)
Location: GET /api/orders/{id}
Reproduction: Log in as user A, request /api/orders/1024 (user B's order).
  The API returns user B's address and items with HTTP 200.
Impact: Any authenticated user can read any other user's orders.
Fix: Load the order through the current user's scope, for example
  Order.where(user_id: current_user.id).find(params[:id]), and return
  404 when it is not found.
```

## Fix Suggestions

- Injection: use parameterized queries and prepared statements; never build
  queries by string concatenation. Encode output for its context.
- XSS: escape HTML, use a strict Content Security Policy, and set cookies
  with `HttpOnly` and `Secure`.
- SSRF: allowlist destinations, block private and link-local ranges, and
  validate redirects after DNS resolution.
- IDOR: enforce ownership on every read, write, and delete, server-side.
- Secrets: move keys to environment variables or a secret manager, rotate
  any key found in source control, and add a pre-commit secret scan.
- Auth: hash passwords with Argon2id or bcrypt, use short-lived sessions,
  rotate tokens on privilege change, and rate-limit login attempts.

## Pitfalls

- Do not report a scanner warning without reproducing it; scanners produce
  false positives on framework-safe code.
- Do not confuse a missing header with an exploitable bug; rate it Low and
  say so.
- Do not test with destructive payloads such as `DROP TABLE` or mass
  deletion, even on a local copy, unless the user asked for it.
- Do not chain findings into an exploit on a shared system; prove each
  step separately and stop at the boundary the user set.
- Do not include real secrets, tokens, or personal data in the report;
  redact values and show only the first few characters.
