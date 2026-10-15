import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-311 (VX-336 U6a — the run record `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md`,
// U6a D-311-1/4/5/8): the core half of `duplicate_note`, as exact state transitions —
// `duplicateNoteForClient` lands HER Duplicate as Version's rows (the one extracted body,
// `duplicateAsVersionBody`), the caller's guard first; ONE entry labelled as given, whose undo
// tombstones the copy, whose redo revives it on the stamp, and which RETIRES quietly when the
// copy is already gone; and the records (`PostCopyResult.blocks`) are the copy's live fans —
// active takes in fan order, the shown take by read_note's rule, each naming its source block.
// (The wire pins are `MCPDuplicateNoteServerTests`.) New API, so green by construction: state
// transitions, the house's rule for a pure addition (U5b's precedent).

@Suite("VX-311 — duplicate_note's act and its records (core)")
struct MCPDuplicateNoteActsTests {
    private func withUndo<T>(_ body: (Operations, UndoStack, AppDatabase) throws -> T) throws -> T {
        try withOperations { _, db in
            let stack = UndoStack()
            return try body(Operations(undoStack: stack), stack, db)
        }
    }

    private struct Shape: Equatable {
        let title: String?
        let profile: String?
        let entryDate: String?
        let wing: String
        let locked: Int
        let texts: [String?]
        let tags: [String]
        let books: Int
        let derivedFrom: [String]
        let versionOf: Int
    }

    /// The copy as her door and the wire both see it: its row, its rendered takes, its tags,
    /// its books, its lineage to the source, the version anchor.
    private func shape(_ db: AppDatabase, copy: String, source: String) throws -> Shape {
        try db.read { db in
            let row = try #require(try Row.fetchOne(
                db, sql: "SELECT title, profile, entry_date, wing_id, locked FROM container WHERE id = ?",
                arguments: [copy]))
            let copyBlocks = try String.fetchAll(
                db, sql: "SELECT block_id FROM container_block WHERE container_id = ? AND deleted_at IS NULL ORDER BY position, id",
                arguments: [copy])
            let sourceBlocks = try String.fetchAll(
                db, sql: "SELECT block_id FROM container_block WHERE container_id = ? AND deleted_at IS NULL ORDER BY position, id",
                arguments: [source])
            let derived = try copyBlocks.map { block in
                try String.fetchOne(
                    db, sql: "SELECT target_block_id FROM edge WHERE source_block_id = ? AND type = 'derived_from' AND deleted_at IS NULL",
                    arguments: [block]) ?? "-"
            }
            #expect(derived == sourceBlocks, "one derived_from per copied block, each to its source block")
            let versionOf = try Int.fetchOne(
                db, sql: """
                    SELECT COUNT(*) FROM edge WHERE type = 'version_of' AND deleted_at IS NULL
                      AND (source_block_id IN (SELECT value FROM json_each(?)) OR target_block_id IN (SELECT value FROM json_each(?)))
                    """,
                arguments: [String(decoding: try JSONEncoder().encode(copyBlocks), as: UTF8.self),
                            String(decoding: try JSONEncoder().encode(copyBlocks), as: UTF8.self)]) ?? -1
            return Shape(
                title: row["title"], profile: row["profile"], entryDate: row["entry_date"], wing: row["wing_id"],
                locked: row["locked"],
                texts: try Queries.renderPost(db, containerID: copy).filter { !$0.isGap }.map(\.text),
                tags: try String.fetchAll(
                    db, sql: "SELECT tag_id FROM post_tag WHERE post_id = ? AND deleted_at IS NULL ORDER BY created_at, id",
                    arguments: [copy]),
                books: try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                    arguments: [copy]) ?? -1,
                derivedFrom: derived, versionOf: versionOf)
        }
    }

    /// The rows equal her Duplicate as Version's, on the same source: bookless in the source's
    /// wing, the tags riding, one `derived_from` per block, one `version_of`; a SEALED source is
    /// legal and the copy is never born locked.
    @Test func theRowsAreHerDuplicateAsVersionsExactly() throws {
        try withUndo { ops, _, db in
            let wing = try ops.createWing(name: "research")
            let book = try ops.createReading(name: "drafts", kind: .book, wingId: wing.id)
            let source = try ops.createPost(title: "the essay", entryDate: "2026-10-14", wingId: wing.id)
            _ = try ops.addPostToReading(source.id, to: book.id)
            let one = try ops.seedBlock(in: source.id, text: "One.")
            let alt = try ops.branchVariant(one.block.id, from: one.variant.id)
            try ops.autosave(alt.id, text: "One, again.", charDelta: 7)
            _ = try ops.seedBlock(in: source.id, text: "Two.")
            let tag = try ops.createTag(name: "essay", wingID: wing.id)
            try ops.applyTag(tag.id, toPost: source.id)
            try ops.lockPost(source.id)

            let theirs = try ops.duplicateAsVersion(source.id)
            let mine = try ops.duplicateNoteForClient(source.id, undoLabel: "claude-code's duplicate")

            let herShape = try shape(db, copy: theirs.post.id, source: source.id)
            let wireShape = try shape(db, copy: mine.post.id, source: source.id)
            #expect(wireShape == herShape, "the wire lands her door's rows")
            #expect(wireShape.wing == wing.id && wireShape.books == 0 && wireShape.tags == [tag.id])
            #expect(wireShape.locked == 0, "a sealed source copies; the copy is never born locked")
            #expect(wireShape.versionOf == 1 && wireShape.entryDate == "2026-10-14" && wireShape.title == "the essay")
            #expect(mine.blocks.map(\.blockID) == mine.blockCopies.map(\.copy), "the records are the copies, in order")
        }
    }

    /// The guard runs FIRST, inside the act's transaction: a guard that throws writes nothing
    /// and registers nothing.
    @Test func aThrowingGuardWritesNothing() throws {
        struct Refused: Error {}
        try withUndo { ops, stack, db in
            let source = try ops.createPost(title: "the essay")
            _ = try ops.seedBlock(in: source.id, text: "One.")
            let notes = "SELECT COUNT(*) FROM container WHERE kind = 'post'"
            let before = try db.fetchInt(notes)
            #expect(throws: Refused.self) {
                try ops.duplicateNoteForClient(source.id, undoLabel: "u", guardedBy: { _ in throw Refused() })
            }
            #expect(try db.fetchInt(notes) == before && stack.depth == 0, "nothing minted, no entry")
        }
    }

    /// ONE entry, labelled as given: its undo tombstones the copy, its redo revives it on the
    /// stamp; a copy she deleted herself since makes the undo QUIET, and the entry retires.
    @Test func oneEntryUndoesAndRedoesTheCopyAndACopySheDeletedStaysDeleted() throws {
        try withUndo { ops, stack, db in
            let source = try ops.createPost(title: "the essay")
            _ = try ops.seedBlock(in: source.id, text: "One.")
            let copy = try ops.duplicateNoteForClient(source.id, undoLabel: "claude-code's duplicate")
            #expect(stack.depth == 1 && stack.topLabel == "claude-code's duplicate")

            #expect(try stack.undoReporting(with: ops) == .init(label: "claude-code's duplicate", changed: true))
            #expect(try db.deletedAt("container", copy.post.id) != nil, "⌥⌘Z: the copy goes to the Trash")
            #expect(try db.deletedAt("container", source.id) == nil, "the source never moves")
            #expect(try stack.redoReporting(with: ops) == .init(label: "claude-code's duplicate", changed: true))
            #expect(try db.deletedAt("container", copy.post.id) == nil, "⇧⌥⌘Z: the same copy back")

            try ops.deleteContainer(copy.post.id)
            let deletedAt = try db.deletedAt("container", copy.post.id)
            #expect(try stack.undoReporting(with: ops) == .init(label: "claude-code's duplicate", changed: false),
                    "her Delete since: the undo changes nothing")
            #expect(stack.depth == 0 && stack.redoDepth == 0, "the quiet half RETIRES the entry")
            #expect(try db.deletedAt("container", copy.post.id) == deletedAt, "her deletion stands, its stamp hers")
        }
    }

    /// The records ARE the copy's live fans: active takes in fan order with their labels, the
    /// shown take by read_note's rule (an ARCHIVED chosen falls back to the default), each record
    /// naming its source block — and an archived take rides the note outside the record.
    @Test func theRecordsAreTheCopysLiveFans() throws {
        try withUndo { ops, _, db in
            let source = try ops.createPost(title: "the essay")
            let one = try ops.seedBlock(in: source.id, text: "One.")
            let two = try ops.seedBlock(in: source.id, text: "Two.")
            let again = try ops.branchVariant(two.block.id, from: two.variant.id)
            try ops.setTakeLabel(again.id, label: "again")
            try ops.chooseVariant(two.block.id, variantID: again.id)
            let shelved = try ops.branchVariant(one.block.id, from: one.variant.id)
            try ops.chooseVariant(one.block.id, variantID: shelved.id)
            try ops.archiveVariant(shelved.id)  // block 1's CHOSEN take, archived

            let copy = try ops.duplicateNoteForClient(source.id, undoLabel: "u")
            #expect(copy.blocks.map(\.sourceBlockID) == [one.block.id, two.block.id])
            for record in copy.blocks {
                let (fan, chosen, fallback) = try db.read { db in
                    (try Row.fetchAll(
                        db, sql: """
                            SELECT id, label FROM variant WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
                            ORDER BY fan_position, id
                            """, arguments: [record.blockID]),
                     try String.fetchOne(
                        db, sql: "SELECT chosen_variant_id FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                        arguments: [record.blockID]),
                     try String.fetchOne(db, sql: "SELECT default_variant_id FROM block WHERE id = ?",
                                         arguments: [record.blockID]))
                }
                #expect(record.takes.map(\.id) == fan.map { $0["id"] as String }, "the active fan, in fan order")
                #expect(record.takes.map(\.label) == fan.map { $0["label"] as String? })
                let active = Set(fan.map { $0["id"] as String })
                let shown = [chosen, fallback].compactMap { $0 }.first(where: active.contains)
                #expect(record.shownTakeID == shown, "read_note's rule: the chosen while active, else the default")
            }
            #expect(copy.blocks[0].takes.count == 1, "the archived take rides the note, outside the record")
            let archivedCopies = try db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE block_id = ? AND status = 'archived' AND deleted_at IS NULL",
                [copy.blocks[0].blockID])
            #expect(archivedCopies == 1)
            #expect(copy.blocks[1].takes.map(\.label) == [nil, "again"])
            #expect(copy.blocks[1].shownTakeID == copy.blocks[1].takes[1].id, "the copy shows what the source chose")
        }
    }
}
