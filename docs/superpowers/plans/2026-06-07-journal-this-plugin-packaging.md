# journal-this Plugin Packaging Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Package the existing `journal-this` Claude Code skill as a versioned, installable plugin (v1.0.0) with a GitHub release, and round out the repo with polish files — without changing the skill's behavior.

**Architecture:** Restructure the repo into the Claude Code plugin layout (`.claude-plugin/` manifests + `skills/journal-this/` + a `commands/` shim), so the repo doubles as its own `journal-this` marketplace. Distribute two ways: the native plugin system (`/plugin marketplace add` → `/plugin install`) and a manual-install `.zip` attached to a tagged GitHub release. No npm.

**Tech Stack:** Claude Code plugin manifests (JSON), Markdown (skill/command/docs), `git`, `gh`, `zip`, `jq`. No application code, no test framework — verification is validation commands (`jq`, `grep`, `unzip -l`, file checks).

**Verification note (read first):** This is packaging work, so each task uses **write → verify → commit** instead of write-test-first. The "verify" step is a concrete command with expected output; treat a mismatch exactly like a failing test — stop and fix before committing.

**Outward-facing boundary:** Tasks 1–8 are local (safe to run fully). Tasks 9–10 push, open a PR, tag, create a release, and edit public repo metadata — **do not run them without explicit user go-ahead**, and run Task 10 against `main` *after the PR merges*.

**Working directory:** repo root of the worktree (`/Users/chris/journal-this/.claude/worktrees/dazzling-solomon-fe445e`). All paths below are relative to it. Current branch: `claude/dazzling-solomon-fe445e`.

**Commit trailer:** every commit in this plan ends with:
```
Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
```

---

## File structure (what this plan creates / moves / modifies)

```
.claude-plugin/
  plugin.json          CREATE — plugin manifest, holds version 1.0.0 + skill pointer
  marketplace.json     CREATE — repo is its own marketplace ("journal-this")
commands/
  journal-this.md      CREATE — typed-command shim, hands off to the skill
skills/
  journal-this/
    SKILL.md           MOVE   — from repo root (content unchanged)
    config.template.json MOVE — from repo root (kept beside SKILL.md)
CHANGELOG.md           CREATE — Keep-a-Changelog, v1.0.0 entry
CONTRIBUTING.md        CREATE — layout map, local-test + release checklist
.gitignore             CREATE — OS cruft + the build zip
README.md              MODIFY — full rewrite: badges, two install paths, new file list
LICENSE                (unchanged — already MIT © 2026 Chris Pelatari)
journal-this.zip       BUILD ARTIFACT (Task 8/10) — never committed (.gitignored)
```

Each task below produces a self-contained, independently sensible commit.

---

## Task 1: Restructure into the plugin layout

Move the skill files into `skills/journal-this/` (a plugin discovers skills under `skills/<name>/SKILL.md`). Use `git mv` to preserve history. `SKILL.md` and `config.template.json` move **together** so the "config.template.json in this skill folder" reference (SKILL.md line 50) stays valid.

**Files:**
- Move: `SKILL.md` → `skills/journal-this/SKILL.md`
- Move: `config.template.json` → `skills/journal-this/config.template.json`

- [ ] **Step 1: Create the target directory and move both files with history**

```bash
mkdir -p skills/journal-this
git mv SKILL.md skills/journal-this/SKILL.md
git mv config.template.json skills/journal-this/config.template.json
```

- [ ] **Step 2: Verify the new structure and that nothing else moved**

Run:
```bash
git status --short
ls skills/journal-this
```
Expected: `git status` shows two renames (`R  SKILL.md -> skills/journal-this/SKILL.md` and the config rename); `ls` lists exactly `SKILL.md` and `config.template.json`.

- [ ] **Step 3: Verify the load-bearing reference still resolves**

Run:
```bash
grep -n "this skill folder" skills/journal-this/SKILL.md
test -f skills/journal-this/config.template.json && echo "config template present beside SKILL.md"
```
Expected: line 50 prints the "See `config.template.json` in this skill folder…" sentence, and the second line prints `config template present beside SKILL.md`. (The reference is now satisfied because both files share the folder.)

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "$(cat <<'EOF'
refactor: move skill into skills/journal-this/ for plugin layout

