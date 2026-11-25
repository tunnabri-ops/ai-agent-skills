---
name: code-review-security
description: Perform rigorous code reviews and security assessments covering correctness, architecture, authorization, data integrity, vulnerabilities, performance and maintainability. Use before merging or releasing changes.
---

# Code Review and Security

## Review mindset

Assume the change may contain subtle defects. Review the full diff and relevant surrounding code. Prioritize user harm, data loss, security exposure and production outages over style preferences.

## Review order

1. Understand the intent, requirements and acceptance criteria.
2. Inspect the full diff, call sites, data model, API contracts and deployment impact.
3. Trace critical data flows from untrusted input to sensitive operations.
4. Check authorization and ownership at every protected resource boundary.
5. Verify transaction, concurrency, retry and idempotency behavior.
6. Inspect failure handling, observability and recovery.
7. Check performance and resource usage.
8. Check tests and documentation.
9. Run relevant tools and reproduce suspected defects safely.

## Correctness and maintainability checklist

- Does the implementation satisfy the requirement?
- Are boundary cases and null/empty states handled?
- Are invariants enforced in the correct layer?
- Are errors propagated and mapped consistently?
- Are resources closed and cancellation handled?
- Are state changes atomic where required?
- Are duplicate requests safe?
- Are public APIs backward compatible?
- Are abstractions cohesive and proportionate?
- Is there dead code, duplicated logic or hidden side effects?
- Are logs useful without exposing sensitive information?

## Security checklist

Consider applicable OWASP risks and threat-model the application:
- Broken access control / IDOR.
- Authentication and session flaws.
- Injection (SQL, NoSQL, command, template, path).
- XSS, CSRF, SSRF and unsafe redirects.
- Insecure deserialization and file uploads.
- Secrets in source, logs, artifacts or client bundles.
- Weak cryptography or custom authentication schemes.
- Missing rate limits and abuse controls.
- CORS misconfiguration mistaken for authorization.
- Sensitive data over-collection or excessive retention.
- Dependency and supply-chain vulnerabilities.
- Unsafe defaults, debug mode and exposed admin interfaces.
- Missing security headers, TLS or secure cookie flags where applicable.

Never implement custom cryptography. Use vetted libraries and established protocols. Do not run destructive exploit tests against systems without authorization.

## Dependency review

Check direct and transitive dependency advisories, maintenance, provenance where available, license, package scripts and version constraints. Avoid blindly upgrading major versions without migration review.

## Finding format

For each finding include:
- Severity: Critical / High / Medium / Low / Informational.
- Location: file and line or precise component.
- Evidence: concrete behavior or reproducible path.
- Impact: user/business/technical consequence.
- Recommendation: specific fix.
- Confidence: confirmed / likely / needs verification.

Do not report speculative style preferences as security vulnerabilities. Do not claim a clean security audit from a limited static review.

## Release gate

Block release for unresolved critical/high issues unless an explicitly authorized risk acceptance exists with owner, mitigation and expiry. After fixes, rerun affected tests and scans. Write `docs/SECURITY_REVIEW.md` with scope, tools, findings, remediation and residual risks.
