//
//  CommentPanelDoorsTests.swift
//  VariorumTests
//
//  VX-183 (the VX-282 run, U5 — VX-179 U1's observation O-2): the comments
//  panel's doors — Add, Save, Revert, Delete, Restore, Delete forever… — were
//  undeclared in the capability registry since 13u3 A2. P-1: every
//  user-facing act is declared exactly once, surfaces render their doors FROM
//  the registry, gating is data; the grow-as-touched rule brings them in as
//  the panel's own work (VX-257) touches it.
//
//  DEBT, NOT A BUG: nothing behaved wrongly, so no red-on-old pin is owed (the
//  run record says so). What these pin is that the declaration is whole and
//  that nothing moved: every door still renders — the same words, the same
//  order, the same emphasis, on the same rows — and every door still ACTS,
//  through the one dispatch, against the store. The declared ⇔ rendered half
//  is the registry walk's (`CapabilityRegistryTests
//  .theSurfacesRenderExactlyTheDeclaredSurfaceActs` — its new line).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-183 — the comments panel's doors, declared in the registry", .serialized)
struct CommentPanelDoorsTests {
    /// The panel's six doors, in the words it shipped with — what a reader
    /// sees on the rows today. A verb changed in the registry changes the
    /// panel, so it must change here deliberately.
    private static let shippedWords: [CapabilityID: String] = [
        .addComment: "Add",
        .saveComment: "Save",
        .revertComment: "Revert",
        .deleteComment: "Delete",
        .restoreComment: "Restore",
        .deleteCommentForever: "Delete forever\u{2026}",
    ]

    /// Each declaration is a `.surface` act on the block, reachable from Takes
    /// natively (R118), keyless, in the panel's own words — and the panel's
    /// copy reads those words FROM the registry (one source).
    @Test func eachDoorIsDeclaredOnceAsASurfaceActInThePanelsOwnWords() {
        for (id, word) in Self.shippedWords {
            let capability = CapabilityRegistry.capability(id)
            #expect(capability.verb == word, "\(id) wears the panel's word")
            #expect(capability.doors == [.surface], "\(id) is rendered inline only")
            #expect(capability.scope == .block, "\(id) acts on a block's comment")
            #expect(capability.takesAccess == .native, "\(id) — Takes reaches it natively")
            #expect(capability.shortcutLabel == nil, "\(id) — ⌘⏎/⎋ are the panel's monitor's, not menu keys")
            #expect(!capability.unavailableNote.isEmpty)
        }
        #expect(CommentsPanelCopy.add == "Add")
        #expect(CommentsPanelCopy.save == "Save")
        #expect(CommentsPanelCopy.revert == "Revert")
        #expect(CommentsPanelCopy.delete == "Delete")
        #expect(CommentsPanelCopy.restore == "Restore")
        #expect(CommentsPanelCopy.deleteForeverVerb == "Delete forever\u{2026}")
    }

