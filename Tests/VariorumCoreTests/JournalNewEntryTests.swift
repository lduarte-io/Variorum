import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **VX-797 — the VX-805 run, Unit C** (her 2026-11-04 ruling, written on the
/// ticket: "⌘J keeps open-today and opens the day's FIRST entry; the
/// deliberate new-note doors in the Journal (New Entry, ⌥⌘N in the focused
/// book) mint a fresh entry dated today; … several entries per day are
/// legal").
///
/// The record: `notes/plans/fixes/vx-805-journal-cluster.md` §5 (Unit C, and
/// the cross-run seam above it — "scope 'the day's first entry' to the
/// Journal's MEMBERS"), PROVISIONALs P-805-C1..C3.

// MARK: - Fixture helpers

/// ⌘J's composite exactly (`JournalBooks.openToday`'s two halves): the day's
/// entry, opened or minted, then the one shelving road.
private func pressCommandJ(
    _ ops: Operations, day: String, standingWing: String = ""
) throws -> (entry: Operations.JournalEntryResult, shelving: Operations.DailyBookShelving) {
    let entry = try ops.createOrOpenJournalEntry(entryDate: day, standingWing: standingWing)
    return (entry, ops.shelveInDailyJournalBook(entry.container.id))
}

private func journalID(_ db: AppDatabase) throws -> String {
    try #require(try db.read { try Queries.dailyJournalBookID($0) })
}

private func liveMember(_ db: AppDatabase, _ postID: String, of readingID: String) throws -> Bool {
    try db.fetchInt(
        """
        SELECT COUNT(*) FROM reading_post
        WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL AND status = 'member'
        """, [readingID, postID]) == 1
}

/// Every `reading_post` row for the pair — live, arrival or tombstoned.
private func pairRows(_ db: AppDatabase, _ postID: String, _ readingID: String) throws -> Int {
    try db.fetchInt(
        "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND post_id = ?",
        [readingID, postID]) ?? -1
}

private func liveNoteCount(_ db: AppDatabase) throws -> Int {
    try db.fetchInt(
        "SELECT COUNT(*) FROM container WHERE kind = 'post' AND deleted_at IS NULL") ?? -1
}

// MARK: - ⌘J: the day's FIRST entry is the Journal's (the lookup)

@Suite("VX-797 — ⌘J opens the day's first entry: the Journal's members first")
struct JournalDaysFirstEntryTests {
    /// THE CROSS-RUN SEAM (vx-809, 2026-11-05): a day-dated journal-shaped
    /// note may be a COPY, not an entry. A bookless day-shaped note made
    /// BEFORE the day's filed entry must never be "the day's": ⌘J opens the
    /// Journal's member, and the shelving never files the stranger.
    /// RED ON OLD: the notebook shape alone answered — the earlier bookless
    /// note opened, and ⌘J FILED it into the Journal.
    @Test func aBooklessDayShapedNoteNeverOutranksTheJournalsMember() throws {
        try withOperations { ops, db in
            let day = "2026-11-05"
            let stranger = try ops.createPost(title: "day-shaped", profile: .journal, entryDate: day)
            let entry = try ops.createPost(profile: .journal, entryDate: day)
            guard case .shelved(let journal) = ops.shelveInDailyJournalBook(entry.id) else {
                Issue.record("the fixture files its entry")
                return
            }

            let pressed = try pressCommandJ(ops, day: day)
            #expect(!pressed.entry.created)
            #expect(pressed.entry.container.id == entry.id,
                    "the day's first entry is the Journal's member, never an earlier stranger")
            #expect(pressed.shelving == .alreadyDecided)
            #expect(try pairRows(db, stranger.id, journal) == 0,
                    "the stranger is never filed into the Journal")
        }
    }

    /// The realistic shape of the seam: she ARCHIVED the day's entry and
    /// DUPLICATED it — the copy wears the entry's day and profile verbatim
    /// and lands bookless (the Journal has no rule). ⌘J opens HER entry (the
    /// day's only member, archived — "an archived entry still opens when it
    /// is all the day has"), and the copy stays bookless. RED ON OLD: the
    /// live-over-archived tier picked the bookless COPY and ⌘J filed it.
    @Test func aDuplicateOfAnArchivedEntryIsNeverTheDay() throws {
        try withOperations { ops, db in
            let day = "2026-11-05"
            let first = try pressCommandJ(ops, day: day)
            let entry = first.entry.container
            let journal = try journalID(db)
            try ops.seedBlock(in: entry.id, text: "the morning")
            try ops.archiveContainer(entry.id)
            let copy = try ops.duplicateAsVersion(entry.id).post
            // The premise, spelled: the copy wears the day shape.
            #expect(copy.profile == .journal && copy.entryDate == day)
            #expect(try pairRows(db, copy.id, journal) == 0, "the copy lands bookless")

            let pressed = try pressCommandJ(ops, day: day)
            #expect(!pressed.entry.created)
            #expect(pressed.entry.container.id == entry.id,
                    "her archived entry is the day's — the copy is not an entry")
            #expect(pressed.shelving == .alreadyDecided)
            #expect(try pairRows(db, copy.id, journal) == 0, "the copy is never filed")
        }
    }

    /// The pair-decided law, beside several entries a day: she takes the
    /// day's FIRST entry off the Journal — ⌘J then opens the next MEMBER and
    /// never re-files the one she removed. Only when she has removed every
    /// member does the notebook shape answer again (the removed entry opens,
    /// still un-filed — `openTodayNeverReShelvesAnEntryTheAuthorRemoved`'s
    /// precedent, held). RED ON OLD: the first ⌘J after the removal opened
    /// the REMOVED entry (the earliest day shape).
    @Test func removingTheFirstEntryOpensTheNextMemberAndNeverRefilesIt() throws {
        try withOperations { ops, db in
            let day = "2026-11-05"
            let first = try pressCommandJ(ops, day: day).entry.container
            let journal = try journalID(db)
            // A second entry the same day, filed (a New Entry's shape).
            let second = try ops.createPost(profile: .journal, entryDate: day)
            try ops.addPostToReading(second.id, to: journal)

            _ = try ops.removePostFromReading(first.id, from: journal)
            let pressed = try pressCommandJ(ops, day: day)
            #expect(!pressed.entry.created)
            #expect(pressed.entry.container.id == second.id,
                    "the day's first remaining MEMBER opens")
            #expect(pressed.shelving == .alreadyDecided)
            #expect(try !liveMember(db, first.id, of: journal))
            #expect(try pairRows(db, first.id, journal) == 1,
                    "her removal stands: one tombstoned row, nothing minted beside it")

            // Every member removed: the notebook shape answers (the earliest),
            // and the pair stays decided.
            _ = try ops.removePostFromReading(second.id, from: journal)
            let last = try pressCommandJ(ops, day: day)
            #expect(!last.entry.created && last.entry.container.id == first.id)
            #expect(last.shelving == .alreadyDecided)
            #expect(try !liveMember(db, first.id, of: journal))
            #expect(try pairRows(db, first.id, journal) == 1)
        }
    }

    /// The order among the Journal's members (P-805-C1): earliest
    /// `(created_at, id)` with the notebook rule's live-over-archived tier
    /// kept — "Today must open the entry the day's page shows". A GUARD
    /// (green on both sides: the two members are also the only day shapes).
    @Test func theDaysFirstMemberIsTheEarliestCreatedUnarchivedFirst() throws {
        try withOperations { ops, db in
            let day = "2026-11-05"
            let first = try pressCommandJ(ops, day: day).entry.container
            let journal = try journalID(db)
            let second = try ops.createPost(profile: .journal, entryDate: day)
            try ops.addPostToReading(second.id, to: journal)

            #expect(try pressCommandJ(ops, day: day).entry.container.id == first.id,
                    "the earliest-created member")
            try ops.archiveContainer(first.id)
            #expect(try pressCommandJ(ops, day: day).entry.container.id == second.id,
                    "an archived first entry yields to the live one the day's page shows")
            try ops.archiveContainer(second.id)
            #expect(try pressCommandJ(ops, day: day).entry.container.id == first.id,
                    "all archived: the earliest again")
            #expect(try liveNoteCount(db) == 2, "⌘J minted nothing")
        }
    }

    /// The notebook shape stays the fallback (P-805-C1's conflicting
    /// precedents): a day whose entry could not be filed — the Journal
    /// finished — re-opens THAT entry on every press (never a stray Pool
    /// entry per press, the bounded-notebook doctrine), and once the Journal
    /// reopens the next press files it (the shelving's repair). A GUARD.
    @Test func aDayTheJournalCouldNotTakeStillOpensItsOneEntry() throws {
        try withOperations { ops, db in
            _ = try pressCommandJ(ops, day: "2026-11-04")
            let journal = try journalID(db)
            try ops.lockReading(journal)

            let first = try pressCommandJ(ops, day: "2026-11-05")
            #expect(first.entry.created && first.shelving == .bookFinished)
            let again = try pressCommandJ(ops, day: "2026-11-05")
            #expect(!again.entry.created && again.entry.container.id == first.entry.container.id,
                    "the same entry — no stray per press")
            #expect(again.shelving == .bookFinished)

            try ops.unlockReading(journal)
            let healed = try pressCommandJ(ops, day: "2026-11-05")
            #expect(healed.entry.container.id == first.entry.container.id)
            #expect(healed.shelving == .shelved(readingID: journal), "the repair files it")
        }
    }
}

