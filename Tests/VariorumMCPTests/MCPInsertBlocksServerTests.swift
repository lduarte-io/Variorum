import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-255 (VX-336 U5b — the run record `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md`,
// U5b UNIT RECORD D4–D10, the orchestrator's rulings on the forks and THE
// CONTINUATION'S BUILD PLAN): THE DOOR COULD NOT ADD A PARAGRAPH TO A NOTE. Her doors
// add a block anywhere (⌘⇧⏎, the Return key's act, paste); the wire could only mint
// a whole note or divide a block whose text already held the words. Her ruling:
// *"write new lets them add blocks at the end, edit lets them write blocks anywhere."*
// The shape `insert_blocks(note_id, after_block_id?, blocks)` with create_note's block
// shape. The rung is read from the call's ARGUMENTS (P-VX255-1): no anchor (or `at:
// "end"`) lands at the note's END at write new; ANY `after_block_id` — the last block
// included — or `at: "start"` (P-VX255-2) needs EDIT, and a write-new holder hears the
// rungTooLow family's sentence (never the not-shared shape for a note it can read). ONE
// transaction, ONE client-named undo (newBlock's road), at most 200 blocks a call
// (P-VX255-4), `blocks` only (P-VX255-3); the answer is VX-252's shape.
//
// Wire only, so every pin compiles on the tree before the fix — where the tool is
// ABSENT: every call answered `Unknown tool: insert_blocks.` (red by absence). Cases 7
// (the fence) and 8 (D8's characterization) carry GUARD lines that hold on both sides
// (the byte-identity across a call's forms; no flush asked; her words where she typed
// them) beside the lines that need the tool.

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

/// One block as the answer's record says it — or as `read_note with_ids` reads it
/// (`MCPMintedAnswerServerTests`' record, copied — it is private there).
private struct BlockRecord: Equatable, CustomStringConvertible {
    let blockID: String
    let shownTakeID: String?
    let takes: [String]
    let labels: [String?]

    var description: String { "\(blockID) shows \(shownTakeID ?? "-") of \(takes) labelled \(labels)" }

    static func answered(_ answer: [String: Any]) -> [BlockRecord]? {
        guard let blocks = answer["blocks"] as? [[String: Any]] else { return nil }
        return blocks.map(record)
    }

    static func read(_ read: [String: Any]) -> [BlockRecord] {
        (read["blocks"] as? [[String: Any]] ?? []).map(record)
    }

    private static func record(_ block: [String: Any]) -> BlockRecord {
        let takes = block["takes"] as? [[String: Any]] ?? []
        return BlockRecord(
            blockID: block["block_id"] as? String ?? "", shownTakeID: block["shown_take_id"] as? String,
            takes: takes.map { $0["take_id"] as? String ?? "" }, labels: takes.map { $0["label"] as? String })
    }
}

/// The anchor's one sentence — for a block of another note and for nothing alike.
private let anchorNotThisNotes =
    "after_block_id isn't a block of this note — read_note with with_ids: true gives its block ids."

@Suite("VX-255 — insert_blocks: write new adds at the end, edit anywhere", .serialized)
struct MCPInsertBlocksServerTests {
    /// A note of `texts.count` blocks in a book: the note, its blocks, the book.
    private func herNote(
        _ h: ServerHarness, in book: Reading, _ texts: [String], title: String = "her note"
    ) throws -> (note: Container, blocks: [Operations.NewBlockResult]) {
        let note = try h.operations.createPost(title: title)
        _ = try h.operations.addPostToReading(note.id, to: book.id)
        let blocks = try texts.map { try h.operations.newBlock(in: note.id, text: $0, registeringUndo: false) }
        return (note, blocks)
    }

    /// The note's live placements, in order.
    private func order(_ h: ServerHarness, _ noteID: String) async throws -> [String] {
        try await h.database.read { db in
            try String.fetchAll(
                db, sql: """
                    SELECT block_id FROM container_block WHERE container_id = ? AND deleted_at IS NULL
                    ORDER BY position, id
                    """, arguments: [noteID])
        }
    }

    private func liveBlocks(_ h: ServerHarness) async throws -> Int {
        try await h.database.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM block WHERE deleted_at IS NULL") ?? -1
        }
    }

    private func blockText(_ text: String) -> Value { .object(["text": .string(text)]) }

    // MARK: - 1. write new, at the end

    @Test func writeNewAddsTheBlocksAtTheNotesEndInOrderAndOneUndoWalksThemBack() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "o ladrão de raios", kind: .book)
            let (note, hers) = try herNote(h, in: book, ["Um.", "Dois.", "Três."])
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, book.id))
            let depth = h.undoStack.depth
            let touched = "SELECT last_touched_at FROM container WHERE id = ?"
            let touchedBefore = try await h.database.read { try String.fetchOne($0, sql: touched, arguments: [note.id]) }

            let inserted = try await call(connection, "insert_blocks", [
                "note_id": .string(note.id),
                "blocks": .array([
                    .object([
                        "text": .string("Quatro."),
                        "takes": .array([
                            .object(["text": .string("Four."), "label": .string("english")]),
                            .object(["text": .string("")]),  // a blank take is a take (R-VX171-2)
                        ]),
                    ]),
                    .object(["text": .string("Cinco."), "name": .string("the fifth")]),
                    blockText(""),
                ]),
            ])
            #expect(inserted.isError != true, "\(text(inserted))")
            let answer = try json(inserted)
            let newIDs = try #require(answer["block_ids"] as? [String])
            #expect(newIDs.count == 3)
            #expect(answer["note_id"] as? String == note.id)
            #expect(try await order(h, note.id) == hers.map(\.block.id) + newIDs, "after her last block, in order")

            let read = try json(try await call(connection, "read_note",
                                               ["note_id": .string(note.id), "with_ids": .bool(true)]))
            let stored = BlockRecord.read(read)
            #expect(Array(stored.suffix(3)) == BlockRecord.answered(answer) ?? [],
                    "the answer's records are the new blocks as stored — VX-252's shape")
            #expect(stored.suffix(3).first?.labels == [nil, "english", nil],
                    "labels exactly as given at write new (VX-197's split), the blank take kept")
            let name = try await h.database.read { db in
                try String.fetchOne(db, sql: "SELECT name FROM block WHERE id = ?", arguments: [newIDs[1]])
            }
            #expect(name == "the fifth")

            #expect(h.undoStack.depth == depth + 1 && h.undoStack.topLabel == "claude-code's blocks", "ONE entry")
            let receipt = try #require(h.receipts.value.last)
            #expect(receipt.act.rawValue == "blocks" && receipt.count == 3 && receipt.targetID == note.id)
            #expect(receipt.show == .note(noteID: note.id, blockID: newIDs[0], select: nil), "Open › the first new one")
            let touchedAfter = try await h.database.read { try String.fetchOne($0, sql: touched, arguments: [note.id]) }
            #expect(touchedAfter != nil && touchedAfter != touchedBefore, "minting text is working on the post")

            // ⌥⌘Z walks the run back whole (untouched mints vanish, no tray);
            // ⇧⌥⌘Z returns the SAME ids, in place.
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's blocks")
            #expect(try await order(h, note.id) == hers.map(\.block.id), "her three untouched")
            let gone = try await h.database.read { db in
                try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM block WHERE id IN (?, ?, ?) AND deleted_at IS NOT NULL",
                    arguments: StatementArguments(newIDs))
            }
            let trayed = try await h.database.read { db in
                try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM block WHERE id IN (?, ?, ?) AND last_container_id IS NOT NULL",
                    arguments: StatementArguments(newIDs))
            }
            #expect(gone == 3, "every new block dead")
            #expect(trayed == 0, "an untouched mint never trays")
            #expect(try h.undoStack.redo(with: h.writeOperations) == "claude-code's blocks")
            #expect(try await order(h, note.id) == hers.map(\.block.id) + newIDs, "the same ids back, in place")

            // at: "end" spells the same.
            let atEnd = try await call(connection, "insert_blocks", [
                "note_id": .string(note.id), "at": .string("end"), "blocks": .array([blockText("Seis.")]),
            ])
            #expect(atEnd.isError != true, "\(text(atEnd))")
            let sixth = try #require(try json(atEnd)["block_ids"] as? [String])
            #expect(try await order(h, note.id) == hers.map(\.block.id) + newIDs + sixth)
            await h.hangUp(connection)
        }
    }

    // MARK: - 2. write new with ANY anchor hears the rung's sentence, and her ask

    @Test func writeNewWithAnyAnchorHearsTheRungsSentenceAndAsksHerForEdit() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "o ladrão de raios", kind: .book)
            let (note, hers) = try herNote(h, in: book, ["Um.", "Dois.", "Três."])
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, book.id))
            let blocks = try await liveBlocks(h)
            let depth = h.undoStack.depth
            let sentence = MCPRefusalCopy.words(.rungTooLow(granted: .writeNew), .note, asked: true)

            let anchored: [[String: Value]] = [
                ["after_block_id": .string(hers[2].block.id)],  // her LAST block — still an anchor (P-VX255-1)
                ["at": .string("start")],  // the start door is edit's (P-VX255-2)
            ]
            for place in anchored {
                h.asks.setValue([])
                var arguments: [String: Value] = ["note_id": .string(note.id), "blocks": .array([blockText("x")])]
                arguments.merge(place) { _, given in given }
                let refused = try await call(connection, "insert_blocks", arguments)
                #expect(refused.isError == true)
                #expect(text(refused) == sentence, "\(place): \(text(refused))")
                let ask = h.asks.value.last
                #expect(ask?.scopeKind == .note && ask?.scopeID == note.id && ask?.rung == .edit,
                        "her ask, quietly queued at edit on the note: \(String(describing: ask))")
            }
            #expect(try await liveBlocks(h) == blocks && h.undoStack.depth == depth, "nothing minted")
            await h.hangUp(connection)
        }
    }

    // MARK: - 3. edit, anywhere

    @Test func editAddsTheBlocksRightAfterAnyBlockOrAtTheStart() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "o ladrão de raios", kind: .book)
            let (note, hers) = try herNote(h, in: book, ["Um.", "Dois.", "Três."])
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, book.id))
            let ids = hers.map(\.block.id)

            let after = try await call(connection, "insert_blocks", [
                "note_id": .string(note.id), "after_block_id": .string(ids[0]),
                "blocks": .array([blockText("Um e meio."), blockText("Quase dois.")]),
            ])
            #expect(after.isError != true, "\(text(after))")
            let middle = try #require(try json(after)["block_ids"] as? [String])
            #expect(try await order(h, note.id) == [ids[0]] + middle + [ids[1], ids[2]], "between her 1st and 2nd")

            let start = try await call(connection, "insert_blocks", [
                "note_id": .string(note.id), "at": .string("start"), "blocks": .array([blockText("Zero.")]),
            ])
            #expect(start.isError != true, "\(text(start))")
            let first = try #require(try json(start)["block_ids"] as? [String])
            #expect(try await order(h, note.id) == first + [ids[0]] + middle + [ids[1], ids[2]], "before her first")
            await h.hangUp(connection)
        }
    }

    // MARK: - 4. the anchor's one sentence

    @Test func anAnchorThatIsntABlockOfThisNoteAnswersOneSentenceAndMintsNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "o ladrão de raios", kind: .book)
            let (note, _) = try herNote(h, in: book, ["Um.", "Dois."])
            let (_, others) = try herNote(h, in: book, ["Another note's block."], title: "another")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, book.id))
            let blocks = try await liveBlocks(h)

            var said: [String] = []
            for anchor in [others[0].block.id, "no-such-block"] {
                let refused = try await call(connection, "insert_blocks", [
                    "note_id": .string(note.id), "after_block_id": .string(anchor),
                    "blocks": .array([blockText("x")]),
                ])
                #expect(refused.isError == true)
                said.append(text(refused))
            }
            #expect(said == [anchorNotThisNotes, anchorNotThisNotes],
                    "a readable note's block and nothing, byte-identical: \(said)")
            #expect(try await liveBlocks(h) == blocks, "nothing minted")
            await h.hangUp(connection)
        }
    }

    // MARK: - 5. the parse's refusals (before any decision)

    @Test func malformedCallsAreRefusedAtTheParseNamingWhatIsWrong() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "o ladrão de raios", kind: .book)
            let (note, hers) = try herNote(h, in: book, ["Um."])
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, book.id))
            let blocks = try await liveBlocks(h)
            let id = Value.string(note.id)
            let one = Value.array([blockText("x")])
            let cases: [([String: Value], String)] = [
                (["note_id": id, "after_block_id": .string(hers[0].block.id), "at": .string("end"), "blocks": one],
                 "Pass after_block_id or at, not both."),
                // …before the note is decided: the same words for a note that doesn't exist.
                (["note_id": .string("no-such-note"), "after_block_id": .string("b"), "at": .string("end"),
                  "blocks": one],
                 "Pass after_block_id or at, not both."),
                (["note_id": id, "at": .string("middle"), "blocks": one], "at must be \"start\" or \"end\"."),
                (["note_id": id, "after_block_id": .string(""), "blocks": one], "after_block_id must be a block id."),
                (["note_id": id], "blocks is required."),
                (["note_id": id, "blocks": .array([])], "blocks must list at least one block."),
                (["note_id": id, "blocks": .array(Array(repeating: blockText("x"), count: 201))],
                 MCPWriteTools.overCapWords(tool: "insert_blocks", noun: "blocks", count: 201)),
                (["note_id": id, "blocks": .array([.object(["name": .string("no text")])])], "blocks[0] needs a text."),
            ]
            for (arguments, words) in cases {
                let refused = try await call(connection, "insert_blocks", arguments)
                #expect(refused.isError == true)
                #expect(text(refused) == words, "\(arguments.keys.sorted()): \(text(refused))")
            }
            #expect(try await liveBlocks(h) == blocks, "nothing minted")
            await h.hangUp(connection)
        }
    }

    // MARK: - 6. a sealed note refuses; a locked take at the anchor never does

    @Test func aSealedNoteRefusesAndALockedTakeAtTheAnchorNeverDoes() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "o ladrão de raios", kind: .book)
            let (sealed, _) = try herNote(h, in: book, ["Sealed."], title: "sealed")
            try h.operations.lockPost(sealed.id)
            let (open, hers) = try herNote(h, in: book, ["Her locked take.", "Two."], title: "open")
            try h.operations.lockVariant(hers[0].variant.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, book.id))
            let blocks = try await liveBlocks(h)

            let refused = try await call(connection, "insert_blocks", [
                "note_id": .string(sealed.id), "blocks": .array([blockText("x")]),
            ])
            #expect(refused.isError == true && text(refused).contains("lockedPost"), "\(text(refused))")
            #expect(try await liveBlocks(h) == blocks, "a sealed note mints nothing")

            let landed = try await call(connection, "insert_blocks", [
                "note_id": .string(open.id), "after_block_id": .string(hers[0].block.id),
                "blocks": .array([blockText("Below her locked take.")]),
            ])
            #expect(landed.isError != true, "a locked take is never touched: \(text(landed))")
            let added = try #require(try json(landed)["block_ids"] as? [String])
            #expect(try await order(h, open.id) == [hers[0].block.id] + added + [hers[1].block.id])
            await h.hangUp(connection)
        }
    }

    // MARK: - 7. THE FENCE — an unreachable note answers the one not-shared sentence

    /// GUARD lines (green on both sides): the three forms answer byte-identically,
    /// and nothing is minted — the anchor and the blocks are never looked at before
    /// the note's decision. The sentence line needs the tool (red by absence on old).
    @Test func anUnreachableNoteAnswersTheOneNotSharedSentenceWhateverTheCallNames() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let shared = try h.operations.createReading(name: "shared", kind: .book)
            let hidden = try h.operations.createReading(name: "never shared", kind: .book)
            let (note, hers) = try herNote(h, in: hidden, ["Hidden."])
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, shared.id))
            let blocks = try await liveBlocks(h)
            let forms: [[String: Value]] = [
                ["note_id": .string(note.id), "blocks": .array([blockText("x")])],
                ["note_id": .string(note.id), "after_block_id": .string(hers[0].block.id),
                 "blocks": .array([blockText("x")])],
                ["note_id": .string(note.id), "after_block_id": .string("no-such-block"),
                 "blocks": .array([blockText(""), .object(["text": .string("y"), "takes": .array([])])])],
            ]
            var said: [String] = []
            for arguments in forms {
                let refused = try await call(connection, "insert_blocks", arguments)
                #expect(refused.isError == true)
                said.append(text(refused))
            }
            #expect(Set(said).count == 1, "byte-identical whatever the call names: \(said)")
            #expect(said.first == MCPRefusalCopy.words(.notShared, .note), "the ONE not-shared sentence")
            #expect(try await liveBlocks(h) == blocks)
            await h.hangUp(connection)
        }
    }
}

