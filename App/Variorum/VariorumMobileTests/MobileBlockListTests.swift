//
//  MobileBlockListTests.swift
//  VariorumMobileTests
//
//  Parity C4b item 5 — the in-note block list (her mid-chain ruling 11)
//  and block names' phone face. The rows ride `Queries.blockTOC` and the
//  ONE `tocHandle` brain (AppSpec §12's letter: the name where set, else
//  the first sentence DERIVED AT READ TIME, never stored); the tap rides
//  the VM's `jumpToBlock`.
//

import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("Mobile block list — the in-note TOC (parity C4b)")
struct MobileBlockListTests {
    /// The rows: reading order, the NAME where set, else the first
    /// sentence — and the derivation is read-time truth, never a stored
    /// copy: rename the block or edit its text and the handle follows
    /// on the next read with no row of its own anywhere.
    @Test func rowsCarryNamesElseFirstSentencesDerivedAtReadTime() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await session.runner.run { ops -> (post: String, a: String, b: String, b1: String, c: String) in
                let post = try ops.createPost(title: "toc", profile: .blog)
                let a = try ops.newBlock(
                    in: post.id, text: "The opening paragraph stands here.", at: .end)
                try ops.setBlockName(a.block.id, name: "opening")
                let b = try ops.newBlock(
                    in: post.id, text: "First sentence here. Second follows.", at: .end)
                let c = try ops.newBlock(in: post.id, text: "The fanned one.", at: .end)
                _ = try ops.branchVariant(c.block.id, from: c.variant.id)
                return (post.id, a.block.id, b.block.id, b.variant.id, c.block.id)
            }
            let model = MobileBlockListModel(session: session, postID: seed.post)
            await model.refresh()

            #expect(model.rows.map(\.blockID) == [seed.a, seed.b, seed.c])
            // The name where set…
            #expect(MobileBlockListModel.handle(model.rows[0]) == "opening")
            // …else the FIRST SENTENCE, derived (the one core brain).
            #expect(MobileBlockListModel.handle(model.rows[1]) == "First sentence here.")
            // The fan marker's truth rides the row.
            #expect(model.rows.map(\.hasFan) == [false, false, true])

            // Read-time, not stored: a rename and a text edit both land
            // in the NEXT read with no denormalized handle anywhere.
            try await session.runner.run { [a = seed.a, b1 = seed.b1] ops in
                try ops.setBlockName(a, name: nil)
                try ops.autosave(b1, text: "A rewritten start. And more.", charDelta: 5)
            }
            await model.refresh()
            #expect(MobileBlockListModel.handle(model.rows[0])
                == "The opening paragraph stands here.")
            #expect(MobileBlockListModel.handle(model.rows[1]) == "A rewritten start.")
        }
    }

    /// The tap's contract: the caret lands at the block's start and the
    /// block's first line arrives in the viewport (the hybrid-jump
    /// geometry — `.ensuresLayout` on exactly the target fragment). A
    /// block that has left the note refuses in plain words.
    @Test func aTapJumpsTheEditorToTheBlockAndADeadBlockRefuses() async throws {
        try await withEditorWorld { session, db in
            let blocks = (1...30).map { n in
                "Paragraph \(n) has enough words to take a visible line or two on the page."
            }
            let postID = try await makePost(session, blocks: blocks)
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            surface.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
            surface.layoutIfNeeded()
            let view = surface.textView

            let list = MobileBlockListModel(session: session, postID: postID)
            await list.refresh()
            #expect(list.rows.count == 30)
            let target = list.rows[19]

            model.jumpToBlock(target.blockID)

            let range = try #require(model.rangeOfBlock(target.blockID))
            #expect(view.selectedRange == NSRange(location: range.location, length: 0))
            // The block's first line sits inside the visible band.
            // The door's own contract: the block's first line lands a
            // breath (24 pt) under the viewport's top edge — asserted
            // as the offset equality, which holds windowless too (the
            // headless harness gives the view no HEIGHT, so a
            // visible-band containment would read a zero viewport; the
            // pixels ride the chain-end look, the A1-masthead class).
            let geometry = try #require(view.firstLineGeometry(atOffset: range.location))
            let landingY = max(0, geometry.fragmentMinY + view.textContainerInset.top - 24)
            #expect(view.contentOffset.y > 0, "the jump scrolled at all")
            #expect(abs(view.contentOffset.y - landingY) <= 1,
                    "the block's first line sits a breath under the viewport top")

            // A dead block refuses in plain words (no platform named).
            let doomed = list.rows[0].blockID
            try await session.runner.run { ops in try ops.deleteBlock(doomed) }
            await model.refreshTakesFromStore()
            model.jumpToBlock(doomed)
            #expect(model.statusMessage == "That block is no longer in this note.")
            #expect(model.statusMessage?.contains("Mac") == false)
        }
    }

    /// The empty state speaks the structural doors' own standing
    /// sentence (one vocabulary for "no blocks yet"), and the chip's
    /// word is the bare voiced door (countless — recorded judgment: the
    /// list is the census).
    @Test func theEmptyStateAndChipWordAreThePinnedVocabulary() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await session.runner.run { ops in
                try ops.createPost(title: "bare", profile: .blog).id
            }
            let model = MobileBlockListModel(session: session, postID: postID)
            await model.refresh()
            #expect(model.rows.isEmpty)
            #expect(MobileBlockListModel.emptyNote
                == "No blocks yet — type on the page and each finished paragraph becomes one.")
            #expect(MobileBlockListModel.chipWord == "blocks")
            #expect(!MobileBlockListModel.emptyNote.contains("Mac"))
        }
    }
}
