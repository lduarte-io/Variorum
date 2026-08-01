import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 13g, batch 7 — her ruling R6-3: an untitled note shows its DATE,
/// everywhere, **including on export** (her refinement: *"someone might be
/// frustrated exporting a note with a date they see as a title and then
/// their exported note says 'Untitled'"*).
///
/// The date is never written into `container.title`; this whole suite is
/// about a projection.
@Suite("The display title (13g batch 7 — R6-3)")
struct DisplayTitleTests {
    /// The fixture clock's first instant (`withOperations`). Tests derive
    /// their expected day from it THROUGH `JournalDay`, never as a literal:
    /// the fallback is a LOCAL calendar day, so a literal would pass only in
    /// the timezone it was written in.
    private static let fixtureStart = Date(timeIntervalSince1970: 1_782_864_000)
    private static var fixtureDay: String { JournalDay.dayString(from: fixtureStart) }

    // MARK: - The pure brain

    @Test func aStoredTitleWinsAndIsReturnedEXACTLYAsStored() {
        #expect(DisplayTitle.note(
            title: "Real name", entryDate: "2026-07-04", createdAt: nil) == "Real name")
        // Not trimmed: the trim is only ever the absence test.
        #expect(DisplayTitle.note(
            title: "  spaced  ", entryDate: nil, createdAt: nil) == "  spaced  ")
    }

    /// **The load-bearing half of `isAbsent`** — the literal placeholder is
    /// no title. Until this batch ⌘N stored the literal string "Untitled",
    /// so a rule keyed on nil/empty alone would have fixed none of the notes
    /// already in her library.
    ///
    /// DISCRIMINATING REVERT (verified): drop `|| trimmed == placeholder`
    /// from `DisplayTitle.isAbsent` and this test fails on its third and
    /// fourth expectations while every other expectation in the suite holds.
    @Test func theLiteralUntitledCountsAsNoTitleAndSoDoBlanks() {
        #expect(DisplayTitle.isAbsent(nil))
        #expect(DisplayTitle.isAbsent(""))
        #expect(DisplayTitle.isAbsent("   \n "))
        #expect(DisplayTitle.isAbsent("Untitled"))
        #expect(DisplayTitle.isAbsent("  Untitled  "))
        #expect(!DisplayTitle.isAbsent("Untitled thoughts"))
        #expect(!DisplayTitle.isAbsent("untitled"))  // case matters: not the placeholder
        #expect(DisplayTitle.note(
            title: "Untitled", entryDate: "2026-07-04", createdAt: nil) == "2026-07-04")
    }

    @Test func theDateChainIsEntryDateThenTheDayItWasWritten() {
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!
        let stamp = "2026-07-09T13:00:00.000Z"

        // entry_date outranks created_at: what she SAID the note's date is.
        #expect(DisplayTitle.note(
            title: nil, entryDate: "2026-07-04", createdAt: stamp,
            calendar: utc) == "2026-07-04")
        // …and with no entry date, the day it was written.
        #expect(DisplayTitle.note(
            title: nil, entryDate: nil, createdAt: stamp, calendar: utc) == "2026-07-09")
        // An empty entry date is no date, not an empty name.
        #expect(DisplayTitle.note(
            title: "", entryDate: "", createdAt: stamp, calendar: utc) == "2026-07-09")
        // Nothing at all: the placeholder still exists, and is still right.
        #expect(DisplayTitle.note(
            title: nil, entryDate: nil, createdAt: nil) == "Untitled")
    }

    /// The created day is the LOCAL calendar day, for the reason the doc
    /// comment gives: `entry_date` is a local day by construction
    /// (`JournalDay.dayString` over `Calendar.current`), so a UTC-sliced
    /// fallback beside it would mean a different KIND of day in the same
    /// slot.
    @Test func theWrittenDayIsTheUSERSCalendarDayNotAUTCSlice() {
        var tokyo = Calendar(identifier: .gregorian)
        tokyo.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        var newYork = Calendar(identifier: .gregorian)
        newYork.timeZone = TimeZone(identifier: "America/New_York")!
        // 2026-07-09T23:30:00Z — already the 10th in Tokyo, still the 9th
        // in New York. A `substr(created_at, 1, 10)` would say "2026-07-09"
        // to both.
        let lateEvening = "2026-07-09T23:30:00.000Z"
        #expect(DisplayTitle.note(
            title: nil, entryDate: nil, createdAt: lateEvening,
            calendar: tokyo) == "2026-07-10")
        #expect(DisplayTitle.note(
            title: nil, entryDate: nil, createdAt: lateEvening,
            calendar: newYork) == "2026-07-09")
    }

    @Test func anUnparseableStampReadsAsNoDayRatherThanAGuess() {
        #expect(DisplayTitle.day(fromStamp: nil) == nil)
        #expect(DisplayTitle.day(fromStamp: "") == nil)
        #expect(DisplayTitle.day(fromStamp: "2026-07-09") == nil)  // a day, not a stamp
        #expect(DisplayTitle.day(fromStamp: "nonsense") == nil)
        #expect(DisplayTitle.note(
            title: nil, entryDate: nil, createdAt: "nonsense") == "Untitled")
    }

    // MARK: - The wire: one note, through the store

    /// DISCRIMINATING REVERT (verified): drop the `createdAt:` argument from
    /// `Queries.noteDisplayTitle`'s call into the brain and the third
    /// expectation fails with "Untitled" — the very word her ruling retires.
    @Test func oneNotesDisplayTitleComesFromTheStoreThroughTheOneBrain() throws {
        try withOperations { ops, db in
            let named = try ops.createPost(title: "Real name")
            let dated = try ops.createPost(title: nil, entryDate: "2026-07-04")
            let bare = try ops.createPost(title: nil)
            // The pre-13g mint's literal, still sitting in her store:
            let legacy = try ops.createPost(title: "Untitled")

            let names = try db.read { database in
                try [named.id, dated.id, bare.id, legacy.id, "nope"].map {
                    try Queries.noteDisplayTitle(database, id: $0)
                }
            }
            #expect(names[0] == "Real name")
            #expect(names[1] == "2026-07-04")
            #expect(names[2] == Self.fixtureDay)
            #expect(names[3] == Self.fixtureDay)
            // A row that isn't there has no name — the caller's own per-kind
            // fallback still owns that case.
            #expect(names[4] == nil)
        }
    }

    // MARK: - The listings

    @Test func aListingRowNamesItselfWithoutEachSurfaceReDecidingIt() throws {
        try withOperations { ops, db in
            let bare = try ops.createPost(title: nil)
            let legacy = try ops.createPost(title: "Untitled")
            let named = try ops.createPost(title: "Kept")

            let library = try db.read { try Queries.library($0) }
            let byID = Dictionary(
                uniqueKeysWithValues: library.map { ($0.postID, $0.displayTitle) })
            #expect(byID[bare.id] == Self.fixtureDay)
            #expect(byID[legacy.id] == Self.fixtureDay)
            #expect(byID[named.id] == "Kept")

            // The ⌘K catalog builds its hit name eagerly through the same
            // brain (its row-set is bounded per kind).
            let hits = try db.read { try Queries.searchCatalog($0, query: "") }
            let hitTitles = Dictionary(
                hits.filter { $0.kind == .post }.map { ($0.id, $0.title) },
                uniquingKeysWith: { first, _ in first })
            #expect(hitTitles[bare.id] == Self.fixtureDay)
            #expect(hitTitles[legacy.id] == Self.fixtureDay)
        }
    }

    @Test func aBooksEntryNamesItselfTheSameWay() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "Shelf", kind: .curated)
            let bare = try ops.createPost(title: nil)
            try ops.addPostToReading(bare.id, to: book.id)

            let entries = try db.read { try Queries.assembleReading($0, readingID: book.id) }
            #expect(entries.count == 1)
            #expect(entries[0].displayTitle == Self.fixtureDay)
        }
    }

    // MARK: - Export (her refinement — the same answer, on the page)

    /// DISCRIMINATING REVERT (verified): put `Export`'s retired private
    /// `displayTitle(_:entryDate:)` back in front of the heading and the
    /// first expectation fails — the exported note is headed "Untitled".
    @Test func aReadingExportHeadsAnUntitledNoteWithItsDateNotWithUntitled() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "Shelf", kind: .curated)
            let bare = try ops.createPost(title: nil)
            try ops.newBlock(in: bare.id, text: "Body of the bare note.")
            try ops.addPostToReading(bare.id, to: book.id)

            let markdown = try db.read { try Queries.exportReading($0, readingID: book.id) }
            #expect(markdown.contains("## \(Self.fixtureDay)"))
            #expect(!markdown.contains("Untitled"))
            // The BODY is byte-untouched — a title has never been content.
            #expect(markdown.contains("Body of the bare note."))
            let body = try db.read { try Queries.exportPost($0, postID: bare.id) }
            #expect(body == "Body of the bare note.")
        }
    }

    /// The 11b filename shape VERIFIED rather than assumed (the brief's own
    /// instruction): an untitled note has been named by its date alone since
    /// 11b, so the ratified convention already complied. What this batch
    /// changes is exactly one thing — the pre-13g literal "Untitled" now
    /// counts as no title, so those notes join the same shape.
    @Test func theBulkManifestNamesAnUntitledNoteByItsDateAlone() throws {
        try withOperations { ops, db in
            let legacy = try ops.createPost(title: "Untitled", entryDate: "2026-07-11")
            try ops.newBlock(in: legacy.id, text: "Legacy body.")
            let named = try ops.createPost(title: "Kept", entryDate: "2026-07-10")
            try ops.newBlock(in: named.id, text: "Kept body.")

            let manifest = try db.read {
                try Queries.bulkExportManifest($0, includeReadings: false)
            }
            let paths = manifest.map(\.relativePath)
            #expect(paths.contains("2026-07-11.md"))
            #expect(paths.contains("2026-07-10 Kept.md"))
            #expect(!paths.contains { $0.contains("Untitled") })
        }
    }
}
