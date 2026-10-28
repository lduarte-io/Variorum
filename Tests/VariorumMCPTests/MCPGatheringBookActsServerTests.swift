import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-639 — A GATHERING GETS A BOOK's ACTS AT EDIT; THE RULE STAYS HERS (the VX-648
// run, batch 2; her ruling 2026-10-28, QUESTIONS #245 RB-7: "we literally just built
// set_starred for notes, so why is it not allowed to do it on a gathering?" → book
// parity at the edit rung, the rule staying hers). At EDIT on the gathering PLACE —
// its own grant or its wing's — `rename_book`, `archive_book` / `unarchive_book`,
// `delete_book` and `set_starred` act on a gathering exactly as on a book: her
// doors' bodies, ONE client-named undo each, in words that say "gathering". What a
// gathering can't take — a finish, a note taken out or moved, its RULE — answers the
// reworded gathering sentence where the client can read it (A-648-5 for the rule),
// the one shape where it can't. Every call keeps the hers-alone trio byte-identical.
// RED ON OLD: every act on a gathering answered the old gathering sentence.

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

private func call(
    _ h: ServerHarness, _ connection: HarnessConnection, _ name: String, _ arguments: [String: Value],
    sourceLocation: SourceLocation = #_sourceLocation
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await callKeepingHersAlone(h, connection, name, arguments, sourceLocation: sourceLocation)
}

@Suite("VX-639 — a gathering takes a book's acts at edit; its rule stays hers", .serialized)
struct MCPGatheringBookActsServerTests {
    private func reading(_ h: ServerHarness, _ id: String) throws -> Reading {
        try #require(try h.database.read { try Reading.fetchOne($0, key: id) })
    }

