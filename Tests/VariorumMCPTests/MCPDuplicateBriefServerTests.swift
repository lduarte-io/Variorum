import CryptoKit
import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-766 (the VX-771 run, batch 1): `duplicate_note`'s BRIEF FORM. The field
// report's #12: a 209-block note answered 71k characters and overflowed the
// client's context — the full answer carries a record per block (VX-252's, with
// every take's id and sha256). `brief: true` (schema-declared, so VX-606's call
// door knows it) answers the copy's ids and counts only — `note_id`,
// `source_note_id`, `tag_ids` + `tags`, `book_id`/`section_id` where given,
// `landed`, `block_count`, `take_count` — and NO per-block records. Without
// `brief` (or with `brief: false`) the answer is BYTE-UNCHANGED: pinned against
// the exact bytes captured on the tree before this change, in the harness's
// deterministic world.
//
// RED ON OLD: every `brief` call refused at the call door ("brief isn't an
// argument of duplicate_note …"); the golden pin green on both sides by design
// (it is the byte-unchanged guard).

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

@Suite("VX-766 — duplicate_note's brief form", .serialized)
struct MCPDuplicateBriefServerTests {
    /// A deterministic world: three blocks (the middle one fanned — two active
    /// takes, the second chosen and labelled, plus an archived one), one tag.
    /// Returns the source's id; the harness's ids are incrementing, its clock
    /// ticks by seconds, so the copy's answer is byte-reproducible.
    private func seed(_ h: ServerHarness) throws -> String {
        let source = try h.operations.createPost(title: "brief source")
        _ = try h.operations.newBlock(in: source.id, text: "One.", registeringUndo: false)
        let two = try h.operations.newBlock(in: source.id, text: "Two.", registeringUndo: false)
        let again = try h.operations.branchVariant(two.block.id, from: two.variant.id)
        try h.operations.autosave(again.id, text: "Two, again.", charDelta: 7)
        try h.operations.setTakeLabel(again.id, label: "again")
        try h.operations.chooseVariant(two.block.id, variantID: again.id)
        let shelved = try h.operations.newBlankVariant(two.block.id)
        try h.operations.archiveVariant(shelved.id)
        _ = try h.operations.newBlock(in: source.id, text: "Three.", registeringUndo: false)
        let tag = try h.operations.createTag(name: "essay")
        _ = try h.operations.applyTag(tag.id, toPost: source.id)
        return source.id
    }

