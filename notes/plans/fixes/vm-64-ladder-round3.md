# VM-64 — ladder round 3 (cold review, the whole run's diff on the merged tree)

**Reviewer:** `fable-reviewer`, fresh, `notes/REVIEW_PROMPT.md` verbatim, zero framing. **Diff:** `ad5053002...HEAD` on
`vm-64-timing-and-lags`, tip `beefc79f7` (the final code tree is `74d91c666`; every later commit is the record or a
notes-only merge — checked by `--stat`). **Anchor:** the run record `notes/plans/fixes/vm-64-timing-and-lags.md`,
rounds 1 and 2 (findings, responses, final calls), the midpoint review.

**Read, in this session:** REVIEW_PROMPT; CLAUDE.md and its loaded canon; the run record's FOR A LATER READER, §1–§6,
the stage results through the round-2 window, batch 4's closeout whole, batch 6's hazards and round-trip table, the
round-2 fix pass's two closeouts whole; round 1 whole; round 2 whole; the midpoint review whole; SyncSpec in full (a
migration landed and the services' sync start is in the diff); TEXTKIT2_NOTES §3–§4 (the editor seam); the handoff
and the closeout drafts whole. Every production file of the diff: Core `Diagnostics/` (four files), `Domain/
StructuralFlightFence`, `Operations+Variant` (the narrowed op beside `closeAutoCommit`, `autoCommitDirtyVariants`,
`isDirty`), `OwnerIdentity`, `Migrations` (v1_38), `IdleCommit`, `LibraryPaging` (whole), `ShelfQueries`; `Shared/`
`AppTiming` (whole), `AppSession` (the leaving branch and the registry), `AppServices`, `AppBootstrap`,
`AutosaveCoordinator.flushNow`, `SyncSession`; the phone's `MobileTiming`, `MobileTimingView`,
`MobileLibraryViewModel` (whole), `MobileLibraryView`, `MobileLine` (whole), the shell files, `MobileWriteView` (the
screen's task and leaving), `MobileEditorViewModel` (the whole diff with `teardown`, `arrive`/`loadLive`/`start`,
`ingest`, `applyProjection`, `applyPendingIfClean`, the gate, the fence block), `MobileStructural` (the latch and five
doors), `MobileUndoDoor`, `MobileLivenessAuthority` (`register`, `takeLiveness`), the two chips, the fixture seeder.
With them, the code each change lands in: `AppDatabase.observe`, `EditorProjectionPolicy.decide`, GRDB's
`ValueConcurrentObserver` start path and the fork's manifest (WAL snapshots on). Pins read:
`MobileLibraryPagingRulesTests` whole, the open-once guard and hazard (a)'s pin, the tests the run edited in place
(`MobileWingsTests`, `MobileWingDoorTests`, `BlockCommentTests`).

