//
//  BlockHistoryPane.swift
//  Variorum (Mac)
//
//  **THE POST-13L POLISH ROUND, BATCH 4 — LEDGER ROW 17 (G2): THE ONE BLOCK
//  HISTORY PANE.**
//
//  Her second-sitting ruling, verbatim: *"I know I just ruled that history
//  should go in the block menu, but I think I'm changing my mind and it should
//  be in the bottom chrome — my reasoning is that history is quite similar to
//  commit, it's the natural pair to commit."* So the door sits beside Commit
//  on BOTH bars (write a moment · see the moments — the bar becomes the
//  block's time controls) and opens THIS: one cohesive side panel with four
//  regions, in order —
//
//    1. **Savepoint runs** — ALL of the block's live takes, sectioned, the
//       take you're in expanded (her ruling). Restore per row.
//    2. **Archived takes** — set aside, never gone, with Unarchive.
//    3. **Deleted takes** — on the 30-day clock, with Put back. **NO purge
//       door here** (row 21's letter: Delete Now lives on TRASH SURFACES —
//       the global Trash and the note's leaving section — never here).
//    4. **Came from** — the lineage region: ALL of a merge's originals (the
//       13l walk's P-3 fix — the old door showed one of two), each with its
//       text and a ONE-BUTTON way back into the note.
//
//  ── WHAT THIS ABSORBS, AND WHY IT IS ONE SURFACE AND NOT FOUR ────────────
//  Three faces used to answer parts of "what has this block been?" — Write's
//  inline `CommitHistoryView` strip, the Takes bar's history sheet, and the
//  J3 lineage peek with its own nested tray sheet — and none of them answered
//  all of it. Her F2 report is the proof it mattered: she FOUND the deleted
//  take, in the History face, and still could not tell whose history she was
//  reading (*"it's unclear that history is under Note, that makes it seem
//  like the Note's history"*). One pane, one door, one name. Her stated
//  teaching intent binds the design: *"the 'Block history' pane will be a
//  strong memory and the expectations are clear."*
//
//  ── READ-CHEAP TIER ONLY (P3) ────────────────────────────────────────────
//  Every take in here is a `Text`. Nothing in a history pane is ever a live
//  editor — this is a look at what a block has been, not a place to write.
//
//  ── THE HELD OBSERVATION (adjudication 2, RECORD-ONLY) ───────────────────
//  As a side panel this can stand open while she types, and its projection
//  reads `variant` and `commit_point` — so GRDB re-runs it when a buffer is
//  autosaved. P1 is not breached: the re-read's cost is ∝ this block's own
//  fan and savepoint history, never the note's length or the corpus. What
//  changed is the FREQUENCY, which is the tray panel's own class one surface
//  over; the architect's adjudication is record-only for both, and no
//  debounce machinery is built here.
//

import Foundation
import GRDB  // AsyncValueObservation iteration
import Observation
import SwiftUI
import VariorumCore

/// **THE MAC'S OWN WORDS FOR THE BLOCK HISTORY DOOR.**
///
/// The vocabulary itself moved to `Shared/BlockHistoryFace.swift` at mobile
/// round 2 batch 6a, when the phone grew its own Block History face. What
/// stayed is exactly what names a MAC door or a MAC chord — a shared home is
/// the wrong place for a sentence that points at one platform's bottom bar
/// (MobileSoul §4.4's no-redirect rule, read from the other side).
nonisolated extension BlockHistoryPath {
    /// The bar's door label. Lowercased by the voice like its neighbour
    /// ("commit ⌘S"); the pairing IS the teaching moment (her G4 chapter:
    /// write a moment · see the moments).
    static let doorLabel = "history"

    /// How copy elsewhere points at the door.
    static let doorPhrase = "the history door in the note's bottom bar"

    static var cameFromPathWithDoor: String { "\(cameFromPath) (\(doorPhrase))" }

    static let noSavepoints = "No saved moments yet \u{2014} \u{2318}S saves one."

    /// **THE CURRENT-BLOCK JUMP** (the post-13l polish round, ledger row 33 —
    /// her 2026-08-25 refinement on the ratified request scoping): *"i think
    /// the history pane staying on the block you asked about is fine, but if
    /// you've changed blocks there should be a small button or something to
    /// show current block's history, so you don't have to close it and reopen
    /// it."*
    ///
    /// The pane stays scoped to the block the REQUEST named — following the
    /// caret would mean a panel that jumps while she types — so the door is
    /// the way out of that scoping, and it renders ONLY while the two really
    /// differ (a button that could not move the pane is a door that cannot
    /// act, which P-2 says is not rendered at all).
    ///
    /// **Mac-only by construction**: the phone's Block History is a sheet
    /// that covers the page and stands its editor down, so its caret cannot
    /// move while the face is open — there is no jump to offer.
    static let jumpVerb = "Show the block you're in"
    static let jumpHelp =
        "Your cursor has moved to a different block — this points the panel at "
        + "that block's history instead, without closing it"

    /// **Row 28 (the Act 10 correction round): the savepoints region's one
    /// meaning line** — her ask nearly verbatim ("Savepoints: this take's
    /// saved moments"); the other three regions already carried theirs.
    static let savepointsExplainer =
        "Each take's saved moments \u{2014} Restore loads one back into its buffer."

    // MARK: VX-431 (the VX-440 run) — each region's ONE line

    /// **The regions' meaning lines, cut to one line each** — the
    /// `ExplainerLine` idiom (her R-VX184-6 for the MCP pane: *"every
    /// explainer cut to one line with the full text behind an (i)"*), which
    /// the clarity pass adopts for her "cluttered and wordy". The WHOLE
    /// sentences are the shipped ones, kept verbatim behind the (i)
    /// (`savepointsExplainer` above is pinned word for word); these are the
    /// summaries. Mac-local, like the rest of this extension: the phone's
    /// Block History is untouched by this batch. PROVISIONAL words (P-440-10).
    static let savepointsLine = "Each take's saved moments."
    static let archivedLine = "Set aside, out of the fan."
    static let deletedLine = "On the \(TrashWindow.days)-day clock."
    static let cameFromLine = "Kept whole and set aside \u{2014} not deleted."

    /// The open commit row's door to the whole moment (R-440-3: "a 'read in
    /// full' door opens a sheet with the whole text"). PROVISIONAL (P-440-10).
    static let readInFullVerb = "Read in full"
    static let readInFullHelp =
        "The whole of this saved moment, to read and select \u{2014} with Restore and "
        + "Bring back as a take beside it"

    /// **The read-in-full sheet's title** (R-440-3: "titled by the commit's
    /// name else 'Commit · ‹date›'") — the date in the row's own stamp form.
    static func readingTitle(_ commit: CommitPoint, now: Date) -> String {
        SavepointRowFace.name(commit)
            ?? "Commit \u{B7} \(CommitRowFace.stamp(commit.createdAt, now: now))"
    }

    /// **Bring back as a take** (R-440-3's second foot door; the op is
    /// `Operations.bringBackCommitAsTake`). PROVISIONAL words (P-440-4/-10).
    static let bringBackAsTakeVerb = "Bring back as a take"
    static let bringBackAsTakeHelp =
        "Makes this saved moment a take of its own on this block \u{2014} the last in "
        + "its fan, never chosen \u{2014} so you can read it and work on it in the editor. "
        + "The moment itself stays"

    /// The act's receipt (P-440-4: "a quiet receipt names the act"), naming
    /// the take by the label it was born with when the moment had a name.
    static func broughtBackAsTake(label: String?) -> String {
        guard let label else {
            return "Brought back as a take \u{2014} it's the last take in this block's fan."
        }
        return "Brought back as the take \u{201C}\(label)\u{201D} \u{2014} it's the last "
            + "take in this block's fan."
    }
}

@MainActor
@Observable
final class BlockHistoryModel {
    @ObservationIgnored private let session: AppSession
    let postID: String
    let blockID: String
    let focusedVariantID: String?

