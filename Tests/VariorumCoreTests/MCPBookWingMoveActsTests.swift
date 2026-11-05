import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-807 (the VX-809 run, batch 2 — her R-807; the orchestrator's A-809-14/-15/-16,
// R-805-5) — `mcpMoveBookToWing`, the MCP door's book move. Exact state
// transitions: HER body (`moveReadingToWing(db:)`) inside one transaction — the
// PARITY pin proves the wrapped act writes byte for byte what her door writes;
// the wire's belts (a gathering, the daily Journal) and A-809-15 (a fence never
// drops — the act refuses whole, nothing written); the reach-scoped answer
// facts; and the ONE client-named entry (A-809-14): an exact-row round trip,
// OBSOLETE-quiet when the world moved on, refused WHOLE and kept when it is
// partially aged. Who may act is the server's rule (`MCPBookWingMoveServerTests`).

private struct GuardRefused: Error, Equatable {}

/// The fixture's ids.
private struct World {
    var studio = "", atlas = "", other = "", shelf = "", chapter = ""
    var one = "", two = "", three = "", four = "", waiter = "", writing = "", drafts = ""
}

@Suite("VX-807 — move_book_to_wing: the act")
struct MCPBookWingMoveActsTests {
    private let label = Operations.MCPWriteAct.bookWingMove.undoLabel(client: "claude-code")

    private func withUndo<T>(_ body: (Operations, UndoStack, AppDatabase) throws -> T) throws -> T {
        try withOperations { _, db in
            let stack = UndoStack()
            return try body(Operations(undoStack: stack), stack, db)
        }
    }

    /// Atlas (Home): shelved and starred, a chapter, a rule (#writing), an
    /// outflow (#writing/drafts), a waiting arrival; members one (filed, in
    /// Other too, tagged #writing), two (archived, a block tagged
    /// #writing/drafts, WAITING at Other's Arrivals), three (marked Private —
    /// its own fence rides), four (a saved version). Studio has its own
    /// #writing (adopted); #writing/drafts is minted there.
    private func build(_ ops: Operations) throws -> World {
        var w = World()
        w.studio = try ops.createWing(name: "Studio").id
        _ = try ops.createTag(name: "writing", wingID: w.studio)
        let writing = try ops.createTag(name: "writing")
        let drafts = try ops.createTag(parent: writing.id, name: "drafts")
        w.writing = writing.id
        w.drafts = drafts.id
        let atlas = try ops.createReading(name: "Atlas", kind: .book, intakeSeating: .arrivals)
        w.atlas = atlas.id
        w.shelf = try ops.createShelf(name: "Desk").id
        try ops.setReadingShelf(atlas.id, shelf: w.shelf)
        try ops.setStarred(.reading(atlas.id), starred: true)
        w.chapter = try ops.createSection(in: atlas.id, name: "Part one").id
        let other = try ops.createReading(name: "Other", kind: .book, intakeSeating: .arrivals)
        w.other = other.id
        let one = try ops.createPost(title: "one")
        _ = try ops.newBlock(in: one.id, text: "One.", registeringUndo: false)
        let two = try ops.createPost(title: "two")
        let twoBlock = try ops.newBlock(in: two.id, text: "Two.", registeringUndo: false)
        let three = try ops.createPost(title: "three")
        let four = try ops.createPost(title: "four")
        _ = try ops.newBlock(in: four.id, text: "Four.", registeringUndo: false)
        for note in [one, two, three, four] { _ = try ops.addPostToReading(note.id, to: atlas.id) }
        try ops.assignPostToSection(one.id, in: atlas.id, section: w.chapter)
        _ = try ops.addPostToReading(one.id, to: other.id)
        _ = try ops.applyTag(writing.id, toPost: one.id)
        _ = try ops.applyTag(drafts.id, toBlock: twoBlock.block.id)
        try ops.archiveContainer(two.id)
        _ = try ops.setNotePrivate(three.id, true)
        _ = try ops.saveNoteVersion(four.id)
        // Rules last: an applying act after them bells (intake), and the
        // fixture's waiting rows are made deliberately.
        try ops.setReadingQuerySpec(atlas.id, querySpec: try RuleGrammar.encode(.tag(writing.id)))
        try ops.setReadingOutflow(atlas.id, tagIDs: [drafts.id])
        try ops.setReadingQuerySpec(other.id, querySpec: try RuleGrammar.encode(.tag(drafts.id)))
        let waiter = try ops.createPost(title: "waiter")
        _ = try ops.applyTag(writing.id, toPost: waiter.id)  // waits at Atlas's Arrivals
        w.waiter = waiter.id
        _ = try ops.applyTag(drafts.id, toPost: two.id)      // two waits at Other's Arrivals
        w.one = one.id
        w.two = two.id
        w.three = three.id
        w.four = four.id
        return w
    }

    /// Every row the move can touch, as text (ids are deterministic).
    private func snapshot(_ db: AppDatabase) throws -> [String] {
        try db.read { db in
            try ["reading", "reading_post", "reading_section", "container", "post_tag", "block_tag", "tag", "shelf"]
                .flatMap { table in try Row.fetchAll(db, sql: "SELECT * FROM \(table) ORDER BY id").map { "\(table) \($0)" } }
        }
    }

    /// What an undo must put back — every column the move or its replay
    /// writes except the clock's (`updated_at`, tombstone stamps): the live
    /// rows and their places.
    private func projection(_ db: AppDatabase) throws -> [String] {
        try db.read { db in
            try [
                "SELECT id, wing_id, shelf_id, shelf_position, query_spec, auto_tag_ids, grouping_tag_id, locked, sealed_at, owned, starred, archived_at FROM reading WHERE deleted_at IS NULL",
                "SELECT id, reading_id, post_id, status, section_id, position FROM reading_post WHERE deleted_at IS NULL",
                "SELECT id, wing_id, archived_at, locked FROM container WHERE deleted_at IS NULL",
                "SELECT id, tag_id, post_id FROM post_tag WHERE deleted_at IS NULL",
                "SELECT id, tag_id, block_id FROM block_tag WHERE deleted_at IS NULL",
            ].flatMap { sql in try Row.fetchAll(db, sql: sql + " ORDER BY id").map(\.description) }
        }
    }

    private func wing(_ db: AppDatabase, _ table: String, _ id: String) throws -> String? {
        try db.read { try String.fetchOne($0, sql: "SELECT wing_id FROM \(table) WHERE id = ?", arguments: [id]) }
    }

    // MARK: - The act is her door's act, byte for byte

    @Test func theWrappedActWritesExactlyWhatHerDoorWrites() throws {
        let hers: [String] = try withOperations { ops, db in
            let w = try build(ops)
            _ = try ops.moveReadingToWing(w.atlas, to: w.studio)
            return try snapshot(db)
        }
        let wire: (snapshot: [String], result: Operations.MCPBookWingMove) = try withUndo { ops, _, db in
            let w = try build(ops)
            let result = try ops.mcpMoveBookToWing(w.atlas, to: w.studio, undoLabel: label)
            return (try snapshot(db), result)
        }
        #expect(hers == wire.snapshot, "the same rows, ids and stamps — her body, wrapped, never re-derived")
        // Her facts ride whole (her receipt counts everything).
        #expect(wire.result.move.notes == 4 && wire.result.move.dismissedArrivals == 1)
        #expect(wire.result.move.alsoLeft.map(\.book) == ["Other"])
    }

    @Test func everythingRidesWholeAndLandsUnshelved() throws {
        try withUndo { ops, stack, db in
            let w = try build(ops)
            let depth = stack.depth  // the fixture's own entries
            _ = try ops.mcpMoveBookToWing(w.atlas, to: w.studio, undoLabel: label)
            let atlas = try #require(try db.read { try Reading.fetchOne($0, key: w.atlas) })
            #expect(atlas.wingId == w.studio && atlas.shelfId == nil && atlas.shelfPosition == nil && atlas.starred)
            for note in [w.one, w.two, w.three, w.four] { #expect(try wing(db, "container", note) == w.studio) }
            #expect(try db.read { try Container.fetchOne($0, key: w.two) }?.archivedAt != nil, "archived rides archived")
            #expect(try db.read { try Queries.mcpNoteFacts($0, noteID: w.three) }?.fence != nil, "its own Private mark rides")
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL AND status = 'member'",
                [w.atlas]) == 4)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL", [w.other]) == 0,
                "one's membership and two's waiting row in Other are severed")
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND post_id = ? AND deleted_at IS NOT NULL AND status = 'arrival'",
                [w.atlas, w.waiter]) == 1, "the waiting note stays behind, its row decided")
            #expect(try wing(db, "container", w.waiter) == "")
            #expect(try db.fetchInt("SELECT COUNT(*) FROM reading_section WHERE reading_id = ? AND deleted_at IS NULL",
                                    [w.atlas]) == 1, "the chapter rides")
            #expect(try db.fetchInt("SELECT COUNT(*) FROM tag WHERE wing_id = ? AND path = 'writing/drafts' AND deleted_at IS NULL",
                                    [w.studio]) == 1, "a missing path is minted in the destination")
            #expect(try db.fetchInt("SELECT COUNT(*) FROM tag WHERE wing_id = '' AND deleted_at IS NULL") == 2,
                    "the source's vocabulary stays — the book move tombstones no tag")
            #expect(stack.depth == depth + 1 && stack.topLabel == label, "ONE client-named entry")
        }
    }

    // MARK: - The answer's facts, through the caller's reach

    @Test func theAnswersFactsCountAndNameOnlyWhatTheReachAdmits() throws {
        try withUndo { ops, _, _ in
            let w = try build(ops)
            let hidden: Set<String> = [w.three, w.other]
            let result = try ops.mcpMoveBookToWing(w.atlas, to: w.studio, undoLabel: label, reach: { _, target in
                switch target {
                case .note(let id), .reading(let id): !hidden.contains(id)
                }
            })
            #expect(result.notes == 3 && result.archivedNotes == 1, "the hidden member is not counted")
            #expect(result.leftBooks.isEmpty, "the severed membership's book is hidden — neither named nor counted")
            #expect(result.dismissedArrivals == 1)
            #expect(result.move.notes == 4, "her facts stay whole (hers)")
        }
        try withUndo { ops, _, _ in
            let w = try build(ops)
            let all = try ops.mcpMoveBookToWing(w.atlas, to: w.studio, undoLabel: label)
            #expect(all.notes == 4 && all.leftBooks == [.init(noteID: w.one, bookID: w.other, name: "Other")])
        }
    }

    @Test func aTwinInTheDestinationIsNamedOnlyWhereReadable() throws {
        try withUndo { ops, _, _ in
            let studio = try ops.createWing(name: "Studio")
            let twin = try ops.createReading(name: "ATLAS", kind: .book, wingId: studio.id)
            let atlas = try ops.createReading(name: "Atlas", kind: .book)
            let seen = try ops.mcpMoveBookToWing(atlas.id, to: studio.id, undoLabel: label)
            #expect(seen.twins == [.init(bookID: twin.id, name: "ATLAS")])
            let back = try ops.createReading(name: "Atlas", kind: .book)
            let unseen = try ops.mcpMoveBookToWing(back.id, to: studio.id, undoLabel: label, reach: { _, target in
                target != Operations.MCPReadTarget.reading(twin.id)
            })
            #expect(unseen.twins == [.init(bookID: atlas.id, name: "Atlas")], "only the readable twin")
        }
    }

    // MARK: - The refusals

    @Test func theWiresBeltsRefuseAGatheringAndTheDailyJournalBeforeHerBody() throws {
        try withUndo { ops, stack, db in
            let studio = try ops.createWing(name: "Studio")
            let tag = try ops.createTag(name: "board")
            let gathering = try ops.createReading(
                name: "Board", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            #expect(throws: Operations.MCPBookMoveRefusal.gathering) {
                try ops.mcpMoveBookToWing(gathering.id, to: studio.id, undoLabel: label)
            }
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-06-30").container
            _ = ops.shelveInDailyJournalBook(entry.id)
            let journal = try #require(try db.read { try Queries.dailyJournalBookID($0) })
            // The wire's SHARED move fence (R-805-5) — her body moves the
            // Journal since VX-435 (its `dailyJournalIsHomeOnly` retired), so
            // this refusal is the wire's alone; the op's own `.dailyJournal`
            // belt was folded into the fence at the VX-805 merge-in.
            #expect(throws: OperationError.dailyJournalMovesOnlyByHand(id: journal)) {
                try ops.mcpMoveBookToWing(journal, to: studio.id, undoLabel: label)
            }
            #expect(try wing(db, "reading", journal) == "" && stack.depth == 0)
        }
    }

    @Test func herRefusalsSpeakUnchanged() throws {
        try withUndo { ops, stack, _ in
            let studio = try ops.createWing(name: "Studio")
            let book = try ops.createReading(name: "Atlas", kind: .book)
            #expect(throws: OperationError.readingAlreadyInWing(readingID: book.id, wingID: "")) {
                try ops.mcpMoveBookToWing(book.id, to: "", undoLabel: label)
            }
            #expect(throws: OperationError.wingNotFound(id: "nowhere")) {
                try ops.mcpMoveBookToWing(book.id, to: "nowhere", undoLabel: label)
            }
            let note = try ops.createPost(title: "held")
            _ = try ops.addPostToReading(note.id, to: book.id)
            let done = try ops.createReading(name: "Done", kind: .book)
            _ = try ops.addPostToReading(note.id, to: done.id)
            try ops.lockReading(done.id)
            #expect(throws: OperationError.lockedReading(id: done.id)) {
                try ops.mcpMoveBookToWing(book.id, to: studio.id, undoLabel: label)
            }
            #expect(throws: GuardRefused()) {
                try ops.mcpMoveBookToWing(book.id, to: studio.id, undoLabel: label, guardedBy: { _ in throw GuardRefused() })
            }
            #expect(stack.depth == 0)
        }
    }

    /// A-809-15 (P-809-10): a member that is also a member of a stay-behind
    /// PRIVATE book — or of the daily Journal — would leave the move UNFENCED;
    /// the act refuses whole and writes nothing. Red on the pre-fix act: her
    /// body alone lands and the note's fence drops.
    @Test func aMoveThatWouldShedAMembersFenceRefusesWholeAndWritesNothing() throws {
        try withUndo { ops, stack, db in
            let studio = try ops.createWing(name: "Studio")
            let book = try ops.createReading(name: "Atlas", kind: .book)
            let diary = try ops.createReading(name: "Diary", kind: .book)
            _ = try ops.setBookPrivate(diary.id, true)
            let secret = try ops.createPost(title: "fenced by the diary")
            _ = try ops.addPostToReading(secret.id, to: book.id)
            _ = try ops.addPostToReading(secret.id, to: diary.id)
            #expect(try db.read { try Queries.mcpNoteFacts($0, noteID: secret.id) }?.fence != nil)
            let before = try snapshot(db)
            #expect(throws: Operations.MCPBookMoveRefusal.wouldShedAFence) {
                try ops.mcpMoveBookToWing(book.id, to: studio.id, undoLabel: label)
            }
            #expect(try snapshot(db) == before && stack.depth == 0, "nothing written, nothing to undo")
        }
        try withUndo { ops, stack, db in
            let studio = try ops.createWing(name: "Studio")
            let entry = try ops.createPost(title: "a Journal member")
            _ = ops.shelveInDailyJournalBook(entry.id)
            let book = try ops.createReading(name: "Atlas", kind: .book)
            _ = try ops.addPostToReading(entry.id, to: book.id)
            #expect(try db.read { try Queries.mcpNoteFacts($0, noteID: entry.id) }?.fence != nil)
            #expect(throws: Operations.MCPBookMoveRefusal.wouldShedAFence) {
                try ops.mcpMoveBookToWing(book.id, to: studio.id, undoLabel: label)
            }
            #expect(try wing(db, "container", entry.id) == "" && stack.depth == 0)
        }
    }

    // MARK: - The undo (A-809-14 — the WRAP)

    @Test func theUndoPutsEveryRowBackAndTheRedoMovesTheSameRowsAgain() throws {
        try withUndo { ops, stack, db in
            let w = try build(ops)
            let before = try projection(db)
            _ = try ops.mcpMoveBookToWing(w.atlas, to: w.studio, undoLabel: label)
            let after = try projection(db)
            let undone = try #require(try stack.undoReporting(with: ops))
            #expect(undone.changed && undone.label == label)
            #expect(try projection(db) == before, "the book, its shelf, rule and outflow, every member, its memberships, applications and the dismissed arrival — exact rows")
            #expect(stack.redoDepth == 1)
            #expect(try stack.redo(with: ops) == label)
            #expect(try projection(db) == after, "the redo moves the same rows again — the same ids, never a re-run")
            #expect(try stack.undo(with: ops) == label)
            #expect(try projection(db) == before, "and round-trips")
        }
    }

    @Test func theUndoIsQuietWhenTheWorldMovedOn() throws {
        // Her door moved it back herself.
        try withUndo { ops, stack, db in
            let w = try build(ops)
            _ = try ops.mcpMoveBookToWing(w.atlas, to: w.studio, undoLabel: label)
            _ = try ops.moveReadingToWing(w.atlas, to: "")
            let moved = try projection(db)
            let depth = stack.depth
            let quiet = try #require(try stack.undoReporting(with: ops))
            #expect(!quiet.changed && quiet.label == label && stack.depth == depth - 1 && stack.redoDepth == 0,
                    "obsolete — quiet, retired")
            #expect(try projection(db) == moved)
        }
        // The book went to the Trash.
        try withUndo { ops, stack, _ in
            let w = try build(ops)
            _ = try ops.mcpMoveBookToWing(w.atlas, to: w.studio, undoLabel: label)
            try ops.deleteReading(w.atlas)
            #expect(try stack.undoReporting(with: ops)?.changed == false)
        }
    }

    @Test func aPartiallyAgedMoveRefusesItsUndoWholeAndKeepsTheEntry() throws {
        // Each way the act ages: a member tagged in the destination, a note
        // added to the book, the book shelved there, a severed book deleted.
        let agings: [(String, (Operations, World) throws -> Void)] = [
            ("a member took a tag in the destination", { ops, w in
                let tag = try ops.createTag(name: "fresh", wingID: w.studio)
                _ = try ops.applyTag(tag.id, toPost: w.four)
            }),
            ("a note joined the book there", { ops, w in
                let newcomer = try ops.createPost(title: "newcomer", wingId: w.studio)
                _ = try ops.addPostToReading(newcomer.id, to: w.atlas)
            }),
            ("the book was shelved there", { ops, w in
                let shelf = try ops.createShelf(name: "Studio shelf", wingID: w.studio)
                try ops.setReadingShelf(w.atlas, shelf: shelf.id)
            }),
            ("a severed membership's book was deleted", { ops, w in try ops.deleteReading(w.other) }),
        ]
        for (aging, act) in agings {
            try withUndo { ops, stack, db in
                let w = try build(ops)
                _ = try ops.mcpMoveBookToWing(w.atlas, to: w.studio, undoLabel: label)
                try act(ops, w)
                let aged = try projection(db)
                let depth = stack.depth
                #expect(stack.topLabel == label, "\(aging): the aging act registered no entry over ours")
                #expect(throws: Operations.MCPBookMoveRefusal.changedSince(bookID: w.atlas), "\(aging)") {
                    try stack.undo(with: ops)
                }
                #expect(try projection(db) == aged, "\(aging): nothing half-written")
                #expect(stack.depth == depth && stack.topLabel == label, "\(aging): the entry is kept (resolvable)")
            }
        }
    }

    @Test func theRedoRefusesKeepingTheEntryOverAFinishedStayBehindBook() throws {
        try withUndo { ops, stack, db in
            let w = try build(ops)
            _ = try ops.mcpMoveBookToWing(w.atlas, to: w.studio, undoLabel: label)
            _ = try stack.undo(with: ops)
            try ops.lockReading(w.other)
            #expect(throws: OperationError.lockedReading(id: w.other)) { try stack.redo(with: ops) }
            let stayed = try wing(db, "reading", w.atlas)
            #expect(stack.redoDepth == 1 && stayed == "")
        }
    }
}
