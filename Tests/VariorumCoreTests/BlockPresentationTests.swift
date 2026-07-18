import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 13, Step A1 — migration v1_9 `block.presentation`: the callout
/// frame (rulings R16/R27). Identity-level metadata like `block.name`;
/// canonical JSON; CAS under sync.
@Suite("Block presentation / callouts (Phase 13, A1 — v1_9)")
struct BlockPresentationTests {
    @Test func columnExistsNullableOnBlock() throws {
        let db = try AppDatabase.inMemory()
        try db.read { db in
            let column = try Row.fetchAll(db, sql: "PRAGMA table_info(block)")
                .first { $0["name"] == "presentation" }
            #expect(column != nil)
            #expect(column?["notnull"] == 0, "presentation is nullable — nil = a plain block")
        }
    }

    @Test func setUpdateClearWithCanonicalJSONAndNoOpGuard() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "Goal <3.", at: .end).block

            try ops.setBlockPresentation(
                block.id, BlockPresentation(color: "blue", emoji: "💡"))
            let stored = try db.fetchString(
                "SELECT presentation FROM block WHERE id = ?", [block.id])
            #expect(stored == #"{"color":"blue","emoji":"💡","kind":"callout"}"#,
                    "canonical sorted-keys JSON — equal presentations are byte-equal")

            // The typed accessor round-trips.
            let fetched = try db.read { try Block.fetchOne($0, key: block.id) }
            #expect(fetched?.blockPresentation == BlockPresentation(color: "blue", emoji: "💡"))

            // No-op set writes nothing (updated_at holds still).
            let before = try db.fetchString(
                "SELECT updated_at FROM block WHERE id = ?", [block.id])
            try ops.setBlockPresentation(
                block.id, BlockPresentation(color: "blue", emoji: "💡"))
            #expect(try db.fetchString(
                "SELECT updated_at FROM block WHERE id = ?", [block.id]) == before)

            // Clearing returns the block to plain.
            try ops.setBlockPresentation(block.id, nil)
            #expect(try db.fetchString(
                "SELECT presentation FROM block WHERE id = ?", [block.id]) == nil)
        }
    }

    @Test func presentationIsMetadataNeverTouchOrChurn() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "Prose.", at: .end).block
            let touched = try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [post.id])
            let churn = try db.fetchString(
                "SELECT churn_accumulator FROM container WHERE id = ?", [post.id])

            try ops.setBlockPresentation(block.id, BlockPresentation(color: "sand"))

            #expect(try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [post.id]) == touched)
            #expect(try db.fetchString(
                "SELECT churn_accumulator FROM container WHERE id = ?", [post.id]) == churn)
        }
    }

    @Test func emptyKindRefusesAndSealRefuses() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost(title: "p", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "Prose.", at: .end).block

            #expect(throws: OperationError.invalidPresentationKind) {
                try ops.setBlockPresentation(block.id, BlockPresentation(kind: "  "))
            }

            try ops.lockPost(post.id)
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.setBlockPresentation(block.id, BlockPresentation())
            }
        }
    }

    @Test func malformedStoredJSONReadsAsPlainNeverCrashes() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "Prose.", at: .end).block
            // A future/foreign writer left garbage — the read side falls
            // open to a plain block (prose renders; the frame is lost, the
            // text never is).
            try db.write { db in
                try db.execute(
                    sql: "UPDATE block SET presentation = 'not json' WHERE id = ?",
                    arguments: [block.id])
            }
            let fetched = try db.read { try Block.fetchOne($0, key: block.id) }
            #expect(fetched?.blockPresentation == nil)
        }
    }

    @Test func unknownKindSurvivesTheRoundTrip() throws {
        // A future client's frame family decodes, re-encodes, and never
        // corrupts here (the unknown-vocabulary doctrine).
        let foreign = #"{"color":"lilac","kind":"sidebar-note"}"#
        let decoded = BlockPresentation.decode(foreign)
        #expect(decoded?.kind == "sidebar-note")
        #expect(try decoded?.encodedJSON() == foreign)
    }

    @Test func presentationCrossesTheWireAsPlainMetadata() throws {
        // The column rides the block payload automatically (introspected
        // serializer) — pin one full row → payload → apply hop.
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "Prose.", at: .end).block
            try ops.setBlockPresentation(block.id, BlockPresentation(color: "blue"))

            let payload = try db.read { db in
                try SyncRow.fetch(db, table: SyncSchema.table(named: "block")!, rowID: block.id)
            }
            #expect(payload?.columns["presentation"] ==
                    .text(#"{"color":"blue","kind":"callout"}"#))
        }
    }
}
