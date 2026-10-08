//
//  MobileBlockHistory.swift
//  VariorumMobile
//
//  **THE BLOCK HISTORY TWIN** (mobile round 2, batch 6a) — the phone's
//  edition of the post-13l polish round's ledger row 17 (G2), built to that
//  round's RULED design rather than to the mid-design it superseded
//  (`notes/plans/mobile-round-2.md` §69, MobileSoul PL-14).
//
//  ── WHAT IT CLOSES: A LIVE DATA HOLE ─────────────────────────────────────
//  Takes stopped rowing in the global Trash when `TrashScope` shipped on both
//  platforms — deliberately, because a deleted take on a living block is not
//  a note leaving the library. The Mac gained the take's two new homes in the
//  same round; the phone did not, so a deleted take was **invisible AND
//  un-restorable on the phone** (the round's LR1-3, "the dark window"). This
//  face is the take's home on this device, which is what makes the global
//  rule safe here too.
//
//  ── ONE COHESIVE FACE PER BLOCK, HER FOUR REGIONS IN HER ORDER ───────────
//    1. **Savepoint runs** — ALL live takes, sectioned, the take you're in
//       expanded (her ruling, and the ONE shared rule decides which:
//       `BlockHistoryExpansion`). Restore per row, quiet runs collapsed
//       (13j J11, `SavepointRuns` + `SavepointHistoryFace`).
//    2. **Archived takes** — set aside, no clock, with Unarchive.
//    3. **Deleted takes** — the 30-day clock and Put back, and **NO PURGE
//       DOOR** (her evolved rule: Delete Now lives on TRASH SURFACES only —
//       never in the writing flow). Since batch 6b the region's explainer
//       NAMES the road that does carry one: the per-note tray's **Leaving**
//       section (blocks ▸ leaving), where a deleted take wears Put back and
//       Delete Now. It still never names the global Trash, which by her D1
//       ruling does not list takes at all.
//    4. **Came from** — ALL of a merge's originals (never `.first` — the 13l
//       walk's P-3), each with its text and a one-button `placeBlock` way
//       back through the SHARED act (`PreservedOriginPutBack`).
//
//  ── WHAT IS SHARED AND WHAT IS THE PHONE'S ───────────────────────────────
//  The projection is core (`Queries.blockHistory`). Every word, every row
//  face and the expansion rule are `Shared/BlockHistoryFace.swift`, hoisted
//  out of the Mac at this batch so the two faces cannot drift (MobileSoul
//  §3). What is the phone's own: the ROW LIST below (a flat, table-shaped
//  sequence, because the phone renders a `UITableView` where the Mac renders
//  a SwiftUI `List` with sections), the flush-and-refusal idiom every phone
//  door already speaks, and the door's placement.
//
//  ── THE DOOR — MOVED AT BATCH 9, BY HER LETTER ───────────────────────────
//  Her G2 ruling put the Mac's door in the bottom chrome *"beside Commit —
//  history is the natural pair to commit"*, and the phone answered it with
//  a `Block History…` row in the block ⋯ next to `Commit Take` (batch 6a
//  also fixed the NAME there — `Take History…` became `Block History…`, her
//  F2 report answered one noun over: *"it's unclear that history is under
//  Note, that makes it seem like the Note's history"*).
//
//  **She then moved it herself** (2026-08-23): *"i also think that take
//  history should move into the three ... menu on each take rather than the
//  main three dot menu."* So the door is now a row on EVERY LIVE TAKE
//  CARD's ⋯ inside the takes browser
//  (`MobileTakesBrowserController.openHistory`), and the block ⋯ has none.
//  The word did not fork on the way over: that row's title is composed from
//  the SHARED `BlockHistoryPath.name`, so it still says `Block History…` and
//  a re-word lands once.
//
//  **What the move buys, and it is the reason the shape is right rather
//  than merely obedient:** `open(blockID:focused:)` now takes the take the
//  door was pressed ON, so the savepoint run that opens expanded is THAT
//  take's — where the block-⋯ road could only ever offer the block's
//  DISPLAYED take, whichever card she was actually asking about.
//
//  **What it costs, recorded rather than discovered later:** the browser
//  refuses to open on a GAP block (an un-synced placement with no variant —
//  *"This block hasn't fully synced; it is read-only for now"*), so this
//  face is no longer reachable on one. The block ⋯'s row was; nothing else
//  is. A gap block's history is thin by construction (no live take, so no
//  savepoint runs — at most deleted takes and origins), and the state is a
//  sync race rather than a place she sits, but it IS a road that closed and
//  it is on her sitting list.
//
//  ── SCOPING, AND WHY THERE IS NO JUMP DOOR ───────────────────────────────
//  The Mac's pane stands open beside a live editor, so its caret can wander
//  off the block on screen and ledger row 33 gave it a jump button. The
//  phone's sheet COVERS the page and stands its editor down (the comments/
//  takes sheet posture), so the caret cannot move while the face is up: there
//  is no jump to offer, and rendering one would be a door that cannot act
//  (P-2). Recorded rather than ported.
//
//  Reads are refresh-on-event (the comments controller's discipline, kept
//  from the take-history face this replaces): at open, after every verb, and
//  on projection ingests while open. Deliberately NOT the Mac's held
//  observation — that observation reads `variant` and `commit_point` and so
//  re-runs at autosave rate, which the Mac accepts because its pane sits
//  beside a live editor. The phone's does not.
//

