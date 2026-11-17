#!/usr/bin/env bash
# Check every skill has a SKILL.md with frontmatter `name` (matching its folder) and `description`.
set -euo pipefail
cd "$(dirname "$0")/../skills"
fail=0
for d in */; do
  name="${d%/}"; f="$name/SKILL.md"
  [ -f "$f" ] || { echo "✗ $name: missing SKILL.md"; fail=1; continue; }
  [ "$(head -1 "$f")" = "---" ] || { echo "✗ $name: no frontmatter"; fail=1; continue; }
  fm="$(awk 'NR==1{next} /^---$/{exit} {print}' "$f")"
  fm_name="$(printf '%s\n' "$fm" | sed -n 's/^name: *//p')"
  case "$name" in _*) ;; *)
    [ "$fm_name" = "$name" ] || { echo "✗ $name: frontmatter name '$fm_name' != folder"; fail=1; } ;;
  esac
  printf '%s\n' "$fm" | grep -q '^description: *.\+' || { echo "✗ $name: missing description"; fail=1; }
done
[ "$fail" = 0 ] && echo "✓ all skills valid"
exit "$fail"
