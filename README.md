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
