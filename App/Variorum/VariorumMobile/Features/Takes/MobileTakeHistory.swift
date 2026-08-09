//
//  MobileTakeHistory.swift
//  VariorumMobile
//
//  Parity round Stage C, batch C4a — the COMMIT door + the take-history
//  face: AppSpec §9's deliberate-savepoint pillar reaches the phone. A
//  sibling type beside the takes controllers (the S1 NIT-3 law); pixels
//  in `MobileTakeHistorySheetView`; the VM only routes.
//
//  THE SHAPE (the matrix row's "a note/block-level act + a see-your-data
//  history list"): both doors ride the block ⋯ — the phone's one
//  block-acts home — and act on the caret block's DISPLAYED (peek-aware)
//  take, exactly the Mac's caret-variant semantics (⌘S commits the caret
//  take; the CommitBar's History lists it). Flip/peek to a take first
//  and the doors follow it — per-take history through composition, one
//  door per act.
//
//  - COMMIT TAKE — `Operations.commit(kind: .manual)`, FLUSH-FIRST (the
//    op snapshots the STORE buffer; pending surface bytes must land
//    first or the savepoint holds stale text — the structural doors'
//    contract, applied to the act whose whole job is the exact bytes).
//  - TAKE HISTORY… — `Queries.commitHistory` + `splitDates`, each row
//    flagged through the ONE core predicate (`commitPredatesSplit` —
//    hoisted at this batch; the Mac's CommitRules delegates to it).
//  - RESTORE — `Operations.restoreCommit`; a PRE-SPLIT row gates on a
//    confirm first (AppSpec §9's documented warning: the old commit
//    still holds the full pre-split text and restoring resurrects both
//    halves). The gate is inspectable state (`pendingRestore`) — the
//    view presents it; headless tests drive `restore(confirmed:)`.
//
//  Reads are refresh-on-event (the comments controller's discipline):
//  at open, after every verb, and on projection ingests while open.
//

import Foundation
import UIKit
import VariorumCore

@MainActor
final class MobileTakeHistoryController {
    private let session: AppSession
    private var runner: OperationsRunner { session.runner }
    weak var model: MobileEditorViewModel?

    /// The block the sheet is open on. nil = closed.
    private(set) var openBlockID: String?
    /// The take whose history the open sheet lists — the DISPLAYED take
    /// captured at open (a peek's take while peeking; the shown chosen
    /// otherwise). Deliberately held for the sheet's life: the list
    /// names ONE take's history, and a remote flip mid-read must not
    /// silently swap whose past you are reading (recorded).
    private(set) var variantID: String?
    private(set) var items: [HistoryItem] = []
    /// The pre-split confirm's gate (AppSpec §9's warning): set when a
    /// flagged row's restore is requested; the view presents it, and
    /// `restore(_:confirmed: true)` / `cancelPendingRestore()` resolve.
    private(set) var pendingRestore: HistoryItem?

    /// The pixels' hook: state or content changed — re-render the sheet.
    var onChanged: (() -> Void)?

    var isOpen: Bool { openBlockID != nil }

    init(session: AppSession) {
        self.session = session
    }

    struct HistoryItem: Equatable {
        let commit: CommitPoint
        let predatesSplit: Bool
    }

    // MARK: - Copy (pinned statics — promises tests can keep)

    static let committedStatus = "Committed — a savepoint of this take is kept."
    static let restoredStatus = "Restored — the take now reads as that savepoint."
    /// The row's flag word (the Mac history list's own tag).
    static let predatesSplitRowFlag = "predates a split"
    /// The confirm's message (AppSpec §9's documented warning class).
    static let predatesSplitWarning =
        "This commit predates a split of this block — restoring it brings back text from before the split."

    // MARK: - The commit door (the ⋯'s "Commit Take")

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

    /// The ⋯'s "Take History…": opens on the block's displayed take.
    func open(blockID: String) {
        guard let model, let slot = model.slot(for: blockID) else { return }
        guard let displayed = slot.variantID else {
            model.report("This block hasn't fully synced; it is read-only for now.")
            return
        }
        openBlockID = blockID
        variantID = displayed
        items = []
        pendingRestore = nil
        onChanged?()
        Task { await refresh() }
    }

    func close() {
        guard isOpen else { return }
        openBlockID = nil
        variantID = nil
        items = []
        pendingRestore = nil
        onChanged?()
    }

    /// Every projection ingest routes here (VM routing): refresh an open
    /// sheet (a restore/commit elsewhere lands live); close when the
    /// block left the surface.
    func projectionDidChange() {
        guard let blockID = openBlockID else { return }
        if model?.slot(for: blockID) == nil {
            close()
        } else {
            Task { await refresh() }
        }
    }

    /// One coherent read: the take's commits + the block's split dates,
    /// flagged through the one core predicate. Cost ∝ the take's own
    /// history + the block's split edges (P1).
    func refresh() async {
        guard let blockID = openBlockID, let variantID else { return }
        do {
            let value = try await session.database.read { db in
                (commits: try Queries.commitHistory(db, variantID: variantID),
                 splits: try Queries.splitDates(db, blockID: blockID))
            }
            // BOTH captures must still govern (C4 ladder MINOR): a
            // close→flip→reopen on the same block could let an in-flight
            // first-open read land last and list the OLD take's history
            // under the new capture. Honestly unpinnable (the read isn't
            // seam-injectable) — the mechanism is the reviewer's trace,
            // re-verified at the fix.
            guard openBlockID == blockID, self.variantID == variantID
            else { return }
            items = value.commits.map {
                HistoryItem(
                    commit: $0,
                    predatesSplit: Queries.commitPredatesSplit(
                        commitDate: $0.createdAt, splitDates: value.splits))
            }
            onChanged?()
        } catch {
            model?.report(String(describing: error))
        }
    }

    // MARK: - Restore (AppSpec §9's warning rides the pre-split road)

    /// Restores a savepoint into the take's buffer. A PRE-SPLIT row
    /// gates on the confirm first (`pendingRestore` — the view presents
    /// it); the restore itself is flush-first like every door that
    /// rewrites a buffer (a pending flush landing after it would
    /// overwrite the restored text with the stale surface — the
    /// stale-flush class).
    func restore(_ item: HistoryItem, confirmed: Bool = false) async {
        guard let model, let variantID else { return }
        if item.predatesSplit && !confirmed {
            pendingRestore = item
            onChanged?()
            return
        }
        pendingRestore = nil
        await model.autosave.flushNow()
        guard !model.autosave.isDirty else {
            model.report("Unsaved changes couldn't be written — resolve that first, then retry.")
            return
        }
        do {
            try await runner.run { ops in
                try ops.restoreCommit(variantID, commitID: item.commit.id)
            }
            model.report(Self.restoredStatus)
            await model.refreshTakesFromStore()
            await refresh()
            onChanged?()
        } catch {
            model.report(Self.refusalMessage(error, act: "restore this savepoint"))
        }
    }

    func cancelPendingRestore() {
        guard pendingRestore != nil else { return }
        pendingRestore = nil
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
