---
name: iptv-stream-check
description: Use when the user asks to verify live TV streams, IPTV playlists, or m3u8/DASH links, including checking whether a channel is live, dead, geo-blocked, or tokenized, and when cleaning up or adding channels to a playlist.
---

# IPTV Stream Check

Verify streams with evidence, in small batches, and never delete a link
on one sandbox failure alone. A check result is a claim about one URL at
one moment, not a verdict about the channel forever.

> **CRITICAL RULE — READ FIRST**
>
> **A stream that fails a sandbox curl check can still play on a real
> device. This is proven for `mono.ts.m3u8` links: they fail sandbox
> checks yet play fine on the user's phone or TV.**
>
> **Never delete, remove, or mark dead a link based on a sandbox failure
> alone. Mark it `needs-device-check` and ask the user to test it on
> their device. The user's device is the ground truth, not the sandbox.**

## When to Use This Skill

- Checking one channel link, a playlist, or a whole channels file.
- Adding a new channel or live event from a source playlist.
- Auditing a playlist: removing dead links, keeping working ones.
- Debugging why a stream plays in one app but not in another.

## Check Order

1. Confirm the URL is well-formed: `http(s)://`, no spaces, no truncation.
2. Run a HEAD request first, then a short ranged GET if HEAD is inconclusive.
3. Follow redirects and record the full redirect chain.
4. Read the content type and the first bytes of the body.
5. For m3u8, fetch the playlist and check that at least one segment URL
   inside it resolves. For DASH, fetch the MPD and check its representations.
6. Record the result with the time, HTTP code, and content type.

## How to Read a Result

| Signal | Likely meaning |
| --- | --- |
| 200 + `application/vnd.apple.mpegurl` or `application/x-mpegURL` | Live m3u8 playlist |
| 200 + `application/dash+xml` | Live DASH manifest |
| 200 + `video/MP2T` or `video/mp4` | Direct segment or stream |
| 301 / 302 / 307 to another host | Redirect — check the final URL, not the first |
| 403 | Blocked: geo-block, hotlink protection, or missing headers |
| 404 / 410 | Dead at this URL — still needs a device check before removal |
| 401 / 403 with a token or expiry in the URL | Tokenized link — may work for minutes, then expire |
| Timeout / connection refused / DNS failure | Host unreachable from the sandbox — not proof it is dead |
| 200 + `text/html` | Returned a web page, not a stream — wrong URL or a block page |

## Dead vs Geo-Blocked vs Tokenized

- **Dead:** 404/410, DNS does not resolve, or the host is gone. Re-check
  once after a few hours, then mark `needs-device-check` before any removal.
- **Geo-blocked:** 403 from the sandbox but the same link works in another
  region, or the provider's docs say the channel is region-locked. Keep
  the link and note the region. Try a different user-agent or referer
  header before concluding it is blocked.
- **Tokenized:** the URL contains `token=`, `expires=`, `sig=`, or a
  session id. It can be live now and dead in an hour. Do not store it as
  a permanent channel. Note the expiry and re-check before adding it.
- **Sandbox-only failure:** timeout, TLS error, or connection reset in
  the sandbox, especially for `mono.ts.m3u8` links. Mark
  `needs-device-check`. Do not delete. Do not re-check it in a loop.

## curl Commands

```bash
# HEAD, follow redirects, show headers and final URL
curl -sIL --max-time 15 -A "Mozilla/5.0" "https://example.com/live.m3u8"

# Ranged GET: fetch only the first 2 KB of the playlist
curl -s -L --max-time 15 -r 0-2047 -A "Mozilla/5.0" "https://example.com/live.m3u8"

# Full check with headers that some providers require
curl -s -L --max-time 15 \
  -H "Referer: https://example.com/" \
  -H "Origin: https://example.com" \
  -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" \
  "https://example.com/live.m3u8" | head -c 2000

# Check a segment URL listed inside a playlist
curl -s -o /dev/null -w "%{http_code} %{content_type}\n" --max-time 15 \
  "https://example.com/segment001.ts"
```

Use the bundled script for a standard check:

```bash
./scripts/check-stream.sh "https://example.com/live.m3u8"
# LIVE  | HTTP 200 | application/vnd.apple.mpegurl | final: https://cdn.example.com/live.m3u8
```

## Batch Checking Rules

- Check in small batches (10–20 URLs at a time). Large sweeps across
  many unknown hosts can trigger approval prompts or rate limits.
- Wait 1–2 seconds between requests to the same host.
- Run checks sequentially, not in parallel, against one small host.
- Save results to a file as you go, so a stopped run keeps its progress.
- Never start a sweep of hundreds of unknown hosts without warning
  the user first.

## Adding a Channel or Live Event

1. Verify the stream with the commands above and record the evidence.
2. For a live event, also verify the match is actually live: check a
   live score source, not just a playlist label. A label alone is not proof.
3. Check for duplicates by URL, not by name: the same channel can
   legitimately have two or three different server URLs.
4. Keep every distinct server URL for the same channel. Label them
   Server 1, Server 2, Server 3 in the app.
5. Add the channel name, group, logo URL, and stream URL to the playlist.
6. Rebuild the playlist file so the app and the file stay in sync.

## Playlist Hygiene

- Dedupe by URL only, never by name. Two entries with the same name and
  different URLs are two servers, not a duplicate.
- Removing a dead server URL removes only that entry, never the channel.
- Rebuild the `.m3u` file one entry per channel name after any change.
- Keep a backup of the channels file before a bulk edit.
- Record every removal with the date, the check result, and who confirmed it.

## Pitfalls

- Deleting a `mono.ts.m3u8` link because the sandbox check failed. The
  user's device plays it. Restore it immediately if this happens.
- Treating a 403 as dead. It is usually geo-block or header protection.
- Treating a tokenized link as permanent. It expires.
- Checking a playlist URL and concluding the channel is live without
  checking that a segment inside it resolves.
- Adding a live event from a playlist label without checking the score.
- Running a huge parallel sweep that floods the user with prompts.

## Before Finishing

- [ ] Every checked URL has a recorded result: code, content type, time.
- [ ] No link was deleted on sandbox failure alone; failures are marked
  `needs-device-check`.
- [ ] Redirects were followed and the final URL was recorded.
- [ ] Duplicates were checked by URL, not by name; extra servers were kept.
- [ ] Live events were verified against a live score, not a label.
- [ ] The playlist file was rebuilt and the change was verified.
