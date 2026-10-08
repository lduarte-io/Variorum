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

    /// RED-ON-OLD — a seeded book arrived and was deleted; the first
    /// write's occasion declines it. **JUSTIFIED VEHICLE EDIT (13s-b U1b):**
    /// the pin rode *Encryption Explained*, which left the phone's default
    /// seed at R-13s-5/37 — the SUBJECT (the tombstone honoured through the
    /// one shared brain) is unchanged and now rides SHERLOCK, the remaining
    /// first-write book, through the same `seedIfNeeded` road.
    @Test func aDeletedSeededBookIsNotReMintedByTheFirstWrite() async throws {
        try await withEditorWorld { session, db in
            // Both session leaves injected — a headless run never writes the
            // test host's defaults (RUN A A2 row 8's rule).
            session.seededBookMarkIsSet = { _ in false }
            session.markSeededBook = { _ in }
            let book = SampleLibrarySeeder.Book.sherlock

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
                    loadSample: { mark.value },
                    saveSample: { mark.value = $0 }))
            guard case .ran(_, let sample) = await furniture.run() else {
                Issue.record("expected the occasion to run")
                return
            }

            #expect(sample == .deletedByTheReader, "\(String(describing: sample))")
            let name = book.name
            let live = try await db.read { db in
                try Queries.readings(db).filter { $0.name == name }.count
            }
            #expect(live == 0, "the reader's deletion stands")
            #expect(mark.value, "and is recorded on this device")
        }
    }
}
