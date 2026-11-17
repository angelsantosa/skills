#!/usr/bin/env bash
# One-shot setup on a fresh machine: clone (or update) this repo, then install.
#
#   curl -fsSL https://raw.githubusercontent.com/angelsantosa/skills/main/bootstrap.sh | bash
#
# Env: SKILLS_DIR (clone location, default ~/.local/share/skills). Extra args go to install.sh.
set -euo pipefail

REPO="angelsantosa/skills"
DIR="${SKILLS_DIR:-$HOME/.local/share/skills}"

if [ -d "$DIR/.git" ]; then
  git -C "$DIR" pull --ff-only --quiet
else
  git clone --quiet "https://github.com/$REPO.git" "$DIR"
fi

exec "$DIR/install.sh" "$@"
