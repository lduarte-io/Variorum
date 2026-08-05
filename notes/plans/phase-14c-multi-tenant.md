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
SMTP before the door (the ~2/hr built-in cap; provider = her account,
author-assist), rate/abuse limits recorded with the tier. The PL-6
residual (the phone's first-run FULL-SETUP visual walk) rides the
stranger-onboarding validation.

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

## Ledger (running; every row owned)

| # | Item | Status |
|---|------|--------|
| L1 | 09 artifact: rebuild DDL + tenant-scoped RPCs + forced RLS + fence + entitlement table; lockstepVersion 6 same-commit | pending — batch 1 |
| L2 | Engine wire: key id per round; CF-16 fence surfacing; Merge/Repairs zero-diff proof | pending — batch 1 |
| L3 | Fake-server multi-user parity + TWO-USER convergence suites + in-partition repairs + scoped settings | pending — batch 1 |
| L4 | CF-8 re-key door (vault-first order pinned; truncate RPC; bridge trigger inert-until-14d) | pending — batch 2 |
| L5 | Account deletion door (purge RPC; local-copy-survives copy PINNED; custody cleanup) | pending — batch 2 |
| L6 | Runner drain-summary fix + key_vault.updated_at decision | pending — batch 2 |
| L7 | Entitlement machinery + hosted-sync gate UX (price-agnostic) | pending — batch 3 |
| L8 | Sign-up surface + fresh-account vault provisioning + empty-store onboarding | pending — batch 3 |
| L9 | Entitlement-write server function + the site-agent contract block (checkout is the site's build) | pending — batch 3 |
| L10 | SMTP + rate/abuse limits (author-assist acts recorded) | pending — batch 3 |
| L11 | The ladder (combined diff) | pending |
| L12 | The DEDICATED isolation-boundary review round (her proof-bar ruling) | pending |
| L13 | The gate: deploy · repush · phone re-onboard · live probes (uid-checked second account; BYPASSRLS check) · domain + iss · SMTP · HER signup flip · stranger validation (incl. PL-6 phone walk) | pending — her go per step |
| L14 | Closeout ritual in full (incl. the 14d micro-plan + the finalized contract brief; the §12 running record's 5→6 entry; the KnownIssues auth row resolved/re-owned) | pending |
| L15 | The 14d prep: live journal-bridge provider + staged re-push machinery, dormant behind the standing pause, both halves pinned (Round-6 ruling) | pending — batch 2 |

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
