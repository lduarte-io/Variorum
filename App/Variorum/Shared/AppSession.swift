//
//  AppSession.swift
//  Variorum (shared: Mac + Mobile)
//
//  The composition root's shared state: the opened store plus the
//  session-scoped objects every feature receives by injection (no globals —
//  CLAUDE.md code hygiene). Cross-feature interaction routes through parent
//  composition holding this, never feature-to-feature calls.
//
//  Phase 8: compiled into BOTH app targets. The iOS capture surface uses the
//  same session shape over the same store — the mobile journal is a UI
//  profile, never a separate data model (CoreDescription pillar 8).
//

import Dependencies
import Observation
import Foundation
import VariorumCore

/// The undo stack's menu-facing mirror (Phase 9 — per-op undo labels): a
/// tiny observable the Edit menu reads, refreshed by the stack's change
/// observer. The stack stays the truth; this is a projection.
@MainActor
@Observable
final class UndoMenuState {
    private(set) var topLabel: String?
    /// 13c 1B (A10): the redo half's label, from the same refresh — the
    /// stack stays the truth, this is a projection of BOTH its ends.
    private(set) var topRedoLabel: String?

    func refresh(from stack: UndoStack) {
        topLabel = stack.topLabel
        topRedoLabel = stack.topRedoLabel
    }
}

@MainActor
final class AppSession {
    let database: AppDatabase
    /// pre-13x ladder round 2, F3 (MINOR-N3): which store this session
    /// serves — the seeded books' per-variant marks are read against it
    /// (one build can open either store — the dev fence's opt-in — so an
    /// unscoped read would let the dev store's mark answer for the real one;
    /// the Debug and Release domains themselves are separate, verified at the
    /// U6 round 2). The bootstrap
    /// hands its variant; a headless session (the pins) defaults to `.real`.
    let storeVariant: AppDatabase.StoreVariant
    /// F3 (MINOR-N3): the seeded books' per-book mark on THIS device, as the
    /// tutorial door's SILENT ensure reads it — the production leaf reads
    /// `SampleLibrarySeeder.isMarkedSeeded` for `storeVariant`; a pin
    /// injects its own, so no headless run ever reads the test host's
    /// defaults (the test host's domain IS the Debug app's — the row-36 class).
    @ObservationIgnored var seededBookMarkIsSet: @MainActor (SampleLibrarySeeder.Book) -> Bool
    /// **RUN A batch A2, row 8 (17l item 1 / KnownIssues 38): the WRITE half
    /// of the same mark** — how a seeded-book road records, on this device,
    /// that the reader's decision about this book is now on record.
    ///
    /// F3 (MINOR-N3) taught the silent ensure to decline on a tombstoned
    /// reading of the book's name. A tombstone is the reader's word only
    /// while the Trash keeps it: Delete Now writes a purge intent and the
    /// janitor then physically removes the row — and 13j's purged-ids ledger
    /// is CONTENT-FREE by design (`purge_intent` / `purged_row` carry a table
    /// name and a row id, never a book's name), so after the purge nothing
    /// that survives can be asked "was a book called this deleted?". The
    /// roads therefore record the decision WHILE the evidence stands, in the
    /// one place the seeder already keeps it.
    ///
    /// Injected for the same reason the reader is: the test host IS
    /// `io.lduarte.Variorum.debug`, so a headless run that wrote the
    /// production key would set the dev store's own mark (the row-42 class).
    @ObservationIgnored var markSeededBook: @MainActor (SampleLibrarySeeder.Book) -> Void

    /// **The READ-side clock** (13j J1 — the 30-day Trash window).
    ///
    /// Every recovery listing takes a required `now`, because "in the Trash"
    /// is a statement about time and a surface that inherited someone else's
    /// idea of the boundary could show her a Put back she can no longer use.
    /// It resolves through `@Dependency(\.date)` — the same injected clock
    /// `Operations` writes stamps with — so a test standing on day 29 and a
    /// test standing on day 31 are both one line, and production reads the
    /// system clock.
    ///
    /// **Snapshotted in `init`, deliberately.** The readers are all HELD
    /// observations (`.task`s that start when a surface appears and read the
    /// clock when they start), so the read can land long after the scope that
    /// built the session has gone; taking the generator at construction is
    /// what makes "the session's clock" mean the clock of the world the
    /// session was built in, in production and under test alike.
    @ObservationIgnored private let clock: DateGenerator
    var now: Date { clock.now }

    /// **Is a sync chain configured?** (13j ladder B, B3 — her round-11
    /// ruling's receipt condition.) Wired by AppServices to
    /// `SyncSession.isConfigured`; false by default, which is the honest
    /// answer for a session nothing wired (tests, previews, the
    /// never-signed-in install). The purge doors word their receipts by it,
    /// and the local purge road below runs only while it is false — a
    /// configured chain's janitor covers everything, local families
    /// included, so two sweeps never race.
    @ObservationIgnored var syncConfigured: () -> Bool = { false }

    /// **The first-write signal** (pre-13u Act 0 — her B1 ruling
    /// R-pre13u-1, *"seed on first WRITE, not first launch"*).
    ///
    /// Wired only by the PHONE today (`MobileFirstWriteFurniture`), and it
    /// lives here for the reason `syncConfigured` does: this is the one
    /// object every write door on either platform already holds, so a door
    /// announces "she made something" in one line instead of five models
    /// growing a new constructor parameter. Default is a no-op, which is
    /// the honest answer for the Mac, for previews, and for every pin that
    /// never wired it.
    ///
    /// **It is a signal, never a barrier.** Callers announce and move on —
    /// nothing on a write path ever awaits what this starts. The whole
    /// point of moving furniture off the launch path was that furniture can
    /// always wait; it must not become something her keystroke waits for.
    @ObservationIgnored var onFirstWrite: @MainActor () -> Void = {}

