import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// 13i-c U2 — **THE DOOR ENUMERATION** (the 13i-c plan §4; the sitting record
/// §6: "every membership-creating door consults ownership … The record's list
/// is the checklist; missing one is a ladder finding"). ONE test per op-level
/// row, 1–12, named for the row, each asserting WHAT the road consults and
/// the OUTCOME it reaches. Rows 13 (sync apply — `Phase13iRepairTests`) and
/// 14–22 (the faces — U4) are pinned elsewhere.
@Suite("13i-c U2 — the door enumeration, rows 1–12 (every membership road consults ownership)")
struct OwnershipDoorTests {
    // MARK: - Fixtures

    private func rule(_ term: RuleTerm) throws -> String {
        try #require(try RuleGrammar.encode(term))
    }

    private func note(_ ops: Operations, _ title: String) throws -> Container {
        let post = try ops.createPost(title: title)
        try ops.seedBlock(in: post.id, text: "the text of \(title)")
        return post
    }

    private func ownedBook(
        _ ops: Operations, _ name: String, querySpec: String? = nil
    ) throws -> Reading {
        let book = try ops.createReading(name: name, kind: .book, querySpec: querySpec)
        try ops.setReadingOwned(book.id, owned: true)
        return book
    }

    private func members(_ db: AppDatabase, _ readingID: String) throws -> [String] {
        try db.read { try Queries.assembleReading($0, readingID: readingID).map(\.postID) }
    }

    private func status(_ db: AppDatabase, _ readingID: String, _ postID: String) throws -> String? {
        try db.fetchString(
            """
            SELECT CASE WHEN deleted_at IS NULL THEN status ELSE 'gone:' || status END
            FROM reading_post WHERE reading_id = ? AND post_id = ? ORDER BY rowid DESC LIMIT 1
            """, [readingID, postID])
    }

    /// The ownership invariant (§6): no note is a live member of an owned
    /// book AND of any other book.
    private func exclusivityHolds(_ db: AppDatabase) throws -> Bool {
        try db.fetchInt(
            """
            SELECT COUNT(*) FROM (
              SELECT rp.post_id FROM reading_post rp
              JOIN reading r ON r.id = rp.reading_id AND r.deleted_at IS NULL AND r.kind = 'book'
              WHERE rp.deleted_at IS NULL AND rp.status = 'member'
              GROUP BY rp.post_id HAVING COUNT(*) > 1 AND SUM(r.owned) > 0)
            """) == 0
    }

    // MARK: - Row 1 — `addPostToReading` (every hand-add) · consults the table

