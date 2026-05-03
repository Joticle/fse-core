# FSE.md — FlowState Engineering Foundation File

<!-- =================================================================== -->
<!-- FSE START                                                           -->
<!-- Everything between FSE START and FSE END is the methodology itself. -->
<!-- Do not modify this block unless you are upgrading the FSE version.  -->
<!-- =================================================================== -->

## FSE Session Protocol — VERIFY → PLAN → EXECUTE → VALIDATE

Every FSE session follows four phases, in order. Skipping a phase is a protocol violation.

### 1. VERIFY
At the start of every session, before doing anything else:

1. Read `FSE.md`, `FSE_STATE.md`, and `FSE_DISCOVERY.md` in full.
2. Read any Tier 2 files that exist (`FSE_POLICE.md`, `FSE_SCHEMA.md`, `FSE_UI.md`, `FSE_PACKAGES.md`, `PATTERNS.md`).
3. Run the project's build/check command. Capture the current state.
4. Confirm the working tree is clean (or note what is dirty and why).
5. Report:
   - Current build state (clean / warnings / errors)
   - Current priorities from `FSE_STATE.md`
   - Any blockers from the last session

Do not start coding until VERIFY is complete.

### 2. PLAN
Before writing or modifying any file:

1. State what will be built, in plain language.
2. List every file that will be created, modified, or deleted.
3. Call out any architectural decision that is not already in `FSE.md`.
4. Wait for explicit approval.

One approval covers one plan. A new scope means a new plan.

### 3. EXECUTE
Once approved:

1. Work one file at a time.
2. Output complete file contents — never snippets, diffs, or partial implementations.
3. No stubs, TODOs, or placeholder functions. If a piece is unknown, stop and ask.
4. After each file, wait for confirmation before moving to the next file.
5. Do not change code outside the agreed scope. If adjacent cleanup is warranted, surface it — do not silently make the edit.

### 4. VALIDATE
After every change:

1. Run the self-healing build loop (below).
2. Confirm zero errors and no new warnings above the baseline.
3. Update `FSE_STATE.md`:
   - Append a session history entry
   - Update build state
   - Record any new lessons learned
   - Record any new technical debt
4. Never commit with a broken build.

## Self-Healing Build Loop

After every change that could affect the build:

```
Attempt 1: build → if clean, done. If broken, read the error and fix.
Attempt 2: build → if clean, done. If broken, read the error and fix.
Attempt 3: build → if clean, done. If broken, STOP.
```

**Maximum three attempts.** On the third failure, do not attempt a fourth fix. Stop, capture the full error, report it, and hand back control. Pushing past this limit is how broken code reaches production.

## Counter-Point Protocol

When the self-healing build loop hits three failed attempts:

1. Stop.
2. Do not try another fix in the same direction. The reasoning that produced the last three attempts is the reasoning that is failing — trust that signal.
3. Report the full context: the error, each attempt, and why each attempt was made.
4. Switch approach: consult the user, use a different model, consult a Tier 2 document, or revert and re-plan.

The Counter-Point Protocol exists to break AI logic loops — the failure mode where an assistant repeats variants of the same wrong answer with increasing confidence.

## Session End Protocol

Before ending any session:

1. Confirm the build is clean.
2. Confirm the working tree is committed or deliberately left dirty.
3. Update `FSE_STATE.md` with:
   - What was built in this session
   - What the next session should start with
   - Any blockers the next session will hit
4. If any lessons were learned this session, record them under Lessons Learned.
5. If any technical debt was introduced deliberately, record it under Known Technical Debt.

## FSE Document Ecosystem

### Tier 1 — Required
- **FSE.md** — This file. Architecture, stack, standing orders, and the methodology block.
- **FSE_STATE.md** — Living state. Session history, priorities, lessons, debt.
- **FSE_DISCOVERY.md** — Initial audit. Infrastructure checklist, gaps.

### Tier 2 — Add When Needed
- **FSE_POLICE.md** — Absolute rules that must never be violated (security, compliance, data boundaries).
- **FSE_SCHEMA.md** — Entity model, database schema conventions, naming rules.
- **FSE_UI.md** — Design language, component rules, accessibility baseline.
- **FSE_PACKAGES.md** — Approved dependencies. Rules for adding new ones.
- **PATTERNS.md** — Proven patterns and idioms for this codebase.

