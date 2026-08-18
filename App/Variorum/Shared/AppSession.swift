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
    /// The session-scoped structural undo stack (AppSpec §9) — in-memory,
    /// never persisted. (On the Mac it wires to the Edit menu; the phone
    /// registers entries where its structural doors do — divide, merge,
    /// delete, the takes browser's archive/delete-variant, the chip's
    /// diverge — with no undo UI yet: C2 ladder R1-4/R2-N1 corrected the
    /// older "no structural ops on mobile" claim this line carried.)
    let undoStack: UndoStack
    let operations: Operations
    /// Serial off-main executor for every operations-layer write (P2), and
    /// the serialization guard `undo()` requires.
    let runner: OperationsRunner
    /// The Edit menu's window onto the undo stack (top label, live).
    let undoMenuState = UndoMenuState()

    /// Phase 13b Stage 1a (N3), HOISTED cross-platform at the mobile S3
    /// ladder (round-1 BLOCKER): ONE `AutosaveCoordinator` per open post.
    /// Three Mac surfaces used to mint their own (Editor / Takes /
    /// BlockTOC), so TWO debounced pipelines could run over one post at
    /// once and flush a stale buffer OVER a newer one — the ordering was
    /// luck. The S3 shell reproduced the same class on the phone (two
    /// alive tab stacks, each able to hold the same post), so the door is
    /// now both platforms': one coordinator per post makes the newest
    /// text win structurally (one pending entry per variant).
    /// Coordinators are session-cached (tiny; bounded by posts opened per
    /// session). The clock parameters apply when the coordinator is
    /// MINTED — the cache means later callers share the first caller's
    /// clock, which is exactly what the test harness's deterministic
    /// sleep needs; production callers pass nothing.
    private var postAutosaves: [String: AutosaveCoordinator] = [:]

    func autosave(
        forPost postID: String,
        debounce: Duration = .milliseconds(500),
        sleep: @escaping @Sendable (Duration) async throws -> Void =
            { try await Task.sleep(for: $0) }
    ) -> AutosaveCoordinator {
        if let existing = postAutosaves[postID] { return existing }
        let coordinator = AutosaveCoordinator(
            runner: runner, debounce: debounce, sleep: sleep)
        postAutosaves[postID] = coordinator
        #if os(macOS)
        // The Mac-only riders: the quit door awaits every open post's
        // coordinator, and the W22 first-edit note is wired here because
        // this registry is the one place that knows both halves — which
        // post an edit belongs to, and that every surface editing it
        // shares this coordinator. (The phone has neither a quit door nor
        // the multi-book note; its background flush rides the liveness
        // authority's own bookkeeping.)
        _ = quitFinalize.register { [weak coordinator] in
            await coordinator?.flushNow()
        }
        coordinator.onFirstEdit = { [weak self] in
            self?.noteMultiBookEdit(postID)
        }
        #endif
        return coordinator
    }

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
    /// (structural undo's auto-commit, `applyBridgeLanding`, the lock
    /// family), applied to the copy door that is offered at the dirty
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
    /// copy of it. `flushNow()` on a post that is not open is a no-op with
    /// nothing pending, so the entry is safe for the library and pool rows,
    /// which duplicate posts that may not be open at all.
    func runCopying<T: Sendable>(
        from postID: String, _ body: @escaping @Sendable (Operations) throws -> T
    ) async throws -> T {
        await autosave(forPost: postID).flushNow()
        return try await runner.run(body)
    }

    /// The copy family's OTHER shape (13e E10's sweep): a copy whose SOURCE
    /// is named by a block, not by a post — `poolDragCopy`, where the block
    /// being dragged lives in some pool the dropping editor cannot name.
    /// Flushing every open coordinator answers it without a lookup, and
    /// costs nothing when nothing is pending (`flushNow` returns
    /// immediately on a clean coordinator). Open posts are a handful by
    /// construction — this is not a corpus walk.
    func flushEveryOpenPost() async {
        for coordinator in postAutosaves.values {
            await coordinator.flushNow()
        }
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
            let books = (try? await self.database.read { db in
                try Queries.readingsContaining(db, postID: postID)
            }) ?? []
            guard MultiBookEditNote.shouldSpeak(
                bookCount: books.count, seen: MultiBookEditNote.hasBeenSeen())
            else { return }
            MultiBookEditNote.markSeen()
            let target = MultiBookEditNote.divergeTarget(
                books, recentlyVisited: self.recentBookIDs())
            self.status.speak(
                MultiBookEditNote.sentence(bookCount: books.count),
                action: target.map { book in
                    StatusCenter.Item.Action(
                        label: DivergeCopy.buttonLabel(book: book.name),
                        perform: { [weak self] in
                            self?.divergeFromNote(postID, in: book)
                        })
                })
        }
    }

    /// The note's button, acting: the ONE operation, reported in the ONE
    /// status voice (the button's own toast is already dismissed by then).
    private func divergeFromNote(_ postID: String, in book: Reading) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                _ = try await self.divergeForBook(postID, in: book.id)
                self.status.speak(DivergeCopy.done(book: book.name))
            } catch {
                self.status.speak(DivergeCopy.refusal(for: error, book: book.name))
            }
        }
    }

    /// 13b Stage 4, Batch 4B (S4-23 ruling 3): the merge ceremony's
    /// per-SESSION join memory — the last CONFIRMED join choice seeds the
    /// next sheet's pairings; a fresh launch resets to the canon default
    /// (one AppSession per launch; parallel test worlds stay independent).
    var mergeJoinMemory: MergeJoin?

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
    #endif

    init(database: AppDatabase) {
        self.database = database
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
        commandRouter.speak = { status.speak($0) }
        let editorRouter = self.editorRouter
        commandRouter.writeEditorAttached = { editorRouter.active != nil }
        // QoL batch 3 (L6): the find family needs the editor that owns a
        // scroll view — the inline book/spread/pool editors attach with
        // `scrollView: nil` and must never render the find doors enabled.
        commandRouter.writeEditorOwnsScrollView = { editorRouter.active?.scrollView != nil }
        commandRouter.undoAvailable = { menuState.topLabel != nil }
        commandRouter.redoAvailable = { menuState.topRedoLabel != nil }
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
#endif
