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
