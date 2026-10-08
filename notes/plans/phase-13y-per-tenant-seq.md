# Phase 13y — Per-Tenant `server_seq` + the Minimal Abuse Guard

> **✔ CLOSED 2026-09-24** — deployed at her window (marker 8→9 live on the production mirror, both devices enrolled under the challenge protocol). The closeout paragraph lives in `notes/PhaseCloseoutArchive.md`. *(Banner added 2026-10-08: the OPEN status line below was never flipped at the close and kept misleading sessions — it is history.)*

**STATUS: OPEN — kicked off 2026-09-22 at her word (`/architect-phase 13y`), the kickoff
sitting's answers below (R-13y-1…4).** Plan authored 2026-08-30 at the 13p closeout;
corrected 2026-09-21 (marker 8→9, the `12_` slot); **REFRESHED 2026-09-22 at this kickoff —
the correction note's rider fold-in is executed in the STEPS below**, so this file reads
top-to-bottom without patch notes. The master-plan 13y row is the scope's record; this plan
is the buildable detail and the phase's ONE running record (ledger, sitting records, unit
records, the ladder, the closeout).

Created PRE-RELEASE at her 2026-08-26 launch-strategy ruling, the moment she ruled sync OPEN
at v1: *"I'm not going to block people from signing in and syncing when the app is first
released… It's cheap now. and it seems like it's better to have it done."*

---

## KICKOFF MESSAGE (for fresh implementer sessions — briefs name sections of this file)

Read, in order: this file top to bottom; `CLAUDE.md` + the canon docs per the standing
preflight; **`notes/SyncSpec.md` IN FULL** (this phase lives in its §2/§3/§5/§7/§9/§12 — the
I-1 disclosure record in §12 is the thing this phase closes); **`notes/sync-postmortem-fragments.md`**
(the standing read before changing anything in `Sync/`); the 14c gate record in
`notes/plans/phase-14c-multi-tenant.md` (the mirror's born-multi-tenant shape, the BYPASSRLS
repair, the `variorum_definer` role); `notes/plans/phase-13j-purge-memo.md` + SyncSpec §12's
13j entry (the deploy-window choreography this phase repeats, and the
`device_cursor`/`purged_row`/`sync_horizon()` machinery it must review);
`notes/plans/pre-13x-deploy-checklist.md` (the most recent window's worked example + §10's
standing caveat this phase retires); `Server/supabase/` DDL 01–11 **+ the `maintenance/`
overlays** (the live mirror's true shape — the deployed truth is 11's function set WITH the
rotation-clearing-guard overlay applied).

**The whole phase is `Sources/VariorumCore/Sync/` + server SQL — the standing Fable rider
applies to ALL of it.** Cast: R-13y-1 below.

**Numbering facts, pinned so nothing collides:** pre-13x took marker **7→8** and claimed
`11_pre13x_postures.sql`; `SyncSchema.lockstepVersion` = **8** today. **This phase takes
marker 8→9 and `12_phase13y_tenant_seq.sql`.** *(The plan's original "7→8 / 11_" claim was
authored before pre-13x existed; corrected 2026-09-21 by the RUN B orchestrator.)*

## THE KICKOFF SITTING RECORD (2026-09-22 — her four answers; verbatim-faithful)

- **R-13y-1 — CAST: all-Fable, RUN B's shape** (her pick of the recommended option): this
  session as orchestrator (writes no feature code beyond adjudication/record/environment
  acts), a **FRESH Fable implementer session per acceptance unit**, strictly sequential, ONE
  `fable-reviewer` ladder over the phase's combined diff (fresh reviewer per round, cap
  three; the SAME-MODEL flow — the orchestrator arbitrates against canon, the spec wins).
- **R-13y-2 — THE DEPLOY WINDOW: PAT pre-authorized, ONE end-of-phase window** (her pick of
  the recommended option): units → ladder → then ONE coordinated sitting — A1 backup, the
  mirror deploy executed by the orchestrator through the stored PAT (the pre-13x §16
  arrangement; if the permission classifier blocks the mutating call, the exact command is
  prepared and SHE fires it via the `!` road — the 13j precedent), the Mac Release + phone
  refreshes (marker-9 builds), her live round each direction, the cursor carry-over verified
  on her real account.
- **R-13y-3 — THE macOS-27 BASELINE: yes** — her words: *"yes my app is quit now"*. The
  TK2-spike §5 re-run PLUS one early full-Mac-suite baseline on the new OS before UNIT A
  spawns (a recorded, justified deviation from "never run the full suite at a session's
  start": the OS under the recorded baseline changed, and TEXTKIT2_NOTES §5 demands the
  re-verification). Results in ENVIRONMENT ACTS below.
- **R-13y-4 — THE TWO MID-PHASE DECISIONS: PROVISIONAL-and-continue** (her pick): the
  abuse-guard NUMBERS and the key-proof challenge DESIGN are ruled by the orchestrator under
  the architect mandate, logged in `notes/QUESTIONS.md` as PROVISIONAL, built, and ratified
  by her at the checkpoint. **This supersedes, for this phase and at her own word, the
  2026-09-21 "she confirms at its sitting" clause on the numbers.** Governance rider the
  orchestrator adds, recorded here so it binds: because the deploy is the one hard-to-reverse
  act, the window's pre-deploy summary NAMES both PROVISIONALs in one line each before
  anything fires — a last honest exit, not a re-litigation.

## BINDING PRINCIPLES

The 13b constitution (P-1…P-9) + its application notes bind this phase per the
`/architect-phase` skill, exactly as RUN B carried them (`notes/plans/run-b-sync-correctness.md`
§BINDING PRINCIPLES — copied byte-verbatim there; incorporated here by that reference to keep
this file readable in full). The load-bearing ones for a `Sync/` phase: **P-4** (broadcasts
carry signals, never decisions), **P-5** (the friction doctrine — the challenge memo is
exactly a P-5 memo), **P-7** (find bugs before she does; red-on-old absolute), **P-8**
(standing law: P1–P3 bind the engine; complexity in the store, restraint in the UI).

## WHY (one paragraph)

The mirror's `server_seq` is ONE global monotonic sequence stamped across all tenants.
Ordering-wise that is fine (each client only ever SEES its own rows), but it leaks: any
tenant can infer the AGGREGATE write volume/timing of all others from the gaps in the seqs
they receive — the 14c I-1 accepted-and-recorded disclosure, accepted at launch scale with
the closure named as a future §12 event. With sync OPEN at v1 (free ~3 months), stranger
cursors accumulate from launch day — after which a seq-semantics migration means resetting or
re-mapping REAL users' cursors. Now, with effectively one tenant, the migration is nearly
free. The same open-at-v1 ruling means the project takes unmetered public writes from launch
day — hence the MINIMAL abuse guard rides along, and the Fragments agent gets an
abuse-posture brief through the standing carry channel.

## THE DESIGN CONSTRAINTS (from the row + SyncSpec — binding)

- **Client semantics UNCHANGED, and test-pinned.** The premise that makes this safe: a
  client's cursor only ever meets own-account rows, and §7's seq-ranked repairs compare rows
  WITHIN one account — so per-tenant sequences preserve every relative order any client ever
  observes. Step 0 VERIFIES this premise against the code before anything is built; if any
  client-side comparison crosses accounts, STOP and report (that would be a design surprise,
  not a detail).
- **Ordering authority stays `server_seq`** (§9) — per-owner now, but still server-stamped,
  still monotonic per the only scope any client sees. Wall clocks stay display-only.
- **Her existing seqs CARRY OVER as the initial per-tenant values — no cursor reset** for her
  devices (the row's explicit requirement).
- **ONE §12 lockstep event, HER window, the 13j choreography** (both her device builds
  refreshed in-window; the marker fences). R-13y-2 sets the window's shape.
- **The server stays dumb.** Per-owner stamping is a trigger + counter table; no merge
  intelligence moves server-side.
- **The abuse guard is MINIMAL by design** — per-account write quotas/rate limits at the RPC
  layer with a TYPED refusal the client surfaces honestly (the §12 refusal grammar: outbox
  intact, cursor unmoved, a visible status). The tier's full posture is 13t's; this phase
  only ensures launch day is not an open firehose.
- **PROVISIONAL governance (R-13y-4):** the numbers and the challenge design are the
  orchestrator's ruled PROVISIONALs — logged at `notes/QUESTIONS.md` #144 when ruled, named
  at the window pre-deploy, ratified at the checkpoint.

## THE ACCEPTANCE UNITS (named at plan time, per `notes/PhaseSizingGuidance.md`)

Two phase-sized units under the one theme — within the guidance's line. ONE implementer
session each, strictly sequential (B builds on A's artifact). The phase is ONE §12 lockstep
event; its sync-kind acceptance evidence is shared: **the convergence suites green under the
per-tenant harness + her live two-device round at the window with cursors intact.**

- **UNIT A — the per-tenant sequence** (Steps 0–3): the survey, the `12_` DDL authored (with
  the guard fold-in + NIT-4 + the horizon exposure), the client pins, the per-tenant fake
  server, the disclosure-closure probe, the adopt-road pin. Unit-level evidence: ALL
  convergence/two-user suites green under per-tenant numbering + the probe as the headline
  pin.
- **UNIT B — the guard and the proof** (Steps 4–5): the minimal abuse guard (+ the re-auth
  doors), the key-proof challenge (memo → ruling → build), the Fragments brief. Unit-level
  evidence: the quota suites (refuse cleanly, recover, never refuse the import burst), the
  challenge suites (a replayed captured proof refuses; the fake's twin), the refusal-grammar
  pins.

Then: the ladder over the combined diff → **Step 6, HER WINDOW** (the shared acceptance
evidence lands there).

## STEPS (each with tests; suites run at step ends — the 2026-09-21 riders are FOLDED IN)

**Step 0 — the seq-assumption survey (UNIT A; read-only; the gate on everything).**
Enumerate every reader of `server_seq`/`sync_row_seq` client-side (`Merge.swift`,
`Repairs.swift`, cursor handling, `PurgeJanitor`/ledger reconciliation, `CorpusRotation`'s
seq comparisons, `SampleLibraryDedupe`'s seq-ranked legs, `RekeyRecencyProbe`) and every
server-side consumer (`sync_pull`'s ordering + the A5 visibility horizon, `sync_horizon()`,
`sync_purge_ledger()`, `sync_purge_execute`, `device_cursor`, `purged_row`,
`key_vault_update`'s rotation arm). Verdict each WITHIN-ACCOUNT (safe) or CROSS-ACCOUNT
(stop-and-report). Record the table in this file. **Three server-side mint sites are already
known from the kickoff preflight — the survey verifies and COMPLETES this list, never trusts
it:** `stamp_server_seq()`'s `nextval('sync_server_seq')` (09:227 — the trigger every data
table fires), `sync_purge_execute`'s `granted_seq := nextval(…)` (11:697 — compared against
the owner's device cursors), and `key_vault_update`'s `next_seq := nextval(…)` (11:922 — the
`rotation_started_seq` mint, compared against the owner's data-row seqs by the completion
guard). Every one must draw from the OWNER'S counter or its comparison breaks. Test: none
(survey); its output is the record.

**Step 1 — the mirror's per-owner stamping (UNIT A): `Server/supabase/12_phase13y_tenant_seq.sql`,
authored now, deployed ONLY at her window.**
- A per-owner counter table + one counter function (row-locked upsert-increment — per-tenant
  serialization: tenants never contend with each other); the stamping trigger and the Step-0
  mint sites ALL swapped to it.
- `sync_pull` ordering/cursor per-owner (the RLS/owner scoping already fences visibility —
  the cursor semantics join it), **with its parameters REORDERED so `key_proof` is
  defaultless everywhere** (NIT-4, pre-13x ladder 2026-09-07 — Postgres forbids a defaultless
  parameter after defaulted ones; old signatures dropped first, the 09 discipline).
- Initialization copies each owner's current `MAX(server_seq)` across every data table as
  their counter's floor, so her existing cursors stay valid (no reset — the carry-over is
  proven live at Step 6).
- **The rotation completion guard's body FOLDED IN** (RUN B S1/Q3's carry; the standing
  caveat at `notes/plans/pre-13x-deploy-checklist.md` §10 retires with this artifact): the
  deployed `key_vault_update` carries `VARIORUM_ROTATION_ROWS_REMAIN` in its canonical body,
  verified by an arm-9-style **DDL text pin** on the deployed body, never assumed from the
  overlay's state. The `maintenance/pre13x-ladder-rotation-clearing-guard.sql` overlay is
  marked superseded-by-12 in its header.
- **The A5 horizon's ONE source of truth** (pre-13x closeout consideration 2, her
  instruction): the server's visibility horizon (today `interval '2 seconds'` inline in
  `sync_pull`) becomes a served constant exposed through the lockstep read
  (`sync_schema_version`'s shape — the exact vehicle is the implementer's proposal, the
  orchestrator rules), and `CorpusRotation.horizonWait` DERIVES its wait from it (server + margin),
  pinned — one constant moving without the other reopens BLOCKER-1's class.
