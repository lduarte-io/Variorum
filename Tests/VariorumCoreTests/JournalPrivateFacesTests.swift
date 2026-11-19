import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// **VX-1007 — the daily Journal shows as Private wherever Private is shown**
/// (the VX-981 run, BATCH 1; her report 2026-11-18: "the journal does not wear
/// the private eye icon & it doesn't show with "private" ticked in its book
/// settings"; her ruling: "I honestly think it always being private is good. I
/// don't want to change it for now. It should just show as ticked and locked in
/// the immediate sense also.").
///
/// The fence has three legs in ONE derivation site (`Queries.mcpNoteFacts` /
/// `mcpBookFacts`): a note's own day-entry shape (`profile = 'journal'`), a live
/// membership in a live reading wearing THE daily Journal's marker, and the
/// Private mark. The faces' facts (`Queries.privateMarks` /
/// `privateBookMarks`) read the Private leg only, so the Journal and its
/// entries wore no eye. These pins read the faces' facts against the fence's
/// own answers. Bug-class pins are RED on the scaffold commit (the new fields
/// declared, the old reads kept); the GUARD pins say so in their names' docs.
@Suite("VX-1007 — the faces' Journal facts: the fence's own legs, leg by leg")
struct JournalPrivateFacesTests {
    private func marks(_ db: AppDatabase, _ ids: [String]) throws -> [String: Queries.PrivateMark] {
        try db.read { try Queries.privateMarks($0, noteIDs: ids) }
    }

    private func bookMarks(_ db: AppDatabase, _ ids: [String]) throws -> [String: Queries.PrivateBookMark] {
        try db.read { try Queries.privateBookMarks($0, readingIDs: ids) }
    }

    // MARK: - The daily Journal's own book mark

