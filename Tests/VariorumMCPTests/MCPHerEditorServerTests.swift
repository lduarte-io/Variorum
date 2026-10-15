import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP

// VX-275 (Run VX-246, U3 — the record `notes/plans/fixes/vx-246-mcp-door-fixes-
// ai-docs.md`, U3 UNIT RECORD): HER EDITOR vs THE WIRE, headless. Her ruling
// (a): before a wire delete lands, the app saves what she has typed and moves
// her pane off the deleted note, exactly as her own Delete door does — and the
// wider class traced beside it (an act that freezes, rewrites, restructures or
// copies a take she may be typing in reads the STORED row, never her pending
// buffer). Written BEFORE the fix, on the seam tree: `MCPHostHooks.beforeWrite`
// and `MCPWriteReceipt.notesLeftDead` exist and nothing calls or sets them, so
// every pin here that says "the flush ran first" is RED on old.
//
// THE MODEL OF HER OPEN EDITOR (`HerOpenEditor`): the app's `AutosaveCoordinator`
// as the wire meets it — the WHOLE take text held pending per take, and a
// flush that lands each entry through her own `autosave` or KEEPS it pending
// when the write is refused (`flushNow`'s keep-pending posture). The pins call
// `flush()` once more AFTER the act: that is her 500 ms debounce firing, which
// on the pre-fix tree is where her bytes are refused or written over the act.
// The Mac half (`MCPHerEditorDoorTests`) drives the REAL coordinator, the real
// door and a real socket.

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

/// Her open editor's pending text, as the app's coordinator holds it.
private final class HerOpenEditor: Sendable {
    let operations: Operations
    let pending = LockIsolated<[String: String]>([:])

    init(_ operations: Operations) { self.operations = operations }

    /// She types: the take's WHOLE text is held pending (`record`).
    func type(_ takeID: String, _ text: String) {
        pending.withValue { $0[takeID] = text }
    }

    /// Her flush: each entry lands through her own autosave, or — refused (a
    /// tombstoned, archived or locked take) — stays pending, in memory only.
    func flush() {
        for (takeID, text) in pending.value.sorted(by: { $0.key < $1.key }) {
            do {
                try operations.autosave(takeID, text: text, charDelta: 1)
                pending.withValue { $0[takeID] = nil }
            } catch {
                // kept pending — the coordinator's posture (Phase 7 MAJOR 1)
            }
        }
    }
}

/// The session's runner as the wire sees it, recording each act's TURN — so a
/// pin can say the flush ran BEFORE the turn, never inside it.
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

/// One world: the server harness's store, an edit grant on the Home wing for
/// claude-code, her open editor, the wire's write tools with the app's two
/// VX-275 hooks modelled (the flush, the receipts).
private struct World {
    let h: ServerHarness
    let editor: HerOpenEditor
    let log = LockIsolated<[String]>([])
    let receipts = LockIsolated<[MCPWriteReceipt]>([])
    var tools: MCPWriteTools

    init(_ h: ServerHarness) throws {
        self.h = h
        editor = HerOpenEditor(h.writeOperations)
        _ = try h.operations.recordMCPContact(name: "claude-code", version: "1")
        _ = try h.approve("claude-code", spec(.edit, .wing, ""))
        tools = MCPWriteTools(
            database: h.database, grants: h.operations,
            executor: TurnLogExecutor(operations: h.writeOperations, log: log))
        let log = self.log
        let receipts = self.receipts
        let editor = self.editor
        tools.hooks = MCPHostHooks(
            onWrite: { receipt in receipts.withValue { $0.append(receipt) } },
            now: { ServerHarness.worldNow },
            beforeWrite: { tool in
                log.withValue { $0.append("flush:\(tool)") }
                editor.flush()
            })
    }

    func call(_ name: String, _ arguments: [String: Value]) async -> MCPReadTools.Outcome {
        await tools.call(name, arguments: arguments, clientName: "claude-code")
    }