Claude Code plugins discover skills under skills/<name>/SKILL.md.
SKILL.md and config.template.json move together so SKILL.md's
"config.template.json in this skill folder" reference stays valid.
No content changes.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 2: Add the plugin + marketplace manifests

Create `.claude-plugin/plugin.json` (version lives here) and `.claude-plugin/marketplace.json` (makes the repo its own marketplace). These are authored and reviewed together because their `version` must stay equal.

**Files:**
- Create: `.claude-plugin/plugin.json`
- Create: `.claude-plugin/marketplace.json`

- [ ] **Step 1: Create `.claude-plugin/plugin.json` with this exact content**

```json
{
  "name": "journal-this",
  "version": "1.0.0",
  "description": "Turn a Claude Code work session into a dated journal entry in your own voice, saved to a folder or GitHub repo.",
  "author": { "name": "Chris Pelatari" },
  "homepage": "https://github.com/BlueFenixProductions/journal-this",
  "repository": "https://github.com/BlueFenixProductions/journal-this",
  "license": "MIT",
  "keywords": ["journaling", "journal", "devlog", "engineering-journal", "claude-code", "skill", "writing"],
  "skills": ["./skills/journal-this"]
}
```

- [ ] **Step 2: Create `.claude-plugin/marketplace.json` with this exact content**

```json
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "journal-this",
  "owner": { "name": "Chris Pelatari" },
  "description": "Blue Fenix Productions — the journal-this Claude Code plugin.",
  "plugins": [
    {
      "name": "journal-this",
      "source": "./",
      "description": "Turn a Claude Code work session into a dated journal entry in your own voice, saved to a folder or GitHub repo.",
      "category": "productivity",
      "version": "1.0.0",
      "keywords": ["journaling", "claude-code", "skill", "devlog"]
    }
  ]
}
```

- [ ] **Step 3: Verify both files are valid JSON and versions match**

Run:
```bash
jq -e . .claude-plugin/plugin.json > /dev/null && echo "plugin.json OK"
jq -e . .claude-plugin/marketplace.json > /dev/null && echo "marketplace.json OK"
test "$(jq -r .version .claude-plugin/plugin.json)" = "$(jq -r '.plugins[0].version' .claude-plugin/marketplace.json)" && echo "versions match"
test "$(jq -r '.skills[0]' .claude-plugin/plugin.json)" = "./skills/journal-this" && echo "skill path OK"
```
Expected: `plugin.json OK`, `marketplace.json OK`, `versions match`, `skill path OK`.

- [ ] **Step 4: Commit**

```bash
git add .claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "$(cat <<'EOF'
feat: add plugin + marketplace manifests (v1.0.0)

Repo doubles as its own "journal-this" marketplace (source "./").
Version 1.0.0 recorded in both manifests; install reads
journal-this@journal-this.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 3: Add the `/journal-this` command shim

Plugin-provided skills are namespaced (`/journal-this:journal-this`). This thin command restores the advertised bare `/journal-this` (and `/journal-this setup`) and hands off to the skill — single source of truth stays `SKILL.md`. Commands are auto-discovered from `commands/`; no manifest entry needed.

**Files:**
- Create: `commands/journal-this.md`

- [ ] **Step 1: Create `commands/journal-this.md` with this exact content**

```markdown
---
description: Capture this session as a dated journal entry in your own voice (journal-this skill)
---

The user invoked `/journal-this`. They want to capture the current session as a dated journal entry, written in their own voice, using the **journal-this** skill.

Arguments (optional): $ARGUMENTS

- If `$ARGUMENTS` contains `setup`, run the journal-this **setup interview** to (re)configure the journal — operator name, voice source, and destination.
- Otherwise, run the journal-this skill's normal workflow to produce and file the entry.

Use the journal-this skill to do this — follow its instructions exactly; do not improvise a different journaling process.
```

- [ ] **Step 2: Verify the command file has frontmatter and the argument hook**

Run:
```bash
head -1 commands/journal-this.md
grep -c '\$ARGUMENTS' commands/journal-this.md
```
Expected: first line is `---` (frontmatter opens), and the grep count is `2` — `$ARGUMENTS` appears twice: in the arguments line and in the `setup` conditional. (The check's intent is "the placeholder is present"; any count ≥ 1 passes.)

- [ ] **Step 3: Commit**

```bash
git add commands/journal-this.md
git commit -m "$(cat <<'EOF'
feat: add /journal-this command shim

