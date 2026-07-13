#!/usr/bin/env bash
# ============================================================================
# FlowState Engineering — secret-scan pre-push hook   (fse-core / tooling)
# ----------------------------------------------------------------------------
# Layer 1  DETERMINISTIC  -> HARD BLOCK (exit 1)
#   B1-B6 : provider tokens, secret assignment, connection-string passwords
#   A1-A3 : structural "shape" patterns (JWT / hex / base64)
#           A2/A3 are CONTEXT-BOUND (value position only) — a deliberate,
#           operator-approved deviation from the literal "shape pattern" scope
#           to avoid hard-blocking on git SHAs, lockfile hashes, and assets.
#   A4-A5 : project-local literals (retired credentials, deploy profile names)
#           loaded at runtime from <repo-root>/.fse-secrets-patterns
# Layer 2  ENTROPY        -> WARN ONLY (does not block on its own)
#           base64 >= 4.5 bits/char, hex >= 3.0 bits/char, min length 20
#
# Escape:  append   # fse-allow: <reason>   (reason REQUIRED) to suppress a line
# Carve-outs (never a secret): empty string, bare env-var ref, ${..}/%..% interp
#
# Usage:  pre-push.sh                 (git pre-push; reads ref updates on stdin)
#         pre-push.sh --scan-file F   (scan one file directly; used by tests)
# ============================================================================
set -u

ENTROPY_MIN_LEN=20
ENTROPY_B64_BITS=4.5
ENTROPY_HEX_BITS=3.0
ZERO_SHA=0000000000000000000000000000000000000000

block_hits=()   # FILE:LINE | ID | description
warn_hits=()    # FILE:LINE | entropy | token-info
note_hits=()    # advisories (e.g. fse-allow with no reason)

# ---------------------------------------------------------------------------
# DETERMINISTIC PATTERNS  (POSIX ERE, used with bash =~)
# Case-sensitive provider/shape patterns run against the raw line; the two
# keyword patterns (B2, B6) run against a lowercased copy so they are
# case-insensitive without (?i), which bash ERE does not support.
# ---------------------------------------------------------------------------
RE_B1='(AKIA|ASIA|AGPA|AIDA|AROA)[0-9A-Z]{16}'                    # AWS access key id
RE_B3='-----BEGIN ([A-Z0-9]+ )?PRIVATE KEY-----'                 # PEM private key
RE_B4='(gh[pousr]_[0-9A-Za-z]{36}|github_pat_[0-9A-Za-z_]{22,})'  # GitHub token
RE_B5='xox[baprs]-[0-9A-Za-z]{8,}-[0-9A-Za-z-]{8,}'              # Slack token
RE_A1='eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{8,}'  # JWT

# B2 generic secret assignment  (keyword + assign + value)  -> value captured
RE_B2='(password|passwd|pwd|secret|api[_-]?key|apikey|access[_-]?key|client[_-]?secret|auth[_-]?token|token|credential)["'"'"']?[[:space:]]*[:=][[:space:]]*(.*)$'
# B6 connection-string password   pwd=... / password=...      -> value captured
RE_B6='(password|pwd)=([^;"'"'"'[:space:]]{6,})'

# A2/A3 shapes are CONTEXT-BOUND (must be a quoted/assigned value).
RE_A2='[:=][[:space:]]*["'"'"']?[0-9a-fA-F]{64,}'                 # hex secret (>=64) in value position
RE_A3='[:=][[:space:]]*["'"'"']?[A-Za-z0-9+/]{40,}={0,2}'        # base64 blob (>=40) in value position