    func json(_ outcome: MCPReadTools.Outcome) throws -> [String: Any] {
        try #require(try JSONSerialization.jsonObject(with: Data(outcome.text.utf8)) as? [String: Any])
    }

    func text(ofTake id: String) async throws -> String? {
        try await h.database.read { db in
            try String.fetchOne(db, sql: "SELECT working_text FROM variant WHERE id = ?", arguments: [id])
        }
    }

    func rendered(_ noteID: String) async throws -> String {
        try await h.database.read { try Queries.renderedText($0, containerID: noteID) }
    }
}

@Suite("VX-275 — her editor vs the wire: the flush before the act (headless)", .serialized)
struct MCPHerEditorServerTests {
    // MARK: - The seam's order, and which acts ask

    /// The flush runs as its OWN turn, BEFORE the act's turn — for a listed act
    /// even when the act then refuses (the flush never depends on the id named:
    /// P-VX275-1's no-oracle property) — and never for an act that meets no
    /// take's text. **RED on old:** no act flushes at all.
    @Test func theFlushRunsBeforeTheActsTurnOnlyForTheActsThatMeetHerText() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try World(h)
            let note = try h.operations.createPost(title: "ch 1")
            let one = try h.operations.newBlock(in: note.id, text: "One.", registeringUndo: false)
            let two = try h.operations.newBlock(in: note.id, text: "Two.", registeringUndo: false)

            let deleted = await w.call("delete_block", ["block_id": .string(two.block.id)])
            #expect(deleted.isError != true, "\(deleted.text)")
            #expect(w.log.value == ["flush:delete_block", "act"], "the flush, THEN the act's own turn")

