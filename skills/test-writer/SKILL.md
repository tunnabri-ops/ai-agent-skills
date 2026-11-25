---
name: test-writer
description: Use when the user asks for tests, test coverage, TDD, or verification that code works, including unit, integration, and end-to-end tests for Python or JavaScript/TypeScript projects, and when a bug fix or new feature needs a failing test first and a passing test after.
---

# Test Writer

Write real tests that prove behaviour. A test that cannot fail is not a test.
Test the public behaviour, not the internal implementation, so refactors do
not break the suite for no reason.

## When to Use This Skill

- Adding a feature, fixing a bug, or refactoring existing code.
- The user asks for unit, integration, or end-to-end tests.
- Coverage is low, flaky, or unknown and needs a concrete target.
- A regression appeared and must never come back silently.

## TDD Flow

1. Read the feature or bug report. Restate the expected behaviour in one sentence.
2. Write one failing test for that behaviour first. Run it and confirm it fails
   for the right reason, not because of a typo or a missing import.
3. Write the smallest implementation that makes the test pass.
4. Run the full suite. Fix only what the failing test requires.
5. Refactor the implementation while keeping all tests green.
6. Add edge-case tests only after the happy path passes.

## Test Pyramid

- Unit tests (most): one function, one module, fast, no network or disk.
- Integration tests (some): real database, real file system, real HTTP
  against a local test server. Use test containers or a temp directory.
- End-to-end tests (few): drive the real app through its UI, CLI, or API.
  Keep them short, stable, and independent of each other.

## What Makes a Good Test

- One behaviour per test. Name it after the behaviour: `test_rejects_negative_price`.
- Arrange, Act, Assert: set up data, call the code, check the result.
- Use realistic data, including empty strings, zero, negative numbers,
  very long input, Unicode, and missing fields.
- Never depend on test order, wall-clock time, randomness, or the network.
- Clean up every file, record, and server the test creates.

## Edge Cases Checklist

- Empty input, null/None, missing key, and wrong type.
- Boundary values: 0, 1, -1, max, max + 1, empty list, single item.
- Duplicate input, repeated calls, and concurrent calls where relevant.
- Error paths: invalid JSON, timeout, 404, 500, permission denied.
- Unicode and Bangla text, emoji, and very long strings.
- Time zones, leap days, and month boundaries for date code.

## Mocking Rules

- Mock at the boundary: HTTP clients, databases, file systems, clocks.
- Never mock the code under test. Never mock a pure function.
- Prefer a fake (in-memory store, local test server) over a mock object
  when the interaction is complex.
- Assert on the result and on the important side effect, not on every
  internal call. A test that mirrors the implementation is brittle.
- Reset mocks between tests. A leaked mock is a common source of flakiness.

## Python — pytest

```python
# test_pricing.py
import pytest
from shop.pricing import apply_discount

def test_applies_percentage_discount():
    assert apply_discount(1000, 10) == 900

def test_rejects_discount_over_100():
    with pytest.raises(ValueError, match="discount"):
        apply_discount(1000, 101)

@pytest.mark.parametrize("price,discount,expected", [
    (100, 0, 100),
    (100, 50, 50),
    (0, 10, 0),
])
def test_discount_table(price, discount, expected):
    assert apply_discount(price, discount) == expected

def test_uses_fake_store(monkeypatch):
    from shop import orders
    calls = []
    monkeypatch.setattr(orders, "send_email", lambda to, body: calls.append(to))
    orders.place_order("a@example.com", 100)
    assert calls == ["a@example.com"]
```

Run: `pytest -q`, `pytest -q --cov=shop --cov-report=term-missing`.

## JavaScript / TypeScript — Vitest / Jest

```ts
// pricing.test.ts
import { describe, it, expect, vi } from "vitest";
import { applyDiscount } from "./pricing";

describe("applyDiscount", () => {
  it("applies a percentage discount", () => {
    expect(applyDiscount(1000, 10)).toBe(900);
  });

  it("rejects a discount over 100", () => {
    expect(() => applyDiscount(1000, 101)).toThrow(/discount/);
  });

  it.each([
    [100, 0, 100],
    [100, 50, 50],
    [0, 10, 0],
  ])("price %i discount %i gives %i", (price, discount, expected) => {
    expect(applyDiscount(price, discount)).toBe(expected);
  });

  it("sends one confirmation email", async () => {
    const sendEmail = vi.fn().mockResolvedValue(undefined);
    await placeOrder({ email: "a@example.com", total: 100 }, { sendEmail });
    expect(sendEmail).toHaveBeenCalledTimes(1);
  });
});
```

Run: `npx vitest run`, `npx vitest run --coverage`.

## Integration Test Pattern

```python
# test_api_orders.py — runs against a local test server, no mocks
def test_create_order_returns_201(client, tmp_path):
    response = client.post("/orders", json={"total": 500})
    assert response.status_code == 201
    assert response.json()["status"] == "pending"
    assert response.json()["id"]
```

Use a fresh database or temp directory per test. Never run integration
tests against production data or a shared staging database.

## Coverage Guidance

- Target 80%+ on new code, 70%+ overall for a mature project. Aim for
  branch coverage on payment, auth, and validation logic.
- Coverage is a floor, not a goal. 100% coverage with weak assertions
  proves nothing. Check the uncovered lines report and add tests for
  the branches that matter: error handling, permissions, money.
- Do not chase coverage by testing getters, constants, or generated code.
- Exclude generated files, migrations, and third-party vendored code
  from the coverage report.

## Flaky Test Checklist

- Replace `time.sleep()` with polling and a timeout.
- Freeze the clock (`freezegun`, `vi.useFakeTimers()`) for date logic.
- Seed random data or use fixed fixtures.
- Give each test its own temp directory and unique port.
- Retry only at the CI level, never inside the test, and log every retry.

## Pitfalls

- Testing implementation details: renaming a helper breaks ten tests.
- One giant test that checks everything and tells nothing when it fails.
- Shared mutable fixtures that leak state between tests.
- Tests that pass only on the author's machine (hard-coded paths, ports,
  time zones, or network access).
- Skipping the failing-test-first step, then writing a test that passes
  even with the bug present. Always watch it fail first.
- Asserting only `status_code == 200` without checking the response body.

## Before Finishing

- [ ] Every new behaviour has a test; every fixed bug has a regression test.
- [ ] The new test failed before the fix and passes after it.
- [ ] Full suite passes: `pytest -q` or `npx vitest run`.
- [ ] No test depends on order, time, randomness, or the live network.
- [ ] Coverage report checked; important uncovered branches are tested.
- [ ] No test writes to production data, shared files, or real services.