    @Test func row01_theHandAddConsultsTheTable_plainAdd_memberedElsewhere_ownedElsewhere() throws {
        try withOperations { ops, db in
            let owned = try ownedBook(ops, "owned")
            let plain = try ops.createReading(name: "plain", kind: .book)
            let other = try ops.createReading(name: "other", kind: .book)
            let bookless = try note(ops, "bookless")
            let ordinary = try note(ops, "ordinary")
            try ops.addPostToReading(ordinary.id, to: other.id)

            try ops.addPostToReading(bookless.id, to: owned.id)          // plain add (clean)
            try ops.addPostToReading(ordinary.id, to: plain.id)          // plain add (beside)
            #expect(throws: OperationError.noteMemberedElsewhere(
                postID: ordinary.id, readingID: owned.id, elsewhere: [other.id, plain.id])) {
                try ops.addPostToReading(ordinary.id, to: owned.id)
            }
            #expect(throws: OperationError.noteOwnedElsewhere(
                postID: bookless.id, readingID: plain.id, owner: owned.id)) {
                try ops.addPostToReading(bookless.id, to: plain.id)
            }
            #expect(try members(db, owned.id) == [bookless.id])
            #expect(try exclusivityHolds(db))
        }
    }

    // MARK: - Row 2 — the arrival seat (`seatArrival`) · consults the table

    @Test func row02_theArrivalSeatConsultsTheTable_seat_orTheTwoRefusalsLeavingTheBell() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let owned = try ownedBook(ops, "owned", querySpec: try rule(.tag(work.id)))
            try ops.setReadingIntakeSeating(owned.id, .arrivals)
            // Both living books wait at Arrivals, so one act bells the note at
            // both doors (a plain AUTO book would seat it at once).
            let plain = try ops.createReading(
                name: "plain", kind: .book, querySpec: try rule(.tag(work.id)),
                intakeSeating: .arrivals)
            let other = try ops.createReading(name: "other", kind: .book)
            let free = try note(ops, "free")
            let membered = try note(ops, "membered")
            try ops.addPostToReading(membered.id, to: other.id)
            for n in [free, membered] { _ = try ops.applyTag(work.id, toPost: n.id) }
            let rows = try db.read {
                try ReadingPost.fetchAll($0, sql: """
                    SELECT * FROM reading_post WHERE reading_id = ? ORDER BY rowid
                    """, arguments: [owned.id])
            }
            #expect(rows.map(\.status) == [.arrival, .arrival])   // the dial, both waiting

            #expect(try ops.seatArrival(rows[0].id).status == .member)   // a free note: seat
            #expect(throws: OperationError.noteMemberedElsewhere(
                postID: membered.id, readingID: owned.id, elsewhere: [other.id])) {
                try ops.seatArrival(rows[1].id)
            }
            #expect(try status(db, owned.id, membered.id) == "arrival")  // the bell stands
            // The plain book's bell for the note the owned book now holds.
            #expect(try status(db, plain.id, free.id) == "arrival")
            let plainBell = try #require(try db.fetchString(
                "SELECT id FROM reading_post WHERE reading_id = ? AND post_id = ?",
                [plain.id, free.id]))
            #expect(throws: OperationError.noteOwnedElsewhere(
                postID: free.id, readingID: plain.id, owner: owned.id)) {
                try ops.seatArrival(plainBell)
            }
            #expect(try exclusivityHolds(db))
        }
    }

    // MARK: - Row 3 — intake's event/backfill/catch-up through a REAL owned book

    @Test func row03_intakesOwnedArmsThroughARealOwnedBook_claimOrBellOnEveryOccasion() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let other = try ops.createReading(name: "other", kind: .book)
            // BACKFILL: a rule set on a rule-less owned book.
            let early = try note(ops, "early free")
            let earlyShared = try note(ops, "early shared")
            try ops.addPostToReading(earlyShared.id, to: other.id)
            for n in [early, earlyShared] { _ = try ops.applyTag(work.id, toPost: n.id) }
            let owned = try ownedBook(ops, "owned")
            try ops.setReadingQuerySpec(owned.id, querySpec: try rule(.tag(work.id)))
            #expect(try status(db, owned.id, early.id) == "member")        // claim
            #expect(try status(db, owned.id, earlyShared.id) == "arrival") // bell
            // EVENT.
            let free = try note(ops, "free")
            let shared = try note(ops, "shared")
            try ops.addPostToReading(shared.id, to: other.id)
            for n in [free, shared] { _ = try ops.applyTag(work.id, toPost: n.id) }
            #expect(try status(db, owned.id, free.id) == "member")
            #expect(try status(db, owned.id, shared.id) == "arrival")
            // CATCH-UP (un-finish): the gap's matches bell, free or not.
            try ops.lockReading(owned.id)
            let gap = try note(ops, "gap")
            _ = try ops.applyTag(work.id, toPost: gap.id)
            try ops.unlockReading(owned.id)
            #expect(try status(db, owned.id, gap.id) == "arrival")
            #expect(try exclusivityHolds(db))
        }
    }

    // MARK: - Row 4 — `shelveInDailyJournalBook` · consults the table, never throws

    @Test func row04_theDailyDoorConsultsTheTable_addOrWaitingAtTheDoor() throws {
        try withOperations { ops, db in
            let plainEntry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-01").container
            guard case .shelved(let journalID) = ops.shelveInDailyJournalBook(plainEntry.id) else {
                Issue.record("expected the entry shelved"); return
            }
            #expect(try status(db, journalID, plainEntry.id) == "member")   // add
            let claimed = try ops.createOrOpenJournalEntry(entryDate: "2026-07-02").container
            let owned = try ownedBook(ops, "owned")
            try ops.addPostToReading(claimed.id, to: owned.id)
            #expect(ops.shelveInDailyJournalBook(claimed.id) == .waitingAtDoor(readingID: journalID))
            #expect(try status(db, journalID, claimed.id) == "arrival")
            #expect(try exclusivityHolds(db))
        }
    }

    // MARK: - Row 5 — the ceremonies (`copyPostIntoReading` / `movePostIntoReading`)

    @Test func row05_theCeremoniesNeedNoConsult_copyWithTags_moveWithTheSeveredList() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "tag")
            let owned = try ownedBook(ops, "owned")
            let a = try ops.createReading(name: "a", kind: .book)
            let b = try ops.createReading(name: "b", kind: .book)
            let n = try note(ops, "n")
            _ = try ops.applyTag(tag.id, toPost: n.id)
            try ops.addPostToReading(n.id, to: a.id)
            try ops.addPostToReading(n.id, to: b.id)

            let copy = try ops.copyPostIntoReading(n.id, into: owned.id).copy
            #expect(try db.fetchString(
                "SELECT tag_id FROM post_tag WHERE post_id = ? AND deleted_at IS NULL",
                [copy.id]) == tag.id)
            #expect(try members(db, a.id) == [n.id] && members(db, b.id) == [n.id])

            let moved = try ops.movePostIntoReading(n.id, into: owned.id)
            #expect(moved.severed.map(\.readingId) == [a.id, b.id])
            #expect(try members(db, owned.id) == [copy.id, n.id])
            #expect(try exclusivityHolds(db))
        }
    }

    // MARK: - Row 6 — the bind (`convertSmartReadingToCurated`) · owned notes in the assembly

    @Test func row06_theBindConsultsOwnershipPerNote_leaveOutByDefaultOrCopyIn() throws {
        try withOperations { ops, db in
            let t = try ops.createTag(name: "t")
            let owned = try ownedBook(ops, "owned")
            let claimed = try note(ops, "claimed")
            try ops.addPostToReading(claimed.id, to: owned.id)
            let free = try note(ops, "free")
            for n in [claimed, free] { _ = try ops.applyTag(t.id, toPost: n.id) }
            let leaving = try ops.createReading(
                name: "leaving", kind: .gathering, querySpec: try rule(.tag(t.id)))
            let copying = try ops.createReading(
                name: "copying", kind: .gathering, querySpec: try rule(.tag(t.id)))

            let left = try ops.convertSmartReadingToCurated(leaving.id)
            #expect(left.leftOut == [claimed.id])
            #expect(try members(db, leaving.id) == [free.id])

            let copied = try ops.convertSmartReadingToCurated(copying.id, ownedNotes: .copyIn)
            let fork = try #require(copied.copied.first)
            #expect(try members(db, copying.id) == [fork.copyID, free.id])
            #expect(try members(db, owned.id) == [claimed.id])
            #expect(try exclusivityHolds(db))
        }
    }

    // MARK: - Row 7 — `restoreReading`'s membership revival · the revival pass

    @Test func row07_restoreReadingRunsTheRevivalPass_demoteOrTombstone() throws {
        try withOperations { ops, db in
            let owned = try ownedBook(ops, "owned")
            let n = try note(ops, "n")
            try ops.addPostToReading(n.id, to: owned.id)
            try ops.deleteReading(owned.id)
            let plain = try ops.createReading(name: "plain", kind: .book)
            try ops.addPostToReading(n.id, to: plain.id)
            try ops.restoreReading(owned.id)
            #expect(try status(db, owned.id, n.id) == "member")             // earliest stands
            #expect(try status(db, plain.id, n.id) == "gone:member")        // later plain goes
            #expect(try exclusivityHolds(db))
        }
    }

    // MARK: - Row 8 — `restoreContainer`'s membership revival · the revival pass

    @Test func row08_restoreContainerRunsTheRevivalPass() throws {
        try withOperations { ops, db in
            let plain = try ops.createReading(name: "plain", kind: .book)
            let laterOwned = try ops.createReading(name: "later owned", kind: .book)
            let n = try note(ops, "n")
            try ops.addPostToReading(n.id, to: plain.id)
            try ops.addPostToReading(n.id, to: laterOwned.id)
            try ops.deleteContainer(n.id)
            try ops.setReadingOwned(laterOwned.id, owned: true)
            try ops.restoreContainer(n.id)
            #expect(try status(db, plain.id, n.id) == "member")             // earliest, plain
            #expect(try status(db, laterOwned.id, n.id) == "arrival")       // the owned side bells
            #expect(try exclusivityHolds(db))
        }
    }

    // MARK: - Row 9 — the re-applies · the revival pass

    @Test func row09_theReappliesRunTheRevivalPass_bindRedo_divergeUndoRedo_mintRedo() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            // The bind's redo (`reapplySmartConversion`).
            let t = try ops.createTag(name: "t")
            let gathering = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try rule(.tag(t.id)))
            let n = try note(ops, "n")
            _ = try ops.applyTag(t.id, toPost: n.id)
            try ops.convertSmartReadingToCurated(gathering.id)
            _ = try stack.undo(with: ops)
            let owned = try ownedBook(ops, "owned")
            try ops.addPostToReading(n.id, to: owned.id)
            _ = try stack.redo(with: ops)
            #expect(try status(db, gathering.id, n.id) == "member")
            #expect(try status(db, owned.id, n.id) == "arrival")
            #expect(try exclusivityHolds(db))

            // The diverge's undo (`revertDiverge`) and redo (`reapplyDiverge`).
            let plain = try ops.createReading(name: "plain", kind: .book)
            let m = try note(ops, "m")
            try ops.addPostToReading(m.id, to: plain.id)
            let diverge = try ops.divergePostForReading(m.id, in: plain.id)
            let owner2 = try ownedBook(ops, "owner two")
            try ops.addPostToReading(m.id, to: owner2.id)
            _ = try stack.undo(with: ops)
            #expect(try status(db, owner2.id, m.id) == "arrival")
            _ = try stack.redo(with: ops)
            #expect(try members(db, plain.id) == [diverge.copy.post.id])
            #expect(try exclusivityHolds(db))

            // A minted container's redo (`reapplyMintedContainer` — copy in)
            // rides `restoreContainer`, so the pass runs there too.
            let copy = try ops.copyPostIntoReading(m.id, into: owned.id).copy
            _ = try stack.undo(with: ops)
            _ = try stack.redo(with: ops)
            #expect(try status(db, owned.id, copy.id) == "member")
            #expect(try exclusivityHolds(db))
        }
    }

    // MARK: - Row 10 — `divergePostForReading` · none needed (a control pin)

    @Test func row10_divergeIsAllowedEverywhere_itCopies() throws {
        try withOperations { ops, db in
            let owned = try ownedBook(ops, "owned")
            let plain = try ops.createReading(name: "plain", kind: .book)
            let claimed = try note(ops, "claimed")
            try ops.addPostToReading(claimed.id, to: owned.id)
            let shared = try note(ops, "shared")
            try ops.addPostToReading(shared.id, to: plain.id)
            try ops.addPostToReading(try note(ops, "x").id, to: plain.id)

            let inOwned = try ops.divergePostForReading(claimed.id, in: owned.id)
            #expect(try members(db, owned.id) == [inOwned.copy.post.id])
            let inPlain = try ops.divergePostForReading(shared.id, in: plain.id)
            #expect(try members(db, plain.id).contains(inPlain.copy.post.id))
            #expect(try exclusivityHolds(db))
        }
    }

    // MARK: - Row 11 — `newPostInReading` on an owned book · none needed

    @Test func row11_aNoteMintedInAnOwnedBookIsSoleByConstructionInTheBooksWing() throws {
        try withOperations { ops, db in
            let owned = try ownedBook(ops, "owned")
            try db.write {
                try $0.execute(sql: "UPDATE reading SET wing_id = 'w2' WHERE id = ?",
                               arguments: [owned.id])
            }
            let minted = try ops.newPostInReading(owned.id)
            #expect(minted.wingId == "w2")
            #expect(try db.read { try Queries.noteMemberships($0, postID: minted.id) }
                .map(\.book.id) == [owned.id])
            #expect(try exclusivityHolds(db))
        }
    }

    // MARK: - Row 12 — `duplicateReading` shallow/deep · the source's ownership

    @Test func row12_duplicateConsultsTheSourcesOwnership_shallowRefusesOnAnOwnedSource() throws {
        try withOperations { ops, db in
            let owned = try ownedBook(ops, "owned")
            let plain = try ops.createReading(name: "plain", kind: .book)
            let a = try note(ops, "a")
            let b = try note(ops, "b")
            try ops.addPostToReading(a.id, to: owned.id)
            try ops.addPostToReading(b.id, to: plain.id)

            #expect(throws: OperationError.ownedBookDuplicatesDeep(id: owned.id)) {
                try ops.duplicateReading(owned.id, name: "shallow", deep: false)
            }
            let deep = try ops.duplicateReading(owned.id, name: "deep", deep: true)
            #expect(try members(db, deep.reading.id) == deep.copied.map(\.copyID))
            let shallow = try ops.duplicateReading(plain.id, name: "sibling", deep: false)
            #expect(try members(db, shallow.reading.id) == [b.id])
            #expect(try exclusivityHolds(db))
        }
    }
}
