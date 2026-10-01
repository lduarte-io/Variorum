import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// 13i-c U2 — FINISHED AND SEALED, exact state transitions (the 13i-c plan §5;
/// the sitting record §5, §24; R-13ic-3). Every test names the rows: the
/// book's `locked`/`sealed_at`, each member's `locked`/`locked_at`, the forks'
/// slots, the arrivals' tombstones, the insurance commits.
@Suite("13i-c U2 — seal · unseal · the finish ladder's guards")
struct BookSealTests {
    private func rule(_ term: RuleTerm) throws -> String {
        try #require(try RuleGrammar.encode(term))
    }

    private func note(
        _ ops: Operations, _ title: String
    ) throws -> (post: Container, variantID: String) {
        let post = try ops.createPost(title: title)
        let minted = try ops.seedBlock(in: post.id, text: "the text of \(title)")
        return (post, minted.variant.id)
    }

    private func post(_ db: AppDatabase, _ id: String) throws -> Container {
        try #require(try db.read { try Container.fetchOne($0, key: id) })
    }

    private func reading(_ db: AppDatabase, _ id: String) throws -> Reading {
        try #require(try db.read { try Reading.fetchOne($0, key: id) })
    }

    private func members(_ db: AppDatabase, _ readingID: String) throws -> [String] {
        try db.read { try Queries.assembleReading($0, readingID: readingID).map(\.postID) }
    }

    private func stamp(_ date: Date?) -> String? {
        date.map { DateFormatter.variorumISO8601.string(from: $0) }
    }

    @Test func sealingForksSharedMembersFinishesStampsAndSealsEveryMemberOnTheBooksStamp() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let book = try ops.createReading(
                name: "book", kind: .book, querySpec: try rule(.tag(work.id)),
                intakeSeating: .arrivals)
            let elsewhere = try ops.createReading(name: "elsewhere", kind: .book)
            let sole = try note(ops, "sole")
            let shared = try note(ops, "shared")
            let early = try note(ops, "sealed early")
            for n in [sole, shared, early] { try ops.addPostToReading(n.post.id, to: book.id) }
            try ops.addPostToReading(shared.post.id, to: elsewhere.id)
            try ops.lockPost(early.post.id)                 // its own, earlier stamp
            let earlyStamp = try post(db, early.post.id).lockedAt
            try ops.autosave(sole.variantID, text: "edited, never saved", charDelta: 5)
            let waiting = try note(ops, "waiting")
            _ = try ops.applyTag(work.id, toPost: waiting.post.id)   // an arrival (the dial)

            let preview = try db.read { try Queries.sealPreview($0, readingID: book.id) }
            #expect(preview.forks.map(\.postID) == [shared.post.id])
            #expect(preview.pendingArrivals == 1)

            let result = try ops.sealReading(book.id)

