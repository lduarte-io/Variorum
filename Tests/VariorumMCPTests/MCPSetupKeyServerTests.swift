import Darwin
import Dependencies
import Foundation
import GRDB
import MCP
import System
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-168 — THE PER-SETUP KEY over the socket road (the VX-156 brief §12's K2,
// her kickoff ruling R-VX168-1). A real `MCPServerHost` on a real socket: the
// handshake reads the shim's preamble and the `initialize` frame, admits or
// refuses ONCE, and a refusal is ONE sentence in the shim's refusal shape —
// byte-identical across every arm but the request id (no oracle) — then the
// connection closes. Admitted connections serve exactly as before (the frame
// replayed into the SDK).

@Suite("VX-168 — the setup key on the socket road", .serialized)
struct MCPSetupKeyServerTests {
    /// The refusal's error object, checked whole: the shim's code, the ONE
    /// sentence, the request answered by its id.
    private func expectRefusal(_ answer: [String: Any], id: Int, _ comment: Comment) {
        #expect(answer["result"] == nil, comment)
        #expect(answer["id"] as? Int == id, comment)
        let error = answer["error"] as? [String: Any]
        #expect(error?["code"] as? Int == MCPShim.refusalCode, comment)
        #expect(error?["message"] as? String == MCPHandshake.refusal, comment)
    }

    /// After its one answer, a refused connection is CLOSED (EOF), and it
    /// never holds a session slot.
    private func expectClosed(_ fd: Int32) {
        var timeout = timeval(tv_sec: 2, tv_usec: 0)
        _ = setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
        var byte: UInt8 = 0
        #expect(read(fd, &byte, 1) == 0, "the refused connection is hung up after its answer")
        close(fd)
    }

    /// Her Activity list's CONNECTION lines (the tool calls log beside them).
    private func activity(_ h: ServerHarness) throws -> [String] {
        try h.database.read { db in
            try Row.fetchAll(db, sql: "SELECT client_name, act, outcome FROM mcp_activity WHERE act LIKE 'connect_%' ORDER BY id")
                .map { "\($0["client_name"] as String) \($0["act"] as String) \($0["outcome"] as String)" }
        }
    }

    // MARK: - A fresh client, end to end

    /// The setup's key → a connection request bound to it, the advice read
    /// at `initialize`, no tools; approved and granted, it acts — and its
    /// own key keeps admitting it on a second connection.
    @Test func aFreshClientSetUpEndToEnd() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "a page")
            let key = try h.operations.mintMCPSetupKey()   // the pane's Copy setup command
            let first = try await h.connect(as: "codex", presenting: key)
            let request = try h.client("codex")
            #expect(request.state == .pending && request.isSetupBound)
            #expect(try await first.client.listTools().tools.isEmpty, "a request reaches nothing")

            _ = try h.approve("codex", .init(rung: .read, scopeKind: .note, scopeID: note.id, duration: .always))
            let read = try await first.client.callTool(name: "read_note", arguments: ["note_id": .string(note.id)])
            #expect(read.isError != true, "approved and granted, it acts")

            let second = try await h.connect(as: "codex", presenting: key)
            #expect(try await second.client.callTool(name: "read_note", arguments: ["note_id": .string(note.id)])
                .isError != true, "its own key admits it again")
            #expect(try await h.eventually { h.host.connectedClientNames == ["codex"] })
            await h.hangUp(first)
            await h.hangUp(second)
        }
    }

    // MARK: - Two tools under one name, told apart

    /// VX-198 (A JUSTIFIED EDIT, the ritual — R-VX184-5, "the newest copied
    /// setup wins"; the VX-168 drill's impostor leg re-pinned): this test's
    /// premise was "the SAME name with ANOTHER key — a newer copy's — is
    /// refused". Her ruling reverses exactly that arm: a newer copy RE-BINDS
    /// the name (approval and grants kept), and the tool still holding the key
    /// it replaced is the one turned away — with its own sentence. Every
    /// other impostor road keeps the ONE sentence: no key, a key never issued,
    /// another name's key. The standing session (decided once) keeps working;
    /// the row the refusals claimed is untouched; her Activity list says which.
    @Test func twoToolsUnderOneNameAreToldApart() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "a page")
            let real = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", .init(rung: .read, scopeKind: .note, scopeID: note.id, duration: .always))
            let codexKey = try h.setupKey(for: "codex")
            let codex = try await h.connect(as: "codex")

            // A newer copy of the setup: it takes the name.
            // VX-258 (A JUSTIFIED EDIT, the ritual — her ruling: a key re-binds with zero clicks only the name its setup was copied FOR): the
            // newer copy is Claude Code's own tab's, so it carries the name;
            // an "Any MCP client" copy here waits for her OK instead
            // (`MCPSetupKeyImpostorServerTests`, `MCPSetupKeyTabServerTests`).
            let newer = try h.operations.mintMCPSetupKey(copiedFor: "claude-code")
            let (newerFD, rebound) = try h.rawOpen(as: "claude-code", presenting: newer, id: 6)
            #expect(rebound["id"] as? Int == 6 && rebound["result"] != nil, "the newest setup is admitted: \(rebound)")
            close(newerFD)
            let before = try h.client("claude-code")
            #expect(before.state == .approved && before.isSetupBound, "approval kept, the name bound to the newer key")

            // The key it replaced: its own sentence. Every other road: the one.
            let (oldFD, old) = try h.rawOpen(as: "claude-code", presenting: try h.setupKey(for: "claude-code"), id: 7)
            #expect(old["result"] == nil && old["id"] as? Int == 7)
            #expect((old["error"] as? [String: Any])?["message"] as? String == MCPHandshake.replacedRefusal)
            expectClosed(oldFD)
            let (bareFD, bare) = try h.rawOpen(as: "claude-code", presenting: nil, id: 8)
            expectRefusal(bare, id: 8, "no key under a bound name")
            expectClosed(bareFD)
            let (forgedFD, forged) = try h.rawOpen(as: "claude-code", presenting: "vmk1_neverminted", id: 9)
            expectRefusal(forged, id: 9, "a key never issued under a bound name")
            expectClosed(forgedFD)
            let (foreignFD, foreign) = try h.rawOpen(as: "claude-code", presenting: codexKey, id: 10)
            expectRefusal(foreign, id: 10, "another name's key under a bound name")
            expectClosed(foreignFD)

            #expect(try h.client("claude-code") == before, "no refusal touched the row it claimed")
            #expect(try await real.client.callTool(name: "read_note", arguments: ["note_id": .string(note.id)])
                .isError != true, "the standing session was decided once — it keeps working")
            #expect(try activity(h) == [
                "claude-code \(MCPSetupKeyRule.reboundAct) allowed",
                "claude-code connect_replaced_key refused",
                "claude-code connect_bare refused",
                "claude-code connect_not_this_names_key refused",
                "claude-code connect_not_this_names_key refused",
            ])
            await h.hangUp(real)
            await h.hangUp(codex)
        }
    }

    // MARK: - A bare shim

    /// No key under a NEW name is refused, the connection request never made
    /// (R-VX168-1: no grandfathering — the bound and approved-unbound names'
    /// bare arms are pinned beside their own cases).
    @Test func aBareShimIsRefusedUnderAnyName() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let (fd, answer) = try h.rawOpen(as: "stray", presenting: nil, id: 3)
        expectRefusal(answer, id: 3, "a bare new name")
        expectClosed(fd)
        #expect(try await h.database.read { try Queries.mcpClient($0, name: "stray") } == nil,
                "a bare arrival never enters the waiting room")
        // The SDK's own client hears it as an initialize error.
        await #expect(throws: (any Error).self) {
            _ = try await h.connect(as: "stray", presenting: nil)
        }
    }

    // MARK: - R-VX168-1's branch: an approved name with no key

    /// Her clients from before VX-168: approved, grants held, no key. A bare
    /// arrival refuses; the first fresh setup presented under the name BINDS
    /// it (no revoke, no re-approval) and serves her grants; from then a bare
    /// or another key refuses and the bound key keeps admitting.
    @Test func anApprovedUnboundNameBindsTheFirstFreshSetupThenBareRefuses() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "her page")
            _ = try h.operations.recordMCPContact(name: "claude-code", version: "2.1")
            _ = try h.approve("claude-code", .init(rung: .read, scopeKind: .note, scopeID: note.id, duration: .always))
            #expect(try h.client("claude-code").isSetupBound == false)

            let (bareFD, bare) = try h.rawOpen(as: "claude-code", presenting: nil, id: 1)
            expectRefusal(bare, id: 1, "unbound, a bare arrival still refuses")
            expectClosed(bareFD)

            // VX-258 (A JUSTIFIED EDIT, the ritual — her ruling: a key re-binds with zero clicks only the name its setup was copied FOR): she
            // re-runs Claude Code's OWN setup, so its key carries the name (an
            // untagged copy here waits for her OK — VX-258's bind arm,
            // `MCPSetupKeyImpostorTests`).
            let rerun = try h.operations.mintMCPSetupKey(copiedFor: "claude-code")   // she re-runs the setup
            let bound = try await h.connect(as: "claude-code", presenting: rerun)
            #expect(try h.client("claude-code").isSetupBound)
            #expect(try h.client("claude-code").state == .approved, "her approval kept")
            #expect(try await bound.client.callTool(name: "read_note", arguments: ["note_id": .string(note.id)])
                .isError != true, "her grants serve the bound tool")

            let (afterFD, after) = try h.rawOpen(as: "claude-code", presenting: nil, id: 2)
            expectRefusal(after, id: 2, "bound now, bare refuses")
            expectClosed(afterFD)
            let again = try await h.connect(as: "claude-code", presenting: rerun)
            #expect(try await again.client.listTools().tools.contains { $0.name == "read_note" })
            #expect(try activity(h) == [
                "claude-code connect_bare refused",
                "claude-code \(MCPSetupKeyRule.boundAct) allowed",
                "claude-code connect_bare refused",
            ])
            await h.hangUp(bound)
            await h.hangUp(again)
        }
    }

    // MARK: - The one sentence (no oracle)

    /// Every refusal arm answers BYTE-IDENTICALLY but for the request id: a
    /// key never minted, another name's key, a bound name's other key, no
    /// key, no name, and a first frame that is not `initialize`.
    @Test func everyRefusalIsTheSameSentence() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let owned = try h.setupKey(for: "claude-code")
        let real = try await h.connect(as: "claude-code")
        var answers: [Data] = []
        for (name, key) in [("forger", "vmk1_neverminted"), ("codex", owned), ("claude-code", "vmk1_other"),
                            ("stray", nil), ("", try h.operations.mintMCPSetupKey())] as [(String, String?)] {
            let (fd, answer) = try h.rawOpen(as: name, presenting: key, id: 5)
            expectRefusal(answer, id: 5, "\(name)")
            answers.append(try JSONSerialization.data(withJSONObject: answer, options: [.sortedKeys]))
            close(fd)
        }
        // A connection that never opens with initialize. VX-180 (A JUSTIFIED
        // EDIT, the ritual): this arm's premise was "a non-initialize REQUEST
        // first is refused at once" — exactly what VX-180 changes (a
        // pre-initialize request is now answered -32601 and the window reads
        // on). The SAME frame now reaches the refusal past the window's
        // bound; its answer — the one sentence on id 5 — is unchanged, byte
        // for byte. (A first frame that is no request at all keeps the
        // immediate refusal: `MCPPreInitializeWindowTests`.)
        guard case .success(let fd) = MCPSocketRoad.connect(directory: h.directory) else {
            throw HarnessFailure("could not connect")
        }
        _ = MCPShim.writeAll(fd, MCPPreamble.line(key: try h.operations.mintMCPSetupKey()))
        for window in 0..<MCPHandshake.preInitializeLimit {
            _ = MCPShim.writeAll(fd, Data((#"{"jsonrpc":"2.0","id":\#(100 + window),"method":"tools/list"}"# + "\n").utf8))
            #expect(MCPShim.readFirstLine(fd, limit: 1 << 20).range(of: Data("-32601".utf8)) != nil, "inside the window")
        }
        _ = MCPShim.writeAll(fd, Data((#"{"jsonrpc":"2.0","id":5,"method":"tools/list"}"# + "\n").utf8))
        let line = MCPShim.readFirstLine(fd, limit: 1 << 20)
        let notInitialize = try #require(try JSONSerialization.jsonObject(with: line) as? [String: Any])
        expectRefusal(notInitialize, id: 5, "a connection that never opens with initialize")
        answers.append(try JSONSerialization.data(withJSONObject: notInitialize, options: [.sortedKeys]))
        close(fd)
        #expect(Set(answers).count == 1, "one sentence, byte for byte, whatever the arm")
        #expect(!MCPHandshake.refusal.contains("wrong") && !MCPHandshake.refusal.contains("unknown"))
        await h.hangUp(real)
    }

    // MARK: - The denied-name bind (ladder R1, F-2 — deliberate, now pinned)

    /// Identity is decided ONCE per connection; APPROVAL stays `MCPGrantRule`'s,
    /// per call — so a DENIED, unbound name presenting a fresh unclaimed key
    /// BINDS it and the handshake admits the connection, which then reaches
    /// NOTHING ("denied" on every call — the honest answer; the key advice
    /// could not help it). A Deny on the STILL-DENIED client releases that
    /// binding too (the release runs ahead of `denyMCPClient`'s already-denied
    /// short-circuit — the sanity pass's NIT: exercised here, not just
    /// claimed), and re-running the setup works in EITHER order around her
    /// approval (R-VX168-1's "just re-run the setup"). GREEN ON BOTH SIDES by
    /// design: this pins standing behaviour the round found unargued; it
    /// fixes nothing.
    @Test func aDeniedNameBindsAFreshKeyButReachesNothingUntilApproval() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "a page")
            let first = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", .init(rung: .read, scopeKind: .note, scopeID: note.id, duration: .always))
            await h.hangUp(first)
            let clientID = try h.client("claude-code").id
            try h.operations.denyMCPClient(clientID)  // releases the binding (P-VX168-U1-1)
            #expect(try h.client("claude-code").isSetupBound == false)

            // The fresh key binds while denied — the row STAYS denied…
            let fresh = try h.operations.mintMCPSetupKey()
            let connection = try await h.connect(as: "claude-code", presenting: fresh)
            #expect(try h.client("claude-code").state == .denied, "binding is identity, never approval")
            #expect(try h.client("claude-code").isSetupBound)
            // …and the connection reaches nothing: denied, per call.
            let refused = try await connection.client.callTool(
                name: "read_note", arguments: ["note_id": .string(note.id)])
            #expect(refused.isError == true && text(refused).contains("denied this client"), "\(text(refused))")

            // A Deny on the STILL-DENIED, bound client releases the binding:
            // the hash-NULL runs ahead of the already-denied short-circuit.
            // The released key then opens no NEW connection…
            try h.operations.denyMCPClient(clientID)
            #expect(try h.client("claude-code").isSetupBound == false)
            #expect(try h.client("claude-code").state == .denied)
            let (fd, answer) = try h.rawOpen(as: "claude-code", presenting: fresh, id: 6)
            expectRefusal(answer, id: 6, "the released key is gone")
            expectClosed(fd)

            // …while the STANDING connection stays decided (the handshake
            // decides once; the release gates the next connection, whose road
            // back is R-VX168-1's re-run). Her approval opens it per call —
            // Deny revoked the old grant, so the approval brings a new one.
            _ = try h.approve("claude-code", .init(rung: .read, scopeKind: .note, scopeID: note.id, duration: .always))
            let read = try await connection.client.callTool(
                name: "read_note", arguments: ["note_id": .string(note.id)])
            #expect(read.isError != true, "re-run setup then approve — either order works: \(text(read))")
            await h.hangUp(connection)
        }
    }

    /// Ladder R1, F-3: a tag-only preamble (an empty key — a hand-rolled
    /// client's, never the shim's) is BARE, so her Activity says "without a
    /// setup key", never "a key this library doesn't hold". The wire answer
    /// is the one sentence either way. RED ON OLD: the empty string hashed
    /// and logged `connect_not_issued`.
    @Test func anEmptyKeyPreambleIsBare() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let (fd, answer) = try h.rawOpen(as: "stray", presenting: "", id: 9)
        expectRefusal(answer, id: 9, "a tag-only preamble")
        expectClosed(fd)
        #expect(try activity(h) == ["stray connect_bare refused"])
    }

    // MARK: - A store that cannot answer (fail closed, its own sentence)

    /// Ladder R1, F-1: a STORE error during the admission fails CLOSED — but
    /// the answer is the store-error sentence ("try again"), never the key
    /// advice (a correctly keyed client must not be told to re-copy its
    /// setup when the store merely failed). Nothing is logged: the store it
    /// would log to is the one that failed. RED ON OLD: the `try?` arm
    /// answered every store error with `MCPHandshake.refusal`.
    @Test func aStoreErrorRefusesWithItsOwnSentenceNeverKeyAdvice() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let key = try h.operations.mintMCPSetupKey()
        // Poison the admission's own read: the standing query has no table.
        try await h.database.write { try $0.execute(sql: "DROP TABLE mcp_setup_key") }
        let (fd, answer) = try h.rawOpen(as: "claude-code", presenting: key, id: 4)
        #expect(answer["result"] == nil && answer["id"] as? Int == 4)
        let error = answer["error"] as? [String: Any]
        #expect(error?["code"] as? Int == MCPShim.refusalCode)
        #expect(error?["message"] as? String == MCPHandshake.storeErrorRefusal,
                "\(String(describing: error?["message"]))")
        #expect(error?["message"] as? String != MCPHandshake.refusal,
                "never key advice for a store failure — following it would rotate a good key for nothing")
        expectClosed(fd)
    }

    // MARK: - The opening read (pure over a descriptor)

    @Test func theOpeningReadTakesThePreambleThenTheFrameAndNothingMore() throws {
        func opening(_ bytes: String) -> MCPHandshake.Opening? {
            var fds: [Int32] = [-1, -1]
            #expect(pipe(&fds) == 0)
            _ = MCPShim.writeAll(fds[1], Data(bytes.utf8))
            close(fds[1])
            defer { close(fds[0]) }
            return MCPHandshake.readOpening(fd: fds[0])
        }
        #expect(opening("variorum-mcp-key vmk1_a\n{\"id\":1}\n{\"id\":2}\n")
                == .init(presentedKey: "vmk1_a", firstFrame: Data("{\"id\":1}".utf8)))
        #expect(opening("{\"id\":1}\n") == .init(presentedKey: nil, firstFrame: Data("{\"id\":1}".utf8)), "bare")
        // Ladder R1, F-3: a tag-only preamble (an empty key) is BARE — the
        // classify stays honest about the line (`.preamble(key: "")`, its own
        // pin), and the handshake maps the nothing-key to no key.
        #expect(opening("variorum-mcp-key\n{\"id\":1}\n")
                == .init(presentedKey: nil, firstFrame: Data("{\"id\":1}".utf8)), "a tag with no key is bare")
        #expect(opening("variorum-mcp-key \n{\"id\":1}\n")?.presentedKey == nil, "a tag with a space, the same")
        #expect(opening("\n\nvariorum-mcp-key vmk1_a\n\n{\"id\":1}\n")?.presentedKey == "vmk1_a", "blank lines skipped")
        #expect(opening("variorum-mcp-key vmk1_a\n") == nil, "no frame before EOF")
        #expect(opening("{\"id\":1}") == nil, "no newline before EOF")
        #expect(opening(String(repeating: "\n", count: MCPHandshake.blankLimit + 2) + "{}\n") == nil, "bounded blanks")

        // Byte-exact: the frame after the opening is left for the transport.
        var fds: [Int32] = [-1, -1]
        #expect(pipe(&fds) == 0)
        _ = MCPShim.writeAll(fds[1], Data("variorum-mcp-key k\n{\"id\":1}\n{\"id\":2}\n".utf8))
        close(fds[1])
        _ = MCPHandshake.readOpening(fd: fds[0])
        #expect(MCPShim.readFirstLine(fds[0], limit: 64) == Data("{\"id\":2}".utf8))
        close(fds[0])
    }

    @Test func theInitializeFrameNamesTheClient() {
        let frame = Data(#"{"jsonrpc":"2.0","id":0,"method":"initialize","params":{"clientInfo":{"name":"codex","version":"0.4"}}}"#.utf8)
        let declared = MCPHandshake.initialize(frame)
        #expect(declared?.name == "codex" && declared?.version == "0.4")
        #expect(MCPHandshake.initialize(Data(#"{"method":"tools/list","params":{}}"#.utf8)) == nil)
        #expect(MCPHandshake.initialize(Data("not json".utf8)) == nil)
    }
}