Plugin skills are namespaced (/journal-this:journal-this); this shim
restores the advertised bare /journal-this and /journal-this setup,
forwarding $ARGUMENTS and handing off to the skill (no forked workflow).

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 4: Add `.gitignore`

Ignore OS/editor cruft and the on-demand build zip so it's never committed.

**Files:**
- Create: `.gitignore`

- [ ] **Step 1: Create `.gitignore` with this exact content**

```gitignore
# OS / editor cruft
.DS_Store
Thumbs.db
*.log

# Release artifact — built on demand (see CONTRIBUTING.md) and attached to the
# GitHub release; never committed.
journal-this.zip
```

- [ ] **Step 2: Verify the build artifact is ignored**

Run:
```bash
touch journal-this.zip
git check-ignore journal-this.zip && echo "zip is ignored"
rm journal-this.zip
```
Expected: prints `journal-this.zip` then `zip is ignored`.

- [ ] **Step 3: Commit**

```bash
git add .gitignore
git commit -m "$(cat <<'EOF'
chore: add .gitignore for OS cruft and the build zip

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 5: Add `CHANGELOG.md`

Keep-a-Changelog format with the v1.0.0 entry dated today (2026-06-07).

**Files:**
- Create: `CHANGELOG.md`

- [ ] **Step 1: Create `CHANGELOG.md` with this exact content**

```markdown
# Changelog

All notable changes to **journal-this** are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-06-07

### Added
- Initial release of the **journal-this** Claude Code skill: turns the current
  session into a dated markdown journal entry in the Operator's own voice.
- First-run **setup interview** that records operator name, voice source, and
  destination to `~/.config/journal-this/config.json`.
- **Voice anchoring** — reads recent existing entries and replicates their
  structural skeleton (frontmatter, headings, footer) and prose style.
- **Disk and GitHub destinations**, including commit + push with multi-machine
  `pull --rebase` race handling and an optional PR push mode.
- Packaged as a **Claude Code plugin** — this repo doubles as its own
  marketplace and ships a `/journal-this` command — plus a **GitHub release
  zip** for manual drop-in installs.

[1.0.0]: https://github.com/BlueFenixProductions/journal-this/releases/tag/v1.0.0
```

- [ ] **Step 2: Verify the version heading and link reference exist**

Run:
```bash
grep -n "## \[1.0.0\] - 2026-06-07" CHANGELOG.md
grep -n "^\[1.0.0\]:" CHANGELOG.md
```
Expected: both greps return a matching line (the dated 1.0.0 heading and the link-reference footer).

- [ ] **Step 3: Commit**

```bash
git add CHANGELOG.md
git commit -m "$(cat <<'EOF'
docs: add CHANGELOG with v1.0.0 entry

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 6: Add `CONTRIBUTING.md`

Layout map, local-test instructions, and the maintainer release checklist (which encodes the real update mechanic: bump the version string, not just the tag). Also points curious readers at the design spec — the "worked example" value Chris wants from this repo.

**Files:**
- Create: `CONTRIBUTING.md`

- [ ] **Step 1: Create `CONTRIBUTING.md` with this exact content**

(The outer fence below is 4 backticks because the file content contains 3-backtick code blocks.)

````markdown
# Contributing to journal-this

Thanks for your interest! journal-this is a small, focused Claude Code plugin —
a single skill plus the manifests that distribute it. Contributions that keep it
sharp and well-documented are welcome.

## Repository layout

```
.claude-plugin/
  plugin.json          # plugin manifest (name, version, the skill it provides)
  marketplace.json     # this repo doubles as its own marketplace
commands/
  journal-this.md      # thin shim so you can type /journal-this
skills/
  journal-this/
    SKILL.md           # the skill itself — the source of truth for behavior
    config.template.json
CHANGELOG.md
README.md
docs/superpowers/specs/  # how this plugin was designed (a worked example)
```

The behavior lives entirely in `skills/journal-this/SKILL.md`. The command is a
thin entry point that hands off to the skill — keep it that way; don't fork the
workflow into two places.

## Testing your changes locally

Install the skill directly:

```bash
cp -R skills/journal-this ~/.claude/skills/journal-this   # Claude Code
```

…or exercise the full plugin path from your local clone:

```
/plugin marketplace add /absolute/path/to/your/clone
/plugin install journal-this@journal-this
```

