//
//  CommentPanelParkTests.swift
//  VariorumTests
//
//  **RUN A ladder round 2, the MAJOR — binding 5's sweep: the Mac comments
//  panel's refused drafts survive the panel's close** (the orchestrator's
//  fork ruling extended by its own binding 5; PROVISIONAL, QUESTIONS #140).
//
//  THE MECHANISM, traced: `CommentsPanelModel` is minted per presentation
//  at its ONE construction site (`CommentsPanel.init`) and dies with the
//  sheet or popover — Close, a click outside the popover, ⎋⎋. A refusal
//  correctly KEEPS `addDraft` (and a dirty row's draft) on the model and
//  speaks in the panel — and the close then took the model, drafts and
//  all. The add draft is deliberately never filed on leaving (#118(a));
//  `onDisappear` commits dirty ROWS, and under a sealed note that commit
//  REFUSES on a dying model. Both arms are row 65's class on the Mac's
//  own comment surface. The park (`CommentDraftPark`, one brain with the
//  phone sheet's) lives on `AppSession` — the home that outlives the
//  model — and parks at REFUSAL time in `fileAddDraft` / `commitEdit`, so
//  no close site changed.
//
//  DISCRIMINATING REVERT (R2-B, announced in the round-2 record): remove
//  both `commentDraftPark.park(...)` calls — pins (a) and (b) go red at
//  their restore arms, (c) and (e) at their parked premises; the guard
//  (d) stays green (an unsubmitted draft never parked anything).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withPanelWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 23))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
private func seedPanelPost(
    _ session: AppSession
) async throws -> (postID: String, blockA: String, blockB: String) {
    try await session.runner.run { ops in
        let post = try ops.createPost(title: "panel park", profile: .blog)
        let a = try ops.newBlock(
            in: post.id, text: "First block here.", at: .end, registeringUndo: false)
        let b = try ops.newBlock(
            in: post.id, text: "Second block here.", at: .end, registeringUndo: false)
        return (post.id, a.block.id, b.block.id)
    }
}

@MainActor
@Suite("RUN A ladder round 2 — the Mac panel's refused drafts survive its close", .serialized)
struct CommentPanelParkTests {
    private static let typed = "A paragraph the store refused, one Close from gone."

