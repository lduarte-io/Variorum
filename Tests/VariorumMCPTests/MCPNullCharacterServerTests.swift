import CryptoKit
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP

// VX-357 (VX-348 U1 — the run record `notes/plans/fixes/vx-348-prelaunch-sweep.md`,
// U1 UNIT RECORD): ON THE MCP DOOR, ALWAYS SAY IT. Her ruling (2026-10-15):
// U+0000 is stripped in the operations layer (the store cannot hold it — a bind
// stopped at the first NUL and lost the rest), and the wire's answer names how
// many null characters were removed — `null_characters_removed` — while each
// `sha256` digests the text AS STORED, so the fingerprint stays true. A write
// whose text holds none answers byte-unchanged (no key).
//
// Wire only (the SDK's own client over a real socket). Every expected digest is
// CryptoKit's over the expected stored bytes, never the product's digest.
// RED ON OLD: the store held each text only up to its first NUL, the digests
// were the sent bytes', and no count was said (the run record's red-on-old leg).

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

private let removedKey = "null_characters_removed"

@Suite("VX-357 — the MCP door says how many null characters it removed", .serialized)
struct MCPNullCharacterServerTests {
    private func readWithIDs(_ connection: HarnessConnection, _ noteID: String) async throws -> [String: Any] {
        try json(try await call(connection, "read_note", ["note_id": .string(noteID), "with_ids": .bool(true)]))
    }

    /// `take_id → (text, label)` as `read_note with_ids` returns them.
    private func storedTakes(_ read: [String: Any]) -> [String: (text: String?, label: String?)] {
        var takes: [String: (text: String?, label: String?)] = [:]
        for block in read["blocks"] as? [[String: Any]] ?? [] {
            for take in block["takes"] as? [[String: Any]] ?? [] {
                if let id = take["take_id"] as? String { takes[id] = (take["text"] as? String, take["label"] as? String) }
            }
        }
        return takes
    }