If you already have a hand-installed copy at `~/.claude/skills/journal-this/`,
move it aside first so it doesn't shadow the plugin.

## Cutting a release (maintainers)

1. Bump `version` in **both** `.claude-plugin/plugin.json` and the plugin entry
   in `.claude-plugin/marketplace.json` (keep them equal).
2. Add a dated entry to `CHANGELOG.md`.
3. Commit, then tag and push the tag:
   ```bash
   git tag -a vX.Y.Z -m "journal-this vX.Y.Z"
   git push origin vX.Y.Z
   ```
4. Build the manual-install zip and attach it to a GitHub release:
   ```bash
   ( cd skills && zip -r ../journal-this.zip journal-this )
   gh release create vX.Y.Z journal-this.zip --title "vX.Y.Z" --notes-file <(sed -n '/## \[X.Y.Z\]/,/## \[/p' CHANGELOG.md)
   ```

Consumers pick up updates with `/plugin marketplace update journal-this` then
`/plugin update` — the `version` string drives updates, **not** the git tag.

## License

By contributing, you agree that your contributions are licensed under the
[MIT License](LICENSE).
````

- [ ] **Step 2: Verify the release checklist and layout are present**

Run:
```bash
grep -n "Cutting a release" CONTRIBUTING.md
grep -n "plugin update" CONTRIBUTING.md
```
Expected: both greps return a matching line.

- [ ] **Step 3: Commit**

```bash
git add CONTRIBUTING.md
git commit -m "$(cat <<'EOF'
docs: add CONTRIBUTING with layout map and release checklist

Records the real update mechanic (bump version string + /plugin update,
not the git tag) and points readers at the design spec.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 7: Rewrite `README.md`

Full rewrite: badge row, two install paths (plugin + manual), consistent "plugin that provides a skill" terminology, updated file list, and a versioning/contributing footer. Preserve the existing description and example verbatim (they're still accurate).

**Files:**
- Modify (full overwrite): `README.md`

- [ ] **Step 1: Overwrite `README.md` with this exact content**

(Outer fence is 4 backticks because the content contains 3-backtick code blocks.)

````markdown
# journal-this

[![Latest release](https://img.shields.io/github/v/release/BlueFenixProductions/journal-this?sort=semver)](https://github.com/BlueFenixProductions/journal-this/releases)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Claude Code plugin](https://img.shields.io/badge/Claude%20Code-plugin-d97757.svg)](#install)

A Claude Code **plugin** that provides the `journal-this` **skill** — it turns the current session into a dated markdown journal entry, written in *your* voice, saved to *your* journal (a local folder or a GitHub repo).

It's the generalized, shareable version of a personal engineering-journal workflow: read the conversation, find what actually moved, write it up the way you'd write it, and file it (commit + push for GitHub destinations, handling the multi-machine pull–rebase race).

## Install

### Option A — Plugin (recommended)

Versioned and updatable through Claude Code's plugin system:

```
/plugin marketplace add BlueFenixProductions/journal-this
/plugin install journal-this@journal-this
```

Update later with `/plugin marketplace update journal-this` then `/plugin update`.

### Option B — Manual drop-in

Download `journal-this.zip` from the [latest release](https://github.com/BlueFenixProductions/journal-this/releases/latest) and unzip it into your skills directory:

```bash
unzip journal-this.zip -d ~/.claude/skills/      # Claude Code
unzip journal-this.zip -d ~/.agents/skills/      # Codex
```

## Use

Type `/journal-this` (or just say **"journal this"**) at the end of a work session — it also offers to journal proactively when a substantial session winds down.

- **First run** walks you through a one-time setup interview: your name, where your existing writing lives (so it learns your voice), and where entries should go. It saves your answers to `~/.config/journal-this/config.json`.
- **Every run after that** reads that config, anchors on a couple of your recent entries, writes the new entry, and files it.

Re-run the interview any time with `/journal-this setup`.

## Example

**First run — the setup interview:**

```
You:  /journal-this
Claude:  No config yet — let's set up your journal (takes 30 seconds).
         1. Whose journal is this? → Dana
         2. Where does your existing writing live, so I can match your voice?
            (local folder / GitHub repo / paste / none) → ~/devlog/entries
         3. Save entries to a plain folder or a GitHub repo? → GitHub repo
            • local clone path? → ~/devlog
            • subdirectory? → entries
            • branch / remote? → main / origin
            • push directly or open a PR? → directly
         4. Filename pattern? → (default) YYYY-MM-DD-kebab-slug.md
         5. Add a co-author trailer to commits? → default Claude trailer

         Saved to ~/.config/journal-this/config.json. You're set — next time
         just say "journal this".