    /// **PIN (a) — RED ON OLD.** A refused ADD draft comes back at the
    /// next open of the same block's panel — a FRESH model, exactly as the
    /// per-presentation `@State` produces — saying why the box is not
    /// empty, in the receipt register (nothing is being refused).
    @Test func aRefusedAddDraftComesBackAtTheNextOpenOfItsBlocksPanel() async throws {
        try await withPanelWorld { session, _ in
            let seed = try await seedPanelPost(session)
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            let panel = CommentsPanelModel(session: session, blockID: seed.blockA)
            panel.addDraft = Self.typed
            await panel.fileAddDraft()
            #expect(panel.status?.isRefusal == true, "the premise: the store refused")
            #expect(panel.addDraft == Self.typed, "…and the panel kept the draft (shipped)")

            // The panel closes; the model dies. The next open mints fresh.
            let reopened = CommentsPanelModel(session: session, blockID: seed.blockA)
            #expect(reopened.addDraft == Self.typed, "her words came back")
            #expect(reopened.status == .receipt(CommentDraftPark.restoredNote),
                    "the box says why it is not empty — the receipt register")
            #expect(session.commentDraftPark.held == nil,
                    "clear-at-restore: the panel is the only home again")
        }
    }

    /// **PIN (b) — RED ON OLD.** A refused IN-PLACE EDIT rides the park
    /// with its row: the `onDisappear` net's close-time commit is exactly
    /// the call that parks, so the close sites needed no change.
    @Test func aRefusedInPlaceEditRidesTheParkOntoItsRow() async throws {
        try await withPanelWorld { session, db in
            let seed = try await seedPanelPost(session)
            let comment = try await session.runner.run { [blockID = seed.blockA] ops in
                try ops.addBlockComment(to: blockID, text: "First thought.")
            }
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            let panel = CommentsPanelModel(session: session, blockID: seed.blockA)
            panel.adopt(.init(live: [comment], deleted: []))
            panel.setDraft("Sharpened, and worth keeping.", for: comment.id)
            // The close road: `onDisappear` commits every dirty row — this
            // call — and the refusal lands on a dying model.
            await panel.commitEdit(comment.id)
            #expect(panel.status?.isRefusal == true, "the premise: the commit refused")

            let reopened = CommentsPanelModel(session: session, blockID: seed.blockA)
            #expect(reopened.draft(for: comment.id) == "Sharpened, and worth keeping.",
                    "the refused edit is back on its row")
            #expect(reopened.status == .receipt(CommentDraftPark.restoredNote))
            // The first snapshot keeps it — the comment is live and the
            // draft is dirty against it (`survivingDrafts`' own rule).
            let live = try await db.read { [blockID = seed.blockA] database in
                try Queries.blockComments(database, blockID: blockID)
            }
            reopened.adopt(.init(live: live, deleted: []))
            #expect(reopened.draft(for: comment.id) == "Sharpened, and worth keeping.")
            #expect(reopened.isDirty(comment.id), "…and the row wears its unsaved mark")
        }
    }

    /// **PIN (c)** — a landed submit of the parked block clears the park,
    /// so a draft with a row never comes back as a ghost.
    @Test func aLandedSubmitClearsTheParkSoNothingComesBackAsAGhost() async throws {
        try await withPanelWorld { session, db in
            let seed = try await seedPanelPost(session)
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            let panel = CommentsPanelModel(session: session, blockID: seed.blockA)
            panel.addDraft = Self.typed
            await panel.fileAddDraft()
            #expect(session.commentDraftPark.held?.text == Self.typed,
                    "the premise: the refusal parked it")

            // The store recovers and the SAME open panel's retry lands.
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.unlockPost(postID)
            }
            await panel.fileAddDraft()
            #expect(panel.addDraft.isEmpty, "landed — the add area lets go")
            #expect(session.commentDraftPark.held == nil, "…and the park holds nothing")

            let reopened = CommentsPanelModel(session: session, blockID: seed.blockA)
            #expect(reopened.addDraft.isEmpty, "no ghost of the landed text")
            #expect(reopened.status == nil)
            let stored = try await db.read { [blockID = seed.blockA] database in
                try Queries.blockComments(database, blockID: blockID)
            }
            #expect(stored.map(\.text) == [Self.typed], "exactly one row — the landed one")
        }
    }

    /// **PIN (d) — THE GUARD (green on both sides, by design).** A draft
    /// she typed and never filed is her ordinary abandon — ⎋'s clear and
    /// the panel's close keep nothing, exactly as ruled (#118(a); the ⎋
    /// ladder), so the park can never widen into a general draft-keeper.
    @Test func anUnsubmittedDraftStaysHerOrdinaryAbandon() async throws {
        try await withPanelWorld { session, _ in
            let seed = try await seedPanelPost(session)
            let panel = CommentsPanelModel(session: session, blockID: seed.blockA)
            panel.addDraft = "typed, thought better of, abandoned"

            #expect(session.commentDraftPark.held == nil,
                    "nothing was refused, so nothing is parked")
            let reopened = CommentsPanelModel(session: session, blockID: seed.blockA)
            #expect(reopened.addDraft.isEmpty, "the reopen is a fresh box — her ruled abandon")
            #expect(reopened.status == nil)
        }
    }

    /// **PIN (e)** — a DIFFERENT block's panel shows nothing of the parked
    /// draft and leaves it held; the draft's own block still restores it.
    @Test func aDifferentBlocksPanelShowsNothingAndLeavesItHeld() async throws {
        try await withPanelWorld { session, _ in
            let seed = try await seedPanelPost(session)
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            let panel = CommentsPanelModel(session: session, blockID: seed.blockA)
            panel.addDraft = Self.typed
            await panel.fileAddDraft()
            #expect(session.commentDraftPark.held?.blockID == seed.blockA)

            let other = CommentsPanelModel(session: session, blockID: seed.blockB)
            #expect(other.addDraft.isEmpty, "another block's panel shows nothing of it")
            #expect(other.status == nil)
            #expect(session.commentDraftPark.held?.blockID == seed.blockA,
                    "…and the park still holds the first block's draft")

            let reopened = CommentsPanelModel(session: session, blockID: seed.blockA)
            #expect(reopened.addDraft == Self.typed, "its own block's panel restores it")
        }
    }
}
