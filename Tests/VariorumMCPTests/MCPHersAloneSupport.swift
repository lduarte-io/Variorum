import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP

// VX-184 LADDER ROUND 1 — THE `hersAlone` OVERCLAIM (the opus-reviewer's MINOR,
// agreed): the U5 record said "the server pins assert the columns byte-identical
// after every act", and only `rename_book`'s pin read them. This makes the
// sentence true: the five U5 server suites route EVERY wire call through
// `callKeepingHersAlone`, which reads the columns R-VX184-2 keeps hers alone —
// Private (`ai_private_at`), Seal (`sealed_at`, a note's `locked`) and Own
// (`owned`) — before and after the call and expects them byte-identical, a
// refused call included. A strengthening of the pins, not a bug fix: no MCP road
// writes those columns, so these expectations are green on both sides (the run
// record's ROUND 1 FIX PASS says so, with a mutation that proves they bite).

extension ServerHarness {
    /// The hers-alone columns (R-VX184-2), read whole: every reading's
    /// `owned`, `sealed_at` and `ai_private_at`; every container's `locked`
    /// (a note's seal) and `ai_private_at` — tombstoned rows included.
    func hersAlone() throws -> [String] {
        try database.read { db in
            try Row.fetchAll(db, sql: "SELECT id, owned, sealed_at, ai_private_at FROM reading ORDER BY id")
                .map(\.description)
                + Row.fetchAll(db, sql: "SELECT id, locked, ai_private_at FROM container ORDER BY id").map(\.description)
        }
    }
}

/// One wire call, with the hers-alone columns expected byte-identical across it.
func callKeepingHersAlone(
    _ h: ServerHarness, _ connection: HarnessConnection, _ name: String, _ arguments: [String: Value],
    sourceLocation: SourceLocation = #_sourceLocation
) async throws -> (content: [Tool.Content], isError: Bool?) {
    let before = try h.hersAlone()
    let result = try await connection.client.callTool(name: name, arguments: arguments)
    #expect(try h.hersAlone() == before, "\(name) left Private, Seal and Own as they were (R-VX184-2)",
            sourceLocation: sourceLocation)
    return result
}
