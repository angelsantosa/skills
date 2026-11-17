#!/usr/bin/env bash
# One-shot setup on a fresh machine: clone (or update) this repo, then install.
#
#   gh api repos/angelsantosa/skills/contents/bootstrap.sh -H 'Accept: application/vnd.github.raw' | bash
#
# Env: SKILLS_DIR (clone location, default ~/.local/share/skills). Extra args go to install.sh.
set -euo pipefail

REPO="angelsantosa/skills"
DIR="${SKILLS_DIR:-$HOME/.local/share/skills}"

if [ -d "$DIR/.git" ]; then
  git -C "$DIR" pull --ff-only --quiet
elif command -v gh >/dev/null 2>&1; then
  gh repo clone "$REPO" "$DIR" -- --quiet
else
  git clone --quiet "git@github.com:$REPO.git" "$DIR"
fi

exec "$DIR/install.sh" "$@"
