import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-813 (the VX-809 run, batch 2 — her R-813) — a book's ORDER on the wire, end
// to end over the socket: `set_book_order` at EDIT on the book or the gathering
// place (her navigator's Save as This Book's Order draws on both — R-VX184-1's
// parity); the answer, `changed: false` with nothing written for the order
// already as asked; her op's one refusal (a finished or sealed book); the
// receipt and the ONE client-named undo; the `order` options on `create_book`
// (write new) and `set_book_rule` (A-809-17: the call's rung read from its
// arguments — an order decides the book at EDIT); `list_books` reading the
// order back.

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

@Suite("VX-813 — a book's order on the wire", .serialized)
struct MCPBookOrderServerTests {
    /// The reading's whole row, as text (a sync read — the async overload
    /// would win inside the test bodies).
    private func row(_ h: ServerHarness, _ id: String) throws -> String {
        try h.database.read { db in
            try Row.fetchOne(db, sql: "SELECT * FROM reading WHERE id = ?", arguments: [id])?.description ?? ""
        }
    }

    private func rule(_ h: ServerHarness, _ id: String) throws -> String? {
        try h.database.read { try Reading.fetchOne($0, key: id)?.querySpec }
    }

    private func order(_ h: ServerHarness, _ id: String) throws -> [String] {
        try h.database.read { db in
            let row = try #require(try Row.fetchOne(db, sql: "SELECT sort_field, sort_dir FROM reading WHERE id = ?",
                                                   arguments: [id]))
            return [row["sort_field"], row["sort_dir"]]
        }
    }

    @Test func setBookOrderLandsAtEditWithItsAnswerReceiptAndOneUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "Letters", kind: .book)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, book.id))
            let landed = try await call(connection, "set_book_order", [
                "book_id": .string(book.id), "sort_field": .string("entry_date"), "sort_dir": .string("desc"),
            ])
            #expect(landed.isError != true)
            #expect(text(landed) == #"{"book_id":"\#(book.id)","changed":true,"order":{"sort_dir":"desc","sort_field":"entry_date"}}"#)
            #expect(try order(h, book.id) == ["entry_date", "desc"])
            #expect(h.receipts.value.map(\.act) == [.bookSort])
            #expect(h.receipts.value.first?.targetTitle == "Letters")
            #expect(h.undoStack.topLabel == "claude-code's book order", "ONE client-named undo")
            _ = try h.undoStack.undo(with: h.writeOperations)
            #expect(try order(h, book.id) == ["manual", "asc"])

            // The order already as asked: changed false, nothing written, no
            // receipt, nothing to undo.
            try h.operations.setReadingSort(book.id, field: .createdAt, direction: .asc)
            let before = try row(h, book.id)
            let depth = h.undoStack.depth
            let same = try await call(connection, "set_book_order", [
                "book_id": .string(book.id), "sort_field": .string("created_at"),
            ])
            #expect(text(same) == #"{"book_id":"\#(book.id)","changed":false,"order":{"sort_dir":"asc","sort_field":"created_at"}}"#,
                    "sort_dir defaults to asc")
            let after = try row(h, book.id)
            #expect(before == after && h.undoStack.depth == depth && h.receipts.value.count == 1)

            // list_books reads the order back.
            let listed = try object(try await call(connection, "list_books", [:]))
            let entry = try #require((listed["books"] as? [[String: Any]])?.first)
            #expect(entry["order"] as? [String: String] == ["sort_field": "created_at", "sort_dir": "asc"])
            await h.hangUp(connection)
        }
    }

    @Test func belowEditTheOrderRefusesWithHerAskAtEdit() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "Letters", kind: .book)
            let connection = try await h.connect(as: "claude-code")
            var grant = try #require(try h.approve("claude-code", spec(.read, .book, book.id)))
            let client = try h.client("claude-code").id
            for rung in [MCPGrantRule.Rung.read, .suggest, .writeNew] {
                if rung != .read {
                    try h.operations.revokeMCPGrant(grant)
                    grant = try h.operations.grantMCPAccess(client, spec(rung, .book, book.id))
                }
                h.asks.setValue([])
                let refused = try await call(connection, "set_book_order", [
                    "book_id": .string(book.id), "sort_field": .string("entry_date"),
                ])
                #expect(refused.isError == true)
                #expect(text(refused).hasPrefix("This client may only \(MCPRefusalCopy.rungWords(rung)) here."))
                #expect(h.asks.value.map(\.rung) == [.edit], "her ask, at edit")
            }
            #expect(try order(h, book.id) == ["manual", "asc"])
            await h.hangUp(connection)
        }
    }

    @Test func aGatheringTakesAnOrderAtEditOnItsPlaceAndAFinishedBookRefuses() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let tag = try h.operations.createTag(name: "board")
            let gathering = try h.operations.createReading(
                name: "Board", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            let finished = try h.operations.createReading(name: "Done", kind: .book)
            try h.operations.lockReading(finished.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let landed = try await call(connection, "set_book_order", [
                "book_id": .string(gathering.id), "sort_field": .string("last_touched"), "sort_dir": .string("desc"),
            ])
            let landedAnswer = try object(landed)
            #expect(landed.isError != true && landedAnswer["changed"] as? Bool == true)
            #expect(try order(h, gathering.id) == ["last_touched", "desc"])
            #expect(h.receipts.value.map(\.act) == [.gatheringSort])
            #expect(h.undoStack.topLabel == "claude-code's gathering order")
            let refused = try await call(connection, "set_book_order", [
                "book_id": .string(finished.id), "sort_field": .string("manual"),
            ])
            #expect(refused.isError == true && text(refused) == "Refused: \(OperationError.lockedReading(id: finished.id))",
                    "her op's own refusal, through the one chain")
            await h.hangUp(connection)
        }
    }

    @Test func theOrderArgumentsRefuseInWordsBeforeAnyDecision() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "Letters", kind: .book)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, book.id))
            let noField = try await call(connection, "set_book_order", ["book_id": .string(book.id)])
            #expect(text(noField).hasPrefix("sort_field is required"))
            let badField = try await call(connection, "set_book_order", [
                "book_id": .string(book.id), "sort_field": .string("title"),
            ])
            #expect(text(badField).hasPrefix("sort_field must be one of"))
            let badDir = try await call(connection, "set_book_order", [
                "book_id": .string(book.id), "sort_field": .string("entry_date"), "sort_dir": .string("down"),
            ])
            #expect(text(badDir) == "sort_dir must be \"asc\" or \"desc\".")
            #expect(try order(h, book.id) == ["manual", "asc"] && h.undoStack.depth == 0)
            await h.hangUp(connection)
        }
    }

    // MARK: - The order options

    @Test func createBookTakesAnOrderAtWriteNewAndEchoesItOnlyWhenGiven() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            let plain = try object(try await call(connection, "create_book", ["name": .string("Plain"), "wing_id": .string("")]))
            #expect(plain["order"] == nil, "no order given: the answer byte-unchanged")
            let dated = try await call(connection, "create_book", [
                "name": .string("Journal of days"), "wing_id": .string(""),
                "order": .object(["sort_field": .string("entry_date"), "sort_dir": .string("desc")]),
            ])
            let answer = try object(dated)
            #expect(answer["order"] as? [String: String] == ["sort_field": "entry_date", "sort_dir": "desc"])
            let id = try #require(answer["book_id"] as? String)
            #expect(try order(h, id) == ["entry_date", "desc"])
            #expect(h.undoStack.depth == 2, "one entry per mint, never a second for the order")
            let unknown = try await call(connection, "create_book", [
                "name": .string("X"), "wing_id": .string(""), "order": .object(["field": .string("manual")]),
            ])
            #expect(unknown.isError == true
                    && text(unknown).hasPrefix("order.field isn't an argument of create_book, so nothing was done"),
                    "VX-606's one check at the call door reaches inside the option's object: \(text(unknown))")
            await h.hangUp(connection)
        }
    }

    @Test func setBookRuleWithAnOrderDecidesTheBookAtEdit() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "Letters", kind: .book)
            let connection = try await h.connect(as: "claude-code")
            let grant = try #require(try h.approve("claude-code", spec(.writeNew, .book, book.id)))
            let withOrder: [String: Value] = [
                "book_id": .string(book.id), "rule": .object(["tag": .string("percy")]),
                "order": .object(["sort_field": .string("entry_date")]),
            ]
            h.asks.setValue([])
            let refused = try await call(connection, "set_book_rule", withOrder)
            #expect(refused.isError == true && text(refused).hasPrefix("This client may only \(MCPRefusalCopy.rungWords(.writeNew)) here."),
                    "an order is an edit of the book (A-809-17): \(text(refused))")
            #expect(h.asks.value.map(\.rung) == [.edit])
            #expect(try rule(h, book.id) == nil, "nothing landed")
            // Without an order, write new lands as before.
            let ruled = try await call(connection, "set_book_rule", [
                "book_id": .string(book.id), "rule": .object(["tag": .string("percy")]),
            ])
            #expect(ruled.isError != true)
            try h.operations.revokeMCPGrant(grant)
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.edit, .book, book.id))
            let depth = h.undoStack.depth
            let landed = try object(try await call(connection, "set_book_rule", [
                "book_id": .string(book.id), "order": .object(["sort_field": .string("created_at"), "sort_dir": .string("desc")]),
            ]))
            #expect(landed["changed"] as? Bool == true)
            #expect(landed["order"] as? [String: String] == ["sort_field": "created_at", "sort_dir": "desc"])
            #expect(try order(h, book.id) == ["created_at", "desc"] && h.undoStack.depth == depth + 1)
            await h.hangUp(connection)
        }
    }
}
