# RUN B — sync correctness (17i + 17d + 17l item 5)

**STATUS: OPEN — kickoff 2026-09-21 (the author's word, same day RUN A closed).** Batch B1 (the
hunt) is next to spawn; her kickoff answers are recorded below as they land.

An ad-hoc standing-fixes phase under a Fable orchestrator per the runs file
(`notes/plans/pre-beta-standing-fix-runs.md`, her confirmed grouping 2026-09-14, R-13u-6).
**EVERYTHING in this run is `Sources/VariorumCore/Sync/` work or its harness — the standing rider:
Fable implements, Fable reviews; no Opus seat.** The entries themselves live in
`notes/plans/phase-17-standing-fixes.md` — that file is the binding item record; the 17i brief is
`notes/plans/pre-13u-memo-sync-disagreements.md` (probe answers are RECORDED THERE, in its
⚠️ UNSETTLED section, whether they confirm canon or not). This file is the run's ONE running record
(ledger, batch briefs and records, adjudications, the ladder, the closeout). At close each entry's
dispositions are copied into the 17 file and 17i · 17d · 17l item 5 close; the phase itself never
does.

**Baselines at open (RUN A's finals, by reference — `notes/plans/run-a-custody-text-loss.md`
CLOSEOUT):** core **1639/177** green · the FULL Mac suite **3086 tests in 509 suites ALL GREEN,
zero failures** · iOS BUILD SUCCEEDED · mobile **642/109 with exactly the 4 known issues** ·
marker **8** · `/Applications` = RUN A's Release (`d22dc18e…`, behind backup
`run-a-refresh-20260922T004359Z`) · git clean at `08d9ea8f`. **Never run the full suite at a
session's start — these ARE the baseline.**

**FENCES (binding on every batch):**
- **ZERO server-side deploys, zero lockstep, zero schema — marker stays 8.** No agent runs SQL
  against the production mirror this run (the PAT stays untouched); the live mirror sees only her
  devices' own app traffic at the coordinated window. A fix that wants a mirror change, a schema
  change, or a §12 event STOPS AND REPORTS (it is a 13y candidate or hers).
