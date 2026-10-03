import Foundation
import GRDB
import Testing

@testable import VariorumCore

// 13i-e U1 — BOOK ARCHIVE (her kickoff rulings R-13ie-1…4; the binding record
// is the 13i-e plan's U1 RECORD). Exact state transitions per op — every test
// names the rows and stamps it moves, and the rows it must NOT move — then
// the archived semantics per consumer: auto-ingestion pauses (the one table),
// explicit adds land, a gathering answers empty everywhere its rule is read,
// the Bookcase lists no archived reading, membership stays a fact.

// MARK: - Shared fixtures

private func rule(_ term: RuleTerm) throws -> String {
    try #require(try RuleGrammar.encode(term))
}

private func note(_ ops: Operations, _ title: String, text: String? = nil) throws -> Container {
    let post = try ops.createPost(title: title)
    try ops.seedBlock(in: post.id, text: text ?? "the words of \(title)")
    return post
}

private func archivedAt(_ db: AppDatabase, _ table: String, _ id: String) throws -> String? {
    try db.fetchString("SELECT archived_at FROM \(table) WHERE id = ?", [id])
}

/// Every row of the book's membership table, tombstones included, in
/// insertion order.
private func rows(_ db: AppDatabase, _ readingID: String) throws -> [ReadingPost] {
    try db.read {
        try ReadingPost.fetchAll(
            $0, sql: "SELECT * FROM reading_post WHERE reading_id = ? ORDER BY rowid",
            arguments: [readingID])
    }
}

private func assembled(_ db: AppDatabase, _ readingID: String) throws -> [String] {
    try db.read { try Queries.assembleReading($0, readingID: readingID).map(\.postID) }
}

// MARK: - The op family

@Suite("13i-e U1 — book archive: the op family's exact transitions")
struct BookArchiveOperationTests {
    @Test func archivingAPlainBookWritesItsOwnRowAndNothingElse() throws {
        try withOperations { ops, db in
            let t = try ops.createTag(name: "t")
            let book = try ops.createReading(
                name: "plain", kind: .book, querySpec: try rule(.tag(t.id)),
                intakeSeating: .arrivals)
            let member = try note(ops, "member")
            try ops.addPostToReading(member.id, to: book.id)
            let waiter = try note(ops, "waiter")
            _ = try ops.applyTag(t.id, toPost: waiter.id)      // the bell
            let before = try rows(db, book.id)
            #expect(before.map(\.status) == [.member, .arrival])
            try db.clearOutbox()

            try ops.archiveReading(book.id)

            let stamp = try #require(try archivedAt(db, "reading", book.id))
            #expect(try db.fetchString("SELECT updated_at FROM reading WHERE id = ?", [book.id]) == stamp)
            // R-13ie-2: a plain book archives ALONE — its notes stay live.
            #expect(try archivedAt(db, "container", member.id) == nil)
            #expect(try archivedAt(db, "container", waiter.id) == nil)
            // The edge: pending arrivals KEEP WAITING (finishing's sweep is
            // deliberately not mirrored); every row exactly as it was.
            #expect(try rows(db, book.id) == before)
            // ONE row write: the reading, and nothing else reaches the outbox.
            #expect(try db.outboxContains("reading", book.id))
            #expect(try db.fetchInt("SELECT COUNT(*) FROM sync_outbox") == 1)
            // The book still opens with its members (the edit law).
            #expect(try assembled(db, book.id) == [member.id])
        }
    }

