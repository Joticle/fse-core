# FSE_STATE.md — Living Project State

This file is updated at the end of every session. It is the single source of truth for "where the project is right now."

## Identity

- **Project:** [Project name]
- **FSE Version:** 1.0.0
- **Last Updated:** [YYYY-MM-DD]
- **Last Session By:** [Name / handle]

## Build State

- **Build:** [clean / warnings / broken]
- **Tests:** [passing / failing / not yet implemented]
- **Lint:** [clean / N warnings / broken]
- **Type check:** [clean / N warnings / broken]
- **Last verified:** [YYYY-MM-DD]

Record the exact command used to verify, so the next session runs the same check:

```
[e.g. npm run build && npm run test && npm run lint]
```

## Current Blockers

List anything blocking forward progress. Remove items once resolved.

- [ ] [Blocker description — who/what is needed to unblock]

If there are no blockers, write: *None.*

## Open Decisions

Open decisions are recorded in `FSE.md`'s OPEN DECISIONS block; as each is cleared, the decision and the session that cleared it are noted here.

## Next Session Priorities

Ordered list. The next session starts at the top.

1. [Highest priority item]
2. [Next item]
3. [Next item]

## Warning Baseline

Mirror the baseline from `FSE.md`. If this session changed the baseline, record the change and the reason.

- **Build warnings:** [0]
- **Lint warnings:** [0]
- **Type warnings:** [0]

## Lessons Learned

Add an entry whenever a mistake is made that could be repeated in a future session. Format:

```
### [YYYY-MM-DD] — [Short title]
**What happened:** [One or two sentences.]
**Why it happened:** [Root cause.]
**Rule going forward:** [The new behavior that prevents a repeat.]
```

*No lessons recorded yet.*

## Known Technical Debt

Record debt that was knowingly accepted. Format:

```
### [Short title]
**Introduced:** [YYYY-MM-DD, session reference]
**What it is:** [The shortcut taken.]
**Why it was accepted:** [The tradeoff.]
**Cost of leaving it:** [What this will cost if not paid down.]
**Trigger to pay it down:** [The event that should force a fix.]
```

*No technical debt recorded yet.*

## Session History

Most recent session first. Each entry is short — the diff tells the story of *what*; this log captures *why*.

---

### [YYYY-MM-DD] — FSE Onboarding
**Goal:** Adopt FlowState Engineering for this project.
**Done:**
- Created `FSE.md`, `FSE_STATE.md`, `FSE_DISCOVERY.md` at project root.
- Ran initial infrastructure discovery — see `FSE_DISCOVERY.md`.
- Confirmed build state and recorded baseline.
**Next:** Begin first FSE session against the top priority in `FSE_STATE.md`.
**Notes:** [Anything worth flagging for the next session.]

---
