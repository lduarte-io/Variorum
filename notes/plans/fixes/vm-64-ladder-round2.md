# VM-64 — ladder round 2 (cold review, the whole run's diff on the merged tree)

**Reviewer:** `fable-reviewer`, fresh, `notes/REVIEW_PROMPT.md` verbatim, zero framing. **Diff:** `eb18888db...HEAD` on
`vm-64-timing-and-lags`, tip `c9b21c5aa` (68 files, ~15.6k insertions; the production half is 35 files, ~3.7k lines).
**Anchor:** the run record `notes/plans/fixes/vm-64-timing-and-lags.md`, round 1's findings, responses and final calls
(`vm-64-ladder-round1.md`), the midpoint review.

**Read, in this session:** REVIEW_PROMPT; CLAUDE.md and its loaded canon; the run record's FOR A LATER READER, §1–§6
(plan, cast, batches, LIVE STATUS, the stage results, the review foci), batch 5's closeout and the merge-in closeout
whole, the other closeouts by their hazard, residual and design-call sections; round 1 whole; the midpoint review;
SyncSpec in full (a migration landed, and the services' sync start is in the diff); TEXTKIT2_NOTES §3–§4 (the editor
seam); every production file of the diff under `Sources/`, `Shared/` and `VariorumMobile/`, each with the code its
change lands in (`AppDatabase.observe`, `EditorProjectionPolicy`, `StoreBinding.lock`, the Mac's
`LibraryCatalogModel`, VM-55's `MobileLine` and `MobileWingScope`); the pins that carry the fix pass and the merge
(`MobileNoteHoldTests` whole, `MobileLibraryPagingRulesTests`, the hidden-switch guard, `holdLibraryAsItsViewDoes`,
hazard (a)'s pin); the handoff and the closeout drafts.

**Run headless:** `swift test --filter 'TimingRecorderTests|StructuralFlightFenceTests|LeavingSavepointTests|OwnerAdoptionTests|OwnerIdentityTests|LibraryPoolPagingTests|MigrationTests'`
— **105 tests in 10 suites passed** (round 1's 103 plus the fix pass's pin and guard). The whole-package claim was
read from its local log (`App/Variorum/DerivedData/vm64-gate-swifttest.log`: 703/130 · 4,178/576 with 5 known
issues · 32/4 = 4,913, no failure line; built at `66ac9d503`), and the merged-tree builds from theirs (both
`** TEST BUILD SUCCEEDED **` at `f4068b3cf`; every commit after it touches the record alone — checked). **No hosted
suite was run** (no stage; the machine note forbids `xcodebuild`) — see finding 4.

**Verdict: 0 BLOCKER · 1 MAJOR · 5 MINOR · 3 NIT.**

---

## Findings (severity-ranked)

**1. [MAJOR] · `App/Variorum/VariorumMobile/Features/Shell/MobileLibraryViewModel.swift:814` (`confirmDeleteNote`)
with `:499-521` (`holdFirstPage`) · a note deleted from a Library row past the first page stays listed, and a Put
back of one does not come back.** Mechanism, traced: VM-68 lists pages past the first but HOLDS only the first
(`holdFirstPage` observes `Self.read(db, question, after: nil, limit: listingLimit)`). `AppDatabase.observe` ends in
`.removeDuplicates()` (`Sources/VariorumCore/Persistence/AppDatabase.swift:267-270`). The row's delete door runs
`ops.deleteContainer`, which writes exactly the deleted note's row and its saved versions
(`Operations+Container.swift:694-718`). So when the deleted row sits past row `listingLimit` (200), the write wakes
the observation, the re-fetched first page — items, cursor and all — equals the last one, nothing is delivered,
`followFirstPage` never runs, and `all` (or `bookless`) keeps the row. Nothing else re-asks: `confirmDeleteNote`
clears the confirm, flushes, deletes, speaks "moved to Trash" with Undo, and returns; the view's task key has not
moved. What she sees: Library, scrolled past the 200th note, long-press a row, Delete, confirm — the line says it
moved to the Trash and the row stays. Pressing Delete on it again refuses (`liveContainer` throws on a tombstone);
tapping it opens a deleted note. It heals only when the first page next moves, or when she leaves the Library and
returns (the return's first delivery re-asks the listed depth). The reverse leg is the same hole: the line's Undo
(`MobileLine.swift:123-126`, `restoreContainer`) restores a deep note whose stamp has not moved, so the first page
is again unchanged — `MobileLine.swift:139-141`'s "A landed Put back says nothing: the row is back on the page"
holds only inside the first page. The Mac's own read has the rule the port dropped: its one-shot listing re-asks IN
PLACE after an act on its own rows (`LibraryCatalogModel.refresh`, its doc at `:791` — "a rename, a tag, an archive,
a delete, a wing move, a book's row menu"; one caller at `:722`), beside the follow the phone did port. Before VM-68 no row past 200 was listed, so the hole is this run's. **Fix shape:** after the
Library's own row acts land — the delete door, and the line's Put back of a note — re-ask the shown listing at its
listed depth through the existing single-flight road (`followFirstPage(question)` when `rows(listing).count >
listingLimit`; inside the first page the held observation already answers). The Put back needs a seam the session-
level `MobileLine.putBack` can reach (the implementer's choice of shape; the Mac's rule is the model). A ★ toggle
on a Bookless row is the same class where a ★ gathering exists (the row's loose class moves) and should ride the
same re-ask. **Pin (red on this tree):** `MobileLibraryPagingRulesTests`' world, `aDeeperListingFollowsItsFirstPage`'s
posture — `listingLimit: 4`, 12 notes, held on screen, `loadMore` to 8 rows; `await model.confirmDeleteNote(row 7)`;
settle; `model.all` no longer holds it and stays 7 deep in `Queries.library`'s order. Second arm, same world:
restore it (`restoreContainer`) through the door the fix gives the Put back; the row is listed again.

**2. [MINOR] · `App/Variorum/VariorumMobile/Features/Write/MobileEditorViewModel.swift:1327`
(`flightSurfaceHoldsTheStore`) against `:1163-1201` (`applyPendingIfClean`) · the fence's settle rule reads "no
deferred projection" while that projection's fresh read is still in flight.** The brain's rule
(`StructuralFlightFence.surfaceHoldsTheStore`, `Domain/StructuralFlightFence.swift:106-110`) says the page holds the
store exactly when no forced render and no deferred projection is outstanding, and the face reads the second from
`pendingProjection != nil`. But `applyPendingIfClean` sets `pendingProjection = nil` at `:1174` BEFORE its re-read
returns (it restores the marker only on its failure arms), so for the length of one projection read the marker
says "settled" over a page that has not re-read. Two places read it in that state and drain: the settle loop's
check (`:1344`, `if self.flightSurfaceHoldsTheStore { break }` then `drainFlightFenceIfSettled`) and the projection
hook (`:1048`). (The landing's own check at `:1318` is not exposed on the doors I traced: a deferred settle sets the
marker in the same synchronous run that drops the latch.) The road, traced: a door's own settle
(`refreshTakesFromStore` → `ingest`) is DEFERRED because a tail mint is in flight (`busy` → `.deferUntilClean`, the
marker set, the page still pre-act); the latch drops into `.settling` and the settle task waits in
`awaitMintSettle()`; the mint's finish (`TailCrystallizer` → `host.applyPendingIfClean()`) clears the marker and
starts its read; then EITHER the mint's own commit delivery is consumed before that read lands (clean and
non-matching → `.refetchFresh` → the marker set and cleared again → the hook's task drains), OR the finish ran ahead
of the settle task's first iteration (its first check reads "settled" and drains). From there until a fresh read's
`ingest` lands, the gate approves a key against the pre-act tiling — `recordAutosave` records the whole old block,
the read's result re-defers behind the dirty buffer, and the flush rescues into a `'conflict'` take: VM-2's own
bug. Honest reach: it needs a mint INSIDE a flight (VM-226's idle clock, or a gate-less tail edit) and then a key
inside one read's time (milliseconds on a short note, the whole-projection read on the 100k note). Rare; nothing
is lost when it happens (the rescue keeps both texts). It is a hole in the rule the fence states, at the seam the
run built. **Fix shape:** the settle rule must also know a settle
read is in flight — one fact on the model raised where `applyPendingIfClean` takes the marker and lowered when its
task ends on any arm, read by `flightSurfaceHoldsTheStore` (a third input to `surfaceHoldsTheStore`); the
projection hook then drains when that read's `ingest` lands. Nothing else in `applyPendingIfClean` moves. It may
ride VM-226 (the same road — a mint inside a flight) if the orchestrator prefers one pin-first session for both.
**Pin:** headless on the model, the store held so reads park (`withEditorWorld` is a `DatabaseQueue`, so a held
write parks them): with the page rendered and clean, drive a non-matching delivery
(`applyProjection(_, fromDelivery: true)` → `.refetchFresh` → the marker taken, the read parked) and require the
readable fact (`hasDeferredProjection`, or the new one) to stay true until the read lands — red today. The fence
arm on top: the same parked read with the fence `.settling` must not drain.

**3. [MINOR] · `MobileLibraryViewModel.swift:462-469` (`hold(_:)`) and `:98` (`visible`) · after a wing switch
made while the Bookless listing is not held, the Library draws the PREVIOUS wing's Bookless rows until the return's
first fetch lands.** The merge re-landing's (a) says a hidden switch is honoured on return; that is true of the
NOTES listing only. Trace: Bookless filter standing; the wing door (on any root) switches and lands on the Shelf,
so the Library is hidden; the key changes and the task restarts hidden: `prime(question(.notes))` reads the new
wing's notes, and the function returns at `guard hold.onScreen` — the Bookless rows are not re-read (by design:
"nothing held, not even read") and not cleared. On the return the body renders `visible` = `bookless` = the old
wing's loose notes (with `booklessLoaded` and `booklessWingHasNotes` the old wing's too, so the empty line can be
the old wing's), and only then does the task start and its first fetch land the new wing's. On main, VM-55's
`MobileWingScope.follow` re-read BOTH listings at the switch, hidden or not, so this window is the merge's. It is
one read long (the loose page: 8 ms on the simulator fixture, more on her library) and self-healing; it shows
another wing's notes in a product whose wings isolate totally, and a tap inside it opens the other wing's note
(the app's wing follows the focused note). The hosted guard
(`aWingSwitchedWhileTheLibraryIsAwayIsHonouredOnTheReturn`) drives All and settles before it looks, so it cannot
see this. **Fix shape:** rows are drawn only while they answer the current wing — `visible` (and the empty-line
facts) return nothing for a listing whose landed `Paging.question?.wing` is not `session.wing.readScope`; a pure
read in the body's own pass, so no frame draws the old wing. **Pin (red on this tree, deterministic, model
level):** VM-55's `TwoWingWorld`; Bookless held on screen in Home until it lists Home's loose note; the hold
cancelled; `session.wing.switchTo(work)`; `await model.hold(model.hold(onScreen: false))`; then
`model.visible` holds no Home note (today: it is Home's row).

**4. [MINOR] · the run record §5 (the fix-pass row, the merge row) · the tree this round reviewed has no hosted
evidence since the merge, and round 1's condition on finding 2 is unmet.** Round 1's final call confirmed finding
2's fix on conditions "owed before this round closes": the pin RED on the build with only that hunk reversed and
GREEN on the fix build, alone and in company — "the next checker's to read". Neither has run: the newest hosted
logs under `notes/plans/vm64-screens/` are 11:09, the merged-tree products (`vm64-gate`, `vm64-gate-red`) were
built 14:01–14:07, and the record's own rows say "stage runs owed". So at this tip: the finding-2 pin has never
executed on either build (a bug-class fix without its red-on-old run); VM-55's four re-landed Library pins and the
new hidden-switch guard have never executed; `MobileNoRawErrorPinTests` over the four converted lines has not run;
the perf suite's asserted counts have not been re-read on the merged tree; and the batches 6 + 7 walk (round 1's
finding 4) is still PENDING. The record is honest about every one of these — this is the gate, pinned in place
again, not a wrong claim. My reading of the pin's code: its posture is sound in its own world (`AppDatabase.inMemory()`
is a queue, so the held write parks the leaving's candidates READ after teardown cleared the token — not the
runner's write, as round 1's call described it; nothing was typed, so on a pool that leaving would not park). **Fix:**
run groups (i)–(iv) of the merge-in closeout's stage commands and the walk, and record executed counts and every
red by name, before the merge gate counts as open.

**5. [MINOR] · the run record §7 batch 5 ▸ "The shape chosen" (the cost table), the handoff ("Shown: its first
page is re-read at each save (bounded…)"), the AppSpecRecord draft ("bounded by the page") · the held first page
is not viewport-shaped in two cases the record does not state — review focus 5's honest answer is "yes, still
corpus-shaped there".** (a) Under three of the phone's four sorts (created, date, last meaningful edit) the page
read is `catalogNotesPage`'s single arm with no index on its key: a top-N pass over the store's live notes, ∝ the
note count, as `LibraryPaging.swift`'s own header says of the Mac. The cost table's "one seek down
`idx_container_touched` stopping at the page" is the edited sort's alone. (b) Under the edited sort in a wing
holding fewer notes than a page (any small wing — the phone stands in one since VM-55), the touched arm is forced
onto `idx_container_touched` (`INDEXED BY`), which carries neither kind nor wing, and `LIMIT limit + 1` never
fills: it walks every live container in the store, fetching each row to test its wing. The record names this
floor for the Bookless page only. Neither is a regression (the old listings scanned and sorted every post on every
write, hidden or not, and the Mac's catalog has the same shape), and while the Library is on screen little is
typed — so the consequence is a record that over-claims and a cost her wave-4 tuning should know about. **Fix:**
correct the three sentences (the table, the handoff line, the draft) to say which sort and which wing shape is a
bounded seek and which is ∝ the notes; ticket the two cases for VM-176's ranking (an index for either is a local
schema change of v1_38's class, hers to schedule). No pin: a cost property that is red on the old code too.

**6. [MINOR] · `notes/handoffs/vm-64-handoff.md:20` (P-2-1) and its P-2-2 bullet; `vm-64-closeout-drafts.md:11`
(the QUESTIONS bundle, P-2-1 and P-2-2) and `:82` (the SurfaceContracts fence line) · four statements her handoff
and the canon drafts make are false on the merged tree.** Each says the after-flight sentence is spoken "with the
act's Undo still beside it" / "keeps its Undo or Redo" / "with the door's Undo kept". Since the merge the drain's
`report(…, action: statusAction)` reaches `MobileLine.say(…, as: .refusal, door: undoDoor)`
(`MobileLine.swift:73-95`), which first withdraws the note's standing structural-Undo line and then draws a
refusal with no action; `statusAction` is read by no face. The merge-in closeout found exactly this ("P-2-2 meets
VM-61") and carried it to QUESTIONS, but the handoff and the drafts — written before the merge — still tell her
the opposite of what her phone will do. The same draft line (`:82`) says "nothing reaches the store stale", which
VM-226 (open, traced: the tail's idle clock inside a flight) and finding 2 contradict; a contract line should
claim what the fence guarantees (an edit the gate is asked about, or that reaches a block's text, is never written
toward the store during a flight). **Fix:** correct the four statements to the merged behaviour (the refusal wins
the line; the Undo stays in the ⋯ sheet; P-2-2's options as the merge-in closeout lists them) and narrow the draft
contract line. Record edits; no pin.

**7. [NIT] · VM-227's ticket body (to be pointed at round 1's trace at the merge) · the unobserved state now costs
more than the ticket says.** By reading: an editor that holds its coordinator but does not listen (VM-227's
remaining road) never hears `onSettled`, so a projection deferred behind her typing leaves `pendingProjection` set
after the buffer is clean (nothing but `applyPendingIfClean` clears it — `:1164-1174`; an echo delivery adopts and
leaves it). The next structural act then lands with the marker set, `.awaitSettle` → three re-reads that never
clear it → the fence stays `.settling`, and every key is refused with "Another structural change is still landing."
until a non-matching delivery arrives or the note is popped and reopened. SPECULATIVE in the guard's sense — I
traced it but cannot stage VM-227's state without that ticket's own pin. Add it to the ticket's body so its
priority is judged on "typing refused", not "a delayed apply".

**8. [NIT] · `App/Variorum/Shared/AppTiming.swift:209` + `MobileQuickNote.swift:891` · two places the readout can
mislead her sitting.** (a) `open()` begins "Open → note on screen" and "Open → keyboard up in the note" before the
filing, and nothing cancels them when the filing hands back no note (an empty box, a refusal); any note painted
by any road inside the next 30 s then ends the span and records a bogus, long sample in the row the handoff calls
"the whole of your second lag". Fix: cancel both spans where `file()` returns nil (pinnable on the model: Open on
an empty box, then `AppTiming.notePainted()`, records nothing). (b) "Savepoints per leaving" is a 10 s
`.keepFirst` window that no act closes (`:311-314`; `noteLeft` finishes the span only), so two leavings inside ten
seconds are ONE sample holding both, and the handoff's step "go back out of a note you edited, and of one you only
read → 1 after an edit, 0 after only reading" reads as a single 1 if she does them back to back. Fix: say so in
the handoff beside the other three caveats (or close the window at `noteLeft` when no app leaving opened it).

**9. [NIT] · small things, one line each.** `MobileTiming.swift:61` — a local named `print` shadows the function
in that closure. `MobileTimingView.swift:146` — the readout's header is drawn upper-cased (`title.uppercased()`);
the edit trace's header is too, but her standing rule is sentence case, and the handoff's wording-pass list names
the title without saying it is drawn in capitals. `AppTiming.recorder` is a process-wide static beside CLAUDE.md's
"no global singletons": the reason is recorded and sound (launch and unlock spans cross sessions, and the edit
trace is the precedent), and its cost is recorded too (the perf suite runs alone) — named here so the next
diagnostics addition does not take it as licence for product state.

## Review foci (each addressed explicitly)

1. **Timing layer content and cost — SOLID.** Re-read whole: no entry point takes a string (two closed
   `String`-backed enums; the archive is raw series names and numbers; the build key is version | build |
   `LC_UUID`); every mark is one relaxed atomic load when off and a lock, a clock read, a dictionary slot and a
   ring write when on; memory is bounded (a 64-ring per series over a closed catalog; `TimingBook` holds two
   builds); the file is numbers-only JSON in the app's container, written on its own utility queue 20 s after the
   first unsaved change and at backgrounding; the test host never persists. CastleRules carries no rule a
   numbers-only side file meets. Instrument-fidelity notes are finding 8.
2. **Speed claims carry numbers — SOLID.** The BEFORE and AFTER tables give median and range, n = 5, the simulator
   and the machine's load named; batch 4's and batch 7's headless figures are marked Mac numbers; batch 5 says
   plainly that one page fetch is not faster. The one over-claim is a cost SHAPE, not a number (finding 5).
3. **VM-2's roads — answered, with one new hole.** Every edit the gate is asked about is refused and said; every
   gate-less edit to a block's text is withheld, the tiling kept, the page re-read before the fence drops; no key
   is dropped unsaid. Open: the settle rule's in-flight-read window (finding 2), the tail's timer road (VM-226,
   ticketed), autocorrect and dictation on a device (her sitting). The Insert Below exemption's trace is right
   (`newBlock` rewrites no text; the flag is set after the "already landing" guard, so a refused Insert Below
   cannot unfence another door's flight).
4. **VM-67 — SOLID.** The probe and the UPDATEs share one writer access, so nothing can land between them; the
   predicate, the call sites and the occasions are unchanged; `0e9948d03` is the schema alone (the migration and
   its two index-set pins), ahead of the op at `e6d16fca7`; `git diff --name-only` over
   `Sources/VariorumCore/Sync` and `Server` is empty; SyncSpec §2 and §12 read in full — a local partial index
   moves no mirror table, column or classification, and the marker stays 15. The suite ran green here.
5. **VM-68 — one MAJOR, two MINOR.** A held read is still ∝ the notes in two unstated cases (finding 5). No note
   is UNREACHABLE by scrolling — the inverse fails instead: a row can stay listed after its note is deleted
   (finding 1), and a wing switch can draw the old wing's Bookless rows for one read (finding 3). The Mac's
   Library did not change: both statements are pinned byte-identical against frozen pre-change builders, and
   those pins ran green here.
6. **VM-69 / VM-70 — SOLID.** The load is the observation's first value and the stream is held open until
   `start()` takes it (unbounded buffering; the writer-held guard reads the widest window); a re-arrival's first
   value takes the delivery arm; the chrome's one pass covers every apply arm and the arms that touch nothing
   still get theirs; the release is the leaving's last act, drops only a clean entry with no holder, and is
   balanced on every road I could construct (first arrival, re-show after and before the give-back, a double
   cover, a twin that never arrived, two tabs on one note). P3's one live editor is untouched. Residual: VM-227,
   with finding 7's addendum.
7. **VM-71 — the lock did not move, and no savepoint is skipped beyond round 1's accepted gap.** The diff holds no
   line of `MobileRelock.swift` or `MobileShellRouter.swift`; `AppBootstrap.swift`'s is two timing marks. Every
   caller lands its own writes before it asks (teardown waits out the tail's mint — `awaitMintSettle` loops until
   the mint ends, it is not time-bounded), the candidates read is a byte-superset of the op's own test, and the
   narrowed op re-checks each take in one transaction on one clock read.
8. **The Mac unchanged; brains placed right — SOLID.** The Mac's `savepointOnLeaving` statements are the same
   statements in the same order (compared against `eb18888db`: the two inner guards collapsed into one outer
   `#if`, nothing else); `closeAutoCommit(_:)` is untouched; the new Core APIs have one caller; every Shared mark
   is inert there; `adoptOwnerID`'s no-write-when-nothing-is-unowned applies to the Mac too and is recorded.
   Brains sit in Core (`Diagnostics/`, `Domain/StructuralFlightFence`, the two queries, the narrowed op) and
   `Shared/` (the catalog); the phone owns faces.

## Clean bill (load-bearing things specifically checked and found solid)

- **Round 1's fixes, in the code.** `TimingRecorder.end`'s `kept` rule arm for arm (a no-op `endIfOpen` tells the
  handler nothing; an unmatched end, a stale drop and a recorded sample each tell it once); `surfaceSettled()` a
  query; `takeAutosaveHold`'s re-observe after the re-acquire on both paths, the adopt branch stopping the old
  token before it observes the new coordinator; the re-made error hook speaks the same road `init`'s does
  (`reportOperationError` is `report(OpsRefusalCopy.sentence…)`); finding 1's comments name the one-ask gap and its
  bound, and the guard test holds it.
- **The merge's two conflicts.** `holdFirstPage` carries its catch (H3's trap closed); all four of batch 5's raw
  error lines speak `OpsRefusalCopy.sentence(for:roads:)`; VM-55's `follow` is gone from the listings and the hold
  key carries the wing; a superseded `prime` that had already finished lands before the new wing's, never after;
  `holdLibraryAsItsViewDoes` is the view's road (the key under observation tracking, the hold restarted on each
  change).
- **`leavingSavepointCandidates` ↔ `closeAutoCommit`.** The same join and filters as `autoCommitDirtyVariants`;
  `IS NOT COALESCE(last savepoint, '')` equals `isDirty` on both of its arms, as a byte superset; the gone,
  sealed and cadence gates are the op's.
- **`adoptOwnerID`.** `writeWithoutTransaction` is the wrapper's own door (a locked store refuses exactly as
  `write` did); the report's shape is preserved; the UPDATEs still enqueue their outbox rows by trigger.
- **The fence on its ordinary road.** The door's own settle re-reads the page before the latch drops, so the
  landing check is honest wherever that settle applied; the two-latch rule (structural and undo) never drops the
  other's fence; a forced render under a delivery keeps its flag for the fresh read (the shared policy's
  precedence); the gate belt disarms the arming it refuses.
- **The Library's paging machine, apart from finding 1.** Generation and question guards on every landing; the
  single-flight follow and its cancel on the hold's end; `wantsMore` kept until a page appends; the union's
  withheld books; `sort_key` non-null in every arm.
- **The leaving's read against the lock.** A leaving that meets the closed store returns on `StoreLockedError`; a
  read already in flight when the binding locks is waited out by the pool's close, as any in-flight read was
  before this run.
- **Process.** No `Co-Authored-By` or session trailer in the range; no device identifier in the record; the shared
  ledgers untouched on the branch; the ladder-cap change matches her recorded words in CLAUDE.md, both skills and
  ProcessHistory; VM-226, VM-227 and VM-232…237 minted with their evidence labels.
- **P1 across the diff.** Nothing added scales with the corpus on a write road: adoption ∝ the unowned rows, the
  leaving's read ∝ the note's takes on a reader, the fence and the timing layer O(1). The read-side exceptions are
  finding 5's two cases, neither new. Nothing tracks word-level change; nothing copies text across entities.

*(Finding 1 is new and is the round's MAJOR. Findings 2 and 3 are new. Finding 4 is round 1's condition and gate,
still open. Findings 5 and 6 are record and document corrections. No finding touches `Sources/VariorumCore/Sync/`;
none is marked FINDER-FIXES at this stage — the final calls follow the implementer's responses.)*

---

## Implementer responses (round 2 fix pass)

*The round-2 fix pass's implementer (Opus, fresh, cross-model flow): one entry per finding and one for O-1, written
before any code and pushed first. Each says agree or dispute with its ground; the reviewer makes the final call on each.
Line numbers are at `85762803a`. The pass's own record is the run record §5 ▸ "Ladder round 2 — fix pass" and §7 ▸
"Ladder round 2 — fix pass". "Applied" below means applied in this pass's first turn, with its pin; everything hosted is
PENDING the orchestrator's stage.*

### 1 · [MAJOR] a deleted (or Put back) note past the first page — AGREE; the delete leg and the ★ leg applied this pass; the Put back leg needs a seam the brief's fence forbids me to cut — arms below, (A) recommended, waiting for the final call

**Traced on today's code, as written.** `holdFirstPage` (`MobileLibraryViewModel.swift:499-521`) observes only
`read(db, question, after: nil, limit: listingLimit)`; `AppDatabase.observe` ends in `.removeDuplicates()`
(`Persistence/AppDatabase.swift:266-269`); the row's door `confirmDeleteNote` (`:814-832`) runs `deleteContainer`, whose
`tombstoneNoteFamily` writes `deleted_at`/`updated_at` on the note and its versions only
(`Operations+Container.swift:694-718`). A row at index ≥ `listingLimit` therefore leaves the first page byte-identical:
the observation re-fetches, delivers nothing, `followFirstPage` never runs, and `all`/`bookless` keep the row. The Put
back is the same hole reversed: `MobileLine.swift:123-126` → `putBack` (`:141-150`) → `restoreContainer`
(`Operations+Container.swift:748-805`), which clears the tombstone and stamps `updated_at` and moves none of the four
phone sorts' keys, so a deep note's return leaves the first page unchanged too. Confirmed: before VM-68 no row past 200
was listed, so the hole is this run's.

**Every act the phone's Library rows and its message line can take, and whether it re-asks** (the brief's enumeration):

| Act | What it can change past the first page | Re-asks the shown listing? |
|---|---|---|
| A row's tap — the note opens on the Library's own stack | the Library is hidden while the note shows (`libraryOnScreen` needs `libraryPath.isEmpty`) | not needed — the return's first delivery re-asks the listed depth (`holdFirstPage` → `followFirstPage` when deeper than a page); anything done in the note is behind that |
| A row's long-press ▸ Delete, confirmed | the note leaves All/Notes and Bookless | **YES — applied** (`confirmDeleteNote`, after the op lands) |
| A row's long-press ▸ Star / Unstar | **All and Notes: nothing** — they list every note whatever its stars or books, and no phone sort key is a star's. **Bookless: the loose class moves** where a ★ gathering exists (it now shows, or stops showing, the note) or a living book's rule carries a ★ term (intake seats the note: it gains a home) | **YES for Bookless — applied** (the row's star button, after `stars.toggle` lands, tells the model — `rowStarLanded()`); All/Notes not re-asked |
| The line's Undo after a NOTE's delete (Put back) — the row's door, the note's ⋯ sheet (`MobileEditorViewModel.swift:1582`) or Versions (`MobileVersions.swift:232`) — pressed while the Library is on screen | the note returns to All/Notes and, if loose, to Bookless | **needs the seam below — NOT applied** |
| The line's Undo after a BOOK's delete (`MobileShelfViewModel.swift:208`, `MobileBookDetails.swift:165`), pressed while the Library is on screen | Bookless: the book's members regain a home and leave the loose class. (All's books come from the Shelf's own held, unbounded observation — it follows by itself) | the same seam — one `putBack` body serves both arms of the line |
| The line's Unarchive (`.unarchiveBook`, the daily Journal's archive) | nothing a listing shows (an archived book still homes its notes; the phone's archive is plain `archiveReading`) | no |
| "+ new note" | mints and pushes the note — the Library is hidden; the return re-asks | not needed |
| 🗑 Trash, the Archived row | pushed rooms on the Library's stack (`MobileShellView.swift:266-267`) — their Put back / unarchive land while the Library is hidden; the return re-asks | not needed |
| The filter, the sort, the wing | a new question: its first page | not needed (the wing: finding 3) |
| Search | while hits show the listing is not drawn, and hit rows carry no act | not needed |
| Not on the phone's Library rows today: archive, a move to another wing, a rename (and no title sort), a filing into a book | — | — |
| **Not the Library's act:** a sync apply that tombstones, revives or re-homes a note past the first page while the Library is on screen | the same shape | **no — outside this finding's class.** The Mac's catalog has the same exposure (its follow is the held 200-window's membership, `LibraryViewModel.swift:85`); a ticket body for it is in my report |

**The re-ask as built (the reviewer's shape):** after the act lands, the SHOWN listing is re-asked at its listed depth
through the existing single-flight road (`followFirstPage(question)`) — only when it is deeper than one page (inside the
first page the held observation already answers), only for the question it last landed (a newer question's own first
landing answers otherwise), and only while that listing is held (a new `holds` count on its paging state, raised and
lowered by `holdFirstPage`; hidden, the return re-asks anyway). ∝ the listed rows, one statement per act (P1) — the
Mac's `refresh` rule. **One correction to the reviewer's pin text:** "stays 7 deep" — the follow re-reads the LISTED
depth (`reread`, `:546`: `max(listingLimit, rows.count)`), so after one of 8 rows is deleted the listing is 8 deep again,
the next note moving up — the Mac's `refresh` (`max(Self.pageSize, noteHits.count)`, `LibraryCatalogModel.swift:800`).
The pin asserts that: the deleted note gone, 8 rows, `Queries.library`'s first 8.

**The Put back leg — the choice.** The line's Undo is built inside VM-55's `MobileLine.action(for:)`, and nothing about a
landed Put back is observable to the Library: the op runs through `session.runner` (no landed hook,
`Shared/OperationsRunner.swift`), a landed Put back says nothing (P-55-4, `MobileLine.swift:139-141`), and the store
change does not move the first page. The brief fences `MobileLine` ("read it, call it, do not change it"). Arms:
- **(A) RECOMMENDED — one line in `MobileLine.putBack`:** after a landed Put back, post a phone-local notification (the
  Mac's own `.variorumNotesDeleted` precedent, `Variorum/Features/Library/NoteDeletion.swift:192, 235`), its object the
  session; the Library re-asks its shown listing on it while held (inside the hold, the same `reaskAfterRowAct`). It
  covers EVERY Put back through the line — the row's, the ⋯ sheet's, Versions', a book's — with one road and no second
  spelling. Cost: one line (and the notification's name) in VM-55's file — the fence lifted for that line.
- **(B) the Library speaks its delete line itself** — `session.status.removal(…, undo:)` with its own action
  (`restoreContainer`, the refusal words, then the re-ask). No VM-55 line; but it covers only the row's own delete (the
  ⋯ sheet's and Versions' Put back stay un-re-asked while the Library shows), and spells the Put back road and its
  refusal a second time beside `MobileLine`'s — the drift class VM-61 retired.
- **(C) a held witness** — while on screen the held fetch also reads the liveness of the rows that recently LEFT the
  listing (∝ that set) and a revival re-asks. No VM-55 line; covers every Put back road and a sync revival, but not a
  note that newly turns loose; a bounded set to design and the held read's shape to widen — more machinery than the
  finding asks.
The pin is the same under every arm (the reviewer's second arm): delete a deep row, press the line's own Undo
(`session.status.current?.action?.perform()` — VM-55's own pin's road, `MobileMessageLineTests.swift:470`), and require
the row listed again in its place. RED on this tree and on this pass's tree; it lands with the arm in the second turn.

**Pins applied this pass:** `MobileLibraryPagingRulesTests.aRowDeletedPastTheFirstPageLeavesTheListing` (old API only,
so it is in the red build; red-on-old expected: the deleted note still listed after the settle) and
`MobileLibraryRowActsTests.aStarThatTakesADeepRowOutOfTheLooseClassReAsksBookless` (a ★ gathering, 12 loose notes,
Bookless 8 deep, row 7 starred: it leaves Bookless; it names the new door, so it lives in its own file, which the red
build moves aside — batch 5's recipe — and it is a DESIGN pin of the same road, whose red-on-old is the delete pin's).

### 2 · [MINOR] the settle rule reads "settled" while the settle read is in flight — AGREE with the hole; the one-fact shape as specified would fence her ORDINARY road; NOT applied (the brief's condition: it needs more than that one fact) — rides VM-226

**The hole, traced, as written.** `applyPendingIfClean` (`:1163-1202`) nils the marker at `:1174` before its read; the
settle rule (`flightSurfaceHoldsTheStore`, `:1327-1330`) reads only the marker and `forceFullRender`; the projection
hook (`:1048-1050`) and the settle loop (`:1344`) both drain on it. Both of the reviewer's paths are real (the mint's
finish reaches `host.applyPendingIfClean()` through `finishMint`'s arms, `Shared/EditorBrain/TailCrystallizer.swift`),
and both need a mint inside a flight — VM-226's road.

**Why the specified fix is wrong as written — the ordinary road, traced.** Every fencing door renders the post-act page
with its OWN settle before its latch drops (`refreshTakesFromStore` then the `defer`, `MobileStructural.swift:115/226`,
`:250/347`, …). In the app the editor's live observation runs (`start()`), and it delivers the op's commit. When that
delivery is consumed BEFORE the door's settle ingests — the likelier order in production: the observation's fetch
starts at the commit, the door's read only after the runner hop back — the page is still pre-act, clean (the flush
landed) and non-matching, so the policy answers `.refetchFresh` (`EditorProjectionEngine.swift:157`) and
`applyPendingIfClean` takes the marker and starts a re-read. The door's settle then renders the post-act page and drops
the latch WHILE that re-read may still be in flight. Today the landing reads "settled" and drains — **correctly**: the
page holds the post-act store (the door's own fresh read put it there). Under the one fact "raised where
`applyPendingIfClean` takes the marker, lowered when its task ends", the same landing reads "not settled", the fence goes
to `.settling`, and a key she types in the next read's time is REFUSED and "Another structural change is still
landing." is said — on an ordinary divide with no mint anywhere; on the 100k note that window is one whole-projection
read. **No existing pin would see it**: no fence pin's model starts its live observation (`makeSurfaceEditor`,
`MobileMarkdownTests.swift:29-41`, calls `loadOnce()` only), so the suite would stay green over the regression.

**What the precise rule needs:** the in-flight read may count only while no fresh, non-delivery apply has rendered
since the marker was taken — the fact lowered also by every render arm of a non-delivery apply (or an epoch pair:
deferral vs render). That is a second fact or a second lowering site, beyond the brief's condition, so **nothing is
applied**; `MobileEditorViewModel.swift` is untouched by this pass. Proposed for VM-226 (one pin-first session for both,
the reviewer's own alternative): the reviewer's pin (the marker taken, the read parked on the held queue, the readable
fact raised until it lands; the fence arm: the latch dropped while it is parked must not drain — today's
`structuralFlightChanged` drains synchronously at `:1318`, so that arm is deterministic, but it needs a real door, since
`structuralInFlight` is `private(set)`), PLUS an ordinary-road GUARD in a world whose model runs its live observation:
after a divide whose delivery's re-read is still in flight when the door's own settle has rendered, a typed key is
approved (green today; red under the one-fact shape). `hasDeferredProjection` keeps its meaning either way —
`MobileDeferredProjectionRetryTests.swift:77` asserts it clears before the re-read.

### 3 · [MINOR] after a hidden wing switch, Bookless draws the previous wing's rows for one read — AGREE; applied as proposed, plus the union's books withheld while the notes answer another wing

**Traced as written** (`hold(_:)` `:462-469` returns at `guard hold.onScreen` with `bookless`, `booklessLoaded` and
`booklessWingHasNotes` still the old wing's; the body renders `visible` before the task restarts). **The same hole
elsewhere, checked:**
- **The notes listing:** primed in the new wing on the hidden switch (`hold(_:)` `:463-466`), so at the return it
  normally answers the new wing — UNLESS the return comes within one read of the switch: the return's restart cancels
  the hidden prime mid-read (`CancellationError`, nothing lands) and `all` still names the old wing until the held
  page's first delivery. Rarer; the same gate covers it.
- **A filter change:** Bookless opened after a switch made while All showed — its rows still name the old wing. The
  same hole by another trigger; covered (the second pin).
- **A sort change:** a new question in the same wing — the previous sort's rows, of the right wing, for one read, as
  before VM-68 (`observeLibrary` restarted then too). Not a wing leak and NOT gated (gating it would blink the listing
  empty on every sort change).

**Built:** `landedWing` — the wing each listing's rows answer, OBSERVED (the `Paging` class is not, and a landing that
moves only the wing — two empty listings — must still redraw), set in `land`. `visible` and `emptyListing` return
nothing for a listing whose landed wing is not `session.wing.readScope`; a never-landed listing keeps today's rules.
One addition to the reviewer's text, said: `rows(books:)` also withholds All's BOOKS while the notes answer another
wing — otherwise the new wing's books draw alone for that read and then re-position as the notes land (P-68-4's
"nothing jumps"). **Pins** (old API only, in the red build): `MobileLibraryPagingRulesTests.aWingSwitchedWhileBooklessWasNotHeldDrawsNoOtherWingsRows`
(the reviewer's: red-on-old `visible == [homeNote]`; plus no empty line meanwhile and Work's row on the return — guards)
and `…aDoorOpenedAfterAWingSwitchDrawsNoOtherWingsRows` (the filter-change trigger: red-on-old `visible == [homeNote]`).

### 4 · [MINOR] the merged tree's hosted evidence — the orchestrator's.

One line: the 14:43–14:51 window settles round 1's finding-2 condition (red at exactly the two named expectations on the
hunk-reversed build, 5 of 5 on the fix, the merge-touched 38 types green in one host); the merge gate and the walk stay
the orchestrator's, and this pass adds lines (findings 1, 3, 8(a), 9, O-1) that the final tree's gate covers.

### 5 · [MINOR] "bounded" over-claimed in two cases — AGREE; the three sentences corrected

Confirmed in the code: `.createdAt`, `.entryDate` and `.lastMajorRevision` take `catalogNotesPage`'s single arm with no
index on the key (`LibraryPaging.swift:241-243`; its header `:22-30` says so of the Mac); the edited sort's touched arm is
`INDEXED BY idx_container_touched` (`:216-227`), an index over every live container, so in a wing holding fewer notes
than a page `LIMIT limit + 1` never fills and the walk reaches the index's end, fetching each row to test kind, archive
and wing. Corrected in place, first text legible: the record's batch 5 cost table (the "On screen" cell) and its floor
paragraph's scope, the handoff's "Rulings reconciled" row, the AppSpecRecord draft's VM-68 paragraph, and the same
over-claim in the drafts' residuals row 23. No pin (a cost shape, red on the old code too). The ticket's body is in my
report.

### 6 · [MINOR] four statements false on the merged tree — AGREE; corrected

The drain's `report(…, action: statusAction)` reaches `MobileLine.say(…, as: .refusal, door: undoDoor)`, which withdraws
the note's standing Undo line and draws a refusal with no action (`MobileLine.swift:72-95`) — for every door, not only
the removal-class ones (a divide's own receipt is an ordinary act the line never draws). Corrected: the handoff's P-2-1
and P-2-2 (P-2-2 now carries "the fence's sentence meets the one message line" with its three options in plain words,
left at (a)); the drafts' bundle (P-2-1's clause; P-2-2 rewritten with (a)–(c)); the drafts' SurfaceContracts fence line
narrowed to the reviewer's guarantee ("an edit the gate is asked about, or that reaches a block's text, is never written
toward the store during a flight") and the Undo clause corrected. Also corrected, the same false clause: the r2
closeout's "What each input gets" paragraph in the record ("with the door's Undo/Redo kept beside it"), marked in place.

### 7 · [NIT] VM-227's body — AGREE; the paragraph is in my report (Linear is the orchestrator's).

### 8 · [NIT] two readout pitfalls — (a) AGREE, applied with a pin; (b) the caveat, not the code

**(a) traced:** `open()` (`MobileQuickNote.swift:891-897`) begins both Open spans (`AppTiming.boxOpenPressed`,
`Shared/AppTiming.swift:207-210`) and, when `file()` hands back nil (an empty box, a refusal, a withdrawal), nothing
cancels them, so the next `notePainted()` or `keyboardUp()` inside 30 s records a long, false sample. **Built:**
`AppTiming.boxOpenFiledNothing()` cancels both (the recorder's existing `cancel`), called from `open()` when `file()`
returns nil. **Pin:** `MobileBoxOpenTimingTests.anOpenThatFilesNothingLeavesNoOpenSpan` — Open on an empty box, the box's
task finished, then `AppTiming.notePainted()` and `AppTiming.keyboardUp()`: neither series gains a sample and neither
span is open (red-on-old: both spans still open, and each gains one sample). Hosted; it reads the process's one recorder
— reliable because the host runs Swift Testing serially (O-1), said in its header.
**(b) the caveat, and why not the code:** closing the window at `noteLeft` is right only when a NOTE's leaving opened it;
a backgrounding opens the same `.keepFirst` window and must keep counting through the removed screens' own leavings (a
Castle backgrounding's lock teardown — the 3 → 1 series batch 7 is judged by), and the brain's window does not record who
opened it. Closing it honestly needs an opener in the brain's window API plus an app-side rule, pinnable only hosted
(`Shared/` is not in the Core package) — not a few lines, and a slip moves the Castle series' meaning. Written instead:
the handoff's readout step ("leave about ten seconds between the two leavings") and a bracketed note on the row in
batch 1's "what each number means" table.

### 9 · [NIT] three small things

`print` → `fingerprint` (`MobileTiming.swift:61`). **The header:** the readout ALONE forces capitals on screen — its
title line is `title.uppercased() — heading.uppercased()` (`MobileTimingView.swift:146`), drawn as the first line of the
sheet; the sibling edit trace's SCREEN draws its headline in mixed case (`MobileEditTrace.swift:475-493`, shown at
`:560-564` — its upper-case "VARIORUM EDIT TRACE (E1)" is only in the COPIED transcript), and Settings' "Diagnostics"
header is a plain `chromeLabel` (`MobileSettingsView.swift:264`), not a list style. So the two `.uppercased()` go (the
words stay as drafted, for her wording pass); `MobileTimingTests`' three expectations follow. The recorder: no change.

### O-1 · the perf suite must run alone — AGREE; gated

**Confirmed by reading:** the scheme's `parallelizable = "NO"` (`VariorumMobile.xcscheme:34`) is written into the built
xctestrun as `InProcessParallelizationEnabled = false` for `VariorumMobileTests` (`DerivedData/vm64-gate/…/VariorumMobile_VariorumMobile_iphonesimulator27.1-arm64-x86_64.xctestrun`,
read with `plutil -p`). Swift Testing parallelizes within one process (Apple's "Parallelization" page); no Apple page
names this key's effect on it (an external lookup found none — one user report ties the key to serial Swift Testing
runs, and the probe's one-after-another order agrees). So yes: that flag is what keeps this host serial, and it is the
only thing — nothing in the suite or the tree stops a whole-target run from including it, or a later suite's leftovers
(a late leaving's savepoint mark, a debounced save, a model still alive) from landing in its windows when it runs after
others. **Built:** `.enabled(if: ProcessInfo.processInfo.environment["VM66_PERF"] != nil, …)` — the
`ShortcutsTabCaptureTests` precedent (`TEST_RUNNER_VX677_SHOTS`); the display name says "gated:
TEST_RUNNER_VM66_PERF=1 — it runs alone"; the header's mechanism sentence corrected to the probe's facts; the skip's
comment says how to run it; every place that tells a reader how to run it corrected (the record's batch 3 group (i) and
the merge-in closeout's (iii), the handoff's "The next runs", the drafts' MobileSoul sentence and PR line, and the
drafts' VM-66 paragraph). **A better shape without production changes:** none I can see — the suite already reads
deltas against snapshots, and no test can stop another suite's late task from counting into the one recorder. No pin
beyond the probe: the stage pieces are a whole-target run that SKIPS its 13 (Swift Testing counts skipped tests in "N
tests … passed" — read the skipped lines) and the gated run alone, 13 passed.

## Final calls (reviewer)

*The round-2 reviewer, same session, after reading the implementer's responses (`35551e25f`), every commit of the
fix pass in the code itself (`64af6d64a` · `6b6c288b1` · `28dc98ac5` · `c42078746` · `f45d25498` · `8eeafb614`), its
closeout (§7 ▸ "Ladder round 2 — fix pass", `980c784a1` · `3b8dc24cb`) and the merged tree's stage window
(`3dcafa735`, checked against its local logs `notes/plans/vm64-screens/mg-*.log`). One call per finding, and one for
O-1. **Every call below is on the code AS READ:** a QUIET window holds this Mac, so none of this pass's app-target
lines has been compiled and none of its pins has run; "confirmed as applied" means the lines do what the finding
asked when read, and each stays conditional on its named run. Nothing here touches `Sources/VariorumCore/Sync/`.*

**Finding 1 (a row acted on past the first page) — CONFIRMED; the delete and ★ legs AS APPLIED; the Put back leg:
APPLY ARM (A).**
*The two legs applied.* `reaskAfterRowAct` is the fix I asked for, with the right guards: it re-asks only a HELD
listing (the `holds` count is the honest form — `.task(id:)` starts the next hold before the last one's `defer`),
only the question its rows answer, only deeper than a page, through the one single-flight follow. The enumeration of
every Library-row and line act is the work a MAJOR deserves and I accept its verdicts (All and Notes are not moved
by a ★; Bookless is). **The implementer's correction to my pin text is right and I adopt it:** the follow re-reads
the LISTED depth, so after the delete the listing is 8 deep again with the next note moved up — the Mac's `refresh`
rule — not "7 deep". The delete pin as written (the doomed note gone; `model.all` equal to `Queries.library`'s first
8) is the pin.
*The Put back leg — arm (A).* (B) spells the Put back road and its refusal a second time and covers only the row's
own delete; (C) widens the held read to answer one act. (A) is one signal for every Put back the line can make,
and it is the Mac's own shape (`.variorumNotesDeleted`: a signal posted after the writes land, the catalog's view
re-asking on it — `LibraryCatalogView.swift:426`). What lands, exactly: **(i)** in `MobileLine.putBack`, ONE line
after `try await session.runner.run(body)` returns — a phone-local notification, its object the session, posted on
the success path only (a refused Put back posts nothing; `unarchive` is a different function and posts nothing,
correctly — an archived book still homes its notes). The notification's name is declared with its listener, not in
`MobileLine`, so VM-55's file gains that one line and no more. **(ii)** the Library listens only while its view is
mounted (the view's `.onReceive`, or a listener inside the hold — the implementer's choice), accepts only its own
session's signal (object identity), and answers by re-asking the SHOWN listing through `reaskAfterRowAct` — so every
guard above applies and a Put back inside the first page stays the held observation's. No second spelling of the
op, the refusal words or the line. **(iii)** `MobileLine.swift:139-141`'s comment ("the row is back on the page")
becomes true again past the first page and needs no edit. **The pin must hold:** `MobileLibraryPagingRulesTests`'
world (limit 4, 12 notes, held on screen, 8 listed); the seventh row deleted through `confirmDeleteNote`; settle
until it is gone; then the line's OWN Undo pressed (`session.status.current?.action?.perform()` — it must be
non-nil); settle; the note is listed again and `model.all` equals `Queries.library`'s first 8, no note twice. It
names old API only, so it joins the red build: RED there and on this pass's first-turn tree (the row never returns
while the hold stands), green with (A). The (A) hunks join the reversed set of `vm64-gate2-red`.
*Conditions, for the next reader:* the red-on-old run shows the delete pin red at its two expectations and the Put
back pin red; both green on the fix build alone and in company; the ★ pin green (a design pin — its red-on-old is
the delete's, said so in its header, accepted).

**Finding 2 (the settle rule reads "settled" while its read is in flight) — the hole CONFIRMED; my fix shape
WITHDRAWN on the implementer's dispute; DISMISSED from this pass to VM-226.** I rechecked the dispute in the code
and it is right. On the ordinary road in the app the op's commit delivery is consumed while the door's own settle
read is suspended; it is clean and non-matching, so the policy answers `.refetchFresh` and `applyPendingIfClean`
takes the marker and starts a re-read; the door's settle then renders the post-act page and drops the latch with
that re-read still in flight. Today the landing drains — correctly, the page holds the store. Under the one fact I
specified it would read "not settled", and a key typed within one read of an ordinary divide would be refused and
the sentence said; on the 100k note that is a whole-projection read after every structural act. And no fence pin
would see it: none of their worlds starts the editor's live observation. A fix that over-fences her common road to
close a rare one is the wrong trade, and the precise rule needs more than a few lines at the editor seam.
**VM-226 must carry, in its body:** (1) the hole as traced (this file's finding 2: `applyPendingIfClean` clears the
marker at `:1174` before its read lands; the settle loop's check at `:1344` and the projection hook at `:1048`
drain on it; the road needs a tail mint inside a flight — the ticket's own road); (2) the shape that is WRONG and
why (one fact raised where the marker is taken and lowered when the read ends — the responses' ordinary-road
trace), so no later session re-proposes it; (3) the rule the fix needs: an in-flight settle read counts against
"settled" only while no fresh, non-delivery apply has rendered since the marker was taken — its shape (an epoch
pair, or a second lowering site at the render arms) is that session's to design, pin first; (4) three pins: the
hole (a real door's flight whose own settle is deferred behind a mint, the marker taken and the read parked on the
held store — the fence must not drain; red today), the ordinary-road GUARD (a world whose model runs its live
observation: after a divide whose delivery's re-read is still in flight when the door's settle has rendered, a
typed key is approved — green today, required green after), and the ticket's original idle-clock pin; (5) the
coverage fact, first on that session's list: no fence pin's world runs the live observation
(`makeSurfaceEditor` calls `loadOnce()` only), so every delivery-inside-a-flight ordering is unpinned today; (6) it
is editor-seam work — a Fable cold review. The ticket's title should name both roads (the idle save's stale write,
and the fence dropping before the page has re-read). Severity stands MINOR; status OPEN under VM-226. The
handoff's VM-226 line in "What was found and not fixed" gains the second road in plain words. No line of
`MobileEditorViewModel.swift` changes in this pass — correct.

**Finding 3 (another wing's Bookless rows after a switch) — CONFIRMED AS APPLIED.** `landedWing` is set where the
rows are replaced, is observed (the two-empty-listings case redraws), stores a nil scope as a value, and gates the
three readers a face has: `visible`, the empty line, and All's books. I checked the claim that nothing else draws
the rows: no view reads `all` or `bookless` directly — every face goes through `visible` / `rows(books:)`. The two
additions are right and I adopt them: the filter-door trigger (the same hole by another road, with its own pin),
and All's books waiting with its notes (drawn alone they would re-position as the notes land — P-68-4's own rule;
display for one read, not a product call). Not gating a sort change is right (same wing; gating it would blink the
list on every sort). One consequence, accepted and said: if a wing's first read FAILS, that listing now draws
nothing where it used to draw the old wing's rows — the refusal is on the line, and nothing is the honest drawing.
*Condition:* both pins red on `vm64-gate2-red` at the expectations the closeout names, green on the fix; VM-55's
five wing types green in company (they settle with `eventually`, so the brief blank cannot fail them — to be
shown, not assumed).

**Finding 4 (the merged tree's hosted evidence) — round 1's condition on finding 2 is MET; the gate stays open.**
Read from the logs, not the record: `mg-hold-red.log` — 5 tests in 1 suite failed with 2 issues, both in
`aScreenShownAgainBeforeItsLeavingFinishedListensToItsCoordinator`, at `MobileNoteHoldTests.swift:227` and `:234`,
the two `observesAutosave` expectations round 1 named; `mg-hold-green.log` — 5 of 5 passed; `mg-merged38.log` — 234
tests in 38 suites passed with the hold suite in company, VM-55's four re-landed Library pins, the hidden-switch
guard and the raw-error scan among them. That is red on the hunk-reversed build, green alone and green in company:
finding 2 of round 1 is closed. What finding 4 still holds open, all the orchestrator's: this pass's first compile
and its red-on-old and fix runs (`vm64-gate2-red`, `vm64-gate2`); the whole phone target and the whole Mac target
on the final tree; the whole Core package once on the final tree; the batches 6 + 7 walk.

**Finding 5 ("bounded" over-claimed) — CONFIRMED AS APPLIED.** The cost table's cell, the floor paragraph's scope,
the handoff's row and the two draft sentences now say which sort and which wing shape is a bounded seek and which
grows with the store's notes, with the first text left legible. The ticket: ONE, Debt · Confirmed · Performance ·
Low, a candidate member of VM-176, naming both cases (the three non-default sorts' top-N pass; the edited sort's
walk to the index's end in a wing smaller than a page) and that an index for either is a local schema change of
v1_38's class, hers to schedule.

**Finding 6 (four statements false on the merged tree) — CONFIRMED AS APPLIED, with one clause still to scope.**
P-2-1 and P-2-2 in the handoff and the bundle now say what her phone does (the refusal wins the line; the Undo is
in the ⋯ sheet; P-2-2's three options in plain words), the draft contract line claims only what the fence
guarantees, and the r2 closeout's paragraph is marked in place. Still over-claiming, in the same handoff bullet:
"Nothing old is ever written" — scope it to the keys the bullet is about (a key refused or held back this way never
writes old text), since VM-226's two roads stand open and are listed further down the same file. A record edit,
the orchestrator's or the implementer's.

**Finding 7 (VM-227's body) — CONFIRMED.** The paragraph goes into the ticket at the merge beside round 1's trace:
in the unobserved state a deferred marker is never cleared, so the next structural act can leave every key refused
until the note is reopened. It stays labelled as traced by reading, not staged.

**Finding 8 (two readout pitfalls) — (a) CONFIRMED AS APPLIED; (b) the caveat ACCEPTED in place of the code.**
(a) `boxOpenFiledNothing()` cancels both spans exactly where `file()` hands back no note; the pin reads the two
series before and after a paint and a keyboard rise, and its guard keeps a filing Open timed. *Condition:* red on
`vm64-gate2-red` (both spans open, a false sample each), green on the fix. (b) The reason given is right and I
checked it: the same keep-first window is opened by the app's backgrounding and must keep counting through the
removed screens' own leavings (two mounted notes under Castle would be cut at the first one's `noteLeft`), and the
window does not know who opened it — closing it honestly needs an opener in the brain's window API, which is more
than a NIT earns and puts batch 7's Castle series at risk. The handoff's "leave about ten seconds between the two"
and the bracketed note on the table row are the fix.

**Finding 9 (three small things) — CONFIRMED AS APPLIED.** The rename; the heading drawn as drafted, with the
finer reading than mine (the edit trace's SCREEN is mixed case; only its copied transcript is capitals); the three
test expectations following and one holding the title not upper-cased. The recorder unchanged — correct.

**O-1 (the speed suite gated behind a switch) — CONFIRMED AS APPLIED, on two conditions and one ticket.** The
reason is sound: the suite's oracle is the process's one recorder, and in a whole-target run its order among the
other suites is not its own to choose; the probe showed company run serially with this suite first, never the
case that matters (run after others). The gate itself is right as built (`.enabled(if:)`, the display name, the
skip's words, the header corrected to what the probe showed). But judged as a fix it has a cost the responses do
not name: **the gate takes bug-class pins out of every ordinary run.** Read against the suite's assertions: the
savepoint counts have a company-safe twin (`MobileLeavingSavesOnceTests`), registry growth has two
(`MobileNoteOpenOnceTests`, `MobileNoteHoldTests`), owner adoption has Core's; but **"a note is read once per
open" — VM-69's headline, 2 → 1 — is asserted nowhere else** (`MobileNoteOpenOnceTests` pins the chrome and the
chips, not the projection read), and the SHELL's hidden-Library zeros (the wiring that hands `isOnScreen` down) are
pinned only here too. *Condition 1 — the gate's legs:* this run's merge gate has three phone-side lines, each
recorded with its counts — the whole target, saying in words "13 skipped (the gated speed suite)", never folded
into "passed"; the gated suite alone, 13 passed, none skipped; and the round's own red and fix runs — and the
drafts' MobileSoul sentence gains the clause that a phone merge gate runs the gated suite as its own leg, so the
next run's gate does not read a skip as a pass. *Condition 2 — one company-safe GUARD, test-only, this pass's
second turn:* in `MobileNoteOpenOnceTests`, by its existing statement trace on the world's one connection, an open
through the hosted screen runs the note's projection read exactly once between mount and the first live delivery;
with a second arm in the same test that drives the harness's old shape (`loadOnce()` then `start()`) and counts two
— so the oracle is shown to tell one from two in the same process. What is counted is the open's OWN road (the
arrival's load and the live updates' first fetch — one read, not two); if the pin's mount makes the liveness grant
owe a re-read of its own, mount without that or count it apart and say so, never fold it in. Named a guard (the
red-on-old proof of VM-69 is the gated suite's, recorded at the stage); no production line. *The ticket:* Debt · Confirmed · Tests & tooling ·
Medium — company-safe twins for the remaining counts only the gated suite asserts (the hidden Library's zero
re-reads and redraws through the real shell, the covered-Library pin, editor builds per open), read off the store
or the model rather than the process's recorder.

**The optional ticket (a sync apply on a deep listed row) — YES, a ticket.** It is finding 1's mechanism with
another writer: while the Library is on screen and listed past its first page, a remote tombstone, revival or
re-homing of a deep note leaves the held first page unchanged, so the row stays (or stays missing) until the first
page next moves or she leaves and returns. Outside finding 1's class — not the Library's own act — and correctly
left out of this pass. Class: Bug · Suspected (traced by reading on a mechanism finding 1's pin proves; its own
pin first — a direct tombstone of a deep row under a running hold) · Library & sidebar · Low; team VM, a candidate
rider for wave 2's Library umbrella (VM-87); its body names that the Mac's catalog shares the shape and that a
completed sync round which applied rows is the natural moment to re-ask a deep listing.

*No FINDER-FIXES: finding 1's arm (A) and O-1's guard are specified above for the implementer's second turn;
finding 2 goes to VM-226 with its body specified; everything else is applied or a record edit.*

**Is anything in this pass a NEW blocker or major?** No — by reading. The pass is uncompiled, so that answer is
owed again once `vm64-gate2` builds and its pins run.

**What the next round's reader should look at first:** arm (A)'s one line in `MobileLine.putBack` and its
listener's scope (its own session only, alive only with the Library's view) with the Put back pin's red on the
pre-fix tree; then the red-on-old run's exact reds against the closeout's table; then that finding 2 is OPEN under
VM-226 and the fence suite still has no world that runs the editor's live observation.
