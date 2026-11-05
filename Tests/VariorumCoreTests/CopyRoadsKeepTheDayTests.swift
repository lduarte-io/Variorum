import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **VX-845 (the VX-805 run, Unit A) — P-771-1's keep-the-day rule reaches
/// every copy road but the saved version.** Her ruling 2026-11-04 (the VX-771
/// handoff walkthrough, QUESTIONS #258 F-1(c) — "EXTEND to all three"): the
/// rule (`Domain/DuplicateDay` — an undated, untitled, non-journal source's
/// copy takes the source's CREATION DAY as `entry_date`) extends to promote
/// (lens → note), diverge-for-reading, and the ownership forks. Option (c)'s
/// own words in the VX-771 record: "extend it to every `copyPost` road but the
/// saved version (promote, diverge, the ownership forks too)" — so the reach
/// is the two remaining bodies' every caller:
///
/// - PROMOTE: `promoteLens` and `promotePicks` (the record groups them —
///   A-771-1's `promoteLens`/`promotePicks`);
/// - DIVERGE: `divergePostForReading`;
/// - THE OWNERSHIP FORKS: `ceremonyCopy` (the record's
///   `Operations+Ownership.swift:88`) — the copy every ownership ceremony
///   mints: the Own conversion's fork-in-place, the seal's (the same
///   `forkSharedMembers` step), COPY IN, the deep duplicate, the bind's
///   copy-in limb — both its `copyPost` path and its BARE path (an empty
///   note). MOVE IN mints no copy ("where applicable").
///
/// THE MECHANISM (traced, pre-fix): each road called `copyPost(…)` with
/// `keepingNamedDay` defaulted `false` (or, for `ceremonyCopy`'s bare path, a
/// `Container(…, entryDate: source.entryDate …)` literal), so the copy stored
/// the source's nil `entry_date` and `DisplayTitle.note` named it for the
/// COPY's own birth day — the field report's re-dating class, on these roads.
///
/// The residuals hold on every road (ruled the same day): a TYPED-titled
/// undated source's copy stays undated; a dated source's copy keeps its date;
/// an undated JOURNAL-profile source's copy stays undated (the notebook rule).
/// The saved version stays date-cleared (V3 — untouched).
@Suite("VX-845 — every copy road but the saved version keeps the day")
struct CopyRoadsKeepTheDayTests {
    static let bornOn = DuplicateKeepsItsDayTests.bornOn  // 2026-06-20T12:00:00Z

    /// Every copy road VX-845 reaches, each building its own fixture around
    /// the given source and answering the copy's id.
    enum Road: String, CaseIterable, CustomTestStringConvertible {
        case promoteLens, promotePicks, diverge
        case ownFork, sealFork, copyIn, deepDuplicate, bindCopyIn

        var testDescription: String { rawValue }

