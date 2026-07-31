//
//  DivergeAndExtractSeamTests.swift
//  VariorumCoreTests
//
//  Phase 13f, batch 5's continuation — two rulings, both at the operations
//  and Domain layers where they belong:
//
//  **W23 — DIVERGE FOR THIS BOOK** (her round-10 item 4, architect-ruled
//  shape 1): one transaction, the copy taking the original's EXACT slot in
//  this book, the original leaving this book alone, and ONE undo entry whose
//  inverse AND redo are exact-row on do-time ids. The whole reason this is
//  an operation rather than an app-layer compound is the undo entry — so the
//  undo↔redo round trip is the suite's centre of gravity.
//
//  **W24 — EXTRACT JOINS A11** (her round-12 ruling): the ONE seam-trim
//  brain now serves extract too, so a blank line at the boundary survives on
//  the piece BEFORE the seam instead of being silently dropped.
//

import Foundation
import GRDB
import Testing
@testable import VariorumCore

// MARK: - W23: the compound

@Suite("Diverge for this book (13f W23)")
struct DivergeForBookTests {
    /// A book, a post in it (with a fan, so the copy has something to carry),
    /// and a chapter the membership points at.
    private func world(
        _ ops: Operations, chaptered: Bool = true
    ) throws -> (book: String, post: String, section: String?, other: String) {
        let book = try ops.createReading(name: "Orbit", kind: .curated)
        let section = chaptered
            ? try ops.createSection(in: book.id, name: "One").id : nil
        let first = try ops.createPost(title: "first")
        _ = try ops.newBlock(in: first.id, text: "Opening block.")
        let post = try ops.createPost(title: "shared")
        let block = try ops.newBlock(in: post.id, text: "Alpha beta.")
        _ = try ops.branchVariant(block.block.id, from: block.variant.id)
        try ops.addPostToReading(first.id, to: book.id)
        try ops.addPostToReading(post.id, to: book.id)
        if let section { try ops.assignPostToSection(post.id, in: book.id, section: section) }
        // A second book, so the ORIGINAL provably lives on somewhere.
        let other = try ops.createReading(name: "Field Notes", kind: .curated)
        try ops.addPostToReading(post.id, to: other.id)
        return (book.id, post.id, section, other.id)
    }

    private func membership(
        _ db: AppDatabase, book: String, post: String
    ) throws -> ReadingPost? {
        try db.read { db in
            try ReadingPost
                .filter(Column("reading_id") == book && Column("post_id") == post
                    && Column("deleted_at") == nil)
                .fetchOne(db)
        }
    }

