# Phase 14a — Suite identity: the neutral account — execution plan

> **Status: OPEN — the kickoff design sitting is IN PROGRESS (2026-08-03, author-attended).**
> Opened at the author's redirect recorded on the master plan pointer ("i think i'll
> probably just run phase 14 right now instead of 13e then - more sync engine surgery,
> seems better for this current token burning era"). Runs under `/architect-phase` (the
> skill governs; CLAUDE.md wins on conflict — the 2026-08-03 push rule supersedes the
> skill's environment-section "never push" line: sessions commit AND push at regular
> intervals). **NO pre-written plan existed** — the 2026-07-30 split of row 14 fixed
> scope boundaries only; this file is authored JUST-IN-TIME from the sitting's rulings.
> **Cast:** her recorded lean is ALL-FABLE for this token window — confirmed or amended
> at sitting batch 1 (see the sitting record). **14b is its OWN kickoff at this phase's
> gate** — nothing here builds E2EE; 14a must merely never preclude it.

## What this phase is (the fixed scope boundary, from the 2026-07-30 split)

One login for the whole suite — both apps trust a neutral account. Deliverables per the
master-plan 14a row: the neutral OIDC issuer (the 9c delegated pattern re-pointed at the
suite account) · non-author provisioning (signups deliberately re-enabled — on the
NEUTRAL account, see the guard note below) · the consent/sign-in pages productized on
stargazing.tech (retiring the 9c LAN-interim residual; that repo's own agent builds
them — the author tasks it, this repo's sessions never do) · her own account's migration
path off the 9c route-A arrangement · **the Fragments-side conversation OPENS HERE**
(asks ride `notes/fragments-bridge-contract.md`, carried by her; `~/dev/fragments` is
hands-off, always). **14a is the suite launch's critical path** (her 2026-07-30
snapshot: Fragments is "pretty ready" and its remaining launch items — "the login page /
the stargazing login decisions, privacy policy, etc." — largely coincide with this
scope).

## What binds (ruled BEFORE kickoff — pointers, never re-litigated on no new grounds)

- **Neutral issuer, RULED** (release-strategy §4, fifth round): *"i have other apps in
  the works and a single login makes sense."* The identity-home fork is settled; the
  MECHANICS are this sitting's question 1.
- **Brand PROVISIONAL: stargazing** — her uncertainty preserved verbatim: *"i'll have
  to think about if stargazing is the brand I want but it's what I'll go with for now."*
