#!/usr/bin/env bash
# ============================================================================
# fse-doctor — FSE conformance validator + structural pass
# ----------------------------------------------------------------------------
# Reads a holding's FSE_CONFORMANCE.md (the fenced yaml block), validates it,
# reports pin drift against fse-core, and runs a structural pass that enforces
# the holding's declared bindings.
#
#   Layer 1  SCHEMA      -> FAIL (exit 1)   malformed/incomplete conformance file
#   Layer 2  PIN DRIFT   -> WARN            how many fse-core tags behind the pin is
#   Layer 3  STRUCTURAL  -> FAIL (exit 1)   binding violations not covered by a
#                                           deviation's scope glob
#
# A deviation entry with a `scope:` glob suppresses structural findings whose
# path matches, and only for the USO named in its `rule:`. A deviation with no
# scope is advisory: findings are still reported.
#
# Zero dependencies beyond bash, awk, sed, grep, git, curl — fse-core has no
# build and takes no runtime dependencies.
#
# Usage:  fse-doctor.sh                 (run from a holding's bedrock root)
#         fse-doctor.sh --file PATH     (explicit conformance file)
#         fse-doctor.sh --root PATH     (holding root to scan)
#         fse-doctor.sh --no-net        (skip the pin-drift fetch)
#         fse-doctor.sh --quiet         (findings only)
#
# Exit:   0 clean (warnings allowed) | 1 findings | 2 usage error
# ============================================================================
set -u

CORE_REPO="https://github.com/Joticle-Git/fse-core.git"
SUPPORTED_SCHEMA=1
VERBS="create|alter|seed|drop|fix|verify"

CONF=""; ROOT=""; NO_NET=0; QUIET=0
fail_hits=(); warn_hits=(); note_hits=(); suppressed=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file)  CONF="${2:-}"; shift 2 ;;
    --root)  ROOT="${2:-}"; shift 2 ;;
    --no-net) NO_NET=1; shift ;;
    --quiet) QUIET=1; shift ;;
    -h|--help) sed -n '2,30p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

[[ -z "$ROOT" ]] && ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
[[ -z "$CONF" ]] && CONF="$ROOT/FSE_CONFORMANCE.md"
if [[ ! -f "$CONF" ]]; then
  echo "fse-doctor: no FSE_CONFORMANCE.md at $CONF" >&2
  echo "            run from a holding's bedrock root, or pass --file" >&2
  exit 2
fi

fail() { fail_hits+=("$1"); }
warn() { warn_hits+=("$1"); }
note() { note_hits+=("$1"); }
say()  { [[ $QUIET -eq 1 ]] || printf '%s\n' "$1"; }

# ---------------------------------------------------------------------------
# Extract the first fenced yaml block, strip comments and blanks.
# ---------------------------------------------------------------------------
YAML="$(awk '/^```yaml/{f=1;next} /^```/{if(f)exit} f' "$CONF")"
if [[ -z "${YAML//[[:space:]]/}" ]]; then
  echo "fse-doctor: no fenced \`\`\`yaml block found in $CONF" >&2
  exit 2
