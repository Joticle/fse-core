# fse-doctor — conformance validator + structural pass

`fse-doctor` reads a holding's `FSE_CONFORMANCE.md`, validates it, reports how far
its pin has drifted from fse-core, and enforces the bindings the holding declared.

It is the enforcement half of the pin/conformance model. `FSE_CONFORMANCE.md`
records the choices; fse-doctor is what makes them cost something to ignore. A
binding nothing checks is a comment.

It lives in fse-core — not in a stack extension — because the parser and the
schema must stay version-locked. A holding pins one tag and gets the rules *and*
the matching enforcer: `fse_core_pin: v1.2.1` fetches both at `v1.2.1`. A parser
versioned separately from the schema it parses is the exact drift this model exists
to kill.

Zero dependencies beyond `bash`, `awk`, `sed`, `grep`, `git`, `curl` — fse-core has
no build and takes no runtime dependencies.

## Usage

Run from a holding's bedrock root:

```bash
tooling/fse-doctor/fse-doctor.sh
```

| Flag | Effect |
|------|--------|
| `--file PATH` | Explicit conformance file (default `<root>/FSE_CONFORMANCE.md`) |
| `--root PATH` | Holding root to scan (default: git toplevel, else cwd) |
| `--no-net` | Skip the pin-drift fetch (offline / air-gapped CI) |
| `--quiet` | Findings only — no header or clean line |

As a gate (CI step, or a `pre-push` hook alongside `secret-scan`):

```bash
tooling/fse-doctor/fse-doctor.sh --quiet || exit 1
```

## The three layers

**Layer 1 — schema → FAIL.** The file must be parseable and complete:
`conformance_schema` supported; `holding` present; `fse_core_pin` an exact
`vN.N.N` tag; `last_rebase` / `last_doctor` UTC `YYYY-MM-DD`; `sql_layout` ∈ `A|B`;
`cross_module` ∈ `raw-sql|contracts|both`; `css_prefix` and `reference_seed_home`
present. Ledger hygiene: ids unique and `DEV-NNN`-shaped, `rule`/`summary`/`reason`
present, `status` ∈ `accepted|remediation-planned`, and `remediate_by` required
**iff** status is `remediation-planned` (and meaningless when `accepted`).

**Layer 2 — pin drift → WARN.** Fetches fse-core's tags and reports how many
releases behind `fse_core_pin` sits, so the rebase ritual has a trigger instead of
a vibe. A pin naming a tag that does not exist is a **FAIL**. Requires fse-core to
be reachable and **public** — holdings fetch unauthenticated.

**Layer 3 — structural → FAIL.** Enforces the declared bindings against tracked
files (build output and vendor trees are never scanned):

| Rule | Check |
|------|-------|
| USO-01 | No `TODO` / `FIXME` / `NotImplementedException` markers |
| USO-08 | No hard-coded hex / `rgb()` / raw `px` in `.css/.scss/.cshtml/.razor`. The file that *defines* the `css_prefix` tokens is exempt automatically |
| USO-13 | Layout **A**: `db/{Module}/{NNN}_{verb}_{object}.sql`, verb ∈ `create,alter,seed,drop,fix,verify`; a flat `db/migrations/` under layout A is a mixed-layout violation. Layout **B**: `db/migrations/{NNN}_{topic}.sql` (plus `db/_meta/`) |
| claims | Every file listed in `tier2_present` must actually exist |
| bindings | `reference_seed_home` should resolve (**WARN** — a holding may have no standing seeds yet) |

## Deviations suppress findings — but only if scoped

A deviation with a `scope:` glob suppresses structural findings whose path matches,
**and only for the USO named in its `rule:`**. A deviation with no scope is
advisory: findings are still reported. An empty or decorative ledger suppresses
nothing. This is what stops the ledger from becoming a place to write "we know" and
move on.

```yaml
deviations:
  - id: DEV-001
    rule: USO-08
    summary: legacy hero styles predate tokens
    reason: shared with a vendor bundle; cannot retheme yet
    status: accepted
    scope: "wwwroot/css/legacy-*.css"   # USO-08 findings under here are suppressed
    date: 2026-01-01
```

Globs support `*` (within a path segment), `**` (across segments), and `?`.

## Exit codes

| Code | Meaning |
|------|---------|
| 0 | Clean — warnings may still print (pin drift, missing seed home) |
| 1 | Findings — schema errors, or structural violations no deviation scopes |
| 2 | Usage error — no conformance file, or no fenced `yaml` block in it |

## Scope, honestly

Only a minority of the 13 Universal Standing Orders are mechanically checkable.
USO-01, USO-08 and USO-13 are; credentials (USO-07) are covered by
`tooling/secret-scan`. The rest — "wait for explicit approval," provenance tagging,
the Counter-Point Protocol — are process rules no linter can audit. fse-doctor
moves *some* conformance auditing off human vigilance. It does not replace it, and
a green run is not a claim that the session followed the protocol.
