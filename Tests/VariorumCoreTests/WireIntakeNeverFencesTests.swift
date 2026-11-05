import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// A-809-11 — THE F-5 BUILD (the VX-809 run, batch 3; PROVISIONAL P-809-8): an
// intake seat a WIRE applying act triggers never FENCES the note. Where the
// seat's landing would make the note fenced — a Private book, THE daily
// Journal — it BELLS instead (an arrival is no membership, so no fence; her
// seat from Arrivals is her act). Her own acts are untouched; un-tag and
// un-star stay non-events.
//
// Two layers here, both headless: the pure table (`IntakeDecision.verdict`'s
// new row, exhaustively — the arm only ever turns a SEAT into a BELL, and only
// for a wire client's act where membership fences) and the core acts on a value
// heard as the client's (`Operations.heardAsWireClient()`), road by road through
// the one application road. The red-on-old evidence is the wire's
// (`MCPWireIntakeNeverFencesServerTests` + the two-store catalog's F-5 rows):
// these pins name an API the pre-fix tree did not have.

@Suite("A-809-11 — a wire act's intake never fences the note (P-809-8)")
struct WireIntakeNeverFencesTests {
    typealias D = IntakeDecision

    // MARK: - The pure table

    private func book(
        fences: Bool, isLive: Bool = true, isBook: Bool = true, rule: D.RuleState = .readable,
        locked: Bool = false, seating: IntakeSeating? = nil, maxPosts: Int? = nil,
        memberCount: Int = 0, owned: Bool = false, archived: Bool = false
    ) -> D.BookFacts {
        D.BookFacts(
            isLive: isLive, isBook: isBook, rule: rule, locked: locked, seating: seating,
            maxPosts: maxPosts, memberCount: memberCount, owned: owned, archived: archived,
            membershipFences: fences)
    }