    private(set) var history = Queries.BlockHistory()
    private(set) var loaded = false

    /// **A receipt is not a refusal** — the tray's own split (ledger row 6),
    /// classed where the message is produced and never guessed from its text.
    private(set) var status: TrayViewModel.Status?

    /// **Is the note this block lives in SEALED?** (13u4 UNIT S3 —
    /// KnownIssues row 69.) The pane had no seal fact at all, so its rename
    /// door opened a NAME FIELD under a sealed note and refused only at ⏎ —
    /// she typed a name into a field that could never keep it. `false` until
    /// the watch below lands, which is the safe direction: the worst a stale
    /// `false` can do is open the field one beat early, and the op's own
    /// refusal is still the backstop underneath.
    private(set) var sealed = false

    /// The pre-split confirm (AppSpec §9's documented behaviour): a commit
    /// older than the newest live divide/extract on this block still holds
    /// the pre-split text, so restoring it resurrects both halves.
    var pendingRestore: PendingRestore?

    nonisolated struct PendingRestore: Identifiable, Equatable, Sendable {
        let variantID: String
        let commit: CommitPoint
        var id: String { commit.id }
    }

    /// **The moment open in the read-in-full sheet** (VX-431 — R-440-3), or
    /// nil. A fact on the model rather than a view's private state, for row
    /// 69's reason: a claim about what a door opens has to be checkable.
    var reading: CommitReading?

    nonisolated struct CommitReading: Identifiable, Equatable, Sendable {
        let commit: CommitPoint
        /// The take the moment was saved from — Restore's target.
        let variantID: String
        /// That take's heading, as its run in the pane names it.
        let takeHeading: String
        var id: String { commit.id }
    }

    init(
        session: AppSession, postID: String, blockID: String,
        focusedVariantID: String? = nil
    ) {
        self.session = session
        self.postID = postID
        self.blockID = blockID
        self.focusedVariantID = focusedVariantID
    }

    /// Held only while the pane is on screen — the view's `.task` owns the
    /// lifetime, so the observation of `variant`/`commit_point` never stands
    /// over a typing burst on a pane nobody is looking at.
    func start() async {
        do {
            for try await value in session.database.observeBlockHistory(
                blockID, now: session.now
            ) {
                adopt(value)
            }
        } catch is CancellationError {
        } catch {
            status = .refusal(String(describing: error))
        }
    }

    /// **The seal fact, held only while the pane is on screen** (row 69).
    ///
    /// A WATCH rather than a one-shot read, deliberately: she can unseal from
    /// the masthead with this pane open, and a door that stays hidden until
    /// the pane is re-opened is a capability she cannot find — the same
    /// lie as the field that opened and could not keep her name, pointing
    /// the other way. It is one row by primary key, off-main, held only
    /// while the pane is up; it joins KnownIssues row 13's
    /// panes-re-query-at-autosave-cadence class at that class's cheapest
    /// end, and it is named in this unit's record rather than slipped in.
    func watchSeal() async {
        do {
            for try await header in session.database.observeContainerHeader(postID) {
                sealed = header?.locked == true
            }
        } catch is CancellationError {
        } catch {
            // A seal we cannot read is not a refusal to show her: the offer
            // stands and the operation's own guard answers (the backstop).
            sealed = false
        }
    }

    /// Internal so tests drive the pane deterministically (the
    /// `TrayViewModel.adopt` seam).
    func adoptSeal(_ sealed: Bool) { self.sealed = sealed }

    /// Internal so tests drive the pane deterministically (the
    /// `TrayViewModel.adopt` seam).
    func adopt(_ value: Queries.BlockHistory) {
        history = value
        loaded = true
    }

    var isEmpty: Bool { history.isEmpty }

    /// **The Commits region's count** (VX-431 — region headers carry their
    /// counts): every saved moment of every LIVE take the region lists, the
    /// quiet ones folded into runs included — the number of moments, not of
    /// rows.
    var commitCount: Int {
        history.activeTakes.reduce(0) { $0 + (history.savepoints[$1.id]?.count ?? 0) }
    }

    /// Which savepoint run this pane opens with (her ruling: every take is
    /// sectioned, the one she is in is expanded).
    ///
    /// **The rule itself moved to `Shared/BlockHistoryExpansion` at mobile
    /// round 2 batch 6a** — a phone that opened a different take than the Mac
    /// would be answering one ruling twice. This is the forwarder, kept so
    /// every shipped pin rides unmodified (the 3C parity pattern).
    static func initiallyExpanded(
        _ history: Queries.BlockHistory, focused: String?
    ) -> Set<String> {
        BlockHistoryExpansion.initiallyExpanded(history, focused: focused)
    }

    /// **Where the jump door would go, or nil** (ledger row 33). A pure rule,
    /// so the DECISION is pinned without rendering anything: the caret's block
    /// must be in the SAME note as this pane and a DIFFERENT block from the one
    /// it is showing. Anything else — an unknown caret, a caret in another
    /// note's pane, a caret in the very block on screen — is no jump, and the
    /// door does not render (P-2).
    ///
    /// It returns a ready-made request rather than an id, so the take she is
    /// standing in rides along and her *"the focused take's expanded"* ruling
    /// survives the jump.
    static func jumpTarget(
        _ focused: FocusedBlock?, postID: String, blockID: String
    ) -> BlockHistoryRequest? {
        guard let focused, focused.postID == postID, focused.blockID != blockID
        else { return nil }
        return BlockHistoryRequest(
            postID: postID, blockID: focused.blockID,
            focusedVariantID: focused.variantID)
    }

    func predatesSplit(_ commit: CommitPoint) -> Bool {
        CommitRules.predatesSplit(
            commitDate: commit.createdAt, splitDates: history.splitDates)
    }

    // MARK: - Region 1: restore a savepoint

    /// Restore a saved moment into its take's buffer.
    ///
    /// **It flushes the post's pending buffer FIRST**, and that is not
    /// optional: the editor debounces autosaves, so a restore landing while a
    /// keystroke is still pending would be overwritten by that flush moments
    /// later. `EditorViewModel.restore` has always done this for the strip
    /// this pane replaces; the pane reaches the same coordinator through the
    /// session's existing-only road (`flushExistingAutosave`), which never
    /// mints one for a post no surface has opened.
    func restore(_ commit: CommitPoint, of variantID: String, confirmed: Bool = false)
        async
    {
        if !confirmed, predatesSplit(commit) {
            pendingRestore = PendingRestore(variantID: variantID, commit: commit)
            return
        }
        pendingRestore = nil
        status = nil
        await session.flushExistingAutosave(forPost: postID)
        do {
            try await session.runner.run { ops in
                try ops.restoreCommit(variantID, commitID: commit.id)
            }
            status = .receipt(BlockHistoryCopy.restoredSavepoint)
            // VX-431 (item 4): the restore LANDED — say where, on the writing
            // surface beside this pane (`RestoreLanding`: a signal each
            // surface decides about for itself).
            session.commandRouter.pendingRestoreLanding = RestoreLanding(
                postID: postID, blockID: blockID, variantID: variantID, text: commit.text)
        } catch let error as OperationError {
            status = .refusal(TrayRefusalCopy.message(for: error))
        } catch {
            status = .refusal(DeletionRefusal.fallback(error))
        }
    }

    func confirmPendingRestore(_ pending: PendingRestore) async {
        await restore(pending.commit, of: pending.variantID, confirmed: true)
    }