fi
strip_comment() {              # drop trailing # comment outside quotes
  printf '%s' "$1" | sed -E 's/[[:space:]]+#[^"'"'"']*$//'
}
unquote() { local v="$1"; v="${v%\"}"; v="${v#\"}"; v="${v%\'}"; v="${v#\'}"; printf '%s' "$v"; }
trim() { local v="$1"; v="${v#"${v%%[![:space:]]*}"}"; v="${v%"${v##*[![:space:]]}"}"; printf '%s' "$v"; }

top_scalar() {                 # $1=key -> value at column 0
  local line; line="$(printf '%s\n' "$YAML" | grep -E "^$1:" | head -1)"
  [[ -z "$line" ]] && return 1
  unquote "$(trim "$(strip_comment "${line#*:}")")"
}
binding() {                    # $1=key -> value under bindings:
  local line; line="$(printf '%s\n' "$YAML" | awk '/^bindings:/{f=1;next} /^[a-z_]+:/{f=0} f' | grep -E "^[[:space:]]+$1:" | head -1)"
  [[ -z "$line" ]] && return 1
  unquote "$(trim "$(strip_comment "${line#*:}")")"
}

is_date() { [[ "$1" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; }

# ---------------------------------------------------------------------------
# LAYER 1 — schema
# ---------------------------------------------------------------------------
schema="$(top_scalar conformance_schema || true)"
if [[ -z "$schema" ]]; then
  fail "schema | conformance_schema is missing — cannot parse safely"
elif ! [[ "$schema" =~ ^[0-9]+$ ]]; then
  fail "schema | conformance_schema must be an integer (got '$schema')"
elif [[ "$schema" -ne $SUPPORTED_SCHEMA ]]; then
  fail "schema | conformance_schema $schema unsupported — this fse-doctor speaks $SUPPORTED_SCHEMA"
fi

holding="$(top_scalar holding || true)"
[[ -z "$holding" ]] && fail "schema | holding is missing"

pin="$(top_scalar fse_core_pin || true)"
if [[ -z "$pin" ]]; then fail "schema | fse_core_pin is missing"
elif ! [[ "$pin" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  fail "schema | fse_core_pin must be an exact tag like v1.2.1 (got '$pin')"
fi

for k in last_rebase last_doctor; do
  v="$(top_scalar "$k" || true)"
  if [[ -z "$v" ]]; then fail "schema | $k is missing"
  elif ! is_date "$v"; then fail "schema | $k must be UTC YYYY-MM-DD (got '$v')"; fi
done

sql_layout="$(binding sql_layout || true)"
case "$sql_layout" in
  A|B) ;;
  "")  fail "schema | bindings.sql_layout is missing" ;;
  *)   fail "schema | bindings.sql_layout must be A or B (got '$sql_layout')" ;;
esac

css_prefix="$(binding css_prefix || true)"
if [[ -z "$css_prefix" ]]; then fail "schema | bindings.css_prefix is missing"
elif ! [[ "$css_prefix" =~ ^--[A-Za-z0-9]+-$ ]]; then
  warn "schema | bindings.css_prefix '$css_prefix' is unconventional (expected like --ex-)"
fi

cross_module="$(binding cross_module || true)"
case "$cross_module" in
  raw-sql|contracts|both) ;;
  "") fail "schema | bindings.cross_module is missing" ;;
  *)  fail "schema | bindings.cross_module must be raw-sql|contracts|both (got '$cross_module')" ;;
esac

seed_home="$(binding reference_seed_home || true)"
[[ -z "$seed_home" ]] && fail "schema | bindings.reference_seed_home is missing"

tier2_raw="$(binding tier2_present || true)"
tier2_raw="${tier2_raw#[}"; tier2_raw="${tier2_raw%]}"

# --- deviations -------------------------------------------------------------
dev_ids=(); dev_rules=(); dev_scopes=()
dev_block="$(printf '%s\n' "$YAML" | awk '/^deviations:/{f=1;next} /^[a-z_]+:/{f=0} f')"
cur_id=""; cur_rule=""; cur_status=""; cur_remed=""; cur_scope=""; cur_date=""; cur_sum=""; cur_reason=""
flush_dev() {
  [[ -z "$cur_id" ]] && return 0
  local tag="deviation $cur_id"
  [[ "$cur_id" =~ ^DEV-[0-9]{3,}$ ]] || fail "ledger | $tag | id must look like DEV-001"
  for i in "${dev_ids[@]:-}"; do [[ "$i" == "$cur_id" ]] && fail "ledger | $tag | duplicate id"; done
  [[ -z "$cur_rule"   ]] && fail "ledger | $tag | rule is missing"
  [[ -z "$cur_sum"    ]] && fail "ledger | $tag | summary is missing"
  [[ -z "$cur_reason" ]] && fail "ledger | $tag | reason is missing"
  case "$cur_status" in
    accepted)
      [[ -n "$cur_remed" ]] && warn "ledger | $tag | remediate_by is set but status is 'accepted' — it has no meaning" ;;
    remediation-planned)
      if [[ -z "$cur_remed" ]]; then fail "ledger | $tag | status is 'remediation-planned' but remediate_by is empty"
      elif ! is_date "$cur_remed"; then fail "ledger | $tag | remediate_by must be UTC YYYY-MM-DD (got '$cur_remed')"; fi ;;
    "") fail "ledger | $tag | status is missing" ;;
    *)  fail "ledger | $tag | status must be accepted|remediation-planned (got '$cur_status')" ;;
  esac
  if [[ -z "$cur_date" ]]; then fail "ledger | $tag | date is missing"
  elif ! is_date "$cur_date"; then fail "ledger | $tag | date must be UTC YYYY-MM-DD (got '$cur_date')"; fi
  [[ -z "$cur_scope" ]] && note "ledger | $tag | no scope glob — advisory only, findings are still reported"
  dev_ids+=("$cur_id"); dev_rules+=("$cur_rule"); dev_scopes+=("$cur_scope")
  cur_id=""; cur_rule=""; cur_status=""; cur_remed=""; cur_scope=""; cur_date=""; cur_sum=""; cur_reason=""
}
while IFS= read -r line; do
  [[ -z "${line//[[:space:]]/}" ]] && continue
  local_val="$(unquote "$(trim "$(strip_comment "${line#*:}")")")"
  case "$(trim "$line")" in
    -\ id:*)        flush_dev; cur_id="$local_val" ;;
    rule:*)         cur_rule="$local_val" ;;
    summary:*)      cur_sum="$local_val" ;;
    reason:*)       cur_reason="$local_val" ;;
    status:*)       cur_status="$local_val" ;;
    remediate_by:*) cur_remed="$local_val" ;;
    scope:*)        cur_scope="$local_val" ;;
    date:*)         cur_date="$local_val" ;;
  esac
