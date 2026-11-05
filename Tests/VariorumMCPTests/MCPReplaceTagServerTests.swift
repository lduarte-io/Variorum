import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-812 — `replace_tag` ON THE WIRE (the VX-809 run, batch 3; her R-812:
// "'across a wing' means across the client's REACH in that wing — the sweep acts
// on and counts only what the client can see; hidden wearers of tag A are
// untouched, unmentioned and uncounted"). Every pin drives a real client over
// the socket: the sweep takes exactly the wearers of A the client may EDIT, each
// its own act (its entry, its receipt on the call's run key, its Activity line);
// a hidden wearer's application row is BYTE-IDENTICAL after; the answer counts
// the swept set only, beside the scope words in their notes form; intake hears
// B as any application, and taking A off evicts nothing; the 200 cap leaves
// `remaining`. Features: no red-on-old owed (the tool did not exist).

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

private func call(
    _ connection: HarnessConnection, _ name: String, _ arguments: [String: Value]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: name, arguments: arguments)
}

@Suite("VX-812 — replace_tag: tag A → tag B across the client's reach in a wing", .serialized)
struct MCPReplaceTagServerTests {
    private func worn(_ h: ServerHarness, _ postID: String) throws -> [String] {
        try h.database.read {
            try String.fetchAll(
                $0,
                sql: """
                    SELECT t.path FROM post_tag pt JOIN tag t ON t.id = pt.tag_id
                    WHERE pt.post_id = ? AND pt.deleted_at IS NULL ORDER BY t.path
                    """,
                arguments: [postID])
        }
    }

    /// Every column of every post_tag row of one note — the byte-identity probe.
    private func rows(_ h: ServerHarness, _ postID: String) throws -> [Row] {
        try h.database.read {
            try Row.fetchAll($0, sql: "SELECT * FROM post_tag WHERE post_id = ? ORDER BY id", arguments: [postID])
        }
    }

    private func status(_ h: ServerHarness, _ readingID: String, _ postID: String) throws -> String? {
        try h.database.read {
            try String.fetchOne(
                $0,
                sql: "SELECT status FROM reading_post WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL",
                arguments: [readingID, postID])
        }
    }

    private func tagWing(_ h: ServerHarness, _ tagID: String) throws -> String? {
        try h.database.read { try String.fetchOne($0, sql: "SELECT wing_id FROM tag WHERE id = ?", arguments: [tagID]) }
    }

    private func activityCount(_ h: ServerHarness, _ act: String) throws -> Int {
        try h.database.read {
            try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM mcp_activity WHERE act = ?", arguments: [act]) ?? 0
        }
    }

