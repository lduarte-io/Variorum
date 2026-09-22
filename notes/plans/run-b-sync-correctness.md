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
| 1 | B1 | **Probe P1** — delete-vs-edit-plus-new-take (her scenario): N in the Trash on both, matching stamp; T2 tombstoned with N's exact stamp; **T1's `working_text` on the laptop after the merge — new or old? — RECORDED**; `restoreContainer(N)` on the laptop: what comes back, and does it converge to the phone | open |
| 2 | B1 | **Probe P2** — the same, deletion PURGED before resume: (a) ASSERT the horizon HOLDS the purge while the laptop is a live device; (b) the 60-day drop-out returner meets `purged` — **what it does LOCALLY with dirty T1 + new T2, RECORDED** (the unsettled corner → QUESTIONS with options, never decided) | open |
| 3 | B1 | **Probe P3** — edit-vs-edit on one take (S5): loser is a `'conflict'` card on the same block; nothing lost either side (expected confirm; lands as a green pin) | open |
| 4 | B1 | **Probe P4** — the round-shape sweep: the convergence suites' CORE scenarios re-run under production's round shape (pull → push, 200-row chunks each its own server transaction, interleavings) + a chunk split at each registry boundary the scenario crosses; **any pin that passes only in the harness's order is a finding** (recorded as a new ledger row) | open |
| 5 | B1 | **Probes P5(b) + P5(c)** — the dedupe double-retirement race (classifier's push delayed past the other device's pass, evidence changed between) · the echo pull's extra round per two-copy meeting; RECORDED (fence: the late-registry legs are 18a's — re-verify, don't absorb) | open |
| 6 | B1 | **17d P8 — THE RUN** (the entry's own rule: reproducing it IS the red-on-old pin; not reproducing it closes it REFUTED): the deterministic construction the verifier named — hold B's push (`FakeSyncServer.holdPushes`), let A pull + sweep, release (`commitHeldPushes`) — a mirror orphan whose pull stalls A's cursor forever. Read against `notes/plans/phase-13j-purge-memo.md` §4f | open |
| 7 | B2 | **17i fix item 1** — the general `tag.path` repair honors §7's own sentence for applications arriving AFTER the duplicate died (KnownIssues row 34; pre-existing since Phase 5, MAJOR). Pin as the row states it: two devices create "ideas" offline, each applies it to its OWN note, converge → both notes tagged on both devices (red on old: one application dead) | open |
| 8 | B2 | **17i structural item R3-2** — the seed-shape guard invokes the REAL classifier (`Queries.isDailyJournalMintShape`) instead of mirroring its SQL | open |
| 9 | B2 | **17d P8 — the fix**, per row 6's verdict (a reproduced mechanism gets a fix whose DESIGN the implementer proposes and the orchestrator rules BEFORE building — client-side only; a fix wanting server lines stops and reports as a 13y candidate). REFUTED at row 6 ⇒ this row closes with it | open |
| 10 | B2 | **17d P9** — `expandContainer`'s member-block arm is liveness-conditional: a LIVE container root purges the note + placements while orphaning every block it held (incl. the verifier's more-reachable road: the in-transaction re-expand after `executePurge` racing a Put back) | open |
| 11 | B2 | **17d P28** — `reapplyStructural`'s untombstoning loop is the ONE revive road that does not `voidPurgeIntents`; a leftover Delete-Now intent later claims the block and strips its 30-day window | open |
| 12 | B2 | **17d P31** — a permanently stalled pull cursor reports a clean round forever: `PullReport.stalled` (and `PushReport.deferred`) gain a production reader (the `BridgeScheduler.status.stalled` precedent); the status surface stops saying "fine" under a stall | open |
| 13 | B3 | **17l item 5** — the double passphrase ask at a follow after a rotation (KnownIssues row 37): when the passphrase is UNCHANGED at a rotation, `RotationSecrets` re-wraps under the EXISTING descriptor (same salt → same derived key; the wrapped payload is the new master). **HER SCOPE (2026-09-07): passphrase wrap ONLY — the recovery-words wrap keeps its fresh salt at every act, and a pin asserts the two descriptors stay independent.** Pin: a sibling that opened by the passphrase follows a Replace All Keys with zero prompts (red today) | open |
| 14 | B4 | **The harness-realism structural deliverable** — `productionRound` (built in B1 as the hunt's instrument) becomes the convergence suites' DEFAULT; chunk splits at registry boundaries as a sweep; every suite green under the NEW shape | open |

*(Hunt findings from B1 join the ledger as new rows at B1's adjudication — each owned: fixed in
B2, or RECORDED with a named owner outside the run.)*

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
sequential, one at a time, ONE batch each** (B1 → B2 → B3 → B4). **Cold review: ONE
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

## KICKOFF — her answers (recorded verbatim-faithful as they land)

- **The live-round window:** PENDING (asked at kickoff).
- **The stress-test pass (the pre-13x CONSIDERATIONS' ten questions — her-triggered, read-only;
  findings file as 17/13y candidates):** PENDING (asked at kickoff — hosted beside this run, or
  hers to run separately).
- **The optional live Replace All Keys at the window (item 5 felt live):** PENDING.

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

## BATCH B2 — THE FIXES (brief finalized at spawn, after B1's adjudication; the settled scope)

Ledger rows 7–12 + whatever B1 hands over: the `tag.path` repair (row 7, pin as stated) · R3-2's
classifier (row 8) · P8 per its verdict (row 9 — **design fork: the implementer proposes, the
orchestrator rules, repo-first, before the build**) · P9 (row 10) · P28 (row 11) · P31 (row 12).
Pin before fix on every row; pins under production's round shape wherever the scenario is a sync
round (the memo's own lesson — R2-1/R2-2 passed in the harness order and failed in production's);
red-on-old verified by behavioural revert. `Sources/VariorumCore/Sync/` +
`Operations+UndoInverses.swift` (P28) expected; zero schema, zero server lines.

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
