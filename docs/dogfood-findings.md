# Dogfood findings

Issues discovered by running journal-this against real journals, and what changed
in the skill because of them. Newest first.

## 2026-06-11 — a `\s` in a description broke six consecutive site deploys

**Journal:** homelab-topology (`topo.bluefenix.net`, VitePress on Coolify/madara).

**What happened:** an entry written by the skill quoted a regex —
`` `/^\s*import.../m` `` — inside its double-quoted `description:` frontmatter.
In a double-quoted YAML scalar, `\` begins an escape sequence and `\s` is illegal,
so VitePress's strict YAML parser rejected the entry and every deploy after it
failed at the build step (six in a row before anyone noticed — the previous
container kept serving the stale site, masking the breakage). The journal repo's
own index generator parsed the same frontmatter *leniently*, so nothing failed at
write time; the error surfaced only deep in `vitepress build`, naming a column
offset but not the offending file.

**Root cause, skill-side:** the SKILL.md skeleton-replication contract said to
reproduce the samples' "keys and quoting" but never warned that double-quoted
YAML treats backslashes as escape introducers. Entries that quote regexes or
Windows paths — common in an engineering journal — are exactly the prose that
trips it.

**What changed:**
- `SKILL.md` step 3 now carries a **"Backslash hazard in double-quoted
  frontmatter"** paragraph: double any literal backslash (`\\s`), or
  JSON-stringify the whole value and paste the result.
- The affected journal repo also gained a write-time guard (its index generator
  now strict-validates quoted frontmatter values and fails naming the file, the
  key, and the remedy). **Recommendation for any journal site consuming
  skill-written entries:** validate frontmatter at generation time with a parser
  at least as strict as the site builder's, and make the failure name the file.
