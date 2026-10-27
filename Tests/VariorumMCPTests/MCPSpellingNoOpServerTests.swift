import CryptoKit
import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-358 (RUN VX-548, batch 2a — the run record
// `notes/plans/fixes/vx-548-run-mcp-grant-pane-fixes.md`, BATCH 2a RECORD; born as the
// VX-336 U7 builder A's OWED 3).
//
// THE TRACED MECHANISM: `edit_take`'s and `restore_commit`'s "nothing to write" test
// is Swift `String` equality (`Operations.editTakeUnderInsurance`: `variant.workingText
// != newText`; `restoreCommitForClient`: `variant.workingText != commitPoint.text`),
// which is CANONICAL equivalence. So a client that sends a take's NFD spelling onto its
// NFC text — or restores a commit holding the other spelling — hears `changed: false`,
// nothing is written, and the answered `sha256` (VX-254: the STORED text's bytes)
// differs from the digest of the bytes the client sent: honest about the store,
// silent about why a write-proving client's digest won't match.
//
// The build (PROVISIONAL MB-5 — the brief's default): canonical equality STAYS the
// no-op rule (an invisible re-normalization must not rewrite prose, churn, or mint
// undo entries and commits); when the no-op's asked text (sent, after the U+0000
// strip — or the commit's) is spelled with other code points than the stored take,
// the answer says so with ONE additive key, `stored_text_normalization_differs: true`,
// absent otherwise — so every other answer stays byte-unchanged (the guards below pin
// the exact key sets). The digest stays the stored text's (VX-254's definition).
//
// Wire only (the SDK's own client over a real socket): every pin compiles on the tree
// before the fix and runs RED there by absence (the old answer lacks the key).

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: .always)
}

private func call(
    _ connection: HarnessConnection, _ name: String, _ arguments: [String: Value]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: name, arguments: arguments)
}

private func digest(_ text: String) -> String {
    SHA256.hash(data: Data(text.utf8)).map { String(format: "%02x", $0) }.joined()
}

/// "café" precomposed (U+00E9) and decomposed (e + U+0301) — canonically equal,
/// byte-different.
private let nfc = "Um caf\u{00E9}."
private let nfd = "Um cafe\u{0301}."

private let key = "stored_text_normalization_differs"

@Suite("VX-358 — a no-op whose spelling differs says so; every other answer is byte-unchanged", .serialized)
struct MCPSpellingNoOpServerTests {
    /// The take's stored bytes, read raw (never through a canonical compare).
    private func storedBytes(_ h: ServerHarness, _ takeID: String) async throws -> [UInt8] {
        try await h.database.read { db in
            let text = try String.fetchOne(db, sql: "SELECT working_text FROM variant WHERE id = ?", arguments: [takeID])
            return Array((text ?? "").utf8)
        }
    }