    /// Announce that a door just put content in the store. Idempotence is
    /// the LISTENER's job (the furniture's mark, its own once-per-launch
    /// flag), deliberately: a door should not have to know whether it is
    /// the first one, and a session that tracked it would have to decide
    /// what "first" means across locks, re-composition and store swaps.
    func noteFirstWrite() { onFirstWrite() }

    /// One best-effort local sweep (13j ladder B, B3 — `LocalPurge`, the
    /// transportless road: never-synced families physically remove with no
    /// server, no ledger, no horizon — there is no one to strand). Swept at
    /// launch + periodic cadence by AppServices, and right after a
    /// purge-door confirm so Delete Now on a local install feels like what
    /// it says. Quiet on failure (a purge cadence is never a surface to
    /// throw at; the next sweep retries), and a no-op while a sync chain is
    /// configured (its janitor owns the road). The store is bound
    /// EXPLICITLY — this session's, never the ambient installed one (the
    /// A4 fence's lesson: a test host's ambient database is the dev store,
    /// and physical removal must never land there by dependency accident).
    func sweepLocalPurge() async {
        guard !syncConfigured() else { return }
        _ = try? await LocalPurge(database: database).sweep()
    }
    /// The session-scoped structural undo stack (AppSpec §9) — in-memory,
    /// never persisted. (On the Mac it wires to the Edit menu; the phone
    /// registers entries where its structural doors do — divide, merge,
    /// delete, the takes browser's archive/delete-variant, the chip's
    /// diverge — and, since mobile round 2's M20, HAS a door of its own:
    /// a receipt-based undo. **13l L-d corrects "with no undo UI yet",**
    /// which this line still said after that shipped; what the phone has
    /// no door for is REDO, and that is a mobile batch's, not a fact about
    /// this stack. C2 ladder R1-4/R2-N1 had already corrected the older
    /// "no structural ops on mobile" claim.)
    let undoStack: UndoStack
    let operations: Operations
    /// Serial off-main executor for every operations-layer write (P2), and
    /// the serialization guard `undo()` requires.
    let runner: OperationsRunner
    /// The Edit menu's window onto the undo stack (top label, live).
    let undoMenuState = UndoMenuState()
    /// 13i-d U5 — THE CURRENT WING (`WingState`): the library every surface
    /// reads. Held in memory here; the bootstrap attaches the device's
    /// memory, so no pin ever touches the test host's defaults.
    let wing = WingState()

    /// Phase 13b Stage 1a (N3), HOISTED cross-platform at the mobile S3
    /// ladder (round-1 BLOCKER): ONE `AutosaveCoordinator` per open post.
    /// Three Mac surfaces used to mint their own (Editor / Takes /
    /// BlockTOC), so TWO debounced pipelines could run over one post at
    /// once and flush a stale buffer OVER a newer one — the ordering was
    /// luck. The S3 shell reproduced the same class on the phone (two
    /// alive tab stacks, each able to hold the same post), so the door is
    /// now both platforms': one coordinator per post makes the newest
    /// text win structurally (one pending entry per variant).
    /// Coordinators are cached while held (tiny; since 18k C1 every Mac holder
    /// releases at its end of life, so the cache is bounded by the notes open
    /// — plus, on the Mac, those still owed a leaving savepoint — never by
    /// the notes opened this session). The clock parameters apply when the coordinator is
    /// MINTED — the cache means later callers share the first caller's
    /// clock, which is exactly what the test harness's deterministic
    /// sleep needs; production callers pass nothing.
    ///
    /// **13l L-d — the entries can now be RELEASED**, because one caller
    /// grows this map without bound: the phone's home-screen quick note
    /// takes a coordinator per CAPTURE, and every capture is a different
    /// post, so a day of jotting left a coordinator per jot for
    /// `flushEveryOpenPost` to walk at every filing and every background
    /// flush. See `releaseAutosave(forPost:)`.
    private var postAutosaves: [String: Hold] = [:]

    /// One post's coordinator, with what it takes to let go of it.
    private struct Hold {
        let coordinator: AutosaveCoordinator
        /// The Mac's ⌘Q registration, so releasing takes its registration
        /// with it rather than leaving a closure for a post nothing holds
        /// — and so a later re-mint of the SAME post registers once, not
        /// twice (13l L-d: the traced trap, CLOSED rather than tolerated).
        var quitToken: UUID?
        /// How many callers have asked for this post's coordinator.
        ///
        /// **Over-counting is safe and under-counting is not**, which is
        /// why this counts every call rather than trying to be clever. A
        /// caller that takes a coordinator transiently and never releases
        /// simply keeps the count above zero forever, which is precisely
        /// the behaviour this map had before: the entry stays. Only a
        /// caller that actually releases can bring it to zero.
        ///
        /// *(13l, the ladder's LR-MINOR-2: this used to name `NoteDeletion`
        /// and `ShellActions` as that kind of caller. `NoteDeletion` no
        /// longer mints at all — it flushes through
        /// `flushExistingAutosave(forPost:)`, because its doors routinely
        /// name notes nothing ever opened. 18k C1: neither does
        /// `ShellActions.toggleSeal` — an open post's entry is held by its
        /// surface, and once holds are RELEASED a transient mint that never
        /// released would pin the entry for good.)*
        ///
        /// **18k C1 — every Mac holder now releases, exactly once per
        /// acquisition, at its owner's real end of life** (a view model's
        /// `deinit`; a per-post cache's letting go). That is what brings this
        /// to zero; the Mac's rule for what happens THEN is on
        /// `releaseAutosave(forPost:)`.
        var holders: Int
        #if os(macOS)
        /// Every acquisition this entry has had — a generation. A surface
        /// opening the note moves it, which is how a drop in flight knows the
        /// note was re-opened under it (18k C1).
        var acquisitions = 1
        /// The `acquisitions` value at which a leaving savepoint was last
        /// asked for. Equal to `acquisitions` means the note has been LEFT
        /// and nothing has opened it since (18k C1).
        var leftAtAcquisition: Int?
        var isLeft: Bool { leftAtAcquisition == acquisitions }
        #endif
    }

