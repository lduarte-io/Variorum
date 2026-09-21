//
//  MobileCommentParkTests.swift
//  VariorumMobileTests
//
//  **RUN A ladder round 2, the MAJOR — a refused comment draft survives
//  the sheet's close** (the orchestrator's fork ruling: the row-65 park's
//  shape extended to the comments sheet; PROVISIONAL, QUESTIONS #140).
//
//  THE MECHANISM, traced: 17b P4 taught the field to KEEP a refused draft
//  — and the sheet's close then destroyed it anyway. `render()`'s
//  open→closed transition clears the field, and every close road reaches
//  it: the dim-tap, Done, and `projectionDidChange`'s auto-close when the
//  block leaves the surface. The refusal's own sentence INVITES the close
//  ("This note is locked — unlock it to change comments": the unlock
//  lives outside the sheet), so the inviting gesture was the destroying
//  one. The park (`CommentDraftPark`, one brain with the Mac panel's)
//  holds the REFUSED submitted text on the controller, parked at refusal
//  time so no close site needed touching.
//
//  DISCRIMINATING REVERT (R2-A, announced in the round-2 record): remove
//  the `draftPark.park(...)` call from `submitDraft`'s `.refused` arm —
//  pins (i), (ii), (iv) and (v) go red at their park/restore arms; the
//  guard (iii) stays green (her abandon grammar never parked anything).
//
//  LADDER ROUND 3 (F2 + the raise): the restore became a NON-CONSUMING
//  PEEK — this sheet's close never submits, so clear-at-restore made
//  reopen-then-close-without-filing lose the words for good — and the
//  clear is keyed by the SAME DRAFT `(blockID, commentID)` (a landed edit
//  must not spend a parked add draft's insurance). Pins (vi)/(vii) hold
//  those; pin (i)'s clear-at-restore assertion is a RULED-CHANGE edit,
//  named in the round-3 record. Reverts R3-A/R3-C announced there.
//

import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
private func seedTwoBlockPost(
    _ session: AppSession
) async throws -> (postID: String, blockA: String, blockB: String) {
    try await session.runner.run { ops in
        let post = try ops.createPost(title: "comment park", profile: .blog)
        let a = try ops.newBlock(
            in: post.id, text: "First block here.", at: .end, registeringUndo: false)
        let b = try ops.newBlock(
            in: post.id, text: "Second block here.", at: .end, registeringUndo: false)
        return (post.id, a.block.id, b.block.id)
    }
}

/// Any descendant carrying this accessibility identifier.
private func find(_ identifier: String, in root: UIView) -> UIView? {
    if root.accessibilityIdentifier == identifier { return root }
    for child in root.subviews {
        if let hit = find(identifier, in: child) { return hit }
    }
    return nil
}

/// The mounted-sheet world the P4 pins established: a real window, the
/// real sheet, the real door.
@MainActor
private func mounted(
    _ surface: MobileWriteSurfaceView
) -> (window: UIWindow, host: UIViewController) {
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 700))
    let host = UIViewController()
    host.view.addSubview(surface)
    surface.frame = host.view.bounds
    window.rootViewController = host
    window.makeKeyAndVisible()
    window.layoutIfNeeded()
    return (window, host)
}

@MainActor
@Suite("RUN A ladder round 2 — a refused comment draft survives the close", .serialized)
struct MobileCommentParkTests {
    /// **PIN (i) — RED ON OLD.** Refused, then CLOSED (the gesture the
    /// refusal's sentence invites), then the SAME block's comments opened
    /// again: the draft AND the edit target come back, and the box says
    /// why it is not empty. On the shipped code the reopen is empty and
    /// the edit target gone.
    @Test func aRefusedDraftComesBackAtTheNextOpenOfItsBlock() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedTwoBlockPost(session)
            let (model, surface) = await makeSurfaceEditor(session, postID: seed.postID)
            let (window, _) = mounted(surface)
            defer { window.isHidden = true }

            model.openComments(blockID: seed.blockA)
            #expect(await model.comments.add("First thought."))
            let comment = try #require(model.comments.comments.first)
            model.comments.beginEditing(comment.id)

            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            let sheet = try #require(surface.textView.commentsSheetView)
            let field = try #require(find("comments.draft", in: sheet) as? UITextView)
            let submit = try #require(find("comments.submit", in: sheet) as? UIButton)
            let typed = "Sharpened, and worth keeping across the close."
            field.text = typed
            submit.sendActions(for: .touchUpInside)
            await settle { model.statusMessage != nil }
            #expect(field.text == typed, "the premise: P4's fix — the field kept it")

            // The close the refusal invites (the unlock lives outside the
            // sheet). The shipped code wipes the field here, forever.
            model.comments.close()
            window.layoutIfNeeded()
            #expect(model.comments.isOpen == false)

