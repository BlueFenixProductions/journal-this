# journal-this

[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Claude Code skill](https://img.shields.io/badge/Claude%20Code-skill-d97757.svg)](#install)

A Claude Code **skill** that turns the current session into a dated markdown journal entry, written in *your* voice, saved to *your* journal (a local folder or a GitHub repo).

It's the generalized, shareable version of a personal engineering-journal workflow: read the conversation, find what actually moved, write it up the way you'd write it, and file it (commit + push for GitHub destinations, handling the multi-machine pull–rebase race).

## Install

One line from a clone:

```bash
git clone https://github.com/BlueFenixProductions/journal-this
cd journal-this
./install.sh            # -> ~/.claude/skills/journal-this   (Claude Code)
./install.sh --codex    # -> ~/.agents/skills/journal-this   (Codex)
```

Then reload Claude Code (`/reload-plugins`, or restart) and type `/journal-this`.

Prefer to do it by hand? It's a single folder — copy it in:

```bash
cp -R skills/journal-this ~/.claude/skills/journal-this
```

That's the whole skill: `SKILL.md` plus a config template.

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
install.sh                 # one-line installer (copies the skill into your skills dir)
skills/
  journal-this/
    SKILL.md               # the skill itself — the only file an install needs
    config.template.json   # documents every config field; setup creates the real one
CHANGELOG.md
CONTRIBUTING.md
LICENSE
```

## Versioning & contributing

Releases follow [Semantic Versioning](https://semver.org); see [CHANGELOG.md](CHANGELOG.md). Contributions welcome — see [CONTRIBUTING.md](CONTRIBUTING.md). Curious how this was designed? The spec lives in [`docs/superpowers/specs/`](docs/superpowers/specs/) — note those design docs describe an earlier plugin-packaging approach that was later simplified to this plain skill.

## License

MIT — see [LICENSE](LICENSE).