// MARK: - The Journal's New Entry: a fresh entry, every press (the mint)

/// The outbox as a set of `(table, row)` pairs — the exact write set a test
/// pins after `clearOutbox()`.
private func outboxSet(_ db: AppDatabase) throws -> Set<String> {
    try db.read { db in
        Set(try Row.fetchAll(db, sql: "SELECT table_name, row_id FROM sync_outbox")
            .map { "\($0["table_name"] as String):\($0["row_id"] as String)" })
    }
}

@Suite("VX-797 — the Journal's New Entry mints a fresh entry, filed through ⌘J's own gate")
struct JournalNewEntryMintTests {
    /// THE RULING'S CORE: New Entry twice in one day → two live entries, both
    /// the Journal's members, each a fresh row in the day shape; ⌘J then opens
    /// the day's FIRST (the earliest-created — here ⌘J's own). The exact
    /// state transition of one press: the entry row and its membership, at
    /// the end, unsectioned — nothing else written. RED ON OLD by
    /// construction (no such op; the daily book's door was create-or-open).
    @Test func mintingTwiceInOneDayMakesTwoLiveMembersAndCommandJOpensTheFirst() throws {
        try withOperations { ops, db in
            let day = "2026-11-05"
            let opened = try pressCommandJ(ops, day: day).entry.container
            let journal = try journalID(db)
            try db.clearOutbox()

            let one = try ops.newJournalEntry(entryDate: day)
            #expect(one.shelving == .shelved(readingID: journal))
            let entry = one.container
            #expect(entry.id != opened.id, "a FRESH entry — never the day's existing one")
            #expect(entry.kind == .post && entry.profile == .journal && entry.entryDate == day)
            #expect(entry.title == nil && entry.segmentationDefault == nil && entry.wingId == "")
            let membership = try #require(try db.read { db in
                try ReadingPost.fetchOne(
                    db, sql: "SELECT * FROM reading_post WHERE reading_id = ? AND post_id = ?",
                    arguments: [journal, entry.id])
            })
            #expect(membership.status == .member && membership.sectionId == nil
                    && membership.deletedAt == nil)
            let openedPosition = try #require(try db.fetchString(
                "SELECT position FROM reading_post WHERE reading_id = ? AND post_id = ?",
                [journal, opened.id]))
            #expect(membership.position > openedPosition, "filed at the end")
            #expect(try outboxSet(db) == ["container:\(entry.id)", "reading_post:\(membership.id)"],
                    "the press writes the entry and its membership — nothing else")
            #expect(try db.fetchInt("SELECT COUNT(*) FROM block") == 0, "no block minted")

            let two = try ops.newJournalEntry(entryDate: day)
            #expect(two.shelving == .shelved(readingID: journal))
            #expect(Set([opened.id, entry.id, two.container.id]).count == 3)
            for id in [opened.id, entry.id, two.container.id] {
                #expect(try liveMember(db, id, of: journal))
            }

            let again = try pressCommandJ(ops, day: day)
            #expect(!again.entry.created && again.entry.container.id == opened.id,
                    "⌘J opens the day's first entry")
            #expect(again.shelving == .alreadyDecided)
            #expect(try liveNoteCount(db) == 3, "⌘J minted nothing")

            // A day with no entry yet: New Entry is that day's first — and
            // ⌘J then opens it.
            let fresh = try ops.newJournalEntry(entryDate: "2026-11-06")
            #expect(try pressCommandJ(ops, day: "2026-11-06").entry.container.id
                    == fresh.container.id)
        }
    }

    /// The pair-decided law, UNCHANGED: a member she took off the Journal is
    /// never re-filed by a New Entry (the mint files only its own fresh row),
    /// and ⌘J then opens the fresh member, not the one she removed.
    @Test func aRemovedMemberIsNeverRefiledByAMint() throws {
        try withOperations { ops, db in
            let day = "2026-11-05"
            let removed = try pressCommandJ(ops, day: day).entry.container
            let journal = try journalID(db)
            _ = try ops.removePostFromReading(removed.id, from: journal)

            let made = try ops.newJournalEntry(entryDate: day)
            #expect(made.shelving == .shelved(readingID: journal))
            #expect(try liveMember(db, made.container.id, of: journal))
            #expect(try !liveMember(db, removed.id, of: journal))
            #expect(try pairRows(db, removed.id, journal) == 1, "her removal stands — one tombstone")
            let pressed = try pressCommandJ(ops, day: day)
            #expect(pressed.entry.container.id == made.container.id,
                    "⌘J opens the day's first MEMBER")
            #expect(try pairRows(db, removed.id, journal) == 1)
        }
    }

    /// REFUSE BEFORE MINT (P-805-C2): a finished, sealed or full Journal
    /// refuses New Entry with its add refusal and mints NOTHING — never a
    /// stray Pool entry per press. RED ON OLD by construction.
    @Test func aJournalThatCannotTakeANoteRefusesBeforeTheMint() throws {
        try withOperations { ops, db in
            let day = "2026-11-05"
            _ = try pressCommandJ(ops, day: day)
            let journal = try journalID(db)
            let before = try liveNoteCount(db)

            try ops.lockReading(journal)
            #expect(throws: OperationError.lockedReading(id: journal)) {
                try ops.newJournalEntry(entryDate: day)
            }
            #expect(try liveNoteCount(db) == before, "finished: nothing minted")
            try ops.unlockReading(journal)

            try ops.setReadingMaxPosts(journal, maxPosts: 1)
            #expect(throws: OperationError.readingAtCapacity(id: journal)) {
                try ops.newJournalEntry(entryDate: day)
            }
            #expect(try liveNoteCount(db) == before, "full: nothing minted")
            try ops.setReadingMaxPosts(journal, maxPosts: nil)

            _ = try ops.sealReading(journal)
            #expect(throws: OperationError.lockedReading(id: journal)) {
                try ops.newJournalEntry(entryDate: day)
            }
            #expect(try liveNoteCount(db) == before, "sealed: nothing minted")

            #expect(throws: OperationError.invalidEntryDate("2026-11-5")) {
                try ops.newJournalEntry(entryDate: "2026-11-5")
            }
            #expect(try liveNoteCount(db) == before, "a malformed day mints nothing")
        }
    }

    /// The SAME gate as ⌘J (P-805-C3): an ARCHIVED Journal comes back for a
    /// New Entry, exactly as when a day arrives, and the fresh entry files.
    @Test func anArchivedJournalComesBackForANewEntry() throws {
        try withOperations { ops, db in
            let day = "2026-11-05"
            _ = try pressCommandJ(ops, day: day)
            let journal = try journalID(db)
            try ops.archiveReading(journal)

            let made = try ops.newJournalEntry(entryDate: day)
            #expect(made.shelving == .shelved(readingID: journal))
            #expect(try db.fetchString("SELECT archived_at FROM reading WHERE id = ?", [journal]) == nil,
                    "the Journal is back")
            #expect(try liveMember(db, made.container.id, of: journal))
        }
    }

    /// Beside the Journal (P-805-B6, Unit B's wing scoping): with the Journal
    /// moved to another wing the fresh entry is born THERE whatever wing she
    /// stands in, and files; with no Journal living the entry is born where
    /// she stands and ⌘J's ensure mints the Journal beside it.
    @Test func theFreshEntryIsBornBesideTheJournal() throws {
        try withOperations { ops, db in
            let day = "2026-11-05"
            let studio = try ops.createWing(name: "Studio")
            _ = try pressCommandJ(ops, day: day)
            let journal = try journalID(db)
            _ = try ops.moveReadingToWing(journal, to: studio.id)

            let made = try ops.newJournalEntry(entryDate: day, standingWing: "")
            #expect(made.container.wingId == studio.id, "born in the Journal's wing")
            #expect(made.shelving == .shelved(readingID: journal))

            try ops.deleteReading(journal)
            let attic = try ops.createWing(name: "Attic")
            let first = try ops.newJournalEntry(entryDate: day, standingWing: attic.id)
            #expect(first.container.wingId == attic.id, "no Journal: where she stands")
            guard case .shelved(let fresh) = first.shelving else {
                Issue.record("the ensure mints a Journal and files the entry")
                return
            }
            #expect(fresh != journal)
            #expect(try db.read { try Queries.reading($0, id: fresh) }?.wingId == attic.id)
        }
    }
}
