#!/usr/bin/env bash
# install.sh — install ai-agent-skills into Claude Code, Codex, Cursor,
# Gemini CLI and OpenCode.
# Usage:
#   ./install.sh                 install all skills into every agent dir found
#   ./install.sh --list          list skills, install nothing
#   ./install.sh --skill <name>  install one skill only
#   ./install.sh --dry-run       show what would happen, change nothing
#   ./install.sh --dest <dir>    install into a custom skills directory
#   ./install.sh --verify        check installed skills have valid SKILL.md
#   ./install.sh --uninstall     remove only the skills this pack installed
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/skills"
DRY_RUN=0
ONLY_SKILL=""
CUSTOM_DEST=""
DO_VERIFY=0
DO_UNINSTALL=0

# Agent skills directories, in priority order.
DESTS=(
  "$HOME/.claude/skills"
  "$HOME/.codex/skills"
  "$HOME/.cursor/skills"
  "$HOME/.gemini/skills"
  "$HOME/.config/opencode/skills"
)

list_skills() {
  for d in "$SRC_DIR"/*/; do
    [ -f "$d/SKILL.md" ] || continue
    basename "$d"
  done | sort
}

usage() {
  echo "Usage: $0 [--list] [--skill <name>] [--dry-run] [--dest <dir>] [--verify] [--uninstall]"
  echo ""
  echo "  --list          list available skills and exit"
  echo "  --skill <name>  install only this skill"
  echo "  --dry-run       show what would be installed, change nothing"
  echo "  --dest <dir>    install into a custom skills directory"
  echo "  --verify        check installed skills, report OK/MISSING per agent dir"
  echo "  --uninstall     remove only the skills this pack installed"
  exit 0
}

# A skill copy counts as "ours" if it carries our marker file.
MARKER=".ai-agent-skills"

while [ $# -gt 0 ]; do
  case "$1" in
    --list) list_skills; exit 0 ;;
    --skill) ONLY_SKILL="${2:-}"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --dest) CUSTOM_DEST="${2:-}"; shift 2 ;;
    --verify) DO_VERIFY=1; shift ;;
    --uninstall) DO_UNINSTALL=1; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1" >&2; usage ;;
  esac
done

if [ -n "$ONLY_SKILL" ]; then
  if [ ! -f "$SRC_DIR/$ONLY_SKILL/SKILL.md" ]; then
    echo "Error: no skill named '$ONLY_SKILL'." >&2
    echo "Available skills:" >&2
    list_skills >&2
    exit 1
  fi
  SKILLS=("$ONLY_SKILL")
else
  mapfile -t SKILLS < <(list_skills)
fi

if [ ${#SKILLS[@]} -eq 0 ]; then
  echo "Error: no skills found in $SRC_DIR" >&2
  exit 1
fi

# Resolve destinations: custom dest wins; otherwise every known agent dir.
TARGETS=()
if [ -n "$CUSTOM_DEST" ]; then
  TARGETS=("$CUSTOM_DEST")
else
  for d in "${DESTS[@]}"; do
    TARGETS+=("$d")
  done
fi

# --- --verify: check installed copies, change nothing -----------------------
if [ "$DO_VERIFY" -eq 1 ]; then
  FAIL=0
  CHECKED=0
  for dest in "${TARGETS[@]}"; do
    [ -d "$dest" ] || continue
    for skill in "${SKILLS[@]}"; do
      CHECKED=$((CHECKED + 1))
      target="$dest/$skill"
      if [ -f "$target/SKILL.md" ] \
        && grep -q '^name: '"$skill"'$' "$target/SKILL.md" \
        && grep -q '^description: Use when' "$target/SKILL.md"; then
        echo "OK      $skill  ($dest)"
      else
        echo "MISSING $skill  ($dest)"
        FAIL=$((FAIL + 1))
      fi
    done
  done
  if [ "$CHECKED" -eq 0 ]; then
    echo "No agent skills directory found to verify."
    echo "Install Claude Code, Codex, Cursor, Gemini CLI or OpenCode first, or use --dest <dir>."
    exit 1
  fi
  echo "Verify: $((CHECKED - FAIL)) OK, $FAIL MISSING out of $CHECKED checks."
  [ "$FAIL" -eq 0 ]
  exit $?
fi

# --- --uninstall: remove only copies this pack installed --------------------
if [ "$DO_UNINSTALL" -eq 1 ]; then
  REMOVED=0
  SKIPPED=0
  for dest in "${TARGETS[@]}"; do
    [ -d "$dest" ] || continue
    for skill in "${SKILLS[@]}"; do
      target="$dest/$skill"
      if [ -f "$target/$MARKER" ]; then
        if [ "$DRY_RUN" -eq 1 ]; then
          echo "[dry-run] would remove $target"
        else
          rm -rf "$target"
          echo "Removed $skill from $dest"
        fi
        REMOVED=$((REMOVED + 1))
      elif [ -d "$target" ]; then
        echo "Skipped $skill in $dest (no marker — not installed by this pack)"
        SKIPPED=$((SKIPPED + 1))
      fi
    done
  done
  echo "Uninstall: $REMOVED removed, $SKIPPED skipped (not ours)."
  exit 0
fi

# --- install -----------------------------------------------------------------
INSTALLED=0
BACKED_UP=0
for dest in "${TARGETS[@]}"; do
  # With no custom dest, only install into agent dirs that look installed
  # (parent dir exists) — don't create ~/.codex for someone who never used Codex.
  if [ -z "$CUSTOM_DEST" ] && [ ! -d "$(dirname "$dest")" ]; then
    continue
  fi
  for skill in "${SKILLS[@]}"; do
    target="$dest/$skill"
    if [ "$DRY_RUN" -eq 1 ]; then
      echo "[dry-run] would copy skills/$skill -> $target"
    else
      mkdir -p "$dest"
      # Back up an existing folder with the same name before overwriting it.
      if [ -d "$target" ] && [ ! -f "$target/$MARKER" ]; then
        mv "$target" "$target.bak"
        echo "Backed up existing $skill to $target.bak"
        BACKED_UP=$((BACKED_UP + 1))
      fi
      rm -rf "$target"
      cp -r "$SRC_DIR/$skill" "$target"
      touch "$target/$MARKER"
      chmod +x "$target"/scripts/*.sh 2>/dev/null || true
      echo "Installed $skill -> $target"
    fi
    INSTALLED=$((INSTALLED + 1))
  done
done

if [ "$DRY_RUN" -eq 1 ]; then
  echo "Dry run: $INSTALLED skill copies planned, nothing changed."
elif [ "$INSTALLED" -eq 0 ]; then
  echo "No agent skills directory found."
  echo "Install Claude Code, Codex, Cursor, Gemini CLI or OpenCode first, or use --dest <dir>:"
  echo "  ./install.sh --dest ~/.claude/skills"
  exit 1
else
  echo ""
  echo "Done: $INSTALLED skill copies installed ($BACKED_UP existing folders backed up to *.bak)."
  echo "Verify any time with:  ./install.sh --verify"
  echo "Remove with:           ./install.sh --uninstall"
  echo "Restart your agent (or start a new session) and describe a task — it will load the matching skill."
fi