// MARK: - 8. D8 — her editor: the act never waits for her flush, and nothing of hers moves

/// Her open editor's pending text, as the app's coordinator holds it
/// (`MCPHerEditorServerTests`' model, copied — it is private there).
private final class HerOpenEditor: Sendable {
    let operations: Operations
    let pending = LockIsolated<[String: String]>([:])

    init(_ operations: Operations) { self.operations = operations }

    func type(_ takeID: String, _ text: String) {
        pending.withValue { $0[takeID] = text }
    }

    func flush() {
        for (takeID, text) in pending.value.sorted(by: { $0.key < $1.key }) {
            do {
                try operations.autosave(takeID, text: text, charDelta: 1)
                pending.withValue { $0[takeID] = nil }
            } catch {
                // kept pending — the coordinator's posture
            }
        }
    }
}

/// The session's runner, recording each act's TURN.
private actor TurnLogExecutor: MCPWriteExecutor {
    private let operations: Operations
    private let log: LockIsolated<[String]>

    init(operations: Operations, log: LockIsolated<[String]>) {
        self.operations = operations
        self.log = log
    }

    func run<T: Sendable>(_ body: @Sendable (Operations) throws -> T) throws -> T {
        log.withValue { $0.append("act") }
        return try withDependencies {
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SystemRandomNumberGenerator())
        } operation: {
            try body(operations)
        }
    }
}

