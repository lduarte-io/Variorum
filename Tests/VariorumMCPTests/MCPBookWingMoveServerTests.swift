import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-807 (the VX-809 run, batch 2 — her R-807; the orchestrator's A-809-2/-14/-15/
// -16; R-805-5) — `move_book_to_wing` end to end over the socket: EDIT on the
// book + WRITE NEW on the destination wing (the note move's R1, one level up),
// once grants of both sides spent together; the reach-scoped answer (hidden
// members, hidden stay-behind books, hidden waiting notes neither named nor
// counted; `beyond_reach` always); the receipt and the ONE client-named undo;
// the refusals — R-805-5's daily Journal AT THE WIRE, a gathering (A-809-16), a
// frozen stay-behind book in her words where readable and the fixed sentence
// where not, a shed fence (A-809-15).

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

private func call(
    _ connection: HarnessConnection, _ name: String, _ arguments: [String: Value]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: name, arguments: arguments)
}

private func object(_ result: (content: [Tool.Content], isError: Bool?)) throws -> [String: Any] {
    try #require(try JSONSerialization.jsonObject(with: Data(text(result).utf8)) as? [String: Any])
}

@Suite("VX-807 — move_book_to_wing on the wire", .serialized)
struct MCPBookWingMoveServerTests {
    private func wingOf(_ h: ServerHarness, _ table: String, _ id: String) throws -> String? {
        try h.database.read { try String.fetchOne($0, sql: "SELECT wing_id FROM \(table) WHERE id = ?", arguments: [id]) }
    }

    private func grantIDs(_ h: ServerHarness) throws -> [String] {
        try h.database.read { try String.fetchAll($0, sql: "SELECT id FROM mcp_grant ORDER BY created_at, id") }
    }

    private func consumed(_ h: ServerHarness, _ id: String) throws -> Bool {
        try h.database.read {
            try String.fetchOne($0, sql: "SELECT consumed_at FROM mcp_grant WHERE id = ?", arguments: [id])
        } != nil
    }

    /// The pair's live membership row (a sync read).
    private func livePair(_ h: ServerHarness, _ book: String, _ note: String) throws -> Bool {
        try h.database.read { db in
            try Bool.fetchOne(db, sql: """
                SELECT EXISTS (SELECT 1 FROM reading_post WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL)
                """, arguments: [book, note]) ?? false
        }
    }

    private func dailyJournal(_ h: ServerHarness) throws -> String? {
        try h.database.read { try Queries.dailyJournalBookID($0) }
    }

    private func lastActivity(_ h: ServerHarness) throws -> MCPActivityRow? {
        try h.database.read { try Queries.mcpActivity($0, limit: 1) }.first
    }

