//
//  MobileCommentDraftTests.swift
//  VariorumMobileTests
//
//  **17b P4 (RUN A, batch A1) — a refused comment must not eat the
//  comment.**
//
//  THE MECHANISM, traced: `MobileCommentsSheetView.submitDraft()` read the
//  field, wrote `draftField.text = ""`, and only THEN fired
//  `model.comments.submitDraft(text)`; the controller's `run` funnel
//  handles a throw with `model.report(...)` and nothing anywhere put the
//  words back. The refusal is reachable on an ordinary gesture, not a
//  contrived one: `open(blockID:)` has no seal check and the block menus
//  append the Comments row unconditionally (fire-and-DO), while
//  `Operations.addBlockComment` calls `ensurePlacementUnlocked` before
//  anything else and throws `.lockedPost` under a sealed note — the
//  controller even ships the sentence for it. So: seal a note, tap ⋯ →
//  Comments, type a paragraph, tap Add. The field empties, the store gains
//  nothing, and she reads "This note is locked — unlock it to change
//  comments." with her text gone and no undo.
//
//  The EDIT arm lost a second thing: `editingID` was nilled before the
//  run, so a refused edit also forgot which comment she was editing.
//
//  This is the class the project has ruled twice — QUESTIONS #120(e) and
//  the quick note's Q2 rule, *"no refusal here is ever reached by a road
//  that discarded her text"* — and the pad's own 13u3 fix is the shape
//  these pins assert: state leaves only when the store has taken it.
//
//  DISCRIMINATING REVERT (verified): in the sheet, clear the field before
//  the `Task` again; in the controller, nil `editingID` before its `run`.
//

import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
private func seedCommentPost(
    _ session: AppSession
) async throws -> (postID: String, blockID: String) {
    try await session.runner.run { ops in
        let post = try ops.createPost(title: "comments", profile: .blog)
        let a = try ops.newBlock(in: post.id, text: "First block here.", at: .end)
        return (post.id, a.block.id)
    }
}

/// Any descendant carrying this accessibility identifier.
@MainActor private func find(_ identifier: String, in root: UIView) -> UIView? {
    if root.accessibilityIdentifier == identifier { return root }
    for child in root.subviews {
        if let hit = find(identifier, in: child) { return hit }
    }
    return nil
}

@MainActor
@Suite("17b P4 — the comments draft survives a refusal")
struct MobileCommentDraftTests {
    /// **THE DOOR, DRIVEN FOR REAL**: the submit button's own action, on a
    /// mounted sheet, under a sealed note.
    @Test func aRefusedSubmitKeepsHerParagraphInTheField() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedCommentPost(session)
            let (model, surface) = await makeSurfaceEditor(session, postID: seed.postID)
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 700))
            let host = UIViewController()
            host.view.addSubview(surface)
            surface.frame = host.view.bounds
            window.rootViewController = host
            window.makeKeyAndVisible()
            defer { window.isHidden = true }
            window.layoutIfNeeded()

            // The note is SEALED — an ordinary state, and the one the
            // comment ops refuse under.
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            model.openComments(blockID: seed.blockID)
            let sheet = try #require(surface.textView.commentsSheetView)
            window.layoutIfNeeded()
            #expect(!sheet.isHidden, "the sheet really mounted")

            let field = try #require(find("comments.draft", in: sheet) as? UITextView)
            let submit = try #require(find("comments.submit", in: sheet) as? UIButton)
            let typed = "A whole paragraph she just wrote, and would have to write again."
            field.text = typed

            submit.sendActions(for: .touchUpInside)
            await settle { model.statusMessage != nil }

            #expect(field.text == typed,
                    "her words live nowhere else — the field keeps them (#120(e)'s rule)")
            #expect(model.statusMessage
                == "This note is locked — unlock it to change comments.")
            let stored = try await db.read { database in
                try Queries.blockComments(database, blockID: seed.blockID)
            }
            #expect(stored.isEmpty, "and nothing was written, so the retry is real")

            // THE RETRY LANDS, and only then does the field empty.
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.unlockPost(postID)
            }
            submit.sendActions(for: .touchUpInside)
            await settle { !(field.text ?? "").isEmpty == false }

            #expect(field.text?.isEmpty == true, "the store took it, so the field lets go")
            let after = try await db.read { database in
                try Queries.blockComments(database, blockID: seed.blockID)
            }
            #expect(after.map(\.text) == [typed])
        }
    }

    /// The EDIT arm's second loss: the row she was editing.
    @Test func aRefusedEditKeepsTheCommentItWasEditing() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedCommentPost(session)
            let (model, _) = await makeSurfaceEditor(session, postID: seed.postID)
            model.openComments(blockID: seed.blockID)
            #expect(await model.comments.add("First thought."))
            let comment = try #require(model.comments.comments.first)

            model.comments.beginEditing(comment.id)
            #expect(model.comments.editingID == comment.id)

            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            let landed = await model.comments.submitDraft("Sharpened.")

            #expect(!landed, "the door says the store refused, so the sheet can hold the draft")
            #expect(model.comments.editingID == comment.id,
                    "and she is still editing the comment she chose — the target survives")
            #expect(model.comments.comments.first?.text == "First thought.")
        }
    }

    /// The guard: the ordinary road is unchanged — a submit that lands
    /// clears the edit target and says so.
    @Test func aSubmitThatLandsSaysSoAndEndsTheEdit() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedCommentPost(session)
            let (model, _) = await makeSurfaceEditor(session, postID: seed.postID)
            model.openComments(blockID: seed.blockID)
            #expect(await model.comments.add("First thought."))
            let comment = try #require(model.comments.comments.first)

            model.comments.beginEditing(comment.id)
            #expect(await model.comments.submitDraft("Sharpened."))
            #expect(model.comments.editingID == nil)

            let stored = try await db.read { database in
                try Queries.blockComments(database, blockID: seed.blockID)
            }
            #expect(stored.map(\.text) == ["Sharpened."])
        }
    }
}
