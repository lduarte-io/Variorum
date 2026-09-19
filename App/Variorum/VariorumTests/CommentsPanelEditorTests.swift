//
//  CommentsPanelEditorTests.swift
//  VariorumTests
//
//  13u3 UNIT A2 — the comments panel as a text editor (the gutter memo's
//  §2 D; her item 3). The panel's FACE is a redesign, and a face redesign is
//  not a bug pin — so most of what is below pins the semantics the redesign
//  had to DECIDE (what a commit writes, what an emptied comment means, what
//  ⎋ undoes, which drafts survive a projection arrival, which class each
//  message carries), not a defect. The ONE defect-shaped cell in the unit —
//  the edit road storing untrimmed text where the add road trimmed — is
//  marked red-on-old and its measurement is in the UNIT A2 RECORD.
//
//  The keyboard ROUTING (⌘⏎ / ⎋ reaching the focused area through a live
//  window) is the walk's: it is AppKit key-equivalent dispatch into a
//  focused `TextEditor`, which this harness has no honest way to drive. What
//  is pinned here is what each key MEANS, as a value — `CommentComposition`
//  — so the view's job is reduced to handing the brain what is focused.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The pure brain

@Suite("The comments panel's writing semantics (13u3 UNIT A2)")
struct CommentCompositionTests {
    @Test func theAddDoorFilesTrimmedProseAndIsSilentOnNothing() {
        #expect(CommentComposition.filing("") == .nothing)
        #expect(CommentComposition.filing("   \n\t ") == .nothing)
        #expect(CommentComposition.filing("  take 1 wins  ") == .file("take 1 wins"))
        // A comment is FREE PROSE: its own paragraphs survive, only the ends
        // are trimmed (⏎ inside the draft is a newline — the memo's §2 D).
        #expect(CommentComposition.filing("\n first\n\n second \n")
            == .file("first\n\n second"))
    }

    @Test func aCommitWritesOnlyWhatWouldChange() {
        #expect(CommentComposition.commit(draft: "same", stored: "same") == .unchanged)
        // The trim rule decides "same", so trailing whitespace is not an edit.
        #expect(CommentComposition.commit(draft: "same\n  ", stored: "same") == .unchanged)
        #expect(CommentComposition.commit(draft: " new ", stored: "old") == .save("new"))
        #expect(CommentComposition.commit(draft: "", stored: "old") == .emptied)
        #expect(CommentComposition.commit(draft: "  \n ", stored: "old") == .emptied)
    }

    @Test func dirtyMeansCommittingWouldDoSomething() {
        #expect(!CommentComposition.isDirty(draft: "same ", stored: "same"))
        #expect(CommentComposition.isDirty(draft: "changed", stored: "same"))
        // An emptied comment IS dirty — there is something to put back.
        #expect(CommentComposition.isDirty(draft: "", stored: "same"))
    }

    @Test func escapeIsALadderMostLocalFirst() {
        #expect(CommentComposition.escape(writing: .addDraft("half a thought"))
            == .clearDraft)
        #expect(CommentComposition.escape(writing: .addDraft("")) == .close)
        #expect(CommentComposition.escape(
            writing: .comment(id: "c1", draft: "edited", stored: "kept")) == .revert("c1"))
        #expect(CommentComposition.escape(
            writing: .comment(id: "c1", draft: "kept ", stored: "kept")) == .close)
        #expect(CommentComposition.escape(writing: .nothing) == .close)
    }

    @Test func aProjectionArrivalKeepsHerProseAndDropsWhatIsSettled() {
        let drafts = [
            "kept": "still writing this",
            "settled": "landed",
            "gone": "typed into a comment that has since been deleted",
        ]
        let surviving = CommentComposition.survivingDrafts(
            drafts, stored: ["kept": "old text", "settled": "landed"])
        #expect(surviving == ["kept": "still writing this"])
    }
}

// MARK: - The model, through the real operations

