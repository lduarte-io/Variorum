import Foundation
import Testing

@testable import VariorumMCP

// VX-132 — THE HARNESS's HYGIENE (the run record
// `notes/plans/fixes/vx-184-mcp-launch-polish.md`, U1 — "VX-132 — the trace").
// The pinned SDK's message loop SPINS once its stream ends (measured: one core
// per such client, for the rest of the run). The harness's transport parks the
// loop and ends the client instead. This pin names the harness's own transport
// (`receiveCalls`), so it is a new-tree pin — watched red by reverting the
// hygiene alone (the record's piece 2).

@Suite("VX-132 — a client whose server hung up never spins", .serialized)
struct MCPHarnessHygieneTests {
    @Test func aConnectionTheServerClosesEndsItsClientInsteadOfSpinning() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let connection = try await h.connect(as: "left-connected")
        _ = try await connection.client.listTools()   // a live, answering connection first
        h.host.stop()   // the server hangs up every session
        var asked = 0
        for _ in 0..<200 {   // the loop drains its ended stream and asks again — once
            asked = await connection.client.transport.receiveCalls
            if asked >= 2 { break }
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(asked == 2, "the loop asked for its stream again once it ended")
        try await Task.sleep(for: .milliseconds(300))
        #expect(await connection.client.transport.receiveCalls == 2,
                "…and then never again: parked, not spinning (the SDK alone asks without end)")
        await #expect(throws: (any Error).self, "the ended client refuses at once, never waits") {
            _ = text(try await connection.client.callTool(name: "list_books"))
        }
    }
}
