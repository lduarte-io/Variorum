import Darwin
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-258 — THE IMPOSTOR ON THE SOCKET ROAD (the run record
// `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`, U1 — "VX-258"; VX-184's
// ladder round 1's MAJOR). A fresh MINT — her "Any MCP client" copy, given to a
// tool that calls itself `claude-code` — connects under the bound, approved name.
// It must reach NOTHING (no tools, every call the waiting sentence a connection
// request hears — the same answer a first-contact request gets, so its holder
// cannot tell an approved name from a new one), and the real client's key keeps
// connecting. Pre-fix API only: this compiles on the pre-fix tree, where it was
// watched RED (the impostor was served with every grant; the real key was then
// turned away as replaced).

@Suite("VX-258 — a fresh mint under a bound, approved name reaches nothing", .serialized)
struct MCPSetupKeyImpostorServerTests {
    private func message(_ answer: [String: Any]) -> String? {
        (answer["error"] as? [String: Any])?["message"] as? String
    }

    @Test func theImpostorConnectsReachingNothingAndTheRealKeyKeepsConnecting() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "her page")
            _ = try h.operations.newBlock(in: note.id, text: "the harbour at dawn", registeringUndo: false)
            let first = try h.operations.mintMCPSetupKey()
            let real = try await h.connect(as: "claude-code", presenting: first)
            _ = try h.approve("claude-code", .init(rung: .read, scopeKind: .note, scopeID: note.id, duration: .always))

            let impostorKey = try h.operations.mintMCPSetupKey()
            let impostor = try await h.connect(as: "claude-code", presenting: impostorKey)
            #expect(try await impostor.client.listTools().tools.isEmpty, "no tools — nothing is shared with it")
            let read = try await impostor.client.callTool(name: "read_note", arguments: ["note_id": .string(note.id)])
            #expect(read.isError == true && !text(read).contains("the harbour"), "nothing read: \(text(read))")

            // No oracle: a first-contact request (a new name, a fresh key) hears
            // exactly what the impostor hears.
            let stranger = try await h.connect(as: "a-new-tool", presenting: try h.operations.mintMCPSetupKey())
            #expect(try await stranger.client.listTools().tools.isEmpty)
            let theirs = try await stranger.client.callTool(name: "read_note", arguments: ["note_id": .string(note.id)])
            #expect(text(read) == text(theirs) && read.isError == theirs.isError,
                    "the impostor's answer is a connection request's, byte for byte")

            // The real client: its open session served, its key still admitted.
            let served = try await real.client.callTool(name: "read_note", arguments: ["note_id": .string(note.id)])
            #expect(served.isError != true && text(served).contains("the harbour at dawn"), "\(text(served))")
            let (fd, again) = try h.rawOpen(as: "claude-code", presenting: first, id: 7)
            close(fd)
            #expect(again["id"] as? Int == 7 && again["result"] != nil,
                    "the real key keeps connecting: \(String(describing: message(again)))")
            await h.hangUp(impostor)
            await h.hangUp(stranger)
            await h.hangUp(real)
        }
    }
}
