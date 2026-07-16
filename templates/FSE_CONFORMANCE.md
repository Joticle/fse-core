# FSE Conformance

FSE_CONFORMANCE.md is the machine-readable single source of truth for one holding's relationship to fse-core. fse-doctor parses the fenced yaml block below; a human reads it directly during VERIFY. Universal FSE rules are NOT restated in holding bedrock — they are fetched from fse-core at the pinned tag. This file records only what is local to the holding: the pinned core version, bindings, and the deviation ledger.

One holding maintains exactly one FSE_CONFORMANCE.md at its bedrock root.

## Schema

```yaml
# fse-doctor parses this block. Human reads it directly. Universal rules are not duplicated here.
conformance_schema: 1              # format version of THIS file; lets fse-doctor parse safely as the schema evolves
holding: ExampleHolding            # holding identifier (local, never a public value)
fse_core_pin: v1.0.0               # exact fse-core tag fetched during VERIFY
last_rebase: 2026-01-01            # UTC date this holding last adopted a core version
last_doctor: 2026-01-01            # UTC date fse-doctor last ran a structural pass

bindings:
  sql_layout: A                   # A = per-module db/{Module}/ | B = flat db/migrations/ applied ledger
  css_prefix: "--ex-"             # project CSS custom-property token prefix
  cross_module: raw-sql           # raw-sql | contracts | both
  reference_seed_home: src/Database/Seeds/
  tier2_present: []               # list of Tier 2 files present, e.g. [FSE_POLICE.md, FSE_SCHEMA.md]

deviations:
  - id: DEV-001
    rule: USO-06                  # USO id or named core rule this deviation is measured against
    summary: one-line description of the deviation
    reason: why the deviation exists and cannot be removed now
    status: accepted              # accepted | remediation-planned
    remediate_by:                 # optional UTC date; only meaningful when status is remediation-planned
    scope: "src/**/Example/*.cshtml"   # optional glob; if present, fse-doctor suppresses matches here
    date: 2026-01-01
```

## Field reference

- conformance_schema — Format version of this file itself, independent of fse_core_pin. Lets fse-doctor evolve parsing without breaking older holdings.
- holding — Local holding identifier. Never a public value.
- fse_core_pin — The exact fse-core tag this holding conforms to. Universal rules are fetched at this tag during VERIFY from the canonical raw source (raw.githubusercontent.com/Joticle-Git/fse-core at the pinned tag). fse-core must remain public: holdings fetch unauthenticated, so making it private breaks every holding's VERIFY. The gap between this pin and the latest fse-core tag is what fse-doctor reports.
- last_rebase — UTC date the holding last adopted a core version via the rebase ritual.
- last_doctor — UTC date of the last fse-doctor structural pass.
- bindings — The per-holding choices that universal rules leave open. Authoritative. This is where drift dies: a binding is a recorded choice a linter enforces, not a thing each holding reinvents.
- bindings.sql_layout — Exactly one layout per holding (A or B). A holding with an existing applied, checksummed migration ledger is B and stays B.
- deviations[] — The deviation ledger. Each entry is one accepted or planned departure from a core rule.
- deviations[].scope — Optional glob. When present, fse-doctor treats matches under it as known and suppresses them. When absent, the deviation is advisory only and fse-doctor still flags matches.

## Rules

- Universal FSE rules are never restated in this file or in holding bedrock. They live once in fse-core at the pinned tag.
- Exactly one sql_layout per holding. The binding is authoritative; an applied checksummed ledger stays on B and is never broken into per-module folders.
- A deviation without a scope glob is advisory: fse-doctor still reports matches. A deviation with a scope glob suppresses matches under that glob. An empty or decorative ledger provides no suppression.
- warning_baseline is NOT recorded here. It lives in FSE_STATE.md as its single source of truth.
- This file is edited only during the rebase ritual or when a deviation is added, accepted, or resolved — never mid-build.
