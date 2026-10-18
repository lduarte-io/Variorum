import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-392 (VX-348 U5 — her ruling R-VX348-5, the run record
// `notes/plans/fixes/vx-348-prelaunch-sweep.md` §U5): a client granted a wing
// that holds nothing could not learn the wing's id — `list_books` lists books,
// `list_notes` notes, and an empty wing has neither — so it could never make
// its first write there ("the client has no way to make its first write into a
// wing it was explicitly granted"). `list_wings` answers each wing the client
// holds a grant on: its id, name, rungs, duration and what is in it, counted
// exactly as the listings would list it. Ungranted wings are simply absent; no
// field tells hidden from missing.

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

private func call(
    _ connection: HarnessConnection, _ name: String, _ arguments: [String: Value] = [:]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: name, arguments: arguments)
}

private func wings(_ connection: HarnessConnection) async throws -> [[String: Any]] {
    let answer = try await call(connection, "list_wings")
    #expect(answer.isError != true, "\(text(answer))")
    return try #require(try json(answer)["wings"] as? [[String: Any]])
}

@Suite("VX-392 — list_wings: a granted wing is discoverable, empty or not", .serialized)
struct MCPListWingsServerTests {
    /// Sync reads (the async overloads would win inside the test bodies).
    private func consumedAt(_ h: ServerHarness, _ grant: String) throws -> String? {
        try h.database.read {
            try String.fetchOne($0, sql: "SELECT consumed_at FROM mcp_grant WHERE id = ?", arguments: [grant])
        }
    }

    private func liveGrantID(_ h: ServerHarness, _ client: String) throws -> String? {
        try h.database.read { db in try Queries.mcpGrants(db, clientID: client).first { $0.ruleGrant.isLive }?.id }
    }

    // MARK: - The ticket's done-when (RED ON OLD: no such tool)

