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
| 7 | B2 | **17i fix item 1** — the general `tag.path` repair honors §7's own sentence for applications arriving AFTER the duplicate died (KnownIssues row 34; pre-existing since Phase 5, MAJOR). Pin as the row states it: two devices create "ideas" offline, each applies it to its OWN note, converge → both notes tagged on both devices (red on old: one application dead) | **FIXED** (B2 P1 — `repointApplicationUnderDeadDuplicateTag`; two pins red-on-old by revert; #142 PROVISIONAL) |
| 8 | B2 | **17i structural item R3-2** — the seed-shape guard invokes the REAL classifier (`Queries.isDailyJournalMintShape`) instead of mirroring its SQL | **DONE** (B2 P1 — architectural; the one public classifier body invoked by pass AND guard) |
| 9 | B2 | **17d P8 — the fix**, per row 6's verdict (a reproduced mechanism gets a fix whose DESIGN the implementer proposes and the orchestrator rules BEFORE building — client-side only; a fix wanting server lines stops and reports as a 13y candidate). REFUTED at row 6 ⇒ this row closes with it | **FIXED** (B2 P2 — the ledger-verified orphan heal, ruled Shape A + tombstone narrowing; B1 wraps unwrapped red-on-old) |
| 10 | B2 | **17d P9** — `expandContainer`'s member-block arm is liveness-conditional: a LIVE container root purges the note + placements while orphaning every block it held (incl. the verifier's more-reachable road: the in-transaction re-expand after `executePurge` racing a Put back) | **FIXED** (B2 P1 — live-root family-complete expansion; two pins red-on-old) |
| 11 | B2 | **17d P28** — `reapplyStructural`'s untombstoning loop is the ONE revive road that does not `voidPurgeIntents`; a leftover Delete-Now intent later claims the block and strips its 30-day window | **FIXED** (B2 P1 — the redo road voids intents; pin red-on-old) |
| 12 | B2 | **17d P31** — a permanently stalled pull cursor reports a clean round forever: `PullReport.stalled` (and `PushReport.deferred`) gain a production reader (the `BridgeScheduler.status.stalled` precedent); the status surface stops saying "fine" under a stall | **FIXED** (B2 P1 — the stall + deferral surfaced honestly; pins red-on-old) |
| 13 | B3 | **17l item 5** — the double passphrase ask at a follow after a rotation (KnownIssues row 37): when the passphrase is UNCHANGED at a rotation, `RotationSecrets` re-wraps under the EXISTING descriptor (same salt → same derived key; the wrapped payload is the new master). **HER SCOPE (2026-09-07): passphrase wrap ONLY — the recovery-words wrap keeps its fresh salt at every act, and a pin asserts the two descriptors stay independent.** Pin: a sibling that opened by the passphrase follows a Replace All Keys with zero prompts (red today) | **FIXED** (B3 — the proven-by-unwrap reuse road; three pins, revert-verified core AND door; the nine attacker arms byte-untouched) |
| 14 | B4 | **The harness-realism structural deliverable** — `productionRound` (built in B1 as the hunt's instrument) becomes the convergence suites' DEFAULT; chunk splits at registry boundaries as a sweep; every suite green under the NEW shape | open |

| 16 | B4 | **S1's Q2 NIT (the hosted stress pass)** — `sync_reencrypt` under an OLD key proof is the one data RPC the attacker suite never fires; it HOLDS structurally (`sync_key_gate`) — a TENTH arm in `MultiTenantSyncAttackerTests` (or the fake-server twin) pins it. Test-only; green-by-design is this row's expected verdict (a coverage pin, not a defect claim) | open |
| 15 | B2 | **F-1 (B1's hunt, probe P5(b))** — the dedupe double-retirement race: an edit landing between the seed-push and the two devices' passes, with the editor's pushes delayed across its own two pulls, retires BOTH copies on both devices AND loses the edit's bytes outright (pull-first merges the pristine tombstoned baseline over the dirty row; rescue skips block-dead; the cleared outbox means the edit never reaches the server). Breaks R-pre13u-8's "an edited copy is NEVER silently retired" and §6's forbidden outcome IN THE BYTES. Red pin waiting wrapped: `p5bTheDoubleRetirementRaceRetiresBothCopiesAndLosesTheEdit`. **Fix constraints (the orchestrator's, at the F-1 ruling):** the outcome must land on the ruled matrix — exactly-one-edited ⇒ the EDITED copy survives; both-edited ⇒ both survive; deterministic on both devices; err toward EDITED. Design fork: the implementer proposes, the orchestrator rules, repo-first, before the build. **Escape valve:** if the honest fix is a redesign of the dedupe's occasions rather than a repair-rule-scale change, STOP AND REPORT — the row then closes RECORDED → 18a beside KnownIssues row 33, the pin standing wrapped | **FIXED** (B2 P2 — ride-the-row #143(a) + the kill-time defense per the AMENDED ruling; B1 wrap unwrapped red-on-old) |

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
  direction); the orchestrator pings her when everything else is done. **DECLARED READY
  2026-09-22 (her word, mid-B4: "i've closed my app, so the live window should be considered
  ready - my phone will also be available when it is time")** — her app is quit (zero-instance
  for the finals' full Mac run and the Release build; the pgrep check still runs at each act,
  state being state), and the window's acts proceed without a further scheduling ask the moment
  the ladder closes: A1 backup → the Mac install refresh → the phone build → the ping for her
  round. The HELD optional live Replace All Keys stays hers to decide at the round itself.
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
- [x] The two PROPOSALS written (row 9 · row 15) — sections below; AWAITING THE ORCHESTRATOR'S
  RULINGS (no Phase-2 line built).
- [x] Phase 1 finals: FULL CORE SUITE **1661 tests / 179 suites — PASSED, exactly the 3 known
  issues** (the two P8 wraps + the P5(b) wrap, waiting for Phase 2) + the one sanctioned
  real-server skip. Arithmetic exact: baseline 1654/179 + 7 new pins (2 SyncRepairTests,
  2 PurgeOpsTests, 1 PurgeConvergenceTests, 2 SyncSchedulerTests), zero new suites. Mac
  touched-suite run green (18/2: SampleLibraryTests + SyncStalledRowTests); iOS BUILD SUCCEEDED.
  Fences held: zero schema, zero server/mirror lines, marker 8, `/Applications` and her real
  store untouched (her live real-store instance observed running and left strictly alone).
- [x] **PHASE 2 (built to the recorded rulings, 2026-09-22):**
  - [x] Row 15 Part 1 (the ride-the-row rescue) — FIXED, red-on-old VERIFIED BY BEHAVIOURAL
    REVERT (pin `p1PhoneFirstResumeRidesTheUnpushedEditIntoTheTrash` [200/1]); ONE scope
    judgment flagged below (the (true,true) shape — the trace's own find).
  - [x] Row 15 Part 2 (the defense leg) — FIXED, B1's P5(b) wrap UNWRAPPED as red-on-old and
    VERIFIED BY BEHAVIOURAL REVERT against the committed fix; ONE ruled-constraint deviation
    flagged below WITH ITS PIN-PROOF (the pre-batch-dirt arm's unsoundness), for the
    orchestrator's arbitration.
  - [x] Row 9 (the ledger-verified orphan heal, ruled Shape A + tombstone narrowing) — FIXED,
    B1's two P8 wraps UNWRAPPED as red-on-old and VERIFIED BY BEHAVIOURAL REVERT against the
    committed fix; the live-row refusal and the transient guard pinned beside them.
  - [x] Phase 2 finals: FULL CORE SUITE **1666 tests / 179 suites — ALL PASSED, ZERO KNOWN
    ISSUES** (the three B1 wraps are GONE — green pins now; the one sanctioned real-server
    skip stands). Arithmetic exact: Phase-1's 1661 + 5 new pins. Mac app BUILD SUCCEEDED ·
    iOS BUILD SUCCEEDED (core's public API grew: `PullStall`, `PullReport.stall`,
    `SampleCopyVerdict`/`SampleCopyClassifier`). Fences held: zero schema, zero server/mirror
    lines, marker 8; `/Applications` and her real store untouched.

### DEATHS / RESUMES

- none. **One PROTOCOL SLIP, recorded (Phase 2, row 15 Part 2):** the implementer ran a
  behavioural revert on Repairs.swift BEFORE Part 2's hook was committed and restored it with
  `git checkout`, which wiped the uncommitted hook — exactly the state the no-revert-without-a-
  committed-pre-revert-state rule exists to prevent. Recovery: the three edits were re-applied
  from the session's own context byte-faithfully, rebuilt, re-verified (44/5 green), COMMITTED
  — and the behavioural revert then re-run against the committed fix (both p5b pins red, 12
  issues; restored 13/13). Every revert after the slip was commit-first. Nothing was lost;
  noted because the record must never read cleaner than the session ran.

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

### PROPOSAL — ROW 9 (17d P8, the purge-window mirror orphan): the design fork, for the orchestrator's ruling

**The B1 refinements bind:** the stall lands AT the orphaned placement (block X + VX apply and
the cursor passes them; the placement's `container_id → N` fails everywhere); the jam is
permanent and one-way; after B's reconcile NO device holds any row or tombstone for the mirror's
orphan; nothing ever removes it from the mirror. Client-side only — and the client HAS a
mirror-row remover: `executePurge`, an existing RPC (zero server lines).

**Shape A (RECOMMENDED) — the ledger-verified orphan heal, janitor/scheduler layer.**
1. `PullReport` gains the stall's identity (client-side struct only): the stalled row's
   (table, rowID) and its unresolvable FK referents.
2. A scheduler round that ends `pullStalled` with a janitor wired hands the stall to
   `janitor.healPurgeOrphan(_:using:)` (row 12's reader is the hook, already built).
3. The heal's DISCRIMINATOR — exact, no timers: read the full purge ledger
   (`purgeLedger(since: 0)` — content-free and prunable by design; the stall path is rare and
   self-limiting). EVERY missing referent ledger-named (or below a non-zero floor — pruned,
   same meaning) ⇒ the referent can NEVER arrive: this is a purge orphan, a late-arriving
   member of a family purged everywhere. Any referent NOT named while the floor is 0 ⇒ a
   genuine transient straggler ⇒ heal NOTHING (SyncSpec §5's self-healing class stands).
4. The heal: build the completion set — the stalled row plus its locally-present cascade
   residue (rows tombstoned with the stalled row's own exact stamp, the cascade contract's
   discriminator; expanded through `PurgeFamily`) — `executePurge` it (the mirror deletes the
   orphan rows AND ledgers them, idempotently: every device's feed stops carrying them, and
   any straggler push meets the `'purged'` refusal), then `deleteLocal` the local residue.
   Report the heal (SweepReport + status); the scheduler triggers a follow-up round and the
   pull proceeds past the gap.
5. **§4f legality:** the healed rows are cascade-stamped members of a family whose deletion
   crossed the horizon (it was purged); they are TOMBSTONES on the mirror (B's cascade stamped
   them before the held/banded push); no device holds them live (B1's refinement 2, asserted).
   The heal COMPLETES an incomplete purge — it removes nothing any device wants, and it is
   what makes "really gone… not on the server either" true for the orphan variant rows'
   sealed ciphertext of a purged note. Deterministic: every device runs the same check against
   the same ledger; `executePurge` is idempotent.
6. **The fence, stated:** this is the NARROW traced mechanism — a heal for the
   ledger-verified purge-orphan class only — NOT the general poison-row park/heal subsystem
   (KnownIssues row 19, owner 12): no parking, no retry policy, no drop-loudly framework; a
   stall that is not ledger-proven-permanent is left exactly as designed.

**Shape B — prevention at the sweep (REJECTED as primary):** impossible client-side — the A5
visibility band means the sweeping device cannot see a peer's in-band rows by construction, so
any quiescence heuristic narrows the window without closing it; a server-side pre-purge orphan
check is a mirror change (a 13y candidate, not a proposal). Could ride Shape A as a cheap
narrowing (skip the sweep when the same round's pull was non-empty); deliberately NOT proposed —
the heal is needed regardless and the smaller diff is the honest one.

**Shape C — skip-and-advance, drop loudly (REJECTED):** deterministic ("a tombstoned arriving
row whose referents are ledger-purged skips; the cursor advances") and transport-free — but the
orphan rows stay on the mirror FOREVER (a purged note's sealed ciphertext hosted indefinitely,
against §4f's whole purpose), and every fresh device re-meets and re-decides them. Stands only
as the recorded degraded posture for engine compositions with no purge surface — which already
refuse visibly (`pullToHead`'s typed `pullStalled`) and now carry row 12's flag.

**Pins on the build:** unwrap B1's two wrapped desired-contract blocks (held-push +
visibility-band: "bounded rounds + reconciles after the release must clear the jam") as the
red-on-old pins; add the transient guard (a stall whose referent is NOT ledger-named heals
nothing — no `executePurge` fires); assert both devices converge and the mirror holds zero
orphan rows after the heal.

### PROPOSAL — ROW 15 (F-1, the dedupe double-retirement race): the design fork, for the orchestrator's ruling

**The constraints bind:** exactly-one-edited ⇒ the EDITED copy survives (LIVE — the ruled
matrix names survival, not a Trash row); both-edited ⇒ both survive; deterministic on both
devices; err toward EDITED. Two coordinated repair-rule-scale parts — the escape valve is NOT
invoked (occasions untouched, classifier untouched, no schema).

**Part 1 — the merge layer's ride-the-row rescue (the BYTES).** In `rescueLosingText`'s
skip case: when the LOCAL side's dirty `working_text` loses the row and the conflict-card
rescue cannot land (block dead), the local text OVERLAYS the merged row's `working_text` — the
edit rides the row, exactly P1's settled end-state ("the edit rides the row INTO the Trash"),
extended from the pushed direction to the unpushed one. The merged row then differs from the
server ⇒ the outbox entry SURVIVES ⇒ the ridden text pushes and converges. This also closes the
GENERAL unpushed-edit-vs-whole-family-deletion bytes loss (P1's un-probed other resume order:
phone-first, the laptop's unpushed edit currently clobbered by the server's old text — same
mechanism F-1 rides). **Flagged for arbitration, honestly:** §6's tombstone rule is silent on
the row's TEXT when the block is dead; P1's ANSWERED block blessed ride-the-row for the pushed
direction; I read the overlay as the same sentence's other half and §6's "deleting an edit
nobody chose to lose is the one forbidden outcome" as its warrant — the orchestrator arbitrates
against the spec.

**Part 2 — the dedupe's defense leg (the COPY, the ruled matrix).** A post-batch check in the
dedupe's own firing scope: when a pull batch transitioned a same-name sample copy live→dead
(`touched.tombstonedParents` ∩ the facts' book name), AND the meeting context stands (another
same-name copy row exists, live or dead — the once-per-store-life event), AND the dead copy's
family carries LOCAL INTENT THE SERVER NEVER SAW (family rows still in `sync_outbox` after the
batch — Part 1 is what keeps the edited row's entry alive through the merge), the copy was
EDITED-HERE with the evidence still in flight: REVIVE the family exact-stamp (the
`restoreContainer` flip shape, in-apply, every write enqueued explicitly per §7). The revival
pushes; the other device applies it, its own pass re-fires (a `reading` row applied) and finds
one live copy → settles. Outcomes on the matrix: exactly-one-edited ⇒ the edited copy ends LIVE
everywhere with its bytes (the pristine one stays retired); both-edited ⇒ each device defends
its own ⇒ both survive; deterministic end-state under CAS; errs toward EDITED (outbox dirt =
unpushed intent = defense).
- **The accepted corner (record + PROVISIONAL):** her deliberate delete of the sample book on
  one device while another holds UNPUSHED edits to it, INSIDE the two-copy meeting window,
  is revived by the defense — visible in the library, never silent; outside the meeting window
  (one copy — the overwhelmingly normal state) the defense can never fire. Err-toward-EDITED's
  letter.
- **Fences re-verified, not absorbed:** NOT row 33's late-registry legs (that class is
  trailing-chunk evidence of PUSHED engagement; this discriminator is exactly UNPUSHED outbox
  evidence — disjoint by construction); NOT an occasion redesign (18a keeps its sitting).
- **Considered and dropped:** a retirement MARK the editing side rescues against (B1's
  candidate ii — no column exists; zero schema; overloading a user column is corruption), and
  a B-side pass deferral while its own copy holds outbox dirt (doesn't stop A's stale-evidence
  retirement from landing; prevention cannot reach the race's cause).

**Pins on the build:** unwrap `p5bTheDoubleRetirementRaceRetiresBothCopiesAndLosesTheEdit` as
red-on-old (the edited copy survives live, bytes intact); add the both-edited variant (both
survive); a Part-1 bytes pin (the P1 phone-first order: an unpushed edit rides the row into the
Trash and Put back returns it); and the no-defense guard (a deliberate delete with NO second
copy present never revives).

### ROWS 9 + 15 — THE ORCHESTRATOR'S RULINGS (2026-09-22, recorded repo-first; Phase 2 builds to these)

**Phase 1 verified before ruling:** the eight commits read; LIVE STATUS complete, zero PENDING;
all six new pins re-run by the orchestrator's own hands — 6 tests / 4 suites GREEN. The row-7
recreated-tag PROVISIONAL is FILED as **QUESTIONS #142** (the draft verbatim; (a) stands).

**ROW 9 RULING — Shape A APPROVED, with ONE narrowing condition.** The heal is §4f's own
completion (the orphan rows are tombstones of a family whose deletion crossed the horizon; the
mirror hosting a purged note's sealed ciphertext forever is what §4f exists to end), uses ONLY
existing RPCs (the zero-server-lines fence holds), leaves §5's transient-straggler class
untouched by the exact ledger discriminator, and is the narrow traced mechanism — not row 19's
park/heal subsystem (no parking, no retry policy; that fence line stands in the build). **The
narrowing condition:** the heal fires ONLY when the stalled arriving row is itself a TOMBSTONE
(`deleted_at` set — the traced construction's shape; B's cascade stamps the orphan before the
push). A LIVE stalled row whose referent is ledger-named is NEVER healed — left stalled and
honest under row 12's flag, and recorded if ever observed, because it would be a class nobody
has traced and safe-by-refusal is the right posture toward it. Shapes B and C rejected as
proposed (B impossible client-side; C hosts purged ciphertext forever). The `purgeLedger(since:
0)` full read is accepted on the stall path's rarity; owner-12's future ledger pruning keeps the
below-floor-means-purged semantics the discriminator already handles. Pins as proposed, plus the
live-row refusal guard.

**ROW 15 RULING — the two-part repair APPROVED, with ONE constraint on Part 2's discriminator,
and Part 1 lands PROVISIONAL.**
- **Part 1 (ride-the-row) — the canon arbitration:** §6's matrix is SILENT on the tombstoned
  row's TEXT when the block is dead; its own ratified doctrine sentence ("deleting an edit
  nobody chose to lose is the one forbidden outcome") is the warrant, and B1's P1 verdict
  blessed ride-the-row as the SAFE end-state for the pushed direction — Part 1 makes the
  unpushed direction converge to the same end-state, closing P1's un-probed other resume order
  as well as F-1's bytes. No invariant moves (the row stays tombstoned; S5 untouched — no
  conflict card is minted for a dead block). Under the PROVISIONAL rule this is the most
  spec-defensible reading of a silent cell, not a canon change: **it lands PROVISIONAL, filed as
  QUESTIONS #143(a)** for her ratification as a §6 clarification at the closeout.
- **Part 2 (the defense leg) — the constraint:** the defense's evidence is **PRE-BATCH dirt
  only** — outbox rows whose enqueue PRECEDES the current apply (`queued_at` before the
  transaction's start, or an equivalent batch-start snapshot). In-apply enqueues (the repairs'
  own explicit outbox rows, including anything a pass writes near the keeper) can NEVER
  self-justify a revival — without this line, a device's own repair bookkeeping could read as
  "edits" and revive the copy it just correctly retired, degrading exactly-one-edited into
  both-survive. (Part 1's preserved entry qualifies naturally: the edit's enqueue predates the
  batch.) The accepted corner (her deliberate delete inside the two-copy meeting window with
  unpushed edits revives, visibly) is **QUESTIONS #143(b)**, PROVISIONAL — it errs toward her
  words and can never fire outside the once-per-store-life meeting window. The
  considered-and-dropped alternatives are sustained as dropped (the mark is schema; deferral
  cannot stop the crossing). Pins as proposed, plus the both-edited variant and the no-defense
  guard.

---

## BATCH B2 RECORD — PHASE 2 (rows 9 + 15, built to the rulings; 2026-09-22)

### ROW 15 — F-1, the double-retirement race: FIXED (both parts; two judgment calls FLAGGED)

**Part 1 — the ride-the-row rescue (`Merge.swift`; PROVISIONAL #143(a) as ruled).** When a
dirty local `working_text` loses the row to an ARRIVING TOMBSTONE and the conflict-card rescue
cannot land (block dead), the local text overlays the merged row; the outbox entry survives
(landed ≠ server), the ridden text pushes, both devices converge with the edit on the
tombstoned row, and Put back returns it. `rescueLosingText` now returns whether a card was
minted; no card is ever minted here (S5 untouched).

**FLAGGED JUDGMENT CALL 1 — the (true,true) scope, found by the pin's own first red:** my
proposal said "when the LOCAL side's dirty text loses the row… (block dead)"; the ruling
approved it as the §6 silent-cell reading. Building it exposed the loss's REAL shape: the
arriving BLOCK tombstone's local cascade stamps the dirty variant EARLIER IN THE SAME BATCH
(registry order; cascades stay active during apply), so by the variant's own merge the case is
**(true, true)** — both tombstoned, the local row carrying the unpushed edit — not (false,
true). The shipped overlay therefore keys on `server.isTombstoned` alone and deliberately does
NOT consult the local tombstone state. Two untraced corners recorded, NOT silently decided:
(a) a LIVE server row over a dirty local edit under a dead block keeps shipped server-wins
behavior (riding would merely swap whose bytes die — one row, no card possible); (b) in
(true,true) with BOTH sides having ridden edits, riding keeps the LOCAL edit where the old code
kept the first pusher's — one side loses the row's bytes either way; the changed face of the
same corner. Both are the same both-edited-under-a-dead-block class; stated at the code.

**Part 2 — the defense leg (`Repairs.swift` + `SampleLibraryDedupe.swift`).** The kill-time
hook records evidence at the retirement's FIRST family death — a member CONTAINER's or the
READING's own live→dead transition, whichever arrives first in registry order — reading the
REAL classifier while the copy is still whole, once per copy per batch, pull-only. The
post-batch defense (`defendEditedSampleCopies`) revives exact-stamp (every flip enqueued, §7)
only where the READING itself ended dead under the recorded stamp (a lone member-note deletion
is an ordinary delete) and only on a definite EDITED verdict (INDETERMINATE defers to the
retiring side's complete evidence — loop-free). Self-retirements never record kills (direct
writes bypass `writeResolvedRow`), so the constraint's degradation scenario is dead by
construction. The registry-order finding is itself recorded: a verdict taken at the READING's
tombstone reads a half-killed copy (dead members = "her pruning" = EDITED) and revives every
correct retirement forever — the scratch trace's ping-pong, which is why the hook fires at the
FIRST death.

**FLAGGED JUDGMENT CALL 2 — the ruled PRE-BATCH-DIRT arm is ABSENT, its unsoundness
PIN-PROVEN (the orchestrator arbitrates):** the ruling's letter — outbox rows whose enqueue
precedes the batch — was built first and broke an EXISTING pin:
`theMarkerIsSpentWhenTheOtherDevicesRetirementLands` (both copies PRISTINE) went red because
the tag-collision repair's re-pointed applications of the arriving copy's own notes — PRIOR-
batch repair bookkeeping, enqueued in an earlier pull's apply — sat in the batch-start snapshot
and revived the correctly-retired copy: the constraint's exact degradation scenario ("repair
bookkeeping… revives the copy it just correctly retired"), one batch earlier than the letter
anticipated. The kill-time classifier arm is STRICTLY STRONGER against that scenario (it reads
domain rows and NO outbox evidence at all) and is what makes the ruled matrix's BOTH-EDITED row
reachable (each device's edit has typically PUSHED before the peer's retirement arrives, so
outbox evidence cannot defend it — the ruled pin itself forced this). The classifier-blind
residual (a chapter rename as the ONLY act) remains exactly the pre-existing R2-5 declined-leg
class, unchanged by this batch. If the orchestrator overrules, the dirt arm is a small re-add —
but it re-reds the marker pin.

**Pins + revert (all against the committed fix):**
`p1PhoneFirstResumeRidesTheUnpushedEditIntoTheTrash` [200/1] (Part 1's bytes — P1's un-probed
other resume order, closed; red-on-old pre-fix at the clobber, red again under the overlay
revert) · `p5bTheDoubleRetirementRaceKeepsTheEditedCopyAliveWithItsEdit` (B1's wrap UNWRAPPED —
the ruled matrix's first row; red under the hook revert at survival AND bytes) ·
`p5bBothEditedMeansBothCopiesSurvive` (the matrix's second row; red under the same revert) ·
`aDeliberateDeleteWithNoSecondCopyIsNeverDefended` (no meeting context ⇒ the deletion stands;
green under the revert too — it pins the defense's ABSENCE) · `p5c…` (the 3-round cadence) and
the full dedupe suites green beside them.

### ROW 9 — 17d P8's fix: THE LEDGER-VERIFIED ORPHAN HEAL (ruled Shape A + narrowing): FIXED

**Built exactly to the ruling.** `PullReport.stall` names the stall (the first unsatisfiable
row, its tombstone stamp, its missing referents — client-side, no wire change). A scheduler
round ending stalled hands it to `PurgeJanitor.healPurgeOrphan`: preflight (the reconcile's
discipline) → **the ruled narrowing** (tombstones only; a LIVE stalled row is never healed —
left stalled and honest under row 12's flag) → **the exact discriminator** (EVERY missing
referent named in the purged-ids ledger, read from 0 on this rare, self-limiting path; an
unnamed referent is a genuine §5 straggler and NOTHING is touched; the below-floor case refuses
too — recorded for the ledger-pruning rider) → **the completion set** (the stalled row + local
cascade residue on its EXACT stamp, family-expanded) through `executePurge` + `deleteLocal` —
§4f's own act, existing RPCs only, zero server lines; idempotent across devices. One follow-up
round flips `pullStalled` back honestly. The row-19 park/heal fence is stated at the site: no
parking, no retry policy, no drop-loudly framework.

**Pins + revert (against the committed fix):** B1's two wrapped constructions UNWRAPPED —
`p8AHeldPushAcrossThePurgeWindowJamsThePullForever` + `p8TheVisibilityBandVariantJamsTheSameWay`
(bounded SCHEDULER rounds clear the jam; the orphan leaves the mirror AND is ledger-fenced; A's
local residue completes the family; B's fresh note reaches A — the one-way flow resumes). Under
the behavioural revert (the scheduler's heal call disabled) both are fully red — the permanent
jam exactly as B1 reproduced it — while the refusal pins stay green; restored 13/13. Beside
them: `aLiveStalledRowIsLeftStalledAndHonestNeverHealed` (the narrowing end to end:
ledger-named referent, LIVE row, nothing purged, ledger count unchanged, status honest) and
`aStallWhoseReferentIsNotLedgerNamedHealsNothing` (the transient guard: no `executePurge`
fires, mirror untouched).

### PHASE 2 FINALS

FULL CORE SUITE **1666 tests / 179 suites — ALL PASSED, ZERO KNOWN ISSUES** (the finish line
the brief set: the SAME tests with zero wraps — B1's three wrapped probes are now green pins
of the fixed contracts) + the one sanctioned real-server skip. Arithmetic exact: Phase-1
finals 1661 + 5 new pins (p1PhoneFirst, p5bBothEdited, aDeliberateDelete, aLiveStalledRow,
aStallWhoseReferent; p5b renamed in place). Mac app **BUILD SUCCEEDED** · iOS **BUILD
SUCCEEDED** (core's grown public API compiles into both targets). Fences: zero schema, zero
server/mirror lines, marker 8, `/Applications` and her real store untouched throughout.

### BATCH B2 — ORCHESTRATOR ADJUDICATION (2026-09-22; the batch CLOSES here)

**Verification, my own hands:** the Phase-2 commits read one by one (pathspec-limited, pushed,
honest); the record's LIVE STATUS complete; **the FULL core suite re-run by the orchestrator:
1666 tests / 179 suites — ALL PASSED, zero known issues** (the finish line: B1's three wraps are
gone, their contracts now ordinary green pins). Fences held: zero schema, zero server lines,
marker 8, her store untouched. **BATCH B2 CLOSES; ledger rows 7 · 8 · 9 · 10 · 11 · 12 · 15 all
FIXED/DONE.**

**JUDGMENT CALL 1 — SUSTAINED.** The build follows the TRACED mechanism over my proposal's
letter, which is the hallucination guard's own doctrine: the pin's first red proved the loss's
real shape is (true,true) — the arriving block tombstone's local cascade stamps the dirty
variant earlier in the same batch — so keying the overlay on `server.isTombstoned` alone is the
fix for the mechanism that exists, and the ruled OUTCOME (the P1-blessed end-state in the
unpushed direction) is pin-proven. The two untraced both-edited-under-a-dead-block corners are
correctly recorded-not-decided (one row, no card possible, one side's bytes lose the row under
EITHER choice — a symmetric-loss cell no build should silently pick); they stay stated at the
code and in this record, inside #143(a)'s neighborhood if she ever wants to rule them.

**JUDGMENT CALL 2 — SUSTAINED; MY RULING'S LETTER IS AMENDED.** The pre-batch-dirt arm I ruled
was built to the letter first and PIN-PROVEN UNSOUND (`theMarkerIsSpentWhenTheOtherDevicesRetirementLands`
red with both copies pristine — PRIOR-batch repair bookkeeping is pre-batch dirt, the exact
degradation my constraint existed to prevent, one batch earlier than its letter anticipated).
The kill-time classifier arm satisfies the constraint's PURPOSE strictly more strongly — the
defense reads domain rows through the ONE classifier (row 8's own unification) and NO outbox
evidence at all, so repair bookkeeping cannot masquerade as edits by construction — and it is
what makes the ruled both-edited row reachable at all. **The amended ruling, binding:** the
defense's evidence is the kill-time classifier verdict (definite EDITED at the FIRST family
death, reading-ended-dead, self-retirements recording nothing); no outbox-based arm exists or
returns. The classifier-blind residual (a chapter rename as the only act) is the pre-existing
R2-5 declined-leg class, unchanged, owned where it was.

**The protocol slip — noted, resolved, and carried forward:** one behavioural revert ran via
`git checkout` over an UNCOMMITTED hook (the resiliency addendum's 11(a) class — "commit before
you revert" — violated once), recovered byte-faithfully, re-verified commit-first, honestly
recorded in DEATHS/RESUMES. Nothing was lost; the remaining briefs keep the rule stated and the
B3/B4 records inherit the reminder.

---

## BATCH B3 BRIEF — 17l ITEM 5, the double passphrase ask (row 13; self-contained)

**You are a Fable implementer session for RUN B batch B3.** ONE item, custody-adjacent `Sync/`:
her find at the pre-13x acceptance walk — *"I used my passphrase to sign in on my phone but then
I was asked to enter my passphrase again … a little annoying."*

**READ FIRST, in full, in your own context:** `CLAUDE.md` + canon (SyncSpec WHOLE — §3's
pre-13x/E2EE paragraphs; the 14b design pointer) · `notes/sync-postmortem-fragments.md` · THIS
FILE (FENCES · ENVIRONMENT TRAPS · this brief · both prior adjudications — the B2 slip's
commit-before-revert reminder binds you) · `notes/plans/phase-17-standing-fixes.md` **17l item 5
verbatim** (the entry's text is the spec) + `notes/KnownIssuesAndTechDebt.md` row 37 ·
`notes/plans/pre-13x-postures-design.md`'s ledger 54 (the no-second-entry follow this fix makes
true across rotations) · `Sources/VariorumCore/Sync/CorpusRotation.swift` (`RotationSecrets.init`,
~:71) + the descriptor/KDF sources it touches (`PassphraseKDF`, `StoreKeyEnvelope` as needed).

**THE FIX (the entry's letter):** when the passphrase is UNCHANGED at a rotation,
`RotationSecrets` re-wraps the master under the EXISTING KDF descriptor (the same salt → the
same derived key; the wrapped payload is the new master — cryptographically sound); a CHANGED
passphrase keeps the fresh random salt. **HER SCOPE LINE, binding: the reuse applies to the
PASSPHRASE wrap ONLY — the recovery-words wrap keeps its own descriptor and its fresh salt at
every act.**

**PINS (each red-on-old by behavioural revert, commit-first):** (1) the zero-prompt follow — a
sibling that opened by the passphrase follows a Replace All Keys with zero prompts (RED today:
the descriptor differs and the field asks); (2) the independence guard — the passphrase wrap's
and the recovery wrap's descriptors stay independent across a rotation (the recovery salt is
fresh even when the passphrase salt is reused); (3) the changed-passphrase guard — a rotation
that CHANGES the passphrase mints a fresh salt (the reuse never leaks into the changed case).
**The custody suites ride your close:** `CorpusRotationTests` · `MultiTenantSyncAttackerTests`
(the nine arms must stay green — a descriptor reuse that weakened an arm would be a finding
against the FIX, stop and report) · the rotation drill where it runs headless · the full core
suite (baseline **1666/179, zero wraps**). Zero schema, zero server lines, marker 8; her store
and `/Applications` untouched.

**Your record:** append `## BATCH B3 RECORD` below this brief — LIVE STATUS from the first
commit, the trace in your own words (WHY the fresh salt broke ledger 54's road — the follow's
descriptor-equality gate), fix, pins + revert evidence, finals. **Checkpoint protocol:** commit
per piece + push; pathspec-limited staging; PENDING until verified; foreground grep-poll waits;
no subagents (one Sonnet lookup for external facts only); NO REVERT without the pre-revert state
COMMITTED (B2's slip is the fresh reminder); no commit trailers.

## BATCH B3 RECORD — 17l ITEM 5, the double passphrase ask

### LIVE STATUS (flipped in the same commit as each piece; unverified claims marked PENDING)

- [x] Record opened; brief + READ FIRST list read in full (SyncSpec whole + the canon load, the
  postmortem, this file's FENCES/TRAPS/brief/both adjudications, 17l item 5 verbatim, KnownIssues
  row 37, the postures design's ledger 54 + §7 step 1/§12 contract sentences + the 4a item-4
  build record, `CorpusRotation.swift` whole, `PassphraseKDF.swift` whole, `KeyVaultFormat`'s
  create/unwrap roads, `RecoveryPhrase`'s derivation, `StoreKeyEnvelope`'s wrap fields, the
  runner's ceremony + both follow roads, and the three test suites' idioms). The mechanism
  re-traced by my own hands (the trace below).
- [x] THE FIX — `RotationSecrets.derive(passphrase:recoveryWords:forRotationOf:freshKDF:)` in
  `Sync/CorpusRotation.swift` (the reuse road, proven-by-unwrap) + the runner's ceremony derive
  moved into the branches (`PostureSwitch.swift`: the enrolled arm derives against the fetched
  vault; the local-only arm keeps the fresh salt). Core `swift build` green. *(Pins landed in the bullets below — the trailer stood while this piece was the head.)*
- [x] Pin 2 (the independence guard) + pin 3 (the changed-passphrase guard) + the core half of
  pin 1 (the same-word rotation keeps the vault's descriptor; a pre-rotation held key opens M′)
  — `CorpusRotationTests` +3, suite **18/18 green** (15 existing + the 3 pins, all named in the
  run log). *(Revert evidence landed below.)*
- [x] Pin 1 (the zero-prompt follow, the DOOR) —
  `PostureSwitchTests.theSiblingThatOpenedByThePassphraseFollowsAReplaceAllKeysWithZeroPrompts`
  (the entry's letter end to end + the changed-word door arm) + arm (vii) of the
  un-followed-device pin RE-BASED to the fixed contract (the ruled-change class: the second
  same-word rotation reuses the descriptor, the held key still matches, the follow runs with no
  field). Suite run: **44/44 passed, 0 skipped** (149 s; her real-store instance pid 38939
  observed running at `/Applications` and left strictly alone). *(Mac revert evidence landed below.)*
- [x] CORE revert evidence (pre-revert state committed at b57a8d38, both reverts + restores):
  **REVERT A** (the reuse road forced onto the fresh-salt arm — the pre-fix semantics):
  `aSameWordRotationKeeps…` RED, 3 issues (`secrets.kdf == before.kdf` :277, `after.kdf ==
  before.kdf` :281, and the held key's `unwrapMaster` threw `unwrapFailed` :268 — her double
  ask's core mechanism verbatim) · `theRecoveryWrapStaysFresh…` RED, 2 issues (both reuse
  premises) · pin 3 GREEN (the changed case IS the old behavior — the guard class, as
  predicted); run 18 tests / 5 issues. Restored via `git checkout` over the committed tree →
  18/18 green. **REVERT B** (the reuse made unconditional — the unwrap proof skipped): pin 3
  RED, 4 issues (:361 fresh descriptor, :362 fresh salt, :366 the vault's descriptor moved, and
  :372 "an error was expected but none was thrown" — under the mutant the changed word under
  the OLD salt OPENED the new wrap, precisely the leak the guard exists for); pins 1/2 green.
  Restored → 18/18 green.
- [x] Mac revert evidence (REVERT A against the committed tree 58946397): run **44 tests /
  8 issues / 2 failed — EXACTLY the two 17l-item-5 tests, zero collateral**: the door pin RED
  with 5 issues (:2900 the descriptor moved, :2908 the notice's kdf differs, :2911
  `canFollowFromHeldKey → false`, :2914 the door fell to `.askPassphrase` — her double ask at
  the door verbatim, :2921 the `.done` guard) and the re-based arm (vii) RED with 3 issues
  (the same three). Restored via `git checkout` over the committed tree → both touched suites
  re-run green.
- [x] Finals: `MultiTenantSyncAttackerTests` **2/2 — all nine arms green, untouched** ·
  `KeyProofGateTests` **11/11** (the headless drill's home) · `CorpusRotationTests` **18/18** ·
  FULL CORE SUITE **1669 tests / 179 suites — ALL PASSED** (baseline 1666 + exactly the 3 pins;
  zero known issues; the one sanctioned real-server skip) · touched Mac suites
  (`PostureSwitchTests` + `Phase13pControllerTests`) **92 tests / 2 suites — passed, 0 skipped**
  · iOS `VariorumMobile` generic-platform build **BUILD SUCCEEDED**. Fences held: zero schema,
  zero server/mirror lines, marker 8; `/Applications` and her real store untouched (her live
  real-store instance, pid 38939, observed and left strictly alone).

### DEATHS / RESUMES

- none.

### THE TRACE (my own hands — why the fresh salt broke ledger 54's no-second-entry road)

A derived passphrase key is a function of (word, descriptor) — Argon2id over the descriptor's
salt — and can only open a wrap made under that exact pair. Ledger 54's follow
(`PostureSwitchRunner.followDerived`, `PostureSwitch.swift` ~:716) therefore gates on descriptor
EQUALITY: `fetched.format.kdf == kdf` (the held key's), then `unwrapMaster(withPassphraseKey:)`.
Her phone's lobby held the key it derived when she typed her word to unlock — under the local key
file's P-wrap descriptor, which equals the VAULT's descriptor as of the last reconcile
(ledger 53's shape). But `RotationSecrets.derive` (`CorpusRotation.swift` :71) defaulted its
descriptor to `.v1(salt: PassphraseKDF.randomSalt())` — a FRESH salt at every call — and the
runner's ceremony (`PostureSwitch.swift` :479) called it with that default, before even fetching
the vault. So every Replace All Keys / entering Castle moved the vault to a descriptor no
sibling could be holding yet, even when the word itself did not change: the follow's equality
gate failed on every sibling (`passphraseRequired` — the field asks), and the held key could not
have opened the new wrap anyway (same word + different salt = different key). Result, hers at
the acceptance walk: a device that had just typed its word to unlock was asked the same word
again at the follow — "reused for the follow, never asked twice" (§7 step 1) broken across every
rotation, structurally, since the road shipped.

### THE FIX

**Core (`Sources/VariorumCore/Sync/CorpusRotation.swift`):** a second derive entry,
`RotationSecrets.derive(passphrase:recoveryWords:forRotationOf:freshKDF:)`. It floor-validates
the vault's descriptor (the read-site discipline), derives under it, and PROVES the word
unchanged by opening the vault's `masterWrappedByPassphrase` — never guessed from UI state. On
proof: the descriptor is REUSED (same salt → same derived key; the wrapped payload is the new
master — the entry's "cryptographically sound"). On failure: the word is changed (or was changed
elsewhere) and the shipped fresh-salt road runs byte-unchanged (`freshKDF` defaulted to the
heavy v1; tests inject a fast one) — one extra derivation, only on that rare deliberate act.
HER SCOPE LINE held structurally: the recovery key is derived fresh from the words given at the
act, identically in both arms — no part of the passphrase descriptor reaches that path.

**The one call site (`App/Variorum/Shared/PostureSwitch.swift`):** the ceremony's derive moved
from before the vault fetch into the branches — the enrolled arm derives against the FETCHED
format through the new road (off-main as before); the local-only arm (no vault, nothing to
reuse, no sibling to follow) keeps the fresh-salt derive. The follow roads, `begin`, the walk,
completion: untouched.

### PINS + REVERT EVIDENCE (pre-revert state COMMITTED FIRST, every time)

- **Pin 1, core half — `aSameWordRotationKeepsTheVaultsDescriptorSoAPreRotationHeldKeyOpens`**
  (`CorpusRotationTests`): a key derived under the vault's descriptor BEFORE a same-word
  rotation opens M′ AFTER it (`secrets.kdf == before.kdf`, `after.kdf == before.kdf`, the
  held key unwraps the new master — ledger 54's gate in core terms) — and the SECOND rotation
  reuses it again (the chain her phone lives on).
- **Pin 1, the DOOR — `theSiblingThatOpenedByThePassphraseFollowsAReplaceAllKeysWithZeroPrompts`**
  (`PostureSwitchTests`): the sibling's session holds the key derived under the PRE-rotation
  vault descriptor (the lobby's state); the acting device runs Replace All Keys with the SAME
  word; the sibling's follow: `canFollowFromHeldKey` TRUE, `choosePassphrase()` asks NOTHING,
  `.done`, the library re-keyed once, M′ in custody, the new key file's P copy under the reused
  descriptor and opening under the typed word. Then the CHANGED-word door arm: a second rotation
  under a NEW word → the held key is honestly stale → the field asks (the reuse never leaks into
  the changed case, at the door).
- **Pin 2 — `theRecoveryWrapStaysFreshAndIndependentWhenThePassphraseDescriptorIsReused`**
  (`CorpusRotationTests`): across a same-word rotation with fresh words, `after.kdf ==
  before.kdf` (the reuse premise) while `masterWrappedByRecovery` is FRESH BYTES wrapping the
  NEW master under the words given at the act — the old words open nothing, the new words open
  M′; and a second same-word SAME-words rotation still mints a fresh recovery wrap (fresh at
  every act even when both secrets are unchanged). Her scope line as code.
- **Pin 3 — `aChangedPassphraseMintsAFreshSaltAndTheReuseNeverLeaksIntoTheChangedCase`**
  (`CorpusRotationTests`): the new road with a DIFFERENT word mints a FRESH descriptor
  (`secrets.kdf != before.kdf`, fresh salt), the rotation lands under it, a key under the OLD
  descriptor opens nothing, the new word under the new descriptor opens M′.
- **REVERT A (the behavioural revert — the pre-fix semantics restored: `forRotationOf` made to
  take the fresh-salt road unconditionally), run AFTER each pins' commit, restore verified
  green each time:** CORE — `aSameWordRotationKeeps…` RED, 3 issues (the reuse premise :277,
  the vault's descriptor moved :281, and the held key's `unwrapMaster` threw `unwrapFailed`
  :268 — her double ask's core mechanism verbatim); `theRecoveryWrapStaysFresh…` RED, 2 issues
  (both reuse premises); pin 3 GREEN (the changed case IS the old behavior — the
  preserved-behavior guard class, B2's `aDeliberateDeleteWithNoSecondCopyIsNeverDefended`
  precedent); run 18 tests / 5 issues. MAC — 44 tests / 8 issues / 2 failed, EXACTLY the two
  17l-item-5 tests and zero collateral: the door pin RED, 5 issues (`canFollowFromHeldKey →
  false`; the door fell to `.askPassphrase` — the field asked the word just typed, her find at
  the walk reproduced at the door); the re-based arm (vii) RED, 3 issues. Every revert started
  only after the pre-revert state was COMMITTED (b57a8d38 for core, 58946397 for the Mac);
  every restore was `git checkout` over a committed tree, re-run green (core 18/18; Mac 92/2).
- **REVERT B (the discrimination mutant — the reuse made UNCONDITIONAL, the unwrap proof
  skipped):** pin 3 RED, 4 issues (:361 the fresh-descriptor assert, :362 the fresh salt, :366
  the vault's descriptor moved, and :372 "an error was expected but none was thrown" — under
  the mutant the changed word under the OLD salt OPENED the new wrap, precisely the leak the
  guard exists for); pins 1/2 premises green. Restored → 18/18 green. Pin 3 is a
  preserved-behavior guard (green on the pre-fix code BY DESIGN); this mutant is its
  discriminating red — recorded plainly rather than claimed as red-on-old.
- **RE-BASED SHIPPED PIN (the ruled-change class, B2's precedent):** the un-followed-device
  pin's arm (vii) tail (`PostureSwitchTests` ~:3530) asserted the PRE-fix consequence — after a
  second same-word rotation "the held key's descriptor is the first rotation's — asked". Under
  the fix the second rotation reuses the descriptor, so the held key still matches and the
  follow runs from it with no field; the arm now asserts exactly that (and the ledger-35 head
  of the arm — the notice re-asks at once on the NEW key id — is untouched: the notice keys on
  the corpus key id, which is fresh at every rotation regardless).

### FINALS

Core: `CorpusRotationTests` **18/18** (15 existing + the 3 pins) · `MultiTenantSyncAttackerTests`
**2/2 — all nine arms green, byte-untouched** (the arms turn on the master, the proof and the
fence — none on the passphrase salt; the reuse weakened nothing, so the brief's stop-and-report
tripwire never fired) · `KeyProofGateTests` **11/11** (the headless rotation drill's home) ·
FULL CORE SUITE **1669 tests / 179 suites — ALL PASSED, zero known issues** + the one sanctioned
real-server skip (arithmetic exact: baseline 1666/179 + 3 core pins, zero new suites). Mac
touched suites (`PostureSwitchTests` + `Phase13pControllerTests`): **92 tests / 2 suites —
passed, 0 skipped** (44 + 48; the new door pin and the re-based arm (vii) inside). iOS
`VariorumMobile` generic-platform build: **BUILD SUCCEEDED** (the shared runner compiles into
the phone — the R3-2 lesson's gate). Fences: zero schema, zero server/mirror lines, marker 8;
`/Applications` and her real store untouched throughout (her live real-store instance, pid
38939 at the `/Applications` path, observed before every Mac-suite run and left strictly
alone). Files touched: `Sources/VariorumCore/Sync/CorpusRotation.swift` ·
`App/Variorum/Shared/PostureSwitch.swift` · `Tests/VariorumCoreTests/CorpusRotationTests.swift`
· `App/Variorum/VariorumTests/PostureSwitchTests.swift` · this record. Commits: b0fa300a (the
fix + the record) · b57a8d38 (the core pins) · 58946397 (the door pin + the re-base) · this
close — each pathspec-limited, each pushed. **BATCH B3 IS COMPLETE — awaiting the
orchestrator's verification; B4 is not mine to start.**

---

### BATCH B3 — ORCHESTRATOR ADJUDICATION (2026-09-22; the batch CLOSES here)

**Verification, my own hands:** the four commits read (pathspec-limited, pushed, honest); the
custody suites re-run by the orchestrator — `CorpusRotationTests` + `MultiTenantSyncAttackerTests`
+ `KeyProofGateTests`: **31 tests / 3 suites GREEN** (all nine attacker arms standing untouched —
the tripwire never fired); the record's revert evidence read in full (REVERT A reproducing her
double ask at BOTH layers — `unwrapFailed` on the held key in core, `.askPassphrase` at the door
— and REVERT B catching exactly the old-salt leak the changed-case guard fences). Three stale
`PENDING` trailer words in LIVE STATUS were verified as discharged-by-later-bullets and tidied
by the orchestrator (a cosmetic record edit, no substance). The arm-(vii) re-base is SUSTAINED
as the ruled-change class (the shipped arm asserted the pre-fix staleness this entry exists to
end; ledger 35's notice half untouched). The mid-batch commit `5ecb8c2b` was verified as the
BACKGROUND health-review session's own new file (`notes/plans/post-13u-health-rounds.md`) — no
collision with this run; left alone per her instruction. **BATCH B3 CLOSES; ledger row 13
FIXED.** One item carried to the window's checklist: her HELD optional live Replace All Keys
would now let her FEEL the zero-prompt follow on the phone — the fix is exactly her reported
annoyance's cure.

---

## BATCH B4 — HARNESS REALISM (brief finalized at spawn; the settled scope)

Ledger row 14: `productionRound` becomes the convergence suites' DEFAULT round shape; the chunk
splits at registry boundaries land as a sweep (suite × scenario × boundary, each cell converted
or exempt-with-reason); every suite green under the new shape. The old convenience order survives
only where a test's SUBJECT is the order itself (named, with the reason at the line). This is the
postmortem lesson-8 deliverable: after B4, a sync test that doesn't exercise the production path
is decoration BY EXCEPTION, not by default. **Plus row 16** (S1's routing): the tenth attacker
arm — `sync_reencrypt` under an OLD proof — pinned in `MultiTenantSyncAttackerTests` or the
fake-server twin (test-only; green-by-design is the expected verdict).

**BATCH B4 BRIEF (self-contained):** you are a Fable implementer session for RUN B batch B4 —
the structural deliverable. READ FIRST, in full, in your own context: `CLAUDE.md` + canon
(SyncSpec WHOLE) · `notes/sync-postmortem-fragments.md` (lesson 8 is your charter) · THIS FILE
(FENCES · TRAPS · rows 14 + 16 · the B1 RECORD — `ProductionRound.swift`'s shape and the P4
sweep's coverage map are your starting point · all three adjudications) ·
`Tests/VariorumCoreTests/Support/ProductionRound.swift` + the convergence suites named in the
TRAPS section. THE WORK: (1) convert the convergence suites' round driving to `productionRound`
as the DEFAULT — pull → push per device, chunked pushes as separate server transactions —
recording the conversion as a SWEEP TABLE (suite × scenario: converted · exempt-with-reason;
the only legal exemptions are tests whose SUBJECT is the order itself or whose harness
composition has no room for a round at all, each named with the reason at the line); (2) the
registry-boundary chunk-split arm added where a scenario crosses a boundary (B1's
`pushSplitAtBoundary` is the instrument); (3) row 16's tenth-arm pin; (4) every suite green
under the new shape — a conversion that turns a pin red is a FINDING, not a nuisance: trace it
(the B1/B2 classes are the likely homes), record it, and STOP AND REPORT if it is a product
defect rather than a test-idiom artifact (the orchestrator routes it — a new ledger row or an
owner). NO product lines: `Tests/` only; zero `Sources/`, zero schema, marker 8. Your record:
`## BATCH B4 RECORD` with LIVE STATUS from the first commit, the sweep table, any findings, and
finals (full core at close — baseline **1669/179, zero wraps**). Checkpoint protocol as every
batch: commit per piece + push, pathspec-limited, PENDING until verified, foreground grep-poll
waits, no subagents (one Sonnet lookup max), commit-before-revert, no trailers.

## BATCH B4 RECORD — HARNESS REALISM

### LIVE STATUS (flipped in the same commit as each piece; unverified claims marked PENDING)

- [x] Record opened; brief + READ FIRST list read in full (SyncSpec whole + the canon load, the
  postmortem — lesson 8 the charter, this file's FENCES/TRAPS/rows 14+16/the B1 record whole/all
  three adjudications, `Support/ProductionRound.swift` + `SyncTestHarness` + `FakeSyncServer` +
  `FaultInjectingTransport`, `ProductionRoundShapeSweepTests` whole, and every convergence suite
  the TRAPS name — SyncConvergence, SyncMerge, SyncRepair, SyncPull, SyncPush, FaultInjection,
  EditorRate, StructuralSession, MobileCapture, MultiTenant + the attacker file — plus the
  `outboxRowsAhead` helper and the `sync_reencrypt` SQL body's gate wiring).
- [x] SyncConvergenceTests converted (assertConverged + 5 seed settles + the soak →
  `productionQuiescence`; 5 "X reaches the server first" stagings → `productionRound(x)`) + the
  NEW deleted-post cascade split arm at the `container_block` boundary
  (`aDeletedPostsCascadeSplitAtThePlacementBoundaryStillConvergesRestorably` — B's local cascade
  pre-produces the stranded placement tombstones on the exact stamp; restore revives the whole
  family). Suite run GREEN: 20 tests / 3 suites (the filter also matches the separate
  `Phase11SyncConvergenceTests`/`Phase13SyncConvergenceTests` structs — out-of-brief residue,
  their own quiesce helpers already pull→push).
- [ ] SyncRepairTests converted (seed → productionQuiescence; the both-accepted races as
  concurrent-round weaves; B-round-as-halves where the (c)-leg asserts between them) + the
  cross-batch `post_tag` split arm (the row-7 durable predicate's chunk-gap claim, pinned) —
  PENDING
- [ ] SyncPullTests stagings converted; SyncPullTests/SyncPushTests exemptions annotated at the
  line (half-round mechanics · order-is-the-subject) — PENDING
- [ ] FaultInjectionSyncTests seeds + tails converted (armed fault halves stay — the subject) —
  PENDING
- [ ] EditorRateSyncTests + StructuralSessionSyncTests + MobileCaptureSyncTests converted + the
  same-day double-create split arm at the `block` boundary — PENDING
- [ ] MultiTenantSyncTests: `fleetQuiesce` → production order (pull→push per device); stagings
  converted; gate/refusal halves annotated — PENDING
- [ ] Row 16: the tenth arm (`sync_reencrypt` under an OLD proof — fence-first + proof-refused +
  the gate-pass control + the DDL text pin), the nine arms byte-untouched — PENDING
- [ ] SyncMergeTests suite-level exemption annotated; `ProductionRound.swift` header's
  "B4's deliverable" sentence flipped to done — PENDING
- [ ] THE SWEEP TABLE (suite × scenario: converted · exempt-with-reason · boundary cell) written
  below — PENDING
- [ ] Finals: FULL CORE SUITE at close (baseline **1669/179, zero wraps**; arithmetic stated
  exactly) — PENDING

### DEATHS / RESUMES

- none so far.

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
