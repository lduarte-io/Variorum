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

    /// The impostor — the SAME name with ANOTHER key (a newer copy's) or
    /// with none — is refused with the one sentence while the real tool's
    /// session keeps working; the client row is untouched; her Activity
    /// list says which.
    @Test func twoToolsUnderOneNameAreToldApart() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "a page")
            let real = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", .init(rung: .read, scopeKind: .note, scopeID: note.id, duration: .always))
            let before = try h.client("claude-code")

            let newer = try h.operations.mintMCPSetupKey()
            let (otherFD, other) = try h.rawOpen(as: "claude-code", presenting: newer, id: 7)
            expectRefusal(other, id: 7, "another key under a bound name")
            expectClosed(otherFD)
            let (bareFD, bare) = try h.rawOpen(as: "claude-code", presenting: nil, id: 8)
            expectRefusal(bare, id: 8, "no key under a bound name")
            expectClosed(bareFD)

            #expect(try h.client("claude-code") == before, "the impostor never touched the row it claimed")
            #expect(try await real.client.callTool(name: "read_note", arguments: ["note_id": .string(note.id)])
                .isError != true, "the real tool keeps working")
            #expect(try activity(h) == [
                "claude-code connect_not_this_names_key refused",
                "claude-code connect_bare refused",
            ])
            #expect(try await h.eventually { h.host.connectedClientNames == ["claude-code"] })
            await h.hangUp(real)
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

            let rerun = try h.operations.mintMCPSetupKey()   // she re-runs the setup
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
        // A first frame that is not initialize.
        guard case .success(let fd) = MCPSocketRoad.connect(directory: h.directory) else {
            throw HarnessFailure("could not connect")
        }
        _ = MCPShim.writeAll(fd, MCPPreamble.line(key: try h.operations.mintMCPSetupKey()))
        _ = MCPShim.writeAll(fd, Data((#"{"jsonrpc":"2.0","id":5,"method":"tools/list"}"# + "\n").utf8))
        let line = MCPShim.readFirstLine(fd, limit: 1 << 20)
        let notInitialize = try #require(try JSONSerialization.jsonObject(with: line) as? [String: Any])
        expectRefusal(notInitialize, id: 5, "a first frame that is not initialize")
        answers.append(try JSONSerialization.data(withJSONObject: notInitialize, options: [.sortedKeys]))
        close(fd)
        #expect(Set(answers).count == 1, "one sentence, byte for byte, whatever the arm")
        #expect(!MCPHandshake.refusal.contains("wrong") && !MCPHandshake.refusal.contains("unknown"))
        await h.hangUp(real)
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
