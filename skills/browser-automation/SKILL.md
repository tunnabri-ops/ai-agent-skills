---
name: browser-automation
description: Use when automating a browser with an agent, filling forms, clicking through a web flow, scraping a page that needs JavaScript, taking screenshots to verify a page, or testing a web app end to end with Playwright.
---

# Browser Automation

Drive a real browser with code: open pages, click, type, read content,
wait for the page to settle, and screenshot the result for verification.
Use Playwright, which controls Chromium, Firefox, and WebKit through one
API and works in both Python and Node.js. Automate only sites and accounts
the user owns or explicitly asked you to use, and never pretend a bot is
a human.

## Core Rules

- Automate with the user's permission for that site and that account.
  Never automate a login, purchase, or account action the user did not
  ask for.
- Never bypass a CAPTCHA, bot check, or login wall. If a page shows a
  CAPTCHA or blocks the browser, stop, tell the user what happened, and
  ask how to proceed. Do not solve CAPTCHAs to evade a block, do not
  rotate proxies or user agents to dodge detection, and do not retry
  aggressively after a block.
- Never store, log, or paste passwords, tokens, or session cookies into
  chat, files, or screenshots shared with anyone else. Read credentials
  from environment variables or a secret store at run time.
- Wait for elements instead of sleeping for a fixed time. A fixed sleep
  is slow when the page is fast and flaky when the page is slow.
- Screenshot before and after the important step. A screenshot is the
  cheapest proof that the page looked the way the script expected.
- Close the browser when the script ends. A leaked headless browser keeps
  holding memory, ports, and a logged-in session.

## Setup

Install Playwright once per project, then install the browsers it drives:

```bash
# Python
pip install playwright
playwright install chromium

# Node.js
npm install -D playwright
npx playwright install chromium
```

Run `playwright install chromium` even when a system Chromium exists;
Playwright pins a browser build it has tested against, so the system
browser is not a reliable substitute.

## Workflow

1. Decide headed or headless before writing the script. Headless
   (`headless=True`) is faster and fits CI and servers; headed
   (`headless=False`) shows the browser window and is the right choice
   when debugging a flow or showing the user what happens.
2. Launch the browser, open a context, and open a page. A context is an
   isolated profile: cookies and storage in one context do not leak into
   another, so use one context per account or per test.
3. Navigate with `page.goto(url)` and wait for the load state the step
   needs: `domcontentloaded` for the HTML, `networkidle` only when the
   page truly settles (many pages never go idle).
4. Locate elements by role, label, or test id, not by fragile CSS paths.
   Prefer `get_by_role("button", name="Sign in")` over
   `div:nth-child(3) > button`. A label survives a redesign; a positional
   selector does not.
5. Act, then assert. After a click or a form submit, wait for the element
   that proves the action worked — a heading, a success message, a URL
   change — instead of assuming it worked.
6. Screenshot the result with `page.screenshot(path="after.png")`. Read
   the screenshot before reporting success; a green test and a broken
   page can coexist.
7. Read text with `locator.inner_text()` or `page.content()` for checks,
   and save structured data (JSON, CSV) rather than pasting raw HTML
   into a report.
8. Close the context and the browser in a `finally` block so a failure
   mid-script does not leave a browser running.

## Minimal Runnable Example (Python)

Save this as `check_site.py`, set no secrets in it, and run it with
`python check_site.py`. It opens a page, waits for its heading, fills
a search box, screenshots the result, and prints the page title.

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    try:
        page.goto("https://example.com", wait_until="domcontentloaded")
        page.screenshot(path="home.png")
        heading = page.get_by_role("heading").first
        heading.wait_for(state="visible", timeout=10000)
        print("Heading:", heading.inner_text())
        print("Title:", page.title())
        page.screenshot(path="heading.png")
    finally:
        browser.close()
```

## Common Actions

| Task | Python | Node.js |
|------|--------|---------|
| Open a page | `page.goto(url)` | `page.goto(url)` |
| Click | `page.get_by_role("button", name="Save").click()` | `page.getByRole("button", { name: "Save" }).click()` |
| Fill a field | `page.get_by_label("Email").fill("a@b.com")` | `page.getByLabel("Email").fill("a@b.com")` |
| Read text | `page.get_by_role("heading").inner_text()` | `page.getByRole("heading").innerText()` |
| Wait for element | `locator.wait_for(state="visible")` | `locator.waitFor({ state: "visible" })` |
| Screenshot | `page.screenshot(path="shot.png")` | `page.screenshot({ path: "shot.png" })` |

## Examples

Example 1 — log in and verify the dashboard (credentials from env):

```python
import os
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    try:
        page.goto("https://app.example.com/login")
        page.get_by_label("Email").fill(os.environ["APP_EMAIL"])
        page.get_by_label("Password").fill(os.environ["APP_PASSWORD"])
        page.get_by_role("button", name="Sign in").click()
        page.wait_for_url("**/dashboard", timeout=15000)
        page.screenshot(path="dashboard.png")
        print("Logged in, dashboard URL:", page.url)
    finally:
        browser.close()
```

Input: a login URL and credentials in `APP_EMAIL` / `APP_PASSWORD`.
Output: the dashboard URL printed and `dashboard.png` saved as proof.

Example 2 — a flow that hits a CAPTCHA (stop, do not solve it):

```python
page.goto("https://example.com/checkout")
if page.locator("iframe[src*='captcha'], [id*='captcha']").count() > 0:
    page.screenshot(path="captcha-blocked.png")
    raise SystemExit("Stopped: CAPTCHA shown. Ask the user how to proceed.")
```

Input: a checkout page that presents a CAPTCHA.
Output: the script stops, saves proof, and asks the user — it does not
try to solve the CAPTCHA or switch browsers to evade the check.

## Headless vs Headed

- Headless: no window, faster, works on servers and in CI, and is the
  default for repeatable checks. Use it for scraping, testing, and
  scheduled runs.
- Headed: a visible window, slower, needs a display, and is the right
  choice when debugging a selector, watching a flow once, or showing
  the user what the browser does. Launch with `headless=False`.
## Checklist

- [ ] Installed Playwright and ran `playwright install chromium`.
- [ ] Chose headless for repeat runs, headed for debugging.
- [ ] Located elements by role, label, or test id, not by position.
- [ ] Waited for the element or URL that proves each step worked.
- [ ] Took a screenshot before and after the important step and read it.
- [ ] Read credentials from environment variables, never hard-coded.
- [ ] Stopped and asked the user on any CAPTCHA, bot block, or login wall.
- [ ] Closed the browser in a `finally` block.
- [ ] Saved scraped data as JSON or CSV, not as raw HTML in a report.

## Pitfalls

- Do not use `time.sleep(5)` to wait for a page; use `wait_for` on the
  element or URL that proves the page is ready.
- Do not use brittle selectors such as `:nth-child(4)` or generated
  class names; they break on the next deploy.
- Do not click an element before checking it is visible and enabled;
  clicking a hidden element throws, and clicking too early clicks the
  wrong thing.
- Do not reuse one browser context across accounts; cookies and logins
  leak between tests and produce false passes.
- Do not screenshot only on success; a screenshot on failure is the
  evidence that explains what went wrong.
- Do not solve CAPTCHAs, rotate user agents, or hammer a site after a
  block to evade detection; stop and ask the user instead.
- Do not trust `page.title()` alone as proof a flow worked; assert on
  the element or URL the user actually cares about.
