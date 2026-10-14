import Dependencies
import Foundation
import GRDB
import MCP
import System
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// 13n-b U1 P6 — THE SERVER END TO END: a real `MCPServerHost` bound on a real
// socket in a temp directory, driven by the MCP SDK's own `Client` over that
// socket (the framing the shim forwards verbatim). These are the verification
// bar's READ half, pinned PER TOOL: reads never exceed the grant; journals
// never ride a standing grant; a once grant is spent once; while-connected
// ends with the connection; revocation and denial are immediate; a pending
// client reads nothing and sees no tools.

/// One live server over an in-memory store, with deterministic ids and clock.
final class ServerHarness: @unchecked Sendable {
    /// U4: the harness world's "now" (the core harness's `harnessNow`).
    static let worldNow = Date(timeIntervalSince1970: 1_782_864_000 + 3_600)
    let database: AppDatabase
    let operations: Operations
    /// U2: the session's undo stack, as the app's runner holds it — the
    /// write tools register on it through `writeOperations`.
    let undoStack = UndoStack()
    let writeOperations: Operations
    let directory: URL
    let host: MCPServerHost
    /// U2: what the app would have been told (AF-6's asks; the receipts).
    let asks = LockIsolated<[MCPAsk]>([])
    let receipts = LockIsolated<[MCPWriteReceipt]>([])

    init() throws {
        let database = try AppDatabase.inMemory()
        self.database = database
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        let stack = undoStack
        (operations, writeOperations) = withDependencies {
            $0.database = database
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
        } operation: { (Operations(), Operations(undoStack: stack)) }
        directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("vmcp-\(UUID().uuidString.prefix(8))", isDirectory: true)
        host = MCPServerHost(
            database: database, operations: operations, directory: directory, version: "test",
            executor: SeededExecutor(operations: writeOperations))
        let asks = self.asks
        let receipts = self.receipts
        host.hooks = MCPHostHooks(
            refusalWords: { error in "Refused: \(error)" },
            onAsk: { ask in asks.withValue { $0.append(ask) } },
            onWrite: { receipt in receipts.withValue { $0.append(receipt) } },
            // U4: the tray's 30-day window reads the WORLD's clock (fixtures
            // are stamped from 2026-07-01, an hour in).
            now: { ServerHarness.worldNow })
        try host.start()
    }

