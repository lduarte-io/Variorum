import Darwin
import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-818 (the VX-809 run, batch 4 — `notes/plans/fixes/vx-809-mcp-door-ergonomics.md`,
// BATCH 4 RECORD; her R-818, A-809-20): THE SERVER SURVIVES THE LOCK — the host's
// half, headless. The harness drives the host's two new roads directly
// (`suspend()` while the store is still open, then the pool closed under the bound
// view; the pool opened again, then `resume(executor:)`), exactly the order the
// app's lock road and next ready run them. The app's half (which teardown suspends
// and which still stops — `macLockTeardown` reading the bootstrap's road) is
// `MCPStopRoadsDoorTests` / `MacWillLockTests` (App target, under the stage).
//
// Feature pins of a new posture: the host had no suspend road before this batch,
// so its red-on-old lives where the posture is chosen — the App suites drive
// `macLockTeardown` on both trees. The one bug-class row here (a call the lock
// OVERTOOK answered a raw Swift case) carries its own named revert.

private func lockedText(_ result: (content: [Tool.Content], isError: Bool?)) -> (String, Bool) {
    (text(result), result.isError ?? false)
}

/// The activity log's rows, newest first, as "client act".
private func activity(_ h: ServerHarness) throws -> [String] {
    try h.database.read { try Queries.mcpActivity($0) }.map { "\($0.clientName) \($0.act)" }
}

private func revokedAt(_ h: ServerHarness, _ grantID: String) throws -> String? {
    try h.database.read { try Queries.mcpGrant($0, id: grantID) }?.revokedAt
}

/// Every line the server writes to `fd` until it hangs up (each without its
/// newline), read under the descriptor's receive bound.
private func linesUntilEOF(_ fd: Int32) -> [Data] {
    var lines: [Data] = []
    var line = Data()
    var byte: UInt8 = 0
    while true {
        let count = read(fd, &byte, 1)
        if count < 0, errno == EINTR { continue }
        guard count == 1 else { break }
        if byte == UInt8(ascii: "\n") {
            lines.append(line)
            line = Data()
        } else {
            line.append(byte)
        }
    }
    if !line.isEmpty { lines.append(line) }
    return lines
}

/// The close line among `lines` (the 0x1E-led line VX-762's road writes), as words.
private func closeWords(_ lines: [Data]) -> String? {
    lines.last { $0.first == 0x1E }.map { String(decoding: $0.dropFirst(), as: UTF8.self) }
}

@Suite("VX-818 — the server survives the Castle lock: the host's half", .serialized)
struct MCPLockPostureServerTests {
    /// **Every call while locked answers ONE flat sentence, before anything is
    /// read** — a note the client can read, an id that names nothing, an unknown
    /// tool, a write with an undeclared argument: byte-identical answers, no
    /// grant decided, nothing logged, nothing spent (the once grant is still
    /// unspent after the unlock), and the store never touched (it is CLOSED —
    /// any access would have answered the store-failure form instead).
    @Test func everyCallWhileLockedAnswersTheOneSentenceAndTouchesNothing() async throws {
        let h = try ServerHarness(lockable: true)
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "the dunes")
            _ = try h.operations.newBlock(in: note.id, text: "marram on the dunes", registeringUndo: false)
            let other = try h.operations.createPost(title: "another")
            let conn = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", .init(rung: .edit, scopeKind: .note, scopeID: note.id, duration: .always))
            let once = try h.operations.grantMCPAccess(
                try h.client("claude-code").id,
                .init(rung: .read, scopeKind: .note, scopeID: other.id, duration: .once))
            let logged = try activity(h)

            #expect(h.host.suspend(), "a running host suspends")
            #expect(h.host.state == .suspended)
            try h.lockStore()

            let calls: [(String, [String: Value]?)] = [
                ("read_note", ["note_id": .string(note.id)]),
                ("read_note", ["note_id": .string(other.id)]),
                ("read_note", ["note_id": .string("no-such-note")]),
                ("no_such_tool", nil),
                ("rename_note", ["note_id": .string(note.id), "title": .string("x"), "undeclared": .bool(true)]),
                ("list_my_activity", nil),
            ]
            for (tool, arguments) in calls {
                let (said, isError) = lockedText(try await conn.client.callTool(name: tool, arguments: arguments))
                #expect(said == MCPLockedLibrary.words, "\(tool): \(said)")
                #expect(isError, "\(tool) answers as a refusal")
            }
            #expect(MCPLockedLibrary.words == "The library is locked \u{2014} ask again once it's unlocked.")

            try h.unlockStore()
            #expect(await h.host.resume(executor: SeededExecutor(operations: h.writeOperations)) == .resumed)
            #expect(try activity(h) == logged, "nothing was logged while the library was locked")
            #expect(try revokedAt(h, once) == nil, "no once grant was spent")
            let spent = try await h.database.read { try Queries.mcpGrant($0, id: once) }?.consumedAt
            #expect(spent == nil, "the once grant is still unspent")
            await h.hangUp(conn)
        }
    }

    /// **The connection SURVIVES lock → unlock, and its next call serves** — the
    /// same connection, no reconnect, no re-grant; its WHILE-CONNECTED grant is
    /// alive after the unlock (it never disconnected — the consequence named in
    /// the bundle, P-809-4); an always grant as ever. The resume re-announces the
    /// tool list, and a list while locked is the one it was last served (F-15b).
    @Test func theConnectionSurvivesTheLockAndItsWhileConnectedGrantWithIt() async throws {
        let h = try ServerHarness(lockable: true)
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "the dunes")
            _ = try h.operations.newBlock(in: note.id, text: "marram on the dunes", registeringUndo: false)
            let conn = try await h.connect(as: "claude-code")
            let whileConnected = try #require(try h.approve(
                "claude-code", .init(rung: .read, scopeKind: .wing, scopeID: "", duration: .connection)))
            let listed = try await conn.client.listTools().tools.map(\.name)
            #expect(listed.contains("read_note"))

            #expect(h.host.suspend())
            try h.lockStore()
            let whileLocked = try await conn.client.listTools().tools.map(\.name)
            #expect(whileLocked == listed, "F-15b (i): the last-served list, nothing read")
            #expect(h.host.connectedClientNames == ["claude-code"], "the connection is still the client's")
            try await Task.sleep(for: .milliseconds(200))

            try h.unlockStore()
            #expect(await h.host.resume(executor: SeededExecutor(operations: h.writeOperations)) == .resumed)
            #expect(h.host.state == .running)
            #expect(try revokedAt(h, whileConnected) == nil, "the until-disconnect grant survived the lock")
            let read = text(try await conn.client.callTool(name: "read_note", arguments: ["note_id": .string(note.id)]))
            #expect(read.contains("marram on the dunes"), "the next call serves on the same connection: \(read)")
            #expect(try activity(h).allSatisfy { !$0.hasSuffix(MCPConnectionEnd.libraryClosed.act) },
                    "nothing ended, so no end line was said")
            await h.hangUp(conn)
        }
    }

    /// **A connection that CLOSED during the lock** — its client's last — leaves no
    /// line (nothing logs while the store is shut) and its while-connected grant
    /// ends AT THE RESUME, before anything is served: never kept past it. An
    /// always grant stays.
    @Test func aClientThatLeftDuringTheLockLosesItsWhileConnectedGrantAtTheResume() async throws {
        let h = try ServerHarness(lockable: true)
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "a note")
            let conn = try await h.connect(as: "claude-code")
            let whileConnected = try #require(try h.approve(
                "claude-code", .init(rung: .read, scopeKind: .wing, scopeID: "", duration: .connection)))
            let always = try h.operations.grantMCPAccess(
                try h.client("claude-code").id,
                .init(rung: .read, scopeKind: .note, scopeID: note.id, duration: .always))
            let logged = try activity(h)

            #expect(h.host.suspend())
            try h.lockStore()
            await h.hangUp(conn)
            #expect(try await h.eventually { h.host.connectedClientNames.isEmpty }, "the client left")

            try h.unlockStore()
            #expect(await h.host.resume(executor: SeededExecutor(operations: h.writeOperations)) == .resumed)
            #expect(try revokedAt(h, whileConnected) != nil, "its last connection ended: the grant ended at the resume")
            #expect(try revokedAt(h, always) == nil, "an always grant outlives it")
            #expect(try activity(h) == logged, "the end during the lock said nothing")
        }
    }

    /// **A NEW connection during the lock is HELD** (A-809-20): its `initialize`
    /// answered, it names no one (not connected, no client row, nothing logged),
    /// it lists no tools, every call hears the locked sentence; at the resume its
    /// admission runs through the one op — it becomes the client and is served
    /// on the same connection, no reconnect.
    @Test func aConnectionArrivingDuringTheLockIsHeldThenAdmittedAtTheResume() async throws {
        let h = try ServerHarness(lockable: true)
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "the dunes")
            _ = try h.operations.newBlock(in: note.id, text: "marram", registeringUndo: false)
            _ = try h.setupKey(for: "claude-code")
            let logged = try activity(h)

            #expect(h.host.suspend())
            try h.lockStore()
            let held = try await h.connect(as: "claude-code")
            #expect(held.client.initialized.serverInfo.name == VariorumMCP.serverName, "initialize answered normally")
            #expect(try await held.client.listTools().tools.isEmpty, "a held connection lists no tools")
            let said = text(try await held.client.callTool(name: "read_note", arguments: ["note_id": .string(note.id)]))
            #expect(said == MCPLockedLibrary.words)
            #expect(h.host.connectedClientNames.isEmpty, "a held connection names no one")

            try h.unlockStore()
            let noRow = try await h.database.read { try Queries.mcpClient($0, name: "claude-code") } == nil
            #expect(noRow, "nothing was written for it while locked")
            #expect(try activity(h) == logged)
            #expect(await h.host.resume(executor: SeededExecutor(operations: h.writeOperations)) == .resumed)
            #expect(try await h.eventually { h.host.connectedClientNames == ["claude-code"] },
                    "admitted at the resume: a connection request, as at any first contact")
            _ = try h.approve("claude-code", .init(rung: .read, scopeKind: .note, scopeID: note.id, duration: .always))
            let read = text(try await held.client.callTool(name: "read_note", arguments: ["note_id": .string(note.id)]))
            #expect(read.contains("marram"), "served on the same connection: \(read)")
            await h.hangUp(held)
        }
    }

    /// **A held connection the admission REFUSES** (a bare shim) hears the
    /// refusal as its close line at the resume, and ends naming no one — the
    /// refusal logged as at connect (her Activity speaks it), nothing more.
    @Test func aHeldConnectionRefusedAtTheResumeHearsItAsItsCloseLine() async throws {
        let h = try ServerHarness(lockable: true)
        defer { h.tearDown() }
        #expect(h.host.suspend())
        try h.lockStore()
        let (fd, answer) = try h.rawOpen(as: "claude-code", presenting: nil)
        defer { close(fd) }
        #expect(answer["result"] != nil, "a bare shim's initialize is answered while held: \(answer)")
        try h.unlockStore()
        #expect(await h.host.resume(executor: SeededExecutor(operations: h.writeOperations)) == .resumed)
        let lines = linesUntilEOF(fd)
        #expect(closeWords(lines) == MCPHandshake.refusal, "\(lines.map { String(decoding: $0, as: UTF8.self) })")
        #expect(h.host.connectedClientNames.isEmpty)
        #expect(try activity(h).first?.hasPrefix("claude-code ") == true, "the refusal is logged in words for her")
    }

    /// **THE IDENTITY BELT (A-809-20):** another library opened beneath the held
    /// connections (the lobby's empty-slot landing — no teardown ran) — the
    /// resume ABANDONS them: each hears the closing road's close line, and
    /// NOTHING is written to the library now open (no end line, no client row,
    /// no grant touched) — their own library's store is gone.
    @Test func aResumeOverAnotherLibraryAbandonsAndWritesNothing() async throws {
        let h = try ServerHarness(lockable: true)
        defer { h.tearDown() }
        try await h.within {
            let (fd, _) = try h.rawOpen(as: "claude-code", presenting: try h.setupKey(for: "claude-code"))
            defer { close(fd) }
            _ = try h.approve("claude-code", .init(rung: .read, scopeKind: .wing, scopeID: "", duration: .connection))
            #expect(try await h.eventually { h.host.connectedClientNames == ["claude-code"] })

            #expect(h.host.suspend())
            try h.lockStore()
            let other = try h.swapInAnotherStore()
            defer {
                for suffix in ["", "-wal", "-shm"] { try? FileManager.default.removeItem(atPath: other.path + suffix) }
            }
            #expect(await h.host.resume(executor: SeededExecutor(operations: h.writeOperations)) == .abandoned)
            let lines = linesUntilEOF(fd)
            #expect(closeWords(lines) == MCPCloseWords.libraryClosed)
            try await Task.sleep(for: .milliseconds(300))
            #expect(try activity(h).isEmpty, "nothing written to the library now open")
            let noClient = try await h.database.read { try Queries.mcpClient($0, name: "claude-code") } == nil
            #expect(noClient)
            #expect(h.host.state == .stopped)
        }
    }

    /// **The resumed host writes through the FRESH session's executor** (the slot):
    /// the client's write registers its undo on the NEW stack the unlock
    /// composed, never the dead one — her ⌥⌘Z reaches it.
    @Test func aWriteAfterTheResumeLandsOnTheFreshExecutorsUndoStack() async throws {
        let h = try ServerHarness(lockable: true)
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "a note")
            let conn = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", .init(rung: .writeNew, scopeKind: .note, scopeID: note.id, duration: .always))

            #expect(h.host.suspend())
            try h.lockStore()
            try h.unlockStore()
            let freshStack = UndoStack()
            let fresh = withDependencies {
                $0.database = h.database
                $0.uuid = UUIDGenerator { UUID() }
                $0.date = DateGenerator { ServerHarness.worldNow }
            } operation: { Operations(undoStack: freshStack) }
            #expect(await h.host.resume(executor: SeededExecutor(operations: fresh)) == .resumed)
            let before = h.undoStack.depth
            let tagged = try await conn.client.callTool(
                name: "apply_tag", arguments: ["note_id": .string(note.id), "tag": .string("dunes")])
            #expect(tagged.isError != true, "\(text(tagged))")
            #expect(freshStack.depth == 1, "the client's ⌥⌘Z entry is on the fresh session's stack")
            #expect(h.undoStack.depth == before, "never on the stack the lock let go")
            await h.hangUp(conn)
        }
    }

    /// **The quit while locked** stays the quit: the quit's close line, nothing
    /// written (the store is shut); a suspend of a host that is not running
    /// changes nothing; a resume before the store is open keeps it suspended.
    @Test func theQuitWhileLockedAndTheEdgesOfTheTwoRoads() async throws {
        let h = try ServerHarness(lockable: true)
        defer { h.tearDown() }
        let (fd, _) = try h.rawOpen(as: "claude-code", presenting: try h.setupKey(for: "claude-code"))
        defer { close(fd) }
        #expect(try await h.eventually { h.host.connectedClientNames == ["claude-code"] })
        let logged = try activity(h)
        #expect(h.host.suspend())
        #expect(!h.host.suspend(), "a suspended host does not suspend twice")
        try h.lockStore()
        #expect(await h.host.resume(executor: SeededExecutor(operations: h.writeOperations)) == .stillLocked,
                "a resume before the store is open keeps the host suspended")
        #expect(h.host.state == .suspended)
        h.host.stopWithTheProcess()
        #expect(closeWords(linesUntilEOF(fd)) == MCPCloseWords.quit)
        try h.unlockStore()
        try await Task.sleep(for: .milliseconds(200))
        #expect(try activity(h) == logged, "a quit says nothing, locked or not")
        #expect(await h.host.resume(executor: SeededExecutor(operations: h.writeOperations)) == .notSuspended)
    }

    /// **RED ON OLD (the one bug-class row) — a call the lock OVERTOOK:** the
    /// store shut under a call already past the door (here: the pool closed with
    /// no suspend — what a call in flight meets). It answered the raw Swift case
    /// ("…: StoreLockedError()") — VX-362's class; it now speaks the one chain's
    /// store-failure sentence in its honest form, never "ask again" (an act may
    /// have landed before a later write of the same call met the lock).
    @Test func aCallTheLockOvertookSpeaksTheStoreFailureFormNeverARawCase() async throws {
        let h = try ServerHarness(lockable: true)
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "a note")
            let conn = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", .init(rung: .read, scopeKind: .note, scopeID: note.id, duration: .always))
            _ = try await conn.client.listTools()
            try h.lockStore()
            let said = text(try await conn.client.callTool(name: "read_note", arguments: ["note_id": .string(note.id)]))
            #expect(!said.contains("StoreLockedError"), "no raw Swift case on the wire: \(said)")
            #expect(said == MCPWireRefusalCopy.storeFailureWords(MCPLockedLibrary.overtakenDetail), "\(said)")
            try h.unlockStore()
            await h.hangUp(conn)
        }
    }
}

/// The words, pure (no socket — VX-818's bug-class row's red-on-old leg runs here).
@Suite("VX-818 — the locked library's words")
struct MCPLockedWordsTests {
    /// **RED ON OLD:** a `StoreLockedError` reaching a tool family's catch-all
    /// was said as "Variorum couldn't complete ‹tool›: StoreLockedError()" — a raw
    /// Swift case on the wire (VX-362's class). Now: the store-failure sentence's
    /// honest form, through the ONE chain, on every road a call can leave by.
    @Test func aStoreLockedErrorIsSaidInTheStoreFailureFormOnEveryRoad() {
        let honest = MCPWireRefusalCopy.storeFailureWords(MCPLockedLibrary.overtakenDetail)
        #expect(honest == "Variorum's library store refused the work (the library is locked), so this call may "
                + "not have landed \u{2014} read what it touches before trying again.")
        #expect(MCPWireRefusalCopy.unexpected(StoreLockedError(), tool: "read_note", appWords: { _ in nil }) == honest)
        #expect(MCPWireRefusalCopy.spoken(StoreLockedError(), appWords: { _ in "an app sentence" }) == honest)
        #expect(!honest.contains("ask again"), "never the door's invitation: the act may have landed")
    }
}
