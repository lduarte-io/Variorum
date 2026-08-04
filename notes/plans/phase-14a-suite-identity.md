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

## THE RULED STATE (as of sitting round 0k, 2026-08-03 — read FIRST; the sitting
## rounds below are the record, and they SUPERSEDE earlier sections where they differ)

- **Account home: the VARIORUM PROJECT ITSELF** (round 0h — supersedes batch-1 R2's
  *[removed for publication]*
  issuer; "stargazing" is the BRAND and the pages' front (planetlillian a live
  candidate); an eventual custom domain fronts the issuer. **No new org, no Pro
  purchase now** (her free-tier posture; upgrade at her word).
- **14a creates NO table** — `auth.users` already holds her. Her migration = add a
  *[removed for publication]*
  then retire `custom:fragments`. Variorum + mobile sign in DIRECT to the project;
  other apps (Fragments, future) ride the delegated OAuth flow.
- **Single sign-in absolute** (0f/0i): the Fragments email+password identity retires;
  the bridge's session goes suite-delegated (one browser hop per device, then the
  standing persisted-session + refresh loop); the separate bridge/sync credential
  surfaces RETIRE **at 14a** — one identity, one flow.
- **Nobody signs in before the family completes** (0e/0f): Variorum signups stay OFF
  until 14c's parent-join isolation; TestFlight waits for the whole family; NO
  Fragments-native tester accounts, ever. Non-author provisioning is 14c's.
- **No interim allowlist** (0j — supersedes 0i/0d): the signups-off toggle is the
  SOLE guard until 14c; the spike's post-OAuth-server re-probe (signup 403 AND a
  first delegated sign-in from a new identity both refuse) is LOAD-BEARING.
- **Standing guardrails:** custom domain before the first non-author signup; the
  re-decide checkpoint (the separate-project question gets one last look before the
  first stranger account); the vault-home question re-opens FREE at 14b's sitting.
- **The three Fragments touchpoints** (concrete asks live in
  `notes/fragments-bridge-contract.md`, staged): #1 at 14a — trust the issuer,
  delegated sign-in, link her user, retire native signup + password · #2 at 14b —
  journal-class E2EE + the trim/empty-body relocations · #3 at 14c — the
  entitlement check.
- **Execution opened IN-SITTING (0k):** her hands-on order — A1 backup → enable the
  OAuth 2.1 Server → register the Fragments client (+ the spike callback) → the
  signup-refusal re-probe → add her direct password → the pages brief to the
  stargazing.tech agent (authored AFTER client registration, so it carries real
  coordinates) → the Fragments asks carried. **14b's draft is authored at 14a's
  gate**; she opens it with its design sitting (key derivation / recovery /
  enrollment — the deliberately careful one; cast decided there).

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
  account migration — the Fragments-project password identity stays. *(SUPERSEDED at
  round 0f, 2026-08-03 — she ruled single sign-in with NO surviving Fragments
  password: the password identity retires; the bridge's session becomes
  stargazing-DELEGATED against the Fragments project, same persistence + refresh.)*
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