    /// Fixture writes read the position jitter's RNG from the CALLER's
    /// context (`FractionalIndex`), so a test body runs inside this scope —
    /// it sets only the RNG; the captured `Operations` keeps its own ids and
    /// clock.
    func within<T>(_ body: () async throws -> T) async throws -> T {
        try await withDependencies {
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SystemRandomNumberGenerator())
        } operation: {
            try await body()
        }
    }

    /// VX-132: stopping the host hangs up every session, and each client the
    /// harness made then ENDS ITSELF (`HarnessTransport` — its stream drained,
    /// it disconnects and closes its own socket). No client is left spinning
    /// and no descriptor is closed under a reader that could reuse its number.
    func tearDown() {
        host.stop()
        try? FileManager.default.removeItem(at: directory)
    }

    /// VX-168: each name's own setup key — minted ONCE per name, exactly as
    /// a Copy setup command would, and presented by every `connect(as:)`.
    private let setupKeys = LockIsolated<[String: String]>([:])

    /// The setup key `name` connects with (minted on first use).
    /// VX-258 (A JUSTIFIED EDIT, the ritual): a name's own key is copied FOR
    /// it — the setup she copies from that client's own tab — so the name
    /// takes it with zero clicks whether it is new, bound or approved and
    /// unbound, exactly as every pin written before VX-258 assumed. A test
    /// about an "Any MCP client" copy mints its own untagged key.
    func setupKey(for name: String) throws -> String {
        if let key = setupKeys.value[name] { return key }
        let key = try operations.mintMCPSetupKey(copiedFor: MCPSetupKeyRule.canCarry(name) ? name : nil)
        setupKeys.withValue { $0[name] = key }
        return key
    }

    /// A client connected over the socket and initialized as `name`,
    /// presenting its OWN setup key (VX-168 — what a shim run from the
    /// pane's setup does).
    func connect(as name: String) async throws -> HarnessConnection {
        try await connect(as: name, presenting: try setupKey(for: name))
    }

    /// The same, presenting `key` as the shim's preamble — nil = a BARE shim.
    /// VX-132: through the bounded client — the connect fails NAMED past its
    /// limit, and a connect that fails leaves no client behind.
    func connect(as name: String, presenting key: String?) async throws -> HarnessConnection {
        guard case .success(let fd) = MCPSocketRoad.connect(directory: directory) else {
            throw HarnessFailure("could not connect")
        }
        if let key { _ = MCPShim.writeAll(fd, MCPPreamble.line(key: key)) }
        let transport = HarnessTransport(fd: fd)
        let sdk = Client(name: name, version: "1.0")
        await transport.onDrained { await sdk.disconnect() }
        do {
            let initialized = try await HarnessDeadline.run(
                "connect(as: \(name))", onTimeout: { Task { await transport.end() } }
            ) {
                try await sdk.connect(transport: transport)
            }
            return (HarnessClient(sdk: sdk, transport: transport, initialized: initialized), fd)
        } catch {
            Task { await sdk.disconnect() }
            throw error
        }
    }

    /// VX-168: a RAW opening — the preamble when `key` is given, then an
    /// `initialize` naming `name` with request id `id` — and the server's
    /// first answer as JSON. The caller closes the descriptor. VX-132: the
    /// read is bounded by the harness's limit (an answer that never comes
    /// fails "no JSON answer", never a stalled run).
    func rawOpen(as name: String, presenting key: String?, id: Int = 1) throws -> (fd: Int32, answer: [String: Any]) {
        guard case .success(let fd) = MCPSocketRoad.connect(directory: directory) else {
            throw HarnessFailure("could not connect as \(name)")
        }
        var timeout = timeval(tv_sec: Int(HarnessDeadline.seconds.rounded(.up)), tv_usec: 0)
        _ = setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
        if let key { _ = MCPShim.writeAll(fd, MCPPreamble.line(key: key)) }
        let line = """
            {"jsonrpc":"2.0","id":\(id),"method":"initialize","params":{"protocolVersion":"2025-06-18",\
            "capabilities":{},"clientInfo":{"name":"\(name)","version":"1"}}}
            """
        _ = MCPShim.writeAll(fd, Data((line + "\n").utf8))
        let answer = MCPShim.readFirstLine(fd, limit: 1 << 20)
        guard let object = try JSONSerialization.jsonObject(with: answer) as? [String: Any] else {
            close(fd)
            throw HarnessFailure("\(name) got no JSON answer")
        }
        return (fd, object)
    }

    /// The client hangs up — VX-132: its transport closes the socket once the
    /// SDK is done reading it (the harness never touches the number after).
    func hangUp(_ connection: HarnessConnection) async {
        await connection.client.disconnect()
    }

    func client(_ name: String) throws -> MCPClient {
        guard let client = try database.read({ try Queries.mcpClient($0, name: name) }) else {
            throw HarnessFailure("no client row for \(name)")
        }
        return client
    }

    func approve(_ name: String, _ spec: Operations.MCPGrantSpec?) throws -> String? {
        try operations.approveMCPClient(try client(name).id, granting: spec)
    }

    /// Wait (bounded) until `condition` holds.
    func eventually(_ condition: () throws -> Bool) async throws -> Bool {
        for _ in 0..<200 {
            if try condition() { return true }
            try await Task.sleep(for: .milliseconds(10))
        }
        return try condition()
    }
}

/// The write executor of the harness: `MCPSerialExecutor`'s shape, with the
/// position jitter's RNG scoped (a body on an actor inherits no test
/// dependencies; production reads the live RNG, as every write does).
actor SeededExecutor: MCPWriteExecutor {
    private let operations: Operations
    init(operations: Operations) { self.operations = operations }
    func run<T: Sendable>(_ body: @Sendable (Operations) throws -> T) throws -> T {
        try withDependencies {
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SystemRandomNumberGenerator())
        } operation: {
            try body(operations)
        }
    }
}

struct HarnessFailure: Error, CustomStringConvertible {
    let description: String
    init(_ description: String) { self.description = description }
}

func text(_ result: (content: [Tool.Content], isError: Bool?)) -> String {
    result.content.compactMap { content -> String? in
        if case .text(let text, _, _) = content { return text }
        return nil
    }.joined()
}