    private func tagCount(_ h: ServerHarness, path: String) throws -> Int {
        try h.database.read { try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM tag WHERE path = ?", arguments: [path]) ?? 0 }
    }

    @Test func theSweepTakesOnlyTheWearersTheClientMayEditAndLeavesHiddenRowsByteIdentical() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let studio = try h.operations.createWing(name: "Studio")
            let a = try h.operations.createTag(name: "a", wingID: studio.id)
            let byA = try h.operations.createReading(
                name: "by a", kind: .book, querySpec: try RuleGrammar.encode(.tag(a.id)), wingId: studio.id)
            var notes: [Container] = []
            for title in ["one", "two"] {
                let note = try h.operations.createPost(title: title, wingId: studio.id)
                _ = try h.operations.applyTag(a.id, toPost: note.id)
                notes.append(note)
            }
            // Hidden wearers: a PRIVATE note, and a note in the wing the client
            // may only READ (a note grant at read).
            let hidden = try h.operations.createPost(title: "hidden", wingId: studio.id)
            _ = try h.operations.applyTag(a.id, toPost: hidden.id)
            _ = try h.operations.setNotePrivate(hidden.id, true)
            let readOnly = try h.operations.createPost(title: "read only", wingId: "")
            let homeA = try h.operations.createTag(name: "a")
            _ = try h.operations.applyTag(homeA.id, toPost: readOnly.id)
            let hiddenBefore = try rows(h, hidden.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, studio.id))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.read, .note, readOnly.id))

            let result = try await call(connection, "replace_tag",
                                        ["wing_id": .string(studio.id), "tag": .string("#a"), "with": .string("b/c")])
            #expect(result.isError != true, "\(text(result))")
            let answer = try json(result)
            #expect(answer["replaced"] as? [String] == notes.map(\.id), "creation order, the editable wearers only")
            #expect(answer["replaced_count"] as? Int == 2 && answer["refused_count"] as? Int == 0
                    && answer["remaining"] as? Int == 0)
            #expect(answer["tag"] as? String == "a" && answer["with"] as? String == "b/c")
            #expect(answer[MCPWriteTools.beyondReachKey] as? String == MCPWriteTools.beyondReachNotesWords)
            let b = try #require(answer["with_tag_id"] as? String)
            #expect(try tagWing(h, b) == studio.id, "B minted in the wing by its path")
            for note in notes { #expect(try worn(h, note.id) == ["b/c"]) }
            #expect(try rows(h, hidden.id) == hiddenBefore, "a hidden wearer's rows are byte-identical")
            #expect(try worn(h, readOnly.id) == ["a"], "another wing's same-path tag is never swept")
            // A off is a non-event: the book A brought them into keeps them.
            for note in notes { #expect(try status(h, byA.id, note.id) == "member") }
            // Per note: an entry, a receipt on the ONE run key, an Activity line.
            #expect(h.undoStack.depth == 2 && h.undoStack.topLabel == "claude-code's tag replacement")
            let receipts = h.receipts.value
            #expect(receipts.map(\.act) == [.tagReplace, .tagReplace])
            #expect(receipts[0].runKey != nil && receipts[0].runKey == receipts[1].runKey)
            #expect(receipts[0].detail == "a" && receipts[0].replacementPath == "b/c")
            #expect(try activityCount(h, "replace_tag") == 2)
            // ⌥⌘Z walks the notes back one at a time.
            _ = try h.undoStack.undo(with: h.writeOperations)
            #expect(try worn(h, notes[1].id) == ["a"] && worn(h, notes[0].id) == ["b/c"])
            await h.hangUp(connection)
        }
    }

    /// Intake hears B as any application — a plain book seats, a Private one's
    /// would-be seat bells (A-809-11's wire hand).
    @Test func intakeHearsTheNewTag() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let a = try h.operations.createTag(name: "a")
            let b = try h.operations.createTag(name: "b")
            let byB = try h.operations.createReading(name: "by b", kind: .book, querySpec: try RuleGrammar.encode(.tag(b.id)))
            let diary = try h.operations.createReading(name: "diary", kind: .book, querySpec: try RuleGrammar.encode(.tag(b.id)))
            _ = try h.operations.setBookPrivate(diary.id, true)
            let note = try h.operations.createPost(title: "n")
            _ = try h.operations.applyTag(a.id, toPost: note.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let result = try await call(connection, "replace_tag",
                                        ["wing_id": .string(""), "tag": .string("a"), "with": .string("b")])
            #expect(result.isError != true, "\(text(result))")
            #expect(try status(h, byB.id, note.id) == "member")
            #expect(try status(h, diary.id, note.id) == "arrival")
            await h.hangUp(connection)
        }
    }

    /// A tag no note in reach wears — absent, or worn only beyond reach —
    /// answers the empty sweep, byte-identical, and mints nothing.
    @Test func aTagWornOnlyBeyondReachAnswersExactlyAsAMissingOne() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let secret = try h.operations.createTag(name: "secret")
            let hidden = try h.operations.createPost(title: "hidden")
            _ = try h.operations.applyTag(secret.id, toPost: hidden.id)
            _ = try h.operations.setNotePrivate(hidden.id, true)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let worn = try await call(connection, "replace_tag",
                                      ["wing_id": .string(""), "tag": .string("secret"), "with": .string("fresh")])
            let missing = try await call(connection, "replace_tag",
                                         ["wing_id": .string(""), "tag": .string("nowhere"), "with": .string("fresh")])
            #expect(worn.isError != true && missing.isError != true)
            #expect(text(worn).replacingOccurrences(of: "\"secret\"", with: "\"nowhere\"") == text(missing))
            #expect(try json(worn)["with_tag_id"] is NSNull)
            #expect(try tagCount(h, path: "fresh") == 0, "nothing applied, nothing minted")
            #expect(h.undoStack.depth == 0 && h.receipts.value.isEmpty)
            await h.hangUp(connection)
        }
    }

    /// The cap: 200 notes a call, oldest first; `remaining` counts the rest the
    /// client could edit, and the next call sweeps them.
    @Test func theCapLeavesRemainingForTheNextCall() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let a = try h.operations.createTag(name: "a")
            for index in 0...MCPWriteTools.listCap {
                let note = try h.operations.createPost(title: "n\(index)")
                _ = try h.operations.applyTag(a.id, toPost: note.id)
            }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let first = try await call(connection, "replace_tag",
                                       ["wing_id": .string(""), "tag": .string("a"), "with": .string("b")])
            #expect(try json(first)["replaced_count"] as? Int == MCPWriteTools.listCap)
            #expect(try json(first)["remaining"] as? Int == 1)
            let second = try await call(connection, "replace_tag",
                                        ["wing_id": .string(""), "tag": .string("a"), "with": .string("b")])
            #expect(try json(second)["replaced_count"] as? Int == 1 && json(second)["remaining"] as? Int == 0)
            await h.hangUp(connection)
        }
    }

    @Test func theArgumentsRefuseInWords() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            for (args, words) in [
                (["wing_id": .string(""), "tag": .string("a"), "with": .string("#a")] as [String: Value],
                 MCPWriteTools.sameTagWords),
                (["tag": .string("a"), "with": .string("b")], "wing_id is required (\"\" is Home)."),
                (["wing_id": .string(""), "tag": .string("//"), "with": .string("b")],
                 "tag must be a tag path \u{2014} names joined by /, e.g. \"percy/pt-en\"."),
            ] {
                let result = try await call(connection, "replace_tag", args)
                #expect(result.isError == true && text(result) == words, "\(text(result))")
            }
            await h.hangUp(connection)
        }
    }
}
