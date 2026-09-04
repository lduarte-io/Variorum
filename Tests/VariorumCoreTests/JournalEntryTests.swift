import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 8, Step 3's core half: the user-set calendar day (`JournalDay`),
/// the notebook rule (`createOrOpenJournalEntry`), and the journal-profile
/// library listing the entry list rides.
@Suite("Journal day & the notebook rule (Phase 8, Step 3)")
struct JournalEntryTests {
    // MARK: - JournalDay (pure Domain)

    @Test func dayStringIsZeroPaddedInTheGivenCalendar() throws {
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!
        // 2026-07-07T23:30:00Z
        let lateEvening = Date(timeIntervalSince1970: 1_783_467_000)
        #expect(JournalDay.dayString(from: lateEvening, calendar: utc) == "2026-07-07")

        // The same instant is already the 8th in Tokyo — the USER'S calendar
        // decides the day, not UTC.
        var tokyo = Calendar(identifier: .gregorian)
        tokyo.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        #expect(JournalDay.dayString(from: lateEvening, calendar: tokyo) == "2026-07-08")

        // Zero padding keeps lexicographic == chronological.
        // 2026-01-05T12:00:00Z
        let january = Date(timeIntervalSince1970: 1_767_614_400)
        #expect(JournalDay.dayString(from: january, calendar: utc) == "2026-01-05")
    }

    @Test func isValidAcceptsRealDaysAndRefusesTheRest() {
        #expect(JournalDay.isValid("2026-07-07"))
        #expect(JournalDay.isValid("1999-12-31"))
        #expect(JournalDay.isValid("2028-02-29"))   // leap day
        #expect(!JournalDay.isValid("2026-02-30"))  // not a real day
        #expect(!JournalDay.isValid("2026-13-01"))  // no month 13
        #expect(!JournalDay.isValid("2026-7-7"))    // unpadded
        #expect(!JournalDay.isValid("07-07-2026"))  // wrong order
        #expect(!JournalDay.isValid("2026/07/07"))  // wrong separator
        #expect(!JournalDay.isValid("tomorrow"))
        #expect(!JournalDay.isValid(""))
        #expect(!JournalDay.isValid("2026-07-07T00:00:00Z"))  // a timestamp, not a day
    }

    // MARK: - setEntryDate day-key validation (Phase 9b, Step 6 — closes
    // the KnownIssues row; red-on-old: the pre-9b op accepted any string)

