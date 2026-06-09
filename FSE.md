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

The ~15KB rule is a split trigger, not a hard cap on file size — it applies to bedrock methodology files (`FSE.md`, `FSE_STATE.md`, `FSE_DISCOVERY.md`, and other Tier 2 reference docs), not to source code files. Source files split based on cohesion and module boundaries; methodology files split based on context-window cost.

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
11. **Bedrock Authoring Guard.** When authoring or editing a foundation file, any section lacking an explicit human-provided decision is recorded in the file's OPEN DECISIONS block and never filled with a plausible default. A section with no decision is left explicitly open; it is not completed with an inferred or stack-conventional answer. A confabulated bedrock decision is more dangerous than a missing one — a gap gets noticed, an invented decision gets enforced by every session that follows. The operator clears the OPEN DECISIONS block over subsequent sessions; until a decision is cleared, no session treats the open section as ground truth.

Stack-specific standing orders go in the "Project-Specific Standing Orders" section below, or in a stack extension file.

## Session Numbering & Artifact Lifecycle

Sessions are numbered. Session artifacts have a lifecycle. Both are universal across FSE projects.

### Session Numbering

Every CLI session has a unique, sequential identifier within the project. Numbering is project-local — each project counts independently.

A project picks one of two valid numbering schemes and stays consistent within itself:

**Flat numbering** — `SESSION_01`, `SESSION_02`, `SESSION_03`, …
- Zero-padded 2-digit; expand to 3 digits past 99.
- Simplest scheme. Best for projects without explicit phasing.

**Hierarchical numbering** — `Session 1`, `Session 2A`, `Session 2A.1`, `Session 2B.1.2`, …
- Phase + sub-phase + run structure mirroring the project's build plan.
- Best for projects with explicit phases or multi-stage builds.
- Branch points (e.g., `2A.1` and `2A.2`) and refinements (e.g., `2A.1.1`) are valid.

Both schemes share the same rules:
- A session is one CLI invocation that runs to completion (success, partial completion, or clean stop).
- Identifiers are unique and never reused. Failed or reverted sessions still consume an identifier.
- Identifiers persist across branches and phases. They count CLI runs, not git operations.

The session identifier appears in:
- **Prompt headers** — `SESSION 08 — PHASE 1 RUN 2: <SCOPE>` or `SESSION 2B.1.2 — <SCOPE>`
- **Report filenames** — `SESSION_08_PHASE_1_RUN_2_REPORT.md` or `SESSION_2B_1_2_REPORT.md` (dots become underscores in filenames)
- **Commit messages** — `[FSE] Session 8 Phase 1 Run 2: <what shipped>` or `[FSE] Session 2B.1.2: <what shipped>`
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

| Session | Date | Scope | Outcome | Report |
|---------|------|-------|---------|--------|
| SESSION_01 | 2026-MM-DD | <scope summary> | <success/partial/reverted> | `sessions/active/SESSION_01_*.md` or `sessions/archive/YYYY-MM/SESSION_01_*.md` |

The Report column is a relative path that updates when the report moves from Active to Archived.

**Ordering.** Rows render in git chronological order (by commit date), not by numerical or alphabetical session identifier. The session log is a historical record of what actually happened — chronological order preserves operator behavior including out-of-name-order sessions (a `Session 2G.0.1` committed before `Session 2G` reflects the real sequence and stays in that order in the table).

**Optional Branch column.** Projects that work across multiple branches may add a `Branch` column between `Date` and `Scope`. Projects that stay on `main` (the common case) omit the column rather than fill it with placeholder values.

**Backfill clustering rule.** When reconstructing session history from git log for projects adopting the methodology mid-stream, group commits into sessions using these heuristics:

1. Commits with explicit session prefixes (`Session 2A:`, `[FSE] Session 8:`, etc.) belong to the named session.
2. Unprefixed commits cluster into the adjacent named session when same date AND scope-adjacent (chore commits supporting a feature commit, hotfixes following a feature ship). The clustered commits inherit the named session's identifier; the table row notes "(with hotfixes)" or similar in the Outcome column.
3. Unprefixed commits that don't cluster cleanly into an adjacent session form a new synthesized session. Synthesized identifiers follow the project's existing scheme (e.g., a new `2E.1` between `2E` and `2F` in a hierarchical project).
4. Reconstructed entries are flagged in the Report column as `(reconstructed — no original report)`. Sessions with original reports preserved (e.g., entries already in `SESSION_STATE.md`) reference those instead.

