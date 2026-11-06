import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// **THE TWO-STORE CATALOG PIN** (VX-825 — the VX-809 run, batch 1; her ruling
// R-825: "every MCP answer is a PURE FUNCTION OF THE CLIENT'S REACHABLE STATE —
// nothing on the wire may vary with what the client cannot reach", pinned as:
// an answer must not differ between a store where hidden things exist and one
// where none do; R-825-sweep (c): EVERY tool's arms, refusals included).
//
// THREE stores are built through the same calls in the same order: A holds
// hidden things — Private notes and books, ungranted books and a whole ungranted
// wing, a fenced daily Journal entry, an owned book claiming a reachable note, a
// finished book holding one, a Private book collecting a reachable tag, a hidden
// book of a name the client will mint, a tag worn only by a hidden note, and a
// hidden note with a block, take, comment, commit and lens — and B and C hold
// none. The hidden rows are minted by a separate operations value with its own
// ids (`F0000000-…`), clock and jitter, so every REACHABLE id, stamp and
// position aligns across the three. The SAME client with the SAME grants then
// walks the same arms — every tool, its landed arms and its refusals, hidden
// ids passed in A where B and C pass the same strings naming nothing — and:
//
// - B == C on every arm (the CONTROL: the harness itself is deterministic);
// - A == B on every arm, byte for byte, except the ENUMERATED EXCEPTIONS
//   (A-809-4's one recorded class — a refusal forced by a hidden cause), each
//   asserted to differ in exactly the ruled way;
// - no answer in A carries a hidden id.
//
// The catalog table is the run record's BATCH 1 RECORD ("THE CATALOG"); batches
// 2–3 add their tools' arms here as they land.

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

/// Every id the arms name: the reachable world (aligned across the stores) and
/// the hidden one (minted in A; the same strings name nothing in B and C).
struct CatalogWorld: Sendable {
    var home = ""
    var studio = "", studioBook = "", studioMember = "", seed = ""
    var shared = "", capped = "", card = "", cardBlock = "", cardTake = "", cardTake2 = "", cardBlock2 = ""
    var cardComment = "", cardCommit = "", cardLens = "", second = "", work = "", workBlock1 = "", workBlock2 = ""
    var mover = "", ownedNote = "", stuck = "", loose = "", capMember = "", chapter = "", doomed = "", secretTopic = ""
    var board = "", freshStart = "", idea = "", cappedToo = "", tooMember = "", gathering = ""
    // VX-807 (batch 2): the books move_book_to_wing moves.
    var traveler = "", travOne = "", stuckBook = "", fencedBook = ""
    // VX-827 U1: the lineage arms' note (in the shared book) and its readable
    // Copy to Wing copy in Studio.
    var kin = "", kinCopy = ""
    // hidden (A only)
    var vault = "", secretBoard = "", finished = "", diary = "", twinStudio = "", attic = "", atticBook = ""
    var atticNote = "", journalEntry = "", privateShared = "", privateCapped = "", secretNote = ""
    var secretBlock = "", secretTake = "", secretComment = "", secretCommit = "", secretLens = ""
    var privateStudio = "", hiddenChapter = ""
    var journalBook = "", locket = ""
}

/// One call of the walk.
struct CatalogArm: Sendable {
    let label: String
    let tool: String
    let args: @Sendable (CatalogWorld, [String: String]) -> [String: Value]
    /// Ids an answer mints that later arms name (aligned across stores).
    var capture: (@Sendable ([String: Any]) -> [String: String])? = nil
}

@Suite("VX-825 — the two-store catalog: every answer is a pure function of reach", .serialized)
struct MCPTwoStoreCatalogServerTests {
    // MARK: - The world

