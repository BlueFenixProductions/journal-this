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
- Distributed as a plain **Claude Code skill** installed with a one-line
  `install.sh` (or a manual `cp -R`), exposing a bare `/journal-this` command.

[1.0.0]: https://github.com/BlueFenixProductions/journal-this/releases/tag/v1.0.0
