import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **VX-826 (the VX-809 run, batch 1 — her R-826: "a date-titled note's copy
/// reads the SOURCE's displayed title, never today's"; A-809-10, PROVISIONAL
/// P-809-7): THE JOURNAL CLASS, the remainder VX-759 left.**
///
/// The trace (the run record's BATCH 1 RECORD, VX-826): a note's name is
/// `DisplayTitle.note` — the title, else `entry_date`, else the day of
/// `created_at`; a copy is born today. VX-759's `DuplicateDay` gave an undated,
/// untitled copy its source's creation day — EXCEPT a journal-profile source
/// (every ⌘J entry), kept undated, so such an entry with its date cleared
/// duplicated as TODAY. A-809-10: `DuplicateDay` extends to that class (the one
/// ratified mechanism; `DisplayTitle` stays a display rule, no title written).
///
/// The body is shared: her Duplicate with Tags / without Tags (`duplicateAsVersion`
/// → `duplicateAsVersionBody` → `copyPost(keepingNamedDay:)`) and her Copy to
/// Wing (`copyNoteToWing`, both mint paths). The wire never reaches this class:
/// `profile = 'journal'` is a fence leg, and `duplicate_note` / `copy_note_to_wing`
/// refuse a fenced source in their one sentence.
///
/// **RED ON OLD** (run on `1805c2d50`'s tree, before the fix): each class pin's
/// copy stored `entry_date` NULL and was named for the harness day, not its
/// source's "2026-06-20". The residual guards are green on both sides by design:
/// a TYPED-titled undated source's copy stays undated (her ruled residual), a
/// DATED journal entry's copy keeps its date verbatim, and a saved VERSION stays
/// date-cleared (V3) — the seam VX-845 shares, pinned byte-for-byte here.
@Suite("VX-826 — a date-titled journal entry's copy reads its source's title, never today's")
struct DuplicateDateTitleTests {
    static let bornOn = DuplicateKeepsItsDayTests.bornOn  // 2026-06-20T12:00:00Z

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

    /// A ⌘J entry whose date she cleared: journal profile, no title, no date —
    /// named for the day it was born.
    private func clearedEntry(_ ops: Operations, _ db: AppDatabase, wingID: String = "", text: String? = "Dear diary.")
        throws -> Container {
        let source = try ops.createPost(title: nil, profile: .journal, wingId: wingID)
        if let text { _ = try ops.newBlock(in: source.id, text: text, registeringUndo: false) }
        try backdate(db, source.id)
        let stored = try row(db, source.id)
        #expect(stored.entryDate == nil && stored.title == nil && stored.profile == .journal)
        #expect(name(stored) == day, "the premise: the entry is named for its birth day")
        return stored
    }

    // MARK: - THE CLASS — red on old

    @Test(arguments: Operations.DuplicateTags.allCases)
    func herDuplicateDoorsNameTheCopyAsTheSourceIsNamed(_ tags: Operations.DuplicateTags) throws {
        try withOperations { ops, db in
            let source = try clearedEntry(ops, db)

            let copy = try row(db, try ops.duplicateAsVersion(source.id, tags: tags).post.id)

            #expect(name(copy) == name(source), "never today's: \(name(copy)) vs \(name(source))")
            #expect(copy.entryDate == day && copy.title == nil, "the day, as an entry_date — no title written")
            #expect(copy.profile == .journal, "the profile rides verbatim (the copy stays fenced)")
            #expect(copy.createdAt > source.createdAt, "its own birth is its own — never forged")
        }
    }

    @Test func herCopyToWingNamesTheCopyAsTheSourceIsNamed() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "elsewhere")
            let source = try clearedEntry(ops, db)

            let copy = try row(db, try ops.copyNoteToWing(source.id, to: wing.id).id)

            #expect(copy.wingId == wing.id && name(copy) == name(source), "\(name(copy))")
            #expect(copy.entryDate == day && copy.title == nil)
        }
    }

    @Test func herCopyToWingOfAnEmptyEntryNamesTheBareCopyAsTheSourceIsNamed() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "elsewhere")
            let source = try clearedEntry(ops, db, text: nil)

            let copy = try row(db, try ops.copyNoteToWing(source.id, to: wing.id).id)

            #expect(name(copy) == name(source) && copy.entryDate == day, "\(name(copy))")
        }
    }

    // MARK: - The residuals — byte-verbatim, green on both sides (the VX-845 seam)

    /// Her ruled residual (QUESTIONS #258's P-771-1 disposition): a TYPED-titled
    /// undated source's copy stays undated — a journal-profile one too.
    @Test(arguments: [Profile.journal, Profile.generic])
    func aTypedTitledUndatedSourcesCopyStaysUndated(_ profile: Profile) throws {
        try withOperations { ops, db in
            let source = try ops.createPost(title: "the morning", profile: profile)
            _ = try ops.newBlock(in: source.id, text: "Words.", registeringUndo: false)
            try backdate(db, source.id)

            let copy = try row(db, try ops.duplicateAsVersion(source.id).post.id)

            #expect(copy.entryDate == nil && copy.title == "the morning" && copy.profile == profile)
        }
    }

    /// A DATED journal entry's copy keeps its date verbatim (it always did).
    @Test func aDatedJournalEntrysCopyKeepsItsDateVerbatim() throws {
        try withOperations { ops, db in
            let source = try ops.createPost(title: nil, profile: .journal, entryDate: "2026-05-05")
            _ = try ops.newBlock(in: source.id, text: "Dated.", registeringUndo: false)
            try backdate(db, source.id)

            let copy = try row(db, try ops.duplicateAsVersion(source.id).post.id)

            #expect(copy.entryDate == "2026-05-05" && copy.title == nil)
        }
    }

    /// A saved VERSION stays date-cleared (V3 — `mintNoteVersion`), the class's
    /// source included: the version road is not a duplicate road.
    @Test func aSavedVersionOfTheClassStaysDateCleared() throws {
        try withOperations { ops, db in
            let source = try clearedEntry(ops, db)

            let version = try row(db, try ops.saveNoteVersion(source.id).post.id)

            #expect(version.entryDate == nil, "V3: a version claims no day")
        }
    }
}
