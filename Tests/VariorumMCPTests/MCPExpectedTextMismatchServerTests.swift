import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-760 (the VX-771 run, batch 2 — the run record
// `notes/plans/fixes/vx-771-mcp-agent-ergonomics.md`, BATCH 2 RECORD).
//
// THE TRACED MECHANISM: `Operations.editTakeUnderInsurance` refuses
// `bufferChangedSinceGesture` for ANY `expected_text` that is not the take's stored
// text; the refusal travels `MCPWriteTools.land` → `MCPWireRefusalCopy.spoken`, whose
// wire words have no arm for it, so the app's table speaks — "The text changed while
// that gesture was landing…" (`OpsRefusalTable.swift:279`), a race with the author,
// even when the client simply sent PART of the take (the common case: her pending
// typing has already landed before the act, VX-275). The harness's hook prints the
// raw case.
//
// THE FIX: the edit_take door answers the fact pattern it can PROVE from the two
// texts (sent, stored now) — whitespace at the ends, part of the take, the take and
// more, or where they first differ — with both lengths, and never claims a race;
// where the texts genuinely diverge it keeps the buffer-moved reading available.
//
// Wire only (the SDK's own client over a real socket): every pin compiles on the tree
// before the fix and runs RED there (the old answer is the raw case); the no-op guard
// is green on both sides by design.

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

/// The race sentence the fix must never speak where it can't prove one — her
/// table's, and the raw case the harness's hook prints.
private func claimsARace(_ answer: String) -> Bool {
    answer.contains("changed while that gesture was landing") || answer.contains("bufferChangedSinceGesture")
}

@Suite("VX-760 — edit_take's mismatch says what the door can prove, never a race it can't", .serialized)
struct MCPExpectedTextMismatchServerTests {
    private struct World {
        let h: ServerHarness
        let connection: HarnessConnection
        let note: Container
        let takeID: String
    }

    /// A note with one take holding `text`, shared at edit (always).
    private func world(_ h: ServerHarness, _ text: String) async throws -> World {
        let note = try h.operations.createPost(title: "ch 1")
        let seeded = try h.operations.newBlock(in: note.id, text: text, registeringUndo: false)
        let connection = try await h.connect(as: "claude-code")
        _ = try h.approve("claude-code", spec(.edit, .note, note.id))
        return World(h: h, connection: connection, note: note, takeID: seeded.variant.id)
    }

    private func edit(_ w: World, expected: String, text: String = "The client's rewrite.") async throws
        -> (content: [Tool.Content], isError: Bool?) {
        try await call(w.connection, "edit_take", [
            "take_id": .string(w.takeID), "text": .string(text), "expected_text": .string(expected),
        ])
    }

    /// Nothing was written: the take's bytes, no commit, no undo entry, no
    /// receipt — and the refusal logged.
    private func expectNothingWritten(_ w: World, stored: String) async throws {
        #expect(try await w.h.database.read { db in
            try String.fetchOne(db, sql: "SELECT working_text FROM variant WHERE id = ?", arguments: [w.takeID])
        } == stored)
        #expect(try await w.h.database.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", arguments: [w.takeID])
        } == 0, "no bracket for a refused edit")
        #expect(w.h.undoStack.depth == 0, "nothing landed, nothing to undo")
        #expect(w.h.receipts.value.isEmpty, "a receipt only claims what landed")
        let logged = try await w.h.database.read { db -> [String]? in
            guard let row = try Row.fetchOne(
                db, sql: "SELECT outcome, target_id FROM mcp_activity WHERE act = 'edit_take' ORDER BY id DESC LIMIT 1")
            else { return nil }
            return [row["outcome"] as String? ?? "", row["target_id"] as String? ?? ""]
        }
        #expect(logged == ["refused", w.takeID], "the refusal is logged on the take: \(String(describing: logged))")
    }

    // MARK: - Part of the take

    /// The client sent the take's first sentence — a proper PREFIX. The answer
    /// says the expected text must be the WHOLE take, gives both lengths, and
    /// keeps both readings (sent part of it · read it before it grew), claiming
    /// no race. RED ON OLD: the raw case.
    @Test func aPrefixOfTheTakeSaysItMustBeTheWholeText() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let stored = "Her opening line. And a second sentence after it."
            let w = try await world(h, stored)
            let answer = try await edit(w, expected: "Her opening line.")
            let words = text(answer)
            #expect(answer.isError == true)
            #expect(words.contains("expected_text matches only the start of the take"), "\(words)")
            #expect(words.contains("it must be the take's WHOLE current text"), "\(words)")
            #expect(words.contains("expected_text is 17 characters, the take 49"), "both lengths: \(words)")
            #expect(words.contains("if you read it earlier, it has grown since"), "the buffer-moved reading kept: \(words)")
            #expect(!claimsARace(words), "no race the door can't prove: \(words)")
            try await expectNothingWritten(w, stored: stored)
            await h.hangUp(w.connection)
        }
    }

    /// A passage from INSIDE the take. RED ON OLD.
    @Test func aPassageFromInsideTheTakeSaysItMustBeTheWholeText() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let stored = "Her opening line. And a second sentence after it."
            let w = try await world(h, stored)
            let answer = try await edit(w, expected: "And a second sentence")
            let words = text(answer)
            #expect(answer.isError == true)
            #expect(words.contains("expected_text matches only a passage from inside the take"), "\(words)")
            #expect(words.contains("it must be the take's WHOLE current text"), "\(words)")
            #expect(words.contains("expected_text is 21 characters, the take 49"), "\(words)")
            #expect(!claimsARace(words), "\(words)")
            try await expectNothingWritten(w, stored: stored)
            await h.hangUp(w.connection)
        }
    }

    // MARK: - Whitespace, and the take and more

    /// The client trimmed the take's trailing newline. RED ON OLD.
    @Test func whitespaceOnlyAtTheEndsIsSaidAsSuch() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let stored = "Her line, and a blank line after it.\n"
            let w = try await world(h, stored)
            let answer = try await edit(w, expected: "Her line, and a blank line after it.")
            let words = text(answer)
            #expect(answer.isError == true)
            #expect(words.contains("they differ only in whitespace at the start or end"), "\(words)")
            #expect(words.contains("expected_text is 36 characters, the take 37"), "\(words)")
            #expect(!claimsARace(words), "\(words)")
            try await expectNothingWritten(w, stored: stored)
            await h.hangUp(w.connection)
        }
    }

    /// The client sent two blocks' text for one take. RED ON OLD.
    @Test func theTakeAndMoreSaysItMustBeExactlyThisTake() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let stored = "Her line."
            let w = try await world(h, stored)
            let answer = try await edit(w, expected: "Her line.\n\nThe next block's line.")
            let words = text(answer)
            #expect(answer.isError == true)
            #expect(words.contains("expected_text holds the take's whole current text and more"), "\(words)")
            #expect(words.contains("it must be exactly this one take's text"), "\(words)")
            #expect(words.contains("expected_text is 33 characters, the take 9"), "\(words)")
            #expect(!claimsARace(words), "\(words)")
            try await expectNothingWritten(w, stored: stored)
            await h.hangUp(w.connection)
        }
    }

    // MARK: - A genuinely changed buffer

    /// The client read the take; then the author rewrote it (an autosave —
    /// her typing landed). The texts diverge beyond a prefix: the answer says
    /// where they first differ (an offset into the SENT text, UTF-16 units),
    /// both lengths, and the buffer-moved reading — as a possibility, never a
    /// claim. RED ON OLD.
    @Test func aGenuinelyChangedTakeSaysWhereTheTextsFirstDiffer() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try await world(h, "Her line.")
            let read = try json(try await call(w.connection, "read_note", [
                "note_id": .string(w.note.id), "with_ids": .bool(true),
            ]))
            let asRead = try #require(
                ((read["blocks"] as? [[String: Any]])?.first?["takes"] as? [[String: Any]])?.first?["text"] as? String)
            #expect(asRead == "Her line.")
            try h.operations.autosave(w.takeID, text: "Her lines, rewritten.", charDelta: 12)

            let answer = try await edit(w, expected: asRead)
            let words = text(answer)
            #expect(answer.isError == true)
            #expect(words.contains("they first differ at character 8 of expected_text"), "\(words)")
            #expect(words.contains("expected_text is 9 characters, the take 21"), "\(words)")
            #expect(words.contains("If you read the take earlier, it has changed since"), "\(words)")
            #expect(!words.contains("bufferChangedSinceGesture"), "never the raw case: \(words)")
            #expect(try await h.database.read { db in
                try String.fetchOne(db, sql: "SELECT working_text FROM variant WHERE id = ?", arguments: [w.takeID])
            } == "Her lines, rewritten.", "her words stand")
            #expect(h.undoStack.depth == 0)
            await h.hangUp(w.connection)
        }
    }

    /// The UTF-16 rule, said once: an emoji before the difference counts two.
    /// RED ON OLD.
    @Test func theFirstDifferenceIsCountedInUTF16UnitsOfTheSentText() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try await world(h, "\u{1F30A} sea glass, green.")
            let answer = try await edit(w, expected: "\u{1F30A} sea glass, blue.")
            let words = text(answer)
            #expect(words.contains("they first differ at character 14 of expected_text"), "\(words)")
            #expect(words.contains("expected_text is 19 characters, the take 20"), "\(words)")
            await h.hangUp(w.connection)
        }
    }

    // MARK: - The guards (green on both sides by design)

    /// A matching edit whose text is already the take's stays the no-op it was:
    /// `changed: false`, the exact key set, nothing written.
    @Test func aMatchingNoOpAnswersAsBefore() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try await world(h, "Her line.")
            let answer = try await edit(w, expected: "Her line.", text: "Her line.")
            #expect(answer.isError != true, "\(text(answer))")
            let object = try json(answer)
            #expect(object["changed"] as? Bool == false)
            #expect(Set(object.keys) == ["take_id", "block_id", "note_id", "changed", "sha256"], "\(object.keys.sorted())")
            #expect(h.undoStack.depth == 0)
            await h.hangUp(w.connection)
        }
    }

    /// A matching edit lands exactly as before.
    @Test func aMatchingEditLandsAsBefore() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try await world(h, "Her line.")
            let answer = try await edit(w, expected: "Her line.")
            #expect(answer.isError != true, "\(text(answer))")
            #expect(try json(answer)["changed"] as? Bool == true)
            #expect(h.undoStack.topLabel == "claude-code's edit")
            await h.hangUp(w.connection)
        }
    }
}