    func autosave(
        forPost postID: String,
        debounce: Duration = .milliseconds(500),
        sleep: @escaping @Sendable (Duration) async throws -> Void =
            { try await Task.sleep(for: $0) }
    ) -> AutosaveCoordinator {
        if var existing = postAutosaves[postID] {
            existing.holders += 1
            #if os(macOS)
            existing.acquisitions += 1
            #endif
            postAutosaves[postID] = existing
            return existing.coordinator
        }
        let coordinator = AutosaveCoordinator(
            runner: runner, debounce: debounce, sleep: sleep)
        postAutosaves[postID] = Hold(coordinator: coordinator, holders: 1)
        #if os(macOS)
        // The Mac-only riders: the quit door awaits every open post's
        // coordinator, and the W22 first-edit note is wired here because
        // this registry is the one place that knows both halves — which
        // post an edit belongs to, and that every surface editing it
        // shares this coordinator. (The phone has neither a quit door nor
        // the multi-book note; its background flush rides the liveness
        // authority's own bookkeeping.)
        //
        // **13j J11 — ⌘Q IS A LEAVING, and this is the one registration
        // point that already knows every open post.** The quit closure
        // flushes AND savepoints, so quit is covered by construction for
        // every post any surface has opened this session — the same
        // "registered ONCE, covers every surface" property the flush half
        // has had since 13b 1a. `savepointOnLeaving` flushes first itself,
        // so the two halves are one call.
        postAutosaves[postID]?.quitToken = quitFinalize.register { [weak self] in
            await self?.savepointOnLeaving(postID)
        }
        coordinator.onFirstEdit = { [weak self] in
            self?.noteMultiBookEdit(postID)
        }
        #endif
        return coordinator
    }

    /// **Flush a post's pending buffer WITHOUT minting a coordinator for it**
    /// (13l, the end-of-phase ladder's LR-MINOR-2).
    ///
    /// The rule this exists for: a post NO surface has opened has nothing
    /// pending, by construction — the only thing that fills a coordinator is a
    /// surface recording into it. So a caller that only wants "land whatever is
    /// unflushed" gains nothing from `autosave(forPost:)`'s minting arm and
    /// pays for it twice: a permanent map entry `flushEveryOpenPost` walks
    /// forever (the holder count can never reach zero — the caller does not
    /// release), and on the Mac a `quitFinalize` closure registered for a note
    /// nothing holds. `NoteDeletion` reaches this entry precisely because its
    /// doors routinely name notes that were never open — a Library row, or
    /// fifty of them under ⌘-click multi-select. **`runCopying` reaches it for
    /// the same reason** (13l, the ladder's R2-1): the library and pool
    /// duplicate rows name posts that may not be open at all.
    ///
    /// This is `savepointOnLeaving`'s existing-only shape, made a named entry
    /// so the two roads cannot drift; that method's own doc has always carried
    /// the argument for it.
    ///
    /// **It answers whether the post's buffer is CLEAN after the flush** (VM-5
    /// whole-round pass, MINOR 4) — the editor's `flushPendingText` contract,
    /// one layer down. `false` means a write was refused and the coordinator
    /// KEPT the bytes pending (its keep-pending posture — a seal or lock that
    /// landed remotely mid-typing); `true` when nothing is held for the post,
    /// which by the rule above means nothing is pending. A caller whose act
    /// READS or COPIES the store — a version is a copy of the note — must
    /// consult it, or it acts on a store missing her last words while
    /// reporting success (`VersionActs`). Discardable, so the callers that
    /// only want "land whatever can land" read exactly as before.
    @discardableResult
    func flushExistingAutosave(forPost postID: String) async -> Bool {
        guard let coordinator = postAutosaves[postID]?.coordinator else { return true }
        await coordinator.flushNow()
        return !coordinator.isDirty
    }

    /// How many posts this session is holding a coordinator for — the size
    /// of the walk `flushEveryOpenPost` makes (13l L-d). The growth this
    /// fix is about is a claim about a COUNT on BOTH platforms, and only
    /// the Mac has a `quitFinalize` registry to read it from.
    var openAutosaveCount: Int { postAutosaves.count }

    /// How many holders a post's coordinator has right now — zero when the
    /// post has no entry (18k C1). "Exactly one release per acquisition" is a
    /// claim about THIS number, and it is not visible in the entry count:
    /// a surface that acquires on every keystroke, or a discarded view-model
    /// twin that acquired and never released, leaves the entry looking the
    /// same while pinning it forever. The pins read it; nothing in the app
    /// decides anything from it.
    func autosaveHolderCount(forPost postID: String) -> Int {
        postAutosaves[postID]?.holders ?? 0
    }

    /// The posts some surface is HOLDING right now, in any window (18k C1's
    /// holders — a pane, a note window, a book's live editor). Read by the
    /// Mac's structural undo/redo door to ask which notes on screen its act
    /// left dead (the 13n-a walk, WA-3), so it can ride the navigate-away
    /// signal for them. Bounded by what is open, never by the corpus (P1).
    var heldPostIDs: [String] {
        postAutosaves.compactMap { $0.value.holders > 0 ? $0.key : nil }
    }

