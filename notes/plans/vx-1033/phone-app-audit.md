# The phone app outside the editor: an architecture and robustness audit (read-only, main @ 37cf317fe)

Scope: `App/Variorum/VariorumMobile/` except the Write editor. That means `Features/Shell` (41 files), `Features/Protection`, `Features/Read`, `Features/Perf`, `Features/Tutorial`, the app root, and the parts of `App/Variorum/Shared/` the phone composes (`AppBootstrap`, `AppSession`, `AppServices`, `SyncSession`, `WingState`, `OperationsRunner`). I did not repeat the editor audit or the sync-lag report (both on `vx-1033-nov-22-sitting`). `Features/Takes` got only grep-level checks (raw writes, `try?`). Nothing was built, run or edited.

Class tags:
- **TRACED-BUG:** a concrete input gives a wrong result, read straight from the code.
- **TRACED-RISK:** the code allows the failure, but showing it needs a device or particular timing.
- **SMELL:** structure that breeds bugs.
- **INFERRED:** reasoning, not a code read.

---

## Verdict

**A sound base with specific rotten spots. It does not need structural work before wave 2, but one rotten spot sits right under two of the four wave-2 umbrellas and should be fixed first.**

What is sound, and it is most of the code:
- **Every write goes through operations.** There are no raw SQL writes and no ad-hoc `db.write` anywhere on the phone. Every write is `session.runner.run { ops in … }` (77 call sites) or a shared helper (`TrashPutBack`, `TrashPurge`, `session.divergeForBook`).
- **One raw SQL read exists**, and it has already drifted from Core's rule (finding 6).
- **Reads are off the main thread.** Every database read is async.
- **Lists are bounded.** They are windowed with a probe row, or keyset-paged (the Library since VM-68).
- **Hidden screens never hold a note.** A hidden stack is always popped to its root (P-47-19), which removes a whole class of "a note open behind the screen" hazards.
- **Delete doors save typing first.**
- **Refusals are worded.** Most go through the shared refusal tables (`DeletionRefusal`, `OpsRefusalCopy`, `BookNameCopy`).
- **Tests are mostly behaviour tests.** About 95% run against in-memory stores, with red-on-old discipline.
- **The quick-note box's text-loss defences are careful and pinned.**

What is rotten clusters in one place: **the lifecycle seam (lock, unlock, background, return).**
- **The quick-note box keeps the first open's session.** The box is held by the app for the whole process, but it binds only the first open's session. After any relock it files into a stale session: the wrong wing, a message line nobody sees, an undo stack nobody can reach (finding 1).
- **The library can lock after she has come back.** The leaving lock runs even when she returns before the background flush finishes (finding 2).
- **A lock during start leaves zombie services.** A lock that lands while `AppServices.start()` is suspended leaves a second sync chain, idle-commit clock and purge loop running (finding 3).
- **The base fact multiplies all three.** Under Castle every backgrounding locks (VM-105, ticketed), so each of these is reached at app switches, not on rare occasions.
- **A Shared design choice hides them.** The reopened library adopts its fresh pool into the same rebindable database view, so a stale `AppSession` keeps writing successfully. The tests model the same posture: one session reused across `store.reopen()`.

The second weakness is **Mac brains copied rather than shared**. Wave 2 builds directly on several of them:
- the Library's paging and landing state machine;
- the Today composition;
- the book contents grouping;
- the Finish-row door table.

The Today copy has already diverged (finding 5).

My reading of "buggy": it comes less from new features breaking old ones and more from (a) every app switch tearing the app down under Castle, with the races above riding on that, and (b) the editor's own issues. Most of the shell code is careful.

---

## Ranked findings

Ordered by what they can do to her writing first, then by reach.

### 1. TRACED-BUG: after any relock, the quick-note box files through the first open's session (VM-107, and its reach is wider than the ticket says)