- **The 13y-adjacent residuals are NOT ours — re-verify owners, never absorb:** the dedupe's
  late-registry legs (KnownIssues row 33, owner **18a**) · the daily-Journal identity + the
  renamed-book corner #85(a) (row 32, owner **13i-e**) · the per-tenant seq / key-proof challenge /
  A5-horizon-one-source-of-truth (**13y**'s row) · pull-to-head memory (row 17, owner **12**) ·
  the general poison-row park/heal DESIGN (row 19, owner **12**) — P8's fix, if one is owed, is
  the narrow traced mechanism, never the park/heal subsystem; P31's fix surfaces the stall
  honestly, never designs the heal.
- **Canon outranks code:** a probe that falsifies a SyncSpec sentence is a finding against the
  CODE unless she rules the sentence wrong — log such to `notes/QUESTIONS.md`, never decide.
  Product-flavored gaps the probes expose (P2's returner corner is the known one) go to QUESTIONS
  as options, never built.
- Never touch `/Applications` or her real store mid-run; the install + phone refresh happen only
  at HER coordinated live-round window (see ACCEPTANCE below).
- 17e's rows (61 · 66 · 67), 17r, and 18a/18b are not this run's.

---

## BINDING PRINCIPLES — the 13b constitution (P-1…P-9, copied byte-verbatim per the skill; the application notes bind the same way)

- **P-1 — One capability registry.** Every user-facing act is declared
  exactly once: verb, scope (block/take/post/book), per-mode availability
  rule, its doors (menu / context / bar / shortcut / palette), and its
  refusal copy. Surfaces render their doors FROM the registry; gating is
  data, never per-view if-statements. A registry-walk test asserts every
  declared door exists and every rendered door is declared. This kills the
  D3/D4 class structurally — the capability matrix stays green by
  construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act —
  including any mode-switch choreography, done visibly for the user — or
  delivers the operations layer's real refusal. A door that can never act in
  its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface
  component (live + read modes; one measurement brain — the width-gated
  remeasure; the shared canary) that every pane composes; the live editor
  core's identity machinery (`BlockRangeIndex`, crystallization) becomes its
  live mode, not a sibling implementation. "What text does this pane show,
  and is it live" is answered by ONE pure, unit-tested authority
  (`PaneTextAuthority`); views never re-derive it. Its invariants stated as
  code: exactly one live pane; the live pane is buffer-authoritative; read
  panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter
  may announce that something happened (mode changed, post opened); no
  listener derives business state or availability from a broadcast, and no
  flow's correctness depends on broadcast ordering. Cross-feature flows
  route through composition. (Stage 0's survey enumerates today's
  notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule
  marks an under-architected feature. The response is never another patch:
  write the feature's DESIGN MEMO — intended behavior whole, edge cases
  enumerated on paper, refusal wordings, undo story — get the author's
  rulings on the product-flavored edges, then build to the memo. Happy path
  ships first, but the edges are *decided at design time*, not discovered by
  the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial
  flow is the contract for every happy path. It stays green — automated
  where the harness allows, screenshot-walked otherwise — and any change
  that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive
  harness: the ops-layer soaks (exist), the board/view-model invariant soak
  (Stage 1), the registry walk (P-1), the per-batch scripted screenshot
  walkthrough. Red-on-old stays absolute: no bug-class fix without a pin
  that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind
  the rebuilt layer exactly as they bind the substrate (invalidation ∝
  realized rows; one live editor; virtualized long views). Overlays, never
  rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit`
  (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary.
  Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing
  board layout, text authority, and gesture routing splits by concern
  (`TakesViewModel` at 890 lines is the standing counterexample). Same
  hygiene rule as the substrate, applied where it was being waived.

**Application notes (13b's build record, binding as stated in the skill):** P-1's scope is the
ROUTED vocabulary, grown incrementally. P-3 keeps TWO deliberate surface kinds. Storage-coupled
code lives feature-side; parity refactors keep every pre-move name as computed
forwards/typealiases so every existing pin compiles UNMODIFIED (the 3C pattern). Every
equality-gated sink delivers its stored state AT WIRE TIME; overlay geometry refreshes trigger on
EVERY input axis. The closing form for a recurring fixed class is the sweep table: instance ×
host/path, each cell FIXED-with-named-pin or provably SAFE.

**Run-relevant notes:** this run is engine-and-harness work, so P-7 (find bugs before she does —
the hunt IS this principle run as a batch) and the postmortem's lesson 8 (*"any future sync test
that doesn't exercise the production path is decoration"* — the harness-realism deliverable's
whole reason) carry the weight; the UI principles bind trivially (no chrome expected in the diff).
`notes/sync-postmortem-fragments.md` is the standing read before ANY `Sync/` line — every batch
brief names it.

---

## THE LEDGER (every row owned; a row closes FIXED-with-named-pin · DISMISSED-AS-HOLLOW / REFUTED · RECORDED-with-owner · DEFERRED-with-owner)

| # | Batch | Item (the binding text is the 17 entry's / the memo's) | Status |
|---|---|---|---|
| 1 | B1 | **Probe P1** — delete-vs-edit-plus-new-take (her scenario): N in the Trash on both, matching stamp; T2 tombstoned with N's exact stamp; **T1's `working_text` on the laptop after the merge — new or old? — RECORDED**; `restoreContainer(N)` on the laptop: what comes back, and does it converge to the phone | **CONFIRMED — canon, green pin** (the laptop's NEW text rides into the Trash on both; Put back converges byte-identically) |
| 2 | B1 | **Probe P2** — the same, deletion PURGED before resume: (a) ASSERT the horizon HOLDS the purge while the laptop is a live device; (b) the 60-day drop-out returner meets `purged` — **what it does LOCALLY with dirty T1 + new T2, RECORDED** (the unsettled corner → QUESTIONS with options, never decided) | **(a) CONFIRMED — green · (b) RECORDED — the silent family-complete drop pinned as shipped; QUESTIONS #141 filed, hers** |
| 3 | B1 | **Probe P3** — edit-vs-edit on one take (S5): loser is a `'conflict'` card on the same block; nothing lost either side (expected confirm; lands as a green pin) | **CONFIRMED — green (production order, sizes 200/1)** |
| 4 | B1 | **Probe P4** — the round-shape sweep: the convergence suites' CORE scenarios re-run under production's round shape (pull → push, 200-row chunks each its own server transaction, interleavings) + a chunk split at each registry boundary the scenario crosses; **any pin that passes only in the harness's order is a finding** (recorded as a new ledger row) | **RUN — 0 new findings** (7 scenarios green; the seq-0 placement observation recorded as canon-conforming) |
| 5 | B1 | **Probes P5(b) + P5(c)** — the dedupe double-retirement race (classifier's push delayed past the other device's pass, evidence changed between) · the echo pull's extra round per two-copy meeting; RECORDED (fence: the late-registry legs are 18a's — re-verify, don't absorb) | **(b) REPRODUCED — hunt finding F-1 → NEW ROW 15 (B2), the orchestrator's ruling below · (c) CONFIRMED — designed cost, green pin (3-round cadence made precise)** |
| 6 | B1 | **17d P8 — THE RUN** (the entry's own rule: reproducing it IS the red-on-old pin; not reproducing it closes it REFUTED): the deterministic construction the verifier named — hold B's push (`FakeSyncServer.holdPushes`), let A pull + sweep, release (`commitHeldPushes`) — a mirror orphan whose pull stalls A's cursor forever. Read against `notes/plans/phase-13j-purge-memo.md` §4f | **CONFIRMED — REPRODUCED in BOTH constructions** (held-push + visibility-band, wrapped citing row 9; row 9 LIVE for B2) |
| 7 | B2 | **17i fix item 1** — the general `tag.path` repair honors §7's own sentence for applications arriving AFTER the duplicate died (KnownIssues row 34; pre-existing since Phase 5, MAJOR). Pin as the row states it: two devices create "ideas" offline, each applies it to its OWN note, converge → both notes tagged on both devices (red on old: one application dead) | open |
| 8 | B2 | **17i structural item R3-2** — the seed-shape guard invokes the REAL classifier (`Queries.isDailyJournalMintShape`) instead of mirroring its SQL | open |
| 9 | B2 | **17d P8 — the fix**, per row 6's verdict (a reproduced mechanism gets a fix whose DESIGN the implementer proposes and the orchestrator rules BEFORE building — client-side only; a fix wanting server lines stops and reports as a 13y candidate). REFUTED at row 6 ⇒ this row closes with it | open |
| 10 | B2 | **17d P9** — `expandContainer`'s member-block arm is liveness-conditional: a LIVE container root purges the note + placements while orphaning every block it held (incl. the verifier's more-reachable road: the in-transaction re-expand after `executePurge` racing a Put back) | open |
| 11 | B2 | **17d P28** — `reapplyStructural`'s untombstoning loop is the ONE revive road that does not `voidPurgeIntents`; a leftover Delete-Now intent later claims the block and strips its 30-day window | open |
| 12 | B2 | **17d P31** — a permanently stalled pull cursor reports a clean round forever: `PullReport.stalled` (and `PushReport.deferred`) gain a production reader (the `BridgeScheduler.status.stalled` precedent); the status surface stops saying "fine" under a stall | open |
| 13 | B3 | **17l item 5** — the double passphrase ask at a follow after a rotation (KnownIssues row 37): when the passphrase is UNCHANGED at a rotation, `RotationSecrets` re-wraps under the EXISTING descriptor (same salt → same derived key; the wrapped payload is the new master). **HER SCOPE (2026-09-07): passphrase wrap ONLY — the recovery-words wrap keeps its fresh salt at every act, and a pin asserts the two descriptors stay independent.** Pin: a sibling that opened by the passphrase follows a Replace All Keys with zero prompts (red today) | open |
| 14 | B4 | **The harness-realism structural deliverable** — `productionRound` (built in B1 as the hunt's instrument) becomes the convergence suites' DEFAULT; chunk splits at registry boundaries as a sweep; every suite green under the NEW shape | open |

| 16 | B4 | **S1's Q2 NIT (the hosted stress pass)** — `sync_reencrypt` under an OLD key proof is the one data RPC the attacker suite never fires; it HOLDS structurally (`sync_key_gate`) — a TENTH arm in `MultiTenantSyncAttackerTests` (or the fake-server twin) pins it. Test-only; green-by-design is this row's expected verdict (a coverage pin, not a defect claim) | open |
| 15 | B2 | **F-1 (B1's hunt, probe P5(b))** — the dedupe double-retirement race: an edit landing between the seed-push and the two devices' passes, with the editor's pushes delayed across its own two pulls, retires BOTH copies on both devices AND loses the edit's bytes outright (pull-first merges the pristine tombstoned baseline over the dirty row; rescue skips block-dead; the cleared outbox means the edit never reaches the server). Breaks R-pre13u-8's "an edited copy is NEVER silently retired" and §6's forbidden outcome IN THE BYTES. Red pin waiting wrapped: `p5bTheDoubleRetirementRaceRetiresBothCopiesAndLosesTheEdit`. **Fix constraints (the orchestrator's, at the F-1 ruling):** the outcome must land on the ruled matrix — exactly-one-edited ⇒ the EDITED copy survives; both-edited ⇒ both survive; deterministic on both devices; err toward EDITED. Design fork: the implementer proposes, the orchestrator rules, repo-first, before the build. **Escape valve:** if the honest fix is a redesign of the dedupe's occasions rather than a repair-rule-scale change, STOP AND REPORT — the row then closes RECORDED → 18a beside KnownIssues row 33, the pin standing wrapped | open |

*(Hunt findings from B1 join the ledger as new rows at B1's adjudication — each owned: fixed in
B2, or RECORDED with a named owner outside the run. F-1 is row 15; F-2 was already owned as
row 9.)*

---

## ENVIRONMENT TRAPS (every batch brief carries this section verbatim)

- **The loop is the core package:** `swift build` / `swift test --filter <SuiteName>` from the
  repo root — no Xcode project needed for engine/harness work. The FULL core suite runs at each
  batch's close (baseline 1639/177); the full Mac suite ONLY at the run's finals (baseline
  3086/509 — never at a session's start). Swift Testing's "Test run with N tests" line COUNTS
  skipped tests — read the `skipped:` lines before claiming a gated suite ran.
- **The two-client harness lives in `Tests/VariorumCoreTests/Support/`** — `SyncTestHarness.swift`
  (two in-memory clients), `FakeSyncServer.swift` (in-process; `visibilityHorizon`, `holdPushes` /
  `commitHeldPushes` — built for the A5 skew), `FaultInjectingTransport.swift` (chunking via
  `batchSize`, drops, re-entrancy). The convergence suites: `SyncConvergenceTests` ·
  `SyncMergeTests` · `SyncRepairTests` · `SyncPullTests` · `SyncPushTests` ·
  `FaultInjectionSyncTests` · `EditorRateSyncTests` · `StructuralSessionSyncTests` ·
  `MobileCaptureSyncTests` · `MultiTenantSyncTests` (+ `MultiTenantSyncAttackerTests` — custody
  pins; touch only if a fix moves what they pin).
- **A reproduced defect the batch is not fixing lands as a `withKnownIssue`-wrapped probe citing
  its ledger row** (the row-51 pattern) — the suite stays green, the red stays visible, and the
  fix batch unwraps it as its red-on-old pin. Never commit a bare red test.
- **Zero mirror access:** no SQL against production, no PAT use, no deploys. The
  `SupabaseTransport` integration pass is NOT this run's; the live evidence is her devices at her
  window.
- **Mac-suite runs at finals:** from `App/Variorum/`, suite-level `-only-testing` only; selectors
  written LITERALLY on the command line (the `-only-testing`-in-a-variable trap prints
  `Executed 0 tests` + `TEST SUCCEEDED`); NEVER a custom build configuration (non-"Debug" builds
  SPM deps RELEASE and strips the DEBUG-gated oracles); zsh `pipestatus`. The flake list
  (adjudicate by the paired interleaved protocol, never one isolated run): the
  differential-latency pin · `CanvasDragTrackingTests` · `BlocksWorkbenchFaceTests`' single-click
  · the row-49 landing arm · `ModeSwitchCarryTests`' top-of-Write arm.
- **Instance checks before any Mac-suite run:** `pgrep -fl 'Variorum.app/Contents/MacOS'`,
  discriminate by PATH; real-store instances identified by STORE — NEVER quit or kill one; no
  Release builds or `/Applications` refreshes mid-run (the refresh is the closeout window's,
  behind the A1 rail, her app quit by HER).
- **Git:** never `git checkout` over uncommitted work; commit per piece and **PUSH after every
  commit**; **no commit trailers**; **stage PATHSPEC-LIMITED (`git add <your files>`), never
  `git add -A`** — the orchestrator edits shared records between your commits.
- **Session resiliency (the checkpoint protocol — binding from the FIRST commit):** the batch
  record's LIVE STATUS section written at the START and flipped in the same commit as each piece,
  unverified claims marked PENDING · synchronous foreground waits only, via the grep-poll loop
  (`grep -q '<EXIT LINE>' <log> && break; sleep 5` — never `tail -f | grep -m1`, never a
  backgrounded run you end your turn on) · never spawn subagents (ONE Sonnet lookup for external
  facts only; repo reading never delegated) · no revert starts until the record names it and the
  pre-revert state is COMMITTED · every death and resume noted in the record.

---

## CAST & DISCIPLINE

**Orchestrator: Fable — this session** (writes no feature code beyond adjudication/record acts).
**Implementer: Fable (`claude`-type agent on this model), a FRESH session per batch, strictly
sequential, one at a time, ONE batch each** (B1 → **S1, the hosted stress pass — read-only,
custody/postures, its own findings file, never a fix** → B2 → B3 → B4). **Cold review: ONE
`fable-reviewer` ladder over the run's COMBINED diff** after B4 (fresh reviewer per round; cap
three rounds). **This is a SAME-MODEL phase** — findings go to a fresh Fable fix session verbatim,
agree/dispute returns, and **the orchestrator arbitrates against the spec docs (the spec wins;
SyncSpec §§5–7 and §12 are the contracts under test)**; every finding gets a written disposition;
a dispute turning on undefined product behavior goes to `notes/QUESTIONS.md`.

**PIN BEFORE FIX on every item** — the hallucination guard: trace the mechanism yourself; every
bug-class fix lands with a red-on-old pin verified by BEHAVIOURAL REVERT; a pin green on both
sides is DISMISSED AS HOLLOW and recorded. **P8's own rule (the entry's):** the RUN is the pin —
reproducing it confirms, not reproducing it REFUTES and closes (a refuted row is not "hollow"
shame, it is the entry's designed outcome). Probes that CONFIRM canon land as green pins
documenting settled behavior — that is a deliverable, not a failure to find.
PROVISIONALs log to `notes/QUESTIONS.md` (next free number — check the file's end). Author-only
calls are hard stops. Batches close only on the orchestrator's verification (record spot-checks +
the suites' evidence); the run's sync-kind acceptance is below.

**ACCEPTANCE (the sync kind, per `notes/PhaseSizingGuidance.md` §1):** the convergence suites
green under the NEW harness shape (B4's close) **+ one live two-device round on the real mirror —
HER devices, HER window, coordinated at kickoff.** The window's shape: A1 backup → Mac install
refresh + phone build refresh (marker stays 8, so no refuse window exists) → she runs a round
each direction and we verify convergence from the app's own status; optionally (her call) a real
Replace All Keys to feel item 5's zero-prompt follow live. **Stated deviation, per the guidance's
own rule:** the install refresh PRECEDES this drill because the drill needs the new engine on her
devices — the sync twin of "the refresh follows the walk," recorded rather than silent.

---

## KICKOFF — her answers (2026-09-21, the kickoff sitting)

- **The live-round window: AT THE RUN'S CLOSE** (her pick of the recommended option) — batches →
  ladder → finals first; then ONE coordinated window (A1 backup → both refreshes → her round each
  direction); the orchestrator pings her when everything else is done.
- **The stress-test pass: HOSTED IN RUN B** (her pick) — one read-only Fable session in a
  sequential slot, **slotted as S1 between B1 and B2** (both hunts complete before the fix batch,
  so an in-scope finding can join B2's brief; out-of-scope findings file as 17/13y candidates).
  Its findings file: `notes/plans/run-b-stress-pass.md`.
- **The optional live Replace All Keys at the window (item 5 felt live): UNANSWERED — HELD** on
  her checklist for the window itself; the headless pins are the evidence either way.

---

## BATCH B1 BRIEF — THE HUNT (self-contained; read in this order)

**You are a Fable implementer session for RUN B batch B1 — the sync reconciliation HUNT.** You
build probes and record answers; **you fix NOTHING in this batch.** Every line you write is test
or harness code (`Tests/VariorumCoreTests/`), plus records.

**READ FIRST, in full, in your own context (never delegated):**
1. `CLAUDE.md` (the canon it loads — **SyncSpec WHOLE**; §§5–7 and §12 are the contracts under
   test; OverallModel §6/S2/S5).
2. `notes/plans/pre-13u-memo-sync-disagreements.md` **WHOLE** — the probes P1–P5 are its
   ⚠️ UNSETTLED section; your answers are RECORDED THERE.
3. `notes/sync-postmortem-fragments.md` — the standing read before any `Sync/` work; its lesson 8
   is this batch's doctrine.
4. `notes/plans/phase-17-standing-fixes.md` — entry **17i** whole, and **17d P8** (its finder
   claim + the verifier's trace name your repro construction) + the 13j purge memo
   `notes/plans/phase-13j-purge-memo.md` §4f (the contract P8 is read against).
5. This file's FENCES, ENVIRONMENT TRAPS, and LEDGER rows 1–6.
6. The harness: `Tests/VariorumCoreTests/Support/SyncTestHarness.swift`, `FakeSyncServer.swift`
   (`visibilityHorizon`, `holdPushes`/`commitHeldPushes`), `FaultInjectingTransport.swift`
   (`batchSize` chunking); skim `SyncConvergenceTests` + `SyncRepairTests` for the suites' idiom.

**THE WORK, in order:**
1. **Build `productionRound(client)`** in `Tests/VariorumCoreTests/Support/` — production's round
   shape as ONE helper: pull → push, pushes chunked at `batchSize` with each chunk its own server
   transaction, interleaving points exposed so two clients' rounds can be woven. This is the
   hunt's INSTRUMENT; converting the existing suites to it is batch B4's, not yours.
2. **Probes P1 · P2 · P3 · P5(b) · P5(c)** exactly as the memo states them, under production's
   round shape, in a new suite (suggested: `SyncReconciliationProbeTests.swift`). For each:
   record WHAT HAPPENS (rows, stamps, texts — the memo's own ASSERT-and-RECORD lists), then write
   the answer into the memo's ⚠️ UNSETTLED section (dated, with the pin's name). A probe that
   confirms canon lands as a GREEN pin. A probe that reproduces a defect lands
   `withKnownIssue`-wrapped citing its new ledger row — never a bare red. A probe that exposes a
   canon GAP (P2's returner corner is the expected one) gets its options drafted for
   `notes/QUESTIONS.md` in your record — the orchestrator files them; you never decide.
3. **17d P8's RUN** (ledger row 6): the deterministic construction from the verifier's trace —
   phone B creates block X inside note N; Mac A Delete-Nows N; both pull the intent; hold B's
   push of the cascade rows, let A pull + sweep (the purge expands from A's store, which never
   saw X), release B's push; assert whether A's next pull stalls forever
   (`SyncEngine.foreignKeysSatisfiable` → `stopIndex` truncation, cursor held). **Reproducing it
   IS the pin** (wrap `withKnownIssue`, cite row 9); not reproducing it after an honest
   construction — including the visibility-band variant — closes it REFUTED with the trace of why
   the window closes.
4. **Probe P4 — the round-shape sweep:** re-run the convergence suites' CORE scenarios (the
   memo's word — the scenario table's ✔ rows, not every test) under `productionRound` + a chunk
   split at each registry boundary the scenario crosses. Any pin that passes only in the
   harness's convenience order is a FINDING: record it (mechanism, which order, which split),
   `withKnownIssue`-wrap the production-shape twin, and list it for the ledger. **Fence:** if a
   finding is the dedupe's late-registry leg (KnownIssues row 33) or another owned residual,
   record + name the owner — do not absorb.
5. **Your record** (BATCH B1 RECORD below): LIVE STATUS from the first commit; per-probe answers
   (one section each, the memo's questions answered in its own terms); the findings list with
   your severity read; the QUESTIONS drafts; finals (full core suite green — the wrapped probes
   keep it green).

**Discipline (restated):** commit per piece + push every commit, pathspec-limited staging; LIVE
STATUS flipped in the same commit; foreground grep-poll waits only; no subagents (one Sonnet
lookup for external facts only); no revert without a committed pre-revert state; zero `Sources/`
lines (harness + tests + records only — if a probe cannot be expressed without a `Sources/` seam,
STOP AND REPORT to the orchestrator instead of adding one).

---

## BATCH B1 RECORD — THE HUNT

### LIVE STATUS (flipped in the same commit as each piece; unverified claims marked PENDING)

- [x] Record opened; brief + READ FIRST list read in full (SyncSpec whole, the memo whole, the
  postmortem, 17i + 17d P8 + the purge memo §2/§4f, the harness files, the engine +
  scheduler + janitor + Merge + Repairs + SampleLibraryDedupe sources).
- [x] `productionRound` helper (Tests/Support/ProductionRound.swift) — BUILT, compiles: pull→push
  per device at transport `batchSize` (each push chunk its own server transaction), the
  `ProductionStep` weave for cross-device interleavings, `productionQuiescence` (non-purge
  scenarios; the purge idiom stays explicit rounds + dump equality), and `pushSplitAtBoundary`
  (the registry-boundary chunk split via the armed mid-drain fault). Janitor legs deliberately
  composed per scenario, not baked in (the fault transport has no purge surface).
- [x] Probe P1 (delete-vs-edit-plus-new-take) — RUN, GREEN pin
  (`SyncReconciliationProbeTests.p1DeleteVsEditPlusNewTake`, batch sizes 200 and 1); answer
  recorded below; canon confirmed.
- [x] Probe P3 (edit-vs-edit, production shape) — RUN, GREEN pin
  (`SyncReconciliationProbeTests.p3EditVsEditOnOneTake`, batch sizes 200 and 1); canon confirmed.
- [x] Probe P2(a) (horizon holds while the laptop is live) — RUN, GREEN pin
  (`p2aTheHorizonHoldsThePurgeWhileTheLaptopIsLive`); canon confirmed; one deliberate
  consequence recorded (the 30-day window is the deletion's clock, not each device's discovery
  clock).
- [x] Probe P2(b) (60-day drop-out returner vs purged family) — RUN, GREEN pin
  (`p2bTheSixtyDayDropoutReturnerDropsItsEditsWithThePurgedFamily`); shipped behavior RECORDED
  (drop, family-complete, silent — the purge-wins letter); the canon GAP goes to QUESTIONS
  (draft below) — the orchestrator files it.
- [x] 17d P8 run (ledger row 6) — RUN: **REPRODUCED, BOTH constructions** (held-push
  `p8AHeldPushAcrossThePurgeWindowJamsThePullForever` + visibility-band
  `p8TheVisibilityBandVariantJamsTheSameWay`), each `withKnownIssue`-wrapped citing ledger row 9;
  reproduction facts asserted green; the answer + the observed mechanism refinements recorded
  below. Row 6 verdict: **CONFIRMED — reproducing it IS the pin; row 9 (the fix) is LIVE for B2.**
- [x] Probe P5(b) (dedupe double-retirement race) — RUN: **REPRODUCED**
  (`p5bTheDoubleRetirementRaceRetiresBothCopiesAndLosesTheEdit`, wrapped) — both copies retired
  everywhere AND the edit's bytes lost outright under production order; finding F-1 below;
  RECORDED with owner candidates (the 18a fence re-verified, not absorbed).
- [x] Probe P5(c) (echo pull's extra round) — RUN, GREEN pin
  (`p5cTheDeferralPlusTheEchoPullCostTwoRoundsPerMeeting`); the designed cost observed PRECISELY:
  the deferring device's own push ECHO re-defers, so meeting → echo → decide is a 3-round cadence
  under production order (the harness order folded meeting + echo into one window). Latency only.
- [x] Probe P4 round-shape sweep — RUN (`ProductionRoundShapeSweepTests`, 7 scenarios, all
  green): **0 new findings** — every ✔-row core scenario converges under production's round
  shape + registry-boundary chunk splits with the other device's round between the halves.
  Coverage map + the two out-of-reach ✔ rows (with reasons) live in the suite header and below.
- [x] Memo ⚠️ UNSETTLED section updated — a dated ANSWERED block with pin names under each of
  P1 · P2 · P3 · P4 · P5(b)/(c) (the section-header flip to "answered" stays the closeout's;
  the scenario table's two `?` rows likewise).
- [x] Finals: FULL CORE SUITE **1654 tests in 179 suites — PASSED, with exactly the 3 known
  issues** (the two P8 wraps + the P5(b) wrap; zero unexpected failures; the one standing skip
  is the sanctioned real-server integration gate). Baseline 1639/177 + B1's 15 probes in 2 new
  suites, exactly accounted. **BATCH B1 IS COMPLETE — awaiting the orchestrator's verification.**

### DEATHS / RESUMES

- none.

### PER-PROBE ANSWERS

#### P1 — delete-vs-edit-plus-new-take (ledger row 1): CONFIRMED — canon, green pin

Run exactly as the memo states it (production round shape, laptop resumes first), at transport
batch sizes 200 and 1. **The answers, in the memo's own terms:**

- **N is in the Trash on both devices, `deleted_at` matching** — the tombstone wins (rule 1); the
  phone's cascade stamp is the one stamp everywhere.
- **T2 exists on both, tombstoned with N's EXACT stamp** — the §7 orphan repair direction 2 stamps
  the live take arriving under the locally-dead block into the cascade; it rides Put back.
- **T1's `working_text` after the merge is the laptop's NEW text — on BOTH devices.** Mechanism,
  traced then observed: the phone's merge takes the server-wins baseline (the laptop's pushed
  edit) and overlays the phone's tombstone on it, so the edited text rides the row INTO the
  Trash; `rescueLosingText`'s block-live guard SKIPS the conflict card (the whole block died with
  the note — `rescueSkippedWhenTheWholeBlockDied`'s unit rule, now proven end-to-end at the
  whole-note scale). The phone's OLD text is the same take's pre-edit ancestor state, not a
  separate intent — no one's intent is lost; zero `'conflict'` rows exist afterwards.
- **`restoreContainer(N)` on the laptop brings back the WHOLE family and converges to the phone
  byte-identically**: N, the block, T1 (still the new text), T2 (its own text) — every row revived
  on the one exact stamp, both dumps equal after the settle.

Verdict: **the §6 rescue rule's whole-note-tombstone case resolves SAFELY under shipped code** —
deletion wins into the Trash, the edit survives on the row, the new take rides the stamp, Put
back restores everything. No canon sentence falsified; no fix owed. Positive-activity asserts pin
that the phone's resume round really merged (≥2), applied (≥1) and repaired (≥1) — the pass
cannot go vacuous.

#### P2 — the deletion PURGED before resume (ledger row 2): (a) CONFIRMED green · (b) RECORDED + a QUESTIONS draft

**(a) The horizon HOLDS while the laptop is a live device — confirmed, green pin.** With the
laptop silent but inside the 60-day window, the phone's sweep DEFERS the backdated family
(`familiesPurged == 0`, `familiesDeferred ≥ 1`) and nothing leaves the mirror. Once the laptop
pulls the tombstone (P1's merge dance runs — its edit rides the row into the Trash, T2 joins the
cascade) and both cursors re-record, the purge proceeds family-complete, the laptop reconciles
through the ledger, and both stores converge to zero family rows.

**One deliberate consequence, recorded (no defect):** the 30-day window belongs to the DELETION's
clock (`TrashWindow.cutoffStamp` compares `deleted_at`), not to each device's discovery clock. A
laptop offline longer than the window sees the family land in its Trash and purge moments later —
the horizon guarantees every live device SEES the deletion before the bytes go (13j memo §2's
letter), not that each device's own 30 days restart. Canon-conforming; noted for 18a's design
sitting since it borders the same product territory as (b).

**(b) The 60-day drop-out returner — the memo's unsettled corner. THE ANSWER: DROP,
family-complete, silently.** Shipped mechanism, production path (the scheduler's B2
ledger-reconciliation pre-pass runs BEFORE each round's drain):

- the ledger names every row the purging device knew (N, the block, T1 — never T2, whose id the
  server never saw);
- the pre-pass expands those roots against the RETURNER's own store (`PurgeFamily.expand` —
  `expandBlock` takes variants liveness-blind), so the dirty T1 edit AND the never-pushed T2 are
  physically deleted with the family, their outbox entries swept;
- the subsequent round is CLEAN: `push.purged == 0` (the refusal never fires — nothing left to
  refuse), no stall, and **no mirror orphan** (T2 never lands — the
  `aReturnersUnpushedChildNeverLandsAsAMirrorOrphan` guarantee re-proven on her scenario);
- **no say-so fires**: `deviceLeftBehindReloadRequired` gates on the ledger FLOOR, which stays 0
  until ledger pruning exists — so the returner's unpushed writing under a purged family is
  discarded with NO surface at all.

This is the purge-wins doctrine's letter, stated at `PurgeJanitor.reconcileLedger`'s own comment
— the CODE conforms to canon (13j memo §2 + §4f). Whether the PRODUCT wants more than silence is
the gap. **QUESTIONS DRAFT (for the orchestrator to file at the next free number):**

> **The 60-day drop-out returner's edited-purged-rows corner (17i probe P2(b), RUN B B1).** A
> device that left the horizon returns holding unpushed edits to (and new takes on) a family
> other devices purged. Shipped behavior, pinned: the ledger pre-pass drops the family —
> including the unpushed writing — locally and silently; no refusal fires, no say-so exists
> (the say-so road gates on ledger pruning's floor, which is 0). "Nothing typed in either app
> can be permanently lost" and the purge-wins doctrine collide here. Options: **(a)** keep the
> silent drop (her own deletion, 30+ days aged; the returner was gone 60+ days — the drop is the
> designed convergence; zero code); **(b)** before dropping, RESCUE the family's locally-dirty
> texts and never-pushed takes into a fresh local note (the conflict-as-variant instinct applied
> at the purge boundary; the rows still drop, the words survive); **(c)** SAY SO without
> rescuing: one visible line (count + dates) when the pre-pass discards unpushed writing, the
> R-13j returner grammar extended to the floor-0 road. PROVISIONAL: shipped (a) stands until she
> rules; the probe pins (a) as the current contract.

#### P3 — edit-vs-edit on one take, production shape (ledger row 3): CONFIRMED — canon, green pin

S5 end-to-end under production's pull→push order at batch sizes 200 and 1: the loser lands as
exactly ONE `'conflict'` card on the same block; both texts live on both devices; dumps equal.
The Phase 5 pin's claim survives the round shape production actually runs.

#### 17d P8 — the purge-window mirror orphan (ledger row 6): REPRODUCED, both constructions — row 9 is live

**The run's rule discharged: reproducing it IS the red-on-old pin.** Both deterministic
constructions land the permanent jam, `withKnownIssue`-wrapped citing ledger row 9 (B2 unwraps
the desired-contract block as its red-on-old pin):

- **Held-push** (`p8AHeldPushAcrossThePurgeWindowJamsThePullForever`): phone B mints block X
  inside converged note N offline; Mac A Delete-Nows N and rounds; B's round applies N's
  tombstone (X joins the cascade, N's exact stamp) and B's push of X's three rows is HELD
  (`FakeSyncServer.holdNextPush` — seqs assigned, invisible); A's sweep expands N's family from
  A's store, which never saw X, and `executePurge` removes + ledgers exactly what A knew; the
  held transaction commits; X's rows surface above A's cursor.
- **Visibility-band** (`p8TheVisibilityBandVariantJamsTheSameWay`): the same shape with NO held
  transaction — `FakeSyncServer(visibilityHorizon:)`; B's push commits inside the band, A pulls
  and sweeps within it, the clock leaves it. The window production actually has (~2 s).

**Observed mechanism, two refinements on the verifier's trace (recorded for B2's design fork):**

1. The stall lands AT the orphaned placement, not at the batch's head: block X and variant VX
   APPLY (their FK closures resolve in-batch — X's pushed row carries a NULL
   `last_container_id`, since `newBlock` never sets it and the cascade doesn't either; only
   `deleteBlock` stamps it), the cursor advances past them, then `container_block.container_id →
   N` fails both locally and in-batch, `stopIndex` truncates, and the cursor holds JUST BELOW
   the placement — permanently. A therefore ends up holding a tombstoned X + VX with no
   placement and no container: harmless rows, but the placement above them jams the feed.
2. The jam is PERMANENT and ONE-WAY, asserted: A's ledger reconcile names nothing A still holds
   (scan point advances, nothing drops); B's reconcile sweeps X LOCALLY on B — after which **no
   device holds any row or tombstone for the mirror's orphan** — and nothing ever removes it
   from the mirror; a fresh note B then writes lands above the stall and can NEVER reach A
   (asserted by id). Silent under P31's green light (row 12 is the honesty half).

**For B2 (row 9):** the fix design fork is the implementer's to propose and the orchestrator's
to rule BEFORE building — client-side only; anything wanting server lines stops as a 13y
candidate. The two wrapped desired-contract blocks ("bounded rounds + reconciles after the
release must clear the jam") are the red-on-old pins waiting to unwrap.

#### P5(b) — the dedupe double-retirement race (ledger row 5): REPRODUCED — hunt finding F-1

**Construction (the memo's traced observation made deterministic):** A seeds copyA, B seeds
copyB, both push (the server holds copyB's PRISTINE bytes); B then edits a copyB note — the edit
sits in B's outbox and B's pushes are delayed from here; B's two pulls run its pass on LOCAL
evidence (copyB edited → keep it, retire copyA — the ruled outcome, on B's evidence); A's two
pulls run its pass on the SERVER's evidence (both pristine → retire copyB, smaller-id keeper —
correct, on A's evidence); the delayed pushes then land, production order per device.

**Observed, asserted green:** the two retirements CROSS — tombstones win both ways, **both
copies end dead on both devices** (the shipped sample library vanishes into the Trash whole),
the stores CONVERGE (this is a ruled-outcome violation, not a divergence) — **and the edit's
bytes are LOST OUTRIGHT**: B's resume round pulls A's retirement BEFORE pushing (production's
own order), the merge lands the server's pristine tombstoned baseline over the dirty edited row,
`rescueLosingText` skips because the block died earlier in the same batch, and the cleared
outbox entry means the edit never reaches the server at all. Zero rows anywhere carry the edited
text, live or tombstoned.

**Severity read (mine, for adjudication): MAJOR.** It breaks two ruled sentences at once — "an
edited copy is NEVER silently retired" (R-pre13u-8) and §6's "deleting an edit nobody chose to
lose is the one forbidden outcome" — and the second breaks in the BYTES, not merely to the
Trash. Tempered by: the window needs an edit landing between the seed-push and both passes with
the editor's pushes delayed across its own two pulls (a real but narrow interleave); the event
class is once-per-store-life (two independently-seeded copies meeting); and in real use the
savepoint occasions often insure the text (though a mid-session autosave-only edit, as probed,
has no savepoint). **Ownership: NOT row 33's late-registry leg** (that class is engagement rows
in post-`post_tag` tables travelling in a trailing chunk; this class is evidence CHANGING
between two devices' passes — re-verified, not absorbed). Candidates for the orchestrator:
(i) a new ledger row fixed in B2 (a dedupe-shaped fix — e.g. the pass refuses to classify a copy
whose rows carry pending LOCAL dirt for the other side, or retirement tombstones carry a
distinguishing mark the editing side's merge rescues against); (ii) RECORDED to 18a beside row
33 (the deletion-aware-sync design sitting owns the posture). The wrapped pin
(`withKnownIssue`, "the edited copy must survive on both devices") waits for either owner.

#### P5(c) — the echo pull's extra round (ledger row 5): CONFIRMED designed cost, green pin — with a sharper mechanism than the memo's phrase

Under PRODUCTION rounds the deferring device takes THREE rounds from meeting to decision:
round 1's pull brings the other copy (arrived-this-batch deferral + the one-shot marker, R2-3);
**round 2's pull is NOT empty — it serves the device's OWN push echo back** (its copy's rows sat
above its cursor after round 1's push half), the echo re-applies that copy's `reading` row, and
the arrived-this-batch rule RE-DEFERS and re-arms the marker — this is "the echo pull" of the
memo's observation; round 3's genuinely-empty window fires the pass and decides. The harness's
convenience order had folded the meeting and the echo into ONE window (push-both-then-pull), so
the old suites recorded a 1-round deferral; production's shape shows 2. Latency only —
convergence intact, verdicts unchanged, pinned as a stated fact.

#### P4 — the round-shape sweep (ledger row 4): 0 NEW FINDINGS — every core scenario converges under production shape + boundary splits

`ProductionRoundShapeSweepTests`, seven scenarios, each pull→push per device with a mid-drain
chunk split at a registry boundary the scenario crosses and the OTHER device's full round
between the halves:

| Scenario (✔ row) | Shape + boundary | Outcome |
|---|---|---|
| edit-vs-edit (S5) | split at `variant` (+ probe P3 at sizes 200/1) | GREEN — 1 conflict card, nothing lost |
| delete-take-vs-edit, block lives | split at `variant` (tombstone stranded) | GREEN — edit rescued, tombstone honored, I10 holds |
| I10 double-tombstone | split at `variant` | GREEN — same `'rescued'` survivor on both, seq-deterministic |
| placement race (I2) | split at `container_block` (A's placement never accepted) | GREEN — the never-accepted row ranks seq 0 and LOSES (SyncSpec §3's own sentence; the split changes WHICH row wins vs the both-pushed order — deterministically, not divergently; recorded as an observation, not a finding) |
| rename/rename CAS | production, sizes 200/1 (single-table — no cross-table boundary exists) | GREEN — first-landed wins, lost rename only |
| concurrent divide | split at `edge` (edge AND placement chunks stranded) | GREEN — the documented B₁C₁B₂C₂ duplication, byte-identical |
| daily-Journal keeper | production rounds at chunk-per-row (batchSize 1) | GREEN — one keeper, both entries, designation converged. (The tombstone-vs-re-point cross-chunk orders are the furniture suite's existing F1 pins — not duplicated.) |

**Covered elsewhere, not duplicated:** the sample-library dedupe's production-shape runs are
probes P5(b)/P5(c); its `post_tag`-boundary chunk split is the R2-1 reserved-tag completeness
guard's own pinned territory (`SampleLibraryDedupeRepairTests`). **Out of sweep reach, with
reasons:** the restored-old-backup re-key row (a custody/backup-matrix behavior — wave 2a's
pins, not a two-client convergence scenario) and the seed-gate-declines row (app-target seeder
logic, outside the core harness).

**One construction lesson recorded honestly:** the sweep's first run flagged S2/S3 red on
`variantIsChosen` — my constructions, not the code (deleteVariant refuses a chosen variant BY
DESIGN; the suites' null-the-chosen seed idiom applies) — and S4 red on my INVERTED expectation
(I predicted later-landing wins; the spec ranks a never-accepted row 0). Both were probe bugs;
zero product findings.

### FINDINGS LIST (B1's hand-over to adjudication)

| # | Finding | Severity (mine) | Pin | Owner status |
|---|---|---|---|---|
| F-1 | P5(b): the dedupe double-retirement race retires BOTH copies (the edited one included) and loses the edit's bytes under production order | MAJOR | `p5bTheDoubleRetirementRaceRetiresBothCopiesAndLosesTheEdit` (wrapped) | NEW — candidates: B2 row, or RECORDED → 18a beside KnownIssues row 33 (not row 33 itself — re-verified) |
| F-2 | 17d P8: the purge-window mirror orphan permanently jams the pull, one-way and silent | MAJOR (the entry's own rating) | `p8AHeldPushAcrossThePurgeWindowJamsThePullForever` + `p8TheVisibilityBandVariantJamsTheSameWay` (both wrapped) | OWNED — ledger row 9 (B2) |
| — | P2(b)'s silent-drop returner corner | product gap, not a defect | `p2bTheSixtyDayDropoutReturnerDropsItsEditsWithThePurgedFamily` (green, pins shipped behavior) | QUESTIONS draft above — the orchestrator files |
| — | P2(a)'s deletion-clock window consequence · P5(c)'s 3-round cadence | recorded facts, no defect | green pins | noted for 18a's sitting |

### B1 FINALS

Core suite: **1654 tests / 179 suites, PASSED, exactly 3 known issues** (the wraps: 2 × P8, 1 ×
P5(b)); one standing sanctioned skip (the real-server integration gate). Files added:
`Tests/VariorumCoreTests/Support/ProductionRound.swift` (the instrument),
`Tests/VariorumCoreTests/SyncReconciliationProbeTests.swift` (8 probes),
`Tests/VariorumCoreTests/ProductionRoundShapeSweepTests.swift` (7 sweep scenarios). Zero
`Sources/` lines, zero mirror access, zero schema — the fences held. Per-ledger-row verdicts:
row 1 CONFIRMED-green · row 2 CONFIRMED-green (a) + RECORDED-with-QUESTIONS-draft (b) · row 3
CONFIRMED-green · row 4 RUN, 0 findings · row 5 REPRODUCED-wrapped (b) + CONFIRMED-green-cost
(c) · row 6 CONFIRMED-REPRODUCED (both constructions; row 9 live for B2).

---

### BATCH B1 — ORCHESTRATOR ADJUDICATION (2026-09-21; the batch CLOSES here)

**Verification, my own hands:** the eight commits read one by one (each pathspec-limited, each
pushed, honestly named); the record's LIVE STATUS all flipped with zero PENDING residue; the memo
carries a dated ANSWERED block with pin names under every probe (headers flip at closeout, per
the ritual); **the two new suites re-run by the orchestrator: 15 tests / 2 suites PASSED with
exactly the 3 known-issue wraps** — the two P8 constructions and the P5(b) race — matching the
record's finals exactly (the implementer's full-core claim of 1654/179 is arithmetic-consistent
with baseline 1639/177 + 15/2 and is spot-checked, not re-run; B2's close re-runs the full core).
Zero `Sources/` lines, zero mirror access, marker 8 — the fences held. **BATCH B1 CLOSES.**

**The F-1 ruling (recorded repo-first before any B2 session exists): F-1 is ROW 15, fixed in
B2.** Reasons: (1) 17i's own charter — *"every discrepancy found becomes an item here with the
standard trace + red-on-old pin"* — and P5(b) was a NAMED 17i probe, so its reproduction is
17i's item by design; (2) the class is DATA LOSS IN THE BYTES, breaking two ruled sentences
(R-pre13u-8's never-silently-retired; §6's forbidden outcome) — the project's worst class, with
the right cast already seated; (3) the 18a fence names the LATE-REGISTRY legs (KnownIssues row
33), which the implementer re-verified this is NOT — the fence's purpose was to keep 18a's
DESIGN work out, not to bounce a reproduced deterministic defect. The escape valve on row 15
keeps the fence honest: a fix that turns out design-scale stops and reports rather than absorbing
18a's sitting. Severity MAJOR sustained (the narrowing facts — the interleave window, the
once-per-store-life event class — temper reachability, not the class).

**The P2(b) product gap is FILED as QUESTIONS #141** (the implementer's draft, taken verbatim
with the filing frame; shipped behavior (a) stands PROVISIONAL until she rules). **RULED the same
sitting: (b) eventually, not now — parked as NEW ENTRY 17s (opens at her word); #141 and the 17
file carry her words. Ledger row 2(b) is therefore fully closed — recorded, filed, ruled, owned.** **P2(a)'s
deletion-clock consequence and P5(c)'s 3-round cadence** are recorded facts whose durable home is
the memo's ANSWERED blocks — 18a's sitting reads the memo; no unowned residue.

**Row 4's seq-0 observation** is canon working as written (SyncSpec §3's never-accepted-ranks-0
sentence) — recorded, no action, deliberately NOT a QUESTIONS row.

**Hand-note for S1 (the stress pass):** `Tests/VariorumCoreTests/Support/ProductionRound.swift`
now exists as a constructions instrument; F-1's and P8's constructions are worked examples if a
question's answer wants a runnable trace (S1 remains read-only — it cites, it never fixes).

---

### SLOT S1 — ORCHESTRATOR ADJUDICATION (2026-09-21; the slot CLOSES here)

**The hosted stress pass ran and returned 10 HOLDS · 0 FINDING · 0 OPEN** — the findings file
`notes/plans/run-b-stress-pass.md` (ten sections, each flipped in its own pathspec-limited
commit; verified by the orchestrator: 10 VERDICT lines + the summary, zero PENDING, the range
diff touching ONLY that file). No design hole; the sharp corners (the crash-resume
conflict-follow pair, the iCloud-reset mint-vs-heal gap, BLOCKER-1's seq-based guard) each held
exactly at the seam an adversary pushes. **Three routings, none a defect:**
1. **Q2's suite-completeness NIT → NEW LEDGER ROW 16 (B4):** `sync_reencrypt` under an OLD proof
   is structurally gated (`sync_key_gate`) but is the one data RPC the attacker suite never
   fires — a tenth arm pins it (test-only).
2. **Q3's operational caveat → RECORDED in its durable home** (`notes/plans/pre-13x-deploy-checklist.md`
   §10's standing caveat): an `11_pre13x_postures.sql` redeploy silently reverts the completion
   guard; the maintenance overlay re-runs after any 11 redeploy, and 13y's consolidated DDL
   should fold the guard in.
3. **Q10's 17n scope refinement → HER CHECKPOINT BUNDLE (propose-only):** the 12-CHARACTER floor
   is a length floor, not an ENTROPY floor — a human-chosen 12-char passphrase can still be
   brute-forceable; pairing the floor with a strength check is her call to want or decline
   (17n is closed; nothing reopens without her word).
The already-owned residuals S1 cited (13y · Phase 12 · 17m/#90 · 13x · ledger 61's PROVISIONAL)
were re-verified as owned — nothing absorbed, nothing unowned. **SLOT S1 CLOSES.**

---

## BATCH B2 BRIEF — THE FIXES (rows 7–12 + 15; self-contained; read in this order)

**You are a Fable implementer session for RUN B batch B2 — the fix batch.** Every defect you fix
was traced by B1's hunt or the 2026-08-30 sweep's verifier; your work is pin-first fixes, with
TWO design forks that go to the orchestrator before their builds.

**READ FIRST, in full, in your own context (never delegated):**
1. `CLAUDE.md` + the canon it loads — **SyncSpec WHOLE** (§§5–7, §12); OverallModel §6/S2/S5.
2. `notes/sync-postmortem-fragments.md` — the standing read before any `Sync/` line.
3. THIS FILE: the FENCES · ENVIRONMENT TRAPS · LEDGER rows 7–12 + 15 · the **BATCH B1 RECORD**
   whole (the mechanisms, the wrapped pins waiting for you, and the two P8 refinements are
   there) · the B1 and S1 adjudications.
4. `notes/plans/phase-17-standing-fixes.md` — entries **17i** (rows 7–8's letter) and **17d**
   (P8/P9/P28/P31's finder claims + verifier traces, which are your trace starting points, to be
   re-verified by your own hands — the hallucination guard).
5. `notes/KnownIssuesAndTechDebt.md` row 34 (the tag.path mechanism + its pin, stated).
6. `notes/plans/phase-13j-purge-memo.md` §4f (the contract P8's fix must honor).
7. The code as the rows name it: `Sync/Repairs.swift` (tag.path), `Sync/SampleLibraryDedupe.swift`
   + `Sync/Merge.swift` (F-1), `Sync/PurgeJanitor.swift` + `Sync/PurgeFamily.swift` +
   `Sync/SyncEngine.swift` (P8/P9), `Operations/Operations+UndoInverses.swift` (P28),
   `Sync/SyncScheduler.swift` (P31).

**THE WORK — two phases in ONE session:**

**Phase 1 (build now):** rows 7 · 8 · 10 · 11 · 12, each pin-before-fix, red-on-old verified by
BEHAVIOURAL REVERT, pins under `productionRound` wherever the scenario is a sync round:
- **Row 7 (tag.path):** the repair honors §7's sentence for applications arriving AFTER the
  duplicate died — the pin as KnownIssues row 34 states it (two devices, one path, each applied
  to its OWN note; both notes tagged on both devices after convergence; red on old).
- **Row 8 (R3-2):** the seed-shape guard invokes `Queries.isDailyJournalMintShape` itself —
  delete the mirrored SQL, never a second copy.
- **Row 10 (P9):** `expandContainer`'s member-block arm made liveness-safe for a LIVE container
  root; cover the verifier's more-reachable road (the in-transaction re-expand after
  `executePurge` racing a Put back). Honor "purge is never partial."
- **Row 11 (P28):** `reapplyStructural`'s untombstoning loop calls `voidPurgeIntents` like every
  sibling road, reason at the site (the B1-class one-liner; the entry's trace is the pin's
  scenario).
- **Row 12 (P31):** `PullReport.stalled` and `PushReport.deferred` gain production readers — the
  `BridgeScheduler.status.stalled` precedent; a stalled round STOPS reporting as a clean success.
  The scheduler half is `Sync/`; a minimal honest status face line in the App-side sync status
  surface is LEGAL for this row (keep it minimal; no new chrome vocabulary — P-8 binds).
**Then STOP building and write the two PROPOSALS** (below) into your record, hand back, and WAIT.

**Phase 2 (after the orchestrator's rulings arrive by message):** rows 9 and 15 built to the
rulings:
- **Row 9 (P8, the purge-window mirror orphan):** propose 2–3 candidate CLIENT-SIDE fix shapes
  with tradeoffs (the B1 refinements bind: the stall lands AT the placement; the jam is
  permanent/one-way; no device retains a root). A shape wanting server lines is a 13y candidate,
  not a proposal. Unwrap B1's two wrapped constructions as your red-on-old pins.
- **Row 15 (F-1, the dedupe double-retirement race):** propose per the row's fix constraints
  (exactly-one-edited ⇒ the EDITED copy survives; both-edited ⇒ both survive; deterministic on
  both devices; err toward EDITED). The escape valve is the row's: a design-scale-only answer is
  a STOP-AND-REPORT, not a build. Unwrap B1's wrapped pin as red-on-old.

**Fences restated:** zero schema, zero server/mirror lines, marker 8; `/Applications` and her
real store untouched; the 18a/13y/12-owned residuals stay owned (fix the traced mechanisms,
never the park/heal design or the dedupe's occasion redesign). Full core suite at your close
(baseline 1654/179 with 3 wraps — your finish line is the SAME tests with ZERO wraps: the three
wrapped probes become green pins as their fixes land).

**Your record:** append `## BATCH B2 RECORD — THE FIXES` below this brief: LIVE STATUS from the
first commit (every row a line, PENDING until verified); per-row trace-in-your-own-words +
pin + fix + revert verification; the two PROPOSALS as their own subsections (options, tradeoffs,
your recommendation); finals. **Checkpoint protocol (binding from the FIRST commit):** commit
per piece + push every commit, pathspec-limited staging (never `git add -A`); LIVE STATUS
flipped in the same commit; foreground grep-poll waits only; never spawn subagents (ONE Sonnet
lookup for external facts only); no revert without a committed pre-revert state; deaths/resumes
noted.

## BATCH B2 RECORD — THE FIXES

### LIVE STATUS (flipped in the same commit as each piece; unverified claims marked PENDING)

- [x] Record opened; brief + READ FIRST list read in full (SyncSpec whole + the canon load, the
  postmortem, this file's FENCES/TRAPS/LEDGER/B1 record/both adjudications, 17i + 17d whole,
  KnownIssues row 34, the purge memo whole, the disagreements memo whole, and the code as the
  rows name it — Repairs, SampleLibraryDedupe, Merge, PurgeJanitor, PurgeFamily, SyncEngine,
  SyncScheduler, Operations+UndoInverses, Operations+Purge, Triggers, the harness files, the B1
  probe suite, the Mac guard test, SyncStatusViews). Every Phase-1 mechanism re-traced by my own
  hands (per-row trace sections below).
- [x] Row 7 (tag.path arrival-order repair) — FIXED, red-on-old VERIFIED BY BEHAVIOURAL REVERT
  (pins `applicationsArrivingAfterTheDuplicateTagDiedRepointToTheKeeper` [200/1] +
  `blockTagApplicationsArrivingAfterTheDuplicateDiedRepointToo`; per-row section below).
- [x] Row 8 (the seed-shape guard invokes the real classifier) — DONE (architectural; both Mac
  guard tests green invoking `SampleCopyClassifier.classify` over the real seeds; section below).
- [x] Row 10 (P9: expandContainer's live-root member-block arm) — FIXED, red-on-old VERIFIED BY
  BEHAVIOURAL REVERT (pins `aLiveContainerRootExpandsItsLiveMemberBlocksFamilyComplete` +
  `aPutBackRacingTheSweepsMirrorPurgeNeverLeavesAPartialFamily`; per-row section below).
- [x] Row 11 (P28: reapplyStructural voids purge intents) — FIXED, red-on-old VERIFIED BY
  BEHAVIOURAL REVERT (pin `theRedoRoadVoidsALiveIntentLikeEverySiblingRevive`; section below).
- [x] Row 12 (P31: stalled/deferred gain production readers + the honest face line) — FIXED,
  red-on-old VERIFIED BY BEHAVIOURAL REVERT (core pins ×2 + Mac face pins; iOS build gate green;
  section below).
- [ ] The two PROPOSALS written (row 9 · row 15) — PENDING
- [ ] Phase 1 finals (full core suite; iOS build gate for the shared-file touches) — PENDING
- [ ] **PHASE 2 (opens only at the orchestrator's rulings):** rows 9 + 15 — PENDING

### DEATHS / RESUMES

- none.

### ROW 7 — the tag.path repair's arrival-order leg (17i fix item 1; KnownIssues row 34): FIXED

**The mechanism, re-traced by my own hands (not taken from the row):**
`repairTagPathCollision` (Repairs.swift) fires at write time when a live `tag` row collides on
path with a live local rival; it re-points only the duplicate's applications PRESENT at that
moment. An application arriving AFTER the duplicate died — the same pull batch suffices, since
registry order puts `tag` before both application tables — reached the orphan check
(`deadParentStamp`), met the freshly-dead parent, and was orphan-stamped into its cascade; that
tombstone (enqueued, pushed) then won the merge against the other side's re-pointed copy in both
push orders. The broken DIRECTION is the duplicate-holder-pushes-first order: under production's
pull→push, the device whose tag is the keeper meets the other side's un-repaired rows in one
batch. (The keeper-arrives-first direction already healed: the local collision repair re-points
local applications before they ever push.) The Phase 5 pin applied both tags to the SAME post,
which masked exactly this — it stays green beside the new pins.

**The fix:** `repointApplicationUnderDeadDuplicateTag` — a write-time leg in `writeResolvedRow`
between the Journal-keeper leg and the orphan check, the Journal keeper's direction-2 shape
applied to tags: a live `post_tag`/`block_tag` arriving under a locally-present DEAD tag while a
LIVE tag carries the same path re-points to that keeper (same-path is §7's identity for tags,
exactly as mint-shape is the Journal's), or tombstones as a pure duplicate when the keeper is
already applied to the same target; enqueued explicitly (§7's repair-write discipline). A
missing tag row stays a straggler (§5 tolerance); a dead tag with no live same-path keeper is an
ordinary deletion — the cascade takes the application exactly as ever. Deliberately a DURABLE
predicate, not batch-scoped state: it serves the same-batch letter AND any cross-batch arrival
(a real-concurrency chunk gap) by one rule, and cannot rot if pull windowing ever changes.

**Pins + revert:** `applicationsArrivingAfterTheDuplicateTagDiedRepointToTheKeeper` (sizes
200/1; production order, B-first; asserts the (c) outbox leg between the pull and push halves,
then both notes tagged on the keeper on both devices) + `blockTagApplicationsArrivingAfter…`
(the block_tag twin). RED ON OLD verified by BEHAVIOURAL REVERT against the committed fix
(`if false` on the leg → exactly the both-notes-tagged asserts fail, 6 issues; restored →
10/10 green). Suite `SyncRepairTests` 10/10.

**PROVISIONAL, for the orchestrator's QUESTIONS filing (drafted; I never decide):**

> **The recreated-tag catch (RUN B B2 row 7's one behavior consequence).** The arrival-order
> leg keys on the picture at arrival (a dead tag + a live same-path keeper), which is also the
> picture a deliberate tombstone-then-recreate leaves. Consequence: a stale offline
> application of the DELETED tag now re-points onto the recreation instead of dying with the
> deleted tag's cascade. Spec-defensible (the §7 sentence names the path as the identity; the
> Journal keeper's direction-2 does the same for mint-shape; §6's "deleting an edit nobody
> chose to lose" points the same way), and the alternative discriminators are worse: batch-
> scoped state misses cross-batch arrivals, and a keeper-id-ordering test made the outcome
> depend on random UUID order. Options: (a) keep the rescue (shipped by this fix); (b) narrow
> the leg to same-batch-retired duplicates only (re-opens the cross-batch loss). PROVISIONAL:
> (a) stands until she rules.

### ROW 10 — P9: a LIVE container root expands family-complete (17d P9): FIXED

**The mechanism, re-traced:** `expandContainer`'s member-block arm required
`b.deleted_at = c.deleted_at` — never true for a LIVE container — while placements, lenses,
canvas rows, references, tags and memberships were taken liveness-blind. Three purge-wins roads
can hand the expansion a live root: the engine's `.purged` refusal handler (SyncEngine ~:209 —
no liveness precondition on the pushed row), the janitor's in-transaction re-expand AFTER
`executePurge` (a Put back landing in the network window makes the root live — the verifier's
more-reachable road), and `reconcileLedger` (filters on `rowExists` only). On each, the note and
its placements went while its blocks stayed live, unplaced, `last_container_id` nulled by the
survivor detachment — invisible on every surface, the partial state `PurgeFamily`'s own header
("purge is never partial") forbids.

**Reachability, honestly stated (my own tracing, beyond the entry's):** on the ENGINE road and
the reconcile road the partiality is TRANSIENT in most constructions — the peer's `executePurge`
ledgered every family row, so the stranded blocks are refused `'purged'` as their own roots at
their own pushes (Put back enqueues them) and self-heal within a drain or a round; the verifier's
tempering said as much. The state that persists to the next round — and the contract violation
either way — is the janitor's race road, where the sweep ITSELF leaves the store partial and
every listing between that sweep and the next round shows a note-less orphan family. MINOR
sustained; fixed at the mechanism.

**The fix:** the member-block arm gains the LIVE-root arm — live blocks under LIVE placements
(what `deleteContainer`'s cascade would take) — dead-root behavior byte-identical (exact-stamp
victims only). A block deleted EARLIER still keeps its own clock (dead ⇒ no live placement); an
ARCHIVED block still never rides (archiving releases its placement, so the discriminator
excludes it by construction — verified against `performArchiveBlock`). `familyVerdict` is
unchanged in outcome: a live family row of a tombstoned kind already read `.stale` on the
janitor's collection road, and now the stale check sees the blocks too.

**Pins + revert:** `aLiveContainerRootExpandsItsLiveMemberBlocksFamilyComplete` (PurgeOpsTests —
the mechanism: live root ⇒ live member blocks + takes ride; earlier-deleted and archived blocks
excluded) and `aPutBackRacingTheSweepsMirrorPurgeNeverLeavesAPartialFamily`
(PurgeConvergenceTests — the verifier's road, deterministic via `ExecutePurgeHookedTransport`, a
one-shot hook landing the Put back between the mirror purge and the removal transaction; asserts
zero family rows post-sweep, then convergence with no stall). RED ON OLD verified by BEHAVIOURAL
REVERT against the committed fix (old WHERE clause restored → 7 issues, exactly the stranded
blocks/takes; restored → 32/32 green across both suites). The B1 probe suite stays green beside
it (P1/P2's whole-family scenarios exercise the dead-root arm byte-unchanged).

### ROW 11 — P28: the redo road voids purge intents (17d P28): FIXED

**The mechanism, re-traced:** `voidPurgeIntents` has six callers — every road that flips a
tombstone back (`revertDeleteBlock`, `revertDeleteVariant`, `restoreBlock`, `restoreVariant`,
`restoreContainerRows`, `restoreReading`'s), each with the 13j-ladder-B1 reason at the site —
and `reapplyStructural`'s `untombstoningBlocks` loop performs the identical
`deletedAt = nil` + `flipBlockCascadeTombstones` transition (its own comment names it
`revertDeleteBlock`'s exact shape) without the call. The other two re-applies are safe by
delegation (`reapplyMintedContainer` → `restoreContainer`; `reapplyImportedBlocks` →
`revertDeleteBlock`), so this loop was the single hole. Consequence chain verified with the
fences' own predicates: a live leftover intent hides the row from the Trash and the tray
unconditionally (`pi.deleted_at IS NULL`), and `familyVerdict` reads `.stale` only while the row
is LIVE — an ordinary re-delete before the next sweep flips it eligible and the janitor takes
the bytes with no Trash listing, no Put back, no 30-day window.

**The fix:** one call in the loop, the sibling roads' exact rule, reason at the site.
Block-level only, matching `revertDeleteBlock` (the cascade victims' own intents follow their
kinds' roads exactly as on the undo side).

**Pin + revert:** `theRedoRoadVoidsALiveIntentLikeEverySiblingRevive` (PurgeOpsTests, beside
its undo-road sibling) — the entry's trace through the REAL doors: divide → autosave in the
mint → `stack.undo` (trays the diverged mint) → `requestPurge` (the tray's Delete Now) →
`stack.redo` → asserts the intent is voided AND the ordinary re-delete lists on a fresh clock.
RED ON OLD verified by BEHAVIOURAL REVERT against the committed fix (call removed → both
asserts fail; restored → 15/15; undo/redo suites 65/65 across 5 suites).

### ROW 8 — R3-2: the seed-shape guard invokes the REAL classifier (17i structural): DONE

**The mechanism (architectural — the hallucination guard's written-justification class, no test
pin owed):** `theShippedSeedSatisfiesTheDedupesPristineContract` was a hand-copied mirror of the
classifier's SQL. What concretely degrades: a classifier LEG the mirror lacks (the class has
grown twice already — R2-5's five legs, R3-3's six named more) leaves the guard green while the
real classifier reads the shipped seed EDITED — the silent both-survive failure ("two Sherlock
books forever") the guard exists to announce, undetectable by any test that doesn't run the real
body. **The fix:** the classifier's ONE body moves to `public SampleCopyClassifier`
(`SampleCopyVerdict` public with it; the facts-taking wrapper derives manifest + reserved tag id
exactly as the engine's pass does); the engine's pass calls the same body — the row's letter,
"never a second copy" — and BOTH Mac guard tests (Sherlock + *Encryption Explained*) now assert
`classify(db, copyID:, facts:) == .pristine` over the REAL seed, with the per-leg walk kept as
diagnostics naming WHICH fact drifted when the invocation reds. Drift is now impossible by
construction: a new classifier leg runs inside the guard the moment it exists. Behavior
byte-unchanged (dedupe suites, probes, and both Mac guards green; the invocation assert is
green-by-design — the old mirror was faithful TODAY, which is exactly why this is architectural
and not a defect).

### ROW 12 — P31: the stall and the deferral gain production readers (17d P31): FIXED

**The mechanism, re-traced:** `SyncEngine.pull` truncates at the first FK-unsatisfiable row and
RETURNS NORMALLY (`report.stalled = true`, cursor held); `SyncScheduler.runOneRound` discarded
both reports (`_ = try await engine.pull()`) and unconditionally stamped
`lastError = nil / lastSuccessAt = now` — so a permanently jammed cursor (the P8 orphan class)
rendered "Synced <time>" forever while integrating nothing, one-way divergence under a green
light. `PushReport.deferred` (rows enqueued whose referents never arrived) was discarded the
same way. The pattern existed next door: `BridgeScheduler.status.stalled`.

**The fix:** `Status.pullStalled` + `Status.pushDeferredCount`, assigned from the round's own
reports on the SUCCESS branch (the precedent's shape — a thrown round learned nothing); the
shared status row gains the `.stalled` face — warning-toned, LITERALLY the idle row's doors,
ONE honest line (`stalledLabel` = "Sync incomplete — some changes haven't arrived yet") — which
decorates only the CLEAN branch (syncing/offline/error faces byte-unchanged, pinned). P-8 held:
no new chrome vocabulary, existing caption styles and door shapes only. The face's `stalled:`
parameter is DEFAULTED false so every existing state pin reads unmodified (the 3C spirit);
`VaultBootstrap`'s one-shot pull stays out of scope (its stall already surfaces through
`pullToHead`'s typed refusal).

**Pins + revert:** core `aStalledPullStopsReportingACleanRoundAsFine` (a clean round first —
flag false; then the P8 orphan shape minted cheaply test-side via `server.executePurge` — round
clean, `lastError nil`, `pullStalled` TRUE) and
`aDeferredPushIsNamedOnTheStatusRowAndClearsWhenItResolves` (the A5 visibility-band
construction: B's competing move commits inside the band, A's push defers at the reject whose
current row references an unseen container; the band passes and the signal clears) — RED ON OLD
verified by BEHAVIOURAL REVERT of the two assignment lines (both pins fail exactly at the
flags). Mac `SyncStalledRowTests` (the `.stalled` face + the never-outranks precedence),
suite-run green 18/2 beside the row-8 guards; **iOS BUILD SUCCEEDED** (the shared-file gate —
the pre-13u R3-2 lesson applied to its own namesake).

---

## BATCH B3 — 17l ITEM 5 (brief finalized at spawn; the settled scope)

Ledger row 13, the entry's text verbatim (`phase-17-standing-fixes.md` 17l item 5 + KnownIssues
row 37): the same-descriptor re-wrap at an UNCHANGED passphrase in `CorpusRotation.swift`
(`RotationSecrets.init`); a CHANGED passphrase keeps the fresh salt; **her scope line — the reuse
applies to the PASSPHRASE wrap ONLY**, the recovery-words wrap keeps its own descriptor and fresh
salt, a pin asserts the two descriptors stay independent. Pins: the zero-prompt follow (red
today) + the independence guard + a changed-passphrase-fresh-salt guard. The custody suites
(`MultiTenantSyncAttackerTests`, `CorpusRotationTests`, the rotation drill) ride the close.

## BATCH B4 — HARNESS REALISM (brief finalized at spawn; the settled scope)

Ledger row 14: `productionRound` becomes the convergence suites' DEFAULT round shape; the chunk
splits at registry boundaries land as a sweep (suite × scenario × boundary, each cell converted
or exempt-with-reason); every suite green under the new shape. The old convenience order survives
only where a test's SUBJECT is the order itself (named, with the reason at the line). This is the
postmortem lesson-8 deliverable: after B4, a sync test that doesn't exercise the production path
is decoration BY EXCEPTION, not by default.

---

## THE LADDER (ONE Fable ladder over the run's combined diff; opens after B4's record closes)

Fresh `fable-reviewer` per round, `notes/REVIEW_PROMPT.md` VERBATIM, zero framing; findings
recorded here repo-first before any fix session sees them; the SAME-MODEL flow (fix session
responds agree/dispute; the orchestrator arbitrates against canon; the spec wins); cap three
rounds; every finding dispositioned in writing.

## CLOSEOUT (opens at the ladder's close)

Dispositions copied into the 17 file (17i · 17d close; 17l item 5's disposition lands in 17l's
closed section as the deferred row's resolution); KnownIssues rows 34 + 37 resolved/re-owned; the
memo's ⚠️ UNSETTLED section flipped to answered; the master plan's order line 3 ticked; her
ratify bundle (QUESTIONS rows) assembled; the coordinated live-round window (A1 rail → install +
phone refresh → her round each direction → the evidence recorded here); the checkpoint report;
hard stop — **13y is next and is NOT this run's to start.**
