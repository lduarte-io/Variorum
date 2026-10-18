//
//  MCPConnectionEndDoorTests.swift
//  VariorumTests
//
//  VX-394 (VX-348 U5 — the run record `notes/plans/fixes/vx-348-prelaunch-sweep.md`
//  §U5, VX-394's section): a dropped MCP connection says why in Settings ▸ MCP ▸
//  Activity. The headless half (the host's lines, once each) is
//  `MCPConnectionEndServerTests`; these pin the APP's half — the door's two
//  stop roads carry their reasons, the lock road says the library's closing
//  BEFORE the services stop, and the four ends read in words.
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 394))
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

/// A raw client on the door's socket: its own setup key's preamble, then an
/// `initialize` as `name` — admitted (a first contact is a pending request,
/// which is a connection that named itself). Returns the descriptor once the
/// server answered; the caller closes it.
private func connect(_ directory: URL, as name: String, key: String) throws -> Int32 {
    guard case .success(let fd) = MCPSocketRoad.connect(directory: directory) else {
        throw CocoaError(.fileNoSuchFile)
    }
    var timeout = timeval(tv_sec: 5, tv_usec: 0)
    _ = setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
    var bytes = MCPPreamble.line(key: key)
    bytes.append(Data((#"{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"\#(name)","version":"1"}}}"# + "\n").utf8))
    bytes.withUnsafeBytes { raw in
        var offset = 0
        while offset < raw.count {
            let written = Darwin.write(fd, raw.baseAddress! + offset, raw.count - offset)
            guard written > 0 else { return }
            offset += written
        }
    }
    _ = MCPShim.readFirstLine(fd, limit: 1 << 20)
    return fd
}

private func endActs(_ db: AppDatabase) async throws -> [String] {
    let acts = Set(MCPConnectionEnd.allCases.map(\.act))
    return try await db.read { try Queries.mcpActivity($0) }.reversed().map(\.act).filter { acts.contains($0) }
}

@MainActor
@Suite("VX-394 — a dropped connection says why (the app's half)", .serialized)
struct MCPConnectionEndDoorTests {
    /// RED ON OLD: the door's stops logged nothing. Her switch OFF ends the
    /// connection as "the server was turned off"; the lock road's record,
    /// then its detach, as "the library locked or closed" — ONCE.
    @Test func theDoorsTwoStopRoadsSayTheirReasonsOnce() async throws {
        try await withDoorWorld { (session: AppSession, db: AppDatabase) async throws in
            let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent("vend-\(UUID().uuidString.prefix(8))", isDirectory: true)
            defer { try? FileManager.default.removeItem(at: directory) }
            let operations = Operations()
            let door = MCPDoor(serverAllowed: true) { database, executor in
                MCPServerHost(
                    database: database, operations: operations, directory: directory, version: "test",
                    executor: executor)
            }
            door.attach(session: session)
            door.setEnabled(true)
            #expect(try await settle { door.serverState == .running })
            let key = try operations.mintMCPSetupKey(copiedFor: "claude-code")
            // Its `initialize` answered, the connection has named itself.
            let first = try connect(directory, as: "claude-code", key: key)
            defer { close(first) }

            door.setEnabled(false)   // her switch
            #expect(try await settle { door.serverState == .off })
            var ends: [String] = []
            for _ in 0..<300 {
                ends = try await endActs(db)
                if !ends.isEmpty { break }
                try await Task.sleep(for: .milliseconds(10))
            }
            #expect(ends == [MCPConnectionEnd.serverOff.act])

            door.setEnabled(true)
            #expect(try await settle { door.serverState == .running })
            let second = try connect(directory, as: "claude-code", key: key)
            defer { close(second) }
            await door.recordLibraryClosing()   // the lock road, before the store goes
            #expect(try await endActs(db) == [MCPConnectionEnd.serverOff.act, MCPConnectionEnd.libraryClosed.act])
            door.detach()                        // …then its stop
            try await Task.sleep(for: .milliseconds(300))
            #expect(try await endActs(db) == [MCPConnectionEnd.serverOff.act, MCPConnectionEnd.libraryClosed.act],
                    "the detach's hang-up never says it twice")
        }
    }

    /// The ruled lock order, with the door's step in it: every note's leaving
    /// savepoint (the quit-finalize registry), THEN the connections' end
    /// lines, THEN the services stop — so the lines land while the store is
    /// open and nothing of hers waits on them. RED ON OLD: no such step.
    @Test func theLockRoadSaysTheConnectionsEndAfterTheSavepointsAndBeforeTheStop() async throws {
        try await withDoorWorld { (session: AppSession, _: AppDatabase) async throws in
            let order = LockIsolated<[String]>([])
            let token = session.quitFinalize.register { order.withValue { $0.append("savepoints") } }
            defer { session.quitFinalize.unregister(token) }
            let teardown = macWillLock(
                session: session, endingConnections: { order.withValue { $0.append("connections") } }
            ) { order.withValue { $0.append("stop") } }
            await teardown()
            #expect(order.value == ["savepoints", "connections", "stop"])
        }
    }

    /// The four ends, in words (PROVISIONAL, VX-234's pass): never a raw act
    /// id, never an underscore, the count said when a run coalesces.
    @Test func aConnectionsEndReadsInWords() {
        func said(_ end: MCPConnectionEnd, count: Int = 1) -> String {
            MCPPaneCopy.activityLine(MCPActivityFace.Line(
                id: 1, clientName: "claude-code", act: end.act, targetKind: nil, targetID: nil,
                targetTitle: nil, allowed: true, count: count, at: "2026-10-18T03:31:00.000Z"))
        }
        #expect(said(.clientClosed) == "claude-code disconnected")
        #expect(said(.libraryClosed) == "claude-code was disconnected when the library locked or closed")
        #expect(said(.serverOff) == "claude-code was disconnected when the MCP server was turned off")
        #expect(said(.overLimit) == "claude-code was disconnected after a message over the size limit")
        #expect(said(.clientClosed, count: 3) == "claude-code disconnected (3 times)")
        for end in MCPConnectionEnd.allCases {
            #expect(!said(end).contains("_"), "\(end): \(said(end))")
        }
    }
}
