# FlowState Engineering (FSE)

**The constraint-based AI development methodology.**

> Your AI assistant forgets everything between sessions. FSE makes it remember.

---

## What FSE Is

FlowState Engineering is a methodology for building production software with AI coding assistants. It solves the three problems every AI-assisted developer hits when they try to ship real software:

1. **Context loss** — the AI doesn't remember what you built yesterday
2. **Architecture drift** — the AI introduces patterns that contradict your design
3. **Repeated mistakes** — the same error happens across sessions because nothing tracks what went wrong

FSE fixes all three with a system that lives at your project root: living documents the AI reads at every session start, a session protocol that enforces discipline, and a self-healing build loop that catches errors before they reach production.

FSE is **tool-agnostic**. It works with Claude Code, Cursor, Copilot, Windsurf, Aider, or any AI coding assistant. It is **stack-agnostic**. The methodology is universal; language-specific rules live in [FSE Stack Extensions](https://github.com/Joticle/fse-extensions).

FSE is **free, open source, and Apache 2.0 licensed.**

---

## Who Is This For

Solo developers and small teams who:

- Use AI coding assistants daily
- Manage one or more production codebases
- Want AI speed without sacrificing code quality
- Are tired of re-explaining their architecture to the AI every session
- Are tired of fixing the same mistakes over and over

FSE was built by a solo developer managing eight production solutions across healthcare, legal, finance, elder care, and education simultaneously. Every concept here was born from real pain and proven in production.

---

## The System at a Glance

### FlowState Foundation Files (FFF)

Three markdown files at your project root. The AI reads them at every session start.

| File | Purpose |
|------|---------|
| `FSE.md` | Architecture, stack, structure, dependencies, constraints, standing orders |
| `FSE_STATE.md` | Session history, build state, priorities, lessons learned, technical debt |
| `FSE_DISCOVERY.md` | Initial project audit, infrastructure checklist, known gaps |

That's it. No frameworks to install. No dependencies to add. No services to subscribe to. Three files.

### Session Protocol — VERIFY → PLAN → EXECUTE → VALIDATE

Every coding session follows the same four phases:

- **VERIFY** — Read the foundation files. Check the build. Confirm what exists. Note open technical debt.
- **PLAN** — State what will be built. List files that will change. Get approval before writing.
- **EXECUTE** — One file at a time. Complete code only. No stubs. Wait for confirmation between files.
- **VALIDATE** — Run the self-healing build loop. Confirm 0 errors. Update `FSE_STATE.md`.

### Self-Healing Build Loop

After every file change: build, check, fix if needed, retry. Maximum 3 attempts. If still failing after 3: **stop and report** — never push forward with a broken build.

### Counter-Point Protocol

When the self-healing loop hits 3 failed attempts, the AI does not attempt a 4th fix using the same reasoning. It stops, reports full context, and recommends switching approach or model. This is the discipline that breaks AI logic loops — the failure mode where an AI proposes the same wrong fix with minor variations forever.

### Tiered Document Ecosystem

Documentation grows with the project. Start simple, expand when needed.

**Tier 1 — Required**
The three foundation files above. Every FSE project has these.

**Tier 2 — When Needed (created when `FSE.md` exceeds ~15KB or complexity demands focused reference)**

| File | Purpose |
|------|---------|
| `FSE_POLICE.md` | Absolute rules — things that caused real pain and must never happen again |
| `FSE_SCHEMA.md` | Entity patterns, database conventions, naming conventions |
| `FSE_UI.md` | Design language, component patterns, CSS architecture |
| `FSE_PACKAGES.md` | Approved packages with exact versions, banned packages |
| `PATTERNS.md` | Proven reusable patterns extracted from completed sessions |

**Tier 3 — Optional**

| File | Purpose |
|------|---------|
| `BUILD_LOG.md` files | Per-module build logs for complex sessions |
| `AUDIT_REPORT.md` | Deep audit findings |
| `CHANGELOG.md` | Production deploy record |
| `CONTRIBUTING.md` | Multi-developer projects |

### Universal Standing Orders

These apply to every FSE project regardless of stack. Stack-specific orders live in extensions.

1. No stubs, TODOs, placeholders, or `NotImplementedException`
2. No snippets or partial code — complete file contents every time
3. Never assume file contents — always read or ask first
4. Never change styling or functionality outside the current task scope
5. Self-healing build loop runs after every change
6. Never commit a broken build
7. Credentials are never output, committed, or referenced in conversation

---

## Quick Start

### 1. Clone or download the repo

```bash
git clone https://github.com/Joticle/fse-core.git
```

Or download the three template files from the [`templates/`](templates/) folder.

### 2. Drop the three foundation files into your project root

```
your-project/
  FSE.md
  FSE_STATE.md
  FSE_DISCOVERY.md
  src/
  ...
```

### 3. Fill in `FSE.md`

Replace the placeholder sections with your project's actual architecture, stack, and constraints. The FSE template at the top of the file stays as-is — that's the methodology contract your AI follows.

### 4. Wire your AI tool

Each AI tool reads a different config file at session start. Add a one-line bridge file pointing at FSE.md.

**Claude Code** — create `.claude/instructions.md`:
```
Read FSE.md, FSE_STATE.md, and FSE_DISCOVERY.md at the start of every session.
Follow the FSE protocol defined in FSE.md without exception.
```

**Cursor** — add to `.cursorrules`:
```
Read FSE.md, FSE_STATE.md, and FSE_DISCOVERY.md at the start of every session.
Follow the FSE protocol defined in FSE.md without exception.
```

**Other tools** — create whatever config file your tool reads and point it at the three foundation files.

### 5. Run your first session

Paste the [onboarding prompt](prompts/ONBOARDING_PROMPT.md) into your AI assistant. It will run the FSE infrastructure check, read your foundation files, report current state, and tell you what to do next.

You're running FSE.

---

## Stack Extensions

FSE Core is stack-agnostic. The session protocol, foundation files, and self-healing build loop work for any language.

For language-specific standing orders, anti-patterns, and module structures, see **[FSE Stack Extensions](https://github.com/Joticle/fse-extensions)**.

The .NET extension is the reference implementation. Extensions for the top 10 stacks are open for community contribution.

The same repository also hosts **methodology extensions** — cross-cutting practices that any stack can adopt. The first is [`kpi`](https://github.com/Joticle/fse-extensions/tree/main/kpi), which adds session-level metrics capture (complexity scoring, drift moments, portfolio rollup aggregates). Methodology extensions are opt-in per project.

---

## What FSE Is Not

- **Not a framework.** Nothing to install. No runtime dependencies.
- **Not a tool.** It's a methodology. The tools you already use stay.
- **Not vibe coding with extra steps.** It's the opposite — explicit constraints prevent drift, not vibes.
- **Not a substitute for engineering judgment.** It amplifies your judgment by making sure the AI respects it.
- **Not enterprise-only.** Built for solo developers first. Scales up cleanly to teams.

---

## Repository Structure

```
fse-core/
  README.md              ← you are here
  LICENSE                ← Apache 2.0
  CONTRIBUTING.md        ← how to contribute
  CODE_OF_CONDUCT.md     ← Contributor Covenant
  SECURITY.md            ← security disclosure policy
  templates/             ← drop these into your project root
    FSE.md
    FSE_STATE.md
    FSE_DISCOVERY.md
  prompts/               ← copy-paste prompts for AI sessions
    ONBOARDING_PROMPT.md
  .github/               ← issue templates, PR template
```

---

## Contributing

FSE is a living methodology. Real-world reports, methodology improvements, and new patterns are welcome.

- **Found something that doesn't work?** Open an issue.
- **Have a methodology improvement?** Open a PR with the proposed change and the reasoning.
- **Want to add a stack extension?** See [fse-extensions](https://github.com/Joticle/fse-extensions).
- **Used FSE on a real project?** Share what worked and what didn't via discussions.

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full contribution process.

---

## Community

- **Website:** [fstate.dev](https://fstate.dev)
- **Quickstart guide:** [fstate.dev/quickstart](https://fstate.dev/quickstart)
- **Stack extensions:** [github.com/Joticle/fse-extensions](https://github.com/Joticle/fse-extensions)
- **Issues & discussions:** Use the GitHub Issues tab on this repo

---

## License

Apache 2.0 — see [LICENSE](LICENSE) for full details.

You can use FSE for personal projects, commercial products, internal tools, or anything else. Attribution appreciated but not required.

---

*FlowState Engineering™*
*Created by Scott Michael Wilson · Joticle, Inc.*
*Born October 2025*
