# PATTERNS.md — Proven Reusable Patterns

> Universal rules live in FSE.md. This file holds project-specific patterns only.

*Patterns earn their place here by shipping at least once in a real
session. A pattern in this file is safe to reach for again without
re-deriving the design. Speculative patterns — ideas that look reusable
but have not been proven — belong in the session report that proposed
them, not here.*

*This file does not duplicate framework-level patterns from official
documentation. Those are reachable via the framework's own docs.
PATTERNS.md records only the patterns specific to how this project does
things.*

## How a Pattern Earns Its Place

A pattern is promoted into PATTERNS.md when all three are true:

1. It has been used in at least one completed session.
2. The session report identifies it as reusable.
3. It has a clear trigger condition that a future session can recognize
   ("apply when …").

A pattern that has worked once but is unlikely to recur does not need to
be promoted yet. Premature pattern extraction is overhead — let real
re-use prove value first.

## Pattern Format

Each pattern carries these fields:

- **Name** — *Short, memorable noun phrase.*
- **Trigger** — *The situation that should reach for this pattern.*
- **Solution** — *The pattern itself, in two to four sentences.*
- **Example** — *A code or structure excerpt that shows it in use,
  sanitized and generic.*
- **Counter-cases** — *Situations where the pattern does NOT apply.
  Equally important — patterns without explicit limits get over-applied.*
- **First used** — *Session N, YYYY-MM-DD.*

## Patterns

*Most recent pattern at the top. Patterns are added in promotion order.*

### [Pattern name]

- **Trigger:** *[When to reach for this pattern.]*
- **Solution:** *[The pattern, stated in two to four sentences.]*
- **Example:**
  ```
  [code or structure excerpt — generic, sanitized]
  ```
- **Counter-cases:** *[Situations where this pattern does NOT apply.]*
- **First used:** *[Session N, YYYY-MM-DD]*

### [Next pattern name]

- **Trigger:** *[…]*
- **Solution:** *[…]*
- **Example:**
  ```
  [code]
  ```
- **Counter-cases:** *[…]*
- **First used:** *[Session N, YYYY-MM-DD]*

## Retired Patterns

*Patterns superseded by better approaches are moved here with a note on
what replaced them and why. The history matters — a retired pattern often
explains why the current pattern looks the way it does.*

### [Retired pattern name]

- **Original use:** *[Brief description of the original pattern.]*
- **First used:** *[Session N, YYYY-MM-DD]*
- **Retired:** *[YYYY-MM-DD] — replaced by [new pattern name].
  Reason: [Why the replacement is better.]*