**Run headless:** `swift test --filter 'TimingRecorderTests|StructuralFlightFenceTests|LeavingSavepointTests|OwnerAdoptionTests|OwnerIdentityTests|LibraryPoolPagingTests|MigrationTests'`
— **105 tests in 10 suites passed** (round 2's count); the Mac's own paging suite, `LibraryPagingTests`, 8 tests in 1
suite passed. **The round-2 stage window's claims were read from its local
logs, not the record** (`notes/plans/vm64-screens/r2-*.log`): the red build 31 tests in 4 suites, failed with 16
issues in exactly the seven named tests; the fix alone 32 in 5 passed; in company 237 in 27 passed with 2 known
issues and 14 "skipped" lines (the 13 gated tests and their suite); the gated suite alone 13 in 1 passed. **No hosted
suite was run by this reviewer** (no stage; the machine note forbids `xcodebuild`), so findings 1 and 3 below are
traced by reading and their pins are specified, not run.

**Verdict: 0 BLOCKER · 0 MAJOR · 2 MINOR · 3 NIT.** Round 2's MAJOR (finding 1) is fixed as its final call asked, on
every road its pins drive; finding 1 here is what that fix leaves at the listing's end.

---

## Findings (severity-ranked)

**1. [MINOR] · `App/Variorum/VariorumMobile/Features/Shell/MobileLibraryViewModel.swift:643-655` (`reread`) with
`:596-602` (`reaskAfterRowAct`) and `:699-705` (`askForMore`) · in a FULLY listed listing deeper than a page, a
delete followed by the line's Undo comes back one row short — and when the deleted row was the LAST one, the note
Put back is not listed at all.** Round 2's fix re-asks "the listed depth" (`max(listingLimit, rows.count)`). That
depth shrinks by one at a delete once every note is listed, and nothing grows it back. Traced in round 2's own pin
world (`listingLimit: 4`, held on screen), with 6 notes instead of 12:
- hold lands 4 rows (`next` set); `loadMore` appends 2 → 6 rows, `next == nil`, `allHasMore == false`;
- `confirmDeleteNote(all[5])` → `reaskAfterRowAct` (6 > 4) → `reread` at depth 6 → 5 rows, `next == nil`;
- the line's Undo → `restoreContainer` → the signal → `reaskAfterRowAct` (5 > 4) → `reread` at depth **5** over 6
  live notes → the first 5 and a cursor. The restored note is the 6th: `all` is unchanged (`changed == false`, so
  nothing redraws), `state.next` is now set, `allHasMore` turns true.
- Nothing asks for that next page: `land` → `askForMore` needs `wantsMore`, which is false (it is raised only by
  `rowAppeared`, and only while `next != nil` — it was nil when the tail rows came on screen), and those tail rows
  are already on screen, so `onAppear` does not fire again.
What she sees: Library scrolled to its end (more than 200 notes, all loaded), long-press the oldest note, Delete,
confirm, tap Undo — nothing comes back, and the line says nothing (`MobileLine.swift:138-140`: "the row is back on
the page"). Two more shapes of the same hole: (b) the deleted row sat more than `prefetchMargin` (30) rows above the
end — the note returns, the listing's LAST row drops off, and in All every book older than the new last note is
withheld again (`union(notesComplete: false)`); (c) within the last 30 rows but not last — the restored row's own
`onAppear` asks for the page and it heals. It heals in every shape on a scroll that re-realizes a tail row, or on
leaving the Library and returning. No data consequence (the note is restored). Round 2's two Put back pins list 8
of 12 notes, where the depth is refilled from below, so they cannot see it; the handoff's "an Undo of a delete … is
shown at once" (`vm-64-handoff.md`, "What was found and not fixed") is false in shape (a). The same landing happens
with no Undo at all when a note arrives at the top of a fully listed deep listing (a sync apply while she is at the
end): the oldest row drops off and waits for a scroll — VM-242's neighbour.
**Fix shape (the implementer's choice between two; no other line moves):** (i) *a listing that was complete stays
complete* — in `land`, when the rows it replaces answered the SAME question with `next == nil` and the page landing
carries a cursor, raise `wantsMore` before `askForMore` (so the one missing page is read and appended through the
existing `loadMore`, its generation guard and its dedupe); or (ii) the Put back's re-ask reads one row deeper than
what is listed (`reaskAfterRowAct` handing `reread` a depth, +1 on the Put back's road only). (i) is preferred: it
also covers the arrival case above and keeps All's books placed, and it cannot loop (a page that appends clears
`wantsMore`; a listing that was not complete is untouched). **Pin (red on this tree, model level, deterministic —
`MobileLibraryPagingRulesTests`' world):** 6 notes, `listingLimit: 4`, held on screen, `loadMore` until
`!model.allHasMore` (6 rows); `confirmDeleteNote(model.all[5])`; the line's Undo read off the line as in
`aPutBackThroughTheLinesUndoReturnsARowPastTheFirstPage`; settle until 5 rows; press Undo; settle;
`model.all.map(\.postID)` equals `Queries.library`'s whole listing (6), no note twice, `!model.allHasMore`. Red
today at "the note Put back is listed again". A second arm for shape (b) at the same size is not reachable (30-row
margin); say so in the pin's doc rather than add a second world.

**2. [MINOR] · the run record §5 (LIVE STATUS, "Still owed"), its FOR A LATER READER, and
`notes/handoffs/vm-64-handoff.md` ▸ "What happened" · the gate rounds 1 and 2 pinned is still open, and three
standing texts are stale at this tip.** Not a code defect — carried so it cannot evaporate between this round and the
merge. (a) Owed on the final tree, by the record's own last line: the whole phone target (the gated suite's 13
shown as skipped, in words), the whole Mac target, and the batches 6 + 7 combined walk (round 1's finding 4; the
plan's rule in §2, third bullet: an umbrella closes on use-shaped evidence, never on a pin alone). Finding 1's fix
moves the final code tree, so these run after it. (b) FOR A LATER READER still says round 2 is PENDING and its
ladder line stops at round 1; CLAUDE.md asks that section be kept current, and a later session reading it would not
learn that round 2 found a MAJOR, what it was, or that VM-240/241/242 exist. (c) The LIVE STATUS table's rows
"Ladder r1 · fix pass" and "Ladder r2 · fix pass" both still read IN-PROGRESS, though the stage windows below them
settled both. (d) The handoff's opening paragraph says the run was "reviewed twice with no blocker and no major";
its PENDING slot covers only what is left before the merge, so as filled it would tell her no review found a major.
Round 2 found one (a deleted Library row past the first page stayed listed) and it was fixed; her handoff should say
so in one plain sentence, and its "Reviews" paragraph the same. **Fix:** run and record (a) with executed counts and
every red by name; bring (b)–(d) current at the closeout. No pin.

**3. [NIT] · `App/Variorum/VariorumMobile/Features/Write/MobileEditorViewModel.swift:1310-1324`
(`structuralFlightChanged`) with `MobileStructural.swift:114-127` (and each door's twin) · a door that refuses
before it does anything still "lands a flight", and with a projection deferred the fence goes to `.settling` over a
page nothing changed.** Every door raises the latch before its own guards, so a divide with the caret in the open
tail runs, with no suspension: latch up (`flightBegan`) → "This text isn't a block yet…" → `defer` → latch down →
`flightLanded(surfaceSettled:)`. If `pendingProjection != nil` at that moment the landing reads unsettled, the
settle task forces a flush and a whole-note re-read (`refreshTakesFromStore`), and until it lands the gate refuses
every key with "Another structural change is still landing." — about an act that did not happen. Honest reach, said
plainly: the marker is set only while a delivery waits behind a busy buffer, and a hand that opens a menu has
usually paused past the 500 ms debounce, so the transient case is hard to reach and heals in one flush and one
read. The lasting case is the one to record: a buffer that cannot go clean (a refused write kept pending — the
coordinator's keep-pending posture, `AutosaveCoordinator.swift:167-178`; e.g. a take locked from another device
under her unflushed words) keeps the marker set, so after ANY door press — a refusing one included — three re-reads
fail and the fence stays up: typing is refused in every block of the note until the note is reopened. It is round
2's finding 7 (VM-227's stuck fence) with a second way in and a smaller trigger. It also bears on P-2-4 as the
handoff words it ("keys keep being refused until the next update from your library arrives"): while the buffer
cannot go clean, the next update does not end it either — every projection defers behind the buffer
(`EditorProjectionPolicy.decide`: busy outranks every apply arm) — so her ruling on P-2-4 should be asked with that
case named. **Disposition proposed:** no code
in this pass (the settle rule is VM-226's pin-first, Fable-reviewed session, and the shape round 2 ruled wrong must
not be re-proposed); add to VM-226's body: (1) a flight whose door never suspended lands as a drain — or the settle
rule counts only what the flight itself put between the page and the store; (2) the fence's fail-closed settle has
no exit while the buffer cannot go clean. **Pin for that session (deterministic, model level, the fence suite's
world):** page rendered; one key through the keyboard road (dirty); `applyProjection(_, fromDelivery: true)` →
`hasDeferredProjection`; `await model.structural.divide(atSurfaceCaret:)` at a caret in the open tail; then
`model.flightFence.phase == .open` and the next keyboard consult approved — red on this tree (`.settling`, refused).
Traced by reading, not staged.

**4. [NIT] · `App/Variorum/Shared/AppTiming.swift:445-459` (`processStartInstant`) and `:252-257` (`noteArrived`) ·
two more places the readout can mislead her sitting** (round 2's finding 8 class; a handoff caveat each, or a few
lines). (a) *Launch rows under iOS prewarming.* The launch spans begin at the kernel's start time for the pid when
it is under a minute old. iOS may prewarm an app — start its process and run it up to, not including, the app's
own launch — well before she taps the icon. A prewarm more than a minute old is dropped by the guard (the span then
starts at `MobileTiming.start`, missing the pre-main time the comment says it includes); one under a minute old is
counted whole, so "Launch → lock screen" and its siblings can read tens of seconds on a launch that felt instant.
No run here showed it, and it is unmeasured on a device. **The platform half, from the round's one external lookup
(a Sonnet subagent, read-only; quotes as it returned them):** Apple's "About the app launch sequence" says
"Prewarming creates your process and loads the libraries your app links against, then suspends your process without
allowing any application code to run", and "The system can prewarm your app after a device reboot, and periodically
as system conditions allow"; an Apple DTS engineer on the developer forums (thread 763739): "your process was
created at 6am but applicationDidFinishLaunching isn't called until 7am". **Still SPECULATIVE in one link:** no
source says what `sysctl`'s `p_starttime` returns for a prewarmed process — that it is the prewarm's creation time is
implied by those lines, not stated, and nothing here staged it. What is traced is this side's arithmetic: a start
time older than the tap and under a minute is counted whole. On the fix: `ActivePrewarm` is NOT Apple-documented
(third-party SDKs read it; the same DTS engineer says the system still sets it and that UIApplication clears it), so
a read from `MobileTiming.start()` may come too late to see it — untested. The honest options, cheapest first: a
caveat beside the handoff's other three (a Launch row far above the rest is a prewarmed start, not a slow one);
measure the launch from `start()` always (never inflated, and it gives up the pre-main time); or read the variable
before the app's own launch begins. No pin from a simulator. (b) *"Note
reads per open" can read 2 on a tree that reads once.* The per-open window is `.keepFirst`, 10 s, closed only by a
first delivery. An arrival cancelled mid-load (a push and an immediate pop — `loadLive` returns on its
cancellation arm and nothing closes the window) leaves it open; the next open inside ten seconds joins it, and its
close records both opens' reads as one sample. The handoff tells her the row "should read 1". Fix: cancel the
window where `loadLive` returns without a delivery (`recorder.cancelWindow(.noteReadsPerOpen)` behind one
`AppTiming` call), pinnable beside `MobileBoxOpenTimingTests`; or the caveat.

**5. [NIT] · small things, one line each.** (a) `vm-64-closeout-drafts.md` ▸ (e)5, the Library's SurfaceContracts
line carries "— ladder round 2, finding 1" inside the contract sentence; CLAUDE.md's two-file rule keeps ladder
findings out of that file — drop the clause (the record pointer at the line's end already serves). (b)
`Sources/VariorumCore/Diagnostics/TimingStats.swift:118-129`: the decode's comment says a decoded record "is held to
the ring's own invariants rather than trusted", but a positive `capacity` is taken as written (the first `record`
reserves that many slots), and `TimingReport.number` converts with `Int(_:)`, which traps on a value past `Int`'s
range; both are reachable only from a damaged `timing.json`, which is read at every launch on the timing file's own
queue — clamp the decoded capacity to `defaultCapacity` and bound the value before the conversion, or narrow the
comment. (c) §7 batch 4
and the v1_38 migration comment say the unowned-rows indexes are "empty in the steady state"; that is the signed-in
state. In a library never signed in (a local-only Mac library, the dev store) every row of the eleven tables is
unowned, so each index holds every row and is maintained at every mint, for an adoption that never runs there —
small (one short entry per row) and correct, but it is the cost P-67-2 rejected a full index for, and the record
should say which libraries pay it. (d) `MobileEditorViewModel.swift:244-251` and `:330-335` spell the editor's two
coordinator hooks twice (`init`'s `onError` goes through `report(OpsRefusalCopy.sentence…)`, the re-made one through
`reportOperationError`) — the same road today; one private `observeAutosave()` used by both would keep it so.

## Review foci (each addressed explicitly)

1. **Timing layer content and cost — SOLID.** Re-read whole: no entry point takes a string; the archive is raw
   series names, numbers, the build key (version | build | `LC_UUID`) and a day; a mark is one relaxed atomic load
   when off and a lock, a clock read, a dictionary slot and a ring write when on; memory is a 64-ring per series of
   a closed catalog and two builds' tables; the file is numbers-only JSON in the app's container, written on its
   own utility queue. Nothing in CastleRules speaks to a numbers-only side file (searched). Fidelity notes:
   finding 4; robustness of the decode: finding 5(b).
2. **Speed claims carry numbers — SOLID.** The BEFORE and AFTER tables give median and range, n = 5, the simulator
   named and the machine's load beside each run; batch 4's and batch 7's headless figures are marked Mac numbers;
   batch 5 says a page fetch is not faster; round 2's correction of the cost shape (finding 5 there) is in the
   record, the handoff and the drafts.
3. **VM-2's roads — answered as round 2 left them, with one addendum.** Every edit the gate is asked about is
   refused and said at once (`refuse`) and again at the drain; a gate-less block edit keeps the tiling, records
   nothing, and owes a store re-read before the fence drops; the flight belt sits above `index.verdict`, so a
   cross-block gesture inside a flight is refused, not scheduled; Insert Below's exemption sets and restores its
   flag in an order that cannot unfence another door. No key is dropped unsaid. Open, all ticketed: VM-226 (the
   tail's idle save; the settle read in flight), VM-227, the device's autocorrect and dictation (her sitting), and
   finding 3 here for VM-226's body.
4. **VM-67 — SOLID.** The probe and the UPDATEs share one writer access; the predicate, call sites and occasions
   are unchanged; `0e9948d03` is the schema alone, ahead of the op; `git diff --name-only` over
   `Sources/VariorumCore/Sync` and `Server` is empty; SyncSpec §2 (no mirror indexes) and §12 (tables, columns,
   semantics) read in full — a local partial index is not a lockstep event and the marker stays 15. The eight pins
   ran green here. The one unrecorded cost is finding 5(c).
5. **VM-68 — no note is unreachable; one residual of round 2's fix (finding 1).** Held reads: the first page only,
   only while drawn; its two ∝-the-store cases are recorded and ticketed (VM-240). The Mac's Library did not
   change: both statements are pinned byte-identical against frozen pre-change builders, and those pins ran green
   here. The `poolLoose` arm's alias, argument order and non-null sort key were checked against the statement text.
6. **VM-69 / VM-70 — SOLID.** The load is the observation's first value; on a pool GRDB compares the first fetch's
   WAL snapshot with the writer's and refetches before it starts tracking (read in the checkout; the fork builds
   with snapshots, and GRDB keeps a non-empty WAL at open, so the compare is available from the first read); the
   stream holds later values until `start()` takes the iterator, and every exit of `loadLive` that does not hand
   the iterators on drops them (the observation ends). A re-arrival's first value takes the delivery arm — a
   changed note then costs a second read before it paints, a considered trade (it closes the old `loadOnce`'s
   unchecked rewrite) and recorded. The release is the leaving's last act, balanced on every road I could
   construct; every reader of the coordinator reads it at use time (grepped), so the adopt path strands no one.
   P3's one live editor is untouched.
7. **VM-71 — the lock did not move, and no savepoint is skipped beyond round 1's accepted gap.** No line of
   `MobileRelock.swift` or `MobileShellRouter.swift` is in the diff. The candidates read equals `isDirty` on both
   arms as a byte superset (never savepointed and empty is not owed on either side), with the op's own gone, sealed
   and cadence gates; the narrowed op re-checks each listed take in one transaction on one clock read; a closed
   store returns quietly and any other read failure falls back to the whole op.
8. **The Mac unchanged; brains placed right — SOLID.** The Mac's `savepointOnLeaving` is the same statements in
   the same order under one `#if`; every Shared mark is inert there; `closeAutoCommit(_:)` is untouched; the Mac
   gains only `adoptOwnerID`'s no-write-when-nothing-is-unowned and v1_38 (finding 5(c) for local-only
   libraries). Brains sit in Core and `Shared/`; the phone owns faces.

## Clean bill (load-bearing things specifically checked and found solid)

- **Round 2's fixes, in the code.** Arm (A): one post in `MobileLine.putBack`, on the success path only; the
  listener registered at `holdFirstPage`'s top and removed first in its `defer`, filtered to its own session by
  object identity, answering only through `reaskAfterRowAct` — whose guards (a held listing, the question its rows
  answer, deeper than a page) hold; two overlapping holds fold into the follow's single flight; an old hold's
  `defer` cannot cancel a new hold's follow in practice (a new question's first delivery always lands directly).
  `landedWing` is observed, stores a nil scope as a value, and gates `visible`, the empty line and All's books.
  `boxOpenFiledNothing` cancels both spans exactly where `file()` hands back nothing. The readout's heading is
  drawn as drafted. The speed suite is gated, and the open-once guard counts the open's own road and tells one
  read from two in the same process.
- **Round 2's stage window, from its logs.** The seven meant reds and no other on the reversed build (16 issues);
  green alone and in company; the 13 gated tests logged as skipped in company and passing alone.
- **`leavingSavepointCandidates` ↔ `closeAutoCommit(_:takes:)` ↔ `autoCommitDirtyVariants`.** Same join, same
  filters, id order; I2 makes the join one row per take.
- **`adoptOwnerID`.** `writeWithoutTransaction` plus `inTransaction` is GRDB's own `write` shape; the report keeps
  its one-entry-per-table shape; the UPDATEs still enqueue by trigger (SyncSpec §3).
- **The Library's paging machine, apart from finding 1.** Generation and question guards on every landing; the
  hidden hold reads the note listing once per question and holds nothing; the return's first delivery re-asks the
  listed depth; `wantsMore` survives a superseded page; cancellation leaves no follow behind; the view's one task
  key carries the filter, the sort, the wing and the shell's on-screen fact, and a band drag changes it only when
  the Bool flips.
- **`ingest`'s chrome rule.** One pass on every arm: the arms that rewrite the page lay it out themselves, the
  arms that touch nothing still get theirs; the flag cannot go stale across an `ingest` (cleared before, read
  after, no re-entry).
- **The fence's ordinary road.** The latch's `didSet` on both doors; the two-latch landing; the storage belt's
  `forceFullRender` and `flushPendingText`'s re-read before a door plans; the drain's one sentence from the
  existing copy home.
- **Tests the run edited in place.** VM-55's wing pins drive the Library through its view's own road
  (`holdLibraryAsItsViewDoes`) with their expectations unchanged; `BlockCommentTests`' index set gained exactly
  the one new index; the `.oneWing` fixture runs the same operations in the same order.
- **Process.** No `Co-Authored-By` or session trailer in the range; no device identifier, address or account id in
  the added notes (searched); the shared ledgers untouched on the branch; the ladder-cap change in CLAUDE.md, both
  skills and ProcessHistory matches her recorded words, and CLAUDE.md's line carries no date or quote; no line in
  `Sync/`, `Server/` or custody code, and the one line under `Features/Protection/` is the lock screen's timing
  mark.
- **P1 across the diff.** Nothing added scales with the corpus on a write road; the read-side exceptions are
  VM-240's two recorded cases. Nothing tracks word-level change; nothing copies text across entities.

*(Finding 1 is new and is a residual of round 2's finding-1 fix. Finding 2 is rounds 1 and 2's gate, still open,
with three stale texts. Findings 3–5 are new. No finding touches `Sources/VariorumCore/Sync/`; none is marked
FINDER-FIXES — finding 1's fix and pin are specified above for the implementer. No new BLOCKER or MAJOR: by the
ladder's rule this round earns no round 4, so finding 1's fix is the orchestrator's line-by-line check.)*

## Implementer responses (round 3 fix pass)

*The round-3 fix pass's implementer (opus, the same session that built round 2's part B), after reading this file
whole, `MobileLibraryViewModel.swift` whole, the view's row `onAppear`, `MobileLibraryPagingRulesTests.swift` whole,
§7 batch 5's "The shape chosen" and the hidden-Library rules, Core's `TimingStats.swift`, `TimingReport.swift`,
`TimingRecorder.swift`'s `restore`/`absorb`/`merged` and `TimingRecorderTests.swift`, and — read only —
`AppTiming.swift`'s two named passages, `MobileStructural.divide`'s guard order and `MobileEditorViewModel`'s
`structuralFlightChanged` and its two `autosave.observe` sites. Written and pushed before any code. Every finding is
AGREED; the arms that wait for your final call are named in each entry.*

### 1 · [MINOR] a fully listed listing comes back one row short after a delete and the line's Undo — AGREE; shape (i), built one clause narrower as (i′) (the added note below); applied this pass with three pins

**My trace, in the pin world (`listingLimit: 4`, held on screen, 6 notes, the edited sort):** the hold's first
delivery lands 4 and a cursor; `loadMore` appends 2 → 6, `next == nil`, `allHasMore == false`. The delete of `all[5]`
(the oldest) leaves the held first page byte-identical (no delivery); `reaskAfterRowAct` (6 > 4) → `followFirstPage` →
`reread` at `max(4, 6) = 6` over 5 live notes → 5 rows, `next == nil` (`catalogNotesPage` probes `limit + 1`, so an
exact-depth read of the whole store carries no cursor). The line's Undo → `restoreContainer` (no sort key stamped) → the
first page unchanged again → only the signal → `reaskAfterRowAct` (5 > 4) → `reread` at `max(4, 5) = 5` over 6 →
the first 5 and a cursor; `place` finds `all` unchanged (no redraw), sets `next`, flips `allHasMore` true; `land`'s
`askForMore` finds `wantsMore == false` (raised only by `rowAppeared` while `next != nil` — nil when the tail came on
screen) and the follow still set. Nothing asks again; the restored (oldest) note is not listed. Your shapes (b) and (c)
are the same model state with the restored row inside the listing and its LAST row dropped; they differ only in
whether a view's `onAppear` fires for a row near the end — the model is identical. And the arrival case (a note at the
top of a fully listed deep listing, no Undo): the held page changes → the follow → `reread` at depth N over N + 1 → the
oldest drops, the same stuck cursor. Confirmed in every shape you named.

**Shape (i), checked against every caller of `land`** (`land` has exactly three: `prime`, `holdFirstPage`'s direct arm,
`reread`; `loadMore` APPENDS through `append`, never `land`):
- `prime` lands only when `paging.question != question` — always a NEW question, whose existing first branch clears
  `wantsMore`; (i)'s branch is `else`, so it never runs there. The same for every new question elsewhere: a first
  landing, a sort change, a wing change.
- `holdFirstPage`'s direct arm: a new question (as above), or a listing of at most one page (`rows ≤ limit`). There (i)
  runs only when that one-page listing was complete and the new first page carries a cursor — the store crossed a
  page (a note at the top; or the return after notes arrived while hidden). It reads ONE page after the cursor —
  what the store's growth pushed off the end. Today that row comes back only if the new row's `onAppear` finds it in
  the 30-row tail.
- `reread` (the follow's re-ask; the return's re-ask of a deeper listing; a row act; a Put back): it lands INSIDE the
  follow task, so `land`'s own `askForMore` is a no-op (`follow != nil`); the follow's existing exit (`follow = nil`,
  then `askForMore`) starts the one `loadMore`. `followAgain` re-reads land with `next` already set, so they never
  raise again; the raised `wantsMore` simply waits for the exit.
- A filter change: each listing has its own `Paging`; a return to a filter whose listing was complete for the same
  question re-lands through the two arms above and stays complete.
- `loadMore` itself: `append` clears `wantsMore`; a superseded page asks again (the existing rule, once per landing
  that superseded it).

**Why it cannot loop or over-read (P1):** the raise fires only on the one transition "the rows were complete for this
question, and this landing carries a cursor"; the same landing sets `next`, so no later landing re-raises until a page
has appended AND the listing is complete again. Each raise costs at most one keyset page after the cursor (∝ the page);
a store that grew by more than a page between two landings (a large sync) ends with ONE page appended, a cursor and
`wantsMore` false — the rest load as she scrolls, the ordinary road, never a chase of the store. A listing that was not
complete is untouched (its `next` was already set): round 2's four pins at 8 of 12 are the guards for that (they expect
exactly the listed depth back, and would read 12 if (i) over-read).