@MainActor
@Suite("The comments panel model as an editor (13u3 UNIT A2)", .serialized)
struct CommentsPanelModelEditorTests {
    /// Re-reads the store into the model exactly as the observation would.
    private func adopt(_ panel: CommentsPanelModel, _ h: EditorHarness) async throws {
        let blockID = panel.blockID
        let snapshot = try await h.database.read { db in
            CommentsPanelModel.Snapshot(
                live: try Queries.blockComments(db, blockID: blockID),
                deleted: try Queries.deletedBlockComments(db, blockID: blockID))
        }
        panel.adopt(snapshot)
    }

    @Test func theAddAreaFilesWithTheOneTrimRuleAndClearsItself() async throws {
        try await withEditor(seedBlocks: ["First block."]) { h in
            let blockID = try h.storeSlots()[0].blockID
            let panel = CommentsPanelModel(session: h.session, blockID: blockID)

            // ⌘⏎ on an empty draft is SILENT — nothing filed, nothing said.
            await panel.fileAddDraft()
            try await adopt(panel, h)
            #expect(panel.comments.isEmpty)
            #expect(panel.status == nil)

            panel.addDraft = "  the polite ending belongs in ch. III \n"
            await panel.fileAddDraft()
            try await adopt(panel, h)
            #expect(panel.comments.map(\.text) == ["the polite ending belongs in ch. III"])
            #expect(panel.addDraft == "", "a filed draft leaves the add area empty")
        }
    }

    @Test func aCommentEditsInPlaceAndStoresTheTrimmedText() async throws {
        // **RED-ON-OLD (the unit's one defect-shaped cell).** The shipped
        // panel trimmed on the ADD road and not on the EDIT road, so the same
        // keystrokes stored different text depending on which box they were
        // typed in. Behavioural revert: make `CommentComposition.trimmed`
        // return its argument and this cell fails on `"  quieter ending \n"`.
        try await withEditor(seedBlocks: ["First block."]) { h in
            let blockID = try h.storeSlots()[0].blockID
            let panel = CommentsPanelModel(session: h.session, blockID: blockID)
            await panel.add("the ending is too loud")
            try await adopt(panel, h)
            let id = panel.comments[0].id

            #expect(!panel.isDirty(id), "a freshly adopted comment is clean")
            panel.setDraft("  quieter ending \n", for: id)
            #expect(panel.isDirty(id))
            await panel.commitEdit(id)
            try await adopt(panel, h)
            #expect(panel.comments.map(\.text) == ["quieter ending"])
            #expect(!panel.isDirty(id), "the saved draft stops claiming unsaved changes")
            #expect(panel.status == nil, "a saved edit says nothing — the mark going out IS the receipt")
        }
    }

