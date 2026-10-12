import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-168 U3 — THE LENS DOORS' CORE: exact state transitions. VX-171 (R-VX171-2,
// her word, door-only): the structured `create_note` MINTS a blank take where
// its payload says `""` — the file doors (the Level 0 format, which cannot
// carry one) keep dropping it. The wire's own pins are `MCPLensDoorsServerTests`.

@Suite("VX-168 U3 — the lens doors' core: the blank take's mint")
struct MCPBlankTakeMintTests {
    private func withUndo<T>(_ body: (Operations, UndoStack, AppDatabase) throws -> T) throws -> T {
        try withOperations { _, db in
            let stack = UndoStack()
            return try body(Operations(undoStack: stack), stack, db)
        }
    }

    private func fan(_ db: AppDatabase, _ blockID: String) throws -> [Variant] {
        try db.read { db in
            try Variant.fetchAll(
                db, sql: "SELECT * FROM variant WHERE block_id = ? AND deleted_at IS NULL ORDER BY fan_position, id",
                arguments: [blockID])
        }
    }

    /// RED ON OLD: the blank take was dropped (`mintDocument`'s format rule
    /// ran on this door too) — the fan held two takes.
    @Test func aStructuredNotesBlankTakeIsMintedInPlaceInTheFan() throws {
        try withUndo { ops, stack, db in
            let minted = try ops.createStructuredNote(
                title: "the review", entryDate: nil,
                blocks: [.init(text: "In place.", takes: [.init(label: nil, text: ""), .init(label: "alt", text: "Alt.")])],
                in: .wing(""), undoLabel: "claude-code's note")
            let blockID = try #require(minted.blockIDs.first)
            let takes = try fan(db, blockID)
            #expect(takes.map(\.workingText) == ["In place.", "", "Alt."])
            #expect(takes.map(\.label) == [nil, nil, "alt"])
            #expect(takes.allSatisfy { $0.status == .active && !$0.locked && $0.parentVariantId == nil })
            #expect(minted.alternateCount == 2, "the blank take counts as the take it is")
            let pointers = try db.read { db in
                try Row.fetchOne(
                    db,
                    sql: """
                        SELECT cb.chosen_variant_id AS chosen, b.default_variant_id AS dflt
                        FROM container_block cb JOIN block b ON b.id = cb.block_id WHERE cb.block_id = ?
                        """,
                    arguments: [blockID])
            }
            #expect(pointers?["chosen"] as String? == takes[0].id && pointers?["dflt"] as String? == takes[0].id,
                    "the in-place text stays chosen AND default; the blank take is never either")
            #expect(try db.read { try Queries.renderedText($0, containerID: minted.post.id) } == "In place.")
            #expect(stack.depth == 1, "one entry for the whole note, as ever")
            _ = try stack.undo(with: ops)
            #expect(try db.deletedAt("container", minted.post.id) != nil)
        }
    }

    /// The FILE road keeps the format's rule: a document whose section would
    /// say `""` mints nothing for it (the Level 0 format cannot write one —
    /// `alternatesSection` skips it — so one format keeps one meaning).
    @Test func theDocumentRoadStillDropsABlankAlternate() throws {
        try withUndo { ops, _, db in
            let named = VariorumDocument.NamedDocument(
                fallbackTitle: "",
                document: VariorumDocument.Document(
                    title: "file", tagPaths: [],
                    blocks: [.init(text: "In place.", alternates: [.init(label: nil, text: ""), .init(label: nil, text: "Alt.")])]))
            let imported = try ops.importNote(named, in: .wing(""), undoLabel: "claude-code's import")
            let blockID = try #require(imported.blockIDs.first)
            #expect(try fan(db, blockID).map(\.workingText) == ["In place.", "Alt."])
        }
    }
}
