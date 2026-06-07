# journal-this — packaging & release polish (design)

**Date:** 2026-06-07
**Branch:** `claude/dazzling-solomon-fe445e`
**Repo:** https://github.com/BlueFenixProductions/journal-this (public, default branch `main`, no releases yet)

## 1. Context & intent

`journal-this` is a **Claude Code skill** — pure markdown (`SKILL.md` + `config.template.json` + `README.md` + `LICENSE`). There is no executable, so the original framing ("add a `package.json` so it installs via `npm i -g`") is a category mismatch: a global npm package puts a binary on `PATH`, and we have no binary. The *real* intent behind that request is three things:

1. **A version number** — so releases are trackable.
2. **A one-step install** — easy for others to adopt.
3. **A downloadable `.zip` on GitHub** — the artifact the README already promises but that doesn't exist yet.

All three are delivered by the channels built for Claude Code skills, with no Node tooling.

## 2. Decision

- **Distribution:** native **Claude Code plugin** (the repo doubles as its own marketplace) **plus** a tagged **GitHub release** with a manual-install `.zip`. **No npm.**
- **Version:** **1.0.0** (feature-complete, documented; signals "stable, ready to depend on"). Recorded in `plugin.json`, the `marketplace.json` plugin entry, the git tag `v1.0.0`, and `CHANGELOG.md`. `SKILL.md` frontmatter stays version-free (matches every real skill example: name + description only).
- **Marketplace name:** **`bluefenix`** (brandable, room to add future plugins) → install reads `journal-this@bluefenix`.
- **Polish extras (all in):** `CHANGELOG.md`, README badges, root `.gitignore` + GitHub repo topics, `CONTRIBUTING.md`.
- **Author identity in manifests:** name only (`Chris Pelatari`), **no email** — the repo is public.

Conventions below were verified by reading working manifests on disk: `vue-development`, `karpathy-skills`, and Chris's own `local/signal` plugin.

## 3. Target repository layout

```
journal-this/                        ← repo root IS the plugin (marketplace source ".")
├── .claude-plugin/
│   ├── plugin.json                  ← NEW
│   └── marketplace.json             ← NEW (repo is its own marketplace)
├── skills/
│   └── journal-this/
│       ├── SKILL.md                 ← MOVED from root via `git mv` (content unchanged)
│       └── config.template.json     ← MOVED with it (kept adjacent — see §6)
├── CHANGELOG.md                     ← NEW
├── CONTRIBUTING.md                  ← NEW
├── .gitignore                       ← NEW
├── README.md                        ← install section rewritten
└── LICENSE                          ← unchanged
```

A plugin discovers skills under `skills/<name>/SKILL.md`, so the move is **required**, not cosmetic. The skill's behavior is unchanged.

## 4. Artifact specifications

### 4.1 `.claude-plugin/plugin.json`
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

### 4.2 `.claude-plugin/marketplace.json`
```json
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "bluefenix",
  "owner": { "name": "Chris Pelatari" },
  "description": "Blue Fenix Productions — Claude Code plugins",
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
`source: "./"` means "the plugin is this repo root" — verified against vue-development and karpathy-skills, which use the identical pattern with `.claude-plugin/` at root and `skills/<name>/` alongside.

### 4.3 `README.md` (rewrite)
- **Header:** title + badge row — version (`1.0.0`), license (MIT), and a "Claude Code plugin" shield. Static `img.shields.io/badge/...` badges (no CI dependency).
- **What it does:** keep the existing 2-paragraph description and voice.
- **Install — two options:**
  - **A. Plugin (recommended, versioned + updatable):**
    ```
    /plugin marketplace add BlueFenixProductions/journal-this
    /plugin install journal-this@bluefenix
    ```
  - **B. Manual drop-in (unchanged UX):** download `journal-this.zip` from the [Releases](https://github.com/BlueFenixProductions/journal-this/releases) page, then
    ```bash
    unzip journal-this.zip -d ~/.claude/skills/      # Claude Code
    unzip journal-this.zip -d ~/.agents/skills/      # Codex
    ```
- **Use / Example:** keep as-is (still accurate).
- **What's in the box:** update the "Files" section for the new layout (`.claude-plugin/`, `skills/journal-this/SKILL.md`, `config.template.json`, `CHANGELOG.md`, `CONTRIBUTING.md`).
- **Footer:** Versioning (link `CHANGELOG.md`), Contributing (link `CONTRIBUTING.md`), License.
- **Terminology fix:** consistently describe it as "a Claude Code **plugin** that provides the `journal-this` **skill**." Stop using "skill" and "plugin" interchangeably.

### 4.4 `CHANGELOG.md`
Keep-a-Changelog format. Single `## [1.0.0] - 2026-06-07` entry under `### Added`: the journaling workflow (voice-anchoring, setup interview, disk + GitHub destinations, pull–rebase race handling) and the packaging (distributed as a Claude Code plugin + GitHub release zip). Link-reference the compare/tag URLs at the bottom.

