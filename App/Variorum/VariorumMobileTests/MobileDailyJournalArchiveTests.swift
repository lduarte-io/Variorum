//
//  MobileDailyJournalArchiveTests.swift
//  VariorumMobileTests
//
//  13i-e U2 — the PHONE's daily-Journal doors (the sitting record §10; scope
//  item 3's letter: "every door that offers Delete on a book offers ARCHIVE
//  on the daily Journal instead", P-2). The two doors — the shelf row's
//  long-press and Book Details' act row — offer Archive on the marker-bearer
//  (the op guard's own predicate) and Delete everywhere else; the act lands
//  and names its road back, and Today's Entry IS that road on the phone.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import VariorumMobile

private enum JournalFixtureError: Error { case notShelved }

@MainActor
@Suite("13i-e U2 — the phone's daily Journal offers Archive in Delete's place")
struct MobileDailyJournalArchiveTests {
    @Test func theDailyJournalsDoorsArchiveAndTheDayBringsItBack() async throws {
        try await withEditorWorld { session, db in
            let (journal, plain) = try await session.runner.run { ops -> (String, String) in
                let entry = try ops.createPost(title: nil)
                guard case .shelved(let id) = ops.shelveInDailyJournalBook(entry.id) else {
                    throw JournalFixtureError.notShelved
                }
                return (id, try ops.createReading(name: "Plain", kind: .book).id)
            }
            let shelf = try await db.read { try Queries.bookshelf($0) }
            let journalBook = try #require(shelf.first { $0.reading.id == journal })
            let plainBook = try #require(shelf.first { $0.reading.id == plain })
            #expect(MobileShelfFaces.offersArchiveInsteadOfDelete(journalBook.reading))
            #expect(!MobileShelfFaces.offersArchiveInsteadOfDelete(plainBook.reading),
                    "an ordinary book keeps its Delete")

            // The shelf row's door: archive, a receipt naming the road back.
            let model = MobileShelfViewModel(session: session)
            await model.archiveDailyJournal(journalBook)
            #expect(try await db.read { try Queries.reading($0, id: journal) }?.archivedAt != nil)
            #expect(model.lastError == nil)
            #expect(model.lastReport == MobileShelfFaces.archivedDailyJournalReceipt(name: journalBook.reading.name))
            #expect(try await db.read { try Queries.bookshelf($0) }.allSatisfy { $0.reading.id != journal },
                    "archived: off the shelf")

            // Today's Entry is the road back — the SAME book, live again.
            _ = await model.openToday(day: "2026-10-04")
            #expect(try await db.read { try Queries.reading($0, id: journal) }?.archivedAt == nil)

            // Book Details' door: the same act, and it reports it went.
            let details = MobileBookDetailsModel(session: session, readingID: journal)
            #expect(await details.archiveDailyJournal())
            #expect(try await db.read { try Queries.reading($0, id: journal) }?.archivedAt != nil)
            // A second press refuses in the shared table's words, never a raw enum.
            #expect(await details.archiveDailyJournal() == false)
            #expect(details.lastError == "That book is already archived \u{2014} nothing changed.")

            // The delete road's own table speaks the guard's sentence.
            #expect(DeletionRefusal.words(OperationError.dailyJournalCannotBeDeleted(id: journal))
                    == BookArchiveCopy.cannotDeleteDailyJournal)
        }
    }
}
