# Phase 12 — Hardening & perf validation (execution plan)

> Authored 2026-07-16 at Phase 11b's closeout per the front-loaded-planning
> rule, FROM `notes/plans/phase-12-brief.md` — the brief's pre-answered
> decisions (the Phase 8 backup ritual is DRILLED here; the fault-injection
> and re-entrancy suites re-run here; the §12 lockstep lessons fold into the
> GC memo) are **binding**; its four open questions are answered in §"Open
> questions, answered". The brief's central instruction governs every step:
> **harden against the evidence, not against hypotheticals** — the author
> has months of real daily use behind the store by now, and the real corpus
> is the test plan's input, never a guess.
>
> **Staffing (CLAUDE.md model policy):** coordinator **Opus** · implementer
> **Opus** · cold reviewer **FABLE** under the **cross-model review flow**
> (the reviewer makes the final call on disputed findings and implements its
> confirmed fixes itself; the implementer gets one sanity pass over the
> reviewer's diff). **The standing Sync/ rider is ACTIVE:** any change
> inside `Sources/VariorumCore/Sync/` is sync-engine surgery and is Fable
> work — in this Opus-implemented phase the coordinator STOPS AND REPORTS
> rather than letting the implementer touch it (Step 3's windowed pull, if
> built, is exactly this class — plan for the handover).

## Kickoff message (for a fresh session)

> You are starting **Phase 12 of Variorum** — hardening & perf validation:
> prove the load-bearing claims at real corpus scale, on the current OS,
> under real sync history, and leave the debt table clean. **First, verify
> Phase 11 is closed** (the master plan pointer says Phase 12; the 11a and
> 11b closeout paragraphs exist). **Second, check the deploy state:** if
> the author's PHONE still runs the pre-11a build (her one-time Release
> install — the 11b handoff checklist item), the two-device halves of the
> soak audit (Step 2) and the phone-resync acceptance (Step 3) are BLOCKED
> on it — say so in your first report rather than soaking one device.
> Read, in order: `CLAUDE.md`; `notes/plans/phase-12-brief.md` IN FULL
> (its pre-answered decisions are binding); this plan IN FULL;
> `notes/OverallModel.md`; `notes/AppSpec.md` §4 (P1's letter and the
> escape-hatch door), §14's 2026-07-12/13 deltas (the conditional join;
> the takes/lens machinery the benchmarks must cover); `notes/SyncSpec.md`
> IN FULL (§5's pull-to-head note, §7's repairs — the soak audits their
> real-world firing rates — and §12, whose lessons the GC memo must fold
> in); `notes/KnownIssuesAndTechDebt.md` (Phase 12 owns SEVEN rows — the
> debt sweep's worklist); `notes/sync-postmortem-fragments.md` (read
> BEFORE touching anything in Sync/); the Phase 4 plan's benchmark
> section + `Tests/VariorumCoreTests/PerfBenchmarkTests.swift` and
> `Support/CorpusFactory.swift` (the builders Step 1 extends); the Phase
> 11 plan's closeout (11a + 11b — the surfaces the benchmarks now cover).
> **Baselines — do not re-run at session start: core `swift test` 650
> green in 77 suites · Mac app 380 green in 68 suites · mobile 11 green
> in 4 suites** (the Phase 11b closeout's final counts). Environment
> traps: piped xcodebuild masks exit codes (`set -o pipefail`); a live
> app instance or stale unsigned DerivedData product blocks the Mac test
> runner (NEVER kill the author's `/Applications/Variorum.app`); a wrong
> `-only-testing:` name reports vacuous SUCCESS on zero tests — always
> confirm the count line; SwiftUI `.task` doesn't fire under the test
> host. **Hard author gates:** every read of her REAL store (Step 0's
> stats, Step 2's dumps) is author-assist — never headless (the 9c/A5
> precedent: the permission system refusing headless credentialed access
> is correct); the GC memo (Step 4) is a Phase-6-class gate she
> adjudicates — NOTHING destructive ships before her written acceptance;
> the device-retirement policy inside it is her call outright.

## Ground rules

- **Evidence first.** Step 0's measured reality (corpus size, densities,
  tombstone counts, initial-sync memory) decides Step 3's build-or-defer
  and shapes Step 1's corpus builders. No hypothetical scale targets.
- **Benchmarks are ratio-asserted against RECORDED numbers** (Phase 4's
  render/autosave figures, Phase 6's spike numbers, Phase 10's read-tier
  cost, Phase 11's takes-board fetch). A silent budget relaxation is a
  full-severity review finding (review focus 1).
- **Nothing destructive without the author's accepted memo.** GC in this
  phase is a MEMO; purge code (if she accepts) lands behind her
  acceptance, or in a later phase — her call.
- **Findings are counts, not adjectives** (review focus 2): the soak
  record states numbers (rows compared, rescues found, repairs fired,
  drain times) with each anomaly traced or explicitly filed.
- The A4 fence stays absolute: dev-store sessions never touch the one
  production mirror; every real-corpus operation is a COPY taken with the
  author (her store files stay hers).

## Open questions, answered (the brief's four — ride the checkpoint ratify list)

1. **Soak pass/fail thresholds (PROVISIONAL, concrete):** (a) dump-compare
   after a full sync = **byte-identical synced tables, zero unexplained
   divergences** — any diff is a finding, full stop; (b) every
   `conflict`/`rescued`/`fragments` variant **traceable to a real race**
   (a rescue with no explaining event = finding); (c) repair firing rates:
   I2 move/move, dedupe, and dangling-chosen repairs expected **rare**
   (single digits over months); I10 resurrections expected **zero** on a
   single-author corpus — any occurrence is traced; (d) outbox drain at
   editor rate on the real corpus: a full push cycle ends with an empty
   outbox within the sync round's normal cadence (no monotonic growth
   across a session). Thresholds are the plan's PROVISIONAL — the
   checkpoint ratifies or tightens them.
2. **Windowed pull: MEASURE FIRST, decision gate in Step 3.** Build only
   if the real corpus's full-feed initial sync exceeds the budget defined
   there (memory headroom on the PHONE, the constrained device); otherwise
   re-defer WITH the measurements recorded in KnownIssues (the evidence
   rule — the brief's own instruction).
3. **GC memo scope: the personal shape** (two known devices, horizon =
   min acknowledged `server_seq` across them), **with the Phase 14
   multi-tenant extension NOTED, not designed** (per the brief's
   recommendation). The never-returning-device policy is presented as
   options for the author — never decided in the memo.
4. **Phase 13 prerequisites measured now:** (a) rendering-attribute /
   decoration budget on the live TK2 editor (TEXTKIT2 §3 flags this as
   the fragile area styling will lean on); (b) read-tier per-view cost at
   corpus scale (Phase 10 recorded 0.35 ms median — re-verify);
   (c) keystroke-path headroom under tint/badge/gap decorations at the
   Step 1 corpus. Numbers recorded in the closeout for the design phase
   to start from.

## Steps

### Step 0 — the evidence baseline (author-assist; everything downstream keys off this)
**Work:** with the author present: (i) a read-only COPY of her real store
(and the phone's, if practical) taken via the recoverable-open path;
(ii) measured reality recorded: post/block/variant/commit counts, fan
density distribution, journal-day count, longest post, tombstone counts,
`sync_row_seq` extent, store file size; (iii) the changefeed's total row
count and the full-feed memory footprint estimate (the Step 3 gate's
input); (iv) deploy-state check (phone build; lockstep marker). NOTHING
writes to her store; the copy is the phase's working corpus.
**Tests:** none owed (an audit step) — the recorded numbers land in this
plan's closeout as the phase's input table.

### Step 1 — P1 at corpus scale
**Work:** extend `CorpusFactory` to Step 0's measured densities ("years
of journals + a book": thousands of posts, tens of thousands of blocks,
real fan/commit distribution); re-run EVERY ratio-asserted benchmark —
renderPost, renderedText/export projection, autosave, reading assembly,
timeline keyset, library, the takes projection (11a), bulk-export
manifest (11b, the one deliberately corpus-shaped projection — assert
linear, never worse), editor keystroke path, read-tier realization
(Phase 10's figures) — flat means flat at THIS scale. The TEXTKIT2 §5
matrix runs on the current point release (spike re-run only if a macOS
update landed unabsorbed — check first); zero TK1 fallbacks (canary).
**Tests:** the extended benchmarks ARE the tests (ratio-asserted, seeded,
deterministic); the suite stays green at baseline counts + the new
benchmarks.

### Step 2 — the sync soak audit (the brief's (a)–(d), thresholds per answer 1)
**Work:** against the real-store copies (author-assist for fresh dumps):
(a) dump-compare both devices' synced tables after a full sync —
byte-identical or findings; (b) enumerate every conflict/`rescued`/
`'fragments'` variant with its explaining event (the week-one
dump-compare ritual, formalized and retired into this audit);
(c) repair-frequency review from `sync_row_seq`/store evidence against
answer 1(c)'s expectations; (d) outbox drain timing at editor rate on
the working corpus. Extend the Phase 8 fault-injection/re-entrancy
suites ONLY where the audit exposes an uncovered class (brief
pre-answer: they re-run here regardless).
**Tests:** the fault-injection + re-entrancy suites re-run green; any
audit-driven extension lands with the standard red-on-old discipline.
The audit RECORD (counts, traces, dispositions) goes in the closeout.

### Step 3 — pull-to-head windowing (KnownIssues row; DECISION GATE first)
**Work:** the gate: Step 0(iii)'s measured full-feed footprint vs the
budget (the phone must re-sync from scratch against the author's full
store within sane memory — define "sane" from the device's real
headroom, recorded). **If under budget: RE-DEFER with the measurements**
(update the KnownIssues row with the numbers and the re-check trigger —
e.g. corpus doubling). **If over: build per-window apply** — windows
with per-window commits and per-window cursor advance, straggler guard
preserved, sized from the evidence. **The build is Sync/ surgery — the
rider applies: Fable implements it or the coordinator stops and
reports.**
**Tests (if built):** outcome-neutrality (same final state as the
one-transaction apply on the same feed — the Phase 5 harness proves it);
cursor advances only on commit; a mid-window failure resumes without
loss or double-apply; the straggler guard's stall behavior unchanged;
the acceptance test = a from-scratch client against the working corpus
within the budget.

### Step 4 — the tombstone GC decision memo (author gate; a MEMO, not a build)
**Work:** the memo per the brief's letter: horizon = minimum acknowledged
`server_seq` across registered devices; physical purge strictly below it
(tombstones + their unreachable `commit_point` rows — AppSpec §14.4's
no-tombstone-column design); the **never-returning device** treated as
an explicit AUTHOR-CALL options section (device registry + manual
retirement vs age-based vs never-purge); server-side vs client-side
purge ordering; **the backup interaction rule** (a rotating backup
restored from before the horizon reintroduces purged rows — define
detection/re-purge or a restore-freshness rule); the §12
migration-lockstep lessons folded into the server-change choreography
section. The memo ends with a recommendation and STOPS — the author
adjudicates (Phase-6-class); purge code is NOT this phase's deliverable
unless she both accepts and directs it.
**Tests:** none (a memo); if she accepts AND directs a build, the purge
lands behind its own suite (horizon math pure-function-tested;
purge-below-horizon only; a full GC round-trip on the harness) — scoped
at her direction, not before.

### Step 5 — the backup restore drill (KnownIssues row)
**Work:** take a rotating cold copy (Phase 8's A1 machinery), open it
through the recoverable-open path as a real store, verify it renders
(library, a post, a fan, the journal) and that sync stays OFF for the
drill copy (the A4 fence — a restored store must never pair with the
production mirror uncoordinated; document what a REAL restore must do
about `sync_state`/cursor). The drill's steps become a short runbook
section in the closeout (a backup that's never been restored is a hope).
**Tests:** an automated drill test where feasible (open-a-backup-copy →
renders, WAL-consistent); the manual runbook recorded.

### Step 6 — the debt sweep (zero orphans, honestly)
**Work:** every remaining KnownIssues row resolved here or re-affirmed
with owner + reason, with evidence:
- **Bridge push sweep O(journal-days)** — measure the real sweep cost at
  Step 0's journal-day count; build the dirty-day set (or a VERIFIED
  stamp filter) if the measurement demands it, else re-affirm with
  numbers. (Bridge/ prudence: coordinate with the rider if the fix
  touches engine seams.)
- **Bounded view windows** — assess load-more/windowing affordances
  against the real listing sizes; build or re-defer with evidence.
- **Within-post virtualization** — the evidence question the brief asks
  (has any real post approached 100k words?); likely re-defer with the
  numbers; the block-TOC remains the escape hatch's natural face.
- **Poison-row isolation** — review the soak record for any jam
  candidate; design the park/heal shape only if one exists (the row's
  own rule), else re-affirm.
- **Pull-to-head + restore drill + GC** — dispositioned by Steps 3–5.
The closeout states the sweep's outcome row by row.
**Tests:** whatever the sweep builds lands with tests per the standing
expectations; re-affirmations need the recorded evidence, not tests.

### Step 7 — Phase 13 prerequisite numbers + phase verification
**Work:** answer 4's three measurements (rendering-attribute budget on
the live editor; read-tier per-view cost at scale; keystroke headroom
under decorations), recorded for the design phase. Then the phase gate:
full suites on all three targets; the benchmark record compared against
every recorded prior number; the soak record complete; the KnownIssues
table verified zero-orphan.
**Closeout ritual:** results + dispositions in this plan; master plan
row 12 → done, pointer → 13 with its kickoff note (Phase 13 is
author-attended Fable sessions per CLAUDE.md — the 9d shape, no
`/run-phase` cast by default; its plan is authored FROM
`notes/plans/phase-13-brief.md`, which is an orientation sketch — a head
start, not a contract); KnownIssues reconciliation; the author handoff
(`notes/handoffs/phase-12-handoff.md`) LAST, checklist at top (the GC
memo adjudication is the headline item).

## Hard author gates (stop-and-report, coordinator relays)
1. **Step 0 / Step 2's real-store access** — author-assist, never
   headless; copies only, nothing writes to her stores.
2. **Step 4's GC memo** — she adjudicates; the never-returning-device
   policy is her call; nothing purges before written acceptance.
3. **Any Sync/ change** (Step 3's build branch; any Step 2 engine
   extension) — the standing rider: Fable implements or the coordinator
   stops and reports.
4. The phone-install dependency (carried from 11a): if still pending at
   kickoff, Step 2's two-device halves and Step 3's phone acceptance
   wait on her one-time install.

## Explicitly out of scope
Multi-tenant GC/accounts hardening, E2EE, the variorum-edition bundle
(14); visual polish and the typographic PDF (13); building GC purge
without the accepted memo; any new view surface (Phase 11 closed the
view set); rewriting sync internals beyond what Step 3's gate demands.

## Risks
- **Real-store handling** — the phase's evidence lives in her private
  corpus; copies only, author present, the A4 fence absolute. A leaked
  or mutated store is the unrecoverable class.
- **The GC memo's blast radius** — GC is the system's first deliberately
  destructive design; the memo/gate structure exists so no purge logic
  exists before the author has ruled on the horizon, retirement, and
  backup rules.
- **Benchmark honesty** — corpus builders that don't match measured
  densities prove nothing; Step 0 exists so Step 1 can't be built on
  guesses (review focus 1 audits the comparison, not the narrative).
- **Cross-model flow friction** — first Opus-implemented phase since the
  flow was defined; the coordinator owns keeping the reviewer's fix
  passes and the implementer's sanity passes strictly sequential.

## Review foci (for the cold reviewer — the brief's five, carried verbatim in intent)
1. Benchmarks ratio-asserted at the new scale, compared against recorded
   Phase 4/6/10/11 numbers — any silent budget relaxation is
   full-severity.
2. The soak analysis ran against REAL data; findings recorded with
   counts, not adjectives.
3. Windowed pull (if built): outcome-neutrality proven; cursor advances
   only on commit; straggler guard preserved. (If deferred: the
   measurements justify it and the KnownIssues row carries them.)
4. GC: nothing destructive shipped without the author's accepted memo;
   the horizon math handles the never-returning device explicitly.
5. KnownIssues verified zero-orphan (every row a live owner and a
   this-phase disposition).

## Closeout

*(Filled at phase end per the ritual.)*