    /// **NAMING A SAVED MOMENT AFTER THE FACT** (13u3 UNIT D — her ruling
    /// R-13u3-1: *"Editable"*, a rename door in Block History beside the
    /// savepoint).
    ///
    /// Offered on MANUAL AND QUIET savepoints alike — her selection was the
    /// unqualified "Editable", and a quiet moment is exactly the one she is
    /// most likely to want to label ("the one before I left"). The `kind` is
    /// untouched, so a renamed quiet savepoint still reads as quiet and its
    /// occasion stays visible.
    ///
    /// No flush here, unlike `restore`: this writes METADATA on an immutable
    /// snapshot, so there is no buffer race to lose — the whole reason the
    /// rename is cheap is that it cannot reach any text.
    /// **Does the rename door open its NAME FIELD?** (row 69.) The branch is
    /// a fact on the model rather than an `if` inside a private view body,
    /// for UNIT S1's own reason one file over: a claim about what a door
    /// offers has to be checkable.
    var renameOpensTheField: Bool { !sealed }

    /// **The sealed answer to the rename door** (row 69). The pane's grammar
    /// is uniformly act-then-worded-refusal under a seal — Restore does
    /// exactly this — so the door still ACTS and still SPEAKS; what it no
    /// longer does is open a field she would type a name into and lose. The
    /// sentence is the standing one (`TrayRefusalCopy`, the `lockedPost`
    /// arm), not new copy.
    func refuseRenameUnderSeal() {
        status = .refusal(TrayRefusalCopy.message(
            for: OperationError.lockedPost(id: postID)))
    }

    func rename(_ commit: CommitPoint, to name: String?) async {
        status = nil
        do {
            let wrote = try await session.runner.run { ops in
                try ops.renameCommitPoint(commit.id, message: name)
            }
            // A receipt reports an act that LANDED (18i's grammar), and the
            // OP's own answer says whether one did: ⏎ with the seed unedited
            // writes nothing, so the pane says nothing — an unnamed
            // savepoint's empty ⏎ used to speak "Name cleared…" about a name
            // that never existed (13u3 ladder round 1, R1-2's face half).
            guard wrote else { return }
            status = .receipt(BlockHistoryCopy.renamed(SavepointName.normalized(name)))
        } catch let error as OperationError {
            status = .refusal(TrayRefusalCopy.message(for: error))
        } catch {
            status = .refusal(DeletionRefusal.fallback(error))
        }
    }

    // MARK: - Region 1: read a moment in full, bring it back as a take (VX-431)

    /// **"Read in full"** (R-440-3): the open row's door puts the moment in
    /// the sheet. Nothing is written.
    func readInFull(_ commit: CommitPoint, of take: Variant, heading: String) {
        readingTrace = []
        reading = CommitReading(commit: commit, variantID: take.id, takeHeading: heading)
    }

    /// **The sheet's two foot doors, as one act** (VX-431 W-2, the VX-440
    /// walk) — what a foot press asks the model to do with the moment it
    /// shows.
    nonisolated enum ReadingAct: Equatable, Sendable {
        case restore(confirmed: Bool)
        case bringBack
    }

    /// **What the sheet road did, in order** — the act running and the sheet
    /// going (an observation seam, plain values like `restoreLandings`;
    /// cleared when a moment is put in the sheet). The W-2 pin's read.
    nonisolated enum ReadingStep: Equatable, Sendable { case acted, dismissed }
    private(set) var readingTrace: [ReadingStep] = []

    /// The act a foot press handed over, waiting for its sheet to go.
    @ObservationIgnored private var pendingReadingAct: (act: ReadingAct, reading: CommitReading)?

    /// **A foot door was pressed on the sheet showing `reading` — the act
    /// WAITS for the sheet to go** (W-2). It used to run at once, so the
    /// restore's store write, the delivery's rewrite of the block and the
    /// landing with its wash all ran WHILE the sheet was being dismissed —
    /// the window not key, the sheet still over the page — and the walk saw
    /// the caret left at the block's END (the rewrite's, with no landing
    /// standing after it) and the wash missed. Run from the sheet's
    /// `onDismiss` instead, the act is the pane row's own road, in the row
    /// road's window: one landing behaviour.
    func readingFootPressed(_ act: ReadingAct, for reading: CommitReading) {
        pendingReadingAct = (act, reading)
    }

    /// The sheet is gone (the pane's `.sheet(onDismiss:)`): the act a foot
    /// press handed over runs now — at most once; a sheet closed by Close or
    /// ⎋ hands nothing over and nothing runs.
    func readingSheetDismissed() async {
        readingTrace.append(.dismissed)
        guard let pending = pendingReadingAct else { return }
        pendingReadingAct = nil
        await runReadingAct(pending.act, for: pending.reading)
    }

    private func runReadingAct(_ act: ReadingAct, for reading: CommitReading) async {
        readingTrace.append(.acted)
        switch act {
        case .restore(let confirmed):
            await restore(reading.commit, of: reading.variantID, confirmed: confirmed)
        case .bringBack:
            await bringBackAsTake(reading.commit)
        }
    }

    /// **"Bring back as a take"** (R-440-3, the sheet's second foot door): the
    /// moment becomes a take of its own on the block
    /// (`Operations.bringBackCommitAsTake` — `branchVariant`'s posture: no
    /// touch, no churn, no undo entry; a seal refuses). NO flush first, and
    /// deliberately: the op copies the COMMIT's text, never a buffer, so a
    /// keystroke still pending in the take it came from cannot be lost or
    /// raced (the branch doors flush because they copy the buffer). Its
    /// receipt names the act (P-440-4); a refusal speaks in the tray family's
    /// words, like every act in this pane.
    func bringBackAsTake(_ commit: CommitPoint) async {
        status = nil
        do {
            let take = try await session.runner.run { ops in
                try ops.bringBackCommitAsTake(commit.id)
            }
            status = .receipt(BlockHistoryPath.broughtBackAsTake(label: take.label))
        } catch let error as OperationError {
            status = .refusal(TrayRefusalCopy.message(for: error))
        } catch {
            status = .refusal(DeletionRefusal.fallback(error))
        }
    }

    // MARK: - Region 2: unarchive

    func unarchive(_ variantID: String) async {
        status = nil
        do {
            try await session.runner.run { ops in try ops.unarchiveVariant(variantID) }
            status = .receipt(BlockHistoryCopy.unarchivedTake)
        } catch let error as OperationError {
            status = .refusal(TrayRefusalCopy.message(for: error))
        } catch {
            status = .refusal(DeletionRefusal.fallback(error))
        }
    }

    // MARK: - Region 3: put a deleted take back

    /// `restoreVariant` — the recovery-door class (no undo entry: the door IS
    /// the recovery). The receipt reads the op's OWN answer, because the
    /// restore is an exact flip (#68(b)) and a take archived when it was
    /// deleted comes back archived.
    func putBackTake(_ variantID: String) async {
        status = nil
        do {
            let restored = try await session.runner.run { ops in
                try ops.restoreVariant(variantID)
            }
            status = .receipt(BlockPastCopy.restored(restored))
        } catch let error as OperationError {
            status = .refusal(TrayRefusalCopy.message(for: error))
        } catch {
            status = .refusal(DeletionRefusal.fallback(error))
        }
    }

    // MARK: - Region 4: bring an original back

    /// The one-button `placeBlock` road her fourth sitting asked for, through
    /// the ONE shared composition the tray's own door calls — so two doors
    /// onto one act cannot drift on where the block lands or what the receipt
    /// says.
    func bringBack(_ originBlockID: String) async {
        status = nil
        do {
            status = .receipt(try await PreservedOriginPutBack.run(
                session: session, postID: postID, blockID: originBlockID))
        } catch let error as OperationError {
            status = .refusal(TrayRefusalCopy.message(for: error))
        } catch {
            status = .refusal(DeletionRefusal.fallback(error))
        }
    }
}