    /// RED on old: THE daily Journal — the book ⌘J files into — wears the
    /// book mark (its fence's book leg), with no stamp of its own.
    @Test func theDailyJournalWearsTheBookMark() throws {
        try withOperations { ops, db in
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-01").container
            guard case .shelved(let journalID) = ops.shelveInDailyJournalBook(entry.id) else {
                Issue.record("the daily door did not file the entry")
                return
            }
            let plain = try ops.createReading(name: "plain", kind: .book)
            let read = try bookMarks(db, [journalID, plain.id])
            #expect(read[journalID] == Queries.PrivateBookMark(own: false, dailyJournal: true),
                    "THE daily Journal wears the mark — derived, nothing stamped")
            #expect(read[plain.id] == nil, "a plain book wears none")
            #expect(try db.read { try Queries.isBookPrivate($0, readingID: journalID) } == false,
                    "no write: the Journal's own stamp stays unset")
        }
    }

    /// RED on old: an ARCHIVED daily Journal is alive, so it still fences —
    /// and still wears the mark.
    @Test func anArchivedDailyJournalStillWearsIt() throws {
        try withOperations { ops, db in
            let journal = try ops.createReading(name: "Journal", kind: .book, profile: "daily")
            try ops.archiveReading(journal.id)
            #expect(try bookMarks(db, [journal.id])[journal.id]?.dailyJournal == true)
            #expect(try db.read { try Queries.mcpBookFacts($0, readingID: journal.id) }?.fence == .journal,
                    "the fence agrees (control)")
        }
    }

    /// RED on old: a stale second bearer of the marker (two devices'
    /// not-yet-converged Journals) fences — the conservative direction — so it
    /// wears the mark too.
    @Test func aStaleSecondDailyBearerWearsItToo() throws {
        try withOperations { ops, db in
            let first = try ops.createReading(name: "Journal", kind: .book, profile: "daily")
            let second = try ops.createReading(name: "Journal (other Mac)", kind: .book, profile: "daily")
            let read = try bookMarks(db, [first.id, second.id])
            #expect(read.count == 2)
            #expect(read.values.allSatisfy { $0.dailyJournal && !$0.own })
        }
    }

    /// GUARD (green before and after — the boundary the fix must not cross): a
    /// journal-TRAIT book (`profile = 'journal'`, not fenced since VX-163), a
    /// book toggled journal-style, a deleted Journal and a GATHERING carrying a
    /// stale 'daily' marker wear no mark (books only; the facts never name a
    /// gathering).
    @Test func aTraitBookADeadJournalAndAGatheringWearNone() throws {
        try withOperations { ops, db in
            let trait = try ops.createReading(name: "dream journal", kind: .book, profile: "journal")
            let toggled = try ops.createReading(name: "reading log", kind: .book)
            try ops.setJournalTrait(toggled.id, on: true)
            let dead = try ops.createReading(name: "old Journal", kind: .book, profile: "daily")
            _ = try ops.deleteReading(dead.id)
            let tag = try ops.createTag(name: "t")
            let gathering = try ops.createReading(
                name: "gathered", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            try db.write { db in
                try db.execute(sql: "UPDATE reading SET profile = 'daily' WHERE id = ?", arguments: [gathering.id])
            }
            #expect(try bookMarks(db, [trait.id, toggled.id, dead.id, gathering.id]).isEmpty)
        }
    }

    /// RED on old: the Journal with its OWN stamp too reads both facts (the
    /// face then speaks the Journal's arm — the row is locked, D-6).
    @Test func aJournalWithItsOwnStampReadsBoth() throws {
        try withOperations { ops, db in
            let journal = try ops.createReading(name: "Journal", kind: .book, profile: "daily")
            try ops.setBookPrivate(journal.id, true)
            #expect(try bookMarks(db, [journal.id])[journal.id] == Queries.PrivateBookMark(own: true, dailyJournal: true))
        }
    }

    // MARK: - Each journal leg marks its note

    /// RED on old: each journal leg alone marks its note, named exactly — a
    /// ⌘J day entry filed in the Journal (both legs), a loose page filed there
    /// by hand (the member leg), a day entry taken out of the Journal (the
    /// entry leg — private wherever it is filed, D-1).
    @Test func eachJournalLegMarksItsNote() throws {
        try withOperations { ops, db in
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-01").container
            guard case .shelved(let journalID) = ops.shelveInDailyJournalBook(entry.id) else {
                Issue.record("the daily door did not file the entry")
                return
            }
            let name = try #require(try db.read { try Reading.fetchOne($0, key: journalID) }).name
            let journal = Queries.BookRef(id: journalID, name: name)
            let loose = try ops.createPost(title: "a loose page")
            _ = try ops.addPostToReading(loose.id, to: journalID)
            let taken = try ops.createOrOpenJournalEntry(entryDate: "2026-07-02").container
            _ = ops.shelveInDailyJournalBook(taken.id)
            _ = try ops.removePostFromReading(taken.id, from: journalID)
            let free = try ops.createPost(title: "an open page")

            let read = try marks(db, [entry.id, loose.id, taken.id, free.id])
            #expect(read[entry.id] == Queries.PrivateMark(
                own: false, viaBooks: [], journalEntry: true, viaJournals: [journal]))
            #expect(read[loose.id] == Queries.PrivateMark(
                own: false, viaBooks: [], journalEntry: false, viaJournals: [journal]))
            #expect(read[taken.id] == Queries.PrivateMark(
                own: false, viaBooks: [], journalEntry: true, viaJournals: []))
            #expect(read[free.id] == nil, "an open page reads nothing back")
            for id in [entry.id, loose.id, taken.id] {
                #expect(read[id]?.isFenced == true && read[id]?.isPrivate == false,
                        "fenced by a journal leg — not by the Private mark")
            }
        }
    }

    /// RED on old: only the ASKED ids are read (P1 — the drawn rows), the
    /// journal legs included.
    @Test func onlyTheAskedIdsAreRead() throws {
        try withOperations { ops, db in
            let journal = try ops.createReading(name: "Journal", kind: .book, profile: "daily")
            let asked = try ops.createPost(title: "asked", profile: .journal)
            let other = try ops.createPost(title: "not drawn", profile: .journal)
            _ = try ops.addPostToReading(asked.id, to: journal.id)
            _ = try ops.addPostToReading(other.id, to: journal.id)
            #expect(Set(try marks(db, [asked.id]).keys) == [asked.id])
            #expect(try marks(db, []).isEmpty)
        }
    }

    // MARK: - THE PARITY PIN — the face says Private exactly where the fence does

    /// RED on old (the journal rows): over a matrix that walks every leg's
    /// boundary — the entry shape and other profiles, member and ARRIVAL rows,
    /// a removed membership, a live, archived, deleted and stale-second
    /// Journal, a trait book, a Private book, and the legs combined — the
    /// face's facts agree with `mcpNoteFacts` LEG BY LEG: Private-mark leg ⇔
    /// `fence == .privateMark`; journal-only ⇔ `fence == .journal`; nothing ⇔
    /// nil. A respelled leg on either side breaks a row here. The fence's own
    /// answers are pinned to their ruled values too, so the factoring of
    /// `mcpNoteFacts` into named fragments (F1) cannot have moved it (REVIEW
    /// FOCI 1 — a GUARD half, green before and after).
    @Test func theFaceSaysPrivateExactlyWhereTheFenceSaysFencedLegByLeg() throws {
        try withOperations { ops, db in
            let journal = try ops.createReading(name: "Journal", kind: .book, profile: "daily")
            let stale = try ops.createReading(name: "Journal (other Mac)", kind: .book, profile: "daily")
            let shut = try ops.createReading(name: "Journal (archived)", kind: .book, profile: "daily")
            let gone = try ops.createReading(name: "Journal (deleted)", kind: .book, profile: "daily")
            let trait = try ops.createReading(name: "dream journal", kind: .book, profile: "journal")
            let vault = try ops.createReading(name: "vault", kind: .book)
            let plain = try ops.createReading(name: "plain", kind: .book)
            try ops.setBookPrivate(vault.id, true)

            var expected: [String: MCPGrantRule.Fence?] = [:]
            func note(_ title: String, profile: Profile? = nil, _ fence: MCPGrantRule.Fence?) throws -> String {
                let id = try ops.createPost(title: title, profile: profile).id
                expected[id] = fence
                return id
            }
            _ = try note("open", nil)
            _ = try note("a blog post", profile: .blog, nil)
            _ = try note("an entry, bookless", profile: .journal, .journal)
            let inJournal = try note("a loose page in the Journal", .journal)
            let entryInJournal = try note("an entry in the Journal", profile: .journal, .journal)
            let inStale = try note("in the stale bearer", .journal)
            let inShut = try note("in the archived Journal", .journal)
            let inGone = try note("in the deleted Journal", nil)
            let arriving = try note("an arrival at the Journal", nil)
            let removed = try note("taken out of the Journal", nil)
            let inTrait = try note("in a trait book", nil)
            let entryInTrait = try note("an entry in a trait book", profile: .journal, .journal)
            let own = try note("its own mark", .privateMark)
            let ownInJournal = try note("its own mark, in the Journal", .privateMark)
            let entryOwn = try note("an entry with its own mark", profile: .journal, .privateMark)
            let inVault = try note("in a Private book", .privateMark)
            let entryInVault = try note("an entry in a Private book", profile: .journal, .privateMark)
            let inVaultAndJournal = try note("in the vault and the Journal", .privateMark)
            let inPlain = try note("in a plain book", nil)

            for id in [inJournal, entryInJournal, ownInJournal, arriving, removed, inVaultAndJournal] {
                _ = try ops.addPostToReading(id, to: journal.id)
            }
            _ = try ops.addPostToReading(inStale, to: stale.id)
            _ = try ops.addPostToReading(inShut, to: shut.id)
            _ = try ops.addPostToReading(inGone, to: gone.id)
            for id in [inTrait, entryInTrait] { _ = try ops.addPostToReading(id, to: trait.id) }
            for id in [inVault, entryInVault, inVaultAndJournal] { _ = try ops.addPostToReading(id, to: vault.id) }
            _ = try ops.addPostToReading(inPlain, to: plain.id)
            for id in [own, ownInJournal, entryOwn] { try ops.setNotePrivate(id, true) }
            try db.write { db in
                try db.execute(
                    sql: "UPDATE reading_post SET status = 'arrival' WHERE post_id = ? AND reading_id = ?",
                    arguments: [arriving, journal.id])
            }
            _ = try ops.removePostFromReading(removed, from: journal.id)
            try ops.archiveReading(shut.id)
            _ = try ops.deleteReading(gone.id)

            let ids = Array(expected.keys).sorted()
            let face = try marks(db, ids)
            let facts = try db.read { try Queries.mcpNoteFacts($0, noteIDs: ids) }
            #expect(facts.count == ids.count, "every matrix note has facts (live, non-version posts)")
            for id in ids {
                let fence = facts[id]?.fence
                // The fence did not move: each row's ruled answer.
                #expect(fence == expected[id] ?? nil, "the fence's own answer for \(id)")
                // The face, leg by leg.
                #expect((face[id]?.isFenced ?? false) == (fence != nil), "fenced at all: \(id)")
                #expect((face[id]?.isPrivate ?? false) == (fence == .privateMark), "the Private-mark leg: \(id)")
                #expect(((face[id]?.journalFenced ?? false) && !(face[id]?.isPrivate ?? false)) == (fence == .journal),
                        "a journal leg alone: \(id)")
            }
            // Non-vacuity: every class is exercised.
            #expect(ids.filter { facts[$0]?.fence == .journal }.count >= 6)
            #expect(ids.filter { facts[$0]?.fence == .privateMark }.count >= 6)
            #expect(ids.filter { facts[$0]?.fence == nil }.count >= 6)
            // And each journal leg's own boundary, named: the entry leg alone,
            // the member leg alone.
            #expect(face[entryInTrait]?.journalEntry == true && face[entryInTrait]?.viaJournals == [])
            #expect(face[inJournal]?.journalEntry == false
                    && face[inJournal]?.viaJournals.map(\.id) == [journal.id])
            #expect(face[ownInJournal]?.own == true && face[ownInJournal]?.viaJournals.map(\.id) == [journal.id])

            // The BOOKS, leg by leg, against `mcpBookFacts`.
            let readings = [journal, stale, shut, gone, trait, vault, plain]
            let bookFace = try bookMarks(db, readings.map(\.id))
            for reading in readings {
                let fence = try db.read { try Queries.mcpBookFacts($0, readingID: reading.id) }?.fence
                #expect((bookFace[reading.id] != nil) == (fence != nil), "a book fenced at all: \(reading.name)")
                #expect((bookFace[reading.id]?.own ?? false) == (fence == .privateMark), "its own stamp: \(reading.name)")
                #expect(((bookFace[reading.id]?.dailyJournal ?? false) && !(bookFace[reading.id]?.own ?? false))
                        == (fence == .journal), "the daily marker: \(reading.name)")
            }
        }
    }

    // MARK: - P1 — every new statement is driven by the drawn ids

    /// GUARD (the statements exist on the scaffold; the law holds from their
    /// first commit): the two journal statements and the book statement seek
    /// by the ids, never scan `container`, `reading_post` or `reading`; the
    /// member read enters through `idx_reading_post_post`.
    @Test func theJournalStatementsAreDrivenByTheIdsNeverAScan() throws {
        try withOperations { ops, db in
            let journal = try ops.createReading(name: "Journal", kind: .book, profile: "daily")
            for n in 0..<20 {
                let note = try ops.createPost(title: "n\(n)", profile: .journal)
                _ = try ops.addPostToReading(note.id, to: journal.id)
            }
            func plan(_ sql: String) throws -> String {
                try db.read { db in
                    try Row.fetchAll(db, sql: "EXPLAIN QUERY PLAN \(sql)", arguments: ["[\"x\"]"])
                        .map { ($0["detail"] as String?) ?? "" }.joined(separator: "\n")
                }
            }
            for sql in [Queries.privateMarkJournalEntrySQL, Queries.privateMarkViaJournalSQL,
                        Queries.privateBookMarkSQL] {
                let shown = try plan(sql)
                for table in ["c", "rp", "r"] {
                    #expect(!shown.contains("SCAN \(table)"), "\(shown)")
                }
                #expect(shown.contains("SEARCH"), "\(shown)")
            }
            #expect(try plan(Queries.privateMarkViaJournalSQL).contains("idx_reading_post_post"))
        }
    }

    /// GUARD — ONE derivation, said as text: the faces' journal statements are
    /// built from the fence's own fragments, and the fence's note legs are
    /// those fragments (so a leg respelled on one side alone is a red here
    /// as well as in the parity matrix).
    @Test func theFacesJournalStatementsAreBuiltFromTheFencesOwnFragments() {
        #expect(Queries.privateMarkJournalEntrySQL.contains(Queries.journalEntryLegForNote))
        #expect(Queries.privateMarkViaJournalSQL.contains(Queries.fenceMemberRowSQL))
        #expect(Queries.privateMarkViaJournalSQL.contains(Queries.dailyJournalLegForBook))
        #expect(Queries.journalMemberLegForNote.contains(Queries.fenceMemberRowSQL))
        #expect(Queries.journalMemberLegForNote.contains(Queries.dailyJournalLegForBook))
        #expect(Queries.privateBookMarkSQL.contains(Queries.dailyJournalLegForBook),
                "the book statement reads the fence's book leg itself")
        #expect(Queries.privateBookMarkSQL.contains(Queries.privateLegForBook))
    }

    // MARK: - The gate (R-878-K3) — closed, nothing past the grants store

    /// GUARD (green before and after): with no approved client the drawn
    /// reads answer nothing for a Journal world and read nothing but the
    /// client list — no `container`, `reading_post` or `reading`; an approval
    /// brings the Journal's marks (the RED half on old).
    @Test func theGateClosedReadsNothingPastTheGrantsStore() throws {
        try withOperations { ops, db in
            let journal = try ops.createReading(name: "Journal", kind: .book, profile: "daily")
            let entry = try ops.createPost(title: "today", profile: .journal)
            _ = try ops.addPostToReading(entry.id, to: journal.id)
            func traced() throws -> (notes: [String: Queries.PrivateMark],
                                     books: [String: Queries.PrivateBookMark], sqls: [String]) {
                try db.read { db in
                    var sqls: [String] = []
                    db.trace { sqls.append($0.description) }
                    defer { db.trace(options: [], nil) }
                    let notes = try Queries.privateMarksDrawn(db, noteIDs: [entry.id])
                    let books = try Queries.privateBookMarksDrawn(db, readingIDs: [journal.id])
                    return (notes, books, sqls)
                }
            }
            _ = try ops.recordMCPContact(name: "asking", version: "1")
            let closed = try traced()
            #expect(closed.notes.isEmpty && closed.books.isEmpty, "no approved client: nothing drawn")
            #expect(!closed.sqls.isEmpty, "the gate ran (non-vacuity)")
            for table in ["container", "reading"] {
                #expect(!closed.sqls.contains { $0.contains(table) }, "no `\(table)` read: \(closed.sqls)")
            }
            let client = try ops.recordMCPContact(name: "claude-code", version: "1")
            try ops.approveMCPClient(client.id, granting: nil)
            let open = try traced()
            #expect(open.notes[entry.id]?.isFenced == true, "approved: the entry's mark is drawn")
            #expect(open.books[journal.id]?.dailyJournal == true, "approved: the Journal's mark is drawn")
        }
    }

    /// RED on old: the drawn facts follow the Journal's facts as they move —
    /// a page filed into the Journal, taken out, the designation moved to
    /// another book (the marker moves; nothing is stamped). Plain reads, not a
    /// held observation (an observation that never re-emits would hang a run
    /// on the old code): the held reads' regions are the same tables the
    /// Private leg's held pin already proves (`PrivateMarkFactsTests`).
    @Test func theDrawnFactsFollowTheJournalsFacts() throws {
        try withOperations { ops, db in
            let journal = try ops.createReading(name: "Journal", kind: .book, profile: "daily")
            let next = try ops.createReading(name: "Notebook", kind: .book)
            let page = try ops.createPost(title: "a loose page")
            let client = try ops.recordMCPContact(name: "claude-code", version: "1")
            try ops.approveMCPClient(client.id, granting: nil)
            func notes() throws -> [String: Queries.PrivateMark] {
                try db.read { try Queries.privateMarksDrawn($0, noteIDs: [page.id]) }
            }
            func books() throws -> [String: Queries.PrivateBookMark] {
                try db.read { try Queries.privateBookMarksDrawn($0, readingIDs: [journal.id, next.id]) }
            }
            #expect(try notes().isEmpty)
            _ = try ops.addPostToReading(page.id, to: journal.id)
            #expect(try notes()[page.id]?.viaJournals.map(\.id) == [journal.id])
            _ = try ops.removePostFromReading(page.id, from: journal.id)
            #expect(try notes().isEmpty)

            #expect(Set(try books().keys) == [journal.id])
            try ops.setDailyJournalBook(next.id)
            #expect(Set(try books().keys) == [next.id], "the mark follows the marker — nothing stamped")
            #expect(try db.read { try Queries.isBookPrivate($0, readingID: next.id) } == false)
        }
    }
}