    /// True while any open note's coordinator holds typed text that has not
    /// landed (pending in its debounce, or a flush in flight). The phone's
    /// first-write furniture reads this to PACE the sample library's story
    /// turns behind her own writing (the pre-13u ladder's F12): a story
    /// import is one serial runner turn, and an autosave queued behind it
    /// waits the whole turn.
    var hasPendingAutosave: Bool {
        postAutosaves.values.contains { $0.coordinator.isDirty }
    }

    /// **Let go of a post's coordinator** (13l L-d).
    ///
    /// The map is a cache with one guarantee — ONE coordinator per post, so
    /// two surfaces editing one note can never run two debounced pipelines
    /// and flush a stale buffer over a newer one (13b 1a's N3, and the S3
    /// ladder's BLOCKER). Nothing ever let go of an entry, which was fine
    /// while every entry was a note she had OPENED; the phone's quick note
    /// broke that assumption by taking one per capture.
    ///
    /// Releasing is **deliberately conservative**: it drops the entry only
    /// when the last holder lets go AND the coordinator has nothing
    /// pending. A dirty coordinator keeps its place, because
    /// `flushEveryOpenPost` and the ⌘Q registration must still be able to
    /// reach unflushed text — dropping it is the one thing that could lose
    /// bytes, so it is the one thing this refuses to do.
    ///
    /// **The traced trap is closed, not tolerated.** The Mac registers a
    /// `quitFinalize` closure when a post's coordinator is minted, so
    /// release-then-re-mint used to mean two registrations for one post
    /// (harmless — `closeAutoCommit` dedupes — but noise nobody chose).
    /// The token now rides in the entry and goes with it, so a re-mint
    /// registers exactly once and a released post leaves no closure behind.
    ///
    /// **ON THE MAC THE LAST RELEASE NEVER DROPS THE ENTRY BY ITSELF (18k
    /// C1).** There the entry is also the note's ⌘Q/lock savepoint — the
    /// quit closure IS `savepointOnLeaving` — and a surface letting go is
    /// not the note being LEFT: a split's unfocused pane keeps showing its
    /// note after its editor unmounts, a mode switch closes one surface
    /// before the next opens, and a note edited inside a book or as a
    /// Compare peer is never reported as left at all. Dropping on the
    /// release would quietly cost each of those its savepoint. So the Mac
    /// drops an entry only through **a leaving savepoint that lands after
    /// the last holder let go** (`savepointOnLeaving`, below): a release of
    /// a note nobody has left keeps it, owed; a release of a note that WAS
    /// left re-takes that leaving savepoint — it flushes first, and it
    /// carries whatever the departing surface wrote on its way out, such as
    /// the open tail its finalize crystallized AFTER the workspace's own
    /// leaving savepoint ran — and the entry goes when it lands. The phone
    /// has no quit registry and keeps the rule above unchanged.
    ///
    /// Returns whether the entry was dropped by THIS call — on the Mac,
    /// never (the drop, when it comes, is the savepoint's).
    @discardableResult
    func releaseAutosave(forPost postID: String) -> Bool {
        guard var hold = postAutosaves[postID] else { return false }
        hold.holders -= 1
        // More releases than acquisitions is the text-loss class (a surviving
        // surface would record into a coordinator the ⌘Q walk can no longer
        // reach): stop the world in DEBUG, never silently.
        assert(hold.holders >= 0, "releaseAutosave: more releases than acquisitions for \(postID)")
        #if os(macOS)
        postAutosaves[postID] = hold
        guard hold.holders <= 0, hold.isLeft else { return false }
        Task { [weak self] in await self?.savepointOnLeaving(postID) }
        return false
        #else
        guard hold.holders <= 0, !hold.coordinator.isDirty else {
            postAutosaves[postID] = hold
            return false
        }
        postAutosaves[postID] = nil
        return true
        #endif
    }

    #if os(macOS)
    /// A leaving savepoint is starting for `postID` (18k C1): mark the note
    /// LEFT at its current generation, and report whether anybody held it as
    /// the savepoint began. Only a savepoint that STARTS with nobody holding
    /// the note may drop the entry — one that starts while a surface is still
    /// finalizing cannot see what that surface writes on its way out, and the
    /// surface's own last release re-takes it instead.
    private func markLeaving(_ postID: String) -> (acquisitions: Int, unheld: Bool)? {
        guard var hold = postAutosaves[postID] else { return nil }
        hold.leftAtAcquisition = hold.acquisitions
        postAutosaves[postID] = hold
        return (hold.acquisitions, hold.holders <= 0)
    }

    /// The Mac's one drop (18k C1): the savepoint landed, and since it began
    /// nobody has opened the note, nobody holds it, and nothing is pending.
    private func dropAfterLeaving(_ postID: String, acquisitions: Int) {
        guard let hold = postAutosaves[postID],
              hold.acquisitions == acquisitions,
              hold.holders <= 0,
              !hold.coordinator.isDirty
        else { return }
        if let token = hold.quitToken { quitFinalize.unregister(token) }
        postAutosaves[postID] = nil
    }
    #endif

    /// **THE SHARED DIVERGE ENTRY — every W23 door rides it** (13f cold
    /// review, R1-4: the Mac's first-edit note button + chip book rows,
    /// and — since parity C2 — the phone's membership chip; SHARED, not
    /// Mac-fenced, for exactly the soul document's reason: mobile never
    /// forks a brain, and this four-line entry IS the flush-first brain).
    /// It flushes the post's pending buffer FIRST, so the copy carries what
    /// she just typed: the note's trigger fires at the FIRST dirty
    /// keystroke, so its offer arrives exactly when the buffer is
    /// guaranteed unflushed — and `copyPost` reads `working_text` rows, so
    /// a click inside the debounce minted a book copy missing the very
    /// keystrokes that summoned it. The insure-before-copy doctrine
    /// (structural undo's auto-commit, the lock family — and, until
    /// 2026-09-04, the retired bridge's landing), applied to the copy door that is offered at the dirty
    /// moment. The pre-existing 11a copy doors (`duplicateAsVersion` /
    /// `promoteLens`) are deliberately untouched — that class goes to
    /// KnownIssues at the closeout (the orchestrator's ruling).
    ///
    /// *(13e E10: that last sentence is RETIRED — the 11a copy doors now
    /// ride `runCopying` below, which is this entry's own flush-first body
    /// made shared. The KnownIssues row it named resolves with that.)*
    func divergeForBook(_ postID: String, in bookID: String) async throws
        -> Operations.DivergeResult {
        try await runCopying(from: postID) { ops in
            try ops.divergePostForReading(postID, in: bookID)
        }
    }

