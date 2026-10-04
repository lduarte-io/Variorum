import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// 13i-d U5b — **THE BULK WING MOVE** (`moveWingContents`; her R-13id-4
/// backdoor, built to R-13id-6 item 8). A new op — exact state transitions:
/// the full arithmetic (every note, book, gathering, membership, waiting
/// arrival and dismissal record riding; finished and sealed books whole; tags
/// adopt or mint by path; a snippet's application re-pointed; EVERY source
/// tag tombstoned, so the wing ends genuinely EMPTY and Delete Wing then
/// succeeds), the confirm's tag buckets equal to the act, the refusals and the
/// daily-Journal belt, the Trash rows left to the dangling-wing rule (a Put
/// back re-homes and never crosses — F-U5b-1), and no undo registration.
@Suite("13i-d U5b — move everything in a wing to another wing")
struct WingContentsMoveTests {
    private func liveTag(_ db: AppDatabase, wing: String, path: String) throws -> VariorumCore.Tag? {
        try db.read {
            try VariorumCore.Tag.fetchOne(
                $0, sql: "SELECT * FROM tag WHERE wing_id = ? AND path = ? AND deleted_at IS NULL",
                arguments: [wing, path])
        }
    }

    private func liveTagIDs(_ db: AppDatabase, table: String, column: String, target: String) throws
        -> Set<String>
    {
        Set(try db.read {
            try String.fetchAll(
                $0,
                sql: "SELECT tag_id FROM \(table) WHERE \(column) = ? AND deleted_at IS NULL",
                arguments: [target])
        })
    }

    private func reading(_ db: AppDatabase, _ id: String) throws -> Reading {
        try #require(try db.read { try Reading.fetchOne($0, key: id) })
    }

    /// The whole arithmetic, to HOME (which already has `writing`).
    @Test func everythingMovesTheTagsRetireAndTheWingEndsEmpty() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let wing = try ops.createWing(name: "Imports")
            let w = wing.id
            // The wing's vocabulary: writing (+ draft), poems (a snippet
            // wears it), classics (a gathering's rule names it), orphan.
            let writing = try ops.createTag(name: "writing", wingID: w)
            let draft = try ops.createTag(parent: writing.id, name: "draft")
            let poems = try ops.createTag(name: "poems", wingID: w)
            let classics = try ops.createTag(name: "classics", wingID: w)
            let orphan = try ops.createTag(name: "orphan", wingID: w)
            let homeWriting = try ops.createTag(name: "writing")
            _ = try ops.createReading(name: "b1", kind: .book)  // Home's twin name

            let shelf = try ops.createShelf(name: "Imported", wingID: w)
            let b1 = try ops.createReading(name: "B1", kind: .book, wingId: w, shelfId: shelf.id)
            let b2 = try ops.createReading(name: "B2", kind: .book, wingId: w)
            let b3 = try ops.createReading(name: "B3", kind: .book, wingId: w)
            let writingRule = try #require(try RuleGrammar.encode(.tag(writing.id)))
            let living = try ops.createReading(
                name: "Living", kind: .book,
                querySpec: writingRule,
                wingId: w, intakeSeating: .arrivals)
            let classicsRule = try #require(try RuleGrammar.encode(.tag(classics.id)))
            let gathering = try ops.createReading(
                name: "Classics", kind: .gathering,
                querySpec: classicsRule, wingId: w)