import Foundation
import UIKit
import VariorumCore

@MainActor
final class MobileBlockHistoryController {
    private let session: AppSession
    private var runner: OperationsRunner { session.runner }
    weak var model: MobileEditorViewModel?

    /// The block the face is open on. nil = closed.
    private(set) var openBlockID: String?
    /// The take she was in when the face opened — the DISPLAYED take (a
    /// peek's take while peeking; the shown chosen otherwise). It decides
    /// which savepoint run opens expanded (her ruling) and it is what the
    /// Commit door acts on. Deliberately held for the face's life: a remote
    /// flip mid-read must not silently swap whose past you are reading.
    private(set) var focusedVariantID: String?

    /// The whole block's time, in one core projection.
    private(set) var history = Queries.BlockHistory()
    private(set) var loaded = false

    /// Which savepoint runs are open. Session UI state; seeded from her
    /// ruling by the SHARED rule on the first loaded snapshot.
    private(set) var expandedTakes: Set<String> = []
    private var seededExpansion = false
    /// Which collapsed quiet runs are open (13j J11, per take).
    private(set) var expandedRuns: Set<String> = []

    /// The pre-split confirm's gate (AppSpec §9's warning): set when a
    /// flagged row's restore is requested; the view presents it, and
    /// `restore(_:confirmed: true)` / `cancelPendingRestore()` resolve.
    private(set) var pendingRestore: PendingRestore?

    /// **A receipt is not a refusal** — the shared classification
    /// (`RecoveryStatus`), so the face's line reads muted or in the alarm
    /// token without any view re-deriving it from the words.
    private(set) var status: RecoveryStatus?

    /// The pixels' hook: state or content changed — re-render the face.
    var onChanged: (() -> Void)?

    var isOpen: Bool { openBlockID != nil }

    init(session: AppSession) {
        self.session = session
    }

    struct PendingRestore: Equatable {
        let variantID: String
        let commit: CommitPoint
    }

    // MARK: - Copy (pinned statics — promises tests can keep)

    /// 13s-b U4 (her R-13s-31): the word is COMMIT — and where the sentence
    /// says what a commit IS, it rides the app's plain gloss, the saved
    /// moment (the Mac's receipts' twin; PROVISIONAL P-U4-1).
    static let committedStatus = "Committed — a saved moment of this take is kept."
    static var restoredStatus: String { BlockHistoryCopy.restoredSavepoint }
    /// The row's flag word (the shared history vocabulary's own tag).
    static var predatesSplitRowFlag: String { BlockHistoryCopy.predatesSplitMark }
    /// The confirm's message (AppSpec §9's documented warning class).
    static var predatesSplitWarning: String { BlockHistoryCopy.predatesSplitDetail }