    /// **THE COPY FAMILY'S ONE ENTRY (13e E10 — the KnownIssues row *"Copy
    /// doors read the store past a dirty buffer"*, owner 13e).** Every door
    /// that mints a COPY of a post runs through here, because every one of
    /// them carries the same hazard: the copying operations read
    /// `working_text` ROWS, so a copy taken inside the editor's autosave
    /// debounce lacks the last seconds of typing. The loss is the copy's
    /// completeness, never text — the original still receives the flush —
    /// but a duplicate that silently drops the paragraph she just wrote is
    /// exactly the surprise the insure-before-copy doctrine exists to
    /// prevent.
    ///
    /// The body is `divergeForBook`'s, which the 13f cold review (R1-4)
    /// wrote for the ONE door it was reviewing; 13e's row is the rest of
    /// the family arriving at the same rule rather than growing a second
    /// copy of it.
    ///
    /// **THE FAMILY GREW AT 17b P7 (RUN A, batch A1): a BRANCH is a copy.**
    /// 13e's sweep table was drawn around doors that copy a POST, so the
    /// doors that copy a TAKE — the boards' ⌘T / ＋ new take / diverge-here
    /// and the three whole-post "write new takes" doors — were never in it,
    /// and they ran on the bare runner while Write's identical gesture
    /// (`EditorViewModel.mintCaretTake`) flushed first. `branchVariant` and
    /// `branchAllFans` read `working_text` ROWS exactly as `copyPost` does,
    /// so the same half-second window minted a take without the sentence
    /// she had just typed — and OverallModel §3 says a branch inherits the
    /// CURRENT buffer. They now ride this entry.
    ///
    /// **Where the line sits, and why it is not "flush before every ops
    /// call":** a door that READS stored text to mint from it is a member;
    /// a door that mints EMPTY (`newBlankVariant` — the blank-take family)
    /// is not, because there is nothing for a stale row to spoil, and its
    /// pending keystrokes still land on the take she typed them into. That
    /// negative half is pinned too (`BranchDoorFlushTests`), so the line is
    /// visible rather than assumed.
    ///
    /// **It flushes the EXISTING coordinator and never mints one** (13l, the
    /// ladder's R2-1). The line here used to read *"`flushNow()` on a post
    /// that is not open is a no-op with nothing pending, so the entry is safe
    /// for the library and pool rows"* — true of the FLUSH and false of
    /// everything around it, which is exactly the falsehood LR-MINOR-2
    /// corrected at `NoteDeletion`'s door. `autosave(forPost:)` MINTS on a
    /// miss: a map entry `flushEveryOpenPost` walks forever (this caller
    /// never releases) plus, on the Mac, a `quitFinalize` closure for a note
    /// nothing opened. The library and pool rows duplicate posts that may not
    /// be open at all, so this door met that cost on every press.
    /// Semantics are unchanged: an open source HAS an entry and still
    /// flushes, and a never-opened one has nothing pending by construction.
    func runCopying<T: Sendable>(
        from postID: String, _ body: @escaping @Sendable (Operations) throws -> T
    ) async throws -> T {
        await flushExistingAutosave(forPost: postID)
        return try await runner.run(body)
    }

    /// The copy family's OTHER shape (13e E10's sweep): a copy whose SOURCE
    /// is named by a block, not by a post — `poolDragCopy`, where the block
    /// being dragged lives in some pool the dropping editor cannot name.
    /// Flushing every open coordinator answers it without a lookup, and
    /// costs nothing when nothing is pending (`flushNow` returns
    /// immediately on a clean coordinator).
    ///
    /// **What it actually walks** (13l L-d — the old line said "open posts
    /// are a handful by construction", which stopped being true the moment
    /// the phone's quick note began taking a coordinator per capture): every
    /// post any surface has asked this session about and not released. That
    /// is bounded by a session's activity, never by the corpus — and since
    /// L-d the quick note lets its captures go, which was the one caller
    /// that grew it without bound.
    func flushEveryOpenPost() async {
        for hold in postAutosaves.values {
            await hold.coordinator.flushNow()
        }
    }