### Phased Adoption

A project mid-flight on existing work does not have to adopt the full methodology in one batch. Phased adoption is permitted and expected when adopting FSE on a project that already has active session work.

The components can be adopted independently, in any order:

1. **Session numbering** — start using `Session N:` (or `[FSE] Session N:`) prefixes in commit messages going forward. No file moves required. Past commits stay as they are.
2. **Artifact lifecycle** — create `/sessions/active/` and `/sessions/archive/` and place new session reports in Active. Existing reports stay where they are until the bedrock rename happens.
3. **Bedrock rename** — rename `CLAUDE.md` → `FSE.md`, `SESSION_STATE.md` → `FSE_STATE.md`, `DISCOVERY_REPORT.md` → `FSE_DISCOVERY.md`. Add thin `CLAUDE.md` pointer. This is the heaviest step and touches every reference to bedrock files.
4. **Session log table** — add the table to `FSE_STATE.md` (or `SESSION_STATE.md` if rename is deferred). Backfill historical sessions from git log per the clustering rule above.

Adoption order is the project's call. The most common path is: components 1 and 2 first (additive, no risk), then components 3 and 4 at a natural break point (e.g., after a phase ships).

Document the adoption state in `FSE_STATE.md` until the project is fully on FSE conventions:
FSE Adoption State

Session numbering: adopted from Session N forward
Artifact lifecycle: adopted (sessions/ created)
Bedrock rename: deferred until <break point>
Session log table: deferred until bedrock rename


Once all four components are adopted, remove the adoption state block.

## Module Pattern — Context-Bounded Context

**Thesis:** Modular software architectures demand modular context. Because the AI context window is the development environment, context isolation must precisely mirror architectural isolation to prevent token bloat, context degradation, and cross-domain hallucination as a solution scales.

### Structural Invariants

- Every distinct domain module folder under `src/Modules/*` must contain a local `MODULE.md` file.
- **Activation Threshold:** This constraint is conditionally active. Greenfield projects at S001 with zero modules carry zero `MODULE.md` files. The constraint activates upon creation of the first module.
- **Header Convention (exact):**

  ```
  # {ModuleName} — Module Reference

  Read this file when working on this module. Platform architecture and global FSE rules live in the root FSE.md.
  ```

- The root `FSE.md` maintains a Module Reference Table listing every module and its `MODULE.md` path.

### Content Scope & Boundaries

A local `MODULE.md` acts as a context firewall. The root `FSE.md` remains the global constitution and must never absorb module-specific details. Local `MODULE.md` is strictly limited to:

- Isolated domain schema and entities
- Module-specific DbContext configuration and data-isolation rules
- Internal module invariants and business logic
- Explicit cross-module data-access notes (APIs, events, allowed dependencies)

### Protocol Enforcement

- **Scaffolding Rule:** A module's `MODULE.md` is created in the exact same session as the module scaffolding. A module cannot be born without its context boundary file.
- **VERIFY Gate:** When a session targets a specific module, the AI must read that module's `MODULE.md` as an explicit step in the VERIFY phase before touching any code in that domain.

### Rationale (Solo Founder Lens)

Multi-person teams can rely on human domain owners ("Ask Dave"). As a solo founder scaling a portfolio, you offload domain memory entirely to session context. This pattern protects your development environment from the success of your own modular architecture.

<!-- =================================================================== -->
<!-- FSE END                                                             -->
<!-- Everything below this line is project-specific.                     -->
<!-- =================================================================== -->


================================================================
OPEN DECISIONS — sections awaiting an explicit operator decision.
Bedrock Authoring Guard: nothing below is ground truth until cleared.
================================================================
( none — every section below carries an explicit operator decision, made in SESSION_01 )
================================================================

## Project Identity

- **Name:** fse-core
- **Owner:** Joticle, Inc. — Scott Michael Wilson
- **Purpose:** The open-source FlowState Engineering methodology repository. It publishes the FSE templates, onboarding prompts, governance documents, and methodology extensions that downstream FSE projects adopt. It is the canonical source of the methodology.
- **Status:** Production — public and published.
- **Repository:** https://github.com/Joticle/fse-core
- **License:** Apache 2.0
- **Methodology version:** 1.0.0 (tracked in `VERSION`; git tag `v1.0.0`)

## Tech Stack