    @Test func setEntryDateRefusesMalformedDayKeys() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .journal, entryDate: "2026-07-09")
            for bad in ["2026-7-9", "2026/07/09", "2026-02-30", "tomorrow", ""] {
                #expect(throws: OperationError.invalidEntryDate(bad)) {
                    try ops.setEntryDate(post.id, entryDate: bad)
                }
            }
            // Nothing moved: the entry keeps its canonical day.
            #expect(try db.fetchString(
                "SELECT entry_date FROM container WHERE id = ?", [post.id]) == "2026-07-09")
        }
    }

    /// Round-2 pin (MINOR 2; red on pre-fix code): `createPost` was the
    /// REMAINING permissive door after Step 6 — a malformed key minted a
    /// live entry invisible to its own day.
    @Test func createPostRefusesMalformedDayKeysToo() throws {
        try withOperations { ops, db in
            for bad in ["2026-7-9", "2026/07/09", "2026-02-30", "yesterday", ""] {
                #expect(throws: OperationError.invalidEntryDate(bad)) {
                    try ops.createPost(profile: .journal, entryDate: bad)
                }
            }
            #expect(try db.fetchInt("SELECT COUNT(*) FROM container") == 0)
            // Canonical and nil stay legitimate (nil = an undated post).
            _ = try ops.createPost(profile: .journal, entryDate: "2026-07-09")
            _ = try ops.createPost(title: "undated")
            #expect(try db.fetchInt("SELECT COUNT(*) FROM container") == 2)
        }
    }

    @Test func setEntryDateAllowsCanonicalKeysAndNil() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .journal, entryDate: "2026-07-09")
            try ops.setEntryDate(post.id, entryDate: "2027-01-31")
            #expect(try db.fetchString(
                "SELECT entry_date FROM container WHERE id = ?", [post.id]) == "2027-01-31")
            // Un-dating stays legitimate (generic post metadata).
            try ops.setEntryDate(post.id, entryDate: nil)
            #expect(try db.fetchString(
                "SELECT entry_date FROM container WHERE id = ?", [post.id]) == nil)
        }
    }

    /// The mobile date picker formats through `JournalDay.dayString`
    /// (EntryEditorView / EntryListViewModel) — verified by TEST, not
    /// assumption (the plan's Step 6): every dayString output passes the
    /// validation gate, across paddings, year edges, leap days, and
    /// non-UTC calendars.
    @Test func dayStringOutputAlwaysPassesTheValidationGate() {
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!
        var tokyo = Calendar(identifier: .gregorian)
        tokyo.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        let moments: [TimeInterval] = [
            1_782_864_000,  // 2026-07-01
            1_767_614_400,  // 2026-01-05 (padded month/day)
            1_735_689_540,  // 2024-12-31 23:59 UTC (year edge)
            1_836_518_400,  // 2028-02-29 (leap day)
            0,              // 1970-01-01
        ]
        for calendar in [utc, tokyo] {
            for moment in moments {
                let day = JournalDay.dayString(from: Date(timeIntervalSince1970: moment), calendar: calendar)
                #expect(JournalDay.isValid(day), "\(day) must pass the ops boundary")
            }
        }
    }

    // MARK: - createOrOpenJournalEntry (the notebook rule)

    @Test func createsAJournalEntryWithTheExactRowSet() throws {
        try withOperations { ops, db in
            let result = try ops.createOrOpenJournalEntry(entryDate: "2026-07-07")
            #expect(result.created)
            let entry = result.container
            #expect(entry.kind == .post)
            #expect(entry.profile == .journal)
            #expect(entry.entryDate == "2026-07-07")
            #expect(entry.segmentationDefault == .oneBlock,
                    "the journal profile seeds one-block segmentation (AppSpec §7)")
            // Exactly one container row, nothing else minted.
            #expect(try db.fetchInt("SELECT COUNT(*) FROM container") == 1)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM block") == 0)
        }
    }

    @Test func opensTheExistingLiveEntryForThatDay() throws {
        try withOperations { ops, db in
            let first = try ops.createOrOpenJournalEntry(entryDate: "2026-07-07")
            let second = try ops.createOrOpenJournalEntry(entryDate: "2026-07-07")
            #expect(!second.created, "the notebook rule: one entry per calendar day")
            #expect(second.container.id == first.container.id)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM container") == 1)

            // A different day is a different page.
            let other = try ops.createOrOpenJournalEntry(entryDate: "2026-07-08")
            #expect(other.created)
        }
    }

    @Test func aConvergedDoubleCreateOpensTheEarliestDeterministically() throws {
        try withOperations { ops, db in
            // Two live same-day entries (the offline double-create after
            // convergence — legal by design; no unique index exists).
            let earlier = try ops.createPost(title: "phone", profile: .journal, entryDate: "2026-07-07")
            _ = try ops.createPost(title: "mac", profile: .journal, entryDate: "2026-07-07")
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM container WHERE entry_date = '2026-07-07'") == 2)

            let opened = try ops.createOrOpenJournalEntry(entryDate: "2026-07-07")
            #expect(!opened.created)
            #expect(opened.container.id == earlier.id,
                    "earliest (created_at, id) opens — deterministic on every device")
        }
    }

    @Test func tombstonedAndForeignProfileRowsNeverSatisfyTheRule() throws {
        try withOperations { ops, _ in
            // A deleted journal entry on the date does not block a fresh one.
            let dead = try ops.createOrOpenJournalEntry(entryDate: "2026-07-07").container
            try ops.deleteContainer(dead.id)
            let fresh = try ops.createOrOpenJournalEntry(entryDate: "2026-07-07")
            #expect(fresh.created, "a tombstoned entry is gone; the day page is blank again")
            #expect(fresh.container.id != dead.id)

            // A same-day BLOG post is not a journal page.
            _ = try ops.createPost(title: "essay", profile: .blog, entryDate: "2026-07-08")
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-08")
            #expect(entry.created)
        }
    }

    @Test func anArchivedEntryOpensRatherThanMintingADuplicate() throws {
        try withOperations { ops, _ in
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-07").container
            try ops.archiveContainer(entry.id)
            let reopened = try ops.createOrOpenJournalEntry(entryDate: "2026-07-07")
            #expect(!reopened.created,
                    "archive is kept-out-of-view, not gone — opening beats a same-day duplicate")
            #expect(reopened.container.id == entry.id)
        }
    }

    // MARK: - The journal-profile library listing (Step 4's query)

    @Test func libraryFiltersByProfileAndSortsByEntryDate() throws {
        try withOperations { ops, db in
            _ = try ops.createPost(title: "an essay", profile: .blog, entryDate: "2026-07-09")
            _ = try ops.createOrOpenJournalEntry(entryDate: "2026-07-06")
            _ = try ops.createOrOpenJournalEntry(entryDate: "2026-07-08")
            _ = try ops.createOrOpenJournalEntry(entryDate: "2026-07-07")

            let journal = try db.read {
                try Queries.library(
                    $0, sort: .entryDate, direction: .desc, limit: 50, profile: .journal)
            }
            #expect(journal.map(\.entryDate) == ["2026-07-08", "2026-07-07", "2026-07-06"],
                    "journal entries only, newest day first")

            let everything = try db.read {
                try Queries.library($0, sort: .entryDate, direction: .desc, limit: 50)
            }
            #expect(everything.count == 4, "no profile filter = the whole library")
        }
    }
}