**Mechanism.**
- The box is process-lived: `MobileShellRouter.quickNote` (`MobileShellRouter.swift:52`), held by the app's `@State` router (`VariorumMobileApp.swift:33`).
- Each new shell calls `router.quickNote.bind(session:)` (`MobileShellView.swift:211`). But `bind` only sets a nil session: `if self.session == nil { self.session = session }` (`MobileQuickNote.swift:345-347`).
- Every unlock makes a new `AppSession` (`AppBootstrap.swift:496`). The box keeps the first one.

**Why nothing visibly breaks.**
- On a reopen, the old database view adopts the fresh pool: "The re-open after a lock: the SAME ambient view adopts the fresh pool" (`AppBootstrap.swift:459-468`).
- So the stale session's writes land in the right store.
- What diverges is everything else the session owns.

**What she sees** (each traced):
- **The wrong wing.** The mint files into `session.wing.currentID` (`MobileQuickNote.swift:730`). `WingState` is per session (`AppSession.swift:237`), and the stale one never hears a wing switch made after the unlock. So after a relock plus a wing switch, quick notes land in the old wing's Pool, and the Library she is standing in never shows them.
- **Invisible refusals.** The box's refusals speak into the old session's status centre (`MobileQuickNote.swift:248`). The new shell's message line watches the new session, so a refused capture says nothing.
- **Untrue copy.** The locked-store refusal promises "unlock the library and it will save" (`:157-160`). Nothing retries at unlock: the one re-armed mint fires while still locked, and the next try waits for her next keystroke or leaving.
- **Typing missed before a sync round.** The box's autosave coordinator sits in the old session's registry. The new session's `flushPendingTypingBeforeRound` (`AppSession.swift:634-637`) and `flushEveryOpenPost` never reach it. A sync round can then apply under her pending box typing. VX-683's rescue keeps both texts as a conflict take, so nothing is lost, but it is the road VX-683 exists to avoid.
- **Unreachable undo.** The mint's undo entry goes on the old session's stack.
- **Two runners.** The old session's `OperationsRunner` actor keeps running beside the new one, so runner-level atomicity of composites no longer holds between the box and the rest (INFERRED, low risk).
- **Memory.** The old session, its undo pre-images and its autosave registry are kept for the life of the process (INFERRED).

**Reach.** Under Castle, `MobileRelockPolicy.locksOnLeaving` is simply `policy != nil` (`MobileRelock.swift:50`). Every app switch locks, so the box goes stale at the first app switch of each launch, not on an occasional relock.

**Why no test caught it.**
- `MobileQuickNoteUnderLockTests` (`MobileProtectionTests.swift:318-341`) locks but never reopens.
- `aCastleBackgroundingSavepointsOnceBeforeTheStoreCloses` (`MobileLeavingSavesOnceTests.swift:351-385`) reopens and keeps the same session.

**Damage.** It misfiles and hides captures. It does not destroy text.

**Ticket.** VM-107 (High, Confirmed, in VM-103, "mechanism traced; consequence not run"). The wrong-wing and silent-refusal consequences are not written in it.

**Fix shape.**
- Make the box session-keyed. `bind` replaces the session when it changes, after filing any held note through the old session first.
- Key the shell on its session (finding 13).
- Pin it: open, lock, reopen with a new `AppSession`, switch wing, capture. Then assert the note's wing, the line the refusal reached, and that the new session's flush reaches the box's coordinator.

### 2. TRACED-RISK: the leaving lock fires after she has already come back (not ticketed)

**Mechanism.**
- On `.background`, `mobileScenePhaseChanged` starts one task (`MobileShellRouter.swift:417-437`): file the box, flush the editors, savepoints, `sync.flush()` (a full network round), then `relock.didLeaveTheScreen()`. The last step is deliberately "NOT gated on `Task.isCancelled`".
- On `.active` (`:394-403`), the handler calls `didReturnToTheScreen()`. That returns false while `leftAt` is nil (`MobileRelock.swift:138-141`), which it always is during the flush, because `leftAt` is set only inside `didLeaveTheScreen` (`:126-129`). Nothing cancels or voids the pending leaving.