**Not applicable — fse-core is a documentation / methodology repository.** There is no programming language, runtime, framework, build system, package manager, or hosting. The repository is Markdown and plain-text artifacts consumed by humans and AI assistants. Sections of the FSE template that assume a software stack (Tech Stack, Database, Module Pattern, Warning Baseline, Self-Healing Build Loop) are marked Not Applicable throughout this file rather than filled with invented values.

## Solution Structure

```
fse-core/
  FSE.md                 ← this file — fse-core's own root constitution
  FSE_STATE.md           ← living state: session log, priorities, lessons, debt
  FSE_DISCOVERY.md       ← initial self-hosting audit
  README.md              ← public methodology overview
  LICENSE                ← Apache 2.0
  VERSION                ← methodology version (1.0.0)
  CONTRIBUTING.md        ← contribution process
  CODE_OF_CONDUCT.md     ← Contributor Covenant
  SECURITY.md            ← disclosure policy
  .claude/
    instructions.md      ← AI session bridge → reads the three foundation files
    settings.local.json  ← local tool permissions (not a methodology artifact)
  .github/
    ISSUE_TEMPLATE/      ← bug_report, feature_request, methodology_question
    PULL_REQUEST_TEMPLATE.md
  templates/             ← PUBLISHED artifacts — adopters copy these into their own repos
    FSE.md  FSE_STATE.md  FSE_DISCOVERY.md
    FSE_POLICE.md  FSE_PACKAGES.md  PATTERNS.md
    FIELD_REPORT_TEMPLATE.md  ONBOARDING_PROMPT.md
  docs/
    methodology/
      daoboard/
        NOTIFICATION-2026-05-17.md   ← DAOBoard extension notification (notify-before-implement)
```

| Module | MODULE.md Path | Status |
|--------|----------------|--------|

*Module Reference Table — Not applicable. fse-core has no `src/Modules/*`; it is a documentation repository with no domain modules.*

**Published-artifact boundary:** Everything under `templates/` is a contract that downstream repositories depend on. The placeholders in `templates/*` are filled by *adopters in their own repos*, never here. This root `FSE.md` is fse-core's **own filled instance** — a different file with a different purpose from `templates/FSE.md`, which is the blank master. The two coexist by design.

## Database

**Not applicable — documentation repository, no datastore.**

## How fse-core Operates

- **Self-hosting.** fse-core runs under the methodology it publishes. Every change flows through the FSE session protocol (VERIFY → PLAN → EXECUTE → VALIDATE), the same protocol defined in the methodology block above.
- **Session numbering.** Flat scheme (`SESSION_01`, `SESSION_02`, …). Adoption of self-hosting is `SESSION_01`.
- **VALIDATE gate — documentation integrity.** There is no build. A change passes VALIDATE when: (1) all internal links and file paths in the changed documents resolve, and (2) the `FSE START … FSE END` methodology blocks (in `templates/` and in this root file) are unchanged unless the change is an explicit methodology version bump. This gate replaces the Self-Healing Build Loop for this repository.
- **Versioning.** The methodology version lives in `VERSION` and is mirrored by a git tag (`v1.0.0`). A methodology change that alters the `FSE START … FSE END` block is a version event.
- **Extension convention — notify before implement.** Extensions to FSE are opened by a notification artifact committed before any implementation. The live example is `docs/methodology/daoboard/NOTIFICATION-2026-05-17.md` (DAOBoard). The notification *is* the opening artifact of the extension arc; no code ships under a notification alone.
- **Relationship to fse-extensions.** Stack-specific standing orders and methodology extensions (e.g. the .NET reference implementation, the `kpi` extension) live in the separate `Joticle/fse-extensions` repository, not here.

## Project-Specific Standing Orders

Rules that apply to fse-core in addition to the Universal Standing Orders above. Both ratified in SESSION_01 (2026-06-08).

1. **Templates are published contracts.** Never fill the placeholder slots in `templates/*` — those are filled by adopters in their own repositories. Never edit the `FSE START … FSE END` methodology block (in any `templates/*` file or in this root `FSE.md`) except as part of an explicit methodology version bump recorded in `VERSION` and tagged. Downstream repositories depend on these artifacts as a stable contract.
2. **No methodology or extension change ships without a notification artifact.** Following the DAOBoard convention (`docs/methodology/daoboard/NOTIFICATION-*.md`), any extension to the methodology is opened by a notification authored and committed *before* implementation. The notification states intent, placement, protections, and scope. Implementation proceeds only under a filed notification.

## Warning Baseline

**Not applicable — no build.** The validation gate for this repository is documentation integrity (defined under *How fse-core Operates*), not a warning count.
