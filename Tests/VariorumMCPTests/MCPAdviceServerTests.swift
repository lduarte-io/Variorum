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
    _ connection: HarnessConnection, _ name: String, _ arguments: [String: Value]
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
        // VX-197 (VX-336 U8a — A JUSTIFIED EDIT, the ritual): R-VX184-3, her
        // ruling carried from VX-184's pre-run sitting — 2,000 → 3,000, the
        // bound and its pin moved together.
        #expect(MCPSession.instructionsBound == 3_000)
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
        // VX-197 (VX-336 U8a — A JUSTIFIED EDIT, the ritual): the U7 carries
        // name the recovery tool (list_my_activity), the organization advice
        // names the copy road (duplicate_note) — and the paging clause names
        // ONE parameter, read_note's ids_only, which must be a declared input
        // of read_note (a parameter is not a tool).
        let parameters: Set<String> = ["ids_only"]
        #expect(Set(names) == Set(["read_note", "show_in_app", "list_books", "move_note_to_wing",
                                   "list_my_activity", "duplicate_note"]).union(parameters),
                "the tools and parameters it names: \(names)")
        for name in Set(names).subtracting(parameters).union(["search"]) {
            #expect(MCPToolCatalog.declaration(named: name) != nil, "\(name) is a declared tool")
        }
        let readNoteInputs = MCPToolCatalog.readNote.inputSchema.objectValue?["properties"]?.objectValue ?? [:]
        for parameter in parameters {
            #expect(readNoteInputs[parameter] != nil, "\(parameter) is a declared input of read_note")
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
        // 13n-c U6 — VX-273 and VX-160, the guide's lesson 3 fourth card:
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

    // MARK: - VX-197 (VX-336 U8a): the advice at 3,000 — the U7 carries, the
    // edit rung's reach, the organization advice, the three acts that stay the
    // author's (R-VX184-2), and ONE link (R-VX184-4)

    /// U7's carry (builder A's OWED 6): "Tools appear only for what they have
    /// shared" is UNTRUE once list_my_activity lists at zero reach
    /// (P-VX261-2). The line says the built rule, tied to the catalog: the
    /// ONE tool listed on approval alone is list_my_activity.
    @Test func theToolsLineSaysWhatIsListedOnApproval() {
        #expect(!advice.contains("Tools appear only for what they have shared"))
        #expect(advice.contains(
            "Once approved, list_my_activity is always listed; other tools appear only for what the author "
                + "has shared (re-announced when that changes)."))
        #expect(MCPToolCatalog.all.filter(\.listedWhenApproved).map(\.name) == ["list_my_activity"],
                "the catalog's fact the sentence states")
    }

    /// The paging and digest roads (U7's carries, builder B's OWED 3), said
    /// WITHOUT a number: the page bound and the limit's numbers live in
    /// read_note's description (U7c's sentence), so nothing a window measures
    /// can falsify the advice. And the recovery road after a lost answer.
    @Test func theAdviceNamesPagingDigestsAndRecoveryWithNoNumber() {
        #expect(advice.contains(
            "Read a long note in pages (limit, then cursor); ids_only gives each take's sha256 instead of its text."))
        #expect(advice.contains("Many writes answer each take's sha256, to prove your words landed."))
        #expect(advice.contains("If an answer is lost, list_my_activity shows whether the call landed."))
        let inputs = MCPToolCatalog.readNote.inputSchema.objectValue?["properties"]?.objectValue ?? [:]
        #expect(["limit", "cursor", "ids_only"].allSatisfy { inputs[$0] != nil }, "read_note's own inputs")
        // A GUARD (green on both sides by design): no number at all beyond the
        // format's version token and the digest's name — a page bound, a limit
        // or a cap belongs to the descriptions.
        let numberless = advice
            .replacingOccurrences(of: VariorumDocument.versionToken, with: "")
            .replacingOccurrences(of: "sha256", with: "")
        #expect(numberless.firstMatch(of: /[0-9]/) == nil, "the advice states no number a window could move")
    }

    /// The edit rung's reach as built (R-VX184-1: as capable as the author at
    /// the keyboard, the three acts that stay hers aside) and write new's
    /// insert_blocks at a note's end (P-VX255-1) — the catalog's facts.
    @Test func theRungsSayTheirReachAsBuilt() {
        #expect(advice.contains(
            "write new (new notes, books, chapters, tags, versions; blocks added at a note's end)"))
        #expect(advice.contains(
            "edit (most of what the author can do at the keyboard: edit, choose and commit takes; "
                + "divide, merge, move, delete; rename, archive)"))
        #expect(MCPToolCatalog.insertBlocks.rung == .writeNew, "insert_blocks lists from write new")
        for tool in ["rename_note", "rename_book", "archive_note", "archive_book", "choose_take", "save_commit"] {
            #expect(MCPToolCatalog.declaration(named: tool)?.rung == .edit, "\(tool) is edit's")
        }
    }

    /// The organization advice (the plan's "U7: the AI's docs" item 2, her
    /// recipes' spirit): notes over chat, books and chapters, tags and books
    /// that collect by tag rules, takes over edits, comments for review, and
    /// duplicate_note for a revision Compare lines up (VX-311 · VX-298).
    @Test func theAdviceEncouragesOrganization() {
        #expect(advice.contains(
            "Help the author stay organized: put plans, summaries and research into notes, not just chat; "
                + "file notes into books and chapters; tag them, and make books that collect by tag rules."))
        #expect(advice.contains(
            "Offer a rewrite as a new take beside theirs, not an edit of their words; leave review as comments."))
        #expect(advice.contains(
            "For a revision, copy the note with duplicate_note and edit the copy, so Compare lines the two up."))
        for tool in ["create_note", "create_book", "create_section", "add_note_to_book", "apply_tag",
                     "set_book_rule", "add_take", "add_comment", "duplicate_note"] {
            #expect(MCPToolCatalog.declaration(named: tool) != nil, "\(tool) is a declared tool")
        }
    }

    /// R-VX184-2: Private, Seal and Own stay the author's alone — "though the
    /// AI should know about them so it can tell a user that they might want
    /// that." No tool sets them (the catalog's fact).
    @Test func theAdviceSaysTheThreeActsAreTheAuthorsAlone() {
        #expect(advice.contains(
            "Three acts are the author's alone: marking something Private, sealing a book (finished, its text "
                + "frozen) and making a book own its notes. You can't do them, but suggest one when it would help."))
        let words = Set(MCPToolCatalog.all.flatMap { $0.name.split(separator: "_").map(String.init) })
        #expect(words.isDisjoint(with: ["private", "seal", "unseal", "own", "owned", "disown"]),
                "no tool marks Private, seals or owns")
    }

    /// R-VX184-4: ONE sentence links the public guide at its FIXED URL — the
    /// advice's last line, the only link it carries. (The launch gate travels
    /// with it: a build carrying this line ships publicly only after the page
    /// is live.)
    @Test func theAdviceLinksTheGuideOnce() {
        let url = "https://stargazing.tech/variorum/mcp"
        #expect(advice.components(separatedBy: url).count == 2, "the URL, exactly once")
        #expect(advice.components(separatedBy: "://").count == 2, "and no other link")
        #expect(advice.hasSuffix("\nThe guide to this door: \(url)"), "its one sentence, last")
    }

    // MARK: - It arrives

    /// A real client reads the advice at `initialize` over the socket — before
    /// approval, before any tool is listed.
    @Test func aRealClientReadsTheAdviceAtInitializeBeforeItHoldsAnything() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        // VX-168 (A JUSTIFIED EDIT, the ritual): a new client arrives with
        // its setup's key — a bare one is refused before `initialize`.
        // VX-132 (A JUSTIFIED EDIT, the ritual): through the harness's bounded
        // client (the same SDK client on the same socket road, its acts
        // time-limited) instead of a hand-built one; `initialized` is what
        // `initialize` answered — exactly what `Client.connect` returned here.
        let connection = try await h.connect(as: "a-new-client")
        #expect(connection.client.initialized.instructions == MCPSession.instructions,
                "the advice, verbatim, at initialize")
        let tools = try await connection.client.listTools().tools
        #expect(tools.isEmpty, "a connection request sees no tools — only the advice")
        await h.hangUp(connection)
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

    // MARK: - Her sitting's ask: the while-connected duration's BUILT meaning

    /// The advice says what "until you disconnect" actually does (her sitting,
    /// 2026-10-11 — "so a confused user who asks their AI hears the real
    /// answer"), and each clause is EXECUTED here against the host's own
    /// lifecycle: the grant belongs to the client's NAME (a connection opened
    /// AFTER the grant keeps it alive), it ends when that name's LAST open
    /// connection closes (`MCPServerHost.ended`), a reconnect does not bring it
    /// back, and the server stopping ends it (every session hung up; every
    /// start sweeps). `MCPServerTests.whileConnectedEndsWhenTheClientsLast…`
    /// pins the two-connections-from-the-start case beside it.
    @Test func untilYouDisconnectSaysTheBuiltMechanics() async throws {
        #expect(advice.contains(
            "Until you disconnect lasts while any connection under your client's name stays open, "
            + "sessions opened later included; it ends when the last one closes or Variorum's server "
            + "stops, and reconnecting does not restore it."))
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "b", kind: .book)
            let spec = Operations.MCPGrantSpec(rung: .read, scopeKind: .book, scopeID: book.id, duration: .connection)
            func revoked(_ id: String) throws -> Bool {
                try h.database.read { try Queries.mcpGrant($0, id: id) }?.revokedAt != nil
            }
            func liveConnectionGrants() throws -> Int {
                let client = try h.client("claude-code")
                return try h.database.read { try Queries.mcpGrants($0, clientID: client.id) }
                    .filter { $0.duration == .connection && $0.revokedAt == nil }.count
            }

            let first = try await h.connect(as: "claude-code")
            let grant = try #require(try h.approve("claude-code", spec))
            let later = try await h.connect(as: "claude-code")  // opened AFTER the grant
            await h.hangUp(first)
            try await Task.sleep(for: .milliseconds(200))
            #expect(try revoked(grant) == false, "a session opened later keeps it alive — the grant is the name's")
            await h.hangUp(later)
            #expect(try await h.eventually { try revoked(grant) }, "it ends when the LAST one closes")

            let again = try await h.connect(as: "claude-code")
            try await Task.sleep(for: .milliseconds(200))
            #expect(try revoked(grant) && liveConnectionGrants() == 0, "reconnecting does not restore it")

            let second = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec)
            h.host.stop()  // Variorum's server stops: every session hung up
            #expect(try await h.eventually { try revoked(second) }, "the server stopping ends it")
            _ = again

            let orphan = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec)
            #expect(try revoked(orphan) == false, "minted while the server is down…")
            try h.host.start()
            #expect(try revoked(orphan), "…and every server start sweeps it (no connection survives a stop)")
        }
    }
}