    @Test func aWireClientsWouldBeSeatWhereMembershipFencesBellsOnEveryOccasion() {
        let free = D.NoteFacts(matchesRule: true, pair: .fresh, memberedElsewhere: false, ownedElsewhere: false)
        for occasion in [D.Occasion.event, .backfill] {
            #expect(D.verdict(book: book(fences: true), note: free, occasion: occasion, actor: .wireClient) == .arrival)
            #expect(D.verdict(book: book(fences: true), note: free, occasion: occasion, actor: .author) == .seat,
                    "her own act seats as it always did")
            #expect(D.verdict(book: book(fences: false), note: free, occasion: occasion, actor: .wireClient) == .seat,
                    "a book whose membership fences nothing seats a wire act's note")
        }
        // An OWNED fencing book claiming a free note is a seat too — it bells.
        #expect(D.verdict(book: book(fences: true, owned: true), note: free, occasion: .event, actor: .wireClient)
                == .arrival)
        // The default actor is hers: every pre-A-809-11 caller reads as before.
        #expect(D.verdict(book: book(fences: true), note: free, occasion: .event) == .seat)
    }

    /// THE ARM'S WHOLE REACH, exhaustively: over every combination of book and
    /// note facts and every occasion, a wire client's verdict equals hers —
    /// EXCEPT that her SEAT where membership fences is the wire's ARRIVAL. It
    /// never invents a row (nothing → nothing), never drops one, never seats.
    @Test func theArmOnlyEverTurnsHerSeatIntoABellWhereMembershipFences() {
        var cases = 0
        for fences in [false, true] {
            for isLive in [false, true] { for isBook in [false, true] {
                for rule in [D.RuleState.none, .malformed, .readable] { for locked in [false, true] {
                    for seating in [IntakeSeating?.none, .auto, .arrivals] { for full in [false, true] {
                        for owned in [false, true] { for archived in [false, true] {
                            let facts = book(
                                fences: fences, isLive: isLive, isBook: isBook, rule: rule, locked: locked,
                                seating: seating, maxPosts: full ? 1 : nil, memberCount: full ? 1 : 0,
                                owned: owned, archived: archived)
                            for matches in [false, true] {
                                for pair in [D.PairState.fresh, .live, .leftAsMember, .dismissed] {
                                    for (membered, ownedElsewhere) in [(false, false), (true, false), (true, true)] {
                                        let note = D.NoteFacts(
                                            matchesRule: matches, pair: pair,
                                            memberedElsewhere: membered, ownedElsewhere: ownedElsewhere)
                                        for occasion in [D.Occasion.event, .backfill, .catchUp] {
                                            let hers = D.verdict(book: facts, note: note, occasion: occasion, actor: .author)
                                            let wire = D.verdict(book: facts, note: note, occasion: occasion, actor: .wireClient)
                                            let expected: D.Verdict = (hers == .seat && fences) ? .arrival : hers
                                            #expect(wire == expected, "fences \(fences) · \(facts) · \(note) · \(occasion)")
                                            cases += 1
                                        }
                                    }
                                }
                            }
                        } }
                    } }
                } }
            } }
        }
        #expect(cases == 2 * 2 * 2 * 3 * 2 * 3 * 2 * 2 * 2 * 2 * 4 * 3 * 3)
    }

    // MARK: - The book's fact (the fence's two book legs, one derivation site)

    @Test func membershipFencesInAPrivateBookAndTheDailyJournalOnly() throws {
        try withOperations { ops, db in
            let plain = try ops.createReading(name: "plain", kind: .book)
            let trait = try ops.createReading(name: "a notebook", kind: .book, profile: "journal")
            let diary = try ops.createReading(name: "diary", kind: .book)
            _ = try ops.setBookPrivate(diary.id, true)
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-06-30").container
            _ = ops.shelveInDailyJournalBook(entry.id)
            let journal = try #require(try db.read { try Queries.dailyJournalBookID($0) })
            let gone = try ops.createReading(name: "gone", kind: .book)
            _ = try ops.setBookPrivate(gone.id, true)
            try ops.deleteReading(gone.id)
            func fences(_ id: String) throws -> Bool {
                try db.read { try Queries.membershipFencesNotes($0, readingID: id) }
            }
            #expect(try fences(plain.id) == false)
            #expect(try fences(trait.id) == false, "a journal TRAIT is no fence leg (VX-163)")
            #expect(try fences(diary.id) == true)
            #expect(try fences(journal) == true)
            #expect(try fences(gone.id) == false, "a dead book fences nothing")
            #expect(try fences("no-such-book") == false)
        }
    }

    // MARK: - The operations value

    @Test func theWireHandIsAPropertyOfTheValueNeverOfTheRunner() throws {
        let stack = UndoStack()
        let hers = Operations(undoStack: stack)
        let wire = hers.heardAsWireClient()
        #expect(hers.intakeActor == .author)
        #expect(wire.intakeActor == .wireClient)
        #expect(wire.undoStack === stack, "the wire's acts register on HER stack — one ⌥⌘Z")
        #expect(Operations().intakeActor == .author, "every value her doors build is hers")
    }

    // MARK: - The core acts, road by road through the one application road

    /// The world: in Home, a PRIVATE book collecting #topic and ★ (joins
    /// quietly — her intake would SEAT), a plain book collecting #topic (the
    /// control: a wire act still seats where membership fences nothing).
    private struct World {
        let topic: VariorumCore.Tag
        let diary: Reading
        let stars: Reading
        let plain: Reading
    }

    private func world(_ ops: Operations) throws -> World {
        let topic = try ops.createTag(name: "topic")
        let diary = try ops.createReading(name: "Diary", kind: .book, querySpec: try RuleGrammar.encode(.tag(topic.id)))
        _ = try ops.setBookPrivate(diary.id, true)
        let stars = try ops.createReading(name: "Starred diary", kind: .book, querySpec: try RuleGrammar.encode(.star))
        _ = try ops.setBookPrivate(stars.id, true)
        let plain = try ops.createReading(name: "Plain", kind: .book, querySpec: try RuleGrammar.encode(.tag(topic.id)))
        return World(topic: topic, diary: diary, stars: stars, plain: plain)
    }

    /// The pair's live rows' statuses (every live row — never more than one).
    private func rows(_ db: AppDatabase, _ readingID: String, _ postID: String) throws -> [String] {
        try db.read {
            try String.fetchAll(
                $0,
                sql: "SELECT status FROM reading_post WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL",
                arguments: [readingID, postID])
        }
    }

    private func fence(_ db: AppDatabase, _ postID: String) throws -> MCPGrantRule.Fence? {
        try db.read { try #require(try Queries.mcpNoteFacts($0, noteID: postID)).fence }
    }

    /// The state pin, one note: the arrival row stands at the fencing book, NO
    /// membership there, the note UNFENCED (the fence's own facts).
    private func expectBelledUnfenced(
        _ db: AppDatabase, _ readingID: String, _ postID: String, _ road: String
    ) throws {
        #expect(try rows(db, readingID, postID) == ["arrival"], "\(road): the would-be seat waits at the door")
        #expect(try fence(db, postID) == nil, "\(road): the note stays as reachable as the act found it")
    }

    @Test func applyTagOnTheWireBellsAtAPrivateBookAndStillSeatsAPlainOne() throws {
        try withOperations { her, db in
            let w = try world(her)
            let wire = her.heardAsWireClient()
            let note = try her.createPost(title: "the client's")
            _ = try wire.applyTagPath("topic", toPost: note.id, undoLabel: "claude-code's tag")
            try expectBelledUnfenced(db, w.diary.id, note.id, "apply_tag")
            #expect(try rows(db, w.plain.id, note.id) == ["member"], "a plain book seats a wire act's note")
            // HER act, the parity witness: her intake seats — the note is fenced.
            let mine = try her.createPost(title: "hers")
            _ = try her.applyTag(w.topic.id, toPost: mine.id)
            #expect(try rows(db, w.diary.id, mine.id) == ["member"])
            #expect(try fence(db, mine.id) == .privateMark, "her own seat fences, as it always did")
            // Un-tag is a non-event: the arrival stays waiting, nothing new.
            _ = try wire.removeTagForClient(path: "topic", fromNote: note.id, undoLabel: "claude-code's tag removal")
            #expect(try rows(db, w.diary.id, note.id) == ["arrival"], "un-tagging never evicts (§19)")
            // Her seat from Arrivals is HER act — it fences, by her hand.
            let arrival = try #require(try db.read {
                try String.fetchOne($0, sql: "SELECT id FROM reading_post WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL",
                                    arguments: [w.diary.id, note.id])
            })
            _ = try her.seatArrival(arrival)
            #expect(try fence(db, note.id) == .privateMark)
        }
    }

    @Test func aStarOnTheWireBellsAtAPrivateStarBookAndUnstarringIsANonEvent() throws {
        try withOperations { her, db in
            let w = try world(her)
            let wire = her.heardAsWireClient()
            let note = try her.createPost(title: "starry")
            _ = try wire.setStarredForClient(.post(note.id), starred: true, undoLabel: "claude-code's star")
            try expectBelledUnfenced(db, w.stars.id, note.id, "set_starred")
            _ = try wire.setStarredForClient(.post(note.id), starred: false, undoLabel: "claude-code's unstar")
            #expect(try rows(db, w.stars.id, note.id) == ["arrival"], "un-starring never evicts (§19)")
            let mine = try her.createPost(title: "her star")
            try her.setStarred(.post(mine.id), starred: true)
            #expect(try rows(db, w.stars.id, mine.id) == ["member"], "her star seats, as it always did")
        }
    }

    @Test func theDailyJournalsWouldBeSeatBellsForAWireAct() throws {
        try withOperations { her, db in
            let topic = try her.createTag(name: "day-topic")
            let entry = try her.createOrOpenJournalEntry(entryDate: "2026-06-30").container
            _ = her.shelveInDailyJournalBook(entry.id)
            let journal = try #require(try db.read { try Queries.dailyJournalBookID($0) })
            try her.setReadingQuerySpec(journal, querySpec: try RuleGrammar.encode(.tag(topic.id)))
            let note = try her.createPost(title: "a wire note")
            _ = try her.heardAsWireClient().applyTagPath("day-topic", toPost: note.id, undoLabel: "claude-code's tag")
            try expectBelledUnfenced(db, journal, note.id, "apply_tag into the daily Journal's rule")
            let mine = try her.createPost(title: "hers")
            _ = try her.applyTag(topic.id, toPost: mine.id)
            #expect(try rows(db, journal, mine.id) == ["member"])
            #expect(try fence(db, mine.id) == .journal, "her own seat fences, as it always did")
        }
    }

    /// The OUTFLOW road: a wire mint into a book whose outflow tag a Private
    /// book collects — the outflow's application is the client's act too.
    @Test func aWireMintsOutflowBellsAtAPrivateBook() throws {
        try withOperations { her, db in
            let w = try world(her)
            let filed = try her.createReading(name: "Filed", kind: .book)
            try her.setReadingOutflow(filed.id, tagIDs: [w.topic.id])
            let minted = try her.heardAsWireClient().createNote(
                title: "filed", text: "Words.", in: .book(filed.id), undoLabel: "claude-code's note")
            #expect(try rows(db, filed.id, minted.post.id) == ["member"], "the client's own filing lands")
            try expectBelledUnfenced(db, w.diary.id, minted.post.id, "create_note's outflow")
            // add_note_to_book's outflow, the same road.
            let loose = try her.createPost(title: "loose")
            _ = try her.heardAsWireClient().addNoteToBookForClient(loose.id, book: filed.id, undoLabel: "claude-code's add")
            try expectBelledUnfenced(db, w.diary.id, loose.id, "add_note_to_book's outflow")
        }
    }

    /// The DUPLICATE body (her door's, shared) and the IMPORT header.
    @Test func aWireDuplicateWithTagsAndAWireImportsHeaderBellAtAPrivateBook() throws {
        try withOperations { her, db in
            let w = try world(her)
            let source = try her.createPost(title: "source")
            _ = try her.newBlock(in: source.id, text: "Source words.", registeringUndo: false)
            _ = try her.applyTag(w.topic.id, toPost: source.id)
            // Her seat fenced the SOURCE; take it out of the Diary (a decided
            // pair), so only the copy's tagging is heard there.
            _ = try her.removePostFromReading(source.id, from: w.diary.id)
            let copy = try her.heardAsWireClient().duplicateNoteForClient(
                source.id, filing: nil, undoLabel: "claude-code's duplicate")
            try expectBelledUnfenced(db, w.diary.id, copy.copy.post.id, "duplicate_note with_tags")
            #expect(!copy.memberBookIDs.contains(w.diary.id), "an arrival is no membership — never answered as one")
            let imported = try her.heardAsWireClient().importNote(
                VariorumDocument.NamedDocument(
                    fallbackTitle: "", document: try VariorumDocument.parse("{#topic}\n\nImported words.")),
                in: .wing(""), undoLabel: "claude-code's import")
            try expectBelledUnfenced(db, w.diary.id, imported.post.id, "import_document's header")
        }
    }
}