@Suite("VX-255 — insert_blocks and her open editor (D8, headless)", .serialized)
struct MCPInsertBlocksHerEditorTests {
    /// D8: `flushesHerEditorFirst` is FALSE — the act adds blocks and touches no
    /// take's text. She types in the block the run lands after (the note's last,
    /// for an anchorless call; any block, for an anchored one): the act's turn asks
    /// for no flush, her later flush lands her words in her take, and the new
    /// blocks sit below it. GUARD lines (green on both sides): no flush asked; her
    /// words where she typed them. The landing lines need the tool.
    @Test func herTypingInTheBlockItLandsAfterIsNeverFlushedOrMoved() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            _ = try h.operations.recordMCPContact(name: "claude-code", version: "1")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let log = LockIsolated<[String]>([])
            let editor = HerOpenEditor(h.writeOperations)
            var tools = MCPWriteTools(
                database: h.database, grants: h.operations,
                executor: TurnLogExecutor(operations: h.writeOperations, log: log))
            tools.hooks = MCPHostHooks(
                now: { ServerHarness.worldNow },
                beforeWrite: { tool in
                    log.withValue { $0.append("flush:\(tool)") }
                    editor.flush()
                })
            let note = try h.operations.createPost(title: "ch 1")
            let one = try h.operations.newBlock(in: note.id, text: "One.", registeringUndo: false)
            let two = try h.operations.newBlock(in: note.id, text: "Two.", registeringUndo: false)
            func takeText(_ id: String) async throws -> String? {
                try await h.database.read { db in
                    try String.fetchOne(db, sql: "SELECT working_text FROM variant WHERE id = ?", arguments: [id])
                }
            }