Add a Tier 2 file when:
- `FSE.md` exceeds ~15KB, or
- A category of rules is being repeated across sessions, or
- A domain (UI, schema, security) warrants its own authoritative document.

The ~15KB cap applies to bedrock methodology files (`FSE.md`, `FSE_STATE.md`, `FSE_DISCOVERY.md`, and other Tier 2 reference docs) — not to source code files. Source files split based on cohesion and module boundaries; methodology files split based on context-window cost.

### Tier 3 — Optional / Aged-Out
- **BUILD_LOG_*.md** — Long-form logs of significant builds or migrations.
- **AUDIT_REPORT.md** — Point-in-time audits.
- **CHANGELOG.md** — User-facing change history.
- **Archived session reports** — Reports moved out of `/sessions/active/` into `/sessions/archive/YYYY-MM/` once superseded by newer artifacts. See Session Numbering & Artifact Lifecycle below.

## Universal Standing Orders

These apply to every FSE project, regardless of stack.

1. **No stubs, TODOs, placeholders, or incomplete implementations.** If it isn't finished, it doesn't get written.
2. **No snippets or partial code.** Output complete file contents every time.
3. **Never assume file contents or existence.** Always read the current file, or list the directory, or ask before modifying or referencing any file.
4. **Never change styling, functionality, or configuration outside the current task scope.** Implicit refactors — cleaning up imports, reorganizing DI registrations, "while I'm here" tweaks — are protocol violations regardless of intent. Build-fix edits are limited to the file under active edit. If resolving the build requires changes to any other file, halt and surface a re-plan request. Do not expand scope silently.
5. **The self-healing build loop runs after every change.** No exceptions.
6. **Never commit with a broken build.**
7. **Credentials are never output, logged, or committed.** Ever.
8. **Token-First Construction.** No UI ships without project-defined design tokens. Every visual CSS value — color, spacing, radius, shadow, font-size — must reference a token variable defined by the project (e.g., `--fse-*`, `--cc-*`, `--br-*`). Hard-coded literals (hex, rgb, named colors, raw px values) outside the project's token definition file are build-fails. Pre-existing violations are recorded in `fse-style-baseline.json` and resolved when the file is next modified — the baseline is a one-way ratchet that only shrinks.
9. **Pattern-First Design.** No UI element is built in isolation. Before writing new component CSS or markup, consult `FSE_UI.md` for an existing pattern. If a pattern exists, it must be used. If a new pattern is required, it is proposed during the PLAN phase, added to `FSE_UI.md`, and only then implemented. The session does not close until `FSE_UI.md` reflects every component introduced.
10. **Visual Validation Phase.** Every session that touches UI ends with a Visual Validation step inside VALIDATE. Each modified page is compared against the relevant patterns in `FSE_UI.md`. Any drift is either resolved before commit or recorded explicitly in `FSE_STATE.md` as accepted technical debt with justification. Visual validation is a named phase, not a habit.

Stack-specific standing orders go in the "Project-Specific Standing Orders" section below, or in a stack extension file.

## Session Numbering & Artifact Lifecycle

Sessions are numbered. Session artifacts have a lifecycle. Both are universal across FSE projects.

### Session Numbering

Every CLI session is numbered sequentially across the project's lifetime as `SESSION_NN` (zero-padded 2-digit; expand to 3 digits past 99). Numbering is project-local — each project starts at `SESSION_01` and counts independently.

- A session is one CLI invocation that runs to completion (success, partial completion, or clean stop).
- Numbers are sequential and never reused. Failed or reverted sessions still consume a number.
- Session numbers persist across branches and phases. They count CLI runs, not git operations.

The session number appears in:
- **Prompt headers** — `SESSION 08 — PHASE 1 RUN 2: <SCOPE>`
- **Report filenames** — `SESSION_08_PHASE_1_RUN_2_REPORT.md`
- **Commit messages** — `[FSE] Session 8 Phase 1 Run 2: <what shipped>`
- **`FSE_STATE.md` session log** — see schema below

