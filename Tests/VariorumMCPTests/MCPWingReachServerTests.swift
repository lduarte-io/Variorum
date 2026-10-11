import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// 13n-c U6 — THE WING ON THE WIRE, the read side: `show_in_app`'s `wing`
// target (VX-158 — the brief §8's A, mockup §7) and R-AIR-12's gatherings
// read as facts under a wing grant ("granting a wing grants access to
// everything … unless it's deliberately marked private"; gatherings "do NOT
// become separate grant targets").

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

private func call(
    _ connection: (client: Client, fd: Int32), _ name: String, _ arguments: [String: Value]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: name, arguments: arguments)
}

/// A fake app standing where the test says, applying the RULE, recording what
/// it would have delivered (`MCPHostHooks.show`'s contract).
private final class FakeApp: @unchecked Sendable {
    let standing = LockIsolated(MCPShowRule.Standing.frontmostMainWindow)
    let delivered = LockIsolated<[MCPShowTarget]>([])

    var hook: @Sendable (MCPShowTarget) async -> MCPShowRule.Verdict {
        { [self] target in
            let verdict = MCPShowRule.verdict(standing.value)
            if verdict == .navigate { delivered.withValue { $0.append(target) } }
            return verdict
        }
    }
}

@Suite("13n-c U6 — show_in_app's wing target and gatherings under a wing grant", .serialized)
struct MCPWingReachServerTests {
    /// Sync reads (the async overloads would win inside the test bodies).
    private func consumedAt(_ h: ServerHarness, _ grant: String) throws -> String? {
        try h.database.read {
            try String.fetchOne($0, sql: "SELECT consumed_at FROM mcp_grant WHERE id = ?", arguments: [grant])
        }
    }

    // MARK: - show_in_app → a wing (VX-158)

    @Test func showInAppSwitchesToAWingOnlyUnderWingLevelReachAndNeverSpends() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let app = FakeApp()
        h.host.hooks.show = app.hook
        try await h.within {
            let variorum = try h.operations.createWing(name: "variorum")
            let studio = try h.operations.createWing(name: "studio")
            let studioBook = try h.operations.createReading(name: "sketches", kind: .book, wingId: studio.id)
            let studioNote = try h.operations.createPost(title: "a sketch", wingId: studio.id)
            let connection = try await h.connect(as: "claude-code")
            let once = try #require(try h.approve("claude-code", spec(.read, .wing, variorum.id, .once)))
            let client = try h.client("claude-code").id

            let shown = try await call(connection, "show_in_app",
                                       ["target": .string("wing"), "wing_id": .string(variorum.id)])
            #expect(shown.isError != true, "\(text(shown))")
            #expect(app.delivered.value == [.wing(wingID: variorum.id, name: "variorum", shownBy: "claude-code")],
                    "the wing, its name, and who asked — the receipt says it")
            #expect(try consumedAt(h, once) == nil, "a show never spends a once grant")

            app.standing.setValue(.notFrontmost)
            let away = try await call(connection, "show_in_app",
                                      ["target": .string("wing"), "wing_id": .string(variorum.id)])
            #expect(away.isError == true && text(away) == MCPShowRule.notFrontmostWords)
            app.standing.setValue(.frontmostMainWindow)

            // A book or note grant in a wing never reaches the WING.
            _ = try h.operations.grantMCPAccess(client, spec(.edit, .book, studioBook.id))
            _ = try h.operations.grantMCPAccess(client, spec(.edit, .note, studioNote.id))
            let byBook = try await call(connection, "show_in_app",
                                        ["target": .string("wing"), "wing_id": .string(studio.id)])
            #expect(byBook.isError == true && text(byBook) == MCPRefusalCopy.words(.notShared, .wing))
            let nowhere = try await call(connection, "show_in_app",
                                         ["target": .string("wing"), "wing_id": .string("no-such-wing")])
            #expect(text(nowhere) == text(byBook), "an unreached wing and no wing answer alike")

            // The open book reads every wing — Home by its place-name; a wing
            // that is not there still answers the one answer.
            try h.operations.setMCPSwitch(.openBook, on: true)
            let home = try await call(connection, "show_in_app", ["target": .string("wing"), "wing_id": .string("")])
            #expect(home.isError != true)
            #expect(app.delivered.value.last == .wing(wingID: "", name: "Home", shownBy: "claude-code"))
            let ghost = try await call(connection, "show_in_app",
                                       ["target": .string("wing"), "wing_id": .string("no-such-wing")])
            #expect(ghost.isError == true && text(ghost) == MCPRefusalCopy.words(.notShared, .wing))
            #expect(app.delivered.value.count == 2, "nothing moved for the refusals")
            await h.hangUp(connection)
        }
    }
}
