================================================================================
FSE EXTENSION NOTIFICATION
DAOBoard — Public Operations Surface for the FSE Factory
================================================================================

SESSION CLASS: Architectural Notification + Extension Scope
SESSION SHAPE: Heavy (multi-part scope authoring, not implementation)
ORIGIN: Office of the Chairman, Joticle, Inc.
DATE: 2026-05-17
METHODOLOGY VERSION: [current FSE version]
TARGET METHODOLOGY VERSION: [next minor — DAOBoard extension lands here]

================================================================================
1. NOTIFICATION TO THE FSE PROJECT
================================================================================

This document formally notifies the FlowState Engineering project of the
chairman's intent to extend FSE into a new operational domain: the public
operations surface of the factory itself.

The extension is named DAOBoard. It will live as a first-class FSE concept
alongside the existing primitives (bedrock files, session protocol, standing
orders, lessons learned registry, pattern library).

The extension is being notified now, before any implementation, because:

  - It introduces a new artifact type (daoboard.yaml) into every property
    repo that adopts it.

  - It introduces a new aggregation layer (the DAOBoard backend) that
    reads across the entire portfolio.

  - It introduces a new public surface (fstate.dev/DAOBoard) that exposes
    factory state to the world.

  - It introduces a new standing order (Public Surface Discipline) that
    governs operator behavior across every property indefinitely.

  - It requires explicit decisions about what the factory commits to
    showing publicly forever, because once published, data is in caches,
    screenshots, and third-party indexes outside operator control.

This notification opens the extension arc. No code ships under this
notification. The notification is the artifact.

================================================================================
2. INTENT
================================================================================

DAOBoard makes the FSE factory operate in public on the dimensions the
operator affirmatively chooses to publish, and only those dimensions.

The intent is not marketing. The intent is not promotion. The intent is:

  (a) Producing a verifiable, auditable, real-time artifact that demonstrates
      the FSE methodology is operating across the portfolio at the velocity
      and discipline claimed.

  (b) Replacing the founder's verbal claims with a public surface that the
      reader confirms in fifteen seconds without operator presence.

  (c) Creating an audit trail of public claims that traces back to specific
      commits, with timestamps and version history, so every number the
      factory shows can be reconstructed at any point in time.

  (d) Creating operating discipline through visibility — the factory
      operating in public makes the standing orders harder to skip and the
      build gate harder to violate.

  (e) Producing a single URL that does the work of every future outreach,
      stakeholder communication, SME recruitment conversation, and champion
      readiness demonstration.

  (f) Converting the operator's verbal claims about factory state into a
      single verifiable URL that does the work of every future outreach,
      stakeholder communication, and methodology demonstration. The public
      surface is the artifact that lets the work speak without operator
      presence. This is the function that justifies the cost and risk of
      the public surface — without it, DAOBoard would be operating
      discipline alone, which does not require a public artifact. The
      audience-conversion function is a peer to (a) through (e), not a
      downstream byproduct.

DAOBoard is not a product. DAOBoard is a methodology extension. It is part
of FSE the same way bedrock files are part of FSE.

================================================================================
3. WHERE IT LIVES IN THE FSE STRUCTURE
================================================================================

