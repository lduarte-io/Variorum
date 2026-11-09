//
//  VX775ActivityLogFailureDoorTests.swift
//  VariorumTests (Mac)
//
//  VX-775 — THE APP'S HALF (the VX-913 run, B3; the run record's B3 RECORD).
//  Her rulings: "the error goes to her, the truth goes to the client" (the #267
//  sitting) and, at this run's kickoff, a REFUSAL-kind line on the one status
//  seam naming the client and the store's own words. The headless pins are
//  `MCPActivityLogFailureServerTests` (red on the seam tree and under the
//  behavioural revert — the fix commit's `MCPWriteTools.swift` and
//  `MCPWriteTools+NoteLists.swift` from its parent); this file is the face, and
//  the whole road through the REAL door, host and socket.
//
//  The store's failure is made real as the headless pins make it: a TEMP trigger
//  on the session's one connection aborting every `mcp_activity` insert (VX-369's
//  precedent — GRDB raises the same `DatabaseError` for a full disk).
//

import Darwin
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
import VariorumMCP
import VariorumMCPSocket
@testable import Variorum

@MainActor
private func withDoorWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 775))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
private func settle(_ condition: @MainActor () -> Bool) async throws -> Bool {
    for _ in 0..<300 {
        if condition() { return true }
        try await Task.sleep(for: .milliseconds(10))
    }
    return condition()
}

/// A minimal client on the door's socket — its key's preamble, `initialize`,
/// `notifications/initialized`, then ONE `tools/call`. Every read and write is
/// off the main actor (the door's hooks land there).
private nonisolated func writeLine(_ fd: Int32, _ data: Data) {
    var bytes = data
    bytes.append(UInt8(ascii: "\n"))
    bytes.withUnsafeBytes { raw in
        var offset = 0
        while offset < raw.count {
            let written = Darwin.write(fd, raw.baseAddress! + offset, raw.count - offset)
            if written < 0, errno == EINTR { continue }
            guard written > 0 else { return }
            offset += written
        }
    }
}

private nonisolated func answer(_ fd: Int32, to id: Int) -> [String: Any]? {
    for _ in 0..<64 {
        let line = MCPShim.readFirstLine(fd, limit: 1 << 20)
        guard !line.isEmpty else { return nil }
        guard let object = try? JSONSerialization.jsonObject(with: line) as? [String: Any] else { continue }
        if (object["id"] as? Int) == id { return object }
    }
    return nil
}