**Why (i) over (ii):** (ii) heals only the Put back's road (not the arrival, not the return after a hidden arrival, not
a ★ or delete whose re-ask meets a store that grew meanwhile), and reads one row more on every Put back. (i) is one
condition in `land`, and every road through it heals.

**One residual of (i), said rather than built:** in All, between the landing that breaks completeness and the one page
appending (one keyset read), `allHasMore` reads true, so books older than the last listed note are withheld for that
read and then return — a one-read blink at the listing's end, where today they stay withheld until a scroll. Holding
`allHasMore` false over the chase would draw books the union cannot yet place (P-68-4's own rule), so I left `place`
alone.

**[ADDED by this implementer while building, after the responses were pushed — one over-read the paragraph above
missed, and the arm it makes for your final call.]** Read again against the direct arm of `holdFirstPage`: a SHORT
complete listing whose first page a single landing reaches PAST — the plainest case is a first sync onto an empty
Library held on screen (0 rows, `next == nil`; the first delivery lands a full page and a cursor) — meets your
condition, so (i) as specified reads a second page she did not come near, and from then on the held listing is two
pages deep: every later delivery of that sync goes through the follow and re-reads two pages where it landed one.
Bounded and ∝ what is listed (P1 holds), but an over-read on the heaviest road the Library has. Nothing is stuck
there to begin with: the new rows reach below what was listed, so the ones near the new end fire their own `onAppear`
as she scrolls. **Built, therefore, (i′):** the same condition plus "this page reaches no deeper than the rows it
replaced" (`page.items.count <= rows(listing).count`) — exactly the re-ask at the listed depth (`reread`, depth =
the rows) and a one-page listing that was exactly full; every shape you named, and the arrival, meet it (the three
pins below are red on old and green under either arm). **Arms for your final call:** (i′) as built — recommended;
(i) exactly as you wrote it — the extra clause deleted, the pins unchanged; the over-read above recorded.

