import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **VX-759 (the VX-771 run, batch 1 — PROVISIONAL P-771-1): A DUPLICATE OF AN
/// UNDATED, UNTITLED NOTE KEEPS THE DAY IT IS NAMED FOR.**
///
/// The trace (the run record's BATCH 1 RECORD): a note with no typed title and
/// no `entry_date` is NAMED by its birth day at read (`DisplayTitle.note` —
/// the title, else `entry_date`, else the day of `created_at`). `copyPost`
/// copied `title`, `profile` and `entry_date` verbatim — nil, nil — and stamped
/// the copy's own `created_at`, so every copy was named for the day it was MADE:
/// the field report's 28 copies of "2026-10-20"-style notes all read the day
/// they were duplicated, and sank under an entry-date sort.
///
/// P-771-1: such a source's copy takes the source's CREATION DAY as its
/// `entry_date` (the store's day calendar), so it is named and sorted as its
/// source is — while its own `created_at` stays its honest birth (never
/// forged). A DATED or TYPED-TITLED source's copy is byte-verbatim as before,
/// and an undated JOURNAL-profile source's copy stays undated (the notebook
/// rule keys on `profile = 'journal' AND entry_date` — a copy never claims a
/// notebook day its source did not, `mintNoteVersion`'s V3 reason).
///
/// The body is SHARED (AppSpec §9): her Duplicate with Tags / without Tags and
/// the wire's `duplicate_note` run `duplicateAsVersionBody`, so one pin set
/// covers both doors here and `MCPDuplicateDatingServerTests` covers the wire.
///
/// **RED ON OLD** (run on the pre-fix tree, before the fix was written): the
/// undated class's copy stored `entry_date` NULL and was named for the harness
/// day (2026-07-01 local), not its source's "2026-06-20".
@Suite("VX-759 — a duplicate keeps the day its undated source is named for")
struct DuplicateKeepsItsDayTests {
    /// Midday UTC, so the source's LOCAL day is the 20th in any zone within
    /// ±11 h — and the harness's own clock (2026-07-01) is a different day in
    /// every zone.
    static let bornOn = Date(timeIntervalSince1970: 1_781_956_800)  // 2026-06-20T12:00:00Z