    @Test func aGatheringArchivesToo_andStopsAssemblingUntilUnarchived() throws {
        try withOperations { ops, db in
            let t = try ops.createTag(name: "t")
            let gathering = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try rule(.tag(t.id)))
            let n = try note(ops, "n")
            _ = try ops.applyTag(t.id, toPost: n.id)
            #expect(try assembled(db, gathering.id) == [n.id])

            try ops.archiveReading(gathering.id)
            #expect(try archivedAt(db, "reading", gathering.id) != nil)
            #expect(try assembled(db, gathering.id).isEmpty, "R-13ie-3: a saved rule put away")

            let returned = try ops.unarchiveReading(gathering.id)
            #expect(returned.isEmpty, "a gathering holds no notes to return")
            #expect(try archivedAt(db, "reading", gathering.id) == nil)
            #expect(try assembled(db, gathering.id) == [n.id])
        }
    }

    @Test func theDoorsRefuseHonestlyAndARefusalMovesNothing() throws {
        try withOperations { ops, db in
            let t = try ops.createTag(name: "t")
            let book = try ops.createReading(name: "b", kind: .book)
            let gathering = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try rule(.tag(t.id)))
            let dead = try ops.createReading(name: "dead", kind: .book)
            try ops.deleteReading(dead.id)

            #expect(throws: OperationError.readingNotArchived(id: book.id)) {
                try ops.unarchiveReading(book.id)
            }
            try ops.archiveReading(book.id)
            let stamp = try archivedAt(db, "reading", book.id)
            // P-13ie-U1-1: a second archive refuses — and never re-stamps.
            #expect(throws: OperationError.readingAlreadyArchived(id: book.id)) {
                try ops.archiveReading(book.id)
            }
            #expect(throws: OperationError.readingAlreadyArchived(id: book.id)) {
                try ops.archiveReadingWithNotes(book.id)
            }
            #expect(try archivedAt(db, "reading", book.id) == stamp)
            // P-13ie-U1-2: the with-notes op refuses a gathering, first.
            #expect(throws: OperationError.wrongReadingKind(id: gathering.id, expected: .book)) {
                try ops.archiveReadingWithNotes(gathering.id)
            }
            #expect(try archivedAt(db, "reading", gathering.id) == nil)
            for door in [ops.archiveReading, { _ = try ops.archiveReadingWithNotes($0) },
                         { _ = try ops.unarchiveReading($0) }] as [(String) throws -> Void] {
                #expect(throws: OperationError.readingNotFound(id: dead.id)) { try door(dead.id) }
            }
        }
    }

    @Test func archivingWithNotesStampsTheBookAndItsMembersOnOneClockRead() throws {
        try withOperations { ops, db in
            let t = try ops.createTag(name: "t")
            let owned = try ops.createReading(
                name: "owned", kind: .book, querySpec: try rule(.tag(t.id)),
                intakeSeating: .arrivals)
            try ops.setReadingOwned(owned.id, owned: true)
            let a = try note(ops, "a")
            let b = try note(ops, "b")
            let early = try note(ops, "archived on its own")
            for n in [a, b, early] { try ops.addPostToReading(n.id, to: owned.id) }
            try ops.archiveContainer(early.id)
            let earlyStamp = try #require(try archivedAt(db, "container", early.id))
            try ops.lockPost(b.id)                              // a sealed member archives too
            let waiter = try note(ops, "waiter")
            _ = try ops.applyTag(t.id, toPost: waiter.id)       // an arrival, not a member

            let archived = try ops.archiveReadingWithNotes(owned.id)

            #expect(archived == [a.id, b.id], "the live, unarchived members, in book order")
            let stamp = try #require(try archivedAt(db, "reading", owned.id))
            #expect(try archivedAt(db, "container", a.id) == stamp)
            #expect(try archivedAt(db, "container", b.id) == stamp)
            #expect(try db.fetchString("SELECT updated_at FROM container WHERE id = ?", [a.id]) == stamp)
            // The edge: a note archived on its own keeps ITS stamp.
            #expect(try archivedAt(db, "container", early.id) == earlyStamp)
            #expect(earlyStamp != stamp)
            // An arrival's note is not a member.
            #expect(try archivedAt(db, "container", waiter.id) == nil)
            // Archive is visibility, never lifecycle: no tombstone anywhere.
            for n in [a, b, early, waiter] {
                #expect(try db.deletedAt("container", n.id) == nil)
            }
            #expect(try rows(db, owned.id).allSatisfy { $0.deletedAt == nil })
            #expect(try db.fetchInt("SELECT locked FROM container WHERE id = ?", [b.id]) == 1)
        }
    }

    /// The edge (the plan's EDGES list): "A note archived INDIVIDUALLY before
    /// its owned book's archive-with-notes: stamp differs, so the book's
    /// unarchive leaves it archived."
    @Test func unarchivingReturnsExactlyTheNotesArchivedWithTheBook() throws {
        try withOperations { ops, db in
            let owned = try ops.createReading(name: "owned", kind: .book)
            try ops.setReadingOwned(owned.id, owned: true)
            let a = try note(ops, "a")
            let b = try note(ops, "b")
            let early = try note(ops, "archived on its own")
            for n in [a, b, early] { try ops.addPostToReading(n.id, to: owned.id) }
            try ops.archiveContainer(early.id)
            let earlyStamp = try archivedAt(db, "container", early.id)
            try ops.archiveReadingWithNotes(owned.id)

            let returned = try ops.unarchiveReading(owned.id)

            #expect(returned == [a.id, b.id])
            #expect(try archivedAt(db, "reading", owned.id) == nil)
            #expect(try archivedAt(db, "container", a.id) == nil)
            #expect(try archivedAt(db, "container", b.id) == nil)
            #expect(try archivedAt(db, "container", early.id) == earlyStamp,
                    "the stamp-mismatch letter: it was set aside on its own")
            #expect(try assembled(db, owned.id) == [a.id, b.id])
        }
    }

    /// P-13ie-U1-3: a note that LEFT the book while it was archived is no
    /// longer a member — its story diverged, it stays as it is.
    @Test func aNoteThatLeftTheBookWhileArchivedStaysArchived() throws {
        try withOperations { ops, db in
            let owned = try ops.createReading(name: "owned", kind: .book)
            try ops.setReadingOwned(owned.id, owned: true)
            let stays = try note(ops, "stays")
            let leaves = try note(ops, "leaves")
            for n in [stays, leaves] { try ops.addPostToReading(n.id, to: owned.id) }
            try ops.archiveReadingWithNotes(owned.id)
            _ = try ops.removePostFromReading(leaves.id, from: owned.id)   // legal while archived
            let leavesStamp = try archivedAt(db, "container", leaves.id)

            let returned = try ops.unarchiveReading(owned.id)

            #expect(returned == [stays.id])
            #expect(try archivedAt(db, "container", stays.id) == nil)
            #expect(try archivedAt(db, "container", leaves.id) == leavesStamp)
        }
    }

    /// P-13ie-U1-4: the door is the recovery — the family registers nothing,
    /// and (archive removing no content) leaves the redo future alone.
    @Test func theFamilyRegistersNoUndoAndKeepsTheRedoFuture() throws {
        let stack = UndoStack()
        try withOperations { _, _ in
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost(title: "p")
            _ = try ops.newBlock(in: post.id, text: "one", at: .end)
            _ = try stack.undo(with: ops)
            #expect(stack.depth == 0 && stack.redoDepth == 1)
            let plain = try ops.createReading(name: "plain", kind: .book)
            let owned = try ops.createReading(name: "owned", kind: .book)
            try ops.setReadingOwned(owned.id, owned: true)

            try ops.archiveReading(plain.id)
            try ops.archiveReadingWithNotes(owned.id)
            try ops.unarchiveReading(plain.id)
            try ops.unarchiveReading(owned.id)

            #expect(stack.depth == 0)
            #expect(stack.redoDepth == 1, "archive strands no stack entry")
        }
    }
}

