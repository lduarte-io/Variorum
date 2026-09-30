//
//  MobileFirstWriteTombstoneTests.swift
//  VariorumMobileTests
//
//  18o U2 — KnownIssues row 66, RULED R-18k-5 (*honour the tombstone at
//  launch*), on the PHONE. The phone seeds its sample books at the first
//  WRITE rather than at launch (R-pre13u-1), but through the SAME brain —
//  `SampleLibrarySeeder.seedIfNeeded` ("same brain, two occasions", the
//  seeder's header) — so the ruled rule reaches this occasion by
//  construction. This pins that it does: a store holding a seeded book the
//  reader DELETED, with no mark on this device, is not re-minted by the
//  first-write occasion, and the decision is recorded in the book's mark.
//
//  *Red on the old code:* the occasion re-minted the book (`.seeded`).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import VariorumMobile

@MainActor
private final class BookMark {
    var value = false
}

@MainActor
@Suite("18o U2 — row 66: the phone's first-write occasion honours a seeded book's tombstone")
struct MobileFirstWriteTombstoneTests {

    /// RED-ON-OLD — *Encryption Explained* arrived and was deleted; the
    /// first write's occasion declines it (Sherlock's and the Jekyll book's
    /// marks read "already seeded", so their parses never run).
    @Test func aDeletedSeededBookIsNotReMintedByTheFirstWrite() async throws {
        try await withEditorWorld { session, db in
            // Both session leaves injected — a headless run never writes the
            // test host's defaults (RUN A A2 row 8's rule).
            session.seededBookMarkIsSet = { _ in false }
            session.markSeededBook = { _ in }
            let book = SampleLibrarySeeder.Book.encryptionExplained

            // The book ARRIVED (the seeder's own mint, no mark written) and
            // the reader then deleted it.
            let stories = try SampleLibrarySeeder.loadStories(for: book)
            let existing = try await db.read { db in
                try SampleLibrarySeeder.discover(db, book: book)
            }
            let seeded = try await SampleLibrarySeeder.seed(
                session: session, book: book, stories: stories, existing: existing)
            let readingID = seeded.readingID
            try await session.runner.run { ops in try ops.deleteReading(readingID) }

            let mark = BookMark()
            let furniture = MobileFirstWriteFurniture(
                session: session, storeVariant: .dev,
                marks: .init(
                    loadJournal: { true }, saveJournal: { _ in },
                    loadSample: { true }, saveSample: { _ in },
                    loadEncryptionBook: { mark.value },
                    saveEncryptionBook: { mark.value = $0 }))
            _ = await furniture.run()

            #expect(furniture.encryptionBookOutcome == .deletedByTheReader,
                    "\(String(describing: furniture.encryptionBookOutcome))")
            let name = book.name
            let live = try await db.read { db in
                try Queries.readings(db).filter { $0.name == name }.count
            }
            #expect(live == 0, "the reader's deletion stands")
            #expect(mark.value, "and is recorded on this device")
        }
    }
}