    /// **THE SAVEPOINT-ON-LEAVING ENTRY (13j J11 — her sitting-round-1
    /// cadence ruling).** A note has stopped being an open one: flush what
    /// is pending, then leave one quiet savepoint per take that changed.
    ///
    /// **Every leaving road calls THIS and nothing else** — the shell's
    /// shown-notes departure, a window's teardown, ⌘Q (registered above), and
    /// the quick note's filing. Its two lines are the whole per-platform
    /// half of the ruling; everything that DECIDES anything (the dedupe, the
    /// cadence modes, the seal, the vanished container) lives in
    /// `Operations.closeAutoCommit`, so a second platform owes a hook, never
    /// a rule (MobileSoul's brains-in-core line).
    ///
    /// **Flush-first is load-bearing, not tidiness:** `closeAutoCommit` reads
    /// `working_text` ROWS, and the leaving gesture arrives inside the
    /// autosave debounce by construction — she stops typing and navigates.
    /// Without the flush the savepoint would capture the text as of half a
    /// second before the last keystrokes, which is the copy-door class 13e's
    /// E10 closed for the copy family (`runCopying`), arriving here.
    ///
    /// It never throws: a leaving is not a moment to refuse at. The op's own
    /// two quiet no-ops cover the sealed and vanished cases; anything else
    /// (a store error) is swallowed here rather than raised at a surface that
    /// is already gone — nothing was lost, because the flush landed the text
    /// and the next leaving tries again.
    func savepointOnLeaving(_ postID: String) async {
        // The EXISTING coordinator, never a minted one: a post no surface
        // opened has nothing pending by construction, and minting here would
        // cache a coordinator — and, on the Mac, a quit registration — for a
        // note that was never open.
        //
        // (13l L-d — the line that used to follow claimed the quick note was
        // "exactly that case: it mints its note through the operations layer,
        // so there is no buffer to flush". That is INVERTED. The phone's box
        // takes a real coordinator at `adopt` and autosaves the tail it owns
        // through it, which is why its filing flushes before it savepoints
        // and why it now RELEASES the entry afterwards. The reasoning above
        // stands on its own; the example was simply wrong.)
        #if os(macOS)
        // 18k C1: this is also the Mac registry's ONE drop — see
        // `releaseAutosave(forPost:)` for why the release itself never is.
        let leaving = markLeaving(postID)
        #endif
        await flushExistingAutosave(forPost: postID)
        let landed = (try? await runner.run { ops in
            try ops.closeAutoCommit(postID)
        }) != nil
        #if os(macOS)
        // A savepoint that did not land (a locked or failing store) keeps the
        // entry: the note still owes it, and ⌘Q or the lock tries again.
        if landed, let leaving, leaving.unheld {
            dropAfterLeaving(postID, acquisitions: leaving.acquisitions)
        }
        #else
        _ = landed
        #endif
    }

    #if os(macOS)
    /// The focused editor + per-post scroll anchors (text locations, never
    /// pixel offsets — the memo's restore rule). Menu commands route here.
    /// Mac-only: the TK2 editor is the Mac's surface (AppSpec §4).
    let editorRouter = EditorRouter()
    /// Phase 11 (review round 1, MINOR 2): every LIVE editing surface with
    /// its own autosave debounce — the takes board's panes, the TOC's
    /// expanded block — registers a flush here; the quit door awaits them
    /// ALL, not just the focused editor (the Phase 10 quit-door class,
    /// reintroduced by the new surfaces, closed the same way).
    /// (13b 1a refinement: surfaces no longer register themselves — the
    /// per-post autosave registry below registers each coordinator ONCE,
    /// so the quit door covers every surface of every open post by
    /// construction.)
    let quitFinalize = QuitFinalizeRegistry()

    /// **17b row 65 (RUN A batch A1) — where a REFUSED capture waits.**
    /// Session-scoped and in memory, beside `quitFinalize` because it has
    /// the same shape: one of it, however many pad windows come and go.
    /// The pad is a singleton `Window`, so closing it tears down its
    /// `@State` — which is why the words had nowhere to live once a
    /// refusal reached a road that had no pad left.
    let quickNotePark = QuickNotePark()

    /// **RUN A ladder round 2 (the MAJOR, binding 5's sweep) — where a
    /// REFUSED comment draft waits on the Mac.** Session-scoped beside the
    /// quick-note park and for the same reason: `CommentsPanelModel` is
    /// minted per presentation and dies with its sheet or popover, so a
    /// draft the store refused died with it. The phone's park lives on its
    /// comments CONTROLLER (the ruling's letter — that controller outlives
    /// its sheet); the BRAIN is the one shared type either way, so the two
    /// doors cannot drift. PROVISIONAL, QUESTIONS #140.
    let commentDraftPark = CommentDraftPark()

    /// Phase 13b Stage 1b (P-1/P-4): the ONE command-routing brain — the
    /// menu bar/palette/bars route surface commands and mode switches
    /// through this; surfaces register handlers by composition. Replaces
    /// the notification regimes (see `Registry/CommandRouter.swift`).
    let commandRouter = CommandRouter()
    /// Phase 13b Stage 1b (AD-14): the ONE status/refusal presentation —
    /// transient outcomes land here and render as the shell's toast.
    let status = StatusCenter()

    /// The window's recently-visited books, most recent first — wired by the
    /// shell to ITS workspace (the `openNoteCount` idiom: the workspace is
    /// per-window state and this session is the app's, so a closure is what
    /// keeps the two straight). W22's button reads it to name its target.
    @ObservationIgnored var recentBookIDs: () -> [String] = { [] }

    /// W22's body: flag first (so the common case costs a `UserDefaults`
    /// read and nothing else), then ONE membership read off the main thread
    /// (P2), then the sentence — once, ever. Writes no store bytes.
    ///
    /// 13f batch 5: the note CARRIES W23's door (her round-10 item 4 — *"not
    /// just an FYI"*). The target is the first CURATED book in the chooser's
    /// own order, which is ONE rule that reduces to "the book you came from"
    /// in exactly the case that matters, because arriving at a book floats it
    /// to the top of that order. No curated book (every membership derived)
    /// ⇒ the note speaks without a button rather than guessing a target.
    private func noteMultiBookEdit(_ postID: String) {
        guard !MultiBookEditNote.hasBeenSeen() else { return }
        Task { @MainActor [weak self] in
            guard let self else { return }
            // VX-111: BOOKS only — a gathering the note appears in holds
            // nothing, so it never counts toward "in N books".
            let books = MultiBookEditNote.memberBooks((try? await self.database.read { db in
                try Queries.readingsContaining(db, postID: postID)
            }) ?? [])
            guard MultiBookEditNote.shouldSpeak(
                bookCount: books.count, seen: MultiBookEditNote.hasBeenSeen())
            else { return }
            MultiBookEditNote.markSeen()
            let target = MultiBookEditNote.divergeTarget(
                books, recentlyVisited: self.recentBookIDs())
            // 13u2 UNIT E (row 56): the class is READ here rather than
            // inferred from whether an action rode along — with a book to
            // diverge into this is an OFFER (a question with a button);
            // without one it is the plain note it always was. Byte-identical
            // to what `speak(_:action:)` delivered, said out loud.
            let sentence = MultiBookEditNote.sentence(bookCount: books.count)
            if let book = target {
                self.status.offer(
                    sentence,
                    action: StatusCenter.Item.Action(
                        label: DivergeCopy.buttonLabel(book: book.name),
                        perform: { [weak self] in
                            self?.divergeFromNote(postID, in: book)
                        }))
            } else {
                self.status.refuse(sentence)
            }
        }
    }

