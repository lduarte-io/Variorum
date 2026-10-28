import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-606 — THE SCHEMA THE WIRE PUBLISHES IS THE SCHEMA IT ENFORCES (the VX-648
// run, batch 2; her word "refuse undeclared arguments on every tool"). The VX-548
// mid window's MID-3: `read_note` served a call carrying `"ids": true` although
// its schema says `additionalProperties: false` — the call road never read the
// schema back, so an invented or misspelled argument was dropped in silence.
// Every pin drives a real client over the socket (the session's `CallTool`
// handler is the one door). RED ON OLD by behavioural revert: with the door's one
// check removed (`MCPSession`'s `MCPArgumentSchema.refusal` call), each refused
// call below is served, decided or refused in other words.

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

@Suite("VX-606 — an argument the schema does not declare refuses the call, on every tool", .serialized)
struct MCPUndeclaredArgumentsServerTests {
    private func activityCount(_ h: ServerHarness) throws -> Int {
        try h.database.read { try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM mcp_activity") ?? 0 }
    }

    private func consumedAt(_ h: ServerHarness, _ grant: String) throws -> String? {
        try h.database.read {
            try String.fetchOne($0, sql: "SELECT consumed_at FROM mcp_grant WHERE id = ?", arguments: [grant])
        }
    }

    private func liveNotes(_ h: ServerHarness) throws -> Int {
        try h.database.read {
            try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM container WHERE kind = 'post' AND deleted_at IS NULL") ?? 0
        }
    }

    /// MID-3's exact call: `read_note` with `ids: true` under a ONCE read
    /// grant — refused in words, the once grant unspent, nothing logged; the
    /// declared spelling (`with_ids`) then reads and spends it.
    @Test func readNoteRefusesTheUndeclaredIdsAndSpendsNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "the harbour")
            let connection = try await h.connect(as: "claude-code")
            let grant = try #require(try h.approve("claude-code", spec(.read, .note, note.id, .once)))
            let before = try activityCount(h)

            let refused = try await connection.client.callTool(
                name: "read_note", arguments: ["note_id": .string(note.id), "ids": .bool(true)])
            #expect(refused.isError == true)
            #expect(text(refused)
                    == "ids isn't an argument of read_note, so nothing was done — send only the arguments its input schema lists.")
            #expect(try consumedAt(h, grant) == nil, "a refused call never spends a once grant")
            #expect(try activityCount(h) == before, "a parse refusal is never logged")
            #expect(h.asks.value.isEmpty, "nothing is asked")

            let served = try await connection.client.callTool(
                name: "read_note", arguments: ["note_id": .string(note.id), "with_ids": .bool(true)])
            #expect(served.isError != true, "\(text(served))")
            #expect(try json(served)["note_id"] as? String == note.id)
            #expect(try consumedAt(h, grant) != nil, "the declared spelling reads, and spends it")
            await h.hangUp(connection)
        }
    }

    /// A write with every argument right but one it invented: refused before
    /// the act — no note minted, no undo entry, no receipt, no activity line.
    @Test func aWriteCarryingAnUndeclaredArgumentWritesNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let notes = try liveNotes(h)
            let before = try activityCount(h)
            let refused = try await connection.client.callTool(
                name: "create_note",
                arguments: ["wing_id": .string(""), "text": .string("Hello."), "colour": .string("red"),
                            "pinned": .bool(true)])
            #expect(refused.isError == true)
            #expect(text(refused)
                    == "colour and pinned aren't arguments of create_note, so nothing was done — send only the arguments its input schema lists.")
            #expect(try liveNotes(h) == notes && h.undoStack.depth == 0 && h.receipts.value.isEmpty)
            #expect(try activityCount(h) == before)

            let landed = try await connection.client.callTool(
                name: "create_note", arguments: ["wing_id": .string(""), "text": .string("Hello.")])
            #expect(landed.isError != true, "\(text(landed))")
            #expect(try liveNotes(h) == notes + 1)
            await h.hangUp(connection)
        }
    }

    /// EVERY declared tool, called with one argument no schema declares,
    /// answers exactly the refusal — the rule is the catalog's, never a
    /// tool's — and the store hears nothing (no activity, no undo, no
    /// receipt, no ask). The client holds edit on Home, so on the old road
    /// most of these calls would be decided, served or written.
    @Test func everyDeclaredToolRefusesAnUndeclaredArgumentAndTheStoreHearsNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            _ = try h.operations.createPost(title: "a note")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let before = try activityCount(h)
            #expect(MCPToolCatalog.all.count > 60, "the walk is the whole catalog")
            for declaration in MCPToolCatalog.all {
                let answer = try await connection.client.callTool(
                    name: declaration.name, arguments: ["vx606_not_an_argument": .bool(true)])
                #expect(answer.isError == true, "\(declaration.name)")
                #expect(text(answer) == "vx606_not_an_argument isn't an argument of \(declaration.name), so nothing "
                        + "was done — send only the arguments its input schema lists.", "\(declaration.name): \(text(answer))")
            }
            #expect(try activityCount(h) == before)
            #expect(h.undoStack.depth == 0 && h.receipts.value.isEmpty && h.asks.value.isEmpty)
            await h.hangUp(connection)
        }
    }

    /// A tool no catalog knows still answers as it did; a call whose
    /// arguments are all declared is routed exactly as before (an empty
    /// call to `list_my_activity` lists).
    @Test func anUnknownToolAndADeclaredCallAnswerAsBefore() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .wing, ""))
            let unknown = try await connection.client.callTool(name: "no_such_tool", arguments: ["ids": .bool(true)])
            #expect(text(unknown) == "Unknown tool: no_such_tool.")
            let listed = try await connection.client.callTool(name: "list_my_activity", arguments: [:])
            #expect(listed.isError != true, "\(text(listed))")
            let paged = try await connection.client.callTool(name: "list_my_activity", arguments: ["limit": .int(5)])
            #expect(paged.isError != true, "\(text(paged))")
            await h.hangUp(connection)
        }
    }

    /// GUARD (VX-258's face — green on both sides): a connection whose setup
    /// key waits for her OK hears the pending sentence for every known tool,
    /// an undeclared argument included — the check runs after the waiting
    /// branch, as every parse refusal does.
    @Test func aWaitingSetupHearsThePendingSentenceWhateverItSends() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "n")
            let real = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, note.id))
            await h.hangUp(real)
            #expect(try await h.eventually { h.host.connectedClientNames.isEmpty })
            let waiting = try await h.connect(as: "claude-code", presenting: try h.operations.mintMCPSetupKey())
            let refused = try await waiting.client.callTool(
                name: "read_note", arguments: ["note_id": .string(note.id), "ids": .bool(true)])
            #expect(refused.isError == true && text(refused) == MCPRefusalCopy.words(.clientPending, .note))
            await h.hangUp(waiting)
        }
    }
}