/// **THE MAC'S DELETED-REGION EXPLAINER.** The rest of `BlockHistoryCopy`
/// moved to `Shared/BlockHistoryFace.swift` at batch 6a; this half stayed
/// because it names *This Note's Tray*, which is a Mac surface (the phone's
/// note-level trash section is its own batch).
nonisolated extension BlockHistoryCopy {
    /// The deleted region's own explainer: **no purge door here**, and the
    /// honest place it does live (row 21's letter).
    /// (18d batch 2: the tray's *"leaving section"* became its **Leaving**
    /// view, one of two at the top of the panel — so the road this sentence
    /// names is spelled the way the panel now reads, filter and all. J8's
    /// copy-truth rule: a sentence that points at a door must point at the
    /// door that is there.)
    static let deletedExplainer = deletedRegionExplainer(
        purgeRoad: "open \(TrayPath.menuLabel) and choose "
            + "\(TrayPath.leavingTab) \u{25B8} \(RecoveryCopy.trayFilterTakes)")
}

/// **THE BLOCK HISTORY PANE.** One occupant of the post detail's inspector
/// column (the seam batch 3 opened), and the same view the bars present as a
/// sheet where no inspector exists (the book spread's inline form, the scraps
/// hosts) — one component, so the two hosts cannot tell different stories
/// about one block.
struct BlockHistoryPane: View {
    /// The registry ids this pane renders INLINE (P-1's `.surface` door; the
    /// walk unions every renderer). Put back and Unarchive are acts pointed
    /// at directly on their own rows. **`.deleteNow` is deliberately absent**
    /// — row 21's letter: this is not a trash surface.
    static let surfaceCapabilities: [CapabilityID] = [.restoreTake, .unarchiveTake]

    let session: AppSession
    /// How this pane closes. In a sheet the environment's `dismiss` answers;
    /// in the inspector the host hands the closing act down (the `TrayPanel`
    /// precedent, same reason).
    var onClose: (() -> Void)?
    /// Raised by the came-from region's second door. The HOST decides where
    /// the tray opens — the inspector swaps panels, a sheet host swaps
    /// sheets — which is what dissolves the peek's nested sheet
    /// (adjudication 3) instead of moving it.
    var onOpenTray: ((String) -> Void)?
    /// **Where the current-block jump lands** (ledger row 33). The HOST
    /// re-points its own occupant — the inspector swaps the panel's case, a
    /// sheet host swaps its pending request — for `onOpenTray`'s reason: the
    /// pane is scoped by its request, so re-scoping is the host's act and not
    /// a second lifetime inside this view.
    var onJump: ((BlockHistoryRequest) -> Void)?
    @State private var model: BlockHistoryModel
    /// Which take's savepoint run is open. Session UI state, like every other
    /// expansion in the app; seeded from her ruling by
    /// `initiallyExpanded` on the first loaded snapshot.
    @State private var expandedTakes: Set<String> = []
    @State private var seededExpansion = false
    /// Which quiet savepoint runs are open (13j J11's collapse, per take).
    @State private var expandedRuns: Set<String> = []
    /// VX-431 (the clarity pass): which commit rows are OPEN — a row rests as
    /// one line and a press shows more of the moment in place. Session UI
    /// state, like the two expansions above.
    @State private var openCommits: Set<String> = []
    /// 13u3 UNIT D: which savepoint's name is being edited (R-13u3-1).
    @State private var renameAsk: SavepointNameAsk?
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    #if DEBUG
    /// This pane's own name in `BlockHistoryPaneOracle` (VX-668's pin door;
    /// the 18k C4 owner shape).
    @State private var oracleOwner = UUID()
    #endif

