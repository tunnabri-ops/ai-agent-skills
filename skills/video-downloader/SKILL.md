---
name: video-downloader
description: Use when downloading videos correctly, including picking the best format and quality with yt-dlp, downloading and concatenating HLS/m3u8 streams with ffmpeg, resuming interrupted downloads, and handling playlists, subtitles, and audio extraction.
---

# Video Downloader

Download videos correctly: pick the right format and quality, resume
interrupted downloads, handle HLS/m3u8 streams, and extract audio or
subtitles. The primary tool is `yt-dlp`; `ffmpeg` handles HLS downloads,
concatenation, and remuxing.

## Legal Note

Only download content you have rights to: your own videos, public-domain
material, Creative Commons content, or anything the uploader explicitly
allows downloading. Do not download copyrighted content without permission,
do not bypass paywalls or DRM, and do not re-upload downloaded content as
your own. When in doubt, ask the user whether they own the rights or the
content is public-domain before downloading.

## When to Use This Skill

- The user asks to download a video, playlist, or audio track from a URL.
- The user asks for a specific quality, format, or resolution.
- The user has an m3u8/HLS link and needs the video file.
- A download failed halfway and needs to be resumed.

## Prerequisites

- `yt-dlp` installed and up to date: `pip install -U yt-dlp`.
- `ffmpeg` installed and on the PATH: `ffmpeg -version` must succeed.
- Enough disk space: a 1080p hour-long video is typically 1–3 GB.
- A stable connection for large files; resume works only if the server supports it.

## Workflow

### 1. Inspect before downloading

1. List available formats first — never guess a format code.
2. Check the title, duration, and filesize before starting a large download.
3. Confirm the output folder exists and has enough free space.

```bash
yt-dlp -F "https://example.com/watch?v=VIDEO_ID"
yt-dlp --get-title --get-duration --get-format "https://example.com/watch?v=VIDEO_ID"
```

### 2. Pick quality correctly

1. Prefer a combined format when available: `-f "bestvideo+bestaudio/best"`.
2. Cap the height explicitly when the user names a quality: `-f "bv*[height<=720]+ba/best"`.
3. For audio only, use `-x --audio-format mp3 --audio-quality 0`.
4. For a small file, cap the total size: `-f "best[filesize<500M]/best"`.
5. Always merge to MP4 for maximum compatibility: `--remux-video mp4 --recode-video mp4`.

```bash
yt-dlp -f "bestvideo+bestaudio/best" --remux-video mp4 -o "%(title)s.%(ext)s" "URL"
yt-dlp -f "bv*[height<=1080]+ba/best" -o "%(title)s [%(height)sp].%(ext)s" "URL"
yt-dlp -x --audio-format mp3 --audio-quality 0 -o "%(title)s.%(ext)s" "URL"
```

### 3. Download a playlist

1. Download the whole playlist with one command; do not loop URLs by hand.
2. Number files so order survives renaming: `-o "%(playlist_index)02d - %(title)s.%(ext)s"`.
3. Skip already-downloaded items with `--download-archive downloaded.txt`.
4. Limit a test run to the first item: `--playlist-items 1`.

```bash
yt-dlp --download-archive downloaded.txt -o "%(playlist_index)02d - %(title)s.%(ext)s" "PLAYLIST_URL"
```

### 4. Subtitles and metadata

1. Download subtitles with `--write-subs --sub-langs en,bn --embed-subs`.
2. Add a thumbnail and metadata with `--embed-thumbnail --add-metadata`.
3. Auto-generate subtitles only when no uploaded captions exist: `--write-auto-subs`.

```bash
yt-dlp --write-subs --sub-langs en,bn --embed-subs --embed-thumbnail --add-metadata "URL"
```

### 5. Download an HLS / m3u8 stream with ffmpeg

1. Prefer `yt-dlp` for m3u8 URLs first — it handles variants and retries.
2. Use `ffmpeg` directly when yt-dlp cannot parse the playlist.
3. Copy the streams without re-encoding (`-c copy`) to keep quality and speed.
4. Add `-reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 5` for flaky streams.
5. If the stream has separate audio and video playlists, download both and mux them.

```bash
yt-dlp "https://example.com/stream.m3u8" -o "video.mp4"
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 5 -i "https://example.com/stream.m3u8" -c copy video.mp4
ffmpeg -i video.m3u8 -i audio.m3u8 -c copy -map 0:v:0 -map 1:a:0 output.mp4
```

### 6. Concatenate segments or parts

1. For HLS segments already on disk, list them in a text file in play order.
2. Use the concat demuxer with `-c copy` — never re-encode just to join files.
3. Verify the output duration matches the sum of the parts.

```bash
printf "file 'part1.ts'\nfile 'part2.ts'\nfile 'part3.ts'\n" > parts.txt
ffmpeg -f concat -safe 0 -i parts.txt -c copy output.mp4
ffprobe -v error -show_entries format=duration -of csv=p=0 output.mp4
```

### 7. Resume an interrupted download

1. Re-run the exact same yt-dlp command — it resumes automatically by default.
2. For a direct ffmpeg HLS download, restart it; HLS has no byte-range resume.
3. If yt-dlp reports the file is already complete, verify it plays before deleting.
4. If a download keeps failing, add `--retries 10 --fragment-retries 10`.

```bash
yt-dlp -f "bestvideo+bestaudio/best" --retries 10 --fragment-retries 10 "URL"
```

## Quality Picker (Decision Table)

| User says | Command flag |
|---|---|
| Best quality | `-f "bestvideo+bestaudio/best"` |
| 1080p max | `-f "bv*[height<=1080]+ba/best"` |
| 720p max | `-f "bv*[height<=720]+ba/best"` |
| 480p / small file | `-f "bv*[height<=480]+ba/best"` |
| Audio only | `-x --audio-format mp3` |
| Smallest usable | `-f "worstvideo+worstaudio/worst"` |

## Checklist Before Reporting Done

- [ ] Format list checked before downloading; no guessed format codes.
- [ ] Output file exists, has a non-zero size, and plays from start to finish.
- [ ] Resolution and duration match what the user asked for.
- [ ] Subtitles embedded when requested.
- [ ] Playlist archive updated so a re-run skips finished items.
- [ ] Rights check done: own, public-domain, or explicitly allowed content only.

## Pitfalls

- Downloading without `-F` first and getting a 144p file or audio-only file.
- Re-encoding with ffmpeg when `-c copy` would preserve quality and finish faster.
- Concatenating files with different codecs — remux them to one codec first.
- Assuming an HLS download can resume like a normal file download; it cannot.
- Ignoring the legal note: downloading copyrighted or DRM-protected content.
- Overwriting a good file by re-running without `--download-archive` on playlists.
