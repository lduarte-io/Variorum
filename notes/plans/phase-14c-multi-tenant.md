# Phase 14c — Multi-tenant hardening & the paid tier — plan

> **Status: OPEN — the design sitting RAN 2026-08-04 (author-attended,
> same day as 14b's close). All seven staged questions RULED plus two
> she added mid-sitting; rulings recorded verbatim-faithful below. Cast
> ALL-FABLE at her pick. THE ONE-BATCH FRAGMENTS HANDOFF MOVED to new
> micro-phase 14d at her ruling — 14c closes without waiting on
> Fragments. This file is the phase's ONE running record.**

## Kickoff message (as run — historical; the sitting it staged is below)

You are the architect for Variorum Phase 14c (repo ~/dev/variorum,
branch main), under `/architect-phase` discipline (the skill file
governs; CLAUDE.md binds; cast decided at this kickoff as always). The
phase opens with the AUTHOR-ATTENDED design sitting this file stages.
READ FIRST, in order: (1) this file in full; (2) the master plan's 14c
row — the scope ledger's letter — and the 14b closeout paragraph above
it; (3) `notes/plans/phase-14b-suite-e2ee.md`'s THE DESIGN + the CF
ledger + "HER ACCEPTANCE" sections (what the vault, seam, and flows
ARE); (4) `notes/handoffs/phase-14b-handoff.md` (standing facts, never
re-derive); (5) `notes/fragments-bridge-contract.md`'s EXECUTION MODEL
*[removed for publication]*
(7) `notes/sync-postmortem-fragments.md` before ANY
`Sources/VariorumCore/Sync/` line. STANDING: the mirror is LIVE
production (announced changes only, committed artifacts, her explicit
go, the A1 rail); the signups-off toggle is THE corpus guard and flips
ONLY as this phase's own deliberate act, after isolation; her
Variorum-usage pause status is HERS — ask, never assume.

**FRAMING NOTE (binding on every subagent brief — the 14b cutover's
lesson, recorded so it cannot repeat):** this phase's subject matter is
security-shaped end to end — per-user isolation, account deletion, key
rotation, credential flows. A message discussing it WITHOUT its product
frame can trip model-routing safeguards mid-phase (it moved the 14b
orchestrator seat off Fable). Mitigation: LEAD with the frame — this is
the author's own app (Variorum), the work is its multi-tenant account
system for her own users, and the rulings are recorded in this repo.
Prefer "the user's isolation boundary", "the account's deletion story"
over bare verbs.

## The binding principles

The 13b constitution (P-1…P-9) binds per the `/architect-phase` skill,
which holds the byte-verbatim text and the application precisions —
copied by reference, exactly as 14b did. Phase-specific names inside
the rules are their provenance; the rules are general and BINDING here.

## Preflight findings (the architect's, before the sitting)

- **The "EIGHT non-owner tables" count is the 9c-era letter, now
  stale:** `reading_section` (Phase 13) and `lens_choice` (Phase 11a)
  arrived ownerless after 04_auth_rls.sql's header was written. The
  true count is **TEN** ownerless mirror tables — variant,
  commit_point, edge, container_block, reading_post, reading_section,
  post_tag, block_tag, lens_choice, setting — beside the EIGHT
  owner-carrying ones (container, block, reading, tag, reference,
  canvas_layout, lens, block_comment). Relayed at the sitting; the
  design below counts ten.
- The Swift fake server cannot execute Postgres policies — whatever
  isolation mechanism is chosen, the fake EMULATES its semantics and
  the REAL Postgres truth is proven by the integration pass + the live
  probes. Stated at the sitting; folded into the proof bar.

## THE DESIGN SITTING (2026-08-04 — author-attended; rulings recorded
## same-turn, verbatim-faithful; question-tool batches ≤4)

### Round 1 — process & posture (option-label picks, no free text)

- **Cast: ALL-FABLE** (orchestrator · fresh implementer per batch ·
  fresh cold reviewer per ladder round) — the recommended option,
  matching 14b's executed cast and the standing Sync/ rider.
- **Her Variorum-usage pause: "Keep it through 14c"** — one active
  writer until the family closes; the simplest window for the
  lockstep/rebuild work and the re-key door's live testing. The pause
  remains HERS; this ruling is its 14c status, not its end-state.
- **Purchase channel: WEB-FIRST** — the tier sells on stargazing.tech;
  the apps sign into the account and read the entitlement (the
  multiplatform-services pattern). IAP addable later without rework.
  Current steering/external-link rules get verified at build time by a
  lookup agent, per the recorded caveat.
*[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*

### Round 2 — the isolation core (three ruled; one became Rounds 3–4)

- **Isolation mechanism — her free-text reply, verbatim:** *"i think
  server stamped owner is probably fine, but is RLS-native rewrite
  significantly better in some aspect? because the truth is that i'm
  the only user, so if there was ever a time for redoing the whole
  thing for a \*truly correct\* solution, it is right now"* → answered
  honestly at Round 3.
- **`setting` redesign: MIRROR-ONLY scoping** — composite identity
  (owner_id, key) server-side; the RPCs scope every setting read/CAS
  to the caller; owner stamped and subtracted server-side; the local
  schema and app untouched (a device's store is one user's by nature).
  *(Subsumed by Round 4's clean rebuild — the composite key becomes
  the table's real PK, no special case; the local-side-untouched half
  of this ruling stands.)*
- **The proof bar: HARNESS + LIVE PROBE + EXTRA REVIEW** (the
  strongest option): TWO-USER convergence suites in the Phase 5
  harness (each user's fleet converges independently; zero cross-user
  rows through both RPCs; repairs stay inside the partition; a
  stranger's corpus exactly as unreadable as hers) PLUS a live probe
  against production with a real, deliberately provisioned second
  account (uid-checked per the 14b near-miss lesson) that must see
  zero of her rows through both doors PLUS a dedicated extra
  cold-review round focused solely on the isolation boundary, beyond
  the phase's standard ladder.
- **CF-8's stale-writer fence: the VAULT-KEY-ID FENCE** — every sync
  round carries the caller's active key id; the server compares it
  against the account's current `key_vault` row — mismatch refuses the
  round with the keys-were-replaced state (CF-16's honesty, enforced
  server-side). The re-key door writes the NEW vault first, so every
  stale writer is fenced before the truncate runs. Structural fix for
  the whole stale-key class, not just the re-key window.

### Round 3 — the RLS answer + her mandate widening (mid-sitting
### message, verbatim)

The architect's honest answer, relayed: RLS-native is significantly
better in exactly ONE aspect — the boundary enforced by the database
engine itself, fail-closed (a forgotten filter returns zero foreign
rows instead of leaking; the same philosophy as the app's DB-enforced
invariants). It does NOT change CAS/merge/horizon, still needs owner
columns (parent-join policies are the slow knotted road), and the fake
server can't execute policies either way. The best-of-both shape
offered: keep the battle-tested SECURITY DEFINER RPCs with explicit
guards AND add per-table policies with **FORCE ROW LEVEL SECURITY**
(binds policies even on definer functions; `auth.uid()` reads the JWT
GUC, so it works inside them). **Her pick: the HYBRID.** One build-time
caveat pinned: verify empirically that the hosted `postgres` role
carries no BYPASSRLS (the live probe proves it).

**Then her mid-sitting message, verbatim — the mandate widening:**
*"I just want to make sure that we're doing the absolute best long
term, architecturally sound, me in 2 years will be happy about it
choice possible. things are so fluid right now that it wouldn't be a
problem to delete every table and make them again - I didn't really
even know the tables weren't set up for multi user until we got to
phase 14. So, keep that in mind. What is genuinely best?"*

*(Reassurance recorded with it: the schema DID plan for multi-user —
S4's owner_id on top-level entities was day-one; the child tables were
deliberately deferred to the accounts phase. This is the planned seam
arriving, not scars.)*

### Round 4 — THE CLEAN REBUILD RULED (the genuinely-best answer)

The design space walked honestly: schema-per-tenant /
database-per-tenant rejected (strongest namespace isolation, but every
migration and lockstep event multiplies by tenant count forever —
operationally hostile for a solo maintainer); client-protocol changes
rejected (multi-tenancy is a server-side scoping concern by the
architecture's own design). **Her ruling: CLEAN REBUILD** — drop and
recreate the 18 data tables BORN multi-tenant:

- **owner_id NOT NULL inside a composite primary key (owner_id, id)** —
  (owner_id, key) for `setting`, no special case. Another account's
  rows aren't guarded away — they're structurally UNADDRESSABLE: every
  lookup is tenant-scoped by the table's own identity; cross-tenant id
  collision becomes impossible rather than improbable.
- Composite PKs are FREE here precisely because the mirror has NO
  foreign keys by design (the repair architecture requires the
  constraint-free mirror) — the usual children-carry-the-key cost
  cannot exist.
- **(owner_id, server_seq) indexes** — each user's changefeed reads
  off its own index.
- Forced-RLS policies + the explicit RPC guards ride on top (Round 3's
  hybrid, now on born-clean tables). Two independent enforcement
  layers; a bug must get through both.
- Zero client-side changes for ownership itself — owner is stamped and
  subtracted server-side for the ten; the eight owner-carrying tables
  keep their client-carried owner_id + the existing validate-equals-
  caller guard.
- The window that makes it a small act: her corpus re-pushes from
  local truth through the proven runner (the 14b road, run twice); the
  phone re-onboards once, as at 14b.

### Round 5 — lifecycle & choreography

- **Account deletion: IMMEDIATE HARD PURGE — her pick, with her
  question verbatim:** *"immediate hard purge - but this won't delete
  the user's work locally, right?"* **ANSWERED: correct — local copies
  SURVIVE.** The purge touches only the server: the account's rows
  across the 18 data tables, the `key_vault` row, entitlement rows,
  and the auth user. Every device's local SQLite is untouched and the
  app keeps working locally (the signed-out state reads as normal —
  the standing v1 principle). **PINNED as the door's copy rule (the
  CF-6 class): the deletion copy must say the local copy survives.**
  Friction: typed confirmation naming the consequence + the encryption
  passphrase as authorization; subscription cancellation
  handled/warned first.
- **The 14a re-decide checkpoint: CLOSED — the VARIORUM PROJECT STAYS
  the suite's account home** (the recommended option; the one look-back
  14a left is now spent). The custom domain fronts it as the public
  face before the first stranger.
- **The signup door choreography: the PROPOSED ORDER ruled** —
  (1) isolation built + two-user harness green + the dedicated
  isolation review round; (2) the clean-rebuild lockstep deploy + her
  repush; (3) her live probes with the provisioned second account
  (stranger-sees-zero); (4) custom domain attached + `iss` verified;
  (5) entitlement/tier machinery in place; (6) signups ON — the
  deliberate flip; (7) stranger-onboarding validation (fresh account,
  empty-store first pull reads as normal, vault setup); (8) —
  *amended by the next ruling* — the phase CLOSES; the Fragments batch
  becomes 14d. The door never opens before isolation is proven AND the
  tier can gate hosted sync.
- **The one-batch Fragments handoff: MOVED TO NEW MICRO-PHASE 14d —
  her ruling, verbatim:** *"let's let this phase close out (I won't
  want to delay closing out and all of those tests just for fragments
  because there's some UI refactoring work going on there right now).
  it can be 14d (we don't have a 14d anymore, right?) micro phase to
  validate that the bridge still works - will there even be any code
  changes related to variorum when we're verifying that? probably not,
  right? the issue is more just bringing it to fragments and running
  verification later that it worked? Let me know if there's a more
  active fragments consideration."* **The architect's answers,
  recorded:** (a) yes — the 14d number is free (old 14d was renumbered
  13m 2026-08-03); (b) mostly right, but a SMALL real Variorum-side
  act exists: the bridge's journal-class capability shipped
  STRUCTURALLY PAUSED behind a refusing key provider (14b L11), so 14d
  wires the live journal-bridge key provider, runs the staged re-push
  from truth (her historical days arrive encrypted — also what ends
  the legacy-plaintext era on the satellite), and verifies the full
  round-trip over ciphertext — micro-phase-sized, not zero; (c) the
  active considerations are sequencing facts, not code: the old
  Fragments-side issuer can be switched off at 14d with no Variorum
  dependency (14a's direct sign-in already shipped), and the
  entitlement shape must be stable before Fragments builds its check —
  14c ships it. The custom-domain guardrail HOLDS under the split: the
  domain attaches at choreography step (4), inside 14c, so 14d's
  provider configs are written once against the final issuer URL.

### Round 6 — her gate-readiness + the 14d-prep ruling (mid-phase
### message, 2026-08-04; recorded verbatim)

Her words: *"what is waiting on me? please elaborate on the deploy,
live probes, domain / SMTP steps, and signup flip. I'm ready to give
whatever explicit go or whatever other support is needed. and good to
know that there's going to be a couple last variorum changes at 14d -
i think we should do whatever we can but still not gate on fragments
being done."*

Recorded: **(a)** her gate readiness — the gos come at the gate in the
ruled order; nothing is hers before batches 1–3 + the ladder + the
isolation round complete (the elaboration of each gate step was given
in-session; the gate section of "The batches" is the binding text).
**(b) THE 14D-PREP RULING: the Variorum-side 14d code is BUILT IN 14c,
DORMANT** — the live journal-bridge key provider (the 14b Keychain
custody seam) and the staged re-push-from-truth machinery land in
batch 2, pinned but behind the STANDING structural pause, which
remains the default until 14d's deliberate act. 14d's Variorum half
reduces to the un-pause + the staged re-push run + the round-trip
verification — so 14d gates on nothing but the Fragments conversation
itself, exactly her intent.

### Round 7 — her return after the session-limit break (2026-08-05;
### the batch-3 implementer had died at her limit BEFORE any work —
### verified: zero commits, clean tree; respawned fresh this round)

Her message, verbatim: *"hi, you can go ahead and continue your work.
you may have to restart a new implementer session - i hit my 5 hour
limit and the implemeneter might just be gone completely or it might
be recoverable. i'm also ready to do the deploy step whenever and I
*[removed for publication]*
second account. I can look at cloudflare for whatever you need for the
domain step. if this is just for users having an account / logging in
at stargazing.tech I think account makes more sense? or is it for
*[removed for publication]*
*[removed for publication]*
*[removed for publication]*
*[removed for publication]*
wasn't sure how much of this is direct code changes - I'm contemplating
moving the SMTP into the same 14d phase as fragments due to this
*[removed for publication]*
*[removed for publication]*
and you can drive the live probes and the deploy. i can type my
passphrase into the runner as needed. let me know on what remains in
this phase and what we should do"*

**Recorded and ruled:**

*[removed for publication]*
  joins the gate runbook (L13); admin-provisioned, uid-checked,
  entitlement-granted per the batch-1 hold.
- **DNS is Cloudflare** — exact records handed to her at the domain
  step.
- **THE ISSUER HOSTNAME RULED: `auth.stargazing.tech`** (her pick
  after the it's-not-billing clarification: the domain fronts the
  AUTH SERVICE/issuer — tokens' `iss`, OAuth discovery, auth-email
  links, both apps' + Fragments' provider configs; the sign-in/consent
  PAGES and the future checkout are ordinary stargazing.tech content,
  no special domain work). Her changeability question answered on the
  record: the SITE is always freely changeable; the issuer SUBDOMAIN
  is changeable too — a coordinated config update (both apps, the
  Fragments provider entry, re-verification; old email links die,
  sessions re-mint) with NO data migration ever — cheap now, more
  coordination once third-party configs reference it. It is the one
  hostname to treat as long-lived.
- **SMTP's config ACT MOVES TO 14d — ratified** (her size concern +
  the honest input: zero code, ~30 minutes of dashboard config, and
  its only hard deadline is real email volume, which arrives with
  TestFlight — already 14d-gated). 14c still ships the runbook + her
  ratified template copy (batch 3, unchanged); the signup flip stays
  in 14c on the built-in mailer, harmless at pre-distribution volume.
- **Gate delegations, her word:** the architect DRIVES the deploy,
  the live probes, AND the signup flip ("I also think that you can do
  the signup flip and you can drive the live probes and the deploy")
  — amending Round 5's the-flip-is-her-hand detail; each act still
  announced before it runs, and the deploy still sequences AFTER the
  ladder + the dedicated isolation round (a live-production deploy
  deserves its review first — her "ready whenever" recorded as
  standing readiness, not a resequencing). She types her passphrase
  into the runner as needed.
*[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  time by lookup).

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

**Recorded and ruled:**

- **Domain permanence uncertainty PRESERVED:** the apex domain
  (stargazing.tech, a paid premium domain) may move depending on her
  first year — recorded so 14d's Fragments provider configs are
  written knowing a future coordinated issuer move is a live
  possibility (config-only, no data migration — the Round-7 answer
  stands either way).
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
- **The passphrase step WAITS FOR THE GATE:** it is the repush half
  of the deploy — nothing passphrase-shaped exists to run before 09
  deploys (running the runner now would push against the CURRENT
  mirror, a no-op the wrong side of the rebuild). Sequence: batch 3 →
  ladder → isolation round → the gate, where the deploy and her
  passphrase moment arrive together, announced.

### Round 9 — THE SESSION SEAM RULED (2026-08-05; her directive at the
### 356.6k context reading — the skill's own cutover discipline,
### invoked by her)

Her directive, verbatim-faithful: finish everything that comes BEFORE
the steps requiring her — *"just finish up the actual code changes
(including the extra cold review)"* — with the architect still
controlling *"the ladder and tier of review"*; author mid-session
handoff notes ahead of time so a NEW session does *"the driving /
verification"*; the Fragments brief is THIS architect's responsibility
(*"since you have more direct context on the code"*); and *"It would
be your responsibility to write the plan for the 2nd half of 14c."*
The folded-to-new-session scope, her words quoting the standing gate
list: deploy + repush + phone re-onboard → probes → domain attach →
the flip → the stranger validation walk → the one-look ratify bundle
→ closeout including the 14d micro-plan.

**THE SEAM, as ruled (this session = the BUILD HALF; a fresh session
= the GATE HALF):**

- **This session finishes:** batch 3 (verify + adjudicate) → the
  standard ladder over the combined diff (fresh cold reviewer per
  round, fixes, re-review, cap 3) → the DEDICATED isolation review
  round → the FRAGMENTS BRIEF finalized in the contract file (the
  14c-era concrete facts written by the seat that held the code
  context; the few gate-dependent fields — e.g. the confirmed issuer
  URL post-attachment — marked FILL-AT-GATE for the successor) → the
  14d MICRO-PLAN DRAFTED (the architect's refinement, accepted
  rationale: batch 2's traced corner and the dormant machinery live
  in this session's verified context — the gate session finalizes
  with gate facts rather than authoring cold) → the GATE-HALF PLAN +
  the role handoff with a PASTE-READY kickoff prompt (the skill's
  two-document form; `phase-13b-stage4-orchestrator-handoff.md` the
  exemplar) → memory + push → HARD STOP.
- **The fresh gate session executes:** the gate list above exactly as
  recorded at L13 (announced per step; deploy/probes/flip
  architect-driven per Round 7; her passphrase + Cloudflare + phone
  acts + walks), the ratify bundle (B1-1/2/3 · B2-1/2/3 + batch 3's ·
  the doors' copy redline), then the closeout ritual in full.

## THE DESIGN (settled by the sitting — the architecture the batches
## build)

**1. The born-multi-tenant mirror (the clean rebuild).** ONE
consolidated artifact, `Server/supabase/09_phase14c_multitenant.sql`:
drops and recreates the 18 data tables with their FINAL columns (the
01→08 accretion consolidated), each with `owner_id uuid NOT NULL` in a
composite PK `(owner_id, id)` — `(owner_id, key)` for `setting` — plus
`(owner_id, server_seq)` indexes, the `server_written_at` horizon
column, and the seq-stamp trigger. NO other constraints and NO FKs
(SyncSpec §2's repair requirement is untouched). Forced RLS
(`ENABLE` + `FORCE ROW LEVEL SECURITY`) with owner policies keyed on
`auth.uid()` on all 18 + `entitlement`; `key_vault` keeps its 14b
policies. The RPCs rewritten tenant-scoped: every CAS lookup keys on
`(caller, id)`; owner stamped into every insert server-side and
subtracted from every served payload for the ten mirror-only-owner
tables; the eight client-carried owner tables keep the existing
validate-equals-caller guards. The A5 visibility horizon and wire
shapes preserved VERBATIM. Explicit guards + policies = the two-layer
hybrid. **ONE SyncSpec §12 lockstep event: marker 5→6**, deployed only
at her explicit go at the gate; `SyncSchema.lockstepVersion` bumps in
the same commit as the DDL (the AuthRLSDDLTests pin pattern).

**2. The vault-key-id fence (CF-8's structural half + the stale-key
class).** `sync_push`/`sync_pull` gain a required active-key-id
parameter; the server compares it against the caller's `key_vault`
row's current corpus key id — mismatch refuses the whole round with a
NAMED error the client surfaces as the CF-16 replaced state. The
engine sends its held key id every round. The bridge's rounds carry
the journal-bridge key id the same way when they resume (14d). Old
(pre-14c) clients refuse at the marker — the fence parameter rides the
same lockstep event.

**3. CF-8, the user-facing re-key door.** In-app, no terminal; both
form factors via the shared seam where feasible (Mac is the floor).
Order OF OPERATIONS (the fence makes it safe): passphrase
authorization → NEW vault written FIRST (new key ids; every stale
writer everywhere is now fenced by design) → the account-scoped
truncate RPC (`delete … where owner_id = auth.uid()` per table — the
composite PK makes this exact) → local `resyncReinitialize` → repush →
the bridge's staged re-push trigger (inert while the bridge is paused;
live from 14d). Composes with deletion (deletion supersedes re-key;
two doors, shared friction grammar).

**4. Account deletion.** The immediate hard purge per the ruling: an
authenticated, passphrase-authorized purge RPC removes the account's
rows across the 18 tables + `key_vault` + entitlement rows, then the
auth user itself (definer-function admin removal — mechanics verified
at build). Device custody cleared locally via the CF-11 forget
machinery after the server act. **The copy says the local copy
survives** (her pinned rule). Subscription state checked/warned first.

**5. The tier.** `entitlement` rows on the account (born in 09; her
account seeded entitled); the RPCs enforce entitlement from birth —
safe because strangers arrive only after the tier per the ruled
choreography. Web-first checkout on stargazing.tech (that repo's own
agent builds the page; she tasks it — this repo never does); the
checkout's webhook writes entitlement rows via a small server
function; the Variorum apps READ the entitlement (plain authenticated
reads, the P-ii pattern) and gate hosted sync with honest copy.
Price named by her at launch; machinery price-agnostic. Payment
processor + current steering rules: verified at build by a Sonnet
lookup + her accounts (author-assist).

**6. Signup & stranger onboarding.** The signup door opens ONLY at
choreography step (6), as her deliberate act at the gate. In-app
account creation UX (14a built sign-in; this adds sign-up), per-user
vault provisioning at signup = the 14b stepped setup flow running for
a fresh account (verify its generality; it was built account-agnostic),
empty-store first pull reading as NORMAL (the v1 principle), custom
SMTP before the door *(Round-7 amendment: the config ACT moves to 14d
— 14c ships the runbook + her ratified template copy; the flip runs on
the built-in mailer at pre-distribution volume)*, rate/abuse limits
recorded with the tier. The PL-6 residual (the phone's first-run
FULL-SETUP visual walk) rides the stranger-onboarding validation.

**7. What this phase does NOT do (deliberate):** no Fragments-side
work and no bridge resumption (14d's); no TestFlight (after 14d, her
standing ruling); no QR device-linking (the recorded R-4 future door);
no GC/tombstone horizon work (12/13j's — account deletion sidesteps it
because a deleted account has no peers left to strand); no local
schema change of any kind (zero core migrations expected — the entire
isolation build is server-side + engine wire).

## Scope ledger (the master-plan row's letter, as amended by the
## sitting)

1. Per-user isolation of the TEN ownerless mirror tables (the
   preflight correction) — via the clean rebuild, NOT retrofit.
2. `setting` multi-user redesign — subsumed: (owner_id, key) PK in the
   rebuild.
3. The signup door opens — after isolation, per the ruled choreography.
4. Per-user key-vault provisioning at signup + rotation at scale.
5. CF-8, the user-facing re-key door — with the vault-key-id fence
   BEFORE the truncate (the C-3 constraint, mechanism honored).
6. The suite subscription — *[removed for publication]*.
7. Tier-launch operationalia: custom SMTP · in-app ACCOUNT DELETION
   (immediate hard purge; local survives, pinned) · rate/abuse limits.
8. The custom domain fronts the issuer BEFORE the door opens (step 4)
   — and therefore before 14d's handoff (the guardrail holds).
9. ~~THE PHASE'S END: the one-batch Fragments handoff~~ — **MOVED to
   micro-phase 14d** (her Round-5 ruling; the contract file carries a
   dated amendment).

## 14b's smaller pinned contributions (owned rows, not to lose)

- **Admin `generate_link` BYPASSES signups-off** — the provisioning
  hazard AND the deliberate tool: the second-account probe provisions
  through it, uid-checked, before the door opens.
- **GM-3's gateway burst-pacing:** stranger-scale initial pushes join
  the at-scale design (the runner's pacing generalizes).
- **The runner's drain-summary accumulator** (cosmetic): fixed at the
  first runner touch this phase.
- **`key_vault.updated_at` client-write** (ladder R2-1's declined
  one-liner): the vault-generalization batch decides it with reasons.
- **The PL-6 residual:** the phone's first-run full-setup walk rides
  stranger-onboarding validation.

## The batches (fresh Fable implementer per batch, strictly
## sequential; briefs = this file's named sections + the environment
## traps verbatim)

**Batch 1 — the born-multi-tenant mirror + the two-user harness.**
1. `Server/supabase/09_phase14c_multitenant.sql` (THE DESIGN 1–2):
   the consolidated rebuild DDL + rewritten RPCs + forced-RLS policies
   + the fence parameter + the `entitlement` table (her account's seed
   row in the deploy script). Its OWN commit (the model-change
   convention); `SyncSchema.lockstepVersion` → 6 in the same commit,
   pin-held.
2. Engine wire: the active-key-id parameter each round; the fence
   refusal surfaced as the CF-16 replaced state (the existing state,
   new server-side trigger); serializer/Merge/Repairs ZERO-diff
   (proven on the batch diff, the 14b precedent).
3. Fake server: multi-user parity with the new semantics (composite
   identity, owner stamp/subtract, fence, entitlement check) — the
   emulation-only caveat recorded in every relevant test's comment.
4. THE TWO-USER CONVERGENCE SUITES (the Phase 5 harness's second
   axis): two users × two devices each, converging independently over
   ciphertext; zero cross-user rows through both RPCs; repairs stay
   in-partition; scoped settings; the stranger-corpus-unreadable
   assertion. Red-on-old discipline throughout.

**Batch 2 — the account lifecycle doors.**
1. CF-8's re-key door per THE DESIGN 3 (vault-first order pinned by
   test; the truncate RPC; the bridge trigger inert-until-14d).
2. Account deletion per THE DESIGN 4 (the purge RPC; the local-copy-
   survives copy pinned; custody cleanup via the forget machinery).
3. The drain-summary accumulator fix rides the runner touch; the
   `key_vault.updated_at` call decided with reasons.
4. **THE 14D PREP (her Round-6 ruling):** the LIVE journal-bridge key
   provider (the 14b Keychain custody seam) + the staged
   re-push-from-truth machinery, built and PINNED but DORMANT — the
   standing structural pause stays the default until 14d's deliberate
   act. Pins prove BOTH halves: dormancy (no bridge round runs with
   the pause in place) and readiness (the flip → a full staged
   re-push round against the fake, every day re-arriving as
   ciphertext).

**Batch 3 — the tier + the door.**
1. Entitlement reads + the hosted-sync gate UX in both apps' shared
   seam; price-agnostic machinery.
2. Sign-up surface + fresh-account vault provisioning generality +
   empty-store onboarding (THE DESIGN 6).
3. The stargazing.tech checkout is the SITE agent's build (she tasks
   it); this batch delivers the entitlement-write server function +
   the site-facing contract facts (a short handoff block in this
   file).
4. SMTP + rate/abuse limits: the config acts recorded; her account
   steps author-assist.

**The ladder + the isolation round.** ONE standard ladder over the
combined diff (fresh cold reviewer, REVIEW_PROMPT verbatim; rounds per
the standing rules) PLUS the ruled DEDICATED isolation-boundary review
round (a fresh reviewer whose anchor is the isolation design + the 09
artifact + the two-user suites — beyond the standard ladder).

**The gate (author-attended, the choreography executed in the ruled
order):** A1 rail (backup + mirror export) → 09 deploy at her go →
her repush via the proven runner → phone re-onboard → the live probes
(second account provisioned via the admin door, uid-checked;
stranger-sees-zero through both RPCs; the BYPASSRLS empirical check) →
custom domain attached + `iss` verified (author-assist; cost/plan
implications surfaced with a lookup first) → SMTP live → HER FLIP of
the signups toggle → stranger-onboarding validation (incl. the PL-6
phone walk) → closeout (incl. authoring 14d's micro-plan + finalizing
the contract brief she carries).

### Batch 1 — record (implementer session, 2026-08-04)

**Shipped, per deliverable (commits on `main`):**

1. **L1 — the born-multi-tenant mirror artifact** (`b6b2c7e`, its own
   commit per the model-change convention; AUTHORED NEVER DEPLOYED —
   the deploy is the architect's gate act at her explicit go):
   `Server/supabase/09_phase14c_multitenant.sql` — the 18 data tables
   dropped and recreated per THE DESIGN 1 (final consolidated columns
   from the 01→08 accretion; `owner_id uuid NOT NULL` leading composite
   PKs `(owner_id, id)` / `(owner_id, key)` for setting; `(owner_id,
   server_seq)` changefeed indexes; `server_written_at` + the two-column
   stamp trigger; NO other constraints, NO FKs — SyncSpec §2's repair
   requirement untouched); ENABLE + FORCE row level security on all 18
   with owner policies on `auth.uid()`; the RPCs rewritten tenant-scoped
   with NEW signatures `sync_push(batch, active_key_id)` /
   `sync_pull(since_seq, active_key_id, max_rows)` — CAS keyed
   (caller, id), owner stamped into every insert, owner subtracted from
   every served payload for the TEN mirror-only-owner tables, the EIGHT
   client-carried tables keeping validate-equals-caller, the A5 horizon
   and wire shapes VERBATIM (pinned); the vault-key-id FENCE and the
   entitlement gate opening both bodies; the `entitlement` table born
   clean with the deploy-path seed; marker 5→6 the file's LAST
   statement. `SyncSchema.lockstepVersion` → 6 in the SAME commit,
   pin-held (the 08 precedent), plus the `SyncServerRefusalMarker`
   constants the DDL pin ties to the SQL's RAISE tokens.
2. **L2 — engine wire + CF-16 surfacing** (`b40deeb` + `a6bf612`):
   `SyncTransport.push/pull` gain the REQUIRED `activeKeyID` parameter
   (deliberately no default — the protocol's own schemaVersion doctrine:
   wrappers forward, fakes enforce; a defaulted shim could silently drop
   the fence in every composed test); the engine sends its held corpus
   key id on BOTH round halves, resolved before network contact;
   `SupabaseTransport` carries `active_key_id` in both wire DTOs and
   classifies the marker refusals into typed errors
   (`SyncError.encryptionKeysReplaced` / `.syncNotEntitled`); the app
   classifier arm `EncryptionSession.isKeysReplacedError` + the
   `SyncRowFace` keysReplaced arm covering BOTH CF-16 triggers
   (fence-before-poison-push, decrypt-failure-after) — one state, one
   face, one Re-enroll door.
3. **L3 — fake parity + the two-user suites** (`b40deeb` + `9316d5b`):
   `FakeSyncServer` reworked to multi-tenant parity (per-account
   partitioned storage = the composite-PK twin; whole-batch owner
   validation = the RAISE-aborts-all parity; per-account vault key id +
   entitlement; `connection(as:)` per-user transports; per-user
   inspection; `truncateAccount`; `wipe()` preserving provisioning
   exactly as the real truncate never touches key_vault/entitlement) —
   the EMULATION caveat recorded in the fake's header AND every
   relevant suite (the real Postgres truth is the gate's integration
   pass + live probes, per the preflight). `MultiTenantSyncTests`
   (8 tests): the crown (two fleets converge independently over
   ciphertext, zero cross-user rows, the all-tenants mirror-dump
   ciphertext walk) · stranger-corpus exactly-as-unreadable · colliding
   ids in separate partitions with independent CAS · scoped settings
   never CAS-fight (the L2-subsumed redesign's proof) · the tag.path
   repair stays in-partition (identical natural key across tenants
   dedupes nothing) · the fence end-to-end (stale writer refuses both
   halves typed, outbox/cursor intact, ZERO rows past the fence; heals
   by the CF-8 road: new keys → account truncate → resyncReinitialize →
   repush, the old key provably unable to open the re-sealed corpus) ·
   the entitlement gate (refuses typed, heals on grant) · the
   engine-wire pin (the held key id on every push AND pull).

**Design calls, each with its reason:**

- **The OLD RPC signatures are DROPPED first** (09 section 0): Postgres
  overloads by signature, so a lingering `sync_pull(bigint, int)` would
  keep serving the ten ownerless tables to any authenticated caller
  with no owner filter, no fence, no entitlement — a cross-tenant read
  door beside the new one. Pinned
  (`theOldRPCSignaturesAreDroppedByTheRebuild`). Interim note: a
  pre-14c client never sees the missing function in practice — the §12
  marker check runs FIRST each round half and refuses at 5≠6.
- **Marker TOKENS, not sentences** (`VARIORUM_STALE_KEY_FENCE` /
  `VARIORUM_NO_ENTITLEMENT`): the transport classifies refusal bodies
  by token; human wording may evolve server-side, the token may not,
  and the DDL pin holds the SQL and the client constants together.
- **Gate order auth → fence → entitlement** in both RPC bodies (and the
  fake): the fence is the data-integrity guard — a stale writer's
  refusal must never be maskable by commerce state.
- **A missing vault row refuses AT THE FENCE** (same arm as mismatch):
  mid-re-key and never-setup callers both hold no right to write; the
  CF-16 re-enroll road is the honest fix for both. (The engine refuses
  keys-unavailable before network contact anyway — this arm is the
  server's backstop.)
- **Owner policies carry NO `to` clause**: under FORCE RLS the definer
  role itself must match a policy or the RPCs default-deny themselves;
  direct API access stays shut by privilege revokes exactly as before.
  The sitting's BYPASSRLS caveat is restated in 09's header for the
  live probe.
- **Owner stamped into ALL 18 inserts** (not only the ten): uniform and
  server-authoritative; for the eight it merely re-affirms the
  validated payload value. THE DESIGN's stamp/subtract letter holds:
  subtraction stays exactly the ten's (the eight's clients own the
  column).
- **`entitlement` is RLS-ENABLED, deliberately NOT forced**: the
  definer RPCs must read it for the gate; the apps read their own row
  via the owner-only SELECT policy (the P-ii pattern); NO write grants
  to authenticated — entitlement writes are server-side only (batch
  3's webhook function / service_role).
- **The retired stored-owner guard**: 04–06's "belongs to another
  owner" arm is gone as structurally unreachable — the tenant-scoped
  CAS read cannot see a foreign row. The pin pivoted from the guard's
  text to the composite scoping itself
  (`theDeployedPushBodyIsTenantScoped`); the two-user suites prove the
  behavior end-to-end.
- **`SyncClient` defaults SIGNED IN** (the fake's default account):
  post-14c a syncing device is always signed in (transport requires a
  session; adoption ran at 9c), and the born-multi-tenant mirror
  refuses unowned pushes. `OwnerIdentityTests`' backfill choreography
  REWRITTEN to the post-14c shape — adoption precedes first sync; the
  pre-9c unowned-corpus-through-the-mirror scenario is retired with
  the mirror it modeled (the file's history holds it).
- **The serializer walk grew three teeth with the artifact** (same
  commit): `entitlement` joins the server-only tables; `owner_id` on a
  table whose CLIENT schema lacks it is server machinery (the
  stamp/subtract's walk-side mirror); and the DDL parser is now
  DROP-AWARE — 09's rebuild REPLACES a table's accumulated column set,
  so a column lost in the consolidation fails the walk instead of
  hiding in the 01∪09 union (the rebuild's own drift class).
- **`SyncError.syncNotEntitled` is built now, its FACE is batch 3's**:
  the typed error + transport classification ship with the wire (the
  suites pin the refusal grammar); today it presents as the generic
  error face with the cause note — the tier's dedicated UX is L7's,
  deliberately not front-run.

**PROVISIONAL (logged for the ratify list; none gated the core):**

- **PROVISIONAL B1-1 — the fake's NULL-owner latitude.** The real 09
  RPC refuses a NULL `owner_id` on the eight; the fake accepts it into
  the caller's partition. Options weighed: (i) strict parity — refuse
  NULL, which forces the whole legacy harness (every pre-9c-shaped
  scenario and crafted row) onto signed-in fixtures; (ii) the chosen
  latitude — partitioning already makes the outcome tenant-safe, the
  strict arm stays PINNED in the DDL
  (`pushCarriesTheClientOwnerGuard`'s `is distinct from`) and is proven
  on real Postgres at the gate, and the two-user suites run fully
  signed-in so the meaningful arm (foreign owner refuses) is exercised
  in the fake too; (iii) a fake mode flag (rejected — a switchable
  fake is the postmortem's fidelity failure shape). Recorded in the
  fake's header where no reader can miss it.
- **PROVISIONAL B1-2 — the entitlement table's shape**:
  `(user_id, feature)` PK, `feature = 'hosted_sync'`, nullable
  `expires_at` (NULL = non-expiring), `source` provenance text.
  Price-agnostic per THE DESIGN 5; batch 3 may adjust with recorded
  reasons before the deploy (the artifact is undeployed until the
  gate).
- **PROVISIONAL B1-3 — the fence compares `corpus_key_id` only**: THE
  DESIGN 2's letter for these two RPCs; the journal-bridge key id
  rides the BRIDGE's own rounds when they resume (14d/L15's road,
  Fragments-side dialect — never these endpoints).

**Red-on-old (all by behavioral revert, restored green after):**

- Drop-aware DDL parser: drop-handling neutralized → 
  `aRebuildThatDropsAColumnIsVisibleToTheWalk` RED; restored green.
- The fence: the fake's key-id guard neutralized → the stale-writer
  suite RED (would-be poison pushes land); restored green.
- The partition: collapsed to the single pre-14c keyspace → the crown,
  colliding-ids, and scoped-settings suites all RED (the exact
  single-keyspace failure classes: cross-tenant CAS fights, B's fleet
  adopting A's setting); restored green.
- The entitlement gate: neutralized → the unentitled-round suite RED;
  restored green.
- The CF-16 face arm: removed → the fence refusal presented as the
  generic `.error` face (Retry/Account doors) and
  `theFenceRefusalPresentsAsTheReplacedRow` RED; restored green.
- (The new DDL pins and the protocol parameter are red-on-old
  inherently: no 09 file / no parameter exists on the pre-batch tree.)

**Zero-diff proof (the 14b precedent, on the batch range
`01fc2a7..a6bf612`):** `git diff -- Sources/VariorumCore/Sync/Merge.swift
Repairs.swift SyncEncryption.swift` → EMPTY (0 lines). The engine
inland — merge matrix, repairs, the payload-crypto seam — is
byte-untouched; the batch's whole `Sync/` footprint is
SupabaseTransport (+49) · SyncEngine (+10, the two call sites + doc) ·
SyncSchema (+50, lockstepVersion 6 + markers + two error cases) ·
SyncTransport (+17, the signatures + doctrine comment).

**Counts (batch end, all synchronous runs):** core **1174/125** green
(was 1158/124) · Mac **1220/213** with the standing
`TakePaneMeasureTests` tripwire the ONE red BY IDENTITY (was 1218/213)
· mobile **175/26** green (simulator; the shared SyncStatusViews/
EncryptionSession changes compile and pass untouched suites) · spine
**51/7** green.

**The architect's verification + adjudication (2026-08-04, at the
batch's completion):** commits/diffs/record spot-checked per the
verify-not-trust rule — tree clean at `c151c98`, `swift build` green
(the transient SourceKit diagnostics were stale index noise), the 09
artifact's claims confirmed by inspection (18 FORCE RLS statements,
composite PKs, old signatures dropped, marker last), the zero-diff
claim structure-checked. **PROVISIONAL dispositions (the mandate's
architectural calls; bundled for her one-look ratify at the gate):**
B1-1 SUSTAINED — the fake's latitude is tenant-safe by partitioning,
the strict arm stays DDL-pinned and is proven on real Postgres at the
gate, and a switchable fake is the postmortem's fidelity failure
shape; B1-2 SUSTAINED as provisional until batch 3 (the artifact is
undeployed; adjust-with-reasons stands); B1-3 SUSTAINED — THE DESIGN
2's letter, the bridge's key id rides its own dialect at 14d. The
old-signature drop is ratified as an isolation requirement, not a
style call. The probe-account entitlement grant joins the gate
runbook (L13).

**Held for the architect / the gate:**

- **The probe account needs a deliberate entitlement grant** in the
  live-probe setup (recorded in 09's seed comment): entitlement is
  enforced from birth, so an unentitled probe account would refuse at
  the tier gate instead of serving zero rows — the grant is part of
  provisioning the second account, and its own deletion later is the
  natural purge test (the Verification section's letter).
- **The BYPASSRLS empirical check** rides the live probe (the
  sitting's pinned caveat; restated in 09's header).
- **CF-8's account-scoped truncate RPC is batch 2's** — 09 ships no
  truncate door (the fake's `truncateAccount` models the semantics the
  two-user fence suite proves against).
- 07's header note ("no un-updated client exists today") and 14b-era
  phrasing in older artifacts stand as deployed history — 09's header
  carries the current choreography.

### Batch 2 — record (implementer session, 2026-08-04)

**Shipped, per deliverable (commits on `main`):**

1. **L4 — CF-8, the user-facing re-key door** (`ae1b4c6` the SQL half,
   its own commit per the model-change convention · `8bedbe2` the core
   brain · `f564e00` the app door):
   - **09 gains `account_data_truncate(active_key_id)`** (new section 6;
     the artifact stays AUTHORED NEVER DEPLOYED; the marker stays the
     file's LAST statement — sections renumbered 6→8→9 so the
     marker-last pin holds): tenant-scoped row DELETEs over EXACTLY the
     18 registry tables (never TRUNCATE — row-scoped by the composite
     identity; never key_vault/entitlement/sync_meta; `server_seq`
     untouched, SyncSpec §9), gated by the SAME vault-key-id fence arm +
     marker as the sync RPCs — the ORDER's server-side enforcement:
     only a caller presenting the account's CURRENT corpus key id can
     empty the account, and post-vault-write that is exactly the device
     that just re-keyed (C-3's poison window closed structurally).
     Three new `AuthRLSDDLTests` pins (registry-exact table lists via a
     shared array parser; the fence/order/posture letters).
   - **`AccountRekey` (core, Crypto/) — THE ORDER OF OPERATIONS, pinned:**
     passphrase authorization (the CURRENT vault's master unwrapped,
     then discarded — nothing of the old key world survives) → the NEW
     vault written FIRST via the R1-2 CAS-guarded `updateVault` (fresh
     master + corpus + journal-bridge keys with fresh ids, fresh
     Argon2id salt/descriptor, the SAME passphrase; NO recovery wrap —
     see the landing below) → `onNewVaultMaterial` AWAITED (custody
     adoption, before the truncate, so this device is never stale
     against its own new vault) → the fenced truncate presenting the
     NEW corpus key id → `resyncReinitialize` (the proven R-2 half; the
     DRAIN deliberately stays the app scheduler's — visible sync-row
     progress; the headless drain shape stays `vault-bootstrap`'s) →
     the bridge staging trigger (below; inert under the pause).
     **Non-atomicity honest and PINNED:** the road back from ANY
     mid-run failure is RUNNING THE DOOR AGAIN (the rerun test proves a
     failed truncate heals whole); the surface speaks that road on
     every failure.
   - **The app door (the shared Mac+phone seam):** EncryptionView's
     enrolled section gains "Replace Encryption Keys…" — the honest
     warning naming the OTHER devices' fate (the CF-16 replaced state +
     re-enroll), the recovery phrase's death, and the local copy's
     survival; the CF-7-grammar understanding CHECKBOX; the passphrase
     field. `EncryptionSession.rekeyAccount` drives the injected runner
     (AppServices wires the REAL brain with the sync chain STOPPED
     around the truncate/reinit window — no scheduler round can race
     it — and the ordinary sign-in composition reconnecting after) and
     **LANDS IN THE STANDING CF-5 MANDATORY-PHRASE STEP**:
     `enrolled(hasRecoveryWrap: false)` IS step 4, so the new 12 words
     generate/write-down/confirm through setup's own machinery — zero
     new phrase code, and the flow is interruption-proof exactly as
     CF-5 built it.
2. **L5 — account deletion** (same three commits):
   - **09 gains `account_purge()`** (new section 7): data rows →
     `key_vault` → `entitlement` → **the auth user LAST** (key_vault's
     FK to auth.users makes the order load-bearing; pinned). No fence
     (deletion supersedes re-key — a stale device's owner may still
     delete) and no entitlement gate on either door (data removal is a
     right, never commerce-gated — a recorded design call). **The
     definer-function auth-user removal VERIFIED honestly** (the
     build-time Sonnet lookup THE DESIGN asked for): Supabase's 2025-04
     auth-schema lockdown restricted DDL + migration-table DML ONLY —
     the `postgres` role keeps DML on `auth.users`, and Supabase
     collaborators explicitly confirm the SECURITY DEFINER
     self-deletion RPC pattern (discussions #1066/#26223/#35987; the
     restriction notice is #34270; `auth.identities/sessions/
     refresh_tokens` cascade; no Supabase Storage in this project, so
     the storage.objects RESTRICT caveat is N/A). Recorded caveats IN
     the artifact: already-issued JWTs stay valid ≤1 h after deletion —
     and the fence's missing-vault arm is the backstop (a purged
     account's lingering push refuses; PINNED in harness); the
     Edge-Function/admin-API shape is the recorded fallback if a live
     deploy ever refuses the delete (a redesign-level swap, never a
     quiet patch). The gate's probe-account deletion is the live
     verification (the Verification section already names it).
   - **`AccountDeletion` (core)** — the purge behind the CLIENT-side
     passphrase authorization (a real master unwrap; the server can
     never verify a passphrase — that is the E2EE design; the server's
     own gate is the session). **`AccountLifecycleClient` +
     `AccountLifecycleProviding`** (core, Auth/) — the doors' seam,
     deliberately NOT folded into `SyncTransport` (fourteen conformers
     would take a stance on doors they never exercise); the transports'
     exact posture (signed-out refuses pre-compose; ONE 401 retry; the
     fence marker classifies into `SyncError.encryptionKeysReplaced` —
     ONE CF-16 state, whichever door refused), plus the entitlement
     read (the P-ii pattern) for the subscription warning.
   - **The app door:** AccountView's signed-in section gains "Delete
     Account…" — **HER PINNED COPY RULE byte-anchored** ("The writing
     on this device stays on this device… Only the account and its
     synced copy are deleted" — the Mac pin holds the sentences); the
     subscription warning FIRST (the static cancel-first advisory
     always; the best-effort entitlement-read note strengthens it —
     batch 3's checkout owns the real cancellation flow); the TYPED
     confirmation ("delete my account") gating the button; the
     passphrase field. `AppServices.deleteAccount`: purge → custody
     cleared through the CF-11 forget machinery → sign-out; the local
     STORE untouched by construction; a refused deletion clears
     NOTHING local (the wiring pin's wrong-passphrase arm).
3. **L6 — the runner fix + the R2-1 decision** (`8bedbe2`):
   - **The drain-summary accumulator FIXED** (the 14b drill's recorded
     quirk): the engine's `PushReport` dies with a THROWN round, so
     under GM-3's absorbed drops every round but the last could lose
     its accepted chunks from the total (the drill's 674-of-7,274).
     The summary now counts the OUTBOX DRAIN itself (in the runner's
     single-writer world an entry clears exactly when the mirror
     accepts its row — thrown rounds included). `Report.pushedAccepted`
     semantics: drained-to-mirror rows.
   - **`key_vault.updated_at` client-write DECIDED — write it**: every
     `updateVault` stamps `updated_at` truthfully. Reasons: the re-key
     door replaces the row's ENTIRE contents through this path, so an
     insert-time-only stamp would actively mislead ("when were the keys
     replaced?" is a real support question at 14c's stranger scale);
     display/bookkeeping only, never ordering (`revision` stays the CAS
     token; SyncSpec §9's clock doctrine holds); creates stay
     server-defaulted (`now()`); implemented as a plain now-closure,
     deliberately NOT `@Dependency(\.date)` — a bound clock forced onto
     every vault-touching suite across both layers for a value no
     assertion orders by (the first `@Dependency` attempt broke exactly
     that class of tests; reverted to the honest shape).
4. **L15 — THE 14D PREP (her Round-6 ruling), built and PINNED, DORMANT:**
   - **`BridgeEngine.stageRepushFromTruth`** — the staged
     re-push-from-truth machinery: every AGREED journal day's
     `last_synced_hash` becomes a SENTINEL (`restaged:repush-from-truth`)
     so the push half's `hash == agreedHash ⇒ skip` guard re-pushes the
     day's rendered truth, re-sealed under whatever journal key the
     round holds. **The sentinel over NULL is a design call with a
     traced reason:** an agreed-EMPTY day must re-push its sealed
     emptiness over a dead-key body, and a NULLed hash would hit the
     standing never-first-push-of-emptiness guard — the sentinel keeps
     that guard scoped to genuinely virgin days (revert-proven).
     Stamp-only rows and LWW stamps/created_at echoes survive staging;
     idempotent; the identical-body re-push's `replaced` receipt is
     absorbed by discrimination rule (ii) (traced: the pushed plaintext
     contains the opened previous body), while a genuinely unseen
     Fragments body still rescues under rule (iii).
   - **`DeviceBridgeKeyProvider` (App/Shared)** — the LIVE
     journal-bridge key provider: the real Keychain-custody road
     through the 14b seam, `DeviceKeySyncProvider`'s exact twin for the
     bridge's class (custody already holds the journal key + id from
     enrollment — 14d adds no key machinery). **Production wires it
     NOWHERE**: AppServices passes no `makeBridgeKeyProvider`, so the
     refusing default — the STRUCTURAL PAUSE — stands until 14d's
     deliberate act.
   - **Both halves PINNED** (`BridgeRestageTests`): DORMANCY — with the
     pause in place, a staged world's round refuses before any network
     contact, zero transport writes, the staged days waiting intact;
     READINESS — the deliberate flip (a live provider) drives the full
     staged re-push against the fake: the day re-arrives `e1:`, opens
     to the rendered truth, no spurious rescue, and the day SETTLES
     back to a real agreed hash (the next round is quiet). The re-key
     door's bridge trigger connects to this machinery (the end-to-end
     re-key test asserts the staging), inert until 14d.

**Design calls, each with its reason (beyond those above):**

- **The re-key keeps the CURRENT passphrase** (a fresh salt/descriptor,
  same secret): changing the passphrase is the standing separate door
  (Round 7's), and coupling the two acts would widen CF-8's ceremony
  for no security gain (the passphrase never left the device either
  way). One door, one act — the CF-2 coherence doctrine.
- **The new vault carries NO recovery wrap** — not an omission: the old
  phrase wrapped the old master and dies with it BY DESIGN; landing in
  `enrolled(hasRecoveryWrap: false)` makes the standing CF-5 mandatory
  step mint the new phrase with zero new machinery and the same
  interruption-proofness.
- **The app pauses sync around the brain** (`sync.stop()` →
  reconnect-after): a scheduler round racing the truncate/reinit window
  would push against a half-re-keyed account; the reconnect is the
  ordinary sign-in composition, so the drain starts through the
  standing triggers and the sync row shows "N pending" progress.
- **The doors' server grants are authenticated-only, no service_role**
  (unlike the sync RPCs): account acts are always a signed-in user's
  own, never server machinery's.
- **`FakeSyncServer.purgeAccount`** models deletion as account
  disappearance — a lingering device's round refuses at the fence's
  missing-vault arm, which is exactly the real world's backstop for the
  JWT-until-expiry window (pinned).
- **The wiring emulation caveat, restated where it lives:** the
  rekey-world harness wires the scripted vault so a successful vault
  write MOVES the fake mirror's fence comparand (the one-Postgres
  shape); the REAL Postgres truth is the DDL pins + the gate's live
  probe, exactly the batch-1 discipline.

**PROVISIONALs (logged for the ratify list; none gated the core):**

**The architect's verification + adjudication (2026-08-04, at the
batch's completion):** commits/tree/build spot-checked per the
verify-not-trust rule — clean at `8431b9b`, `swift build` green (the
recurring SourceKit diagnostics are stale index noise, dismissed by
the green build again), the truncate RPC confirmed gated by the SAME
fence arm/marker as the sync RPCs, `account_purge` present with the
data → vault → entitlement → auth-user-last order, and
`DeviceBridgeKeyProvider` confirmed BUILT AND WIRED NOWHERE in
production (the Round-6 dormancy letter). **PROVISIONAL dispositions:**
B2-1 SUSTAINED — refusing a vault-less deletion would deny the
deletion right to exactly the accounts with nothing synced; session +
typed confirmation is the honest floor; B2-2 SUSTAINED as provisional
for HER WALK (the pinned requirements are byte-anchored; the
surrounding sentences are a taste surface — propose-only, one line
each to change); B2-3 SUSTAINED until batch 3's tier UX takes the
read into its real home. **The held 14d trace is ROUTED: the 14d
micro-plan (authored at L14's closeout) MUST carry the
old-key-satellite-rows-ahead-of-the-cursor corner as a named step** —
the staged re-push must be sequenced against the bridge's pull (or
the pull's refusal tolerated for the window) when the pause lifts;
narrow and visible, impossible while the pause stands.

- **PROVISIONAL B2-1 — a VAULT-LESS account deletes with the typed
  confirmation + session alone.** No passphrase exists to demand, and
  refusing outright would deny the deletion right (App Store 5.1.1(v),
  14c's own operationalia row) to exactly the accounts with nothing
  synced (no vault ⇒ nothing under the tier's mandatory E2EE). Options
  weighed: (i) refuse (denies the right); (ii) demand the account
  PASSWORD (a second credential surface for a corner; the session
  already proves it); (iii) the chosen arm. Pinned.
- **PROVISIONAL B2-2 — the doors' COPY WORDING** (the re-key warning +
  checkbox sentence, the deletion explanation + "delete my account"
  confirmation phrase): composed in the ruled CF-6/CF-7 grammar — the
  local-copy-survives rule and the other-devices consequence are HER
  PINNED requirements and byte-anchored; the exact sentences around
  them are drafted for her walk, one line each to change.
- **PROVISIONAL B2-3 — `refreshSubscriptionNote` is best-effort**: a
  failed entitlement read stays silent because the STATIC cancel-first
  advisory shows regardless; the note only ever strengthens. Batch 3's
  tier UX (L7) may promote the read into its real home.

**Red-on-old (all by behavioral revert, restored green after):**

- The ORDER pin: the brain's truncate moved BEFORE the vault write →
  `theRekeyWritesTheNewVaultFirstAndTruncatesUnderTheNewKeyID` RED on
  the order assertion ("(vaultWrite → 1) < (truncate → 0)"); restored.
- The staging: `stageRepushFromTruth` neutralized to a no-op → the
  readiness pin RED three ways (staged 0, pushed 0, no server write);
  restored.
- The SENTINEL design: staging rewritten to NULL the hash (the rejected
  shape) → `anAgreedEmptyDayRepushesSealedEmptinessOnlyWhenStaged` RED
  exactly on the emptiness-guard mechanism; restored.
- The deletion authorization: the unwrap check removed → wrong
  passphrase PURGED anyway (the pin red on "a refused authorization
  must never reach the purge"); restored.
- The accumulator: the old returned-reports accounting restored → the
  pin RED on the exact drill class ("(pushedAccepted → 158) ==
  (totalRows → 1358)"); restored.
- The updated_at stamp: the client write dropped → the stamp pin RED
  (nil through every update); restored.
- (The SQL pins, the new protocol/seam types, and the app doors are
  red-on-old inherently — none existed on the pre-batch tree; the
  batch-1 precedent's reading.)

**Held for the architect / 14d:**

- **A traced 14d-era coordination corner (recorded, NOT this batch's to
  fix):** after a POST-14D re-key, any `journal_entries` row AHEAD of
  the bridge's pull cursor still sealed under the old journal key
  refuses the round at the land seam (R1-4's own refuse-with-cursor-held
  choice) — and since `run()` is pull-then-push, the staged re-push
  cannot overwrite those rows until they are re-written Fragments-side
  (their re-enrollment + re-save) or land. Narrow (requires unlanded
  Fragments writes at the re-key moment), VISIBLE (the round refuses,
  never silent), nothing lost; at 14c the bridge is paused so the
  corner cannot occur. 14d's design owns the final word — flagged for
  its micro-plan.
- The 09 artifact remains AUTHORED NEVER DEPLOYED; batch 2's sections
  ride the same gate deploy (marker still last — pinned).
- The gate's probe-account deletion doubles as the purge's live
  verification (already the Verification section's letter), and the
  BYPASSRLS check now also covers the two new definer functions for
  free (same role, same probe).

**Counts (batch end, all synchronous runs):** core **1191/127** green
(was 1174/125 — +3 DDL pins, +9 AccountLifecycleTests, +4
BridgeRestageTests, +1 accumulator pin, exactly accounted) · Mac
encryption family 30/7 green · **full Mac suite: 1226/215
tripwire-only** (the standing `TakePaneMeasureTests` red BY IDENTITY;
was 1220/213 — +6 in 2 new suites) · mobile **175/26** green
(simulator; the shared seam carries both doors) · spine **51/7** green.

*(Correction appended 2026-08-05, ladder R1-2 — the record above stands
as written, this note dates the drift: the purge-order claim "key_vault's
FK to auth.users makes vault-before-user load-bearing" is FALSE —
08_phase14b_lockstep.sql declares that FK `ON DELETE CASCADE`, so
deleting the auth user first would succeed and cascade the vault row.
The order stands as the deliberate reporting/clarity choice (explicit
removals, exact counts); the 09 comments and the DDL pin's comments now
say so. Behavior was never affected; the order pin itself stays.)*

### Batch 3 — record (implementer session, 2026-08-05)

**Shipped, per deliverable (commits on `main`):**

1. **L7 — entitlement reads + the hosted-sync gate UX** (`6c205e8`, the
   batch's app half, both apps' shared seam):
   - **The tier face:** `SyncRowFace` gains `.notEntitled`; the server's
     `VARIORUM_NO_ENTITLEMENT` refusal now presents as a NORMAL row —
     secondary styling, and its doors are LITERALLY the idle row's
     (`Sync now` enabled + `Account…`), pinned as data equality with the
     idle face — instead of batch 1's deliberate stand-in (the generic
     error face with the cause note). "Sync now" is the heal: activation
     takes effect on the next round, no relaunch. The classifier
     (`HostedSyncTier.isNotEntitledError`) is exact-match and pinned
     disjoint from every keys classifier — commerce state never wears a
     keys face.
   - **The tier's one home** (`App/Variorum/Shared/TierViews.swift`):
     the copy (what it is — the E2EE promise first · works-fully-without
     — the v1 principle's own sentence · where it lives —
     stargazing.tech, the web-first ruling) with a PRICE-AGNOSTIC pin
     (no price-shaped token in any tier static — she names the number at
     launch); the Account tab's `HostedSyncSection` (CF-14's "account
     will one day show payment", made good): active shows the standing +
     an honest "Renews or ends…" line (renewal is the processor's world
     — the app cannot know which), inactive shows the three-line honest
     pitch, `.unknown` renders NOTHING (a failed read is quiet — never
     an error face; when the server actually refuses a round, the sync
     row's tier line narrates).
   - **B2-3 PROMOTED into this home:** `refreshHostedSyncStatus` is the
     ONE entitlement read (the P-ii pattern through
     `AccountLifecycleProviding`), feeding `AccountState.hostedSync`;
     the deletion door's subscription note now DERIVES from the same
     read (one read, one truth). Currency honors `expires_at` exactly as
     09's letter (NULL = non-expiring; unparseable counts current — the
     server parses authoritatively, and the client must never
     manufacture a refusal the server didn't make).
2. **L8 — sign-up + fresh-account onboarding** (same commit):
   - **The sign-up door:** `AuthSession.signUp` drives
     `POST /auth/v1/signup` through the 14a seam (same project, same
     persistence, only sessions ever persist). Two success shapes,
     verified against GoTrue source by the batch's one lookup: an
     autoconfirm 200 IS a token response — adopted exactly as sign-in
     (the onChange wiring composes sync; the empty-store first pull
     follows); a session-less 200 = `.confirmationRequired`.
   - **The refusals classify and speak** (the R94 doctrine at the
     creation door, `ErrorPresentation.signUpFailureMessage`): the
     signups-off toggle — THE pre-gate constant — speaks as a CLOSED
     DOOR ("Account creation isn't open yet…"), never a generic failure
     blaming the input (both GoTrue vocabularies: `signup_disabled` +
     the message text); already-registered → "sign in instead"; weak
     password; 429 rate limit; the network arm; and the SOURCE-VERIFIED
     `email_address_not_authorized` arm — the built-in mailer refuses
     non-team recipients entirely, so this is the pre-SMTP era's REAL
     stranger refusal, and it blames the server's email setup, never
     the user.
   - **The surface** (`AccountView`): the signed-out section flips to a
     create-account form (email · password · confirm — the typo class is
     real when the reset road sits behind a 2/hr mailer; live mismatch
     line; CF-1 grammar: one act button, a borderless way back; the
     footnote speaks the v1 principle at the door: "works fully without
     an account"). The confirmation NOTICE renders as a normal secondary
     line, never red.
   - **FRESH-ACCOUNT GENERALITY PINNED** (THE DESIGN 6's "verify its
     generality" instruction, executed as a real pin —
     `FreshAccountSetupGeneralityTests`, parameterized over two
     arbitrary fresh uids): a brand-new account with no vault row walks
     the CF-5 mandatory-phrase setup EXACTLY as her account did (the
     `.noVault` offer, the pure rules gates incl. her checkbox sentence,
     the create act, the step-4 `enrolled(hasRecoveryWrap: false)`
     landing, confirm-by-re-entry), a second device of the same fresh
     account enrolls by passphrase into IDENTICAL custody, and the
     12-word road unlocks a third. Nothing keys on her account.
   - **THE EMPTY-STORE FIRST ROUND PINNED at the engine**
     (`MultiTenantSyncTests`, the harness's real shape): a fresh
     entitled account's FIRST PULL against a mirror already holding
     HER corpus serves ZERO rows — no stall, no refusal, A's corpus
     invisible; the first push carries EXACTLY the store's seeded
     `setting` rows (the honest finding below); the first authored note
     then lands in the stranger's own partition with hers untouched.
3. **L9 — the entitlement-write server function + the site contract**
   (`dc077ca`, the SQL half, its own commit per the model-change
   convention; the artifact stays AUTHORED NEVER DEPLOYED, marker still
   the file's LAST statement — sections renumbered 8→9→10): 09 section 8
   is `entitlement_set(target_user, target_feature, active, valid_until,
   via)` — ONE processor-agnostic function the checkout webhook calls;
   GRANT is an UPSERT (renewals move `expires_at` through the same
   call), REVOKE is a row DELETE (a row IS the entitlement; billing
   history is the processor's — the dumbness doctrine); identity is the
   PARAMETER, never `auth.uid()` (a webhook has no user session);
   SECURITY DEFINER with execute granted to service_role ONLY —
   authenticated revoked BY NAME (batch 1's the-apps-never-write
   letter). One new DDL pin
   (`theEntitlementWriteDoorIsServiceRoleOnlyAndProcessorAgnostic`).
   **The gate's probe-account grant (batch 1's held item) now has its
   deliberate tool** — the header records the exact call. THE SITE
   HANDOFF BLOCK follows this record (the section the stargazing.tech
   agent reads; that repo builds the page — this repo never does).
4. **L10 — the SMTP runbook + rate/abuse limits (RUNBOOK ONLY — the
   config act is 14d's by Round 7):**
   `notes/plans/phase-14c-smtp-runbook.md` — the exact dashboard act
   (Authentication → Emails → SMTP Settings, field by field), the
   sending-domain DNS shape for Cloudflare (SPF merge rule, the
   CNAME-must-be-grey-cloud trap, DMARC p=none), a provider comparison
   with a REASONED recommendation (Resend — TXT-only records sidestep
   the Cloudflare trap; free tier covers auth volume; hers to
   overrule), recommended rate/abuse-limit settings with reasons
   (keep 30/hr email + 60 s windows; the CAPTCHA escalation recorded
   unconfigured), and the auth email templates' DRAFT COPY staged for
   HER RATIFY (CF-10 spirit; the reset draft carries the load-bearing
   "never touches your encryption passphrase" paragraph — the 14b
   two-secrets model must survive a stranger's password-reset moment).
   NO dashboard contact was made. Facts source-verified by the batch's
   ONE Sonnet lookup (GoTrue source + live Supabase docs; provider
   pricing flagged third-party-sourced for a 14d re-check).

**Design calls, each with its reason:**

- **The tier row wears the idle doors LITERALLY** (pinned as equality
  with the idle face): "reads as normal, never degraded" made
  falsifiable — the door set, the styling voice, and the enabled states
  are the ordinary row's, and "Sync now" doubles as the activation heal.
- **The in-app tier copy deliberately does NOT promise Fragments
  coverage.** The suite promise (one payment covers both apps) is the
  PAGE's to make — where the purchase happens and where the ruled
  choreography places it — because Fragments' own entitlement check
  does not exist until the 14d-era batch, and shipped app copy must
  claim only what the app does today. The contract block below hands
  the suite promise to the site explicitly. (PROVISIONAL B3-3 — one
  line to change if she wants the suite named in-app.)
- **`.unknown` renders nothing at all** (not a spinner, not a
  placeholder): the section only exists once a read succeeds — a
  status read is never its own alarm, and an entitled user with a
  failed read must not see the sales pitch.
- **The subscription note keys on the tier's ONE feature** (the old
  batch-2 read joined all active features): the suite has one
  entitlement by design; a future second feature re-opens the
  derivation — recorded so it cannot drift silently.
- **`confirmationNotice` REWORDED mid-batch on a source-verified fact:**
  GoTrue's enumeration prevention answers an already-registered email
  with an IDENTICAL session-less 200 (sanitized user body) and sends NO
  email — the pretty sentence ("we just sent you an email") would be a
  lie in that arm. The shipped notice covers both roads honestly
  without revealing which fired ("If this address already has an
  account, no email arrives — sign in with its existing password
  instead"), preserving the enumeration protection. Pinned.
- **`signUp` decodes token-response-FIRST:** the autoconfirm shape is
  exactly the password grant's response, so the adoption path is the
  proven one; anything else on a 2xx is `.confirmationRequired` — no
  brittle field-sniffing of the user body.
- **The confirm-password field exists** (sign-in has none): a stranger
  mistyping a NEW password locks themselves out until a reset email,
  and the pre-SMTP mailer is capped at 2/hr to team addresses only —
  the one place the extra field pays its rent.
- **THE HONEST RESHAPE of the empty-store pin (a finding):** the
  brief's "zero rows" phrasing meets reality — a virgin store is not
  row-empty, because the schema SEEDS three `setting` rows and those
  push on the first round (real, correct behavior: settings are
  document semantics and must reach the mirror). The pin now says
  what's true: the first PULL is zero-row-clean (the stranger's actual
  first sync experience — the scheduler's order is pull→push), and the
  first push carries exactly the seeds, nothing refusing anywhere.
- **The runbook lives at `notes/plans/phase-14c-smtp-runbook.md`**: a
  standalone file the 14d act executes from top to bottom (the 14d
  micro-plan points at it), rather than prose buried in this file —
  the 9c Step-6-runbook precedent.
- **Template drafts cover only the emails in use** (confirm · reset ·
  change-email): drafting copy for doors that don't exist (magic link,
  invite, reauth) would sit stale and unratified; their Supabase
  defaults stand until a feature uses them.

**PROVISIONAL B1-2 — FINALIZED AS SHIPPED (the batch-3 duty on the
undeployed artifact):** the entitlement shape stands exactly as batch 1
authored it — `(user_id, feature)` PK · `feature = 'hosted_sync'` ·
nullable `expires_at` (NULL = non-expiring) · `source` provenance text ·
`granted_at`. Reasons, recorded: (a) the webhook write maps onto it 1:1
— `entitlement_set`'s parameters ARE the row's columns, nothing
processor-shaped needed; (b) the composite PK leaves room for a future
second feature without redesign; (c) `expires_at` makes a lapsed
subscription self-expiring even if a cancellation webhook never fires
(both RPC gates and the app read honor it independently); (d) `source`
is the support answer at stranger scale ("why is this account
entitled?"). Considered and DECLINED: an `updated_at`/audit column (the
mirror is not the billing system's history — the processor owns history;
the dumbness doctrine) and a status column (state duplication — a row IS
the entitlement; revoke deletes). The shape is final for the gate
deploy.

**PROVISIONALs (logged for the ratify list; none gated the core):**

**The architect's verification + adjudication (2026-08-05, at the
batch's completion):** commits/tree/build spot-checked — clean at
`6d34fae`, `swift build` green, `entitlement_set` confirmed
service_role-only with the marker still the file's last statement, the
runbook present with the source-verified mailer facts. **PROVISIONAL
dispositions:** B3-1 SUSTAINED as provisional for HER WALK (the B2-2
class exactly); B3-2 SUSTAINED (nothing configured; her overrule one
line at 14d); B3-3 SUSTAINED as provisional for HER WALK — and flagged
PROMINENTLY on the ratify bundle, because whether the app promises
Fragments coverage is a product-voice call (the implementer's arm is
the defensible one: never promise in-app what is not live until 14d;
the suite promise rides the site page). **THE MAILER-ARM DECISION
(the runbook §1 fork, the architect's call, vetoable at the gate):
*[removed for publication]*
validation window and is removed after. Reasons: it exercises the
FULL real stranger road (signup → confirmation email → confirm →
vault setup) including the template copy she ratifies (the CF-10
spirit wants her to see the real email); arm (b) would flip a
launch-posture semantic (autoconfirm) as a test convenience — a real
product decision she has not ruled, and the forgotten-toggle class;
arm (c) bypasses exactly the door being validated. The 2/hr cap is
irrelevant at one walk; the address is hers, so team membership
grants nothing she doesn't hold.

- **PROVISIONAL B3-1 — the tier/sign-up COPY WORDING** (the B2-2
  class): the pinned requirements — works-fully-without ·
  stargazing.tech · price-agnostic · the enumeration-honest notice ·
  the closed-door signups-off voice — are byte-anchored; the sentences
  around them are drafted for her walk, one line each to change.
- **PROVISIONAL B3-2 — the runbook's provider recommendation (Resend) +
  the §6 template drafts**: staged for her ratify at/before 14d;
  nothing is configured; the recommendation carries its reasons and her
  overrule is one line.
- **PROVISIONAL B3-3 — no Fragments-coverage promise in-app** (the
  design call above): the suite promise rides the site page; one line
  to change at her word.

**Red-on-old (all by behavioral revert, restored green after):**

- The entitlement-write posture: the service_role grant flipped to
  authenticated → the DDL pin RED on both posture arms; restored green.
- The tier face: the classifier branch neutralized (`if false,`) → the
  refusal fell to the generic `.error` face — the EXACT pre-batch
  behavior — and `theTierRefusalPresentsAsANormalRowWithTheIdleDoors`
  RED; restored green.
- The quiet-failure arm: the failed entitlement read made to set
  `account.lastError` → `aFailedReadStaysQuietAndUnknown` RED on "a
  failed status read never mints an error face"; restored green.
- (The signUp API, its classifier arms, the generality suite, and the
  empty-store pin are red-on-old inherently — none existed on the
  pre-batch tree. The generality and empty-store pins are behavior pins
  of THE DESIGN 6's claims, not bug fixes — no old-code defect was
  traced, so no hollow fix was minted; the hallucination guard's
  traced-mechanism duty is met by the walks themselves.)

**Counts (batch end, all synchronous runs, 2026-08-05):** core
**1193/127** green (was 1191/127 — +1 the empty-store onboarding pin,
+1 the entitlement-write DDL pin, exactly accounted) · Mac
**1240/219 tripwire-only** (the standing `TakePaneMeasureTests` red BY
IDENTITY, the one allowed; was 1226/215 — +3 AuthSessionTests sign-up
arms, +10 in TierAndOnboardingTests' three suites, +1
FreshAccountSetupGeneralityTests, exactly accounted) · spine **51/7**
green (by type name, the seven `Tutorial*Tests`) · mobile **175/26**
green (iPhone 17 simulator; the shared seam carries the tier face, the
sign-up form, and the tier section — no mobile-only code).

**Held for the architect / the gate:**

- **A GATE consideration from the source-verified mailer facts (new
  information, decision NOT made here):** the built-in mailer delivers
  ONLY to org-team addresses, so at gate step (7) a stranger-shaped
  signup on the built-in mailer cannot receive its confirmation email
  even with signups ON. Three arms (runbook §1): add the probe address
  to the org team for the window · toggle email confirmations OFF
  (autoconfirm) — also a legitimate launch posture to rule deliberately
  · admin-provision via the standing `generate_link` road. The
  confirmations-toggle posture (ON-with-SMTP at 14d vs autoconfirm) is
  a sitting-worthy call, recorded not made. The app face for the
  refusal is already honest either way (the
  `email_address_not_authorized` arm).
- **The probe-account entitlement grant now has its deliberate tool**:
  `entitlement_set('<probe-uid>', 'hosted_sync', true, null,
  'probe-setup')` as service_role — 09's header records it.
- **The site handoff block below is ready for her tasking** of the
  stargazing.tech agent; the processor decision rides that tasking
  (Round 7's letter).
- 09 remains AUTHORED NEVER DEPLOYED; the marker is still the file's
  last statement (pinned); batch 3's section rides the same gate
  deploy.
- The runbook flags one genuine Supabase docs discrepancy (OTP default
  30/hr vs 360/hr across two official pages) — read the dashboard's
  shown value at the 14d act.

### Cold-review ladder — ROUND 1 (2026-08-05; fresh Fable reviewer, REVIEW_PROMPT verbatim, zero implementation context)

**Scope reviewed:** the full phase diff `01fc2a7..6d34fae` (batches 1–3),
the 09 SQL artifact read line-by-line as deployed-at-gate production SQL,
every new/changed core and App source, the harness rework, and the suites.
**Runs performed by the reviewer:** full core suite — **1193 tests / 127
suites GREEN** (matches the batch-3 record exactly); targeted Mac run over
the phase's eight new/touched suites (AccountLifecycleDoorTests ·
AccountDoorWiringTests · FreshAccountSetupGeneralityTests ·
HostedSyncTierFaceTests · HostedSyncStatusReadTests ·
SignUpPresentationTests · AuthSessionTests · CrossoverRoundTests) — **40/8
GREEN**. Zero-diff on the engine inland re-verified on the whole phase
range (`Merge.swift` / `Repairs.swift` / `SyncEncryption.swift` /
`SyncScheduler.swift` — 0 lines); zero changes under `Persistence/`,
`Models/`, `Operations/`, `Domain/`, `Queries/` (THE DESIGN 7's
no-local-schema letter holds).

**Findings, severity-ranked:**

**[MAJOR] R1-1 · `Sources/VariorumCore/Crypto/AccountRekey.swift:100–147`
(doc 48–56) + `App/Variorum/Shared/AppServices.swift:423–447` — the
re-key's CRASH windows between steps 2 and 5 leave silent, unsignaled
states; the recorded "the surface speaks that road on every failure"
(batch-2 record) holds only for THROWN failures — a crash has no surface,
and nothing persisted re-speaks the rerun road on relaunch.** Two traced
arms:
  *(a) crash after the truncate returns (step 4), before
  `resyncReinitialize` commits (step 5):* the device holds NEW custody +
  the NEW vault, so every later round passes the fence; the outbox holds
  only rows dirty at crash time (those self-heal via the engine's
  nil-current rebase, SyncEngine.swift:139–146); every CLEAN row never
  re-enqueues — the mirror silently holds a near-empty corpus while the
  sync row reads idle. No CF-16, no error, no prompt to re-run the door.
  On a product whose one paid promise is the hosted E2EE copy, the backup
  is silently gone until the user happens to re-run the door.
  *(b) crash after custody adoption (step 3), before the truncate (step
  4):* the mirror keeps the OLD-key corpus and the old master was
  discarded in step 1 — those rows are permanently unopenable. This
  device syncs on quietly (fence passes); a LATER second-device
  enrollment pulls the old-key rows and refuses as payload-crypto wearing
  the CF-16 face, whose prescription ("Re-enroll…") cannot heal it — the
  key that sealed those rows no longer exists anywhere; the actual fix
  (re-run the re-key door on the first device) is named nowhere.
  *Partial mitigation observed, honestly:* on next `EncryptionSession
  .refresh()` the state lands in `enrolled(hasRecoveryWrap: false)` — the
  CF-5 mandatory-phrase step presents — so the user sees SOMETHING
  changed; but completing the phrase step heals the recovery wrap only,
  never the truncate/reinit halves. The `AccountRekey` doc comment
  analyzes exactly one crash window (2→3, the visible one) and is silent
  on 3→4 and 4→5, so the recorded analysis reads complete while the two
  silent windows are the dangerous ones.
  *Proposed fix (small, pinnable):* persist a rekey-in-progress marker
  (device Keychain beside custody, or `sync_state`) written before step 2
  and cleared only after step 5 completes; at composition/refresh, a set
  marker re-speaks the rerun road (and may refuse rounds until re-run).
  Red-on-old pin: set the marker, rebuild the world (the relaunch shape),
  assert the surface speaks / rounds refuse — fails on today's code.

**[MINOR] R1-2 · `Server/supabase/09_phase14c_multitenant.sql:971–974,
1045` + `Tests/VariorumCoreTests/AuthRLSDDLTests.swift:389–407` + the
batch-2 record above — the purge order's stated mechanism is FALSE:
`key_vault.user_id`'s FK is `ON DELETE CASCADE`
(08_phase14b_lockstep.sql:61–62), not RESTRICT.** The 09 header says "the
vault row must die before the user row can", line 1045 says "key_vault's
FK is gone now" (implying necessity), the DDL pin's comment says the
order is "load-bearing", and the batch-2 record pinned the same claim —
but with CASCADE, deleting `auth.users` first would succeed and cascade
the vault row. Behavior is unaffected (explicit deletes work and the
counts report stays accurate; `entitlement` has no FK at all), but
deployed production SQL now teaches a wrong invariant — the drift class
these comments exist to prevent (a future editor could "rely" on a
RESTRICT that does not exist). *Fix:* correct the three comments + the
record; keep the order as the deliberate reporting/clarity choice it
actually is. No test pin needed (comment-accuracy class; the order pin
itself stays).

**[MINOR] R1-3 · `App/Variorum/Shared/TierViews.swift:78–95` —
`HostedSyncTier.isCurrent`/`expiryLine` cannot parse PostgREST's
fractional-second `timestamptz` output, making the fail-open
"unparseable counts current" arm the LIKELY arm, not a corner.**
`DateFormatter.variorumISO8601` demands `yyyy-MM-dd'T'HH:mm:ss.SSS'Z'`
(VariorumRecord.swift:31–37 — fails on `+00:00` offsets and 6-digit
fractions) and the fallback `ISO8601DateFormatter()` lacks
`.withFractionalSeconds` (fails on any fraction). PostgREST serializes
`timestamptz` with microseconds whenever they are non-zero — so an
`expires_at` carrying fractional seconds (a processor-passed ISO with
fractions; any server-computed stamp) parses nil → counts CURRENT → an
EXPIRED subscription's Account tab shows "Hosted sync is active" (and
the deletion door derives "cancel it first") while the server refuses
rounds. Display-only, and fail-open is the RECORDED design call for
gating — but the recorded intent was a parse-QUIRK escape hatch, not the
common integration shape. *Fix:* add an `ISO8601DateFormatter` with
`.withInternetDateTime, .withFractionalSeconds` as a second fallback.
Red-on-old pin: a past expiry with `.123456+00:00` must project
`.inactive` — fails today.

**[NIT] R1-4 · `App/Variorum/Shared/AppServices.swift:431–435` — the
custody-adoption closure captures `[weak self]`; if AppServices were gone
mid-run, `onNewVaultMaterial` completes WITHOUT adopting and the brain
proceeds to the truncate, making this device the stale writer against its
own re-key.** Practically unreachable (AppServices is app-lifetime), but
the brain's contract ("custody must land before the truncate") is
enforced by convention only — a strong capture (the closure dies with the
run anyway) or a throwing adoption contract would make it structural.

**[NIT] R1-5 · `App/Variorum/Shared/ErrorPresentation.swift:68–80` — the
sign-up block's doc comment was inserted between `signInFailureMessage`'s
doc comment and its declaration**, so the sign-in commentary ("…is
exactly wrong on the sign-in form itself") now reads as documentation for
`signUpClosedMessage`, and `signInFailureMessage` (line ~137) is left
undocumented. Comment-placement only; move the orphaned lines back above
their function.

**Clean bill — load-bearing things specifically checked and found solid:**

- **The 09 artifact as production SQL:** all 18 tables verified reborn
  with `(owner_id, id)` / `(owner_id, key)` composite PKs, FORCE RLS +
  no-`to`-clause owner policies (correct under FORCE for the definer),
  privilege revokes, stamp triggers, `(owner_id, server_seq)` indexes; NO
  uniqueness/FKs/checks beyond the PKs (SyncSpec §2's dumbness preserved,
  the header says so loudly); the old RPC signatures dropped FIRST (the
  cross-tenant read door named and closed); `caller` correctly uuid-typed;
  the CAS delete+insert shape byte-faithful to 06's (verified against
  06:200–210) now tenant-scoped on every seek/delete/insert; the reject
  payload subtracts `owner_id` for the ten and keeps it for the eight; a
  malicious `owner_id` inside a ten-table payload is overridden by the
  server stamp (`||` right-side wins — traced); `%L`/`%I`/`using`
  parameterization sound throughout (no injection road found); the A5
  horizon clause verbatim in every branch (18 `from %I t` = 18 owner
  filters, and the pin counts them); the marker bump is the file's LAST
  statement with `on conflict (key) do update` (line 1165–1166 — a
  re-runnable deploy); the fence reads `key_vault` (ENABLE-only RLS, so
  the definer-owner read works — verified against 08:107; the batch-1
  "policies deliberately role-unrestricted" reasoning applies to the 18
  FORCED tables and holds).
- **The fence + entitlement gates:** auth → fence → entitlement order in
  both RPC bodies AND the truncate; missing-vault refuses at the fence
  (the purge backstop for the JWT-until-expiry window — pinned);
  `entitlement` correctly RLS-enabled-not-forced (the definer must read
  it); `entitlement_set` service_role-only with authenticated revoked by
  name; the truncate never touches key_vault/entitlement/sync_meta and
  never TRUNCATEs (registry-exact table list pinned via the shared array
  parser).
- **The engine wire:** `activeKeyID` REQUIRED on the protocol (no
  default — a fence-dropping wrapper cannot compile), sent on BOTH
  halves from the round's own key world (`crypto.keys.corpusKeyID` — the
  id that seals is the id presented, so it cannot diverge); marker-token
  classification at both transports (`SupabaseTransport.classifiedFailure`
  + `AccountLifecycleClient.classified`), tokens pinned to the SQL by the
  DDL tests; both new `SyncError` cases refuse with outbox intact +
  cursor unmoved (verified in the fence suite's assertions).
- **The two-user suites are real proofs, not smoke:** the fence test
  asserts outbox/cursor/server-rows unchanged through both refused
  halves, then walks the WHOLE CF-8 heal to convergence with the old key
  provably unable to open the re-sealed corpus; the empty-store pin's
  honest reshape (seeded settings ARE the first push) matches the schema
  truth; the colliding-ids, scoped-settings, and in-partition-repair
  suites each pin the exact pre-14c failure class.
- **The re-key brain's THROWN-failure story:** wrong passphrase touches
  nothing; a failed truncate leaves the new vault + custody and the rerun
  completes whole (both pinned); the CAS-guarded `updateVault`
  (`expectedRevision`) refuses a vault moved mid-flow; KDF work runs off
  the MainActor (nonisolated async brain); custody adoption awaited
  before the truncate. (The crash-window gap is R1-1.)
- **The deletion door:** purge → forget → sign-out order wired and
  pinned; a refused deletion clears NOTHING local (wrong-passphrase arm
  pinned); her byte-pinned local-copy-survives copy present and pinned;
  the vault-less arm matches PROVISIONAL B2-1's letter; sync stopped
  around both doors with reconnect on every failure arm.
- **The 14d prep's dormancy:** `DeviceBridgeKeyProvider` grep-verified
  wired nowhere in production (`makeBridgeKeyProvider` stays nil);
  `stageRepushFromTruth`'s sentinel can collide with no hex hash; staging
  preserves stamps/created_at and skips stamp-only rows (pinned);
  `db.changesCount` is the correct GRDB read for the staged count.
- **Harness fidelity:** the fake's gate order (account → fence →
  entitlement) and whole-batch owner-refusal match the RPC bodies;
  `wipe()` preserves provisioning exactly as the real truncate spares
  key_vault/entitlement; auto-adopt is opt-in only (fence suites always
  set explicit ids); the `SyncClient` signed-in default matches the
  born-multi-tenant reality and the OwnerIdentityTests rewrite is
  coherent with the retired pre-9c mirror.
- **Serializer walk:** drop-aware parsing traced correct (a rebuild
  REPLACES the accumulated set; red-on-old pin feeds doctored SQL);
  `entitlement` in the server-only set; conditional `owner_id`-as-server-
  machinery only where the client schema lacks the column.
- **No P1/S1–S5 violations anywhere in the diff:** no text copied across
  entities, nothing scales with corpus size client-side (the pull union
  rides the per-tenant indexes), tombstone semantics untouched (the
  mirror truncate/purge are the RULED server-side acts, not domain
  deletes), wall clocks nowhere near ordering (`updated_at` is display
  bookkeeping; `revision` stays the CAS token — the R2-1 decision's
  letter honored).
- **The doors' Keychain-on-MainActor cadence** (adopt/forget in the new
  flows) reuses exactly the paths already inside the OWNED KnownIssues
  row (13e's settings-cadence family) — no NEW unowned debt.

### Ladder fix record (round 1 → 2) — fix session, 2026-08-05

*(Fresh Fable fix session per the ladder; every finding independently
traced before any fix — the hallucination guard's letter; every
bug-class pin verified by BEHAVIORAL REVERT with the exact red recorded.
Commits: `419eeba` (R1-2 SQL) · `1df2e24` (R1-2 record) · `a1b9953`
(R1-3) · `28e3376` (R1-4+R1-5) · `5a207ec` (R1-1).)*

**R1-1 (MAJOR) — FIXED.** *Independent trace, all three windows
confirmed against the shipped code:* **4→5** — `account_data_truncate`
row-DELETEs mint no changefeed entries and `resyncReinitialize` is ONE
write transaction, so a crash between them leaves sync_versions
non-zero, the cursor at head, and the outbox holding only
crash-time-dirty rows; on relaunch the fence passes (custody + vault
both new), the pull serves nothing, the dirty rows self-heal through
the nil-current rebase (SyncEngine.swift:140–146) and every CLEAN row
never re-enqueues — the mirror silently holds a near-empty corpus while
the row reads idle. **3→4** — the vault replacement destroys the old
master's wrapped copy (step 1 discards the unwrap; step 2 replaces the
row), and this device's cursor sits at head so it never decrypts the
old-key rows; rounds pass the fence and the mirror becomes a mixed-key
corpus — silent here, permanent `payloadCryptoFailure` for any
later-enrolling device, with CF-16's "re-enroll" prescription unable to
heal it. **2→3** — visible as CF-16 on this device, but its re-enroll
heal lands EXACTLY in the 3→4 silent state (custody healed, truncate
never run), so even the "visible" window needed the completing prompt.
*The fix (the reviewer's proposed shape, strengthened):*
`AccountRekeyMarker` — a persisted rekey-in-progress marker in the
LOCAL-ONLY `sync_state` keyspace (never synced by design; survives
`resyncReinitialize` by construction — it deletes only the cursor key;
deliberately NOT the Keychain, which would grow the owned 13e
settings-cadence SecItem family at round cadence). Written after
authorization and BEFORE the vault write (so 2→3 is covered too);
cleared ONLY when the WHOLE road completes — after step 6, a superset
of the reviewer's after-step-5 that protects the bridge-staging leg for
14d; a step-2 failure keeps it set on purpose (an `updateVault` network
failure is ambiguous — the write may have landed — and the rerun is the
universal heal, the pinned doctrine's own letter). Enforcement: BOTH
engine round halves refuse first (`SyncError.accountRekeyIncomplete` —
outbox intact, cursor unmoved, the §12 grammar; `resyncReinitialize`
deliberately unguarded so the brain's step 5 runs). The surface SPEAKS
on both form factors through the shared seam: a dedicated sync-row
state (`.rekeyIncomplete`, one door "Finish key replacement…" straight
to the Encryption tab — deliberately never the replaced-keys row, whose
re-enroll cannot complete a half-run re-key) and an Encryption-surface
banner above EVERY state arm carrying the completing Replace door (the
brain's rerun heals every window state, from `.keysReplaced` included);
account deletion clears the marker (a purged account owes no
completion). The RULED order is untouched — the marker brackets it; the
`AccountRekey` doc comment now analyzes all three windows (the
reviewer's observed gap). Sync/ footprint: SyncEngine +21, SyncSchema
+13; Merge/Repairs/SyncEncryption/SyncScheduler ZERO-diff across the
whole fix range (verified). One closeout note: `sync_state` gains its
third key (`rekey_in_progress`) — AppSpec §7's `-- keys:` comment line
is the closeout's to update with the delta, flagged here rather than
edited canon mid-ladder. *Pins + behavioral-revert evidence:*
`theRekeyMarkerRefusesRoundsAcrossRelaunchUntilTheDoorCompletes` (core;
engine check neutralized → RED 5 issues: both "an error was expected
but none was thrown", `outboxCount == outboxBefore` failed, "(cursorAfter
→ \"5\") == (cursorBefore → nil)", server rowCount changed — the exact
silent mechanism); the ORDER pin's new marker half (brain's marker
write removed → RED: "vault-write:…:marker=clear" ≠ "…:marker=set") and
`aFailedTruncateLeavesTheRerunRoadThatCompletes`'s marker half (same
revert → RED on `markerMidRoad`); the wrong-passphrase test's
no-marker-residue arm; `theRekeyIncompleteRowSpeaksTheFinishRoad` (Mac;
classifier arm neutralized → RED: "(face.kind → .error)" with the
generic Retry/Account doors — the pre-fix presentation);
`theSurfaceReSpeaksTheRerunRoadFromThePersistedMarker` +
`thePersistedMarkerReachesTheSurfaceAndDeletionClearsIt` (refresh read
removed → RED on `rekeyIncomplete → false` in both) +
`aFailedRekeyKeepsTheBannerUp`; plus marker-clear assertions riding the
standing order/wiring pins. All restored green after each revert.

**R1-2 (MINOR) — FIXED (comment/record class, no pin per the finding).**
*Independent trace:* `08_phase14b_lockstep.sql:61–62` declares
`user_id uuid primary key references auth.users (id) on delete cascade`
— deleting the auth user first would succeed and cascade the vault row,
so the three "vault must die before the user row can / load-bearing"
claims described a RESTRICT that does not exist. *Fix:* 09's section-7
header and in-body comment corrected (its own commit — the SQL-artifact
convention; zero statements changed, still AUTHORED NEVER DEPLOYED);
the DDL pin's doc + inline comments corrected (the order assertions
stand — the order is the RULED reporting shape, now named as a
deliberate choice); the batch-2 record's dated correction APPENDED
below its original text, never rewritten.

**R1-3 (MINOR) — FIXED.** *Independent trace, reproduced empirically in
a scratch run before fixing:* `variorumISO8601` (`.SSS'Z'`) parses no
offset shape; plain `ISO8601DateFormatter` parses no fraction — so
`2020-01-01T00:00:00.123456+00:00` → nil under BOTH arms → counts
CURRENT; and PostgREST serializes `timestamptz` with microseconds
whenever non-zero, making that the common integration shape. The same
scratch run verified `.withFractionalSeconds` parses 1–6 fractional
digits on the deployment OSes (the historical exactly-3 limitation is
gone), so the reviewer's proposed fallback is sufficient. *Fix:* one
shared `HostedSyncTier.parseServerTimestamp` (canonical → plain →
fractional) feeding `isCurrent` AND `expiryLine`; the fail-open arm
survives for genuinely alien text (the recorded design call). *Pin:*
`postgRESTFractionalTimestampsParseAndExpire` — run LITERALLY red-on-old
(written first, executed on the pre-fix tree → RED, 3 issues: the past
fractional expiry counted current, the trimmed-zero shape counted
current, `expiryLine` nil on a real date), then green after the fix.

**R1-4 (NIT) — FIXED (structural class, traced justification, no pin
per the guard's architectural arm).** *Independent trace:* with
`[weak self]`, a deallocated AppServices makes `onNewVaultMaterial`
complete WITHOUT adopting; the brain (which cannot know) proceeds to
the truncate, leaving this device the stale writer against its own
re-key. Practically unreachable — AppServices is app-lifetime and the
door is only drivable from its live UI — hence no pin: a red-on-old
test would require deallocating AppServices mid-run, a state the app
cannot reach. *Fix (smallest honest):* STRONG capture — the closure
lives only for the run (the brain is a local), so the strong reference
makes the adopt-before-truncate contract structural at zero cycle risk;
the alternative throwing-adoption contract would have reshaped the core
type for a hazard the capture eliminates outright.

**R1-5 (NIT) — FIXED (comment placement, no pin).** *Independent
trace:* the 14a sign-in doc block and the 14c sign-up block form one
contiguous `///` run above `signUpClosedMessage`, so the sign-in
commentary ("…exactly wrong on the sign-in form itself") documented the
wrong declaration and `signInFailureMessage` sat bare. *Fix:* the block
moved home above `signInFailureMessage`, with a one-line dated note of
the move.

**Verification (all synchronous):** core **1194/127 GREEN** (was
1193/127 — +1 the relaunch pin, exactly accounted) · Mac touched
suites + the tutorial spine **111/19 GREEN** (EncryptionFlowTests'
eight suites · TierAndOnboardingTests' three · AuthSessionTests · the
seven `Tutorial*Tests`; the full-suite baseline 1240/219 tripwire-only
stands per the no-full-suite-rerun discipline — this session's Mac
delta is +5 tests in already-run suites, all green) · mobile
**175/26 GREEN** (iPhone 17 simulator — the shared seam carries the
banner, the row state, and the classifier; no mobile-only code) ·
engine inland ZERO-diff re-verified. Ready for ROUND 2 (the reviewer's
re-review over these fixes).

### Cold-review ladder — ROUND 2 (2026-08-05; fresh reviewer anchored on round 1's findings + dispositions + the fix record)

**Scope re-reviewed:** the whole fix range `b9fcc3a..9159460` (all six
fix commits plus the gate-handoff draft that rides the range) read
line-by-line; every marker-lifecycle claim verified against the CODE,
not the record; `notes/SyncSpec.md`'s refusal grammar and
`notes/sync-postmortem-fragments.md` read per the prompt before judging
the engine lines. **Runs performed by this reviewer (all synchronous):**
core **1194/127 GREEN** (matches the fix record exactly — +1 the
relaunch pin over round 1's 1193); Mac touched suites **60/12 GREEN**
(the EncryptionFlowTests eight + TierAndOnboardingTests' three +
AuthSessionTests) + the tutorial spine **51/7 GREEN** — together the fix
record's 111/19, reproduced; engine-inland zero-diff re-verified on the
fix range (`Merge.swift` / `Repairs.swift` / `SyncEncryption.swift` /
`SyncScheduler.swift` — 0 lines; `Persistence/`, `Models/`,
`Operations/`, `Domain/`, `Queries/` — 0 lines). **One pin
independently revert-verified:** in a scratch worktree (main tree
untouched) the engine's marker guard was neutralized and
`theRekeyMarkerRefusesRoundsAcrossRelaunchUntilTheDoorCompletes` run —
RED with the EXACT recorded five issues (both "an error was expected
but none was thrown", the outbox drained past `outboxBefore`, cursor
nil→"5", server rows changed), then the worktree removed. The MAJOR's
red-on-old claim is real, not narrated.

**Per-finding verdicts:**

**R1-1 (MAJOR) — fix SOUND.** Every lifecycle claim verified against
the code: the marker is written after authorization and BEFORE the
vault write (`AccountRekey.swift:127` — so the 2→3 window is bracketed
too) and cleared ONLY after step 6 (`:181` — the bridge-staging leg
included); it survives `resyncReinitialize` by construction
(`SyncEngine.swift:378` deletes only `last_server_seq`; the marker key
is untouched); BOTH round halves refuse FIRST (`SyncEngine.swift:102`
push, `:247` pull — before `ensureDeviceID`, keys, lockstep, and any
network contact), throwing `SyncError.accountRekeyIncomplete` with
outbox intact and cursor unmoved — the §12 grammar exactly, and the pin
asserts all three (outbox count, cursor, server rows);
`resyncReinitialize` is deliberately unguarded so the brain's own step
5 runs (verified: it is not a round half and touches no network);
account deletion clears the marker (`AppServices.swift:483`); the
wrong-passphrase arm leaves no residue (marker set only after the
unwrap succeeds — pinned). The surface story holds on both legs: the
banner rides above EVERY Encryption state arm
(`EncryptionViews.swift:227`; the enrolled arm's own Replace door is
suppressed while the banner carries it — no doubled `showingRekey`
flow, exactly two render sites for `rekeySection`), `refresh()`
re-projects the marker on every launch (`EncryptionSession.swift:127`)
and `rekeyAccount` re-reads it after every run (`:296`); the sync row's
`.rekeyIncomplete` face is its own state with the one completing door,
classified by exact string equality and pinned disjoint from
keysLocked/keysReplaced/payload-crypto/notEntitled both ways. The
scheduler surfaces the error verbatim (`String(describing:)` = the
`description` the classifier matches), nils `lastError` only on a
successful round, and the offline classifier is a URLError-code
allowlist — the new refusal can never wear the offline face. The
harness's "fresh engine per call = the relaunch shape" claim is true
(`SyncTestHarness.swift:110–125` builds a new `SyncEngine` per
push/pull over the same store). Nothing new introduced: the marker
lives outside `SyncSchema.tables` (never serialized, no triggers watch
`sync_state`), the completeness walk is untouched, and the Sync/
footprint is the recorded +21/+13 with the four inland files zero-diff.

**R1-2 (MINOR) — fix SOUND.** The factual basis re-verified at the
source: `08_phase14b_lockstep.sql:61–62` declares `references
auth.users (id) on delete cascade` — the finding's letter. `419eeba`
changes comment lines only (zero SQL statements — verified in the
diff); the 09 header and in-body comment now name the purge order as
the deliberate reporting/clarity choice; the DDL pin's comments
corrected with the order assertions intact; the batch-2 record's
correction APPENDED below the original, dated, never rewritten.

**R1-3 (MINOR) — fix SOUND.** Mechanism re-traced independently:
`variorumISO8601` (`.SSS'Z'`, POSIX/UTC) cannot parse an offset shape;
plain `ISO8601DateFormatter` cannot parse a fraction — so the pre-fix
arms both returned nil on `….123456+00:00` and fail-open counted an
expired subscription current. The shared `parseServerTimestamp`
(canonical → plain → `.withFractionalSeconds`) feeds `isCurrent` AND
`expiryLine`; the pin covers the 6-digit, trimmed-fraction,
no-fraction-offset, and expiryLine arms and runs green now; the
fail-open arm survives for genuinely alien text — the recorded design
call, honored not widened.

**R1-4 (NIT) — fix SOUND.** The strong capture makes
adopt-before-truncate structural; the closure dies with the local brain
so there is no cycle (the outer `rekeyRunner` door closure keeps its
`[weak self]` + throw, correctly — a gone AppServices REFUSES rather
than proceeds). The no-pin justification is legitimate under the
guard's architectural arm: the red state requires deallocating an
app-lifetime object mid-run.

**R1-5 (NIT) — fix SOUND.** The sign-in doc block sits above
`signInFailureMessage` with a dated moved-home note;
`signUpClosedMessage` keeps only its own commentary.

**NEW findings (none BLOCKER/MAJOR — by the ladder rule, NO round 3):**

**[NIT] R2-1 · `App/Variorum/Shared/EncryptionViews.swift:227` +
`EncryptionSession.swift:127` — the banner and its Replace door render
above the `.signedOut` arm too, where the door can only fail and the
thrown-arm's prescription is the wrong one.** Traced: `refresh()` reads
the marker before the signed-in guard (deliberately — the banner is
"above EVERY state arm"), so a crash-mid-re-key followed by sign-out
relaunches into the banner; pressing Replace runs the brain, whose step
1 `fetchVault` throws signed-out, and `rekeyAccount`'s catch speaks
"run Replace Keys again" when the actual prerequisite is signing in.
Mitigations already in place: the state arm directly below says "Sign
in first — your encryption vault lives on your account", nothing is
silent, nothing is lost, and the rerun completes after sign-in — hence
NIT, not MINOR. Fix if wanted: keep the prompt, suppress the banner's
button in `.signedOut` (one conditional; pinnable — signedOut + marker
⇒ no Replace button, red on today's code).

**Observations recorded so nobody re-derives them (no severity):**
(1) a step-2 CAS refusal (`expectedRevision` mismatch — a DEFINITIVE
no-write, unlike the ambiguous network arm the fix comment names) also
keeps the marker set; harmless and arguably right — in that state the
vault moved, this device is stale, rounds would refuse at the fence
regardless, and the rerun heals. (2) `AccountRekeyMarker.set` stamps
wall-clock `Date()` directly rather than `@Dependency(\.date)` —
documented deliberate in its doc comment (support honesty; `isSet`
checks presence only, nothing reads or orders by the value; the
`key_vault.updated_at` precedent); not a finding. (3) CARRIED FORWARD
for the closeout: AppSpec §7's `sync_state` `-- keys:` comment still
lists two keys — the third (`rekey_in_progress`) is the closeout's
delta to record, per the fix record's own flag. (4) the `.newerFormat`
+ marker double-corner resolves into a spoken refusal (the
refuse-by-format-version posture throws at fetch/unwrap before any
vault write), never a silent format downgrade — checked, clean.

**Clean bill — what this round specifically checked and found solid:**
the marker's engine read is one DB read per round half at round
cadence, off the main thread through the reader pool (P2; no P1
scaling); `runAccountRekey`'s catch reconnects the chain and the
reconnected rounds refuse into the new row state — the crash story and
the thrown story converge on one surface; deletion's `try?` clear can
at worst leave a marker that re-prompts a completable rerun, never
silence; the gate-handoff draft's "marker" mentions are all the
LOCKSTEP marker (5→6), no staleness against the new machinery; the
`VaultBootstrap` gate runner is unaffected (a marker on her store
cannot exist absent a crashed re-key, and if it ever did the runner
refuses visibly); the mobile seam claim verified STRUCTURALLY — the
`Shared` folder is a synchronized group compiled into the
`VariorumMobile` target, so the banner/row/classifier ride with zero
mobile-only code (the simulator run itself accepted from the fix
record per this round's core+Mac run mandate); no TODO/debug residue
anywhere in the fix range; the postmortem's delicate classes (clock
trust, changefeed, round order, serializer completeness) are all
untouched by the fixes.

**VERDICT: all five round-1 fixes SOUND; one NEW NIT (R2-1); no new
BLOCKER/MAJOR — the ladder closes at round 2.**

### The stargazing.tech checkout — contract facts (for the site's own
### agent)

*(This block is the handoff the site's agent builds from — she tasks
that agent; this repo never writes site code. Everything here is
price-agnostic: she names the number at launch.)*

- **What is sold:** the suite's ONE hosted-sync plan. One payment
  covers Variorum AND Fragments (the author's suite ruling —
  *[removed for publication]*
  ONE suite account and both apps check it (Fragments' check lands in
  its own later batch — the page may promise suite coverage; the apps'
  in-app copy deliberately claims only their own behavior until then).
- **What the page promises (aligned with shipped app copy):** hosted
  sync keeps an end-to-end encrypted copy of the user's writing — the
  server can never read it; the apps work FULLY without the tier
  (everything stays on-device); no price shown until she names one.
- **The account model:** Supabase auth on the Variorum project; a user
  IS an auth user (uuid). Sign-in for the checkout uses the SAME
  project's auth (publishable key + `/auth/v1/token?grant_type=password`
  — or the site's own session flow against the same issuer). **The
  checkout MUST capture the buyer's account uuid at purchase time**
  (require suite sign-in before checkout; store the uuid in the
  processor's customer metadata) — the webhook maps processor customer
  → uuid.
- **The issuer hostname:** `auth.stargazing.tech` fronts the auth
  service once attached at the 14c gate (until then the raw
  *[removed for publication]*
  pages and the checkout itself are ordinary stargazing.tech content —
  no special domain work (the Round-7 ruling).
- **The entitlement write (the ONE server integration):** on payment
  events the site's SERVER-SIDE webhook calls the `entitlement_set`
  RPC with the SERVICE-ROLE key — never from a browser; the
  service-role key is a server secret:
  `POST {projectURL}/rest/v1/rpc/entitlement_set` with JSON body
  `{"target_user": "<uuid>", "target_feature": "hosted_sync",
  "active": true, "valid_until": "<ISO8601 or null>",
  "via": "<processor>:<subscription id>"}`.
  Semantics: grant is an UPSERT (send it on checkout-complete AND on
  every renewal, `valid_until` = the period end — a lapsed subscription
  self-expires server-side even if a later webhook never fires); revoke
  is `"active": false` (a row DELETE). The apps never write
  entitlement; `authenticated` holds no execute grant on this function.
- **How activation reaches the apps (no site work):** the apps READ
  their own entitlement row (owner-only SELECT) and the sync RPCs gate
  server-side (`VARIORUM_NO_ENTITLEMENT`); an activated plan heals on
  the user's next sync round — no app release, no site callback.
- **Cancellation/management UX is the checkout's own duty:** the apps'
  account-deletion door warns "cancel your subscription first" and can
  only best-effort read the entitlement — subscription management
  lives with the processor, i.e. on the site.
- **Processor choice:** hers, decided when she tasks the site agent
  (Round 7's record: easy to change before real subscribers — this
  function is processor-agnostic by design; sticky after, because
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*

## Ledger (running; every row owned)

| # | Item | Status |
|---|------|--------|
| L1 | 09 artifact: rebuild DDL + tenant-scoped RPCs + forced RLS + fence + entitlement table; lockstepVersion 6 same-commit | **done — batch 1** (`b6b2c7e`; artifact AUTHORED NEVER DEPLOYED — the deploy is the gate's) |
| L2 | Engine wire: key id per round; CF-16 fence surfacing; Merge/Repairs zero-diff proof | **done — batch 1** (`b40deeb` + `a6bf612`; zero-diff proven on the batch range — the record above) |
| L3 | Fake-server multi-user parity + TWO-USER convergence suites + in-partition repairs + scoped settings | **done — batch 1** (`b40deeb` + `9316d5b`; 8 suites, all guards revert-verified red-on-old) |
| L4 | CF-8 re-key door (vault-first order pinned; truncate RPC; bridge trigger inert-until-14d) | **done — batch 2** (`ae1b4c6`+`8bedbe2`+`f564e00`; the order revert-verified red-on-old; the app door lands in the CF-5 mandatory-phrase step) |
| L5 | Account deletion door (purge RPC; local-copy-survives copy PINNED; custody cleanup) | **done — batch 2** (same commits; her copy rule byte-pinned; the definer auth-user removal verified by lookup, the fence backstop pinned; purge→forget→signOut wired) |
| L6 | Runner drain-summary fix + key_vault.updated_at decision | **done — batch 2** (`8bedbe2`; the summary counts the outbox drain — the drill's 674-of-7,274 class, red-on-old; updated_at DECIDED write-on-update with reasons) |
| L7 | Entitlement machinery + hosted-sync gate UX (price-agnostic) | **done — batch 3** (`6c205e8`; the `.notEntitled` face wears the IDLE doors literally — reads-as-normal pinned as data equality, red-on-old vs the generic error face; TierViews.swift the tier's one home, copy price-agnostic-pinned; B2-3 promoted — ONE entitlement read feeds `AccountState.hostedSync`, the deletion note derives) |
| L8 | Sign-up surface + fresh-account vault provisioning + empty-store onboarding | **done — batch 3** (same commit; `AuthSession.signUp` through the 14a seam, refusals classify-and-speak incl. the closed-door signups-off voice + the source-verified `email_address_not_authorized` arm; the confirmation notice enumeration-honest; FRESH-ACCOUNT GENERALITY pinned over arbitrary uids; the empty-store first pull pinned zero-row-clean at the engine with her corpus invisible) |
| L9 | Entitlement-write server function + the site-agent contract block (checkout is the site's build) | **done — batch 3** (`entitlement_set` in 09 section 8, `dc077ca` its own commit — processor-agnostic, service_role-only, grant=upsert/revoke=delete, DDL-pinned; the probe grant's deliberate tool; the contract block written into this file below the batch-3 record) |
| L10 | SMTP runbook + template copy + rate/abuse limits (the config ACT re-owned to 14d, Round 7) | **done — batch 3** (`notes/plans/phase-14c-smtp-runbook.md` — dashboard act step-by-step, Cloudflare DNS shape incl. the grey-cloud CNAME trap, reasoned provider recommendation, limits with reasons, template DRAFTS for her ratify; NO config act, NO dashboard contact; the built-in-mailer team-only fact flagged as a gate consideration) |
| L11 | The ladder (combined diff) | pending |
| L12 | The DEDICATED isolation-boundary review round (her proof-bar ruling) | pending |
| L13 | The gate: deploy · repush · phone re-onboard · live probes (second account on <her-email>, uid-checked, entitlement-granted; BYPASSRLS check) · auth.stargazing.tech + iss (Cloudflare, hers) · the signup flip (architect-driven per Round 7) · stranger validation (incl. PL-6 phone walk) | pending — announced per step; deploy/probes/flip architect-driven at her Round-7 delegation |
| L14 | Closeout ritual in full (incl. the 14d micro-plan + the finalized contract brief; the §12 running record's 5→6 entry; the KnownIssues auth row resolved/re-owned) | pending |
| L15 | The 14d prep: live journal-bridge provider + staged re-push machinery, dormant behind the standing pause, both halves pinned (Round-6 ruling) | **done — batch 2** (`8bedbe2`+`f564e00`; DeviceBridgeKeyProvider built, wired NOWHERE; stageRepushFromTruth with the sentinel design revert-proven; dormancy AND readiness pinned; the re-key door's trigger connected, inert) |

## Environment traps (carried into every batch brief, per the skill)

- Instance checks: `pgrep -fl 'Variorum.app/Contents/MacOS'` AND
  discriminate by PATH; real-store instances treated by STORE, never
  quit/killed; no Release builds or `/Applications` refreshes while
  one lives — and NO refresh that would strand her build's
  lockstepVersion ahead of the deployed marker (the standing rule: the
  refresh WAITS for the gate's deploy).
- The mirror is LIVE production: any dashboard/SQL change announced
  before it happens, committed in-repo artifacts verbatim, her
  explicit go, the A1 rail first. **The signups-off toggle flips ONLY
  at the gate's ruled step (6), by HER hand.**
- Her Variorum-usage pause HOLDS through 14c (Round 1) — one active
  writer; still announce windows before mirror acts.
- Backups WAL-safe with UTC names, ALWAYS before touching the real
  store.
- Mac tests from `App/Variorum/`, suite-level `-only-testing` only;
  zsh `pipestatus`; never a custom build configuration (the 4G trap);
  core tests via `swift test` from the repo root.
- The standing tripwire red (`TakePaneMeasureTests.aStrandedRenderTier…`)
  is BY IDENTITY the one allowed Mac red; anything else is real.
- Baselines (never re-run at session start — 14b's closeout is the
  record): core 1158/124 · Mac 1218/213 (the tripwire) · mobile 175/26
  · spine 51/7.
- Sessions never touch `~/dev/fragments` or the Fragments project
  *[removed for publication]*
  her. The stargazing.tech site has its OWN agent she tasks — this
  repo delivers contract facts, never site code.
- Implementer sessions WAIT SYNCHRONOUSLY on their own builds/tests
  (the 14a background-wait death), and write repo-first records BEFORE
  long verification runs with claims marked PENDING.
- The FRAMING NOTE above binds every subagent brief.

## Verification (the phase's acceptance)

The ruled proof bar in full: two-user convergence suites green over
ciphertext (each fleet independent, zero cross-user rows, in-partition
repairs) · the live stranger-sees-zero probe through both RPCs with
the uid-checked second account · the dedicated isolation review round
closed · the E2EE acceptance carried forward (a stranger's corpus
exactly as unreadable as hers) · her data intact through the rebuild
(row counts exact at the repush, the 14b proof shape) · the re-key
door's fence proven (a stale writer's round refuses with the CF-16
state — pinned in harness, validated at the gate if she wants the
drill) · deletion's purge verified on the second account (probe → its
own deletion is the natural test) · the spine green every batch · zero
KnownIssues rows orphaned.