# ---------------------------------------------------------------------------
# A4/A5 — load project-local literals from sibling patterns file.
# Each non-blank, non-comment line is matched as a CASE-INSENSITIVE literal
# substring (A4 = retired-credential strings, A5 = deploy profile names).
# The file lives at the repo root and is gitignored — never committed.
# ---------------------------------------------------------------------------
LOCAL_PATTERNS=()
load_local_patterns() {
  local root pf
  root="$(git rev-parse --show-toplevel 2>/dev/null)" || return 0
  pf="$root/.fse-secrets-patterns"
  [[ -f "$pf" ]] || return 0
  local ln
  while IFS= read -r ln || [[ -n "$ln" ]]; do
    ln="${ln%%$'\r'}"                       # tolerate CRLF
    [[ -z "${ln//[[:space:]]/}" ]] && continue
    [[ "${ln#"${ln%%[![:space:]]*}"}" == \#* ]] && continue
    LOCAL_PATTERNS+=("$ln")
  done < "$pf"
}

# ---------------------------------------------------------------------------
# CARVE-OUTS — value-level tests that PREVENT B2/B6 from firing on legitimate
# code. Applied to the captured value (and full RHS for env refs).
# Carve-out regexes are held in variables so bash treats them as patterns,
# not shell syntax (literal ()/{}/<> in an inline =~ break the [[ ]] parser).
# Returns 0 (carve-out, NOT a secret) or 1 (treat as candidate secret).
# ---------------------------------------------------------------------------
CO_DOLLAR_BRACE='^\$\{[^}]*\}$'
CO_PERCENT='^%[^%]*%$'
CO_HANDLEBARS='^\{\{[^}]*\}\}$'
CO_DOLLAR_PAREN='^\$\([^)]*\)$'
CO_HASH_BRACE='^#\{[^}]*\}$'
CO_ANGLE='^<[^>]*>$'
CO_ENVREF='(process\.env|os\.environ|os\.getenv|getenv|System\.getenv|Environment\.GetEnvironmentVariable|configuration\[|builder\.configuration|\.GetConnectionString|ENV\[|[^A-Za-z]env\[)'

extract_literal() {            # $1 = RHS text after the : or =
  local rhs="$1" lit
  rhs="${rhs#"${rhs%%[![:space:]]*}"}"                 # ltrim
  if   [[ $rhs =~ ^\"([^\"]*)\" ]]; then lit="${BASH_REMATCH[1]}"
  elif [[ $rhs =~ ^\'([^\']*)\' ]]; then lit="${BASH_REMATCH[1]}"
  else lit="${rhs%%[[:space:];,)]*}"; fi              # unquoted: up to delimiter
  printf '%s' "$lit"
}
is_carveout() {                # $1 = literal value, $2 = full RHS
  local v="$1" rhs="$2" lv
  [[ -z "$v" ]] && return 0                                   # empty string  ""
  [[ $v =~ $CO_DOLLAR_BRACE ]] && return 0                    # ${VAR}
  [[ $v =~ $CO_PERCENT      ]] && return 0                    # %VAR%
  [[ $v =~ $CO_HANDLEBARS   ]] && return 0                    # {{VAR}}
  [[ $v =~ $CO_DOLLAR_PAREN ]] && return 0                    # $(VAR)
  [[ $v =~ $CO_HASH_BRACE   ]] && return 0                    # #{VAR}
  [[ $v =~ $CO_ANGLE        ]] && return 0                    # <PLACEHOLDER>
  [[ $rhs =~ $CO_ENVREF     ]] && return 0                    # bare env/config ref
  lv="${v,,}"
  case "$lv" in
    your_*|changeme|change_me|replace_me|replaceme|placeholder|example|redacted|dummy|none|null|n/a|tbd|todo) return 0;;
  esac
  [[ $lv =~ ^x+$ ]] && return 0                               # xxxxxxxx
  [[ $lv =~ ^\*+$ ]] && return 0                              # ********
  return 1
}

# ---------------------------------------------------------------------------
# ENTROPY — Shannon bits/char via awk, with the 4.5/3.0/20 gates.
# ---------------------------------------------------------------------------
shannon_bits() {               # $1 = token -> prints bits/char
  awk -v s="$1" 'BEGIN{
    n=length(s); if(n==0){print 0; exit}
    for(i=1;i<=n;i++){c=substr(s,i,1); f[c]++}
    e=0; for(c in f){p=f[c]/n; e-=p*log(p)/log(2)}
    printf "%.4f", e
  }'
}
ge() { awk -v a="$1" -v b="$2" 'BEGIN{exit !(a>=b)}'; }       # a >= b ?

entropy_scan() {               # $1=file $2=lineno $3=content
  local file="$1" no="$2" line="$3" tok bits gate kind
  while read -r tok; do
    [[ ${#tok} -lt $ENTROPY_MIN_LEN ]] && continue
    if [[ $tok =~ ^[0-9a-fA-F]+$ ]]; then gate=$ENTROPY_HEX_BITS; kind=hex
    else gate=$ENTROPY_B64_BITS; kind=base64; fi
    bits="$(shannon_bits "$tok")"
    if ge "$bits" "$gate"; then
      warn_hits+=("$file:$no | entropy | ${kind} len=${#tok} bits=${bits} (>= ${gate})")
    fi
  done < <(grep -oE '[A-Za-z0-9+/=_-]{20,}' <<<"$line")
}

# ---------------------------------------------------------------------------
# # fse-allow: <reason>  — reason REQUIRED. A bare `fse-allow:` with no reason
# is NOT honored and is reported as an ignored advisory.
# ---------------------------------------------------------------------------
allow_state() {                # $1=line -> "allow" | "noreason" | "none"
  local line="$1"
  if [[ $line =~ \#[[:space:]]*fse-allow:[[:space:]]*[^[:space:]] ]]; then echo allow
  elif [[ $line =~ \#[[:space:]]*fse-allow: ]]; then echo noreason
  else echo none; fi
}

# ---------------------------------------------------------------------------
# Core scanner — one logical line.
# ---------------------------------------------------------------------------
scan_line() {                  # $1=file $2=lineno $3=content
  local file="$1" no="$2" line="$3" lc rhs val p
  case "$(allow_state "$line")" in
    allow)    return 0 ;;                                      # suppressed (reason present)
    noreason) note_hits+=("$file:$no | fse-allow with no reason — ignored (reason required)") ;;
  esac
  lc="${line,,}"

  if   [[ $line =~ $RE_B1 ]]; then block_hits+=("$file:$no | B1 | AWS access key id"); return 0
  elif [[ $line =~ $RE_B3 ]]; then block_hits+=("$file:$no | B3 | private key PEM block"); return 0
  elif [[ $line =~ $RE_B4 ]]; then block_hits+=("$file:$no | B4 | GitHub token"); return 0
  elif [[ $line =~ $RE_B5 ]]; then block_hits+=("$file:$no | B5 | Slack token"); return 0
  elif [[ $line =~ $RE_A1 ]]; then block_hits+=("$file:$no | A1 | JWT"); return 0
  elif [[ $line =~ $RE_A2 ]]; then block_hits+=("$file:$no | A2 | hex secret (>=64) in value position"); return 0
  elif [[ $line =~ $RE_A3 ]]; then block_hits+=("$file:$no | A3 | base64 blob (>=40) in value position"); return 0
  fi

  if [[ $lc =~ $RE_B2 ]]; then
    rhs="${BASH_REMATCH[2]}"; val="$(extract_literal "$rhs")"
    if ! is_carveout "$val" "$rhs"; then
      block_hits+=("$file:$no | B2 | secret-like assignment with literal value"); return 0
    fi
  fi
  if [[ $lc =~ $RE_B6 ]]; then
    val="${BASH_REMATCH[2]}"
    if ! is_carveout "$val" "$val"; then
      block_hits+=("$file:$no | B6 | connection-string password"); return 0
    fi
  fi

  for p in "${LOCAL_PATTERNS[@]:-}"; do
    [[ -z "$p" ]] && continue
    if [[ "$lc" == *"${p,,}"* ]]; then
      block_hits+=("$file:$no | A4/A5 | project-local secret literal"); return 0
    fi
  done

  entropy_scan "$file" "$no" "$line"
}

# ---------------------------------------------------------------------------
# Producers
# ---------------------------------------------------------------------------
scan_file() {                  # scan an explicit file, real line numbers
  local file="$1" no=0 line
  while IFS= read -r line || [[ -n "$line" ]]; do
    no=$((no+1)); scan_line "$file" "$no" "$line"
  done < "$file"
}

scan_push_range() {            # added lines for one ref update
  local base="$1" tip="$2" file="?" no=0 l
  while IFS= read -r l; do
    if   [[ $l == +++\ b/* ]]; then file="${l#+++ b/}"
    elif [[ $l == @@* ]]; then
      no=$(sed -E 's/^@@ -[0-9,]+ \+([0-9]+).*/\1/' <<<"$l"); no=$((no-1))
    elif [[ $l == +* && $l != +++* ]]; then
      no=$((no+1)); scan_line "$file" "$no" "${l:1}"
    elif [[ $l != -* ]]; then no=$((no+1)); fi
  done < <(git diff -U0 --no-color "$base" "$tip")
}

# ---------------------------------------------------------------------------
# Report + exit
# ---------------------------------------------------------------------------
report() {
  local x
  for x in "${note_hits[@]:-}";  do [[ -n "$x" ]] && printf 'note:  %s\n' "$x" >&2; done
  for x in "${warn_hits[@]:-}";  do [[ -n "$x" ]] && printf 'WARN:  %s\n' "$x" >&2; done
  for x in "${block_hits[@]:-}"; do [[ -n "$x" ]] && printf 'BLOCK: %s\n' "$x" >&2; done
  if ((${#block_hits[@]})); then
    printf '\nfse secret-scan: push BLOCKED — %d finding(s). Remove the secret, or annotate the line with `# fse-allow: <reason>` if it is a documented false positive.\n' "${#block_hits[@]}" >&2
    return 1
  fi
  ((${#warn_hits[@]})) && printf '\nfse secret-scan: %d entropy warning(s) — push allowed.\n' "${#warn_hits[@]}" >&2
  return 0
}

main() {
  load_local_patterns
  if [[ "${1:-}" == "--scan-file" ]]; then
    [[ -n "${2:-}" && -f "$2" ]] || { echo "usage: pre-push.sh --scan-file <path>" >&2; exit 2; }
    scan_file "$2"; report; exit $?
  fi
  local local_ref local_sha remote_ref remote_sha base empty_tree
  empty_tree="$(git hash-object -t tree /dev/null)"
  while read -r local_ref local_sha remote_ref remote_sha; do
    [[ "$local_sha" == "$ZERO_SHA" ]] && continue            # branch delete
    if [[ "$remote_sha" == "$ZERO_SHA" ]]; then
      base="$(git rev-list --max-count=1 "$local_sha" --not --remotes 2>/dev/null \
              | { read -r c; [[ -n "$c" ]] && git rev-parse "${c}^" 2>/dev/null; })"
      [[ -z "$base" ]] && base="$empty_tree"
    else
      base="$remote_sha"
    fi
    scan_push_range "$base" "$local_sha"
  done
  report; exit $?
}
main "$@"