```

**Every run after that — journaling a session:**

```
You:  journal this
Claude:  Read your 2 most recent entries to anchor voice.
         Wrote: ~/devlog/entries/2026-06-07-oauth-token-refresh-race.md
         Commit a1b9f3c → pushed 4e21d0a..a1b9f3c  main -> main
```

The entry comes out in your voice and house style (it reproduces the frontmatter,
headings, and structure your existing entries use), summarizing what actually moved
in the session — what shipped, what broke, what's deferred — not a generic recap.

## What's in the box

```
.claude-plugin/
  plugin.json            # plugin manifest — this is what makes it installable
  marketplace.json       # the repo doubles as its own marketplace
commands/
  journal-this.md        # the /journal-this command (hands off to the skill)
skills/
  journal-this/
    SKILL.md             # the skill itself — the only file a manual install needs
    config.template.json # documents every config field; setup creates the real one
CHANGELOG.md
CONTRIBUTING.md
LICENSE
```

The manual-install `journal-this.zip` contains just the `skills/journal-this/` folder — `SKILL.md` + `config.template.json` — so it unzips straight into `~/.claude/skills/journal-this/`.

## Versioning & contributing

Releases follow [Semantic Versioning](https://semver.org); see [CHANGELOG.md](CHANGELOG.md). Contributions welcome — see [CONTRIBUTING.md](CONTRIBUTING.md). Curious how this plugin was designed? The spec lives in [`docs/superpowers/specs/`](docs/superpowers/specs/).

## License

MIT — see [LICENSE](LICENSE).
````

- [ ] **Step 2: Verify the rewrite — both install paths, new terminology, no stale references**

Run:
```bash
grep -n "plugin install journal-this@journal-this" README.md
grep -n "unzip journal-this.zip -d ~/.claude/skills/" README.md
grep -n "img.shields.io/github/v/release" README.md
grep -c "the only required file" README.md
```
Expected: the first three greps each return a matching line (plugin install command, manual unzip command, dynamic release badge). The fourth returns `0` — the old README's "the only required file" phrasing is gone (replaced by the new file list).

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "$(cat <<'EOF'
docs: rewrite README for plugin + release install

Badge row, two install paths (plugin install + manual zip), consistent
"plugin that provides the journal-this skill" terminology, updated file
list, and a versioning/contributing footer.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 8: Local verification (full pre-PR checklist)

Run the complete §8 automated checklist from the spec and build the release zip in `/tmp` to confirm its shape. No commit — this produces evidence the branch is correct.

**Files:** none modified.

- [ ] **Step 1: Validate manifests, structure, and the moved reference**

Run:
```bash
jq -e . .claude-plugin/plugin.json > /dev/null && echo "plugin.json valid"
jq -e . .claude-plugin/marketplace.json > /dev/null && echo "marketplace.json valid"
test "$(jq -r .version .claude-plugin/plugin.json)" = "1.0.0" && echo "plugin version 1.0.0"
test -f skills/journal-this/SKILL.md && echo "SKILL.md in place"
head -4 skills/journal-this/SKILL.md | grep -q "^name: journal-this" && echo "SKILL.md frontmatter intact"
test -f commands/journal-this.md && echo "command present"
grep -q "this skill folder" skills/journal-this/SKILL.md && echo "config reference resolves"
```
Expected: `plugin.json valid`, `marketplace.json valid`, `plugin version 1.0.0`, `SKILL.md in place`, `SKILL.md frontmatter intact`, `command present`, `config reference resolves`.

- [ ] **Step 2: Build the release zip in /tmp and confirm its contents**

Run:
```bash
rm -f /tmp/journal-this.zip
( cd skills && zip -r /tmp/journal-this.zip journal-this )
unzip -l /tmp/journal-this.zip
```
Expected: the archive lists exactly `journal-this/SKILL.md` and `journal-this/config.template.json` (plus the `journal-this/` dir entry). It must **not** contain `.claude-plugin/`, `commands/`, or any doc files.

- [ ] **Step 3: Assert the zip shape programmatically**

Run:
```bash
unzip -Z1 /tmp/journal-this.zip | sort | grep -vE '/$' > /tmp/zip-files.txt
cat /tmp/zip-files.txt
test "$(cat /tmp/zip-files.txt)" = "$(printf 'journal-this/SKILL.md\njournal-this/config.template.json' | sort)" && echo "ZIP SHAPE OK"
```
Expected: `/tmp/zip-files.txt` contains only the two skill files, then `ZIP SHAPE OK` prints.

- [ ] **Step 4: Check README badge/link targets resolve (network)**

Run:
```bash
curl -sI "https://img.shields.io/github/v/release/BlueFenixProductions/journal-this?sort=semver" | head -1
curl -sI "https://img.shields.io/badge/license-MIT-green.svg" | head -1
```
Expected: each returns `HTTP/2 200` (the shields endpoints respond; the release badge will render "no releases" until Task 10, which is expected and not an error). If offline, skip this step and note it.

- [ ] **Step 5: Confirm the tree and clean working state**

Run:
```bash
git status --short
git log --oneline -7
find . -type f -not -path './.git/*' -not -path './.remember/*' | sort
```
Expected: `git status` is clean (all tasks committed); the log shows Tasks 1–7's commits; the file list shows the new layout (`.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `commands/journal-this.md`, `skills/journal-this/SKILL.md`, `skills/journal-this/config.template.json`, `CHANGELOG.md`, `CONTRIBUTING.md`, `.gitignore`, `README.md`, `LICENSE`, and the `docs/superpowers/` spec + plan) and **no** `SKILL.md`/`config.template.json` at the repo root.

