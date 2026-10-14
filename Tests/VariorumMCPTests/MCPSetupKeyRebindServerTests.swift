import Darwin
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-198 — R-VX184-5 ON THE SOCKET ROAD (the run record
// `notes/plans/fixes/vx-184-mcp-launch-polish.md`, U1 — "VX-198"). The VX-168
// drill's impostor leg, re-pinned to the new rule: a SECOND copy of the setup
// connects under the bound name and is served (approval and grants kept); the
// key it replaced then hears its OWN sentence; a key never issued, a bare shim
// and another name's key still hear the one sentence. Pre-fix API only (the
// replaced sentence is matched by its words), so this COMPILES on the pre-fix
// tree, where it was watched RED.

@Suite("VX-198 — the newest copied setup on the socket road", .serialized)
struct MCPSetupKeyRebindServerTests {
    private func message(_ answer: [String: Any]) -> String? {
        (answer["error"] as? [String: Any])?["message"] as? String
    }

    @Test func aSecondCopyRebindsTheNameAndTheReplacedKeyHearsItsOwnSentence() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "her page")
            _ = try h.operations.newBlock(in: note.id, text: "the harbour at dawn", registeringUndo: false)
            let first = try h.operations.mintMCPSetupKey()
            let old = try await h.connect(as: "claude-code", presenting: first)
            _ = try h.approve("claude-code", .init(rung: .read, scopeKind: .note, scopeID: note.id, duration: .always))
            let codex = try await h.connect(as: "codex")   // another name, its own key bound

            // She runs the setup again (a second Copy setup command press).
            // VX-258 (A JUSTIFIED EDIT, the ritual — her ruling: a key re-binds with zero clicks only the name its setup was copied FOR): the
            // second copy is from Claude Code's own tab.
            let rerun = try h.operations.mintMCPSetupKey(copiedFor: "claude-code")
            let newer = try await h.connect(as: "claude-code", presenting: rerun)
            let read = try await newer.client.callTool(name: "read_note", arguments: ["note_id": .string(note.id)])
            #expect(read.isError != true && text(read).contains("the harbour at dawn"),
                    "the newest setup is served by her standing grant: \(text(read))")
            #expect(try h.client("claude-code").state == .approved, "approval kept")

            // The session the older key opened was decided once — it stays
            // served until it ends; the NEXT connection with that key refuses.
            let stillOpen = try await old.client.callTool(name: "read_note", arguments: ["note_id": .string(note.id)])
            #expect(stillOpen.isError != true, "a connection is decided once")
            let (replacedFD, replaced) = try h.rawOpen(as: "claude-code", presenting: first, id: 4)
            close(replacedFD)
            #expect(replaced["id"] as? Int == 4 && replaced["result"] == nil)
            #expect(message(replaced)?.contains("a newer setup replaced this one") == true,
                    "the replaced key hears its own sentence: \(String(describing: message(replaced)))")

            // Every other key road under the name still hears the ONE sentence.
            for (key, why) in [("vmk1_neverminted", "a key never issued"), (nil, "no key"),
                               (try h.setupKey(for: "codex"), "another name's key")] as [(String?, String)] {
                let (fd, answer) = try h.rawOpen(as: "claude-code", presenting: key, id: 5)
                close(fd)
                #expect(message(answer) == MCPHandshake.refusal, "\(why): the one sentence")
                #expect(message(answer)?.contains("newer setup") != true, "\(why): never the replaced sentence")
            }
            await h.hangUp(old)
            await h.hangUp(newer)
            await h.hangUp(codex)
        }
    }
}