**The race.** She switches away. The background round takes several seconds: the sync report counts at least 13 sequential HTTPS calls, and one round took about a minute on her phone. She comes back within that window and starts typing. The round finishes, `didLeaveTheScreen()` runs, and under Castle the library locks: the lock screen replaces the app while she is using it.

**Damage.**
- The teardown flushes the editors first, so ordinary typing is saved.
- Text being composed or dictated at that moment meets the editor audit's F3/F4 gap. INFERRED: this is a new trigger for that loss.

**Ticket.** None. The sync report notes the lock on every leaving but not this ordering. VM-105 will reshape this code, and the race survives any policy that still locks at a leaving.

**Fix shape.**
- Give each leaving a generation number. `.active` voids the pending one.
- `didLeaveTheScreen` locks only while the scene is still away.
- Pin it with a slow `sync.flush()` stand-in that returns after an `.active` arrives, and assert no lock.

### 3. TRACED-RISK: a lock during `AppServices.start()` leaves zombie services running (Shared; the phone meets it far more often)

**Mechanism.**
- `AppServices.start()` (`AppServices.swift:298-335`) awaits `auth.setOnChange`, `auth.currentUserID` and `connectSyncIfAllowed()`. That last one awaits owner adoption and `sync.configure`.
- After the awaits it starts the sync chain (`:543-546`), `idleCommits.start()` (`:325`) and the hourly purge loop (`:329`).
- `stop()` (`:337-350`) sets no flag, and `start()` checks none.
- The phone's lock road calls `services?.stop(); services = nil` from `onWillLock` (`VariorumMobileApp.swift:143-155`) while `.task` may still be suspended in `await fresh.start()` (`:156`). `.task` cancellation does not stop `start()`.
- When `start()` resumes after the stop, `configure` builds a fresh scheduler on the stopped `SyncSession`. The key provider is the bootstrap's single `newRoadSyncKeys`, which gets its key back at the next unlock.

**Result.** After that unlock, two sync schedulers, two idle-commit clocks and two purge loops run against one store.

**Damage.** Data stays safe: the engine's one-writer belt refuses a round whose cursor moved underneath it (`SyncEngine.swift:758-773`). The cost is doubled rounds, belt refusals with immediate follow-ups, and duplicate sweeps. INFERRED: that is battery and churn, and it may feed the "sync feels slow" reports.

**Window.** As long as `start()` takes, after each unlock. It is narrow per event, but under Castle there is an event at every return.

**Ticket.** None.

**Fix shape.**
- Add a `stopped` flag checked after each await in `start()`, or have the app's task re-check its services' identity before `start()` continues.
- Pin it with a suspending auth fake: call `stop()` mid-start and assert no scheduler.

### 4. SMELL (ticketed): under Castle every app switch tears the whole app down, and findings 1–3 ride on it

`locksOnLeaving = policy != nil` (`MobileRelock.swift:50`). Every Castle backgrounding:
- flushes;
- drops the `.ready` tree;
- closes the pool;
- reopens cold after Face ID;
- rebuilds the services;
- lands her on the Bookcase with empty stacks.

The time-away branch (`locksOnReturn`) is dead code today, and the pin `leavingLocksUnderCastleAlways` fixes the current behaviour in place, though the work list says it traces to a planner's item, not to her (W-187). This is the base fact that turns 1–3 from rare into routine, and it is very likely a large part of why the app feels buggy.

**Tickets.** VM-105, VM-106 and VM-25 (in VM-103). They change exactly this code, so findings 2 and 3 should land with or before VM-105, and the return branch's pins must become real when it goes live (finding 9).

### 5. SMELL: wave 2 builds on Mac brains the phone copied instead of sharing, and one copy has already diverged

Each line below names the phone copy, its Mac original, and the gap.

