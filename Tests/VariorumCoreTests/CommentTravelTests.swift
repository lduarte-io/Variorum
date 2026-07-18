import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 13, Step A2 — the travel rules: comments DUPLICATE onto structural
/// successors (her ratified instinct: "duplicate where needed and easy to
/// resolve"), and the presentation frame inherits down the split taxonomy.
/// One state-transition test per operation, plus the undo pins (reverting a
/// mint must strand no live copies — the cascade owns them).
@Suite("Comment & presentation travel (Phase 13, A2)")
struct CommentTravelTests {
    private func comments(
        _ db: AppDatabase, on blockID: String
    ) throws -> [String] {
        try db.read { try Queries.blockComments($0, blockID: blockID).map(\.text) }
    }

    // MARK: - Extract / divide (source survives / in-place cut)

    @Test func extractCopiesCommentsAndInheritsTheFrame() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "One. Two.", at: .end).block
            try ops.setBlockPresentation(block.id, BlockPresentation(color: "blue"))
            _ = try ops.addBlockComment(to: block.id, text: "note α")
            _ = try ops.addBlockComment(to: block.id, text: "note β")
            let dead = try ops.addBlockComment(to: block.id, text: "deleted — must not travel")
            try ops.deleteBlockComment(dead.id)

            let minted = try ops.extract(block.id, span: 0..<4)  // "One."

            #expect(try comments(db, on: block.id) == ["note α", "note β"],
                    "the source keeps its live comments")
            #expect(try comments(db, on: minted.block.id) == ["note α", "note β"],
                    "the minted half gets COPIES, in the source's order")
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM block_comment WHERE block_id = ?", [minted.block.id]) == 2,
                    "deleted comments do NOT travel")
            #expect(try db.fetchString(
                "SELECT presentation FROM block WHERE id = ?", [minted.block.id])
                == (try db.fetchString(
                    "SELECT presentation FROM block WHERE id = ?", [block.id])),
                    "the callout frame inherits")
            // Copies are fresh rows with PRESERVED created_at (a note's
            // date is part of the note) — never the same row.
            let pairs = try db.read { db in
                try Row.fetchAll(db, sql: """
                    SELECT a.id AS src, b.id AS copy FROM block_comment a
                    JOIN block_comment b ON b.text = a.text AND b.block_id = ?
                    WHERE a.block_id = ? AND a.deleted_at IS NULL
                    """, arguments: [minted.block.id, block.id])
            }
            for pair in pairs { #expect((pair["src"] as String) != (pair["copy"] as String)) }
            let createdAts = try db.read { db in
                try Row.fetchAll(db, sql: """
                    SELECT a.created_at AS src, b.created_at AS copy FROM block_comment a
                    JOIN block_comment b ON b.text = a.text AND b.block_id = ?
                    WHERE a.block_id = ? AND a.deleted_at IS NULL
                    """, arguments: [minted.block.id, block.id])
            }
            for row in createdAts {
                #expect((row["src"] as String) == (row["copy"] as String),
                        "the copy preserves the source note's created_at")
            }
        }
    }

    @Test func divideCopiesToTheMintedHalfAndBothKeepTheFrame() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "First half. Second half.", at: .end).block
            try ops.setBlockPresentation(block.id, BlockPresentation(color: "sand", emoji: "🌙"))
            _ = try ops.addBlockComment(to: block.id, text: "spans the whole thought")

            let minted = try ops.divide(block.id, cut: 11)

            #expect(try comments(db, on: block.id) == ["spans the whole thought"])
            #expect(try comments(db, on: minted.block.id) == ["spans the whole thought"])
            let sourceFrame = try db.fetchString("SELECT presentation FROM block WHERE id = ?", [block.id])
            #expect(sourceFrame != nil)
            #expect(try db.fetchString(
                "SELECT presentation FROM block WHERE id = ?", [minted.block.id]) == sourceFrame,
                    "both halves were the callout's content — both keep the frame")
        }
    }

    @Test func divideWCopiesToBothSuccessorsAndAKeepsItsOriginals() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .generic)
            let made = try ops.newBlock(in: post.id, text: "AA. BB.", at: .end)
            let second = try ops.branchVariant(made.block.id, from: made.variant.id)
            try ops.setBlockPresentation(made.block.id, BlockPresentation(color: "blue"))
            let original = try ops.addBlockComment(to: made.block.id, text: "the W note")

            let result = try ops.divideW(
                made.block.id, cuts: [made.variant.id: 3, second.id: 3])

            #expect(try comments(db, on: made.block.id) == ["the W note"],
                    "A — preserved whole — keeps its original notes")
            #expect(try comments(db, on: result.first.block.id) == ["the W note"])
            #expect(try comments(db, on: result.second.block.id) == ["the W note"])
            let frame = try db.fetchString(
                "SELECT presentation FROM block WHERE id = ?", [made.block.id])
            for successor in [result.first.block.id, result.second.block.id] {
                #expect(try db.fetchString(
                    "SELECT presentation FROM block WHERE id = ?", [successor]) == frame)
            }
            // Three distinct live rows carry the text: the original + two copies.
            #expect(try db.fetchInt("""
                SELECT COUNT(*) FROM block_comment
                WHERE text = 'the W note' AND deleted_at IS NULL
                """) == 3)
            #expect(try db.fetchString(
                "SELECT id FROM block_comment WHERE block_id = ?",
                [made.block.id]) == original.id)
        }
    }

    // MARK: - Merge (mirrors W)

    @Test func mergeCarriesBothSidesNotesChronologically() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .generic)
            let first = try ops.newBlock(in: post.id, text: "Alpha.", at: .end).block
            let second = try ops.newBlock(in: post.id, text: "Beta.", at: .end).block
            // Interleaved creation: first gets a note, then second, then
            // first again — the merged list must read chronologically
            // across BOTH sources (copies preserve created_at).
            _ = try ops.addBlockComment(to: first.id, text: "1: on alpha")
            _ = try ops.addBlockComment(to: second.id, text: "2: on beta")
            _ = try ops.addBlockComment(to: first.id, text: "3: on alpha again")

            let merged = try ops.merge(first.id, second.id)

            #expect(try comments(db, on: merged.block.id)
                    == ["1: on alpha", "2: on beta", "3: on alpha again"])
            #expect(try comments(db, on: first.id) == ["1: on alpha", "3: on alpha again"],
                    "the released sources keep their originals as lineage")
            #expect(try comments(db, on: second.id) == ["2: on beta"])
        }
    }

    @Test func mergeKeepsTheFrameOnlyWhenBothSourcesAgree() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .generic)
            // Agreeing frames → the frame carries.
            let a1 = try ops.newBlock(in: post.id, text: "A one.", at: .end).block
            let a2 = try ops.newBlock(in: post.id, text: "A two.", at: .end).block
            try ops.setBlockPresentation(a1.id, BlockPresentation(color: "blue"))
            try ops.setBlockPresentation(a2.id, BlockPresentation(color: "blue"))
            let agreed = try ops.merge(a1.id, a2.id)
            #expect(try db.fetchString(
                "SELECT presentation FROM block WHERE id = ?", [agreed.block.id])
                == #"{"color":"blue","kind":"callout"}"#)

            // Differing frames (callout + plain) → a PLAIN block; no side
            // silently wins (PROVISIONAL rule).
            let b1 = try ops.newBlock(in: post.id, text: "B one.", at: .end).block
            let b2 = try ops.newBlock(in: post.id, text: "B two.", at: .end).block
            try ops.setBlockPresentation(b1.id, BlockPresentation(color: "sand"))
            let mixed = try ops.merge(b1.id, b2.id)
            #expect(try db.fetchString(
                "SELECT presentation FROM block WHERE id = ?", [mixed.block.id]) == nil)
        }
    }

    // MARK: - The copy family

    @Test func poolDragCopyCarriesNotesAndFrame() throws {
        try withOperations { ops, db in
            let pool = try ops.createPool(title: "scraps")
            let scrap = try ops.newBlock(in: pool.id, text: "loose idea", at: .end).block
            try ops.setBlockPresentation(scrap.id, BlockPresentation(emoji: "💡"))
            _ = try ops.addBlockComment(to: scrap.id, text: "where this came from")
            let post = try ops.createPost(title: "draft", profile: .generic)

            let copy = try ops.poolDragCopy(scrap.id, to: post.id)

            #expect(try comments(db, on: copy.block.id) == ["where this came from"])
            #expect(try comments(db, on: scrap.id) == ["where this came from"],
                    "the pool original is untouched")
            #expect(try db.fetchString(
                "SELECT presentation FROM block WHERE id = ?", [copy.block.id])
                == (try db.fetchString("SELECT presentation FROM block WHERE id = ?", [scrap.id])))
        }
    }

    @Test func duplicateAsVersionAndPromoteLensCarryNotesPerBlock() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "keeper", profile: .generic)
            let b1 = try ops.newBlock(in: post.id, text: "First block.", at: .end).block
            let b2 = try ops.newBlock(in: post.id, text: "Second block.", at: .end).block
            try ops.setBlockPresentation(b2.id, BlockPresentation(color: "blue"))
            _ = try ops.addBlockComment(to: b1.id, text: "on the first")
            _ = try ops.addBlockComment(to: b2.id, text: "on the second")

            let duplicate = try ops.duplicateAsVersion(post.id)
            for (source, copy) in duplicate.blockCopies {
                #expect(try comments(db, on: copy) == (try comments(db, on: source)),
                        "every block copy carries its source's notes")
                #expect(try db.fetchString(
                    "SELECT presentation FROM block WHERE id = ?", [copy])
                    == (try db.fetchString("SELECT presentation FROM block WHERE id = ?", [source])))
            }

            let lens = try ops.createLens(post: post.id, name: "thread")
            let promoted = try ops.promoteLens(lens.id)
            for (source, copy) in promoted.blockCopies {
                #expect(try comments(db, on: copy) == (try comments(db, on: source)))
            }
        }
    }

    // MARK: - Undo (the cascade owns the copies)

    @Test func undoingASplitStrandsNoLiveCopies() throws {
        let stack = UndoStack()
        try withOperations { ops0, db in
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost(title: "p", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "First half. Second half.", at: .end).block
            _ = try ops.addBlockComment(to: block.id, text: "travels then dies with the undo")

            let minted = try ops.divide(block.id, cut: 11)
            #expect(try db.fetchInt("""
                SELECT COUNT(*) FROM block_comment WHERE deleted_at IS NULL
                """) == 2)

            _ = try stack.undo(with: ops)

            #expect(try db.fetchInt("""
                SELECT COUNT(*) FROM block_comment WHERE deleted_at IS NULL
                """) == 1, "the copy died with the minted block — no orphan notes")
            #expect(try db.deletedAt("block", minted.block.id) != nil)
            #expect(try comments(db, on: block.id) == ["travels then dies with the undo"],
                    "the source's original is untouched")
            _ = ops0
        }
    }
}