            // The next open of the SAME block takes the draft back.
            model.openComments(blockID: seed.blockA)
            window.layoutIfNeeded()
            #expect(field.text == typed, "her words came back")
            #expect(model.comments.editingID == comment.id,
                    "…and the comment she was editing is still the target")
            #expect(model.comments.restoredNote == CommentDraftPark.restoredNote,
                    "the box says why it is not empty")
            let restoredLabel = try #require(
                find("comments.restored", in: sheet) as? UILabel)
            #expect(!restoredLabel.isHidden)

            // RULED-CHANGE edit (round 3, F2 — the peek): the restore no
            // longer spends the insurance; the park holds until the draft
            // lands or a newer refusal replaces it.
            #expect(model.comments.draftPark.held?.text == typed,
                    "the peek keeps the park holding — the insurance outlives the restore")
        }
    }

    /// **PIN (ii)** — a landed submit of the parked block clears the park,
    /// so a draft with a row never comes back as a ghost.
    @Test func aLandedSubmitClearsTheParkSoNothingComesBackAsAGhost() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedTwoBlockPost(session)
            let (model, surface) = await makeSurfaceEditor(session, postID: seed.postID)
            let (window, _) = mounted(surface)
            defer { window.isHidden = true }

            model.openComments(blockID: seed.blockA)
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            let typed = "A paragraph the store refuses, then takes."
            #expect(await model.comments.submitDraft(typed) == false)
            #expect(model.comments.draftPark.held?.text == typed,
                    "the premise: the refusal parked it")

            // The store recovers and the SAME open sheet's retry lands.
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.unlockPost(postID)
            }
            #expect(await model.comments.submitDraft(typed))
            #expect(model.comments.draftPark.held == nil,
                    "landed — the park holds nothing")

            model.comments.close()
            window.layoutIfNeeded()
            model.openComments(blockID: seed.blockA)
            window.layoutIfNeeded()
            let sheet = try #require(surface.textView.commentsSheetView)
            let field = try #require(find("comments.draft", in: sheet) as? UITextView)
            #expect((field.text ?? "").isEmpty, "no ghost of the landed text")
            #expect(model.comments.restoredNote == nil)
            let stored = try await db.read { [blockID = seed.blockA] database in
                try Queries.blockComments(database, blockID: blockID)
            }
            #expect(stored.map(\.text) == [typed], "exactly one row — the landed one")
        }
    }

    /// **PIN (iii) — THE GUARD (green on both sides, by design).** A draft
    /// she typed and never submitted is her ordinary abandon: the close
    /// keeps nothing, exactly as before — the park can never widen into a
    /// general draft-keeper (binding 1).
    @Test func anUnsubmittedDraftStaysHerOrdinaryAbandon() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedTwoBlockPost(session)
            let (model, surface) = await makeSurfaceEditor(session, postID: seed.postID)
            let (window, _) = mounted(surface)
            defer { window.isHidden = true }

            model.openComments(blockID: seed.blockA)
            let sheet = try #require(surface.textView.commentsSheetView)
            let field = try #require(find("comments.draft", in: sheet) as? UITextView)
            field.text = "typed, thought better of, abandoned"

            model.comments.close()
            window.layoutIfNeeded()
            #expect(model.comments.draftPark.held == nil,
                    "nothing was refused, so nothing is parked")

            model.openComments(blockID: seed.blockA)
            window.layoutIfNeeded()
            #expect((field.text ?? "").isEmpty, "the reopen is a fresh box — her ruled abandon")
            #expect(model.comments.restoredNote == nil)
        }
    }

    /// **PIN (iv)** — a DIFFERENT block's open shows nothing of the parked
    /// draft and leaves it held; the draft's own block still restores it.
    @Test func aDifferentBlocksOpenShowsNothingAndLeavesItHeld() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedTwoBlockPost(session)
            let (model, surface) = await makeSurfaceEditor(session, postID: seed.postID)
            let (window, _) = mounted(surface)
            defer { window.isHidden = true }

            model.openComments(blockID: seed.blockA)
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            let typed = "Parked on the first block."
            #expect(await model.comments.submitDraft(typed) == false)
            model.comments.close()
            window.layoutIfNeeded()

            // Another block's comments: nothing of it shows, nothing is lost.
            model.openComments(blockID: seed.blockB)
            window.layoutIfNeeded()
            let sheet = try #require(surface.textView.commentsSheetView)
            let field = try #require(find("comments.draft", in: sheet) as? UITextView)
            #expect((field.text ?? "").isEmpty)
            #expect(model.comments.restoredNote == nil)
            #expect(model.comments.draftPark.held?.blockID == seed.blockA,
                    "…and the park still holds the first block's draft")

            model.comments.close()
            window.layoutIfNeeded()
            model.openComments(blockID: seed.blockA)
            window.layoutIfNeeded()
            #expect(field.text == typed, "its own block's open restores it")
        }
    }

    /// **PIN (v)** — the AUTO-CLOSE road (`projectionDidChange` closing the
    /// sheet because its block left the surface) cannot destroy the park:
    /// parking happened at REFUSAL time, not at close time (binding 2 —
    /// why no close site needed touching).
    @Test func theAutoCloseRoadParksTheSame() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedTwoBlockPost(session)
            let (model, surface) = await makeSurfaceEditor(session, postID: seed.postID)
            let (window, _) = mounted(surface)
            defer { window.isHidden = true }

            model.openComments(blockID: seed.blockA)
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            let typed = "Refused just before the block left the surface."
            #expect(await model.comments.submitDraft(typed) == false)

            // The block leaves the surface; the projection ingest routes
            // to `projectionDidChange`, which closes the open sheet.
            try await session.runner.run { [postID = seed.postID, blockID = seed.blockA] ops in
                try ops.unlockPost(postID)
                try ops.deleteBlock(blockID)
            }
            await model.refreshTakesFromStore()
            #expect(model.comments.isOpen == false, "the premise: the auto-close ran")
            #expect(model.comments.draftPark.held?.text == typed,
                    "…and the park still holds her words — the auto-close is just another close")
        }
    }

    /// **PIN (vi) — RED ON OLD (the consuming take): the TWO-GENERATION
    /// road (round 3, F2).** Refused → close → reopen (restored) → close
    /// WITHOUT filing (the unlock trip the refusal itself names) → reopen:
    /// the draft is STILL there. Under clear-at-restore the first reopen
    /// SPENT the insurance and the second close wiped the field for good.
    @Test func aRestoredDraftSurvivesACloseSheNeverFiledFrom() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedTwoBlockPost(session)
            let (model, surface) = await makeSurfaceEditor(session, postID: seed.postID)
            let (window, _) = mounted(surface)
            defer { window.isHidden = true }

            model.openComments(blockID: seed.blockA)
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            let typed = "Two closes, still here."
            #expect(await model.comments.submitDraft(typed) == false)
            model.comments.close()
            window.layoutIfNeeded()

            // Generation 1: reopen restores.
            model.openComments(blockID: seed.blockA)
            window.layoutIfNeeded()
            let sheet = try #require(surface.textView.commentsSheetView)
            let field = try #require(find("comments.draft", in: sheet) as? UITextView)
            #expect(field.text == typed, "generation 1 restores")

            // She closes again WITHOUT filing — going to unlock the note,
            // which is the refusal's own remedy. The field wipes (the
            // surface's standing close); the park must not have been spent.
            model.comments.close()
            window.layoutIfNeeded()
            #expect((field.text ?? "").isEmpty, "the close still wipes the field")

            model.openComments(blockID: seed.blockA)
            window.layoutIfNeeded()
            #expect(field.text == typed,
                    "generation 2 STILL restores — the reopen did not spend the insurance")
            #expect(model.comments.restoredNote == CommentDraftPark.restoredNote)
        }
    }

    /// **PIN (vii) — the CROSS-KIND guard, both directions + the
    /// same-draft clear (round 3's raise).** Under the peek the park
    /// outlives the restore, so the clear must key on THE SAME DRAFT
    /// `(blockID, commentID)`: a landed edit must not spend a parked ADD
    /// draft's insurance, a landed add must not spend a parked EDIT
    /// draft's — and the same draft landing still clears (no ghost).
    @Test func aLandedSubmitOfADifferentDraftLeavesTheParkHolding() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedTwoBlockPost(session)
            let (model, surface) = await makeSurfaceEditor(session, postID: seed.postID)
            let (window, _) = mounted(surface)
            defer { window.isHidden = true }

            model.openComments(blockID: seed.blockA)
            #expect(await model.comments.add("First thought."))
            let comment = try #require(model.comments.comments.first)

            // An ADD draft is parked by a refusal.
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            let addTyped = "An add the store refused."
            #expect(await model.comments.submitDraft(addTyped) == false)
            #expect(model.comments.draftPark.held?.commentID == nil,
                    "the premise: an ADD draft is parked")

            // Arm 1: a landed EDIT on the same block leaves it holding.
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.unlockPost(postID)
            }
            model.comments.beginEditing(comment.id)
            #expect(await model.comments.submitDraft("Sharpened v2, landing now."))
            #expect(model.comments.draftPark.held?.text == addTyped,
                    "the parked ADD draft still holds — its words have no row")

            // Arm 2: a parked EDIT draft survives a landed ADD the same way.
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            model.comments.beginEditing(comment.id)
            #expect(await model.comments.submitDraft("Sharpened v3, refused.") == false)
            #expect(model.comments.draftPark.held?.commentID == comment.id,
                    "the newer refusal replaced the park with the EDIT draft")
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.unlockPost(postID)
            }
            model.comments.cancelEditing()
            #expect(await model.comments.submitDraft("A fresh add, landing now."))
            #expect(model.comments.draftPark.held?.commentID == comment.id,
                    "the landed ADD left the parked EDIT draft holding")

            // Arm 3: the SAME draft landing still clears — no ghost.
            model.comments.beginEditing(comment.id)
            #expect(await model.comments.submitDraft("Sharpened v3, refused."))
            #expect(model.comments.draftPark.held == nil,
                    "the same draft landed — the insurance lets go")
        }
    }
}