    /// **THE EXACT SLOT** — her ruled letter: the copy takes the original's
    /// position AND its chapter; the original leaves THIS book only.
    @Test func theCopyTakesTheOriginalsExactSlotAndTheOriginalKeepsItsOtherBooks() throws {
        try withOperations { ops, db in
            let w = try world(ops)
            let before = try #require(try membership(db, book: w.book, post: w.post))

            let result = try ops.divergePostForReading(w.post, in: w.book)

            let copyRow = try #require(try membership(db, book: w.book, post: result.copy.post.id))
            #expect(copyRow.position == before.position, "the same slot, not the end")
            #expect(copyRow.sectionId == before.sectionId, "…and the same chapter")
            #expect(copyRow.sectionId == w.section)
            #expect(try membership(db, book: w.book, post: w.post) == nil,
                    "the original left THIS book")
            #expect(try membership(db, book: w.other, post: w.post) != nil,
                    "…and only this one — it lives on in its other books")
            // The post itself is untouched: this is a membership swap, never
            // a delete (the standing chip 'remove' wording's own rule).
            let live = try db.read { db in
                try Bool.fetchOne(
                    db,
                    sql: "SELECT EXISTS (SELECT 1 FROM container WHERE id = ? AND deleted_at IS NULL)",
                    arguments: [w.post])
            }
            #expect(live == true)
        }
    }

    /// The copy is the `duplicateAsVersion` copy — whole fans and the
    /// version anchor — because it composes the same body.
    @Test func theCopyIsAFullVersionCopy() throws {
        try withOperations { ops, db in
            let w = try world(ops)
            let result = try ops.divergePostForReading(w.post, in: w.book)
            #expect(result.copy.blockCopies.count == 1)
            let takes = try db.read { db in
                try Int.fetchOne(
                    db,
                    sql: """
                        SELECT COUNT(*) FROM variant v
                        JOIN container_block cb ON cb.block_id = v.block_id
                        WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                          AND v.deleted_at IS NULL
                        """,
                    arguments: [result.copy.post.id])
            }
            #expect(takes == 2, "the whole fan rides, as in every copy")
            #expect(result.copy.versionEdge.type == .versionOf)
        }
    }

    /// **THE UNDO ROUND TRIP — the reason this is an operation.** Undo puts
    /// the original back in its own slot and takes the copy away; redo does
    /// it again, exact-row, so the pair ping-pongs.
    @Test func undoRestoresTheOriginalToItsSlotAndRedoDivergesAgain() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let w = try world(ops)
            let before = try #require(try membership(db, book: w.book, post: w.post))
            let result = try ops.divergePostForReading(w.post, in: w.book)

            #expect(stack.topLabel == "Diverge for This Book", "ONE entry, not the mint's")
            _ = try stack.undo(with: ops)

            let restored = try #require(try membership(db, book: w.book, post: w.post))
            #expect(restored.id == before.id, "the SAME row, out of its tombstone")
            #expect(restored.position == before.position)
            #expect(restored.sectionId == before.sectionId, "its chapter came back with it")
            #expect(try membership(db, book: w.book, post: result.copy.post.id) == nil)
            let copyLive = try db.read { db in
                try Bool.fetchOne(
                    db,
                    sql: "SELECT EXISTS (SELECT 1 FROM container WHERE id = ? AND deleted_at IS NULL)",
                    arguments: [result.copy.post.id])
            }
            #expect(copyLive == false, "the copy is gone too — a whole undo, not a half one")

            _ = try stack.redo(with: ops)
            #expect(try membership(db, book: w.book, post: w.post) == nil)
            let back = try #require(
                try membership(db, book: w.book, post: result.copy.post.id))
            #expect(back.id == result.copyMembershipID, "exact-row: the SAME membership row")
            #expect(back.position == before.position)
            #expect(back.sectionId == before.sectionId)
        }
    }

    /// **THE COLD REVIEW'S R1-1 PIN (red on the pre-fix code).** Redo must
    /// bring the copy back WITH ITS CONTENT, not just its rows in the book:
    /// the undo's tombstone CASCADED (placements, blocks, variants — all
    /// stamped with the container's `deleted_at`), and a redo that flipped
    /// only the container row left a live but EMPTY note where her text
    /// was, the text stranded in rows no surface lists. The fix routes the
    /// revival through `restoreContainer`'s exact-stamp cascade restore —
    /// `reapplyMintedContainer`'s own shape.
    @Test func redoRevivesTheCopysContentNotJustItsRow() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let w = try world(ops)
            let result = try ops.divergePostForReading(w.post, in: w.book)
            _ = try stack.undo(with: ops)
            _ = try stack.redo(with: ops)

            let rendered = try db.read { db in
                try Queries.renderPost(db, containerID: result.copy.post.id)
            }
            #expect(!rendered.isEmpty, "the redone copy renders its blocks")
            #expect(rendered.first?.text == "Alpha beta.",
                    "…and they carry her text, not a gap")
            let (placements, variants) = try db.read { db in
                (try Int.fetchOne(
                    db,
                    sql: """
                        SELECT COUNT(*) FROM container_block
                        WHERE container_id = ? AND deleted_at IS NULL
                        """,
                    arguments: [result.copy.post.id]) ?? 0,
                 try Int.fetchOne(
                    db,
                    sql: """
                        SELECT COUNT(*) FROM variant v
                        JOIN container_block cb ON cb.block_id = v.block_id
                        WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                          AND v.deleted_at IS NULL
                        """,
                    arguments: [result.copy.post.id]) ?? 0)
            }
            #expect(placements == 1, "the placement came back with the container")
            #expect(variants == 2, "the whole fan came back — every row, not just the container's")
        }
    }

    /// The three refusals, each the ops layer's own.
    @Test func itRefusesSmartBooksFinishedBooksAndNonMembers() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost(title: "p")
            _ = try ops.newBlock(in: post.id, text: "Text.")

            let smart = try ops.createReading(name: "Smart", kind: .smart)
            #expect(throws: OperationError.self) {
                try ops.divergePostForReading(post.id, in: smart.id)
            }

            let book = try ops.createReading(name: "Orbit", kind: .curated)
            // Not a member yet.
            #expect(throws: OperationError.self) {
                try ops.divergePostForReading(post.id, in: book.id)
            }
            try ops.addPostToReading(post.id, to: book.id)
            try ops.lockReading(book.id)
            #expect(throws: OperationError.self) {
                try ops.divergePostForReading(post.id, in: book.id)
            }
        }
    }

    /// **Capacity is deliberately NOT gated** — the swap is net-zero, so a
    /// full book must still be able to diverge one of its posts. Recorded in
    /// the op's own doc; pinned here so it cannot regress into a refusal.
    @Test func aBookAtItsPostCapCanStillDiverge() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "Small", kind: .curated)
            let post = try ops.createPost(title: "only")
            _ = try ops.newBlock(in: post.id, text: "Text.")
            try ops.addPostToReading(post.id, to: book.id)
            try ops.setReadingMaxPosts(book.id, maxPosts: 1)

            let result = try ops.divergePostForReading(post.id, in: book.id)
            #expect(try membership(db, book: book.id, post: result.copy.post.id) != nil)
            let liveCount = try db.read { db in
                try Int.fetchOne(
                    db,
                    sql: """
                        SELECT COUNT(*) FROM reading_post
                        WHERE reading_id = ? AND deleted_at IS NULL
                        """,
                    arguments: [book.id])
            }
            #expect(liveCount == 1, "net zero: one in, one out")
        }
    }

    /// The assembly SEES the swap: the book renders the copy where the
    /// original stood, in the same chapter and the same place in the order.
    @Test func theBookRendersTheCopyWhereTheOriginalStood() throws {
        try withOperations { ops, db in
            let w = try world(ops)
            let originalOrder = try db.read { db in
                try Queries.assembleReading(db, readingID: w.book).map(\.postID)
            }
            let index = try #require(originalOrder.firstIndex(of: w.post))

            let result = try ops.divergePostForReading(w.post, in: w.book)
            let after = try db.read { db in
                try Queries.assembleReading(db, readingID: w.book).map(\.postID)
            }
            #expect(after.count == originalOrder.count)
            #expect(after[index] == result.copy.post.id, "same place in the book")
            #expect(!after.contains(w.post))
        }
    }
}

