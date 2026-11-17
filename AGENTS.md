# Working in this repo

This repo holds agent skills. Read `README.md` for layout and install steps.

- One skill per folder in `skills/`. The folder name must equal the `name:` in its `SKILL.md`.
- The `description:` decides when an agent loads the skill, so name concrete triggers.
- Start new skills from `skills/_template/`.
- Run `scripts/validate.sh` before committing. CI runs it too.
- Don't edit installed copies under `~/.claude/skills` or `~/.codex/skills`. They're symlinks back here.
- After adding or removing a skill, run `./install.sh`.