    private func gathering(_ h: ServerHarness, _ name: String = "gathered", wing: String = "") throws -> Reading {
        let tag = try h.operations.createTag(name: "percy-\(name)", wingID: wing)
        return try h.operations.createReading(
            name: name, kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)), wingId: wing)
    }

    private func activity(_ h: ServerHarness, _ act: String) throws -> [Row] {
        try h.database.read {
            try Row.fetchAll($0, sql: "SELECT * FROM mcp_activity WHERE act = ? ORDER BY id", arguments: [act])
        }
    }

    private func starred(_ h: ServerHarness) throws -> [StarTarget] {
        try h.database.read { try Queries.starred($0).map(\.target) }
    }

    /// Its OWN grant at edit: the four acts and the star listed and landing,
    /// each one client-named entry in a gathering's words, each undone.
    @Test func aGatheringsOwnEditGrantTakesTheBooksActsEachOneNamedUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let place = try gathering(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .gathering, place.id))
            let listed = Set(try await connection.client.listTools().tools.map(\.name))
            #expect(listed.isSuperset(of: ["rename_book", "archive_book", "unarchive_book", "delete_book", "set_starred"]),
                    "a gathering grant at edit lists the acts it can take")
            #expect(!listed.contains("finish_book") && !listed.contains("set_book_rule"))

            // rename_book
            let renamed = try await call(h, connection, "rename_book",
                                         ["book_id": .string(place.id), "name": .string("percy, gathered")])
            #expect(renamed.isError != true, "\(text(renamed))")
            #expect(try json(renamed)["name"] as? String == "percy, gathered")
            #expect(try reading(h, place.id).name == "percy, gathered" && reading(h, place.id).kind == .gathering)
            #expect(h.undoStack.topLabel == "claude-code's gathering name")
            #expect(h.receipts.value.last?.act == .gatheringName)
            let row = try #require(try activity(h, "rename_book").last)
            #expect(row["target_kind"] as String == "gathering" && row["outcome"] as String == "allowed")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's gathering name")
            #expect(try reading(h, place.id).name == "gathered")

            // set_starred — its own star, her union star (both stores).
            let star = try await call(h, connection, "set_starred",
                                      ["book_id": .string(place.id), "starred": .bool(true)])
            #expect(star.isError != true, "\(text(star))")
            #expect(try starred(h) == [.reading(place.id)] && reading(h, place.id).starred)
            #expect(h.undoStack.topLabel == "claude-code's star")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's star")
            #expect(try starred(h).isEmpty && !reading(h, place.id).starred)

            // archive_book / unarchive_book
            let archived = try await call(h, connection, "archive_book", ["book_id": .string(place.id)])
            #expect(archived.isError != true, "\(text(archived))")
            #expect(try reading(h, place.id).archivedAt != nil)
            #expect(h.undoStack.topLabel == "claude-code's gathering archiving")
            #expect(h.receipts.value.last?.act == .gatheringArchive)
            let unarchived = try await call(h, connection, "unarchive_book", ["book_id": .string(place.id)])
            #expect(unarchived.isError != true, "\(text(unarchived))")
            #expect(try reading(h, place.id).archivedAt == nil)
            #expect(h.undoStack.topLabel == "claude-code's gathering unarchiving")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's gathering unarchiving")
            #expect(try reading(h, place.id).archivedAt != nil, "its unarchive undone: archived again")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's gathering archiving")
            #expect(try reading(h, place.id).archivedAt == nil)

            // delete_book — the Trash; one undo brings it back.
            let deleted = try await call(h, connection, "delete_book", ["book_id": .string(place.id)])
            #expect(deleted.isError != true, "\(text(deleted))")
            let answer = try json(deleted)
            #expect(answer["deleted"] as? Bool == true && answer["notes_released"] as? Bool == false)
            #expect(try reading(h, place.id).deletedAt != nil)
            #expect(h.undoStack.topLabel == "claude-code's gathering deletion")
            #expect(h.receipts.value.last?.act == .gatheringDelete)
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's gathering deletion")
            #expect(try reading(h, place.id).deletedAt == nil && reading(h, place.id).kind == .gathering)
            await h.hangUp(connection)
        }
    }

    /// Its WING's edit grant reaches it the same way (MB-16's place reach).
    @Test func aWingEditGrantReachesItsGatherings() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let place = try gathering(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let renamed = try await call(h, connection, "rename_book",
                                         ["book_id": .string(place.id), "name": .string("by the wing")])
            #expect(renamed.isError != true, "\(text(renamed))")
            #expect(try reading(h, place.id).name == "by the wing")
            #expect(h.undoStack.depth == 1)
            await h.hangUp(connection)
        }
    }

    /// Below edit on the gathering: the rung's refusal, an ask for edit ON THE
    /// GATHERING, nothing changed.
    @Test func belowEditTheRungRefusesAndTheAskNamesTheGathering() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let place = try gathering(h)
            let before = try reading(h, place.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .gathering, place.id))
            for (tool, extra): (String, [String: Value]) in [
                ("rename_book", ["name": .string("x")]), ("archive_book", [:]), ("delete_book", [:]),
            ] {
                let refused = try await call(h, connection, tool, ["book_id": .string(place.id)].merging(extra) { $1 })
                #expect(refused.isError == true
                        && text(refused).hasPrefix("This client may only read, suggest and write new here."),
                        "\(tool): \(text(refused))")
            }
            let starRefused = try await call(h, connection, "set_starred",
                                             ["book_id": .string(place.id), "starred": .bool(true)])
            #expect(starRefused.isError == true)
            let ask = try #require(h.asks.value.last)
            #expect(ask.scopeKind == .gathering && ask.scopeID == place.id && ask.rung == .edit)
            #expect(try reading(h, place.id) == before && h.undoStack.depth == 0 && h.receipts.value.isEmpty)
            await h.hangUp(connection)
        }
    }

    /// A NOTE or BOOK grant never reaches a gathering (R-VX185-1): the one
    /// shape, byte-identical to a missing id — and the refused row logs the
    /// argument's noun, so `list_my_activity` tells nothing.
    @Test func aNoteOrBookGrantNeverReachesAGathering() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let place = try gathering(h)
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, book.id))
            let missing = try await call(h, connection, "rename_book",
                                         ["book_id": .string("no-such-reading"), "name": .string("x")])
            for (tool, extra): (String, [String: Value]) in [
                ("rename_book", ["name": .string("x")]), ("archive_book", [:]), ("unarchive_book", [:]),
                ("delete_book", [:]), ("set_starred", ["starred": .bool(true)]),
            ] {
                let refused = try await call(h, connection, tool, ["book_id": .string(place.id)].merging(extra) { $1 })
                #expect(refused.isError == true && text(refused) == text(missing), "\(tool): \(text(refused))")
            }
            #expect(try activity(h, "rename_book").allSatisfy { $0["target_kind"] as String? == "book" })
            #expect(try reading(h, place.id).name == "gathered" && h.undoStack.depth == 0)
            await h.hangUp(connection)
        }
    }

    /// What a gathering can't take answers the reworded sentence where the
    /// client can read it — its RULE (A-648-5), a finish, a note out or moved
    /// — and the one shape where it can't; nothing written.
    @Test func theRuleAndWhatAGatheringCantTakeAnswerTheGatheringSentence() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let place = try gathering(h)
            let other = try h.operations.createWing(name: "elsewhere")
            let away = try gathering(h, "away", wing: other.id)
            let note = try h.operations.createPost(title: "a note")
            let before = try reading(h, place.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .gathering, place.id))
            let words = MCPWriteTools.gatheringWords("gathered")
            #expect(words.contains("rule is the author's") && words.contains("widen"))
            #expect(!words.contains("renaming") && !words.contains("starring"))
            for (tool, arguments): (String, [String: Value]) in [
                ("set_book_rule", ["book_id": .string(place.id), "rule": .object(["star": .bool(true)])]),
                ("finish_book", ["book_id": .string(place.id)]),
                ("reopen_book", ["book_id": .string(place.id)]),
                ("remove_note_from_book", ["book_id": .string(place.id), "note_id": .string(note.id)]),
            ] {
                let refused = try await call(h, connection, tool, arguments)
                #expect(refused.isError == true && text(refused) == words, "\(tool): \(text(refused))")
            }
            // A gathering it can't read: the one shape, never the sentence.
            let unreadable = try await call(h, connection, "set_book_rule",
                                            ["book_id": .string(away.id), "rule": .object(["star": .bool(true)])])
            #expect(unreadable.isError == true && text(unreadable) == MCPRefusalCopy.words(.notShared, .book))
            #expect(try reading(h, place.id) == before && reading(h, away.id).querySpec == away.querySpec)
            #expect(h.undoStack.depth == 0)
            await h.hangUp(connection)
        }
    }

    /// The name guard is the book's (VX-259): a readable reading's name — a
    /// book's or a gathering's — refuses; one the client can't read never
    /// counts.
    @Test func renamingAGatheringMeetsTheNameGuardOverWhatTheClientCanRead() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let place = try gathering(h)
            _ = try h.operations.createReading(name: "letters", kind: .book)
            let other = try h.operations.createWing(name: "elsewhere")
            _ = try h.operations.createReading(name: "secret", kind: .book, wingId: other.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let clash = try await call(h, connection, "rename_book",
                                       ["book_id": .string(place.id), "name": .string("Letters")])
            #expect(clash.isError == true && text(clash).contains("letters"), "\(text(clash))")
            let unseen = try await call(h, connection, "rename_book",
                                        ["book_id": .string(place.id), "name": .string("secret")])
            #expect(unseen.isError != true, "a name it can't read never blocks: \(text(unseen))")
            await h.hangUp(connection)
        }
    }

    /// A ONCE edit grant on the gathering is one act, spent inside it.
    @Test func aOnceGatheringGrantIsOneAct() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let place = try gathering(h)
            let connection = try await h.connect(as: "claude-code")
            let once = try #require(try h.approve("claude-code", spec(.edit, .gathering, place.id, .once)))
            let first = try await call(h, connection, "rename_book",
                                       ["book_id": .string(place.id), "name": .string("first")])
            #expect(first.isError != true, "\(text(first))")
            let consumed = try await h.database.read {
                try String.fetchOne($0, sql: "SELECT consumed_at FROM mcp_grant WHERE id = ?", arguments: [once])
            }
            #expect(consumed != nil, "spent inside the act")
            let second = try await call(h, connection, "rename_book",
                                        ["book_id": .string(place.id), "name": .string("second")])
            #expect(try second.isError == true && reading(h, place.id).name == "first")
            await h.hangUp(connection)
        }
    }
}
