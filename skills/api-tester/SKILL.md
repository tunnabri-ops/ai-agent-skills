---
name: api-tester
description: Use when the user asks to test, debug, verify, or document a REST API. It guides the agent to probe health and core endpoints with curl, check authentication and error cases, respect rate limits, validate responses against the API contract, and save a reproducible test script so the same checks can be re-run later.
---

# API Tester

Test a REST API the way a careful client would: start with health, then
happy paths, then auth, then errors, then limits. Record everything so the
same run can be repeated by anyone with the script.

## When to Use This Skill

- The user asks "does this API work", "test this endpoint", or "why is
  this request failing".
- A new API, deployment, or integration needs a smoke test before use.
- An endpoint returns an unexpected status, body, or error.
- The user wants a reusable check script for an API.

## When Not to Use It

- The task is to build the API itself rather than test an existing one.
- The API is only described in prose with no reachable base URL.

## Workflow

### 1. Gather the contract first

Before sending any request, collect:

- Base URL (exact, including scheme and any version prefix, e.g.
  `https://api.example.com/v1`).
- Authentication method: none, API key header, Bearer token, or Basic auth.
- The documented endpoints, methods, required parameters, and expected
  response shapes.
- Rate limits and any test/sandbox mode.

If there is no documentation, treat the first successful responses as the
observed contract and write them down. Never assume an endpoint exists.

### 2. Smoke test health endpoints

Start with the cheapest checks, in this order:

```bash
curl -s -o /dev/null -w "%{http_code}\n" https://api.example.com/health
curl -s -o /dev/null -w "%{http_code}\n" https://api.example.com/
curl -s -o /dev/null -w "%{http_code}\n" https://api.example.com/api/health
```

A `200` on any health endpoint means the service is up. A `404` on
`/health` alone does not mean the service is down; it may simply not
expose that path. Check the root and the documented endpoints before
concluding anything.

Use the bundled script for this step:

```bash
./scripts/api-smoke.sh https://api.example.com
```

It prints PASS/FAIL per endpoint with the HTTP code.

### 3. Test the happy path

For each core endpoint:

```bash
curl -s -X GET "https://api.example.com/v1/items?limit=5" \
  -H "Accept: application/json" | head -c 2000
```

Check four things on every response:

1. **Status code** — matches the documented code (usually 200 or 201).
2. **Content-Type** — `application/json` when JSON is expected.
3. **Body shape** — required fields present, types correct, no missing keys.
4. **Timing** — note slow responses (over 2 seconds) as a finding.

For POST/PUT/PATCH, send a minimal valid body first:

```bash
curl -s -X POST "https://api.example.com/v1/items" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_TOKEN" \
  -d '{"name": "smoke-test-item"}'
```

### 4. Test authentication

- No credentials: expect `401` (or `403` if the API uses that for
  missing auth). A `200` without credentials means the endpoint is public.
- Wrong credentials: expect `401`. A `200` with a bad token is a bug.
- Expired or revoked token: expect `401`, not a `500`.
- Correct credentials: expect the documented success code.

Never paste a real secret into chat, a file, or a log. Read tokens from
environment variables (`$API_TOKEN`) or a secure store, and mask them in
any output shared with the user.

### 5. Test error cases

Send each of these and record the actual status and body:

| Case | Request | Expected |
| --- | --- | --- |
| Missing required field | POST without a required key | 400 |
| Bad JSON | POST with `{invalid` | 400 |
| Wrong type | String where a number is required | 400 or 422 |
| Unknown resource | GET `/v1/items/does-not-exist` | 404 |
| Wrong method | DELETE on a read-only endpoint | 405 |
| Unknown route | GET `/v1/nope` | 404 |

A `500` on any of these is a finding, not an expected result. A clear
error body (`{"error": "..."}`) is good; an empty body or HTML error page
on a JSON API is a finding.

### 6. Check rate limits

- Read `X-RateLimit-Limit`, `X-RateLimit-Remaining`, and
  `Retry-After` headers when present.
- If a `429` appears, stop immediately. Do not retry in a loop, do not
  switch tools to keep hammering the API, and do not schedule replacement
  work against the same provider. Report the limit and wait.
- Keep request volume close to what a normal user would send.

### 7. Validate the contract

Compare each response against the documented schema:

- Required fields present, optional fields typed correctly.
- Enum values within the documented set.
- Pagination fields (`page`, `total`, `next`) behave consistently.
- IDs returned by a create call can be read back with a GET.

Log every mismatch as: endpoint, request, expected, actual.

### 8. Save a reproducible script

Save the checks as a script (see `scripts/api-smoke.sh` for the pattern)
so the run can be repeated:

- Takes the base URL as an argument, never hard-codes a secret.
- Prints PASS/FAIL per endpoint with the HTTP code.
- Exits non-zero when any check fails.
- Uses `set -euo pipefail` and `curl --fail` only where a failure
  should stop the run; health checks must report, not abort.

## Output Format

Report results as a table:

| Endpoint | Method | Status | Result | Notes |
| --- | --- | --- | --- | --- |
| /health | GET | 200 | PASS | 120 ms |
| /v1/items/xyz | GET | 404 | PASS | Expected for unknown id |
| /v1/items | POST | 500 | FAIL | Empty body, no error field |

Follow the table with: what works, what fails, and the exact curl command
needed to reproduce each failure.

## Checklist

- [ ] Base URL, auth method, and documented contract collected.
- [ ] Health endpoints probed before anything else.
- [ ] Happy path checked for status, content type, body shape, timing.
- [ ] Missing, wrong, and expired credentials each tested.
- [ ] Error cases tested: 400, 404, 405, bad JSON, wrong types.
- [ ] Rate-limit headers read; a 429 treated as a hard stop.
- [ ] Responses validated against the documented schema.
- [ ] Reproducible script saved and its output attached.
- [ ] No secret pasted into chat, files, or logs.

## Pitfalls

- **Testing only the happy path.** Auth and error handling are where
  real APIs break.
- **Treating 404 on /health as "down".** The service may be up without
  that path. Check the root and real endpoints.
- **Retrying after 429.** A rate limit is a stop sign, not a challenge.
- **Hard-coding secrets in scripts.** Use environment variables.
- **Trusting one run.** A single 200 proves the endpoint answered once,
  not that it is reliable. Re-run the script to confirm.
- **Ignoring the body.** A 200 with an error message inside the body is
  still a failure.