- **Wrap secret RULED 2026-08-03** (release-strategy §4's dated addendum): a SEPARATE
  encryption passphrase, never the account password. **The recorded 14a consequence:
  the neutral issuer needs NO custom sign-in cryptography — stock Supabase auth
  suffices, because no auth secret ever doubles as key material.**
- **The 14b vault lives on the account** (after this phase) and **the 14c entitlement
  is checked from both apps** — 14a builds neither, and its account model must
  preclude neither.
- Verification line from the row: both apps sign in against the neutral account; the
  bare key still grants nothing; **her existing data untouched** (owner_id
  *[removed for publication]*
  must survive this phase byte-identical, or a deliberate mapping must exist; silent
  re-keying is forbidden).
- **SyncSpec §12 governs ANY mirror/schema change**; a mirror deploy executes only on
  her explicit go-ahead (the R53 precedent). The standing Sync/ rider routes
  transport/token work to Fable in any cast.
- **The 9c-era guard is LOAD-BEARING and survives this phase:** the VARIORUM project's
  signups-off toggle is the ONLY guard on the eight non-owner mirror tables (variant +
  commit_point = the whole prose corpus — `04_auth_rls.sql`'s header precondition).
  "Signups deliberately re-enabled" means the NEUTRAL account accepts new users;
  the Variorum project's own signup/first-OIDC door STAYS CLOSED until 14c's
  parent-join isolation. Any design that would open it here is out of scope by ruling.

## The 9c inheritance (verified facts a fresh implementer starts from — sources: the
## 9c plan's Step 0 memo + closeout, the Step 6 runbook, `Server/supabase/04–07`)

- **Route A proven LIVE (2026-07-10):** one Supabase project (Fragments,
  *[removed for publication]*
  *[removed for publication]*
  delegated sign-in mints Variorum-NATIVE sessions (RLS on plain `auth.uid()`, no
  claim gymnastics); `provider_token` + `provider_refresh_token` ride the INITIAL
  exchange only — Supabase never persists or re-delivers them. The
  Supabase-to-Supabase pairing is undocumented but empirically confirmed, including
  the dynamic-registration toggle's semantics (gates only the register handler).
*[removed for publication]*
  *[removed for publication]*
  (the `journal_entries.user_id` class). One email underlies both.
- **The client layer (reused, not rebuilt):** `App/Variorum/Shared/AuthSession.swift`
  (plain-REST GoTrue, PKCE code flow, Keychain persistence, single-flight refresh with
  the provider-pair preservation rule, sign-out-is-terminal), `SignInFlow.swift`
  (ASWebAuthenticationSession, the three round-1 lifecycle fixes), `Auth/UserSession.swift`
  (ONE session seam, two backends — built to be re-pointed), `ProjectConfig.swift`
  (public coordinates, committable BY DESIGN under the signups-off precondition).
  **No third-party SDK** — the hand-rolled doctrine; any new dependency is author-only.
- **The mirror:** `04_auth_rls.sql` shipped the demotion (RLS on all mirrors,
  RPCs authenticated-only, two-half owner guards on the five owner tables), bodies
  re-affirmed verbatim through 05/06/07; **lockstep marker = 4**. The eight non-owner
  tables' guard is procedural (signups-off) until 14c.
- **The bridge's Fragments session is shape (c)** (ratified QUESTIONS #16): her
  Fragments email+password, direct, only the session persisted. It must SURVIVE her
  account migration — the Fragments-project password identity stays.
- **The consent page:** spec `notes/fragments-consent-page-spec.md`; the production
  page NEVER shipped — any new-device sign-in still rides the LAN-interim spike page
  (9c RESIDUAL 1: `python3 -m http.server 3000` in `Spikes/AuthPairingSpike/`). This
  phase retires that residual against the NEUTRAL issuer.
- **Contract state:** all asks answered; ask 13 CLOSED; the 14a-horizon section
  (2026-08-02) pre-frames tonight's questions — Fragments' TestFlight shipped WITHOUT
  waiting on any of this, keeping auth in one seam, with tester-account migration
  accepted as a 14a deliverable ("early testers may face a one-time re-link step").

## The binding principles (the 13b constitution, P-1…P-9 — copied verbatim per the
## `/architect-phase` skill; phase-specific names inside them are the rules' provenance)

- **P-1 — One capability registry.** Every user-facing act is declared exactly once:
  verb, scope (block/take/post/book), per-mode availability rule, its doors (menu /
  context / bar / shortcut / palette), and its refusal copy. Surfaces render their
  doors FROM the registry; gating is data, never per-view if-statements. A
  registry-walk test asserts every declared door exists and every rendered door is
  declared. This kills the D3/D4 class structurally — the capability matrix stays
  green by construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act — including
  any mode-switch choreography, done visibly for the user — or delivers the operations
  layer's real refusal. A door that can never act in its context isn't rendered.
  Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface component (live +
  read modes; one measurement brain — the width-gated remeasure; the shared canary)
  that every pane composes; the live editor core's identity machinery
  (`BlockRangeIndex`, crystallization) becomes its live mode, not a sibling
  implementation. "What text does this pane show, and is it live" is answered by ONE
  pure, unit-tested authority (`PaneTextAuthority`); views never re-derive it. Its
  invariants stated as code: exactly one live pane; the live pane is
  buffer-authoritative; read panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter may announce
  that something happened (mode changed, post opened); no listener derives business
  state or availability from a broadcast, and no flow's correctness depends on
  broadcast ordering. Cross-feature flows route through composition. (Stage 0's survey
  enumerates today's notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule marks an
  under-architected feature. The response is never another patch: write the feature's
  DESIGN MEMO — intended behavior whole, edge cases enumerated on paper, refusal
  wordings, undo story — get the author's rulings on the product-flavored edges, then
  build to the memo. Happy path ships first, but the edges are *decided at design
  time*, not discovered by the author. First two memos owed: **merge** and **the W
  ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial flow is
  the contract for every happy path. It stays green — automated where the harness
  allows, screenshot-walked otherwise — and any change that breaks a tutorial step is
  a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive harness: the
  ops-layer soaks (exist), the board/view-model invariant soak (Stage 1), the registry
  walk (P-1), the per-batch scripted screenshot walkthrough. Red-on-old stays
  absolute: no bug-class fix without a pin that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind the rebuilt
  layer exactly as they bind the substrate (invalidation ∝ realized rows; one live
  editor; virtualized long views). Overlays, never rendering attributes. Chrome
  `fixedSize` texts always carry a `lineLimit` (the b6dae25 class).
  `Theme/VoiceControls.swift` is THE chrome vocabulary. Complexity lives in the store;
  restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing board layout,
  text authority, and gesture routing splits by concern (`TakesViewModel` at 890 lines
  is the standing counterexample). Same hygiene rule as the substrate, applied where
  it was being waived.

## THE KICKOFF SITTING (2026-08-03 — author-attended; rulings recorded VERBATIM)

Her agenda (from the kickoff message, batches of ≤4): **(1)** issuer mechanics — the 9c
candidates re-decided at suite level, with concrete tradeoffs including where the 14b
key vault would live under each; **(2)** the brand/domain surface + the spec for the
consent/sign-in pages (the stargazing.tech agent builds them; she tasks it); **(3)**
non-author provisioning scope and the 14a/14c line; **(4)** her own account's migration
path (fresh A1 backup before anything touches the mirror's auth); **(5)** the
Fragments-side ask list.

### Batch 1 — cast · issuer mechanics · spike timing (presented 2026-08-03)

**Presented tradeoffs (the architect's, from the reading — recorded before her
rulings):**

- **(A) A NEW neutral Supabase project as the suite's account home — RECOMMENDED.**
  The 9c-proven pairing re-pointed: the neutral project enables the OAuth 2.1 Server
  and holds the suite's `auth.users` (signups ON — this is where non-author
  provisioning lives); BOTH app projects register it as a custom OIDC provider; each
  app project keeps minting its own native sessions, so Variorum's RLS/`owner_id`
  stays plain `auth.uid()` — unchanged. **Vault placement:** the 14b key vault and the
  14c entitlement live as RLS'd tables on the neutral project — one account, one uid,
  one vault row; the apps reach it via the provider-token pair (delivered at the
  delegated exchange; refresh strategy is a design point of this phase, and
  provider-token acceptance by the neutral project's PostgREST is one of the two
  load-bearing unknowns the spike verifies). **Costs, honest:** a third Supabase
  project to operate (Free tier caps at 2 projects/org — may need the Pro upgrade she
  said at 9c she's willing to take, or a second org); her account migrates by
  email-based identity linking (spiked before relied on — fallbacks: the admin
  identity-link API; NEVER silent re-keying); the consent page re-targets from the
  Fragments project to the neutral one.
- **(B) Shared signing-key material imported into both app projects.** No third
  project — but no neutral home either: one project is still the de-facto identity
  host, the vault has nowhere natural to live, rotation and compromise blast radius
  couple, the cross-project pattern is undocumented, and GoTrue refresh still binds to
  the minting project. 9c's fallback posture; WEAKER at suite scale (every future app
  re-couples the keys again).
- **(C) One merged Supabase project.** Rejected-leaning since 9c, and worse now:
  coupled deployments and migration lockstep across products, strains
  hands-off-Fragments, and at suite scale ("other apps in the works") it is a
  monolith. Only merit: one-account and the vault are trivial.
- **(D) An external IdP (Clerk/Auth0-class) as the suite identity.** The one
  DOCUMENTED third-party-auth path (Supabase's closed provider list) — but a NEW
  third-party dependency (author-only call by standing rule), a vendor bill, RLS
  demoted to `auth.jwt()->>'sub'` claim gymnastics on both app projects, and the
  vault still needs a Supabase data home — the neutral project gets built ANYWAY,
  plus a vendor.

**Also presented:** spike timing — the two load-bearing unknowns under (A) are (i)
email-based identity linking preserving her existing Variorum `auth.uid()` (the
no-re-keying migration road) and (ii) the neutral project's PostgREST accepting its
own OAuth-server-issued provider tokens (the vault access path; flagged unverified
since 9c). Both are Step-0-class: verify live before the plan builds on them. Brand
does not gate the spike (project refs are random; display names rename freely).

**RULINGS (2026-08-03):**

- **R1 — Cast: ALL-FABLE confirmed** (architect · fresh implementer per batch · cold
  reviewers). Her pre-kickoff lean, ratified at the sitting.
- **R2 — Issuer mechanics: shape (A) RULED** — a NEW neutral Supabase project is the
  suite's account home; OAuth 2.1 Server on it is the suite issuer; both app projects
  trust it as a custom OIDC provider; the 14b vault + 14c entitlement live as RLS'd
  tables on it. B stands down to documented-unused (the 9c posture, re-affirmed at
  suite level); C stays rejected; D rejected (new dependency + the vault needs the
  neutral project anyway).
- **R3 — The best-answer rider, HER WORDS VERBATIM (attached to the spike question,
  binding on the whole phase's design): "nothing that we already have setup should be
  too big of an issue or decider for this - i'm the only user of both apps. i'm not
  sure what A1 backup is. yes, we can run the spike now, but let's get the best
  answer, not whatever is convenient based on current email."** Consequences, as the
  architect reads them (recorded so a fresh session inherits the posture): the
  existing arrangement — current identities, current emails, the 9c custom:fragments
  pairing — is NOT a design constraint; she is the only user of both apps, so her own
  account's migration may be a DELIBERATE re-map (including a §12-choreographed
  owner_id re-key, if that yields the cleanest final state) rather than contorting the
  suite design to preserve accidental identity values. "Her existing data untouched"
  (the row's verification line) still binds as NO LOSS AND NO CORRUPTION — it no
  longer binds as byte-identical uids. The suite account's email is HER free choice,
  never assumed from current accounts; email-based identity linking demotes from "the
  migration road" to one candidate among deliberate options, weighed at the migration
  design step.
- **R4 — Spike timing: NOW, in-sitting** ("yes, we can run the spike now").
- **R5 — The custom:fragments pairing may be retired OUTRIGHT; the bridge's latitude,
  HER WORDS VERBATIM: "yeah, i don't really fully understand what's going on with the
  custom fragments pairing but I am honestly willing to just get rid of it completely
  for now (though we should make sure that it's still possible to add back in later).
  I do care about the bridge long term but if it has to die right now for the E2EE
  phase and then get added back in, that's fine."** The architect's clarification,
  recorded with the ruling because the two mechanisms are DISTINCT (and 9c made them
  independent deliberately): **(a)** the `custom:fragments` pairing is only about
  SIGN-IN — Variorum's project currently trusts Fragments' project as the identity
  that proves who she is. Under the ruled shape (A) it retires at THIS phase by
  design — both apps trust the neutral project instead — so her willingness matches
  the plan exactly; re-adding any such pairing later is a dashboard configuration
  (the 9c-proven pattern), never a rebuild. Once Variorum's provider is deleted, the
  Fragments project's OAuth 2.1 Server (as issuer) and the registered client
  *[removed for publication]*
  BRIDGE (the journal co-writer pushing/pulling `journal_entries`) does NOT ride the
  pairing: its session is shape (c) — her Fragments email+password, direct (ratified
  #16) — so retiring the pairing leaves the bridge running untouched. Nothing in 14a
  needs to kill it, and the recorded 14b direction is that the bridge is KEPT AND
  PROMOTED (public at launch; its journal class gains E2EE under the shared key —
  an upgrade, not a death). Her die-and-re-add latitude is recorded as headroom the
  plan holds but does not currently spend.

**Field notes (the spike record — appended live, the 9c Step-0 form):**

*[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
  *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
  *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
  *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
  *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
  *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
*[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
- **Round 0c (same sitting) — her challenge to the third project itself** ("how big
  of a benefit is having the separate org rather than just a distinct table within
  one of the existing ones? … i'd probably put the home in variorum though instead
  of fragmnets and just not show users that it's within variorum. i'm a little
  conflicted"). The architect's analysis, presented before her ruling (this would
  AMEND R2 if taken):
  *[removed for publication]*
    *[removed for publication]*
  - **Branding: conceded, not an argument** — the project ref is an opaque random
    string; nobody can see "variorum" in the issuer URL, and a custom domain
    (auth.stargazing.tech) can front it later either way.
  - **"Could the table be moved later?" — the tables yes, trivially; THE ISSUER no.**
    The sticky part is auth.users + the issuer URL baked into every app's provider
    config and every user's identity claims. Extracting the account home later =
    re-pointing every app + re-linking EVERY user who exists by then; doing the
    separation now = migrating exactly one user (her). The debt grows with each
    suite signup.
  - **The concrete (non-purity) costs of home-inside-Variorum:** (1) the SIGNUPS
    COLLISION — suite signups ON would mint authenticated Variorum-project users,
    and the 9c BLOCKER's load-bearing guard (signups-off protects the eight
    non-owner mirror tables = her whole prose corpus until 14c) dies; mitigable by
    an 04-class RPC hardening (restrict sync_push/sync_pull to an author allowlist —
    modest, testable, §12-adjacent, her go-ahead) or by DEFERRING suite signups to
    14c. (2) BLAST-RADIUS COUPLING — 14b's E2EE mirror surgery and the suite's
    sign-in would share one project; a mistake in the most delicate upcoming work
    risks every app's login. (3) AUTO-PAUSE on free tier applies to the suite's
    LOGIN (mitigated by her daily sync activity; real on absences).
  *[removed for publication]*
    the Variorum project, suite signups STAY OFF until 14c (the provisioning
    deliverable slips there; Fragments keeps native signups for its testers and
    runs dual sign-in meanwhile; her one account still proves the one-login goal).
  *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
  *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
    (issuer-in-Variorum, signups deferred) recorded as the road NOT taken; variant
    iii (hardening + signups on) recommended against and not taken. Consequences:
    the 9c corpus guard survives byte-untouched; 14b's surgery and the suite's
    login never share a project; provisioning stays a 14a deliverable on the
    neutral project.

- **Round 0d (same sitting, a fresh session — her return with rulings after a
  requested re-litigation):** she asked for the absolute pros/cons of
  home-inside-Variorum once more ("ignore the flag that this shouldn't be
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  anchors kept:
  *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
  - **RULED — NO Fragments-native tester accounts** ("I don't want to have
    fragments native accounts"). SUPERSEDES the contract file's 14a-horizon
    frame (ship TestFlight on native auth, re-link later): TestFlight now WAITS
    on the neutral issuer — her stated window is THIS WEEK — and testers are
    stargazing accounts from day one, so the re-link debt never starts.
    Consequence: the consent/sign-in pages + Fragments' provider re-point are
    the week's critical path (the pages are the long pole — the 9c production
    page never shipped).
  - **R5's headroom is now SPENT, not just held** ("I also am not sure I want to
    even keep what we have on 9c … I don't want the variorum account to be a
    fragments account anymore"): the custom:fragments pairing retires this phase
    exactly as shape (A) intended; her account migrates to the neutral issuer at
    the migration design step (R3's deliberate-remap latitude; the A1 rail
    binds). The 9c client/RLS/RPC machinery is re-pointed, never discarded; the
    bridge (shape (c) session) is untouched by the pairing's death — how
    Fragments handles HER account under stargazing sign-in joins the
    Fragments-side ask list.
  - **HER GOAL, verbatim: "My goal is that by the end of this week, I want other
    people to be able to log in and use both variorum AND fragments."** The
    architect's split, presented with the function bodies re-read this round
    (02/04 verified): Fragments YES this week — full use under suite accounts
    (per-user isolation inside the Fragments project is its own affair; a
    confirm rides the ask list). Variorum sign-in for strangers NO — sync_pull
    owner-filters ONLY the five owner tables, so the eight non-owner tables
    (variant + commit_point = the whole prose corpus; `setting` = one shared
    keyspace) are served to and accepted from ANY authenticated caller of the
    project: a second authenticated user means mutual prose disclosure and
    commingled rows, not isolation. That is 14c's parent-join work, behind 14b
    per her own E2EE-from-birth ruling; the Variorum project's signups stay OFF
    (the standing scope line). What strangers CAN do now: the signed-out local
    app — fully functional by design (the v1 posture: signed-out reads as
    normal, never degraded).
  - **Recommended as a this-week 14a deliverable regardless (her go pending):
    the RPC allowlist hardening** — sync_push/sync_pull additionally refuse any
    caller whose uid is not hers; a few lines in a committed artifact under §12
    discipline (announced, executed verbatim, her go-ahead). It answers her "it
    seems very bad that right now new users could access my variorum tables??"
    structurally: today NOBODY can (signups off; Gate 4's probed 403; the bare
    key mints nothing) — but her instinct that one toggle is thin protection
    for the corpus is right, and the allowlist retires that thinness.
  - Her fundamentals, answered in-chat and kept for the record: **auth.users is
    indeed a small table** — the impact of its home is the PROJECT, not the rows
    (issuer-URL permanence; every account holder becomes an authenticated
    principal inside the same walls as the corpus; operational fate-sharing
    with 14b's surgery). And **the phone holds the full replica by design**
    (state-based row sync, every client a whole store); her store measures
    4.5 MB — prose scale keeps that trivial forever; pull-to-head hardening
    stays Phase 12's.

## Ledger

| # | Item | Status |
|---|------|--------|
| — | *(minted from the sitting's rulings)* | — |

## Environment traps (carried into every batch brief, per the skill)

- Instance checks: `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH;
  real-store instances are treated by STORE, never quit/killed; no Release builds or
  `/Applications` refreshes while one lives.
- Backups WAL-safe with UTC names, ALWAYS before touching the real store or the
  mirror's auth (the A1 rail — her agenda item 4 names it for this phase explicitly).
- Mac tests from `App/Variorum/`, suite-level `-only-testing` only; zsh `pipestatus`;
  never a custom build configuration (the 4G trap).
- The mirror is LIVE production for her daily driving — any dashboard/SQL change to
  the VARIORUM project is announced before it happens, uses committed in-repo
  artifacts verbatim, and follows SyncSpec §12 ordering. The NEUTRAL project (once it
  exists) is pre-production until her account migrates onto it.
- Baselines (do NOT re-run at session start — the 13k closeout is the record): core
  1034/114 · Mac 1191/208 (the one tripwire red by identity, covariate-UNKNOWN) ·
  mobile 14/4 · spine 51/7.