            w.log.setValue([])
            let refused = await w.call("delete_note", ["note_id": .string("no-such-note")])
            #expect(refused.isError == true)
            #expect(w.log.value == ["flush:delete_note", "act"],
                    "a listed act flushes whatever id it names — the cost never depends on the target")

            w.log.setValue([])
            let commented = await w.call("add_comment", ["block_id": .string(one.block.id), "text": .string("a note")])
            #expect(commented.isError != true, "\(commented.text)")
            _ = await w.call("move_block", ["block_id": .string(one.block.id), "note_id": .string(note.id), "at": .string("end")])
            _ = await w.call("set_block_name", ["block_id": .string(one.block.id), "name": .string("opening")])
            #expect(w.log.value == ["act", "act", "act"], "acts that meet no take's text never flush her editor")
        }
    }

    /// The whole act list, by tool name, on the wire: every listed act asks for
    /// her flush with its own name (a parseable call reaches the hook whatever
    /// its target). **RED on old:** none asks.
    @Test func everyListedActAsksForHerFlushByName() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try World(h)
            let id = Value.string("no-such-id")
            let calls: [(String, [String: Value])] = [
                ("delete_note", ["note_id": id]),
                ("delete_block", ["block_id": id]),
                ("delete_take", ["take_id": id]),
                ("lock_take", ["take_id": id]),
                ("archive_take", ["take_id": id]),
                ("edit_take", ["take_id": id, "text": .string("new"), "expected_text": .string("old")]),
                ("restore_commit", ["commit_id": id]),
                ("divide_block", ["block_id": id, "second_half_starts_with": .string("Two")]),
                ("merge_blocks", ["first_block_id": id, "second_block_id": .string("other-id")]),
                ("save_commit", ["take_id": id, "message": .string("keep")]),
                ("save_version", ["note_id": id]),
            ]
            for (name, arguments) in calls { _ = await w.call(name, arguments) }
            #expect(w.log.value.filter { $0.hasPrefix("flush:") } == calls.map { "flush:\($0.0)" })
            // …and the unlisted acts named in the record's SAFE rows ask nothing.
            w.log.setValue([])
            let safe: [(String, [String: Value])] = [
                ("add_take", ["block_id": id, "text": .string("t")]),
                ("choose_take", ["take_id": id]),
                ("unlock_take", ["take_id": id]),
                ("unarchive_take", ["take_id": id]),
                ("put_back", ["block_id": id]),
                ("rename_note", ["note_id": id, "title": .string("t")]),
                ("archive_note", ["note_id": id]),
                ("delete_book", ["book_id": id]),
                ("set_take_label", ["take_id": id, "label": .string("l")]),
            ]
            for (name, arguments) in safe { _ = await w.call(name, arguments) }
            #expect(!w.log.value.contains { $0.hasPrefix("flush:") }, "\(w.log.value)")
        }
    }

    // MARK: - TOMBSTONE: delete_note, delete_block, delete_take (both roads)

    /// Her typing lands in the note's take BEFORE the tombstone, so the
    /// client's ⌥⌘Z (and her Put back) returns it. **RED on old:** the
    /// tombstone carries the last-flushed text and her flush is refused.
    @Test func aWireNoteDeleteLandsHerTypingInTheTombstone() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try World(h)
            let note = try h.operations.createPost(title: "ch 1")
            let block = try h.operations.newBlock(in: note.id, text: "Her line.", registeringUndo: false)
            w.editor.type(block.variant.id, "Her line. And the last thought.")

            let deleted = await w.call("delete_note", ["note_id": .string(note.id)])
            #expect(deleted.isError != true, "\(deleted.text)")
            #expect(try await w.text(ofTake: block.variant.id) == "Her line. And the last thought.",
                    "the tombstone carries her last words")
            w.editor.flush()  // her debounce
            #expect(w.editor.pending.value.isEmpty, "nothing left stranded in memory")

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's note deletion")
            #expect(try await w.rendered(note.id) == "Her line. And the last thought.")
        }
    }

    @Test func aWireBlockDeleteLandsHerTypingInTheTombstone() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try World(h)
            let note = try h.operations.createPost(title: "ch 1")
            _ = try h.operations.newBlock(in: note.id, text: "One.", registeringUndo: false)
            let two = try h.operations.newBlock(in: note.id, text: "Two.", registeringUndo: false)
            w.editor.type(two.variant.id, "Two. Typed under her caret.")

            let deleted = await w.call("delete_block", ["block_id": .string(two.block.id)])
            #expect(deleted.isError != true, "\(deleted.text)")
            #expect(try await w.text(ofTake: two.variant.id) == "Two. Typed under her caret.")
            w.editor.flush()
            #expect(w.editor.pending.value.isEmpty)

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's delete")
            #expect(try await w.rendered(note.id) == "One.\n\nTwo. Typed under her caret.")
        }
    }

    /// Both of `delete_take`'s roads: another take of a fanned block (her
    /// Takes-board pane), and a block's LAST take (the block goes — R-VX184-1).
    @Test func aWireTakeDeleteLandsHerTypingOnBothRoads() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try World(h)
            let note = try h.operations.createPost(title: "ch 1")
            let fanned = try h.operations.newBlock(in: note.id, text: "Chosen.", registeringUndo: false)
            let other = try h.operations.branchVariant(fanned.block.id, from: fanned.variant.id)
            let single = try h.operations.newBlock(in: note.id, text: "Alone.", registeringUndo: false)
            w.editor.type(other.id, "Chosen. Her other try.")
            w.editor.type(single.variant.id, "Alone. And more.")

            let takeGone = await w.call("delete_take", ["take_id": .string(other.id)])
            #expect(takeGone.isError != true, "\(takeGone.text)")
            #expect(try await w.text(ofTake: other.id) == "Chosen. Her other try.")

            let blockGone = await w.call("delete_take", ["take_id": .string(single.variant.id)])
            #expect(blockGone.isError != true, "\(blockGone.text)")
            #expect(try w.json(blockGone)["deleted_block"] as? Bool == true, "the last take takes the block")
            #expect(try await w.text(ofTake: single.variant.id) == "Alone. And more.")
            w.editor.flush()
            #expect(w.editor.pending.value.isEmpty)
        }
    }

    // MARK: - FREEZE: lock_take, archive_take

    /// A lock or an archive refuses her later flush exactly as a tombstone
    /// does; with the flush first, her words are the take's (and the lock's
    /// insurance commit holds them). **RED on old:** the take keeps the
    /// stale text and her bytes stay refused in memory.
    @Test func aWireLockOrArchiveLandsHerTypingFirst() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try World(h)
            let note = try h.operations.createPost(title: "ch 1")
            let block = try h.operations.newBlock(in: note.id, text: "Chosen.", registeringUndo: false)
            let locking = try h.operations.branchVariant(block.block.id, from: block.variant.id)
            let archiving = try h.operations.branchVariant(block.block.id, from: block.variant.id)
            w.editor.type(locking.id, "Chosen. Locked mid-sentence.")
            w.editor.type(archiving.id, "Chosen. Archived mid-sentence.")

            let locked = await w.call("lock_take", ["take_id": .string(locking.id)])
            #expect(locked.isError != true, "\(locked.text)")
            #expect(try await w.text(ofTake: locking.id) == "Chosen. Locked mid-sentence.")
            if let insured = try w.json(locked)["insured_commit_id"] as? String {
                #expect(try await h.database.read { db in
                    try String.fetchOne(db, sql: "SELECT text FROM commit_point WHERE id = ?", arguments: [insured])
                } == "Chosen. Locked mid-sentence.", "the lock insures what she typed")
            }

            let archived = await w.call("archive_take", ["take_id": .string(archiving.id)])
            #expect(archived.isError != true, "\(archived.text)")
            #expect(try await w.text(ofTake: archiving.id) == "Chosen. Archived mid-sentence.")
            w.editor.flush()
            #expect(w.editor.pending.value.isEmpty, "nothing refused, nothing stranded")
        }
    }

    // MARK: - REWRITE: edit_take, restore_commit (the wider class)

    /// The client read the take before she typed: with her typing landed first,
    /// its `expected_text` no longer matches and the op's own stale-read
    /// refusal speaks — nothing written, her words stand. **RED on old:** the
    /// edit lands on the stale row (answered as success) and her next flush
    /// writes her buffer back over it.
    @Test func aWireTakeEditMeetsHerLatestTextAndRefusesAStaleRead() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try World(h)
            let note = try h.operations.createPost(title: "ch 1")
            let block = try h.operations.newBlock(in: note.id, text: "Her line.", registeringUndo: false)
            w.editor.type(block.variant.id, "Her line. Still typing.")

            let edited = await w.call("edit_take", [
                "take_id": .string(block.variant.id), "text": .string("The client's line."),
                "expected_text": .string("Her line."),
            ])
            #expect(edited.isError == true, "the client's read is stale against what she typed: \(edited.text)")
            #expect(edited.text.contains("bufferChangedSinceGesture"), "the op's own refusal: \(edited.text)")
            w.editor.flush()
            #expect(try await w.text(ofTake: block.variant.id) == "Her line. Still typing.")
            #expect(h.undoStack.depth == 0, "nothing landed, nothing to undo")
        }
    }

    /// A restore over her pending typing: the "before" commit insures what she
    /// TYPED, the take reads the restored words, and her flush cannot undo the
    /// restore behind the client's back. **RED on old:** her debounce writes
    /// her buffer over the restore; the "before" commit holds the stale row.
    @Test func aWireRestoreInsuresHerTypingAndStaysRestored() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try World(h)
            let note = try h.operations.createPost(title: "ch 1")
            let block = try h.operations.newBlock(in: note.id, text: "Old words.", registeringUndo: false)
            let saved = try h.operations.commit(block.variant.id, message: "first")
            try h.operations.autosave(block.variant.id, text: "Her line.", charDelta: 9)
            w.editor.type(block.variant.id, "Her line. Still typing.")

            let restored = await w.call("restore_commit", ["commit_id": .string(saved.id)])
            #expect(restored.isError != true, "\(restored.text)")
            let before = try #require(try w.json(restored)["before_commit_id"] as? String)
            #expect(try await h.database.read { db in
                try String.fetchOne(db, sql: "SELECT text FROM commit_point WHERE id = ?", arguments: [before])
            } == "Her line. Still typing.", "the replaced text the insurance holds is what she typed")
            w.editor.flush()  // her debounce
            #expect(try await w.text(ofTake: block.variant.id) == "Old words.", "the restore stands")
        }
    }

    // MARK: - STRUCTURE: divide_block, merge_blocks (the wider class)

    /// A divide cuts her LATEST text. **RED on old:** the divide cuts the stored
    /// row, and her flush then writes the whole old block back into the first
    /// half, so the second half reads twice (runStructural's named
    /// text-duplication class).
    @Test func aWireDivideCutsHerLatestTextAndNothingReadsTwice() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try World(h)
            let note = try h.operations.createPost(title: "ch 1")
            let block = try h.operations.newBlock(
                in: note.id, text: "First half. Second half.", registeringUndo: false)
            w.editor.type(block.variant.id, "First half. Second half. And her extra.")

            let divided = await w.call("divide_block", [
                "block_id": .string(block.block.id), "second_half_starts_with": .string("Second half"),
            ])
            #expect(divided.isError != true, "\(divided.text)")
            w.editor.flush()  // her debounce
            let page = try await w.rendered(note.id)
            #expect(page.components(separatedBy: "Second half").count - 1 == 1, "read once: \(page)")
            #expect(page.contains("And her extra."), "\(page)")
            #expect(try await h.database.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM container_block WHERE container_id = ? AND deleted_at IS NULL",
                                 arguments: [note.id])
            } == 2)
        }
    }

    /// A merge joins her LATEST text. **RED on old:** the merge joins the
    /// stored rows and her flush lands in the released block, outside the note.
    @Test func aWireMergeJoinsHerLatestText() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try World(h)
            let note = try h.operations.createPost(title: "ch 1")
            let one = try h.operations.newBlock(in: note.id, text: "One.", registeringUndo: false)
            let two = try h.operations.newBlock(in: note.id, text: "Two.", registeringUndo: false)
            w.editor.type(two.variant.id, "Two. Typed just now.")

            let merged = await w.call("merge_blocks", [
                "first_block_id": .string(one.block.id), "second_block_id": .string(two.block.id),
            ])
            #expect(merged.isError != true, "\(merged.text)")
            w.editor.flush()  // her debounce
            #expect(try await w.rendered(note.id) == "One.\nTwo. Typed just now.", "her words stayed in the note")
        }
    }

    // MARK: - COPY: save_commit, save_version

    /// Her own ⌘S and Save Version flush first; the wire's do too. **RED on
    /// old:** the commit and the version miss her last words.
    @Test func aWireCommitOrVersionCopiesHerLatestText() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try World(h)
            let note = try h.operations.createPost(title: "ch 1")
            let block = try h.operations.newBlock(in: note.id, text: "Her line.", registeringUndo: false)
            w.editor.type(block.variant.id, "Her line. Her last words.")

            let committed = await w.call("save_commit", [
                "take_id": .string(block.variant.id), "message": .string("keep"),
            ])
            #expect(committed.isError != true, "\(committed.text)")
            let commitID = try #require(try w.json(committed)["commit_id"] as? String)
            #expect(try await h.database.read { db in
                try String.fetchOne(db, sql: "SELECT text FROM commit_point WHERE id = ?", arguments: [commitID])
            } == "Her line. Her last words.")

            w.editor.type(block.variant.id, "Her line. Her last words. Then more.")
            let versioned = await w.call("save_version", ["note_id": .string(note.id)])
            #expect(versioned.isError != true, "\(versioned.text)")
            let versionID = try #require(try w.json(versioned)["version_id"] as? String)
            #expect(try await w.rendered(versionID) == "Her line. Her last words. Then more.")
        }
    }

    // MARK: - The navigate-away FACT

    /// `delete_note`'s receipt names the note it left dead (the app posts it on
    /// THE ONE road, `.variorumNotesDeleted`); an act that kills no note names
    /// none. **RED on old:** the receipt names nothing, so nothing navigates.
    @Test func aWireNoteDeleteNamesTheNoteItLeftDead() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try World(h)
            let note = try h.operations.createPost(title: "ch 1")
            let block = try h.operations.newBlock(in: note.id, text: "One.", registeringUndo: false)
            _ = try h.operations.newBlock(in: note.id, text: "Two.", registeringUndo: false)

            _ = await w.call("delete_block", ["block_id": .string(block.block.id)])
            #expect(w.receipts.value.last?.notesLeftDead == [], "a block delete leaves its note alive")
            _ = await w.call("delete_note", ["note_id": .string(note.id)])
            #expect(w.receipts.value.last?.act == .noteDelete)
            #expect(w.receipts.value.last?.notesLeftDead == [note.id])
        }
    }

    // MARK: - A SAFE row, characterized (green on both sides, by design)

    /// `choose_take` while she types in the take it un-chooses: it never asks
    /// for her flush, and her words still land in the take she typed in —
    /// nothing of hers is overwritten or lost (the record's SAFE row). Green on
    /// the pre-fix tree too: it pins what the fix must NOT change.
    @Test func aPointerMoveNeverNeedsHerFlushAndLosesNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try World(h)
            let note = try h.operations.createPost(title: "ch 1")
            let block = try h.operations.newBlock(in: note.id, text: "Chosen.", registeringUndo: false)
            let other = try h.operations.branchVariant(block.block.id, from: block.variant.id)
            w.editor.type(block.variant.id, "Chosen. Typed.")

            let chose = await w.call("choose_take", ["take_id": .string(other.id)])
            #expect(chose.isError != true, "\(chose.text)")
            #expect(!w.log.value.contains { $0.hasPrefix("flush:") })
            w.editor.flush()
            #expect(try await w.text(ofTake: block.variant.id) == "Chosen. Typed.")
            #expect(w.editor.pending.value.isEmpty)
        }
    }

    // MARK: - COPY: duplicate_note (VX-311, VX-336 U6a — APPENDED; nothing above modified)

    /// A duplicate COPIES her takes, as a version does — her own Duplicate as
    /// Version flushes first (`AppSession.runCopying`, 13e E10), so the wire's
    /// does too, in its own turn before the act's (the run record's D-311-6).
    /// **RED on old:** `Unknown tool: duplicate_note.` — no flush, no copy.
    @Test func aWireDuplicateAsksForHerFlushAndCopiesHerLatestText() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try World(h)
            let note = try h.operations.createPost(title: "ch 1")
            let block = try h.operations.newBlock(in: note.id, text: "Her line.", registeringUndo: false)
            w.editor.type(block.variant.id, "Her line. Her last words.")

            let duplicated = await w.call("duplicate_note", ["note_id": .string(note.id)])
            #expect(duplicated.isError != true, "\(duplicated.text)")
            #expect(w.log.value == ["flush:duplicate_note", "act"], "her flush, THEN the act's own turn")
            let copyID = try #require(try w.json(duplicated)["note_id"] as? String)
            #expect(try await w.rendered(copyID) == "Her line. Her last words.", "the copy carries her latest words")
            #expect(try await w.rendered(note.id) == "Her line. Her last words.")
        }
    }
}