// MARK: - Review round 1 (MINOR): live entries outrank archived siblings

@Suite("Notebook rule: live-over-archived (Phase 8, review round 1)")
struct JournalEntryArchivedSiblingTests {
    /// THE PIN: after a converged double-create where the author archived
    /// the EARLIER entry, "Today" must open the entry the day's page shows
    /// — never the list-invisible archived sibling (pre-fix: plain
    /// `(created_at, id)` order returned the archived one).
    @Test func aLiveEntryOutranksAnEarlierArchivedSibling() throws {
        try withOperations { ops, _ in
            let earlier = try ops.createPost(
                title: "phone half", profile: .journal, entryDate: "2026-07-07")
            let later = try ops.createPost(
                title: "desk half", profile: .journal, entryDate: "2026-07-07")
            try ops.archiveContainer(earlier.id)

            let opened = try ops.createOrOpenJournalEntry(entryDate: "2026-07-07")
            #expect(!opened.created)
            #expect(opened.container.id == later.id,
                    "the live sibling opens — the archived one is out of view")

            // Archived-only days still open their archived entry (the
            // original interpretation, unchanged).
            try ops.archiveContainer(later.id)
            let bothArchived = try ops.createOrOpenJournalEntry(entryDate: "2026-07-07")
            #expect(!bothArchived.created)
            #expect(bothArchived.container.id == earlier.id,
                    "all-archived falls back to earliest — deterministic everywhere")
        }
    }
}

// MARK: - Review round 2 (MINOR): the day-key boundary

@Suite("Notebook rule: day-key well-formedness (Phase 8, review round 2)")
struct JournalEntryDayKeyTests {
    /// THE PIN: a malformed day key ("2026-7-7") must refuse at the
    /// operations boundary — accepted, it would mint a live entry invisible
    /// to the canonical "2026-07-07" (two irreconcilable same-day pages,
    /// broken lexicographic ordering), and this op is the door EXTERNAL day
    /// keys arrive through (the phone's capture; the retired Phase 9b bridge).
    @Test func aMalformedDayKeyRefusesAtTheOperationsBoundary() throws {
        try withOperations { ops, db in
            for bad in ["2026-7-7", "07-07-2026", "2026/07/07", "2026-02-30", "today", ""] {
                #expect(throws: OperationError.invalidEntryDate(bad)) {
                    try ops.createOrOpenJournalEntry(entryDate: bad)
                }
            }
            #expect(try db.fetchInt("SELECT COUNT(*) FROM container") == 0,
                    "nothing minted for any malformed key")

            // The canonical key still works, and the malformed near-miss
            // could never have shadowed it.
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-07")
            #expect(entry.created)
        }
    }
}
