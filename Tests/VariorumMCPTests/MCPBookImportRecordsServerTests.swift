import CryptoKit
import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-567 (the VX-620 run, batch 3 — the record
// `notes/plans/fixes/vx-620-run-mcp-umbrella-remainder.md`, BATCH 3 RECORD). The
// agent report: the BOOK form of `import_document` answers without per-take
// hashes, so verifying a batch means reading every note back — the agent fell back
// to importing one note at a time. "Return per-take sha256s like the single-note
// form." THE BUILD (PROVISIONAL RB-4 — it supersedes P-VX252-1 / P-VX254-2, which
// she RATIFIED 2026-10-15 as "ids only", on the strength of this ticket, seated in
// her run): the book form's answer keeps `book_id`, `note_ids` and `chapter_ids` and
// gains `notes` — per minted note, in `note_ids`' order, VX-252's record exactly:
// `note_id`, `block_ids`, and `blocks` (per block its `block_id`, `shown_take_id` and
// every take in fan order as `{take_id, label?, sha256}` — no text), built from what
// the act minted, never a second read.
//
// Wire only (the SDK's own client over a real socket). Every expected digest is
// computed HERE, by CryptoKit over the sent text's UTF-8 bytes (the VX-254 suite's
// rule), so the pins compile on the old tree and run RED there by absence (no
// `notes` in the book form's answer).

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

/// Plain SHA-256 of the UTF-8 bytes, lowercase hex (what `shasum -a 256` prints).
private func digest(_ text: String) -> String {
    SHA256.hash(data: Data(text.utf8)).map { String(format: "%02x", $0) }.joined()
}

/// One block as a record says it: id, shown take, and every take's id, label and digest.
private struct Record: Equatable, CustomStringConvertible {
    let blockID: String
    let shownTakeID: String?
    let takes: [String]
    let labels: [String?]
    var description: String { "\(blockID) shows \(shownTakeID ?? "-") of \(takes) labelled \(labels)" }

    static func answered(_ blocks: Any?) -> [Record]? {
        guard let blocks = blocks as? [[String: Any]] else { return nil }
        return blocks.map { block in
            let takes = block["takes"] as? [[String: Any]] ?? []
            return Record(
                blockID: block["block_id"] as? String ?? "", shownTakeID: block["shown_take_id"] as? String,
                takes: takes.map { $0["take_id"] as? String ?? "" }, labels: takes.map { $0["label"] as? String })
        }
    }

    /// `read_note with_ids`' blocks — the store, read back.
    static func read(_ read: [String: Any]) -> [Record] {
        answered(read["blocks"]) ?? []
    }
}

@Suite("VX-567 — a whole book's import answers every note's records, each take's sha256", .serialized)
struct MCPBookImportRecordsServerTests {
    /// A note as the export writes it (Alternates sections and labels), so the
    /// format's own spelling is what the book form reads.
    private func exported(_ h: ServerHarness, _ title: String, _ blocks: [(String, [(String, String?)])]) throws -> String {
        let ops = h.operations
        let source = try ops.createPost(title: title)
        for (text, alternates) in blocks {
            let placed = try ops.newBlock(in: source.id, text: text, registeringUndo: false)
            for (alternate, label) in alternates {
                let take = try ops.newBlankVariant(placed.block.id)
                try ops.autosave(take.id, text: alternate, charDelta: alternate.count)
                if let label { try ops.setTakeLabel(take.id, label: label) }
            }
        }
        return try h.database.read { try Queries.variorumDocumentText($0, postID: source.id) }
    }

    @Test func aWholeBookAnswersEveryNotesRecordsWithEachTakesDigest() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            // What the client sends: the in-place text, then each alternate, in fan order.
            let sent: [[[String]]] = [
                [["Olá.", "Hello.", "Hi."], ["Adeus."]],  // chapter "um", note 1
                [["Capítulo dois."]],                      // chapter "um", note 2
                [["Posfácio.", "Afterword."]],             // unfiled
            ]
            let one = try exported(h, "um", [("Olá.", [("Hello.", "english"), ("Hi.", nil)]), ("Adeus.", [])])
            let two = try exported(h, "dois", [("Capítulo dois.", [])])
            let after = try exported(h, "posfácio", [("Posfácio.", [("Afterword.", "english")])])
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))

            let imported = try await call(connection, "import_document", [
                "wing_id": .string(""),
                "book": .object([
                    "name": .string("o ladrão de raios"),
                    "chapters": .array([.object(["name": .string("um"),
                                                 "documents": .array([.string(one), .string(two)])])]),
                    "documents": .array([.string(after)]),
                ]),
            ])
            #expect(imported.isError != true, "\(text(imported))")
            let answer = try json(imported)
            #expect(Set(answer.keys) == ["book_id", "note_ids", "chapter_ids", "notes"],
                    "the three id lists stay; the notes' records join them: \(answer.keys.sorted())")
            let noteIDs = try #require(answer["note_ids"] as? [String])
            let notes = try #require(answer["notes"] as? [[String: Any]], "the book form answers its notes' records")
            #expect(notes.compactMap { $0["note_id"] as? String } == noteIDs, "one record per note, in note_ids' order")
            #expect(notes.count == 3)

            for (index, note) in notes.enumerated() {
                #expect(Set(note.keys) == ["note_id", "block_ids", "blocks"], "VX-252's record: \(note.keys.sorted())")
                let noteID = try #require(note["note_id"] as? String)
                let read = try json(try await call(connection, "read_note",
                                                   ["note_id": .string(noteID), "with_ids": .bool(true)]))
                let stored = Record.read(read)
                #expect(Record.answered(note["blocks"]) == stored,
                        "note \(index): every block, its shown take, every take with its label — as the store holds")
                #expect(note["block_ids"] as? [String] == stored.map(\.blockID), "note \(index): block_ids")
                // Each take's sha256 is the digest of the words the client sent for it, no text riding.
                let blocks = note["blocks"] as? [[String: Any]] ?? []
                let digests = blocks.map { ($0["takes"] as? [[String: Any]] ?? []).map { $0["sha256"] as? String } }
                #expect(digests == sent[index].map { $0.map { Optional(digest($0)) } }, "note \(index): \(digests)")
                for take in blocks.flatMap({ $0["takes"] as? [[String: Any]] ?? [] }) {
                    #expect(Set(take.keys).isSubset(of: ["take_id", "label", "sha256"]), "no text: \(take.keys.sorted())")
                }
            }
            await h.hangUp(connection)
        }
    }

    /// The catalog says what the book form answers — and no longer that it has
    /// no sha256 (the sentence VX-567 retires).
    @Test func theDescriptionSaysTheBookFormsRecords() {
        let description = MCPToolCatalog.importDocument.description
        #expect(!description.contains("no sha256"), "\(description)")
        #expect(description.contains("for a book, its book_id, note_ids and chapter_ids, and notes"), "\(description)")
    }
}