func json(_ result: (content: [Tool.Content], isError: Bool?)) throws -> [String: Any] {
    try #require(try JSONSerialization.jsonObject(with: Data(text(result).utf8)) as? [String: Any])
}

private func book(_ spec: String, _ duration: MCPGrantRule.Duration = .always) -> Operations.MCPGrantSpec {
    .init(rung: .read, scopeKind: .book, scopeID: spec, duration: duration)
}

@Suite("13n-b U1 — the MCP server end to end (the read rung)", .serialized)
struct MCPServerTests {
    // MARK: - The catalog (P-1 on the wire)

    @Test func everyDeclaredToolIsHandledAndEveryHandledToolDeclared() {
        // U2 (justified edit): the catalog grows the suggest and write-new
        // rungs; the walk now reads BOTH handlers. U3 (justified edit, the
        // ritual): the EDIT rung is served now, so it is declared — and
        // write new gains create_section (R-13nb-11 G-1).
        let declared = Set(MCPToolCatalog.all.map(\.name))
        // U4 (justified edit, the ritual): show_in_app is the THIRD handler
        // (it awaits the app's delivery — AF-11 F-3), read rung.
        #expect(declared == MCPReadTools.handledToolNames.union(MCPWriteTools.handledToolNames)
            .union(MCPShowTool.handledToolNames))
        #expect(MCPReadTools.handledToolNames.isDisjoint(with: MCPWriteTools.handledToolNames))
        #expect(MCPShowTool.handledToolNames.isDisjoint(with: MCPReadTools.handledToolNames.union(MCPWriteTools.handledToolNames)))
        #expect(MCPToolCatalog.navigation.map(\.name) == ["show_in_app"])
        #expect(MCPToolCatalog.navigation.allSatisfy { $0.rung == .read })
        #expect(Set(MCPToolCatalog.read.map(\.name)) == ["list_books", "list_notes", "read_note", "search", "export_note"])
        // VX-184 U3 (justified edit, the ritual): suggest gains VX-173's batch
        // doors, add_takes and add_comments, and VX-188's delete_comment.
        #expect(Set(MCPToolCatalog.suggest.map(\.name))
                == ["add_take", "add_comment", "save_lens", "add_takes", "add_comments", "delete_comment"])
        // U4 (justified edit, the ritual): the carriage's write tools join
        // write new (save_version, file_note_in_chapter, set_book_rule) and
        // edit (put_back, set_entry_date).
        // VX-184 U3 (justified edit, the ritual): write new gains VX-187's
        // link_versions.
        // VX-336 U5b (justified edit, the ritual): write new gains VX-255's
        // insert_blocks (the call's rung read from its arguments — an anchor
        // or the start is edit).
        // VX-336 U6a (justified edit, the ritual): write new gains VX-311's
        // duplicate_note (read on the note, write new on its wing).
        #expect(Set(MCPToolCatalog.writeNew.map(\.name))
                == ["create_note", "import_document", "apply_tag", "create_book", "add_note_to_book", "create_section",
                    "save_version", "file_note_in_chapter", "set_book_rule", "link_versions", "insert_blocks",
                    "duplicate_note"])
        // 13n-c U6 (justified edit, the ritual): edit gains the per-item
        // note move across wings (VX-160). VX-168 U2 (justified
        // edit, the ritual): and the deliberate acts — VX-169's save_commit,
        // VX-174's choose_take and adopt_lens (R-MERGE-1).
        // VX-184 U3 (justified edit, the ritual): edit gains VX-190's remove_tag.
        // VX-184 U4 (justified edit, the ritual): edit gains VX-195's edit
        // parity inside a note (R-VX184-1) — the comments family.
        #expect(Set(MCPToolCatalog.edit.map(\.name))
                == ["edit_take", "divide_block", "merge_blocks", "move_block", "delete_block", "set_block_name",
                    "put_back", "set_entry_date", "move_note_to_wing", "save_commit", "choose_take", "adopt_lens",
                    "remove_tag",
                    "edit_comment", "restore_comment",
                    "delete_take", "archive_take", "unarchive_take", "set_take_label", "lock_take", "unlock_take",
                    "restore_commit", "rename_commit", "rename_note", "delete_lens",
                    // VX-184 U5 (justified edit, the ritual): edit gains VX-196's
                    // edit parity across the library (R-VX184-1) — the book's state.
                    "rename_book", "finish_book", "reopen_book", "archive_book", "unarchive_book", "delete_book",
                    // …and a book's membership and order, and its chapters.
                    "remove_note_from_book", "move_note_in_book", "rename_chapter", "delete_chapter",
                    "move_chapter",
                    // …and a note in the library.
                    "delete_note", "archive_note", "unarchive_note"])
        #expect(MCPToolCatalog.read.allSatisfy { $0.rung == .read })
        #expect(MCPToolCatalog.suggest.allSatisfy { $0.rung == .suggest })
        #expect(MCPToolCatalog.writeNew.allSatisfy { $0.rung == .writeNew })
        #expect(MCPToolCatalog.edit.allSatisfy { $0.rung == .edit })
        for declaration in MCPToolCatalog.all {
            #expect(declaration.inputSchema.objectValue?["type"] == "object")
        }
    }

    // MARK: - A new client: a pending request, nothing readable

    @Test func aNewClientIsAPendingRequestThatSeesNoToolsAndReadsNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "ch 7")
            _ = try h.operations.newBlock(in: note.id, text: "secret words")
            let connection = try await h.connect(as: "claude-code")
            #expect(try h.client("claude-code").state == .pending)
            #expect(try await connection.client.listTools().tools.isEmpty, "no door that can never act (P-2)")
            let refused = try await connection.client.callTool(name: "read_note", arguments: ["note_id": .string(note.id)])
            #expect(refused.isError == true)
            #expect(text(refused).contains("connection request is waiting"))
            #expect(!text(refused).contains("secret"))
            let activity = try await h.database.read { try Queries.mcpActivity($0, limit: 1) }
            #expect(activity.first?.act == "read_note" && activity.first?.allowed == false)
            await h.hangUp(connection)
        }
    }

    // MARK: - A book grant: reads the book, refused past it

    @Test func aBookGrantReadsTheBookAndIsRefusedPastIt() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let shared = try h.operations.createReading(name: "the lightning thief", kind: .book)
            let other = try h.operations.createReading(name: "private drafts", kind: .book)
            let inside = try h.operations.createPost(title: "ch 7")
            _ = try h.operations.newBlock(in: inside.id, text: "Honestly, I never asked for the observatory.")
            _ = try h.operations.addPostToReading(inside.id, to: shared.id)
            let outside = try h.operations.createPost(title: "drafts")
            _ = try h.operations.newBlock(in: outside.id, text: "never for the client")
            _ = try h.operations.addPostToReading(outside.id, to: other.id)
            let bookless = try h.operations.createPost(title: "pool note")
            _ = try h.operations.newBlock(in: bookless.id, text: "also never")

            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", book(shared.id))

            let names = Set(try await connection.client.listTools().tools.map(\.name))
            // U4 (justified edit, the ritual): the read rung gains show_in_app.
            #expect(names == ["list_books", "list_notes", "read_note", "search", "export_note", "show_in_app"])

            let books = try json(try await connection.client.callTool(name: "list_books"))["books"] as? [[String: Any]]
            #expect(books?.map { $0["id"] as? String } == [shared.id], "only the shared book is listed")
            #expect(books?.first?["notes"] as? Int == 1)

            let listed = try json(try await connection.client.callTool(name: "list_notes"))["notes"] as? [[String: Any]]
            #expect(listed?.map { $0["id"] as? String } == [inside.id])
            let inBook = try json(try await connection.client.callTool(
                name: "list_notes", arguments: ["book_id": .string(shared.id)]))["notes"] as? [[String: Any]]
            #expect(inBook?.map { $0["id"] as? String } == [inside.id])

            let read = try await connection.client.callTool(name: "read_note", arguments: ["note_id": .string(inside.id)])
            #expect(read.isError != true)
            let document = try await h.database.read { try Queries.variorumDocumentText($0, postID: inside.id) }
            #expect(text(read) == document, "read_note IS the Level 0 format")
            let exported = try await connection.client.callTool(name: "export_note", arguments: ["note_id": .string(inside.id)])
            let rendered = try await h.database.read { try Queries.renderedText($0, containerID: inside.id) }
            #expect(text(exported) == rendered)

            // REFUSED PAST IT — every road, one answer, no words leaked.
            for noteID in [outside.id, bookless.id, "no-such-note"] {
                for tool in ["read_note", "export_note"] {
                    let refused = try await connection.client.callTool(name: tool, arguments: ["note_id": .string(noteID)])
                    #expect(refused.isError == true, "\(tool) \(noteID)")
                    #expect(text(refused).hasPrefix("That note isn't shared with this client"))
                    #expect(!text(refused).contains("never"))
                }
            }
            let refusedBook = try await connection.client.callTool(
                name: "list_notes", arguments: ["book_id": .string(other.id)])
            #expect(refusedBook.isError == true)
            #expect(text(refusedBook).hasPrefix("That book isn't shared with this client"))
            let refusedWing = try await connection.client.callTool(name: "list_notes", arguments: ["wing_id": ""])
            #expect(refusedWing.isError == true, "a book grant never lists the whole wing")
            await h.hangUp(connection)
        }
    }

    // MARK: - Journals never ride a standing grant

    @Test func journalsNeverRideAStandingGrantOrTheOpenBook() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let shared = try h.operations.createReading(name: "mixed", kind: .book)
            let prose = try h.operations.createPost(title: "prose")
            _ = try h.operations.newBlock(in: prose.id, text: "lighthouse prose")
            let entry = try h.operations.createPost(title: "morning pages", profile: .journal)
            _ = try h.operations.newBlock(in: entry.id, text: "lighthouse diary")
            _ = try h.operations.addPostToReading(prose.id, to: shared.id)
            _ = try h.operations.addPostToReading(entry.id, to: shared.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", book(shared.id))
            _ = try h.operations.grantMCPAccess(
                try h.client("claude-code").id, .init(rung: .read, scopeKind: .wing, scopeID: "", duration: .always))
            try h.operations.setMCPSwitch(.openBook, on: true)

            for args: [String: Value] in [[:], ["book_id": .string(shared.id)], ["wing_id": ""]] {
                let notes = try json(try await connection.client.callTool(name: "list_notes", arguments: args))["notes"] as? [[String: Any]]
                #expect(notes?.compactMap { $0["id"] as? String }.contains(entry.id) == false, "\(args)")
                #expect(notes?.compactMap { $0["id"] as? String }.contains(prose.id) == true, "\(args)")
            }
            let refused = try await connection.client.callTool(name: "read_note", arguments: ["note_id": .string(entry.id)])
            #expect(refused.isError == true)
            // 13n-c U1 (justified edit, the ritual — T-2, AppSpec §12's "no
            // fenced-vs-unshared oracle anywhere"): the entry answers exactly
            // as an id that names nothing — it no longer says "journal entry".
            let nothing = try await connection.client.callTool(name: "read_note", arguments: ["note_id": "nope"])
            #expect(text(refused) == text(nothing), "a fenced note answers as nothing")
            let found = try json(try await connection.client.callTool(name: "search", arguments: ["query": "lighthouse"]))
            let noteIDs = (found["passages"] as? [[String: Any]])?.compactMap { $0["note_id"] as? String } ?? []
            #expect(noteIDs.contains(prose.id))
            #expect(!noteIDs.contains(entry.id), "search never surfaces a journal under a standing grant")

            // A per-ask grant naming the entry reaches it (once).
            _ = try h.operations.grantMCPAccess(
                try h.client("claude-code").id, .init(rung: .read, scopeKind: .note, scopeID: entry.id, duration: .once))
            let once = try await connection.client.callTool(name: "read_note", arguments: ["note_id": .string(entry.id)])
            #expect(once.isError != true)
            #expect(text(once).contains("lighthouse diary"))
            let again = try await connection.client.callTool(name: "read_note", arguments: ["note_id": .string(entry.id)])
            #expect(again.isError == true, "the once grant is spent")
            await h.hangUp(connection)
        }
    }

    // MARK: - A note grant, a wing grant, search's scope

    @Test func aNoteGrantListsAndSearchesOnlyThatNote() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let mine = try h.operations.createPost(title: "shared one")
            _ = try h.operations.newBlock(in: mine.id, text: "the harbour at dawn")
            let theirs = try h.operations.createPost(title: "not shared")
            _ = try h.operations.newBlock(in: theirs.id, text: "the harbour at dusk")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", .init(rung: .read, scopeKind: .note, scopeID: mine.id, duration: .always))
            let names = Set(try await connection.client.listTools().tools.map(\.name))
            #expect(!names.contains("list_books"), "a note grant can never list a book — the tool is not offered")
            #expect(names.contains("read_note"))
            let listed = try json(try await connection.client.callTool(name: "list_notes"))["notes"] as? [[String: Any]]
            #expect(listed?.map { $0["id"] as? String } == [mine.id])
            let found = try json(try await connection.client.callTool(name: "search", arguments: ["query": "harbour"]))
            let ids = (found["passages"] as? [[String: Any]])?.compactMap { $0["note_id"] as? String } ?? []
            #expect(ids == [mine.id])
            let narrowed = try await connection.client.callTool(
                name: "search", arguments: ["query": "harbour", "note_id": .string(theirs.id)])
            #expect(narrowed.isError == true)
            await h.hangUp(connection)
        }
    }

    @Test func aWingGrantReachesItsWingOnly() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let work = try h.operations.createWing(name: "Work")
            let homeNote = try h.operations.createPost(title: "home")
            _ = try h.operations.newBlock(in: homeNote.id, text: "kettle")
            let workNote = try h.operations.createPost(title: "work", wingId: work.id)
            _ = try h.operations.newBlock(in: workNote.id, text: "kettle")
            let workBook = try h.operations.createReading(name: "reports", kind: .book, wingId: work.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", .init(rung: .read, scopeKind: .wing, scopeID: work.id, duration: .always))
            let books = try json(try await connection.client.callTool(name: "list_books"))["books"] as? [[String: Any]]
            #expect(books?.map { $0["id"] as? String } == [workBook.id])
            let listed = try json(try await connection.client.callTool(
                name: "list_notes", arguments: ["wing_id": .string(work.id)]))["notes"] as? [[String: Any]]
            #expect(listed?.map { $0["id"] as? String } == [workNote.id])
            let home = try await connection.client.callTool(name: "list_notes", arguments: ["wing_id": ""])
            #expect(home.isError == true)
            let found = try json(try await connection.client.callTool(name: "search", arguments: ["query": "kettle"]))
            let ids = (found["passages"] as? [[String: Any]])?.compactMap { $0["note_id"] as? String } ?? []
            #expect(ids == [workNote.id])
            let homeRead = try await connection.client.callTool(name: "read_note", arguments: ["note_id": .string(homeNote.id)])
            #expect(homeRead.isError == true)
            await h.hangUp(connection)
        }
    }

    // MARK: - Immediacy: revoke, deny, while connected, the tool list

    @Test func revocationAndDenialLandOnTheVeryNextCall() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let shared = try h.operations.createReading(name: "b", kind: .book)
            let note = try h.operations.createPost(title: "n")
            _ = try h.operations.addPostToReading(note.id, to: shared.id)
            let connection = try await h.connect(as: "claude-code")
            let grantID = try #require(try h.approve("claude-code", book(shared.id)))
            #expect(try await connection.client.callTool(name: "read_note", arguments: ["note_id": .string(note.id)]).isError != true)
            try h.operations.revokeMCPGrant(grantID)
            #expect(try await connection.client.callTool(name: "read_note", arguments: ["note_id": .string(note.id)]).isError == true)
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, book(shared.id))
            #expect(try await connection.client.callTool(name: "read_note", arguments: ["note_id": .string(note.id)]).isError != true)
            try h.operations.denyMCPClient(try h.client("claude-code").id)
            let denied = try await connection.client.callTool(name: "read_note", arguments: ["note_id": .string(note.id)])
            #expect(denied.isError == true)
            #expect(text(denied).contains("denied"))
            #expect(try await connection.client.listTools().tools.isEmpty)
            await h.hangUp(connection)
        }
    }

    @Test func whileConnectedEndsWhenTheClientsLastConnectionCloses() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let shared = try h.operations.createReading(name: "b", kind: .book)
            let first = try await h.connect(as: "claude-code")
            let second = try await h.connect(as: "claude-code")
            let grantID = try #require(try h.approve("claude-code", book(shared.id, .connection)))
            func revoked() throws -> Bool {
                try h.database.read { try Queries.mcpGrant($0, id: grantID) }?.revokedAt != nil
            }
            await h.hangUp(first)
            try await Task.sleep(for: .milliseconds(200))
            #expect(try revoked() == false, "another connection of the same client is still open")
            await h.hangUp(second)
            #expect(try await h.eventually { try revoked() }, "the last connection closed — while connected ends")
        }
    }

    @Test func theToolListIsReannouncedWhenTheGrantsChange() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let shared = try h.operations.createReading(name: "b", kind: .book)
            let connection = try await h.connect(as: "claude-code")
            let heard = LockIsolated(0)
            _ = await connection.client.onNotification(ToolListChangedNotification.self) { _ in
                heard.withValue { $0 += 1 }
            }
            _ = try h.approve("claude-code", book(shared.id))
            #expect(try await h.eventually { heard.value > 0 }, "tools/list_changed after the grant")
            #expect(!(try await connection.client.listTools().tools.isEmpty))
            await h.hangUp(connection)
        }
    }

    // MARK: - Round 1 F5: a cursor carries its listing's shape

    @Test func aCursorMintedUnderOneListingOrderIsRefusedByAnother() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let shared = try h.operations.createReading(name: "b", kind: .book)
            for index in 0..<3 {
                let note = try h.operations.createPost(title: "n\(index)")
                _ = try h.operations.addPostToReading(note.id, to: shared.id)
            }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", book(shared.id))
            try h.operations.setMCPSwitch(.openBook, on: true)

            let first = try json(try await connection.client.callTool(
                name: "list_notes", arguments: ["book_id": .string(shared.id), "limit": 1]))
            let cursor = try #require(first["next_cursor"] as? String)
            // The same cursor resumes ITS OWN listing…
            let second = try await connection.client.callTool(
                name: "list_notes", arguments: ["book_id": .string(shared.id), "limit": 1, "cursor": .string(cursor)])
            #expect(second.isError != true)
            // …and is refused by a listing of another order (book order's key
            // is a fractional position; the wing listing's is a recency
            // stamp — comparing one against the other pages garbage).
            let crossed = try await connection.client.callTool(
                name: "list_notes", arguments: ["wing_id": "", "cursor": .string(cursor)])
            #expect(crossed.isError == true)
            #expect(text(crossed).contains("not a next_cursor this server returned"))
            await h.hangUp(connection)
        }
    }

    // MARK: - Round 1 F2: list_books counts exactly what list_notes(book_id:) would emit

    @Test func listBooksCountsOnlyTheNotesTheClientCanList() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let shared = try h.operations.createReading(name: "mixed", kind: .book)
            let prose = try h.operations.createPost(title: "prose")
            _ = try h.operations.newBlock(in: prose.id, text: "plain words")
            let entry = try h.operations.createPost(title: "morning pages", profile: .journal)
            _ = try h.operations.newBlock(in: entry.id, text: "diary words")
            let archived = try h.operations.createPost(title: "put away")
            _ = try h.operations.addPostToReading(prose.id, to: shared.id)
            _ = try h.operations.addPostToReading(entry.id, to: shared.id)
            _ = try h.operations.addPostToReading(archived.id, to: shared.id)
            try h.operations.archiveContainer(archived.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", book(shared.id))

            let books = try json(try await connection.client.callTool(name: "list_books"))["books"] as? [[String: Any]]
            // The fenced member never lists, so it never counts. A count that
            // said more would disclose a hidden member's existence ambient
            // (journals are per-ask, never ambient) and break honest counts.
            // U4 (justified edit — AF-11 F-4's DELIBERATE flip, the ritual):
            // an ARCHIVED member is out of the listing unless asked (the
            // facet's resting posture), so by default it neither lists nor
            // counts; under include_archived it does both — the count stays
            // the listing's extent either way.
            #expect(books?.first?["notes"] as? Int == 1, "the count IS the listing's extent")
            let listed = try json(try await connection.client.callTool(
                name: "list_notes", arguments: ["book_id": .string(shared.id)]))["notes"] as? [[String: Any]]
            #expect(Set(listed?.compactMap { $0["id"] as? String } ?? []) == [prose.id])
            let withArchived = try json(try await connection.client.callTool(
                name: "list_books", arguments: ["include_archived": .bool(true)]))["books"] as? [[String: Any]]
            #expect(withArchived?.first?["notes"] as? Int == 2)
            let listedArchived = try json(try await connection.client.callTool(
                name: "list_notes", arguments: ["book_id": .string(shared.id), "include_archived": .bool(true)]))["notes"]
                as? [[String: Any]]
            #expect(Set(listedArchived?.compactMap { $0["id"] as? String } ?? []) == [prose.id, archived.id])
            #expect(listedArchived?.first { $0["id"] as? String == archived.id }?["archived"] as? Bool == true)
            await h.hangUp(connection)
        }
    }

    // MARK: - Round 1 F1: search needs STANDING reach — listing and serving read one rule

    @Test func searchIsNeitherListedNorServedForAOnceOnlyStanding() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let shared = try h.operations.createReading(name: "b", kind: .book)
            let note = try h.operations.createPost(title: "n")
            _ = try h.operations.newBlock(in: note.id, text: "the harbour at dawn")
            _ = try h.operations.addPostToReading(note.id, to: shared.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", book(shared.id, .once))

            // A once-only standing: search can never return a passage (the
            // recorded once-never-in-search restriction), so it is not listed
            // (P-2 on the wire) — and called anyway, it refuses rather than
            // answering an eternally empty page.
            let names = Set(try await connection.client.listTools().tools.map(\.name))
            #expect(!names.contains("search"), "a door that can never act is not listed")
            #expect(names.contains("read_note"), "the once grant's content read IS offered")
            let served = try await connection.client.callTool(
                name: "search", arguments: ["query": "harbour", "book_id": .string(shared.id)])
            #expect(served.isError == true, "serving reads the same rule as listing")
            #expect(text(served).hasPrefix("That book isn't shared with this client"))

            // A standing grant restores both halves.
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, book(shared.id, .always))
            let relisted = Set(try await connection.client.listTools().tools.map(\.name))
            #expect(relisted.contains("search"))
            let found = try json(try await connection.client.callTool(
                name: "search", arguments: ["query": "harbour", "book_id": .string(shared.id)]))
            #expect((found["passages"] as? [[String: Any]])?.isEmpty == false)
            await h.hangUp(connection)
        }
    }

    // MARK: - Round 1 F7: the session ceiling

    @Test func connectionsPastTheCapAreRefusedWithOneHonestErrorAndSlotsFree() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        // VX-168 (A JUSTIFIED EDIT, the ritual): every connection presents
        // its own setup key now — a bare one would be refused at the door
        // and never hold a slot.
        func rawInitialize(_ name: String) throws -> (fd: Int32, answer: [String: Any]) {
            try h.rawOpen(as: name, presenting: try h.setupKey(for: name))
        }
        var held: [Int32] = []
        defer { for fd in held { close(fd) } }
        for index in 0..<16 {
            let (fd, answer) = try rawInitialize("flood-\(index)")
            held.append(fd)
            #expect(answer["result"] != nil, "connection \(index) serves")
        }
        #expect(try await h.eventually { h.host.connectedClientNames.count == 16 })

        // The seventeenth is refused with ONE honest JSON-RPC error — its
        // id echoed — then closed; a bare close would leave the client
        // saying only "failed".
        let (overFD, refusal) = try rawInitialize("flood-over")
        close(overFD)
        let error = refusal["error"] as? [String: Any]
        #expect(error?["code"] as? Int == MCPShim.refusalCode, "\(refusal)")
        #expect((error?["message"] as? String)?.contains("maximum") == true)
        #expect(refusal["id"] as? Int == 1, "the refusal answers the request by its id")

        // A closed connection frees its slot.
        close(held.removeFirst())
        #expect(try await h.eventually { h.host.connectedClientNames.count == 15 })
        let (freshFD, answer) = try rawInitialize("after-the-drop")
        held.append(freshFD)
        #expect(answer["result"] != nil, "the freed slot serves again")
    }

    // MARK: - The socket's life

    @Test func theSocketIsPrivateWhileServingAndGoneAfterStop() async throws {
        let h = try ServerHarness()
        let path = MCPSocketRoad.socketPath(directory: h.directory)
        let attributes = try FileManager.default.attributesOfItem(atPath: path)
        #expect((attributes[.posixPermissions] as? NSNumber)?.intValue == 0o600)
        #expect(throws: MCPSocketRoad.ListenError(kind: .alreadyServed)) {
            try MCPSocketRoad.listen(directory: h.directory)
        }
        h.tearDown()
        #expect(!FileManager.default.fileExists(atPath: path), "the socket dies with the server")
        if case .failure(let failure) = MCPSocketRoad.connect(directory: h.directory) {
            #expect(failure == .notRunning(errno: ENOENT))
        } else {
            Issue.record("nothing should answer after stop")
        }
    }
}
