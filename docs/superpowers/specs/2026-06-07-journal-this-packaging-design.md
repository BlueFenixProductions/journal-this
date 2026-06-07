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
- **Typed-command UX:** the plugin ships a `commands/journal-this.md` shim so users can type `/journal-this` (and `/journal-this setup`). Without it, a plugin-provided skill is only reachable namespaced as `/journal-this:journal-this` or via model auto-activation — which would silently break the bare `/journal-this` the docs advertise. See §4.8.
- **Version:** **1.0.0** (feature-complete, documented; signals "stable, ready to depend on"). Recorded in `plugin.json` `version`, the `marketplace.json` plugin entry, the git tag `v1.0.0`, and `CHANGELOG.md`. `SKILL.md` frontmatter stays version-free (matches every real skill example: name + description only). **The plugin system resolves version from `plugin.json` → marketplace entry → commit SHA, and installs from default-branch HEAD — *not* from the git tag.** So the tag + release exist for the downloadable zip, human version tracking, and CHANGELOG anchoring; updates reach users via a version bump + `/plugin marketplace update journal-this` → `/plugin update` (see §4.5/§5).
- **Marketplace name:** **`journal-this`** (same as the plugin; install reads `journal-this@journal-this`). Chosen over a branded `bluefenix` name for a single-purpose repo.
- **Polish extras (all in):** `CHANGELOG.md`, README badges, root `.gitignore` + GitHub repo topics, `CONTRIBUTING.md`.
- **Author identity in manifests:** name only (`Chris Pelatari`), **no email** — the repo is public.

Conventions below were verified by reading working manifests on disk: `vue-development`, `karpathy-skills`, and Chris's own `local/signal` plugin.

## 3. Target repository layout

```
journal-this/                        ← repo root IS the plugin (marketplace source ".")
├── .claude-plugin/
│   ├── plugin.json                  ← NEW
│   └── marketplace.json             ← NEW (repo is its own marketplace)
├── commands/
│   └── journal-this.md              ← NEW: thin shim so typed `/journal-this` works (see §4.8)
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
The `skills` array is explicit here; `commands/` is auto-discovered, so the shim in §4.8 needs no manifest entry. (`skills` can be omitted in favor of auto-discovery — vue-development does — but listing it is harmless and self-documenting.)

### 4.2 `.claude-plugin/marketplace.json`
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
`source: "./"` means "the plugin is this repo root" — verified against vue-development and karpathy-skills, which use the identical pattern with `.claude-plugin/` at root and `skills/<name>/` alongside.

### 4.3 `README.md` (rewrite)
- **Header:** title + badge row — a **dynamic** release badge (`img.shields.io/github/v/release/BlueFenixProductions/journal-this`, auto-tracks the latest release so it never needs manual bumping), a license (MIT) badge, and a static "Claude Code plugin" shield. No CI dependency.
- **What it does:** keep the existing 2-paragraph description and voice.
- **Install — two options:**
  - **A. Plugin (recommended, versioned + updatable):**
    ```
    /plugin marketplace add BlueFenixProductions/journal-this
    /plugin install journal-this@journal-this
    ```
  - **B. Manual drop-in (unchanged UX):** download `journal-this.zip` from the [Releases](https://github.com/BlueFenixProductions/journal-this/releases) page, then
    ```bash
    unzip journal-this.zip -d ~/.claude/skills/      # Claude Code
    unzip journal-this.zip -d ~/.agents/skills/      # Codex
    ```
- **Use / Example:** keep as-is (still accurate). Add one line clarifying the entry points: type `/journal-this` (or `/journal-this setup`), or just say "journal this" — it also offers to journal proactively when a session winds down.
- **Updating (plugin):** `/plugin marketplace update journal-this` then `/plugin update` — note that updates follow the `plugin.json` version, not the git tag.
- **What's in the box:** update the "Files" section for the new layout (`.claude-plugin/`, `commands/journal-this.md`, `skills/journal-this/SKILL.md`, `config.template.json`, `CHANGELOG.md`, `CONTRIBUTING.md`).
- **Footer:** Versioning (link `CHANGELOG.md`), Contributing (link `CONTRIBUTING.md`), License.
- **Terminology fix:** consistently describe it as "a Claude Code **plugin** that provides the `journal-this` **skill**." Stop using "skill" and "plugin" interchangeably.

### 4.4 `CHANGELOG.md`
Keep-a-Changelog format. Single `## [1.0.0] - 2026-06-07` entry under `### Added`: the journaling workflow (voice-anchoring, setup interview, disk + GitHub destinations, pull–rebase race handling) and the packaging (distributed as a Claude Code plugin + GitHub release zip). Link-reference the compare/tag URLs at the bottom.

### 4.5 `CONTRIBUTING.md`
Short and practical:
- **Repo layout map** (`.claude-plugin/`, `commands/`, `skills/journal-this/`).
- **Test locally:** drop `skills/journal-this/` into `~/.claude/skills/`, **or** `/plugin marketplace add <local clone path>` then `/plugin install journal-this@journal-this`.
- **Release checklist:** bump `version` in **`.claude-plugin/plugin.json`** *and* the **`marketplace.json`** plugin entry (keep them equal) → add a `CHANGELOG.md` entry → commit → `git tag -a vX.Y.Z` + push tag → build the zip → `gh release create`. Note for consumers: updates land via `/plugin marketplace update journal-this` → `/plugin update` (the version string drives it, not the tag).
- **License:** by contributing you agree your contributions are MIT-licensed.

