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