// The pure rule — the walk reads the schema it is given, at every depth it
// describes, and nothing it doesn't.
@Suite("VX-606 — MCPArgumentSchema: the published schema, read back")
struct MCPArgumentSchemaTests {
    private let schema: Value = .object([
        "type": "object",
        "properties": .object([
            "note_id": .object(["type": "string"]),
            "closed": .object([
                "type": "object",
                "properties": .object(["a": .object(["type": "string"])]),
                "additionalProperties": false,
            ]),
            "open": .object(["type": "object", "properties": .object(["a": .object(["type": "string"])])]),
            "rows": .object([
                "type": "array",
                "items": .object([
                    "type": "object",
                    "properties": .object(["text": .object(["type": "string"])]),
                    "additionalProperties": false,
                ]),
            ]),
        ]),
        "additionalProperties": false,
    ])

    @Test func theWalkFindsEveryUndeclaredKeyAtEveryClosedDepthAndHonoursAnOpenOne() {
        #expect(MCPArgumentSchema.undeclared(nil, schema: schema).isEmpty)
        #expect(MCPArgumentSchema.undeclared(["note_id": "x"], schema: schema).isEmpty)
        #expect(MCPArgumentSchema.undeclared(["note_id": "x", "ids": true, "b": 1], schema: schema) == ["b", "ids"])
        #expect(MCPArgumentSchema.undeclared(["closed": .object(["a": "1", "z": "2"])], schema: schema) == ["closed.z"])
        #expect(MCPArgumentSchema.undeclared(["open": .object(["a": "1", "z": "2"])], schema: schema).isEmpty,
                "an open object stays open")
        #expect(MCPArgumentSchema.undeclared(
            ["rows": .array([.object(["text": "ok"]), .object(["text": "x", "colour": "red"])])], schema: schema)
                == ["rows[1].colour"])
        // A value of the wrong shape is the tool's parse to word, never this walk's.
        #expect(MCPArgumentSchema.undeclared(["closed": "not an object", "rows": 3], schema: schema).isEmpty)
        let open: Value = .object(["type": "object", "properties": .object([:])])
        #expect(MCPArgumentSchema.undeclared(["anything": true], schema: open).isEmpty)
    }

    @Test func theWordsNameWhatWasSentAndCountPastFive() {
        let tail = ", so nothing was done — send only the arguments its input schema lists."
        #expect(MCPArgumentSchema.words(tool: "read_note", undeclared: ["ids"]) == "ids isn't an argument of read_note" + tail)
        #expect(MCPArgumentSchema.words(tool: "t", undeclared: ["a", "b"]) == "a and b aren't arguments of t" + tail)
        #expect(MCPArgumentSchema.words(tool: "t", undeclared: ["a", "b", "c"]) == "a, b and c aren't arguments of t" + tail)
        #expect(MCPArgumentSchema.words(tool: "t", undeclared: ["a", "b", "c", "d", "e", "f", "g"])
                == "a, b, c, d, e and 2 more aren't arguments of t" + tail)
    }

    /// Every tool the catalog declares publishes a CLOSED top level — so the
    /// door's one check covers every tool (a tool published open would be
    /// honoured as open, and this pin would say so).
    @Test func everyDeclaredToolPublishesAClosedSchema() {
        for declaration in MCPToolCatalog.all {
            #expect(declaration.inputSchema.objectValue?["additionalProperties"] == .bool(false), "\(declaration.name)")
            #expect(MCPArgumentSchema.refusal(tool: declaration.name, arguments: ["x_undeclared": true]) != nil)
            #expect(MCPArgumentSchema.refusal(tool: declaration.name, arguments: nil) == nil)
        }
        #expect(MCPArgumentSchema.refusal(tool: "no_such_tool", arguments: ["x": true]) == nil, "the router's to say")
    }
}