            let n1 = try ops.createPost(title: "n1", wingId: w)
            let block = try ops.seedBlock(in: n1.id, text: "first words")
            let n2 = try ops.createPost(title: "n2", wingId: w)
            let n3 = try ops.createPost(title: "n3", wingId: w)
            let n4 = try ops.createPost(title: "n4", wingId: w)
            _ = try ops.seedBlock(in: n4.id, text: "sealed words")
            _ = try ops.addPostToReading(n1.id, to: b1.id)
            _ = try ops.addPostToReading(n2.id, to: b1.id)
            let chapter = try ops.createSection(in: b1.id, name: "Part One")
            try ops.assignPostToSection(n1.id, in: b1.id, section: chapter.id)
            try ops.archiveContainer(n2.id)
            _ = try ops.addPostToReading(n3.id, to: b2.id)
            try ops.lockReading(b2.id)
            _ = try ops.addPostToReading(n4.id, to: b3.id)
            _ = try ops.sealReading(b3.id)
            try ops.applyTag(draft.id, toPost: n1.id)       // bells at Living (subtree)
            _ = try ops.applyTag(writing.id, toBlock: block.block.id)
            try ops.applyTag(writing.id, toPost: n3.id)     // bells, then dismissed
            let n3Pair = try #require(try db.fetchString(
                "SELECT id FROM reading_post WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL",
                [living.id, n3.id]))
            try ops.dismissArrival(n3Pair)
            let version = try ops.saveNoteVersion(n1.id).post
            let pool = try ops.createPool(title: "scraps")
            let scrap = try ops.seedBlock(in: pool.id, text: "a scrap")
            _ = try ops.applyTag(poems.id, toBlock: scrap.block.id)
            let sealedAt = try reading(db, b3.id).sealedAt
            let n4LockedAt = try db.read { try Container.fetchOne($0, key: n4.id) }?.lockedAt

            // THE CONFIRM — what moves and what becomes of each tag's name.
            let preview = try db.read { try Queries.wingContentsMovePreview($0, from: w, to: "") }
            #expect(preview.contents == Queries.WingContents(notes: 4, books: 4, gatherings: 1, tags: 5))
            #expect(preview.tags.joins == ["writing"])
            #expect(preview.tags.made == ["classics", "poems", "writing/draft"])
            #expect(preview.tags.lettingGo == ["orphan"])
            #expect(preview.tags.minted == ["classics", "poems", "writing/draft"])
            #expect(preview.nameCollisions == ["B1"])

            let depth = stack.depth
            let result = try ops.moveWingContents(from: w, to: "")
            #expect(stack.depth == depth, "no structural-undo entry")
            #expect(result.moved == preview.contents)
            #expect(result.tagsRetired == 5)
            #expect(result.mintedTags == preview.tags.minted.count, "the confirm's arithmetic IS the act's")

            // The wing is genuinely empty — and Delete Wing succeeds.
            #expect(try db.read { try Queries.wingContents($0, wingID: w) }.isEmpty)
            for tag in [writing, draft, poems, classics, orphan] {
                #expect(try db.deletedAt("tag", tag.id) != nil, "every source tag retires")
            }

            // Notes (and the saved version) all live in Home now.
            for id in [n1.id, n2.id, n3.id, n4.id, version.id] {
                #expect(try db.read { try Queries.effectiveWing($0, ofPost: id) } == "")
            }
            #expect(try db.read { try Container.fetchOne($0, key: n2.id) }?.archivedAt != nil)

            // Memberships, the chapter, the arrival and the dismissal ride.
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND status = 'member' AND deleted_at IS NULL",
                [b1.id]) == 2)
            #expect(try db.fetchString(
                "SELECT section_id FROM reading_post WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL",
                [b1.id, n1.id]) == chapter.id)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND post_id = ? AND status = 'arrival' AND deleted_at IS NULL",
                [living.id, n1.id]) == 1, "the waiting note moved with everything — its row rides")
            #expect(try db.deletedAt("reading_post", n3Pair) != nil, "the dismissal record rides, decided")

            // Readings: whole, unshelved, in Home.
            for id in [b1.id, b2.id, b3.id, living.id, gathering.id] {
                let moved = try reading(db, id)
                #expect(moved.wingId == "" && moved.shelfId == nil && moved.shelfPosition == nil)
            }
            #expect(try reading(db, b2.id).locked, "finished stays finished")
            #expect(try reading(db, b3.id).sealedAt == sealedAt, "sealed stays sealed, same stamp")
            #expect(try db.read { try Container.fetchOne($0, key: n4.id) }?.lockedAt == n4LockedAt)

            // Tags by path: adopt Home's `writing`, mint the rest.
            let homeDraft = try #require(try liveTag(db, wing: "", path: "writing/draft"))
            let homePoems = try #require(try liveTag(db, wing: "", path: "poems"))
            let homeClassics = try #require(try liveTag(db, wing: "", path: "classics"))
            #expect(try liveTag(db, wing: "", path: "orphan") == nil, "nothing carried it — let go")
            #expect(try liveTagIDs(db, table: "post_tag", column: "post_id", target: n1.id) == [homeDraft.id])
            #expect(try liveTagIDs(db, table: "block_tag", column: "block_id", target: block.block.id)
                    == [homeWriting.id])
            #expect(try liveTagIDs(db, table: "post_tag", column: "post_id", target: n3.id) == [homeWriting.id])
            #expect(try liveTagIDs(db, table: "block_tag", column: "block_id", target: scrap.block.id)
                    == [homePoems.id], "the snippet's application re-pointed too")
            #expect(RuleGrammar.decode(try reading(db, gathering.id).querySpec) == .tag(homeClassics.id))
            #expect(RuleGrammar.decode(try reading(db, living.id).querySpec) == .tag(homeWriting.id))

            try ops.deleteWing(w)
            #expect(try db.read { try Queries.wings($0) }.isEmpty)
            #expect(try db.deletedAt("shelf", shelf.id) != nil, "the shelves went with the wing")
        }
    }

    /// The refusals: Home or a dead wing as the source, a dead destination,
    /// the source itself — and the daily-Journal belt (a daily-marked book
    /// among the movers may only go Home).
    @Test func theRefusalsAndTheDailyJournalBelt() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Imports")
            let other = try ops.createWing(name: "Studio")
            #expect(throws: OperationError.wingNotFound(id: "")) {
                try ops.moveWingContents(from: "", to: wing.id)
            }
            #expect(throws: OperationError.wingNotFound(id: "nowhere")) {
                try ops.moveWingContents(from: wing.id, to: "nowhere")
            }
            #expect(throws: OperationError.wingMoveIntoItself(wingID: wing.id)) {
                try ops.moveWingContents(from: wing.id, to: wing.id)
            }
            // The belt: a 'daily'-marked book can only ever be sent HOME.
            let marked = try ops.createReading(
                name: "Stray Journal", kind: .book, profile: Queries.dailyJournalBookProfile,
                wingId: wing.id)
            #expect(throws: OperationError.dailyJournalIsHomeOnly(id: marked.id)) {
                try ops.moveWingContents(from: wing.id, to: other.id)
            }
            #expect(try reading(db, marked.id).wingId == wing.id, "the refusal wrote nothing")
            _ = try ops.moveWingContents(from: wing.id, to: "")
            #expect(try reading(db, marked.id).wingId == "")
            try ops.deleteWing(wing.id)
            #expect(throws: OperationError.wingNotFound(id: wing.id)) {
                try ops.moveWingContents(from: wing.id, to: "")
            }
        }
    }

    /// Item 8(a): the wing's TRASH rows stay where they are. Once the wing is
    /// deleted they read as Home's; a Put back RE-HOMES them — and never
    /// crosses a wing: a note whose book went to another wing comes back
    /// bookless, a book whose note went elsewhere comes back without it
    /// (F-U5b-1). Moved HOME, the same pair rejoins. A trashed note's tags of
    /// the retired vocabulary do not revive (F-U5b-3, the recorded
    /// consequence).
    @Test func theTrashRowsStayAndAPutBackNeverCrosses() throws {
        try withOperations { ops, db in
            func live(_ post: String, _ book: String) throws -> Int {
                try db.fetchInt(
                    "SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND reading_id = ? AND deleted_at IS NULL",
                    [post, book]) ?? 0
            }
            // To ANOTHER wing: the pair splits.
            let wing = try ops.createWing(name: "Imports")
            let studio = try ops.createWing(name: "Studio")
            let book = try ops.createReading(name: "Kept", kind: .book, wingId: wing.id)
            let gone = try ops.createPost(title: "gone", wingId: wing.id)
            _ = try ops.addPostToReading(gone.id, to: book.id)
            let trashedBook = try ops.createReading(name: "Binned", kind: .book, wingId: wing.id)
            let stays = try ops.createPost(title: "stays", wingId: wing.id)
            _ = try ops.addPostToReading(stays.id, to: trashedBook.id)
            try ops.deleteContainer(gone.id)
            try ops.deleteReading(trashedBook.id)
            _ = try ops.moveWingContents(from: wing.id, to: studio.id)
            try ops.deleteWing(wing.id)
            try ops.restoreContainer(gone.id)
            try ops.restoreReading(trashedBook.id)
            #expect(try db.read { try Queries.effectiveWing($0, ofPost: gone.id) } == "", "re-homed")
            #expect(try reading(db, trashedBook.id).wingId == "", "re-homed")
            #expect(try reading(db, book.id).wingId == studio.id)
            #expect(try live(gone.id, book.id) == 0, "its book lives in Studio — it comes back bookless")
            #expect(try live(stays.id, trashedBook.id) == 0, "its note lives in Studio — the book comes back without it")

            // To HOME: the pair comes home together.
            let other = try ops.createWing(name: "Archive Room")
            let tag = try ops.createTag(name: "kept", wingID: other.id)
            let homeBook = try ops.createReading(name: "Homeward", kind: .book, wingId: other.id)
            let note = try ops.createPost(title: "homeward note", wingId: other.id)
            _ = try ops.addPostToReading(note.id, to: homeBook.id)
            try ops.applyTag(tag.id, toPost: note.id)
            try ops.deleteContainer(note.id)
            _ = try ops.moveWingContents(from: other.id, to: "")
            try ops.deleteWing(other.id)
            try ops.restoreContainer(note.id)
            #expect(try live(note.id, homeBook.id) == 1, "both in Home — the membership revives")
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM post_tag WHERE post_id = ? AND deleted_at IS NULL", [note.id]) == 0,
                "the retired vocabulary does not revive (F-U5b-3)")
        }
    }
}

