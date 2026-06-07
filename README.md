# journal-this

A Claude Code skill that turns the current session into a dated markdown journal entry — written in *your* voice, saved to *your* journal (a local folder or a GitHub repo).

It's the generalized, shareable version of a personal engineering-journal workflow: read the conversation, find what actually moved, write it up the way you'd write it, and file it (commit + push for GitHub destinations, handling the multi-machine pull–rebase race).

## Install

Drop the `journal-this/` folder into your skills directory:

- **Claude Code:** `~/.claude/skills/journal-this/`
- **Codex:** `~/.agents/skills/journal-this/`

```bash
unzip journal-this.zip -d ~/.claude/skills/
```

## Use

Just say `journal this` (or `/journal-this`) at the end of a work session.

- **First run** walks you through a one-time setup interview: your name, where your existing writing lives (so it learns your voice), and where entries should go. It saves your answers to `~/.config/journal-this/config.json`.
- **Every run after that** reads that config, anchors on a couple of your recent entries, writes the new entry, and files it.

Re-run the interview any time with `/journal-this setup`.

## Files

- `SKILL.md` — the skill itself (the only required file).
- `config.template.json` — documents every config field; the setup interview creates the real one for you.
- `README.md` — this file.

## License

MIT — see [LICENSE](LICENSE).
