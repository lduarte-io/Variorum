import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 11b, Step B3 — the reference panel's read side and the one sync
/// rule the panel must never weaken: `file_bookmark` is LOCAL-ONLY (AppSpec
/// §7; the Phase 5 exclusion, re-pinned here from the panel's own write
/// path so a future panel change can't open a second door).
@Suite("Reference panel core (Phase 11b, B3)")
struct ReferencePanelQueryTests {
    @Test func referencesListsLiveRowsInPanelOrder() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "P")
            let first = try ops.addReference(to: post.id, kind: .url, name: "One", url: "https://a.example")
            let second = try ops.addReference(to: post.id, kind: .url, name: "Two", url: "https://b.example")
            let third = try ops.addReference(to: post.id, kind: .url, name: "Three", url: "https://c.example")

            // Reorder third to the front; tombstone second.
            try ops.reorderReference(third.id, to: .start)
            try ops.removeReference(second.id)

            let listed = try db.read { try Queries.references($0, containerID: post.id) }
            #expect(listed.map(\.name) == ["Three", "One"])

            // Another post's panel is empty (scoped listing).
            let other = try ops.createPost(title: "Q")
            let empty = try db.read { try Queries.references($0, containerID: other.id) }
            #expect(empty.isEmpty)
            _ = first
        }
    }

    @Test func aPanelCreatedBookmarkNeverReachesASyncPayload() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "P")
            // The panel's exact write path: addReference(kind: .file) with
            // real bookmark bytes.
            let reference = try ops.addReference(
                to: post.id, kind: .file, name: "Paper.pdf",
                fileBookmark: Data([0xDE, 0xAD, 0xBE, 0xEF]))

            // The row is outbox-captured (it syncs) …
            #expect(try db.outboxContains("reference", reference.id))

            // … but its payload carries NO bookmark — and every other
            // column it should.
            let table = SyncSchema.tables.first { $0.name == "reference" }!
            let payload = try db.read { try SyncRow.fetch($0, table: table, rowID: reference.id) }
            let columns = try #require(payload).columns
            #expect(columns["file_bookmark"] == nil)
            #expect(columns["container_id"] == .text(post.id))
            #expect(columns["name"] == .text("Paper.pdf"))

            // The stored row itself still holds the bytes locally.
            let stored = try db.read { database in
                try Data.fetchOne(
                    database,
                    sql: "SELECT file_bookmark FROM reference WHERE id = ?",
                    arguments: [reference.id])
            }
            #expect(stored == Data([0xDE, 0xAD, 0xBE, 0xEF]))
        }
    }

    @Test func viewStateRoundTripsThroughTheOperation() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "P")
            let reference = try ops.addReference(to: post.id, kind: .file, name: "Paper.pdf")
            try ops.updateReferenceViewState(reference.id, viewState: #"{"pdfPage":7}"#)
            let listed = try db.read { try Queries.references($0, containerID: post.id) }
            #expect(listed.first?.viewState == #"{"pdfPage":7}"#)
        }
    }
}