**What lands (Part of VM-68):** in `land`, the existing `if state.question != question { state.wantsMore = false }`
gains `else if state.next == nil, page.next != nil, page.items.count <= rows(question.listing).count { state.wantsMore
= true }`, with its comment. No other line moves.
**Pins** (`MobileLibraryPagingRulesTests`, hosted, model level; the expected red is on the pre-fix code — round 2's
tree with this one hunk reversed):
- `aPutBackOfTheLastRowOfAFullyListedListingReturnsIt` — your pin as specified (6 notes, limit 4, held, listed to the
  end; delete `all[5]`; the line's own Undo read off the line; settle until 5; Undo; expect the store's whole 6, no note
  twice, `!allHasMore`). RED on old with 3 issues: "the note Put back is listed again", "the store's whole listing",
  `!allHasMore`.
- `aPutBackOfARowAboveTheEndOfAFullyListedListingKeepsItsLastRow` — the arm for shapes (b) and (c), at the model level
  (12 notes, three pages, listed to the end; delete `all[6]`; the line's Undo). RED on old with 2 issues (the store's
  whole 12 — the last row dropped; `!allHasMore`); the restored row itself IS listed on both trees. Its doc says why a
  view-level arm for the 30-row margin is not reached at this size: the two shapes differ only by a view's
  `onAppear`, which a model world has none of.
