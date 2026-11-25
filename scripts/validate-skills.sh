#!/usr/bin/env bash
# validate-skills.sh — validate the ai-agent-skills repo.
# Checks every skill folder for valid frontmatter, name matches, both skill
# inventories match, referenced files exist, and shell scripts pass bash -n.
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
  # Shared references are repository resources, not installable skills.
  [ "$skill" = "references" ] && continue
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
  else
    ok "$skill: frontmatter valid (name matches, description exists)"
  fi
done

# --- 2. skills.json parses and lists exactly the same names ------------------
MANIFEST="$REPO_DIR/skills.json"
INVENTORY="$SKILLS_DIR/skills-inventory.json"
if [ ! -f "$MANIFEST" ]; then
  bad "skills.json: missing"
else
  if ! python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$MANIFEST" 2>/dev/null; then
    bad "skills.json: does not parse as JSON"
  else
    ok "skills.json: parses as JSON"
    folders="$(for d in "$SKILLS_DIR"/*/; do
      [ -d "$d" ] || continue
      [ "$(basename "$d")" = "references" ] && continue
      basename "$d"
    done | sort | tr '\n' ' ' | sed 's/ *$//')"
    listed="$(python3 -c "
import json
m = json.load(open('$MANIFEST'))
print(' '.join(sorted(s['name'] for s in m.get('skills', []))))")"
    if [ "$folders" = "$listed" ]; then
      ok "skills.json: lists exactly the skill folders ($(echo "$listed" | wc -w) skills)"
    else
      bad "skills.json: names differ — folders: $folders ; listed: $listed"
    fi
    # Validate manifest entries and the repository inventory, including its
    # shared reference paths.
    if [ ! -f "$INVENTORY" ]; then
      bad "skills/skills-inventory.json: missing"
    elif python3 - "$MANIFEST" "$SKILLS_DIR" "$INVENTORY" "$REPO_DIR/README.md" "$SKILLS_DIR/README.md" <<'PYEOF'
import json, os, re, sys
m = json.load(open(sys.argv[1]))
skills_dir = sys.argv[2]
inventory = json.load(open(sys.argv[3]))
readme_paths = sys.argv[4:]
manifest_skills = m.get("skills", [])
for s in manifest_skills:
    assert s.get("name") and s.get("description") and s.get("path"), s
    skill_dir = os.path.join(skills_dir, s["name"])
    assert os.path.isdir(skill_dir), s["name"]
    assert s["path"] == "skills/" + s["name"], s
    frontmatter = {}
    with open(os.path.join(skill_dir, "SKILL.md"), encoding="utf-8") as skill_file:
        for line in skill_file:
            line = line.rstrip("\n")
            if line == "---" and frontmatter:
                break
            if line.startswith(("name: ", "description: ")):
                key, value = line.split(": ", 1)
                frontmatter[key] = value
    assert frontmatter.get("name") == s["name"], s["name"]
    assert frontmatter.get("description") == s["description"], s["name"]
inventory_skills = inventory.get("skills", [])
assert len(inventory_skills) == len(set(inventory_skills)), \
    "inventory contains duplicate skill names"
assert sorted(inventory_skills) == sorted(s["name"] for s in manifest_skills), \
    "inventory skill names differ from skills.json"
references = inventory.get("references", [])
assert len(references) == len(set(references)), \
    "inventory contains duplicate reference paths"
for path in references:
    assert os.path.isfile(os.path.join(skills_dir, path)), path
expected_names = sorted(s["name"] for s in manifest_skills)
for readme_path in readme_paths:
    with open(readme_path, encoding="utf-8") as readme_file:
        contents = readme_file.read()
    listed_names = sorted(re.findall(r"^\| `([^`]+)` \|", contents, re.MULTILINE))
    assert listed_names == expected_names, \
        f"skill table in {readme_path} differs from skills.json"
with open(readme_paths[0], encoding="utf-8") as readme_file:
    assert f"Skills: {len(manifest_skills)}]" in readme_file.read(), \
        "README skill-count badge differs from skills.json"
print("manifest entries, inventory references and README skill lists complete")
PYEOF
    then
      ok "skills.json, inventory and README skill lists are valid"
    else
      bad "skills metadata or README lists differ, or a referenced path is invalid"
    fi
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