    /// **The phone's deleted-region explainer — and its second half LANDED
    /// AT BATCH 6b.** The lead half is shared; the clause naming where
    /// Delete Now lives is each platform's, and it must NEVER name the Mac's
    /// tray: that is the no-redirect breach (MobileSoul §4.4).
    ///
    /// **Why it was `nil` until now, kept so nobody re-derives it.** §70
    /// handed the flip forward to *"when batch 6b gives the phone its
    /// note-level trash section"*, and batch 6c — which gave the phone a
    /// Trash ROOM with both purge doors in it — correctly DECLINED to flip
    /// it on that room's arrival: **this region lists deleted TAKES, and
    /// takes do not row in the global Trash.** `TrashScope.listedKinds` is
    /// `[.note, .book, .block, .preservedOriginal]` by her D1 ruling, and
    /// `TrashScope.kinds(filter:)` cannot widen past it, so naming the Trash
    /// room here would have sent her to a room where the take she is reading
    /// about does not appear — a door that cannot act (P-2), wearing a true
    /// sentence's clothes.
    ///
    /// The road that makes the sentence true is the one §69.3 ruled and this
    /// batch built: the per-note tray's **Leaving** section, where a deleted
    /// take carries **Put back** and **Delete Now** with confirm-every-time.
    /// The phrase is `MobileNoteTrayModel.purgeRoadPhrase`, composed from the
    /// door's own two words rather than written a second time here.
    /// `MobileBlockHistoryTests.theDeletedRegionNamesTheTrayAsItsPurgeRoad`
    /// holds it, and holds the precondition BOTH ways: the sentence names a
    /// road that really carries the take, and still never names the global
    /// Trash, which still does not list takes.
    static var deletedExplainer: String {
        BlockHistoryCopy.deletedRegionExplainer(
            purgeRoad: MobileNoteTrayModel.purgeRoadPhrase)
    }

    /// The phone's edition of "no saved moments yet" — the Mac's names ⌘S,
    /// and a chord is a platform fact.
    static let noSavepoints = "No saved moments yet — Commit Take in ⋯ keeps one."

    // MARK: - The commit door (the ⋯'s "Commit Take" — history's pair)

    /// Commits the caret block's DISPLAYED take — flush-first, so the
    /// savepoint holds exactly the bytes she sees.
    func commitNow(blockID: String) async {
        guard let model else { return }
        guard let slot = model.slot(for: blockID), let variantID = slot.variantID else {
            model.report("This block hasn't fully synced; it is read-only for now.")
            return
        }
        await model.autosave.flushNow()
        guard !model.autosave.isDirty else {
            model.report("Unsaved changes couldn't be written — resolve that first, then retry.")
            return
        }
        do {
            try await runner.run { ops in _ = try ops.commit(variantID, kind: .manual) }
            model.report(Self.committedStatus)
            if isOpen { await refresh() }
        } catch {
            model.report(Self.refusalMessage(error, act: "commit this take"))
        }
    }

    // MARK: - Open / close

    /// Opens the face on a block, remembering which take's run to expand.
    ///
    /// `focused` is the take card the door was pressed on (batch 9's
    /// per-take ⋯ — see the header). `nil` keeps the original rule: the
    /// block's DISPLAYED take, which is what a block-scale door could know.
    /// Either way the id is held for the face's life, so a remote flip
    /// mid-read cannot silently swap whose past she is reading.
    func open(blockID: String, focused: String? = nil) {
        guard let model, let slot = model.slot(for: blockID) else { return }
        openBlockID = blockID
        focusedVariantID = focused ?? slot.variantID
        history = Queries.BlockHistory()
        loaded = false
        seededExpansion = false
        expandedTakes = []
        expandedRuns = []
        pendingRestore = nil
        status = nil
        onChanged?()
        Task { await refresh() }
    }