    /// The report's repro, whole: a wing with no notes and no books, granted
    /// at edit · always beside a Home read grant. ONE call finds it; a book is
    /// then made in it with nothing else known.
    @Test func aFreshClientGrantedAnEmptyWingFindsItInOneCallAndMakesABookThere() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let planet = try h.operations.createWing(name: "PlanetLillian")
            let homeBook = try h.operations.createReading(name: "o ladrão de raios", kind: .book)
            let homeNote = try h.operations.createPost(title: "ch 1")
            _ = try h.operations.newBlock(in: homeNote.id, text: "words", registeringUndo: false)
            _ = try h.operations.addPostToReading(homeNote.id, to: homeBook.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .wing, ""))
            let client = try h.client("claude-code").id
            _ = try h.operations.grantMCPAccess(client, spec(.edit, .wing, planet.id))

            let names = Set(try await connection.client.listTools().tools.map(\.name))
            #expect(names.contains("list_wings"), "a wing grant lists the discovery tool")

            let found = try await wings(connection)
            #expect(found.map { $0["wing_id"] as? String } == ["", planet.id], "Home first, then the switcher's order")
            let entry = try #require(found.last)
            #expect(entry["name"] as? String == "PlanetLillian")
            #expect(entry["rungs"] as? [String] == ["read", "suggest", "write_new", "edit"])
            #expect(entry["duration"] as? String == "always")
            #expect(entry["notes"] as? Int == 0 && entry["books"] as? Int == 0 && entry["gatherings"] as? Int == 0)
            let home = try #require(found.first)
            #expect(home["name"] as? String == "Home" && home["rungs"] as? [String] == ["read"])
            #expect(home["notes"] as? Int == 1 && home["books"] as? Int == 1)

            let made = try await call(connection, "create_book",
                                      ["name": .string("first book"), "wing_id": .string(planet.id)])
            #expect(made.isError != true, "\(text(made))")
            let bookID = try #require(try json(made)["book_id"] as? String)
            let listed = try json(try await call(connection, "list_books"))["books"] as? [[String: Any]] ?? []
            #expect(listed.contains { $0["id"] as? String == bookID && $0["wing_id"] as? String == planet.id })
            let after = try await wings(connection)
            #expect(after.last?["books"] as? Int == 1, "the count follows what the wing now holds")
            await h.hangUp(connection)
        }
    }

    // MARK: - No oracle: only the client's own wing grants

    /// A wing reached only through a book or a note grant inside it, a wing
    /// with no grant, a gone wing, and the open book alone are all absent —
    /// and with no wing grant the tool is not listed (P-2); called anyway, it
    /// answers an empty list (the list is a courtesy, the rule the boundary).
    @Test func onlyTheClientsOwnWingGrantsAreListed() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let granted = try h.operations.createWing(name: "granted")
            let byBook = try h.operations.createWing(name: "by book")
            let byNote = try h.operations.createWing(name: "by note")
            _ = try h.operations.createWing(name: "nothing")
            let doomed = try h.operations.createWing(name: "doomed")
            let book = try h.operations.createReading(name: "inside", kind: .book, wingId: byBook.id)
            let note = try h.operations.createPost(title: "a note", wingId: byNote.id)
            _ = try h.operations.newBlock(in: note.id, text: "w", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .book, book.id))
            let client = try h.client("claude-code").id
            _ = try h.operations.grantMCPAccess(client, spec(.read, .note, note.id))
            try h.operations.setMCPSwitch(.openBook, on: true)

            var names = Set(try await connection.client.listTools().tools.map(\.name))
            #expect(!names.contains("list_wings"), "no wing grant, no discovery door — not even under the open book")
            #expect(try await wings(connection).isEmpty, "called anyway: nothing, never a wing it holds no grant on")

            _ = try h.operations.grantMCPAccess(client, spec(.suggest, .wing, granted.id, .connection))
            let doomedGrant = try h.operations.grantMCPAccess(client, spec(.read, .wing, doomed.id))
            try h.operations.deleteWing(doomed.id)
            names = Set(try await connection.client.listTools().tools.map(\.name))
            #expect(names.contains("list_wings"))
            let found = try await wings(connection)
            #expect(found.map { $0["wing_id"] as? String } == [granted.id], "only the granted wing — never by book, by note, ungranted or gone")
            #expect(found.first?["duration"] as? String == "until_disconnect")
            #expect(found.first?["rungs"] as? [String] == ["read", "suggest"])

            try h.operations.revokeMCPGrant(doomedGrant)
            let revoked = try await wings(connection)
            #expect(revoked.count == 1)
            await h.hangUp(connection)
        }
    }

    // MARK: - The counts are what the listings list

    /// The wing's notes, books and gatherings counted EXACTLY as
    /// `list_notes(wing_id:)` and `list_books` would list them: a Private note
    /// or book never counts (it never lists — counting it would disclose it),
    /// nor does anything archived (the resting posture).
    @Test func theCountsAreWhatTheListingsList() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let wing = try h.operations.createWing(name: "studio")
            let tag = try h.operations.createTag(name: "parser", wingID: wing.id)
            for title in ["lexer", "grammar"] {
                let note = try h.operations.createPost(title: title, wingId: wing.id)
                _ = try h.operations.newBlock(in: note.id, text: title, registeringUndo: false)
                try h.operations.applyTag(tag.id, toPost: note.id)
            }
            let secret = try h.operations.createPost(title: "secret", wingId: wing.id)
            _ = try h.operations.newBlock(in: secret.id, text: "marshlantern", registeringUndo: false)
            _ = try h.operations.setNotePrivate(secret.id, true)
            let old = try h.operations.createPost(title: "old", wingId: wing.id)
            _ = try h.operations.newBlock(in: old.id, text: "old", registeringUndo: false)
            try h.operations.archiveContainer(old.id)
            _ = try h.operations.createReading(name: "launch", kind: .book, wingId: wing.id)
            let privateBook = try h.operations.createReading(name: "hidden", kind: .book, wingId: wing.id)
            _ = try h.operations.setBookPrivate(privateBook.id, true)
            let shelved = try h.operations.createReading(name: "shelved", kind: .book, wingId: wing.id)
            try h.operations.archiveReading(shelved.id)
            _ = try h.operations.createReading(
                name: "parser things", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)),
                wingId: wing.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .wing, wing.id))

            let entry = try #require(try await wings(connection).first)
            let notes = try json(try await call(connection, "list_notes", ["wing_id": .string(wing.id)]))["notes"]
                as? [[String: Any]] ?? []
            let readings = (try json(try await call(connection, "list_books"))["books"] as? [[String: Any]] ?? [])
                .filter { $0["wing_id"] as? String == wing.id }
            #expect(entry["notes"] as? Int == 2 && notes.count == 2, "the two plain notes: never the Private or archived one")
            #expect(entry["books"] as? Int == 1 && readings.filter { $0["kind"] as? String == "book" }.count == 1)
            #expect(entry["gatherings"] as? Int == 1 && readings.filter { $0["kind"] as? String == "gathering" }.count == 1)
            await h.hangUp(connection)
        }
    }

    // MARK: - A once wing grant (P-VX392-2)

    /// A once grant on a wing is a grant the client holds — so it is listed
    /// (unlisted, it could never be used: the wing's id is the one thing an
    /// empty wing cannot give), and a listing spends nothing; the first write
    /// in the wing spends it, as ever (AF-7).
    @Test func aOnceWingGrantIsListedAndTheListingSpendsNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let wing = try h.operations.createWing(name: "empty")
            let connection = try await h.connect(as: "claude-code")
            let once = try #require(try h.approve("claude-code", spec(.writeNew, .wing, wing.id, .once)))
            let entry = try #require(try await wings(connection).first)
            #expect(entry["wing_id"] as? String == wing.id && entry["duration"] as? String == "once")
            #expect(entry["rungs"] as? [String] == ["read", "suggest", "write_new"])
            #expect(try consumedAt(h, once) == nil, "a listing never spends a once grant")
            let made = try await call(connection, "create_book", ["name": .string("b"), "wing_id": .string(wing.id)])
            #expect(made.isError != true, "\(text(made))")
            #expect(try consumedAt(h, once) != nil, "the first write spends it")
            #expect(try await wings(connection).isEmpty, "spent, it is no longer held")
            await h.hangUp(connection)
        }
    }

    // MARK: - The neighbouring roads (the report's "also check" — guards)

    /// The report's "an empty book granted on its own": `list_books` lists it
    /// (its id and wing are what a write there needs). A guard — green on the
    /// tree before VX-392 too (recorded: this half of the ticket is hollow).
    @Test func anEmptyBookGrantedAloneIsListed() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let wing = try h.operations.createWing(name: "studio")
            let book = try h.operations.createReading(name: "empty", kind: .book, wingId: wing.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, book.id))
            let listed = try json(try await call(connection, "list_books"))["books"] as? [[String: Any]] ?? []
            #expect(listed.count == 1)
            #expect(listed.first?["id"] as? String == book.id && listed.first?["wing_id"] as? String == wing.id)
            #expect(listed.first?["notes"] as? Int == 0)
            let made = try await call(connection, "create_note",
                                      ["title": .string("first"), "text": .string("w"), "book_id": .string(book.id)])
            #expect(made.isError != true, "\(text(made))")
            await h.hangUp(connection)
        }
    }

    /// The report's "a wing with gatherings but no books": `list_books` lists
    /// the gathering (kind gathering) with the wing's id, and `list_wings`
    /// counts it. A guard for the `list_books` half (green before VX-392).
    @Test func aWingWithOnlyAGatheringIsReadThroughBothListings() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let wing = try h.operations.createWing(name: "gathered")
            let tag = try h.operations.createTag(name: "idea", wingID: wing.id)
            let gathering = try h.operations.createReading(
                name: "ideas", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)), wingId: wing.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, wing.id))
            let listed = try json(try await call(connection, "list_books"))["books"] as? [[String: Any]] ?? []
            #expect(listed.map { $0["id"] as? String } == [gathering.id])
            #expect(listed.first?["kind"] as? String == "gathering" && listed.first?["wing_id"] as? String == wing.id)
            let entry = try #require(try await wings(connection).first)
            #expect(entry["books"] as? Int == 0 && entry["gatherings"] as? Int == 1 && entry["notes"] as? Int == 0)
            await h.hangUp(connection)
        }
    }

    /// Her framing — "even when there's a whole wing grant, claude can't see it
    /// or write in it" — proven for a wing that HOLDS things, with no Home
    /// grant at all: the wing's notes and books surface in every listing, and
    /// each rung writes exactly what it should there. A guard (green before
    /// VX-392: the non-empty road worked; the empty wing was the gap).
    @Test func aWingGrantSurfacesItsNotesAndBooksAndWritesAtTheRightRungs() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let wing = try h.operations.createWing(name: "PlanetLillian")
            let book = try h.operations.createReading(name: "essays", kind: .book, wingId: wing.id)
            let note = try h.operations.createPost(title: "draft", wingId: wing.id)
            let block = try h.operations.newBlock(in: note.id, text: "first words", registeringUndo: false)
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            let connection = try await h.connect(as: "claude-code")
            let read = try #require(try h.approve("claude-code", spec(.read, .wing, wing.id)))
            let client = try h.client("claude-code").id

            let shared = try json(try await call(connection, "list_notes"))["notes"] as? [[String: Any]] ?? []
            #expect(shared.map { $0["id"] as? String } == [note.id] && shared.first?["wing_id"] as? String == wing.id)
            let inWing = try json(try await call(connection, "list_notes", ["wing_id": .string(wing.id)]))["notes"]
                as? [[String: Any]] ?? []
            #expect(inWing.map { $0["id"] as? String } == [note.id])
            let books = try json(try await call(connection, "list_books"))["books"] as? [[String: Any]] ?? []
            #expect(books.map { $0["id"] as? String } == [book.id] && books.first?["notes"] as? Int == 1)
            let found = try await call(connection, "search", ["query": .string("first")])
            #expect((try json(found)["passages"] as? [[String: Any]] ?? []).count == 1)

            // read: no write lands.
            let refused = try await call(connection, "create_note",
                                         ["title": .string("x"), "text": .string("y"), "wing_id": .string(wing.id)])
            #expect(refused.isError == true && text(refused).hasPrefix(MCPRefusalCopy.words(.rungTooLow(granted: .read), .wing)))

            // write new: a note and a book land in the wing.
            _ = try h.operations.grantMCPAccess(client, spec(.writeNew, .wing, wing.id), replacing: [read])
            let madeNote = try await call(connection, "create_note",
                                          ["title": .string("x"), "text": .string("y"), "wing_id": .string(wing.id)])
            #expect(madeNote.isError != true, "\(text(madeNote))")
            let madeBook = try await call(connection, "create_book", ["name": .string("more"), "wing_id": .string(wing.id)])
            #expect(madeBook.isError != true, "\(text(madeBook))")
            // …but not an edit of her words.
            let notYet = try await call(connection, "edit_take", [
                "take_id": .string(block.variant.id), "text": .string("rewritten"),
                "expected_text": .string("first words")])
            #expect(notYet.isError == true)

            // edit: her words, rewritten.
            let writeNew = try #require(try liveGrantID(h, client))
            _ = try h.operations.grantMCPAccess(client, spec(.edit, .wing, wing.id), replacing: [writeNew])
            let edited = try await call(connection, "edit_take", [
                "take_id": .string(block.variant.id), "text": .string("rewritten"),
                "expected_text": .string("first words")])
            #expect(edited.isError != true, "\(text(edited))")
            await h.hangUp(connection)
        }
    }

    // MARK: - The AI's docs (R-VX348-5: "the create_book / create_note docs point at it")

    /// Every tool that takes a `wing_id` says where one comes from — the
    /// report's "update the create_book / create_note docs to say where
    /// wing_id comes from" — in its description or the input's own words.
    @Test func everyToolThatTakesAWingIDSaysWhereItComesFrom() throws {
        var taking: [String] = []
        for declaration in MCPToolCatalog.all where declaration.name != "list_wings" {
            let properties = declaration.inputSchema.objectValue?["properties"]?.objectValue ?? [:]
            guard let wing = properties["wing_id"] else { continue }
            taking.append(declaration.name)
            let said = declaration.description + (wing.objectValue?["description"]?.stringValue ?? "")
            #expect(said.contains("list_wings"), "\(declaration.name) takes a wing_id and must point at list_wings")
        }
        #expect(Set(taking) == ["list_notes", "create_note", "import_document", "create_book", "move_note_to_wing",
                                "show_in_app"], "the tools that take a wing_id: \(taking)")
        #expect(MCPToolCatalog.listWings.rung == .read && MCPToolCatalog.listWings.scopes == [.wing])
        #expect(MCPToolCatalog.listWings.grantOnly && !MCPToolCatalog.listWings.listedWhenApproved)
    }
}