    /// The note's button, acting: the ONE operation, reported in the ONE
    /// status voice (the button's own toast is already dismissed by then).
    private func divergeFromNote(_ postID: String, in book: Reading) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                _ = try await self.divergeForBook(postID, in: book.id)
                self.status.receipt(DivergeCopy.done(book: book.name))  // 18i: it landed
            } catch {
                self.status.refuse(DivergeCopy.refusal(for: error, book: book.name))
            }
        }
    }

    /// 13b Stage 4, Batch 4B (S4-23 ruling 3): the merge ceremony's
    /// per-SESSION join memory — the last CONFIRMED join choice seeds the
    /// next sheet's pairings; a fresh launch resets to the canon default
    /// (one AppSession per launch; parallel test worlds stay independent).
    var mergeJoinMemory: MergeJoin?

    /// The use-report round, 18d batch 2 (her ruling U-9): **This Note's
    /// Tray's last view and filter, per SESSION** — the same shape and the
    /// same reason as the join memory above. A fresh launch opens the tray
    /// on Leaving · all; within a launch the panel comes back where she left
    /// it, whichever note or scraps area it is the tray of (the choice is
    /// about how she is READING the tray, not about one note's contents).
    var trayViewMemory = TrayViewMemory()

    /// 13b Stage 2 ladder (NIT-6): the tutorial doors' in-flight latch —
    /// a double-pressed Restore must never race two discoveries into two
    /// live field guides. Session-scoped (parallel test worlds stay
    /// independent); `begin` runs synchronously at PRESS time, so the
    /// second press bails before any await can interleave.
    private(set) var tutorialDoorInFlight = false

    func beginTutorialDoor() -> Bool {
        if tutorialDoorInFlight { return false }
        tutorialDoorInFlight = true
        return true
    }

    func endTutorialDoor() {
        tutorialDoorInFlight = false
    }

    /// **18k C5 (17e P33): the structural undo/redo DOOR's in-flight latch —
    /// the phone's rule, adopted.** ⌥⌘Z reads the stack across two runner
    /// submissions (the A12 warning, then the undo), so a second press — or a
    /// ⇧⌥⌘Z — landing inside that gap acts on an entry nobody was asked
    /// about. `MobileUndoDoor.inFlight` holds ONE flight across both doors
    /// for exactly that reason; this is the Mac's copy, session-scoped
    /// because `ShellActions` is a value built per menu read (one stack per
    /// session, so one latch per session). `begin` runs synchronously at
    /// PRESS time, before any await — the tutorial door's shape above.
    private(set) var structuralUndoDoorInFlight = false

    func beginStructuralUndoDoor() -> Bool {
        if structuralUndoDoorInFlight { return false }
        structuralUndoDoorInFlight = true
        return true
    }

    func endStructuralUndoDoor() {
        structuralUndoDoorInFlight = false
    }
    #endif

    init(database: AppDatabase, storeVariant: AppDatabase.StoreVariant = .real) {
        @Dependency(\.date) var date
        self.clock = date
        self.database = database
        self.storeVariant = storeVariant
        self.seededBookMarkIsSet = { book in
            SampleLibrarySeeder.isMarkedSeeded(storeVariant: storeVariant, book: book)
        }
        self.markSeededBook = { book in
            SampleLibrarySeeder.markSeeded(storeVariant: storeVariant, book: book)
        }
        let undo = UndoStack()
        self.undoStack = undo
        let ops = Operations(undoStack: undo)
        self.operations = ops
        self.runner = OperationsRunner(operations: ops)
        // The stack mutates on the runner's executor; the menu mirror
        // refreshes on main. (Captures the state object and the stack, never
        // self — no cycle through the session.)
        let menuState = undoMenuState
        undo.setChangeObserver {
            Task { @MainActor in menuState.refresh(from: undo) }
        }
        #if os(macOS)
        // 13b 1b composition wiring: routed speech lands in the status
        // center; the router's context reads the observable editor router
        // and undo mirror (so menu enablement tracks them).
        let status = self.status
        commandRouter.refuse = { status.refuse($0) }
        let editorRouter = self.editorRouter
        commandRouter.writeEditorAttached = { editorRouter.active != nil }
        // QoL batch 3 (L6): the find family needs the editor that owns a
        // scroll view — the inline book/spread/pool editors attach with
        // `scrollView: nil` and must never render the find doors enabled.
        commandRouter.writeEditorOwnsScrollView = { editorRouter.active?.scrollView != nil }
        commandRouter.undoAvailable = { menuState.topLabel != nil }
        commandRouter.redoAvailable = { menuState.topRedoLabel != nil }
        // 13n-c Stage B R1 B6: ⌘L's gate reads the library's wing count (an
        // observable fact on the session's own `WingState` — no window owns it).
        let wing = self.wing
        commandRouter.wingCount = { wing.wingCount }
        #endif
    }
}