    func close() {
        guard isOpen else { return }
        openBlockID = nil
        focusedVariantID = nil
        history = Queries.BlockHistory()
        loaded = false
        seededExpansion = false
        expandedTakes = []
        expandedRuns = []
        pendingRestore = nil
        status = nil
        onChanged?()
    }

    /// Every projection ingest routes here (VM routing): refresh an open
    /// face (a restore/commit elsewhere lands live); close when the block
    /// left the surface.
    func projectionDidChange() {
        guard let blockID = openBlockID else { return }
        if model?.slot(for: blockID) == nil {
            close()
        } else {
            Task { await refresh() }
        }
    }

    /// One coherent read: the whole block's time in ONE core projection —
    /// the fan, every live take's savepoints, the split dates, the deleted
    /// takes, and the origins with their preview text. Cost is the BLOCK's,
    /// never the corpus (P1); `Queries.blockHistory` states it at the query.
    func refresh() async {
        guard let blockID = openBlockID else { return }
        do {
            let value = try await session.database.read { [now = session.now] db in
                try Queries.blockHistory(db, blockID: blockID, now: now)
            }
            // The capture must still govern: a close→reopen on another block
            // could let an in-flight read land under the new scope.
            guard openBlockID == blockID else { return }
            adopt(value)
        } catch {
            status = .refusal(String(describing: error))
            onChanged?()
        }
    }

    /// Internal so tests drive the face deterministically (the Mac
    /// `BlockHistoryModel.adopt` seam, same reason).
    func adopt(_ value: Queries.BlockHistory) {
        history = value
        loaded = true
        if !seededExpansion {
            seededExpansion = true
            expandedTakes = BlockHistoryExpansion.initiallyExpanded(
                value, focused: focusedVariantID)
        }
        onChanged?()
    }

    func toggleTake(_ variantID: String) {
        if expandedTakes.contains(variantID) {
            expandedTakes.remove(variantID)
        } else {
            expandedTakes.insert(variantID)
        }
        onChanged?()
    }

    func toggleRun(_ id: String) {
        expandedRuns = SavepointHistoryFace.toggling(id, in: expandedRuns)
        onChanged?()
    }

    func predatesSplit(_ commit: CommitPoint) -> Bool {
        Queries.commitPredatesSplit(
            commitDate: commit.createdAt, splitDates: history.splitDates)
    }

    // MARK: - THE ROWS (pure — the phone's table shape over her four regions)

    /// One flat sequence, because the phone renders a `UITableView` where the
    /// Mac renders a SwiftUI `List` of sections. Pure over the projection and
    /// the two expansion sets, so a pin can hold what the face SAYS without
    /// rendering a pixel — and so the "no purge door" promise is checkable as
    /// a value rather than by reading a view body.
    enum Row: Equatable {
        case sectionHeader(title: String, explainer: String)
        case takeHeader(variantID: String, title: String, focused: Bool, savepoints: Int,
                        expanded: Bool)
        case quietRun(id: String, count: Int, expanded: Bool)
        case savepoint(variantID: String, commit: CommitPoint, predatesSplit: Bool)
        case quiet(String)
        case archivedTake(Variant)
        case deletedTake(Variant, meta: String)
        case origin(blockID: String, text: String, lineage: String)

        /// A section header's MINIMUM pitch. It is no longer the whole
        /// answer: the explainers are prose, so the sheet measures the row
        /// (`MobileBlockHistoryCell.sectionHeaderHeight`) and floors it
        /// here, keeping the shipped rhythm for the short headers while
        /// letting the two long explainers say their whole sentence
        /// (batch 6a's cold review, M1).
        static let sectionHeaderFloor: CGFloat = 52

        var height: CGFloat {
            switch self {
            case .sectionHeader: return Self.sectionHeaderFloor
            case .takeHeader: return 34
            case .quietRun: return 30
            case .savepoint: return 62
            case .quiet: return 34
            case .archivedTake: return 56
            case .deletedTake: return 62
            case .origin: return 84
            }
        }
    }

