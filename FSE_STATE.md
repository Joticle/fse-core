# FSE_STATE.md — Living Project State

This file is updated at the end of every session. It is the single source of truth for "where the project is right now."

## Identity

- **Project:** fse-core — the FlowState Engineering methodology repository
- **FSE Version:** 1.2.1
- **Last Updated:** 2026-07-09
- **Last Session By:** Scott Michael Wilson

## Build State

- **Build:** N/A — documentation repository, no build
- **Tests:** N/A — no tests
- **Lint:** N/A — no lint configured
- **Type check:** N/A — not applicable
- **Last verified:** 2026-06-08

Verification for this repository is the documentation-integrity gate, not a build command:

```
Manual review: internal links/paths resolve; templates' FSE START/END blocks
unedited outside a version bump. (No tooling wired yet.)
```

## Current Blockers

*None.*

## Open Decisions

No decisions are currently open. The four SESSION_01 adoption decisions were made and cleared this session:

- **Session numbering scheme** → Flat (`SESSION_01` forward). Cleared SESSION_01.
- **VALIDATE gate** → Documentation integrity (links/paths resolve; methodology blocks unedited outside a version bump). Cleared SESSION_01.
- **AI wiring file** → `.claude/instructions.md` pointing at the three root foundation files. Cleared SESSION_01.
- **Project-Specific Standing Orders** → Two orders ratified (published-contract integrity; notification-before-implementation). Cleared SESSION_01.

## Next Session Priorities

1. **Pin-model USO promotion** (notification-gated, version event) — promote the pin/conformance model to a standing order via a filed notification. Both blockers are now cleared: fetch base resolved (SESSION_08) and fse-doctor built + schema validated (SESSION_09). Must inscribe: (a) fse-core stays **public** — holdings fetch rules unauthenticated over raw; (b) `tooling/fse-doctor/` is the enforcer, version-locked to the schema by the same pin.
2. Wire fse-doctor as a gate in a pilot holding — add `FSE_CONFORMANCE.md` to one holding and run fse-doctor in CI or a `pre-push` hook (alongside `secret-scan`). Until a holding actually runs it, the model is validated but unadopted.
3. Decide the DAOBoard inscription path — the Public Surface Discipline standing order (`docs/methodology/daoboard/NOTIFICATION-2026-05-17.md`) is notified but not yet inscribed. Session N+1 of the arc authors the schema + example and inscribes the standing order; it is a minor version event (→ 1.3.0) and needs explicit operator go.
4. Audit fse-extensions content status (separate repository) — DAOBoard aggregator and .NET extension state (tracked gap). Partially answered in SESSION_08: no fse-doctor/conformance tooling exists there.

## Warning Baseline

N/A — no build. The gate is documentation integrity.

## Lessons Learned

*No lessons recorded yet.*

## Known Technical Debt

*No technical debt recorded yet.*

## Session Log

| Session | Date | Scope | Outcome | Report |
|---------|------|-------|---------|--------|
| SESSION_01 | 2026-06-08 | Adopt FSE self-hosting — author root `FSE.md`, `FSE_STATE.md`, `FSE_DISCOVERY.md` + `.claude/instructions.md` wiring | success | (no separate report — recorded inline under Session History) |
| SESSION_02 | 2026-06-18 | Promote Planning Provenance to USO 12 — methodology v1.0.0 → v1.1.0 | success | (no separate report — recorded inline under Session History) |
| SESSION_03 | 2026-07-01 | Promote Query Artifact Discipline to USO 13 — methodology v1.1.0 → v1.2.0 | success | (no separate report — recorded inline under Session History) |
| SESSION_04 | 2026-07-09 | Single-interface terminology correction — retire "CLI invocation/session/run" from the methodology block; methodology v1.2.0 → v1.2.1 | success | (no separate report — recorded inline under Session History) |
| SESSION_05 | 2026-07-09 | Clear parked queue — fix README `prompts/` path + structure; land S87 secret-scan (`.gitignore` + hook + README) | success | (no separate report — recorded inline under Session History) |
| SESSION_06 | 2026-07-09 | Add `templates/FSE_CONFORMANCE.md` — pin/conformance model spec + template (doc-only, no version event) | success | (no separate report — recorded inline under Session History) |
| SESSION_07 | 2026-07-09 | Refresh public README — version 1.0.0 → 1.2.1, standing-orders list 7 → 13 (doc-only) | success | (no separate report — recorded inline under Session History) |
| SESSION_08 | 2026-07-09 | Resolve pin-model fetch base → canonical `Joticle-Git/fse-core`; repoint local origin (doc-only) | success | (no separate report — recorded inline under Session History) |
| SESSION_09 | 2026-07-13 | Build fse-doctor — conformance validator + pin drift + structural pass (`tooling/fse-doctor/`) | success | (no separate report — recorded inline under Session History) |