// MARK: - The pause (auto-ingestion) and the open doors (explicit adds)

@Suite("13i-e U1 — archived: auto-ingestion pauses, explicit adds land (R-13ie-4)")
struct ArchivedIntakeTests {
    @Test func theOneTablePausesAnArchivedBook() {
        let open = IntakeDecision.BookFacts(
            isLive: true, isBook: true, rule: .readable, locked: false,
            seating: nil, maxPosts: nil, memberCount: 0, owned: false)
        var archived = open
        archived.archived = true
        let fresh = IntakeDecision.NoteFacts(
            matchesRule: true, pair: .fresh, memberedElsewhere: false, ownedElsewhere: false)
        #expect(IntakeDecision.intakeRuns(open))
        #expect(!IntakeDecision.intakeRuns(archived))
        for occasion: IntakeDecision.Occasion in [.event, .backfill, .catchUp] {
            #expect(IntakeDecision.verdict(book: archived, note: fresh, occasion: occasion) == .nothing)
        }
        #expect(!open.archived, "the default reads as every pre-13i-e builder did")
    }

    @Test func aLivingArchivedBookNeitherSeatsNorBellsOnTaggingOrStarring() throws {
        try withOperations { ops, db in
            let t = try ops.createTag(name: "t")
            let quiet = try ops.createReading(name: "quiet", kind: .book, querySpec: try rule(.tag(t.id)))
            let bells = try ops.createReading(
                name: "bells", kind: .book, querySpec: try rule(.star), intakeSeating: .arrivals)
            let control = try ops.createReading(name: "control", kind: .book, querySpec: try rule(.tag(t.id)))
            try ops.archiveReading(quiet.id)
            try ops.archiveReading(bells.id)
            let tagged = try note(ops, "tagged")
            let starred = try note(ops, "starred")

            _ = try ops.applyTag(t.id, toPost: tagged.id)
            try ops.setStarred(.post(starred.id), starred: true)

            #expect(try rows(db, quiet.id).isEmpty, "no seat while archived")
            #expect(try rows(db, bells.id).isEmpty, "no bell while archived")
            // The control proves the event fired: an unarchived twin seats it.
            #expect(try rows(db, control.id).map(\.postId) == [tagged.id])
        }
    }

