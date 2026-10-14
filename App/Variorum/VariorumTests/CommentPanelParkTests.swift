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
//  LADDER ROUND 3 (F1 + F2 + the raise): the restore moved OUT of the
//  model's init (a `State(initialValue:)` side effect ran on phantom view
//  constructions and ate the park — F1) into `restoreParkedDraft()`, the
//  panel's `.task` home; the restore became a NON-CONSUMING PEEK (this
//  panel's close never files the add draft, so clear-at-restore made
//  reopen-then-close lose the words — F2); the clear is keyed by the SAME
//  DRAFT `(blockID, commentID)` (a landed edit must not spend a parked add
//  draft's insurance — the raise). Pins (f)/(g)/(h) hold those three; the
//  round-2 pins' clear-at-restore assertions are RULED-CHANGE edits, named
//  in the round-3 record. Reverts R3-A/B/C announced there.
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

            // The panel closes; the model dies. The next open mints fresh
            // and restores from its installed lifecycle (round 3, F1).
            let reopened = CommentsPanelModel(session: session, blockID: seed.blockA)
            reopened.restoreParkedDraft()
            #expect(reopened.addDraft == Self.typed, "her words came back")
            #expect(reopened.status == .receipt(CommentDraftPark.restoredNote),
                    "the box says why it is not empty — the receipt register")
            // RULED-CHANGE edit (round 3, F2 — the peek): the restore no
            // longer spends the insurance; it holds until the draft lands
            // or a newer refusal replaces it.
            #expect(session.commentDraftPark.held?.text == Self.typed,
                    "the peek keeps the park holding — the insurance outlives the restore")
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
            reopened.restoreParkedDraft()
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
            reopened.restoreParkedDraft()
            #expect(reopened.addDraft.isEmpty, "no ghost of the landed text")
            #expect(reopened.status == nil)
            let stored = try await db.read { [blockID = seed.blockA] database in
                try Queries.blockComments(database, blockID: blockID)
            }
            #expect(stored.map(\.text) == [Self.typed], "exactly one row — the landed one")
        }
    }

    /// **PIN (d) — THE GUARD (green on both sides, by design).** A draft
    /// she typed and never filed is not parked by TYPING: the park is
    /// written at a refusal or at the panel's LEAVING, never per keystroke.
    /// (RULED-CHANGE, VX-282 U5 — this doc only: it said "the panel's close
    /// keeps nothing"; her VX-257 ruling — *"yes, clicking away should save
    /// your half typed comment on a draft"* — makes the leaving keep a
    /// non-empty box, pinned in `CommentPanelLeaveTests`. ⎋'s clear stays her
    /// deliberate abandon there; filing on leaving stays ruled out, #118(a).)
    @Test func anUnsubmittedDraftStaysHerOrdinaryAbandon() async throws {
        try await withPanelWorld { session, _ in
            let seed = try await seedPanelPost(session)
            let panel = CommentsPanelModel(session: session, blockID: seed.blockA)
            panel.addDraft = "typed, thought better of, abandoned"

            #expect(session.commentDraftPark.held == nil,
                    "nothing was refused, so nothing is parked")
            let reopened = CommentsPanelModel(session: session, blockID: seed.blockA)
            reopened.restoreParkedDraft()
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
            other.restoreParkedDraft()
            #expect(other.addDraft.isEmpty, "another block's panel shows nothing of it")
            #expect(other.status == nil)
            #expect(session.commentDraftPark.held?.blockID == seed.blockA,
                    "…and the park still holds the first block's draft")

            let reopened = CommentsPanelModel(session: session, blockID: seed.blockA)
            reopened.restoreParkedDraft()
            #expect(reopened.addDraft == Self.typed, "its own block's panel restores it")
        }
    }

    /// **PIN (f) — RED ON OLD (the consuming take): the TWO-GENERATION
    /// road.** Refused → close → reopen (restored) → close WITHOUT filing
    /// (the unlock trip the refusal itself names) → reopen: the draft is
    /// STILL there. Under clear-at-restore the first reopen SPENT the
    /// insurance and the second close lost the words for good (round 3,
    /// F2 — this panel's close never files the add draft, #118(a)).
    @Test func aRestoredDraftSurvivesACloseSheNeverFiledFrom() async throws {
        try await withPanelWorld { session, _ in
            let seed = try await seedPanelPost(session)
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            let panel = CommentsPanelModel(session: session, blockID: seed.blockA)
            panel.addDraft = Self.typed
            await panel.fileAddDraft()
            #expect(panel.status?.isRefusal == true, "the premise: the store refused")

            // Generation 1: close → reopen → restored.
            let second = CommentsPanelModel(session: session, blockID: seed.blockA)
            second.restoreParkedDraft()
            #expect(second.addDraft == Self.typed, "generation 1 restores")

            // She closes again WITHOUT filing (going to unseal the note —
            // the refusal's own remedy). The model dies; nothing submits.
            let third = CommentsPanelModel(session: session, blockID: seed.blockA)
            third.restoreParkedDraft()
            #expect(third.addDraft == Self.typed,
                    "generation 2 STILL restores — the reopen did not spend the insurance")
            #expect(third.status == .receipt(CommentDraftPark.restoredNote))
        }
    }

    /// **PIN (g) — RED ON OLD (the init-time restore): the PHANTOM road
    /// (round 3, F1).** `State(initialValue:)` runs the model's init on
    /// every view-value construction — including phantom values the
    /// presenting body's re-evaluations mint while the panel is up, which
    /// are discarded without ever being installed. A phantom must not eat
    /// the park: only the INSTALLED panel's `.task` restores.
    @Test func aPhantomModelConstructionDoesNotEatThePark() async throws {
        try await withPanelWorld { session, _ in
            let seed = try await seedPanelPost(session)
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            let panel = CommentsPanelModel(session: session, blockID: seed.blockA)
            panel.addDraft = Self.typed
            await panel.fileAddDraft()
            #expect(session.commentDraftPark.held?.text == Self.typed,
                    "the premise: the refusal parked it")

            // The phantom: constructed by a body re-evaluation while the
            // panel is presented, never installed, never given a `.task`.
            _ = CommentsPanelModel(session: session, blockID: seed.blockA)
            #expect(session.commentDraftPark.held?.text == Self.typed,
                    "a bare construction leaves the park holding")

            // The real reopen still restores.
            let reopened = CommentsPanelModel(session: session, blockID: seed.blockA)
            reopened.restoreParkedDraft()
            #expect(reopened.addDraft == Self.typed, "the installed reopen restores")
        }
    }

    /// **PIN (h) — the CROSS-KIND guard, both directions + the same-draft
    /// clear (round 3's raise).** Under the peek the park outlives the
    /// restore, so the clear must key on THE SAME DRAFT `(blockID,
    /// commentID)`: a landed edit must not spend a parked ADD draft's
    /// insurance, a landed add must not spend a parked EDIT draft's — and
    /// a landed submit of the same draft still clears, so nothing ghosts.
    @Test func aLandedSubmitOfADifferentDraftLeavesTheParkHolding() async throws {
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
            panel.addDraft = Self.typed
            await panel.fileAddDraft()
            #expect(session.commentDraftPark.held?.commentID == nil,
                    "the premise: an ADD draft is parked")

            // Arm 1: a landed EDIT on the same block leaves the parked ADD
            // draft's insurance alone.
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.unlockPost(postID)
            }
            panel.setDraft("Sharpened v2, landing now.", for: comment.id)
            await panel.commitEdit(comment.id)
            #expect(panel.status == nil, "the premise: the edit landed")
            #expect(session.commentDraftPark.held?.text == Self.typed,
                    "…and the parked ADD draft still holds — its words have no row")

            // Arm 2: a parked EDIT draft survives a landed ADD the same way.
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            panel.setDraft("Sharpened v3, refused.", for: comment.id)
            await panel.commitEdit(comment.id)
            #expect(session.commentDraftPark.held?.commentID == comment.id,
                    "the newer refusal replaced the park with the EDIT draft")
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.unlockPost(postID)
            }
            panel.addDraft = "A fresh add, landing now."
            await panel.fileAddDraft()
            #expect(session.commentDraftPark.held?.commentID == comment.id,
                    "the landed ADD left the parked EDIT draft holding")

            // Arm 3: the SAME draft landing still clears — no ghost.
            await panel.commitEdit(comment.id)
            #expect(session.commentDraftPark.held == nil,
                    "the same draft landed — the insurance lets go")
            let stored = try await db.read { [blockID = seed.blockA] database in
                try Queries.blockComments(database, blockID: blockID)
            }
            // The parked ADD draft (arm 1) was REPLACED by arm 2's edit
            // refusal — the recorded one-draft, newest-wins trade — so it
            // never landed: exactly the two landed rows stand.
            #expect(stored.map(\.text).sorted()
                    == ["A fresh add, landing now.", "Sharpened v3, refused."].sorted(),
                    "exactly the landed rows — the replaced add draft has none")
        }
    }
}