## Session History

Most recent session first. Each entry is short — the diff tells the story of *what*; this log captures *why*.

---

### SESSION_09 — 2026-07-13 — Build fse-doctor (conformance validator + structural pass)
**Goal:** Build the enforcement half of the pin model *before* promoting it, so writing the parser pressure-tests `conformance_schema: 1` while it can still change cheaply.
**Done:**
- Added `tooling/fse-doctor/fse-doctor.sh` + `README.md`. Three layers: **schema** (parse/validate the fenced yaml, enums, ledger hygiene — FAIL), **pin drift** (fetch fse-core tags, report releases behind; nonexistent pin FAILs — WARN), **structural** (USO-01 stubs, USO-08 token-first using the `css_prefix` binding, USO-13 sql layout grammar per the `sql_layout` binding, `tier2_present` claims — FAIL). Deviation `scope:` globs suppress findings, but only for the USO named in `rule:`.
- Zero dependencies (bash/awk/sed/grep/git/curl), matching the `tooling/secret-scan` precedent and fse-core's no-build identity.
- **Placed in fse-core, not fse-extensions** (reversing the earlier assumption): the parser and schema must stay version-locked, so one pin (`fse_core_pin: v1.2.1`) fetches the rules *and* the matching enforcer. A separately-versioned parser would reintroduce the drift the model exists to kill. fse-extensions is also 100% markdown with no bedrock — an executable there would be a first.
- Validated against fixture holdings, 8 cases: violations caught (hex, raw px, bad SQL verb, TODO), token-definition file correctly exempt, scope-glob suppression working, pin drift correct live against canonical fse-core (`v1.0.0` → "3 releases behind"), nonexistent pin FAILs, schema/enum/ledger failures FAIL, missing file exits 2, clean holding exits 0.
**Schema verdict (the reason for build-before-promote):** `conformance_schema: 1` survived contact with a parser — no shape changes needed. It is safe to freeze in the promotion session.
**Bug caught by testing:** the first glob→regex translator passed globs through `sed`, which broke on `{}` inside a bracket expression and silently disabled **all** scope suppression — the mechanism that makes the deviation ledger load-bearing. Rewritten as a pure-bash char-by-char translator. Had this shipped unbuilt, every scoped deviation would have been decorative.
**Scope guard:** Tooling only. `FSE.md` unchanged, `VERSION` unchanged (1.2.1), no USO added, no version event.
**Honest limit:** Only USO-01/08/13 are mechanically checkable (USO-07 is covered by `tooling/secret-scan`). The other nine are process rules no linter can audit — a green fse-doctor run is not a claim the protocol was followed.
**Next:** Pin-model USO promotion (notification-gated). Must inscribe the fse-core-stays-public constraint and reference fse-doctor as the enforcer.

---

