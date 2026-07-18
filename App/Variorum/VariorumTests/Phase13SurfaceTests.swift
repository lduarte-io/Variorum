//
//  Phase13SurfaceTests.swift
//  VariorumTests
//
//  Phase 13, Stage C1 — the writing surface's behavioral seams: the voice
//  typography (one global source every TK2 surface write shares), the
//  sacred-margin math (R9), the decoration geometry (seams R6, the
//  white-gap rule R17, the indicator R14/R22, the drop boundary R19), the
//  comments panel model (CRUD + the resurrectable deleted list), and the
//  handle drop's reorder mapping.
//

import AppKit
import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

// MARK: - Typography (the voice's text-surface half)

@Suite("Editor typography (Phase 13 C1)")
struct EditorTypographyTests {
    @Test func voicesResolveTheirFonts() {
        let terminal = EditorTypography.resolve(voice: .terminal, inlineComments: false)
        #expect(terminal.font.fontDescriptor.symbolicTraits.contains(.monoSpace),
                "the terminal voice writes in mono (R1)")
        #expect(terminal.font.pointSize == 14)

        let study = EditorTypography.resolve(voice: .study, inlineComments: false)
        #expect(!study.font.fontDescriptor.symbolicTraits.contains(.monoSpace))
        #expect(study.font.pointSize == 16)
        // Iowan Old Style ships with macOS (R49) — the fallback chain is a
        // never-reached safety net on a stock install.
        #expect(study.font.familyName == "Iowan Old Style")
    }

    @Test func inlineCommentsWidenTheGapUniformly() {
        // The R7 setting's mechanism (PROVISIONAL, QUESTIONS): inline
        // comments = a uniformly airier layout — EVERY paragraph gains the
        // strip's room, so §12's boundaries-invisible-at-rest holds.
        for voice in ThemeVoice.allCases {
            let plain = EditorTypography.resolve(voice: voice, inlineComments: false)
            let inline = EditorTypography.resolve(voice: voice, inlineComments: true)
            #expect(inline.paragraphSpacing - plain.paragraphSpacing
                == EditorTypography.inlineCommentSpacing)
        }
    }

    @Test func theBaseAttributesFollowTheCurrentResolution() {
        let saved = EditorTypography.current
        defer { EditorTypography.current = saved }

        EditorTypography.current = EditorTypography.resolve(voice: .study, inlineComments: false)
        #expect(EditorDocument.baseFont.familyName == "Iowan Old Style")
        let (text, _) = EditorDocument.materialize([
            Queries.RenderedBlock(
                blockID: "b1", placementID: "p1", position: "a",
                variantID: "v1", text: "Prose.", activeVariantCount: 1,
                variantLocked: false),
        ])
        let font = text.attribute(.font, at: 0, effectiveRange: nil) as? NSFont
        #expect(font?.familyName == "Iowan Old Style",
                "materialization rides the one global typography")

        EditorTypography.current = EditorTypography.resolve(voice: .terminal, inlineComments: false)
        #expect(EditorDocument.baseFont.fontDescriptor.symbolicTraits.contains(.monoSpace))
    }

    @Test func guttersCenterTheColumnAndNeverPinchBelowTheFloor() {
        // R9: text never runs near the edge. Wide window → centered
        // column; narrow window → the floor gutter holds.
        #expect(EditorTypography.gutterInset(viewWidth: 1280, maxColumn: 680) == 300)
        #expect(EditorTypography.gutterInset(viewWidth: 736, maxColumn: 680)
                == EditorTypography.minGutter)
        #expect(EditorTypography.gutterInset(viewWidth: 400, maxColumn: 680)
                == EditorTypography.minGutter)
    }
}

// MARK: - Decoration geometry (pure)

@Suite("BlockDecor geometry (Phase 13 C1)")
struct BlockDecorGeometryTests {
    private func frame(_ i: Int, y: CGFloat, height: CGFloat) -> BlockDecor.Frame {
        BlockDecor.Frame(
            entryIndex: i, blockID: "b\(i)",
            frame: CGRect(x: 0, y: y, width: 400, height: height))
    }

    @Test func seamsSitMidGapBetweenConsecutiveBlocksOnly() {
        let frames = [
            frame(0, y: 0, height: 40),
            frame(1, y: 48, height: 40),
            frame(3, y: 200, height: 40),  // entry 2 pruned off-viewport
        ]
        let seams = BlockDecor.seamYs(frames)
        #expect(seams == [44], "no seam across a pruned neighbor")
    }