### 4.5 `CONTRIBUTING.md`
Short and practical: repo layout map; how to test locally (drop `skills/journal-this/` into `~/.claude/skills/`, **or** `/plugin marketplace add <local path>` then install); the bump-version-in-three-places + add-CHANGELOG-entry release checklist; "by contributing you agree to MIT."

### 4.6 `.gitignore` (root)
Minimal OS/editor cruft plus the build artifact: `.DS_Store`, `Thumbs.db`, `*.log`, and `journal-this.zip` (the release zip is built on demand and attached to the GitHub release — never committed). (`.remember/` already self-ignores via its own `.gitignore`.)

### 4.7 GitHub repo topics
`claude-code`, `claude-code-plugin`, `claude-skill`, `journaling`, `devlog`, `engineering-journal` — set via `gh repo edit --add-topic`. Outward-facing but low-risk and reversible (see §7).

## 5. Release mechanics

Build the manual-install zip from the skill folder so it unzips to exactly `~/.claude/skills/journal-this/`:
```bash
( cd skills && zip -r ../journal-this.zip journal-this )
# zip top-level entries: journal-this/SKILL.md, journal-this/config.template.json
```
Then tag and release:
```bash
git tag -a v1.0.0 -m "journal-this v1.0.0"
git push origin v1.0.0
gh release create v1.0.0 journal-this.zip \
  --repo BlueFenixProductions/journal-this \
  --title "v1.0.0" --notes-file <changelog excerpt>
```
The build is reproducible from tracked files; `journal-this.zip` is a release artifact and is **not** committed (it's listed in `.gitignore` per §4.6).

## 6. Migration details

- Move with history: `git mv SKILL.md skills/journal-this/SKILL.md` and `git mv config.template.json skills/journal-this/config.template.json`.
- **Adjacency is load-bearing:** `SKILL.md` references "`config.template.json` in this skill folder" (lines 50, 65). Moving both into `skills/journal-this/` together keeps that reference valid. Verify after the move with a grep.
- No content edits to `SKILL.md` are required by this work.

## 7. Outward-facing boundary

On the branch I will: restructure, author all manifests/docs, build the zip locally, validate, and commit. Pushing the branch + opening a PR, and the publish steps (tag push, `gh release create`, `gh repo edit --add-topic`) are outward-facing — **I stop and get explicit go-ahead** before running any of them, or hand them to Chris to run. Nothing publishes autonomously.

## 8. Verification

Automated (pre-PR):
- `jq . .claude-plugin/plugin.json` and `marketplace.json` parse cleanly.
- `skills/journal-this/SKILL.md` exists; frontmatter (`name`, `description`) intact.
- `grep` confirms the "this skill folder" reference still resolves (config template sits beside SKILL.md).
- Build the zip in `/tmp`, `unzip -l` to confirm entries are `journal-this/SKILL.md` + `journal-this/config.template.json`.
- README has no dead relative links; badge URLs resolve.

Manual smoke test (recommended, Chris or me with go-ahead):
- `/plugin marketplace add <local worktree path>` → `/plugin install journal-this@bluefenix` → confirm the `journal-this` skill is listed and triggers.

## 9. Edge cases & notes

- **Duplicate skill after publish:** a hand-installed dev copy at `~/.claude/skills/journal-this/` will coexist with the plugin-installed copy. After publishing, remove the manual copy to avoid double-registration. (Operational note for Chris, not a repo change.)
- **Marketplace name is permanent-ish:** users type `…@bluefenix` forever; confirmed as the chosen name.
- **Spec doc disposition:** this file lives under `docs/superpowers/specs/` as a planning artifact on the feature branch. Recommendation: keep the PR-to-`main` scoped to the plugin files and **do not merge this doc into `main`** (keep the public utility repo clean). Final call is Chris's at spec-review time.

## 10. Out of scope

- npm distribution (explicitly rejected — wrong tool for a markdown skill).
- Any change to the journaling workflow or `SKILL.md` logic.
- CI/CD, automated release pipelines, multi-plugin marketplace expansion (the `bluefenix` marketplace is built to allow it later, but no second plugin is added now).
