# FSE secret-scan — pre-push hook

A dependency-free Bash `pre-push` hook that blocks commits containing secrets
from ever reaching a remote. It is the local enforcement of Universal Standing
Order 7 (*credentials are never output, logged, or committed*).

It scans only the lines a push would actually add — not the whole tree — so it
is fast and false-positive-light. The single file `pre-push.sh` has no
dependencies beyond `bash`, `git`, `awk`, `grep`, and `sed`.

## Install

Point this repo's `pre-push` hook at the script (run from the repo root):

```bash
cp tooling/secret-scan/pre-push.sh .git/hooks/pre-push
chmod +x .git/hooks/pre-push
```

Or symlink it so the hook tracks the committed script:

```bash
ln -sf ../../tooling/secret-scan/pre-push.sh .git/hooks/pre-push
```

On Windows use Git Bash for the same commands. To verify without pushing, scan a
file directly:

```bash
tooling/secret-scan/pre-push.sh --scan-file path/to/file
```

## How it works

Two layers run against every added line.

**Layer 1 — deterministic → HARD BLOCK (exit 1).** A match aborts the push.

| ID | Detects |
|----|---------|
| B1 | AWS access key id (`AKIA…`, `ASIA…`, etc.) |
| B2 | Secret-like assignment: `password`/`secret`/`api_key`/`token`/… `=`/`:` a literal value |
| B3 | PEM private-key block (`-----BEGIN … PRIVATE KEY-----`) |
| B4 | GitHub token (`ghp_…`, `github_pat_…`) |
| B5 | Slack token (`xoxb-…`, etc.) |
| B6 | Connection-string password (`pwd=…` / `password=…`) |
| A1 | JWT (`eyJ….….…`) |
| A2 | Hex secret ≥ 64 chars **in value position** (after `=`/`:`) |
| A3 | Base64 blob ≥ 40 chars **in value position** |
| A4/A5 | Project-local literals loaded from `.fse-secrets-patterns` (see below) |

A2/A3 are deliberately **context-bound** to a value position — a documented
deviation from a pure "shape" match so the hook does not hard-block on git SHAs,
lockfile hashes, and asset fingerprints that appear outside assignments.

**Layer 2 — entropy → WARN only.** High-Shannon-entropy tokens (base64
≥ 4.5 bits/char, hex ≥ 3.0 bits/char, length ≥ 20) are reported but do **not**
block a push on their own.

## Carve-outs (never treated as a secret)

B2/B6 do not fire when the captured value is a non-secret, including:

- empty string `""`
- an env/config reference — `${VAR}`, `%VAR%`, `{{VAR}}`, `$(VAR)`, `#{VAR}`,
  `<PLACEHOLDER>`, or `process.env` / `os.environ` / `builder.Configuration` /
  `.GetConnectionString` / `ENV[…]` and similar
- obvious placeholders — `your_*`, `changeme`, `replace_me`, `placeholder`,
  `example`, `redacted`, `dummy`, `none`, `null`, `n/a`, `tbd`, `todo`
- all-`x` or all-`*` masks

## `.fse-secrets-patterns` (A4/A5)

Project-local literals — retired-credential strings and deploy-profile names —
live one-per-line in `<repo-root>/.fse-secrets-patterns`. Each non-blank,
non-comment line is matched as a **case-insensitive substring**. This file is
**gitignored and never committed** (it would itself be a secret inventory); it is
loaded at runtime. Blank lines and `#` comments are ignored.

## Escape hatch — `# fse-allow: <reason>`

Append `# fse-allow: <reason>` to a line to suppress a documented false positive.
**The reason is required** — a bare `# fse-allow:` with no reason is *not*
honored and is reported as an ignored advisory (`note:`).

## Exit codes

| Code | Meaning |
|------|---------|
| 0 | No blocking findings (entropy warnings may print; push allowed) |
| 1 | One or more Layer 1 findings — push blocked |
| 2 | Usage error (`--scan-file` with a missing path) |

## Testing

Planted, obviously-fake secrets used to exercise the hook use the `*.fse-test`
extension, which is gitignored by construction so a test fixture can never enter
a commit. Scan one directly with `--scan-file`.