3.1 Repository placement

  fse-core/                                  (existing, open source)
    docs/
      methodology/
        daoboard/                            (NEW — extension home)
          README.md                          (extension overview, public)
          schema/
            daoboard.yaml.schema.json        (schema definition)
            daoboard.yaml.example.yaml       (annotated example)
          spec/
            aggregator.spec.md               (aggregator behavior contract)
            gate.spec.md                     (pre-publication gate contract)
            denylist.spec.md                 (pattern denylist contract)
          standing-orders/
            public-surface-discipline.md     (the standing order)

  fse-extensions/                            (existing, open source)
    daoboard-aggregator/                     (NEW — reference implementation)
      README.md
      src/                                   (aggregator source)
      tests/
      LICENSE                                (Apache-2.0, inherits)

  joticle-private/                           (private)
    daoboard-backend/                        (NEW — Joticle's instance)
      config/
        property-allowlist.yaml              (list of repos to aggregate)
        publication-target.yaml              (where to publish snapshots)
      logs/                                  (publication history, audit)

3.2 Per-property placement

  Every property repo that opts in adds a single file:

    [property-repo-root]/daoboard.yaml

  No other files are read by the aggregator. No other files are referenced
  by the public surface.

3.3 Public surface placement

  fstate.dev/                                (existing methodology site)
    DAOBoard/                                (NEW route, public)
      index                                  (factory rollup + per-property cards)
      properties/[slug]                      (individual property detail page)
      methodology                            (link back to FSE methodology home)

================================================================================
4. WHAT THIS EXTENSION COMMITS TO PROTECT — AT ALL COSTS
================================================================================

The protection model is allowlist, not blocklist. The aggregator reads
only daoboard.yaml. Nothing else has a path to the public surface.

The following categories are NEVER permitted in daoboard.yaml, regardless
of operator intent in any single session:

  CATEGORY 1 — INFRASTRUCTURE IDENTIFIERS
    Database names, schema names, table names, column names
    Service principal IDs, tenant IDs, subscription IDs
    Key Vault names, secret names, credential references
    App pool names, hosting account specifics
    Cloud resource identifiers of any kind
    Encryption purposes, DataProtection scopes

  CATEGORY 2 — INDIVIDUALS
    SME names, champion names
    Stakeholder names, board member names
    Customer names, demo persona names, prospect names
    Personnel names beyond the operator's own
    Government contact names, vendor contact names
    Family member names
    Anyone who has not affirmatively consented to public association

    Operator identity exemption:
    The operator of the factory, by the act of operating FSE in public
    under their own name, is exempt from Category 2 protection. Public
    handles, public bylines, and public methodology authorship are part
    of the operating posture. This exemption is bounded: the operator's
    family, household, anchor customer relationship, financial detail,
    and any non-operational identity material remain protected under
    Categories 4 and 6.

    The exemption is an active choice per operator, not an inherited
    property of the role. A future operator who chooses private
    operation is not bound by the prior operator's public posture, and
    the public surface adjusts to reflect the operating operator's
    chosen disclosure level. Succession is named here as principle; the
    mechanic is deferred to the session that handles it.

    Other named individuals may join the operator-exempt tier only by
    their own affirmative written consent, captured in a session report,
    and only for the scope of association they consent to. Consent is
    not transferable across surfaces — consenting to be named as an SME
    on a property's marketing page does not consent to appearing on
    DAOBoard.

  CATEGORY 3 — ARCHITECTURAL DETAIL
    Specific vulnerability fixes (current or historical)
    Authentication mechanisms, authorization patterns
    Encryption keys, signing methods, token formats
    API endpoint structures beyond what is already public on product surfaces
    Internal service boundaries, microservice topology
    Background worker schedules, retry mechanics

  CATEGORY 4 — BUSINESS INTELLIGENCE
    Anchor customer identity or operating relationship detail
    Cap table specifics, ownership percentages, equity grants
    Financial specifics beyond aggregate posture (patient/seeded/revenue)
    Pricing experiments, conversion data, customer count by property
    Acquisition conversations, partnership negotiations
    Competitive positioning specifics beyond product marketing surfaces

  CATEGORY 5 — OPERATIONAL VULNERABILITY WINDOWS
    Pending operator queue items
    Known unfixed issues, deferred security work
    Migration windows, deployment windows, downtime windows
    Credential rotation status, secret expiry dates
    Pool memory caps, infrastructure constraints
    Wrong-environment incidents, recovery procedures

    Aggregate fact vs. operational detail:
    Operational facts at the aggregate level are publishable regardless
    of their direction. Build status, test count, session count, clean
    streak length, last failure date — these are aggregate facts that
    describe what the factory did, not how. They are publishable when
    the streak is intact and publishable when the streak breaks. They
    publish in real time without operator override.

    The detail underneath any operational failure remains protected
    under this category. Root cause, affected systems, recovery
    procedure, exposure surface, what was rolled back, what was patched,
    which environment was wrong, which credential was rotated — these
    are operational detail and are never published.

    The factory shows that it broke. The factory does not show how it
    broke or how it recovered. The break is the signal. The recovery is
    internal.

  CATEGORY 6 — STAKEHOLDER COMMUNICATION DETAIL
    Content of any stakeholder communication
    Board deliberations, governance discussions in progress
    Strategy not yet committed to the corporate operating plan
    Risk assessments below the level published in operating plan

Pressure-tested trade-offs named explicitly:

The following items are publishable under the schema and are named here
so the trade-off is acknowledged rather than implicit. Each carries an
information cost. Each is judged worth the cost because the asymmetry
the public surface creates is the function the extension exists to
serve.

  Methodology version (fse_version):
    Publishing the exact methodology version permits correlation
    against the public fse-core repo's commit history. A sophisticated
    reader can identify which patterns, lessons learned, and standing
    orders are in operation at the factory on any given date. This is
    reconnaissance, not credential exposure. It is judged worth the
    cost because methodology transparency is the operator's posture,
    and obscuring the version while publishing the methodology would be
    incoherent.

  Test count (tests_passing):
    Publishing aggregate test count permits competitors to correlate
    engineering velocity against feature shipping cadence. This is
    competitive intelligence. It is judged worth the cost because the
    asymmetry is the hook, and a competitor capable of matching this
    velocity is not a competitor the factory's posture protects against.

  Build clean streak (builds_clean_streak_days):
    Publishing a streak metric creates a pressure point at the moment
    the streak breaks. The standing order resolves this by inverting
    the integrity logic: a factory that publishes breaks is more
    credible than a factory whose streak appears unbroken. The break is
    positive evidence of trustworthiness, not negative evidence of
    discipline. This inversion is enforced by the absence of any
    override path — no delay window, no manual reset, no operator
    suppression mechanism. The mechanic is in what does not exist.

  Pipeline phase staging (pipeline_stage):
    Locked enum: foundation | polish | fleet | active_monetization.
    Publishing the explicit state-machine value of each property reveals
    strategic sequencing and current capacity allocation. Competitors
    can map the operator's attention matrix. The justification for
    publication: in a zero-burn factory, dormancy is an active
    optimization, not a failure. Publishing phase staging shifts the
    viewer's focus from traditional growth-rate metrics to capacity
    utilization, proving the operator throttles execution against
    constraints deliberately rather than flailing across unmanaged
    fronts. The enum is locked; any change requires a dedicated
    schema-revision session per Section 5.4.

================================================================================
5. HOW THE PROTECTION IS ENFORCED
================================================================================

5.1 Allowlist-only schema

  daoboard.yaml.schema.json defines every permissible field.
  The aggregator validates every loaded daoboard.yaml against the schema
  before processing. Unknown fields fail validation. Validation failure
  excludes that property from the snapshot.

5.2 Read isolation

  The aggregator reads ONLY daoboard.yaml from each property repo.
  No code path reads FSE_STATE.md, session reports, bedrock files,
  standing orders, lessons learned, source code, or any other artifact.
  This is enforced by the aggregator's file access layer being scoped
  to a single filename constant.

5.3 Pre-publication gate

  Before any new snapshot replaces the live published snapshot, the
  gate runs:

    - Schema validation per property (fail-closed)
    - Diff against previous snapshot (new keys flagged)
    - Pattern denylist scan on all string values:
        - GUID-format strings
        - Base64-format strings ≥ 40 chars
        - JWT-format strings
        - Strings containing denylist keywords:
            database, schema, secret, key, credential, token, password,
            vault, principal, tenant, subscription, customer, sme,
            champion, board, cfo, ceo, chairman, anchor, founding,
            and similar
    - String length sanity check (>200 chars fails for review)
    - Type sanity check (unexpected field types fail)

  If any check fails, the snapshot does not publish. The previous
  snapshot remains live. The operator receives a diff report for review.

5.4 Operator acknowledgment for schema expansion

  Adding any new field to daoboard.yaml.schema.json requires:
    - An FSE session report documenting the decision
    - A diff of the schema change
    - Explicit reasoning for why the new field does not fall into any
      protected category
    - The standing order's signature line in the session report

  No schema expansion ships without an explicit operator session.

5.5 Public surface immutability of operator decisions

  Once a field is published, the operator commits to the decision
  publicly. The decision is reversible (field removable) but caches,
  screenshots, and third-party indexes outside operator control will
  retain previously-published data. This is the cost of publication
  and the reason the allowlist is conservative by default.

5.6 Audit trail

  Every published snapshot is committed to a private audit log with:
    - Timestamp
    - Source commit SHA per property
    - Aggregated snapshot content
    - Gate pass/fail report
    - Operator session reference (if schema expansion occurred)

  The audit log is the receipt trail for every public claim. The
  factory can reconstruct what it claimed on any past date.

  Audit log location is intentionally deferred to Session N+3
  (Joticle backend instance). Options under consideration include
  private storage in joticle-private/daoboard-backend/logs/ or an
  on-chain immutability layer. The notification does not resolve this;
  the implementing session does.

================================================================================
6. STANDING ORDER TO BE INSCRIBED
================================================================================

The following standing order is added to the FSE standing orders registry
as part of this extension. It binds the operator and any future operator
of the factory:

  STANDING ORDER — PUBLIC SURFACE DISCIPLINE

  1. The factory operates in public on the dimensions the operator chooses,
     and only those dimensions.

  2. The only file readable by the DAOBoard aggregator is daoboard.yaml at
     the root of each property repo.

  3. daoboard.yaml is an allowlist, governed by the published schema. Fields
     outside the schema are not published.

  4. The aggregator has no code path to FSE_STATE.md, session reports,
     bedrock files, standing orders, lessons learned registry, source code,
     configuration files, or any other operational artifact.

  5. The six protected categories (infrastructure identifiers, individuals,
     architectural detail, business intelligence, operational vulnerability
     windows, stakeholder communication detail) are never published, in any
     form, under any operator decision, under any external pressure.

  6. The pre-publication gate fails closed. Suspicious patterns prevent
     publication until operator review.

  7. Schema expansion requires an explicit FSE session and documented
     operator acknowledgment.

  8. When in doubt, omit. Adding to the public surface is cheap. Removing
     is permanent in artifacts outside operator control.

  9. The operator does not editorialize over the public surface. The numbers
     speak. Captions, taglines, and marketing language do not appear on
     fstate.dev/DAOBoard. The factory's posture is operational visibility,
     not promotion.

  10. Operator identity is an active choice per operator. The current
      operator's exemption from Category 2 does not bind successors. A
      future operator chooses public or private operation at the time of
      succession, and the public surface adjusts to the operating
      operator's chosen disclosure level.

  11. Aggregate operational facts publish in real time without operator
      override. Build status, test count, session count, clean streak
      length, and last failure date publish whether the news is good or
      bad. The integrity of the surface depends on the absence of any
      override path. A factory that publishes breaks is more credible
      than a factory whose streak appears unbroken. Operational detail
      underneath any failure remains protected under Category 5.

  12. The standing order is revisable only in the conservative direction.
      Categories may be added. Protected items may be expanded. Override
      paths may not be created. Schema fields may not be moved from
      protected to permitted. Revisions require a dedicated FSE session
      with the same acknowledgment process as schema expansion (Section
      5.4).

  13. This standing order applies to all current and future properties in
      the factory, and to any extension of the methodology that touches
      the public surface.

================================================================================
7. SCOPE OF THE EXTENSION ARC
================================================================================

The DAOBoard extension is built across the following FSE sessions:

  Session N+1 — Schema and Standing Order
    Author daoboard.yaml.schema.json
    Author daoboard.yaml.example.yaml
    Inscribe Public Surface Discipline standing order
    Commit to fse-core under docs/methodology/daoboard/
    Outcome: schema and standing order live in methodology repo

  Session N+2 — Aggregator Reference Implementation
    Author the aggregator in fse-extensions/daoboard-aggregator/
    Implement read isolation (single filename constant)
    Implement schema validation
    Implement pre-publication gate (denylist, pattern scan, diff)
    Test against synthetic daoboard.yaml fixtures
    Outcome: open-source aggregator anyone can run on their own factory

  Session N+3 — Joticle Backend Instance
    Stand up joticle-private/daoboard-backend/
    Configure property allowlist (initially: methodology site only)
    Wire scheduled refresh (daily, conservative)
    Wire audit log to private storage
    Outcome: Joticle's DAOBoard backend running, no public surface yet

  Session N+4 — Pilot Property Onboarding
    Author daoboard.yaml for ONE pilot property (recommendation: Joticle
    Command Center, lowest sensitivity)
    Run aggregator end-to-end
    Verify gate behavior
    Verify audit log
    Outcome: one property aggregating cleanly, no public surface yet

  Session N+5 — Public Frontend
    Build fstate.dev/DAOBoard route
    Render factory rollup (single property at this point)
    Render per-property card for the pilot
    Apply no-editorialization rule (numbers, timestamps, no captions)
    Deploy to staging, not yet production
    Outcome: staging public surface, operator review

  Session N+6 — Portfolio Rollout
    Author daoboard.yaml for remaining ten properties, one at a time,
    each gated by the protected categories review
    Add each to the aggregator allowlist after schema validation passes
    Final operator review of full snapshot before public push
    Outcome: factory public surface live at fstate.dev/DAOBoard

  Session N+7 — Hardening
    Stress-test the gate with intentionally bad daoboard.yaml fixtures
    Run third-party security review of the aggregator code path
    Document the failure modes and recovery procedures
    Outcome: DAOBoard extension stable, version 1.0 inscribed in FSE

The arc is bounded. Seven sessions. No session adds public surface area
that hasn't been gated through operator decision.

================================================================================
8. WHAT THIS NOTIFICATION DOES NOT AUTHORIZE
================================================================================

  - It does not authorize any property to publish data before its
    daoboard.yaml has been authored and reviewed in an FSE session.

  - It does not authorize the public surface to go live before Session
    N+6 final operator review.

  - It does not authorize the aggregator to read any file other than
    daoboard.yaml.

  - It does not authorize editorialization, marketing copy, or any
    interpretive layer over the published numbers.

  - It does not authorize linking DAOBoard publicly until the standing
    order is inscribed and the gate is operating.

  - It does not authorize any expansion of the protected categories
    list to be made more permissive. The list may be made more
    conservative but never less.

================================================================================
9. ACKNOWLEDGMENT
================================================================================

This notification is committed to the FSE methodology project as the
opening artifact of the DAOBoard extension arc. The extension proceeds
under the standing order inscribed herein. Any deviation from the
protection model in this document constitutes a violation of FSE
discipline and is escalated through the lessons learned registry.

Filed: 2026-05-17
By: Office of the Chairman, Joticle, Inc.
Methodology version at filing: [current]
Extension target version: [next minor]

================================================================================
END NOTIFICATION
================================================================================