// MARK: - W24: extract joins A11

@Suite("Extract's seam keeps the blank line (13f W24)")
struct ExtractSeamTests {
    /// **Her ruling, both directions.** `"Alpha beta.\n\nGamma delta."`
    /// extracted at the blank line: whichever half is extracted, the piece
    /// BEFORE the seam keeps the k−1 newline, so the surface reproduces the
    /// blank byte-for-byte instead of losing it (the A11 rule, widened).
    @Test func aBlankLineAtTheSeamSurvivesOnThePieceBeforeIt() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let text = "Alpha beta.\n\nGamma delta."

            // PREFIX: the span is before the seam, so the MINTED half owns it.
            let a = try ops.newBlock(in: post.id, text: text)
            let prefixCut = ("Alpha beta." as String).utf16.count
            let extracted = try ops.extract(a.block.id, span: 0..<prefixCut)
            #expect(extracted.variant.workingText == "Alpha beta.\n",
                    "the blank rides with the piece before the seam")
            let sourceAfter = try db.read { try ops.renderedVariant($0, blockID: a.block.id) }
            #expect(sourceAfter.workingText == "Gamma delta.")

            // SUFFIX: the span is after the seam, so the SOURCE keeps it.
            let b = try ops.newBlock(in: post.id, text: text)
            let suffixStart = ("Alpha beta.\n\n" as String).utf16.count
            let extracted2 = try ops.extract(
                b.block.id, span: suffixStart..<text.utf16.count)
            #expect(extracted2.variant.workingText == "Gamma delta.")
            let sourceAfter2 = try db.read { try ops.renderedVariant($0, blockID: b.block.id) }
            #expect(sourceAfter2.workingText == "Alpha beta.\n",
                    "the source is the piece before the seam here")
        }
    }

    /// The ordinary seams are BYTE-UNCHANGED — one newline (the everyday
    /// paragraph split) keeps zero, and a plain space seam keeps nothing.
    /// This is the parity half: the ruling moved one byte class and no other.
    @Test func ordinarySeamsAreUnchanged() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()

            let single = try ops.newBlock(in: post.id, text: "Alpha beta.\nGamma delta.")
            let e1 = try ops.extract(single.block.id, span: 0..<11)
            #expect(e1.variant.workingText == "Alpha beta.")
            #expect(try db.read { try ops.renderedVariant($0, blockID: single.block.id) }
                    .workingText == "Gamma delta.")

            let spaced = try ops.newBlock(in: post.id, text: "Alpha beta. Gamma delta.")
            let e2 = try ops.extract(spaced.block.id, span: 0..<11)
            #expect(e2.variant.workingText == "Alpha beta.")
            #expect(try db.read { try ops.renderedVariant($0, blockID: spaced.block.id) }
                    .workingText == "Gamma delta.")
        }
    }

    /// Three newlines keep TWO, exactly as a divide does — the k−1 ownership
    /// rule is the same rule, which is the point of widening it rather than
    /// writing a second one.
    @Test func extractAndDivideAgreeOnTheSameSeam() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let text = "Alpha beta.\n\n\nGamma delta."
            let cut = ("Alpha beta." as String).utf16.count

            let divided = try ops.newBlock(in: post.id, text: text)
            _ = try ops.divide(divided.block.id, cut: cut)
            let dividedFirst = try db.read {
                try ops.renderedVariant($0, blockID: divided.block.id)
            }

            let extracted = try ops.newBlock(in: post.id, text: text)
            let minted = try ops.extract(extracted.block.id, span: 0..<cut)

            #expect(minted.variant.workingText == dividedFirst.workingText,
                    "one seam rule, two doors: \(minted.variant.workingText)")
            #expect(minted.variant.workingText == "Alpha beta.\n\n")
        }
    }

    /// The outer edges keep their standing treatment: only the SEAM moved.
    @Test func onlyTheSeamMovedTheOuterEdgesAreUntouched() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            // Leading whitespace before the span, trailing after it.
            let a = try ops.newBlock(in: post.id, text: "  Alpha beta.\n\nGamma delta.  ")
            let cut = ("  Alpha beta." as String).utf16.count
            let minted = try ops.extract(a.block.id, span: 2..<cut)
            #expect(minted.variant.workingText == "Alpha beta.\n",
                    "the span's own leading blank still trims away")
            #expect(try db.read { try ops.renderedVariant($0, blockID: a.block.id) }
                    .workingText == "Gamma delta.  ",
                    "the source's far edge is untouched, as it always was")
        }
    }
}