### SESSION_08 — 2026-07-09 — Resolve the pin-model fetch base (canonical org path)
**Goal:** Close the load-bearing URL dependency recorded in SESSION_06 before it reached the promotion session.
**Done:**
- Verified the org transfer is complete: `Joticle-Git/fse-core` and `Joticle/fse-core` both resolve to the same commit, and raw at tag `v1.2.1` returns `1.2.1` (HTTP 200) on both bases — nothing was broken.
- Repointed `templates/FSE_CONFORMANCE.md`'s fetch base to the canonical `raw.githubusercontent.com/Joticle-Git/fse-core`; repointed this repo's local `origin` to `https://github.com/Joticle-Git/fse-core.git`.
**Reasoning:** The old base resolved only via GitHub's old-owner redirect. That redirect dies the moment a repo named `fse-core` is recreated under the still-existing `Joticle` account — and the failure mode is not a 404 anyone would notice, it is **silently serving a different repo's rules** to every holding's VERIFY. Pinning to the canonical path removes the redirect dependency entirely.
**Load-bearing constraint (new, inscribed in the template):** The pin model requires fse-core to remain **public** — holdings fetch universal rules unauthenticated over raw. If fse-core ever goes private, every holding's VERIFY fetch 404s (the same class of failure that stalled the fse-website CI when its runner group excluded public repos). The promotion session should carry this constraint into the USO text.
**Next:** Build fse-doctor before promoting. It is named throughout `FSE_CONFORMANCE.md` but exists in neither fse-core nor fse-extensions (both greped, zero hits) — until it exists the conformance file adds reading cost without adding enforcement.

---

### SESSION_07 — 2026-07-09 — Refresh public README to current methodology
**Goal:** Close the tracked gap where the public README lagged the methodology.
**Done:** README header `1.0.0 → 1.2.1`; extended the "Universal Standing Orders" summary from 7 to all 13 (condensed one-liners added for USO 8–13: Token-First Construction, Pattern-First Design, Visual Validation Phase, Bedrock Authoring Guard, Planning Provenance, Query Artifact Discipline). Removed the corresponding `FSE_DISCOVERY.md` gap row.
**Scope guard:** Doc-only. No `FSE.md` or `VERSION` change, no version event — `VERSION` was already 1.2.1; this only aligns the human-facing README to the source of truth.
**Next:** Pin-model USO promotion (+ fetch-base URL) and DAOBoard inscription remain the open items.

---

### SESSION_06 — 2026-07-09 — Add FSE_CONFORMANCE.md spec + template (pin/conformance model)
**Goal:** Introduce the pin/conformance model as a copyable methodology artifact — holdings stop transcribing universal FSE rules and instead pin an fse-core version, record only local bindings + a deviation ledger, and fetch universal rules from fse-core at the pinned tag during VERIFY.
**Done:**
- Added `templates/FSE_CONFORMANCE.md`: one fenced yaml block (parsed by fse-doctor, read by humans at VERIFY) carrying `fse_core_pin`, `bindings`, and a `deviations` ledger, plus field reference and rules. Public-sanitized — every example value generic/fictional (`holding: ExampleHolding`, `css_prefix: "--ex-"`, `scope: src/**/Example/*.cshtml`); zero holding/codename/client values.
- Two convention adjustments vs the source text, to match live fse-core names so the anti-drift artifact does not itself plant drift: `SESSION_STATE.md → FSE_STATE.md` (warning_baseline home) and `CLAUDE_POLICE.md/CLAUDE_SCHEMA.md → FSE_POLICE.md/FSE_SCHEMA.md` (tier2_present example).
**Scope guard:** Doc-only. `FSE.md` unchanged, `VERSION` unchanged (stays 1.2.1), no USO added, no version event. The pin-model USO promotion and its version event remain a separate, notification-gated session.
**Load-bearing dependency (carry forward):** The spec hardcodes the raw fetch base `raw.githubusercontent.com/Joticle/fse-core` — every holding's VERIFY fetches universal rules from it. The org transfer to `Joticle-Git` is in progress (observed as a push redirect this session); if it finalizes, this base moves and every conformance file points at a dead source. The pin-model USO session MUST confirm/update this URL as part of promotion.
**Next:** Notification-gated pin-model USO promotion (also resolves the fetch-base URL). Until then FSE_CONFORMANCE.md is a published template only, not yet a standing order.

---