    @Test func unarchivingALivingBookCatchesUpThroughArrivalsNeverQuietSeats() throws {
        try withOperations { ops, db in
            let t = try ops.createTag(name: "t")
            let book = try ops.createReading(name: "living", kind: .book, querySpec: try rule(.tag(t.id)))
            try ops.archiveReading(book.id)
            let gap = try note(ops, "gap")
            _ = try ops.applyTag(t.id, toPost: gap.id)
            #expect(try rows(db, book.id).isEmpty)

            try ops.unarchiveReading(book.id)

            let caught = try rows(db, book.id)
            #expect(caught.map(\.postId) == [gap.id])
            #expect(caught.map(\.status) == [.arrival], "gap = judgment: the bell, never a quiet seat")
            #expect(caught.allSatisfy { $0.deletedAt == nil })
        }
    }

    @Test func aRuleSetOnAnArchivedBookFiresNothingUntilTheUnarchive() throws {
        try withOperations { ops, db in
            let first = try ops.createTag(name: "first")
            let second = try ops.createTag(name: "second")
            let book = try ops.createReading(name: "b", kind: .book, querySpec: try rule(.tag(first.id)))
            let n = try note(ops, "n")
            _ = try ops.applyTag(second.id, toPost: n.id)
            try ops.archiveReading(book.id)

            try ops.setReadingQuerySpec(book.id, querySpec: try rule(.tag(second.id)))
            #expect(try rows(db, book.id).isEmpty, "the rule edit's catch-up is paused")

            try ops.unarchiveReading(book.id)
            #expect(try rows(db, book.id).map(\.status) == [.arrival])
        }
    }

    /// Every resume road stays paused while archived: un-finish, and Put back
    /// (which also returns the book ARCHIVED — the plan's edge: "the Trash
    /// road never launders it").
    @Test func reopeningOrRestoringAnArchivedBookStaysPaused() throws {
        try withOperations { ops, db in
            let t = try ops.createTag(name: "t")
            let book = try ops.createReading(name: "b", kind: .book, querySpec: try rule(.tag(t.id)))
            try ops.lockReading(book.id)
            try ops.archiveReading(book.id)
            let stamp = try archivedAt(db, "reading", book.id)
            let n = try note(ops, "n")
            _ = try ops.applyTag(t.id, toPost: n.id)

            try ops.unlockReading(book.id)
            #expect(try rows(db, book.id).isEmpty, "the un-finish catch-up is paused")

            try ops.deleteReading(book.id)                      // legal: archive is not protection
            try ops.restoreReading(book.id)
            #expect(try archivedAt(db, "reading", book.id) == stamp, "restored ARCHIVED, same stamp")
            #expect(try rows(db, book.id).isEmpty, "the restore catch-up is paused")

            try ops.unarchiveReading(book.id)
            #expect(try rows(db, book.id).map(\.status) == [.arrival])
        }
    }

