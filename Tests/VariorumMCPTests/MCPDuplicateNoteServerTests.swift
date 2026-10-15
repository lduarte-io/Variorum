import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-311 (VX-336 U6a — the run record `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md`,
// U6a UNIT RECORD D-311-1…8 and THE ORCHESTRATOR'S RULINGS ON U6a's FORKS): HER DUPLICATE
// AS VERSION ON THE WIRE. Compare lines its rows up by shared `derived_from` lineage
// (`Queries.blockKinship`); a `create_note` draft shares none, so Compare opened to empty
// columns and an AI had no road to a lineage-aligned draft. `duplicate_note` wraps her own
// op (`duplicateAsVersion`'s body, extracted once): the copy lands BOOKLESS in the source's
// wing (her door's landing — P-VX311-2), decided at READ on the source and at WRITE NEW on
// that wing (`move_note_to_wing`'s two-sided shape, both once grants spent as one union in
// the act's own transaction); a fenced source the client can read refuses in ONE sentence
// that names no leg (P-VX311-1 — a copy would shed two of the three fence legs); the answer
// is VX-252's records from what the copy MINTED, each naming its `source_block_id`
// (P-VX311-3); ONE client-named ⌥⌘Z; the receipt's Open › opens the copy.
//
// Wire only (the SDK's own client over a real socket), so every pin compiles — and runs RED
// by ABSENCE — on the tree before the fix: there every call answered
// `Unknown tool: duplicate_note.` (the act read by `rawValue`, the fence sentence a literal).

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

/// One block as an answer's record says it — or as `read_note with_ids` reads it.
private struct BlockRecord: Equatable, CustomStringConvertible {
    let blockID: String
    let shownTakeID: String?
    let takes: [String]
    let labels: [String?]

    var description: String { "\(blockID) shows \(shownTakeID ?? "-") of \(takes) labelled \(labels)" }

    static func records(_ object: [String: Any]) -> [BlockRecord]? {
        guard let blocks = object["blocks"] as? [[String: Any]] else { return nil }
        return blocks.map { block in
            let takes = block["takes"] as? [[String: Any]] ?? []
            return BlockRecord(
                blockID: block["block_id"] as? String ?? "", shownTakeID: block["shown_take_id"] as? String,
                takes: takes.map { $0["take_id"] as? String ?? "" }, labels: takes.map { $0["label"] as? String })
        }
    }
}

/// THE FENCE's one sentence (D-311-3, P-VX311-1) — no leg named.
private let fencedWords =
    "This note is shared with you only per ask, so it can't be duplicated \u{2014} a copy would reach further "
    + "than the note does. The author can duplicate it in Variorum."

@Suite("VX-311 — duplicate_note: her Duplicate as Version on the wire", .serialized)
struct MCPDuplicateNoteServerTests {
    private func liveNotes(_ h: ServerHarness) async throws -> Int {
        try await h.database.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM container WHERE kind = 'post' AND deleted_at IS NULL") ?? -1
        }
    }

    private func consumed(_ h: ServerHarness, _ grantID: String?) async throws -> Bool {
        try await h.database.read { db in
            try String.fetchOne(db, sql: "SELECT consumed_at FROM mcp_grant WHERE id = ?", arguments: [grantID]) != nil
        }
    }

    // MARK: - The landing, the answer, the lineage, the undo, the receipt

    /// READ on the note + WRITE NEW on its wing lands the copy bookless in that wing's Pool,
    /// with the source's tags, every take and the lineage Compare reads; the answer is the
    /// copy's records — equal to `read_note with_ids` of the copy — each naming its source
    /// block. **RED on old:** `Unknown tool: duplicate_note.`
    @Test func theCopyLandsBooklessInTheSourcesWingAndAnswersWhatItMinted() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let source = try h.operations.createPost(title: "u6a source")
            _ = try h.operations.addPostToReading(source.id, to: book.id)
            let one = try h.operations.newBlock(in: source.id, text: "One.", registeringUndo: false)
            let two = try h.operations.newBlock(in: source.id, text: "Two.", registeringUndo: false)
            let again = try h.operations.branchVariant(two.block.id, from: two.variant.id)
            try h.operations.autosave(again.id, text: "Two, again.", charDelta: 7)
            try h.operations.setTakeLabel(again.id, label: "again")
            try h.operations.chooseVariant(two.block.id, variantID: again.id)
            let shelved = try h.operations.newBlankVariant(two.block.id)
            try h.operations.archiveVariant(shelved.id)
            let three = try h.operations.newBlock(in: source.id, text: "Three.", registeringUndo: false)
            let tag = try h.operations.createTag(name: "essay")
            _ = try h.operations.applyTag(tag.id, toPost: source.id)
            let sourceText = try await h.database.read { try Queries.renderedText($0, containerID: source.id) }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, source.id))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.writeNew, .wing, ""))
            let depth = h.undoStack.depth

            let duplicated = try await call(connection, "duplicate_note", ["note_id": .string(source.id)])
            #expect(duplicated.isError != true, "\(text(duplicated))")
            let answer = try json(duplicated)
            let copyID = try #require(answer["note_id"] as? String)
            #expect(copyID != source.id)
            #expect(answer["source_note_id"] as? String == source.id)
            #expect(answer["landed"] as? String == "the Pool of Home", "her door's landing, said in its words")

            // The answer IS the store: read_note with ids of the copy, record for record.
            let read = try json(try await call(connection, "read_note",
                                               ["note_id": .string(copyID), "with_ids": .bool(true)]))
            let stored = try #require(BlockRecord.records(read))
            #expect(BlockRecord.records(answer) == stored, "every block, its shown take, every ACTIVE take in fan order")
            #expect(stored.map(\.takes.count) == [1, 2, 1], "the archived take rides the note, outside the fan")
            #expect(stored[1].labels == [nil, "again"])
            #expect(stored[1].shownTakeID == stored[1].takes[1], "the copy shows what the source chose")
            #expect(answer["block_ids"] as? [String] == stored.map(\.blockID), "block_ids stays (F-6)")
            let sources = (answer["blocks"] as? [[String: Any]] ?? []).map { $0["source_block_id"] as? String }
            #expect(sources == [one.block.id, two.block.id, three.block.id], "each record names the block it copies")

            // THE VX-311 POINT: Compare's kinship maps EVERY copy block to its source block.
            let kinship = try await h.database.read { db in
                try Queries.blockKinship(db, anchor: source.id, other: copyID)
            }
            #expect(kinship == Dictionary(uniqueKeysWithValues: zip(
                stored.map(\.blockID), [one.block.id, two.block.id, three.block.id])))

            // Bookless, in the source's wing, the tags riding; the source untouched.
            let (memberships, wing, tags) = try await h.database.read { db in
                (try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                                  arguments: [copyID]),
                 try String.fetchOne(db, sql: "SELECT wing_id FROM container WHERE id = ?", arguments: [copyID]),
                 try String.fetchAll(db, sql: "SELECT tag_id FROM post_tag WHERE post_id = ? AND deleted_at IS NULL",
                                     arguments: [copyID]))
            }
            #expect(memberships == 0 && wing == "" && tags == [tag.id])
            #expect(try await h.database.read { try Queries.renderedText($0, containerID: source.id) } == sourceText)
            #expect(try await h.database.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                                 arguments: [source.id])
            } == 1, "the source keeps its book")

            // ONE client-named entry; the receipt names the copy and opens it.
            #expect(h.undoStack.depth == depth + 1 && h.undoStack.topLabel == "claude-code's duplicate")
            let receipt = try #require(h.receipts.value.last)
            #expect(receipt.act.rawValue == "duplicate" && receipt.targetID == copyID
                    && receipt.targetTitle == "u6a source")
            #expect(receipt.show == .note(noteID: copyID, blockID: nil, select: nil), "Open › opens the copy (F-5)")

            // Her ⌥⌘Z tombstones the copy; ⇧⌥⌘Z returns it.
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's duplicate")
            #expect(try await h.database.read { try Container.fetchOne($0, key: copyID)?.deletedAt } != nil)
            #expect(try h.undoStack.redo(with: h.writeOperations) == "claude-code's duplicate")
            #expect(try await h.database.read { try Container.fetchOne($0, key: copyID)?.deletedAt } == nil)
            await h.hangUp(connection)
        }
    }

    /// Another wing's note lands in THAT wing's Pool, said with its name.
    @Test func aCopyInAnotherWingLandsInThatWingsPool() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let wing = try h.operations.createWing(name: "research")
            let source = try h.operations.createPost(title: "field notes", wingId: wing.id)
            _ = try h.operations.newBlock(in: source.id, text: "Seen.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, wing.id))

            let duplicated = try await call(connection, "duplicate_note", ["note_id": .string(source.id)])
            #expect(duplicated.isError != true, "\(text(duplicated))")
            let answer = try json(duplicated)
            #expect(answer["landed"] as? String == "the Pool of \u{201C}research\u{201D}")
            let copyID = try #require(answer["note_id"] as? String)
            #expect(try await h.database.read { db in
                try String.fetchOne(db, sql: "SELECT wing_id FROM container WHERE id = ?", arguments: [copyID])
            } == wing.id)
            await h.hangUp(connection)
        }
    }

    // MARK: - The one not-shared shape (no oracle)

    /// Missing, tombstoned, a version, a scraps group, another wing's note, an UNREACHED fenced
    /// note: each answers byte-identically to an id naming nothing, and nothing is minted.
    /// **RED on old:** `Unknown tool: duplicate_note.` for all (and the reference itself).
    @Test func anUnreachableSourceAnswersTheOneNotSharedShapeAndMintsNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let elsewhere = try h.operations.createWing(name: "elsewhere")
            let foreign = try h.operations.createPost(title: "theirs", wingId: elsewhere.id)
            _ = try h.operations.newBlock(in: foreign.id, text: "Not yours.", registeringUndo: false)
            let kept = try h.operations.createPost(title: "kept")
            _ = try h.operations.newBlock(in: kept.id, text: "Kept.", registeringUndo: false)
            let version = try h.operations.saveNoteVersion(kept.id)
            let gone = try h.operations.createPost(title: "gone")
            _ = try h.operations.newBlock(in: gone.id, text: "Gone.", registeringUndo: false)
            try h.operations.deleteContainer(gone.id)
            let scraps = try h.operations.createPool(title: "scraps")
            let hidden = try h.operations.createPost(title: "hidden")
            _ = try h.operations.newBlock(in: hidden.id, text: "Private words.", registeringUndo: false)
            _ = try h.operations.setNotePrivate(hidden.id, true)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let notes = try await liveNotes(h)
            let depth = h.undoStack.depth

            let unknown = try await call(connection, "duplicate_note", ["note_id": .string("no-such-note")])
            #expect(unknown.isError == true)
            #expect(text(unknown) == MCPRefusalCopy.words(.notShared, .note), "the ONE answer")
            for id in [foreign.id, version.post.id, gone.id, scraps.id, hidden.id] {
                let refused = try await call(connection, "duplicate_note", ["note_id": .string(id)])
                #expect(refused.isError == true && text(refused) == text(unknown),
                        "\(id) answers byte-identically to an id naming nothing")
            }
            let notesAfter = try await liveNotes(h)
            #expect(notesAfter == notes && h.undoStack.depth == depth, "nothing minted, no entry")
            await h.hangUp(connection)
        }
    }

    // MARK: - The landing's reach: a wing, never a book

    /// A client whose write new is only a BOOK can read the note but can't name where a
    /// bookless copy lands: it hears the wing's refusal, and her ask is for the WING at
    /// write new. **RED on old:** `Unknown tool: duplicate_note.`, no ask.
    @Test func aBookLevelWriteNewHearsTheWingsRefusalAndAsksForTheWing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let source = try h.operations.createPost(title: "a chapter")
            _ = try h.operations.addPostToReading(source.id, to: book.id)
            _ = try h.operations.newBlock(in: source.id, text: "Words.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, book.id))
            let notes = try await liveNotes(h)

            let refused = try await call(connection, "duplicate_note", ["note_id": .string(source.id)])
            #expect(refused.isError == true)
            #expect(text(refused) == MCPRefusalCopy.words(.notShared, .wing), "the landing's side speaks")
            let ask = try #require(h.asks.value.last)
            #expect(ask.scopeKind == .wing && ask.scopeID == "" && ask.rung == .writeNew,
                    "her ask is for the wing the copy would land in")
            #expect(try await liveNotes(h) == notes)
            await h.hangUp(connection)
        }
    }

    // MARK: - The fence (P-VX311-1)

    /// A Private note and a journal entry the client reads through its own PER-ASK grant
    /// refuse in one sentence that names no leg — a copy would shed the fence — and nothing
    /// is minted, nothing asked. **RED on old:** `Unknown tool: duplicate_note.`
    @Test func aFencedSourceUnderAPerAskGrantRefusesInOneSentenceAndMintsNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let secret = try h.operations.createPost(title: "secret")
            _ = try h.operations.newBlock(in: secret.id, text: "Mine.", registeringUndo: false)
            _ = try h.operations.setNotePrivate(secret.id, true)
            let entry = try h.operations.createPost(title: "an entry", profile: .journal)
            _ = try h.operations.newBlock(in: entry.id, text: "Today.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            let client = try h.client("claude-code").id
            _ = try h.operations.grantMCPAccess(client, spec(.read, .note, secret.id, .connection))
            _ = try h.operations.grantMCPAccess(client, spec(.read, .note, entry.id, .connection))
            #expect(try await call(connection, "read_note", ["note_id": .string(secret.id)]).isError != true,
                    "the premise: the client CAN read it, per ask")
            let notes = try await liveNotes(h)
            let asks = h.asks.value.count
            let depth = h.undoStack.depth

            for id in [secret.id, entry.id] {
                let refused = try await call(connection, "duplicate_note", ["note_id": .string(id)])
                #expect(refused.isError == true && text(refused) == fencedWords, "\(text(refused))")
            }
            let notesAfter = try await liveNotes(h)
            #expect(notesAfter == notes && h.undoStack.depth == depth && h.asks.value.count == asks,
                    "nothing minted, no entry, nothing asked")
            await h.hangUp(connection)
        }
    }

    // MARK: - Once grants: both sides as one union; a refused act spends nothing

    /// **RED on old:** `Unknown tool: duplicate_note.` (nothing lands, nothing spends).
    @Test func onceGrantsOnBothSidesSpendAsOneAndARefusedActSpendsNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let source = try h.operations.createPost(title: "once")
            _ = try h.operations.newBlock(in: source.id, text: "Once.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            let noteGrant = try h.approve("claude-code", spec(.read, .note, source.id, .once))

            let refused = try await call(connection, "duplicate_note", ["note_id": .string(source.id)])
            #expect(refused.isError == true && text(refused) == MCPRefusalCopy.words(.notShared, .wing))
            let spentByRefusal = try await consumed(h, noteGrant)
            #expect(!spentByRefusal, "a refused act spends nothing")

            let wingGrant = try h.operations.grantMCPAccess(
                try h.client("claude-code").id, spec(.writeNew, .wing, "", .once))
            let landed = try await call(connection, "duplicate_note", ["note_id": .string(source.id)])
            #expect(landed.isError != true, "\(text(landed))")
            let noteSpent = try await consumed(h, noteGrant)
            let wingSpent = try await consumed(h, wingGrant)
            #expect(noteSpent && wingSpent, "both sides spent, as one")
            let notes = try await liveNotes(h)
            let again = try await call(connection, "duplicate_note", ["note_id": .string(source.id)])
            let notesAfter = try await liveNotes(h)
            #expect(again.isError == true && notesAfter == notes, "spent is spent")
            await h.hangUp(connection)
        }
    }

    // MARK: - The parse

    @Test func aCallWithoutANoteIsRefusedAtTheParse() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let refused = try await call(connection, "duplicate_note", [:])
            #expect(refused.isError == true && text(refused) == "note_id is required.")
            await h.hangUp(connection)
        }
    }
}