### SESSION_05 — 2026-07-09 — Clear parked queue (README fix + land S87 secret-scan)
**Goal:** Empty the standing carry-over queue: the README `prompts/` path discrepancy and the parked S87 secret-scan WIP.
**Done:**
- **README path/structure fix.** Corrected the dead `prompts/ONBOARDING_PROMPT.md` link to `templates/ONBOARDING_PROMPT.md`, and rewrote the "Repository Structure" block to match reality — added `docs/`, `VERSION`, the root self-hosting foundation files, and the four previously-omitted templates (`FSE_POLICE`, `FSE_PACKAGES`, `PATTERNS`, `FIELD_REPORT_TEMPLATE`).
- **Landed S87 secret-scan.** Committed the previously-untracked `.gitignore` and `tooling/secret-scan/pre-push.sh`, and authored the missing `tooling/secret-scan/README.md` the `.gitignore` referenced (dangling reference resolved). The hook is a dependency-free pre-push secret scanner (Layer 1 deterministic hard-block B1–B6/A1–A5, Layer 2 entropy warn, `# fse-allow:` escape, value-position carve-outs). Verified by code inspection; the planted-fixture smoke test was declined this session and not run.
- Closed the corresponding `FSE_DISCOVERY.md` gaps (`.gitignore` absent; README structure omissions) and checked the infrastructure-checklist `.gitignore` item.
**Reasoning:** All three are documentation-integrity items, not methodology-block edits — no version event, `VERSION` stays 1.2.1. The README's *methodology-currency* staleness (header still says "version 1.0.0"; standing-orders section lists 7 of 13) is a larger content update than the tracked path/structure gap, so it was surfaced as a new `FSE_DISCOVERY.md` gap rather than silently expanded into.
**DAOBoard (still open, not actioned):** The third queue item — inscribing the Public Surface Discipline standing order + schema from `docs/methodology/daoboard/NOTIFICATION-2026-05-17.md` — is the opening build session of a 7-session extension arc and a minor version event (→ 1.3.0). It requires an explicit operator decision on the inscription path and was left for a dedicated session.
**Next:** Decide the DAOBoard inscription path; refresh the public README to the current methodology (version + full standing-orders list); audit fse-extensions content status.

---

### SESSION_04 — 2026-07-09 — Single-interface terminology correction (methodology v1.2.1)
**Goal:** Retire tool-boundary–flavored language from the methodology block. The methodology's planning/execution separation is an approval gate, not a two-app tool boundary; the operator runs a single interface (Claude Code Desktop), one project per Holding tab.
**Done:**
- Swept `CLI invocation / CLI session / CLI run / CLI-generated` from the *Session Numbering & Artifact Lifecycle* section of both the root `FSE.md` and the published master `templates/FSE.md`. A session is now defined as "one complete assistant session," and identifiers "count sessions, not git operations." Wording kept tool-agnostic per USO contract (`README.md` — "works with Claude Code, Cursor, Copilot, Windsurf, Aider").
- Bumped `VERSION` 1.2.0 → 1.2.1 — editing the `FSE START … FSE END` block is a version event.
**Reasoning:** fse-core never encoded a two-app separation; its PLAN phase was already the tool-agnostic approval gate. The only anachronism at the source was the "CLI invocation/run" phrasing, which reads as if a session is bound to a command-line tool. The change is terminological and backward compatible, so a patch bump (1.2.0 → 1.2.1), not minor: no new standing order, no PLAN-phase mechanics, no template output convention. Plan-mode enforcement language and the USO 12 single-interface reinforcement were considered and deferred — they would name a tool-specific feature inside the tool-agnostic constitution; that framing belongs in the fse-website Holding and tool-setup docs, not Core.
**Related Holding:** The public two-app framing ("Claude Web is the planning layer / Claude Code is the execution layer") lives in `Joticle/fse-website` (`Pages/HowItWorks.cshtml`), reframed to two *modes* in the same coordinated change — tracked in that repo's own state file.
**Next:** Carry-over remains open — fix the README `prompts/` path discrepancy; land the parked S87 secret-scan WIP (`.gitignore` + `tooling/secret-scan/`); decide the DAOBoard inscription path.

---