    init(
        session: AppSession, request: BlockHistoryRequest,
        onClose: (() -> Void)? = nil, onOpenTray: ((String) -> Void)? = nil,
        onJump: ((BlockHistoryRequest) -> Void)? = nil,
        model: BlockHistoryModel? = nil
    ) {
        self.session = session
        self.onClose = onClose
        self.onOpenTray = onOpenTray
        self.onJump = onJump
        _model = State(initialValue: model
            ?? BlockHistoryModel(
                session: session, postID: request.postID, blockID: request.blockID,
                focusedVariantID: request.focusedVariantID))
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(tokens.chromeLabel(BlockHistoryPath.name))
                    .font(tokens.heading)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                Spacer()
                Button("Close") { close() }
            }
            // VX-144 (the quiet ledger — the architect's precision 5,
            // PROVISIONAL P-VX144-2): the pane-level blurb ("Everything this
            // block has been: …") is NOT drawn here any more. It said again,
            // above the page, what the four section headers and their
            // meaning lines say where they apply — and pushed the first
            // commit down by two (Terminal: three) lines. The Commits
            // section's DEFINING sentence stays verbatim beneath its header.
            // No tooltip replaces it: a hover-hidden sentence is the hint
            // class VX-142 removed. (`BlockHistoryPath.explainer` itself is
            // shared and the phone still reads it.)
            // Ledger row 33 — the current-block jump. It renders only while
            // the caret really is somewhere else (the pure rule decides), and
            // only where a host can act on it, so pressing it always moves
            // the pane (P-2).
            if let jump = jumpTarget, let onJump {
                Button(tokens.chromeLabel(BlockHistoryPath.jumpVerb)) { onJump(jump) }
                    // (VX-144: its inert small control-size modifier left with the
                    // pane's bezels — a voiced style draws no control size.)
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .help(BlockHistoryPath.jumpHelp)
            }
            if let status = model.status {
                Text(status.text)
                    .font(tokens.small)
                    .foregroundStyle(status.isRefusal ? tokens.alarm : tokens.muted)
                    .textSelection(.enabled)
                    .lineLimit(3)
            }
            // Rows 28 + 65 (the Act 10 correction round): the pane was a
            // `List`, and a plain macOS List measures section headers at a
            // fixed height — so the taller region headers (a title AND a
            // meaning line) drew as struck-through slivers, the EXACT
            // mechanism Act 10 item 1 traced and killed in the tray one file
            // over. Same rebuild, same reason: a ScrollView of ordinary
            // stacked views cannot clip a header by measuring it elsewhere,
            // and the four regions now READ as sections — a CalmSectionHeader
            // with air and one meaning line each (the calm-card grammar).
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 6) {
                    savepointRegion
                    archivedRegion
                    deletedRegion
                    cameFromRegion
                }
                .padding(.bottom, 8)
            }
        }
        .padding(12)
        .frame(minWidth: 300, minHeight: 280)
        .background(tokens.surface)
        .task { await model.start() }
        // Row 69: the note's seal, watched for as long as this pane is up.
        .task { await model.watchSeal() }
        #if DEBUG
        // VX-668 (the VX-677 run, batch 5): the pin door — the model THIS
        // pane holds in its own `@State` (the inspector builds the pane with
        // none of its own), published while the pane stands.
        .onAppear { BlockHistoryPaneOracle.publish(model, owner: oracleOwner) }
        .onDisappear { BlockHistoryPaneOracle.release(owner: oracleOwner) }
        #endif
        .onChange(of: model.loaded) { _, loaded in
            guard loaded, !seededExpansion else { return }
            seededExpansion = true
            expandedTakes = BlockHistoryModel.initiallyExpanded(
                model.history, focused: model.focusedVariantID)
        }
        .alert(
            BlockHistoryCopy.predatesSplitTitle,
            isPresented: Binding(
                get: { model.pendingRestore != nil },
                set: { if !$0 { model.pendingRestore = nil } }),
            presenting: model.pendingRestore
        ) { pending in
            Button(BlockHistoryCopy.restoreAnyway, role: .destructive) {
                Task { await model.confirmPendingRestore(pending) }
            }
            Button("Cancel", role: .cancel) { model.pendingRestore = nil }
        } message: { _ in
            Text(BlockHistoryCopy.predatesSplitDetail)
        }
        // VX-431 (R-440-3): "read in full" — the moment's whole text, with
        // Restore and Bring back as a take at its foot. A sheet over the pane
        // (in the inspector or over a host's own sheet alike).
        .sheet(
            item: Binding(
                get: { model.reading },
                set: { model.reading = $0 }),
            onDismiss: { Task { await model.readingSheetDismissed() } }
        ) { reading in
            CommitReadingSheet(
                reading: reading, tokens: tokens, now: session.now,
                predatesSplit: model.predatesSplit(reading.commit),
                onRestore: { confirmed in
                    model.readingFootPressed(.restore(confirmed: confirmed), for: reading)
                },
                onBringBack: { model.readingFootPressed(.bringBack, for: reading) })
        }
    }

    private func close() {
        if let onClose { onClose() } else { dismiss() }
    }

    /// Reading the router's observable fact HERE is what makes the door appear
    /// the moment she clicks into another block: the dependency is registered
    /// by `body`, and the fact only changes when the caret changes BLOCKS.
    private var jumpTarget: BlockHistoryRequest? {
        BlockHistoryModel.jumpTarget(
            session.commandRouter.focusedBlock,
            postID: model.postID, blockID: model.blockID)
    }

    // MARK: - Region 1 — every live take's saved moments

    @ViewBuilder private var savepointRegion: some View {
        // Row 28: a real section — a header with air and one meaning line.
        // VX-431: the header carries the region's count, and its meaning
        // line is ONE line with the whole sentence behind an (i).
        HistoryRegionHeader(
            tokens: tokens, title: BlockHistoryPath.savepointsSection,
            count: model.commitCount,
            line: BlockHistoryPath.savepointsLine,
            detail: BlockHistoryPath.savepointsExplainer)
        if model.loaded, model.history.activeTakes.isEmpty {
            quiet(BlockHistoryPath.nothingHere)
        }
        let takes = model.history.activeTakes
        ForEach(Array(takes.enumerated()), id: \.element.id) { index, take in
            takeRun(take, ordinal: index + 1, of: takes.count)
        }
    }

    @ViewBuilder private func takeRun(
        _ take: Variant, ordinal: Int, of total: Int
    ) -> some View {
        let commits = model.history.savepoints[take.id] ?? []
        let open = expandedTakes.contains(take.id)
        // Row 64's generous-target rule, here too: the WHOLE line toggles the
        // run (the DisclosureGroup it replaces toggled only on its chevron).
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                if open { expandedTakes.remove(take.id) }
                else { expandedTakes.insert(take.id) }
            }
        } label: {
            HStack(spacing: 6) {
                Text(tokens.chromeLabel(open ? "\u{25BE}" : "\u{25B8}"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                Text(tokens.chromeLabel(
                    BlockHistoryPath.takeHeading(take, ordinal: ordinal, of: total)))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                if take.id == model.focusedVariantID {
                    Text(tokens.chromeLabel(BlockHistoryPath.focusedMark))
                        .font(tokens.small)
                        .foregroundStyle(tokens.chosen)
                        .lineLimit(1)
                }
                Spacer(minLength: 8)
                Text(tokens.chromeLabel("\(commits.count)"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(1)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        if open {
            if commits.isEmpty {
                quiet(BlockHistoryPath.noSavepoints)
            }
            // VX-144 (the quiet ledger, precision 4): the run's lines — the
            // collapsed quiet runs and the commits — are ONE sequence, so a
            // token hairline stands between every two of them and never above
            // the first (the take's own line is the run's top edge).
            let entries = CommitRunEntry.entries(commits, expandedRuns: expandedRuns)
            ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                VStack(alignment: .leading, spacing: 0) {
                    if index > 0 { CommitRowRule(tokens: tokens) }
                    switch entry {
                    case .run(let id, let count, let expanded):
                        QuietRunRow(count: count, expanded: expanded, tokens: tokens) {
                            expandedRuns = SavepointHistoryFace.toggling(id, in: expandedRuns)
                        }
                        .padding(.vertical, 4)
                    case .commit(let commit):
                        commitRow(
                            commit, of: take,
                            heading: BlockHistoryPath.takeHeading(take, ordinal: ordinal, of: total))
                    }
                }
            }
        }
    }

    /// One commit as the quiet ledger draws it (`CommitRowView`), wired to
    /// the pane's model: the rename door (row 69's seal rule, R-13u3-1's
    /// one-ask-per-row binding) and Restore. VX-431: the row rests as ONE
    /// line and opens in place on a press (`openCommits`).
    private func commitRow(
        _ commit: CommitPoint, of take: Variant, heading: String
    ) -> some View {
        CommitRowView(
            commit: commit, tokens: tokens,
            predatesSplit: model.predatesSplit(commit), now: session.now,
            renameOpensField: model.renameOpensTheField,
            // One binding PER ROW, reading nil unless this row is the target:
            // a single `@State` bound by every row would put up one popover
            // per savepoint.
            renameAsk: Binding(
                get: { renameAsk?.targetID == commit.id ? renameAsk : nil },
                set: { if $0 == nil { renameAsk = nil } }),
            onName: {
                // Row 69: under a seal the FIELD does not open — the door
                // acts and speaks, like every other act in this pane.
                if model.renameOpensTheField {
                    renameAsk = .renaming(commit)
                } else {
                    model.refuseRenameUnderSeal()
                }
            },
            onRename: { name in Task { await model.rename(commit, to: name) } },
            onRestore: { Task { await model.restore(commit, of: take.id) } },
            expanded: openCommits.contains(commit.id),
            onToggle: {
                withAnimation(.easeInOut(duration: 0.15)) {
                    openCommits = SavepointHistoryFace.toggling(commit.id, in: openCommits)
                }
            },
            onReadInFull: { model.readInFull(commit, of: take, heading: heading) })
    }

    // MARK: - Region 2 — archived takes

    @ViewBuilder private var archivedRegion: some View {
        if !model.history.archivedTakes.isEmpty {
            // Row 28: the region reads as a section (header + meaning line),
            // its rows as calm cards — never a List header that can clip.
            HistoryRegionHeader(
                tokens: tokens, title: BlockHistoryPath.archivedSection,
                count: model.history.archivedTakes.count,
                line: BlockHistoryPath.archivedLine,
                detail: BlockHistoryCopy.archivedExplainer)
                .padding(.top, 8)
            ForEach(model.history.archivedTakes, id: \.id) { take in
                CalmCard(tokens: tokens) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(BlockPastCopy.rowLabel(take))
                            .font(tokens.body)
                            .foregroundStyle(
                                take.workingText.isEmpty ? tokens.muted : tokens.ink)
                            .lineLimit(2)
                        HStack(spacing: 8) {
                            Text(tokens.chromeLabel(TrayPath.archivedForever))
                                .font(tokens.small)
                                .foregroundStyle(tokens.faint)
                                .lineLimit(1)
                                .fixedSize()
                            Spacer(minLength: 8)
                            Button(tokens.chromeLabel(BlockHistoryCopy.unarchiveVerb)) {
                                Task { await model.unarchive(take.id) }
                            }
                            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                            .help("Back into the block's fan, exactly as it was")
                        }
                    }
                }
            }
        }
    }

    // MARK: - Region 3 — deleted takes (NO purge door: row 21's letter)

    @ViewBuilder private var deletedRegion: some View {
        if !model.history.deletedTakes.isEmpty {
            HistoryRegionHeader(
                tokens: tokens, title: BlockHistoryPath.deletedSection,
                count: model.history.deletedTakes.count,
                line: BlockHistoryPath.deletedLine,
                detail: BlockHistoryCopy.deletedExplainer)
                .padding(.top, 8)
            ForEach(model.history.deletedTakes, id: \.id) { take in
                CalmCard(tokens: tokens) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(BlockPastCopy.rowLabel(take))
                            .font(tokens.body)
                            .foregroundStyle(
                                take.workingText.isEmpty ? tokens.muted : tokens.ink)
                            .lineLimit(2)
                        HStack(spacing: 8) {
                            // Row 63: the lead truncates; the CLOCK never does.
                            Text(tokens.chromeLabel(DeletedTakeFace.lead(take)
                                .joined(separator: " \u{B7} ")))
                                .font(tokens.small)
                                .foregroundStyle(tokens.faint)
                                .lineLimit(1)
                                .stampHelp(DeletedTakeFace.leadHelp(take))  // VX-351
                            if let slot = DeletedTakeFace.clockSlot(take, now: session.now) {
                                Text(tokens.chromeLabel(slot))
                                    .font(tokens.small)
                                    .foregroundStyle(tokens.faint)
                                    .lineLimit(1)
                                    .fixedSize()
                                    .layoutPriority(1)
                            }
                            Spacer(minLength: 8)
                            Button(tokens.chromeLabel(BlockPastCopy.putBackVerb)) {
                                Task { await model.putBackTake(take.id) }
                            }
                            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                            .help(BlockPastCopy.putBackHelp(take))
                        }
                    }
                }
            }
        }
    }

    // MARK: - Region 4 — came from (the 13l walk's P-3, fixed)

    @ViewBuilder private var cameFromRegion: some View {
        if !model.history.origins.isEmpty {
            HistoryRegionHeader(
                tokens: tokens, title: BlockHistoryPath.cameFromSection,
                count: model.history.origins.count,
                line: BlockHistoryPath.cameFromLine,
                detail: OriginPeekCopy.explainer)
                .padding(.top, 8)
            ForEach(model.history.origins) { row in
                CalmCard(tokens: tokens) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(TrayRowPreview.line(row.text))
                            .font(tokens.body)
                            .foregroundStyle(
                                row.text?.isEmpty == false ? tokens.ink : tokens.muted)
                            .lineLimit(3)
                        Text(tokens.chromeLabel(OriginPeekCopy.lineageRow(
                            op: row.origin.originOp, at: row.origin.at)))
                            .font(tokens.small)
                            .foregroundStyle(tokens.faint)
                            .lineLimit(2)
                            .stampHelp(OriginPeekCopy.lineageHelp(at: row.origin.at))  // VX-351
                        HStack(spacing: 8) {
                            Spacer(minLength: 0)
                            Button(tokens.chromeLabel(BlockHistoryPath.bringBackVerb)) {
                                Task { await model.bringBack(row.origin.blockID) }
                            }
                            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                            .help(BlockHistoryPath.bringBackHelp)
                            Button(tokens.chromeLabel(BlockHistoryPath.openTrayVerb)) {
                                onOpenTray?(row.origin.blockID)
                            }
                            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                            .disabled(onOpenTray == nil)
                            .help("The whole list: what this note has set aside, and "
                                + "everything of its own that is on the clock")
                        }
                    }
                }
            }
        }
    }

    // MARK: - Pieces

    private func quiet(_ line: String) -> some View {
        Text(tokens.chromeLabel(line))
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .lineLimit(3)
            .fixedSize(horizontal: false, vertical: true)
    }
}


