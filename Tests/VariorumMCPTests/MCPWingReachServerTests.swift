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

    // MARK: - R-AIR-12: gatherings, read facts under a wing grant

    /// The wing "variorum": a gathering of #parser notes, two plain members, a
    /// PRIVATE member (fenced — it must never list or count), a book.
    private struct Gathered {
        let wing: Wing
        let gathering: Reading
        let book: Reading
        let plain: [Container]
        let fenced: Container
    }

    private func gathered(_ h: ServerHarness) throws -> Gathered {
        let wing = try h.operations.createWing(name: "variorum")
        let parser = try h.operations.createTag(name: "parser", wingID: wing.id)
        let gathering = try h.operations.createReading(
            name: "parser things", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(parser.id)),
            wingId: wing.id)
        let book = try h.operations.createReading(name: "launch notes", kind: .book, wingId: wing.id)
        var plain: [Container] = []
        for (title, words) in [("lexer", "the lexer reads quillwort"), ("grammar", "the grammar")] {
            let note = try h.operations.createPost(title: title, wingId: wing.id)
            _ = try h.operations.newBlock(in: note.id, text: words, registeringUndo: false)
            try h.operations.applyTag(parser.id, toPost: note.id)
            plain.append(note)
        }
        let fenced = try h.operations.createPost(title: "private parser", wingId: wing.id)
        _ = try h.operations.newBlock(in: fenced.id, text: "marshlantern secrets", registeringUndo: false)
        try h.operations.applyTag(parser.id, toPost: fenced.id)
        try h.operations.setNotePrivate(fenced.id, true)
        return Gathered(wing: wing, gathering: gathering, book: book, plain: plain, fenced: fenced)
    }

    /// A stale Private stamp on a reading, written as a synced row would land
    /// (a sync write — the async overload would win inside the test bodies).
    private func stampPrivate(_ h: ServerHarness, _ readingID: String) throws {
        try h.database.write { db in
            try db.execute(sql: "UPDATE reading SET ai_private_at = '2026-07-01T00:00:00.000Z' WHERE id = ?",
                           arguments: [readingID])
        }
    }

    private func books(_ result: (content: [Tool.Content], isError: Bool?)) throws -> [[String: Any]] {
        try #require(try json(result)["books"] as? [[String: Any]])
    }

    private func noteIDs(_ result: (content: [Tool.Content], isError: Bool?)) throws -> [String] {
        try #require(try json(result)["notes"] as? [[String: Any]]).compactMap { $0["id"] as? String }
    }

    @Test func aWingGrantReadsItsGatheringsAndNoOtherGrantDoes() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let app = FakeApp()
        h.host.hooks.show = app.hook
        try await h.within {
            let g = try gathered(h)
            let connection = try await h.connect(as: "claude-code")
            let bookGrant = try #require(try h.approve("claude-code", spec(.edit, .book, g.book.id)))
            let client = try h.client("claude-code").id
            let gatheringID: [String: Value] = ["book_id": .string(g.gathering.id)]

            // A book grant (even at edit) and a note grant never reach it.
            #expect(try books(try await call(connection, "list_books", [:])).map { $0["id"] as? String }
                    == [g.book.id], "a gathering is not a book grant's reach")
            let refusedList = try await call(connection, "list_notes", gatheringID)
            #expect(refusedList.isError == true && text(refusedList) == MCPRefusalCopy.words(.notShared, .book))
            try h.operations.revokeMCPGrant(bookGrant)
            let noteGrant = try h.operations.grantMCPAccess(client, spec(.edit, .note, g.plain[0].id))
            #expect(try await call(connection, "list_notes", gatheringID).isError == true)
            try h.operations.revokeMCPGrant(noteGrant)
            #expect(h.asks.value.isEmpty, "no ask is ever raised for a gathering — it is no grant's scope")

            // A wing grant reads it — listed beside the book, honestly counted.
            _ = try h.operations.grantMCPAccess(client, spec(.read, .wing, g.wing.id))
            let listed = try books(try await call(connection, "list_books", [:]))
            #expect(Set(listed.map { $0["id"] as? String }) == [g.book.id, g.gathering.id])
            let entry = try #require(listed.first { $0["id"] as? String == g.gathering.id })
            #expect(entry["kind"] as? String == "gathering" && entry["notes"] as? Int == 2,
                    "the Private member never counts")
            #expect(listed.first { $0["id"] as? String == g.book.id }?["kind"] as? String == "book")
            #expect((entry["rule"] as? [String: Any])?["tag"] as? String == "parser", "how it gathers")
            #expect(Set(try noteIDs(try await call(connection, "list_notes", gatheringID))) == Set(g.plain.map(\.id)),
                    "its assembly, every member through the per-note fence")

            // Paged in its own order, on its own cursor.
            let first = try json(try await call(connection, "list_notes",
                                                gatheringID.merging(["limit": .int(1)]) { $1 }))
            let cursor = try #require(first["next_cursor"] as? String)
            let second = try await call(connection, "list_notes",
                                        gatheringID.merging(["limit": .int(1), "cursor": .string(cursor)]) { $1 })
            #expect(Set(try noteIDs(second) + ((first["notes"] as? [[String: Any]])?.compactMap { $0["id"] as? String } ?? []))
                    == Set(g.plain.map(\.id)))
            let crossed = try await call(connection, "list_notes",
                                         ["book_id": .string(g.book.id), "cursor": .string(cursor)])
            #expect(text(crossed) == MCPReadTools.staleCursorMessage, "a gathering's cursor never pages a book")

            // Searched in its own scope — the Private member's words never answer.
            let hidden = try json(try await call(connection, "search",
                                                 ["query": .string("marshlantern"), "book_id": .string(g.gathering.id)]))
            #expect((hidden["passages"] as? [Any])?.isEmpty == true)
            let found = try json(try await call(connection, "search",
                                                ["query": .string("quillwort"), "book_id": .string(g.gathering.id)]))
            #expect((found["passages"] as? [[String: Any]])?.compactMap { $0["note_id"] as? String } == [g.plain[0].id])

            // Shown as her doors open it.
            let shown = try await call(connection, "show_in_app",
                                       ["target": .string("book"), "book_id": .string(g.gathering.id)])
            #expect(shown.isError != true && app.delivered.value.last == .book(bookID: g.gathering.id, sectionID: nil))

            // A FENCED gathering (a stale Private stamp — no op mints one, a
            // synced row could) is admitted by the wing grant's listing and
            // refused by the rule (the U6-5 mutation M7 found this case
            // missing: the listing's prefilter alone had kept it honest).
            try stampPrivate(h, g.gathering.id)
            #expect(!(try books(try await call(connection, "list_books", [:]))).contains {
                $0["id"] as? String == g.gathering.id
            }, "a fenced gathering never lists")
            let fencedList = try await call(connection, "list_notes", gatheringID)
            #expect(fencedList.isError == true && text(fencedList) == MCPRefusalCopy.words(.notShared, .book))
            await h.hangUp(connection)
        }
    }

    @Test func aGatheringStaysNoGrantsScopeAndNoWritesTarget() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let g = try gathered(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, g.wing.id))
            let client = try h.client("claude-code").id
            #expect(throws: (any Error).self, "no grant names a gathering") {
                try h.operations.grantMCPAccess(client, spec(.read, .book, g.gathering.id))
            }
            h.asks.setValue([])
            let write = try await call(connection, "create_note",
                                       ["text": .string("into a gathering"), "book_id": .string(g.gathering.id)])
            #expect(write.isError == true && text(write) == MCPRefusalCopy.words(.notShared, .book),
                    "a write into a gathering answers as a book that isn't there, under a wing EDIT grant")
            let add = try await call(connection, "add_note_to_book",
                                     ["note_id": .string(g.plain[1].id), "book_id": .string(g.gathering.id)])
            #expect(add.isError == true)
            #expect(h.asks.value.isEmpty)

            // Archived: out of the listing, and assembling nothing, when asked.
            try h.operations.archiveReading(g.gathering.id)
            let resting = try books(try await call(connection, "list_books", [:]))
            #expect(!resting.contains { $0["id"] as? String == g.gathering.id })
            let archived = try books(try await call(connection, "list_books", ["include_archived": .bool(true)]))
            #expect(archived.first { $0["id"] as? String == g.gathering.id }?["notes"] as? Int == 0,
                    "an archived gathering assembles empty")
            await h.hangUp(connection)
        }
    }
}