    func rows() -> [Row] {
        guard loaded else { return [] }
        let active = history.activeTakes
        // THE QUIET SENTENCE IS RESERVED FOR THE ONE-TAKE BLOCK (batch 6a's
        // cold review, M2). `Queries.BlockHistory.isEmpty` is about
        // SAVEPOINTS, archived takes, deleted takes and origins — it says
        // nothing about how many live takes the block has. So a block she
        // had FANNED but not yet committed (any `branchVariant`, the
        // everyday state) fell down this arm and was told it has "one
        // take", with every take section hidden: a face whose whole thesis
        // is honest reporting, asserting a count that was false.
        //
        // The Mac guards the same sentence on `activeTakes.isEmpty` and
        // draws its take sections unconditionally
        // (`BlockHistoryPane.swift:475`); I10 makes its branch practically
        // unreachable there, so the phone was the first surface ever to
        // render this sentence and the `one take` clause had never been
        // load-bearing. This is that rule in its reachable edition: the
        // sentence stands only where it is TRUE, and the moment a second
        // take exists the regions draw exactly as the Mac's do.
        if history.isEmpty, active.count <= 1 {
            return [.quiet(BlockHistoryPath.nothingHere)]
        }
        var rows: [Row] = []

        // 1 — savepoint runs: ALL live takes, sectioned, the focused one open.
        rows.append(.sectionHeader(
            title: BlockHistoryPath.savepointsSection,
            explainer: BlockHistoryPath.explainer))
        for (index, take) in active.enumerated() {
            let commits = history.savepoints[take.id] ?? []
            let expanded = expandedTakes.contains(take.id)
            rows.append(.takeHeader(
                variantID: take.id,
                title: BlockHistoryPath.takeHeading(
                    take, ordinal: index + 1, of: active.count),
                focused: take.id == focusedVariantID,
                savepoints: commits.count,
                expanded: expanded))
            guard expanded else { continue }
            if commits.isEmpty {
                rows.append(.quiet(Self.noSavepoints))
                continue
            }
            for run in SavepointRuns.rows(
                commits, isQuiet: { $0.kind == .auto }, id: { $0.id })
            {
                let rendered = SavepointHistoryFace.rendered(run, expanded: expandedRuns)
                if let count = rendered.runCount {
                    rows.append(.quietRun(
                        id: run.id, count: count, expanded: rendered.expanded))
                }
                for commit in rendered.items {
                    rows.append(.savepoint(
                        variantID: take.id, commit: commit,
                        predatesSplit: predatesSplit(commit)))
                }
            }
        }

        // 2 — archived takes (Unarchive).
        if !history.archivedTakes.isEmpty {
            rows.append(.sectionHeader(
                title: BlockHistoryPath.archivedSection,
                explainer: BlockHistoryCopy.archivedExplainer))
            rows.append(contentsOf: history.archivedTakes.map(Row.archivedTake))
        }

        // 3 — deleted takes: clock + Put back, and NO purge door (her rule).
        if !history.deletedTakes.isEmpty {
            rows.append(.sectionHeader(
                title: BlockHistoryPath.deletedSection,
                explainer: Self.deletedExplainer))
            for take in history.deletedTakes {
                rows.append(.deletedTake(
                    take,
                    meta: DeletedTakeFace.meta(take, now: session.now)
                        .joined(separator: " \u{B7} ")))
            }
        }

        // 4 — came from: EVERY original, never the first.
        if !history.origins.isEmpty {
            rows.append(.sectionHeader(
                title: BlockHistoryPath.cameFromSection,
                explainer: OriginPeekCopy.explainer))
            for row in history.origins {
                rows.append(.origin(
                    blockID: row.origin.blockID,
                    text: TrayRowPreview.line(row.text),
                    lineage: OriginPeekCopy.lineageRow(
                        op: row.origin.originOp, at: row.origin.at)))
            }
        }
        return rows
    }

    // MARK: - Region 1: restore a savepoint

