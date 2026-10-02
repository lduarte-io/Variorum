import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// 13i-d U5 — THE WING OPS (F-U5-1: none existed; the sitting record §9; her
/// kickoff ruling R-13id-2 — "Delete Wing refuses while the wing holds any
/// live note, book or tag, NAMING what remains"). Exact state transitions;
/// a refusal writes nothing.
@Suite("13i-d U5 — the wing operations")
struct WingOperationsTests {
    /// A tag in a wing (raw — the fixture is independent of the tag ops,
    /// whose own wing-honesty `TagWingScopeTests` pins).
    private func tag(_ db: AppDatabase, _ name: String, wing: String) throws -> VariorumCore.Tag {
        try insertWingTag(db, name: name, wing: wing)
    }

    @Test func aWingIsMintedTrimmedAtTheEndAndBlankRefuses() throws {
        try withOperations { ops, db in
            let a = try ops.createWing(name: "  Imports ")
            let b = try ops.createWing(name: "Work")
            #expect(a.name == "Imports")
            let listed = try db.read { try Queries.wings($0) }
            #expect(listed.map(\.id) == [a.id, b.id], "the switcher's order is mint order")
            #expect(a.position < b.position)
            #expect(throws: OperationError.invalidWingName(name: "   ")) {
                try ops.createWing(name: "   ")
            }
            #expect(try db.read { try Queries.wings($0) }.count == 2)
        }
    }

    @Test func renameRetitlesRefusesHomeAndANoOpWritesNothing() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Imports")
            try ops.renameWing(wing.id, to: " Archive ")
            #expect(try db.read { try Queries.liveWing($0, id: wing.id) }?.name == "Archive")
            try db.clearOutbox()
            try ops.renameWing(wing.id, to: "Archive")
            #expect(try db.outboxContains("wing", wing.id) == false, "a no-op writes nothing")
            #expect(throws: OperationError.wingNotFound(id: "")) {
                try ops.renameWing("", to: "Elsewhere")
            }
            #expect(throws: OperationError.invalidWingName(name: "")) {
                try ops.renameWing(wing.id, to: "")
            }
        }
    }

    @Test func theNameGuardRefusesHomeAndALiveWingsNameCaseFolded() throws {
        try withOperations { ops, _ in
            let wing = try ops.createWing(name: "Imports")
            #expect(throws: OperationError.duplicateWingName(name: "Home")) {
                try ops.assertWingNameIsFree(" home ")
            }
            #expect(throws: OperationError.duplicateWingName(name: "Imports")) {
                try ops.assertWingNameIsFree("IMPORTS")
            }
            // Renaming a wing to its own name (or its own casing) is free.
            try ops.assertWingNameIsFree("imports", excluding: wing.id)
            // A dead wing's name is free again.
            try ops.deleteWing(wing.id)
            try ops.assertWingNameIsFree("Imports")
        }
    }

    /// R-13id-2 — the refusal NAMES what remains, counted exactly: notes
    /// (archived included; saved versions excluded), books, gatherings, tags.
    /// Nothing is written.
    @Test func deleteRefusesWhileTheWingHoldsAnythingAndNamesIt() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Imports")
            let a = try ops.createPost(title: "a", wingId: wing.id)
            _ = try ops.newBlock(in: a.id, text: "words", at: .end)
            _ = try ops.saveNoteVersion(a.id)  // a version rides its note — never counted
            let b = try ops.createPost(title: "b", wingId: wing.id)
            try ops.archiveContainer(b.id)  // kept, not gone — counted
            let t = try tag(db, "imported", wing: wing.id)
            _ = try ops.createReading(name: "book", kind: .book, wingId: wing.id)
            _ = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(t.id)),
                wingId: wing.id)
            // Home's own contents never count against the wing.
            _ = try ops.createPost(title: "home note")
            let before = try db.snapshotRow("wing", wing.id, excluding: [])
            try db.clearOutbox()
            let expected = Queries.WingContents(notes: 2, books: 1, gatherings: 1, tags: 1)
            #expect(try db.read { try Queries.wingContents($0, wingID: wing.id) } == expected)
            #expect(throws: OperationError.wingNotEmpty(id: wing.id, contents: expected)) {
                try ops.deleteWing(wing.id)
            }
            #expect(try db.snapshotRow("wing", wing.id, excluding: []) == before)
            #expect(try db.outboxContains("wing", wing.id) == false)
        }
    }

    /// An EMPTY wing deletes, its live shelves tombstoning on the wing's ONE
    /// stamp; another wing's shelves and Home's are untouched; Home itself
    /// refuses (virtual — undeletable by construction).
    @Test func anEmptyWingDeletesWithItsShelvesOnOneStamp() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Imports")
            let other = try ops.createWing(name: "Work")
            let s1 = try ops.createShelf(name: "one", wingID: wing.id)
            let s2 = try ops.createShelf(name: "two", wingID: wing.id)
            let keep = try ops.createShelf(name: "kept", wingID: other.id)
            let home = try ops.createShelf(name: "home shelf")
            try ops.deleteWing(wing.id)
            let stamp = try #require(try db.deletedAt("wing", wing.id))
            #expect(try db.deletedAt("shelf", s1.id) == stamp)
            #expect(try db.deletedAt("shelf", s2.id) == stamp)
            #expect(try db.deletedAt("shelf", keep.id) == nil)
            #expect(try db.deletedAt("shelf", home.id) == nil)
            #expect(try db.read { try Queries.wings($0) }.map(\.id) == [other.id])
            #expect(throws: OperationError.wingNotFound(id: "")) { try ops.deleteWing("") }
            #expect(throws: OperationError.wingNotFound(id: wing.id)) {
                try ops.deleteWing(wing.id)
            }
        }
    }

    /// A deleted note in the wing (in the Trash) does not block the delete —
    /// R-13id-2 counts LIVE contents; the Trash row reads as Home's afterwards
    /// (the dangling rule, pinned with the scoped reads).
    @Test func trashRowsDoNotBlockTheDelete() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Imports")
            let note = try ops.createPost(title: "gone", wingId: wing.id)
            try ops.deleteContainer(note.id)
            try ops.deleteWing(wing.id)
            #expect(try db.deletedAt("wing", wing.id) != nil)
        }
    }

    /// The ONE scope fragment: a wing reads exactly its own rows; HOME reads
    /// '' AND every row whose wing pointer dangles (P-13id-U5-2).
    @Test func theScopeFragmentReadsADanglingWingAsHome() throws {
        try withOperations { ops, db in
            let live = try ops.createWing(name: "Live")
            let doomed = try ops.createWing(name: "Doomed")
            let inHome = try ops.createPost(title: "home")
            let inLive = try ops.createPost(title: "live", wingId: live.id)
            let orphan = try ops.createPost(title: "orphan", wingId: doomed.id)
            // The sync-race shape: a live row left in a wing deleted here
            // (written raw — the op refuses a non-empty wing).
            try db.write {
                try $0.execute(
                    sql: "UPDATE wing SET deleted_at = '2026-07-01T00:01:00.000Z' WHERE id = ?",
                    arguments: [doomed.id])
            }
            func ids(_ wing: String) throws -> Set<String> {
                let scope = Queries.wingScope(column: "c.wing_id", wingID: wing)
                return Set(try db.read {
                    try String.fetchAll(
                        $0,
                        sql: "SELECT c.id FROM container c WHERE c.kind = 'post' AND \(scope.sql)",
                        arguments: StatementArguments(scope.arguments))
                })
            }
            #expect(try ids("") == [inHome.id, orphan.id])
            #expect(try ids(live.id) == [inLive.id])
            #expect(try db.read { try Queries.effectiveWing($0, ofPost: orphan.id) } == "")
            #expect(try db.read { try Queries.effectiveWing($0, ofPost: inLive.id) } == live.id)
        }
    }

    /// A note or book is born in a LIVE wing only.
    @Test func mintsRefuseADeadWing() throws {
        try withOperations { ops, _ in
            let wing = try ops.createWing(name: "Brief")
            try ops.deleteWing(wing.id)
            #expect(throws: OperationError.wingNotFound(id: wing.id)) {
                try ops.createPost(title: "x", wingId: wing.id)
            }
            #expect(throws: OperationError.wingNotFound(id: wing.id)) {
                try ops.createReading(name: "b", kind: .book, wingId: wing.id)
            }
        }
    }
}