- **Library paging and landing.**
  - Phone: `MobileLibraryViewModel.swift:401-777`. It has its own generation counter, superseded pages, a follow single-flight loop, a prefetch margin, an append-dedupe, and a union with books.
  - Mac: `LibraryCatalogModel.swift` (1,306 lines) and `LibraryCatalogPaging.swift`, both Mac-local. The phone file's own comments name the Mac's `followListingMove`, `prefetchMargin` and `loadNearExtras`.
  - Gap: W-037 calls this "face only (Core catalogNotesPage)", but the state machine above the query was copied, not shared. VM-88, 89, 90, 92 and 31 will each add state to a model that already juggles two listings (464 code lines). No ticket hoists it; VM-131 covers only the search model.
- **The Today door.**
  - Phone: `MobileTodayDoor.open` (`MobileTodayDoor.swift:37-85`).
  - Mac: `JournalBooks.openToday` (`BookStructureModel.swift:1077-1115`).
  - Gap: the Mac reads the Journal's archive state before and after and speaks the comes-back receipt, names the book in every shelving note, and names the owning book when the entry waits. The phone speaks generic sentences and none of that. VM-85 covers only the words. Both copies call `Date()` directly for the day (`MobileTodayDoor.swift:40`).
- **The book contents grouping.**
  - Phone: `MobileBookViewModel.grouped` (`:189-215`), which calls itself "the phone's face of the same rule".
  - Mac: `BookStructureModel.grouped` (`BookStructureModel.swift:170`).
- **The Finish row.**
  - Phone: `MobileBookDetailsModel.finishRowAct` (`MobileBookDetails.swift:96-99`), "a phone-side reading of the Mac's table until the door sets are hoisted".
  - Mac: `BookStateDoorSet` (`Features/Readings/BookStateDoors.swift:85`). W-070 owns that hoist.
- **Refusal wording.** `MobileMembershipModel.refusal` and `MobileTagsModel.refusal` are phone-local sentences beside the shared tables.

**Damage.** Maintainability and drift. The Today copy shows the drift already.

**Fix shape.** Hoist the Library's paging and landing machine to `Shared/`, or at least extract the phone's into a pure, pinned type, before VM-87's members add to it. Hoist the Today composition whole as VM-85's real fix.

### 6. TRACED-BUG (display, small): the phone's one raw SQL read copies Core's membership rule and drops `status = 'member'`

**Mechanism.**
- `MobileBookViewModel.start` (`:119-134`) hand-writes "chapters holding a member" for truncated books, "mirroring the assembly's own membership join".
- Core's assembly filters `rp.status = 'member'` (`ReadingAssembly.swift:407, :429`). The copy does not.
- A member demoted to an arrival keeps its `section_id` (`Operations+Ownership.swift:504`).

**Result.** In a chaptered book of more than 300 notes, a chapter holding only arrivals counts as populated. Its header folds under the truncation marker instead of showing as empty.

**Damage.** Display only.

**Ticket.** None.

**Fix shape.** A Core query that shares the assembly's predicate. Line 107 also hand-writes `SELECT * FROM reading` where `Queries.reading` exists.

### 7. TRACED-BUG (clutter): New Note and Today have no single-flight guard

**Mechanism.** The doors in `MobileShelfView.swift:251-255`, `MobileLibraryView.swift:222-226`, `MobileBookView.swift:191-195` and `MobileShelfView.swift:454-460` each start an unguarded `Task` that awaits a mint and then pushes.

**Result.** A second tap mints a second note and pushes a second editor: two untitled notes, or two book memberships. It is likeliest exactly when the first tap seems to do nothing. INFERRED: for example, while the writer is held by a long sync save (VM-184), several taps queue and then all land.

**Damage.** Clutter, not corruption.

**Ticket.** None. VM-246 is the Unarchive twin.

**Fix shape.** The phone already has `MobileWriteLatch` for exactly this and uses it on Create Book, comments, lenses and takes. Use it here too.

### 8. TRACED-BUG (display): screens that say something untrue