// MARK: - VX-144 — the Commits region as a QUIET LEDGER (direction A)

/// **WHAT A COMMIT ROW SAYS, ON THE MAC** (VX-144, the architect's ruling —
/// direction A, precisions 1–2). Her report: *"the commits page is very messy
/// with crowded & cluttered UI."*
///
/// Mac-local ON PURPOSE (precision 7): `Shared/SavepointRowFace` is the
/// phone's face too, and it keeps its words — the phone's Block History is
/// untouched by this batch (the parity line carries it). What differs here:
/// - **The preview is ONE line: the first non-blank paragraph**, never the
///   two-line cut the row used to make — which is what drew "…had.…" when a
///   commit's text had a second paragraph (the cut fell at the newline and an
///   ellipsis landed after the period). This face appends NO ellipsis of its
///   own; the view's one-line tail truncation is the only one.
/// - **The details line drops "saved by hand"** — deliberate is the default
///   state and earns no words — and **the year when it is this year**.
///   **"quiet"** stays on automatic commits (they are visually muted by spec)
///   and **"predates a split"** stays (it is Restore's warning).
///
/// **VX-431 (the VX-440 run) — THE CLARITY PASS** (her report on the ticket:
/// *"cluttered and wordy in the same way that the books and gathering menus
/// are"*; the plan's Batch 2 design, item 1): a commit row RESTS as ONE line —
/// when · its name (when it has one) · the kind's glyph — with Restore, the
/// pane's one-per-row act, at the line's end; the moment's words leave the
/// resting row. A press opens the row in place: a LONGER capped preview of
/// the moment (paragraphs kept), the details words, and the row's other doors
/// ("read in full", the name door). PROVISIONAL anatomy (P-440-9).
///
/// **VX-674 (her ruling on P-440-9's flagged gap):** an UNNAMED commit's
/// resting line carries its first words, muted, after the stamp
/// (`restingWords`) — so the line is when · the name, or else the moment's
/// first words · the kind's glyph. A named commit keeps its name alone.
nonisolated enum CommitRowFace {
    /// **The open row's preview cap** — characters, cheap, far past the lines
    /// the open row draws (`expandedLines`), so the view's tail truncation is
    /// what the eye meets; the whole moment is the read-in-full sheet's.
    static let expandedCap = 600
    /// How many lines the open row's preview may take.
    static let expandedLines = 8

    /// **The open row's preview** — the moment from its first words, its
    /// paragraphs KEPT (the clarity pass's "longer capped preview"; the
    /// resting row's one-paragraph cut retired with the resting preview).
    /// Leading blank lines are dropped; the face appends no ellipsis of its
    /// own (the "…had.…" lesson, VX-144); an empty moment says so in the
    /// take's own words.
    static func expandedPreview(_ text: String) -> String {
        let body = text.drop { $0.isWhitespace }
        guard !body.isEmpty else { return BlockPastCopy.emptyTake }
        return String(body.prefix(expandedCap))
    }

    /// **VX-674 (her ruling on P-440-9's flagged gap, QUESTIONS #249) — an
    /// UNNAMED commit's resting words.** At rest an unnamed commit was a time
    /// and (if quiet) a glyph — none of her words until she opened it. Ruled:
    /// the resting line carries a few words of the moment as a MUTED preview
    /// after the stamp; a NAMED commit keeps its name alone (nil here); the
    /// quiet ◦ is unchanged.
    ///
    /// Cheap and bounded, from the row's already-loaded text (P1 — a cost
    /// of the moment's first `restingCap` characters, never its length):
    /// leading blank lines and spaces are dropped, the FIRST LINE only (a
    /// second paragraph never reaches the resting line — the open row and the
    /// read-in-full sheet carry the rest), capped by `Character` so a cut can
    /// never split a grapheme, trailing spaces trimmed. The face appends NO
    /// ellipsis of its own (VX-144's "…had.…" lesson): the view's one-line
    /// tail truncation is the only one, so how many words show is the
    /// layout's. An empty moment says so in the open row's own words
    /// (PROVISIONAL P-674-1).
    static func restingWords(_ commit: CommitPoint) -> String? {
        guard SavepointRowFace.name(commit) == nil else { return nil }
        return restingPreview(commit.text)
    }

    /// The resting preview's character cap — far past what one line of the
    /// inspector column shows (≈ 40 characters at its default width), so the
    /// layout's truncation is what the eye meets; the bound is the cost's.
    static let restingCap = 160

    /// The resting preview over a moment's text (see `restingWords`).
    static func restingPreview(_ text: String) -> String {
        let body = text.drop { $0.isWhitespace }
        guard !body.isEmpty else { return BlockPastCopy.emptyTake }
        let line = body.prefix(restingCap).prefix { !$0.isNewline }
        var words = String(line)
        while let last = words.last, last.isWhitespace { words.removeLast() }
        return words
    }

    /// **The kind's glyph on the resting line** — a QUIET commit's mark; a
    /// deliberate one earns none (VX-144's "deliberate is the default state
    /// and earns no words", applied to glyphs). One grapheme, monochrome, in
    /// the line's faint ink. PROVISIONAL (P-440-9).
    static let quietGlyph = "\u{25E6}"
    static let quietGlyphHelp = "A quiet commit \u{2014} the app saved this moment on its own"

    static func kindGlyph(_ commit: CommitPoint) -> String? {
        commit.kind == .auto ? quietGlyph : nil
    }

    /// The OPEN row's details words — `details` without the stamp, which the
    /// resting line already says: "quiet" on an automatic commit, and
    /// Restore's warning where the moment predates a split.
    static func notes(_ commit: CommitPoint, predatesSplit: Bool) -> [String] {
        var pieces: [String] = []
        if commit.kind == .auto { pieces.append(quietMark) }
        if predatesSplit { pieces.append(BlockHistoryCopy.predatesSplitMark) }
        return pieces
    }

    /// The resting line's press, said on hover (the row is the door).
    static func toggleHelp(expanded: Bool) -> String {
        expanded ? "Show less of this commit" : "Show more of this commit"
    }

    /// When — the month and day, the time, and the year only when it is not
    /// this one. The two shapes are one format family, so a row from last
    /// year reads as the same sentence with one more word.
    static func stamp(_ date: Date, now: Date, calendar: Calendar = .current) -> String {
        if calendar.isDate(date, equalTo: now, toGranularity: .year) {
            return date.formatted(.dateTime.month(.abbreviated).day().hour().minute())
        }
        return date.formatted(.dateTime.year().month(.abbreviated).day().hour().minute())
    }

    /// The automatic commit's one word (`SavepointRowFace`'s, kept).
    static let quietMark = "quiet"

    static func details(
        _ commit: CommitPoint, predatesSplit: Bool, now: Date,
        calendar: Calendar = .current
    ) -> [String] {
        var pieces = [stamp(commit.createdAt, now: now, calendar: calendar)]
        if commit.kind == .auto { pieces.append(quietMark) }
        if predatesSplit { pieces.append(BlockHistoryCopy.predatesSplitMark) }
        return pieces
    }
}