    /// **The rows' gating, as data** — exactly what the view's if-statements
    /// rendered before (`stampLine`'s `if dirty`, the fold row's pair, the
    /// composer's one door): the same doors, the same order, the same
    /// emphasis.
    @Test func theRowsRenderTheSameDoorsInTheSameOrder() {
        #expect(CommentsPanelDoors.composer == [.addComment])
        #expect(CommentsPanelDoors.liveRow(dirty: false) == [.deleteComment],
                "a clean comment: Delete alone")
        #expect(CommentsPanelDoors.liveRow(dirty: true) == [.saveComment, .revertComment, .deleteComment],
                "an edited comment: Save, Revert, then Delete")
        #expect(CommentsPanelDoors.deletedRow == [.restoreComment, .deleteCommentForever],
                "a deleted comment: Restore, then Delete forever…")
        #expect(Set(CommentsPanel.surfaceCapabilities) == Set(Self.shippedWords.keys),
                "the panel declares exactly its six doors")
        #expect(CommentsPanel.surfaceCapabilities.count == Self.shippedWords.count, "each once")
        for primary in [CapabilityID.addComment, .saveComment, .restoreComment] {
            #expect(CommentsPanelDoors.emphasis(primary) == .primary, "\(primary) is the door you probably want")
        }
        for quiet in [CapabilityID.revertComment, .deleteComment, .deleteCommentForever] {
            #expect(CommentsPanelDoors.emphasis(quiet) == .quiet, "\(quiet) is present, never calling")
        }
    }

    /// The comment's purge door lives where things are already deleted (the
    /// evolved rule — `TrashSurfaceTests`' sibling): surface-only, and the
    /// panel's fold its only renderer.
    @Test func deleteForeverIsATrashSurfaceDoorOnly() {
        let capability = CapabilityRegistry.capability(.deleteCommentForever)
        #expect(capability.doors == [.surface], "a purge act never grows a menu, bar or palette door")
        #expect(capability.unavailableNote.contains("Deleted"), "its note names the fold")
        #expect(CommentsPanelDoors.deletedRow.contains(.deleteCommentForever))
        #expect(!CommentsPanelDoors.liveRow(dirty: true).contains(.deleteCommentForever),
                "never on a live comment — never in the writing flow")
    }

    private func snapshot(_ panel: CommentsPanelModel, _ h: EditorHarness) async throws {
        let blockID = panel.blockID
        let value = try await h.database.read { db in
            CommentsPanelModel.Snapshot(
                live: try Queries.blockComments(db, blockID: blockID),
                deleted: try Queries.deletedBlockComments(db, blockID: blockID))
        }
        panel.adopt(value)
    }

    private func live(_ h: EditorHarness, _ blockID: String) async throws -> [String] {
        try await h.database.read { db in try Queries.blockComments(db, blockID: blockID).map(\.text) }
    }

    /// **Every door still ACTS** — each declared id, through the panel's one
    /// dispatch (the dispatch every rendered button calls), against the store.
    @Test func everyDoorActsThroughTheOneDispatch() async throws {
        try await withEditor(seedBlocks: ["A block."]) { h in
            let blockID = try h.storeSlots()[0].blockID
            let panel = CommentsPanelModel(session: h.session, blockID: blockID)

            // Add — files the composer's words.
            panel.addDraft = "First note."
            await panel.act(.addComment)
            #expect(try await live(h, blockID) == ["First note."], "Add filed it")
            try await snapshot(panel, h)
            let id = try #require(panel.comments.first?.id)

            // Revert — puts an edited comment back.
            panel.setDraft("First note, edited.", for: id)
            #expect(panel.isDirty(id))
            await panel.act(.revertComment, on: id)
            #expect(!panel.isDirty(id) && panel.draft(for: id) == "First note.", "Revert put it back")

            // Save — writes the edit.
            panel.setDraft("First note, edited.", for: id)
            await panel.act(.saveComment, on: id)
            #expect(try await live(h, blockID) == ["First note, edited."], "Save wrote it")

            // Delete — the comment leaves for the fold.
            await panel.act(.deleteComment, on: id)
            #expect(try await live(h, blockID).isEmpty, "Delete took it off the live list")
            try await snapshot(panel, h)
            #expect(panel.deleted.map(\.id) == [id], "…into the fold")

            // Restore — back on the live list.
            await panel.act(.restoreComment, on: id)
            #expect(try await live(h, blockID) == ["First note, edited."], "Restore brought it back")

            // Delete forever — ASKS (the confirm is the act).
            await panel.act(.deleteComment, on: id)
            try await snapshot(panel, h)
            await panel.act(.deleteCommentForever, on: id)
            #expect(panel.pendingDeleteForever == id, "Delete forever asks before it acts")
            await panel.deleteForever(id)
            try await snapshot(panel, h)
            #expect(panel.deleted.isEmpty, "confirmed: off the fold for good")
        }
    }
}
