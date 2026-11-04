import CryptoKit
import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-761 (the VX-771 run, batch 2 — the run record's BATCH 2 RECORD; PROVISIONAL
// P-771-10): edit_take's REPLACE form on the wire — `old_str` + `new_str`, mutually
// exclusive with `expected_text` + `text`. `old_str` must occur EXACTLY ONCE in the
// take's stored text (byte for byte, after her pending typing has landed); zero or
// several refuse naming the count. The landed act is the same edit_take act: the
// before/after bracket (deduped), a sealed post and a locked take refuse, ONE
// client-named undo, touch + churn, `sha256` of the stored result and
// `null_characters_removed` where owed. A mixed or half form refuses at the call door
// — nothing read, written, asked, spent or logged.
//
// Wire only (the SDK's own client over a real socket). RED ON OLD: `old_str` and
// `new_str` are undeclared there (VX-606 refuses the call), so every landing pin
// fails and every refusal speaks other words.

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

/// The call door's words (PROVISIONAL P-771-10), spelled HERE so the pins compile
/// and run on the tree before the fix.
private let oneFormWords =
    "Pass text with expected_text (the take's whole new text) or old_str with new_str (one passage of it), not both."
private let noFormWords =
    "Pass text with expected_text (the take's whole new text), or old_str with new_str (one passage of it)."
private let newStrWords = "new_str is required with old_str: the passage's replacement (\"\" removes it)."
private let oldStrWords = "old_str is required with new_str: the exact passage to replace, as it stands in the take."
private let emptyOldStrWords = "old_str can't be empty: it is the exact passage to replace, as it stands in the take."

/// The digest computed HERE, by CryptoKit — never the server's code.
private func digest(_ text: String) -> String {
    SHA256.hash(data: Data(text.utf8)).map { String(format: "%02x", $0) }.joined()
}

@Suite("VX-761 — edit_take's replace form: one passage, exactly once, the same act", .serialized)
struct MCPReplaceTakeServerTests {
    private struct World {
        let h: ServerHarness
        let connection: HarnessConnection
        let note: Container
        let takeID: String
        let grantID: String?
    }

    private func world(
        _ h: ServerHarness, _ text: String, duration: MCPGrantRule.Duration = .always
    ) async throws -> World {
        let note = try h.operations.createPost(title: "ch 1")
        let seeded = try h.operations.newBlock(in: note.id, text: text, registeringUndo: false)
        let connection = try await h.connect(as: "claude-code")
        let grant = try h.approve("claude-code", spec(.edit, .note, note.id, duration))
        return World(h: h, connection: connection, note: note, takeID: seeded.variant.id, grantID: grant)
    }

    private func replace(_ w: World, _ old: String, _ new: String) async throws
        -> (content: [Tool.Content], isError: Bool?) {
        try await call(w.connection, "edit_take", [
            "take_id": .string(w.takeID), "old_str": .string(old), "new_str": .string(new),
        ])
    }

    private func stored(_ w: World) async throws -> String? {
        try await w.h.database.read { db in
            try String.fetchOne(db, sql: "SELECT working_text FROM variant WHERE id = ?", arguments: [w.takeID])
        }
    }

    private func history(_ w: World) async throws -> [String] {
        try await w.h.database.read { db in
            try String.fetchAll(
                db, sql: "SELECT COALESCE(message, '') FROM commit_point WHERE variant_id = ? ORDER BY created_at, id",
                arguments: [w.takeID])
        }
    }

    private func activity(_ h: ServerHarness) async throws -> [String] {
        try await h.database.read { db in
            try String.fetchAll(db, sql: "SELECT act || ':' || outcome FROM mcp_activity WHERE act = 'edit_take' ORDER BY id")
        }
    }

    private func consumedAt(_ h: ServerHarness, _ grant: String?) async throws -> String? {
        try await h.database.read {
            try String.fetchOne($0, sql: "SELECT consumed_at FROM mcp_grant WHERE id = ?", arguments: [grant])
        }
    }

    // MARK: - It lands: the same act

    /// A passage that stands once lands as edit_take's act: the stored text,
    /// the digest a client can compute by hand, the named bracket, one
    /// client-named undo, the receipt, Activity — and the whole form's keys.
    /// RED ON OLD.
    @Test func aUniquePassageLandsAsTheSameActAndAnswersTheStoredDigest() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try await world(h, "The first line. The second line. The third line.")
            let answer = try await replace(w, "The second line.", "A better second line.")
            #expect(answer.isError != true, "\(text(answer))")
            let object = try json(answer)
            let landed = "The first line. A better second line. The third line."
            #expect(try await stored(w) == landed)
            #expect(object["sha256"] as? String == digest(landed), "the digest of the stored result, by hand")
            #expect(object["changed"] as? Bool == true)
            #expect(object["take_id"] as? String == w.takeID && object["note_id"] as? String == w.note.id)
            #expect(Set(object.keys) == [
                "take_id", "block_id", "note_id", "changed", "sha256", "before_commit_id", "after_commit_id",
            ], "the whole form's answer: \(object.keys.sorted())")
            #expect(try await history(w) == ["before claude-code's edit", "after claude-code's edit"])
            #expect(h.undoStack.depth == 1 && h.undoStack.topLabel == "claude-code's edit")
            #expect(h.receipts.value.last?.act == .edit && h.receipts.value.last?.targetID == w.note.id)
            #expect(try await activity(h) == ["edit_take:allowed"])

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's edit")
            #expect(try await stored(w) == "The first line. The second line. The third line.")
            await h.hangUp(w.connection)
        }
    }

    /// The bracket dedupes as MCPSpec says: her commit already holds the words
    /// replaced, so there is no before commit. RED ON OLD.
    @Test func theBeforeCommitDedupesAgainstHerLatestCommit() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try await world(h, "Her committed line.")
            _ = try h.operations.commit(w.takeID, message: "her moment")
            let answer = try await replace(w, "committed", "rewritten")
            #expect(answer.isError != true, "\(text(answer))")
            let object = try json(answer)
            #expect(object["before_commit_id"] == nil && object["after_commit_id"] is String, "\(object)")
            #expect(try await history(w) == ["her moment", "after claude-code's edit"])
            await h.hangUp(w.connection)
        }
    }

    /// A replacement carrying U+0000 lands stripped and says how many; the
    /// digest is the stored text's. RED ON OLD.
    @Test func aNullInTheReplacementIsRemovedAndSaid() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try await world(h, "Her line.")
            let answer = try await replace(w, "line.", "li\u{0}ne!")
            #expect(answer.isError != true, "\(text(answer))")
            let object = try json(answer)
            #expect(try await stored(w) == "Her line!")
            #expect(object["sha256"] as? String == digest("Her line!"))
            #expect(object[MCPNullCharacters.answerKey] as? Int == 1, "\(object)")
            await h.hangUp(w.connection)
        }
    }

    // MARK: - It refuses: the count, the blank, the guards

    /// Zero and several occurrences refuse naming the count: nothing written,
    /// no bracket, no undo entry, no receipt; the refusal logged; a once grant
    /// unspent — the next good call lands and spends it. RED ON OLD.
    @Test func zeroOrSeveralOccurrencesRefuseNamingTheCountAndSpendNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try await world(h, "the cat, the hat, the mat", duration: .once)
            let none = try await replace(w, "the dog", "a dog")
            #expect(none.isError == true)
            #expect(text(none).contains("old_str doesn't occur in the take's current text (0 times)"), "\(text(none))")
            let three = try await replace(w, "the", "a")
            #expect(three.isError == true)
            #expect(text(three).contains("old_str occurs 3 times in the take's current text"), "\(text(three))")
            #expect(text(three).contains("it must occur exactly once"), "\(text(three))")
            let inWords = try await replace(w, "at", "og")
            #expect(text(inWords).contains("old_str occurs 3 times"), "inside words too: \(text(inWords))")
            #expect(try await stored(w) == "the cat, the hat, the mat")
            #expect(try await history(w).isEmpty && h.undoStack.depth == 0 && h.receipts.value.isEmpty)
            #expect(try await activity(h) == ["edit_take:refused", "edit_take:refused", "edit_take:refused"])
            #expect(try await consumedAt(h, w.grantID) == nil, "a refused act never spends a once grant")

            let one = try await replace(w, "the cat", "a cat")
            #expect(one.isError != true, "the refusals spent nothing: \(text(one))")
            #expect(try await stored(w) == "a cat, the hat, the mat")
            #expect(try await consumedAt(h, w.grantID) != nil, "the landed act spent it")
            await h.hangUp(w.connection)
        }
    }

    /// A replacement that would leave the take blank refuses in edit_take's
    /// blank sentence. RED ON OLD.
    @Test func aReplacementLeavingTheTakeBlankRefuses() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try await world(h, "Her only words.\n")
            let answer = try await replace(w, "Her only words.", "")
            #expect(answer.isError == true)
            #expect(text(answer) == MCPWriteTools.editTakeBlankRefusal, "\(text(answer))")
            #expect(try await stored(w) == "Her only words.\n")
            await h.hangUp(w.connection)
        }
    }

    /// A locked take and a sealed post refuse as ever — even for a passage that
    /// stands once. RED ON OLD (the old door refused `old_str` itself).
    @Test func aLockedTakeAndASealedPostRefuse() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try await world(h, "Guarded words.")
            try h.operations.lockVariant(w.takeID)
            let locked = try await replace(w, "Guarded", "Open")
            #expect(locked.isError == true)
            #expect(text(locked).contains("lockedVariant"), "her lock's refusal: \(text(locked))")
            try h.operations.unlockVariant(w.takeID)
            try h.operations.lockPost(w.note.id)
            let sealed = try await replace(w, "Guarded", "Open")
            #expect(sealed.isError == true)
            #expect(text(sealed).contains("lockedPost"), "the seal's refusal: \(text(sealed))")
            #expect(try await stored(w) == "Guarded words.")
            #expect(h.undoStack.depth == 0)
            await h.hangUp(w.connection)
        }
    }

    // MARK: - The call door: one form, never both

    /// Both forms at once, a half form, an empty passage, no form: each refused
    /// at the parse — nothing written, logged, asked, or spent (a once grant
    /// stays live for the call that follows). RED ON OLD.
    @Test func aMixedOrHalfFormRefusesAtTheCallDoorBeforeAnyDecision() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try await world(h, "Her line.", duration: .once)
            let take = Value.string(w.takeID)
            let both = oneFormWords
            let cases: [([String: Value], String)] = [
                (["take_id": take, "text": .string("x"), "expected_text": .string("Her line."),
                  "old_str": .string("Her"), "new_str": .string("His")], both),
                (["take_id": take, "text": .string("x"), "old_str": .string("Her")], both),
                (["take_id": take, "expected_text": .string("Her line."), "new_str": .string("His")], both),
                (["take_id": take, "old_str": .string("Her")], newStrWords),
                (["take_id": take, "new_str": .string("His")], oldStrWords),
                (["take_id": take, "old_str": .string(""), "new_str": .string("His")], emptyOldStrWords),
                (["take_id": take], noFormWords),
            ]
            for (arguments, words) in cases {
                let refused = try await call(w.connection, "edit_take", arguments)
                #expect(refused.isError == true, "\(arguments.keys.sorted())")
                #expect(text(refused) == words, "\(arguments.keys.sorted()): \(text(refused))")
            }
            #expect(try await activity(h).isEmpty, "a parse refusal is never logged")
            #expect(h.asks.value.isEmpty, "nothing is asked")
            #expect(try await consumedAt(h, w.grantID) == nil, "nothing spent")
            #expect(try await stored(w) == "Her line.")

            let landed = try await replace(w, "Her", "His")
            #expect(landed.isError != true, "\(text(landed))")
            #expect(try await stored(w) == "His line.")
            await h.hangUp(w.connection)
        }
    }

    /// The whole form still lands exactly as before, through the same door.
    @Test func theWholeFormLandsAsBefore() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try await world(h, "Her line.")
            let answer = try await call(w.connection, "edit_take", [
                "take_id": .string(w.takeID), "text": .string("A new line."), "expected_text": .string("Her line."),
            ])
            #expect(answer.isError != true, "\(text(answer))")
            #expect(try json(answer)["sha256"] as? String == digest("A new line."))
            await h.hangUp(w.connection)
        }
    }

    // MARK: - The schema and the description teach both forms

    @Test func theSchemaDeclaresBothFormsAndTheDescriptionTeachesTheOccurOnceRule() throws {
        let declaration = MCPToolCatalog.editTake
        guard case .object(let schema) = declaration.inputSchema,
              case .object(let properties)? = schema["properties"] else {
            Issue.record("edit_take's schema is an object with properties")
            return
        }
        #expect(Set(properties.keys) == ["take_id", "text", "expected_text", "old_str", "new_str"])
        #expect(schema["required"] == .array(["take_id"]), "either form: only the take is always required")
        let words = declaration.description
        #expect(words.contains("old_str"), "\(words)")
        #expect(words.contains("new_str"), "\(words)")
        #expect(words.contains("must occur EXACTLY ONCE in the take's current text"), "\(words)")
        #expect(words.contains("Pass one form, never both."), "\(words)")
    }
}
