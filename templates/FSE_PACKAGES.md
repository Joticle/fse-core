# FSE_PACKAGES.md — Approved Dependency Registry

> Universal rules live in FSE.md. This file holds project-specific packages only.

*The authoritative list of packages this project is permitted to depend
on. Every runtime, dev, and tooling dependency is named here with its
exact approved version and the reason it was approved. Adding a package
that is not listed here is a protocol violation — propose the package
during PLAN, get approval, record it here, then install.*

*This file does not duplicate the package manifest (`package.json`,
`*.csproj`, `requirements.txt`, etc.). The manifest is the machine-readable
record of what is installed. FSE_PACKAGES.md is the human-readable record
of why each entry is there and what alternatives were rejected.*

## Maintenance

- New package proposals go through PLAN approval before being added here.
- Version pins are exact, not ranges. Upgrades require a recorded decision
  (compatibility review, security advisory, or new feature need) and an
  entry in the Upgrade Log.
- The Banned Packages list grows when a package is found unsuitable. The
  reason stays in the file as institutional memory — removing a ban
  requires a new approval entry that supersedes it.
- Transitive dependencies are only recorded when they require a human
  decision (pinned override, exceptioned advisory, peer-dep resolution).
  Do not enumerate the full transitive tree — the manifest already does.

## Runtime Dependencies

*Packages that ship with the application or are loaded at runtime.*

| Package | Version | Purpose | Approved |
|---------|---------|---------|----------|
| *[package-name]* | *[exact version, e.g. 1.5.0]* | *[why this project needs it]* | *[YYYY-MM-DD]* |

## Dev / Tooling Dependencies

*Build tools, test frameworks, linters, type-checkers, code generators.
Dev dependencies have a different review bar than runtime dependencies —
record them separately so the runtime surface stays easy to read.*

| Package | Version | Purpose | Approved |
|---------|---------|---------|----------|
| *[package-name]* | *[exact version]* | *[why]* | *[YYYY-MM-DD]* |

## Transitive Dependency Notes

*Record only the transitives that have required a human decision: pinned
overrides, exceptioned vulnerabilities, peer-dependency resolutions, or
abandoned upstreams that this project is deliberately tolerating.*

- **[transitive-package@version]** — *[The decision and the reason it
  was made.]*

## Banned Packages

*Packages that must never be installed in this project. A ban can be
lifted only by a recorded decision that adds the package back to the
approved list above with a new approval date.*

| Package | Reason | Banned |
|---------|--------|--------|
| *[package-name]* | *[Why it is banned — incident, license, abandonment, security, performance.]* | *[YYYY-MM-DD]* |

## Upgrade Log

*One line per version bump. Newest at the top. The Upgrade Log answers
"why is this on version N rather than version N±1" without re-reading
the whole session history.*

- *[YYYY-MM-DD] — [package] [old version] → [new version]. [Reason.]*