    @Test func theWhiteGapRuleCapsCalloutPadding() {
        // R17 (BINDING): a callout card never swallows the base-background
        // breathing room toward its neighbors.
        #expect(BlockDecor.verticalPad(gap: nil) == 5, "a document edge allows the ideal pad")
        #expect(BlockDecor.verticalPad(gap: 30) == 5, "a roomy gap allows the ideal pad")
        #expect(BlockDecor.verticalPad(gap: 10) == 2, "a tight gap caps the pad")
        #expect(BlockDecor.verticalPad(gap: 4) == 0, "no pad when the gap is at the floor")

        let block = CGRect(x: 0, y: 100, width: 400, height: 40)
        let rect = BlockDecor.calloutRect(
            block: block, gapAbove: 8, gapBelow: nil, textLeft: 28, textRight: 428)
        #expect(rect.minY == 99, "gapAbove 8 → pad (8-6)/2 = 1")
        #expect(rect.maxY == 145, "no neighbor below → the ideal 5")
        #expect(rect.minX == 16, "horizontal air into the gutter")
        #expect(rect.maxX == 440)
    }

    @Test func adjacentCalloutsAlwaysKeepBreathingRoom() {
        // The diagnosed 9d defect, never repeated: two adjacent callouts
        // must leave ≥ the white-gap floor of base background between
        // their cards.
        let gap: CGFloat = 9
        let a = CGRect(x: 0, y: 0, width: 400, height: 40)
        let b = CGRect(x: 0, y: a.maxY + gap, width: 400, height: 40)
        let cardA = BlockDecor.calloutRect(
            block: a, gapAbove: nil, gapBelow: gap, textLeft: 28, textRight: 428)
        let cardB = BlockDecor.calloutRect(
            block: b, gapAbove: gap, gapBelow: nil, textLeft: 28, textRight: 428)
        #expect(cardB.minY - cardA.maxY >= 6 - 0.001)
    }

    @Test func theIndicatorRectWearsTheOutlineOffset() {
        let rect = BlockDecor.indicatorRect(
            block: CGRect(x: 0, y: 50, width: 400, height: 30),
            textLeft: 28, textRight: 428)
        #expect(rect == CGRect(x: 20, y: 47, width: 416, height: 36))
    }

    @Test func dropBoundariesMapDragYsToEntryIndexes() {
        let frames = [
            frame(0, y: 0, height: 40),
            frame(1, y: 48, height: 40),
            frame(2, y: 96, height: 40),
        ]
        // Above the first block → land before entry 0.
        #expect(BlockDecor.dropBoundary(at: -10, frames: frames, entryCount: 3)?.index == 0)
        // Between blocks 0 and 1 (past 0's midpoint) → before entry 1.
        #expect(BlockDecor.dropBoundary(at: 44, frames: frames, entryCount: 3)?.index == 1)
        // Past the last midpoint → the end boundary.
        let end = BlockDecor.dropBoundary(at: 500, frames: frames, entryCount: 3)
        #expect(end?.index == 3)
        #expect(end?.barY == frames[2].frame.maxY + 2)
        // No frames → no boundary (nothing visible to target).
        #expect(BlockDecor.dropBoundary(at: 10, frames: [], entryCount: 3) == nil)
    }

    @Test func narrowGuttersDegradeCardsToBadges() {
        #expect(BlockDecor.gutterFitsCards(viewWidth: 1200, textRight: 900))
        #expect(!BlockDecor.gutterFitsCards(viewWidth: 736, textRight: 708))
    }

    @MainActor
    @Test func aQuietCommentCardIsClickThrough() {
        // Round 3, MINOR (red-on-old by behavioral revert — without the
        // hitTest override the card returned itself): the read tier's
        // quiet cards (no comments door) must never swallow clicks meant
        // for the text beneath; with a door, the card hits normally.
        let card = CommentCardView(frame: NSRect(x: 0, y: 0, width: 120, height: 20))
        card.present(text: "note", tint: .yellow, ink: .black,
                     style: .marginCard(rule: .brown))
        let inside = NSPoint(x: 60, y: 10)
        #expect(card.hitTest(inside) == nil,
                "no door (onClick nil) ⇒ click-through")
        card.onClick = {}
        #expect(card.hitTest(inside) != nil,
                "with a door the card is clickable")
    }
}

// MARK: - The comments panel + the handle drop (live pipeline)

