# Example sessions

Three concrete sessions showing what these skills do in practice. Each one
starts with a plain user request — the agent loads the matching skill itself.

---

## 1. Bug-hunter on a login route

**User:**

> Review this login route for security bugs.

```js
app.post("/login", async (req, res) => {
  const user = await db.users.findOne({ email: req.body.email });
  if (!user || user.password !== req.body.password) {
    return res.status(401).json({ error: "Invalid email or password" });
  }
  res.json({ token: jwt.sign({ id: user.id }, "secret123") });
});
```

**Agent (loads `bug-hunter`):**

| # | Finding | Severity | Proof | Fix |
|---|---------|----------|-------|-----|
| 1 | Plain-text password comparison — passwords stored/compared in clear text | **Critical** | `user.password !== req.body.password` compares raw strings; a DB leak exposes every password | Store bcrypt/argon2 hashes; compare with `bcrypt.compare()` |
| 2 | Hard-coded JWT secret `"secret123"` | **Critical** | Anyone reading the source can forge tokens for any user | Load the secret from an env var, min. 32 random bytes, rotate it |
| 3 | No rate limiting on `/login` | **High** | An attacker can brute-force passwords with unlimited attempts | Add rate limiting (e.g. 5 attempts / 15 min per IP + account lockout) |
| 4 | JWT has no expiry | **Medium** | A stolen token works forever | Set `expiresIn: "15m"` and use refresh tokens |
| 5 | No account-enumeration guard on timing | **Low** | `findOne` vs compare timing can leak whether an email exists | Always run the hash comparison, even when the user is missing |

Result: five findings, worst first, each with a concrete fix — not "this looks insecure".

---

## 2. iptv-stream-check on a playlist

**User:**

> Check whether these links are still live:
>
> - `https://example-cdn.com/live/bangla-vision.m3u8`
> - `https://old-host.net/sports.m3u8`
> - `https://cdn.example.com/mono.ts.m3u8`

**Agent (loads `iptv-stream-check`):**

```bash
./skills/iptv-stream-check/scripts/check-stream.sh \
  https://example-cdn.com/live/bangla-vision.m3u8
# LIVE — HTTP 200, content-type: application/vnd.apple.mpegurl, 1 redirect

./skills/iptv-stream-check/scripts/check-stream.sh \
  https://old-host.net/sports.m3u8
# DEAD — HTTP 404, no playlist body

./skills/iptv-stream-check/scripts/check-stream.sh \
  https://cdn.example.com/mono.ts.m3u8
# UNKNOWN — HTTP 403 in sandbox (curl blocked)
# → marked NEEDS-DEVICE-CHECK, not deleted: mono.ts links often
#   fail a sandbox curl check and still play on a real device.
```

**Report:**

| URL | Verdict | Evidence |
|-----|---------|----------|
| bangla-vision.m3u8 | LIVE | 200, mpegurl, 1 redirect |
| sports.m3u8 | DEAD | 404, confirmed twice |
| mono.ts.m3u8 | NEEDS-DEVICE-CHECK | 403 in sandbox only — keep, verify on device |

---

## 3. github-viral launch checklist

**User:**

> I just finished my repo. Help me launch it.

**Agent (loads `github-viral`):**

1. **README check** — hero line, install in under 60 seconds, demo GIF at the top, English-first. Missing demo → records a 30-second screen recording first.
2. **Topics** — adds up to 20 relevant topics (`claude-code`, `agent-skills`, `ai-agents`, …), removes the generic ones.
3. **Release** — tags `v1.0.0`, writes release notes in "what it does / how to try it in 2 minutes" form, attaches no binaries the user didn't build.
4. **Launch post** — drafts from the template:

> **12 skills your coding agent is missing**
>
> I kept writing the same instructions into every agent session — hunt bugs, write tests, audit security — so I packaged them as skills.
>
> `git clone … && ./install.sh` — 30 seconds, Claude Code / Codex / Cursor.
>
> Repo: https://github.com/tunnabri-ops/ai-agent-skills

5. **After launch** — answers the first issues the same day, stars don't come from the post, they come from the replies.
