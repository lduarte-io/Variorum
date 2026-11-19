import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-961 (the VX-981 run, batch 2 — the record `notes/plans/fixes/vx-981-mcp-door-followups.md`,
// BATCH 2 RECORD): `show_in_app`'s landed-then-log sibling of VX-775. The ruled split, built for
// the write family by VX-775 ("the error goes to her, the truth goes to the client"): after the
// app MOVED her view (`.navigate`) or POSTED the ask (`.offer`), `MCPShowTool.call` wrote the
// Activity line with `try log(…)`; a store failure there fell into the call's catch-all and the
// client heard VX-369's "…so this call may not have landed…" `isError` for a show that happened,
// while she was told nothing.
//
// Failures are made real on the harness's one connection by a TEMP trigger that aborts every
// `mcp_activity` insert (VX-775's and VX-369's precedent — GRDB raises the same error for a full
// disk). A twin world with a working log gives each arm's answer to compare byte for byte.
// RED ON OLD (the behavioural revert — the fix commit's `MCPShowTool.swift` from its parent):
// each landed arm answers `isError` and the app is told nothing.

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: .always)
}

private let everyLineFails = """
    CREATE TEMP TRIGGER vx961_log_failure BEFORE INSERT ON mcp_activity
    BEGIN SELECT RAISE(ABORT, 'the store refused'); END
    """

private let dropTrigger = "DROP TRIGGER vx961_log_failure"

/// The store's words the app is handed (VX-369's form: SQLite's code and message).
private let storeWords = "SQLite error 19: the store refused"

/// What the client's `show_in_app` answered in one world, and what the app heard.
private struct Shown {
    let answer: String
    let isError: Bool
    let failures: [MCPActivityLogFailure]
    let tail: [MCPWriteReceipt]
    let lines: [String]
}

/// One world: a note the client may read; the app stands where `verdict` says (a fake delivery
/// that moves or offers without asking anything else); the log broken or not.
private func show(_ verdict: MCPShowRule.Verdict, logFails: Bool) async throws -> Shown {
    let h = try ServerHarness(seed: 961)
    defer { h.tearDown() }
    return try await h.within {
        let note = try h.operations.createPost(title: "ch 1")
        _ = try h.operations.newBlock(in: note.id, text: "Her line.", registeringUndo: false)
        h.host.hooks.show = { _ in verdict }
        let connection = try await h.connect(as: "claude-code")
        _ = try h.approve("claude-code", spec(.read, .note, note.id))
        if logFails { try await h.database.write { db in try db.execute(sql: everyLineFails) } }
        let result = try await connection.client.callTool(name: "show_in_app", arguments: ["note_id": .string(note.id)])
        if logFails { try await h.database.write { db in try db.execute(sql: dropTrigger) } }
        let lines = try await h.database.read { db in
            try String.fetchAll(db, sql: """
                SELECT act || ':' || outcome FROM mcp_activity WHERE act LIKE 'show_in_app%' ORDER BY id
                """)
        }
        await h.hangUp(connection)
        return Shown(answer: text(result), isError: result.isError == true, failures: h.activityLogFailures.value,
                     tail: h.tailReceipts.value, lines: lines)
    }
}

@Suite("VX-961 — show_in_app answers the act's truth when only its Activity line fails; she is told", .serialized)
struct MCPShowActivityLogFailureServerTests {
    /// **RED ON OLD — the MOVE.** The app moved her view (`.navigate`), then the store refused the
    /// Activity line: the client hears the act's own answer, BYTE FOR BYTE the twin's whose log
    /// works (R-825: nothing on the wire varies with her app-side state); the app is told ONCE —
    /// the client, the tool, the store's words — with no receipts (a show is no write); Activity
    /// simply lacks the row.
    @Test func aMoveWhoseLogFailsAnswersShownAndTellsHer() async throws {
        let twin = try await show(.navigate, logFails: false)
        #expect(!twin.isError && twin.answer == #"{"shown":true}"#, "the control: \(twin.answer)")
        #expect(twin.lines == ["show_in_app:allowed"] && twin.failures.isEmpty, "non-vacuity: its line lands")

        let broken = try await show(.navigate, logFails: true)
        #expect(!broken.isError, "RED ON OLD: a show that happened is no error — \(broken.answer)")
        #expect(broken.answer == twin.answer, "RED ON OLD: the act's own answer, byte for byte the twin's")
        #expect(broken.failures == [
            MCPActivityLogFailure(clientName: "claude-code", tool: "show_in_app", unrecorded: 1, storeWords: storeWords),
        ], "RED ON OLD: the app is told — once, naming the client, the tool and the store's words")
        #expect(broken.tail.isEmpty, "a show carries no receipt")
        #expect(broken.lines.isEmpty, "Activity lacks the row — nothing synthesized")
    }

    /// **RED ON OLD — the ASK.** The app posted the ask on her seam (`.offer`), then the store
    /// refused its Activity row (`show_in_app_offered`): the client hears the offered answer byte
    /// for byte, and she is told once.
    @Test func anAskWhoseLogFailsAnswersOfferedAndTellsHer() async throws {
        let twin = try await show(.offer, logFails: false)
        #expect(!twin.isError && twin.lines == ["\(MCPShowActivity.offeredAct):allowed"], "the control: \(twin.answer)")

        let broken = try await show(.offer, logFails: true)
        #expect(!broken.isError, "RED ON OLD: an ask that stands is no error — \(broken.answer)")
        #expect(broken.answer == twin.answer, "RED ON OLD: the offered answer, byte for byte the twin's")
        #expect(broken.failures == [
            MCPActivityLogFailure(clientName: "claude-code", tool: "show_in_app", unrecorded: 1, storeWords: storeWords),
        ], "RED ON OLD: the app is told once")
        #expect(broken.tail.isEmpty && broken.lines.isEmpty)
    }

    /// A GUARD (green on both trees): a REFUSED show keeps the write family's refusal-line posture —
    /// nothing landed, so a store that cannot take the refusal's line answers VX-369's store-failure
    /// sentence ("…may not have landed…", true: nothing did) and the app hears no landed-act failure.
    /// The never dial's refusal stands for every refusal arm.
    @Test func aRefusedShowKeepsTheRefusalLinesPosture() async throws {
        let broken = try await show(.refuse(MCPShowRule.neverWords), logFails: true)
        #expect(broken.isError && broken.answer.hasPrefix("Variorum's library store refused the work"),
                "the store failure, said: \(broken.answer)")
        #expect(broken.failures.isEmpty, "nothing landed, so nothing landed-but-unlogged is said to her")
        let twin = try await show(.refuse(MCPShowRule.neverWords), logFails: false)
        #expect(twin.isError && twin.answer == MCPShowRule.neverWords && twin.lines == ["show_in_app:refused"])
    }
}
