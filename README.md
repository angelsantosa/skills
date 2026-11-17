# skills

Personal agent skills for Claude Code and Codex: PR babysitting, end-to-end orchestration, and more.

Each skill is a folder under `skills/` with a `SKILL.md` (YAML frontmatter `name` + `description`, then instructions). Folders starting with `_` (like `_template`) are never installed.

| Skill | Purpose |
|---|---|
| `babysit-prs` | Shepherd PRs to green (skeleton) |
| `orchestrate-work` | Plan → delegate → review → fix → merge (skeleton) |

## Install

### For agents (non-interactive)

Run these exactly. Every step is idempotent and needs no prompts.

```bash
# 1. Clone or update, then install (public repo: only git and bash needed)
DIR="${SKILLS_DIR:-$HOME/.local/share/skills}"
if [ -d "$DIR/.git" ]; then git -C "$DIR" pull --ff-only; else git clone https://github.com/angelsantosa/skills.git "$DIR"; fi
"$DIR/install.sh"

# 2. Verify
"$DIR/install.sh" --list
ls -la ~/.claude/skills ~/.codex/skills
```

Exit code `0` means installed. `2` means a target already has a same-named skill that this repo doesn't manage. Report it to the user; rerun with `--force` only if they approve (the existing entry is backed up as `<name>.bak.<timestamp>`).

One-liner equivalent:

```bash
curl -fsSL https://raw.githubusercontent.com/angelsantosa/skills/main/bootstrap.sh | bash
```

### What it does

`install.sh` symlinks each `skills/<name>` into:

- `~/.claude/skills/` (Claude Code)
- `~/.codex/skills/` and `~/.agents/skills/` (Codex)

Because they're symlinks, `git pull` updates every agent at once. Rerun `install.sh` only after adding or removing a skill. Start a new agent session to pick up changes.

| Option | Effect |
|---|---|
| `--dry-run` | Show changes without making them |
| `--list` | List installable skills |
| `--copy` | Copy instead of symlink (filesystems without symlinks) |
| `--force` | Replace conflicting entries (backed up first) |
| `--uninstall` | Remove only links pointing into this repo |
| `SKILLS_TARGETS="a:b"` | Override target directories |

### Updating

```bash
git -C "${SKILLS_DIR:-$HOME/.local/share/skills}" pull --ff-only && "${SKILLS_DIR:-$HOME/.local/share/skills}/install.sh"
```

## Adding a skill

```bash
cp -R skills/_template skills/my-skill   # set `name: my-skill` in its SKILL.md
scripts/validate.sh
./install.sh
```
