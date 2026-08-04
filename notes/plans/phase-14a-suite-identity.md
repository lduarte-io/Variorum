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

- **Round 0u (same sitting) — PRODUCTION PROVEN; the exit criteria confirmed;
  the code gate OPENS at her word.** Her confirmations: the site is PUSHED and
  live · the three-value flip verified on reload · **mobile MERGED to main** ·
  and the `start.html` flow ran END TO END through the PRODUCTION
  stargazing.tech consent page ("it looks so cute!!") — exchange ok, suite
  issuer, her uid, tokens present. **The re-run's "P-ii NOT CLEAN" verdict
  EXPLAINED, not a regression:** the probe 404'd because `vault_probe` was
  DROPPED after round 0r's verified run, exactly as promised — the harness
  stopped-and-reported as designed; P-ii stands verified from 0r. Her
  Variorum-side stargazing URLs: kept (correct there); any added on the
  FRAGMENTS project: cleanup is now contract item 7. **The contract went
  one-batch-complete at her ask:** the EXECUTION MODEL preamble (all three
  touchpoints in ONE handoff at 14c's end; bridge paused 14b→batch, R5's
  latitude spent as designed; Variorum Mobile carries her phone journaling
  meanwhile) + the missing Supabase steps added — old-issuer shutdown with
  its NOT-BEFORE-the-14a-code-batch guard · the signups-toggle nuance
  (Fragments' global toggle ON for delegated first sign-ins; only the SURFACE
  retires) · config hygiene · the existing-rows E2EE migration (the bridge
  re-pushes from Variorum truth) · the ciphertext round-trip as the bridge's
  resumption verification. **The 14c row now pins** the one-batch handoff and
  the custom-domain-before-first-stranger guardrail (so both survive this
  file's closeout). **Her exit criteria, confirmed one-to-one:** strangers
  sign up on either app (14c + the batch's suite-pages signup flow, already
  built and wired) · one login on both (14a code + the batch) · passphrase/
  E2EE done (14b; per-user provisioning 14c) · bridge fully functional over
  ciphertext (14a swap code + 14b payloads + the batch's resumption) ·
  Supabase clean (14a's identity/provider cleanup, the batch's old-issuer
  shutdown, 14c's isolation) · email provider (14c SMTP) — **and the closeout
  ritual authors 14b's plan at this phase's gate, as standing.** Remaining
  small items named to her: her bootstrap-password change at `/oauth/reset` ·
  the spike client's deletion + spike teardown at the phase gate · the A1
  rail before 14b's mirror migration (that plan's own step). **GREEN LIGHT
  standing for batch 1 at her word** (scope: the direct sign-in surface
  Mac+mobile through the one shared seam · the bridge's delegated swap
  shipped DORMANT behind the session seam, activating at the Fragments batch ·
  custom:fragments retirement in app + identity/provider cleanup · the 9c
  auth tests updated).

- **Round 0v (same sitting) — THE PAUSE RULING; the final sweep; the code gate
  EXERCISED.**
  - **OFFICIAL, her word: ALL Variorum activity PAUSES until Phase 14 is
    done** — app usage, the Fragments journal bridge, Variorum Mobile
    development AND usage — "so that we don't have to worry about any data
    changes or loss during these delicate parts of the process." Operational
    consequences the batches inherit: no live-store contention (instance
    traps still followed, but the daily-drive pressure is off);
    `/Applications` refresh timing is flexible; the bridge can be stopped
    without ceremony; the store is quiescent for 14b's migration.
  - **Her last-chance review ("is there anything you think I have not
    considered?") answered with a genuine sweep — THREE findings, none
    blocking 14a, all pinned same-commit:** (1) **custom-domain TIMING
    refinement** — attach BEFORE the one-batch Fragments handoff so provider
    configs are written once against the final issuer URL, with the
    iss-claim verification at attachment (14c row); (2) **in-app ACCOUNT
    DELETION** — App Store 5.1.1(v) requires it wherever account creation
    exists; server-side removal intersects the tombstone-GC design (14c row;
    the 4.8 check rides beside it, likely N/A for a first-party account
    system); (3) **Fragments insights vs journal-class E2EE** — IF anything
    server-side reads `journal_entries`, encryption trades those insights
    away; a NAMED 14b sitting question now on that row. **The mobile agent's
    device-enrollment flag ADDED to the 14b row at her relay** (the phone is
    a first-class device from the design start; the restore drill enrolls
    it). With those pinned: **fully confident — GO.**
  - Standard procedures acknowledged for the batches and the closeout: test
    counts per suite at acceptance (baseline post-merge: core 1039/114 ·
    Mac 1193/208 tripwire-only · mobile 172/24 · spine 51/7 — never re-run at
    session start), the ladder, red-on-old, and the NEW mobile closeout rules
    (the MobileSoul parity-ledger line is REQUIRED at this phase's closeout —
    here it records that mobile ships the same sign-in change simultaneously
    through the shared seam, not a parity debt).

## Batch 1 — the direct sign-in & the auth-seam rework (spawned 2026-08-04)

**Goal:** the Variorum app (Mac AND mobile — merged, one shared seam) signs in
DIRECTLY to its own project with the suite email+password; the delegated
`custom:fragments` road retires from the app's sign-in; the bridge gains its
delegated session acquisition DORMANT. No dashboard changes in this batch (the
identity/provider cleanup is the gate's, after verification).

**Scope, exactly:**
1. **The sign-in surface goes direct:** replace the Variorum sign-in's
   delegated browser flow with an in-app email+password form driving the
   password grant against the Variorum project (round 0h: "the 9c AuthSession
   password grant, re-aimed"). One seam serves Mac and mobile
   (`Auth/UserSession.swift` was built to be re-pointed — use that seam, no
   sibling implementation). Keychain persistence, single-flight refresh, and
   sign-out-is-terminal semantics carry over unchanged.
2. **Session continuity — DEMOTED at her word (round 0w; the R3 best-answer
   posture applied to sessions):** the existing persisted session MAY break —
   she is fine signing in once with the new password ("it is okay if I need
   to resign in - didn't we explicitly say to not shape the code to what
   already exists?"). If continuity survives for free, fine — but write NO
   compatibility shims and NO legacy-session tests; let the cleanest seam
   design win. A one-time re-sign-in is the accepted cost (the bridge's
   Fragments password session is likewise re-mintable). Sessions are not
   data — nothing about her rows is touched either way.
3. **The bridge — REMOVED FROM SCOPE (round 0x, her catch):** the dormant
   delegated road is NOT built in this batch — it was premature (flag-gated
   inert code that cannot run against a real provider until the Fragments
   batch; it moves WHOLESALE to that era, built and tested against the live
   provider). The bridge's existing code (engine + shape-(c) password
   session) stays UNTOUCHED **by default, not by requirement**: her Phase-14
   pause means bridge USABILITY is not required — if the cleanest seam rework
   touches bridge call sites, that is allowed; the bar is only that the
   module keeps compiling and its existing suites stay green (no corrupt
   half-states). Full rip-out was considered and DECLINED: deleting settled,
   tested machinery that returns at the Fragments batch buys no design
   freedom the pause doesn't already grant.
4. **custom:fragments retires from the CODE:** the Variorum sign-in no longer
   references the provider. The SignInFlow/ASWebAuthenticationSession
   machinery is no longer needed by ANY active path — the implementer may
   retire it or leave it, whichever the cleanest seam favors (its hard-won
   lifecycle fixes are documented in the 9c plan if it returns at the
   Fragments batch). `ProjectConfig` keeps both projects' coordinates (the
   bridge code still compiles against Fragments').
5. **Tests:** the 9c auth suites updated to the direct shape; red-on-old pins
   for each behavior change; ALL suites green at acceptance (baselines
   above). Zero `Sync/` lines expected — any need to touch
   `Sources/VariorumCore/Sync/` is a stop-and-report.

**Environment traps (the plan's standing list binds):** instance checks by
bundle id/PID; Mac tests via the cwd-independent `-project` invocation,
suite-level `-only-testing`; no custom build configurations; the mirror is
LIVE — this batch touches NO server config; commit + push at bout ends;
schema: NONE (marker stays 4).

**Acceptance:** she can sign OUT and back IN with email+password on the Mac
app (and the mobile sign-in surface compiles/tests to the same seam) — a
one-time re-sign-in after the update is acceptable, per scope item 2 as
amended; suites green (including the untouched bridge module's existing
suites); red-on-old pins verified both directions.

- **Round 0w (same sitting, mid-batch-1) — her R3 catch: session continuity
  DEMOTED.** Her words: "it is okay if I need to resign in - didn't we
  explicitly say to not shape the code to what already exists? that
  contortions are unneeded since the only user inconvenienced is me?" —
  CORRECT, and the architect's continuity pin was exactly the contortion
  class R3 bans (it could have forced compatibility shims around the legacy
  session's shape instead of the cleanest seam). Batch 1's scope item 2 and
  acceptance amended in place (no shims, no legacy-session tests, one-time
  re-sign-in accepted; sessions are not data); **the amendment was ALSO sent
  to the running implementer via SendMessage AND mirrored here same-turn**
  (the verify-subagent-message-delivery rule — the repo record is the
  authority if the message drops).

- **Round 0x (same sitting, mid-batch-1) — her second catch: the bridge is
  not a constraint, and the DORMANT ROAD was the actual contortion.** Her
  question: "there's no contortion being done around the fragments bridge
  staying usable, right? because it can be fully ripped out right now."
  The architect's honest answer, recorded: keeping the bridge's existing
  code untouched is the DO-NOTHING option (settled, tested machinery her
  pause leaves idle) — no contortion there. The contortion-adjacent piece
  was scope item 3 itself: building the delegated road NOW, flag-gated and
  inert, unable to run against a real provider until the Fragments batch —
  premature work done to say the transition "started." **CUT from batch 1;
  it moves wholesale to the Fragments-batch era** (built and tested against
  the live provider). The bridge's status pinned precisely:
  untouched-BY-DEFAULT, never kept-usable-BY-REQUIREMENT — if the cleanest
  seam rework touches bridge call sites, allowed; the bar is compiling +
  existing suites green (no corrupt half-states). **Full rip-out considered
  and DECLINED with reasoning:** deleting settled machinery that returns at
  the Fragments batch buys no design freedom the pause doesn't already
  grant — the best answer, not the most dramatic one. SignInFlow/ASWeb
  machinery relaxed to implementer's judgment (no active path needs it).
  Amendment sent to the running implementer AND mirrored in the brief
  same-turn (the delivery-verification rule). Batch 1 is now smaller and
  cleaner: direct sign-in · continuity-may-break · provider out of the
  sign-in code · tests.

- **Round 0y (same sitting) — the context-window plan + the ideal-final-shape
  sweep.** Her flag: the session is at ~500k (her standing cutover rule).
  **The honest answer, recorded: this is a MAJOR phase — the ladder + gate +
  closeout + the 14b draft do not confidently fit in ~150k.** The cutover is
  made near-free NOW: **`notes/plans/phase-14a-architect-handoff.md`
  written** (read-first list, live state, the remaining work in order, gate
  steps, standing cautions), and the running implementer instructed to write
  its report INTO the plan file committed+pushed (so a fresh architect can
  receive it even if the message channel is lost). Plan: this session
  receives and adjudicates batch 1's report if it lands within budget; the
  ladder + gate + closeout run in a fresh architect session from the handoff
  at the natural seam. **The sweep of 14b/14c/contract/strategy/KnownIssues
  for allowances-to-what-exists:** mostly already ideal-shape (the 14c row's
  enumeration, the guardrails, the contract's execution model, the
  release-strategy records — all confirmed clean). TWO real findings, fixed
  same-commit: **(1)** the 14b row now carries the consistency note (the
  Fragments END of journal E2EE is DESIGNED at 14b, EXECUTED in the one
  batch) **and the wipe-and-repush candidate** — R3 applied to her mirror's
  migration: local SQLite is truth, the mirror is a peer, one active device —
  re-initializing through the new encrypted serializer may beat migration
  machinery entirely (the 14b sitting rules it, server_seq/cursor
  implications weighed); **(2)** the contract gained a READ-THIS-FIRST
  pointer so the Fragments agent lands on the operative EXECUTION MODEL
  blocks, never the superseded TestFlight-era layers above them.

- **Round 0z (same sitting) — the cutover RULED and staged.** Her word: the
  cutover happens after batch 1's implementer returns to THIS session — the
  sitting architect adjudicates and records, then a fresh architect continues
  from the handoff. Her floated shape (rulings handed to a new implementing
  session that verifies-and-rechecks, then continues as implementer) accepted
  WITH one refinement, offered and taken: the verify-and-recheck role is the
  COLD REVIEWER per the standing ladder (independence is what makes the
  recheck worth anything); a fresh IMPLEMENTER applies confirmed fixes. **The
  paste-ready kickoff message for the fresh session is written INTO the
  handoff file** (`notes/plans/phase-14a-architect-handoff.md` — repo-first,
  so the message survives this chat) and delivered to her in-chat verbatim.
  Remaining for THIS session: receive batch 1's report → adjudicate → record
  the adjudication under the batch section → update the handoff's live-state
  if anything shifted → hand her the go-to-paste word. Her close, recorded
  because it is the sitting's truth: "It's been a genuinely useful sitting -
  we've made huge progress in just a few hours this evening."

### Batch 1 — implementer report (ARCHITECT-RECORDED: the implementer session
### died after its implementation commit, before writing this section)

- **Implementation: COMPLETE and pushed — commit `5082a51`** (plus the
  SignInFlow.swift deletion that rode docs commit `0fd1314`, confirmed
  intentional). The implementer's final status, verbatim substance: both 9c
  auth suites green (22 tests); the retirement-walk pin verified BOTH
  directions (red-on-old: **10 issues on the pre-batch tree**, green after).
- **What shipped** (from the commit + diff): `AuthSession` slims to the
  direct core — `AuthConfiguration` = projectURL+apiKey; the PKCE/authorize/
  exchange doors and the captured provider-token pair retired WHOLESALE
  (they return at the Fragments batch, built against the live provider);
  `SignInFlow` deleted (the implementer's judgment under amended scope item
  4); `AppServices.signInWithVariorum` replaces `signInWithFragments`;
  `AccountView`'s Variorum section is the email+password form (Return-key
  doors, iOS email-field hygiene — the merged mobile surface rides the same
  seam); the bridge's shape-(c) password road byte-untouched. NEW tests: the
  retirement walk, the direct-sign-in wiring pin (account/adoption/sync
  chain), password-grant coverage incl. refusal and no-user-id arms.
- **Files:** AppServices, AuthSession, AuthViews, ProjectConfig,
  AuthSessionTests, Phase9cAuthWiringTests (+ SignInFlow deleted) — net
  −25 lines. Zero `Sync/` lines; no schema; no server config; no bridge
  engine files.

### Batch 1 — architect adjudication (2026-08-04, pre-cutover)

- **Acceptance runs — THE ARCHITECT'S OWN, all four suites, ALL AT BASELINE:**
  core **1039/114 PASSED** · Mac **1193/208, 1 issue = the standing
  TakePaneMeasureTests tripwire CONFIRMED BY IDENTITY** (re-run in isolation:
  `aStrandedRenderTierIsRebuiltByAConvergenceOccasion`, the recorded
  environment-gated red) · mobile **172/24 PASSED** (iPhone 17 Pro sim) ·
  spine **51/7 PASSED** (the seven Tutorial suite TYPE names).
- **Scope compliance verified against the diff's file list:** every changed
  file in the app auth layer + its tests; the amended scope held (no dormant
  road built; bridge untouched; continuity shims absent by design).
- **DISPOSITION: batch 1 ACCEPTED at the architect level** — subject to the
  cold-review ladder, which is the fresh architect session's first act. Items
  the ladder should weigh with fresh eyes: the AuthSession slimming's
  completeness (does anything still reference the retired doors);
  AccountView's refusal wording under the registry discipline; whether the
  retirement walk's 10 red-on-old issues span the meaningful surface or
  cluster; the wiring pin's chain coverage. NOTE for the gate: whether her
  live session survived the seam rework is UNKNOWN and IRRELEVANT by round
  0w — the gate's acceptance is her signing out and in once with
  email+password on the refreshed build.

## The fresh-architect session (2026-08-04 — post-cutover: ladder → gate → closeout)

- **Author ruling, mid-ladder (recorded for the closeout step):** the plan-file
  sections that exist ONLY because of the mid-phase handoff — "what the
  implementer said and the rulings on the implementer's work" — are removed at
  the phase's end for repo hygiene, "only the typical notes kept." Executed at
  closeout: the architect-recorded implementer report + the pre-cutover
  adjudication section condense into the standard batch record; the ladder's
  findings/dispositions (typical notes) stay.

### Cold-review ladder — ROUND 1 (2026-08-04; fresh Fable reviewer,
### REVIEW_PROMPT verbatim, zero implementation context)

**Verdict: NO BLOCKER, NO MAJOR — 3 MINOR + 2 NIT.** The pre-cutover
adjudication's four weigh-items were all addressed explicitly (clean bill
below). Findings + architect dispositions (adjudicated against the spec docs;
no disputes — the implementer session is dead, so dispositions are
architect-direct):

| # | Sev | Finding | Disposition |
|---|-----|---------|-------------|
| R1-1 | MINOR | `AppServices.swift:228` + `AuthViews.swift:126–128` — the wrong-password refusal (now the sign-in's COMMON failure path under the direct form) surfaces as a raw Swift enum dump (`String(describing:)` of `endpointFailure` w/ 400 `invalid_grant`), bypassing the R94 classify-and-speak doctrine; `ErrorCauseNote`'s existing guidance would be WRONG here ("sign out and back in") | CONFIRMED — fix: classify the sign-in failure path; the credentials class (400/`invalid_grant`) surfaces **"Wrong email or password."** (PROVISIONAL wording — her ratify rides the gate checklist); other classes get readable lines, never a raw dump. Red-on-old pin: scripted 400 → the mapped message. |
| R1-2 | MINOR | `AuthViews.swift:137` — `.frame(minWidth: 440)` clips the sign-in form on iPhone sheets (~393 pt proposes, 440 forced → ~24 pt cut each edge): the exact surface the phase's mobile deliverable rides (round 0m "sign in from her phone"; 0s dissolved the mobile message into this seam). Pre-existing (9c Mac-only era), promoted by this batch's role change | CONFIRMED — fix: platform-gate the frame (`#if os(macOS)`, the file's existing pattern). Layout class: mechanism traced, no unit pin constructible (the guard's no-pin justification, recorded here) — verification is the PHONE half of the gate walk. |
| R1-3 | MINOR | `Phase9cAuthWiringTests.swift:403–405` — the retirement + paste-in walks scan only `Shared/`'s TOP level (`contentsOfDirectory` is shallow; `Shared/` now has three Swift-bearing subdirs) — a reintroduction under a subfolder evades the walk while its message claims the shared sources are clean. Today's tree verified clean repo-wide | CONFIRMED — fix: deep enumerator (`FileManager.enumerator(at:)`). Test-only strengthening; no red-on-old owed. |
| R1-4 | NIT | `Phase9cAuthWiringTests.swift:170/:308` — the wiring pin's doc comment says "the retirement walk above" (the walk sits ~230 lines BELOW); the pre-existing retirement-walk MARK dangles over the 13c lifecycle section | CONFIRMED — comment + MARK placement fix. |
| R1-5 | NIT | `AuthViews.swift:87, 142–152` — the new credential fields carry no `.textContentType`, so iOS AutoFill/keychain suggestions won't offer credentials on the phone door (AutoFill is function, not styling) | CONFIRMED — fix: username/email + password content types (platform treatment implementer's judgment). |

**Clean bill (the reviewer's, condensed):** slimming completeness verified
repo-wide (zero live references to any retired door — PKCE/authorize/exchange/
provider-pair/SignInFlow/ASWeb/custom:fragments — outside comments and the
walk's own assertion strings; `callbackWithoutCode` gone; CryptoKit import
dropped; no URL-scheme leftovers). The retirement walk's red-on-old
INDEPENDENTLY verified against the true pre-batch tree (`0fd1314^`): exactly
10 issues spanning all five auth files — spans the surface, not clustered.
The wiring pin's chain is real (account state → the Step 4 `owner_id`
adoption through the production runner path → sync composition → an actual
transport round). Both changed suites re-run by the reviewer: 22 tests, 2
suites, passed. Scope compliance under the 0w/0x amendments (no dormant road,
no shims, no legacy-session tests; bridge shape-(c) byte-untouched; zero
`Sync/` lines; no schema; no server config; ProjectConfig keeps both
projects' coordinates; the two-form AccountView is CORRECT per 0t/0x — not
drift). Continuity survives un-shimmed for free (the pre-batch Keychain blob
decodes under the slimmed `AuthTokens`; a nil load is a clean signed-out
launch, never corruption). The 9c hard-won machinery intact and pinned
(single-flight refresh, sign-out-is-terminal, fail-visible refresh, the A4
dev-store fence, LegacyPasteInCleanup). The signups-off precondition carried
forward and strengthened in ProjectConfig's header. Keychain hygiene holds
(password never persisted; no-user-id refuses before any save; distinct
services).

**Route: all five findings → ONE fresh implementer session (the cutover
ruling's shape — a fresh implementer applies confirmed fixes); ROUND 2
re-reviews the fixes with a fresh reviewer.**

**FIX RECORD (fresh implementer, 2026-08-04 — commit `35062b2`, verified
against the diff by the architect):** R1-1 = new
`ErrorPresentation.signInFailureMessage(_:)` in the R94 doctrine's home
(credentials class → "Wrong email or password." [PROVISIONAL, gate ratify];
transport → connection line; unexpected-status/malformed → readable frames;
never a raw dump; `ErrorCauseNote` deliberately NOT reused — its guidance is
wrong on the sign-in form, recorded in the doc comment), wired into BOTH
`AppServices` password-grant catch blocks (the Fragments connect door shares
the identical 400 mechanism — half-fixing one of two byte-identical sites
declined); **red-on-old pin `aWrongPasswordRefusalSpeaksTheHumanLine`
VERIFIED both directions by behavioral revert** (red on the reverted catch:
the raw `endpointFailure(status: 400, …invalid_grant…)` dump surfaced
verbatim ≠ the mapped string; green restored) plus an other-classes
readable-lines test. R1-2 = the `minWidth: 440` floor macOS-gated (postfix
`#if`, mechanism comment). R1-3 = both walks deep via
`FileManager.enumerator` with a depth self-check so the walk can never
silently go shallow again. R1-4 = comment direction + MARK placement fixed.
R1-5 = `.textContentType(.username/.password)` (platform-resolved, no gate
needed). Acceptance: AuthSessionTests + Phase9cAuthWiringTests = **24 tests
in 2 suites passed** (22 baseline + the 2 new); `VariorumMobile` BUILD
SUCCEEDED (iPhone 17 Pro sim); zero `Sync/` lines; no schema; no server
config; bridge untouched. Recorded-not-touched (the implementer's honest
list): `runOwnerAdoption`'s raw `\(error)` interpolation (same cosmetic
family, out of the findings' scope, and its established-session guidance is
correct there); `AuthSessionTests`' refusal tests still assert the typed
throw (correct — classification is the presentation layer's).

### Cold-review ladder — ROUND 2 (2026-08-04; fresh Fable reviewer, anchored on
### round 1's recorded findings + dispositions + fix record)

**Verdict: EVERY ROUND-1 DISPOSITION HOLDS — zero new BLOCKER/MAJOR. THE
LADDER CLOSES AT ROUND 2** (round 3 is owed only on new HIGH findings). The
reviewer re-derived every mechanism itself: the R1-1 pin's red-on-old
re-verified by ITS OWN behavioral revert (raw dump surfaced verbatim on the
reverted catch; green restored; tree byte-clean at exit); both suites re-run
(24 tests / 2 suites passed); VariorumMobile rebuilt green; scope compliance
re-swept across all three commits (zero `Sync/`, no schema, no server config,
bridge byte-untouched); the retired-token sweep found only two benign
residuals (a provenance comment in CommitBar; the bridge's pre-existing
CryptoKit content hashing — unrelated to auth); continuity-for-free re-proven;
the 9c machinery and the production wiring chain (`AppBootstrap` installs
`OwnerIdentity` over the same Keychain service — her `owner_id` survives by
construction) confirmed.

Post-cap residuals (the 13k precedent — fixed post-cap, recorded here):

| # | Sev | Finding | Disposition |
|---|-----|---------|-------------|
| R2-1 | MINOR | The R1-1 PROVISIONAL wording ratify ("Wrong email or password.") is promised to "ride the gate checklist" but no gate checklist or QUESTIONS.md entry carries it — the drop-at-the-gate risk is the exact failure class the PROVISIONAL rule exists to prevent | CONFIRMED — fixed by the architect same-commit: the ratify line added to the handoff's gate step 3; it also rides the closeout handoff's author checklist. Docs-only. |
| R2-2 | NIT | The R1-1 pin scripts only the legacy GoTrue refusal dialect (`{"error":"invalid_grant"…}`); the mapper also covers the modern `error_code: "invalid_credentials"` dialect but no test asserts that arm — which dialect her live project speaks is verified only at the gate's live walk | CONFIRMED — one extra scripted-body arm asserting the same mapped line; routed to the round-1 fix implementer session (test-only, no red-on-old owed). **DONE — commit `81eca37`** (verified test-only, 19 insertions): sibling test `aModernDialectRefusalSpeaksTheSameHumanLine` scripting the modern body (`error_code: "invalid_credentials"`, no `invalid_grant` anywhere) through the same door, asserting the same mapped line + nothing-signed-in; wiring suite 14 tests green. |

### Phase-final acceptance (2026-08-04, post-ladder — the architect's own runs)

- **Mac: 1196 tests in 208 suites — the ONE issue is the standing
  `TakePaneMeasureTests.aStrandedRenderTierIsRebuiltByAConvergenceOccasion`
  tripwire, BY IDENTITY** (the recorded environment-gated red; 1193 baseline
  + the ladder's 3 new tests = 1196, exact).
- **Mobile: 172 tests in 24 suites PASSED** (iPhone 17 Pro sim) — at
  baseline, with the ladder's shared-seam `AuthViews`/`ErrorPresentation`
  changes compiled in.
- **Spine: 51 tests in 7 suites PASSED** (the seven Tutorial suites, run
  dedicated).
- **Core: 1039/114 stands from the batch-1 acceptance run** — provably
  untouched since: `git diff 5082a51..HEAD -- Sources/ Tests/ Package.swift`
  is EMPTY (every post-batch commit touches `App/` + `notes/` only). Zero
  `Sync/` lines phase-wide; no schema (marker stays 4); no server config
  from any code session.

### THE GATE (2026-08-04 — announced steps, her explicit go per step)

- **Step 1 — `/Applications` refresh: DONE at her go.** Instance check clean
  (pgrep, twice); Release build from `main` @ `1cff66a` (isolated
  DerivedData, BUILD SUCCEEDED); the product replaced
  `/Applications/Variorum.app` (installed 01:58, signed,
  `io.lduarte.Variorum`).
- **Step 2 — her live acceptance: PASSED.** Her words: "signing in works and
  the wrong email popup works as well" — sign-out → suite email+password
  sign-in on the refreshed build, plus the wrong-password arm seen live.
  **R1-1's PROVISIONAL wording "Wrong email or password." treated as
  RATIFIED on that report** (her word invited if she wants different text).
  Mid-step observations, both dispositioned in-chat: the AccountView's
  Fragments-journal row SURVIVING is correct per 0t/0x (the bridge's
  machinery is Variorum-side and stays; only its session-minting swaps to
  delegated at the 14c-end batch era, when the two-form surface collapses
  into one flow per 0i); and her bridge DISCONNECT was her own click
  (confirmed, her words: "i clicked disconnect myself"), not a sign-out
  coupling — independently verified in code before her confirmation:
  `signOutVariorum` touches only the Variorum session
  (`AppServices.swift:235`), `disconnectFragmentsJournal` is its own door
  (`:307`), distinct Keychain services. Nothing lost (a session credential
  only; reconnect = one password entry until the batch era, delegated
  after).

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
