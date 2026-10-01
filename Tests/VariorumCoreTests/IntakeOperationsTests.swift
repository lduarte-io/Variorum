import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// 13i-b U1 — INTAKE, exact state transitions per op and occasion (the 13i-b
/// plan §2; the sitting record §4, §14.1–6, §19, §24). Every test names the
/// rows written — status, liveness, section, position, stamps — never only a
/// count. The pure table's arms live in `IntakeDecisionTests`; this suite is
/// the wiring: which acts are heard, what lands, and in which transaction.
@Suite("13i-b U1 — intake: events, backfill, catch-up, finishing, judgment")
struct IntakeOperationsTests {
    // MARK: - Fixtures

    private func rule(_ term: RuleTerm) throws -> String {
        try #require(try RuleGrammar.encode(term))
    }

    /// A living plain book on one rule.
    private func livingBook(
        _ ops: Operations, _ term: RuleTerm, name: String = "living",
        maxPosts: Int? = nil, seating: IntakeSeating? = nil, autoTagId: String? = nil
    ) throws -> Reading {
        try ops.createReading(
            name: name, kind: .book, querySpec: try rule(term), maxPosts: maxPosts,
            intakeSeating: seating, autoTagId: autoTagId)
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

    private func members(_ db: AppDatabase, _ readingID: String) throws -> [String] {
        try db.read { try Queries.assembleReading($0, readingID: readingID).map(\.postID) }
    }

    private func liveTagIDs(_ db: AppDatabase, _ postID: String) throws -> Set<String> {
        try db.read {
            Set(try String.fetchAll(
                $0, sql: "SELECT tag_id FROM post_tag WHERE post_id = ? AND deleted_at IS NULL",
                arguments: [postID]))
        }
    }

    // MARK: - The tagging EVENT

    @Test func taggingANoteSeatsItAtTheEndUnsectionedInTheActsOwnTransaction() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let book = try livingBook(ops, .tag(work.id))
            let chapter = try ops.createSection(in: book.id, name: "one")
            let early = try ops.createPost(title: "early")
            try ops.addPostToReading(early.id, to: book.id)
            try ops.assignPostToSection(early.id, in: book.id, section: chapter.id)
            try db.clearOutbox()

            let note = try ops.createPost(title: "tagged")
            let application = try ops.applyTag(work.id, toPost: note.id)

            let all = try rows(db, book.id)
            try #require(all.count == 2)
            let seated = try #require(all.last)
            #expect(seated.postId == note.id)
            #expect(seated.status == .member)
            #expect(seated.deletedAt == nil)
            #expect(seated.sectionId == nil)                 // unsectioned (§4)
            #expect(seated.position > all[0].position)       // at the END (§14.2)
            // The act's own transaction: one clock read stamps both rows.
            #expect(seated.createdAt == application.createdAt)
            // An ordinary row through the operations API (S1): the outbox has it.
            #expect(try db.outboxContains("reading_post", seated.id))
            #expect(try members(db, book.id) == [early.id, note.id])
        }
    }

    @Test func subtreeMatchingHearsAChildTagButNeverAParent() throws {
        try withOperations { ops, db in
            let video = try ops.createTag(name: "video")
            let ideas = try ops.createTag(parent: video.id, name: "ideas")
            let broad = try livingBook(ops, .tag(video.id), name: "broad")
            let narrow = try livingBook(ops, .tag(ideas.id), name: "narrow")

            let child = try ops.createPost(title: "child-tagged")
            _ = try ops.applyTag(ideas.id, toPost: child.id)
            #expect(try members(db, broad.id) == [child.id])   // video/ heard video/ideas
            #expect(try members(db, narrow.id) == [child.id])

            let parent = try ops.createPost(title: "parent-tagged")
            _ = try ops.applyTag(video.id, toPost: parent.id)
            #expect(try members(db, broad.id) == [child.id, parent.id])
            #expect(try members(db, narrow.id) == [child.id])  // video/ideas never hears video
        }
    }

    @Test func anActTheRuleDoesNotReferenceIsNotAnEventForIt() throws {
        // `NOT #x` matches nearly everything, but intake fires on the ACT,
        // never on state (§4): tagging #y is not an act this rule hears.
        try withOperations { ops, db in
            let x = try ops.createTag(name: "x")
            let y = try ops.createTag(name: "y")
            let book = try livingBook(ops, .not(.tag(x.id)))
            let note = try ops.createPost(title: "n")
            _ = try ops.applyTag(y.id, toPost: note.id)
            #expect(try rows(db, book.id).isEmpty)
        }
    }

    @Test func aBooleanRuleSeatsOnlyOnTheActThatCompletesTheMatch() throws {
        try withOperations { ops, db in
            let a = try ops.createTag(name: "a")
            let b = try ops.createTag(name: "b")
            let book = try livingBook(ops, .and([.tag(a.id), .tag(b.id)]))
            let note = try ops.createPost(title: "n")
            _ = try ops.applyTag(a.id, toPost: note.id)
            #expect(try rows(db, book.id).isEmpty)           // heard, no match yet
            _ = try ops.applyTag(b.id, toPost: note.id)
            #expect(try members(db, book.id) == [note.id])
        }
    }

    @Test func gatheringsFinishedDeadAndMalformedBooksMaterializeNothing() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let gathering = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try rule(.tag(work.id)))
            let finished = try livingBook(ops, .tag(work.id), name: "finished")
            try ops.lockReading(finished.id)
            let dead = try livingBook(ops, .tag(work.id), name: "dead")
            try ops.deleteReading(dead.id)
            let broken = try ops.createReading(name: "broken", kind: .book)
            try ops.setReadingQuerySpec(broken.id, querySpec: "{not json")

            let note = try ops.createPost(title: "n")
            _ = try ops.applyTag(work.id, toPost: note.id)

            #expect(try rows(db, gathering.id).isEmpty)
            #expect(try rows(db, finished.id).isEmpty)
            #expect(try rows(db, dead.id).isEmpty)
            #expect(try rows(db, broken.id).isEmpty)
            // The gathering still SHOWS it (derived, §3).
            #expect(try members(db, gathering.id) == [note.id])
        }
    }

    @Test func everyLivingBookHearsOneActAndAnArchivedNoteIsNeverSeated() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let one = try livingBook(ops, .tag(work.id), name: "one")
            let two = try livingBook(ops, .tag(work.id), name: "two")
            let note = try ops.createPost(title: "n")
            _ = try ops.applyTag(work.id, toPost: note.id)
            #expect(try members(db, one.id) == [note.id])
            #expect(try members(db, two.id) == [note.id])

            let shelved = try ops.createPost(title: "archived")
            try ops.archiveContainer(shelved.id)
            _ = try ops.applyTag(work.id, toPost: shelved.id)
            #expect(try rows(db, one.id).count == 1)
        }
    }

    @Test func theGatheringCollectDoorIsAnApplyingActToo() throws {
        // R98 recast (§14.6): adding to a GATHERING applies the tag — and the
        // living book on that tag hears the act.
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let gathering = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try rule(.tag(work.id)))
            let book = try livingBook(ops, .tag(work.id))
            let note = try ops.createPost(title: "n")
            _ = try ops.collectPostIntoSmartReading(note.id, into: gathering.id)
            #expect(try members(db, book.id) == [note.id])
        }
    }

    // MARK: - Capacity and the join dial (§4, §14.3)

    @Test func atCapacityTheMatchWaitsAtTheDoorAndIsNeverCounted() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let book = try livingBook(ops, .tag(work.id), maxPosts: 1)
            let first = try ops.createPost(title: "first")
            _ = try ops.applyTag(work.id, toPost: first.id)
            let second = try ops.createPost(title: "second")
            _ = try ops.applyTag(work.id, toPost: second.id)

            let all = try rows(db, book.id)
            try #require(all.count == 2)
            #expect(all.map(\.postId) == [first.id, second.id])
            #expect(all.map(\.status) == [.member, .arrival])
            #expect(all[1].deletedAt == nil)
            #expect(all[1].sectionId == nil)
            #expect(try members(db, book.id) == [first.id])
            let shelf = try db.read { try Queries.bookshelf($0) }
            #expect(shelf.first { $0.reading.id == book.id }?.postCount == 1)
        }
    }

    @Test func theJoinDialSendsEveryMatchToArrivals() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let book = try livingBook(ops, .tag(work.id), seating: .arrivals)
            let note = try ops.createPost(title: "n")
            _ = try ops.applyTag(work.id, toPost: note.id)
            #expect(try rows(db, book.id).map(\.status) == [.arrival])
            #expect(try members(db, book.id).isEmpty)
        }
    }

    // MARK: - Decided pairs (tombstone-means-decided, §4 / §20 / §24)

    @Test func aLiveRowIsNeverDuplicatedByAnotherAct() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let sub = try ops.createTag(parent: work.id, name: "sub")
            let book = try livingBook(ops, .tag(work.id), maxPosts: 0 + 1)
            let filler = try ops.createPost(title: "filler")
            _ = try ops.applyTag(work.id, toPost: filler.id)
            let note = try ops.createPost(title: "n")
            _ = try ops.applyTag(work.id, toPost: note.id)   // → arrival (full)
            _ = try ops.applyTag(sub.id, toPost: note.id)    // a second act: still one bell
            let mine = try rows(db, book.id).filter { $0.postId == note.id }
            try #require(mine.count == 1)
            #expect(mine[0].status == .arrival)
        }
    }

    @Test func aRemovedMemberIsNeverReAddedEvenByAFreshAct() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let book = try livingBook(ops, .tag(work.id))
            let note = try ops.createPost(title: "n")
            _ = try ops.applyTag(work.id, toPost: note.id)
            try ops.removePostFromReading(note.id, from: book.id)
            try ops.removeTag(work.id, fromPost: note.id)
            _ = try ops.applyTag(work.id, toPost: note.id)   // a FRESH act
            let all = try rows(db, book.id)
            try #require(all.count == 1)                     // the tombstone alone
            #expect(all[0].deletedAt != nil)
            #expect(all[0].status == .member)
        }
    }

    @Test func aDismissedArrivalNeverReturnsOnRuleMatchButAFreshActRingsAgain() throws {
        // §24's consequence, built (P-13ib-U1-1): the dismissal decides the
        // pair against STATE — but a fresh tagging act returns the note to
        // Arrivals (never seated over her "no"), as a NEW row; the dismissal
        // record stays.
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let child = try ops.createTag(parent: work.id, name: "child")
            let other = try ops.createTag(name: "other")
            let book = try livingBook(ops, .tag(work.id), seating: .arrivals)
            let note = try ops.createPost(title: "n")
            _ = try ops.applyTag(work.id, toPost: note.id)
            let bell = try #require(try rows(db, book.id).first)
            try ops.dismissArrival(bell.id)

            // Not an act this rule hears: nothing.
            _ = try ops.applyTag(other.id, toPost: note.id)
            #expect(try rows(db, book.id).count == 1)
            // A fresh act it hears (a child of the rule's tag): back at the door.
            _ = try ops.applyTag(child.id, toPost: note.id)
            let all = try rows(db, book.id)
            try #require(all.count == 2)
            #expect(all[0].id == bell.id && all[0].deletedAt != nil)
            #expect(all[1].status == .arrival && all[1].deletedAt == nil)
        }
    }

    @Test func aDismissalNeverYieldsToASeatEvenWithRoomAndTheDialOnAuto() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let book = try livingBook(ops, .tag(work.id), maxPosts: 1)
            let filler = try ops.createPost(title: "filler")
            _ = try ops.applyTag(work.id, toPost: filler.id)
            let note = try ops.createPost(title: "n")
            _ = try ops.applyTag(work.id, toPost: note.id)          // full → bell
            try ops.dismissArrival(try #require(try rows(db, book.id).last).id)
            try ops.setReadingMaxPosts(book.id, maxPosts: nil)       // room now
            try ops.removeTag(work.id, fromPost: note.id)
            _ = try ops.applyTag(work.id, toPost: note.id)           // fresh act
            let mine = try rows(db, book.id).filter { $0.postId == note.id && $0.deletedAt == nil }
            #expect(mine.map(\.status) == [.arrival])
        }
    }

    // MARK: - Non-events (§19, ratified §24)

    @Test func untaggingAndUnstarringNeverEvict() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let byTag = try livingBook(ops, .tag(work.id), name: "by tag")
            let byStar = try livingBook(ops, .star, name: "by star")
            let note = try ops.createPost(title: "n")
            _ = try ops.applyTag(work.id, toPost: note.id)
            try ops.setStarred(.post(note.id), starred: true)
            #expect(try members(db, byTag.id) == [note.id])
            #expect(try members(db, byStar.id) == [note.id])

            try ops.removeTag(work.id, fromPost: note.id)
            try ops.setStarred(.post(note.id), starred: false)
            #expect(try members(db, byTag.id) == [note.id])
            #expect(try members(db, byStar.id) == [note.id])
            #expect(try rows(db, byTag.id).allSatisfy { $0.deletedAt == nil })
        }
    }

    // MARK: - The starring EVENT

    @Test func starringANoteIsHeardByStarRulesAndTheTaggingActCarriesTheStarContext() throws {
        try withOperations { ops, db in
            let a = try ops.createTag(name: "a")
            let starOnly = try livingBook(ops, .star, name: "starred")
            let both = try livingBook(ops, .and([.tag(a.id), .star]), name: "a and starred")

            // Star first, then tag: the TAG act completes `a ∧ star` — so
            // the tagging event must probe with the live star list.
            let first = try ops.createPost(title: "first")
            try ops.setStarred(.post(first.id), starred: true)
            #expect(try members(db, starOnly.id) == [first.id])
            #expect(try rows(db, both.id).isEmpty)
            _ = try ops.applyTag(a.id, toPost: first.id)
            #expect(try members(db, both.id) == [first.id])

            // Tag first, then star: the STAR act completes it.
            let second = try ops.createPost(title: "second")
            _ = try ops.applyTag(a.id, toPost: second.id)
            #expect(try members(db, both.id) == [first.id])
            try ops.setStarred(.post(second.id), starred: true)
            #expect(try members(db, both.id) == [first.id, second.id])
            #expect(try members(db, starOnly.id) == [first.id, second.id])
        }
    }

    @Test func starringABookOrReStarringANoteIsNoEvent() throws {
        try withOperations { ops, db in
            // The dial on "wait at Arrivals", so a dismissal would visibly
            // ring again if a re-star WERE an act (P-13ib-U1-1).
            let book = try livingBook(ops, .star, seating: .arrivals)
            let other = try ops.createReading(name: "plain", kind: .book)
            try ops.setStarred(.reading(other.id), starred: true)
            #expect(try rows(db, book.id).isEmpty)

            let note = try ops.createPost(title: "n")
            try ops.setStarred(.post(note.id), starred: true)
            try ops.dismissArrival(try #require(try rows(db, book.id).first).id)
            try ops.setStarred(.post(note.id), starred: true)   // already starred: no write, no act
            try #require(try rows(db, book.id).count == 1)
            #expect(try rows(db, book.id)[0].deletedAt != nil)
            // A real fresh act (un-star, star) rings again.
            try ops.setStarred(.post(note.id), starred: false)
            try ops.setStarred(.post(note.id), starred: true)
            #expect(try rows(db, book.id).filter { $0.deletedAt == nil }.map(\.status) == [.arrival])
        }
    }

    // MARK: - BACKFILL (creation-time — birth = intent, §4)

    @Test func aBookBornWithARuleSeatsItsCurrentMatchesInCreationOrder() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            var notes: [Container] = []
            for i in 0..<3 {
                let n = try ops.createPost(title: "n\(i)")
                _ = try ops.applyTag(work.id, toPost: n.id)
                notes.append(n)
            }
            let stray = try ops.createPost(title: "untagged")
            let book = try livingBook(ops, .tag(work.id))

            let all = try rows(db, book.id)
            #expect(all.map(\.postId) == notes.map(\.id))
            #expect(all.allSatisfy { $0.status == .member && $0.sectionId == nil })
            #expect(all.allSatisfy { $0.createdAt == book.createdAt })   // the birth's transaction
            #expect(all.map(\.position) == all.map(\.position).sorted())
            #expect(!all.contains { $0.postId == stray.id })
        }
    }

    @Test func backfillHonorsCapacityAndTheDial() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            var notes: [String] = []
            for i in 0..<3 {
                let n = try ops.createPost(title: "n\(i)")
                _ = try ops.applyTag(work.id, toPost: n.id)
                notes.append(n.id)
            }
            let capped = try livingBook(ops, .tag(work.id), name: "capped", maxPosts: 2)
            #expect(try rows(db, capped.id).map(\.status) == [.member, .member, .arrival])
            #expect(try rows(db, capped.id).map(\.postId) == notes)

            let guarded = try livingBook(ops, .tag(work.id), name: "guarded", seating: .arrivals)
            #expect(try rows(db, guarded.id).map(\.status) == [.arrival, .arrival, .arrival])
        }
    }

    @Test func aRuleSetOnARuleLessBookIsBackfillAndHonorsDecidedPairs() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let book = try ops.createReading(name: "hand-made", kind: .book)
            let kept = try ops.createPost(title: "kept")
            try ops.addPostToReading(kept.id, to: book.id)
            let removed = try ops.createPost(title: "removed")
            try ops.addPostToReading(removed.id, to: book.id)
            try ops.removePostFromReading(removed.id, from: book.id)
            let fresh = try ops.createPost(title: "fresh")
            for n in [kept, removed, fresh] { _ = try ops.applyTag(work.id, toPost: n.id) }
            #expect(try rows(db, book.id).count == 2)     // rule-less: no intake yet

            try ops.setReadingQuerySpec(book.id, querySpec: try rule(.tag(work.id)))
            let all = try rows(db, book.id)
            try #require(all.count == 3)
            #expect(all[2].postId == fresh.id && all[2].status == .member)
            #expect(try members(db, book.id) == [kept.id, fresh.id])
        }
    }

    @Test func aGatheringBornWithARuleMaterializesNothing() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let n = try ops.createPost(title: "n")
            _ = try ops.applyTag(work.id, toPost: n.id)
            let gathering = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try rule(.tag(work.id)))
            #expect(try rows(db, gathering.id).isEmpty)
            #expect(try members(db, gathering.id) == [n.id])
        }
    }

    // MARK: - CATCH-UP (resume — gap = judgment, §4)

    @Test func aRuleEditRoutesTheGapThroughArrivalsAndASameValueWriteIsNoOccasion() throws {
        try withOperations { ops, db in
            let a = try ops.createTag(name: "a")
            let b = try ops.createTag(name: "b")
            let book = try livingBook(ops, .tag(a.id))
            let n1 = try ops.createPost(title: "n1")
            _ = try ops.applyTag(a.id, toPost: n1.id)
            let n2 = try ops.createPost(title: "n2")
            _ = try ops.applyTag(b.id, toPost: n2.id)

            try ops.setReadingQuerySpec(book.id, querySpec: try rule(.tag(a.id)))   // same bytes
            #expect(try rows(db, book.id).count == 1)

            try ops.setReadingQuerySpec(book.id, querySpec: try rule(.or([.tag(a.id), .tag(b.id)])))
            let all = try rows(db, book.id)
            #expect(all.map(\.postId) == [n1.id, n2.id])
            #expect(all.map(\.status) == [.member, .arrival])
        }
    }

    @Test func aMalformedRuleMadeReadableIsACatchUp() throws {
        try withOperations { ops, db in
            let a = try ops.createTag(name: "a")
            let book = try ops.createReading(name: "b", kind: .book)
            try ops.setReadingQuerySpec(book.id, querySpec: "{broken")
            let n = try ops.createPost(title: "n")
            _ = try ops.applyTag(a.id, toPost: n.id)
            #expect(try rows(db, book.id).isEmpty)
            try ops.setReadingQuerySpec(book.id, querySpec: try rule(.tag(a.id)))
            #expect(try rows(db, book.id).map(\.status) == [.arrival])
        }
    }

    @Test func unFinishingCatchesUpTheGapOnly() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let book = try livingBook(ops, .tag(work.id))
            let before = try ops.createPost(title: "before")
            _ = try ops.applyTag(work.id, toPost: before.id)
            try ops.lockReading(book.id)
            let during = try ops.createPost(title: "during")
            _ = try ops.applyTag(work.id, toPost: during.id)
            #expect(try rows(db, book.id).count == 1)          // paused: nothing

            try ops.unlockReading(book.id)
            let all = try rows(db, book.id)
            #expect(all.map(\.postId) == [before.id, during.id])
            #expect(all.map(\.status) == [.member, .arrival])
            #expect(try members(db, book.id) == [before.id])
        }
    }

    @Test func unlockingABookThatWasNotFinishedIsNoOccasion() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let book = try livingBook(ops, .tag(work.id))
            // An undecided current match no act reached: tagged while archived.
            let n = try ops.createPost(title: "n")
            try ops.archiveContainer(n.id)
            _ = try ops.applyTag(work.id, toPost: n.id)
            try ops.unarchiveContainer(n.id)

            try ops.unlockReading(book.id)                     // was not finished
            #expect(try rows(db, book.id).isEmpty)
            try ops.lockReading(book.id)
            try ops.unlockReading(book.id)                     // a real resume
            #expect(try rows(db, book.id).map(\.status) == [.arrival])
        }
    }

    @Test func restoringFromTheTrashRevivesThenCatchesUp() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let book = try livingBook(ops, .tag(work.id))
            let member = try ops.createPost(title: "member")
            _ = try ops.applyTag(work.id, toPost: member.id)
            try ops.deleteReading(book.id)
            let gap = try ops.createPost(title: "gap")
            _ = try ops.applyTag(work.id, toPost: gap.id)

            try ops.restoreReading(book.id)
            let all = try rows(db, book.id)
            #expect(all.map(\.postId) == [member.id, gap.id])
            #expect(all.map(\.status) == [.member, .arrival])
            #expect(all.allSatisfy { $0.deletedAt == nil })
        }
    }

    @Test func aFinishedBookRestoresFinishedAndCatchesUpNothing() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let book = try livingBook(ops, .tag(work.id))
            try ops.lockReading(book.id)
            try ops.deleteReading(book.id)
            let n = try ops.createPost(title: "n")
            _ = try ops.applyTag(work.id, toPost: n.id)
            try ops.restoreReading(book.id)
            #expect(try rows(db, book.id).isEmpty)
        }
    }

    // MARK: - FINISHING DISMISSES (§24)

    @Test func finishingDismissesPendingArrivalsOnTheFinishStampAndLeavesMembers() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let book = try livingBook(ops, .tag(work.id), maxPosts: 1)
            let member = try ops.createPost(title: "member")
            _ = try ops.applyTag(work.id, toPost: member.id)
            let waiting = try ops.createPost(title: "waiting")
            _ = try ops.applyTag(work.id, toPost: waiting.id)
            try db.clearOutbox()

            try ops.lockReading(book.id)
            let finished = try #require(try db.read { try Queries.reading($0, id: book.id) })
            let all = try rows(db, book.id)
            try #require(all.count == 2)
            #expect(all[0].deletedAt == nil && all[0].status == .member)
            #expect(all[1].status == .arrival)
            #expect(all[1].deletedAt == finished.updatedAt)    // the finish's own stamp
            #expect(try db.outboxContains("reading_post", all[1].id))
        }
    }

    @Test func aFinishDismissedArrivalReturnsOnlyOnAFreshTaggingAct() throws {
        // §24: "a dismissed arrival returns only on a FRESH tagging act …
        // the un-finish catch-up covers the gap only."
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let book = try livingBook(ops, .tag(work.id), seating: .arrivals)
            let n = try ops.createPost(title: "n")
            _ = try ops.applyTag(work.id, toPost: n.id)
            try ops.lockReading(book.id)
            try ops.unlockReading(book.id)
            #expect(try rows(db, book.id).filter { $0.deletedAt == nil }.isEmpty)

            try ops.removeTag(work.id, fromPost: n.id)
            _ = try ops.applyTag(work.id, toPost: n.id)
            let live = try rows(db, book.id).filter { $0.deletedAt == nil }
            #expect(live.map(\.postId) == [n.id])
            #expect(live.map(\.status) == [.arrival])
        }
    }

    // MARK: - The judgment ops (§2.5)

    @Test func seatingAnArrivalFlipsTheSameRowToAMemberAtTheEnd() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let book = try livingBook(ops, .tag(work.id), seating: .arrivals)
            let hand = try ops.createPost(title: "by hand")
            try ops.addPostToReading(hand.id, to: book.id)
            let n = try ops.createPost(title: "n")
            _ = try ops.applyTag(work.id, toPost: n.id)
            let later = try ops.createPost(title: "later by hand")
            try ops.addPostToReading(later.id, to: book.id)
            let bell = try #require(try rows(db, book.id).first { $0.status == .arrival })

            let seated = try ops.seatArrival(bell.id)
            #expect(seated.id == bell.id)
            let row = try #require(try db.read { try ReadingPost.fetchOne($0, key: bell.id) })
            #expect(row.status == .member)
            #expect(row.sectionId == nil)
            #expect(row.deletedAt == nil)
            #expect(try members(db, book.id) == [hand.id, later.id, n.id])   // the END
        }
    }

    @Test func seatingRefusesAtCapacityOnAFinishedBookAndForANonArrival() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let book = try livingBook(ops, .tag(work.id), maxPosts: 1)
            let member = try ops.createPost(title: "member")
            _ = try ops.applyTag(work.id, toPost: member.id)
            let n = try ops.createPost(title: "n")
            _ = try ops.applyTag(work.id, toPost: n.id)
            let all = try rows(db, book.id)
            try #require(all.count == 2)
            let bell = all[1]

            #expect(throws: OperationError.readingAtCapacity(id: book.id)) {
                try ops.seatArrival(bell.id)
            }
            #expect(throws: OperationError.arrivalNotFound(id: all[0].id)) {
                try ops.seatArrival(all[0].id)               // a member all along
            }
            #expect(throws: OperationError.arrivalNotFound(id: "nope")) {
                try ops.seatArrival("nope")
            }
            // A finished book with a bell on it (only a sync race can stage
            // this — finishing dismisses): judgment "add" refuses.
            try ops.setReadingMaxPosts(book.id, maxPosts: nil)
            try db.write { db in
                try db.execute(sql: "UPDATE reading SET locked = 1 WHERE id = ?",
                               arguments: [book.id])
            }
            #expect(throws: OperationError.lockedReading(id: book.id)) {
                try ops.seatArrival(bell.id)
            }
            // …while dismissing is allowed (it is what finishing does).
            try ops.dismissArrival(bell.id)
            #expect(try db.read { try ReadingPost.fetchOne($0, key: bell.id) }?.deletedAt != nil)
            #expect(throws: OperationError.arrivalNotFound(id: bell.id)) {
                try ops.dismissArrival(bell.id)              // already judged
            }
        }
    }

    @Test func judgmentOnADeadBookRefusesAsMissing() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let book = try livingBook(ops, .tag(work.id), seating: .arrivals)
            let n = try ops.createPost(title: "n")
            _ = try ops.applyTag(work.id, toPost: n.id)
            let bell = try #require(try rows(db, book.id).first)
            // A dead book's rows died with it (cascade) — so a judgment that
            // raced the deletion finds no live arrival at all.
            try ops.deleteReading(book.id)
            #expect(throws: OperationError.arrivalNotFound(id: bell.id)) {
                try ops.seatArrival(bell.id)
            }
        }
    }

    // MARK: - AUTO-TAG (the outflow, §2.6)

    @Test func aNoteMintedInsideTheBookWearsItsAutoTagAndOtherBooksHearIt() throws {
        try withOperations { ops, db in
            let essay = try ops.createTag(name: "essay")
            let source = try ops.createReading(name: "source", kind: .book, autoTagId: essay.id)
            let listener = try livingBook(ops, .tag(essay.id), name: "listener")

            let minted = try ops.newPostInReading(source.id, title: "minted")
            #expect(try liveTagIDs(db, minted.id) == [essay.id])
            #expect(try members(db, source.id) == [minted.id])
            try #require(try rows(db, source.id).count == 1)  // its own pair: decided first
            #expect(try members(db, listener.id) == [minted.id])
            let application = try #require(try db.read {
                try PostTag.fetchOne($0, sql: "SELECT * FROM post_tag WHERE post_id = ?",
                                     arguments: [minted.id])
            })
            #expect(application.createdAt == (try rows(db, source.id))[0].createdAt)
        }
    }

    @Test func aHandAddWearsTheAutoTagOnceAndNeverTwice() throws {
        // P-13ib-1: "adding to a book is real membership, with auto-tag
        // covering the tagging" (§14.6).
        try withOperations { ops, db in
            let essay = try ops.createTag(name: "essay")
            let book = try ops.createReading(name: "b", kind: .book, autoTagId: essay.id)
            let plain = try ops.createPost(title: "plain")
            try ops.addPostToReading(plain.id, to: book.id)
            #expect(try liveTagIDs(db, plain.id) == [essay.id])

            let already = try ops.createPost(title: "already")
            _ = try ops.applyTag(essay.id, toPost: already.id)
            try ops.addPostToReading(already.id, to: book.id)   // no alreadyTagged throw
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM post_tag WHERE post_id = ?", [already.id]) == 1)
        }
    }

    @Test func noOutflowWithoutALiveAutoTagAndClearingItNeverUntags() throws {
        try withOperations { ops, db in
            let essay = try ops.createTag(name: "essay")
            let book = try ops.createReading(name: "b", kind: .book, autoTagId: essay.id)
            let first = try ops.newPostInReading(book.id, title: "first")
            try ops.setReadingAutoTag(book.id, tagID: nil)
            #expect(try liveTagIDs(db, first.id) == [essay.id])   // never untags (ruled)
            let second = try ops.newPostInReading(book.id, title: "second")
            #expect(try liveTagIDs(db, second.id).isEmpty)

            let gone = try ops.createTag(name: "gone")
            try ops.setReadingAutoTag(book.id, tagID: gone.id)
            try ops.deleteTag(gone.id)
            let third = try ops.newPostInReading(book.id, title: "third")   // a dangling outflow: silent
            #expect(try liveTagIDs(db, third.id).isEmpty)
        }
    }

    @Test func intakeSeatsNeverApplyTheAutoTag() throws {
        // P-13ib-U1-3: auto-tag covers notes that did NOT come through the
        // rule (minted here, added by hand); a seat by the rule never tags.
        try withOperations { ops, db in
            let x = try ops.createTag(name: "x")
            let y = try ops.createTag(name: "y")
            let book = try livingBook(ops, .tag(x.id), autoTagId: y.id)
            let n = try ops.createPost(title: "n")
            _ = try ops.applyTag(x.id, toPost: n.id)
            #expect(try members(db, book.id) == [n.id])
            #expect(try liveTagIDs(db, n.id) == [x.id])
        }
    }

    @Test func autoTagAndIntakeNeverLoop() throws {
        // Two books feeding each other: A collects #x and tags #y; B collects
        // #y and tags #x. A mint in A tags #y → B seats it → and stops there
        // (intake is insert-only and never tags; every pair is decided).
        try withOperations { ops, db in
            let x = try ops.createTag(name: "x")
            let y = try ops.createTag(name: "y")
            let a = try livingBook(ops, .tag(x.id), name: "A", autoTagId: y.id)
            let b = try livingBook(ops, .tag(y.id), name: "B", autoTagId: x.id)
            let minted = try ops.newPostInReading(a.id, title: "minted in A")
            #expect(try liveTagIDs(db, minted.id) == [y.id])
            #expect(try members(db, a.id) == [minted.id])
            #expect(try members(db, b.id) == [minted.id])
            #expect(try db.fetchInt("SELECT COUNT(*) FROM reading_post") == 2)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM post_tag") == 1)

            // A hand-add into B tags #x → A hears it; the pair is decided.
            let hand = try ops.createPost(title: "by hand into B")
            try ops.addPostToReading(hand.id, to: b.id)
            #expect(try liveTagIDs(db, hand.id) == [x.id])
            #expect(try members(db, a.id) == [minted.id, hand.id])
            #expect(try db.fetchInt("SELECT COUNT(*) FROM reading_post") == 4)
        }
    }

    // MARK: - tagAllMembers ("also tag the N current members now", §4)

    @Test func tagAllMembersTagsEveryMemberLackingItInOneTransactionAndNeverAnArrival() throws {
        try withOperations { ops, db in
            let essay = try ops.createTag(name: "essay")
            let work = try ops.createTag(name: "work")
            let book = try livingBook(ops, .tag(work.id), maxPosts: 3)
            let listener = try livingBook(ops, .tag(essay.id), name: "listener")
            var notes: [Container] = []
            for i in 0..<4 {
                let n = try ops.createPost(title: "n\(i)")
                _ = try ops.applyTag(work.id, toPost: n.id)   // the 4th waits (cap 3)
                notes.append(n)
            }
            _ = try ops.applyTag(essay.id, toPost: notes[0].id)   // already wears it
            try ops.setReadingAutoTag(book.id, tagID: essay.id)

            let tagged = try ops.tagAllMembers(book.id)
            #expect(tagged == 2)
            #expect(try liveTagIDs(db, notes[1].id).contains(essay.id))
            #expect(try liveTagIDs(db, notes[2].id).contains(essay.id))
            #expect(!(try liveTagIDs(db, notes[3].id).contains(essay.id)))   // an arrival
            let stamps = try db.read {
                try String.fetchAll($0, sql: """
                    SELECT DISTINCT created_at FROM post_tag
                    WHERE tag_id = ? AND post_id IN (?, ?)
                    """, arguments: [essay.id, notes[1].id, notes[2].id])
            }
            #expect(stamps.count == 1)                                    // ONE transaction
            #expect(Set(try members(db, listener.id))
                == Set([notes[0].id, notes[1].id, notes[2].id]))         // each act heard
            #expect(try ops.tagAllMembers(book.id) == 0)                  // idempotent
        }
    }

    @Test func tagAllMembersRefusals() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "b", kind: .book)
            #expect(throws: OperationError.readingHasNoAutoTag(id: book.id)) {
                try ops.tagAllMembers(book.id)
            }
            let gathering = try ops.createReading(name: "g", kind: .gathering)
            let t = try ops.createTag(name: "t")
            #expect(throws: OperationError.wrongReadingKind(id: gathering.id, expected: .book)) {
                try ops.tagAllMembers(gathering.id, tagID: t.id)
            }
            // A finished book is allowed — finishing freezes the assembly,
            // never the notes' tags.
            let n = try ops.createPost(title: "n")
            try ops.addPostToReading(n.id, to: book.id)
            try ops.lockReading(book.id)
            #expect(try ops.tagAllMembers(book.id, tagID: t.id) == 1)
            _ = db
        }
    }

    // MARK: - The two Collecting setters

    @Test func theSettersAreBookOnlyWingScopedAndNoOpGuarded() throws {
        try withOperations { ops, db in
            let t = try ops.createTag(name: "t")
            let book = try ops.createReading(name: "b", kind: .book)
            let gathering = try ops.createReading(name: "g", kind: .gathering)
            #expect(throws: OperationError.wrongReadingKind(id: gathering.id, expected: .book)) {
                try ops.setReadingAutoTag(gathering.id, tagID: t.id)
            }
            #expect(throws: OperationError.wrongReadingKind(id: gathering.id, expected: .book)) {
                try ops.setReadingIntakeSeating(gathering.id, .arrivals)
            }
            #expect(throws: OperationError.self) {
                try ops.createReading(name: "g2", kind: .gathering, autoTagId: t.id)
            }
            // Another wing's tag does not exist from here (§9).
            try db.write { db in
                try db.execute(sql: """
                    INSERT INTO tag (id, name, path, wing_id, created_at, updated_at)
                    VALUES ('far', 'far', 'far', 'elsewhere',
                            '2026-07-01T00:00:00.000Z', '2026-07-01T00:00:00.000Z')
                    """)
            }
            #expect(throws: OperationError.tagNotFound(id: "far")) {
                try ops.setReadingAutoTag(book.id, tagID: "far")
            }

            try ops.setReadingAutoTag(book.id, tagID: t.id)
            try ops.setReadingIntakeSeating(book.id, .arrivals)
            let set = try #require(try db.read { try Queries.reading($0, id: book.id) })
            #expect(set.autoTagId == t.id)
            #expect(set.intakeSeating == .arrivals)
            try db.clearOutbox()
            try ops.setReadingAutoTag(book.id, tagID: t.id)
            try ops.setReadingIntakeSeating(book.id, .arrivals)
            #expect(!(try db.outboxContains("reading", book.id)))   // nothing changed, nothing written
            #expect(try db.read { try Queries.reading($0, id: book.id) }?.updatedAt == set.updatedAt)
        }
    }
}