    /// `create_note`'s structured payload: every text the call sent — the
    /// title, a block's text and name, a take's text and label — is stored
    /// without its null characters; every take's sha256 digests the stored
    /// text; the answer counts them all.
    @Test func aStructuredNoteIsStoredWithoutItsNullsAndTheAnswerCountsThem() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            let created = try await call(connection, "create_note", [
                "wing_id": .string(""), "title": .string("Ti\u{0}tle"),
                "blocks": .array([
                    .object([
                        "text": .string("Ol\u{00E1}\u{0}, mundo."), "name": .string("open\u{0}ing"),
                        "takes": .array([.object(["text": .string("Hello\u{0}\u{0}, world."),
                                                  "label": .string("eng\u{0}lish")])]),
                    ]),
                ]),
            ])
            #expect(created.isError != true, "\(text(created))")
            let answer = try json(created)
            #expect(answer[removedKey] as? Int == 6, "the title's, the text's, the name's, the take's two, the label's")
            let block = try #require((answer["blocks"] as? [[String: Any]])?.first)
            let takes = try #require(block["takes"] as? [[String: Any]])
            #expect(takes.map { $0["sha256"] as? String }
                    == [digest("Ol\u{00E1}, mundo."), digest("Hello, world.")], "each digests the STORED text")
            #expect(takes.last?["label"] as? String == "english", "the label as stored")
            let noteID = try #require(answer["note_id"] as? String)
            let read = try await readWithIDs(connection, noteID)
            let stored = storedTakes(read)
            for take in takes {
                let id = try #require(take["take_id"] as? String)
                #expect(take["sha256"] as? String == stored[id]?.text.map(digest), "the answer digests what a read returns")
            }
            #expect(read["title"] as? String == "Title")
            let blockID = try #require(block["block_id"] as? String)
            #expect(try await h.database.read { db in
                try String.fetchOne(db, sql: "SELECT name FROM block WHERE id = ?", arguments: [blockID])
            } == "opening")
            await h.hangUp(connection)
        }
    }

    /// `edit_take`: the stored text without the null, its digest, the count —
    /// and a re-spelling that differs only by null characters is no change
    /// (`changed: false`), the count said all the same.
    @Test func anEditIsStoredWithoutItsNullAndARespellingByNullsIsNoChange() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "ch 1")
            let one = try h.operations.newBlock(in: note.id, text: "Ela beliscou.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let edited = try json(try await call(connection, "edit_take", [
                "take_id": .string(one.variant.id), "text": .string("Ela belisc\u{0}\u{00E1}u."),
                "expected_text": .string("Ela beliscou."),
            ]))
            #expect(edited["changed"] as? Bool == true)
            #expect(edited["sha256"] as? String == digest("Ela belisc\u{00E1}u."))
            #expect(edited[removedKey] as? Int == 1)
            #expect(storedTakes(try await readWithIDs(connection, note.id))[one.variant.id]?.text == "Ela belisc\u{00E1}u.")
            let same = try json(try await call(connection, "edit_take", [
                "take_id": .string(one.variant.id), "text": .string("Ela belisc\u{00E1}u.\u{0}"),
                "expected_text": .string("Ela belisc\u{00E1}u."),
            ]))
            #expect(same["changed"] as? Bool == false, "nothing but a null differs: nothing to write")
            #expect(same[removedKey] as? Int == 1, "said all the same")
            await h.hangUp(connection)
        }
    }

    /// A comment with a null is stored without it, the count is said, and the
    /// client's authorship record digests the STORED words — so the client
    /// can still delete its own comment at suggest (VX-260's rule holds).
    @Test func aCommentWithANullStaysTheClientsOwn() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "note")
            let one = try h.operations.newBlock(in: note.id, text: "Her words.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.suggest, .wing, ""))
            let added = try json(try await call(connection, "add_comment", [
                "block_id": .string(one.block.id), "text": .string("Tighten\u{0} this."),
            ]))
            #expect(added[removedKey] as? Int == 1)
            let commentID = try #require(added["comment_id"] as? String)
            #expect(try await h.database.read { db in
                try String.fetchOne(db, sql: "SELECT text FROM block_comment WHERE id = ?", arguments: [commentID])
            } == "Tighten this.")
            let deleted = try await call(connection, "delete_comment", ["comment_id": .string(commentID)])
            #expect(deleted.isError != true, "its own comment, words unchanged since: \(text(deleted))")
            await h.hangUp(connection)
        }
    }

    /// `add_takes` counts across its items; `apply_tag` stores the path
    /// without the null and counts it.
    @Test func aBatchAndATagCountEveryNullTheyRemoved() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "fan")
            let one = try h.operations.newBlock(in: note.id, text: "Um.", registeringUndo: false)
            let two = try h.operations.newBlock(in: note.id, text: "Dois.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            let added = try json(try await call(connection, "add_takes", [
                "note_id": .string(note.id),
                "takes": .array([
                    .object(["block_id": .string(one.block.id), "text": .string("One\u{0}.")]),
                    .object(["block_id": .string(two.block.id), "text": .string("Two."), "label": .string("en\u{0}")]),
                ]),
            ]))
            #expect(added[removedKey] as? Int == 2)
            let takes = try #require(added["takes"] as? [[String: Any]])
            #expect(takes.map { $0["sha256"] as? String } == [digest("One."), digest("Two.")])
            #expect(takes.last?["label"] as? String == MCPWriteTools.aiLabel(client: "claude-code", own: "en"))

            let tagged = try json(try await call(connection, "apply_tag", [
                "note_id": .string(note.id), "tag": .string("top\u{0}ic"),
            ]))
            #expect(tagged["tag"] as? String == "topic" && tagged[removedKey] as? Int == 1)
            await h.hangUp(connection)
        }
    }

    /// The AI's docs say the strip where it meets the digest: each tool that
    /// answers the sha256 of text the client SENT carries the one null
    /// sentence, naming the answer key; the tools that send no text don't.
    @Test func theDigestToolsDescriptionsSayTheStrip() {
        let sending = [MCPToolCatalog.addTake, MCPToolCatalog.addTakes, MCPToolCatalog.createNote,
                       MCPToolCatalog.importDocument, MCPToolCatalog.insertBlocks, MCPToolCatalog.editTake]
        for tool in sending {
            #expect(tool.description.contains(MCPToolCatalog.nullSentence), "\(tool.name) says the strip")
        }
        #expect(MCPToolCatalog.nullSentence.contains(removedKey), "the sentence names the answer key")
        for tool in [MCPToolCatalog.readNote, MCPToolCatalog.duplicateNote, MCPToolCatalog.restoreCommit] {
            #expect(!tool.description.contains(MCPToolCatalog.nullSentence), "\(tool.name) sends no text")
        }
    }

    /// A write whose text holds no null character answers byte-unchanged:
    /// the key is absent (never 0).
    @Test func aWriteWithoutANullAnswersWithoutTheKey() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "fan")
            let one = try h.operations.newBlock(in: note.id, text: "Her words.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.suggest, .wing, ""))
            let added = try await call(connection, "add_take", [
                "block_id": .string(one.block.id), "text": .string("Clean words."),
            ])
            #expect(try json(added)[removedKey] == nil)
            #expect(!text(added).contains(removedKey))
            await h.hangUp(connection)
        }
    }
}