/// One line of a take's run, in order: a collapsed QUIET RUN's line (13j
/// J11) or a commit. Flattened so the pane can rule a hairline between every
/// two lines — the grouping and the render decision are the shared ones
/// (`SavepointRuns`, `SavepointHistoryFace`), untouched.
enum CommitRunEntry: Identifiable {
    case run(id: String, count: Int, expanded: Bool)
    case commit(CommitPoint)

    var id: String {
        switch self {
        case .run(let id, _, _): return id
        case .commit(let commit): return commit.id
        }
    }

    static func entries(_ commits: [CommitPoint], expandedRuns: Set<String>) -> [CommitRunEntry] {
        var out: [CommitRunEntry] = []
        for row in SavepointRuns.rows(commits, isQuiet: { $0.kind == .auto }, id: { $0.id }) {
            let rendered = SavepointHistoryFace.rendered(row, expanded: expandedRuns)
            if let count = rendered.runCount {
                out.append(.run(id: row.id, count: count, expanded: rendered.expanded))
            }
            out += rendered.items.map(CommitRunEntry.commit)
        }
        return out
    }
}

/// The hairline between two lines of a run (precision 4) — the voice's own
/// `line` token, one point, full width.
struct CommitRowRule: View {
    let tokens: VoiceTokens

    var body: some View {
        Rectangle()
            .fill(tokens.line)
            .frame(height: 1)
            .frame(maxWidth: .infinity)
    }
}

/// **ONE COMMIT, AS THE QUIET LEDGER DRAWS IT** (VX-144, precisions 1–3).
///
/// The hierarchy flips: the NAME she gave the moment leads in readable ink
/// (R-13u3-1's "the name leads", no longer an 11.5-pt accent whisper) and the
/// acts are quiet voiced WORDS (`VoiceControls.swift`: "chrome is quiet text,
/// never bezels"). The rename door still stands on EVERY commit, manual and
/// quiet alike (R-13u3-1), and says what it does on this row (Name · Rename).
///
/// **VX-431 — the clarity pass:** the row RESTS as one line — when · the name
/// · the quiet glyph, Restore at the end (her ruled "Restore per row") — and
/// the whole line but Restore is the press that OPENS it in place: the
/// moment's longer preview, the details words, and "read in full" beside the
/// name door (`CommitRowFace`'s doc carries the anatomy).
struct CommitRowView: View {
    let commit: CommitPoint
    let tokens: VoiceTokens
    let predatesSplit: Bool
    let now: Date
    /// Row 69: whether the rename door opens its field (false under a seal —
    /// the door then acts and speaks instead).
    let renameOpensField: Bool
    /// This row's slice of the pane's one rename ask (nil unless it is the
    /// target).
    let renameAsk: Binding<SavepointNameAsk?>
    let onName: () -> Void
    let onRename: (String?) -> Void
    let onRestore: () -> Void
    /// VX-431: whether the row is open, and how the resting line opens and
    /// closes it (the pane's session state).
    var expanded: Bool = false
    var onToggle: () -> Void = {}
    /// VX-431: the open row's "read in full" — the moment's whole text in a
    /// sheet (R-440-3). Nil renders no door (P-2: a host with nowhere to
    /// read it offers none).
    var onReadInFull: (() -> Void)? = nil

    /// The name's type: the voice's own reading size for chrome text
    /// (13 pt — Study's system face, Terminal's mono), medium weight.
    static func nameFont(_ tokens: VoiceTokens) -> Font {
        tokens.navigation.weight(.medium)
    }

    /// Restore's hover words, one home (the row and the sheet say the same).
    static let restoreHelp = "Loads this saved moment back into the take's buffer \u{2014} "
        + "the moment itself stays, and saving again appends"

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            restingLine
            if expanded { openPart }
        }
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// **THE RESTING LINE** — when · name (unnamed: the moment's first words,
    /// muted — VX-674) · glyph, the press that opens the row, and Restore at
    /// the end.
    private var restingLine: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            // Row 64's generous-target rule: the whole line (but Restore)
            // opens the row.
            Button(action: onToggle) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    // The clock never truncates — it is the line's anchor.
                    Text(tokens.chromeLabel(CommitRowFace.stamp(commit.createdAt, now: now)))
                        .font(tokens.small)
                        .foregroundStyle(tokens.faint)
                        .lineLimit(1)
                        .fixedSize()
                    if let name = SavepointRowFace.name(commit) {
                        Text(name)
                            .font(Self.nameFont(tokens))
                            .foregroundStyle(tokens.ink)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    } else if let words = CommitRowFace.restingWords(commit) {
                        // VX-674: an unnamed moment's first words, muted —
                        // her prose, so never case-folded by the voice's
                        // chrome rule; one line, the layout's truncation the
                        // only ellipsis (the stamp and the glyph keep their
                        // widths — this is what yields).
                        Text(words)
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    if let glyph = CommitRowFace.kindGlyph(commit) {
                        Text(glyph)
                            .font(tokens.small)
                            .foregroundStyle(tokens.faint)
                            .lineLimit(1)
                            .fixedSize()
                            .help(CommitRowFace.quietGlyphHelp)
                    }
                    Spacer(minLength: 8)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(CommitRowFace.toggleHelp(expanded: expanded))
            Button(tokens.chromeLabel(BlockHistoryCopy.restoreVerb), action: onRestore)
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .help(Self.restoreHelp)
        }
    }

    /// **THE OPEN PART** — more of the moment, its details words, and the
    /// row's other two doors.
    @ViewBuilder private var openPart: some View {
        Text(CommitRowFace.expandedPreview(commit.text))
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .lineLimit(CommitRowFace.expandedLines)
            .truncationMode(.tail)
            .fixedSize(horizontal: false, vertical: true)
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            let notes = CommitRowFace.notes(commit, predatesSplit: predatesSplit)
            if !notes.isEmpty {
                // "predates a split" is Restore's warning and must never fall
                // off the end (row 63's rule): it may wrap once.
                Text(tokens.chromeLabel(notes.joined(separator: " \u{B7} ")))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 8)
            if let onReadInFull {
                Button(tokens.chromeLabel(BlockHistoryPath.readInFullVerb), action: onReadInFull)
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .help(BlockHistoryPath.readInFullHelp)
            }
            Button(tokens.chromeLabel(BlockHistoryCopy.nameVerb(commit)), action: onName)
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .help(renameOpensField
                    ? BlockHistoryCopy.nameHelp(commit)
                    : TrayRefusalCopy.sealed)
                .savepointNameAsk(renameAsk, tokens: tokens) { _, name in onRename(name) }
        }
    }
}