private nonisolated func connectNamed(_ directory: URL, as name: String, key: String) throws -> Int32 {
    guard case .success(let fd) = MCPSocketRoad.connect(directory: directory) else {
        throw CocoaError(.fileNoSuchFile)
    }
    var timeout = timeval(tv_sec: 10, tv_usec: 0)
    _ = setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
    var preamble = MCPPreamble.line(key: key)
    preamble.removeLast()   // the preamble carries its own newline; writeLine adds one
    writeLine(fd, preamble)
    writeLine(fd, Data(#"{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"\#(name)","version":"1"}}}"#.utf8))
    _ = answer(fd, to: 1)
    writeLine(fd, Data(#"{"jsonrpc":"2.0","method":"notifications/initialized"}"#.utf8))
    return fd
}

private nonisolated func callTool(_ fd: Int32, _ tool: String, _ arguments: [String: String]) throws -> (text: String, isError: Bool) {
    let request: [String: Any] = [
        "jsonrpc": "2.0", "id": 2, "method": "tools/call", "params": ["name": tool, "arguments": arguments],
    ]
    writeLine(fd, try JSONSerialization.data(withJSONObject: request))
    guard let reply = answer(fd, to: 2), let result = reply["result"] as? [String: Any],
          let content = result["content"] as? [[String: Any]]
    else { throw CocoaError(.coderReadCorrupt) }
    return (content.compactMap { $0["text"] as? String }.joined(), result["isError"] as? Bool ?? false)
}

/// The door's own server in a temp directory (the VX-605 pins' world).
@MainActor
private final class DoorServer {
    let directory: URL
    let operations: Operations
    let door: MCPDoor

    init() {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("v775-\(UUID().uuidString.prefix(8))", isDirectory: true)
        let operations = Operations()
        self.directory = directory
        self.operations = operations
        door = MCPDoor(serverAllowed: true) { database, executor in
            MCPServerHost(
                database: database, operations: operations, directory: directory, version: "test",
                executor: executor)
        }
    }

    func cleanUp() { try? FileManager.default.removeItem(at: directory) }
}

private let fullDisk = MCPActivityLogFailure(
    clientName: "claude-code", tool: "add_comment", unrecorded: 1,
    storeWords: "SQLite error 13: database or disk is full")

@MainActor
@Suite("VX-775 — a landed write whose Activity line fails: the truth to the client, the error to her", .serialized)
struct VX775ActivityLogFailureDoorTests {
    /// The words (PROVISIONAL, drafted for her trim): the client and the store's
    /// own words; the count form for a list call; no words where the store says
    /// nothing safe to show.
    @Test func theRefusalNamesTheClientAndTheStoresWords() {
        #expect(MCPReceiptCopy.activityLogFailed(fullDisk)
                == "claude-code's change landed, but the activity log couldn't record it \u{2014} SQLite error 13: database or disk is full.")
        #expect(MCPReceiptCopy.activityLogFailed(MCPActivityLogFailure(
            clientName: "codex", tool: "apply_tag", unrecorded: 3, storeWords: "the library is locked"))
                == "codex's 3 changes landed, but the activity log couldn't record them \u{2014} the library is locked.")
        #expect(MCPReceiptCopy.activityLogFailed(MCPActivityLogFailure(
            clientName: "claude-code", tool: "add_take", unrecorded: 1, storeWords: nil))
                == "claude-code's change landed, but the activity log couldn't record it.")
    }

    /// The face: the receipt lands first (⌥⌘O's last change kept — the write is
    /// in her store), then the failure takes the seam as a REFUSAL — the toast,
    /// under her quiet receipt style (and under off).
    @Test func theFailureIsARefusalToastAfterTheReceiptLanded() async throws {
        try await withDoorWorld { (session: AppSession, _: AppDatabase) async throws in
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            for style in [ReceiptStyle.quiet, .off] {
                session.status.receiptStyle = style
                door.landReceipt(MCPWriteReceipt(
                    clientName: "claude-code", act: .comment, targetID: "n1", targetTitle: "ch 1",
                    show: .note(noteID: "n1", blockID: nil, select: nil)))
                door.landActivityLogFailure(fullDisk)
                #expect(session.status.current?.kind == .refusal, "\(style): always the toast")
                #expect(session.status.current?.text == MCPReceiptCopy.activityLogFailed(fullDisk))
                #expect(door.lastShow == .note(noteID: "n1", blockID: nil, select: nil),
                        "\(style): the landed change is still ⌥⌘O's")
            }
        }
    }

    /// **RED ON OLD (the behavioural revert of the core fix):** through the REAL
    /// door, host and socket — a client's landed `add_comment` while her store
    /// refuses the Activity line answers the act's own answer, and the door's
    /// toast says the failure. Old: `isError` in the store-failure words, no
    /// receipt, and nothing on her seam.
    @Test func throughTheRealDoorTheClientHearsTheTruthAndSheHearsTheFailure() async throws {
        try await withDoorWorld { (session: AppSession, db: AppDatabase) async throws in
            let server = DoorServer()
            defer { server.cleanUp() }
            let door = server.door
            door.attach(session: session)
            defer { door.detach() }
            session.status.receiptStyle = .quiet
            door.setEnabled(true)
            #expect(try await settle { door.serverState == .running })
            let note = try server.operations.createPost(title: "ch 1")
            let seeded = try server.operations.newBlock(in: note.id, text: "Her line.", registeringUndo: false)
            let key = try server.operations.mintMCPSetupKey(copiedFor: "claude-code")
            let directory = server.directory
            let fd = try await Task.detached { try connectNamed(directory, as: "claude-code", key: key) }.value
            defer { close(fd) }
            let client = try #require(try await db.read { try Queries.mcpClient($0, name: "claude-code") })
            _ = try server.operations.approveMCPClient(
                client.id, granting: .init(rung: .suggest, scopeKind: .note, scopeID: note.id, duration: .always))

            try await db.write { db in
                try db.execute(sql: """
                    CREATE TEMP TRIGGER vx775_log_failure BEFORE INSERT ON mcp_activity
                    BEGIN SELECT RAISE(ABORT, 'the store refused'); END
                    """)
            }
            let blockID = seeded.block.id
            let result = try await Task.detached {
                try callTool(fd, "add_comment", ["block_id": blockID, "text": "A thought."])
            }.value
            try await db.write { db in try db.execute(sql: "DROP TRIGGER vx775_log_failure") }

            #expect(!result.isError, "RED ON OLD: the act's own answer — \(result.text)")
            #expect(result.text.contains("\"comment_id\""), "\(result.text)")
            let expected = MCPReceiptCopy.activityLogFailed(MCPActivityLogFailure(
                clientName: "claude-code", tool: "add_comment", unrecorded: 1,
                storeWords: "SQLite error 19: the store refused"))
            #expect(try await settle { session.status.current?.text == expected },
                    "RED ON OLD: her seam says the failure — got \(String(describing: session.status.spoken?.text))")
            #expect(session.status.current?.kind == .refusal)
            #expect(door.lastShow != nil, "RED ON OLD: the landed write's receipt reached her (⌥⌘O's last change)")
        }
    }
}
