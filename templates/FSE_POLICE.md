# FSE_POLICE.md — Project Standing Orders

> Universal rules live in FSE.md. This file holds project-specific rules only.

*Absolute rules for this project. Each rule traces to a real incident, an
audit finding, or an external requirement. Promote a rule into this file
when it outgrows FSE.md's "Project-Specific Standing Orders" section, or
when the rule needs enforcement detail beyond a one-line entry.*

*This file does not restate the Universal Standing Orders — those live in
FSE.md and apply to every FSE project regardless of stack.*

## Maintenance

- A rule lands here only after a real incident, audit finding, or recorded
  external requirement. Speculative rules belong in the session report
  that proposes them, not here.
- Each rule is dated and references the incident or session that produced
  it.
- Rules never soften. If a rule no longer applies, move it to the Retired
  Rules section with a dated reason — do not weaken the rule in place.
- The same incident may produce multiple rules. Group related rules under
  one heading when the underlying cause is shared.

## Rule Format

Each rule carries these fields:

- **Rule:** *The absolute prohibition or requirement, stated tersely.*
- **Why:** *The incident, cost, or external requirement that produced it.*
- **Scope:** *What code, file, environment, or operation is bound by the rule.*
- **Enforcement:** *How a violation is caught — build check, code review,
  runbook step, or human discipline.*
- **Established:** *YYYY-MM-DD, with session reference if applicable.*

## Rules

*Most recent rule at the top. New rules go above older ones so the file
reads as a reverse-chronological log of project pain.*

### [Short rule title — e.g. "Never log raw request bodies on auth endpoints"]

- **Rule:** *[The exact prohibition or requirement.]*
- **Why:** *[The incident or finding — what happened, what it cost.]*
- **Scope:** *[Where the rule applies: layer, file glob, environment.]*
- **Enforcement:** *[The check that catches a violation.]*
- **Established:** *[YYYY-MM-DD, Session N reference]*

### [Next rule title]

- **Rule:** *[…]*
- **Why:** *[…]*
- **Scope:** *[…]*
- **Enforcement:** *[…]*
- **Established:** *[YYYY-MM-DD, Session N reference]*

## Retired Rules

*Rules that no longer apply are moved here with a dated note explaining
the change. Keep the original-rule text intact — the history of why the
rule existed remains relevant context even after retirement.*

### [Retired rule title]

- **Original rule:** *[As originally written.]*
- **Original why:** *[The incident that produced it.]*
- **Established:** *[YYYY-MM-DD]*
- **Retired:** *[YYYY-MM-DD] — [Reason for retirement: e.g. framework
  upgrade made the failure mode impossible; external requirement was
  withdrawn; rule was absorbed into Universal Standing Orders.]*