    @Test func aBookMovesWholeWithItsAnswerReceiptAndOneUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let studio = try h.operations.createWing(name: "Studio")
            let atlas = try h.operations.createReading(name: "Atlas", kind: .book)
            let other = try h.operations.createReading(name: "Other", kind: .book)
            let one = try h.operations.createPost(title: "one")
            let two = try h.operations.createPost(title: "two")
            for note in [one, two] { _ = try h.operations.addPostToReading(note.id, to: atlas.id) }
            _ = try h.operations.addPostToReading(one.id, to: other.id)
            try h.operations.archiveContainer(two.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.writeNew, .wing, studio.id))
            let moved = try await call(connection, "move_book_to_wing", [
                "book_id": .string(atlas.id), "wing_id": .string(studio.id),
            ])
            #expect(moved.isError != true)
            #expect(text(moved) == """
                {"archived_notes":1,"beyond_reach":"\(MCPWriteTools.beyondReachWords)","book_id":"\(atlas.id)",\
                "dismissed_arrivals":0,"landed":"unshelved on the Bookcase of \u{201C}Studio\u{201D}",\
                "left_books":[{"book_id":"\(other.id)","name":"Other","note_id":"\(one.id)"}],"left_books_count":1,\
                "moved":true,"notes":2,"same_name_in_wing":[],"wing_id":"\(studio.id)"}
                """)
            #expect(try wingOf(h, "reading", atlas.id) == studio.id)
            #expect(try wingOf(h, "container", one.id) == studio.id && wingOf(h, "container", two.id) == studio.id)
            let receipt = try #require(h.receipts.value.last)
            #expect(receipt.act == .bookWingMove && receipt.targetID == studio.id && receipt.targetTitle == "Studio"
                    && receipt.detail == "Atlas" && receipt.count == 2)
            #expect(try lastActivity(h).map { [$0.act, $0.targetKind, $0.targetTitle] }
                    == ["move_book_to_wing", "book", "Atlas"], "Activity logs the BOOK")
            #expect(h.undoStack.topLabel == "claude-code's book wing move", "ONE client-named undo")
            _ = try h.undoStack.undo(with: h.writeOperations)
            #expect(try wingOf(h, "reading", atlas.id) == "" && wingOf(h, "container", one.id) == "")
            #expect(try livePair(h, other.id, one.id), "the undo brings back the book the note left")
            await h.hangUp(connection)
        }
    }

    @Test func theMoveNeedsEditOnTheBookAndWriteNewOnTheWingSpendingOnceGrantsTogether() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let studio = try h.operations.createWing(name: "Studio")
            let atlas = try h.operations.createReading(name: "Atlas", kind: .book)
            let connection = try await h.connect(as: "claude-code")
            let move: [String: Value] = ["book_id": .string(atlas.id), "wing_id": .string(studio.id)]
            let client = { try h.client("claude-code").id }
            let destination = try #require(try h.approve("claude-code", spec(.writeNew, .wing, studio.id)))
            // The book below edit: its ask, at edit, raised first.
            let low = try h.operations.grantMCPAccess(try client(), spec(.writeNew, .book, atlas.id))
            h.asks.setValue([])
            let refused = try await call(connection, "move_book_to_wing", move)
            #expect(refused.isError == true
                    && text(refused).hasPrefix("This client may only \(MCPRefusalCopy.rungWords(.writeNew)) here."))
            #expect(h.asks.value.map(\.scopeKind) == [.book] && h.asks.value.first?.rung == .edit)
            try h.operations.revokeMCPGrant(low)
            // Edit on the book, the destination short: its ask, at write new.
            _ = try h.operations.grantMCPAccess(try client(), spec(.edit, .book, atlas.id))
            try h.operations.revokeMCPGrant(destination)
            h.asks.setValue([])
            let noWing = try await call(connection, "move_book_to_wing", move)
            #expect(noWing.isError == true && text(noWing) == MCPRefusalCopy.words(.notShared, .wing))
            #expect(h.asks.value.map(\.scopeKind) == [.wing] && h.asks.value.first?.rung == .writeNew)
            #expect(try wingOf(h, "reading", atlas.id) == "", "nothing moved")
            // Once grants of BOTH sides spend together, in the act.
            for id in try grantIDs(h) { try? h.operations.revokeMCPGrant(id) }
            let onceBook = try h.operations.grantMCPAccess(try client(), spec(.edit, .book, atlas.id, .once))
            let onceWing = try h.operations.grantMCPAccess(try client(), spec(.writeNew, .wing, studio.id, .once))
            let landed = try await call(connection, "move_book_to_wing", move)
            #expect(landed.isError != true)
            #expect(try consumed(h, onceBook) && consumed(h, onceWing), "both spent, as one")
            await h.hangUp(connection)
        }
    }

    /// **R-805-5 — THE WIRE KEEPS A JOURNAL REFUSAL, pinned at the TOOL level**
    /// (the merge-order belt with VX-805/VX-435, which makes the daily Journal
    /// movable for HER doors): with the strongest standing reach a client can
    /// hold — an ALWAYS edit grant on Home, write new on the destination — the
    /// daily Journal answers the ONE not-shared shape, byte-identical to a
    /// missing id's, and never moves. Whichever run merges second: this pin
    /// goes red if the wire stops refusing.
    @Test func theDailyJournalRefusesAtTheWireWithTheOneNotSharedShape() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let studio = try h.operations.createWing(name: "Studio")
            let entry = try h.operations.createOrOpenJournalEntry(entryDate: "2026-06-30").container
            _ = h.operations.shelveInDailyJournalBook(entry.id)
            let journal = try #require(try dailyJournal(h))
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.writeNew, .wing, studio.id))
            let missing = try await call(connection, "move_book_to_wing", [
                "book_id": .string("no-such-book"), "wing_id": .string(studio.id),
            ])
            let refused = try await call(connection, "move_book_to_wing", [
                "book_id": .string(journal), "wing_id": .string(studio.id),
            ])
            #expect(refused.isError == true && text(refused) == MCPRefusalCopy.words(.notShared, .book))
            #expect(text(refused) == text(missing), "no oracle: the daily Journal reads as a missing id")
            #expect(try wingOf(h, "reading", journal) == "", "the daily Journal never moved")
            #expect(h.receipts.value.isEmpty && h.undoStack.depth == 0)
            await h.hangUp(connection)
        }
    }

    @Test func aGatheringNeverMovesOnTheWire() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let studio = try h.operations.createWing(name: "Studio")
            let attic = try h.operations.createWing(name: "Attic")
            let tag = try h.operations.createTag(name: "board")
            let board = try h.operations.createReading(
                name: "Board", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            let atticTag = try h.operations.createTag(name: "loft", wingID: attic.id)
            let loft = try h.operations.createReading(
                name: "Loft", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(atticTag.id)), wingId: attic.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.edit, .wing, studio.id))
            let readable = try await call(connection, "move_book_to_wing", [
                "book_id": .string(board.id), "wing_id": .string(studio.id),
            ])
            #expect(readable.isError == true && text(readable) == MCPWriteTools.gatheringMoveWords("Board"))
            let hidden = try await call(connection, "move_book_to_wing", [
                "book_id": .string(loft.id), "wing_id": .string(studio.id),
            ])
            #expect(hidden.isError == true && text(hidden) == MCPRefusalCopy.words(.notShared, .book))
            #expect(try wingOf(h, "reading", board.id) == "" && wingOf(h, "reading", loft.id) == attic.id)
            await h.hangUp(connection)
        }
    }

    @Test func aFrozenStayBehindBookSpeaksHerWordsOnlyWhereReadable() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        h.host.hooks.bookMoveFrozenWords = { book, note, frozen in "HER: \(book) / \(note) / \(frozen)" }
        try await h.within {
            let studio = try h.operations.createWing(name: "Studio")
            let atlas = try h.operations.createReading(name: "Atlas", kind: .book)
            let held = try h.operations.createPost(title: "held")
            _ = try h.operations.addPostToReading(held.id, to: atlas.id)
            let done = try h.operations.createReading(name: "Done", kind: .book)
            _ = try h.operations.addPostToReading(held.id, to: done.id)
            try h.operations.lockReading(done.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, atlas.id))
            let client = try h.client("claude-code").id
            _ = try h.operations.grantMCPAccess(client, spec(.writeNew, .wing, studio.id))
            let move: [String: Value] = ["book_id": .string(atlas.id), "wing_id": .string(studio.id)]
            // Done is beyond reach: the fixed sentence, never "finished".
            let hidden = try await call(connection, "move_book_to_wing", move)
            #expect(hidden.isError == true && text(hidden) == MCPWriteTools.bookMoveHiddenCauseWords)
            // Done readable too: her door's words.
            _ = try h.operations.grantMCPAccess(client, spec(.read, .book, done.id))
            let readable = try await call(connection, "move_book_to_wing", move)
            #expect(readable.isError == true && text(readable) == "HER: Atlas / held / Done")
            #expect(try wingOf(h, "reading", atlas.id) == "")
            await h.hangUp(connection)
        }
    }

    /// A-809-15 (P-809-10) at the wire: a member also in a stay-behind PRIVATE
    /// book would leave the move unfenced, inside a book this client edits —
    /// the one fixed sentence, nothing moved, the note still fenced.
    @Test func aMoveThatWouldShedAFenceRefusesInTheFixedSentence() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let studio = try h.operations.createWing(name: "Studio")
            let atlas = try h.operations.createReading(name: "Atlas", kind: .book)
            let diary = try h.operations.createReading(name: "Diary", kind: .book)
            _ = try h.operations.setBookPrivate(diary.id, true)
            let secret = try h.operations.createPost(title: "secret")
            _ = try h.operations.addPostToReading(secret.id, to: atlas.id)
            _ = try h.operations.addPostToReading(secret.id, to: diary.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, atlas.id))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.writeNew, .wing, studio.id))
            let refused = try await call(connection, "move_book_to_wing", [
                "book_id": .string(atlas.id), "wing_id": .string(studio.id),
            ])
            #expect(refused.isError == true && text(refused) == MCPWriteTools.bookMoveHiddenCauseWords)
            #expect(try wingOf(h, "reading", atlas.id) == "" && wingOf(h, "container", secret.id) == "")
            #expect(h.undoStack.depth == 0)
            await h.hangUp(connection)
        }
    }

    @Test func theAnswerNamesAndCountsOnlyWhatTheClientCanRead() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let studio = try h.operations.createWing(name: "Studio")
            let atlas = try h.operations.createReading(name: "Atlas", kind: .book, intakeSeating: .arrivals)
            let hiddenBook = try h.operations.createReading(name: "Hidden", kind: .book)
            let shown = try h.operations.createPost(title: "shown")
            let privateNote = try h.operations.createPost(title: "private")
            for note in [shown, privateNote] { _ = try h.operations.addPostToReading(note.id, to: atlas.id) }
            _ = try h.operations.setNotePrivate(privateNote.id, true)
            _ = try h.operations.addPostToReading(shown.id, to: hiddenBook.id)
            let tag = try h.operations.createTag(name: "door")
            try h.operations.setReadingQuerySpec(atlas.id, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            let waiting = try h.operations.createPost(title: "waiting")
            _ = try h.operations.applyTag(tag.id, toPost: waiting.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, atlas.id))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.writeNew, .wing, studio.id))
            let raw = try await call(connection, "move_book_to_wing", [
                "book_id": .string(atlas.id), "wing_id": .string(studio.id),
            ])
            let answer = try object(raw)
            #expect(answer["notes"] as? Int == 1, "the Private member came too — never counted")
            #expect((answer["left_books"] as? [Any])?.isEmpty == true && answer["left_books_count"] as? Int == 0,
                    "the book it left is beyond reach — neither named nor counted")
            #expect(answer["dismissed_arrivals"] as? Int == 0, "the waiting note is beyond reach")
            #expect(answer[MCPWriteTools.beyondReachKey] as? String == MCPWriteTools.beyondReachWords)
            #expect(!text(raw).contains(hiddenBook.id) && !text(raw).contains(privateNote.id) && !text(raw).contains(waiting.id))
            #expect(h.receipts.value.last?.count == 2, "her receipt counts every note (hers)")
            await h.hangUp(connection)
        }
    }
}