#if os(macOS)
/// The quit door's finalize registry (Phase 11, review round 1, MINOR 2):
/// weak-closure entries so a dead surface no-ops; surfaces unregister at
/// teardown. `finalizeAll` runs every entry — the delegate awaits it
/// beside the focused editor's own finalize before replying to ⌘Q.
@MainActor
final class QuitFinalizeRegistry {
    private var entries: [UUID: @MainActor () async -> Void] = [:]

    var isEmpty: Bool { entries.isEmpty }
    /// How many closures are registered (13l L-d): the double-registration
    /// trap is a claim about a COUNT, and a pin should be able to read it
    /// rather than infer it from a side effect.
    var count: Int { entries.count }

    func register(_ flush: @escaping @MainActor () async -> Void) -> UUID {
        let token = UUID()
        entries[token] = flush
        return token
    }

    func unregister(_ token: UUID) {
        entries[token] = nil
    }

    func finalizeAll() async {
        for flush in entries.values {
            await flush()
        }
    }
}
/// **THE QUICK-NOTE PARK — a refused capture, and nothing else** (17b row
/// 65, RUN A batch A1; the orchestrator's ruling, Option 1 + the 1b rider,
/// both PROVISIONAL — QUESTIONS #137).
///
/// The pad's words live in `QuickNotePad.text` and NOWHERE else until a
/// note holds them. 13u3 UNIT C made a refusal KEEP them, which is right on
/// the ⏎/⌘⏎ road where the pad stays open — and empty on the two roads that
/// have no pad left afterwards: CLOSING it (the `@State` pad dies with the
/// singleton window) and QUITTING (the outcome was discarded outright).
///
/// **It holds REFUSED captures only** (binding 1). A close with nothing
/// refused still FILES, exactly as her round-14.2 grammar says, and an
/// empty pad still keeps nothing — so this can never quietly widen into a
/// general draft-keeper. A guard pin asserts that.
///
/// **It is MEMORY-ONLY, deliberately** (binding 6's ratify note): her prose
/// never lands in plaintext beside the encrypted store, and the refusal's
/// commonest cause — a locked or unreachable store — is exactly the state
/// in which no key exists to seal a persisted park, so a disk-backed one
/// would fail precisely when it was needed. The cost is stated rather than
/// hidden: a crash or a forced second quit still loses the capture, bounded
/// by one summon, which is the pad's own cost model. And one timing window
/// belongs on the same ledger (ladder round 2, NIT — its own class, strictly
/// neither a crash nor a forced quit): the CLOSE road's refusal lands
/// asynchronously (`onDisappear` spawns the filing task), so a ⌘Q pressed
/// inside that flight is decided before the park is armed and quits
/// UNDECLINED — the quit road itself has no such window, because its own
/// filing runs before the decision by construction, and parking
/// optimistically at close would hold unrefused captures, which binding 1
/// forbids.
@MainActor
@Observable
final class QuickNotePark {
    /// What a refusal left behind.
    struct Held: Equatable {
        var text: String
        var titleFromFirstWords: Bool
        /// The sentence the refusal spoke — re-spoken if a quit is declined
        /// with no pad on screen to carry it.
        var message: String
    }

    private(set) var held: Held?
    /// The 1b rider's one-shot (binding 4). Spent by a decline; re-armed
    /// whenever a capture is parked afresh, so a refusal resolved and later
    /// arising again gets its own single decline.
    private var declineSpent = false
    /// Set by the pad's own lifetime, so a declined quit knows whether a
    /// window is on screen to speak the refusal (binding 4's "leaves the
    /// pad on screen speaking its refusal line").
    var isPadShowing = false

    init() {}

    /// A refusal that reached a road with no pad left.
    func park(text: String, titleFromFirstWords: Bool, message: String) {
        // The one call site (`take()`'s `.refused` arm) fires only after
        // `QuickNoteMint.mints` passed, so a blank capture cannot arrive
        // here — and the silent early-out that used to stand on this line
        // was the wrong failure mode for an impossibility: the only thing
        // it could ever do is quietly eat a refused capture, which is
        // binding 1 inverted (ladder round 1, NIT). Loud in debug; parked
        // like any capture in release.
        assert(!text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
               "a refused capture is never blank — take() guards mints() before the mint")
        // **The 1b one-shot re-arms only when a refusal is ARISING** — the
        // park was empty (ladder round 1, MAJOR). The quit road's own
        // `finalizeAll` re-files the pad on EVERY ⌘Q, and a store that
        // keeps refusing re-parks the SAME standing capture — so an
        // unconditional re-arm here declined the quit forever while the pad
        // was open, binding 4 inverted ("a second consecutive ⌘Q always
        // proceeds"). A RESOLUTION (`clear()`, at `.filed` /
        // `.nothingToFile` / restore) resets the flag, so "a refusal
        // resolved and later re-arising re-arms" holds byte-exactly — and
        // the newest text still wins the park either way.
        if held == nil { declineSpent = false }
        held = Held(text: text, titleFromFirstWords: titleFromFirstWords, message: message)
    }

    /// The next summon takes it — and the park lets go in the same breath
    /// (binding 2): the pad becomes the only home again, so there is no
    /// ghost copy and no double restore. A re-refusal re-parks.
    func restore() -> Held? {
        defer { clear() }
        return held
    }

    /// Filed, or nothing to file: the park holds nothing (binding 2).
    func clear() {
        held = nil
        declineSpent = false
    }

    /// **The 1b rider.** `true` exactly once while a refused capture
    /// stands — macOS's unsaved-work grammar, bounded so she can never be
    /// trapped by a store that will not take it: a second consecutive ⌘Q
    /// always proceeds.
    func declineQuitOnce() -> Bool {
        guard held != nil, !declineSpent else { return false }
        declineSpent = true
        return true
    }
}

#endif
