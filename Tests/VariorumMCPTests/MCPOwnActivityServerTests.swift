import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-261 (VX-336 U7 — the run record `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md`,
// U7 UNIT RECORD D-261-1…8 and THE ORCHESTRATOR'S RULINGS ON U7's FORKS): A CLIENT
// READS ITS OWN RECENT ACTS. After a dropped call, or when its own context is lost
// mid-job, an agent had no way to learn whether a call landed. `list_my_activity`
// answers the activity log's rows for the CALLER'S client name, since its current
// approval (P-VX261-1), newest first — each row exactly as logged (the tool, allowed
// or refused, when, the target it named, and on an allowed row the title it was
// told), never the CURRENT state of a target (D-261-4, the oracle rule). Listed for
// every approved client with no grant (P-VX261-2: recovery after a dropped "until you
// disconnect" grant is the case it exists for); refused rows listed, never titled
// (P-VX261-3); a creating act's row names its place (P-VX261-4); reads join only with
// include_reads (F-261-5 (a)); connection rows and the tool's own rows never list.
// The row classes whose logged target is NOT an id the client sent answer without
// `target_*` when refused — `duplicate_note`'s wing side (P-VX261-5 (b), ruled) and,
// builder A's PROVISIONAL extension P-VX261-6, the chapter acts and `delete_take`
// (their refused rows log a RESOLVED book / block, which as logged would tell a
// hidden chapter or take from a missing one).
//
// Wire only (the SDK's own client over a real socket); the tool is named by its
// string, so every pin compiles on the tree before it and runs RED there by absence
// ("Unknown tool: list_my_activity.").

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: .always)
}

private func call(
    _ connection: HarnessConnection, _ name: String, _ arguments: [String: Value] = [:]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: name, arguments: arguments)
}

/// `list_my_activity`'s answer.
private func activity(
    _ connection: HarnessConnection, _ arguments: [String: Value] = [:]
) async throws -> [String: Any] {
    let answered = try await call(connection, "list_my_activity", arguments)
    #expect(answered.isError != true, "\(text(answered))")
    return try json(answered)
}

private func acts(_ answer: [String: Any]) -> [[String: Any]] {
    answer["acts"] as? [[String: Any]] ?? []
}

/// An entry with the named keys taken out (`at` differs call to call — the
/// harness clock ticks per read of it).
private func without(_ entry: [String: Any], _ keys: Set<String>) -> NSDictionary {
    NSDictionary(dictionary: entry.filter { !keys.contains($0.key) })
}

@Suite("VX-261 — list_my_activity: a client reads its own recent acts, as logged", .serialized)
struct MCPOwnActivityServerTests {
    private func logRows(_ h: ServerHarness, _ act: String) async throws -> [MCPActivityRow] {
        try await h.database.read { try Queries.mcpActivity($0) }.filter { $0.act == act }
    }

    // MARK: - What lists (P-261-1…3)