---

## Task 9: Push branch and open the PR  ⚠️ GATED

**Do not run without explicit user go-ahead** (pushing is outward-facing). Opens a PR from `claude/dazzling-solomon-fe445e` into `main`.

**Files:** none modified.

- [ ] **Step 1: Confirm authorization**

Confirm the user has said to push/open the PR. If not, stop here and report that Tasks 1–8 are complete and the branch is ready.

- [ ] **Step 2: Push the branch**

Run:
```bash
git push -u origin claude/dazzling-solomon-fe445e
```
Expected: branch publishes to `origin` without error.

- [ ] **Step 3: Open the PR**

Run:
```bash
gh pr create --repo BlueFenixProductions/journal-this --base main \
  --title "Package journal-this as a Claude Code plugin (v1.0.0)" \
  --body "$(cat <<'EOF'
Packages the `journal-this` skill as a versioned, installable Claude Code plugin and rounds out the repo.

## What changed
- Restructured into the plugin layout: `.claude-plugin/{plugin,marketplace}.json`, `commands/journal-this.md`, and the skill moved to `skills/journal-this/` (content unchanged).
- Repo doubles as its own `journal-this` marketplace → `/plugin install journal-this@journal-this`.
- Added `commands/journal-this.md` so typed `/journal-this` / `/journal-this setup` keep working under a plugin install.
- Polish: `CHANGELOG.md` (v1.0.0), `CONTRIBUTING.md`, `.gitignore`, README rewrite with badges + two install paths.
- Design + plan committed under `docs/superpowers/` as a worked example.

## Follow-up (post-merge)
- Tag `v1.0.0`, build `journal-this.zip` from `skills/journal-this/`, and attach it to a GitHub release.
- Set repo topics.
- Remove the hand-installed dev copy at `~/.claude/skills/journal-this/` to avoid double-registration.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```
Expected: prints the new PR URL.

- [ ] **Step 4: Report the PR URL to the user and stop for merge.**

---

## Task 10: Publish the release  ⚠️ GATED — run on `main` AFTER the PR merges

**Do not run without explicit user go-ahead.** These steps create a tag, a public release, and edit public repo metadata. Run them from an up-to-date `main` checkout so the release reflects merged code.

**Files:** none modified (produces an untracked build artifact).

- [ ] **Step 1: Confirm authorization and that the PR is merged**

Confirm the user approved publishing and that the PR merged. Then sync `main`:
```bash
git checkout main
git pull --ff-only origin main
```
Expected: `main` fast-forwards to include the merge.

- [ ] **Step 2: Verify the version on main, then tag and push**