### 4.6 `.gitignore` (root)
Minimal OS/editor cruft plus the build artifact: `.DS_Store`, `Thumbs.db`, `*.log`, and `journal-this.zip` (the release zip is built on demand and attached to the GitHub release — never committed). (`.remember/` already self-ignores via its own `.gitignore`.)

### 4.7 GitHub repo topics
`claude-code`, `claude-code-plugin`, `claude-skill`, `journaling`, `devlog`, `engineering-journal` — set via `gh repo edit --add-topic`. Outward-facing but low-risk and reversible (see §7).

### 4.8 `commands/journal-this.md` (plugin-only typed-command shim)
A thin command whose only job is to make the bare `/journal-this` (and `/journal-this setup`) typable for plugin installs, then hand off to the skill — so there is one source of truth (`SKILL.md`), not a forked workflow. Sketch:
```markdown
---
description: Capture this session as a dated journal entry (journal-this skill)
---
Run the **journal-this** skill for this session.

Arguments: $ARGUMENTS
- If `$ARGUMENTS` contains `setup`, run the skill's first-run setup interview (reconfigure).
- Otherwise, produce and file a journal entry per the skill's normal workflow.

Invoke the journal-this skill now; do not re-implement its steps here.
```
Notes:
- **Plugin-only.** The manual-zip install does *not* include this command and does not need it: a standalone skill dropped into `~/.claude/skills/journal-this/` is already reachable as `/journal-this` via skill-name routing (verified — that's how the current dev copy behaves). Commands and skills also live in different dirs for manual installs, so bundling it in the zip would complicate the "unzip into skills/" story for no gain.
- Commands are **auto-discovered** from `commands/`; no `plugin.json` field is required to register it.
- Depending on the Claude Code version the canonical typed form may be `/journal-this` (bare) or `/journal-this:journal-this` (namespaced); either honors the advertised UX, and model auto-activation on winding-down cues works regardless. README wording stays truthful to that.

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
The marketplace source stays `"./"` with **no `ref` pin**, so it tracks default-branch HEAD; post-1.0 fixes reach users once we bump the `version` string and they run `/plugin update`. The tag/release are not in the plugin install path (see §2).

The build is reproducible from tracked files; `journal-this.zip` is a release artifact and is **not** committed (it's listed in `.gitignore` per §4.6).

## 6. Migration details

- Move with history: `git mv SKILL.md skills/journal-this/SKILL.md` and `git mv config.template.json skills/journal-this/config.template.json`.
- **Adjacency is load-bearing:** `SKILL.md` references "`config.template.json` in this skill folder" (verified: one mention, at SKILL.md line 50). Moving both into `skills/journal-this/` together keeps that reference valid. Verify after the move with a grep.
- No content edits to `SKILL.md` are required by this work.

## 7. Outward-facing boundary

On the branch I will: restructure, author all manifests/docs, build the zip locally, validate, and commit. Pushing the branch + opening a PR, and the publish steps (tag push, `gh release create`, `gh repo edit --add-topic`) are outward-facing — **I stop and get explicit go-ahead** before running any of them, or hand them to Chris to run. Nothing publishes autonomously.

## 8. Verification

Automated (pre-PR):
- `jq . .claude-plugin/plugin.json` and `marketplace.json` parse cleanly; `version` strings match across both.
- `skills/journal-this/SKILL.md` exists; frontmatter (`name`, `description`) intact.
- `commands/journal-this.md` exists with a `description` frontmatter key.
- `grep` confirms the "this skill folder" reference still resolves (config template sits beside SKILL.md).
- Build the zip in `/tmp`, `unzip -l` to confirm entries are exactly `journal-this/SKILL.md` + `journal-this/config.template.json` (and that it does **not** include the command or `.claude-plugin/`).
- README has no dead relative links; badge URLs resolve.

Manual smoke test (recommended, Chris or me with go-ahead):
- **First, neutralize the shadow:** the hand-installed dev copy at `~/.claude/skills/journal-this/` will mask/duplicate the plugin. Temporarily move it aside (`mv ~/.claude/skills/journal-this /tmp/`) before testing the plugin, restore or delete after.
- `/plugin marketplace add <local clone path>` → `/plugin install journal-this@journal-this` → confirm: the skill is listed, typed `/journal-this` resolves (bare or namespaced), `/journal-this setup` reaches setup, and auto-activation still fires on a winding-down cue.

## 9. Edge cases & notes

- **Duplicate skill after publish:** a hand-installed dev copy at `~/.claude/skills/journal-this/` (confirmed present) will coexist with the plugin-installed copy. After publishing, remove the manual copy to avoid double-registration. (Operational note for Chris, not a repo change.)
- **LICENSE:** verified correct — `MIT, Copyright (c) 2026 Chris Pelatari`. No change needed.
- **Typed-command form is CC-version-dependent:** `/journal-this` may resolve bare or as `/journal-this:journal-this`; the §4.8 shim + auto-activation keep the advertised UX working either way. README avoids over-promising a single exact string.
- **Marketplace name is permanent-ish:** users type `…@journal-this` forever; confirmed as the chosen name.
- **Spec doc disposition:** this file lives under `docs/superpowers/specs/` and **ships to `main`** — confirmed by Chris. The repo doubles as a worked example for people building their own skills/plugins, so the planning artifacts are part of its value. (Optionally surface them: a one-line pointer from `README.md`/`CONTRIBUTING.md` to `docs/superpowers/specs/` framing it as "how this plugin was designed.")

## 10. Out of scope

- npm distribution (explicitly rejected — wrong tool for a markdown skill).
- Any change to the journaling workflow or `SKILL.md` logic.
- CI/CD, automated release pipelines, multi-plugin marketplace expansion (the `journal-this` marketplace could hold more plugins later, but no second plugin is added now).