- `aNoteArrivingAtTheTopOfAFullyListedListingKeepsItsLastRow` — the arrival case, no Undo (6 notes listed to the end;
  a seventh minted). RED on old with 2 issues (the store's whole 7; `!allHasMore`).
The hosted run for them is in the record's §7 ▸ "Ladder round 3 — fix pass"; the red-on-old build is made after the
VM-78 merge-in, with the gate tree.

### 2 · [MINOR] the gate is still owed; three texts are stale — AGREE

(a) and (b) are the orchestrator's (the merge gate on the final tree, the FOR A LATER READER at closeout). Mine, this
pass: (c) §5's two summary rows "Ladder r1 · fix pass" and "Ladder r2 · fix pass" flipped to what is true (DONE, each
with the stage window that settled it), and the round-3 row added; (d) the handoff's "What happened" and "Reviews" in
plain words — a midpoint review and three rounds; round 1 and round 3 found no blocker and no major; round 2 found one
major (a note deleted from a Library row past the first page stayed on screen, and putting it back did not bring it
back), fixed and then seen failing on the old build and passing on the new — with `PENDING(merge gate)` where the
gate's results go. No pin.

### 3 · [NIT] a door that refuses before doing anything still lands a flight — AGREE by reading; no code (your disposition)

Read: every door raises its latch before its guards (`MobileStructural.divide`: `structuralInFlight = true` then the
seal and tail refusals return through the `defer`), and `structuralFlightChanged` lands the flight through
`flightLanded(surfaceSettled:)`, which reads unsettled while `pendingProjection != nil` — so a refusing press over a
deferred projection goes to `.settling`, and with a buffer that cannot go clean every re-read defers behind it
(`EditorProjectionPolicy` — busy outranks every apply) and the fence never drops until the note is reopened. VM-226's
body is the orchestrator's (Linear). Mine: the handoff's P-2-4 bullet and the drafts' bundle say, in plain words, that
the next update from her library ends a stuck fence — except when a save is stuck and cannot land, when typing stays
refused in that note until it is closed and opened again; and the same line goes under VM-226 in "What was found and not
fixed". `MobileEditorViewModel.swift` and `MobileStructural.swift` untouched.

