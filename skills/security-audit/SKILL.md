---
name: security-audit
description: Use when running a full security audit of an application, service, or codebase, covering threat modelling, dependency and secrets checks, headers and CORS, authentication and sessions, and data exposure, and when a structured audit report with a findings table is needed.
---

# Security Audit

Run a full, evidence-based security audit. Start from what the system does
and who can hurt it, check each layer in turn, and finish with a report
that ranks findings and gives the owner a clear fix order. Audit read-only
by default; do not change production data or configuration without approval.

## Audit Workflow

1. Define scope in writing. List the services, repositories, environments,
   and data in scope, plus anything explicitly out of scope. Record the
   commit, version, and date of the audit.
2. Build a threat model. List assets (user data, secrets, money, admin
   functions), actors (anonymous visitor, logged-in user, admin, insider,
   attacker), and trust boundaries (browser to API, API to database,
   third-party webhook to server).
3. Map data flow. Trace sensitive data from entry to storage to output:
   passwords, tokens, personal data, payment details, and files. Note
   where each item is encrypted, logged, or exposed.
4. Check dependencies and supply chain. Review the lockfile, build
   scripts, CI configuration, and third-party integrations.
5. Scan for secrets and sensitive data in code, config, logs, and history.
6. Check authentication, sessions, and authorization end to end.
7. Check transport, headers, CORS, and cookies.
8. Check data exposure in APIs, error messages, logs, and exports.
9. Verify each finding by reproduction or by reading the exact code path.
10. Write the report, rank findings by severity, and list fixes in the
    order the owner should apply them.

## Threat Model Template

```text
System: <name and version>
Assets: <user accounts, personal data, payment records, admin functions>
Actors: <anonymous, authenticated user, admin, support staff, attacker>
Trust boundaries: <browser/API, API/database, webhook/server, worker/queue>
Top risks:
  1. <attacker action> -> <asset harmed> -> <impact>
  2. <attacker action> -> <asset harmed> -> <impact>
  3. <attacker action> -> <asset harmed> -> <impact>
Out of scope: <what was not checked, and why>
```

Keep the model short: three to five top risks are enough to focus the audit.

## Dependency Check

- Review the lockfile, not only the manifest. A loose version range can
  pull a vulnerable release on the next install.
- Flag dependencies with known CVEs, unmaintained packages, and packages
  with no lockfile entry. Record the CVE ID, the fixed version, and the
  current version for each finding.
- Check for dependency confusion, typosquatting, and packages installed
  from an untrusted registry or a bare URL.
- Check CI and build scripts for secrets in environment variables, for
  `curl | bash` installs, and for actions pinned to a branch instead of a
  commit SHA.
- Confirm that production dependencies are separated from development
  dependencies and that dev tools are not shipped to production.

## Secrets Scan

- Search code, configuration, environment files, CI logs, and Git history
  for API keys, tokens, passwords, private keys, and connection strings.
- Check client-side bundles and mobile apps: anything shipped to the
  client is public, including keys embedded in JavaScript or native code.
- Check error messages, logs, and crash reports for tokens, passwords,
  and personal data. Redact values in the audit report.
- For every secret found, record where it lives, whether it is still
  active, and whether it appears in Git history. The fix is always the
  same: revoke and rotate the secret, move it to a secret manager, and
  add a pre-commit scan so it cannot return.

## Headers, CORS, and Cookies

- Transport: HTTPS enforced everywhere, HSTS enabled, no HTTP fallback
  for authenticated pages, and TLS version 1.2 or higher.
- Headers: `Content-Security-Policy`, `X-Content-Type-Options: nosniff`,
  `X-Frame-Options: DENY` or `frame-ancestors 'none'`,
  `Referrer-Policy`, and `Permissions-Policy` set on responses.
- CORS: origins allowlisted, never `Access-Control-Allow-Origin: *` with
  credentials, and preflight handling limited to the methods the API
  actually needs.
- Cookies: `Secure`, `HttpOnly`, and `SameSite=Lax` or `Strict` on session
  cookies; a short expiry and rotation on privilege change.
- Uploads and downloads: `Content-Disposition` set for user files, MIME
  sniffing disabled, and uploads served from a separate origin.

## Authentication and Sessions

- Passwords hashed with Argon2id or bcrypt, never MD5, SHA-1, or plain
  text. Password reset tokens are single-use, short-lived, and random.
- Login is rate-limited and locked out after repeated failures; failed
  logins are logged without recording the attempted password.
- Sessions expire, rotate on login and privilege change, and are revoked
  server-side on logout and password change.
- Multi-factor authentication is available for admin and privileged
  accounts, and its bypass path is checked.
- Authorization is enforced server-side on every endpoint: test that user
  A cannot read, edit, or delete user B's resources by changing an ID.

## Data Exposure

- APIs return only the fields the client needs. Check list endpoints for
  extra fields such as internal IDs, emails, hashes, or admin flags.
- Error messages do not leak stack traces, SQL, file paths, or internal
  service names to the client.
- Logs do not contain passwords, tokens, card numbers, or full personal
  data. Log retention and access are limited to the team that needs them.
- Exports, backups, and analytics pipelines are encrypted at rest and
  access-controlled. Deleted data is actually deleted, including backups
  within the stated retention window.
- Search, pagination, and filters cannot be abused to enumerate users or
  records. Rate-limit list endpoints.

## Report Template

```text
# Security Audit Report — <system> — <date>

Scope: <services, repos, commit/version>
Method: <code review, dependency check, secrets scan, manual testing>
Threat model summary: <top 3 risks in one line each>

## Summary
<2-3 sentences: overall posture, number of findings by severity>

## Findings

| # | Severity | Title | Location | Impact |
|---|----------|-------|----------|--------|
| 1 | Critical | <title> | <file/endpoint> | <one line> |
| 2 | High | <title> | <file/endpoint> | <one line> |

### 1. <Title> (Critical)
- Evidence: <exact request, code path, or scan output>
- Impact: <what an attacker gains>
- Fix: <specific change, with file or config named>
- Verify: <how to confirm the fix works>

## Positive Observations
<Controls that are working well — name them so they are kept>

## Out of Scope / Not Checked
<What was not audited and why>

## Recommended Fix Order
1. <Critical findings, in order>
2. <High findings, in order>
3. <Medium and Low hardening>
```

## Severity Guide

| Severity | Meaning |
|----------|---------|
| Critical | Direct compromise, data breach, or account takeover. Fix immediately. |
| High | Serious impact with realistic exploitation. Fix before the next release. |
| Medium | Limited impact or needs extra conditions. Fix in the next cycle. |
| Low | Minor hardening issue. Fix with routine maintenance. |
| Informational | Observation, not a vulnerability. No fix required. |

## Pitfalls

- Do not report a scanner warning without verifying the code path; a
  flagged library may never be reachable in this application.
- Do not treat a missing header as Critical; rate it Low unless it enables
  a demonstrated attack.
- Do not audit only the happy path. Check error paths, admin functions,
  webhooks, password reset, and account deletion.
- Do not include real secrets or personal data in the report; redact them.
- Do not claim a system is secure because no Critical finding was found;
  state the scope and the limits of the audit instead.