- **Round 0e (same sitting) — the multi-user completeness sweep + her mental-picture
  round.** Her instruction, executed same-turn: *"let's update the plan for 14 so that
  it includes everything needed for multi user variorum"* — the master plan's 14c row
  now enumerates the full set (the parent-join isolation of the eight tables with the
  14a allowlist retiring INTO it; **the `setting` table's multi-user redesign** — the
  sweep's one genuinely new find: one shared keyspace, no owner column, two users'
  settings would CAS-fight, a §12 lockstep event; the Variorum sign-in door opening;
  stranger onboarding/first-pull; per-user vault provisioning; two-USER convergence
  suites; the stranger-sees-zero probe). Also this round:
  - **Her sequencing word, verbatim: "nobody has a login yet and nobody is going to
    get a login before the E2EE surgery … I don't have users yet (aside from myself),
    the E2EE surgery is going to happen before there are other users, and I want
    things to be well buttoned up before that."** For VARIORUM this confirms the
    standing order (strangers at 14c, after 14b) and is now stamped on the 14c row.
    **THE OPEN RULING it creates:** round 0d's goal had Fragments TestFlight testers
    logging in THIS WEEK — strictly read, "nobody before the E2EE surgery" would
    push TestFlight past 14b (testers' journals otherwise ride plaintext until the
    journal-class E2EE lands and migrates them). Two coherent readings presented to
    her: (i) testers this week, plaintext-until-14b accepted and migrated; (ii) the
    week ships infrastructure + her migration only, 14b runs next at AI speed, and
    TestFlight opens on E2EE'd journals ~a couple of weeks out. Her call; the neutral
    project's signups-ON timing follows the same ruling.
  - **The internal-guard question, conceded and refined** (her push: "I'm still not
    seeing 100% the actual issue … I don't have users yet, the E2EE surgery is going
    to happen before there are other users"): she is RIGHT that her sequencing
    dissolves the interim-window risk the guard argument leaned on — with no second
    authenticated user before 14c's isolation, home-inside-Variorum would also have
    been safe in the interim. What SURVIVES as the separate project's real value,
    stated honestly: (1) fate-sharing/blast radius (14b's mirror surgery, restores,
    pauses never share a project with every app's login); (2) issuer permanence —
    her own future-apps instinct ("it would eventually be a little weird for
    variorum to hold the keys to all of them"), which is the load-bearing reason;
    (3) **vault separation** — under the ruled shape the 14b wrapped keys live on
    the NEUTRAL project while the ciphertext lives on Variorum's, so no single
    project dump ever holds both; inside-Variorum they would cohabit.
  - **The bridge at week's end: byte-unchanged.** The bridge is DATA-plane (journal
    rows between the two APP projects, shape (c) session); the issuer is
    IDENTITY-plane (who she is). No journal byte ever flows through the neutral
    project under any shape; retiring custom:fragments touches sign-in only. The
    with/without-issuer comparison presented in-chat and summarized: without = 
    Fragments doubles as the suite's de-facto identity host; with = both apps trust
    the neutral account and the bridge merely swaps HOW its Fragments-project
    session is eventually obtained (shape (c) today; optionally delegated-via-
    stargazing later). 14b upgrades its journal class to E2EE — an upgrade, never
    a death (R5's latitude stays unspent).
  - **The AI-age structuring answer, recorded:** the 14a→14b→14c order is
    DEPENDENCY-forced (vault on the account → E2EE; E2EE before users → isolation
    before signups), not calendar-forced — so the structure stands and the CALENDAR
    compresses (days-per-phase, not weeks). The one deliberate slow step: 14b's
    key-design sitting (derivation, recovery, enrollment are one-way doors baked
    into ciphertext — build fast, decide carefully).
  - The Fragments-side ask list drafted in-chat this round; it formalizes into
    `notes/fragments-bridge-contract.md` once she rules TestFlight timing and the
    neutral project exists (its issuer URL is the missing coordinate).

- **Round 0f (same sitting) — single sign-in ABSOLUTE; the bridge goes delegated;
  TestFlight stands down to after the family.** Her challenge, verbatim: "I don't
  think I'll have a fragments email + password anymore, right? … I don't want the
  bridge to rely on fragments email + password because that is exactly what we're
  retiring."
  - **RULED — single sign-in with NO surviving Fragments password.** The 9c
    inheritance line ("the Fragments-project password identity stays") is
    SUPERSEDED (annotated in place above): her Fragments USER survives — same uid
    *[removed for publication]*
    the stargazing identity links on, the email+password identity unlinks. One
    identity everywhere (14b's encryption passphrase stays its own separate
    secret by the standing wrap-secret ruling — it is not a second LOGIN).
  - **The bridge under single sign-in (her "what will happen?"):** the bridge's
    load-bearing need was never the password — it is A SESSION against the
    Fragments project. Today that session is minted by password grant; after the
    migration it is minted by the DELEGATED flow (Fragments' GoTrue trusts
    custom:stargazing → mints its ordinary NATIVE session for her linked user).
    Everything downstream is byte-identical: the persisted session, the
    single-flight refresh, the journal_entries dialect, S5's conflict door. The
    felt change: first sign-in per device is one interactive browser round (the
    shared issuer session makes the second app's round near-silent); a dead
    session pauses the bridge visibly and asks her to sign in — the standing
    refuse-don't-guess posture, unchanged.
  - **RULED — TestFlight WAITS for the family**, verbatim: "I'm just going to wait
    to have the testers and testflight until this whole phase 14 and all of its
    issues are resolved and fragments has its new answers / new id provider - i'm
    not in THAT much of a hurry to open up testflight tbh, I'd rather just get
    everything right, variorum mobile going with the correct login, the website
    redirect on stargazing.tech or on planetlillian, my website neatly up, etc."
    Round 0e's open ruling CLOSES on reading (ii)-and-beyond. Consequences: the
    week's critical-path pressure retires (14a proceeds deliberately, 14b
    promptly after; testers after that); the NEUTRAL project's signups toggle
    stays OFF until tester opening (the provisioning machinery remains 14a's
    deliverable — built and spike-tested; the toggle waits); **planetlillian.com
    is recorded as a NEW candidate beside stargazing.tech for the login/consent
    pages' home** (brand still PROVISIONAL) — noted to her that the PAGES' home
    is dashboard-re-pointable later (not a one-way door; only the issuer PROJECT
    is forever); **Variorum mobile builds against the neutral issuer from birth**
    (her word this round — recorded for the mobile design sitting); the contract
    file's 14a-horizon section updated in the same commit (the ship-native-
    then-relink frame superseded; no tester account will ever exist natively).
  - The vault-separation mechanics and the passport-office calibration answered
    in-chat this round: the three-part E2EE shape (ciphertext on Variorum's
    project / the passphrase-wrapped random data key in the vault / the
    passphrase never leaving her devices) and the concrete difference —
    cohabiting means ONE project dump (or one stolen backup) yields ciphertext +
    wrapped key together, collapsing the story to passphrase strength alone;
    separated means a Variorum dump is mathematically useless without a SECOND
    independent compromise. The "how weird" answer: technically zero — 9c IS a
    writing-app passport office today, proven fine at one user — organizationally
    compounding with app count (lifecycle chaining, access hygiene, incident
    blast radius), which is her own future-apps instinct stated back.

- **Round 0g (same sitting) — her third challenge lands: the architect's
  recommendation FLIPS. RULING PENDING HERS.** Her words: "can't i transfer the
  suite identity to something else later? … it seems like that is a manageable
  issue. I guess I'm back to not being that convinced on anything other than
  defense in depth or vibes that the login truly belongs separate from variorum …
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  - **Why the flip is reasoned, not capitulation — five facts are NEW since the
    round-0c ruling:** (1) her sequencing ruling (NOBODY logs in before the whole
    14 family, 14c's isolation included) eliminates every interim security window
    the separate project guarded — by the time any stranger holds an account,
    parent-join isolation is built and tested; (2) TestFlight waits, so there is
    *[removed for publication]*
    *[removed for publication]*
    *[removed for publication]*
    are weaker than the round-0c framing: `auth.users`/`auth.identities` are
    ordinary Postgres rows in a schema she owns — dumpable between projects with
    uids AND password hashes intact; sessions invalidate (everyone signs in
    again) but nothing is lost; and a CUSTOM DOMAIN fronting the issuer before
    the first stranger signs up makes even the issuer URL portable (verify the
    OAuth-server iss-claim behavior at adoption time — flagged, not asserted);
    (5) in-Variorum-as-issuer REMOVES her own migration entirely: her existing
    *[removed for publication]*
    byte-identical by construction, and the R3 re-map machinery stands down.
  - **What honestly remains for the separate project, stated as what it is:**
    the 14b vault-separation depth (real, but the vault is NEW data at 14b —
    the separate-project option can be re-taken THEN at zero migration cost, so
    the decision naturally re-opens at the 14b sitting); ops fate-sharing once
    real users exist (modest, and Pro/reorganization is available then — org
    moves are free); organizational tidiness at N apps (her word for it — vibes —
    is fair at current scale). Also recorded: a PAUSED issuer breaks only NEW
    sign-ins — existing native sessions refresh project-locally (the 9c
    provider-tokens-ride-the-initial-exchange-only fact), so free-tier pause is
    even softer than round 0c framed it.
  *[removed for publication]*
    (a) the RPC author-allowlist lands NOW regardless (config mistakes become
    non-fatal); (b) Variorum-project signups stay OFF until 14c's isolation is
    built and tested — already her ruling; (c) a custom domain fronts the issuer
    BEFORE the first non-author signup (portability insurance, bought only when
    needed); (d) a standing RE-DECIDE CHECKPOINT written into the plan: before
    the first non-author account is ever minted, the separate-project question
    gets one final look — at that moment it is still a one-user migration.
  - **Unchanged by this re-decision, whatever she rules:** single sign-in with
    the Fragments password retiring; the bridge going delegated; TestFlight
    waiting for the family; mobile on the suite login from birth; the 14c
    completeness sweep; the allowlist. The ONLY variables are which project
    hosts the issuer + `auth.users`, and whether new money is spent now.
  - If she takes the flip: round 0c's ruling is SUPERSEDED (recorded, never
    erased), R2's shape (A) amends to "the Variorum project is the account home"
    with the same OAuth-2.1-Server mechanics, and the org/Pro purchase stands
    down until she wants it.

- **Round 0h (same sitting) — RULED: THE FLIP IS TAKEN.** Her words: "I like the
  idea of variorum being the home for users better than fragments being the home
  *[removed for publication]*
  *[removed for publication]*
  SUPERSEDED (recorded, never erased); R2's shape (A) AMENDS: **the VARIORUM
  project is the suite's account home and OAuth 2.1 issuer** — "stargazing"
  survives as the BRAND and the pages' front (plus the eventual custom domain),
  not a separate project. The Pro-org purchase stands down (upgrade at her word,
  when she wants it). **The four guardrails BIND:** allowlist now · Variorum
  signups OFF until 14c's isolation · custom domain fronts the issuer before the
  first non-author signup · the re-decide checkpoint before the first non-author
  account is minted. Consequences: her migration collapses to adding a DIRECT
  *[removed for publication]*
  by construction; custom:fragments then retires); Variorum-the-app and mobile
  sign in DIRECTLY to their own project (no OAuth hop — the 9c AuthSession
  password grant, re-aimed); only OTHER apps (Fragments, future) ride the OAuth
  flow. The issuer URL is therefore KNOWN TODAY
  *[removed for publication]*
  ask list went concrete in this round's commit. **Her table question answered
  for the record: 14a creates NO new table** — `auth.users` already exists in
  the Variorum project and already holds her; the family's new tables are 14b's
  vault (wrapped keys + device enrollment, RLS'd, §12 lockstep) and 14c's
  entitlement + the `setting` owner-scoping. The condensed family map with the
  three Fragments touchpoints (#1 now: trust issuer / delegated sign-in / link
  her user / retire native signup+password; #2 at 14b: journal-class E2EE + the
  trim and empty-body asks; #3 at 14c: the entitlement check) was delivered
  in-chat as her requested mental picture; TestFlight remains after the family.

- **Round 0i (same sitting) — clarifications; the allowlist timing lands NOW at
  her word ("I think either one works").** Dispositions recorded for the build:
  the allowlist is the SINGLE-USER lockdown, not a multi-user feature — written
  now as a committed artifact, deployed only at her explicit go per §12, and
  REPLACED at 14c by real per-user isolation. Her mental-model confirmations,
  all answered yes: her Variorum user always existed — only its PROOF was
  Fragments-only (14a adds a direct password to the SAME user, then removes the
  Fragments proof); 14a REVERSES the trust arrow (today Variorum delegates to
  Fragments; after, Fragments delegates to the suite issuer riding the Variorum
  project). **UI consequence of the 0f single-sign-in ruling, confirmed for the
  build: the separate bridge credential surface RETIRES** — one identity, one
  password, no separate "bridge" vs "sync" sign-ins anywhere; first sign-in per
  device may involve one in-app entry plus one brief browser round (the
  delegated hop that mints the bridge's Fragments-project session), presented
  as ONE flow — flattened as far as the mechanics allow, a build-time detail.
  Fragments-side: there is not and never was a bridge component there — its
  sign-in simply opens its own data, journals included, unchanged. **The
  bridge's end state, pinned in one line: a background limb of her one account —
  the same journal_entries pipe, Variorum-side, session minted via the suite
  identity (14a), payloads encrypted (14b), no identity or credential of its
  own.**

- **Round 0j (same sitting) — the allowlist STANDS DOWN at her word; three
  confirmations.** Her ruling, verbatim: "honestly, if we're doing the real thing
  in 14c I don't see a big point in doing that now - 14c will happen soon enough.
  my corpus doesn't need that much protecting right now." SUPERSEDES round 0i's
  lands-NOW disposition (and 0d's promotion): NO interim allowlist is written or
  deployed; the signups-off toggle remains the SOLE guard on the eight non-owner
  tables until 14c's parent-join isolation retires the single-user premise
  outright. **The compensating check rides the spike (already planned, now
  load-bearing):** after the OAuth 2.1 Server is enabled on the Variorum project,
  re-probe that `POST /auth/v1/signup` AND a first delegated sign-in from a NEW
  identity both still refuse — the 04 header's claim re-VERIFIED under the new
  configuration, never assumed. The master-plan 14c row and the session memory
  are corrected in this same commit (the allowlist-retires-INTO-isolation clause
  comes out). Her confirmations, all affirmed: **(1)** Fragments' sign-in just
  shows the journal because the bridge does all the comparing/pushing/pulling
  from Variorum's side — exactly right. **(2)** Holding a Fragments-project
  session is "easy" in the precise sense that NO second credential exists — the
  one-time browser hop per device is the handshake that turns her suite identity
  into Fragments' own native session (self-refreshing thereafter, project-local);
  controlling the suite identity doesn't skip the handshake, it makes the
  handshake credential-free. **(3)** The active sync loop is 100% Variorum-side;
  Fragments-the-app has no awareness of the bridge today and at 14a. The honest
  edges recorded with the yes: Fragments' SERVER is the passive door (its RPC
  endpoints serve the bridge like any client); the trim / empty-body-as-deletion
  behaviors are small standing interactions; and at 14b Fragments' client DOES
  gain journal-class crypto — the one real involvement, scheduled as
  touchpoint #2.

- **Round 0k (same sitting) — the docs audit + execution opens.** Her asks this
  round, all executed same-commit: **(1)** the full-record audit — the RULED
  STATE banner now heads this file (a fresh session reads it before the
  historical sections; rounds supersede); the KnownIssues auth-hardening row
  re-sequenced (provisioning → 14c); the contract's asks restructured into the
  three STAGED touchpoints at her word ("clear what will be required from
  fragments and what to tell fragments at each stage"); the release-strategy
  identity-home bullet gained the dated 0g–0h addendum (it was accurate at
  concept level — "neutral issuer" survives as brand — but now cannot be
  misread as a separate project). **(2)** Her execution plan for the sitting,
  recorded: she takes the 14a hands-on items NOW in-conversation (the Supabase
  steps together, step-at-a-time with visual verification — the 9c didn't-save
  incidents are the standing caution); the stargazing.tech pages BRIEF is
  authored right after client registration so it carries real coordinates; the
  Fragments asks carried by her after that; **the 14b draft is authored at
  14a's gate** and she opens 14b with its design sitting. **(3)** One
  correction delivered: the sign-in UNIFICATION (the separate bridge/sync
  buttons collapsing into one flow) is **14a build work** — it happens when
  custom:fragments retires and the bridge goes delegated — NOT a 14b item;
  14b's sitting is the encryption design (passphrase/KDF, recovery phrase,
  device enrollment, the setup-warning UX). Her phrasing ("which is also where
  the separate bridge and sync button will be required") flagged back to her
  in case she meant something the architect missed. **(4)** The
  passphrase-storage explanation given in-chat (the envelope model): the
  passphrase itself is NEVER stored anywhere — what the vault stores is the
  random DATA KEY sealed under a passphrase-derived key (and a second copy
  sealed under the recovery phrase); typing the passphrase derives the seal
  key on-device and opens the envelope in memory. Nothing on any server can
  produce the passphrase; the honest corollary (unrecoverable-by-design) is
  the 14b setup warning's whole content.

- **Round 0l (same sitting) — EXECUTION ROUND 1: the OAuth Server is ON.** Her
  confirmations: `/architect-phase` discipline governs (config + docs are
  sitting work; every CODE change goes to a fresh implementer with the ladder);
  **"Allow new users to sign up" re-confirmed OFF, twice**. Her screenshot: the
  OAuth Server toggle enabled on the Variorum project; Site URL
  `http://localhost:3000`; Authorization Path `/oauth/consent`; Allow Dynamic
  OAuth Apps OFF; **"Save changes" still pending** — the save-trap reminder
  issued (the 9c didn't-save incidents; save, reload, verify). Executed this
  round, committed: **(1)** the A1 rail — WAL-safe backup of the real store
  (`variorum-backup-2026-08-04-024355.sqlite`, UTC name, `PRAGMA
  integrity_check` ok, 4.9 MB) BEFORE further auth changes; **(2)**
  `SuiteAccountSpike/config.js` filled with the Variorum project's public
  coordinates; **(3)** the spike README adapted to the ruled shape (signup
  probe INVERTED to refusal; P-ii runs as HER, so the password identity
  precedes the spike; `vault_probe` on the live project only with her
  announced go, dropped after); **(4)** **the pages brief authored:
  `notes/stargazing-login-pages-brief.md`** — the 9c contract re-pointed at
  the suite project with real public coordinates, the two live-failure traps
  carried, NO create-account door (signups-off is correct behavior), "done,
  not pretty" per her word; the old `fragments-consent-page-spec.md` annotated
  SUPERSEDED. **Fragments: told NOTHING yet** — touchpoint #1 goes over only
  after client registration mints real coordinates (client id + secret +
  issuer endpoints). Open to her, in order: save-and-reload the OAuth screen
  (Authorization Path → `/consent.html` for the spike; the real origin +
  `/oauth/consent` at pages-deploy); report what sits BELOW "OAuth Endpoints"
  (a manual OAuth-apps registration UI decides manual vs the dynamic-toggle
  road); check her user's ⋯ menu under Authentication → Users for a direct
  password-set door (else the admin-curl template, password never transiting
  chat).

- **Round 0m (same sitting) — EXECUTION ROUND 2: pages home ruled, spike client
  registered, the brief goes one-pass-complete, the mobile message slotted.**
  Her rulings and the acts, in order:
  - **Pages home RULED: stargazing.tech** ("since it's currently up";
    planetlillian stands down for now — the overall brand stays PROVISIONAL).
    Her floated path `stargazing.tech/variorum` — the architect's
    recommendation, recorded for her call at build: a SUITE-NEUTRAL path
    (`/oauth/…`), because Fragments users and future apps land on these pages
    too.
  - **The brief EXPANDED to the complete one-pass page set** (her Cloudflare
    rebuild budget: "limited number of rebuilds per day … I do want to get the
    website fairly well thought out and completed"): page 1 sign-in+consent ·
    page 2 **the sign-up form built and WIRED NOW** (her question answered YES,
    ruled in — it renders the refusal as "Sign-ups aren't open yet" until 14c
    opens the door, then works with zero page changes) · page 3 the
    password-reset catcher (`/oauth/reset` + a forgot-password trigger). The
    **"not pretty" instruction RETRACTED at her word** ("I don't need it to be
    made particularly ugly either lol") — replaced with her actual frame: style
    at the site agent's discretion; the priority is complete, reliable wiring
    ("log in from phones, update variorum mobile and be able to log in").
  - **The Site-URL flip CONFIRMED as in-phase work matching the brief**: Site
    URL localhost:3000 today (the spike) → `https://stargazing.tech` + the
    consent path at pages-deploy, with the save-reload-verify rule.
  - **The MOBILE update message ADDED as a 14a-GATE deliverable at her word**
    ("do add to the 14 plan that at some point we're going to have to send a
    message to variorum mobile updating it - it carries the shared Phase 8/9c
    shells right now"): when the auth-seam code batch lands, a self-contained
    update message goes to the mobile project (direct sign-in adoption,
    `custom:fragments` retirement, the ProjectConfig/AuthSession seam) so she
    can sign in from her phone. Master-plan 14a row carries the clause.
  - **Registration: the dynamic door WORKED on the first curl** — the spike
    *[removed for publication]*
    `http://localhost:3000/callback.html`), which also PROVES her
    dynamic-toggle save landed (no "no add application section" ambiguity —
    the dashboard has no manual UI, the 9c finding re-confirmed). She toggles
    "Allow Dynamic OAuth Apps" OFF now (9c-proven: registered clients
    survive). **The Fragments client will be registered LATER via the ADMIN
    door** (`POST /auth/v1/admin/oauth/clients`, her PAT/service key — no
    open-registration window, and its client_secret is minted fresh at
    touchpoint-1 handoff).
  - **The password road, answered and prepped:** recovery-email flow, and NO
    provider change first — the email+password identity and `custom:fragments`
    COEXIST on her user; the provider stays enabled until the app's direct
    sign-in ships (her installed app's session refreshes project-locally
    regardless), and her Fragments password stays valid for the bridge until
    the delegated swap. The spike gained **`index.html`** — the recovery
    catcher (Site URL localhost:3000 → the email link lands on it; set the new
    suite password → PUT /auth/v1/user → built-in test sign-in verifies).
    `config.js` carries the client id.
  - Still open before the spike run: the `vault_probe` scratch table on the
    live project (the README's SQL — her paste in the SQL editor at her go;
    dropped after the probe).

- **Round 0n (same sitting) — the reset mystery SOLVED: the 9c residual was
  squatting the port; the recovery flow itself worked perfectly.** Her report:
  the recovery link landed on a bare directory listing; her read ("i think i
  need to change my user from being fragments authorized or something")
  REFUTED with evidence — nothing is wrong with her user. The lsof trace: PID
  42190, `python3 -m http.server 3000`, cwd `Spikes/AuthPairingSpike`, up ~10
  days — **the 9c LAN-interim sign-in server** (her element-hub guess also
  refuted; the screenshots showed its "Fragments — authorize Variorum" page
  and its exact three-file listing). The verify hop honored Site URL and
  delivered the token in the fragment — it just landed in a directory with no
  catcher page. **The residual's retirement is a NAMED 14a deliverable —
  executed now:** she kills the process (the architect's kill was blocked by
  the permission layer; one-liner handed over), then serves
  `SuiteAccountSpike/` on the same port. From this moment new-device
  `custom:fragments` sign-ins have no consent page — acceptable BY
  CONSTRUCTION (that road retires this phase; existing sessions refresh
  project-locally). Her wait-for-the-site alternative declined with reasons:
  the registered redirect URI and Site URL both say localhost:3000, and the
  spike's callback probes don't belong on production pages — two minutes
  locally beats serializing on the site agent (the deployed `/oauth/reset`
  serves REAL resets later). Also this round: **the brief's naming confirmed
  already-neutral** (routes `/oauth/…`, "suite account" copy, no app names —
  she sends it as-is); **the reset-purpose confusion cleared** (her user has
  NO password — recovery is the dashboard's only door to GIVE it one; the
  first half of stop-being-custom:fragments, whose second half — removing the
  provider — lands when the app's direct sign-in ships); Dynamic OAuth Apps
  re-confirmed OFF; `/consent.html` re-confirmed saved.

- **Round 0o (same sitting) — the residual killed by her hand; the recovery
  link dance diagnosed; the deterministic road handed over.** She killed PID
  42190 and serves `SuiteAccountSpike/` on 3000; the catcher's diagnostic path
  worked exactly as designed, reporting `#error=access_denied&error_code=
  otp_expired` verbatim. Diagnosis: a new recovery request INVALIDATES the
  prior link, Gmail's thread-bump surfaces the STALE message's link, and the
  built-in email service is itself rate-limited (a few sends/hour) — not her
  user, not the setup. Two roads handed over, the admin one recommended:
  **(1) the admin door (deterministic, no email):** she runs
  *[removed for publication]*
  her chosen password — password and service key never leave her machine;
  **(2) the magic-link door as fallback:** the catcher now accepts
  `type=magiclink` fragments too (its own OTP type — separate cooldown and a
  fresh email thread), same set-password form after. Her note recorded: **the
  stargazing.tech agent is STARTED on the pages brief** — the Site URL flip
  (localhost → stargazing.tech + `/oauth/consent`) queues behind its deploy.

- **Round 0p (same sitting) — THE MILESTONE: her suite account stands on its
  own.** Out of built-in email quota (her report: "they really mean two per
  hour on the free tier, LOL"), she authorized the architect to set a
  BOOTSTRAP password in-chat ("can I just tell you what to make my password
  and then I'll change my password later?"). Executed via the STORED-PAT
  arrangement (the 9c precedent, `.env.supabase.local`; the service key
  fetched into a shell variable and never printed): admin
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  `custom:fragments` is now REDUNDANT for her sign-in (retirement still waits
  for the app's direct sign-in code, as ordered). The password is
  transcript-known BY HER CHOICE — treated as bootstrap; she changes it at
  the deployed `/oauth/reset` page (or another admin call by her own hand);
  14b's encryption passphrase is a separate, stronger secret regardless.
  **The email-provider item ADDED at her word** — to the 14c row, not her
  floated 14d (correction explained: 14d is the severable export phase; 14c
  is where signups open and operationalia lives; her overrule welcome) —
  with her by-end-of-14 TestFlight-readiness goal recorded verbatim on the
  row. Next: the `vault_probe` scratch table (her SQL-editor paste, announced)
  → the spike run (`start.html` → consent sign-in with the new password →
  approve → callback probes P-ii + the signup-refusal).

- **Round 0q (same sitting) — `vault_probe` created by the architect's hand at
  her word; 14d renumbered 13m at her word.** Her instruction ("don't you have
  the PAT to run that SQL command yourself? go ahead and do that") executed via
  the stored-PAT arrangement: the scratch table is live on the project —
  verified `relrowsecurity = true`, exactly one policy (own-rows) — and gets
  DROPPED after the probe. **The renumber:** her challenge ("wait why is 14d
  even the severable export/PDF phase? that seems random compared to
  everything else that's in phase 14. maybe that should become a 13m or
  something?") is historically explained — the export/PDF debt rows were
  parked on OLD row 14 in the accounts era (commercial-trust/data-portability
  adjacency), and the 2026-07-30 split preserved scope boundaries without
  re-homing — and CORRECT: the material has zero accounts dependency.
  **RENUMBERED 14d → 13m** across the master plan (struck row + the new 13m
  row in the 13 family + the headline mention), both KnownIssues owner cells,
  and the release-strategy split record. The 14 family is now purely the
  accounts arc: 14a identity · 14b E2EE · 14c multi-user + tier. Next: her
  spike run (`start.html` → consent → the new password → approve → the
  callback's P-ii + signup-refusal summary).

- **Round 0r (same sitting) — THE SPIKE COMPLETES: every load-bearing unknown
  answered, all in the good direction.** Her run, end to end: the consent
  *[removed for publication]*
  trap-field present and correctly NOT navigated — the 9c traps held), her
  password sign-in, approve, PKCE code exchange **ok** — `iss` = the suite
  issuer on the Variorum project, `sub` = her uid, refresh + id tokens
  present, `amr` = `oauth_provider/authorization_code`. **The first suite
  sign-in ever taken through her own OAuth server.** Then:
  - **P-ii VERIFIED (the unknown flagged since 9c), verdict verbatim:**
    *"OAuth-issued token IS an authenticated PostgREST user; bare key
    refused/empty"* — insert 201 with `owner_id` = `auth.uid()` resolved to
    her uid; select 200/1 row; bare key 200/0 rows. **The 14b vault design is
    CONFIRMED viable as ruled** (RLS'd tables keyed on plain `auth.uid()`, no
    claim gymnastics) — and the 14c entitlement reads the same way.
  - **The signup-refusal probe (round 0j's load-bearing check) PASSED:**
    `HTTP 422 signup_disabled — "Signups not allowed for this instance"` with
    the OAuth server LIVE. Verified, never assumed. *(Code drift noted for
    the record: 9c's Gate 4 saw 403; today's refusal is 422/`signup_disabled`
    — same door, different number; do not trip on it.)* The
    first-delegated-sign-in half rides the same toggle through the shared
    create-account path (the 04-verified mechanism).
  - **`vault_probe` DROPPED** (0 remaining) — the scratch-table promise kept.
  **STATUS: the sitting's dashboard + spike work is COMPLETE.** Remaining 14a,
  all queued: the CODE batches (the direct sign-in surface · the bridge's
  delegated swap · `custom:fragments` retirement — fresh implementer + ladder
  per the discipline) · the Site URL flip at pages-deploy (the stargazing
  agent is building) · the Fragments client registration (admin door) +
  touchpoint-1 handoff · the mobile update message at the gate · her
  bootstrap-password change once `/oauth/reset` is live.

- **Round 0s (same sitting) — the site pages green-lit; Fragments' client
  registered and touchpoint #1 goes fully concrete; her identity question
  answered with evidence; the mobile-merge order settled.**
  - **P-ii explained to her** (her ask): the label for probe ii of the spike's
    two load-bearing unknowns — whether an OAuth-server-issued token is
    accepted by the SAME project's PostgREST as an ordinary authenticated user
    (`auth.uid()` resolves, RLS applies). Flagged unverified since 9c; the 14b
    vault + 14c entitlement designs ride on it; her run verified it.
  - **The stargazing agent's report REVIEWED — GREEN-LIT to push.** Quality
    noted: both 9c traps handled, the consent-race re-fetch, the sign-up door
    carrying `authorization_id` through, the reset page keeping supabase-js
    OUT of its bundle, 12 headless checks incl. 3 live backend round-trips.
    **Its one catch on the brief is CORRECT and adopted** — the reset flow
    needs `redirect_to` allow-listed, so the dashboard flip is THREE values
    (Site URL · Authorization Path `/oauth/consent` · Redirect URLs +
    `/oauth/reset`); the brief's After-deploy section corrected in this
    commit. Post-deploy verification sequence handed to her: bare
    `/oauth/consent` visit (calm error expected) → the spike re-run END TO END
    through the PRODUCTION pages (the spike client's localhost callback makes
    this legal) → then her bootstrap-password change at `/oauth/reset`.
  - **Fragments' OAuth client REGISTERED via the admin door** (no open
    *[removed for publication]*
    `client_secret_post`, redirect = Fragments' GoTrue callback; the secret
    written ONLY to her untracked `.env.fragments-oauth.local`. The contract's
    touchpoint #1 now carries the full coordinates plus **THE FIRST-SIGN-IN
    *[removed for publication]*
    link deliberately — the journals key on the old uid) and the
    Fragments-signups-toggle interaction check. **She can carry touchpoint #1
    to the Fragments agent NOW.**
  - **Her custom:fragments identity — answered with EVIDENCE, removal
    DEFERRED:** the admin read shows her user's ONLY identity row is
    *[removed for publication]*
    mint an email identity.** Removing it tonight would leave a
    zero-identity user on the account that owns her whole corpus — an
    unverified GoTrue state gambled on production auth for zero functional
    gain, since password sign-in provably bypasses identities (the 0p test).
    The badge is INERT. The removal lands with the code batch's provider
    retirement, state verified before/after (the hallucination-guard posture
    applied to auth surgery).
  - **The mobile-merge order settled (her ask): merging `mobile` → `main`
    BEFORE the 14a code batches is the BETTER order** — the auth seam
    (AuthSession/SignInFlow/ProjectConfig) is SHARED code, so one batch then
    updates both surfaces at once and the "mobile update message" deliverable
    mostly dissolves into ordinary shared-seam work. From 14a's side main is
    ready; the mobile project's own gate (the feel round + Q-M1/Q-M2 + P1–P44)
    remains hers to declare, and the merge is the mobile session's act.
  - **Her Fragments-project question sequenced:** nothing manual to do with
    her Fragments user — the link happens at the first delegated sign-in
    under the first-sign-in rule; the provider config + app flow are the
    Fragments agent's work from the contract asks; the uid check is the one
    deliberate moment.

- **Round 0t (same sitting) — the alignment round; NO CODE at her word.** Her
  corrections and questions, dispositioned:
  - **Badge timing CORRECTED to her:** the custom:fragments identity + provider
    retirement is **14a's code batch**, not 14c — 14c is signups/multi-user.
    Recorded in rounds 0s + the ruled-state banner (the single-sign-in bullet).
  - **14c robustness, answered honestly:** 14c has NO plan file yet BY DESIGN
    (every 14 phase authors its plan at its own kickoff sitting — the split's
    rule, her caveat verbatim: "some design choices will have to be assessed
    and done in that moment"). What exists is the master-plan ROW as a
    complete SCOPE LEDGER (the round-0e completeness sweep at her
    instruction), which 14a/14b findings keep appending to. Robust as a
    checklist; the design is deliberately not pre-written.
  - **Her dashboard act this round:** she "filled out the stargazing.tech
    links in BOTH the fragments and the variorum project." Variorum-side =
    the three-value flip (needs the save-reload-verify + the site actually
    PUSHED — both asked). **Fragments-side: OPEN QUESTION — exactly which
    fields?** The Fragments project needs NO stargazing URLs anywhere; its
    ONE needed change is the custom OIDC provider entry (issuer + client id +
    secret), which she confirmed she has NOT added. Its own 9c-era OAuth
    Server (as issuer) will be switched off later — **WARNING recorded: NOT
    until the 14a code batch lands** (until then the Variorum APP's only
    sign-in UI is the custom:fragments flow; a dead session + a dead
    Fragments issuer = locked out of the app, though never the account).
  - **"Allow Dynamic OAuth Apps" for Fragments: NO** — that toggle is an
    ISSUER-side setting (gates programmatic client registration on the
    project acting as OAuth server). Fragments is not an issuer in the end
    state; nothing to enable there. The Fragments client registration already
    ran on the VARIORUM side via the admin door.
  - **Touchpoint locations, pointed to precisely:** all three live in
    `notes/fragments-bridge-contract.md` under "The 14a horizon" →
    the staged TOUCHPOINT blocks (#1 with delivered coordinates + the
    first-sign-in uid rule; #2 = 14b journal-class E2EE + trim/empty-body
    relocations + the entry_date disclosure; #3 = 14c entitlement check).
  - **HER PROPOSAL, recorded as the leaning: ONE batched Fragments handoff
    after the family** ("would it be easier to just wait and tell the
    fragments agent everything it has to do after 14c? it's okay if fragments
    is broken while the 14 phases happen - that's the beauty of taking care
    of this while i'm the only user"). The architect's read: YES, cleaner —
    one coherent brief (provider + flow + her uid link + password retirement
    + journal E2EE + entitlement) beats three conversations. Consequences
    recorded with it: **(a)** the bridge stays on her Fragments PASSWORD
    session until that batch — so her Fragments password's retirement DEFERS
    to it (the 0f "no surviving password" ruling's timing moves; the ruling
    itself stands); **(b)** at 14b the journal class goes ciphertext
    Variorum-side while Fragments lags — the bridge likely PAUSES for
    Fragments until its batch (EXACTLY the die-and-return latitude she
    pre-granted at R5; the 14b sitting rules the specifics); **(c)** the
    Variorum-Mobile daily-driver ruling (the gate sitting, same day) makes a
    broken-Fragments window genuinely cheap — her phone journaling rides
    Variorum Mobile.
  - **start.html (her "smart.html"):** same as her earlier run — local server
    up, open `http://localhost:3000/start.html` — but post-flip the middle
    hop rides the PRODUCTION consent page, so it works only after the site
    agent's push is live.
  - Mobile context noted from the gate sitting's record: merge `mobile` →
    `main` precedes the code batches at a Phase 14 pause — this alignment IS
    that pause.

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
