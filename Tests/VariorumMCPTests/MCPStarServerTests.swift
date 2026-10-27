import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-596 — `set_starred`, HER STAR ON THE WIRE (her ruling 2026-10-27: "let's
// add the star over the wire, it might as well be included"; the VX-620 run
// record, BATCH 1). Every pin drives a real client over the socket: the EDIT
// rung stars and un-stars a note or a book through her star write — intake
// hearing a note's star exactly as hers, the cap refusing through the ONE
// refusal chain, a no-op answering `changed: false` with nothing to undo — with
// ONE client-named undo per landed act, and every target it cannot reach
// answering the ONE not-shared shape, byte-identical to a missing id. Red on old
// by construction: no such tool (the catalog walk and every call here).

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

@Suite("VX-596 — set_starred: her star on the wire, at the edit rung", .serialized)
struct MCPStarServerTests {
    private func starred(_ h: ServerHarness) throws -> [StarTarget] {
        try h.database.read { try Queries.starred($0).map(\.target) }
    }

    private func pair(_ h: ServerHarness, _ readingID: String, _ postID: String) throws -> String? {
        try h.database.read {
            try String.fetchOne(
                $0,
                sql: "SELECT status FROM reading_post WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL",
                arguments: [readingID, postID])
        }
    }

    private func activity(_ h: ServerHarness) throws -> [Row] {
        try h.database.read {
            try Row.fetchAll($0, sql: "SELECT * FROM mcp_activity WHERE act = 'set_starred' ORDER BY id")
        }
    }

    private func consumedAt(_ h: ServerHarness, _ grant: String) throws -> String? {
        try h.database.read {
            try String.fetchOne($0, sql: "SELECT consumed_at FROM mcp_grant WHERE id = ?", arguments: [grant])
        }
    }

    private func column(_ h: ServerHarness, _ readingID: String) throws -> Int? {
        try h.database.read {
            try Int.fetchOne($0, sql: "SELECT starred FROM reading WHERE id = ?", arguments: [readingID])
        }
    }

    // MARK: - A note: her star, heard by intake, one client-named undo

    @Test func aNoteStarredAtEditIsHeardAsHersWithOneClientNamedUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let joins = try h.operations.createReading(
                name: "starred, seated", kind: .book, querySpec: try RuleGrammar.encode(.star))
            let waits = try h.operations.createReading(
                name: "starred, waiting", kind: .book, querySpec: try RuleGrammar.encode(.star))
            try h.operations.setReadingIntakeSeating(waits.id, .arrivals)
            let note = try h.operations.createPost(title: "a starry note")
            let witness = try h.operations.createPost(title: "hers")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            #expect(try await connection.client.listTools().tools.map(\.name).contains("set_starred"))

            let result = try await call(connection, "set_starred",
                                        ["note_id": .string(note.id), "starred": .bool(true)])
            #expect(result.isError != true, "\(text(result))")
            let answer = try json(result)
            #expect(answer["note_id"] as? String == note.id && answer["starred"] as? Bool == true
                    && answer["changed"] as? Bool == true)
            #expect(Set(answer.keys) == ["note_id", "starred", "changed"])
            #expect(try starred(h) == [.post(note.id)])
            // Intake hears it EXACTLY as her own star (her door, the witness).
            try h.operations.setStarred(.post(witness.id), starred: true)
            for id in [note.id, witness.id] {
                #expect(try pair(h, joins.id, id) == "member", "a living ★ book that joins seats it")
                #expect(try pair(h, waits.id, id) == "arrival", "one whose dial waits bells it")
            }
            // The receipt, the activity line, ONE client-named undo.
            #expect(h.receipts.value.map(\.act) == [.star] && h.receipts.value.first?.targetTitle == "a starry note")
            let rows = try activity(h)
            #expect(rows.count == 1 && rows[0]["target_kind"] as String == "note"
                    && rows[0]["target_id"] as String == note.id && rows[0]["outcome"] as String == "allowed")
            #expect(h.undoStack.depth == 1 && h.undoStack.topLabel == "claude-code's star")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's star")
            #expect(try starred(h) == [.post(witness.id)], "the client's star taken back; hers stays")
            #expect(try pair(h, joins.id, note.id) == "member", "un-starring never evicts (§19)")

            // Un-star: the same tool, the other way.
            let unstar = try await call(connection, "set_starred",
                                        ["note_id": .string(witness.id), "starred": .bool(false)])
            #expect(unstar.isError != true)
            #expect(try json(unstar)["changed"] as? Bool == true)
            #expect(try starred(h).isEmpty && h.undoStack.topLabel == "claude-code's unstar")
            #expect(h.receipts.value.map(\.act) == [.star, .unstar])
            await h.hangUp(connection)
        }
    }

    /// A star already as asked: `changed: false`, nothing written, no undo
    /// entry, no receipt — and the landed Activity line (VX-362's shape).
    @Test func aStarAlreadyAsAskedAnswersChangedFalseWithNothingToUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "n")
            try h.operations.setStarred(.post(note.id), starred: true)
            let other = try h.operations.createPost(title: "other")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            for (id, value) in [(note.id, true), (other.id, false)] {
                let result = try await call(connection, "set_starred",
                                            ["note_id": .string(id), "starred": .bool(value)])
                #expect(result.isError != true)
                let answer = try json(result)
                #expect(answer["changed"] as? Bool == false && answer["starred"] as? Bool == value)
            }
            #expect(try starred(h) == [.post(note.id)])
            #expect(h.undoStack.depth == 0 && h.receipts.value.isEmpty)
            #expect(try activity(h).map { $0["outcome"] as String } == ["allowed", "allowed"])
            await h.hangUp(connection)
        }
    }

    // MARK: - A book: its own grant, the union's two stores

    @Test func aBookStarsUnderItsOwnGrantInBothStores() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "orbit", kind: .book)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, book.id))
            let result = try await call(connection, "set_starred",
                                        ["book_id": .string(book.id), "starred": .bool(true)])
            #expect(result.isError != true, "\(text(result))")
            #expect(Set(try json(result).keys) == ["book_id", "starred", "changed"])
            #expect(try starred(h) == [.reading(book.id)] && (try column(h, book.id)) == 1, "the union's two stores")
            #expect(h.receipts.value.first?.act == .star && h.receipts.value.first?.targetTitle == "orbit")
            #expect(try activity(h).first?["target_kind"] as String? == "book")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's star")
            #expect(try starred(h).isEmpty && (try column(h, book.id)) == 0)
            await h.hangUp(connection)
        }
    }

    // MARK: - The cap, through the one refusal chain

    /// The cap refuses through the wire's ONE chain to HER table
    /// (`MCPWireRefusalCopy.spoken` → the host's `refusalWords` — the Mac's
    /// `OpsRefusalCopy` words it, `MCPWireRefusalSweepTests` walks it); this
    /// harness's hook marks what reached it. Nothing written, no entry.
    @Test func theCapRefusesThroughTheOneChainAndWritesNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            for index in 0..<Operations.starLimit {
                try h.operations.setStarred(.post(try h.operations.createPost(title: "n\(index)").id), starred: true)
            }
            let full = try starred(h)
            let one = try h.operations.createPost(title: "one too many")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let refused = try await call(connection, "set_starred",
                                         ["note_id": .string(one.id), "starred": .bool(true)])
            #expect(refused.isError == true)
            #expect(text(refused) == "Refused: \(OperationError.starLimitReached(limit: Operations.starLimit))",
                    "her table's words, through the one chain: \(text(refused))")
            #expect(try starred(h) == full && h.undoStack.depth == 0 && h.receipts.value.isEmpty)
            #expect(try activity(h).map { $0["outcome"] as String } == ["refused"])
            await h.hangUp(connection)
        }
    }

    // MARK: - What it can't reach: the ONE shape; below edit: the rung and the ask

    @Test func anUnreachedOrFencedTargetAnswersTheOneShapeAndBelowEditTheRungAsks() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "plain")
            let marked = try h.operations.createPost(title: "marked")
            _ = try h.operations.setNotePrivate(marked.id, true)
            let entry = try h.operations.createOrOpenJournalEntry(entryDate: "2026-07-01").container
            guard case .shelved(let dailyID) = h.operations.shelveInDailyJournalBook(entry.id) else {
                Issue.record("the daily door did not file the entry")
                return
            }
            let privateBook = try h.operations.createReading(name: "mine", kind: .book)
            _ = try h.operations.setBookPrivate(privateBook.id, true)
            let elsewhere = try h.operations.createWing(name: "elsewhere")
            let foreign = try h.operations.createPost(title: "foreign", wingId: elsewhere.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let starsBefore = try starred(h)

            let missingNote = try await call(connection, "set_starred",
                                             ["note_id": .string("no-such-note"), "starred": .bool(true)])
            #expect(missingNote.isError == true && text(missingNote) == MCPRefusalCopy.words(.notShared, .note))
            for id in [marked.id, entry.id, foreign.id] {
                let refused = try await call(connection, "set_starred", ["note_id": .string(id), "starred": .bool(true)])
                #expect(refused.isError == true && text(refused) == text(missingNote),
                        "\(id): the fence and the unreached answer as a missing id")
            }
            let missingBook = try await call(connection, "set_starred",
                                             ["book_id": .string("no-such-book"), "starred": .bool(true)])
            #expect(text(missingBook) == MCPRefusalCopy.words(.notShared, .book))
            for id in [dailyID, privateBook.id] {
                let refused = try await call(connection, "set_starred", ["book_id": .string(id), "starred": .bool(true)])
                #expect(refused.isError == true && text(refused) == text(missingBook), "\(id): a fenced book")
            }
            #expect(try starred(h) == starsBefore, "nothing written")

            // Below EDIT: the rung's sentence and her ask, on a note it reaches.
            let reader = try await h.connect(as: "codex")
            _ = try h.approve("codex", spec(.writeNew, .note, note.id))
            h.asks.setValue([])
            let past = try await call(reader, "set_starred", ["note_id": .string(note.id), "starred": .bool(true)])
            #expect(past.isError == true
                    && text(past) == MCPRefusalCopy.words(.rungTooLow(granted: .writeNew), .note, asked: true))
            #expect(h.asks.value.map(\.rung) == [.edit] && h.asks.value.first?.scopeID == note.id)
            #expect(!(try await reader.client.listTools().tools.map(\.name).contains("set_starred")),
                    "listed only for an edit grant (P-2 on the wire)")
            await h.hangUp(connection)
            await h.hangUp(reader)
        }
    }

    /// A GATHERING's own star is the author's: an id this client can read hears
    /// the gathering sentence (P-VX196-2's posture, the author's acts naming
    /// starring now — PROVISIONAL); a gathering it can't read, the one shape.
    @Test func aGatheringsOwnStarIsTheAuthors() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let percy = try h.operations.createTag(name: "percy")
            let gathering = try h.operations.createReading(
                name: "gathered", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(percy.id)))
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let refused = try await call(connection, "set_starred",
                                         ["book_id": .string(gathering.id), "starred": .bool(true)])
            #expect(refused.isError == true && text(refused) == MCPWriteTools.gatheringWords("gathered"))
            #expect(text(refused).contains("starring"))
            #expect(try starred(h).isEmpty && (try column(h, gathering.id)) == 0)
            await h.hangUp(connection)
        }
    }

    // MARK: - The arguments; a once grant

    @Test func theArgumentsAreSaidNeverGuessedAndAOnceGrantIsOneAct() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "n")
            let connection = try await h.connect(as: "claude-code")
            let once = try #require(try h.approve("claude-code", spec(.edit, .note, note.id, .once)))
            for (arguments, words) in [
                (["note_id": Value.string(note.id)], "starred is required: true stars it, false un-stars it."),
                (["note_id": .string(note.id), "starred": .string("yes")], "starred must be true or false."),
                (["starred": .bool(true)], "Pass note_id (a note) or book_id (a book)."),
                (["note_id": .string(note.id), "book_id": .string("b"), "starred": .bool(true)],
                 "Pass note_id or book_id, not both."),
            ] {
                let refused = try await call(connection, "set_starred", arguments)
                #expect(refused.isError == true && text(refused) == words)
            }
            #expect(try consumedAt(h, once) == nil, "a malformed call spends nothing")
            let landed = try await call(connection, "set_starred", ["note_id": .string(note.id), "starred": .bool(true)])
            #expect(landed.isError != true, "\(text(landed))")
            #expect(try consumedAt(h, once) != nil, "the once grant is one act — spent inside the act's transaction")
            let again = try await call(connection, "set_starred", ["note_id": .string(note.id), "starred": .bool(false)])
            #expect(again.isError == true && text(again) == MCPRefusalCopy.words(.notShared, .note),
                    "spent: nothing reaches it now")
            await h.hangUp(connection)
        }
    }
}