    @Test func aCommitThatWouldWriteNothingWritesNothing() async throws {
        try await withEditor(seedBlocks: ["First block."]) { h in
            let blockID = try h.storeSlots()[0].blockID
            let panel = CommentsPanelModel(session: h.session, blockID: blockID)
            await panel.add("unchanged")
            try await adopt(panel, h)
            let id = panel.comments[0].id
            let stamp = panel.comments[0].updatedAt

            panel.setDraft("unchanged   ", for: id)
            await panel.commitEdit(id)
            try await adopt(panel, h)
            #expect(panel.comments[0].updatedAt == stamp,
                    "no write — the row's stamp is untouched")
            #expect(panel.status == nil)
        }
    }

    @Test func anEmptiedCommentRefusesAndGoesBackToWhatIsStored() async throws {
        try await withEditor(seedBlocks: ["First block."]) { h in
            let blockID = try h.storeSlots()[0].blockID
            let panel = CommentsPanelModel(session: h.session, blockID: blockID)
            await panel.add("keep me")
            try await adopt(panel, h)
            let id = panel.comments[0].id

            panel.setDraft("   ", for: id)
            await panel.commitEdit(id)
            try await adopt(panel, h)
            #expect(panel.comments.map(\.text) == ["keep me"], "nothing was written")
            #expect(panel.draft(for: id) == "keep me", "the draft went back to the store")
            #expect(panel.status?.isRefusal == true, "it refuses, in the refusal class")
            #expect(panel.statusMessage?.contains("Delete") == true,
                    "the refusal names the door that actually removes it")
        }
    }

    @Test func escapeRevertsAnEditAndClearsTheAddDraft() async throws {
        try await withEditor(seedBlocks: ["First block."]) { h in
            let blockID = try h.storeSlots()[0].blockID
            let panel = CommentsPanelModel(session: h.session, blockID: blockID)
            await panel.add("as written")
            try await adopt(panel, h)
            let id = panel.comments[0].id

            panel.setDraft("second thoughts", for: id)
            panel.revertEdit(id)
            #expect(panel.draft(for: id) == "as written")
            #expect(!panel.isDirty(id))

            panel.addDraft = "half a thought"
            panel.clearAddDraft()
            #expect(panel.addDraft == "")
        }
    }

    @Test func deleteAndRestoreSpeakReceiptsThatNameTheRoad() async throws {
        try await withEditor(seedBlocks: ["First block."]) { h in
            let blockID = try h.storeSlots()[0].blockID
            let panel = CommentsPanelModel(session: h.session, blockID: blockID)
            await panel.add("a note to delete")
            try await adopt(panel, h)
            let id = panel.comments[0].id

            await panel.delete(id)
            try await adopt(panel, h)
            #expect(panel.comments.isEmpty)
            #expect(panel.deleted.map(\.text) == ["a note to delete"])
            #expect(panel.status?.isRefusal == false, "a delete that LANDED is a receipt")
            #expect(panel.statusMessage?.contains("deleted") == true)

            await panel.restore(id)
            try await adopt(panel, h)
            #expect(panel.comments.map(\.text) == ["a note to delete"])
            #expect(panel.status?.isRefusal == false)
        }
    }

    @Test func aDraftSurvivesAProjectionArrivalAndASavedOneStopsBeingDirty() async throws {
        try await withEditor(seedBlocks: ["First block."]) { h in
            let blockID = try h.storeSlots()[0].blockID
            let panel = CommentsPanelModel(session: h.session, blockID: blockID)
            await panel.add("one")
            await panel.add("two")
            try await adopt(panel, h)
            let first = panel.comments[0].id
            let second = panel.comments[1].id

            panel.setDraft("one, rewritten", for: first)
            panel.setDraft("two   ", for: second)
            // An arrival from anywhere — her own save echoing, another
            // surface, a sync apply.
            try await adopt(panel, h)
            #expect(panel.draft(for: first) == "one, rewritten", "her prose is never dropped")
            #expect(panel.isDirty(first))
            #expect(!panel.isDirty(second), "a draft that would write nothing is settled")

            // The comment a draft belongs to goes away ⇒ the draft goes with it.
            await panel.delete(first)
            try await adopt(panel, h)
            #expect(panel.drafts[first] == nil)
        }
    }

    @Test func theSealRefusesEveryWriteAndKeepsWhatSheTyped() async throws {
        try await withEditor(seedBlocks: ["First block."]) { h in
            let blockID = try h.storeSlots()[0].blockID
            let panel = CommentsPanelModel(session: h.session, blockID: blockID)
            await panel.add("written before the seal")
            try await adopt(panel, h)
            let id = panel.comments[0].id
            try await h.session.runner.run { [postID = h.postID] ops in
                try ops.lockPost(postID)
            }

            panel.setDraft("edited under the seal", for: id)
            await panel.commitEdit(id)
            try await adopt(panel, h)
            #expect(panel.comments.map(\.text) == ["written before the seal"])
            #expect(panel.status?.isRefusal == true)
            #expect(panel.statusMessage?.contains("sealed") == true)
            #expect(panel.draft(for: id) == "edited under the seal",
                    "a refusal never throws away what she typed")

            panel.addDraft = "and a new one"
            await panel.fileAddDraft()
            try await adopt(panel, h)
            #expect(panel.comments.count == 1)
            #expect(panel.status?.isRefusal == true)
            #expect(panel.addDraft == "and a new one", "the refused draft stays in the box")
        }
    }
}
