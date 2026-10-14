//
//  MCPHerEditorDoorTests.swift
//  VariorumTests (Mac)
//
//  VX-275 (Run VX-246, U3 — the record `notes/plans/fixes/vx-246-mcp-door-
//  fixes-ai-docs.md`, U3 UNIT RECORD): HER EDITOR vs THE WIRE, through the
//  REAL door. Her ruling (a): before a wire delete lands, the app saves what
//  she has typed and moves her pane off the deleted note, exactly as her own
//  Delete door does.
//
//  Every pin here runs the shipping chain end to end: a REAL `EditorViewModel`
//  over a real `EditorTextView` with her keystrokes typed through the real
//  input road into the session's ONE coordinator; the REAL `MCPDoor`, attached
//  to the session, serving a real `MCPServerHost` on a socket whose writes run
//  on her `OperationsRunner`; and a client speaking JSON-RPC over that socket.
//  The ONE thing held still: her 500 ms debounce never fires by itself (the
//  coordinator is minted with a sleep that never returns), so "she is still
//  typing" is a STATE the pin holds, never a race against the clock — and a
//  pin's own `flushNow()` is her debounce firing later.
//
//  Written BEFORE the fix, on the seam tree (`MCPHostHooks.beforeWrite` and
//  `MCPWriteReceipt.notesLeftDead` exist, the door is wired to both, the wire
//  calls neither): every pin is RED on old; the red-on-old product is built
//  from that commit (`DerivedData/vx246-u3-red`) and run at the stage (W1).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
import VariorumMCP
import VariorumMCPSocket
@testable import Variorum

// MARK: - A client on the socket (JSON-RPC lines; every read and write OFF the main actor)

/// A minimal MCP client: the setup key's preamble line, `initialize`, then
/// `tools/call`s. Its I/O runs on a detached task so the main actor stays free
/// for the door's hooks (the flush runs THERE — a client blocking the main
/// thread would deadlock the very act it waits for).
private final class SocketClient: @unchecked Sendable {
    let fd: Int32
    private let lock = NSLock()
    private var nextID = 2

    private init(fd: Int32) { self.fd = fd }

    struct Failure: Error, CustomStringConvertible { let description: String }