    private func build(_ h: ServerHarness, hidden: Bool) async throws -> CatalogWorld {
        var w = CatalogWorld()
        let ops = h.operations
        let board = try ops.createTag(name: "board")
        w.board = board.id
        w.freshStart = try ops.createTag(name: "fresh-start").id
        // A tag of Home's vocabulary — in A worn only by a hidden note.
        w.secretTopic = try ops.createTag(name: "secret-topic").id
        // Studio — the client's EDIT wing.
        let studio = try ops.createWing(name: "Studio")
        w.studio = studio.id
        let idea = try ops.createTag(name: "idea", wingID: studio.id)
        w.idea = idea.id
        let studioBook = try ops.createReading(name: "Studio book", kind: .book, wingId: studio.id)
        w.studioBook = studioBook.id
        let member = try ops.createPost(title: "studio member", wingId: studio.id)
        _ = try ops.newBlock(in: member.id, text: "In the studio.", registeringUndo: false)
        _ = try ops.addPostToReading(member.id, to: studioBook.id)
        w.studioMember = member.id
        w.gathering = try ops.createReading(
            name: "Ideas gathered", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(idea.id)),
            wingId: studio.id).id
        let seed = try ops.createPost(title: "seed", wingId: studio.id)
        _ = try ops.newBlock(in: seed.id, text: "A seed of an idea, with words.", registeringUndo: false)
        _ = try ops.applyTag(idea.id, toPost: seed.id)
        w.seed = seed.id
        // Home — reached through book and note grants only.
        let shared = try ops.createReading(name: "Shared", kind: .book)
        w.shared = shared.id
        w.chapter = try ops.createSection(in: shared.id, name: "Part one").id
        let card = try ops.createPost(title: "card")
        let one = try ops.newBlock(in: card.id, text: "The first words of the card.", registeringUndo: false)
        let two = try ops.newBlock(in: card.id, text: "Second block, words again.", registeringUndo: false)
        let alt = try ops.branchVariant(two.block.id, from: two.variant.id)
        try ops.autosave(alt.id, text: "Second block, other words.", charDelta: 6)
        w.cardBlock = one.block.id
        w.cardTake = one.variant.id
        w.cardBlock2 = two.block.id
        w.cardTake2 = alt.id
        w.cardComment = try ops.addBlockComment(to: one.block.id, text: "a note to self").id
        w.cardCommit = try ops.commit(one.variant.id, message: "first").id
        w.cardLens = try ops.createLens(post: card.id, name: "draft lens").id
        _ = try ops.addPostToReading(card.id, to: shared.id)
        _ = try ops.applyTag(board.id, toPost: card.id)
        w.card = card.id
        let second = try ops.createPost(title: "second")
        _ = try ops.newBlock(in: second.id, text: "Second note, words.", registeringUndo: false)
        _ = try ops.addPostToReading(second.id, to: shared.id)
        w.second = second.id
        let work = try ops.createPost(title: "work")
        w.workBlock1 = try ops.newBlock(in: work.id, text: "Alpha sentence. Beta sentence.", registeringUndo: false).block.id
        w.workBlock2 = try ops.newBlock(in: work.id, text: "Gamma.", registeringUndo: false).block.id
        _ = try ops.addPostToReading(work.id, to: shared.id)
        w.work = work.id
        let mover = try ops.createPost(title: "mover")
        _ = try ops.newBlock(in: mover.id, text: "Moving on.", registeringUndo: false)
        _ = try ops.addPostToReading(mover.id, to: shared.id)
        _ = try ops.applyTag(board.id, toPost: mover.id)
        w.mover = mover.id
        let capped = try ops.createReading(name: "Capped", kind: .book, maxPosts: 2)
        w.capped = capped.id
        w.doomed = try ops.createReading(name: "Doomed", kind: .book).id
        let cappedToo = try ops.createReading(name: "Capped too", kind: .book, maxPosts: 2)
        w.cappedToo = cappedToo.id
        let tooMember = try ops.createPost(title: "too member")
        _ = try ops.newBlock(in: tooMember.id, text: "Capped too.", registeringUndo: false)
        _ = try ops.addPostToReading(tooMember.id, to: cappedToo.id)
        w.tooMember = tooMember.id
        let capMember = try ops.createPost(title: "cap member")
        _ = try ops.newBlock(in: capMember.id, text: "Capped words.", registeringUndo: false)
        _ = try ops.addPostToReading(capMember.id, to: capped.id)
        w.capMember = capMember.id
        for name in ["owned note", "stuck", "loose"] {
            let note = try ops.createPost(title: name)
            _ = try ops.newBlock(in: note.id, text: "\(name) words.", registeringUndo: false)
            switch name {
            case "owned note": w.ownedNote = note.id
            case "stuck": w.stuck = note.id
            default: w.loose = note.id
            }
        }
        // VX-807 (batch 2): Traveler (Home, collecting #travel at Arrivals) with
        // a member also in Shared; a book holding `stuck` (which a hidden
        // finished book holds in A); an empty book a hidden note joins in A.
        let travel = try ops.createTag(name: "travel")
        let traveler = try ops.createReading(
            name: "Traveler", kind: .book, querySpec: try RuleGrammar.encode(.tag(travel.id)), intakeSeating: .arrivals)
        w.traveler = traveler.id
        let travOne = try ops.createPost(title: "trav one")
        _ = try ops.newBlock(in: travOne.id, text: "Travelling words.", registeringUndo: false)
        _ = try ops.addPostToReading(travOne.id, to: traveler.id)
        _ = try ops.addPostToReading(travOne.id, to: shared.id)
        w.travOne = travOne.id
        let stuckBook = try ops.createReading(name: "Stuck book", kind: .book)
        _ = try ops.addPostToReading(w.stuck, to: stuckBook.id)
        w.stuckBook = stuckBook.id
        w.fencedBook = try ops.createReading(name: "Fenced book", kind: .book).id
        // VX-827 U1: `kin` (Home, in the shared book) and its Copy to Wing copy
        // in Studio — a READABLE peer in another wing; in A the hidden half
        // gives kin hidden relatives too (below).
        let kin = try ops.createPost(title: "kin")
        _ = try ops.newBlock(in: kin.id, text: "Kin words, first.", registeringUndo: false)
        _ = try ops.newBlock(in: kin.id, text: "Kin words, second.", registeringUndo: false)
        _ = try ops.addPostToReading(kin.id, to: shared.id)
        w.kin = kin.id
        w.kinCopy = try ops.copyNoteToWing(kin.id, to: studio.id).id
        if hidden { try buildHidden(h, &w, board: board.id, idea: idea.id) }
        return w
    }

    /// THE HIDDEN HALF (A only) — its own ids, clock and jitter.
    private func buildHidden(_ h: ServerHarness, _ w: inout CatalogWorld, board: String, idea: String) throws {
        let ops = hiddenOperations(h)
        try withDependencies {
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(HarnessSeededGenerator(seed: 0xF00D))
        } operation: {
            // An OWNED book claims a reachable note (add_note_to_book's hidden cause).
            let vault = try ops.createReading(name: "Vault", kind: .book)
            _ = try ops.setReadingOwned(vault.id, owned: true)
            _ = try ops.addPostToReading(w.ownedNote, to: vault.id)
            w.vault = vault.id
            // A living board collecting #board (backfill seats card and mover).
            w.secretBoard = try ops.createReading(
                name: "Secret board", kind: .book, querySpec: try RuleGrammar.encode(.tag(board))).id
            // A FINISHED book holding a reachable note (the move's hidden cause).
            let finished = try ops.createReading(name: "Done and dusted", kind: .book)
            _ = try ops.addPostToReading(w.stuck, to: finished.id)
            try ops.lockReading(finished.id)
            w.finished = finished.id
            // A PRIVATE book in Studio collecting #idea — the seed taken out
            // again (a decided pair), so it hears only a COPY's tagging.
            let diary = try ops.createReading(
                name: "Diary", kind: .book, querySpec: try RuleGrammar.encode(.tag(idea)), wingId: w.studio)
            _ = try ops.setBookPrivate(diary.id, true)
            _ = try ops.removePostFromReading(w.seed, from: diary.id)
            w.diary = diary.id
            // Hidden books of the names the client will mint and rename toward
            // — one per name arm (a name a READABLE book took first would test
            // the readable collision instead).
            for name in ["Twin import", "Twin book", "Twin gathering", "Twin rename"] {
                let twin = try ops.createReading(name: name, kind: .book, wingId: w.studio)
                _ = try ops.setBookPrivate(twin.id, true)
                w.twinStudio = twin.id
            }
            // A whole ungranted wing.
            let attic = try ops.createWing(name: "Attic")
            w.attic = attic.id
            let atticBook = try ops.createReading(name: "Attic book", kind: .book, wingId: attic.id)
            w.atticBook = atticBook.id
            let atticNote = try ops.createPost(title: "attic note", wingId: attic.id)
            _ = try ops.newBlock(in: atticNote.id, text: "zebra words in the attic.", registeringUndo: false)
            _ = try ops.addPostToReading(atticNote.id, to: atticBook.id)
            w.atticNote = atticNote.id
            // The daily Journal and a day's entry (fenced).
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-06-30").container
            _ = try ops.newBlock(in: entry.id, text: "Dear diary, zebra words.", registeringUndo: false)
            _ = ops.shelveInDailyJournalBook(entry.id)
            w.journalEntry = entry.id
            // PRIVATE members of the reachable books (hidden members).
            for (book, field) in [(w.shared, 0), (w.capped, 1), (w.doomed, 2), (w.cappedToo, 3)] {
                let note = try ops.createPost(title: "private member \(field)")
                _ = try ops.newBlock(in: note.id, text: "zebra words, private.", registeringUndo: false)
                _ = try ops.setNotePrivate(note.id, true)
                _ = try ops.addPostToReading(note.id, to: book)
                if field == 0 { w.privateShared = note.id } else if field == 1 { w.privateCapped = note.id }
            }
            // A hidden chapter in a hidden book.
            w.hiddenChapter = try ops.createSection(in: w.secretBoard, name: "Hidden chapter").id
            // An ungranted Home note wearing a tag no readable note wears, with
            // a block, a take, a comment, a commit and a lens.
            let note = try ops.createPost(title: "secret note")
            let block = try ops.newBlock(in: note.id, text: "zebra words, secret.", registeringUndo: false)
            _ = try ops.applyTag(w.secretTopic, toPost: note.id)
            w.secretNote = note.id
            w.secretBlock = block.block.id
            w.secretTake = block.variant.id
            w.secretComment = try ops.addBlockComment(to: block.block.id, text: "secret comment").id
            w.secretCommit = try ops.commit(block.variant.id, message: "secret").id
            w.secretLens = try ops.createLens(post: note.id, name: "secret lens").id
            // A PRIVATE note in the Studio Pool.
            let privateStudio = try ops.createPost(title: "private studio", wingId: w.studio)
            _ = try ops.newBlock(in: privateStudio.id, text: "zebra words in the studio.", registeringUndo: false)
            _ = try ops.setNotePrivate(privateStudio.id, true)
            _ = try ops.applyTag(w.idea, toPost: privateStudio.id)  // a gathering assembles it; the fence filters it
            w.privateStudio = privateStudio.id
            // A Private member FIRST in the shared book's order (a page that
            // starts on a hidden row).
            let first = try ops.createPost(title: "private first")
            _ = try ops.newBlock(in: first.id, text: "zebra words, first.", registeringUndo: false)
            _ = try ops.setNotePrivate(first.id, true)
            _ = try ops.addPostToReading(first.id, to: w.shared, at: .start)
            // VX-807 (batch 2): Traveler's hidden things — a Private member, a
            // hidden book also holding its readable member, a hidden note
            // waiting at its Arrivals, a hidden twin of its name in Studio.
            let privateTraveler = try ops.createPost(title: "private traveler")
            _ = try ops.setNotePrivate(privateTraveler.id, true)
            _ = try ops.addPostToReading(privateTraveler.id, to: w.traveler)
            let keeper = try ops.createReading(name: "Keeper", kind: .book)
            _ = try ops.addPostToReading(w.travOne, to: keeper.id)
            let travelTag = try #require(try h.database.read {
                try String.fetchOne($0, sql: "SELECT id FROM tag WHERE path = 'travel' AND wing_id = ''")
            })
            let waiter = try ops.createPost(title: "hidden waiter")
            _ = try ops.applyTag(travelTag, toPost: waiter.id)
            let twin = try ops.createReading(name: "Traveler", kind: .book, wingId: w.studio)
            _ = try ops.setBookPrivate(twin.id, true)
            // A hidden note in the Fenced book, fenced by a hidden PRIVATE book
            // (the move would shed its fence — A-809-15).
            let fenced = try ops.createPost(title: "locked away")
            _ = try ops.addPostToReading(fenced.id, to: w.fencedBook)
            let locket = try ops.createReading(name: "Locket", kind: .book)
            _ = try ops.addPostToReading(fenced.id, to: locket.id)
            _ = try ops.setBookPrivate(locket.id, true)
            w.locket = locket.id
            w.journalBook = try #require(try h.database.read { try Queries.dailyJournalBookID($0) })
            // A-809-11 (batch 3): a PRIVATE book in Studio collecting ★ — a
            // client's star on a Studio note is heard there (the tail's F-5
            // star rows).
            let starDiary = try ops.createReading(
                name: "Star diary", kind: .book, querySpec: try RuleGrammar.encode(.star), wingId: w.studio)
            _ = try ops.setBookPrivate(starDiary.id, true)
            // VX-814 (batch 3): a tag of the hidden wing whose path a client's
            // birth tag names — per-wing vocabulary makes it a non-event.
            let atticTopic = try ops.createTag(name: "attic-topic", wingID: w.attic)
            // VX-827 U1 (her F-U1-1 ruling): `kin`'s HIDDEN relatives — her
            // Duplicate (bookless in Home's Pool, ungranted: a copy by every
            // block + a version link), and version links to a Private note, a
            // note in the hidden wing and the daily Journal's entry. Only edges
            // and a copy are minted; no reachable row changes.
            _ = try ops.duplicateAsVersion(w.kin, tags: .none)
            for relative in [w.privateShared, w.atticNote, w.journalEntry] {
                _ = try ops.markPostsAsVersions(w.kin, relative)
            }
            // VX-827 U2 (VX-810): hidden WEARERS of tags the client can name — the
            // shared book's Private member wears #board, the hidden secret note's
            // BLOCK wears #board, the hidden wing's note wears its own
            // #attic-topic (the Private Studio note's #idea is above) — so the
            // list-by-tag arms meet them: absent, never hinted. Applications only;
            // no reachable row changes.
            _ = try ops.applyTag(board, toPost: w.privateShared)
            _ = try ops.applyTag(board, toBlock: w.secretBlock)
            _ = try ops.applyTag(atticTopic.id, toPost: w.atticNote)
        }
    }

    /// The client and its grants — the same in every store.
    private func connect(_ h: ServerHarness, _ w: CatalogWorld) async throws -> HarnessConnection {
        // The app's delivery, stubbed: every show lands as an offer (the dial's
        // default), so the landed show arm is walked past the reach decision.
        h.host.hooks.show = { _ in .offer }
        let connection = try await h.connect(as: "claude-code")
        _ = try h.approve("claude-code", spec(.edit, .book, w.shared))
        let client = try h.client("claude-code").id
        _ = try h.operations.grantMCPAccess(client, spec(.edit, .wing, w.studio))
        _ = try h.operations.grantMCPAccess(client, spec(.edit, .book, w.capped))
        _ = try h.operations.grantMCPAccess(client, spec(.edit, .book, w.doomed))
        _ = try h.operations.grantMCPAccess(client, spec(.edit, .book, w.cappedToo))
        for note in [w.ownedNote, w.stuck] { _ = try h.operations.grantMCPAccess(client, spec(.edit, .note, note)) }
        // VX-807 (batch 2): edit on the books the move arms move.
        for book in [w.traveler, w.stuckBook, w.fencedBook] {
            _ = try h.operations.grantMCPAccess(client, spec(.edit, .book, book))
        }
        _ = try h.operations.grantMCPAccess(client, spec(.read, .note, w.loose))
        return connection
    }

    // MARK: - The walk

    /// What each store answered, arm by arm.
    private func walk(_ hidden: Bool, hiddenIDs: CatalogWorld?) async throws -> (CatalogWorld, [(String, Bool, String)]) {
        let h = try ServerHarness(seed: 0xC0FFEE)
        defer { h.tearDown() }
        return try await h.within {
            var w = try await build(h, hidden: hidden)
            if let ids = hiddenIDs, !hidden { w.copyHidden(from: ids) }
            let connection = try await connect(h, w)
            var captured: [String: String] = [:]
            var answers: [(String, Bool, String)] = []
            let fixture = Self.harnessIDs(in: String(describing: w))
            var minted: [String: String] = [:]
            for (index, arm) in Self.arms.enumerated() {
                let result = try await connection.client.callTool(name: arm.tool, arguments: arm.args(w, captured))
                let raw = text(result)
                var said = raw
                // An id the WALK minted compares as an identity — its order of
                // first appearance in this store's walk — because production
                // ids are random (UUIDv4): the harness's incrementing counter
                // would otherwise turn a row the client never sees (a hidden
                // book seating a copy) into a shifted id. Fixture ids stay raw,
                // and so do the hidden `F0000000-…` ids (the crossing check).
                // Named per ARM (the arm that first said it, then its order
                // there), so an arm that mints in one store only — an
                // exception's landing — never renumbers another arm's ids.
                var local = 0
                for id in Self.harnessIDs(in: said).subtracting(fixture)
                    .sorted(by: { said.range(of: $0)!.lowerBound < said.range(of: $1)!.lowerBound })
                where minted[id] == nil {
                    minted[id] = "<minted-\(index).\(local)>"
                    local += 1
                }
                for (id, name) in minted { said = said.replacingOccurrences(of: id, with: name) }
                answers.append((arm.label, result.isError == true, said))
                if let capture = arm.capture, result.isError != true,
                   let object = try? JSONSerialization.jsonObject(with: Data(raw.utf8)) as? [String: Any] {
                    captured.merge(capture(object)) { $1 }
                }
            }
            await h.hangUp(connection)
            return (w, answers)
        }
    }

    /// **THE PIN.**
    @Test func everyArmOfEveryToolAnswersTheSameWhetherHiddenThingsExistOrNot() async throws {
        let (hiddenWorld, a) = try await walk(true, hiddenIDs: nil)
        let (_, b) = try await walk(false, hiddenIDs: hiddenWorld)
        let (_, c) = try await walk(false, hiddenIDs: hiddenWorld)
        #expect(a.count == b.count && b.count == c.count)
        var table: [String] = []
        for index in a.indices {
            let (label, aError, aText) = a[index]
            let (_, bError, bText) = b[index]
            let (_, cError, cText) = c[index]
            #expect(bText == cText && bError == cError, "CONTROL broke at \(label) — the harness is nondeterministic:\n\(bText)\n\(cText)")
            // A hidden id the CLIENT typed rides back the same in every store
            // (its own argument); one only A's answer carries is a crossing.
            let crossed = Self.hiddenIDs(in: aText).subtracting(Self.hiddenIDs(in: bText))
            #expect(crossed.isEmpty, "\(label): a hidden id crossed: \(crossed) in \(aText)")
            let shape = aError ? "refused" : "landed"
            if let finding = Self.pendingFindings[label] {
                // A FINDING awaiting its ruling (the record's F-5): the act's
                // answer is pure, but its CONSEQUENCE moves the client's reach
                // — the observed behavior asserted exactly, so a change is seen.
                #expect(aText != bText && aError && aText.hasPrefix("That note isn't shared with this client"),
                        "\(label): the pending finding changed shape: \(aText)")
                table.append("| \(label) | A refused / B landed | PENDING FINDING (\(finding)) |")
            } else if let expected = Self.exception(label, hiddenWorld) {
                #expect(aText != bText, "\(label) is an enumerated exception but answered the same")
                #expect(aError && aText == expected.hiddenWords, "\(label): the hidden cause speaks exactly: \(aText)")
                table.append("| \(label) | A \(shape) / B \(bError ? "refused" : "landed") | EXCEPTION (\(expected.why)) |")
            } else {
                #expect(aText == bText && aError == bError, "\(label) varies with what the client cannot reach:\nA: \(aText)\nB: \(bText)")
                table.append("| \(label) | \(shape) | \(aText == bText ? "IDENTICAL" : "DIFFERS") |")
            }
        }
        if let path = ProcessInfo.processInfo.environment["VX825_CATALOG_TABLE"] {
            try table.joined(separator: "\n").write(toFile: path, atomically: true, encoding: .utf8)
            let said = a.map { "\($0.0)\t\($0.1 ? "refused" : "landed")\t\($0.2.prefix(300))" }
            try said.joined(separator: "\n").write(toFile: path + ".answers", atomically: true, encoding: .utf8)
        }
    }

    /// The walk covers the WHOLE catalog: every tool the door declares has at
    /// least one arm (a tool batches 2–3 add must add its arms here), and every
    /// arm names a declared tool.
    @Test func theWalkCoversEveryDeclaredTool() {
        let walked = Set(Self.arms.map(\.tool))
        let declared = Set(MCPToolCatalog.all.map(\.name))
        #expect(walked == declared, "unwalked: \(declared.subtracting(walked)); undeclared: \(walked.subtracting(declared))")
        #expect(Set(Self.arms.map(\.label)).count == Self.arms.count, "every arm's label is its own")
    }

    /// **FINDINGS awaiting the orchestrator's ruling** — NONE since A-809-11's
    /// build (the VX-809 run, batch 3). F-5 sat here: an act the CLIENT landed
    /// applied a tag, a PRIVATE book collecting it SEATED the note, and the
    /// client's next read answered not-shared where a store without the
    /// Private book read it. A wire act's would-be seat where membership fences
    /// now BELLS (P-809-8), so its rows — the seed's copy, the studio member
    /// after its tag, the seed after its star — are pure arms, compared byte
    /// for byte (their red-on-old is the record's B3-3). The mechanism stays
    /// for the next finding a walk turns up.
    static let pendingFindings: [String: String] = [:]

    /// The harness's own (incrementing) ids a text carries.
    static func harnessIDs(in text: String) -> Set<String> {
        Set(text.matches(of: /00000000-0000-0000-0000-[0-9A-F]{12}/).map { String($0.output) })
    }

    /// The `F0000000-…` ids a text carries — inside its opaque cursors too
    /// (a cursor is base64 of the row it resumes after: VX-825 found one
    /// naming a hidden note there).
    static func hiddenIDs(in text: String) -> Set<String> {
        let cursors = text.matches(of: /"next_cursor":"([A-Za-z0-9+\/=]+)"/).compactMap {
            Data(base64Encoded: String($0.output.1)).map { String(decoding: $0, as: UTF8.self) }
        }
        return Set(([text] + cursors).flatMap {
            $0.matches(of: /F0000000-0000-0000-0000-[0-9A-F]{12}/).map { String($0.output) }
        })
    }

    /// A-809-4's ONE recorded exception class — a refusal forced by a cause the
    /// store without the hidden thing does not have — each arm with the exact
    /// words store A must answer: the act family's fixed sentence (P-809-2) where
    /// the cause is an unreadable entity, and (S-1, QUESTIONS #218 standing) her
    /// capacity words about the READABLE add-target where it is fullness.
    static func exception(_ label: String, _ w: CatalogWorld) -> (hiddenWords: String, why: String)? {
        func atCapacity(_ id: String) -> String { "Refused: \(OperationError.readingAtCapacity(id: id))" }
        return [
            "add_note_to_book · a note an unreadable owned book claims":
                (MCPWriteTools.addHiddenCauseWords, "A-809-4 / P-809-2 — the owner is beyond reach"),
            "move_note_to_wing · a note an unreadable finished book holds":
                (MCPWriteTools.moveHiddenCauseWords, "A-809-4 S-2 — the frozen book is beyond reach"),
            "create_note · a capped book (a Private member fills it)":
                (atCapacity(w.cappedToo), "A-809-4 S-1 — fullness of the readable target; #218 stands"),
            "add_note_to_book · the capped book (a Private member fills it)":
                (atCapacity(w.capped), "A-809-4 S-1 — fullness of the readable target; #218 stands"),
            // VX-807 (batch 2): the book move's hidden causes.
            "move_book_to_wing · a book whose note an unreadable finished book holds":
                (MCPWriteTools.bookMoveHiddenCauseWords, "A-809-4 — the frozen book is beyond reach"),
            "move_book_to_wing · a book a hidden note in a Private book sits in (its fence would drop)":
                (MCPWriteTools.bookMoveHiddenCauseWords, "A-809-15 / P-809-10 — the move would shed a fence"),
        ][label]
    }
}

extension CatalogWorld {
    /// B and C pass A's hidden ids — strings that name nothing there.
    mutating func copyHidden(from a: CatalogWorld) {
        vault = a.vault; secretBoard = a.secretBoard; finished = a.finished; diary = a.diary
        twinStudio = a.twinStudio; attic = a.attic; atticBook = a.atticBook; atticNote = a.atticNote
        journalEntry = a.journalEntry; privateShared = a.privateShared; privateCapped = a.privateCapped
        secretNote = a.secretNote; secretBlock = a.secretBlock; secretTake = a.secretTake
        secretComment = a.secretComment; secretCommit = a.secretCommit; secretLens = a.secretLens
        privateStudio = a.privateStudio; hiddenChapter = a.hiddenChapter
        journalBook = a.journalBook; locket = a.locket
    }
}
