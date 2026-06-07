# Contributing to journal-this

Thanks for your interest! journal-this is a small, focused Claude Code **skill** —
a single `SKILL.md` plus a config template. Contributions that keep it sharp and
well-documented are welcome.

## Repository layout

```
install.sh                 # one-line installer (copies the skill into your skills dir)
skills/
  journal-this/
    SKILL.md               # the skill itself — the source of truth for behavior
    config.template.json
CHANGELOG.md
README.md
docs/superpowers/specs/    # how this was designed (a worked example; describes the
                           # earlier plugin-packaging approach, since simplified)
```

The behavior lives entirely in `skills/journal-this/SKILL.md`.

## Testing your changes locally

Install the skill from your clone:

```bash
./install.sh         # copies skills/journal-this -> ~/.claude/skills/journal-this
```

Reload Claude Code (`/reload-plugins`, or restart), then type `/journal-this`.

## Cutting a release (maintainers)

1. Add a dated entry to `CHANGELOG.md`.
2. Commit, then tag and push the tag:
   ```bash
   git tag -a vX.Y.Z -m "journal-this vX.Y.Z"
   git push origin vX.Y.Z
   ```
3. (Optional) attach a zip of the skill folder to the GitHub release for one-step
   manual installs:
   ```bash
   ( cd skills && zip -r ../journal-this.zip journal-this )
   gh release create vX.Y.Z journal-this.zip --title "vX.Y.Z" \
     --notes-file <(sed -n '/## \[X.Y.Z\]/,/## \[/p' CHANGELOG.md)
   ```

## License

By contributing, you agree that your contributions are licensed under the
[MIT License](LICENSE).