done <<< "$dev_block"
flush_dev

# ---------------------------------------------------------------------------
# LAYER 2 — pin drift
# ---------------------------------------------------------------------------
latest_tag=""
if [[ $NO_NET -eq 0 && -n "$pin" ]]; then
  latest_tag="$(git ls-remote --tags --refs "$CORE_REPO" 2>/dev/null \
    | sed -E 's#.*refs/tags/##' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' \
    | sort -t. -k1,1V -k2,2V -k3,3V | tail -1)"
  if [[ -z "$latest_tag" ]]; then
    warn "pin | could not reach fse-core to check drift (offline?) — use --no-net to silence"
  else
    if ! git ls-remote --tags --refs "$CORE_REPO" 2>/dev/null | grep -qE "refs/tags/${pin}$"; then
      fail "pin | fse_core_pin $pin does not exist in fse-core"
    fi
    if [[ "$pin" != "$latest_tag" ]]; then
      behind="$(git ls-remote --tags --refs "$CORE_REPO" 2>/dev/null \
        | sed -E 's#.*refs/tags/##' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' \
        | sort -t. -k1,1V -k2,2V -k3,3V | awk -v p="$pin" 'BEGIN{s=0} {if(s)c++} $0==p{s=1} END{print c+0}')"
      warn "pin | pinned at $pin; latest fse-core is $latest_tag ($behind release(s) behind) — rebase ritual due"
    fi
  fi
fi

# ---------------------------------------------------------------------------
# LAYER 3 — structural pass
# ---------------------------------------------------------------------------
glob_to_regex() {              # translate a scope glob into an ERE
  # Done char-by-char in pure bash: passing globs through sed needs escaping of
  # both glob and sed metacharacters, and {} inside a bracket expression breaks
  # sed's interval parser. Direct translation is shorter and total.
  local g="$1" out="" c i=0
  while (( i < ${#g} )); do
    c="${g:i:1}"
    case "$c" in
      '*')
        if [[ "${g:i:3}" == '**/' ]]; then out+='(.*/)?'; i=$((i+3)); continue
        elif [[ "${g:i:2}" == '**' ]]; then out+='.*';    i=$((i+2)); continue
        else out+='[^/]*'; fi ;;
      '?') out+='[^/]' ;;
      '.'|'['|']'|'('|')'|'{'|'}'|'+'|'^'|'$'|'|'|'\') out+="\\$c" ;;
      *) out+="$c" ;;
    esac
    i=$((i+1))
  done
  printf '^%s$' "$out"
}
is_suppressed() {              # $1=path $2=uso -> 0 if a matching deviation covers it
  local path="$1" uso="$2" i re
  for i in "${!dev_ids[@]}"; do
    [[ -z "${dev_scopes[$i]}" ]] && continue
    [[ "${dev_rules[$i]}" != "$uso" ]] && continue
    re="$(glob_to_regex "${dev_scopes[$i]}")"
    if printf '%s' "$path" | grep -qE "$re"; then return 0; fi
  done
  return 1
}
record() {                     # $1=uso $2=path:line $3=desc
  local p="${2%%:*}"
  if is_suppressed "$p" "$1"; then suppressed=$((suppressed+1)); return 0; fi
  fail "$1 | $2 | $3"
}

# tracked, source-ish files only — never scan build output or vendor trees
mapfile -t FILES < <(git -C "$ROOT" ls-files 2>/dev/null \
  | grep -vE '(^|/)(bin|obj|node_modules|dist|\.git|artifacts)/' || true)

# -- claims: tier2_present files must exist
if [[ -n "${tier2_raw//[[:space:]]/}" ]]; then
  IFS=',' read -ra t2 <<< "$tier2_raw"
  for f in "${t2[@]}"; do
    f="$(unquote "$(trim "$f")")"; [[ -z "$f" ]] && continue
    [[ -f "$ROOT/$f" ]] || fail "claim | bindings.tier2_present lists $f but it does not exist"
  done
