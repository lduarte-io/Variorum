import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-759 (the VX-771 run, batch 1 — PROVISIONAL P-771-1) ON THE WIRE: the field
// report's #14 — "a note whose title is its derived date ("2026-10-20")
// duplicates titled with TODAY's date and no entry_date". `duplicate_note` runs
// her Duplicate's ONE body (`duplicateAsVersionBody`), so the core fix heals the
// wire with it; this pin drives a real client over the socket and reads the
// copy's NAME where the author and the client meet it — the receipt's title
// (`Queries.mcpScopeTitle`, the one display rule) — and the copy's stored date.
// The answer's SHAPE is unchanged (it never echoed a date).
//
// RED ON OLD (run on the pre-fix tree): the receipt named the copy for the
// harness's day and its `entry_date` was NULL.

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

@Suite("VX-759 — duplicate_note keeps the day an undated source is named for", .serialized)
struct MCPDuplicateDatingServerTests {
    /// 2026-06-20T12:00:00Z — the source's birth, eleven days before the
    /// harness's own clock.
    static let bornOn = Date(timeIntervalSince1970: 1_781_956_800)

    @Test func anUndatedUntitledSourcesCopyIsNamedAndDatedAsItsSource() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let source = try h.operations.createPost(title: nil)
            _ = try h.operations.newBlock(in: source.id, text: "Morning pages.", registeringUndo: false)
            try await h.database.write { db in
                try db.execute(
                    sql: "UPDATE container SET created_at = ? WHERE id = ?",
                    arguments: [DateFormatter.variorumISO8601.string(from: Self.bornOn), source.id])
            }
            let day = JournalDay.dayString(from: Self.bornOn, calendar: JournalDay.storeCalendar)
            let sourceName = try await h.database.read { db in
                try Queries.mcpScopeTitle(db, kind: .note, id: source.id, calendar: JournalDay.storeCalendar)
            }
            #expect(sourceName == day, "the premise: the source is named for its birth day")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))

            let duplicated = try await connection.client.callTool(
                name: "duplicate_note", arguments: ["note_id": .string(source.id)])
            #expect(duplicated.isError != true, "\(text(duplicated))")
            let answer = try json(duplicated)
            let copyID = try #require(answer["note_id"] as? String)

            let stored = try await h.database.read { try Container.fetchOne($0, key: copyID) }
            #expect(stored?.entryDate == day, "the copy keeps the day its source is named for")
            #expect(stored?.title == nil, "no title is materialized")
            let receipt = try #require(h.receipts.value.last)
            #expect(receipt.targetTitle == day, "the author's receipt names the copy as its source is named")
            #expect(Set(answer.keys) == ["note_id", "source_note_id", "block_ids", "blocks", "tag_ids", "tags", "landed"],
                    "the answer's shape is unchanged — it never echoed a date")
            await h.hangUp(connection)
        }
    }
}