- `sync_schema_version()` 8→9 last, inside the one guarded transaction; the in-file re-run
  guard per the 09/10/11 precedent; `maintenance/14c-post-deploy-grant-sweep.sql` EXTENDED to
  name every signature 12 creates (the `AuthRLSDDLTests` pin extends with it).
Tests: `AuthRLSDDLTests`' 12 block (signatures, ownership, grants, the guard text pin, the
horizon-exposure shape); the fake server's twin lands in Step 3.

**Step 2 — the client (UNIT A).** `SyncSchema.lockstepVersion` 8→9; any Step-0 verdicted
site adjusted (expected: none — the premise says client code is already within-account); pins
added: (a) a cursor never meets another account's rows (two-user harness assertion, existing
suites extended); (b) §7's seq-ranked repairs produce identical outcomes under per-tenant
numbering (the repair suites re-run against the per-tenant fake server); (c) **the adopt-road
pin** (pre-13x closeout hand-forward, 2026-09-04): the delete-and-set-up-again road — owner
re-stamp + `resyncReinitialize`, the ONLY v1 road that rotates the sync master — still
converges under per-tenant `server_seq` (a cursor reset to 0 under a NEW owner reads that
owner's sequence from its start; the two-user suite gains a delete → recreate → adopt
scenario); (d) `horizonWait` derived from the served horizon (Step 1's client half), pinned.

**Step 3 — the harness (UNIT A).** The fake in-process server gains per-tenant counters
(mirroring Step 1's semantics exactly, including the counter floor + the three mint sites);
ALL convergence suites re-run green under `productionRound` (RUN B's default); **the
DISCLOSURE-CLOSURE PROBE**: tenant B writes heavily; tenant A's pulls and seq bookkeeping are
asserted to carry ZERO information about it (no gaps, no advancing seqs A didn't cause) — the
probe is the phase's headline pin and the closeout amends SyncSpec §12's I-1 record on its
evidence.

**Step 4 — the minimal abuse guard (UNIT B).** Per-account write quota/rate limit at the RPC
layer (shape decided in-phase: simplest honest mechanism — e.g. a per-owner rolling
write-count check inside `sync_push` refusing with a typed error). Client: the refusal
surfaces per the §12 grammar (outbox intact, cursor unmoved, a visible status). **The one
named constraint the numbers must serve, hers verbatim (2026-09-21):** *"I do need to account
for onetime migrations from existing notes app but in general I don't want it abused."* — a
new user's one-time bulk first load is an HONEST burst the quota must never refuse (a
generous first-window allowance or burst bucket beside a lower steady-state rate; the
mechanism is this step's to design). NUMBERS: the orchestrator's ruled PROVISIONAL
(R-13y-4), generous launch-scale headroom, logged at #144; 13t revisits with pricing. Tests:
the fake server enforces the same limit; a suite proves an over-quota push refuses cleanly
and recovers when the window passes; a suite proves the import-burst shape passes untouched.

**Step 4b — the re-auth doors (UNIT B; the 2026-09-01 ADDENDUM, executed):** (1) the
re-authentication doors — Replace Keys, account deletion, and the Standard-mode confirmations
verify the ACCOUNT PASSWORD through a sign-in call against the suite issuer; that road
inherits Supabase's auth rate limits — STATE the numbers in this file, pin a test that a
burst of wrong passwords is refused, and make the app's refusal wording honest ("too many
attempts — wait N minutes"); (2) recent re-authentication for the destructive RPCs —
`account_data_truncate` and `sync_purge_execute` require a session re-authenticated within a
short window (an auth-time claim check inside the RPC, the tenant-scoped-guard pattern; rides
the 12 DDL), so a stolen long-lived token cannot empty an account's server copy from a custom
client. Record: `notes/plans/pre-13x-postures-design.md` §18-I.

**Step 4c — the key-proof challenge (UNIT B; memo FIRST, build second).** Today the proof is
a STATIC bearer secret (`HMAC-SHA256(M, "variorum.key-proof.v1")`, identical on every
request, in every RPC body) — anything operator-side that retains request bodies holds
mutating access forever (pre-13x CONSIDERATIONS item 1; stress-pass Q1 verified the durable
data plane holds only the hash). The fix: a PER-REQUEST challenge verified in
`sync_key_proof_check`. **The short design memo comes before any line** (the plan's own
2026-09-21 rider) and must weigh, at minimum: the verification-key custody trade (the
hash-only-at-rest property Q1 praised is at stake — a symmetric MAC secret stored server-side
vs an asymmetric public key with zero server secret; pgsodium/Ed25519 availability on
Supabase is a Sonnet-lookup fact, never assumed), the nonce/replay-window lifecycle, clock
dependence (§9: no client-clock trust), the fake server's twin, and the migration arm for her
existing vault row. The orchestrator rules the shape under R-13y-4 (PROVISIONAL, #144); the
build lands the server half in the 12 DDL and the client half in `SyncEncryption`/transport.
Pin: a captured proof value replayed on a second request REFUSES.

**Step 5 — the Fragments abuse-limiting brief (UNIT B).** A dated carry item in
`notes/fragments-bridge-contract.md` sharing the quota/limit design so the suite's posture is
one posture (her ask, with the hands-off-repo rule answering her "it's all stargazing"
alternative — the brief is the mechanism, never direct implementation).

**Step 6 — HER DEPLOY WINDOW (R-13y-2; the 13j/pre-13x choreography — the pre-13x checklist
is the worked example).** In one sitting: the A1 rail (WAL-safe backup, integrity_check) →
the pre-deploy snapshot (marker 8, row counts, function set) → `12_phase13y_tenant_seq.sql`
WHOLE in ONE session via the stored-PAT query road (classifier block ⇒ the `!` road, her
hands) → verification (marker 9; every signature; ownership `variorum_definer`; the grant
sweep every-row OK/INFO; the completion-guard TEXT PIN against the deployed body; the horizon
read served; **the pre-deploy summary names the two #144 PROVISIONALs, one line each**) → the
Mac Release refresh behind the A1 rail + the phone build/install (both marker-9; both
marker-8 builds visibly refuse from the bump until refreshed — keep the window tight) → her
live round each direction → **the carry-over proof: her cursors intact on her real account
(the Step 1 floor proven live), `device_cursor` carrying both devices** → the grant sweep
once more.

## VERIFICATION (phase acceptance, from the row + the folded riders)

- Convergence + two-user suites green under per-tenant numbering (the harness's per-tenant
  fake, `productionRound` default).
- The disclosure-closure probe: a second tenant's write activity provably invisible in the
  first tenant's pulls and seq bookkeeping.
- Zero client-visible behavior change (the pinned premise); the adopt-road scenario
  converges.
- Her devices sync across the deploy with cursors intact.
- The quota refusal is typed, honest, and recoverable; normal use never meets it; the
  import-burst shape never refuses.
- The challenge: a replayed captured proof refuses; the memo's ruled shape built on both
  halves; the fake's twin exact.
- The horizon has ONE source of truth, served and derived, pinned on both halves.
- The completion guard lives in the canonical 12 body (text-pinned); the overlay is retired.
- The re-auth doors: auth rate limits stated + pinned; the destructive RPCs demand recent
  re-auth.
- SyncSpec §12's I-1 record AMENDED at closeout (the closure executed); the lockstep running
  record gains the marker 8→9 entry; the deploy checklist's §10 caveat marked retired.

## NON-GOALS

- The tier's full rate/abuse posture, pricing, entitlement changes — 13t's.
- Any merge-matrix or repair-semantics change — the phase's whole premise is that none is
  needed (Step 0 enforces).
- Fragments-side implementation — the brief carries; their repo is hands-off.
- The 13y-adjacent residuals that are NOT this phase's: the sample-library dedupe's
  late-registry legs (KnownIssues row 33, owner **18a**) · the daily Journal's identity
  (owner **13i-e**) · pull-to-head memory + the poison-row park/heal design (owner **12**).

## AUTHOR RULING (2026-09-21, at the RUN B kickoff sitting — the scope CONFIRMED, the abuse numbers DELEGATED with one named constraint)

Asked whether 13y was worth discussing further or settled, and given the tradeoffs straight
(the tenant-to-tenant leak is worst at friends-beta scale; the migration-cost asymmetry is the
real reason for the pre-release slot; the riders are necessary regardless; the costs are the live
§12 window, a new per-owner counter hot row, and one phase of beta delay), she ruled:

- **The scope stands as is.** Her words: *"I think we should keep it as is then, sounds like it's
  solid and will be helpful."* No reopening of the per-tenant design; the plan runs as authored
  plus the 2026-09-21 correction (folded into the STEPS above at the 2026-09-22 kickoff refresh).
- **The abuse-guard NUMBERS are delegated to this phase's recommendation** — her words: *"I'll
  probably just go with your or phase 13y's recommendation on the abuse number."* *(Superseded in
  MECHANISM by R-13y-4, her own kickoff answer: PROVISIONAL-and-continue — the orchestrator rules,
  #144 logs, the checkpoint ratifies; the window pre-deploy names it.)*
- **ONE NAMED CONSTRAINT the numbers must serve, hers verbatim:** *"I do need to account for
  onetime migrations from existing notes app but in general I don't want it abused."* A new
  user's one-time import of an existing notes corpus (the 13h/Apple-Notes road, or any bulk first
  load) is an HONEST write burst the quota must never refuse — the guard's shape must
  distinguish a first-load burst from sustained abuse (e.g. a generous first-window allowance or
  burst bucket beside a lower steady-state rate; the mechanism is Step 4's to design). A refused
  honest import on day one is the worst possible first impression and is this constraint's whole
  point.
- **The launch-era framing confirmed:** *"once sync is paid for I can also price it more
  appropriately"* — the numbers are free-tier launch numbers; 13t revisits with pricing, exactly
  as NON-GOALS already states.

## ADDENDUM (2026-09-01 — from the pre-13x postures design, at the author's word)
The minimal abuse guard gains two named items: **(1) the re-authentication doors** — Replace Keys,
account deletion, and the Standard-mode confirmations (change-passphrase without biometrics, the
plaintext export) verify the ACCOUNT PASSWORD through a sign-in call against the suite issuer; that
road inherits Supabase's auth rate limits — state the numbers, pin a test that a burst of wrong
passwords is refused, and make the app's refusal wording honest ("too many attempts — wait N
minutes"); **(2) recent re-authentication for the destructive RPCs** — `account_data_truncate` and
`sync_purge_execute` should require a session re-authenticated within a short window (an auth-time
claim check inside the RPC, the tenant-scoped-guard pattern), so a stolen long-lived token cannot
empty an account's server copy from a custom client. Record: `notes/plans/pre-13x-postures-design.md`
§18-I (the back-door audit). Both are server SQL + `Sync/`-adjacent — the Fable rider.
*(Executed as Step 4b above.)*

## ENVIRONMENT TRAPS (every implementer brief carries this section verbatim)

- **The loop is the core package:** `swift build` / `swift test --filter <SuiteName>` from the
  repo root. The FULL core suite runs at each unit's close (baseline **1679/179**, re-confirmed
  on macOS 27 at this kickoff); the full Mac suite ONLY at the phase's finals (baseline: the
  ENVIRONMENT ACTS row below — measured on macOS 27 at this kickoff; never at a session's
  start). Swift Testing's "Test run with N tests" line COUNTS skipped tests — read the
  `skipped:` lines before claiming a gated suite ran.
- **The two-client harness lives in `Tests/VariorumCoreTests/Support/`** — `SyncTestHarness.swift`
  (two in-memory clients), `FakeSyncServer.swift` (in-process; `visibilityHorizon`,
  `holdPushes`/`commitHeldPushes`), `FaultInjectingTransport.swift` (chunking, drops,
  re-entrancy). The convergence suites: `SyncConvergenceTests` · `SyncMergeTests` ·
  `SyncRepairTests` · `SyncPullTests` · `SyncPushTests` · `FaultInjectionSyncTests` ·
  `EditorRateSyncTests` · `StructuralSessionSyncTests` · `MobileCaptureSyncTests` ·
  `MultiTenantSyncTests` (+ `MultiTenantSyncAttackerTests`). `productionRound` is the suites'
  default round shape since RUN B.
- **Zero mirror access until Step 6:** no SQL against production, no PAT use, no deploys.
  `12_phase13y_tenant_seq.sql` is AUTHORED in-repo and pinned by `AuthRLSDDLTests`; it fires
  only at her window, by the orchestrator.
- **A reproduced defect a unit is not fixing lands as a `withKnownIssue`-wrapped probe citing
  its ledger row** — never a bare red test.
- **Mac-suite runs (finals only):** from `App/Variorum/`, suite-level `-only-testing` only,
  selectors literal on the command line; NEVER a custom build configuration; zsh `pipestatus`;
  `pgrep -fl 'Variorum.app/Contents/MacOS'` before any run, discriminate by PATH, real-store
  instances quit by HER only. The flake list (adjudicate by the paired interleaved protocol,
  never one isolated run): the differential-latency pin · `CanvasDragTrackingTests` ·
  `BlocksWorkbenchFaceTests`' single-click · the row-49 landing arm · `ModeSwitchCarryTests`'
  top-of-Write arm.
- **Git:** never `git checkout` over uncommitted work; commit per piece and PUSH after every
  commit; NO commit trailers; stage PATHSPEC-LIMITED (`git add <your files>`), never
  `git add -A` — the orchestrator edits shared records between your commits.
- **Session resiliency (the checkpoint protocol — binding from the FIRST commit):** the unit
  record's LIVE STATUS section written at the START and flipped in the same commit as each
  piece, unverified claims marked PENDING · synchronous foreground waits only, via the
  grep-poll loop (`grep -q '<EXIT LINE>' <log> && break; sleep 5` — never `tail -f | grep -m1`,
  never a backgrounded run you end your turn on) · never spawn subagents (ONE Sonnet lookup for
  external facts only; repo reading never delegated) · no revert starts until the record names
  it and the pre-revert state is COMMITTED · every death and resume noted in the record.

## ENVIRONMENT ACTS AT KICKOFF (2026-09-22 — the macOS 27.0 update; R-13y-3)

- **The machine moved macOS 26.x → 27.0 (build 26A428) between RUN B's close and this
  kickoff; Xcode stays 26.3 (SDK 26.2)** — the runtime is now NEWER than the build SDK.
  CLAUDE.md's environment note ("Tahoe 26.x") is stale; the closeout updates it as a recorded
  fact.
- **The TK2 spike §5 re-run: CLEAN on 27.0** (`Spikes/TK2Spike/results-2026-09-22-macos27.0.log`,
  the archived run): canary **0** whole-run (no TK1 fallback), C-hybrid jump pixel-exact
  (paraErr 0, pxErr 0.00, postSettleDrift 0.00) at 6.4–13.8 ms across 10–90% and FLAT at 200k
  words, keystrokes ~2 ms flat at 50k and 200k, `ensureLayout(documentRange)` still the
  banned-path cost (139 ms / 562 ms at 50k/200k — unchanged class). Every Phase-6 conclusion
  holds; live TK2 geometry stays adopted. The §5 matrix row for 27.0 is this line + the log.
- **Core suite on 27.0: 1679/179 ALL PASSED** — byte-matching RUN B's finals count.
- **Full Mac suite on 27.0 (the R-13y-3 early baseline): 3089 tests / 510 suites — 3084
  green + FIVE deterministic macOS-27 deltas, ALL adjudicated before UNIT A spawned.** Every
  one reproduces ISOLATED with a byte-identical signature (so none is load-flake), and the
  tree is unchanged in `Sources/`/`Tests/` since RUN B's all-green finals on macOS 26 two
  days ago — attribution to the OS is by construction. The standing row-60 flake did NOT
  fire this run. The five, classified:
  1. `RefontViewportTests.aShrinkingRefontKeepsTheLineAtTheViewportTop` —
     `topVisibleOffset()` 42034 vs 42128 (a 94-pt drift, deterministic): 13u4 UNIT F2's
     re-font restore is no longer exact on 27 — **possibly a REAL (small) product delta**;
     needs an editor-seam trace (NOT 13y's — the seam wants its own session per R-cor-14).
  2. `PagedReadViewTests.theBarKeepsItsScrubberAndSpeaksApproximately` —
     `count(NSSlider) 0 == 1`: **pin mechanism only.** SwiftUI's `Slider` is no longer
     `NSSlider`-backed on 27. **Product verified IN USE at this kickoff** (dev-store walk:
     the paged Read scrubber renders AND a track click jumped pages 1→286 of ~428; capture
     `notes/plans/13y-screens/01-paged-read-scrubber-jumped-macos27.png`).
  3. `BookViewTests….theSpreadKeepsItsBarWithFormsAndTheJumpScrubber` — identical
     signature and class as 2 (the same control on the two-up spread's bar).
  4. `BoundaryFluidityTests.theKeystrokePathRoutesCrossBlockDeletesIntoTheCompound` —
     `status.spoken → nil`, deterministic: the compound's status never speaks under the
     HARNESS's synthetic keystroke on 27 — needs a trace (harness key-routing vs real
     behavior); editor-seam-adjacent, not 13y's.
  5. `LibraryPanelHostTests.aNoteSelectionStandsThePanelUpWith…` — the pin bans the word
     "inspector" in the SwiftUI reflection dump and an OS-renamed INTERNAL symbol now
     matches it: **pin mechanism only** (nobody added an inspector).
  **Consequence for this phase's finals:** the full-Mac gate reads "green modulo these five
  adjudicated kickoff deltas" — any SIXTH red is 13y's to answer. Ownership: the
  KnownIssues row added at this kickoff, owner **18k** (runtime hygiene — the round she
  ordered to run right AFTER 13y; rows 1 and 4 are its trace items, 2/3/5 are pin
  re-mechanizations). Also observed, recorded: the run logs **6,706 `[AppKit] Invalid view
  geometry: width is infinity/too large` lines** — a NEW macOS-27 logging class with zero
  prior mentions in the repo (the width-1/infinity probes were silent on 26); no test
  failed for it; it joins the standing warning-sweep family (the 1,989 `Modifying state`
  class, owner 12).

## LEDGER (every row owned; a row closes FIXED/DONE-with-evidence · RECORDED-with-owner · DEFERRED-with-owner)

| # | Unit | Item | Status |
|---|---|---|---|
| 1 | env | The TK2 spike §5 re-run on macOS 27.0 | **DONE — clean** (see ENVIRONMENT ACTS) |
| 2 | env | Core suite new-OS baseline | **DONE — 1679/179 green** |
| 3 | env | Full-Mac new-OS baseline (R-13y-3) | **DONE — 3089/510, five deterministic macOS-27 deltas adjudicated (see ENVIRONMENT ACTS; KnownIssues row added, owner 18k; the scrubber product-verified in use)** |
| 4 | A | Step 0 survey + verdict table | **DONE (ec188df3)** — ALL WITHIN-ACCOUNT; F-S1 wide floor; the record's table |
| 5 | A | Step 1 — the `12_` DDL (+ guard fold-in, NIT-4, horizon exposure, sweep extension) | **DONE (468a1fba + c398e1f1)** — authored, text-pinned, marker 9; the horizon vehicle built to the Shape-1 ruling |
| 6 | A | Step 2 — client pins (incl. the adopt-road scenario) | **DONE (d4002bf6 + 2d74c4ab)** — pins a/b/d + adopt-road; lockstepVersion 9; horizonWait derived |
| 7 | A | Step 3 — per-tenant harness + the disclosure-closure probe | **DONE (d4002bf6)** — the headline probe red-on-old by behavioral revert; core 1698/179 at unit close |
| 8 | B | Step 4c memo — the key-proof challenge design (orchestrator rules; #144) | **RULED 2026-09-22 — `notes/plans/phase-13y-memo-key-proof-challenge.md` (the challenge shape §3, the numbers §4, the re-auth window §5, trades §6, edges §7); #144 logged; UNIT B builds TO it** |
| 9 | B | Step 4 — the abuse guard (+ numbers PROVISIONAL; #144) | **DONE (ec80f92d + deb86054)** — the adjudicated one-row tumbling shape; AbuseGuardTests 8/8 |
| 10 | B | Step 4b — the re-auth doors | **DONE (ec80f92d + deb86054)** — 10-min amr check both destructive doors; AuthRateLimit numbers stated + burst pin |
| 11 | B | Step 5 — the Fragments brief | **DONE (61416521)** — the dated carry item, brief only |
| 12 | — | The ladder (combined diff; cap three) | **ROUND 1 DONE** (2 BLOCKER / 1 MAJOR / 3 MINOR / 1 NIT → all dispositioned; the record + the F-R1 re-ruling + the F-R2 arbitration: `notes/plans/13y-ladder-round1.md`; fixes pushed, core 1722/180, both targets build clean) — **ROUND 2 DONE** (1 NEW BLOCKER — the pgcrypto hmac argument SWAP in §5g, invisible to every suite by construction; 1 MINOR — the infra-swallowing exception block; all round-1 dispositions verified sound; record `notes/plans/13y-ladder-round2.md`) — **ROUND 2 FIXES DONE** (both AGREE/FIXED, surgical; R2-F1's red-on-old by behavioral revert against the committed fix; core 1722/180; record + dispositions in `13y-ladder-round2.md`) — **ROUND 3 DONE — THE LADDER CLOSES AT THE CAP: 0 BLOCKER / 0 MAJOR / 2 MINOR / 0 NIT, both round-2 fixes CONFIRMED** (record `notes/plans/13y-ladder-round3.md`; the two post-cap MINORs — the fake's non-transactional nonce burn falsifying the splice pin's claim, and §5g's fail-open NULL asymmetry on the undeployed artifact — FIXED NOW by the orchestrator's post-cap adjudication, no fourth round; **post-cap fixes DONE + verified — the LADDER's build work is CLOSED whole**; one honest residual recorded in round 3's R3-F1 disposition, the post-proof-RAISE nonce-fate seam) |
| 13 | — | Step 6 — HER WINDOW (deploy · installs · live round · carry-over proof) | open — **the checklist is authored; THE FINALS ARE GREEN (below); the window awaits HER word + sitting** |
| 13a | — | **THE FINALS (2026-09-23, the four gates, strictly sequential, zero instances):** core `swift test` **1722/180 ALL PASSED** · full Mac **3089/510 with FOUR issues — exactly four of the FIVE adjudicated kickoff macOS-27 deltas (Refont · LibraryPanel-inspector · the two NSSlider scrubber pins), ZERO new reds; the FIFTH (BoundaryFluidity's compound status) went GREEN this run — deterministic at kickoff, green now, so its class is INTERMITTENT on 27 (KnownIssues row amended; owner 18k unchanged)** · iOS build **SUCCEEDED** · mobile **642/109 with exactly the standing 4 known issues** | **DONE — the gate reads GREEN-MODULO-FOUR, no sixth red** |
| 14 | — | Closeout (SyncSpec §12 running record + I-1 amendment · master plan · handoff · #144 ratify bundle) | open |

---

## UNIT A RECORD (the per-tenant sequence — implementer session, 2026-09-22)

### LIVE STATUS (flipped in the same commit as each piece; a fresh session finishes from this)

- **MACHINERY (recorded per the resiliency protocol):** the UNIT A implementer session
  DIED AT A MODEL-BUDGET LIMIT after delivering Steps 0–3 whole (commits ec188df3 ·
  468a1fba · d4002bf6 · 4c346e98, all pushed; tree clean) and before writing any line of
  the ruled fork piece. A FRESH CLOSER CONTINUATION (2026-09-22, this session) builds
  exactly the ruled Shape 1 and closes the unit — no design latitude, the fork RULING
  section below governs.
- **THE HORIZON VEHICLE (the ruled Shape 1 — the closer continuation's piece):**
  - **SERVER HALF: DONE (this commit)** — `sync_visibility_horizon_ms()` in 12 (new
    section 5; SQL, STABLE, definer, `sync_schema_version()`'s exact grants,
    `variorum_definer`-owned via the acquisition dance, returns 2000); `sync_pull` reads
    it ONCE into a `horizon interval` local and both branch filters derive from it
    (`- %L::interval` — NO inline interval literal survives in the pull body); the grant
    sweep gains the new signature on the version RPC's exact expectation row; the
    verification tail extended (the served constant + two functiondef LIKE checks).
    `AuthRLSDDLTests` re-shaped with it: `theVisibilityHorizonSurvivesEveryRework`
    RE-POINTED at the derivation (helper call present, derived filter, inline literal
    BANNED), the pull's verbatim-modulo pin rewritten as **11's body below the signature
    with EXACTLY the horizon derivation swapped in** (one declare line + the two
    filter/args swaps, the fold-in pins' idiom, non-vacuity arm included), and ONE new
    pin `theServedHorizonIsAConstantFunctionOnTheVersionRPCsShape` (shape · posture ·
    grants · ownership · the 2000 constant — a new-mechanism pin, green by design).
    **AuthRLSDDLTests 69/69 green (+1 over the unit's 68) · SerializerCompleteness 6/6.**
  - **CLIENT HALF + PIN (d) + THE FAKE: DONE (this commit)** — as ruled, one deviation-free
    piece; plus ONE expected pin extension the road itself announced:
    `noOwnershipChangeInstructionExistsOnTheWire` (arm 9's exact wire allowlists) went RED
    on the two new names — the pin doing precisely what its comment promises for a new
    wire road — and its client-RPC and protocol-requirement sets extended by exactly
    `sync_visibility_horizon_ms` / `visibilityHorizonMillis` (zero parameters, so the
    blanket forbidden-word scan covers it unrelaxed; the substance is untouched). The
    Mac/mobile emulators (`EmulatedMirror` · `InertTransport`) gained the required
    conformance (constant 2000; the inert one counts it as a touch), and the app's
    `PostureSwitch.Leaves.horizonWait` default became nil — the driver's production road —
    retiring the app-side hardcoded 2.5 s with it. Suites at this commit:
    **CorpusRotationTests 21/21 (+3) · AuthRLSDDLTests 69/69 (the cross-pin extending the
    helper pin: the extracted deployed constant through the client derivation = the
    retired 2500) · MultiTenantSyncAttackerTests 3/3 · KeyProofGateTests 11/11 ·
    VisibilitySkewTests 2/2.** The details of the ruled shape, as built:
    `SyncRotationTransport.visibilityHorizonMillis()` (REQUIRED, no default — the
    doctrine); `SupabaseTransport` answers via the RPC (the `sync_horizon` bare-bigint
    parse idiom); `CorpusRotation.horizonWait(forServedMillis:)` the ONE pure derivation
    (served + `horizonWaitMargin` 500 ms, stated as derived: today's 2500 − 2000) and
    `productionHorizonWait(transport:sleep:)` the ONE production road (fetch → derive →
    sleep), the init's `horizonWait:` parameter now optional with nil = that road; the
    hardcoded `productionHorizonWait: Duration = 2500 ms` RETIRED (core + the app's
    `PostureSwitch.Leaves` default, which now passes nil through); `FakeSyncServer`
    serves a SETTABLE horizon-millis value (default 2000, the deployed constant) and
    both fake conformers + `SeamTransport`/`EmulatedMirror`/`InertTransport` forward it.
    Pins (CorpusRotationTests): the pure derivation (2000→2500 + settable X→X+500 with
    the margin stated as the subtraction), the SPY-COUNTED production-road walk (served
    7000 → ONE fetch, wait observed exactly 7500 ms through the injected sleeper), and
    the nil-default resolves-to-production-road walk (served 0 → ONE fetch through the
    REAL sleep road). New-mechanism pins, green by design (stated per the brief); the
    non-vacuous arm is the DDL side's inline-literal ban.

- **Step 0 — the seq-assumption survey: DONE (this commit)** — verdict table below; ZERO
  cross-account verdicts, no stop-and-report. Two load-bearing survey findings (F-S1 floor
  widening, F-S2 dedupe verified-absent) + two recorded observations (F-S3 A5-belt, F-S4
  sequence-object disposal) below.
- **Step 1 — `12_phase13y_tenant_seq.sql`: DONE except the horizon vehicle (this commit)** —
  the artifact authored whole (guard, NIT-4 drop-first reorder, counter + floor, the three
  mint swaps, the completion-guard fold-in, the global sequence dropped, marker 9 last in the
  one transaction); the overlay carries the superseded-by-12 header; the grant sweep extended
  (new pull spelling, `next_owner_seq(uuid)`, `sync_owner_seq`); `SyncSchema.lockstepVersion`
  8→9 in the same commit (the standing rule); `AuthRLSDDLTests` gains the 12 block — ELEVEN
  new pins including the three VERBATIM-MODULO exactness pins (12's pull ≡ 11's below the
  signature; purge-execute ≡ 11's + exactly the M2 swap; key_vault_update ≡ the overlay's +
  exactly the M3 swap — the fold-in's "never assumed from the overlay's state" letter) and
  the F-S1 floor-coverage pin; `SerializerCompletenessTests.serverOnlyTables` gains the
  counter. **AuthRLSDDLTests + SerializerCompletenessTests: 74/74 green.** The ONE remaining
  Step 1 piece: the horizon-exposure vehicle — PROPOSED below, NOT BUILT pending the ruling.
- **Step 2 — client: DONE except pin (d)** — lockstepVersion rode Step 1's commit; ZERO
  Step-0-verdicted client sites needed adjusting (the expected outcome — the premise held);
  pin (a)'s two-user arm rides the disclosure probe's pull half (cursor == OWN head, zero
  foreign rows), pin (b) is `theSeqRankedRepairResolvesEachTenantsRaceByItsOwnLaterIntent`
  (the I2 race in BOTH tenants interleaved — each resolves by its OWN later-intent), the
  ADOPT-ROAD pin is `theAdoptRoadConvergesUnderPerTenantSequencing` (purge takes the counter;
  the re-created owner's sequence reads from ITS START — head == accepts; a cursor-0 fresh
  device reads to the new owner's own head; byte-identical pair). Pin (d) awaits the fork
  ruling. **A RENAME, recorded honestly:** the counter landed as `sync_tenant_seq` /
  `next_tenant_seq(for_tenant)` — the survey/record's earlier `sync_owner_seq`/`next_owner_seq`
  spelling tripped the attacker suite's BLANKET wire pin
  (`noOwnershipChangeInstructionExistsOnTheWire` bans "owner" in any deployed function name or
  parameter list); the pin's substance (no wire-reachable ownership instruction) is exactly
  worth keeping unrelaxed, so the FUNCTION renamed to the phase's own per-tenant vocabulary
  instead of the pin gaining an exemption mechanism. The table's COLUMN stays `owner_id`
  (every server table's idiom; the pin scans function signatures only).
- **Step 3 — harness: DONE (this commit)** — `FakeSyncServer` converted to per-account
  counters mirroring 12 EXACTLY (`nextTenantSeq` at all three mint sites; the LAZY wide floor
  — an account's first mint reads the GREATEST of its partition's data seqs, device cursors,
  ledger seqs, a standing rotation seq — the F-S1 initialization's semantics, which also
  models the migration for free; `wipe`/`truncateAccount` leave counters, `purgeAccount`
  takes the account's with it); `headSeq` split per-account (`headSeq(for:)`; the property
  stays the default account's — the single-user suites' exact old meaning);
  `syncToQuiescence`/`productionQuiescence` compare a fleet's cursors against ITS OWN
  account's head. **THE DISCLOSURE-CLOSURE PROBE (the headline)**:
  `theSeqsATenantSeesCarryZeroInformationAboutAnotherTenantsWrites` — after B's forty-note
  burst, A's next accept is granted `aHead + 1` exactly (contiguous — no gap B could cause),
  A's cursor rests at A's own head, every number in A's bookkeeping is A's own, zero foreign
  rows. **The whole sync family green under `productionRound`: 396/396 in 52 suites**
  (Sync* · Purge* · Rotation · Furniture · DrainOrder · Tenant + attacker · FaultInjection ·
  EditorRate · StructuralSession · MobileCapture · KeyProof · Vault · AuthRLS ·
  SerializerCompleteness). **RED-ON-OLD: DEMONSTRATED against commit d4002bf6 by behavioral
  revert** — the fake's mint temporarily reverted to ONE shared counter (the pre-13y mirror's
  numbering; never committed), the probe went RED on exactly its disclosure lines: A's one
  write after B's forty-note burst was granted seq **171** where A's own head was **8** — the
  163-seq gap IS the aggregate-volume side channel (three failed expectations: the contiguity
  line, the cursor line, the bookkeeping-ceiling line); the committed state restored via
  `git checkout --` on the clean tree, the probe green again. The DDL pins carry their own
  non-vacuity arms (the doctored-fixture idiom + the `!= swapped` checks on every
  verbatim-modulo pin).
- **FULL CORE SUITE AT UNIT CLOSE: 1694 tests / 179 suites — ALL PASSED** (2026-09-22; log
  archived in the session scratchpad), exactly ONE skipped — the standing env-gated
  real-server integration pass (`basicOfflineEditsConvergeOverTheRealServer`, part of the
  baseline). The +15 over the 1679/179 baseline is exact: the 12 new AuthRLSDDL 12-block
  pins + the 3 new MultiTenant probes. Suites unchanged at 179.
- **FULL CORE SUITE AT THE CLOSER'S UNIT CLOSE (the horizon piece landed): 1698 tests /
  179 suites — ALL PASSED, ZERO failures** (2026-09-22, the closer continuation; log in its
  session scratchpad), exactly the same ONE env-gated skip. The +4 over the predecessor's
  1694 is exact: the 1 new AuthRLSDDL pin (`theServedHorizonIsAConstantFunctionOnThe
  VersionRPCsShape`, carrying the cross-pin) + the 3 new CorpusRotationTests pins (the
  derivation · the spy-counted production road · the nil-default end-to-end). Suites
  unchanged at 179. **UNIT A IS CLOSED**; the orchestrator verifies, then the ladder.
  ~~**One honest PENDING for the finals:** the three APP-TARGET files this piece touched
  … COMPILE-UNVERIFIED in this session~~ **CLOSED by the orchestrator, same day:**
  `xcodebuild build-for-testing` on BOTH targets (Mac platform=macOS; mobile iPhone 17
  Pro simulator) — **both BUILD SUCCEEDED, zero errors** (the app + test targets
  compile; the seam files — `PostureSwitch.swift`'s nil Leaves default,
  `PostureSwitchTests.swift`'s + `MobileProtectionTests.swift`'s emulator conformances —
  prove out). The finals still RUN the suites; what no longer waits is "does main
  compile."

**ORCHESTRATOR VERIFICATION + UNIT A CLOSE (2026-09-22, my own hands):** the closer's
four commits read; 12's section 5 read (the ruled shape byte-for-it: SQL STABLE definer
returning 2000, the version RPC's grant pair) and the pull's `make_interval` derivation
confirmed at its line with no inline interval literal surviving; spot-runs green —
`CorpusRotationTests` 21/21 (the three new pins among them), the arm-9 wire-allowlist
pin, and earlier the disclosure probe + `AuthRLSDDLTests`; both app targets
build-for-testing clean (above). The predecessor's budget death and the closer
continuation are noted in LIVE STATUS per the resiliency protocol — the death cost zero
commits. **UNIT A IS CLOSED AND VERIFIED. Next: UNIT B (fresh implementer, builds TO the
ruled memo), then the ladder.**

### WHAT REMAINS OPEN IN UNIT A (nothing — the unit is CLOSED; the ladder flags below stay recorded)

1. **The horizon-exposure VEHICLE — CLOSED (the closer continuation, 2026-09-22).** The
   orchestrator's ruling landed (Shape 1, the fork section below) and the piece is BUILT
   whole per the LIVE STATUS's "THE HORIZON VEHICLE" bullet: the 12 artifact + the sweep +
   `AuthRLSDDLTests` (incl. `theVisibilityHorizonSurvivesEveryRework` re-pointed at the
   derivation), `SyncRotationTransport.visibilityHorizonMillis()` /
   `SupabaseTransport` / `FakeSyncServer`, and `CorpusRotation.horizonWait(forServedMillis:)`
   with the production road replacing the retired hardcoded 2500. Pin (d) closed (the
   three CorpusRotationTests pins). Everything in Steps 0–3 is DONE and green.
2. **Flagged for the ladder, recorded (not defects):** F-S4's drop-the-global-sequence call
   (fail-loud closure — the orchestrator may keep or strike; one `drop sequence` line);
   the `sync_tenant_seq` rename note (Step 2's block above); and the F-S3 observation that
   per-owner counter locking serializes ONE account's concurrent pushes mint-to-commit
   (the plan's own stated intent; negligible at personal scale, recorded for 13t's
   at-scale eye) and incidentally closes the A5 skew class within an account (A5 kept
   deployed byte-unchanged as the belt). Also recorded: a service-role DIRECT table write
   (no designed road uses one — everything goes through the RPCs) would now fail loudly at
   `next_tenant_seq`'s EXECUTE check instead of silently minting; fail-loud on an undesigned
   write road, recorded as intended.

### STEP 0 — THE SEQ-ASSUMPTION SURVEY (read-only; every consumer read in this session's own context)

**Verdict: WITHIN-ACCOUNT everywhere. No client- or server-side comparison crosses accounts.**
The phase's premise holds: per-tenant sequences preserve every relative order any client ever
observes, because every observable order is already per-account (the RLS/owner-scoped feed
serves only own rows; every repair/janitor/rotation comparison is between own-account numbers).

**The mint sites — the plan's three, VERIFIED, and the list COMPLETED by grep over
`Server/supabase/**/*.sql` for `nextval`: no fourth live mint site exists.** (01:29, 03:46,
10:582 are superseded historical bodies; 11:60/862 are comments.)

| # | Mint site (deployed truth) | Where | Swap in 12 |
|---|---|---|---|
| M1 | `stamp_server_seq()` — the trigger every data table fires (19 tables) | 09:227 (re-affirmed body) | `new.server_seq := next_owner_seq(new.owner_id)` — every data row carries `owner_id uuid NOT NULL` (09's rebuild), so the trigger has the owner in hand |
| M2 | `sync_purge_execute` — `granted_seq := nextval(…)`, compared against the owner's device cursors (ledger scan points) | 11:697 | `next_owner_seq(caller)` |
| M3 | `key_vault_update` rotation-begin — `next_seq := nextval(…)` into `rotation_started_seq`, compared against the owner's data-row seqs (the seq rule + the completion guard) | overlay:174 (= 11:922 + guard) | `next_owner_seq(caller)` |

**Client-side consumers, each verdicted:**

| Consumer | What it compares | Verdict |
|---|---|---|
| `SyncEngine.cursor`/`setCursor` (`last_server_seq`) | own cursor vs served rows' seqs — the feed is owner-scoped (09/11 `where t.owner_id = %L` on every branch) | WITHIN |
| `SyncEngine.recordSeq`/`knownSeq` (`sync_row_seq`) | own accepts + own pulls; read only by repairs below | WITHIN |
| `SyncEngine.pullIgnoringMarker` window paging | own feed's seq ordering | WITHIN |
| `Merge.merge` | passes serverSeq through to `recordSeq`; no comparison | WITHIN |
| `Repairs.repairPlacementCollision` | incoming seq vs `knownSeq(rival)` — two placements of ONE block in ONE store (one account by construction) | WITHIN |
| `Repairs` I10 resurrection + archive-race rescue | `ORDER BY COALESCE(s.server_seq,0) DESC` over ONE block's variants | WITHIN |
| `PurgeJanitor.sweep` | served horizon (min over OWN device_cursor) capped at OWN cursor; family rows' `sync_row_seq` vs that horizon | WITHIN |
| `PurgeJanitor.reconcileLedger` | own `last_purge_seq` scan point vs own account's ledger page (floor + purgedSeq) — its R2-M2 comment already anticipates this phase and leans on the §12 lockstep refusal during the window | WITHIN |
| `PurgeJanitor.healPurgeOrphan` / `reonboardFromAccount` | own ledger, own stall, own floor | WITHIN |
| `PurgeFamily.deleteLocal` | deletes own `sync_row_seq` bookkeeping | WITHIN |
| `CorpusRotation` (`pullBelow`, walk, completion) + `SyncPayloadCrypto.keyMaterial(forServerSeq:)` | own rows' seqs vs `rotation_started_seq` — VALID only because M3 mints from the same counter as M1; the swap keeps them on the owner's counter together | WITHIN (after M3 swap) |
| `RekeyRecencyProbe` | own cursor anchor; compares `updated_at` strings, not seqs | WITHIN |
| `SampleLibraryDedupe` | **VERIFIED ABSENT (F-S2)**: zero seq reads — keeper choice is smaller-id, kill evidence is wall stamps, `meetingStands` is liveness/outbox/stamps. The plan's starting list named it; the survey's answer is that no seq-ranked leg exists there | N/A |
| `RotationMarker` / `KeyVaultFormat.rotationStartedSeq` / `VaultBootstrap` / `OwnerIdentity` / `Migrations` / `Triggers` / `VariorumRecord` | storage/definitions/log strings only | WITHIN |
| `resyncReinitialize` | clears own `sync_row_seq` + cursor; its "the global server_seq itself is NEVER reset" comment re-reads per-owner (the OWNER's counter is never reset) — comment updated at Step 2 | WITHIN |

**Server-side consumers, each verdicted (deployed truth = 11 + the rotation-clearing overlay):**

| Consumer | Verdict |
|---|---|
| `sync_pull` ordering + A5 horizon | WITHIN — every branch owner-filtered; ordering semantics preserved per-owner |
| `sync_push` CAS + granted seqs + reject payloads | WITHIN — tenant-scoped since 09 |
| `sync_reencrypt` fresh seqs (via M1) | WITHIN |
| `sync_horizon` — min(last_seq) over own `device_cursor` | WITHIN |
| `sync_purge_ledger` — own `purged_row` page + floor 0 | WITHIN |
| `sync_purge_execute` — M2 + own-partition deletes + ledger | WITHIN (after M2 swap) |
| `key_vault_update` — M3 + the completion guard counting OWN ciphertext rows below the seq | WITHIN (after M3 swap) |
| `device_cursor` / `purged_row` rows | per-(owner, device) / per-owner | WITHIN |

**CONSEQUENCES the survey settles for Step 1 (the buildable design):**

- **The counter**: `sync_owner_seq(owner_id uuid PK, last_seq bigint)` + `next_owner_seq(for_owner uuid)`
  (upsert-increment `ON CONFLICT … DO UPDATE … RETURNING` — the row lock IS the per-tenant
  serialization; the parameter name honors the 13j naming rule, the `for_device` idiom).
  Posture: the `device_cursor` pattern — FORCE RLS + owner policy (`owner_id = auth.uid()` —
  every mint path executes with the caller's auth context), revokes from anon/authenticated,
  `select, insert, update` to `variorum_definer` (M1 runs as the definer inside the SECURITY
  DEFINER bodies — the 14c-gate file's recorded INVOKER-trigger reading).
- **Lock-order safety, traced**: every path takes the vault row (gate FOR SHARE /
  `key_vault_update` FOR UPDATE) BEFORE its first counter touch — one lock order, no cycle.
  Decision 31's guarantee TIGHTENS: an old-proof push holds the owner's counter row to commit,
  so the rotation mint waits on BOTH the vault share lock and the counter row — pre-rotation
  seqs sit below the rotation seq by lock order, per owner.
- **F-S1 — THE FLOOR IS WIDER THAN THE PLAN'S SENTENCE (load-bearing; the plan's own "her
  cursors must stay valid" demands it).** Data-max alone is NOT a valid floor: the janitor's
  `executePurge` REMOVES rows from the mirror, so an owner's data-table max can sit BELOW her
  device cursors (she was served the top seqs, then their rows were purged) — a counter floored
  at data-max would mint fresh seqs ≤ her cursor, and her pulls (`server_seq > cursor`) would
  never serve them: silent loss. Same class for the ledger (`purged_seq` below a device's
  `last_purge_seq` scan point is never scanned again) and for a mid-flight rotation
  (`rotation_started_seq`). **The initialization therefore floors each owner's counter at
  GREATEST of: max data-row seq across all 19 tables · max `device_cursor.last_seq` ·
  max `purged_row.purged_seq` · `key_vault.rotation_started_seq`.** Deploy-time reality check:
  on the real mirror all four give values ≤ the global head and the greatest is what her
  cursors demand; on her account today the data/cursor values are the live ones.
- **F-S3 (recorded observation, no action)**: the per-owner counter-row lock serializes ONE
  account's concurrent writers from mint to commit — commit order = seq order per owner — which
  structurally closes the A5 skew class WITHIN an account. A5 stays deployed byte-unchanged
  (CorpusRotation's wait and BLOCKER-1's apparatus lean on it; it demotes to a belt). The
  per-account write serialization is the plan's own stated intent ("tenants never contend with
  each other"); at two-device personal scale the queueing cost is negligible.
- **F-S4 (small call, flagged for the orchestrator/ladder)**: after the three swaps NOTHING
  references `sync_server_seq` (the data tables default `server_seq` to 0; the trigger
  overwrites). Step 1 DROPS the sequence in 12 — fail-loud closure: any future artifact that
  quietly `nextval`s the global counter errors instead of silently reopening the disclosure.
  The superseded overlay is independently inert: its own re-run guard refuses once the deployed
  `key_vault_update` body carries `VARIORUM_ROTATION_ROWS_REMAIN` (which 12's fold-in does).
- **Harness (Step 3)**: `FakeSyncServer` converts its one global `seq` to per-account counters
  with a LAZY max-floor (first mint for an account reads `max(serverSeq)` over its partition —
  the DDL's floor semantics exactly, and it models the migration scenario for free);
  `wipe()`/`truncateAccount` leave counters untouched (the sequence-survives doctrine, per-owner);
  `account`-scoped `headSeq(for:)` replaces the global `headSeq` in `syncToQuiescence` /
  `productionQuiescence` (both compare ONE account's cursors — the per-account head is the
  honest comparand; `MultiTenantSyncTests.fleetQuiesce`'s workaround comment can then say why
  it no longer needs one).

### THE NAMED DESIGN FORK — the A5 horizon-exposure VEHICLE (proposed; NOT BUILT until the orchestrator's ruling lands here)

Today: `interval '2 seconds'` inline in `sync_pull`'s branches; the client twin
`CorpusRotation.productionHorizonWait = 2500 ms` hardcoded — two constants, no link
(BLOCKER-1's class if either moves alone). Three shapes weighed:

- **Shape 1 (RECOMMENDED) — a sibling zero-arg definer function, `sync_schema_version()`'s
  exact shape: `sync_visibility_horizon_ms() returns bigint` (STABLE, returns the constant
  2000; same posture/grants as the version RPC; `variorum_definer`-owned).** `sync_pull`
  reads it ONCE into a local and derives its filter interval from it — the served value and
  the enforced value are ONE function, un-driftable by construction. Client half:
  `SyncRotationTransport` gains `visibilityHorizonMillis()` (the 13j separate-protocol
  precedent — CorpusRotation's walk is the only consumer, so the dozens of engine-wrapper
  transports never carry a dead conformance); the walk's production wait derives
  `served + margin` through one pure pinned function (`CorpusRotation.horizonWait(forServedMillis:)`,
  margin 500 ms — today's 2500−2000), the hardcoded 2500 retired. Pins: DDL (the pull body
  carries the helper call and NO inline interval literal; the helper returns 2000), client
  (the derivation function; the walk fetches the served value on its production road —
  spy-counted), fake (serves a settable value; the walk's wait observed = served + margin).
- **Shape 2 — the constant rides `sync_meta` (`'visibility_horizon_ms'`), read by a serving
  function AND by `sync_pull` per call.** Pro: operator-tunable without a function redeploy.
  Con: a tunable knob makes the dumb server less dumb for no present need — §12's grammar
  deploys changes via numbered artifacts anyway; and the coalesce-default split (function
  default vs table row) is a second place for drift.
- **Shape 3 — widen `sync_schema_version()` itself to jsonb `{version, horizon_ms}`.**
  REJECTED: that function's shape is what a MISMATCHED (old) client must still be able to
  read to refuse cleanly — changing its return type breaks the §12 refusal road for every
  old build, which is exactly the wrong function to destabilize.

**RULING (orchestrator, 2026-09-22, under the architect mandate): SHAPE 1, as proposed —
build it.** The deciding property is Shape 1's own sentence: the served value and the
enforced value are ONE function, un-driftable by construction — which is the rider's whole
demand ("one constant moving without the other reopens BLOCKER-1's class"). Shape 2's
tunability is a knob nobody asked for on a server whose whole design is dumbness (a horizon
change is a deliberate §12-grammar act, not a dial); Shape 3's rejection is correct and
stands (the marker function is the one thing an OLD client must still read to refuse
cleanly — never destabilize the refusal road). The 500 ms margin stays today's arithmetic
(2500−2000), stated as derived so a future horizon change moves the wait for free. Pins as
proposed, all four legs.

**FLAG ADJUDICATIONS (the report's four, each verdicted):**
1. **F-S4's `drop sequence sync_server_seq` — KEPT.** Fail-loud closure is the right
   posture: the mint-closure pin proves no `nextval` survives in the canonical text, and the
   DROP makes any UN-pinned survivor (a future overlay, a hand-run fragment) error loudly
   instead of silently minting from a dead global. The sequence was ours (01's), nothing
   platform-side references it.
2. **The `sync_tenant_seq`/`next_tenant_seq(for_tenant)` rename — APPROVED, and the reason
   is the valuable part:** keeping the attacker suite's blanket no-owner-named-function wire
   pin UNRELAXED preserves arm 9's strength exactly as ruled; an exemption list on that pin
   would have been the drift class. The column stays `owner_id` (the 14c vocabulary).
3. **F-S3 (per-owner lock serializes one account's concurrent pushes mint-to-commit) —
   RECORDED as the plan's stated intent** ("per-tenant serialization, tenants never contend
   with each other"); the at-scale eye is 13t's, noted on its orbit. The A5 horizon staying
   deployed byte-unchanged as the belt is right — the incidental within-account closure is
   a bonus, never the load-bearing guard.
4. **The service-role direct-write fail-loud at the helper's EXECUTE check — INTENDED**
   (the designed roads are the RPCs; a road nobody designed failing loudly is the 14c
   two-layer doctrine applied).

**Orchestrator verification before this ruling landed (my own hands):** the four commits
read; the 12 DDL's load-bearing hunks read (the wide floor, the three mint swaps at their
lines, the fold-in with `VARIORUM_ROTATION_ROWS_REMAIN` in the canonical body, the
drop-sequence, marker 9 last, the helper's revoke/grant pair); the disclosure-closure probe
and the full `AuthRLSDDLTests` suite (68/68) re-run green by the orchestrator.


---

## UNIT B RECORD (the guard and the proof — implementer session, 2026-09-22)

### LIVE STATUS (flipped in the same commit as each piece; a fresh session finishes from this)

- **Piece 1 — the record + the quota-shape proposal: DONE (this commit).** The proposal
  below is sent to the orchestrator before the quota half builds (the memo §8's letter);
  under R-13y-4 the unit proceeds on it without waiting — an orchestrator counter-ruling
  reworks the mechanism, not the numbers (the numbers are the memo §4's, ruled).
- **Piece 2 — the server halves in 12 (the challenge · the quota · the re-auth doors) +
  the grant-sweep extension: DONE (this commit).** The artifact grew UNIT B whole inside
  the ONE transaction: section 0's drop list now drops EVERY 11-era gated signature (a
  survivor would be a challenge-free door); 5b `key_proof_challenge` + 5c
  `sync_write_budget` (both the device_cursor posture); 5d the hoisted
  `sync_constant_time_equal`; 5e `sync_challenge(n)` (session-gated, clamp 32, 5-min GC,
  64-cap oldest-evicted, `extensions.gen_random_bytes`); 5f `key_proof_enroll` (FOR
  UPDATE, the fence, ONCE — ALREADY_ENROLLED for the racing loser, old-hash constant-time
  authorization, secret+hash land together; the NULL-hash arm RETIRED); 5g the reworked
  check (the RULED order: vault → Vault secret [ENROLL before any nonce is consumed] →
  atomic DELETE…RETURNING consume → 5-min server-clock TTL → HMAC over
  `nonce ‖ ':' ‖ rpc_name` → constant-time); 5h the gate passing challenge + the caller's
  name through; 6b sync_push re-created with the gate swap AND the adjudicated quota
  (cap 2000 · pool 500000 · window 50000, refuse-whole boundary, accepted-count increment
  after the loop, budget lock AFTER the vault lock — the stated order); 7/7e the two
  destructive doors gain the 10-minute amr re-auth (gate → re-auth → work) and the
  truncate resets the pool; 7b–7d horizon/ledger/reencrypt re-created challenge-gated
  (reencrypt EXEMPT from the quota, stated); 8 key_vault_update challenge-verified with
  the successor block (a new hash lands ONLY beside its `key_proof_mac`, sha256-matched,
  `vault.create_secret`/`update_secret` in the same transaction); 9 account_purge takes
  the nonces, the budget row and (best-effort, recorded) the Vault secret; 11 the full
  re-own/re-grant sweep + the vault-schema grants (ALL FUNCTIONS form, the
  signature-drift reasoning at the line); the verification tail + the PENDING-until-live
  list extended (extensions-schema resolution, the Vault road, the amr refresh-survival
  probe, the purge's vault delete under postgres). Marker stays 9 — ONE event.
- **Piece 3 — the DDL pins (the AuthRLSDDLTests 12-block rework + the new pins): DONE
  (this commit).** Fourteen UNIT A-era pins re-pointed at the new letter in their own
  idioms (the verbatim-modulo pins gained the enumerated challenge swaps + a
  `removingContiguousBlock` helper for multi-line insertions whose members include common
  lines; the 11-era proof-check/migration-arm pins re-pointed at 11's OWN file as
  deployed history; the sweep-coverage pin's signature lists moved whole with the 11-era
  spellings joining the must-not-EXPECT class) and SEVEN new UNIT B pins added
  (new-mechanism, green by design, stated): the two tables' posture · the mint's
  session-gate/clamp/GC/cap · the enroll road's once/FOR-UPDATE/land-together ·
  the check's RULED consume order + the migration arm's retirement + the static
  compare's absence · the quota's ruled numbers with the refuse-whole boundary and the
  lock order (the adjudication's three points, pinned as stated) · the re-auth window on
  BOTH destructive doors and NONE of the round doors · the vault grants + every new
  function's revoke-from-PUBLIC pair. `SerializerCompletenessTests.serverOnlyTables`
  gains the two tables (UNIT A's counter precedent). **AuthRLSDDLTests 76/76 (+7) ·
  SerializerCompletenessTests 6/6.**
- **Piece 4 — the client challenge road: DONE (this commit).** `KeyProof` gains the v2
  purpose + `macKey`/`macHash`; `KeyProofMaterial` (kp1 wire + kp2, ONE struct from ONE
  master — the approved both-or-neither shape) and `SyncKeyProof` (nonce + bound HMAC,
  one value through the Swift seam — the approved pairing) land; `SyncEncryptionKeys
  .keyProof` becomes the MATERIAL (production derives it in `DeviceKeyMaterial.syncKeys`
  — zero app-target production key-construction sites); `SyncChallengeTransport`
  (fetchChallenges + enrollKeyProof) with `SyncTransport` INHERITING it (every round
  consumer needs it — deliberately not the 13j single-consumer opt-in shape); the
  `SyncChallengeSigner` actor (one per round half/janitor pass/walk/probe: a nonce batch
  fetched once, one nonce per call, the stale-fetch-fresh-retry-ONCE road and the
  enroll-once road with the racing loser's ALREADY_ENROLLED-as-success); every gated
  transport signature's `keyProof` re-typed (labels keep — the pre-13x churn class,
  stated up front and approved); `SupabaseTransport` splits the pair into the two wire
  keys + the two new RPC roads + five new marker classifications (incl.
  `VARIORUM_WRITE_QUOTA` with the retry-after parser and `VARIORUM_REAUTH_REQUIRED`);
  `KeyVaultClient.updateVault` takes the material + optional `successorMacKey` and owns
  its own dance (challenge road, stale-retry-once, enroll road — WITH the found-and-fixed
  post-enroll payload-hash refresh, recorded below); `AccountLifecycleClient` likewise
  (no enroll — the re-key order guarantees enrollment); `CorpusRotation.prepare` installs
  the POST-ENROLL hash (SHA-256(kp2′)) and `begin` carries kp2′ so hash and Vault secret
  land together; the fake mirrors ALL of it (nonce mint/TTL/single-use/eviction on the
  logical clock, the enroll twin with ONE recorded latitude — a NIL-hash row adopts the
  first enrollment, the auto-adopt worlds' road, real-server-refused and DDL-pinned —
  the challenge-verified checkProof in the RULED order, the quota twin, the re-auth
  claim twin, `mintProof` as the direct-call test helper) + `ScriptedVaultServer` routes
  + the whole suite sweep (~30 test files; the wrapper transports forward the new
  surface; per-user worlds gain material/enrolled-state values). TWO REAL FINDINGS fixed
  in the tracing, both recorded: (1) a vault-update payload FETCHED BEFORE enrollment
  carries the creation-era v1 hash, which the server's land-together rule would refuse
  after the dance's own enroll — the client refreshes the payload hash from its material
  (rotation payloads excepted: theirs is the successor's); the cross-DEVICE stale-fetch
  corner refuses loudly into the standing refetch contract, recorded; (2) the successor
  rule could MASK the R1-2 revision CAS for stale-fetch payloads (a proof-flavored
  refusal where the honest contract is refetch-and-re-derive) — 12 + the fake gain the
  revision PRE-CHECK under the held lock right after the proof (the UPDATE's filter
  stays as the belt), the exactness pin's insertion grown by exactly those lines.
  **FULL CORE SUITE at this commit: 1705/179 ALL PASSED** (+7 over the 1698 baseline —
  the seven UNIT B DDL pins; the reworked KeyProofGate suite holds its count with the
  migration-arm tests REWORKED into the enroll-road ones).**
- **Piece 5 — the quota client half (typed refusal + wording + fake budget + pins):
  DONE** *(the typed `SyncError.writeQuotaExceeded(retryAfterSeconds:)` + the honest §12
  wording, the `retry_after_seconds=%` DETAIL parser, and the fake's budget twin all
  landed inside Piece 4's commit (b4c43b58) — the seam ran through the same files; what
  this piece ADDS is the pin suite `Tests/VariorumCoreTests/AbuseGuardTests.swift`
  (NEW, "The minimal abuse guard + the re-auth doors (13y UNIT B)") — the memo §4's
  named pins plus the adjudication's three explicit points, all new-mechanism green-by-
  design: over-quota refuses WHOLE with outbox intact + cursor unmoved and RECOVERS
  when the window tumbles (the refuse-whole boundary pinned AS STATED — `window_rows +
  batch > 50,000` refuses with zero overshoot); the import-burst shape (a first load
  far over 50k) passes untouched through the LIFETIME pool; the batch cap refuses a
  malformed 2,001-row call AND the pin asserts the ruled relation itself —
  `SyncEngine(transport:).batchSize * 10 == 2_000` — so a future chunk-size change
  breaks the pin, not the cap silently; `account_data_truncate` RESETS the pool (the
  adopt road's re-push is a first load, the ruled reset reason); CAS rejects burn NO
  quota (only accepted rows count — the accepted-count-after-the-loop point pinned).
  8/8 green. The budget-after-vault lock order stays STATED AT THE CODE in 12
  (adjudication point 3 — a comment obligation, verified present, not a pin).*
- **Piece 6 — the re-auth doors' client half + the auth rate-limit numbers/pins: DONE**
  *(the typed `SyncError.reauthRequired` + wording landed in Piece 4's seam; this piece
  adds (a) `Sources/VariorumCore/Auth/AuthRateLimit.swift` (NEW) — the pure classifier
  `isRateLimited(status:body:)` (HTTP 429 OR the `over_request_rate_limit` body token —
  the two-vocabulary precedent) + the ONE honest refusal sentence, with THE NUMBERS
  STATED AS FACTS in its doc per the brief's letter and RESTATED HERE per the ADDENDUM:
  **Supabase's token endpoint (the password grant every sign-in and every re-auth
  `verifyPassword` hits) defaults to 150 requests per 5 minutes per IP, bursts to 30,
  configurable** — with the recorded caveats stated honestly: the limit is IP-SCOPED
  (a distributed brute-force is not capped per account) and the tracker holds under-
  enforcement reports, so this is a SPEED BUMP never the wall; the walls are the
  password, the per-request key proof, and the E2EE design (the account password alone
  sees nothing — the postures design §3.10's consequence). (b) The AbuseGuardTests
  re-auth pins: BOTH destructive doors refuse a stale amr claim typed
  (`reauthRequired`) and pass a fresh one; the gate order holds (an unauthenticated
  caller on a stale-reauth account meets the GATE's refusal, never the re-auth's); the
  ROUND doors never consult the claim (push/pull under stale re-auth run clean — the
  memo's "never the round" line pinned). (c) The burst pin: a local `FakeTokenEndpoint`
  modeling the stated limit refuses 150 wrong-password attempts as credentials then
  429s the 151st; the classifier reads it; the IP-scoped caveat has its own arm (a
  second IP passes at the same account); the app's wording asserted VERBATIM against
  `AuthRateLimit.refusalWording`. (d) The COMPILE-PENDING app arm:
  `App/Variorum/Shared/ErrorPresentation.swift`'s `signInFailureMessage` gains the
  rate-limit arm FIRST in the endpointFailure switch — a 429 judged nothing about the
  credential, so "Wrong email or password." would be a lie there — returning the core
  wording; idiom-matched, orchestrator closes with build-for-testing. **The live amr
  refresh-survival probe is OWED AT THE WINDOW** (noted in the window list below): the
  fake's Bool claim twin is a recorded latitude — whether a refreshed session's `amr`
  password timestamp survives token refresh on real GoTrue must be probed live before
  the doors are trusted in anger.*
- **Piece 7 — the KeyProofGateTests rework + the attacker-suite extensions (the tenth arm
  under the challenge protocol; arm 9's exact-name allowlist extensions): DONE** *(the
  REWORK and the attacker extensions landed inside Piece 4's sweep commit (b4c43b58) —
  they were inseparable from the seam re-type; what closes the piece is the memo §3's
  SIX NAMED CHALLENGE PINS appended to `KeyProofGateTests` (suite now 17/17): **THE
  REPLAY PIN** (the headline — a captured `(nonce, proof)` pair spends once; replayed,
  it refuses `keyProofChallengeStale` on its own door AND a different door, nothing
  lands twice, no seq granted, no cursor written), whose red-on-old is a BEHAVIORAL
  REVERT of the fake's atomic consume (the two consume lines commented out, run once,
  RESTORED, never committed — the diff against HEAD empty afterwards), quoted:
  `✘ … KeyProofGateTests.swift:729:15: Expectation failed: an error was expected but
  none was thrown` / `✘ … :739:9: … await server.rowCount(table: "container") ==
  rowsAfter` / `✘ … :740:9: … await server.headSeq == headAfter` — with consume
  disabled the replayed pair LANDED the second push and moved the seq head, the exact
  static-bearer attacker outcome the protocol closes; the TTL pin (an unconsumed nonce
  older than the window refuses stale on the server's clock alone; a fresh nonce on
  the same clock passes — the TTL is the nonce's age, never the session's); the
  CROSS-RPC SPLICE pin (a push-bound pair on the pull door refuses `keyProofRefused`
  AND the splice CONSUMES the nonce — the DELETE precedes the compare — so the pair is
  dead on its own door after); the SIGNER'S RETRY road (a wholly stale stash — the
  sleeping laptop — meets one refusal, refetches EXACTLY once via a counting
  transport, lands; no surfaced error, no loop); the FRESH ACCOUNT'S FIRST ENGINE
  ROUND (provisioned v1-hash-no-secret, one `productionRound` drains the outbox
  through the transparent enroll road and the vault ends enrolled — secret + post-
  enroll hash together, the production shape); and the TOGETHER-RULE refusal (a new
  hash with NO mac, and a mac whose SHA-256 mismatches, both refuse the vault update
  whole — hash and secret land together or not at all, revision unmoved). All but the
  replay pin are new-mechanism green-by-design, said plainly; the replay pin carries
  the quoted red above.*
- **Piece 8 — the Fragments carry item (Step 5): DONE** *(commit 61416521 — ONE dated
  `## CARRY ITEM (2026-09-23)` appended to `notes/fragments-bridge-contract.md` in the
  file's own format: the three layers (challenge proof · quota numbers · re-auth doors)
  as an offered pattern with the Variorum-side file pointers, the SHARED token-endpoint
  facts (same Supabase project), and the honest-429-wording suggestion for their
  sign-in face. Brief only, nothing owed, their repo untouched — the hands-off fence's
  letter.)*
- **Piece 9 — the full-core-suite close line (baseline at open: 1698/179): DONE.
  FULL CORE SUITE AT CLOSE: 1719 tests in 180 suites, ALL PASSED** *(78 s; exactly the
  one standing env-gated real-server skip). **+21 tests, +1 suite over the baseline,
  and the arithmetic closes exactly:** +7 UNIT B DDL pins (piece 2+3) + 6 challenge
  pins (piece 7) + 8 AbuseGuardTests pins (pieces 5+6); the one new suite is
  AbuseGuardTests. The KeyProofGate rework held its count (the two migration-arm tests
  REWORKED into the enroll-road pair, not removed). Everything pushed; the app-target
  COMPILE-PENDING list (the three test files' conformers + the two one-line
  `updateVault` argument sites + the ErrorPresentation rate-limit arm) is the
  orchestrator's build-for-testing close per the adjudication.*

### THE QUOTA MECHANISM'S TABLE SHAPE (the implementer's proposal, per the memo §8 — sent to the orchestrator BEFORE that half builds)

Against the memo §4's ruled targets (500,000-row lifetime first-load pool · 50,000
accepted row-writes per rolling 24 h after it · a per-call batch cap of the measured
shipped chunk ×10 — **measured: `SyncEngine.batchSize` = 200, no composition site
overrides it (grep-verified across `App/` and `Sources/`), so the cap is 2,000
rows/call** · `sync_reencrypt` exempt · `account_data_truncate` resets the pool ·
`sync_purge_execute` unquota'd):

**PROPOSED: ONE per-owner accounting row + a TUMBLING 24-hour window — no write log.**

```sql
create table sync_write_budget (
  owner_id      uuid not null primary key,
  lifetime_rows bigint not null default 0,   -- accepted row-writes ever (since the last truncate reset)
  window_start  timestamptz not null default clock_timestamp(),
  window_rows   bigint not null default 0    -- accepted row-writes since window_start
);
```
(the `device_cursor`/`sync_tenant_seq` posture: FORCE RLS + owner policy, no API-role
privileges, definer row grants.)

Semantics, all inside `sync_push` (the ONLY quota'd door — reencrypt/purge write no new
data rows; the vault write is not data): after the gate + the entitlement gate —
(1) `jsonb_array_length(batch) > 2000` refuses (a malformed client's bound, never a limit
the shipped engine meets — its chunks are ≤ 200); (2) the owner's budget row is
upsert-locked FOR UPDATE (lock order: always AFTER the vault lock — only push touches the
row, no cycle); (3) `lifetime_rows < 500000` ⇒ the first-load pool is live and NO daily
check applies; else the window: `clock_timestamp() - window_start >= interval '24 hours'`
resets it, and `window_rows + jsonb_array_length(batch) > 50000` refuses typed
`VARIORUM_WRITE_QUOTA` carrying `retry_after_seconds=<window_start + 24 h − now>`;
(4) after the CAS loop the SAME locked row increments by the ACTUAL accepted count (the
memo's "accepted row-writes" — CAS rejects burn nothing).

Why this shape over the alternatives I weighed: a per-write LOG table gives an exact
SLIDING window but costs a row per accepted write (the abuse guard becoming its own write
amplifier) and needs its own GC; a fixed UTC-day bucket resets at a wall-clock boundary
that means nothing to the user and lets a midnight-straddling burst double the limit the
same way. The tumbling window is O(1) per push, self-contained in one row, aligns with the
user's own activity (the window starts at their first steady-state write), and its one
weakness — a burst at a window seam can reach ≤ 2× the daily number over a short span —
is bounded, harmless at the ruled scale, and exactly the MINIMAL-guard posture the plan
demands (13t re-prices with real machinery). `account_data_truncate` resets by DELETING
the row (the next push re-creates it at zero — delete-and-set-up-again's repush IS a
first load); `account_purge` removes it (the whole account goes). The seq counter
(`sync_tenant_seq`) is untouched by both — the budget is metering, never ordering.

**ADJUDICATION (orchestrator, 2026-09-22, under the architect mandate): APPROVED AS
PROPOSED — build it.** The shape is the memo §4's targets served by the minimal honest
mechanism: O(1) per push, one self-contained row, the server no less dumb, and both
alternatives correctly declined for the right reasons (a guard that amplifies writes
fails its own purpose; a wall-clock bucket serves nobody). Three things I note as
adjudicated rather than left implicit: (1) the refusal boundary
(`window_rows + batch > 50000` refuses whole) means no overshoot and at worst one
refused sub-limit batch at the seam — acceptable, pin it as stated; (2) the tumbling
seam's ≤2× short-span worst case is ACCEPTED and recorded (13t re-prices); (3) the lock
order (budget row strictly AFTER the vault lock, push the only toucher) is the
deadlock-safety argument — keep it stated at the code. The client seam note is also
adjudicated: the `SyncKeyProof` pairing and `KeyProofMaterial`'s both-or-neither
construction are APPROVED (the memo's shape, made structural), and the app-target
COMPILE-PENDING edits follow the UNIT A closer's exact precedent — the orchestrator
closes them with build-for-testing on both targets at unit close.

### ORCHESTRATOR VERIFICATION + UNIT B CLOSE (2026-09-23, my own hands)

The six build commits verified (105691c8 → 1579fa61, all pushed); the full core suite
re-run by the orchestrator: **1719/180 ALL PASSED**. The DDL's refusal grammar, the atomic
consume, and the Fragments carry item spot-read. **The app seam took FOUR fix rounds after
the unit's own close claim, each found by EXECUTION, not review** — recorded here because
the ladder should read it plainly:
1. (6c7b952f) three compile errors + the honest correction that the whole app-target test
   seam had been missed (the record's original COMPILE-PENDING claim was wrong; corrected
   in place) — the sweep that followed reworked the twinned `VaultRPCEmulation` +
   `EmulatedMirror`/`EmulatedVault` doubles to the challenge protocol.
2. (9f7c5ca7) one more site class (a direct-call `keyProof:` expression), swept as a class.
3. (7395d396) the FIRST EXECUTION of the doubles found a fidelity bug (a split enrollment
   state producing a real extra vault request; the pins' arithmetic confirmed as the real
   wire's truth) — the patch REGRESSED the suite to 43 issues (the enroll self-invalidated
   through its own hash move).
4. (af5d28a5) the STRUCTURAL fix on the orchestrator's steer: the split state retired
   whole — the vault double's row is the one account, the mirror consults it — and the
   doubles ended ~40 lines SMALLER than after the patches.
**Executed evidence at close, every consumer of the doubles:** Mac 66/5 (Castle runner +
drills + connect/tier/flows) + 20/4 (relink · enroll-joins · sync-setup · key doors) +
39/7 (off-main custody · data-safety faces) all PASSED; mobile 33/9 PASSED; both targets
build-for-testing clean. **One process correction, the orchestrator's own:** the first two
mobile "green" claims were VACUOUS (the `Executed 0 tests` + `TEST SUCCEEDED` trap — the
selector named the FILE, not the suite types; the environment traps name exactly this and
it still fired twice on the orchestrator's own runs). The counts above are re-runs with
type-name selectors and confirmed executed counts. **UNIT B IS CLOSED AND VERIFIED. THE
LADDER OPENS NEXT** over the phase's combined diff (ff3a3f86..af5d28a5's tree).

### NOTES CARRIED WHILE BUILDING (repo-first; the report repeats them)

- **The client seam change is the pre-13x class, stated up front:** the challenge protocol
  makes the proof PER-REQUEST, so the Swift transport seam's `keyProof` parameter changes
  TYPE (`String` → the paired `SyncKeyProof` challenge+proof struct; labels keep) on every
  gated method, `SyncEncryptionKeys.keyProof` becomes the derived `KeyProofMaterial`
  (kp1 wire + kp2 MAC key, both from M — one struct so both-or-neither holds by
  construction), and every conformer/call site sweeps mechanically — exactly the churn
  class pre-13x paid when the proof was ADDED. Consequence the brief's "expected: none"
  did not anticipate: the app-target TEST conformers (PostureSwitchTests' emulators,
  Phase8ServicesTests' fakes, MobileProtectionTests) and the two one-line app-production
  `updateVault(keyProof:)` argument expressions (EncryptionSession/PostureSwitch) take
  idiom-matched edits, COMPILE-PENDING for the orchestrator (the UNIT A closer's exact
  precedent, mostly the same files). Piece 6 adds ONE more to the same list:
  `App/Variorum/Shared/ErrorPresentation.swift`'s rate-limit arm (reads two core
  symbols, same build-for-testing close).

  **CORRECTION (2026-09-23, on the orchestrator's failed build-for-testing — exit 65
  both targets, three surfaced errors):** the paragraph above CLAIMED the app-target
  seam edits were made pending compile verification. **They were not — the Piece 4
  sweep covered `Tests/VariorumCoreTests` only and never touched the app target.**
  The three surfaced errors were the app MODULE's alone (the test targets were never
  compiled behind the failing module), so the fix pass swept the WHOLE app-target
  seam, not three expressions:
  - **The three named errors:** `ErrorPresentation.swift` — the mechanism was a
    MISSING `import VariorumCore` (the file's only core reference until the arm was
    the app-side `AuthSessionError`), NOT visibility — `AuthRateLimit` was already
    fully `public`, so zero core visibility changes; `PostureSwitch.swift:1208` +
    `EncryptionSession.swift:447` — both Apple-held-copy reland payloads passing the
    kp1 wire String — now construct `KeyProofMaterial(master:)` from the same master
    (the both-or-neither idiom; the dance's enroll arm serves these non-rotation
    payloads per finding 1).
  - **The app-target TEST seam, swept whole (would have failed the NEXT build):**
    `VaultRPCEmulation` (both byte-identical copies, VariorumTests +
    VariorumMobileTests) reworked to the challenge protocol — `serveUpdate` now
    serves THREE paths so the doubles' unconditional first call routes the dance with
    zero consumer churn (`sync_challenge` mints single-use nonces; `key_proof_enroll`
    lands the secret + post-enroll hash together under the old hash's authorization,
    once; the update check runs 12's RULED order incl. the finding-2 revision
    PRE-CHECK and the successor mac rule; the static-token check and its NULL-hash
    adopt arm RETIRED). The kp2-secret twin rides the ROW JSON under a test-only key
    (per-world storage — a static would cross-contaminate parallel worlds); recorded
    latitudes: no enroll-fence check, no TTL, lock-serialization for FOR UPDATE.
    `PostureSwitchTests`' `EmulatedVault` routes the two roads explicitly (it guards
    the update path before delegating); its `EmulatedMirror` grew the REAL gate twin
    (minted nonces, enrolled secret, HMAC bound to the calling rpc's name, and the
    vault-hash-is-truth rule: a hash moved since enrollment clears the secret and
    demands re-enrollment, with the post-rotation re-adopt arm — the mirror's vault
    WRITE road is external, the recorded latitude). Signature swaps + trivial
    challenge roads (bare mint, silent enroll — these fakes never verified proofs) on
    every transport fake: Phase8ServicesTests ×2, Phase9cAuthWiringTests,
    TierAndOnboardingTests, EncryptionFlowTests ×2, MobileProtectionTests'
    InertTransport; `truncateAccountData` conformers → `KeyProofMaterial` in
    PostureSwitchTests, ConnectLibraryTests, TierAndOnboardingTests,
    EncryptionFlowTests; `updateVault` material swaps in PostureSwitchTests ×5 (incl.
    the stale-proof keys construction), EnrollDirectionsTests, PostureSwitchDrillTests;
    Phase8's keys construction. TWO rotation-completed hash pins moved to `macHash`
    (PostureSwitchTests 733/2234 — Piece 4's `prepare` made `hash(master:)` the wrong
    truth there; PostureSwitchDrillTests:669's negative pin stays true either way),
    and core `KeyProof.hash(master:)`'s doc dropped its now-false "what a rotation's
    vault update installs" clause (the ONE core file touched — comment only; full
    suite re-run 1719/180 ALL PASSED, unchanged).
  - **Round 2 (the orchestrator's second build: iOS CLEAN, Mac ONE error):** a
    third error SHAPE the String sweep could not catch — a DIRECT RPC call handing
    the MATERIAL where the per-request `SyncKeyProof` stands
    (`ConnectLibraryTests:201`, the owner-guard probe pushing straight at
    `y.mirror`). Fixed in the core fake's `mintProof` idiom: `EmulatedMirror` gains
    `mintProof(rpc:material:activeKeyID:)` (enroll-if-unenrolled + one nonce + the
    rpc-bound proof — the gate runs before the owner check, so the probe must pass
    it to REACH the refusal under test; enrolling Y's material there is what Y's
    first engine round would do anyway). The CLASS swept as directed: every
    `keyProof:` argument expression across BOTH app test targets audited — the
    other eleven all hand the material to material-taking seams (`updateVault`,
    `SyncEncryptionKeys`) or are the mirror's own gate forwards; this was the
    class's only member.
  - **Round 3 (the doubles' FIRST EXECUTION: mobile green; Mac 66 tests/5 suites,
    TWO issues — both `emu.updateCount` exactly +1 over the pin in the
    Castle-runner suite):** the traced mechanism CORRECTS the orchestrator's
    read — the mirror never touches `updateCount` and the enroll ROUTE is
    uncounted; the +1 was a genuine SECOND `key_vault_update` REQUEST: both tests
    run `engine.push()` (enrolling at the MIRROR) before the measured window, then
    the rekey's `begin` is the world's first VAULT-door write, whose first attempt
    is enroll-refused (counted — the counter increments before the check refuses)
    before the accepted retry (counted). On the REAL wire the account has ONE
    enrollment state, landed by that very engine round, so `begin` costs one
    request — **the pins' arithmetic is the real wire's truth and stays
    UNMODIFIED; the fidelity bug was the doubles' SPLIT enrollment state** (mirror
    secret vs vault-emu secret). Fix, the surgical one: the mirror's accepted
    enroll propagates to the vault double — `EmulatedMirror.setOnEnroll` +
    `EmulatedVault.enrollProof(macKeyWire:)` (idempotent: never overwrites an
    existing secret, so the post-rotation re-adopt can't cross the successor
    rule's landing), wired at ALL THREE world builders (PostureSwitchTests,
    ConnectLibraryTests, PostureSwitchDrillTests) — strictly convergent toward
    the pre-13y (= real-wire) request counts every existing pin asserts;
    `VaultRPCEmulation.secretKey` went internal for it (both copies still
    byte-identical). Re-derived under the fix: test 1 = begin·refused·accepted =
    +3 ✓; test 2 = begin + 3 refused = +4 ✓. **The `sqlcipher hmac check failed
    pgno=1` ERROR lines are the suite's standing designed wrong-key noise** — the
    Castle drills deliberately open stores under wrong keys/passphrases
    (`StoreEncryptionMigration.opens` probes, the wrongPassphrase arms) and
    SQLCipher logs the hmac failure on every such open, since the 13p
    encrypted-store era; none of this fix pass touches store-key code.
  - **Round 4 (round 3 REGRESSED the suite — 66/43, all one sentence, the enroll
    road's `keyProofEnrollRequired` thrown suite-wide): THE STRUCTURAL FIX.** The
    traced regression mechanism, confirmed at the source: round 3's hook moved the
    row hash to hash(kp2) INSIDE `enrollKeyProof`, AFTER the mirror recorded its
    pre-move `enrolledUnderHash` — so the signer's retry gate saw a "moved" hash,
    the truth-follows rule cleared the secret it had just enrolled, the same
    call's SECOND enroll refusal hit the signer's `guard !enrolled`
    (`KeyProofChallenge.swift:62`) and surfaced; every world's first push died at
    build/seed, hence 42-wide. The orchestrator's steer taken on the trace's
    evidence — the SPLIT state itself was the disease (rounds 1–3 each patched
    its seam from a different side): **the vault double's row is now THE ONE
    ACCOUNT** — `EmulatedVault.enrolledSecret` (the row-held Vault-secret twin) +
    `enrollRoad(kp1:kp2:)` (the HTTP enroll route's twin: once, old-hash
    authorization, secret + post-enroll hash landing together,
    ALREADY_ENROLLED-as-refusal that the signer swallows), and the MIRROR
    consults and enrolls THROUGH it (`attach(vault:enrollment:)` at all three
    world builders). RETIRED WHOLE: the mirror's local `macSecret`,
    `enrolledUnderHash`, the truth-follows/re-adopt machinery, and round 3's
    `setOnEnroll`/`enrollProof` hook — the gate is now the real check's own
    shape (the secret, never a hash comparison), and a rotation's successor rule
    replaces the shared secret at the vault write with nothing left to re-sync.
    Pins byte-untouched; the arithmetic re-derives identically (+3/+4), the
    stale-proof engine still refuses `keyProofRefused` (secret is kp2′, the old
    material's HMAC mismatches), and the two-device world gates both engines
    against the one shared row secret.
  - **Verification within the fence:** all fourteen (+2 in round 2, +5 in round 3,
    +3 in round 4) edited files pass a syntax-only `swiftc -parse` sweep;
    typecheck and execution are the orchestrator's (no Mac-suite runs on this
    side). **Runtime exposure, stated honestly:** the app
    suites' RUNTIME behavior under the challenge dance (the emulation roads above)
    is untested until the next full Mac-suite run — the doubles were built to
    preserve each test's old outcome through the new protocol, but that claim has
    compile-and-reasoning evidence only.
- **OWED AT THE WINDOW (the deploy sitting's list — none of these is mine to run; the
  fences bar all mirror contact):** (1) **the live amr refresh-survival probe** (the
  brief's own note): whether a real GoTrue session's `amr` password timestamp survives
  token REFRESH — the fake's Bool claim is a recorded latitude, and if refresh strips
  or re-dates the claim the 10-minute window mis-measures in one direction or the
  other; probe live before the destructive doors are trusted. (2) **the Vault grants +
  extensions-schema probes** (12's own PENDING-until-live header list): `vault.
  create_secret`/`update_secret` callable by `variorum_definer` on the hosted plan,
  and `hmac`/`gen_random_bytes` resolving via `extensions` in the two bodies that set
  `search_path = public, extensions` — both are hosted-shape facts no fake can pin.
  (3) **`account_purge`'s best-effort vault delete** — the purge takes the nonces,
  budget row and secret with it; the secret's `vault.secrets` DELETE is best-effort by
  design (a stranded secret is inert ciphertext), verify the happy path once live.
  (4) The standing UNIT A window items are unchanged by this unit.