    /// Her amendment, verbatim: *"if you want to add something to an archived
    /// book I think that's fine."* Every explicit add door lands normally.
    @Test func everyExplicitAddLandsOnAnArchivedBook() throws {
        try withOperations { ops, db in
            let t = try ops.createTag(name: "t")
            let book = try ops.createReading(
                name: "archived", kind: .book, querySpec: try rule(.tag(t.id)),
                intakeSeating: .arrivals)
            let waiting = try note(ops, "waiting")
            _ = try ops.applyTag(t.id, toPost: waiting.id)
            let arrival = try #require(try rows(db, book.id).first)
            #expect(arrival.status == .arrival)
            let elsewhere = try ops.createReading(name: "elsewhere", kind: .book)
            let moving = try note(ops, "moving")
            try ops.addPostToReading(moving.id, to: elsewhere.id)
            let source = try note(ops, "source")
            let added = try note(ops, "added")
            try ops.archiveReading(book.id)

            try ops.assertReadingAcceptsPosts(book.id)
            try ops.addPostToReading(added.id, to: book.id)
            let minted = try ops.newPostInReading(book.id, title: "minted")
            let seated = try ops.seatArrival(arrival.id)
            let moved = try ops.movePostIntoReading(moving.id, into: book.id)
            let copied = try ops.copyPostIntoReading(source.id, into: book.id)

            #expect(seated.status == .member && seated.deletedAt == nil)
            #expect(moved.severed.map(\.readingId) == [elsewhere.id])
            let members = try db.read {
                try String.fetchAll(
                    $0, sql: """
                        SELECT post_id FROM reading_post
                        WHERE reading_id = ? AND deleted_at IS NULL AND status = 'member'
                        ORDER BY position, id
                        """, arguments: [book.id])
            }
            #expect(Set(members) == [added.id, minted.id, waiting.id, moving.id, copied.copy.id])
            #expect(try archivedAt(db, "reading", book.id) != nil, "the book stays archived")
        }
    }

    /// P-13ie-U1-6: the OUTFLOW is the explicit act's own tagging, not
    /// ingestion INTO the book — it still rides an add on an archived book.
    @Test func theOutflowStillRidesAnExplicitAddOnAnArchivedBook() throws {
        try withOperations { ops, db in
            let out = try ops.createTag(name: "out")
            let book = try ops.createReading(name: "b", kind: .book, autoTagId: out.id)
            try ops.archiveReading(book.id)
            let n = try note(ops, "n")

            try ops.addPostToReading(n.id, to: book.id)

            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM post_tag WHERE post_id = ? AND tag_id = ? AND deleted_at IS NULL",
                [n.id, out.id]) == 1)
        }
    }
}

// MARK: - The gathering answers EMPTY everywhere its rule is read

@Suite("13i-e U1 — an archived gathering answers empty at every consumer (R-13ie-3)")
struct ArchivedGatheringReadersTests {
    @Test func everyReaderOfTheRuleSkipsAnArchivedGathering() throws {
        try withOperations { ops, db in
            let t = try ops.createTag(name: "t")
            let gathering = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try rule(.tag(t.id)))
            let n = try note(ops, "n", text: "three little words")
            _ = try ops.applyTag(t.id, toPost: n.id)

            struct Seen: Equatable {
                var assembly: [String]
                var chip: [String]
                var card: [String]
                var tucked: [String]
                var loose: [String]
                var words: Int?
            }
            func seen() throws -> Seen {
                try db.read { db in
                    let pool = try Queries.notePoolListing(db, window: 50)
                    return Seen(
                        assembly: try Queries.assembleReading(db, readingID: gathering.id).map(\.postID),
                        chip: try Queries.readingsContaining(db, postID: n.id).map(\.id),
                        card: try Queries.smartBookMembership(db, postIDs: [n.id])[n.id] ?? [],
                        tucked: pool.tucked.map(\.postID),
                        loose: pool.loose.map(\.postID),
                        words: try Queries.bookWordCounts(db)[gathering.id])
                }
            }
            let showing = Seen(
                assembly: [n.id], chip: [gathering.id], card: ["g"],
                tucked: [n.id], loose: [], words: 3)
            #expect(try seen() == showing)

            try ops.archiveReading(gathering.id)
            // The assembly, the chip's gathering leg, the Library card, the
            // Pool's tuck (its note re-classes LOOSE) and the word count all
            // answer empty.
            #expect(try seen() == Seen(
                assembly: [], chip: [], card: [], tucked: [], loose: [n.id], words: nil))

            try ops.unarchiveReading(gathering.id)
            #expect(try seen() == showing)
        }
    }

    /// The bind reads the assembly — an archived gathering's is empty, so the
    /// bind materializes nothing (no new refusal), and the unarchive's
    /// catch-up bells the matches (P-13ie-U1-5).
    @Test func bindingAnArchivedGatheringBindsItsEmptyAssembly() throws {
        try withOperations { ops, db in
            let t = try ops.createTag(name: "t")
            let gathering = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try rule(.tag(t.id)))
            let n = try note(ops, "n")
            _ = try ops.applyTag(t.id, toPost: n.id)
            try ops.archiveReading(gathering.id)
            #expect(try db.read { try Queries.bindOwnedNotesPreview($0, readingID: gathering.id) }.isEmpty)

            let bound = try ops.convertSmartReadingToCurated(gathering.id)

            #expect(bound.membershipIDs.isEmpty)
            #expect(bound.reading.kind == .book && bound.reading.archivedAt != nil)
            try ops.unarchiveReading(gathering.id)
            #expect(try rows(db, gathering.id).map(\.status) == [.arrival])
        }
    }
}