fi

# -- binding: reference_seed_home
if [[ -n "$seed_home" && ! -d "$ROOT/${seed_home%/}" ]]; then
  warn "binding | reference_seed_home '$seed_home' does not exist (no standing seeds yet?)"
fi

# -- USO-01: no stubs / TODOs / placeholders
for f in "${FILES[@]:-}"; do
  [[ -f "$ROOT/$f" ]] || continue
  case "$f" in *.md|*.txt|*fse-doctor*|*secret-scan*) continue ;; esac
  while IFS=: read -r ln _; do
    [[ -z "$ln" ]] && continue
    record "USO-01" "$f:$ln" "stub/TODO marker"
  done < <(grep -nE '\b(TODO|FIXME|NotImplementedException)\b' "$ROOT/$f" 2>/dev/null | cut -d: -f1 | sed 's/$/:/')
done

# -- USO-08: token-first — hard-coded visual literals outside the token file
for f in "${FILES[@]:-}"; do
  case "$f" in *.css|*.scss|*.cshtml|*.razor) ;; *) continue ;; esac
  [[ -f "$ROOT/$f" ]] || continue
  # the file that DEFINES the tokens is exempt
  if grep -qE "^[[:space:]]*${css_prefix}[A-Za-z0-9-]+[[:space:]]*:" "$ROOT/$f" 2>/dev/null; then continue; fi
  while IFS= read -r hit; do
    [[ -z "$hit" ]] && continue
    record "USO-08" "$f:${hit%%:*}" "hard-coded visual literal (use a ${css_prefix}* token)"
  done < <(grep -nE ':[^;{]*(#[0-9a-fA-F]{3,8}\b|\brgba?\(|[^0a-zA-Z-][1-9][0-9]*px\b)' "$ROOT/$f" 2>/dev/null | cut -d: -f1 | sed 's/$/:/')
done

# -- USO-13: query artifact discipline — the declared sql_layout is authoritative
sql_files=(); for f in "${FILES[@]:-}"; do case "$f" in db/*.sql|db/*/*.sql|db/*/*/*.sql) sql_files+=("$f") ;; esac; done
if [[ "$sql_layout" == "A" ]]; then
  for f in "${sql_files[@]:-}"; do
    [[ -z "$f" ]] && continue
    if [[ "$f" == db/migrations/* ]]; then
      record "USO-13" "$f:1" "layout A declared but a flat db/migrations/ ledger is present (mixed layouts)"
    elif ! [[ "$f" =~ ^db/[A-Za-z0-9_]+/[0-9]{3}_(${VERBS})_[a-z0-9_]+\.sql$ ]]; then
      record "USO-13" "$f:1" "layout A requires db/{Module}/{NNN}_{verb}_{object}.sql with verb in ${VERBS//|/,}"
    fi
  done
elif [[ "$sql_layout" == "B" ]]; then
  for f in "${sql_files[@]:-}"; do
    [[ -z "$f" ]] && continue
    if [[ "$f" != db/migrations/* && "$f" != db/_meta/* ]]; then
      record "USO-13" "$f:1" "layout B declared: applied scripts live in db/migrations/ (or db/_meta/)"
    elif [[ "$f" == db/migrations/* ]] && ! [[ "$f" =~ ^db/migrations/[0-9]{3}_[a-z0-9_]+\.sql$ ]]; then
      record "USO-13" "$f:1" "layout B requires db/migrations/{NNN}_{topic}.sql"
    fi
  done
fi

# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------
say "fse-doctor — ${holding:-<unknown holding>} @ ${pin:-<no pin>}"
for x in "${note_hits[@]:-}";  do [[ -n "$x" ]] && printf 'note:  %s\n' "$x"; done
for x in "${warn_hits[@]:-}";  do [[ -n "$x" ]] && printf 'WARN:  %s\n' "$x"; done
for x in "${fail_hits[@]:-}";  do [[ -n "$x" ]] && printf 'FAIL:  %s\n' "$x"; done
[[ $suppressed -gt 0 ]] && say "       ($suppressed finding(s) suppressed by deviation scope globs)"
if ((${#fail_hits[@]})); then
  printf '\nfse-doctor: %d finding(s). Fix them, or record an accepted deviation with a scope glob in FSE_CONFORMANCE.md.\n' "${#fail_hits[@]}" >&2
  exit 1
fi
say "fse-doctor: clean${latest_tag:+ (fse-core latest: $latest_tag)}"
exit 0