            // At the END, while she types in the note's last block.
            editor.type(two.variant.id, "Two. And her next words.")
            let atEnd = await tools.call("insert_blocks", arguments: [
                "note_id": .string(note.id), "blocks": .array([.object(["text": .string("The AI's paragraph.")])]),
            ], clientName: "claude-code")
            #expect(!log.value.contains { $0.hasPrefix("flush:") }, "no flush is asked (GUARD)")
            #expect(log.value == ["act"], "one turn, the act's own: \(log.value)")
            #expect(atEnd.isError != true, "\(atEnd.text)")
            editor.flush()
            #expect(try await takeText(two.variant.id) == "Two. And her next words.", "her words where she typed (GUARD)")
            let rendered = try await h.database.read { try Queries.renderedText($0, containerID: note.id) }
            #expect(rendered == "One.\n\nTwo. And her next words.\n\nThe AI's paragraph.", "the run below her block")

            // AFTER the block her caret is in (edit).
            log.setValue([])
            editor.type(one.variant.id, "One, and more of hers.")
            let after = await tools.call("insert_blocks", arguments: [
                "note_id": .string(note.id), "after_block_id": .string(one.block.id),
                "blocks": .array([.object(["text": .string("Between.")])]),
            ], clientName: "claude-code")
            #expect(!log.value.contains { $0.hasPrefix("flush:") }, "no flush is asked (GUARD)")
            #expect(after.isError != true, "\(after.text)")
            editor.flush()
            #expect(try await takeText(one.variant.id) == "One, and more of hers.", "her words where she typed (GUARD)")
            let again = try await h.database.read { try Queries.renderedText($0, containerID: note.id) }
            #expect(again == "One, and more of hers.\n\nBetween.\n\nTwo. And her next words.\n\nThe AI's paragraph.")
        }
    }
}