// MARK: - The Bookcase, the Archived feed, the catalog, the pickers, membership

@Suite("13i-e U1 — archived: off the Bookcase, under Archived, membership still a fact")
struct ArchivedListingTests {
    @Test func theBookcaseListsNoArchivedReadingOnEitherArm() throws {
        try withOperations { ops, db in
            let t = try ops.createTag(name: "t")
            let kept = try ops.createReading(name: "kept", kind: .book)
            let plain = try ops.createReading(name: "plain", kind: .book)
            let gathering = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try rule(.tag(t.id)))
            let n = try note(ops, "n", text: "two words")
            try ops.addPostToReading(n.id, to: plain.id)
            try ops.archiveReading(plain.id)
            try ops.archiveReading(gathering.id)

            #expect(try db.read { try Queries.bookshelf($0, wingID: "") }.map(\.reading.id)
                    == [kept.id])
            #expect(try db.read { try Queries.bookshelf($0) }.map(\.reading.id) == [kept.id],
                    "the phone's all-wings arm too")
            #expect(try db.read { try Queries.bookcase($0, wingID: "") }.books.map(\.reading.id)
                    == [kept.id])
            #expect(Set(try db.read { try Queries.bookcaseAggregates($0, wingID: "") }
                .lastEdited.keys) == [kept.id])
            #expect(try db.read { try Queries.bookWordCounts($0) }[plain.id] == nil)
            // The pickers and the seeders' existence reads KEEP them.
            #expect(Set(try db.read { try Queries.readings($0) }.map(\.id))
                    == [kept.id, plain.id, gathering.id])
            // The Archived surface's feed: newest archive first.
            #expect(try db.read { try Queries.archivedReadings($0) }.map(\.id)
                    == [gathering.id, plain.id])
            #expect(try db.read { try Queries.archivedReadings($0, wingID: "") }.map(\.id)
                    == [gathering.id, plain.id])
            #expect(try db.read { try Queries.archivedReadings($0, limit: 1) }.map(\.id)
                    == [gathering.id])
            try ops.unarchiveReading(plain.id)
            #expect(try db.read { try Queries.bookshelf($0, wingID: "") }.map(\.reading.id)
                    == [kept.id, plain.id])
            #expect(try db.read { try Queries.archivedReadings($0) }.map(\.id) == [gathering.id])
        }
    }

    @Test func theArchivedFeedIsScopedByWing() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "away")
            let home = try ops.createReading(name: "home book", kind: .book)
            let away = try ops.createReading(name: "away book", kind: .book, wingId: wing.id)
            try ops.archiveReading(home.id)
            try ops.archiveReading(away.id)
            #expect(try db.read { try Queries.archivedReadings($0, wingID: "") }.map(\.id)
                    == [home.id])
            #expect(try db.read { try Queries.archivedReadings($0, wingID: wing.id) }.map(\.id)
                    == [away.id])
            #expect(try db.read { try Queries.bookshelf($0, wingID: wing.id) }.isEmpty)
        }
    }

    /// P-13ie-U1-9 (the plan's edge): an archived book leaves the catalog
    /// exactly as an archived note always has.
    @Test func theCatalogDropsAnArchivedBookAsItAlwaysDroppedAnArchivedNote() throws {
        try withOperations { ops, db in
            let kept = try ops.createReading(name: "Orbit", kind: .book)
            let away = try ops.createReading(name: "Orchard", kind: .book)
            try ops.archiveReading(away.id)
            let books = { (query: String) in
                try db.read { try Queries.searchCatalog($0, query: query, limitPerKind: 50) }
                    .filter { $0.kind == .book }.map(\.id)
            }
            #expect(try books("") == [kept.id])
            #expect(try books("Orch").isEmpty)
            try ops.unarchiveReading(away.id)
            #expect(try books("Orch") == [away.id])
        }
    }

    /// P-13ie-U1-11 — her E13 words: *"archived/deleted books don't count."*
    @Test func anArchivedBooksNameIsFreeAtTheDoor() throws {
        try withOperations { ops, _ in
            let ideas = try ops.createReading(name: "Ideas", kind: .book)
            #expect(throws: OperationError.duplicateBookName(name: "Ideas")) {
                try ops.assertBookNameIsFree("ideas")
            }
            try ops.archiveReading(ideas.id)
            try ops.assertBookNameIsFree("ideas")
            try ops.unarchiveReading(ideas.id)
            #expect(throws: OperationError.duplicateBookName(name: "Ideas")) {
                try ops.assertBookNameIsFree("ideas")
            }
        }
    }

    /// P-13ie-U1-8: membership is a fact — visibility is the book's own state.
    @Test func membershipInAnArchivedBookIsStillAFact() throws {
        try withOperations { ops, db in
            let plain = try ops.createReading(name: "plain", kind: .book)
            let only = try note(ops, "only in an archived book")
            try ops.addPostToReading(only.id, to: plain.id)
            let owned = try ops.createReading(name: "owned", kind: .book)
            try ops.setReadingOwned(owned.id, owned: true)
            let claimed = try note(ops, "owned by an archived book")
            try ops.addPostToReading(claimed.id, to: owned.id)
            let other = try ops.createReading(name: "other", kind: .book)
            try ops.archiveReading(plain.id)
            try ops.archiveReading(owned.id)

            let pool = try db.read { try Queries.notePoolListing($0, window: 50) }
            #expect(!(pool.loose + pool.tucked).map(\.postID).contains(only.id),
                    "a note whose only book is archived is not bookless")
            #expect(try db.read { try Queries.readingsContaining($0, postID: only.id) }.map(\.id)
                    == [plain.id], "the chip still names it (the faces mute it)")
            #expect(throws: OperationError.noteOwnedElsewhere(
                postID: claimed.id, readingID: other.id, owner: owned.id)) {
                try ops.addPostToReading(claimed.id, to: other.id)
            }
        }
    }

    /// P-13ie-U1-10: the shipped archived-note treatment — a starred thing
    /// that is archived stays in Starred.
    @Test func anArchivedStarredBookStaysInStarred() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "starred", kind: .book)
            try ops.setStarred(.reading(book.id), starred: true)
            try ops.archiveReading(book.id)
            #expect(try db.read { try Queries.starred($0) }.map(\.target).contains(.reading(book.id)))
        }
    }

    /// The edges: Finish/Seal/Own on an archived book are legal (no
    /// unarchive-first gate); a duplicate is born unarchived (configuration,
    /// never state); a wing move rides archived, same stamp.
    @Test func archiveIsOrthogonalToFinishSealOwnDuplicateAndTheWingMove() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "b", kind: .book)
            let n = try note(ops, "n")
            try ops.addPostToReading(n.id, to: book.id)
            try ops.archiveReading(book.id)
            let stamp = try #require(try archivedAt(db, "reading", book.id))

            try ops.lockReading(book.id)
            try ops.unlockReading(book.id)
            _ = try ops.sealReading(book.id)
            #expect(try db.fetchString("SELECT sealed_at FROM reading WHERE id = ?", [book.id]) != nil)
            try ops.unsealReading(book.id)
            _ = try ops.setReadingOwned(book.id, owned: true)
            #expect(try archivedAt(db, "reading", book.id) == stamp)

            let twin = try ops.duplicateReading(book.id, name: "twin", deep: true)
            #expect(twin.reading.archivedAt == nil)
            #expect(try archivedAt(db, "reading", twin.reading.id) == nil)

            let wing = try ops.createWing(name: "away")
            _ = try ops.moveReadingToWing(book.id, to: wing.id)
            #expect(try archivedAt(db, "reading", book.id) == stamp, "it rides archived")
            #expect(try db.read { try Queries.archivedReadings($0, wingID: wing.id) }.map(\.id)
                    == [book.id])
        }
    }
}