- **A book deleted elsewhere.** While its contents are open, the observation delivers `reading == nil`. `assembleReading` returns `[]` for a dead book (`ReadingAssembly.swift:301-303`), and the screen says "No notes in this book yet." (`MobileBookView.swift:101`), loses its doors and never pops. The Write screen has a tombstone check; the book screen has none.
- **The Read page before its first load.** It says "Nothing to read yet — this book has no notes." (`MobileReadView.swift:85-90`). This is VM-245's twin; VM-245 names only the contents list.
- **A failed note read on the Read page.** The per-note read is `try?`, so a failure renders that note blank with no message (`MobileReadView.swift:176-181`).
- **Starred before its first load.** It draws its empty line (`MobileStarredView.swift:65`).

**Tickets.** VM-244 and VM-245 cover the Archive and contents flashes. The rest are not ticketed.

**Fix shape.** A "loaded" flag on each listing (the Trash's VM-33 pattern), and pop on a dead book.

### 9. SMELL: test reality — mostly behaviour tests, thin where wave 2's lock work lands

**The numbers.** By a script over `@Test` bodies, about 66 of 1,226 phone tests (about 5%) read source files as text. The rest drive models and hosted surfaces against in-memory stores. That is a good ratio.

**The thin spots, all under VM-103:**
- **Source-scan coverage.** The Protection screens are covered mostly by source scans: `MobileProtectionDoorsTests` (15 of 22) and `MobileProtectionScreenTests` (8 of 12).
- **No coverage at all.** The lock's faces `MobileLibraryMissingView`, `MobileLibraryWordsCard`, `MobileRoadInterludeCard` and `MobileNoKeyFileSheet` have no phone test of any kind. Their brains are shared.
- **No full cycle.** No phone test drives lock, then reopen with a new `AppSession`, then use. The lockable world reuses one session across `store.reopen()` (`MobileLeavingSavesOnceTests.swift:125`, `:351-385`), which is the posture that hides finding 1.
- **A hollow pin.** `aReturnThatLocksDoesNotTriggerASyncRound` (`MobileProtectionTests.swift:274-289`) passes whatever the code does. Under Castle the return can never lock, because the leaving already cleared `leftAt`, and `sync` is nil. The count it asserts came from the leaving.
- **A second weak pin.** `theLockLandsAfterTheWholeFlush` (`:258-272`) can only ever record `["lock"]`, because nothing is registered to flush, so it cannot see ordering. The ordering itself is pinned for real in `MobileLeavingSavesOnceTests`.

### 10. SMELL: feature isolation is nominal, and the god object is the shell view, not the router

- **One folder holds most of the app.** `Features/Shell` holds 41 files: Bookcase, Library, Trash, Archive, Starred, tags, Settings, wings, books, Book Details, Create Book, the quick note, the message line, the band and the tab bar. That is one "feature" in name.
- **The Library holds the Bookcase's view model.** `MobileLibraryView` reads `MobileShelfViewModel` for its book rows (`MobileLibraryView.swift:49`, `:342-368`), and depends on the Bookcase view's `.task` to keep that model alive. CLAUDE.md forbids a feature holding a sibling's view model; here it is legal only because both sit in "Shell".
- **The shell view does about twelve jobs.** `MobileShellView` is 781 lines (383 code). It owns seven models and three navigation stacks, plus:
  - the band gesture and its latch;
  - the route builder;
  - message-line hosting;
  - tab-bar measuring and list-bar counting;
  - the edge-grounds board;
  - Settings and its DEBUG doors;
  - adopting Protection's requests and wiring its receipts;
  - filing the quick note on navigation;
  - the liveness handoff;
  - starting the theme;
  - the timing marks.
- **The router is not the god object.** It has 151 code lines, but its name misleads. Its header says "Two concerns, both routing" (`MobileShellRouter.swift:5-29`), yet it routes nothing and holds five kinds of process-lived state, including the box from finding 1.

**Damage.** Maintainability. Each wave-2 umbrella adds to this file.

### 11. SMELL (P1): reads that scale with the whole library on small screens

- **`Queries.shelfBookTags`.** It aggregates every membership against every post tag, across all wings (`ShelfQueries.swift:460-482`). The Bookcase runs it on each appearance of its root (`MobileShelfView.swift:144`; INFERRED: a NavigationStack root re-runs `.task` when a pop shows it again). Book Details runs it on open and after every act (`MobileBookDetails.swift:133-138`), and also reads every wing's bookshelf to show one book.
- **Snippets.** The listing reads the whole pool on every delivery and windows it in memory (`MobileScraps.swift:95`, `:166`). VM-97 will add editing on top of this.
- **Starred.** Its observation lives for the shell's whole life (`MobileShellView.swift:359`). It re-runs after every autosave, per Core's own comment at `AppearanceQueries.swift:351-356`, and does one header read per starred note on each delivery (`MobileStars.swift:166-180`). It is bounded by the number of stars, but unlike the Library since VM-68 it stays held while she types.

**Tickets.** Partly VM-176 (umbrella) and VM-240 (the Library). None names these three.

### 12. SMELL: rot

- **Comments outweigh code.** `Features/Shell` has 5,987 comment lines to 6,304 code lines. `MobileQuickNote.swift` has 763 comment lines to 529 code. Most of the comments narrate rounds and findings ("4.5a fix round, MAJOR 4", "R2-2") rather than the contract.
- **Stale headers.** `VariorumMobileApp.swift:13` and `MobileShellView.swift:6` say "tabs Shelf · Library"; there are three pages. `VariorumMobileApp.swift:9-10` says there are "no local backups — the phone's store is re-derivable from the mirror", which is false for a library with no account (VM-15's own premise).
- **Dead code.** The relock coordinator's time-away branch is dead under today's policy (finding 4).
- **Retired vocabulary.** Create Book still writes the v1 `SmartQuerySpec` path grammar (`MobileCreateBook.swift:140-143`). Core converts it at the mint (`Operations+Reading.swift:118-141`), so it is not a bug.
- **Unchecked PROVISIONAL marks.** There are 107 across the phone tree. In scope they include "SnapshotPrivacy — PROVISIONAL, pre-Stage-A" (`VariorumMobileApp.swift:81-82`), long after Stage A.

**Ticket.** VM-224 is the leftovers sweep.

### 13. SMELL: the shell is not keyed on its session

`case .ready(let session): MobileShellView(...)` (`VariorumMobileApp.swift:77-80`) has no `.id`. The shell builds seven models from the session at its first init only.

The rule that saves it lives in a comment (`MobileShellRouter.swift:114-124`): every new session reaches the shell through `.opening`, and a road that swapped sessions without leaving `.ready` "must key the shell on its session".

**Fix shape.** `.id(ObjectIdentifier(session))`, which costs nothing.

### 14. TRACED-RISK (for VM-25): the lock's teardown does not file the quick-note box

- The background road files the box first (`MobileShellRouter.swift:310`).
- `mobileWillLock` (`MobileRelock.swift:80-96`) flushes only the registered editors and their savepoints. The box's un-minted text (a 1 s window) and its debounced post-mint typing (500 ms) stay unfiled when the pool closes.
- Today that is reachable only by a non-background lock, such as a crossing's reopen.
- VM-25's planned Lock Now on the home screen, beside the box, makes it ordinary. Text is not lost (the box keeps it, and the shared view lets the stale session save it later), but that rescue depends on finding 1's accident.

**Fix shape.** `mobileWillLock` files the box first, in the same order as the background road.

---

## What wave 2 builds on

### VM-72: Home, wings and capture

**Builds on:**
- `MobileQuickNoteModel`: process-lived, bound once (finding 1), with a `TextField` and a one-turn-late restore (the MAJOR 5 caret jump);
- `MobileShelfView` and its view model;
- `MobileShellView`'s band and stacks;
- the interim `MobileWingDoor` over the shared `WingsModel`;
- `MobileTodayDoor`, the forked composition.

**Fix first, or inside:**
- **VM-107 first.** VM-73 rebuilds the same box, and the two are already marked to serialize.
- **Treat VM-73 as a redesign, not a tweak.** Once Return makes a new line, the box's ownership model breaks: it owns the last minted block, and everything before it is held as `frozenPrefix` behind a boundary hold. Rebuild it over a small, pinned capture brain, and drop the `TextField` restore trick.
- **VM-85 should hoist the Today composition**, not just its words.
- **Latch New Note and Today** (finding 7).
- **Key the shell on its session** (finding 13).
- **Wing switching on the box must use the current session's wing** (VM-80, VM-82). This is finding 1 again.

### VM-87: the Library

**Builds on:**
- `MobileLibraryViewModel`: the copied paging machine, the held first page (VX-618 and VM-240 still open), the books union through the Bookcase's model;
- `MobileStarsModel`, held for the shell's whole life.

**Fix first, or inside:**
- **Hoist or extract the paging and landing machine before VM-88, 89, 90, 92 and 31** (finding 5). Previews (near-extras), title sort, the day filter, the row menu and multi-select are all per-listing state.
- **Fold VM-242 and VM-240 in here.**
- **VM-94: hold Starred only while it is on screen**, as VM-68 did for the Library (finding 11), and add its loaded flag (finding 8).
- **The books union should stop borrowing the Bookcase's view model** (finding 10). Give the Library its own held books read, or a shared row brain (W-032).

### VM-96: Trash, Archived, Snippets, tags

**Builds on:**
- `MobileTrashModel`, over the shared `TrashPutBack` and `TrashPurge`. This is a good base.
- `MobileArchiveModel`. It carries VM-244's flash and speaks an unarchive refusal through the `.putBack` arm because `DeletionRefusal.Act` has no `.unarchive` (its own comment).
- `MobileScrapsModel`: whole-pool deliveries (finding 11).
- `MobileTagsModel`: phone-local refusal words. `deleteTag` registers a structural undo entry the phone has no door for (VM-101).

**Fix inside:**
- page the Snippets read before VM-97 adds editing;
- add the `.unarchive` act arm;
- VM-244.

### VM-103: the lock

**Builds on:**
- `MobileRelockCoordinator` and `MobileRelockPolicy` (every Castle leaving locks; the return branch is dead);
- `mobileScenePhaseChanged` (the lock after the flush, never voided by a return);
- `mobileWillLock` (does not file the box);
- `AppBootstrap.lock` and adoption (stale sessions keep working);
- `AppServices.start` and `stop` (no stopped guard);
- source-scan-heavy Protection tests and untested lobby faces.

**Fix first, inside, as its first members:**
- **Findings 1, 2, 3 and 14, as one lifecycle unit, before VM-104's probe and VM-105's policy change.** VM-105 rewrites the same coordinator, and its new return branch needs real pins, not the hollow one from finding 9.
- **A hosted behaviour test per lobby face** (finding 9).
- **VM-229 and VM-230 as ticketed.**

---

## Recommended hardening scope (outside the editor)

Units in order. Each names what it proves and the evidence of its kind.

1. **L1: one session per open.** Findings 1, 3, 13 and 14 (VM-107 rides as the ticket).
   - **Proves:** after lock and reopen, nothing on the phone acts through an old session, and no services survive their stop.
   - **Evidence:**
     - Headless pins red on old code: lock, reopen with a NEW `AppSession`, wing switch, capture; then assert the wing, the line and the flush reach.
     - A suspending-auth pin proving `stop()` during `start()` leaves no scheduler.
     - A Debug simulator walk on the dev store in Castle (`~/.variorum/dev-castle.env`): capture, switch apps, Face ID or passphrase, switch wing, capture, check where it landed.
     - One device session.
   - **Vehicle:** its own small run, or VM-103's first member. It touches `Shared/AppServices` and the composition root, not `Sync/`.
2. **L2: the leaving lock honours a return.** Finding 2.
   - **Proves:** a return before the leaving's work ends voids that leaving's lock.
   - **Evidence:** a pin with a slow flush stand-in and an `.active` mid-flush (no lock), replacing the hollow `aReturnThatLocksDoesNotTriggerASyncRound` with a real return-that-locks pin. Then one device check: switch away, come back within about 5 s, type for 30 s.
   - **Vehicle:** rides VM-103 next to VM-105, since it is the same file.
3. **L3: single-flight doors and honest first paint.** Findings 7 and 8.
   - **Evidence:** pins (a double invoke gives one note; a dead book pops), and hosted-surface pins of each listing's first paint.
   - **Vehicle:** rides VM-72 (doors), VM-87 (Starred), VM-96 (Archive), and VM-120 later (the book page).
4. **L4: brains to Shared before faces multiply.** Findings 5 and 6.
   - **What:** hoist the Library's paging and landing machine and the Today composition, and replace the book view model's raw SQL with a Core query.
   - **Evidence:** no behaviour change on the paging. The existing `MobileLibraryPagingTests` and `MobileLibraryPagingRulesTests` stay green, and so do the Mac Library suites and the Mac source-scan groups the VM-64 handoff lists. The populated-chapters pin is red on old code, with an arrival carrying a `section_id`.
   - **Vehicle:** its own run, because it touches the Mac's Library. Run it before VM-87, or make it VM-87's first member.
5. **L5: test posture for the lock.** Finding 9.
   - **What:** a lockable world that makes a new session per reopen, and hosted tests for the four lobby faces.
   - **Evidence:** the new pins fail on main where finding 1 bites.
   - **Vehicle:** rides L1 or VM-103.
6. **L6: P1 on small screens.** Finding 11: wing-scope and per-book `shelfBookTags`, page Snippets, hold Starred only while shown.
   - **Evidence:** count pins in the style of `MobileShelfPerfTests` (observation ticks while typing, reads per appearance), and the phone's Timing readout before and after.
   - **Vehicle:** VM-176 or inside VM-87/VM-96.
7. **L7: comment and PROVISIONAL hygiene in Shell.** Finding 12.
   - **What:** rewrite the history-narrating comments of the five biggest Shell files to state the contract, fix the stale headers, and reconcile the in-scope PROVISIONAL marks against QUESTIONS #276–#282.
   - **Evidence:** no behaviour change; the source-scan suites stay green.
   - **Vehicle:** VM-224. It can ride anything.

Per the sizing guidance, L1 and L2 together are one "lifecycle" run, ideally before wave 2's VM-72 and VM-103 start, and coordinated with the editor audit's run because both touch backgrounding. L4 is its own run. The rest ride umbrellas.

---

## What I could not determine

- **Whether her phone library is in Castle today.** INFERRED yes, from PL-60 (her phone joined under her account's Castle mode). Findings 1–4 reach her daily only if it is.
- **How long the background flush's round takes on her phone.** That is finding 2's window. VM-232's split timing would settle it.
- **Whether every reopen road passes through a rendered `.opening` frame.** I checked `beginOpening` and the lock. I did not check every crossing in `AppBootstrap`. A road that does not would leave the shell on old models (finding 13).
- **What two concurrent schedulers do beyond belt refusals** (finding 3): whether the two purge loops or idle-commit clocks can both write something visible.
- **Whether a NavigationStack root re-runs `.task` on every pop** (finding 11's frequency). That is a device or simulator fact.
- **Which of the 107 PROVISIONAL marks have been ruled.** That needs a pass against QUESTIONS #276–#282.
- **`Features/Takes` (2,971 code lines).** Checked only for raw writes, `try?` and Tasks. Its storage-writing parts belong to the editor audit's scope.
- **The real-keyboard behaviour of the quick-note `TextField` restore under dictation and autocorrect.** Device-only, and the same class as the editor audit's F2/F3.
