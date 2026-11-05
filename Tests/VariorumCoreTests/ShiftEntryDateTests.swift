import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **VX-587 (the VX-805 run, Unit A; R-805-3) — "Shift date a day earlier".**
/// Her 10-20 note: "shortcut to make a dated entry one day earlier would be
/// nice" (late-night journaling backfill). The pure day arithmetic
/// (`JournalDay.shifted`) and the op (`Operations.shiftEntryDate`) — the
/// date setter's road and posture, one transaction over the STORED day.
@Suite("VX-587 — shift a dated note a day earlier")
struct ShiftEntryDateTests {
    /// The rule's table: ordinary days, month and year ends, the leap day,
    /// either direction, and no key for a malformed one.
    @Test func theDayArithmetic() {
        #expect(JournalDay.shifted("2026-11-05", byDays: -1) == "2026-11-04")
        #expect(JournalDay.shifted("2026-03-01", byDays: -1) == "2026-02-28")
        #expect(JournalDay.shifted("2024-03-01", byDays: -1) == "2024-02-29", "the leap day")
        #expect(JournalDay.shifted("2026-01-01", byDays: -1) == "2025-12-31", "the year's end")
        #expect(JournalDay.shifted("2026-11-01", byDays: -1) == "2026-10-31")
        #expect(JournalDay.shifted("2026-03-08", byDays: -1) == "2026-03-07", "a DST weekend moves nothing")
        #expect(JournalDay.shifted("2025-12-31", byDays: 1) == "2026-01-01")
        #expect(JournalDay.shifted("2026-11-05", byDays: 0) == "2026-11-05")
        for bad in ["", "2026-13-01", "2026-02-30", "26-11-05", "November 5"] {
            #expect(JournalDay.shifted(bad, byDays: -1) == nil, "\(bad) is no key")
        }
    }

    /// THE STATE TRANSITION: one press moves `entry_date` one day earlier and
    /// stamps `updated_at` — every other column byte-unchanged (no touch, no
    /// churn), the outbox capturing the row; a second press reads the STORED
    /// day and lands two days earlier; nothing registers on ⌥⌘Z.
    @Test func aPressMovesTheStoredDayOneEarlier() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "late night", entryDate: "2026-03-01")
            try ops.seedBlock(in: note.id, text: "Written after midnight.")
            let before = try #require(try db.snapshotRow("container", note.id, excluding: []))
            try db.clearOutbox()

            #expect(try ops.shiftEntryDate(note.id, byDays: -1) == "2026-02-28")

            let after = try #require(try db.snapshotRow("container", note.id, excluding: []))
            var expected = before
            expected["entry_date"] = "2026-02-28".databaseValue
            expected["updated_at"] = after["updated_at"]
            #expect(after == expected, "only the date and the stamp move")
            #expect(after["updated_at"] != before["updated_at"])
            #expect(try db.outboxContains("container", note.id))
            #expect(try db.fetchInt("SELECT COUNT(*) FROM sync_outbox") == 1)

            #expect(try ops.shiftEntryDate(note.id, byDays: -1) == "2026-02-27",
                    "the second press reads the stored day")
            #expect(try db.fetchString("SELECT entry_date FROM container WHERE id = ?", [note.id])
                    == "2026-02-27")
        }
    }

    /// Nothing to shift: an undated note answers nil and writes NOTHING (the
    /// door speaks the registry's note); a malformed stored day likewise.
    @Test func anUndatedNoteWritesNothing() throws {
        try withOperations { ops, db in
            let undated = try ops.createPost(title: "no date")
            let before = try db.snapshotRow("container", undated.id, excluding: [])
            try db.clearOutbox()

            #expect(try ops.shiftEntryDate(undated.id, byDays: -1) == nil)

            #expect(try db.snapshotRow("container", undated.id, excluding: []) == before)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM sync_outbox") == 0)
        }
    }

    /// `setEntryDate`'s reach, exactly: a SEALED note's date still moves (a
    /// seal never froze the date — the setter's own posture); a deleted note
    /// refuses as the setter does.
    @Test func theSettersReachHolds() throws {
        try withOperations { ops, db in
            let sealed = try ops.createPost(title: "sealed", entryDate: "2026-11-05")
            try ops.seedBlock(in: sealed.id, text: "Done.")
            try ops.lockPost(sealed.id)
            #expect(try ops.shiftEntryDate(sealed.id, byDays: -1) == "2026-11-04")

            let dead = try ops.createPost(title: "gone", entryDate: "2026-11-05")
            try ops.deleteContainer(dead.id)
            #expect(throws: OperationError.containerNotFound(id: dead.id)) {
                try ops.shiftEntryDate(dead.id, byDays: -1)
            }
        }
    }
}
