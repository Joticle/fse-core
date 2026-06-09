# FSE_DISCOVERY.md — Initial Project Audit

A one-time snapshot taken when FSE is first adopted. It captures the project as it exists *before* FSE self-hosting, so gaps can be named and tracked.

Update this file only when a gap is closed or a new structural fact is discovered. Day-to-day state lives in `FSE_STATE.md`, not here.

## Solution Overview

| Field | Value |
|-------|-------|
| Project name | fse-core |
| Primary purpose | Open-source FlowState Engineering methodology repository — publishes templates, prompts, governance docs, and methodology extensions |
| Production status | Production — public and published |
| Primary users | Developers adopting FSE; AI coding assistants that read the templates |
| Primary stack | Not applicable — documentation/methodology repository (Markdown) |
| Repository | https://github.com/Joticle/fse-core |
| Discovery date | 2026-06-08 |
| Discovered by | Scott Michael Wilson |

## Build State at Discovery

| Check | Command | Result |
|-------|---------|--------|
| Install | — | N/A — documentation repository, nothing to install |
| Build | — | N/A — no build |
| Tests | — | N/A — no tests |
| Lint | — | N/A — no lint configured |
| Type check | — | N/A — not applicable |

## Infrastructure Checklist

Items that do not apply to a documentation repository are marked **N/A** explicitly rather than left ambiguous.

- [x] Version control in use (Git)
- [ ] `.gitignore` covers secrets, build artifacts, and local environment files — **ABSENT** (gap; low impact — repo holds no secrets or build artifacts)
- [x] `README.md` exists and describes the methodology and how to adopt it
- [x] LICENSE present (Apache 2.0)
- [x] CONTRIBUTING.md present
- [x] CODE_OF_CONDUCT.md present
- [x] SECURITY.md present
- [x] `.github/` issue templates and PR template present
- [ ] CI runs on every push / PR — none configured (low priority for a docs repo; a markdown-link / lint check could be added later)
- N/A — Dependency manifest / lockfile (no dependencies)
- N/A — Environment variables documented (none)
- N/A — Local dev environment from clean clone (no build; clone-and-read)
- N/A — Build command (no build)
- N/A — Test command (no tests)
- N/A — Lint command (none configured)
- N/A — Type check (not applicable)
- N/A — Deployment path (not deployed; consumed by clone/download)
- N/A — Secrets stored outside the repo (no secrets)
- N/A — Database migrations (no database)
- N/A — Backups for production data (no data)
- N/A — Error monitoring (no runtime)
- N/A — Logging destination (no runtime)
- N/A — Production access limited and recorded (no production system; repo write access governed by GitHub permissions)

## Database Summary

**Not applicable — fse-core has no datastore.**

## Gaps to Fill

| Gap | Impact | Priority | Owner |
|-----|--------|----------|-------|
| README references `prompts/ONBOARDING_PROMPT.md` and a `prompts/` directory that do not exist; the file actually lives at `templates/ONBOARDING_PROMPT.md` | Broken path in the published README and Quick Start; new adopters hit a dead link | Med | Scott Michael Wilson |
| README "Repository Structure" omits `docs/` and four shipped templates (`FSE_PACKAGES`, `FSE_POLICE`, `PATTERNS`, `FIELD_REPORT_TEMPLATE`) | Published structure understates what the repo actually ships | Low | Scott Michael Wilson |
| No `.gitignore` | Local files (e.g. `.claude/settings.local.json`) can be committed accidentally | Low | Scott Michael Wilson |
| fse-extensions content status not audited this session | DAOBoard aggregator and .NET extension state is unknown from within fse-core (separate repository) | Low | Scott Michael Wilson |

Close a gap by fixing it and removing the row. Large gaps graduate to `FSE_STATE.md` as priorities.

## FSE Compliance at Discovery

- [x] `FSE.md` present at project root
- [x] `FSE_STATE.md` present at project root
- [x] `FSE_DISCOVERY.md` present at project root (this file)
- [x] AI tool configured to read foundation files at session start (`.claude/instructions.md`)
- [x] Universal Standing Orders reviewed and acknowledged
- [x] Project-Specific Standing Orders drafted in `FSE.md`
- [x] Warning baseline recorded in `FSE.md` (N/A — no build) and mirrored in `FSE_STATE.md`
- [x] First session priorities recorded in `FSE_STATE.md`

FSE self-hosting onboarding is complete.