    private func commitCount(_ h: ServerHarness, _ takeID: String) async throws -> Int {
        try await h.database.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", arguments: [takeID]) ?? -1
        }
    }

    // MARK: - edit_take

    /// The fixture's precondition, said once: the two spellings ARE equal to
    /// Swift and are NOT the same bytes.
    @Test func theFixturesTwoSpellingsAreCanonicallyEqualAndByteDifferent() {
        #expect(nfc == nfd, "Swift's String equality is canonical equivalence")
        #expect(Array(nfc.utf8) != Array(nfd.utf8), "the bytes differ")
        #expect(digest(nfc) != digest(nfd), "so do their digests")
    }

    /// Her store holds NFC; a client sends the NFD spelling. Nothing is
    /// written (the canonical no-op stands — no bytes, no commit, no undo
    /// entry), the digest is the STORED text's, and the answer says the
    /// spellings differ. RED ON OLD: no such key.
    @Test func editTakeSendingAnotherSpellingIsANoOpThatSaysTheSpellingsDiffer() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "spelling")
            let one = try h.operations.newBlock(in: note.id, text: nfc, registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let depth = h.undoStack.depth
            let commits = try await commitCount(h, one.variant.id)

            let respelled = try await call(connection, "edit_take", [
                "take_id": .string(one.variant.id), "text": .string(nfd), "expected_text": .string(nfc),
            ])
            #expect(respelled.isError != true, "\(text(respelled))")
            let answer = try json(respelled)
            #expect(answer["changed"] as? Bool == false, "the canonical no-op stands")
            #expect(answer["sha256"] as? String == digest(nfc), "the digest is the STORED spelling's (VX-254)")
            #expect(answer["sha256"] as? String != digest(nfd), "…never the bytes sent")
            #expect(answer[key] as? Bool == true, "the answer says the spellings differ: \(answer)")
            #expect(Set(answer.keys) == ["take_id", "block_id", "note_id", "changed", "sha256", key],
                    "the no-op's keys plus the one fact: \(answer.keys.sorted())")
            #expect(try await storedBytes(h, one.variant.id) == Array(nfc.utf8), "the store keeps its own bytes")
            #expect(try await commitCount(h, one.variant.id) == commits, "no insurance commit for a no-op")
            #expect(h.undoStack.depth == depth, "no undo entry for a no-op")
            await h.hangUp(connection)
        }
    }

    /// The mirror: an NFD take, the NFC spelling sent. RED ON OLD.
    @Test func editTakeSendingNFCOntoAnNFDTakeSaysTheSpellingsDifferToo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "spelling")
            let one = try h.operations.newBlock(in: note.id, text: nfd, registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let answer = try json(try await call(connection, "edit_take", [
                "take_id": .string(one.variant.id), "text": .string(nfc), "expected_text": .string(nfd),
            ]))
            #expect(answer["changed"] as? Bool == false)
            #expect(answer["sha256"] as? String == digest(nfd), "the stored (NFD) spelling's digest")
            #expect(answer[key] as? Bool == true, "\(answer)")
            #expect(try await storedBytes(h, one.variant.id) == Array(nfd.utf8))
            await h.hangUp(connection)
        }
    }

    // MARK: - restore_commit

    /// A commit holding the NFD spelling, restored onto a take that now reads
    /// the NFC one: the canonical no-op stands, the digest is the stored
    /// text's, and the answer says the commit's spelling differs. RED ON OLD.
    @Test func restoringACommitSpelledOtherwiseIsANoOpThatSaysTheSpellingsDiffer() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "spelling")
            let one = try h.operations.newBlock(in: note.id, text: nfd, registeringUndo: false)
            let decomposed = try h.operations.commit(one.variant.id, message: "nfd")
            try h.operations.autosave(one.variant.id, text: nfc, charDelta: 2)
            #expect(try await storedBytes(h, one.variant.id) == Array(nfc.utf8), "the fixture: the take now holds NFC")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let depth = h.undoStack.depth
            let commits = try await commitCount(h, one.variant.id)

            let restored = try await call(connection, "restore_commit", ["commit_id": .string(decomposed.id)])
            #expect(restored.isError != true, "\(text(restored))")
            let answer = try json(restored)
            #expect(answer["changed"] as? Bool == false, "the canonical no-op stands")
            #expect(answer["sha256"] as? String == digest(nfc), "the STORED spelling's digest")
            #expect(answer[key] as? Bool == true, "the answer says the commit's spelling differs: \(answer)")
            #expect(Set(answer.keys) == ["commit_id", "take_id", "block_id", "note_id", "changed", "sha256", key],
                    "\(answer.keys.sorted())")
            #expect(try await storedBytes(h, one.variant.id) == Array(nfc.utf8))
            #expect(try await commitCount(h, one.variant.id) == commits, "no insurance commit for a no-op")
            #expect(h.undoStack.depth == depth, "no undo entry for a no-op")
            await h.hangUp(connection)
        }
    }

    /// The model learns it where it reads the tool: both descriptions name the
    /// key (the key by its literal, so the pin compiles — and runs RED — on
    /// the tree before the fix), and no other tool's does.
    @Test func bothToolsDescriptionsSayTheSpellingRuleAndNoOtherDoes() {
        #expect(MCPToolCatalog.editTake.description.contains(key), "edit_take says it")
        #expect(MCPToolCatalog.restoreCommit.description.contains(key), "restore_commit says it")
        for tool in MCPToolCatalog.all where ![MCPToolCatalog.editTake.name, MCPToolCatalog.restoreCommit.name]
            .contains(tool.name) {
            #expect(!tool.description.contains(key), "\(tool.name) answers no such key")
        }
    }

    // MARK: - GUARDS (green on both sides, by design — every other answer byte-unchanged)

    /// The ordinary no-op (the same bytes) and an ordinary landed edit answer
    /// EXACTLY the keys they answered before — the new key never appears.
    @Test func everyOtherEditTakeAnswerKeepsItsExactKeys() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "plain")
            let one = try h.operations.newBlock(in: note.id, text: nfc, registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))

            let same = try json(try await call(connection, "edit_take", [
                "take_id": .string(one.variant.id), "text": .string(nfc), "expected_text": .string(nfc),
            ]))
            #expect(same["changed"] as? Bool == false)
            #expect(Set(same.keys) == ["take_id", "block_id", "note_id", "changed", "sha256"],
                    "the byte-identical no-op: unchanged keys: \(same.keys.sorted())")

            let edited = try json(try await call(connection, "edit_take", [
                "take_id": .string(one.variant.id), "text": .string("Um ch\u{00E1}."), "expected_text": .string(nfc),
            ]))
            #expect(edited["changed"] as? Bool == true)
            #expect(edited[key] == nil, "a landed edit never carries it")
            #expect(Set(edited.keys).subtracting(["before_commit_id", "after_commit_id"])
                    == ["take_id", "block_id", "note_id", "changed", "sha256"], "\(edited.keys.sorted())")
            await h.hangUp(connection)
        }
    }

    /// A no-op whose only difference is a U+0000 (removed by the store's rule,
    /// VX-357) is the SAME spelling once stripped — it says how many nulls
    /// were removed and never that the spelling differs.
    @Test func aNullCharacterOnlyNoOpSaysTheNullsAndNotTheSpelling() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "nul")
            let one = try h.operations.newBlock(in: note.id, text: nfc, registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let answer = try json(try await call(connection, "edit_take", [
                "take_id": .string(one.variant.id), "text": .string(nfc + "\u{0000}"), "expected_text": .string(nfc),
            ]))
            #expect(answer["changed"] as? Bool == false)
            #expect(answer["null_characters_removed"] as? Int == 1)
            #expect(answer[key] == nil, "the stripped text IS the stored spelling: \(answer)")
            await h.hangUp(connection)
        }
    }

    /// Restoring a commit that holds the take's own bytes, and a landed
    /// restore, answer exactly the keys they answered before.
    @Test func everyOtherRestoreCommitAnswerKeepsItsExactKeys() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "plain")
            let one = try h.operations.newBlock(in: note.id, text: nfc, registeringUndo: false)
            let first = try h.operations.commit(one.variant.id, message: "first")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))

            let same = try json(try await call(connection, "restore_commit", ["commit_id": .string(first.id)]))
            #expect(same["changed"] as? Bool == false)
            #expect(Set(same.keys) == ["commit_id", "take_id", "block_id", "note_id", "changed", "sha256"],
                    "\(same.keys.sorted())")

            try h.operations.autosave(one.variant.id, text: "Second.", charDelta: 7)
            let landed = try json(try await call(connection, "restore_commit", ["commit_id": .string(first.id)]))
            #expect(landed["changed"] as? Bool == true)
            #expect(landed[key] == nil)
            #expect(Set(landed.keys).subtracting(["before_commit_id", "after_commit_id"])
                    == ["commit_id", "take_id", "block_id", "note_id", "changed", "sha256"], "\(landed.keys.sorted())")
            await h.hangUp(connection)
        }
    }
}