/// **READ IN FULL** (VX-431 — R-440-3, her sitting's "Row expands + full-text
/// sheet": *"a 'read in full' door opens a sheet with the whole text
/// (scrollable, selectable) with Restore and 'Bring back as a take' at its
/// foot"*). Her ticket words are why it exists: *"a long commit can't be read
/// in full."*
///
/// **READ-CHEAP, NEVER AN EDITOR (P3):** the moment is ONE selectable `Text`
/// in a scroll — a saved moment is immutable (I5), and nothing that shows it
/// may look like a place to type. Its cost is the moment's own length, paid
/// once when she summons it (a block's text, never the note's or the corpus's).
///
/// Restore here is the row's Restore exactly — the same model act, its
/// pre-split warning asked HERE (the pane's own alert cannot present over this
/// sheet) — and both foot doors close the sheet, so what they did is seen in
/// the pane and on the page behind it. **W-2 (the VX-440 walk):** a foot door
/// hands its act to the model and THEN closes the sheet; the model runs the
/// act once the sheet is gone (`readingSheetDismissed`, the pane's
/// `onDismiss`), so the landing and its wash happen on the page she can see,
/// exactly as the row's do.
struct CommitReadingSheet: View {
    let reading: BlockHistoryModel.CommitReading
    let tokens: VoiceTokens
    let now: Date
    let predatesSplit: Bool
    /// Restore — `confirmed` is true when the pre-split warning was answered.
    let onRestore: (_ confirmed: Bool) -> Void
    let onBringBack: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var confirmingRestore = false
    #if DEBUG
    /// This sheet's own name in `BlockHistoryPaneOracle` (VX-668's pin door).
    @State private var oracleOwner = UUID()
    #endif

    /// The sheet's measure — a reading width, never the pane's narrow column.
    static let idealWidth: CGFloat = 560

    private var commit: CommitPoint { reading.commit }

    /// What the body reads — the moment's own words, or the take's empty word.
    static func bodyText(_ commit: CommitPoint) -> String {
        commit.text.isEmpty ? BlockPastCopy.emptyTake : commit.text
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(BlockHistoryPath.readingTitle(commit, now: now))
                    .font(tokens.heading)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 12)
                Button(tokens.chromeLabel("Close")) { dismiss() }
                    .keyboardShortcut(.cancelAction)
            }
            // Whose moment, and when — the details the pane's row carries.
            Text(tokens.chromeLabel(
                ([reading.takeHeading]
                    + CommitRowFace.details(commit, predatesSplit: predatesSplit, now: now))
                    .joined(separator: " \u{B7} ")))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            ScrollView {
                Text(Self.bodyText(commit))
                    .font(tokens.body)
                    .foregroundStyle(commit.text.isEmpty ? tokens.muted : tokens.ink)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 4)
            }
            .frame(maxHeight: .infinity)
            HStack(spacing: 10) {
                Spacer(minLength: 0)
                // W-2: the act is handed over FIRST, then the sheet goes —
                // the model runs it once the sheet is gone (`onDismiss`).
                Button(tokens.chromeLabel(BlockHistoryPath.bringBackAsTakeVerb)) {
                    onBringBack()
                    dismiss()
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .help(BlockHistoryPath.bringBackAsTakeHelp)
                Button(tokens.chromeLabel(BlockHistoryCopy.restoreVerb)) { pressRestore() }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                .help(CommitRowView.restoreHelp)
            }
        }
        .padding(16)
        .frame(
            minWidth: 420, idealWidth: Self.idealWidth, maxWidth: 820,
            minHeight: 320, idealHeight: 520)
        .background(tokens.surface)
        #if DEBUG
        // VX-668's pin door: the Restore button's OWN action, so a pin presses
        // exactly what the button does — the act handed over, then THIS
        // sheet's `dismiss` (no in-process road reaches a SwiftUI button).
        .onAppear {
            BlockHistoryPaneOracle.publishSheetRestore(
                commitID: commit.id, owner: oracleOwner) { pressRestore() }
        }
        .onDisappear { BlockHistoryPaneOracle.release(owner: oracleOwner) }
        #endif
        .alert(BlockHistoryCopy.predatesSplitTitle, isPresented: $confirmingRestore) {
            Button(BlockHistoryCopy.restoreAnyway, role: .destructive) {
                onRestore(true)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(BlockHistoryCopy.predatesSplitDetail)
        }
    }

    /// The foot's Restore, as its button runs it — W-2's order: the act handed
    /// over FIRST, then the sheet goes (a pre-split moment asks here first).
    /// One function so VX-668's pin door presses exactly what the button does.
    private func pressRestore() {
        if predatesSplit {
            confirmingRestore = true
        } else {
            onRestore(false)
            dismiss()
        }
    }
}

#if DEBUG
/// **VX-668's PIN DOORS** (the VX-677 run, batch 5 — `notes/plans/fixes/
/// vx-677-editor-panes-ai-door.md`, BATCH 5 RECORD). The app builds the Block
/// History pane in the post detail's INSPECTOR with no model of its own, so
/// the pane's model lives in the pane's `@State`, out of a pin's reach; and
/// the read-in-full sheet's Restore is a SwiftUI button, which no in-process
/// pin can press (SwiftUI builds no accessibility nodes in-process —
/// `ComposedSliders`' finding). So the mounted pane publishes its model and
/// the mounted sheet publishes its Restore button's OWN action
/// (`CommitReadingSheet.pressRestore` — the act handed over, then the
/// sheet's own `dismiss`). Read by pins only; decides nothing. Keyed by the
/// note (the model) and by the commit (the sheet), owner-stamped (18k C4 —
/// a teardown takes only its own).
@MainActor
enum BlockHistoryPaneOracle {
    private static var models = OwnedRegistrations<String, BlockHistoryModel>()
    private static var sheetRestores = OwnedRegistrations<String, @MainActor () -> Void>()

    /// The model of the newest pane standing on this note.
    static func model(forPost postID: String) -> BlockHistoryModel? { models[postID] }

    /// The Restore button's action of the read-in-full sheet showing this
    /// commit, while that sheet stands.
    static func sheetRestore(forCommit commitID: String) -> (@MainActor () -> Void)? {
        sheetRestores[commitID]
    }

    static func publish(_ model: BlockHistoryModel, owner: UUID) {
        models.publish(model, for: model.postID, owner: owner)
    }

    static func publishSheetRestore(
        commitID: String, owner: UUID, _ press: @escaping @MainActor () -> Void
    ) {
        sheetRestores.publish(press, for: commitID, owner: owner)
    }

    static func release(owner: UUID) {
        models.release(owner: owner)
        sheetRestores.release(owner: owner)
    }
}
#endif

/// **A REGION'S HEADER** (VX-431 — the clarity pass): the region's name with
/// its COUNT beside it, and ONE line of meaning with the whole sentence
/// behind an (i) (`ExplainerLine`, the MCP pane's precedent; voiced). It
/// replaces `CalmSectionHeader` on this pane only — Settings and the scraps
/// area keep theirs. The strings are stored RAW (the voice is applied where
/// they are drawn), so a reflection pin reads the shipped sentences verbatim.
struct HistoryRegionHeader: View {
    let tokens: VoiceTokens
    let title: String
    let count: Int
    let line: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(tokens.chromeLabel(title))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                Text(tokens.chromeLabel("\(count)"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(1)
                    .fixedSize()
            }
            ExplainerLine(line: line, detail: detail, tokens: tokens)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 6)
    }
}
