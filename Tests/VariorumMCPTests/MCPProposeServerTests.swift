import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-811 — `propose_notes_to_book` ON THE WIRE (the VX-808 run, Unit B2; her
// VX-811 rulings 2/3/6, the fork's ruling A-808-8). Every pin drives a real
// client over the socket: a set of notes proposed to a book — each item its
// own act at READ reach on the note and the book (the one not-shared shape,
// the fence keeping a Private book and THE daily Journal unreachable), its own
// arrival row stamped `proposed` with its own reason, its own ⌥⌘Z entry, its
// own Activity line; receipts on one run key; a once grant covers one item and
// is spent WHATEVER its rung (P-808-B2-2); the call door refuses a malformed
// call before any decision; the tool is listed by a book or wing grant (or the
// open book) and never says it is read-only. Who sees what is the two-store
// catalog's (`MCPTwoStoreCatalogServerTests`).

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

private func call(
    _ connection: HarnessConnection, _ arguments: [String: Value]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: "propose_notes_to_book", arguments: arguments)
}

private func ids(_ values: String...) -> Value { .array(values.map { .string($0) }) }

@Suite("VX-811 — propose_notes_to_book: a set of notes waits at a book's door", .serialized)
struct MCPProposeServerTests {
    private func rows(_ h: ServerHarness, book: String) throws -> [ReadingPost] {
        try h.database.read {
            try ReadingPost.fetchAll(
                $0, sql: "SELECT * FROM reading_post WHERE reading_id = ? ORDER BY created_at, id", arguments: [book])
        }
    }

    private func arrival(_ h: ServerHarness, _ note: String, _ book: String) throws -> ReadingPost? {
        try rows(h, book: book).first { $0.postId == note && $0.deletedAt == nil && $0.status == .arrival }
    }

    private func activity(_ h: ServerHarness) throws -> [Row] {
        try h.database.read {
            try Row.fetchAll($0, sql: "SELECT * FROM mcp_activity WHERE act = 'propose_notes_to_book' ORDER BY id")
        }
    }

    private func consumedAt(_ h: ServerHarness, _ grant: String) throws -> String? {
        try h.database.read {
            try String.fetchOne($0, sql: "SELECT consumed_at FROM mcp_grant WHERE id = ?", arguments: [grant])
        }
    }

    private func journalID(_ h: ServerHarness) throws -> String? {
        try h.database.read { try Queries.dailyJournalBookID($0) }
    }

    private func note(_ h: ServerHarness, _ title: String) throws -> Container {
        let post = try h.operations.createPost(title: title)
        _ = try h.operations.newBlock(in: post.id, text: "\(title) words.", registeringUndo: false)
        return post
    }

