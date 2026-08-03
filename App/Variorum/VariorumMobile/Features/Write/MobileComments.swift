//
//  MobileComments.swift
//  VariorumMobile
//
//  Mobile Stage 4, batch 1 (M12) — the block's comments sheet: the BRAIN.
//  A sibling type beside the takes controllers (the S1 NIT-3 law); pixels
//  in `MobileCommentsSheetView`. The Mac `CommentsPanelModel`'s semantics
//  mirrored: list + the DELETED section (visible and resurrectable — the
//  never-skimpy rule ports cheaply, so it ships), CRUD through the
//  standing ops with the ops' REAL refusals speaking (the Mac panel's
//  wordings, phone-grammared where the road lives on the Mac).
//
//  Reads are REFRESH-ON-EVENT rather than a third observation loop: the
//  sheet re-reads its two lists at open, after every verb, and on every
//  projection ingest while open (comment writes touch `block_comment`,
//  which the takes projection's comment counts join — so deliveries
//  arrive exactly when comments change; the browser's deterministic
//  refresh discipline, applied).
//

import Foundation
import UIKit
import VariorumCore

@MainActor
final class MobileCommentsController {
    private let session: AppSession
    weak var model: MobileEditorViewModel?

    /// The block the sheet is open on. nil = closed.
    private(set) var openBlockID: String?
    private(set) var comments: [BlockComment] = []
    private(set) var deleted: [BlockComment] = []
    /// The deleted section's fold (collapsed by default — the Mac panel).
    var deletedShown = false
    /// The comment being edited through the draft field. nil = adding.
    private(set) var editingID: String?

    /// The pixels' hook: state or content changed — re-render the sheet.
    var onChanged: (() -> Void)?

    var isOpen: Bool { openBlockID != nil }

    init(session: AppSession) {
        self.session = session
    }

    // MARK: - Open / close

    func open(blockID: String) {
        guard let model, model.slot(for: blockID) != nil else { return }
        openBlockID = blockID
        editingID = nil
        deletedShown = false
        onChanged?()
        Task { await refresh() }
    }

    func close() {
        guard isOpen else { return }
        openBlockID = nil
        editingID = nil
        onChanged?()
    }

    /// Every projection ingest routes here (VM routing): refresh an open
    /// sheet's lists; close when the block left the surface.
    func projectionDidChange() {
        guard let blockID = openBlockID else { return }
        if model?.slot(for: blockID) == nil {
            close()
        } else {
            Task { await refresh() }
        }
    }

    /// One coherent read of both lists (the Mac panel's snapshot shape).
    func refresh() async {
        guard let blockID = openBlockID else { return }
        do {
            let value = try await session.database.read { db in
                (live: try Queries.blockComments(db, blockID: blockID),
                 deleted: try Queries.deletedBlockComments(db, blockID: blockID))
            }
            guard openBlockID == blockID else { return }
            comments = value.live
            deleted = value.deleted
            onChanged?()
        } catch {
            model?.report(String(describing: error))
        }
    }

    // MARK: - The verbs (CRUD + restore, the standing ops)

    func add(_ text: String) async {
        guard let blockID = openBlockID else { return }
        await run { ops in _ = try ops.addBlockComment(to: blockID, text: text) }
    }

    func beginEditing(_ id: String) {
        guard comments.contains(where: { $0.id == id }) else { return }
        editingID = id
        onChanged?()
    }

    func cancelEditing() {
        editingID = nil
        onChanged?()
    }

    /// The draft field's submit: edits the comment under edit, else adds.
    func submitDraft(_ text: String) async {
        if let editingID {
            self.editingID = nil
            await run { ops in try ops.editBlockComment(editingID, text: text) }
        } else {
            await add(text)
        }
    }

    func delete(_ id: String) async {
        await run { ops in try ops.deleteBlockComment(id) }
    }

    func restore(_ id: String) async {
        await run { ops in try ops.restoreBlockComment(id) }
    }

    private func run(_ body: @escaping @Sendable (Operations) throws -> Void) async {
        guard let model else { return }
        do {
            try await session.runner.run(body)
            model.report(nil)
            await refresh()
            // The marker follows the count (slot.commentCount rides the
            // projection): one fresh coherent read through the one door.
            await model.refreshTakesFromStore()
        } catch {
            model.report(Self.refusalMessage(error))
        }
    }

    /// The Mac panel's refusal mapping, phone-grammared: the everyday
    /// cases speak plainly and name the Mac where the road lives there;
    /// the rest is the operations layer's own words.
    static func refusalMessage(_ error: Error) -> String {
        guard let error = error as? OperationError else {
            return String(describing: error)
        }
        switch error {
        case .lockedPost:
            return "This note is locked — unlock it on the Mac to change comments."
        case .invalidCommentText:
            return "A comment needs some text."
        default:
            return String(describing: error)
        }
    }
}
