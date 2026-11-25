#!/usr/bin/env bash
# validate-skills.sh — validate the ai-agent-skills repo.
# Checks every skills/*/SKILL.md for frontmatter (name + description),
# name matches folder, description starts with "Use when", skills.json
# parses and lists exactly the same skill names, and every referenced
# scripts/*.sh exists and passes bash -n.
# Exits 0 only when every check passes.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
SKILLS_DIR="$REPO_DIR/skills"
PASS=0
FAIL=0

ok()   { PASS=$((PASS + 1)); echo "PASS  $1"; }
bad()  { FAIL=$((FAIL + 1)); echo "FAIL  $1"; }

# --- 1. Every skill folder has a SKILL.md with valid frontmatter ------------
for d in "$SKILLS_DIR"/*/; do
  [ -d "$d" ] || continue
  skill="$(basename "$d")"
  file="$d/SKILL.md"
  if [ ! -f "$file" ]; then
    bad "$skill: missing SKILL.md"
    continue
  fi
  # Frontmatter must open with --- on line 1 and close with ---.
  if [ "$(sed -n '1p' "$file")" != "---" ]; then
    bad "$skill: SKILL.md does not start with --- frontmatter"
    continue
  fi
  if ! awk 'NR==1{next} /^---$/{found=1; exit} END{exit !found}' "$file"; then
    bad "$skill: SKILL.md frontmatter never closes"
    continue
  fi
  front="$(awk 'NR>1 && /^---$/{exit} NR>1{print}' "$file")"
  name="$(printf '%s\n' "$front" | sed -n 's/^name: *//p' | head -1)"
  desc="$(printf '%s\n' "$front" | sed -n 's/^description: *//p' | head -1)"
  if [ -z "$name" ]; then
    bad "$skill: frontmatter has no name"
  elif [ "$name" != "$skill" ]; then
    bad "$skill: frontmatter name '$name' does not match folder"
  elif [ -z "$desc" ]; then
    bad "$skill: frontmatter has no description"
  elif ! printf '%s' "$desc" | grep -q '^Use when'; then
    bad "$skill: description does not start with 'Use when'"
  else
    ok "$skill: frontmatter valid (name matches, description starts 'Use when')"
  fi
done

# --- 2. skills.json parses and lists exactly the same names ------------------
MANIFEST="$REPO_DIR/skills.json"
if [ ! -f "$MANIFEST" ]; then
  bad "skills.json: missing"
else
  if ! python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$MANIFEST" 2>/dev/null; then
    bad "skills.json: does not parse as JSON"
  else
    ok "skills.json: parses as JSON"
    folders="$(for d in "$SKILLS_DIR"/*/; do basename "$d"; done | sort | tr '\n' ' ' | sed 's/ *$//')"
    listed="$(python3 -c "
import json
m = json.load(open('$MANIFEST'))
print(' '.join(sorted(s['name'] for s in m.get('skills', []))))")"
    if [ "$folders" = "$listed" ]; then
      ok "skills.json: lists exactly the skill folders ($(echo "$listed" | wc -w) skills)"
    else
      bad "skills.json: names differ — folders: $folders ; listed: $listed"
    fi
    # Every manifest entry must have name, description, path; path must exist.
    python3 - "$MANIFEST" "$SKILLS_DIR" <<'PYEOF' || bad "skills.json: an entry is missing name/description/path or its path does not exist"
import json, os, sys
m = json.load(open(sys.argv[1]))
skills_dir = sys.argv[2]
for s in m.get("skills", []):
    assert s.get("name") and s.get("description") and s.get("path"), s
    assert os.path.isdir(os.path.join(skills_dir, s["name"])), s["name"]
    assert s["path"] == "skills/" + s["name"], s
print("manifest entries complete")
PYEOF
    [ "$FAIL" -eq 0 ] && ok "skills.json: every entry has name/description/path and the path exists"
  fi
fi

# --- 3. Every scripts/*.sh exists where referenced and passes bash -n -------
while IFS= read -r -d '' script; do
  rel="${script#$REPO_DIR/}"
  if bash -n "$script" 2>/dev/null; then
    ok "$rel: bash -n passes"
  else
    bad "$rel: bash -n fails"
  fi
  if [ -x "$script" ]; then
    ok "$rel: executable"
  else
    bad "$rel: not executable"
  fi
done < <(find "$SKILLS_DIR" "$REPO_DIR/scripts" -name '*.sh' -print0 2>/dev/null)

# --- 4. No forbidden placeholder text ----------------------------------------
# Word-boundary match (-w): real identifiers such as Electron's
# autoUpdater.autoDownload must not trip the check.
if grep -rniEw 'TODO|FIXME|Original repo' "$REPO_DIR/skills" "$MANIFEST" "$REPO_DIR/README.md" >/dev/null 2>&1; then
  bad "forbidden text found (TODO/FIXME/Original repo)"
else
  ok "no TODO/FIXME/'Original repo' text in skills, manifest or README"
fi

echo ""
echo "Validate: $PASS passed, $FAIL failed."
[ "$FAIL" -eq 0 ]
