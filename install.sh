#!/usr/bin/env bash
# install.sh — install ai-agent-skills into Claude Code, Codex, Cursor and OpenCode.
# Usage:
#   ./install.sh                 install all skills into every agent dir found
#   ./install.sh --list          list skills, install nothing
#   ./install.sh --skill <name>  install one skill only
#   ./install.sh --dry-run       show what would happen, change nothing
#   ./install.sh --dest <dir>    install into a custom skills directory
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/skills"
DRY_RUN=0
ONLY_SKILL=""
CUSTOM_DEST=""

# Agent skills directories, in priority order.
DESTS=(
  "$HOME/.claude/skills"
  "$HOME/.codex/skills"
  "$HOME/.cursor/skills"
  "$HOME/.config/opencode/skills"
)

list_skills() {
  for d in "$SRC_DIR"/*/; do
    [ -f "$d/SKILL.md" ] || continue
    basename "$d"
  done | sort
}

usage() {
  echo "Usage: $0 [--list] [--skill <name>] [--dry-run] [--dest <dir>]"
  echo ""
  echo "  --list          list available skills and exit"
  echo "  --skill <name>  install only this skill"
  echo "  --dry-run       show what would be installed, change nothing"
  echo "  --dest <dir>    install into a custom skills directory"
  exit 0
}

while [ $# -gt 0 ]; do
  case "$1" in
    --list) list_skills; exit 0 ;;
    --skill) ONLY_SKILL="${2:-}"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --dest) CUSTOM_DEST="${2:-}"; shift 2 ;;
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

INSTALLED=0
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
      rm -rf "$target"
      cp -r "$SRC_DIR/$skill" "$target"
      echo "Installed $skill -> $target"
    fi
    INSTALLED=$((INSTALLED + 1))
  done
done

if [ "$DRY_RUN" -eq 1 ]; then
  echo "Dry run: $INSTALLED skill copies planned, nothing changed."
elif [ "$INSTALLED" -eq 0 ]; then
  echo "No agent skills directory found."
  echo "Install Claude Code, Codex, Cursor or OpenCode first, or use --dest <dir>:"
  echo "  ./install.sh --dest ~/.claude/skills"
  exit 1
else
  echo "Done: $INSTALLED skill copies installed."
  echo "Restart your agent (or start a new session) and describe a task — it will load the matching skill."
fi
