import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-826 (the VX-809 run, batch 1 — her R-826, A-809-10) ON THE WIRE: the
// agent's EXACT repro — "a note whose title is just its date ('2026-11-03', the
// automatic title) still comes out re-titled with today's date" — driven as the
// agent drives it: `duplicate_note`, then `read_note` of the copy, its title
// read where the client reads it.
//
// THE VERDICT (the record's VX-826 trace): this repro is VX-759's class (an
// untitled, undated, NON-journal source — the only date-titled class the wire can
// duplicate) and is GREEN on today's tree; with VX-759's `keepingNamedDay`
// reverted it is RED (the copy read the harness's day) — so the agent's 2-of-7
// was a build without VX-759 (`3f2f650d4`), recorded as fixed by VX-759 and not
// re-fixed here. The class VX-759 left (a journal-profile source with no date —
// `DuplicateDateTitleTests`, core) never reaches the wire: `profile = 'journal'`
// is a fence leg, and the copy refuses a fenced source (pinned last).

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

@Suite("VX-826 — duplicate_note: an automatic date title's copy reads its source's title", .serialized)
struct MCPDuplicateDateTitleServerTests {
    /// 2026-06-20T12:00:00Z — eleven days before the harness's own day.
    static let bornOn = Date(timeIntervalSince1970: 1_781_956_800)

    private func backdate(_ h: ServerHarness, _ postID: String) async throws {
        try await h.database.write { db in
            try db.execute(
                sql: "UPDATE container SET created_at = ? WHERE id = ?",
                arguments: [DateFormatter.variorumISO8601.string(from: Self.bornOn), postID])
        }
    }

    private func title(_ connection: HarnessConnection, _ noteID: String) async throws -> String? {
        try json(try await connection.client.callTool(
            name: "read_note", arguments: ["note_id": .string(noteID), "with_ids": .bool(true)]))["title"] as? String
    }

    /// THE EXACT REPRO, both answer forms and the book road: the copy's title
    /// as `read_note` gives it is the source's — "2026-06-20", never the day the
    /// copy was made.
    @Test(arguments: ["full", "brief", "book"])
    func anAutomaticDateTitlesCopyReadsTheSourcesTitle(_ form: String) async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "Days", kind: .book)
            let source = try h.operations.createPost(title: nil)
            _ = try h.operations.newBlock(in: source.id, text: "Morning pages.", registeringUndo: false)
            _ = try h.operations.addPostToReading(source.id, to: book.id)
            try await backdate(h, source.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            let day = JournalDay.dayString(from: Self.bornOn, calendar: JournalDay.storeCalendar)
            #expect(try await title(connection, source.id) == day, "the premise: the automatic title")

            var arguments: [String: Value] = ["note_id": .string(source.id)]
            if form == "brief" { arguments["brief"] = .bool(true) }
            if form == "book" { arguments["book_id"] = .string(book.id) }
            let duplicated = try await connection.client.callTool(name: "duplicate_note", arguments: arguments)
            #expect(duplicated.isError != true, "\(text(duplicated))")
            let copyID = try #require(try json(duplicated)["note_id"] as? String)

            #expect(try await title(connection, copyID) == day, "the copy reads its source's title, never today's")
            await h.hangUp(connection)
        }
    }

    /// Why the journal class never reaches the wire: a journal-profile note is
    /// fenced, so even a client holding its per-ask grant hears the copy's one
    /// fence sentence, and nothing is minted.
    @Test func theJournalClassIsFencedSoTheWireNeverCopiesIt() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let entry = try h.operations.createPost(title: nil, profile: .journal)
            _ = try h.operations.newBlock(in: entry.id, text: "Dear diary.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.read, .note, entry.id, .once))
            let before = try await h.database.read { try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM container") }

            let duplicated = try await connection.client.callTool(
                name: "duplicate_note", arguments: ["note_id": .string(entry.id)])
            #expect(duplicated.isError == true && text(duplicated) == MCPWriteTools.duplicateFencedWords,
                    "\(text(duplicated))")
            #expect(try await h.database.read { try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM container") } == before)
            await h.hangUp(connection)
        }
    }
}
