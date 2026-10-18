import CryptoKit
import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-254 (VX-336 U7 — the run record `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md`,
// U7 UNIT RECORD D-254-1…6 and THE ORCHESTRATOR'S RULINGS ON U7's FORKS): A WRITE
// PROVES ITS OWN WORDS. Her bilingual-book run's one transcription slip
// ("beliscáu" → "beliscou", ch. 11) was caught only by reading 130k characters
// back. Every tool that writes a take's text from words the client SENT now
// answers, per take, `sha256`: the SHA-256 of the take's text exactly as the act
// stored it, its UTF-8 bytes in lowercase hex, nothing normalized or trimmed — so
// the client digests its own source and compares, no read-back. The minted
// records (`create_note`, `import_document` one document, `insert_blocks`,
// `duplicate_note`) carry it on every take object (`MCPMintedBlocks`, the one
// encoder); the flat answers (`add_take`, `edit_take`, `restore_commit`) one key;
// `add_takes` a `takes` list of objects beside its unchanged `take_ids` (F-254-5
// (a), the no-positional rule). Ruled OUT (guards below, green on both sides):
// `divide_block` / `merge_blocks` (F-254-2 (b) — no words sent; the halves come
// from the seam rule) and the book-form import (F-254-4 (a) — its answer stays
// `book_id, note_ids, chapter_ids`; pinned in `MCPMintedAnswerServerTests`).
//
// Wire only (the SDK's own client over a real socket). Every expected digest is
// computed HERE, by CryptoKit over the text's UTF-8 bytes — never by the product's
// `MCPTextDigest` — so each pin compiles on the tree before the sweep and runs RED
// there by absence (no `sha256` in any answer).

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

/// The test's own digest — plain SHA-256 of the UTF-8 bytes, lowercase hex
/// (what `shasum -a 256` prints).
private func digest(_ text: String) -> String {
    SHA256.hash(data: Data(text.utf8)).map { String(format: "%02x", $0) }.joined()
}

private let emptyDigest = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

/// Per block of a minted answer: its takes' `(take_id, sha256)` in fan order.
private func answeredTakes(_ answer: [String: Any]) -> [[(id: String, sha256: String?)]] {
    (answer["blocks"] as? [[String: Any]] ?? []).map { block in
        (block["takes"] as? [[String: Any]] ?? []).map { take in
            (take["take_id"] as? String ?? "", take["sha256"] as? String)
        }
    }
}

/// `read_note with_ids`, as `take_id → stored text`.
private func storedTexts(_ read: [String: Any]) -> [String: String] {
    var texts: [String: String] = [:]
    for block in read["blocks"] as? [[String: Any]] ?? [] {
        for take in block["takes"] as? [[String: Any]] ?? [] {
            if let id = take["take_id"] as? String { texts[id] = take["text"] as? String }
        }
    }
    return texts
}

@Suite("VX-254 — a write answers each take's sha256 of the text it stored", .serialized)
struct MCPWriteDigestServerTests {
    private func readWithIDs(_ connection: HarnessConnection, _ noteID: String) async throws -> [String: Any] {
        try json(try await call(connection, "read_note", ["note_id": .string(noteID), "with_ids": .bool(true)]))
    }

    /// Every take of a minted answer digests what `read_note` reads back for
    /// that take — the store and the answer agree byte for byte.
    private func expectAnswerMatchesTheStore(
        _ answer: [String: Any], _ read: [String: Any], _ what: String
    ) {
        let stored = storedTexts(read)
        let takes = answeredTakes(answer).flatMap { $0 }
        #expect(!takes.isEmpty, "\(what): the answer lists takes")
        for take in takes {
            #expect(take.sha256 != nil, "\(what): take \(take.id) answers its sha256")
            #expect(take.sha256 == stored[take.id].map(digest), "\(what): take \(take.id) digests the stored text")
        }
    }

    // MARK: - The minted records (the one encoder)

    /// P-254-2: `create_note` with `blocks` — each take's digest is the digest
    /// of the text SENT, through curly quotes, an em dash, an embedded newline,
    /// a trailing space, an emoji, a decomposed é and a blank take.
    @Test func createNoteBlocksAnswersEachTakesDigestOfTheTextSentByteForByte() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            let sent: [[String]] = [
                ["\u{201C}Ol\u{00E1},\u{201D} disse ela \u{2014} e foi.", "first line\nsecond line", ""],
                ["trailing space ", "\u{1F989} an owl"],
                ["cafe\u{0301}"],
            ]
            let blocks: [Value] = sent.map { texts in
                .object([
                    "text": .string(texts[0]),
                    "takes": .array(texts.dropFirst().map { .object(["text": .string($0)]) }),
                ])
            }
            let created = try await call(connection, "create_note", [
                "wing_id": .string(""), "title": .string("digests"), "blocks": .array(blocks),
            ])
            #expect(created.isError != true, "\(text(created))")
            let answer = try json(created)
            let answered = answeredTakes(answer)
            #expect(answered.map { $0.map(\.sha256) } == sent.map { $0.map { Optional(digest($0)) } },
                    "every take, in fan order, digests the bytes sent")
            #expect(answered[0][2].sha256 == emptyDigest, "a blank take is answered and recognizable")
            #expect(answered[2][0].sha256 != digest("caf\u{00E9}"), "nothing is normalized: NFD is not NFC")
            let noteID = try #require(answer["note_id"] as? String)
            expectAnswerMatchesTheStore(answer, try await readWithIDs(connection, noteID), "create_note blocks")
            await h.hangUp(connection)
        }
    }

    /// P-254-3: `create_note` with plain `text` — the prose is segmented by her
    /// setting, so each record digests what was STORED (read_note agrees).
    @Test func createNoteTextAnswersTheDigestOfEachStoredBlock() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            let created = try await call(connection, "create_note", [
                "wing_id": .string(""), "title": .string("prose"),
                "text": .string("Um.\n\nDois \u{2014} tr\u{00EA}s."),
            ])
            #expect(created.isError != true, "\(text(created))")
            let answer = try json(created)
            #expect(answeredTakes(answer).map(\.count) == [1, 1], "two blocks, one take each")
            let noteID = try #require(answer["note_id"] as? String)
            expectAnswerMatchesTheStore(answer, try await readWithIDs(connection, noteID), "create_note text")
            await h.hangUp(connection)
        }
    }

    /// P-254-4: `import_document`, one document — every minted take digests
    /// what the store holds.
    @Test func importDocumentAnswersEachMintedTakesDigest() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            let source = try h.operations.createPost(title: "to K")
            let one = try h.operations.newBlock(in: source.id, text: "Dear K,", registeringUndo: false)
            let alternate = try h.operations.newBlankVariant(one.block.id)
            try h.operations.autosave(alternate.id, text: "Dearest K \u{2014}", charDelta: 11)
            _ = try h.operations.newBlock(in: source.id, text: "Yours.", registeringUndo: false)
            let document = try await h.database.read { try Queries.variorumDocumentText($0, postID: source.id) }
            let imported = try await call(connection, "import_document", [
                "document": .string(document), "wing_id": .string(""),
            ])
            #expect(imported.isError != true, "\(text(imported))")
            let answer = try json(imported)
            #expect(answeredTakes(answer).map { $0.map(\.sha256) }
                    == [[digest("Dear K,"), digest("Dearest K \u{2014}")], [digest("Yours.")]])
            let noteID = try #require(answer["note_id"] as? String)
            expectAnswerMatchesTheStore(answer, try await readWithIDs(connection, noteID), "import_document")
            await h.hangUp(connection)
        }
    }

    /// P-254-5: `insert_blocks` — each new block's takes digest the text sent.
    @Test func insertBlocksAnswersEachTakesDigestOfTheTextSent() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "growing")
            _ = try h.operations.newBlock(in: note.id, text: "Already here.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            let inserted = try await call(connection, "insert_blocks", [
                "note_id": .string(note.id),
                "blocks": .array([
                    .object(["text": .string("Novo \u{2014} um."),
                             "takes": .array([.object(["text": .string("New \u{2014} one."), "label": .string("en")])])]),
                    .object(["text": .string("two\n\nparagraphs, one block")]),
                ]),
            ])
            #expect(inserted.isError != true, "\(text(inserted))")
            let answer = try json(inserted)
            #expect(answeredTakes(answer).map { $0.map(\.sha256) }
                    == [[digest("Novo \u{2014} um."), digest("New \u{2014} one.")],
                        [digest("two\n\nparagraphs, one block")]])
            expectAnswerMatchesTheStore(answer, try await readWithIDs(connection, note.id), "insert_blocks")
            await h.hangUp(connection)
        }
    }

    /// P-254-6: `duplicate_note` — a copy take's digest equals its SOURCE take's
    /// (matched through `source_block_id`, fan order), so a client checks the
    /// copy against what it read.
    @Test func duplicateNoteAnswersEachCopyTakesDigestEqualToItsSourceTakes() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "original")
            let one = try h.operations.newBlock(in: note.id, text: "Ol\u{00E1}.", registeringUndo: false)
            let other = try h.operations.newBlankVariant(one.block.id)
            try h.operations.autosave(other.id, text: "Hello \u{1F44B}", charDelta: 7)
            _ = try h.operations.newBlock(in: note.id, text: "Adeus.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            let source = try await readWithIDs(connection, note.id)
            var sourceTexts: [String: [String]] = [:]
            for block in source["blocks"] as? [[String: Any]] ?? [] {
                sourceTexts[block["block_id"] as? String ?? ""] =
                    (block["takes"] as? [[String: Any]] ?? []).map { $0["text"] as? String ?? "" }
            }
            let copied = try await call(connection, "duplicate_note", ["note_id": .string(note.id)])
            #expect(copied.isError != true, "\(text(copied))")
            let answer = try json(copied)
            let records = answer["blocks"] as? [[String: Any]] ?? []
            #expect(records.count == 2)
            for record in records {
                let from = try #require(record["source_block_id"] as? String)
                let digests = (record["takes"] as? [[String: Any]] ?? []).map { $0["sha256"] as? String }
                #expect(digests == (sourceTexts[from] ?? []).map { Optional(digest($0)) },
                        "the copy of \(from) digests as its source reads")
            }
            let copyID = try #require(answer["note_id"] as? String)
            expectAnswerMatchesTheStore(answer, try await readWithIDs(connection, copyID), "duplicate_note")
            await h.hangUp(connection)
        }
    }

    // MARK: - The flat answers

    /// P-254-7: `add_take` — its digest is the sent text's; a blank take's is
    /// the empty digest.
    @Test func addTakeAnswersTheDigestOfTheTextSent() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "fan")
            let one = try h.operations.newBlock(in: note.id, text: "Her words.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.suggest, .wing, ""))
            let added = try await call(connection, "add_take", [
                "block_id": .string(one.block.id), "text": .string("Ela belisc\u{00E1}u o bra\u{00E7}o."),
            ])
            #expect(added.isError != true, "\(text(added))")
            let answer = try json(added)
            #expect(answer["sha256"] as? String == digest("Ela belisc\u{00E1}u o bra\u{00E7}o."))
            #expect(answer["sha256"] as? String != digest("Ela beliscou o bra\u{00E7}o."), "the slip is caught")
            let blank = try json(try await call(connection, "add_take", [
                "block_id": .string(one.block.id), "text": .string(""),
            ]))
            #expect(blank["sha256"] as? String == emptyDigest)
            let stored = storedTexts(try await readWithIDs(connection, note.id))
            for take in [answer, blank] {
                let id = try #require(take["take_id"] as? String)
                #expect(take["sha256"] as? String == stored[id].map(digest), "the answer digests the stored take")
            }
            await h.hangUp(connection)
        }
    }

    /// P-254-8: `add_takes` — `takes[i]` is `{take_id: take_ids[i], block_id:
    /// items[i].block_id, label (as stored), sha256}`; `take_ids` unchanged.
    @Test func addTakesAnswersATakeObjectPerItemBesideTheUnchangedTakeIDs() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "fan")
            let one = try h.operations.newBlock(in: note.id, text: "Um.", registeringUndo: false)
            let two = try h.operations.newBlock(in: note.id, text: "Dois.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.suggest, .wing, ""))
            let items: [(block: String, text: String, label: String?)] = [
                (two.block.id, "Two.", "english"), (one.block.id, "One \u{2014} at last ", nil), (two.block.id, "", nil),
            ]
            let added = try await call(connection, "add_takes", [
                "note_id": .string(note.id),
                "takes": .array(items.map { item in
                    var fields: [String: Value] = ["block_id": .string(item.block), "text": .string(item.text)]
                    if let label = item.label { fields["label"] = .string(label) }
                    return .object(fields)
                }),
            ])
            #expect(added.isError != true, "\(text(added))")
            let answer = try json(added)
            let ids = try #require(answer["take_ids"] as? [String])
            #expect(ids.count == 3, "take_ids stays, in the items' order")
            let takes = try #require(answer["takes"] as? [[String: Any]])
            #expect(takes.count == 3)
            for (index, item) in items.enumerated() where index < takes.count {
                #expect(takes[index]["take_id"] as? String == ids[index])
                #expect(takes[index]["block_id"] as? String == item.block)
                #expect(takes[index]["label"] as? String
                        == MCPWriteTools.aiLabel(client: "claude-code", own: item.label), "the label as stored")
                #expect(takes[index]["sha256"] as? String == digest(item.text))
            }
            let stored = storedTexts(try await readWithIDs(connection, note.id))
            for take in takes {
                #expect(take["sha256"] as? String == (take["take_id"] as? String).flatMap { stored[$0] }.map(digest))
            }
            await h.hangUp(connection)
        }
    }

    /// P-254-9: `edit_take` — the new text's digest; on `changed: false` the
    /// current text's.
    @Test func editTakeAnswersTheDigestOfTheTextItStored() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "ch 11")
            let one = try h.operations.newBlock(in: note.id, text: "Ela beliscou.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let edited = try json(try await call(connection, "edit_take", [
                "take_id": .string(one.variant.id), "text": .string("Ela belisc\u{00E1}u."),
                "expected_text": .string("Ela beliscou."),
            ]))
            #expect(edited["changed"] as? Bool == true)
            #expect(edited["sha256"] as? String == digest("Ela belisc\u{00E1}u."))
            let same = try json(try await call(connection, "edit_take", [
                "take_id": .string(one.variant.id), "text": .string("Ela belisc\u{00E1}u."),
                "expected_text": .string("Ela belisc\u{00E1}u."),
            ]))
            #expect(same["changed"] as? Bool == false)
            #expect(same["sha256"] as? String == digest("Ela belisc\u{00E1}u."), "nothing written: the current text's")
            #expect(storedTexts(try await readWithIDs(connection, note.id))[one.variant.id].map(digest)
                    == edited["sha256"] as? String)
            await h.hangUp(connection)
        }
    }

    /// P-254-10: `restore_commit` — the digest of the commit's text, now the take's.
    @Test func restoreCommitAnswersTheDigestOfTheRestoredText() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "ch 1")
            let one = try h.operations.newBlock(in: note.id, text: "First \u{2014} draft.", registeringUndo: false)
            let first = try h.operations.commit(one.variant.id, message: "first")
            try h.operations.autosave(one.variant.id, text: "Second draft.", charDelta: 6)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let restored = try json(try await call(connection, "restore_commit", ["commit_id": .string(first.id)]))
            #expect(restored["changed"] as? Bool == true)
            #expect(restored["sha256"] as? String == digest("First \u{2014} draft."))
            #expect(storedTexts(try await readWithIDs(connection, note.id))[one.variant.id].map(digest)
                    == restored["sha256"] as? String)
            await h.hangUp(connection)
        }
    }

    // MARK: - THE U+0000 CHECK (VX-357 — FIXED in VX-348 U1; was the carried OWED 2)

    /// **VX-357, FLIPPED from the known issue it was pinned as** (builder A,
    /// 2026-10-14: a take holding U+0000 was STORED TRUNCATED at its first NUL
    /// — GRDB binds TEXT with length -1, `StandardLibrary.swift:625`, so
    /// "before\0after" (12 bytes) landed as "before" (6) while the answer's
    /// sha256 digested the 12 bytes sent: the one case where the digest
    /// overclaimed). Her ruling (2026-10-15): STRIP it in the operations layer
    /// and, on this door, ALWAYS say it. So the store keeps "beforeafter" (11
    /// bytes — nothing after the null is lost), `read_note` returns it, the
    /// answer's sha256 digests exactly that (the stored text — the fingerprint
    /// stays true), and `null_characters_removed` says 1. RED ON OLD: the store
    /// held 6 bytes, a read returned "before", the digest was the sent bytes'
    /// and no count was said (the run record's red-on-old leg, on the pre-fix
    /// tree).
    @Test func aTakeHoldingUPlus0000IsStoredWithoutItAndTheAnswerSaysHowMany() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "nul")
            let one = try h.operations.newBlock(in: note.id, text: "Her words.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.suggest, .wing, ""))
            let sent = "before\u{0000}after"
            let added = try await call(connection, "add_take", [
                "block_id": .string(one.block.id), "text": .string(sent),
            ])
            #expect(added.isError != true, "the door accepts the call: \(text(added))")
            let answer = try json(added)
            let id = try #require(answer["take_id"] as? String)
            let read = storedTexts(try await readWithIDs(connection, note.id))[id]
            let storedBytes = try await h.database.read { db in
                try Int.fetchOne(
                    db, sql: "SELECT length(CAST(working_text AS BLOB)) FROM variant WHERE id = ?", arguments: [id])
            }
            #expect(Array(sent.utf8).count == 12 && storedBytes == 11, "every byte but the NUL kept")
            #expect(read == "beforeafter", "read_note returns what the store holds")
            #expect(answer["sha256"] as? String == digest("beforeafter"), "the answer digests the STORED text")
            #expect(answer["sha256"] as? String == read.map(digest), "the answer digests what a read returns")
            #expect(answer["sha256"] as? String != digest(sent), "never the bytes sent")
            #expect(answer["null_characters_removed"] as? Int == 1, "the door says how many it removed")
            await h.hangUp(connection)
        }
    }

    // MARK: - GUARDS (green on both sides, by design — not red pins)

    /// F-254-2 (b), ruled: a divide or a merge sends no words — its halves
    /// come from the seam rule — so neither answers a digest (`ids_only`
    /// pages verify them); the structural core's result types stay untouched.
    @Test func divideAndMergeAnswerNoDigest() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "cuts")
            let one = try h.operations.newBlock(in: note.id, text: "First half. Second half.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let divided = try await call(connection, "divide_block", [
                "block_id": .string(one.block.id), "second_half_starts_with": .string("Second"),
            ])
            #expect(divided.isError != true, "\(text(divided))")
            let halves = try json(divided)
            #expect(!text(divided).contains("sha256"))
            let merged = try await call(connection, "merge_blocks", [
                "first_block_id": .string(try #require(halves["first_block_id"] as? String)),
                "second_block_id": .string(try #require(halves["second_block_id"] as? String)),
            ])
            #expect(merged.isError != true, "\(text(merged))")
            #expect(!text(merged).contains("sha256"))
            await h.hangUp(connection)
        }
    }
}