    /// Restores a savepoint into its take's buffer. A PRE-SPLIT row gates on
    /// the confirm first (`pendingRestore` — the view presents it); the
    /// restore itself is FLUSH-FIRST like every phone door that rewrites a
    /// buffer (a pending flush landing after it would overwrite the restored
    /// text with the stale surface — the stale-flush class).
    func restore(_ commit: CommitPoint, of variantID: String, confirmed: Bool = false)
        async
    {
        guard let model else { return }
        if !confirmed, predatesSplit(commit) {
            pendingRestore = PendingRestore(variantID: variantID, commit: commit)
            onChanged?()
            return
        }
        pendingRestore = nil
        status = nil
        await model.autosave.flushNow()
        guard !model.autosave.isDirty else {
            report(.refusal(
                "Unsaved changes couldn't be written — resolve that first, then retry."))
            return
        }
        do {
            try await runner.run { ops in
                try ops.restoreCommit(variantID, commitID: commit.id)
            }
            await model.refreshTakesFromStore()
            report(.receipt(BlockHistoryCopy.restoredSavepoint))
            await refresh()
        } catch {
            report(.refusal(Self.refusalMessage(error, act: "restore this commit")))
        }
    }

    func confirmPendingRestore() async {
        guard let pending = pendingRestore else { return }
        await restore(pending.commit, of: pending.variantID, confirmed: true)
    }

    func cancelPendingRestore() {
        guard pendingRestore != nil else { return }
        pendingRestore = nil
        onChanged?()
    }

    // MARK: - Region 2: unarchive

    func unarchive(_ variantID: String) async {
        status = nil
        do {
            try await runner.run { ops in try ops.unarchiveVariant(variantID) }
            await model?.refreshTakesFromStore()
            report(.receipt(BlockHistoryCopy.unarchivedTake))
            await refresh()
        } catch {
            report(.refusal(Self.refusalMessage(error, act: "unarchive this take")))
        }
    }

    // MARK: - Region 3: put a deleted take back (NO purge door here)

    /// `restoreVariant` — the recovery-door class (no undo entry: the door IS
    /// the recovery). The receipt reads the op's OWN answer, because the
    /// restore is an exact flip (#68(b)) and a take archived when it was
    /// deleted comes back archived.
    func putBackTake(_ variantID: String) async {
        status = nil
        do {
            let restored = try await runner.run { ops in
                try ops.restoreVariant(variantID)
            }
            await model?.refreshTakesFromStore()
            report(.receipt(BlockPastCopy.restored(restored)))
            await refresh()
        } catch {
            report(.refusal(Self.refusalMessage(error, act: "put this take back")))
        }
    }

    // MARK: - Region 4: bring an original back

    /// The one-button `placeBlock` road, through the SHARED act the Mac's own
    /// door calls (`PreservedOriginPutBack`) — so two platforms' doors onto
    /// one act cannot drift on where the block lands or what the receipt says.
    func bringBack(_ originBlockID: String) async {
        guard let model else { return }
        status = nil
        do {
            let receipt = try await PreservedOriginPutBack.run(
                session: session, postID: model.postID, blockID: originBlockID)
            report(.receipt(receipt))
            await refresh()
        } catch {
            report(.refusal(Self.refusalMessage(error, act: "bring this original back")))
        }
    }

    // MARK: - Status

    private func report(_ status: RecoveryStatus) {
        self.status = status
        onChanged?()
    }

    // MARK: - Refusal copy (the ops' real refusals, phone words)

    static func refusalMessage(_ error: Error, act: String) -> String {
        guard let error = error as? OperationError else {
            return String(describing: error)
        }
        switch error {
        case .lockedPost:
            return "This note is locked — unlock it to \(act)."
        case .lockedVariant:
            // Commit AND restore both reach the frozen buffer — the
            // standing locked-take sentence names the road for both.
            return MobileEditorViewModel.lockedTakeRefusal
        default:
            return String(describing: error)
        }
    }
}