### 4 · [NIT] two more places the readout can mislead her sitting — AGREE; caveats, no code

Both as you traced them (read: `processStartInstant` accepts a start under a minute old whole; `noteArrived` opens the
`.keepFirst` 10 s window that only a first delivery closes). Caveats in the handoff's readout steps: (a) a Launch row can
include time the system spent starting the app before she touched it, so several launches and the median and the
smallest, never one; (b) "Note reads per open" can read 2 when a note is opened within about ten seconds of an open that
was abandoned before it finished loading. **Why not code:** (b)'s cancel belongs where `loadLive` returns without a
delivery — inside `MobileEditorViewModel.swift`, which this pass may not open; placing it elsewhere (the screen's task)
would be a second, guessed owner of the window. (a)'s options either give up the pre-main time the row was built to
include (batch 1's rule: no change to what a mark measures without saying so and re-taking the BEFORE) or read an
undocumented variable untested on a device. Neither is a NIT's work; the caveats are honest and cost nothing.

### 5 · [NIT] small things — AGREE (a) (b) (c); (d) declined, with the reason

- **(a)** the clause "— ladder round 2, finding 1" removed from the drafts' SurfaceContracts line; the record pointer at
  the line's end stays.
- **(b) — applied with headless pins (VM-65).** *[CORRECTED by this implementer before the fix landed, after a probe —
  the first text said "the decode itself traps … a capacity near `Int.max` traps INSIDE `init(from:)` … so a damaged
  file would end every launch the same way". FALSE: `Array.reserveCapacity(Int.max)` is a silent no-op (a probe
  binary: capacity 0 after it, exit 0), and the old code decoded that record without trapping. What IS true of the
  capacity: taken as written, the decoded series keeps every sample the file holds (contrary to the comment) and its
  first sample reserves that many slots up front (the same probe reserved 2⁴⁰ slots — 8 TB of address space — and
  carried on, on the Mac; on the phone it is unmeasured). The trap is the readout's alone, as you wrote it.]* A
  positive decoded `capacity` is taken as written; and `TimingReport.number` converts with `Int(_:)` (both branches,
  `oneDecimal` too): a sample past `Int`'s range traps at the readout (observed: `.signal(SIGTRAP)`). The fix: the
  decode takes `defaultCapacity` for any capacity outside `1…defaultCapacity` (the ring's own bound — the app's one
  recorder is built at the default; a re-ring at `merged` takes the recorder's own capacity anyway); `number` bounds
  its value to ±10¹⁵ before converting (a NaN, reachable only as ±∞'s median, reads 0). Pins in `TimingRecorderTests`:
  a plain value pin that a decoded capacity of 100,000 (and of `Int.max`) is held to 64, keeping the newest samples
  (RED on old by value — neither size traps there); and two EXIT TESTS (Swift Testing's
  `#expect(processExitsWith: .success)`, so a trap is asserted in a child process and the suite survives it) — a
  damaged record's report, and the bounded values drawn, both RED on today's code by the trap. The Mac: both types
  are Core, compiled by the Mac, called by nothing of the Mac's (the decode's one caller is the phone's
  `MobileTiming`, the report's the phone's readout; `Shared/AppTiming` uses only the recorder's marks) — checked by
  grep, said in the record.
  **One more, found while tracing, NOT applied — your call:** `TimingRecorder.merged` (the launch's `absorb`) ADDS a
  decoded `count` and the decoded counters to the live ones (`stats.count + current.count`; `counters[key] += value`;
  `restarts`/`abandoned`/`unmatchedEnds`), and a damaged count near `Int.max` overflows there — the same trap at
  launch, by the same file. Arms: (A) saturating adds in `merged` (`addingReportingOverflow`, clamped to `Int.max`),
  pin first (a damaged count absorbed under a live sample must not trap — red today); (B) the decode bounds `count` (an
  arbitrary ceiling); (C) leave it, recorded. I recommend (A), in this pass's same commit class, if you rule it in.
- **(c)** the record's two "empty in the steady state" (§7 batch 4, and batch 4's live-status row) and the drafts' §7
  narrative say the SIGNED-IN steady state, and that in a library never signed in each index holds every row of its
  table (one small index entry per row written). **Arm for your call:** the same phrase in the `v1_38` migration's
  comment (`Persistence/Migrations.swift`) — a comment only, no DDL; I did not touch the migration file without your
  word (the brief named the record and the draft). Recommend: yes, its own commit.
- **(d) — DECLINED, recorded:** `MobileEditorViewModel.swift` stays untouched by the ladder's fix passes (the editor
  seam; a cleanliness nit does not open it). Read for a correctness reason and found none: `reportOperationError(_:)`
  is `report(OpsRefusalCopy.sentence(for: error, roads: .phone))`, the very call `init`'s hook makes, so the two
  spellings are one road today.
