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

    /// **RUN A ladder round 2 (the MAJOR) — where a REFUSED draft waits.**
    /// The sheet wiped its field on every close road — the dim-tap, Done,
    /// and `projectionDidChange`'s auto-close — including the close the
    /// refusal's own sentence invites (the unlock lives outside the
    /// sheet), so the paragraph P4 had just taught the field to keep died
    /// one gesture later. Row 65's class, one surface over; the park's
    /// shape is the ruled fix (PROVISIONAL, QUESTIONS #140). It lives ON
    /// THE CONTROLLER (the ruling's letter) — the controller outlives the
    /// sheet's show/hide, and the park dies with the note's editor, which
    /// is the same bounded cost the pad's park carries.
    let draftPark = CommentDraftPark()

    /// One-shot the sheet's render consumes: the parked text the open just
    /// read back. The field is the VIEW's, so the controller offers the
    /// words once PER OPEN — the one-shot protects her typing within an
    /// open (a later render must not clobber the field). It never clears
    /// the PARK's own hold: since round 3's F2 the restore is a peek, and
    /// the park lets go only when the draft lands or a newer refusal
    /// replaces it.
    private(set) var restoredDraftText: String?

    /// Why the box is not empty — its own line, never the refusal
    /// register (nothing is being refused); cleared the moment she files
    /// again, because by then it answers a question nobody is asking.
    private(set) var restoredNote: String?

    func takeRestoredDraftText() -> String? {
        defer { restoredDraftText = nil }
        return restoredDraftText
    }

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
        deletedShown = false
        // RUN A ladder round 2 (the MAJOR), amended round 3 (F2): the open
        // of the SAME block READS the refused draft back — a PEEK, never a
        // spend, because this surface's close never submits, so a consuming
        // restore made reopen-then-close-without-filing lose the words for
        // good. The park keeps holding until the draft LANDS or a newer
        // refusal replaces it; the edit target comes back with it, and one
        // line says why the box is not empty. A DIFFERENT block's open
        // shows nothing of it and leaves it held.
        if let heldDraft = draftPark.peek(forBlock: blockID) {
            restoredDraftText = heldDraft.text
            editingID = heldDraft.commentID
            restoredNote = CommentDraftPark.restoredNote
        } else {
            restoredDraftText = nil
            editingID = nil
            restoredNote = nil
        }
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

    /// Returns whether the STORE took it — the draft may only be cleared
    /// on `true` (17b P4).
    @discardableResult
    func add(_ text: String) async -> Bool {
        guard let blockID = openBlockID else { return false }
        return await run { ops in _ = try ops.addBlockComment(to: blockID, text: text) }
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
    ///
    /// **17b P4 — IT SAYS WHETHER THE STORE TOOK IT, and the edit target
    /// survives a refusal.** The sheet used to empty its field before this
    /// was ever called and this method nilled `editingID` before running,
    /// so a refusal — reachable on an ordinary gesture, since the Comments
    /// row is offered unconditionally (fire-and-DO) while
    /// `addBlockComment`/`editBlockComment` refuse under a sealed note —
    /// destroyed the comment it was protecting AND lost the row she was
    /// editing. The project has ruled this class twice (#120(e); the quick
    /// note's Q2 rule: *no refusal is ever reached by a road that
    /// discarded her text*), and the pad's own fix is the shape copied
    /// here: state leaves only when the store has taken it.
    @discardableResult
    func submitDraft(_ text: String) async -> Bool {
        guard let blockID = openBlockID else { return false }
        // Filing again — the restored line is answering a question nobody
        // is asking now (the pad's rule for its own line).
        restoredNote = nil
        let editing = editingID
        let outcome: DraftOutcome
        if let editing {
            outcome = await runDraft { ops in try ops.editBlockComment(editing, text: text) }
        } else {
            outcome = await runDraft { ops in _ = try ops.addBlockComment(to: blockID, text: text) }
        }
        switch outcome {
        case .landed:
            if editing != nil { editingID = nil }
            // A landed submit of THE SAME DRAFT clears the park — the
            // words it insured have a row now, so nothing comes back as a
            // ghost. Keyed by (blockID, commentID) since round 3's raise:
            // a landed EDIT must not spend a parked ADD draft's insurance
            // (or vice versa) — that draft never landed.
            draftPark.clearIfHeld(blockID: blockID, commentID: editing)
            onChanged?()
            return true
        case .refused:
            // **Parked at REFUSAL time, from the SUBMITTED text** (RUN A
            // ladder round 2, the MAJOR): every close road — the dim-tap,
            // Done, the projection's auto-close — is covered without
            // touching any close site, and keystrokes that land during
            // the flight are not part of what was refused. On the open
            // sheet this is belt-and-braces (the field keeps the text);
            // on the close that follows, it is the whole fix.
            draftPark.park(blockID: blockID, text: text, commentID: editing)
            onChanged?()
            return false
        case .turnedAway:
            // The latch turned it away (or the model died mid-flight):
            // nothing was written and nothing was refused — the field
            // holds, and the flight already in progress lands or parks
            // in its own turn.
            return false
        }
    }

    func delete(_ id: String) async {
        await run { ops in try ops.deleteBlockComment(id) }
    }

    func restore(_ id: String) async {
        await run { ops in try ops.restoreBlockComment(id) }
    }

    /// One flight at a time (the architectural review's MAJOR 1). This
    /// funnel is every comment write, and `addBlockComment` is the sharpest
    /// unlatched mint in the app: `block_comment` has NO uniqueness by
    /// design (AppSpec §7 — a note has no natural key), so nothing beneath
    /// the door catches a second flight and a double-tapped submit left two
    /// identical comments on the block.
    private let latch = MobileWriteLatch()

    /// What one write attempt became. The park must know a REFUSAL from a
    /// latch-turned-away gesture — parking on the latter would widen the
    /// park past refused drafts (binding 1), and nothing was written or
    /// refused there anyway.
    private enum DraftOutcome {
        case landed
        case refused
        case turnedAway
    }

    /// `true` only when the write LANDED. A gesture the latch turned away
    /// returns `false` too — nothing was written, so whatever the caller
    /// was holding must be held (it is not a refusal, and nothing reports
    /// it as one).
    @discardableResult
    private func run(_ body: @escaping @Sendable (Operations) throws -> Void) async -> Bool {
        await runDraft(body) == .landed
    }

    /// The draft doors' variant of `run`: the same latch, the same funnel,
    /// with the refusal distinguishable (see `DraftOutcome`).
    private func runDraft(
        _ body: @escaping @Sendable (Operations) throws -> Void
    ) async -> DraftOutcome {
        await latch.run { await self.runOnce(body) } ?? .turnedAway
    }

    private func runOnce(
        _ body: @escaping @Sendable (Operations) throws -> Void
    ) async -> DraftOutcome {
        // A dead model is not a refusal: nothing ran and nothing spoke —
        // the same "hold, don't park" answer the latch's turn-away gets.
        guard let model else { return .turnedAway }
        do {
            try await session.runner.run(body)
            model.report(nil)
            await refresh()
            // The marker follows the count (slot.commentCount rides the
            // projection): one fresh coherent read through the one door.
            await model.refreshTakesFromStore()
            return .landed
        } catch {
            model.report(Self.refusalMessage(error))
            return .refused
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
            return "This note is locked — unlock it to change comments."
        case .invalidCommentText:
            return "A comment needs some text."
        default:
            return String(describing: error)
        }
    }
}
