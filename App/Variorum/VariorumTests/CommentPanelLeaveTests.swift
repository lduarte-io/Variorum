//
//  CommentPanelLeaveTests.swift
//  VariorumTests
//
//  VX-257 (the VX-282 run, U5) — her ruling on P-VX179-R2-1 (2026-10-13,
//  verbatim): *"yes, clicking away should save your half typed comment on a
//  draft."* QUESTIONS #215 option (a): when the panel's host closes, a
//  non-empty composer draft PARKS in the existing `CommentDraftPark` and comes
//  back when the panel reopens on that block; ⎋ still clears deliberately
//  (the ladder empties the box before its close rung, so ⎋⎋ leaves nothing);
//  parking never files (#118(a) stands).
//
//  THE MECHANISM (traced in the run record § U5): the panel's ONE leaving body
//  — Close, `.onDisappear`, a popover host's `willClose` — committed dirty
//  in-place EDITS only; the add draft lived on the per-presentation model, so
//  a click-away took it with the model (a sheet's teardown, or — before
//  VX-229 — a stale popover panel nobody could reach again). The park took
//  REFUSED drafts only, at refusal time.
//
//  These cells drive the model's leaving body (`leave()`, the body every
//  closing road runs) and a fresh model per reopen, exactly as the
//  per-presentation `@State` produces; the mounted cells (the popover, the
//  sheets, the take panel's nested sheet) live beside VX-229's in
//  `CommentPanelHostLifecycleTests.swift`. RED ON OLD where marked; GUARD =
//  green on both sides by design.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-257 — the panel's leaving keeps a half-typed comment, and ⎋ still clears", .serialized)
struct CommentPanelLeaveTests {
    private static let half = "a half-typed thought, not done yet "

    private func storedComments(_ h: EditorHarness, _ blockID: String) async throws -> [String] {
        try await h.database.read { db in
            try Queries.blockComments(db, blockID: blockID).map(\.text)
        }
    }

    /// The panel's open, as the installed lifecycle runs it (`.task`'s first
    /// act): a fresh model per presentation, the park read back.
    private func open(_ h: EditorHarness, _ blockID: String) -> CommentsPanelModel {
        let model = CommentsPanelModel(session: h.session, blockID: blockID)
        model.restoreParkedDraft()
        return model
    }