    static func connect(directory: URL, key: String, as name: String) async throws -> SocketClient {
        try await Task.detached { () throws -> SocketClient in
            guard case .success(let fd) = MCPSocketRoad.connect(directory: directory) else {
                throw Failure(description: "could not connect")
            }
            var timeout = timeval(tv_sec: 15, tv_usec: 0)
            _ = setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
            let client = SocketClient(fd: fd)
            client.send(MCPPreamble.line(key: key))
            client.send(Data(("""
                {"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18",\
                "capabilities":{},"clientInfo":{"name":"\(name)","version":"1"}}}
                """ + "\n").utf8))
            let answer = try client.answer(to: 1)
            guard answer["result"] != nil else {
                Darwin.close(fd)
                throw Failure(description: "initialize refused: \(answer)")
            }
            client.send(Data(#"{"jsonrpc":"2.0","method":"notifications/initialized"}"#.utf8 + [UInt8(ascii: "\n")]))
            return client
        }.value
    }

    /// One `tools/call`: the tool's text and whether it is an error.
    func call(_ tool: String, _ arguments: [String: String]) async throws -> (text: String, isError: Bool) {
        let id: Int = lock.withLock {
            defer { nextID += 1 }
            return nextID
        }
        let request: [String: Any] = [
            "jsonrpc": "2.0", "id": id, "method": "tools/call",
            "params": ["name": tool, "arguments": arguments],
        ]
        let line = try JSONSerialization.data(withJSONObject: request) + [UInt8(ascii: "\n")]
        return try await Task.detached { [self] () throws -> (text: String, isError: Bool) in
            send(line)
            let answer = try self.answer(to: id)
            guard let result = answer["result"] as? [String: Any],
                  let content = result["content"] as? [[String: Any]]
            else { throw Failure(description: "no result: \(answer)") }
            let text = content.compactMap { $0["text"] as? String }.joined()
            return (text, result["isError"] as? Bool ?? false)
        }.value
    }

    func close() { Darwin.close(fd) }

    private func send(_ data: Data) {
        data.withUnsafeBytes { raw in
            var offset = 0
            while offset < raw.count {
                let written = Darwin.write(fd, raw.baseAddress! + offset, raw.count - offset)
                if written < 0, errno == EINTR { continue }
                guard written > 0 else { return }
                offset += written
            }
        }
    }

    /// Reads line after line (notifications pass by) until the answer to `id`.
    private func answer(to id: Int) throws -> [String: Any] {
        for _ in 0..<64 {
            var line = Data()
            var byte: UInt8 = 0
            while true {
                let count = Darwin.read(fd, &byte, 1)
                if count < 0, errno == EINTR { continue }
                guard count == 1 else { throw Failure(description: "the server went quiet waiting for \(id)") }
                if byte == UInt8(ascii: "\n") { break }
                line.append(byte)
            }
            guard let object = try JSONSerialization.jsonObject(with: line) as? [String: Any] else { continue }
            if (object["id"] as? Int) == id { return object }
        }
        throw Failure(description: "no answer to \(id)")
    }
}

// MARK: - The world: her live editor + the real door + a client with edit on Home

@MainActor
private struct DoorEditor {
    let editor: EditorHarness
    let door: MCPDoor
    let client: SocketClient

    var session: AppSession { editor.session }
    var model: EditorViewModel { editor.model }

    func call(_ tool: String, _ arguments: [String: String]) async throws -> (text: String, isError: Bool) {
        try await client.call(tool, arguments)
    }

    func slots() throws -> [Queries.RenderedBlock] { try editor.storeSlots() }

    func takeText(_ variantID: String) async throws -> String? {
        try await editor.database.read { db in
            try String.fetchOne(db, sql: "SELECT working_text FROM variant WHERE id = ?", arguments: [variantID])
        }
    }
}

@MainActor
private func settle(_ condition: @MainActor () -> Bool) async throws -> Bool {
    for _ in 0..<500 {
        if condition() { return true }
        try await Task.sleep(for: .milliseconds(10))
    }
    return condition()
}

/// The door's own executor — her `OperationsRunner`, unchanged — with the
/// position jitter's RNG in scope (VX-246 ladder round 1, F-4 — the headless
/// harness's `SeededExecutor` precedent, `MCPServerTests.swift`).
/// `FractionalIndex.between` reads `\.withRandomNumberGenerator` from the
/// CALLER's context, and the served session's task, spawned from the host's
/// accept `Thread`, carries none of the pin's task-locals — so a wire write
/// that mints a position (a divide) read the live RNG and raised the
/// "has no test implementation" warning, unattributed, in every Mac batch.
/// Only the RNG is set: the runner's captured `Operations` keep the
/// harness's own clock and ids. Task-locals carry across the actor hop to
/// the runner (the same task), so the body still runs on her runner.
private struct ScopedRandomExecutor: MCPWriteExecutor {
    let inner: any MCPWriteExecutor
    let rng: WithRandomNumberGenerator

    func run<T: Sendable>(_ body: @Sendable (Operations) throws -> T) async throws -> T {
        try await withDependencies {
            $0.withRandomNumberGenerator = rng
        } operation: {
            try await inner.run(body)
        }
    }
}

/// `withEditor`'s world (EditorTestSupport — the same process-fresh Terminal
/// typography and voice row), with two differences: her coordinator is minted
/// FIRST with a debounce that never fires by itself, and the real door serves
/// a client holding an EDIT grant on the Home wing.
@MainActor
private func withDoorEditor<T>(
    seedBlocks: [String], _ body: @MainActor (DoorEditor) async throws -> T
) async throws -> T {
    let foundTypography = EditorTypography.current
    let foundAdopted = EditorTypography.isAdopted
    defer {
        EditorTypography.current = foundTypography
        EditorTypography.isAdopted = foundAdopted
    }
    EditorTypography.current = EditorTypography.resolve(voice: .terminal, inlineComments: false)
    EditorTypography.isAdopted = false
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    // F-4: ONE seeded RNG, shared by the pin's scope and the served side.
    let rng = WithRandomNumberGenerator(SeededGenerator(seed: 275))
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = rng
    } operation: { @MainActor in
        let session = AppSession(database: db)
        try session.operations.setThemeVoice(.terminal)
        let post = try session.operations.createPost(title: "T", profile: nil)
        for text in seedBlocks {
            _ = try session.operations.newBlock(in: post.id, text: text, registeringUndo: false)
        }
        // HER DEBOUNCE NEVER FIRES BY ITSELF: the coordinator is minted here,
        // first, so every surface on the post shares THIS one (the session's
        // cache keeps the first caller's clock).
        _ = session.autosave(forPost: post.id, sleep: { _ in throw CancellationError() })
        let model = EditorViewModel(session: session, postID: post.id)
        model.tailIdleSleep = { _ in throw CancellationError() }
        model.longBlockLayout.sleep = { _ in throw CancellationError() }
        let (scrollView, textView) = EditorTextView.makeEditor()
        let surfaceDelegate = EditorSurfaceDelegate(model: model)
        surfaceDelegate.wire(to: textView)
        model.attach(textView: textView, scrollView: scrollView)
        let editor = EditorHarness(
            session: session, database: db, model: model,
            textView: textView, surfaceDelegate: surfaceDelegate, postID: post.id)
        try editor.reload()

        // The real door, on a SHORT socket home of its own (AF-1's length
        // guard — MCPPaneTests' precedent), its writes on her runner (with
        // the pin's RNG in scope — F-4, `ScopedRandomExecutor`).
        let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("vh-\(UUID().uuidString.prefix(6))", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let grants = Operations()
        let door = MCPDoor(serverAllowed: true) { database, executor in
            MCPServerHost(
                database: database, operations: grants, directory: directory, version: "test",
                executor: ScopedRandomExecutor(inner: executor, rng: rng))
        }
        door.attach(session: session)
        defer { door.detach() }
        let known = try grants.recordMCPContact(name: "claude-code", version: "1")
        _ = try grants.approveMCPClient(
            known.id, granting: .init(rung: .edit, scopeKind: .wing, scopeID: "", duration: .always))
        let key = try grants.mintMCPSetupKey(copiedFor: "claude-code")
        door.setEnabled(true)
        guard try await settle({ door.serverState == .running }) else {
            throw SocketClient.Failure(description: "the door never served: \(door.serverState)")
        }
        let client = try await SocketClient.connect(directory: directory, key: key, as: "claude-code")
        defer { client.close() }
        return try await body(DoorEditor(editor: editor, door: door, client: client))
    }
}

// MARK: - The pins

@MainActor
@Suite("VX-275 — her editor vs the wire, through the real door", .serialized)
struct MCPHerEditorDoorTests {
    /// **Her ruling's letter, delete_note.** She is mid-sentence; a client
    /// deletes the note. Her words land in the note's take BEFORE the
    /// tombstone (Put back returns them), and the act posts THE ONE
    /// navigate-away signal naming the note, which takes every pane and the
    /// Open strip off it (`WorkspaceModel.notesDeleted` — RootView's listener's
    /// one line). **RED on old:** the tombstone holds the pre-typing text, her
    /// flush is refused, and nothing navigates.
    @Test func aWireNoteDeleteLandsHerWordsAndSendsEveryPaneAway() async throws {
        try await withDoorEditor(seedBlocks: ["Alpha one."]) { world in
            let heard = LockIsolated<[String]>([])
            let token = NotificationCenter.default.addObserver(
                forName: .variorumNotesDeleted, object: nil, queue: .main
            ) { note in
                let ids = (note.userInfo?["postIDs"] as? [String]) ?? []
                heard.setValue(ids)
            }
            defer { NotificationCenter.default.removeObserver(token) }
            let workspace = WorkspaceModel()
            workspace.select(.post(world.editor.postID))
            workspace.openBeside(.post("another"))

            world.editor.type(" And the last thought.", at: 10)
            #expect(world.model.autosave.isDirty, "her words are still pending")

            let answer = try await world.call("delete_note", ["note_id": world.editor.postID])
            #expect(answer.isError == false, "\(answer.text)")
            #expect(!world.model.autosave.isDirty, "her words landed before the act — nothing stranded")
            #expect(try await settle { !heard.value.isEmpty }, "the navigate-away signal was posted")
            #expect(heard.value == [world.editor.postID])
            workspace.notesDeleted(heard.value)
            #expect(!workspace.panes.contains { workspace.selections[$0] == .post(world.editor.postID) },
                    "no pane stands on the tombstone")
            #expect(!workspace.openNotes.ids.contains(world.editor.postID))

            try await world.session.runner.run { (ops: Operations) in try ops.restoreContainer(world.editor.postID) }
            #expect(try world.slots().map(\.text) == ["Alpha one. And the last thought."],
                    "Put back returns the note WITH what she typed last")
        }
    }

