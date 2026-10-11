import Dependencies
import Foundation
import GRDB
import MCP
import System
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// 13n-c U5 — THE AI'S ADVICE (D-2; her kickoff: "notes / documentation for the
// user need to be made clear (especially since that's what a user's AI might
// need as advice too)") and the one fact the docs say that no pin said yet:
// SNIPPETS ARE NOT REACHABLE through the door (round 5, ratified at round 6).
//
// The advice is `MCPSession.instructions`, which every client reads at
// `initialize` before it holds a single grant. These pins keep it from
// drifting silently: its stated length bound; every tool it names declared in
// the catalog; the document format's markers read from `VariorumDocument`;
// the U1 ladder's two carries (F5 — no "Every refusal says why."; R2-8 —
// search serves standing grants only); and its arrival over a real socket.

private func call(
    _ connection: (client: Client, fd: Int32), _ name: String, _ arguments: [String: Value]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: name, arguments: arguments)
}

@Suite("13n-c U5 — the AI's advice, and snippets out of reach", .serialized)
struct MCPAdviceServerTests {
    private var advice: String { MCPSession.instructions }

    // MARK: - The advice's letter

    @Test func theAdviceIsBoundedAsStated() {
        // 13n-c: her ruled bound (P-13nc-U5-5 — 1,500 → 2,000, "a bit of
        // wiggle room for future updates"); the pin keeps its form.
        #expect(MCPSession.instructionsBound == 2_000)
        #expect(advice.count <= MCPSession.instructionsBound,
                "the advice is \(advice.count) characters — a client may carry it in every turn")
        #expect(advice.count > 600, "…and long enough to say what the door is")
    }

    /// Every tool-shaped name the advice says (`read_note`, `show_in_app`, …)
    /// is a tool the catalog declares — and the bare `search` it names is too.
    @Test func everyToolTheAdviceNamesIsDeclared() throws {
        let names = advice.matches(of: /\b[a-z]+(?:_[a-z]+)+\b/).map { String($0.output) }
        // 13n-c U6 (A JUSTIFIED EDIT, the ritual): the gatherings clause names
        // list_books and the move names move_note_to_wing.
        #expect(Set(names) == ["read_note", "show_in_app", "list_books", "move_note_to_wing"],
                "the tools it names: \(names)")
        for name in names + ["search"] {
            #expect(MCPToolCatalog.declaration(named: name) != nil, "\(name) is a declared tool")
        }
        #expect(advice.contains("\nsearch covers standing grants only"))
    }

    /// The format's two facts a model needs, read from the format's own home
    /// (never retyped), so a renamed marker changes the advice with it.
    @Test func theAdviceSpeaksTheFormatsOwnMarkers() {
        #expect(advice.contains("read_note speaks the Variorum document format"))
        #expect(advice.contains(VariorumDocument.versionToken))
        #expect(advice.contains("\"\(VariorumDocument.blockMarker)\""))
    }

    /// The facts the field guide's chapter teaches, said to the model: the
    /// four rungs in their order, the three places and three durations, the
    /// open book, live ids, the fence, snippets, the refusal posture, the
    /// show_in_app etiquette (R-13nb-23) and the client-named undo.
    @Test func theAdviceSaysTheSameFactsTheGuideTeaches() {
        let rungs = ["read (", "suggest (", "write new (", "edit ("]
        let positions = rungs.compactMap { advice.range(of: $0)?.lowerBound }
        #expect(positions.count == 4 && positions == positions.sorted(), "the four rungs, in order")
        #expect(advice.contains("each including those before it"))
        #expect(advice.contains("a note, a book or a wing"))
        #expect(advice.contains("for once, until you disconnect, or always"))
        #expect(advice.contains("(the open book)"))
        #expect(advice.contains("Ids are live"))
        #expect(advice.contains("daily Journal's entries and anything marked Private are shared one ask at a time"))
        #expect(advice.contains("snippets are not reachable at all"))
        #expect(advice.contains("answers exactly as if it did not exist"))
        #expect(advice.contains("don't retry around it: tell the author what you need"))
        // Stage B R1 B13 / O-2 (A JUSTIFIED EDIT — the ritual): the advice
        // names "the author", never a pronoun that assumes theirs.
        #expect(advice.contains("Never call show_in_app unless the author asks"))
        #expect(advice.contains("one undo for the author, named after you"))
        // 13n-c U6 — R-AIR-12 and VX-160, the guide's lesson 3 fourth card:
        // a wing grant reads its gatherings (never granted alone); the move's
        // two rungs.
        #expect(advice.contains("A wing grant also reads that wing's gatherings"))
        #expect(advice.contains("none is ever granted alone"))
        #expect(advice.contains("move_note_to_wing needs edit on the note and write new on the wing it goes to"))
        #expect(MCPToolCatalog.moveNoteToWing.rung == .edit, "the catalog's fact the sentence states")
    }

    /// The U1 ladder's two carries. F5: a fenced or unshared target answers
    /// the ONE not-shared answer by design (T-2), so "every refusal says why"
    /// was false. R2-8: search never serves a once grant.
    @Test func theLadderCarriesLanded() {
        #expect(!advice.contains("Every refusal says why"))
        #expect(advice.contains("search covers standing grants only; read a once grant's note by id."))
        #expect(MCPToolCatalog.search.needsStandingReach, "the catalog's fact the sentence states")
    }

    // MARK: - It arrives

    /// A real client reads the advice at `initialize` over the socket — before
    /// approval, before any tool is listed.
    @Test func aRealClientReadsTheAdviceAtInitializeBeforeItHoldsAnything() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        guard case .success(let fd) = MCPSocketRoad.connect(directory: h.directory) else {
            throw HarnessFailure("could not connect")
        }
        defer { close(fd) }
        let transport = StdioTransport(input: FileDescriptor(rawValue: fd), output: FileDescriptor(rawValue: fd))
        let client = Client(name: "a-new-client", version: "1.0")
        let result = try await client.connect(transport: transport)
        #expect(result.instructions == MCPSession.instructions, "the advice, verbatim, at initialize")
        let tools = try await client.listTools().tools
        #expect(tools.isEmpty, "a connection request sees no tools — only the advice")
        await client.disconnect()
        shutdown(fd, SHUT_RDWR)
    }

    // MARK: - Snippets are not reachable (round 5's fact, the docs' sentence, pinned)

    /// Under the WIDEST reach there is — a Home-wing EDIT grant AND the open
    /// book — a scraps group answers exactly as an id that names nothing, on
    /// every tool, and a word only a snippet holds searches exactly as a word
    /// nowhere. A plain note in the same wing is the control: reached whole.
    @Test func snippetsAreUnreachableUnderAWingEditGrantAndTheOpenBook() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let pool = try h.operations.createPool(title: "scraps")
            let scrap = try h.operations.newBlock(
                in: pool.id, text: "zibeline under the eaves", registeringUndo: false)
            let page = try h.operations.createPost(title: "a plain page")
            _ = try h.operations.newBlock(in: page.id, text: "marram on the dunes", registeringUndo: false)

            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", .init(rung: .edit, scopeKind: .wing, scopeID: "", duration: .always))
            try h.operations.setMCPSwitch(.openBook, on: true)

            // The control: the wing reaches its plain note whole.
            let control = try await call(connection, "read_note", ["note_id": .string(page.id)])
            #expect(control.isError != true && text(control).contains("marram on the dunes"))
            let found = try json(try await call(connection, "search", ["query": "marram"]))
            #expect((found["passages"] as? [[String: Any]])?.compactMap { $0["note_id"] as? String } == [page.id])

            // A word only a snippet holds searches exactly as a word nowhere.
            let snippetWord = try await call(connection, "search", ["query": "zibeline"])
            let nowhereWord = try await call(connection, "search", ["query": "quodlibetarian"])
            #expect(text(snippetWord) == text(nowhereWord) && snippetWord.isError == nowhereWord.isError,
                    "a snippet's word answers byte-identically to a word nowhere")
            #expect((try json(snippetWord)["passages"] as? [Any])?.isEmpty == true)

            // The scraps group, by id, answers as an id naming nothing.
            for tool in ["read_note", "export_note"] {
                let group = try await call(connection, tool, ["note_id": .string(pool.id)])
                let nothing = try await call(connection, tool, ["note_id": .string("no-such-note")])
                #expect(group.isError == true && text(group) == text(nothing),
                        "\(tool): a scraps group is the one answer, byte for byte")
            }
            // Never listed.
            let listed = try json(try await call(connection, "list_notes", ["wing_id": .string("")]))
            let ids = (listed["notes"] as? [[String: Any]])?.compactMap { $0["id"] as? String } ?? []
            #expect(ids.contains(page.id) && !ids.contains(pool.id), "the wing lists its note, never the snippets")
            // And not writable: a take on a snippet's block answers as a block naming nothing.
            let onSnippet = try await call(connection, "add_take", [
                "block_id": .string(scrap.block.id), "text": .string("a client's line"),
            ])
            let onNothing = try await call(connection, "add_take", [
                "block_id": .string("no-such-block"), "text": .string("a client's line"),
            ])
            #expect(onSnippet.isError == true && text(onSnippet) == text(onNothing),
                    "a snippet's block refuses exactly as a block that doesn't exist")
            let fan = try await h.database.read { try Queries.blockFan($0, blockID: scrap.block.id) }
            #expect(fan.count == 1, "nothing was written beside the snippet")
            await h.hangUp(connection)
        }
    }
}
