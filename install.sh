#!/usr/bin/env bash
# Install the skills in this repo for Claude Code and Codex.
#
# Non-interactive and idempotent: safe for an agent to run repeatedly.
# Each directory in skills/ (except names starting with "_") is symlinked into
# every target skills directory. Re-running picks up new skills; --uninstall
# removes only the links this repo created.
#
# Usage:
#   ./install.sh                 install into the default targets
#   ./install.sh --dry-run       show what would change
#   ./install.sh --copy          copy instead of symlink (e.g. Windows without WSL)
#   ./install.sh --force         replace conflicting non-managed entries (backed up)
#   ./install.sh --uninstall     remove links that point into this repo
#   ./install.sh --list          list the skills in this repo
#   SKILLS_TARGETS="dir1:dir2" ./install.sh   override target directories
#
# Exit codes: 0 ok, 1 usage error, 2 conflicts left unresolved.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$REPO_DIR/skills"
DEFAULT_TARGETS="$HOME/.claude/skills:$HOME/.codex/skills:$HOME/.agents/skills"
TARGETS="${SKILLS_TARGETS:-$DEFAULT_TARGETS}"

mode=install; copy=0; force=0; dry=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry=1 ;;
    --copy) copy=1 ;;
    --force) force=1 ;;
    --uninstall) mode=uninstall ;;
    --list) mode=list ;;
    -h|--help) sed -n '2,19p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 1 ;;
  esac
done

run() { if [ "$dry" = 1 ]; then echo "  [dry-run] $*"; else "$@"; fi; }

skills=()
for d in "$SRC_DIR"/*/; do
  name="$(basename "$d")"
  case "$name" in _*) continue ;; esac
  [ -f "$d/SKILL.md" ] || { echo "skip $name: no SKILL.md" >&2; continue; }
  skills+=("$name")
done

if [ "$mode" = list ]; then printf '%s\n' "${skills[@]}"; exit 0; fi

conflicts=0
IFS=':' read -r -a target_dirs <<< "$TARGETS"
for target in "${target_dirs[@]}"; do
  [ -n "$target" ] || continue
  echo "→ $target"

  if [ "$mode" = uninstall ]; then
    [ -d "$target" ] || continue
    for entry in "$target"/*; do
      if [ -L "$entry" ]; then
        case "$(readlink "$entry")" in "$SRC_DIR"/*) run rm "$entry"; echo "  removed $(basename "$entry")" ;; esac
      elif [ -f "$entry/.installed-from" ] && [ "$(cat "$entry/.installed-from")" = "$REPO_DIR" ]; then
        run rm -rf "$entry"; echo "  removed $(basename "$entry") (copy)"
      fi
    done
    continue
  fi

  run mkdir -p "$target"
  for name in "${skills[@]}"; do
    src="$SRC_DIR/$name"; dst="$target/$name"
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
      echo "  ok      $name"; continue
    fi
    if [ -e "$dst" ] || [ -L "$dst" ]; then
      managed=0
      [ -L "$dst" ] && case "$(readlink "$dst")" in "$SRC_DIR"/*) managed=1 ;; esac
      [ -f "$dst/.installed-from" ] && [ "$(cat "$dst/.installed-from")" = "$REPO_DIR" ] && managed=1
      if [ "$managed" = 0 ] && [ "$force" = 0 ]; then
        echo "  CONFLICT $name: $dst exists and is not managed by this repo (use --force)" >&2
        conflicts=$((conflicts + 1)); continue
      fi
      if [ "$managed" = 0 ]; then
        backup="$dst.bak.$(date +%Y%m%d%H%M%S)"; run mv "$dst" "$backup"; echo "  backup  $name → $backup"
      else
        run rm -rf "$dst"
      fi
    fi
    if [ "$copy" = 1 ]; then
      run cp -R "$src" "$dst"
      [ "$dry" = 1 ] || echo "$REPO_DIR" > "$dst/.installed-from"
      echo "  copied  $name"
    else
      run ln -s "$src" "$dst"; echo "  linked  $name"
    fi
  done
done

if [ "$conflicts" -gt 0 ]; then echo "$conflicts conflict(s) left unresolved." >&2; exit 2; fi
echo "done."