        func copy(_ ops: Operations, of sourceID: String) throws -> String {
            switch self {
            case .promoteLens:
                let lens = try ops.createLens(post: sourceID, name: "lens")
                return try ops.promoteLens(lens.id).post.id
            case .promotePicks:
                return try ops.promotePicks(post: sourceID, picks: [:]).post.id
            case .diverge:
                let book = try ops.createReading(name: "book", kind: .book)
                try ops.addPostToReading(sourceID, to: book.id)
                return try ops.divergePostForReading(sourceID, in: book.id).copy.post.id
            case .ownFork:
                let owning = try ops.createReading(name: "owning", kind: .book)
                let elsewhere = try ops.createReading(name: "elsewhere", kind: .book)
                try ops.addPostToReading(sourceID, to: owning.id)
                try ops.addPostToReading(sourceID, to: elsewhere.id)
                return try #require(try ops.setReadingOwned(owning.id, owned: true).copied.first).copyID
            case .sealFork:
                let sealing = try ops.createReading(name: "sealing", kind: .book)
                let elsewhere = try ops.createReading(name: "elsewhere", kind: .book)
                try ops.addPostToReading(sourceID, to: sealing.id)
                try ops.addPostToReading(sourceID, to: elsewhere.id)
                return try #require(try ops.sealReading(sealing.id).forked.first).copyID
            case .copyIn:
                let book = try ops.createReading(name: "book", kind: .book)
                return try ops.copyPostIntoReading(sourceID, into: book.id).copy.id
            case .deepDuplicate:
                let book = try ops.createReading(name: "book", kind: .book)
                try ops.addPostToReading(sourceID, to: book.id)
                return try #require(
                    try ops.duplicateReading(book.id, name: "copy", deep: true).copied.first).copyID
            case .bindCopyIn:
                // One tag per call (a test may copy several sources).
                let tag = try ops.createTag(name: "t\(sourceID.suffix(12))")
                let gathering = try ops.createReading(
                    name: "g", kind: .gathering,
                    querySpec: try #require(try RuleGrammar.encode(.tag(tag.id))))
                let owned = try ops.createReading(name: "owned", kind: .book)
                try ops.setReadingOwned(owned.id, owned: true)
                try ops.addPostToReading(sourceID, to: owned.id)
                _ = try ops.applyTag(tag.id, toPost: sourceID)
                return try #require(try ops.convertSmartReadingToCurated(
                    gathering.id, ownedNotes: .copyIn).copied.first).copyID
            }
        }
    }

    private func backdate(_ db: AppDatabase, _ postID: String) throws {
        try db.write { db in
            try db.execute(
                sql: "UPDATE container SET created_at = ? WHERE id = ?",
                arguments: [DateFormatter.variorumISO8601.string(from: Self.bornOn), postID])
        }
    }

    private func row(_ db: AppDatabase, _ id: String) throws -> Container {
        try #require(try db.read { try Container.fetchOne($0, key: id) })
    }

    private func name(_ post: Container) -> String {
        DisplayTitle.note(
            title: post.title, entryDate: post.entryDate,
            createdAt: DateFormatter.variorumISO8601.string(from: post.createdAt),
            calendar: JournalDay.storeCalendar)
    }

    private var day: String { JournalDay.dayString(from: Self.bornOn, calendar: JournalDay.storeCalendar) }

    /// THE CLASS on every road — RED ON OLD (each road stored NULL and named
    /// the copy for the harness day, 2026-07-01, not the source's 2026-06-20):
    /// the copy keeps the day its undated, untitled source is named for; its
    /// own birth stays its own; the source is never touched.
    @Test(arguments: Road.allCases)
    func anUndatedUntitledNotesCopyKeepsTheDay(_ road: Road) throws {
        try withOperations { ops, db in
            let source = try ops.createPost(title: nil)
            try ops.seedBlock(in: source.id, text: "Morning pages.")
            try backdate(db, source.id)
            let stored = try row(db, source.id)
            #expect(name(stored) == day, "the premise: the source is named for its birth day")

            let copy = try row(db, try road.copy(ops, of: source.id))

            #expect(copy.entryDate == day, "the copy keeps the day its source is named for")
            #expect(name(copy) == name(stored), "so it is NAMED as its source is")
            #expect(copy.title == nil, "no title is materialized")
            #expect(copy.createdAt > stored.createdAt, "its own birth is its own — never forged")
            #expect(try row(db, source.id).entryDate == nil, "the source is never touched")
        }
    }

    /// THE BARE PATH of the ownership forks: an EMPTY undated, untitled note's
    /// ceremony copy (no copyable block — a bare row) keeps the day too. RED
    /// ON OLD: the bare row's literal carried the source's nil.
    @Test(arguments: [Road.copyIn, .ownFork, .sealFork, .deepDuplicate])
    func anEmptyNotesBareCeremonyCopyKeepsTheDay(_ road: Road) throws {
        try withOperations { ops, db in
            let source = try ops.createPost(title: nil)
            try backdate(db, source.id)

            let copy = try row(db, try road.copy(ops, of: source.id))

            #expect(copy.entryDate == day)
            #expect(name(copy) == name(try row(db, source.id)))
        }
    }

    /// The residuals, on every road (byte-verbatim, as before): a TYPED-titled
    /// undated source's copy stays undated (ruled — no invented dates); a
    /// DATED source's copy keeps its date; an undated JOURNAL-profile source's
    /// copy stays undated, so no copy claims a notebook day.
    @Test(arguments: Road.allCases)
    func theResidualsHoldOnEveryRoad(_ road: Road) throws {
        try withOperations { ops, db in
            let titled = try ops.createPost(title: "the essay", profile: .blog)
            try ops.seedBlock(in: titled.id, text: "Titled.")
            let dated = try ops.createPost(title: nil, entryDate: "2026-05-05")
            try ops.seedBlock(in: dated.id, text: "Dated.")
            let journal = try ops.createPost(title: nil, profile: .journal)
            try ops.seedBlock(in: journal.id, text: "Dear diary.")
            for id in [titled.id, dated.id, journal.id] { try backdate(db, id) }

            let titledCopy = try row(db, try road.copy(ops, of: titled.id))
            #expect(titledCopy.entryDate == nil && titledCopy.title == "the essay",
                    "a typed-titled undated source's copy stays undated")
            #expect(try row(db, try road.copy(ops, of: dated.id)).entryDate == "2026-05-05",
                    "a dated source's copy keeps its date")
            let journalCopy = try row(db, try road.copy(ops, of: journal.id))
            #expect(journalCopy.entryDate == nil && journalCopy.profile == .journal,
                    "an undated journal entry's copy claims no notebook day")
            #expect(try db.read { try Queries.canonicalJournalEntry($0, day: day) } == nil)
        }
    }

    /// The edge her ruling KEPT: a saved version stays date-cleared (V3) — the
    /// class's version is born undated, whatever the copy roads now do.
    @Test func theSavedVersionStaysDateCleared() throws {
        try withOperations { ops, db in
            let source = try ops.createPost(title: nil)
            try ops.seedBlock(in: source.id, text: "Morning pages.")
            try backdate(db, source.id)
            let dated = try ops.createPost(title: nil, entryDate: "2026-05-05")
            try ops.seedBlock(in: dated.id, text: "Dated.")

            #expect(try row(db, try ops.saveNoteVersion(source.id).post.id).entryDate == nil)
            #expect(try row(db, try ops.saveNoteVersion(dated.id).post.id).entryDate == nil,
                    "V3 clears even a dated source's version")
        }
    }
}