The term "overnight run" is dropped. Replace with "session" or "unattended session." Sessions happen at all hours.

### Artifact Lifecycle

Session reports and other CLI-generated artifacts move through two phases. The Tier scheme above describes *what* a document is; the Lifecycle describes *where it lives based on age and relevance*.

**Active** — `/sessions/active/`
- New session reports are born here.
- Reports stay in Active while the work is in flight or recently relevant.
- Sessions read Active artifacts during VERIFY when they need recent context.

**Archived** — `/sessions/archive/YYYY-MM/`
- Reports move here when superseded by newer artifacts.
- Organized by year-month (the month the work was originally completed) for predictable retrieval.
- Once archived, a report is Tier 3 historical reference.

Bedrock files (`FSE.md`, `FSE_STATE.md`, `FSE_DISCOVERY.md`, `CLAUDE.md` thin pointer, `README.md`) live at the repo root and never move. Only `.md` files predating this methodology are grandfathered at the root — migration is a separate, explicit decision per project.

### Mandatory Hygiene Steps

**At session start (during VERIFY):**
- Confirm `/sessions/active/` and `/sessions/archive/` exist; create if missing.
- Verify the repo root has not accumulated stray `.md` files since the last session (excluding bedrock + grandfathered).

**At session end (during VALIDATE):**
1. Place the new session report in `/sessions/active/`.
2. Identify any reports in Active that have been superseded by newer work.
3. Move superseded reports to `/sessions/archive/YYYY-MM/`.
4. Update `FSE_STATE.md` session log table.
5. Verify repo root contains only Tier 1 bedrock files (plus grandfathered).

### `FSE_STATE.md` Session Log Schema

Every project's `FSE_STATE.md` includes a session log table with these columns:

| Session | Date | Branch | Scope | Outcome | Report |
|---------|------|--------|-------|---------|--------|
| SESSION_01 | 2026-MM-DD | main | <scope summary> | <success/partial/reverted> | `sessions/active/SESSION_01_*.md` or `sessions/archive/YYYY-MM/SESSION_01_*.md` |

The Report column is a relative path that updates when the report moves from Active to Archived.

<!-- =================================================================== -->
<!-- FSE END                                                             -->
<!-- Everything below this line is project-specific.                     -->
<!-- =================================================================== -->

## Project Identity

- **Name:** [Project name]
- **Owner:** [Owner / team]
- **Purpose:** [One-sentence description of what this project does and for whom.]
- **Status:** [Pre-production / Production / Maintenance]
- **Repository:** [URL]

## Tech Stack

- **Language:** [e.g. TypeScript 5.x]
- **Runtime:** [e.g. Node.js 20 LTS]
- **Framework:** [e.g. Next.js 14 App Router]
- **Database:** [e.g. PostgreSQL 16 via Supabase]
- **Hosting:** [e.g. Vercel]
- **Auth:** [e.g. Supabase Auth]
- **Other key dependencies:** [List anything architecturally load-bearing]

## Solution Structure

```
[project-root]/
  [describe top-level folders and what lives in each]
```

Include:
- Where business logic lives
- Where UI components live
- Where data access lives
- Where tests live
- Anything structurally unusual

## Database

- **Engine:** [e.g. PostgreSQL 16]
- **Migration tool:** [e.g. Prisma Migrate / Supabase migrations / Flyway]
- **Naming conventions:** [snake_case tables, plural table names, etc.]
- **Primary entities:** [List top-level entities and their relationships, or link to FSE_SCHEMA.md]

## Project-Specific Standing Orders

Rules that apply to this project in addition to the Universal Standing Orders above.

1. [e.g. All DB writes go through the repository layer — never call the DB client from route handlers]
2. [e.g. No new runtime dependencies without updating FSE_PACKAGES.md]
3. [e.g. All user-facing strings go through the i18n module]

## Warning Baseline

The current acceptable warning count for this project. Any build that produces more than this count is considered failing.

- **Build warnings:** [0]
- **Lint warnings:** [0]
- **Type warnings:** [0]

Raise the baseline only with a recorded reason in `FSE_STATE.md`.
