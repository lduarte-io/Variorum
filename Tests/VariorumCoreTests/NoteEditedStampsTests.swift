import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// VX-1084 (the VX-1036 run, batch 3 — the book's List mode): many notes'
/// EDITED stamps in one read, the Library row's own stamp — so a note's last
/// edit reads the same in the Library and in a book.
@Suite("VX-1084 — many notes' edited stamps, one read")
struct NoteEditedStampsTests {
    @Test func eachNoteReadsItsOwnLastEditAndTheMintBeforeAnyEdit() throws {
        try withOperations { ops, db in
            let typed = try ops.createPost(title: "typed in")
            let block = try ops.newBlock(in: typed.id, text: "one")
            try ops.autosave(block.variant.id, text: "one two", charDelta: 4)
            let untouched = try ops.createPost(title: "never typed in")
            let stamps = try db.read {
                try Queries.noteEditedStamps($0, noteIDs: [typed.id, untouched.id])
            }
            // The Library's own COALESCE: the last touch, else the mint.
            let rows = try db.read { db in
                try Row.fetchAll(db, sql: """
                    SELECT id, COALESCE(last_touched_at, created_at) AS stamp
                    FROM container WHERE id IN (?, ?)
                    """, arguments: [typed.id, untouched.id])
            }
            #expect(rows.count == 2)
            for row in rows {
                #expect(stamps[row["id"] as String] == row["stamp"] as String?, "\(row)")
            }
            #expect(stamps.count == 2)
        }
    }

    @Test func aGoneNoteAndAnUnknownIdAreAbsentAndNothingAskedReadsNothing() throws {
        try withOperations { ops, db in
            let kept = try ops.createPost(title: "kept")
            let gone = try ops.createPost(title: "gone")
            try ops.deleteContainer(gone.id)
            let stamps = try db.read {
                try Queries.noteEditedStamps($0, noteIDs: [kept.id, gone.id, "no-such-note"])
            }
            #expect(Set(stamps.keys) == [kept.id], "only the live note answers")
            #expect(try db.read { try Queries.noteEditedStamps($0, noteIDs: []) }.isEmpty)
        }
    }
}
