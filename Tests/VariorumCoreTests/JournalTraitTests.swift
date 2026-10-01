import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

// 13i-a — the journal-trait setter (sitting record §10's ruling: the trait
// is a per-book settings row; the op lands here, the Collecting-pane face
// is 13i-e's) and the 'daily' marker's constitutive refusal (PROVISIONAL,
// the 13i-a plan §9).
@Suite("The journal trait setter (13i-a — sitting record §10)")
struct JournalTraitTests {
    @Test func theTraitFlipsBetweenJournalAndBook() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "field notes", kind: .book)
            try ops.setJournalTrait(book.id, on: true)
            #expect(try db.read { try Queries.reading($0, id: book.id) }?.profile == "journal")
            try ops.setJournalTrait(book.id, on: false)
            #expect(try db.read { try Queries.reading($0, id: book.id) }?.profile == "book")
        }
    }

    @Test func theDailyBookRefusesTheToggleItsMarkerIsConstitutive() throws {
        try withOperations { ops, db in
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-09-30")
            guard case .shelved(let dailyID) = ops.shelveInDailyJournalBook(entry.container.id)
            else { Issue.record("the daily mint did not shelve"); return }
            #expect(throws: OperationError.dailyJournalTraitIsConstitutive(id: dailyID)) {
                try ops.setJournalTrait(dailyID, on: false)
            }
            #expect(throws: OperationError.dailyJournalTraitIsConstitutive(id: dailyID)) {
                try ops.setJournalTrait(dailyID, on: true)
            }
            #expect(try db.read { try Queries.reading($0, id: dailyID) }?.profile == "daily",
                    "the marker never moves")
        }
    }

    @Test func aFinishedBookRefusesAndANoOpWritesNothing() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "done", kind: .book, profile: "journal")
            try ops.lockReading(book.id)
            #expect(throws: OperationError.lockedReading(id: book.id)) {
                try ops.setJournalTrait(book.id, on: false)
            }
            try ops.unlockReading(book.id)
            try db.clearOutbox()
            try ops.setJournalTrait(book.id, on: true)  // already the trait
            #expect(try db.outboxContains("reading", book.id) == false,
                    "a no-op writes nothing — the identity-metadata convention")
        }
    }
}