    /// **RED ON OLD — her ruling.** A half-typed comment left in the box when
    /// the panel's host closes comes back, verbatim, at the next open of the
    /// same block — with no line claiming it "couldn't be saved" (nothing was
    /// refused) — and nothing was filed.
    @Test func leavingWithAHalfTypedCommentKeepsItForTheSameBlock() async throws {
        try await withEditor(seedBlocks: ["A block."]) { h in
            let blockID = try h.storeSlots()[0].blockID
            let panel = open(h, blockID)
            panel.addDraft = Self.half
            panel.leave()
            let held = try #require(h.session.commentDraftPark.held, "the leaving parked the draft")
            #expect(held.blockID == blockID && held.commentID == nil && held.text == Self.half,
                    "the add draft, verbatim, for its block")
            #expect(!held.refused, "…held as a draft she left, not as a refusal")

            let reopened = open(h, blockID)
            #expect(reopened.addDraft == Self.half, "her half-typed comment is back")
            #expect(reopened.status == nil,
                    "no line — the refusal's 'couldn't be saved' would be false here")
            #expect(try await storedComments(h, blockID).isEmpty,
                    "parking never files (#118(a))")
        }
    }

    /// **GUARD — ⎋ still clears deliberately.** The ladder's first ⎋ empties
    /// the box; its close rung leaves with nothing in it; the reopen is a
    /// fresh box. (A whitespace-only box is nothing to keep, the same way.)
    @Test func escapeClearsAndTheReopenIsEmpty() async throws {
        try await withEditor(seedBlocks: ["A block."]) { h in
            let blockID = try h.storeSlots()[0].blockID
            let panel = open(h, blockID)
            panel.addDraft = Self.half
            panel.clearAddDraft()  // ⎋'s clear rung
            panel.leave()          // ⎋'s close rung → `close()` → the leaving body
            #expect(h.session.commentDraftPark.held == nil, "nothing parked")
            #expect(open(h, blockID).addDraft.isEmpty, "the reopen is a fresh box")

            let blank = open(h, blockID)
            blank.addDraft = "  \n "
            blank.leave()
            #expect(h.session.commentDraftPark.held == nil, "whitespace alone is nothing to keep")
            #expect(try await storedComments(h, blockID).isEmpty)
        }
    }

    /// **RED ON OLD (at its restore premise) — ⎋ abandons a RESTORED draft
    /// for good.** Left once (parked), reopened (restored), then ⎋-cleared and
    /// closed: the park lets it go, and the next open is empty.
    @Test func escapeAfterARestoreAbandonsTheDraftForGood() async throws {
        try await withEditor(seedBlocks: ["A block."]) { h in
            let blockID = try h.storeSlots()[0].blockID
            let first = open(h, blockID)
            first.addDraft = Self.half
            first.leave()
            let second = open(h, blockID)
            try #require(second.addDraft == Self.half, "premise: the left draft was restored")
            second.clearAddDraft()
            second.leave()
            #expect(h.session.commentDraftPark.held == nil, "the deliberate clear let it go")
            #expect(open(h, blockID).addDraft.isEmpty, "nothing comes back")
        }
    }

    /// **RED ON OLD (its held half) — another block's panel gets no foreign
    /// draft**, and the first block's draft stays held for its own reopen.
    @Test func anotherBlocksPanelGetsNoForeignDraft() async throws {
        try await withEditor(seedBlocks: ["Block A.", "Block B."]) { h in
            let slots = try h.storeSlots()
            let (a, b) = (slots[0].blockID, slots[1].blockID)
            let panel = open(h, a)
            panel.addDraft = Self.half
            panel.leave()

            let other = open(h, b)
            #expect(other.addDraft.isEmpty, "block B's panel shows nothing of A's draft")
            #expect(other.status == nil)
            other.leave()  // leaving B with an empty box never touches A's draft
            #expect(h.session.commentDraftPark.held?.blockID == a, "A's draft is still held")
            #expect(open(h, a).addDraft == Self.half, "…and A's reopen brings it back")
        }
    }

    /// **GUARD — a REFUSED draft left exactly as it was keeps its refusal**:
    /// the leaving does not re-park the same words as a mere draft, so the
    /// reopen still says why the box is not empty (#140's line).
    @Test func aRefusedDraftLeftAsItWasKeepsItsLine() async throws {
        try await withEditor(seedBlocks: ["A block."]) { h in
            let blockID = try h.storeSlots()[0].blockID
            try await h.session.runner.run { [postID = h.postID] ops in try ops.lockPost(postID) }
            let panel = open(h, blockID)
            panel.addDraft = "Refused words."
            await panel.fileAddDraft()
            #expect(panel.status?.isRefusal == true, "premise: the seal refused it")
            panel.leave()
            #expect(h.session.commentDraftPark.held?.refused == true, "still held as the refusal")
            let reopened = open(h, blockID)
            #expect(reopened.addDraft == "Refused words.")
            #expect(reopened.status == .receipt(CommentDraftPark.restoredNote),
                    "the restored line still says why")
        }
    }

    /// **GUARD — a panel that never opened leaves the park as it found it.**
    /// A model whose open never ran (no `.task` — a phantom construction, or a
    /// close before the first turn) has shown nothing and holds nothing
    /// typed: its leaving must not spend a draft held for its block (here a
    /// refused one, held on both sides; the rule's own line is what keeps an
    /// empty box at that leaving from clearing it).
    @Test func aPanelThatNeverOpenedLeavesTheParkAlone() async throws {
        try await withEditor(seedBlocks: ["A block."]) { h in
            let blockID = try h.storeSlots()[0].blockID
            try await h.session.runner.run { [postID = h.postID] ops in try ops.lockPost(postID) }
            let panel = open(h, blockID)
            panel.addDraft = "Refused words."
            await panel.fileAddDraft()
            try #require(h.session.commentDraftPark.held?.text == "Refused words.",
                         "premise: the refusal parked it")
            let unopened = CommentsPanelModel(session: h.session, blockID: blockID)
            unopened.leave()
            #expect(h.session.commentDraftPark.held?.text == "Refused words.",
                    "the held draft survives a leaving that never showed it")
        }
    }
}