    private func backdate(_ db: AppDatabase, _ postID: String, to date: Date = bornOn) throws {
        try db.write { db in
            try db.execute(
                sql: "UPDATE container SET created_at = ? WHERE id = ?",
                arguments: [DateFormatter.variorumISO8601.string(from: date), postID])
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

    /// THE CLASS: no title, no date. The copy is named — and dated — as its
    /// source is, by both of her doors; its own birth stays its own.
    @Test(arguments: Operations.DuplicateTags.allCases)
    func anUndatedUntitledNotesCopyKeepsTheDayItIsNamedFor(_ tags: Operations.DuplicateTags) throws {
        try withOperations { ops, db in
            let source = try ops.createPost(title: nil)
            _ = try ops.newBlock(in: source.id, text: "Morning pages.", registeringUndo: false)
            try backdate(db, source.id)
            let stored = try row(db, source.id)
            let day = JournalDay.dayString(from: Self.bornOn, calendar: JournalDay.storeCalendar)
            #expect(name(stored) == day, "the premise: the source is named for its birth day")
            #expect(stored.entryDate == nil && stored.title == nil)

            let copy = try row(db, try ops.duplicateAsVersion(source.id, tags: tags).post.id)

            #expect(copy.entryDate == day, "the copy keeps the day its source is named for")
            #expect(name(copy) == name(stored), "so it is NAMED as its source is")
            #expect(copy.title == nil, "the name is still derived — no title is materialized")
            #expect(copy.createdAt > stored.createdAt, "its own birth is its own — never forged")
            #expect(try row(db, source.id).entryDate == nil, "the source is never touched")
        }
    }

    /// A blank-but-present title and an EMPTY `entry_date` are absent too —
    /// the display rule's own absence tests (`isAbsent`; an empty day).
    @Test func aBlankTitleAndAnEmptyDateAreTheClassToo() throws {
        try withOperations { ops, db in
            let source = try ops.createPost(title: "   ")
            _ = try ops.newBlock(in: source.id, text: "Blank.", registeringUndo: false)
            try backdate(db, source.id)
            try db.write { db in
                try db.execute(sql: "UPDATE container SET entry_date = '' WHERE id = ?", arguments: [source.id])
            }
            let day = JournalDay.dayString(from: Self.bornOn, calendar: JournalDay.storeCalendar)

            let copy = try row(db, try ops.duplicateAsVersion(source.id).post.id)

            #expect(copy.entryDate == day)
            #expect(copy.title == "   ", "the title is copied verbatim as ever")
            #expect(name(copy) == name(try row(db, source.id)))
        }
    }

    /// NOT the class: a DATED note's copy keeps its date verbatim (it always
    /// did — pinned so P-771-1 can never reach it).
    @Test func aDatedNotesCopyKeepsItsDateVerbatim() throws {
        try withOperations { ops, db in
            let source = try ops.createPost(title: nil, entryDate: "2026-05-05")
            _ = try ops.newBlock(in: source.id, text: "Dated.", registeringUndo: false)
            try backdate(db, source.id)

            let copy = try row(db, try ops.duplicateAsVersion(source.id).post.id)

            #expect(copy.entryDate == "2026-05-05", "verbatim, never the creation day")
            #expect(copy.title == nil)
            #expect(name(copy) == "2026-05-05")
        }
    }

    /// NOT the class: a TYPED-TITLED undated note's copy stays undated —
    /// byte-verbatim (its name is its title, already faithful).
    @Test func aTitledUndatedNotesCopyStaysUndated() throws {
        try withOperations { ops, db in
            let source = try ops.createPost(title: "the essay", profile: .blog)
            _ = try ops.newBlock(in: source.id, text: "Titled.", registeringUndo: false)
            try backdate(db, source.id)

            let copy = try row(db, try ops.duplicateAsVersion(source.id).post.id)

            #expect(copy.entryDate == nil, "no date is invented for a titled note")
            #expect(copy.title == "the essay" && copy.profile == .blog)
        }
    }

    /// The pure rule's table (`DuplicateDay`) — every arm, one calendar.
    @Test func theRulesTable() {
        let born = Self.bornOn
        let calendar = JournalDay.storeCalendar
        let day = JournalDay.dayString(from: born, calendar: calendar)
        func rule(_ title: String?, _ date: String?, _ profile: Profile?) -> String? {
            DuplicateDay.entryDate(title: title, entryDate: date, profile: profile, createdAt: born, calendar: calendar)
        }
        #expect(rule(nil, nil, nil) == day)
        #expect(rule(nil, nil, .blog) == day)
        #expect(rule("", "", .generic) == day)
        #expect(rule(" \n", nil, .bookChapter) == day)
        #expect(rule(nil, "2026-01-02", nil) == "2026-01-02")
        #expect(rule("named", nil, nil) == nil)
        #expect(rule("named", "2026-01-02", nil) == "2026-01-02")
        #expect(rule(nil, nil, .journal) == nil)
        #expect(rule(nil, "2026-01-02", .journal) == "2026-01-02")
    }

    /// NOT the class: an undated JOURNAL-profile note's copy stays undated —
    /// a copy never claims a notebook day (`canonicalJournalEntry` keys on
    /// `profile = 'journal' AND entry_date`), V3's reason. Born the same day as
    /// the copy, so a dated copy WOULD have become that day's entry.
    @Test func anUndatedJournalEntrysCopyStaysUndatedSoTheNotebookRuleHearsNothing() throws {
        try withOperations { ops, db in
            let source = try ops.createPost(title: nil, profile: .journal)
            _ = try ops.newBlock(in: source.id, text: "Dear diary.", registeringUndo: false)
            let day = JournalDay.dayString(from: try row(db, source.id).createdAt, calendar: JournalDay.storeCalendar)

            let copy = try row(db, try ops.duplicateAsVersion(source.id).post.id)

            #expect(copy.entryDate == nil && copy.profile == .journal)
            #expect(try db.read { try Queries.canonicalJournalEntry($0, day: day) } == nil,
                    "no live journal entry claims the day")
        }
    }
}