    /// A set: two readable notes land (each its own arrival, its own reason —
    /// `reasons` over `reason`), a member refuses in her doors' words, a hidden
    /// note answers the one not-shared shape; one entry and one receipt per
    /// landed item on ONE run key; landed items logged on the BOOK.
    @Test func aSetLandsItemByItemEachArrivalStampedWithItsReason() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "Lisbon", kind: .book)
            let member = try note(h, "member")
            _ = try h.operations.addPostToReading(member.id, to: book.id)
            let tram = try note(h, "tram"), fado = try note(h, "fado"), hidden = try note(h, "hidden")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .book, book.id))
            let client = try h.client("claude-code").id
            for one in [tram, fado] { _ = try h.operations.grantMCPAccess(client, spec(.read, .note, one.id)) }
            let notShared = try await connection.client.callTool(name: "read_note", arguments: ["note_id": .string(hidden.id)])

            let result = try await call(connection, [
                "note_ids": ids(tram.id, member.id, hidden.id, fado.id), "book_id": .string(book.id),
                "reason": .string("Both are about Lisbon."),
                "reasons": .object([fado.id: .string("  The fado night, for the music chapter.  ")]),
            ])
            #expect(result.isError != true, "\(text(result))")
            let answer = try json(result)
            #expect(answer["landed_count"] as? Int == 2 && answer["refused_count"] as? Int == 2)
            #expect(answer["waits"] as? String == MCPWriteTools.waitsWords, "the one fixed sentence, always")
            let results = try #require(answer["results"] as? [[String: Any]])
            #expect(results.map { $0["note_id"] as? String } == [tram.id, member.id, hidden.id, fado.id])
            #expect(Set(results[0].keys) == ["note_id", "book_id", "changed"] && results[0]["changed"] as? Bool == true)
            #expect(results[1]["refused"] as? String == "Refused: \(OperationError.alreadyInReading(postID: member.id, readingID: book.id))",
                    "a member: her doors' words (the app's table at the door; the harness's stand-in here)")
            #expect(results[2]["refused"] as? String == text(notShared), "a hidden note: the one not-shared shape")
            #expect(results[2]["refused"] as? String == MCPRefusalCopy.words(.notShared, .note))
            let tramRow = try #require(try arrival(h, tram.id, book.id))
            let fadoRow = try #require(try arrival(h, fado.id, book.id))
            #expect(tramRow.provenance == .proposed(client: "claude-code", reason: "Both are about Lisbon."))
            #expect(fadoRow.provenance?.reason == "The fado night, for the music chapter.", "its own reason, trimmed")
            #expect(try arrival(h, hidden.id, book.id) == nil && h.undoStack.depth == 2)
            #expect(h.undoStack.topLabel == "claude-code's proposal")
            let receipts = h.receipts.value
            #expect(receipts.map(\.act) == [.proposal, .proposal])
            #expect(receipts.allSatisfy { $0.targetID == book.id && $0.targetTitle == "Lisbon" })
            #expect(receipts.map(\.detail) == ["tram", "fado"])
            #expect(receipts[0].runKey != nil && receipts[0].runKey == receipts[1].runKey, "one line at the app")
            let lines = try activity(h)
            #expect(lines.map { $0["outcome"] as String } == ["allowed", "refused", "refused", "allowed"])
            #expect(lines.map { $0["target_kind"] as String } == ["book", "book", "note", "book"],
                    "an item past both decisions is logged on the BOOK (landed, or refused by the op); a decision's refusal on its side")
            // ⌥⌘Z walks the items, newest first.
            _ = try h.undoStack.undo(with: h.writeOperations)
            #expect(try arrival(h, fado.id, book.id) == nil && arrival(h, tram.id, book.id) != nil)
            await h.hangUp(connection)
        }
    }

    /// Already waiting: `changed: false` — no entry, no receipt; a finished
    /// book, a note taken out of the book and a note of another wing refuse;
    /// a call landing nothing is an error answer (still carrying `waits`).
    @Test func theVerdictRowsOnTheWire() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "Lisbon", kind: .book)
            let waiting = try note(h, "waiting"), gone = try note(h, "gone")
            _ = try h.operations.addPostToReading(gone.id, to: book.id)
            _ = try h.operations.removePostFromReading(gone.id, from: book.id)
            let studio = try h.operations.createWing(name: "Studio")
            let elsewhere = try h.operations.createPost(title: "elsewhere", wingId: studio.id)
            let done = try h.operations.createReading(name: "Done", kind: .book)
            try h.operations.lockReading(done.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .wing, ""))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.read, .wing, studio.id))
            _ = try await call(connection, ["note_ids": ids(waiting.id), "book_id": .string(book.id)])
            let depth = h.undoStack.depth, sent = h.receipts.value.count
            let again = try await call(connection, ["note_ids": ids(waiting.id, gone.id, elsewhere.id),
                                                    "book_id": .string(book.id)])
            let results = try #require(try json(again)["results"] as? [[String: Any]])
            #expect(results[0]["changed"] as? Bool == false, "already waiting: done")
            #expect(results[1]["refused"] as? String == MCPWriteTools.proposalLeftTheBookWords)
            #expect(results[2]["refused"] as? String
                    == "Refused: \(OperationError.crossWingMembership(postID: elsewhere.id, readingID: book.id))")
            #expect(h.undoStack.depth == depth && h.receipts.value.count == sent, "a no-op claims nothing")
            let finished = try await call(connection, ["note_ids": ids(waiting.id), "book_id": .string(done.id)])
            #expect(finished.isError == true, "nothing landed: an error answer")
            #expect(try json(finished)["waits"] as? String == MCPWriteTools.waitsWords)
            let refused = try #require(try json(finished)["results"] as? [[String: Any]])
            #expect(refused[0]["refused"] as? String == "Refused: \(OperationError.lockedReading(id: done.id))")
            await h.hangUp(connection)
        }
    }

    /// The fence: a Private book and THE daily Journal are unreachable at read
    /// (even under the open book) — each answers the one not-shared shape, byte
    /// for byte an id naming nothing; a readable GATHERING hears why.
    @Test func aFencedBookIsTheOneShapeAndAGatheringSaysWhy() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let candidate = try note(h, "candidate")
            let secret = try h.operations.createReading(name: "Secret", kind: .book)
            _ = try h.operations.setBookPrivate(secret.id, true)
            let entry = try h.operations.createOrOpenJournalEntry(entryDate: "2026-06-30").container
            _ = h.operations.shelveInDailyJournalBook(entry.id)
            let journal = try #require(try journalID(h))
            let tag = try h.operations.createTag(name: "idea")
            let gathering = try h.operations.createReading(
                name: "Ideas", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .wing, ""))
            try h.operations.setMCPSwitch(.openBook, on: true)
            let missing = try await call(connection, ["note_ids": ids(candidate.id), "book_id": .string("no-such-book")])
            for book in [secret.id, journal] {
                let fenced = try await call(connection, ["note_ids": ids(candidate.id), "book_id": .string(book)])
                #expect(text(fenced) == text(missing), "\(book): the one shape, byte for byte")
            }
            let missingResults = try #require(try json(missing)["results"] as? [[String: Any]])
            #expect(missingResults[0]["refused"] as? String == MCPRefusalCopy.words(.notShared, .book))
            let gathered = try await call(connection, ["note_ids": ids(candidate.id), "book_id": .string(gathering.id)])
            let said = try #require(try json(gathered)["results"] as? [[String: Any]])
            #expect(said[0]["refused"] as? String == MCPWriteTools.proposalGatheringWords("Ideas"))
            #expect(try rows(h, book: secret.id).isEmpty && rows(h, book: journal).count == 1, "nothing written")
            await h.hangUp(connection)
        }
    }

    /// **A once grant covers ONE item — and is spent WHATEVER its rung**
    /// (P-808-B2-2, AF-7's letter): a once WRITE-NEW book grant authorizes one
    /// proposal; the pure rule alone would leave it unspent at read.
    @Test func aOnceGrantAboveReadIsSpentByTheOneItemItAuthorized() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "Lisbon", kind: .book)
            let one = try note(h, "one"), two = try note(h, "two")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, one.id))
            let client = try h.client("claude-code").id
            _ = try h.operations.grantMCPAccess(client, spec(.read, .note, two.id))
            let grant = try h.operations.grantMCPAccess(client, spec(.writeNew, .book, book.id, .once))
            let result = try await call(connection, ["note_ids": ids(one.id, two.id), "book_id": .string(book.id)])
            let results = try #require(try json(result)["results"] as? [[String: Any]])
            #expect(results[0]["changed"] as? Bool == true, "the first item lands under the once grant")
            #expect(results[1]["refused"] != nil, "the next finds it spent: \(text(result))")
            #expect(try consumedAt(h, grant) != nil, "spent inside the first item's transaction")
            #expect(try arrival(h, one.id, book.id) != nil && arrival(h, two.id, book.id) == nil)
            await h.hangUp(connection)
        }
    }

    /// The call door: a malformed call refuses in words before any decision —
    /// nothing read, written, asked, spent or logged.
    @Test func aMalformedCallRefusesBeforeAnyDecision() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "Lisbon", kind: .book)
            let one = try note(h, "one")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .wing, ""))
            let long = String(repeating: "x", count: ArrivalProvenance.reasonCap + 1)
            let cases: [([String: Value], String)] = [
                (["book_id": .string(book.id)], "note_ids is required: 1 to 200 notes."),
                (["note_ids": .array([]), "book_id": .string(book.id)], "note_ids lists no note."),
                (["note_ids": ids(one.id, one.id), "book_id": .string(book.id)], "note_ids lists a note twice."),
                (["note_ids": ids(one.id)], "book_id is required."),
                (["note_ids": ids(one.id), "book_id": .string(book.id), "reasons": .string("x")],
                 "reasons must be an object: a note_id to its reason."),
                (["note_ids": ids(one.id), "book_id": .string(book.id), "reasons": .object(["other": .string("x")])],
                 "reasons names other, which note_ids doesn't list."),
                (["note_ids": ids(one.id), "book_id": .string(book.id), "reason": .string(" \(long) ")],
                 MCPWriteTools.reasonCapWords("reason", count: long.count)),
                (["note_ids": ids(one.id), "book_id": .string(book.id), "reasons": .object([one.id: .string(long)])],
                 MCPWriteTools.reasonCapWords("reasons[\(one.id)]", count: long.count)),
            ]
            for (arguments, words) in cases {
                let refused = try await call(connection, arguments)
                #expect(refused.isError == true && text(refused) == words, "\(arguments): \(text(refused))")
            }
            let single = try await call(connection, ["note_id": .string(one.id), "book_id": .string(book.id)])
            #expect(single.isError == true && text(single).hasPrefix("note_id isn't an argument of propose_notes_to_book"))
            #expect(try activity(h).isEmpty && rows(h, book: book.id).isEmpty && h.asks.value.isEmpty)
            await h.hangUp(connection)
        }
    }

    /// A reason's U+0000 is never stored and the item says how many it removed.
    @Test func aReasonsNullCharactersAreRemovedAndSaid() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "Lisbon", kind: .book)
            let one = try note(h, "one")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .wing, ""))
            let result = try await call(connection, ["note_ids": ids(one.id), "book_id": .string(book.id),
                                                     "reason": .string("a\u{0}b\u{0}")])
            let results = try #require(try json(result)["results"] as? [[String: Any]])
            #expect(results[0][MCPNullCharacters.answerKey] as? Int == 2)
            #expect(try arrival(h, one.id, book.id)?.provenance?.reason == "ab")
            await h.hangUp(connection)
        }
    }

    /// Listed by a book or a wing grant, or the open book — never by a note or
    /// a gathering grant alone (it could never reach a book: P-2); its hints
    /// never say read-only; `list_my_activity` lists its rows as acts.
    @Test func itIsListedWhereItCanActAndNeverSaysItIsReadOnly() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "Lisbon", kind: .book)
            let one = try note(h, "one")
            let tag = try h.operations.createTag(name: "idea")
            let gathering = try h.operations.createReading(
                name: "Ideas", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            let connection = try await h.connect(as: "claude-code")
            let noteGrant = try #require(try h.approve("claude-code", spec(.read, .note, one.id)))
            let client = try h.client("claude-code").id
            let gatheringGrant = try h.operations.grantMCPAccess(client, spec(.read, .gathering, gathering.id))
            func listed() async throws -> Tool? {
                try await connection.client.listTools().tools.first { $0.name == "propose_notes_to_book" }
            }
            #expect(try await listed() == nil, "a note or a gathering grant can never reach a book")
            let bookGrant = try h.operations.grantMCPAccess(client, spec(.read, .book, book.id))
            let tool = try #require(try await listed())
            #expect(tool.annotations.readOnlyHint == false && tool.annotations.idempotentHint == false)
            _ = (noteGrant, gatheringGrant, bookGrant)
            _ = try await call(connection, ["note_ids": ids(one.id), "book_id": .string(book.id)])
            let own = try await connection.client.callTool(name: "list_my_activity", arguments: [:])
            let entries = try #require(try json(own)["acts"] as? [[String: Any]])
            #expect(entries.contains { $0["tool"] as? String == "propose_notes_to_book" },
                    "an act, listed without include_reads: \(text(own))")
            await h.hangUp(connection)
        }
    }

    // MARK: - VX-811 ruling 4 — set_book_rule names how many matches now wait

    /// A rule written on the wire bells its matches; the answer counts the ones
    /// this client can READ (`waiting_count`), beside the fixed sentence — a
    /// note it can't read is rung all the same and never counted. A write that
    /// lands no rule (an outflow alone) and a rule on a finished book (intake
    /// paused) carry neither key.
    @Test func setBookRuleCountsTheBelledMatchesTheClientCanRead() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "Lisbon", kind: .book)
            let done = try h.operations.createReading(name: "Done", kind: .book)
            try h.operations.lockReading(done.id)
            let tag = try h.operations.createTag(name: "lisbon")
            let shared = try note(h, "shared"), unshared = try note(h, "unshared"), alsoUnshared = try note(h, "also")
            for one in [shared, unshared, alsoUnshared] { _ = try h.operations.applyTag(tag.id, toPost: one.id) }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, book.id))
            let client = try h.client("claude-code").id
            _ = try h.operations.grantMCPAccess(client, spec(.read, .note, shared.id))
            _ = try h.operations.grantMCPAccess(client, spec(.writeNew, .book, done.id))
            let ruled = try await connection.client.callTool(
                name: "set_book_rule", arguments: ["book_id": .string(book.id), "rule": .object(["tag": .string("lisbon")])])
            let answer = try json(ruled)
            #expect(answer[MCPBookFacts.waitingCountKey] as? Int == 1, "\(text(ruled))")
            #expect(answer[MCPWriteTools.beyondReachKey] as? String == MCPWriteTools.beyondReachNotesWords)
            #expect(try [shared, unshared, alsoUnshared].allSatisfy { try arrival(h, $0.id, book.id) != nil },
                    "every match rings — the count is only what the client is told")
            let outflow = try await connection.client.callTool(
                name: "set_book_rule", arguments: ["book_id": .string(book.id), "outflow": .array([.string("lisbon")])])
            #expect(try json(outflow)[MCPBookFacts.waitingCountKey] == nil && json(outflow)[MCPWriteTools.beyondReachKey] == nil)
            let paused = try await connection.client.callTool(
                name: "set_book_rule", arguments: ["book_id": .string(done.id), "rule": .object(["tag": .string("lisbon")])])
            #expect(try json(paused)["intake_paused"] != nil && json(paused)[MCPBookFacts.waitingCountKey] == nil)
            await h.hangUp(connection)
        }
    }
}