    /// P-261-1: a `create_note` into a book and an `edit_take` list newest
    /// first, each as logged — the creating act naming its PLACE (P-VX261-4)
    /// with the made note's title, the edit its take.
    @Test func theClientsActsListNewestFirstExactlyAsLogged() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "o ladr\u{00E3}o de raios", kind: .book)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let created = try json(try await call(connection, "create_note", [
                "book_id": .string(book.id), "title": .string("Cap\u{00ED}tulo 11"), "text": .string("Ol\u{00E1}."),
            ]))
            let block = try #require((created["blocks"] as? [[String: Any]])?.first)
            let take = try #require(block["shown_take_id"] as? String)
            let edited = try await call(connection, "edit_take", [
                "take_id": .string(take), "text": .string("Ol\u{00E1}!"), "expected_text": .string("Ol\u{00E1}."),
            ])
            #expect(edited.isError != true, "\(text(edited))")

            let listed = acts(try await activity(connection))
            #expect(listed.map { $0["tool"] as? String } == ["edit_take", "create_note"], "newest first")
            let editRow = try #require(try await logRows(h, "edit_take").first)
            let createRow = try #require(try await logRows(h, "create_note").first)
            #expect(without(listed[0], []) == NSDictionary(dictionary: [
                "tool": "edit_take", "outcome": "allowed", "at": editRow.at,
                "target_kind": "take", "target_id": take, "title": "Cap\u{00ED}tulo 11",
            ]))
            #expect(without(listed[1], []) == NSDictionary(dictionary: [
                "tool": "create_note", "outcome": "allowed", "at": createRow.at,
                "target_kind": "book", "target_id": book.id, "title": "Cap\u{00ED}tulo 11",
            ]), "a creating act names its place, with what it made's title")
            await h.hangUp(connection)
        }
    }

    /// P-261-2: another client's rows never list.
    @Test func anotherClientsActsNeverList() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let mine = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            let theirs = try await h.connect(as: "codex")
            _ = try h.approve("codex", spec(.writeNew, .wing, ""))
            _ = try await call(theirs, "create_note", ["wing_id": .string(""), "title": .string("theirs"), "text": .string("x")])
            _ = try await call(mine, "create_note", ["wing_id": .string(""), "title": .string("mine"), "text": .string("y")])
            let listed = acts(try await activity(mine))
            #expect(listed.map { $0["title"] as? String } == ["mine"])
            #expect(acts(try await activity(theirs)).map { $0["title"] as? String } == ["theirs"])
            await h.hangUp(mine)
            await h.hangUp(theirs)
        }
    }

    /// P-261-3: connection-admission rows under the name are not the client's
    /// acts (some are a stranger's attempts; two carry a replaced key's hash).
    @Test func connectionRowsUnderTheNameNeverList() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", nil)
            try await h.database.write { db in
                for act in ["connect_rebound", "connect_not_this_names_key", MCPSetupKeyRule.awaitingAct,
                            MCPSetupKeyRule.rebindAllowedAct] {
                    try h.operations.recordMCPActivity(
                        db, clientName: "claude-code", act: act, targetKind: "key", targetID: "a-hash",
                        targetTitle: nil, allowed: act == "connect_rebound")
                }
            }
            #expect(acts(try await activity(connection, ["include_reads": .bool(true)])).isEmpty)
            await h.hangUp(connection)
        }
    }

    // MARK: - The oracle (P-261-4, P-261-5, P-261-11, P-VX261-6)

    /// P-261-4: a refused read on an existing note it can't reach and one on a
    /// missing id answer the same entry — the id it sent, no title: the one
    /// not-shared shape, carried into the log.
    @Test func aRefusedActOnAHiddenTargetListsAsOneOnAMissingID() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let shared = try h.operations.createPost(title: "shared")
            let hidden = try h.operations.createPost(title: "her secret title")
            _ = try h.operations.newBlock(in: hidden.id, text: "secret words", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, shared.id))
            #expect(try await call(connection, "read_note", ["note_id": .string(hidden.id)]).isError == true)
            #expect(try await call(connection, "read_note", ["note_id": "no-such-note"]).isError == true)
            let answer = try await activity(connection, ["include_reads": .bool(true)])
            #expect(!(String(data: try JSONSerialization.data(withJSONObject: answer), encoding: .utf8) ?? "")
                .contains("secret"), "no title of what it can't reach")
            let listed = acts(answer)
            #expect(listed.count == 2)
            #expect(listed.map { $0["target_id"] as? String } == ["no-such-note", hidden.id], "the ids it sent")
            #expect(listed.allSatisfy { $0["title"] == nil }, "a refused row is never titled")
            #expect(without(listed[0], ["at", "target_id"]) == without(listed[1], ["at", "target_id"]),
                    "hidden and missing answer the same entry")
            await h.hangUp(connection)
        }
    }

    /// P-VX261-6 (builder A's PROVISIONAL, extending P-VX261-5 (b)'s rule):
    /// the chapter acts log the chapter's BOOK and `delete_take` a last take's
    /// BLOCK — ids the client never sent, resolved even when it can't reach
    /// them. Their refused rows answer without `target_*`, so a hidden chapter
    /// or take lists exactly as a missing id does.
    @Test func refusedRowsLoggingAResolvedTargetAnswerNoTarget() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let shared = try h.operations.createPost(title: "shared")
            let hiddenBook = try h.operations.createReading(name: "her hidden book", kind: .book)
            let hiddenChapter = try h.operations.createSection(in: hiddenBook.id, name: "um")
            let hiddenNote = try h.operations.createPost(title: "hidden")
            let lastTake = try h.operations.newBlock(in: hiddenNote.id, text: "only take", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, shared.id))
            for (tool, key, ids) in [
                ("rename_chapter", "section_id", [hiddenChapter.id, "no-such-chapter"]),
                ("delete_take", "take_id", [lastTake.variant.id, "no-such-take"]),
            ] {
                for id in ids {
                    var arguments: [String: Value] = [key: .string(id)]
                    if tool == "rename_chapter" { arguments["name"] = "dois" }
                    #expect(try await call(connection, tool, arguments).isError == true)
                }
            }
            let listed = acts(try await activity(connection))
            #expect(listed.map { $0["tool"] as? String } == ["delete_take", "delete_take", "rename_chapter", "rename_chapter"])
            for entry in listed {
                #expect(Set(entry.keys) == ["tool", "outcome", "at"], "no target the client never sent: \(entry)")
            }
            #expect(without(listed[0], ["at"]) == without(listed[1], ["at"]))
            #expect(without(listed[2], ["at"]) == without(listed[3], ["at"]))
            await h.hangUp(connection)
        }
    }

    /// P-261-11 (P-VX261-5 (b), ruled): `duplicate_note`'s wing-side refusal
    /// logs the source's RESOLVED wing — an id the client never sent — so its
    /// entry omits `target_*`; the note-side refusal keeps the note it sent.
    @Test func duplicateNotesWingSideRefusalAnswersNoTarget() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "readable")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, note.id))
            #expect(try await call(connection, "duplicate_note", ["note_id": .string(note.id)]).isError == true)
            #expect(try await call(connection, "duplicate_note", ["note_id": "no-such-note"]).isError == true)
            let logged = try await logRows(h, "duplicate_note")
            #expect(logged.map(\.targetKind) == ["note", "wing"], "the log keeps both sides, for her pane")
            let listed = acts(try await activity(connection))
            #expect(listed.count == 2)
            #expect(Set(listed[0].keys) == ["tool", "outcome", "at", "target_kind", "target_id"])
            #expect(listed[0]["target_id"] as? String == "no-such-note")
            #expect(Set(listed[1].keys) == ["tool", "outcome", "at"], "the wing side names no wing: \(listed[1])")
            await h.hangUp(connection)
        }
    }

    /// P-261-5: an allowed row's title is the one it was told at act time —
    /// a rename and then a delete of the note leave the entry unchanged.
    @Test func anAllowedRowsTitleIsActTimeNeverCurrent() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "before")
            let one = try h.operations.newBlock(in: note.id, text: "words", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.suggest, .wing, ""))
            #expect(try await call(connection, "add_take", ["block_id": .string(one.block.id), "text": "more"]).isError != true)
            let first = try #require(acts(try await activity(connection)).first)
            #expect(first["title"] as? String == "before")
            try h.operations.renameContainer(note.id, title: "after")
            let renamed = try #require(acts(try await activity(connection)).first)
            try h.operations.deleteContainer(note.id)
            let deleted = try #require(acts(try await activity(connection)).first)
            #expect(without(renamed, []) == without(first, []), "a rename changes nothing listed")
            #expect(without(deleted, []) == without(first, []), "nor does the note's deletion")
            await h.hangUp(connection)
        }
    }

    // MARK: - Who may read (P-261-6, P-261-7)

    /// P-261-6: after Deny and re-approval the name starts with no history —
    /// rows from before its current approval never list.
    @Test func afterDenyAndReapprovalEarlierRowsNeverList() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            _ = try await call(connection, "create_note", ["wing_id": .string(""), "title": .string("old"), "text": .string("x")])
            #expect(acts(try await activity(connection)).count == 1)
            try h.operations.denyMCPClient(try h.client("claude-code").id)
            _ = try await call(connection, "read_note", ["note_id": "while-denied"])
            _ = try h.approve("claude-code", nil)
            _ = try await call(connection, "read_note", ["note_id": "after-approval"])
            let listed = acts(try await activity(connection, ["include_reads": .bool(true)]))
            #expect(listed.map { $0["target_id"] as? String } == ["after-approval"], "\(listed)")
            await h.hangUp(connection)
        }
    }

    /// P-261-7: an approved client with ZERO grants is offered the tool and
    /// answered; pending and denied clients hear their own sentences; a setup
    /// waiting for her OK hears the pending sentence.
    @Test func approvedWithNoGrantsItIsListedAndAnsweredOthersHearTheirStanding() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let pending = try await h.connect(as: "stranger")
            #expect(try await pending.client.listTools().tools.isEmpty, "a request reaches nothing")
            let asked = try await call(pending, "list_my_activity")
            #expect(asked.isError == true && text(asked) == MCPRefusalCopy.words(.clientPending, .note))

            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", nil)
            #expect(try await connection.client.listTools().tools.map(\.name) == ["list_my_activity"],
                    "approval alone offers only the client's own history")
            #expect(acts(try await activity(connection)).isEmpty)
            try h.operations.denyMCPClient(try h.client("claude-code").id)
            let denied = try await call(connection, "list_my_activity")
            #expect(denied.isError == true && text(denied) == MCPRefusalCopy.words(.clientDenied, .note))
            #expect(try await connection.client.listTools().tools.isEmpty)
            await h.hangUp(connection)
            await h.hangUp(pending)

            // A setup waiting for her OK (VX-258) hears the pending sentence.
            let real = try await h.connect(as: "codex")
            _ = try h.approve("codex", nil)
            await h.hangUp(real)
            #expect(try await h.eventually { !h.host.connectedClientNames.contains("codex") })
            let waiting = try await h.connect(as: "codex", presenting: try h.operations.mintMCPSetupKey())
            #expect(try await waiting.client.listTools().tools.isEmpty)
            let heard = try await call(waiting, "list_my_activity")
            #expect(heard.isError == true && text(heard) == MCPRefusalCopy.words(.clientPending, .note))
            await h.hangUp(waiting)
        }
    }

    // MARK: - The answer's shape (P-261-8, P-261-9)

    /// P-261-8: reads list only with include_reads; the tool's own rows never.
    @Test func readsJoinOnlyWhenAskedAndItsOwnRowsNever() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "n")
            let one = try h.operations.newBlock(in: note.id, text: "w", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.suggest, .wing, ""))
            _ = try await call(connection, "read_note", ["note_id": .string(note.id)])
            _ = try await call(connection, "list_notes")
            _ = try await call(connection, "add_take", ["block_id": .string(one.block.id), "text": "t"])
            _ = try await activity(connection)
            #expect(acts(try await activity(connection)).map { $0["tool"] as? String } == ["add_take"])
            let all = acts(try await activity(connection, ["include_reads": .bool(true)]))
            #expect(all.map { $0["tool"] as? String } == ["add_take", "list_notes", "read_note"])
            #expect(try await logRows(h, "list_my_activity").count == 3, "it is logged like every read")
            await h.hangUp(connection)
        }
    }

    /// P-261-9: `limit` and `next_cursor` tile the rows; a cursor it did not
    /// mint answers the stale sentence.
    @Test func pagesTileTheRowsAndAForeignCursorIsStale() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "n")
            let one = try h.operations.newBlock(in: note.id, text: "w", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.suggest, .wing, ""))
            for index in 0..<5 {
                _ = try await call(connection, "add_take", ["block_id": .string(one.block.id), "text": .string("t\(index)")])
            }
            let whole = acts(try await activity(connection))
            #expect(whole.count == 5)
            var pages: [[[String: Any]]] = []
            var cursor: String?
            repeat {
                var arguments: [String: Value] = ["limit": 2]
                if let cursor { arguments["cursor"] = .string(cursor) }
                let page = try await activity(connection, arguments)
                pages.append(acts(page))
                cursor = page["next_cursor"] as? String
            } while cursor != nil && pages.count < 10
            #expect(pages.map(\.count) == [2, 2, 1], "next_cursor only while rows remain")
            #expect(pages.flatMap { $0 }.map { without($0, []) } == whole.map { without($0, []) })
            for foreign in ["not-a-cursor", Data("r\n2026\nx".utf8).base64EncodedString()] {
                let stale = try await call(connection, "list_my_activity", ["cursor": .string(foreign)])
                #expect(stale.isError == true && text(stale) == "cursor is not a next_cursor this server returned.")
            }
            await h.hangUp(connection)
        }
    }
}