@MainActor
@Suite("Comments panel & block reorder (Phase 13 C1)", .serialized)
struct CommentsAndReorderTests {
    @Test func thePanelModelDrivesCrudAndTheResurrectableDeletedList() async throws {
        try await withEditor(seedBlocks: ["First block.", "Second block."]) { h in
            let blockID = try h.storeSlots()[0].blockID
            let panel = CommentsPanelModel(session: h.session, blockID: blockID)

            await panel.add("take 1 preferred")
            await panel.add("the polite ending belongs in ch. III")
            var snapshot = try await h.database.read { [blockID] db in
                CommentsPanelModel.Snapshot(
                    live: try Queries.blockComments(db, blockID: blockID),
                    deleted: try Queries.deletedBlockComments(db, blockID: blockID))
            }
            panel.adopt(snapshot)
            #expect(panel.comments.map(\.text)
                == ["take 1 preferred", "the polite ending belongs in ch. III"])
            #expect(panel.deleted.isEmpty)

            // Edit, then delete — the deleted list is the recovery surface.
            await panel.edit(panel.comments[0].id, text: "take 1 wins")
            await panel.delete(panel.comments[1].id)
            snapshot = try await h.database.read { [blockID] db in
                CommentsPanelModel.Snapshot(
                    live: try Queries.blockComments(db, blockID: blockID),
                    deleted: try Queries.deletedBlockComments(db, blockID: blockID))
            }
            panel.adopt(snapshot)
            #expect(panel.comments.map(\.text) == ["take 1 wins"])
            #expect(panel.deleted.map(\.text)
                == ["the polite ending belongs in ch. III"], "deleted is visible — never skimpy")

            // Resurrect — the accident is one click away.
            await panel.restore(panel.deleted[0].id)
            snapshot = try await h.database.read { [blockID] db in
                CommentsPanelModel.Snapshot(
                    live: try Queries.blockComments(db, blockID: blockID),
                    deleted: try Queries.deletedBlockComments(db, blockID: blockID))
            }
            panel.adopt(snapshot)
            #expect(panel.comments.count == 2)
            #expect(panel.deleted.isEmpty)

            // A whitespace add refuses and SPEAKS.
            await panel.add("   \n ")
            #expect(panel.statusMessage != nil)
        }
    }

    @Test func theHandleDropLandsAsOneReorder() async throws {
        try await withEditor(seedBlocks: ["Alpha.", "Beta.", "Gamma."]) { h in
            let before = try h.storeSlots().map(\.blockID)

            // Drop entry 0 before entry 2 (between Beta and Gamma).
            await h.model.moveBlock(fromEntry: 0, toBoundary: 2)
            await h.settle()
            try h.reload()
            let after = try h.storeSlots().map(\.blockID)
            #expect(after == [before[1], before[0], before[2]])

            // Drop the (now) middle block at the END boundary.
            await h.model.moveBlock(fromEntry: 1, toBoundary: 3)
            await h.settle()
            try h.reload()
            let end = try h.storeSlots().map(\.blockID)
            #expect(end == [before[1], before[2], before[0]])

            // No-op boundaries (the block's own edges) write nothing.
            let stamp = end
            await h.model.moveBlock(fromEntry: 1, toBoundary: 1)
            await h.model.moveBlock(fromEntry: 1, toBoundary: 2)
            await h.settle()
            #expect(try h.storeSlots().map(\.blockID) == stamp)
        }
    }

    @Test func theCalloutDoorSetsAndClearsTheCaretBlocksFrame() async throws {
        try await withEditor(seedBlocks: ["Framed prose.", "Plain prose."]) { h in
            h.textView.setSelectedRange(NSRange(location: 2, length: 0))
            h.model.updateCaretContext()
            await h.model.setCaretCallout(color: "sand")
            await h.settle()
            var frames = try await h.database.read { [postID = h.postID] db in
                try Queries.blockPresentations(db, containerID: postID)
            }
            let blockID = try h.storeSlots()[0].blockID
            #expect(frames[blockID]?.color == "sand")

            // The emoji door keeps the color.
            await h.model.setCaretCalloutEmoji("💡")
            await h.settle()
            frames = try await h.database.read { [postID = h.postID] db in
                try Queries.blockPresentations(db, containerID: postID)
            }
            #expect(frames[blockID]?.color == "sand")
            #expect(frames[blockID]?.emoji == "💡")

            // Remove restores plain prose.
            await h.model.setCaretCallout(color: nil)
            await h.settle()
            frames = try await h.database.read { [postID = h.postID] db in
                try Queries.blockPresentations(db, containerID: postID)
            }
            #expect(frames.isEmpty)
        }
    }
}