### SESSION_03 — 2026-07-01 — Promote Query Artifact Discipline to USO 13 (methodology v1.2.0)
**Goal:** Inscribe the Query Artifact Discipline rule into the methodology constitution as Universal Standing Order 13.
**Done:**
- Filed the opening notification artifact `docs/methodology/query-artifact-discipline/NOTIFICATION-2026-07-01.md` before any methodology edit, per the notification-before-implementation standing order (commit a2bf0bf).
- Added USO 13 (Query Artifact Discipline) to the Universal Standing Orders. No PLAN-phase mechanics and no template convention were added; this arc is a standing-order addition only.
- Bumped `VERSION` 1.1.0 → 1.2.0 and tagged `v1.2.0` — editing the `FSE START … FSE END` block is a version event.
**Reasoning:** Query Artifact Discipline closes query-artifact drift — the failure where, absent a rule, schema scripts land wherever the author last put one, queries are written inline at the call site, and cross-boundary reads look identical to same-boundary reads. The rule is three clauses: explicit, human-authored, versioned schema in one canonical location; centralized, named queries; and explicit marking of cross-boundary access. The discipline turns on the third clause — a seam that cannot be grepped cannot be governed. Core defines the principle; concrete file locations, naming grammar, language bindings, and boundary-marking syntax belong to each project's binding layer or stack extension. The change is additive and backward compatible, so a minor bump (1.1.0 → 1.2.0), not major. Stated in the abstract as a property of AI-assisted development, with no origin incident named — consistent with the notification artifact filed in a2bf0bf.
**Next:** Carry-over remains open — fix the README `prompts/` path discrepancy; complete and land the parked S87 secret-scan WIP (`.gitignore` + `tooling/secret-scan/`); decide the DAOBoard inscription path.

---

### SESSION_02 — 2026-06-18 — Promote Planning Provenance to USO 12 (methodology v1.1.0)
**Goal:** Inscribe the Planning Provenance rule into the methodology constitution as Universal Standing Order 12.
**Done:**
- Filed the opening notification artifact `docs/methodology/planning-provenance/NOTIFICATION-2026-06-18.md` before any methodology edit, per the notification-before-implementation standing order.
- Added USO 12 (Planning Provenance) to the Universal Standing Orders and amended the PLAN phase with the D/E/I/S tagging step and the surface-Inferred step.
- Bumped `VERSION` 1.0.0 → 1.1.0 and tagged `v1.1.0` — editing the `FSE START … FSE END` block is a version event.
- Added the Planning Provenance output convention to `templates/FSE_STATE.md` so downstream adopters inherit it.
**Reasoning:** Planning Provenance closes the inference-as-requirement failure mode — an unprompted judgment call that persists in a plan acquires the authority of a directive over later sessions. The D/E/I/S taxonomy makes provenance explicit; surfacing only Inferred elements (Scaffold exempt) keeps the confirmation gate low-noise. It is the planning-time companion to USO 11 (Bedrock Authoring Guard): USO 11 governs what gets written into foundation files, USO 12 governs what gets acted on during a session. Framed as a methodology-side rule on its own merits, with no origin incident named.
**Next:** Carry-over from SESSION_01 remains open — fix the README `prompts/` path discrepancy; add `.gitignore`; decide the DAOBoard inscription path.

---

### SESSION_01 — 2026-06-08 — Adopt FSE self-hosting
**Goal:** Make fse-core run under the methodology it publishes.
**Done:**
- Authored root `FSE.md`, `FSE_STATE.md`, `FSE_DISCOVERY.md` describing fse-core as it actually is — a documentation/methodology repository. Stack, Database, Module Pattern, and Warning Baseline are marked Not Applicable rather than filled with .NET-stack values.
- Created `.claude/instructions.md` wiring the AI to read the foundation files at session start.
- Ratified two project-specific standing orders: published-contract integrity, and notification-before-implementation.
- Adopted flat session numbering; this is SESSION_01.
- Defined the VALIDATE gate as documentation integrity.
**Reasoning:** fse-core published the FSE templates but did not itself run under FSE — it had no root foundation files. Self-hosting closes that gap and makes the repository its own reference instance. The methodology repo following its own methodology is the strongest demonstration of the methodology.
**Prior methodology decisions live in git history — referenced, not reconstructed:** USO #11 Bedrock Authoring Guard (`bdc4ad7`), Tier 2 templates (`e64104b`), MODULE.md context-bounded-context constraint (`8cb2908`), v1.0.0 versioning (`84031a6`), 15KB split-trigger fix (`c57ef17`). No fabricated dated reasoning is supplied for these — consult the commits.
**Next:** Fix the README `prompts/` path discrepancy (tracked gap); add `.gitignore`; decide the DAOBoard inscription path.

---