/// The pure tag arithmetic (`WingTagCarry`) — every source tag in exactly one
/// bucket; `minted` is the closure of what is carried minus what the
/// destination has (a foreign carried path counts there, never in a bucket).
@Suite("13i-d U5b — the bulk move's tag arithmetic (pure)")
struct WingTagCarryTests {
    @Test func theClosureCarriesEveryAncestor() {
        #expect(WingTagCarry.closure(["a/b/c", "x"]) == ["a", "a/b", "a/b/c", "x"])
        #expect(WingTagCarry.closure([]).isEmpty)
    }

    @Test func everySourceTagLandsInExactlyOneBucket() {
        let plan = WingTagCarry.plan(
            sourcePaths: ["writing", "writing/draft", "writing/done", "poems", "orphan"],
            carriedPaths: ["writing/draft", "poems", "foreign/thing"],
            destinationPaths: ["writing", "poems"])
        #expect(plan.joins == ["poems", "writing"])
        #expect(plan.made == ["writing/draft"])
        #expect(plan.lettingGo == ["orphan", "writing/done"])
        #expect(plan.minted == ["foreign", "foreign/thing", "writing/draft"])
        let all = plan.joins + plan.made + plan.lettingGo
        #expect(Set(all).count == all.count && all.count == 5)
    }

    @Test func anAncestorOfACarriedPathIsMadeNotLetGo() {
        let plan = WingTagCarry.plan(
            sourcePaths: ["a", "a/b"], carriedPaths: ["a/b"], destinationPaths: [])
        #expect(plan.made == ["a", "a/b"] && plan.lettingGo.isEmpty)
    }
}