    /// **THE BYTE-UNCHANGED GUARD.** Without `brief` — and with `brief:
    /// false` — the answer is exactly the bytes the tree before VX-766
    /// answered (captured there, in this same deterministic world).
    @Test(arguments: [false, true])
    func withoutBriefTheFullAnswerIsByteUnchanged(_ sayFalse: Bool) async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let sourceID = try seed(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            var arguments: [String: Value] = ["note_id": .string(sourceID)]
            if sayFalse { arguments["brief"] = .bool(false) }
            let duplicated = try await connection.client.callTool(name: "duplicate_note", arguments: arguments)
            #expect(duplicated.isError != true, "\(text(duplicated))")
            #expect(text(duplicated) == Self.goldenFullAnswer)
            await h.hangUp(connection)
        }
    }

    /// `brief: true`: the copy's ids and counts, no per-block records — the
    /// same act (the copy in the store, one client-named undo, the receipt),
    /// and the counts are the store's (read_note `ids_only` of the copy).
    /// **RED ON OLD:** refused at the call door, nothing minted.
    @Test func briefAnswersTheCopysIdsAndCountsOnly() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let sourceID = try seed(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            let depth = h.undoStack.depth

            let duplicated = try await connection.client.callTool(
                name: "duplicate_note", arguments: ["note_id": .string(sourceID), "brief": .bool(true)])
            #expect(duplicated.isError != true, "\(text(duplicated))")
            let answer = try json(duplicated)
            // A-771-2 (P-771-8): the brief form ALWAYS carries fan_sha256 — never a brief answer without it.
            #expect(Set(answer.keys)
                    == ["note_id", "source_note_id", "tag_ids", "tags", "landed", "block_count", "take_count",
                        "fan_sha256"],
                    "ids, counts and the fan digest — no block_ids, no per-block records")
            let copyID = try #require(answer["note_id"] as? String)
            #expect(copyID != sourceID && answer["source_note_id"] as? String == sourceID)
            #expect(answer["landed"] as? String == "the Pool of Home")
            #expect(answer["tags"] as? [String] == ["essay"] && (answer["tag_ids"] as? [String])?.count == 1)
            #expect(answer["block_count"] as? Int == 3)
            #expect(answer["take_count"] as? Int == 4, "1 + 2 + 1 — the archived take rides outside the fan")

            // The counts are the store's: read_note ids_only of the copy.
            let read = try json(try await connection.client.callTool(
                name: "read_note", arguments: ["note_id": .string(copyID), "ids_only": .bool(true)]))
            let blocks = read["blocks"] as? [[String: Any]] ?? []
            #expect(blocks.count == 3)
            #expect(blocks.reduce(0) { $0 + (($1["takes"] as? [Any])?.count ?? 0) } == 4)

            // The same act: one client-named entry, the receipt naming and opening the copy.
            #expect(h.undoStack.depth == depth + 1 && h.undoStack.topLabel == "claude-code's duplicate")
            let receipt = try #require(h.receipts.value.last)
            #expect(receipt.act == .duplicate && receipt.targetID == copyID)
            #expect(receipt.show == .note(noteID: copyID, blockID: nil, select: nil))
            await h.hangUp(connection)
        }
    }

    /// The book road keeps its echoes under `brief`: `book_id`, `section_id`,
    /// and `landed` naming the book and its chapter.
    @Test func briefOnTheBookRoadEchoesTheBookAndItsChapter() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let sourceID = try seed(h)
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let chapter = try h.operations.createSection(in: book.id, name: "part one")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, sourceID))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.writeNew, .book, book.id))

            let duplicated = try await connection.client.callTool(
                name: "duplicate_note",
                arguments: ["note_id": .string(sourceID), "book_id": .string(book.id),
                            "section_id": .string(chapter.id), "brief": .bool(true)])
            #expect(duplicated.isError != true, "\(text(duplicated))")
            let answer = try json(duplicated)
            #expect(Set(answer.keys) == ["note_id", "source_note_id", "tag_ids", "tags", "landed", "block_count",
                                         "take_count", "fan_sha256", "book_id", "section_id"])
            #expect(answer["book_id"] as? String == book.id && answer["section_id"] as? String == chapter.id)
            #expect(answer["landed"] as? String == "the end of \u{201C}drafts\u{201D}, in its chapter \u{201C}part one\u{201D}")
            #expect(answer["block_count"] as? Int == 3 && answer["take_count"] as? Int == 4)
            await h.hangUp(connection)
        }
    }

    /// The point of the form: a long note's brief answer stays small while its
    /// full answer grows with every block.
    @Test func aLongNotesBriefAnswerStaysSmall() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let source = try h.operations.createPost(title: "long")
            for index in 0..<120 {
                _ = try h.operations.newBlock(in: source.id, text: "Paragraph \(index).", registeringUndo: false)
            }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            let full = text(try await connection.client.callTool(
                name: "duplicate_note", arguments: ["note_id": .string(source.id)]))
            let brief = try await connection.client.callTool(
                name: "duplicate_note", arguments: ["note_id": .string(source.id), "brief": .bool(true)])
            #expect(brief.isError != true, "\(text(brief))")
            #expect(text(brief).count < 400, "\(text(brief).count) characters")
            #expect(full.count > 20 * text(brief).count, "the full form carries every block's record")
            let counts = try json(brief)
            #expect(counts["block_count"] as? Int == 120 && counts["take_count"] as? Int == 120)
            #expect((counts["fan_sha256"] as? String)?.count == 64, "the digest rides the long note's brief answer too")
            await h.hangUp(connection)
        }
    }

    /// **A-771-2 (fork F-2 — PROVISIONAL P-771-8): `fan_sha256`, computed BY HAND.** The text
    /// the description spells — one line per block in note order, each line that block's take
    /// sha256s in fan order separated by single spaces, the SHOWN take's prefixed `*`, lines
    /// joined by `\n`, no trailing newline — and its SHA-256, lowercase hex of the UTF-8 bytes,
    /// computed here with CryptoKit from LITERAL take digests (never the server's code). The
    /// client's road gives the same text from `read_note ids_only` on the SOURCE, and the `*`
    /// marker is load-bearing: choosing another take changes the digest.
    /// **RED ON OLD:** the brief answer carried no `fan_sha256`.
    @Test func theFanDigestIsTheSHA256OfTheSpelledText() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let sourceID = try seed(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            func sha256(_ text: String) -> String {
                SHA256.hash(data: Data(text.utf8)).map { String(format: "%02x", $0) }.joined()
            }
            // The seed's takes, digested by hand (the same values the full form's golden carries).
            let one = "70277bfc409b502132d7a48b2a3b386294264b31f7bf024a5fb0cafabb8ac122"    // "One."
            let two = "1eb32d1ee4458814f94f8b92d1bd3e06e16dca6fab43d53f700840321f27fdf4"    // "Two."
            let again = "5c70ad9e0d5befba10f7f51a9220133ee069baa71f7720e09af2f05a2ec889d1"  // "Two, again." — shown
            let three = "43c4d94ea2cd4fbece4f396e10852401108971f22e2f37707fbbb688ddc7fe3c"  // "Three."
            #expect([sha256("One."), sha256("Two."), sha256("Two, again."), sha256("Three.")]
                    == [one, two, again, three], "the literal digests are the takes' own")
            let spelled = "*\(one)\n\(two) *\(again)\n*\(three)"

            let duplicated = try await connection.client.callTool(
                name: "duplicate_note", arguments: ["note_id": .string(sourceID), "brief": .bool(true)])
            #expect(duplicated.isError != true, "\(text(duplicated))")
            #expect(try json(duplicated)["fan_sha256"] as? String == sha256(spelled))

            // The client's road: read_note ids_only on the SOURCE spells the very same text.
            let read = try json(try await connection.client.callTool(
                name: "read_note", arguments: ["note_id": .string(sourceID), "ids_only": .bool(true)]))
            let blocks = read["blocks"] as? [[String: Any]] ?? []
            let fromTheSource = blocks.map { block in
                (block["takes"] as? [[String: Any]] ?? []).map { take in
                    ((take["chosen"] as? Bool) == true ? "*" : "") + (take["sha256"] as? String ?? "")
                }.joined(separator: " ")
            }.joined(separator: "\n")
            #expect(fromTheSource == spelled, "computable client-side from the source")

            // The shown take is in the digest: her ✓ on the other take changes it.
            let middle = try #require(blocks.count == 3 ? blocks[1] : nil)
            let first = try #require((middle["takes"] as? [[String: Any]])?.first?["take_id"] as? String)
            try h.operations.chooseVariant(try #require(middle["block_id"] as? String), variantID: first)
            let rechosen = try await connection.client.callTool(
                name: "duplicate_note", arguments: ["note_id": .string(sourceID), "brief": .bool(true)])
            #expect(try json(rechosen)["fan_sha256"] as? String
                    == sha256("*\(one)\n*\(two) \(again)\n*\(three)"))
            await h.hangUp(connection)
        }
    }

    /// A-771-2: the DESCRIPTION is the contract a client checks against, so both tools whose
    /// brief answer carries the digest spell its text form, word for word the shared sentence.
    @Test func theDescriptionsSpellTheFanText() throws {
        let sentence = MCPToolCatalog.fanDigestSentence
        for fragment in ["fan_sha256 proves the copy whole", "one line per block in note order",
                         "take sha256s in fan order separated by single spaces", "the shown take's prefixed with *",
                         "lines joined by \\n with no trailing newline", "read_note with ids_only: true on the source"] {
            #expect(sentence.contains(fragment), "the sentence spells: \(fragment)")
        }
        for tool in [MCPToolCatalog.duplicateNote, MCPToolCatalog.copyNoteToWing] {
            #expect(tool.description.contains(sentence), "\(tool.name) spells the fan text")
        }
    }

    @Test func briefMustBeABoolean() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let sourceID = try seed(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            let notes = try await h.database.read {
                try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM container WHERE kind = 'post' AND deleted_at IS NULL")
            }
            let refused = try await connection.client.callTool(
                name: "duplicate_note", arguments: ["note_id": .string(sourceID), "brief": .string("yes")])
            #expect(refused.isError == true && text(refused) == "brief must be true or false.")
            let notesAfter = try await h.database.read {
                try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM container WHERE kind = 'post' AND deleted_at IS NULL")
            }
            #expect(notesAfter == notes, "nothing minted")
            await h.hangUp(connection)
        }
    }

    /// Captured on the tree BEFORE VX-766 (commit 3f2f650d4), this world, no
    /// `brief` — the bytes the full form must keep.
    static let goldenFullAnswer = #"{"block_ids":["00000000-0000-0000-0000-000000000011","00000000-0000-0000-0000-000000000015","00000000-0000-0000-0000-00000000001B"],"blocks":[{"block_id":"00000000-0000-0000-0000-000000000011","shown_take_id":"00000000-0000-0000-0000-000000000012","source_block_id":"00000000-0000-0000-0000-000000000001","takes":[{"sha256":"70277bfc409b502132d7a48b2a3b386294264b31f7bf024a5fb0cafabb8ac122","take_id":"00000000-0000-0000-0000-000000000012"}]},{"block_id":"00000000-0000-0000-0000-000000000015","shown_take_id":"00000000-0000-0000-0000-000000000017","source_block_id":"00000000-0000-0000-0000-000000000004","takes":[{"sha256":"1eb32d1ee4458814f94f8b92d1bd3e06e16dca6fab43d53f700840321f27fdf4","take_id":"00000000-0000-0000-0000-000000000016"},{"label":"again","sha256":"5c70ad9e0d5befba10f7f51a9220133ee069baa71f7720e09af2f05a2ec889d1","take_id":"00000000-0000-0000-0000-000000000017"}]},{"block_id":"00000000-0000-0000-0000-00000000001B","shown_take_id":"00000000-0000-0000-0000-00000000001C","source_block_id":"00000000-0000-0000-0000-000000000009","takes":[{"sha256":"43c4d94ea2cd4fbece4f396e10852401108971f22e2f37707fbbb688ddc7fe3c","take_id":"00000000-0000-0000-0000-00000000001C"}]}],"landed":"the Pool of Home","note_id":"00000000-0000-0000-0000-000000000010","source_note_id":"00000000-0000-0000-0000-000000000000","tag_ids":["00000000-0000-0000-0000-00000000000C"],"tags":["essay"]}"#
}