Run:
```bash
test "$(jq -r .version .claude-plugin/plugin.json)" = "1.0.0" && echo "main has v1.0.0"
git tag -a v1.0.0 -m "journal-this v1.0.0"
git push origin v1.0.0
```
Expected: `main has v1.0.0`, then the tag pushes to `origin`.

- [ ] **Step 3: Build the release zip from main**

Run:
```bash
rm -f journal-this.zip
( cd skills && zip -r ../journal-this.zip journal-this )
unzip -l journal-this.zip
```
Expected: archive contains exactly `journal-this/SKILL.md` + `journal-this/config.template.json`. (It's `.gitignore`d, so it won't show in `git status`.)

- [ ] **Step 4: Create the GitHub release with the zip and CHANGELOG notes**

Run:
```bash
gh release create v1.0.0 journal-this.zip \
  --repo BlueFenixProductions/journal-this \
  --title "v1.0.0" \
  --notes "$(sed -n '/## \[1.0.0\]/,/^\[1.0.0\]:/p' CHANGELOG.md)"
```
Expected: prints the release URL; the `journal-this.zip` asset is attached.

- [ ] **Step 5: Set repo topics**

Run:
```bash
gh repo edit BlueFenixProductions/journal-this \
  --add-topic claude-code \
  --add-topic claude-code-plugin \
  --add-topic claude-skill \
  --add-topic journaling \
  --add-topic devlog \
  --add-topic engineering-journal
```
Expected: completes without error (topics now visible on the repo page).

- [ ] **Step 6: Smoke-test the published plugin (recommended)**

First neutralize the shadowing dev copy, then install from the published marketplace:
```bash
mv ~/.claude/skills/journal-this /tmp/journal-this-devcopy-backup 2>/dev/null || echo "(no dev copy to move)"
```
Then in Claude Code:
```
/plugin marketplace add BlueFenixProductions/journal-this
/plugin install journal-this@journal-this
```
Confirm: the skill is listed, typed `/journal-this` resolves, `/journal-this setup` reaches setup, and auto-activation still fires on a winding-down cue. When done, delete the backup (`rm -rf /tmp/journal-this-devcopy-backup`) or restore it.

- [ ] **Step 7: Report the release URL and verification results to the user.**

---

## Self-review

**Spec coverage** (each spec section → task):
- §2 distribution decision → Tasks 2, 9, 10. Typed-command UX → Task 3. Version 1.0.0 → Tasks 2, 5, 10. Marketplace name `journal-this` → Task 2. Polish extras → Tasks 4 (.gitignore), 5 (CHANGELOG), 6 (CONTRIBUTING), 7 (README badges), 10 (topics). Author name-only → Task 2.
- §3 layout → Tasks 1–7 collectively produce it; verified in Task 8 Step 5.
- §4.1–4.8 artifacts → Task 2 (4.1, 4.2), Task 7 (4.3), Task 5 (4.4), Task 6 (4.5), Task 4 (4.6), Task 10 (4.7), Task 3 (4.8).
- §5 release mechanics → Task 10 (+ zip build verified early in Task 8).
- §6 migration (`git mv`, adjacency) → Task 1.
- §7 outward-facing boundary → Tasks 9, 10 gated; Tasks 1–8 local.
- §8 verification → Task 8 (automated) + Task 10 Step 6 (manual smoke test).
- §9 edge cases → dev-copy shadow handled in Task 10 Step 6; LICENSE confirmed unchanged (File structure note); CC-version-dependent command form acknowledged in Task 3.
- §10 out of scope → no npm/CI/Codex-native tasks present. ✓ No gaps.

**Placeholder scan:** No "TBD/TODO/handle edge cases". The only angle-bracket tokens are real CLI placeholders inside CONTRIBUTING's generic release example (`vX.Y.Z`, `X.Y.Z`), which are intentionally generic *file content*, not plan gaps; the actual release commands in Task 10 use concrete `v1.0.0`. ✓

**Type/identifier consistency:** `journal-this` plugin name, `journal-this` marketplace name, `journal-this@journal-this` install string, `skills/journal-this/` path, `./skills/journal-this` manifest pointer, and `v1.0.0` tag are consistent across Tasks 2, 7, 9, 10 and the verification asserts. Zip is always built `( cd skills && zip -r … journal-this )` (Tasks 8, 10, CONTRIBUTING). ✓