            let sealed = try reading(db, book.id)
            let bookStamp = try #require(stamp(sealed.sealedAt))
            #expect(sealed.locked)                                   // finished
            #expect(result.forked.map(\.originalID) == [shared.post.id])
            let copyID = try #require(result.forked.first?.copyID)
            #expect(try members(db, book.id).contains(copyID))
            #expect(!(try members(db, book.id).contains(shared.post.id)))
            // Every member sealed on the BOOK's exact stamp…
            for id in [sole.post.id, copyID] {
                #expect(try post(db, id).locked)
                #expect(stamp(try post(db, id).lockedAt) == bookStamp)
            }
            // …except the one sealed on its own, whose stamp stands.
            #expect(try post(db, early.post.id).lockedAt == earlyStamp)
            // The fork's original keeps its other life, unsealed.
            #expect(!(try post(db, shared.post.id).locked))
            #expect(try members(db, elsewhere.id) == [shared.post.id])
            // The finish dismissed the pending arrival on the stamp.
            #expect(try db.fetchString(
                "SELECT deleted_at FROM reading_post WHERE reading_id = ? AND post_id = ?",
                [book.id, waiting.post.id]) == bookStamp)
            // The dirty buffer was insured by one quiet auto commit.
            #expect(try db.fetchString(
                "SELECT kind FROM commit_point WHERE variant_id = ?", [sole.variantID]) == "auto")
            // Sealed = the book is done: a member's text refuses.
            #expect(throws: OperationError.lockedPost(id: sole.post.id)) {
                try ops.autosave(sole.variantID, text: "no", charDelta: 1)
            }
        }
    }

    @Test func sealingAnOwnedBookNeedsNoForks() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "owned", kind: .book)
            try ops.setReadingOwned(book.id, owned: true)
            let a = try note(ops, "a")
            try ops.addPostToReading(a.post.id, to: book.id)
            #expect(try db.read { try Queries.sealPreview($0, readingID: book.id) }.forks.isEmpty)
            #expect(try ops.sealReading(book.id).forked.isEmpty)
            #expect(try members(db, book.id) == [a.post.id])
            #expect(try post(db, a.post.id).locked)
        }
    }

    @Test func sealingAFinishedBookKeepsItsFinishAndAGatheringRefuses() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "book", kind: .book)
            try ops.lockReading(book.id)
            #expect(try db.read { try Queries.sealPreview($0, readingID: book.id) }
                .pendingArrivals == 0)
            try ops.sealReading(book.id)
            #expect(try reading(db, book.id).locked)
            try db.clearOutbox()
            #expect(try ops.sealReading(book.id).forked.isEmpty)   // sealed: a no-op
            try ops.lockReading(book.id)                             // sealed: a no-op too
            #expect(try db.fetchInt("SELECT COUNT(*) FROM sync_outbox") == 0)

            let t = try ops.createTag(name: "t")
            let gathering = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try rule(.tag(t.id)))
            #expect(throws: OperationError.wrongReadingKind(id: gathering.id, expected: .book)) {
                try ops.sealReading(gathering.id)
            }
        }
    }

    @Test func unsealingReopensTheBookAndUnsealsOnlyTheMembersSealedTogether() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let book = try ops.createReading(
                name: "book", kind: .book, querySpec: try rule(.tag(work.id)))
            let a = try note(ops, "a")
            let early = try note(ops, "early")
            try ops.addPostToReading(a.post.id, to: book.id)
            try ops.addPostToReading(early.post.id, to: book.id)
            try ops.lockPost(early.post.id)
            try ops.sealReading(book.id)
            let gap = try note(ops, "matched while sealed")
            _ = try ops.applyTag(work.id, toPost: gap.post.id)   // paused: nothing lands
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE post_id = ?", [gap.post.id]) == 0)

            try ops.unsealReading(book.id)

            let reopened = try reading(db, book.id)
            #expect(!reopened.locked && reopened.sealedAt == nil)   // OPEN in one step
            #expect(!(try post(db, a.post.id).locked))
            #expect(try post(db, early.post.id).locked)             // independent: stays
            // The un-finish CATCH-UP: the gap's match waits at Arrivals.
            #expect(try db.fetchString(
                "SELECT status FROM reading_post WHERE reading_id = ? AND post_id = ?",
                [book.id, gap.post.id]) == "arrival")
            try ops.autosave(a.variantID, text: "editable again", charDelta: 3)
        }
    }

    @Test func theTwoStatesNeverContradict() throws {
        try withOperations { ops, _ in
            let book = try ops.createReading(name: "book", kind: .book)
            #expect(throws: OperationError.readingNotSealed(id: book.id)) {
                try ops.unsealReading(book.id)
            }
            try ops.sealReading(book.id)
            // Reopen is not a door on a SEALED book — Unseal is (R-13ic-3).
            #expect(throws: OperationError.readingSealed(id: book.id)) {
                try ops.unlockReading(book.id)
            }
            #expect(throws: OperationError.lockedReading(id: book.id)) {
                try ops.setReadingOwned(book.id, owned: true)
            }
        }
    }

    @Test func aDeletedSealedBookLeavesItsSealsAndPutBackLetsUnsealWorkAgain() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "book", kind: .book)
            let a = try note(ops, "a")
            try ops.addPostToReading(a.post.id, to: book.id)
            try ops.sealReading(book.id)
            try ops.deleteReading(book.id)
            #expect(try post(db, a.post.id).locked)   // a real post seal (P-13ic-6)

            try ops.restoreReading(book.id)
            #expect(try reading(db, book.id).sealedAt != nil)
            try ops.unsealReading(book.id)
            #expect(!(try post(db, a.post.id).locked))
        }
    }

    /// Found by `OwnershipSoakTests` (seed 3, step 95): a note deleted while
    /// a member, its book SEALED while it lay in the Trash, then put back —
    /// the exact-stamp revival brought it into the sealed book UNSEALED (an
    /// editable member of a book whose text is immutable). The revival now
    /// does what the door would (a sealed book refuses every add): the note
    /// comes back, but not into the sealed book (PROVISIONAL P-13ic-U2-6).
    @Test func aNoteInTheTrashWhenItsBookWasSealedComesBackOutsideTheSealedBook() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "book", kind: .book)
            let kept = try note(ops, "kept")
            let away = try note(ops, "in the trash")
            try ops.addPostToReading(kept.post.id, to: book.id)
            try ops.addPostToReading(away.post.id, to: book.id)
            try ops.deleteContainer(away.post.id)
            try ops.sealReading(book.id)

            try ops.restoreContainer(away.post.id)

            #expect(try db.deletedAt("container", away.post.id) == nil)   // it came back
            #expect(try members(db, book.id) == [kept.post.id])           // not into the edition
            #expect(!(try post(db, away.post.id).locked))
            // A note SEALED with the book still comes home with it.
            try ops.deleteContainer(kept.post.id)
            try ops.restoreContainer(kept.post.id)
            #expect(try members(db, book.id) == [kept.post.id])
        }
    }

    @Test func aSealedBookPutBackTakesBackOnlyItsSealedMembers() throws {
        // P-13ic-6's other half: a member unsealed by hand while the book lay
        // in the Trash does not rejoin the sealed edition.
        try withOperations { ops, db in
            let book = try ops.createReading(name: "book", kind: .book)
            let a = try note(ops, "a")
            let b = try note(ops, "b")
            try ops.addPostToReading(a.post.id, to: book.id)
            try ops.addPostToReading(b.post.id, to: book.id)
            try ops.sealReading(book.id)
            try ops.deleteReading(book.id)
            try ops.unlockPost(b.post.id)        // a real post seal, lifted per note

            try ops.restoreReading(book.id)

            #expect(try members(db, book.id) == [a.post.id])
            #expect(try db.read { try Queries.noteMemberships($0, postID: b.post.id) }.isEmpty)
        }
    }

    @Test func finishedMeansTheContentsAreDoneButTheWritingCanStillChange() throws {
        // Lesson 6, first sentence (the sitting record §25): "Finished means
        // the table of contents is done — the writing inside can still change."
        try withOperations { ops, _ in
            let book = try ops.createReading(name: "book", kind: .book)
            let a = try note(ops, "a")
            try ops.addPostToReading(a.post.id, to: book.id)
            try ops.lockReading(book.id)
            try ops.autosave(a.variantID, text: "still polishing", charDelta: 4)
            #expect(throws: OperationError.lockedReading(id: book.id)) {
                try ops.addPostToReading(try note(ops, "b").post.id, to: book.id)
            }
        }
    }
}
