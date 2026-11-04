import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-769 (the VX-771 run, batch 3 — her ruling R-771-B; the tool shape the
// orchestrator's call, PROVISIONAL P-771-2; the record
// `notes/plans/fixes/vx-771-mcp-agent-ergonomics.md`, BATCH 3 RECORD). The wire
// MINTS A GATHERING: `create_gathering` — `name`, `wing_id`, `rule`, the rule
// REQUIRED at birth (R-13ic-4) in `set_book_rule`'s wire grammar (one parser),
// at WRITE NEW on the wing (`create_book`'s decision and ask). Her mint door's
// row exactly (the one body, `insertReading`); no applying act — nothing seats,
// nothing bells; ONE client-named undo in a gathering's words; the answer the
// gathering's id, name, wing, its rule as stored and `list_books`' own count. A
// mint grants nothing: `decideGathering` answers the minted row as hers, and the
// rule stays hers after birth (`set_book_rule` speaks the gathering sentence).
//
// Wire only (the SDK's own client over a real socket). RED ON OLD: every call
// refused — no such tool.

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

@Suite("VX-769 — create_gathering mints a gathering with its rule", .serialized)
struct MCPCreateGatheringServerTests {
    private func readingRow(_ h: ServerHarness, _ id: String) async throws -> [String: String] {
        try await h.database.read { db in
            let row = try #require(try Row.fetchOne(db, sql: "SELECT * FROM reading WHERE id = ?", arguments: [id]))
            var columns: [String: String] = [:]
            for column in row.columnNames { columns[column] = String(describing: row[column] as DatabaseValue) }
            return columns
        }
    }

    private func memberships(_ h: ServerHarness) async throws -> [String] {
        try await h.database.read { db in
            try Row.fetchAll(db, sql: "SELECT * FROM reading_post ORDER BY id").map(\.description)
        }
    }

    private func readingCount(_ h: ServerHarness) async throws -> Int {
        try await h.database.read { db in try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM reading") ?? 0 }
    }

    // MARK: - The mint (RED ON OLD: no such tool)

    /// The answer, the row (her mint door's, column for column), the tags its
    /// rule names (adopted, or minted in the wing), the receipt, ONE
    /// client-named undo that takes it back and a redo that returns it.
    @Test func theMintLandsHerRowAndAnswersItsIDsRuleAndCount() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let board = try h.operations.createTag(name: "board")
            let card = try h.operations.createPost(title: "card")
            _ = try h.operations.newBlock(in: card.id, text: "Ship it.", registeringUndo: false)
            _ = try h.operations.applyTag(board.id, toPost: card.id)
            let loose = try h.operations.createPost(title: "loose")
            _ = try h.operations.newBlock(in: loose.id, text: "Not on the board.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))

            let minted = try await call(connection, "create_gathering", [
                "name": .string("Board"), "wing_id": .string(""),
                "rule": .object(["or": .array([.object(["tag": .string("board")]),
                                               .object(["tag": .string("#board/todo")])])]),
            ])
            #expect(minted.isError != true, "\(text(minted))")
            let answer = try json(minted)
            #expect(Set(answer.keys) == ["gathering_id", "name", "wing_id", "rule", "notes", "minted_tags"],
                    "the answer's keys: \(answer)")
            let id = try #require(answer["gathering_id"] as? String)
            #expect(answer["name"] as? String == "Board" && answer["wing_id"] as? String == "")
            let echoed = try #require(answer["rule"] as? [String: Any])
            #expect(((echoed["or"] as? [[String: Any]]) ?? []).map { $0["tag"] as? String } == ["board", "board/todo"],
                    "the rule as stored, each tag by its path: \(echoed)")
            #expect(answer["minted_tags"] as? Int == 1, "board/todo was minted in the wing")
            #expect(answer["notes"] as? Int == 1, "it gathers the one card")

            // The count is list_books' own.
            let listed = try json(try await call(connection, "list_books", [:]))
            let entry = try #require((listed["books"] as? [[String: Any]])?.first { $0["id"] as? String == id })
            #expect(entry["kind"] as? String == "gathering" && entry["notes"] as? Int == answer["notes"] as? Int)

            // The row is HER mint door's row, column for column.
            let todo = try #require(try await h.database.read { db in
                try String.fetchOne(db, sql: "SELECT id FROM tag WHERE path = 'board/todo' AND deleted_at IS NULL")
            })
            let spec = try RuleGrammar.encode(.or([.tag(board.id), .tag(todo)]))
            let hers = try h.operations.createReading(name: "Hers", kind: .gathering, querySpec: spec, wingId: "")
            let typed = try #require(try await h.database.read { try Reading.fetchOne($0, key: id) })
            #expect(typed.querySpec == spec, "the rule stored by tag id: \(String(describing: typed.querySpec))")
            #expect(typed.kind == .gathering && typed.shelfId == nil && typed.archivedAt == nil && !typed.locked
                    && !typed.starred && !typed.owned && typed.deletedAt == nil && typed.wingId == "")
            var wire = try await readingRow(h, id)
            var herRow = try await readingRow(h, hers.id)
            for column in ["id", "name", "created_at", "updated_at"] {
                wire[column] = nil
                herRow[column] = nil
            }
            #expect(wire == herRow, "the wire's gathering is her mint's row")

            // The receipt; ONE client-named undo; the redo.
            #expect(h.receipts.value.last?.act.rawValue == "gathering"
                    && h.receipts.value.last?.targetTitle == "Board")
            #expect(h.undoStack.depth == 1 && h.undoStack.topLabel == "claude-code's gathering")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's gathering")
            #expect(try await readingRow(h, id)["deleted_at"] != "NULL", "the undo takes it back")
            #expect(try await h.database.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM tag WHERE id = ? AND deleted_at IS NULL", arguments: [todo])
            } == 1, "a minted tag stays as vocabulary")
            #expect(try h.undoStack.redo(with: h.writeOperations) == "claude-code's gathering")
            #expect(try await readingRow(h, id)["deleted_at"] == "NULL", "the redo returns it")
            await h.hangUp(connection)
        }
    }

    // MARK: - No applying act (RED ON OLD: no such tool)

    /// A gathering assembles at read: its birth seats nothing and bells
    /// nothing ANYWHERE — every membership row is byte-identical — while it
    /// gathers what its rule matches; and the mint grants nothing.
    @Test func theMintIsNoApplyingActAndGrantsNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let board = try h.operations.createTag(name: "board")
            let living = try h.operations.createReading(
                name: "board book", kind: .book, querySpec: try RuleGrammar.encode(.tag(board.id)))
            let waiting = try h.operations.createReading(
                name: "waiting book", kind: .book, querySpec: try RuleGrammar.encode(.tag(board.id)))
            try h.operations.setReadingIntakeSeating(waiting.id, .arrivals)
            var cards: [String] = []
            for title in ["a", "b"] {
                let card = try h.operations.createPost(title: title)
                _ = try h.operations.newBlock(in: card.id, text: title, registeringUndo: false)
                _ = try h.operations.applyTag(board.id, toPost: card.id)
                cards.append(card.id)
            }
            _ = living
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            let before = try await memberships(h)
            let grants = try await h.database.read { db in try Row.fetchAll(db, sql: "SELECT * FROM mcp_grant").map(\.description) }

            let minted = try json(try await call(connection, "create_gathering", [
                "name": .string("Board"), "wing_id": .string(""), "rule": .object(["tag": .string("board")]),
            ]))
            #expect(minted["notes"] as? Int == 2)
            #expect(try await memberships(h) == before, "nothing seats, nothing bells, anywhere")
            #expect(try await h.database.read { db in try Row.fetchAll(db, sql: "SELECT * FROM mcp_grant").map(\.description) }
                    == grants, "a mint grants nothing")
            let id = try #require(minted["gathering_id"] as? String)
            let gathered = try json(try await call(connection, "list_notes", ["book_id": .string(id)]))
            #expect(Set(((gathered["notes"] as? [[String: Any]]) ?? []).compactMap { $0["id"] as? String }) == Set(cards),
                    "it gathers what its rule matches: \(gathered)")
            await h.hangUp(connection)
        }
    }

    // MARK: - The rule is required, in set_book_rule's words (RED ON OLD: no such tool)

    /// No rule, a null rule, and every malformed or empty rule refuse in
    /// words — the malformed ones in `set_book_rule`'s own words for the same
    /// rule (one parser) — minting nothing, asking nothing, registering nothing.
    @Test func aMissingMalformedOrEmptyRuleRefusesInWordsAndMintsNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            let count = try await readingCount(h)

            let absentOrNull: [Value?] = [.none, .some(.null)]
            for missing in absentOrNull {
                var arguments: [String: Value] = ["name": .string("Board"), "wing_id": .string("")]
                if let missing { arguments["rule"] = missing }
                let refused = try await call(connection, "create_gathering", arguments)
                #expect(refused.isError == true && text(refused) == Self.ruleRequiredWords, "\(text(refused))")
            }
            let malformed: [Value] = [
                .object([:]), .object(["and": .array([])]), .object(["tag": .string(" ")]),
                .object(["star": .bool(false)]), .object(["profile": .string("journal")]),
                .object(["colour": .string("blue")]), .string("board"),
                // A path with no segment parses, then the op's resolution
                // refuses it — the one resolution, the one chain's words.
                .object(["or": .array([.object(["star": .bool(true)]), .object(["tag": .string("/")])])]),
            ]
            for rule in malformed {
                let refused = try await call(connection, "create_gathering", [
                    "name": .string("Board"), "wing_id": .string(""), "rule": rule,
                ])
                let theirs = try await call(connection, "set_book_rule", ["book_id": .string(book.id), "rule": rule])
                #expect(refused.isError == true && theirs.isError == true && text(refused) == text(theirs),
                        "one parser, one sentence: \(text(refused)) / \(text(theirs))")
            }
            #expect(try await readingCount(h) == count, "nothing minted")
            #expect(h.asks.value.isEmpty && h.undoStack.depth == 0 && h.receipts.value.isEmpty)
            #expect(text(try await call(connection, "create_gathering", ["wing_id": .string(""), "rule": .object(["star": .bool(true)])]))
                    == "name is required.")
            #expect(text(try await call(connection, "create_gathering", ["name": .string("B"), "rule": .object(["star": .bool(true)])]))
                    == "wing_id is required (\"\" is Home).")
            await h.hangUp(connection)
        }
    }

    /// The sentence as a literal, so the pin compiles — and runs red — on the old tree.
    static let ruleRequiredWords =
        "rule is required: a gathering is made with its rule, written as set_book_rule writes one — "
        + "e.g. {\"tag\": \"board\"} or {\"or\": [{\"tag\": \"board\"}, {\"star\": true}]}."

    // MARK: - create_book's decision and ask (RED ON OLD: no such tool)

    /// WRITE NEW on the wing, exactly as `create_book`: a read-only wing grant
    /// hears the rung and raises the wing's ask; a book-level write new is no
    /// wing reach (the tool is not even listed) and hears what `create_book`
    /// hears; an unshared wing answers create_book's one shape. Never minted.
    @Test func writeNewOnTheWingIsCreateBooksDecisionAndAsk() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let away = try h.operations.createWing(name: "away")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, book.id))
            let count = try await readingCount(h)
            #expect(!(try await connection.client.listTools().tools.map(\.name)).contains("create_gathering"),
                    "listed only where create_book is: a wing at write new")
            #expect(!(try await connection.client.listTools().tools.map(\.name)).contains("create_book"))

            func pair(_ wing: String) async throws -> (String, String) {
                let gathering = try await call(connection, "create_gathering", [
                    "name": .string("Board"), "wing_id": .string(wing), "rule": .object(["star": .bool(true)]),
                ])
                let book = try await call(connection, "create_book", ["name": .string("Board"), "wing_id": .string(wing)])
                #expect(gathering.isError == true && book.isError == true)
                return (text(gathering), text(book))
            }
            let (homeG, homeB) = try await pair("")
            #expect(homeG == homeB, "create_book's refusal: \(homeG)")
            #expect(h.asks.value.last?.scopeKind == .wing && h.asks.value.last?.rung == .writeNew)
            let (awayG, awayB) = try await pair(away.id)
            #expect(awayG == awayB)
            let (nowhereG, nowhereB) = try await pair("no-such-wing")
            #expect(nowhereG == nowhereB)

            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.read, .wing, ""))
            let (tooLowG, tooLowB) = try await pair("")
            #expect(tooLowG == tooLowB && tooLowG.hasPrefix("This client may only read"), "\(tooLowG)")
            #expect(try await readingCount(h) == count + 0, "nothing minted")
            await h.hangUp(connection)
        }
    }

    // MARK: - The rule stays hers; reach is hers (RED ON OLD: no such tool)

    /// `set_book_rule` on the minted gathering answers the gathering sentence,
    /// byte-unchanged, and changes nothing; `decideGathering` decides the wire's
    /// gathering exactly as her own of the same rule under every standing.
    @Test func theRuleStaysHersAndDecideGatheringAnswersTheMintAsHers() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let away = try h.operations.createWing(name: "away")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, away.id))
            let minted = try json(try await call(connection, "create_gathering", [
                "name": .string("Board"), "wing_id": .string(away.id), "rule": .object(["tag": .string("board")]),
            ]))
            let id = try #require(minted["gathering_id"] as? String)
            #expect(minted["wing_id"] as? String == away.id && minted["minted_tags"] as? Int == 1)
            let stored = try await readingRow(h, id)["query_spec"]

            let edited = try await call(connection, "set_book_rule", [
                "book_id": .string(id), "rule": .object(["star": .bool(true)]),
            ])
            #expect(edited.isError == true && text(edited) == MCPWriteTools.gatheringWords("Board"), "\(text(edited))")
            #expect(try await readingRow(h, id)["query_spec"] == stored, "the rule stands")

            let tag = try #require(try await h.database.read { db in
                try String.fetchOne(db, sql: "SELECT id FROM tag WHERE path = 'board' AND wing_id = ?", arguments: [away.id])
            })
            let hers = try h.operations.createReading(
                name: "Hers", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag)), wingId: away.id)
            let (wire, herFacts) = try await h.database.read { db in
                (try #require(try Queries.mcpGatheringFacts(db, readingID: id)),
                 try #require(try Queries.mcpGatheringFacts(db, readingID: hers.id)))
            }
            #expect(wire.wingID == herFacts.wingID && wire.fence == herFacts.fence)
            let shapes: [[MCPGrantRule.Grant]] = [
                [], [.init(id: "g1", rung: .read, scopeKind: .wing, scopeID: away.id, duration: .always)],
                [.init(id: "g2", rung: .edit, scopeKind: .wing, scopeID: away.id, duration: .once)],
                [.init(id: "g3", rung: .writeNew, scopeKind: .wing, scopeID: "", duration: .always)],
                [.init(id: "g4", rung: .read, scopeKind: .note, scopeID: "n", duration: .always)],
            ]
            for grants in shapes {
                for openBook in [false, true] {
                    for rung in MCPGrantRule.Rung.allCases {
                        func decided(_ facts: MCPGrantRule.BookFacts) -> MCPGrantRule.Decision {
                            MCPGrantRule.decideGathering(
                                client: .approved, grants: grants, openBook: openBook, gathering: facts, rung: rung)
                        }
                        #expect(decided(wire) == decided(herFacts), "\(grants) · open \(openBook) · \(rung)")
                    }
                }
            }
            // Her own gathering grant reaches hers, never the wire's — and back.
            let onHers: [MCPGrantRule.Grant] = [.init(id: "g5", rung: .read, scopeKind: .gathering,
                                                      scopeID: hers.id, duration: .always)]
            #expect(MCPGrantRule.decideGathering(client: .approved, grants: onHers, openBook: false, gathering: herFacts)
                    .isAllowed)
            #expect(!MCPGrantRule.decideGathering(client: .approved, grants: onHers, openBook: false, gathering: wire)
                    .isAllowed)
            await h.hangUp(connection)
        }
    }

    // MARK: - The name guard (RED ON OLD: no such tool)

    /// The name is checked against the books and gatherings this client can
    /// READ (VX-259 — `create_book`'s rule): a readable one refuses, as
    /// `create_book` refuses; one the client can't read never blocks it.
    @Test func theNameIsCheckedOnlyAgainstWhatTheClientCanRead() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let away = try h.operations.createWing(name: "away")
            _ = try h.operations.createReading(name: "Board", kind: .book)
            _ = try h.operations.createReading(name: "Hidden", kind: .book, wingId: away.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))

            let clash = try await call(connection, "create_gathering", [
                "name": .string("board"), "wing_id": .string(""), "rule": .object(["star": .bool(true)]),
            ])
            let bookClash = try await call(connection, "create_book", ["name": .string("board"), "wing_id": .string("")])
            #expect(clash.isError == true && text(clash) == text(bookClash), "\(text(clash))")
            let unseen = try await call(connection, "create_gathering", [
                "name": .string("Hidden"), "wing_id": .string(""), "rule": .object(["star": .bool(true)]),
            ])
            #expect(unseen.isError != true, "a book the client can't read never blocks the name: \(text(unseen))")
            await h.hangUp(connection)
        }
    }

    // MARK: - The catalog

    @Test func itIsDeclaredAtWriteNewOnTheWingAndItsDescriptionTeachesIt() throws {
        let declaration = try #require(MCPToolCatalog.declaration(named: "create_gathering"))
        #expect(declaration.rung == .writeNew && declaration.scopes == [.wing])
        let required = declaration.inputSchema.objectValue?["required"]?.arrayValue?.compactMap(\.stringValue)
        #expect(Set(required ?? []) == ["name", "wing_id", "rule"])
        for phrase in ["list_wings", "set_book_rule", "remove_tag", "author"] {
            #expect(declaration.description.contains(phrase), "says \(phrase): \(declaration.description)")
        }
    }
}