    /// **delete_block under her caret.** Her words land first; the act
    /// tombstones the block WITH them; and once the delivery arrives her
    /// editor drops the dead block's range the way her own Delete Block does —
    /// the rewrite from the store, and the caret on the block below's start.
    /// **RED on old:** the tombstone lacks her words, her editor stays dirty
    /// (every flush refused) and keeps the dead block on screen.
    @Test func aWireBlockDeleteUnderHerCaretLandsHerWordsAndTheEditorDropsTheRange() async throws {
        try await withDoorEditor(seedBlocks: ["One.", "Two.", "Three."]) { world in
            let two = try world.slots()[1]
            let twoEnd = world.model.index.range(ofEntryAt: 1).upperBound
            world.editor.type(" Typed.", at: twoEnd)
            #expect(world.model.autosave.isDirty)

            let answer = try await world.call("delete_block", ["block_id": two.blockID])
            #expect(answer.isError == false, "\(answer.text)")
            #expect(try await world.takeText(try #require(two.variantID)) == "Two. Typed.",
                    "the tombstone carries her words")
            #expect(!world.model.autosave.isDirty, "nothing refused, nothing stranded")

            try world.editor.reload()  // the delivery
            let fresh = try world.slots()
            #expect(world.model.index.entries.map(\.blockID) == fresh.map(\.blockID))
            #expect(world.editor.documentText == "One.\nThree.", "the dead block's range is gone")
            let caret = try #require(world.model.caretIdentity())
            #expect(caret.blockID == fresh[1].blockID && caret.offset == 0,
                    "her Delete Block's landing: the start of the block below")
        }
    }

    /// **The wider class, REWRITE.** The client read the take before she
    /// typed; with her words landed first, its `edit_take` is a stale read and
    /// refuses in her words — nothing written. **RED on old:** the edit lands
    /// on the stale row and her next flush silently writes over it.
    @Test func aWireTakeEditOverHerTypingRefusesStaleAndHerWordsStand() async throws {
        try await withDoorEditor(seedBlocks: ["Her line."]) { world in
            let take = try #require(try world.slots()[0].variantID)
            world.editor.type(" Still typing.", at: 9)

            let answer = try await world.call("edit_take", [
                "take_id": take, "text": "The client's line.", "expected_text": "Her line.",
            ])
            #expect(answer.isError == true, "a stale read refuses: \(answer.text)")
            await world.model.autosave.flushNow()  // her debounce
            #expect(try await world.takeText(take) == "Her line. Still typing.")
            #expect(world.session.undoStack.topLabel == nil, "nothing landed for her to undo")
        }
    }

    /// **The wider class, STRUCTURE.** A divide cuts her LATEST text. **RED on
    /// old:** the divide cuts the stored row and her flush writes the whole
    /// old block back into the first half — the second half reads twice.
    @Test func aWireDivideOverHerTypingNeverDuplicatesTheSecondHalf() async throws {
        try await withDoorEditor(seedBlocks: ["First half. Second half."]) { world in
            let block = try #require(try world.slots().first)
            world.editor.type(" And her extra.", at: 24)

            let answer = try await world.call("divide_block", [
                "block_id": block.blockID, "second_half_starts_with": "Second half",
            ])
            #expect(answer.isError == false, "\(answer.text)")
            await world.model.autosave.flushNow()  // her debounce
            let texts = try world.slots().compactMap(\.text)
            #expect(texts.joined(separator: "|").components(separatedBy: "Second half").count - 1 == 1, "\(texts)")
            #expect(texts.joined().contains("And her extra."), "\(texts)")
            try world.editor.reload()
            #expect(world.model.index.entries.count == 2)
        }
    }
}
