//
//  MCPPaneTests.swift
//  VariorumTests (Mac)
//
//  13n-b U1 — SETTINGS ▸ MCP and the door's lifecycle (A-8): the setup
//  command's words and quoting (R-13nb-5), the registry and roster
//  declarations, the test-process fence, the server serving only while
//  attached and ON (and its socket unlinked at detach), the capped snapshot
//  (R-13n-10), and Approve… granting in one act.
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 31))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

/// Wait (bounded) for a condition the door's observation settles.
@MainActor
private func settle(_ condition: @MainActor () -> Bool) async throws -> Bool {
    for _ in 0..<300 {
        if condition() { return true }
        try await Task.sleep(for: .milliseconds(10))
    }
    return condition()
}

@MainActor
@Suite("13n-b U1 — Settings ▸ MCP (the pane and the door's lifecycle)", .serialized)
struct MCPPaneTests {
    // MARK: - The setup command (R-13nb-5)

    @Test func theSetupCommandIsUserScopedAndQuotedForTheShell() {
        let plain = MCPPaneCopy.setupCommand(
            shimPath: "/Applications/Variorum.app/Contents/MacOS/variorum-mcp", isDebugBuild: false)
        #expect(plain == "claude mcp add -s user variorum -- \"/Applications/Variorum.app/Contents/MacOS/variorum-mcp\"")
        let awkward = MCPPaneCopy.setupCommand(shimPath: "/Users/a b/\"x\"/$y/`z`\\w", isDebugBuild: false)
        #expect(awkward.hasSuffix("-- \"/Users/a b/\\\"x\\\"/\\$y/\\`z\\`\\\\w\""),
                "every character a POSIX double-quoted string would read is escaped")
        #expect(MCPPaneCopy.setupCommand(shimPath: "/x", isDebugBuild: true)
                    .hasPrefix("claude mcp add -s user variorum-dev -- "),
                "a dev setup never replaces the real registration")
    }

    @Test func theDoorCopiesTheCommandAndSaysSo() throws {
        let door = MCPDoor(serverAllowed: false)
        let pasteboard = NSPasteboard(name: NSPasteboard.Name("variorum-mcp-pane-test-\(UUID().uuidString)"))
        defer { pasteboard.releaseGlobally() }
        door.copySetupCommand(to: pasteboard)
        #expect(pasteboard.string(forType: .string) == door.setupCommand)
        #expect(door.setupCommand.contains("variorum-dev"), "the test host is the Debug build")
        #expect(door.setupCommand.contains("/Contents/MacOS/variorum-mcp"))
        #expect(door.note == MCPDoor.Note(text: MCPPaneCopy.copiedReceipt, place: .connect),
                "the receipt sits under its button, never below the fold")
    }

    /// The walk's fourth finding (P-2): "while connected" only while the
    /// client is connected — to a client that is not, it could not act as named.
    @Test func whileConnectedIsOfferedOnlyWhileTheClientIsConnected() {
        #expect(MCPGrantSheet.durations(connected: true) == [.once, .connection, .always])
        #expect(MCPGrantSheet.durations(connected: false) == [.once, .always])
    }

    // MARK: - Declarations (P-1)

    @Test func thePanesDoorsAreDeclaredSurfaceOnlyWithHerVerb() {
        for id in MCPPane.surfaceCapabilities {
            let capability = CapabilityRegistry.capability(id)
            #expect(capability.doors == [.surface], "\(id) is decided where the grants are shown")
            #expect(!capability.verb.isEmpty)
        }
        #expect(CapabilityRegistry.capability(.mcpCopySetupCommand).verb == "Copy setup command",
                "R-13nb-5, her words")
        #expect(CapabilityRegistry.capability(.mcpApproveClient).verb == "Approve\u{2026}")
        #expect(CapabilityRegistry.capability(.mcpDenyClient).verb == "Deny")
    }

    @Test func thePaneSitsBesideTagsAndItsRowsAreSearchable() throws {
        let panes = SettingsPane.allCases
        let index = try #require(panes.firstIndex(of: .mcp))
        #expect(panes[index - 1] == .tags)
        #expect(panes[index + 1] == .protection)
        #expect(SettingsPane.mcp.title == "MCP", "R-13n-5 named it")
        #expect(AppSettingsView.rowIDsRendered[.mcp] == ["mcpServer", "mcpOpenBook"])
        #expect(SettingsCatalog.title("mcpServer") == "Enable the MCP server")
        for word in ["mcp", "claude", "claude code", "open book"] {
            #expect(SettingsSearch.findings(matching: word, in: SettingsSearch.settingsEntries)
                        .contains { $0.pane == .mcp }, "“\(word)” finds the MCP pane")
        }
    }

    // MARK: - The lifecycle (A-8)

    @Test func aTestProcessNeverServesEvenWithTheToggleOn() async throws {
        try await withDoorWorld { (session: AppSession, _: AppDatabase) async throws in
            let door = MCPDoor()  // the production default: never in a test process
            door.attach(session: session)
            defer { door.detach() }
            door.setEnabled(true)
            #expect(try await settle { door.snapshot.enabled })
            #expect(door.serverState == .waitingForLibrary)
        }
    }

    @Test func theDoorServesOnlyWhileAttachedAndOnAndUnlinksItsSocket() async throws {
        try await withDoorWorld { (session: AppSession, db: AppDatabase) async throws in
            let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent("vpane-\(UUID().uuidString.prefix(8))", isDirectory: true)
            defer { try? FileManager.default.removeItem(at: directory) }
            let operations = Operations()
            let door = MCPDoor(serverAllowed: true) { database in
                MCPServerHost(database: database, operations: operations, directory: directory, version: "test")
            }
            let socket = MCPSocketRoad.socketPath(directory: directory)
            door.attach(session: session)
            #expect(try await settle { door.snapshot == MCPDoor.Snapshot() })
            #expect(door.serverState == .off, "OFF is the shipped default")
            #expect(!FileManager.default.fileExists(atPath: socket))

            door.setEnabled(true)
            #expect(try await settle { door.serverState == .running })
            #expect(FileManager.default.fileExists(atPath: socket))
            if case .success(let fd) = MCPSocketRoad.connect(directory: directory) { close(fd) } else {
                Issue.record("the running door answers on its socket")
            }
            // The same ready re-appearing (a window's `.task` again) is a
            // no-op: the server keeps serving.
            door.attach(session: session)
            #expect(door.serverState == .running)
            #expect(FileManager.default.fileExists(atPath: socket), "re-attaching the same session keeps the door open")

            door.setEnabled(false)
            #expect(try await settle { door.serverState == .off })
            #expect(!FileManager.default.fileExists(atPath: socket), "the toggle OFF unlinks the socket")

            door.setEnabled(true)
            #expect(try await settle { door.serverState == .running })
            door.detach()   // the lock / quit road
            #expect(!FileManager.default.fileExists(atPath: socket), "the socket dies with the store's session")
            #expect(door.serverState == .waitingForLibrary)
            #expect(try await db.read { try Queries.mcpSwitch($0, .server) }, "detaching never flips her toggle")
        }
    }

    /// 13n-b U2 — ledger row 10, R-13nb-6: an ADOPTED library (a 13x restore
    /// hold beside its store) lands with the server OFF before it could ever
    /// serve, grants kept; her re-enable then serves.
    @Test func anAdoptedLibraryLandsOffBeforeItCouldServeAndHerReEnableServes() async throws {
        try await withDoorWorld { (session: AppSession, db: AppDatabase) async throws in
            let root = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent("vadopt-\(UUID().uuidString.prefix(8))", isDirectory: true)
            defer { try? FileManager.default.removeItem(at: root) }
            try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
            let storeURL = root.appendingPathComponent("variorum.sqlite", isDirectory: false)
            try LibraryRestoreHold.set(besideStore: storeURL, asOf: nil, now: Date())
            let operations = Operations()
            let client = try operations.recordMCPContact(name: "claude-code", version: nil)
            try operations.approveMCPClient(client.id, granting: nil)
            try operations.setMCPSwitch(.server, on: true)   // the copy arrived ON

            let directory = root.appendingPathComponent("sock", isDirectory: true)
            let socket = MCPSocketRoad.socketPath(directory: directory)
            var started = 0
            let door = MCPDoor(serverAllowed: true) { database in
                started += 1
                return MCPServerHost(database: database, operations: operations, directory: directory, version: "test")
            }
            door.attach(session: session, storeURL: storeURL)
            defer { door.detach() }
            #expect(try await settle { door.serverState == .off && door.snapshot.clientCount == 1 })
            #expect(started == 0, "the adopted library never started a server before its OFF write")
            #expect(!FileManager.default.fileExists(atPath: socket))
            #expect(try await db.read { try Queries.mcpSwitch($0, .server) } == false)
            #expect(door.snapshot.clients.first?.client.state == .approved, "clients and grants kept as data")

            door.setEnabled(true)   // her deliberate re-enable
            #expect(try await settle { door.serverState == .running })
            #expect(FileManager.default.fileExists(atPath: socket))
        }
    }

    // MARK: - The lists stay legible (R-13n-10)

    @Test func theSnapshotCapsEachListAndCountsTheRest() async throws {
        try await withDoorWorld { (session: AppSession, db: AppDatabase) async throws in
            let operations = Operations()
            for index in 0..<7 { try operations.recordMCPContact(name: "client-\(index)", version: nil) }
            let approved = try operations.recordMCPContact(name: "claude-code", version: "2.1")
            try operations.approveMCPClient(approved.id, granting: nil)
            for index in 0..<8 {
                let book = try operations.createReading(name: "book \(index)", kind: .book)
                _ = try operations.grantMCPAccess(
                    approved.id, .init(rung: .read, scopeKind: .book, scopeID: book.id, duration: .always))
            }
            let snapshot = try await db.read { try MCPDoor.read($0) }
            #expect(snapshot.pending.count == MCPDoor.pendingCap && snapshot.pendingCount == 7)
            #expect(snapshot.clients.map(\.client.name) == ["claude-code"] && snapshot.clientCount == 1)
            #expect(snapshot.clients.first?.liveGrantCount == 8)
            #expect(snapshot.shared.count == MCPDoor.sharedCap && snapshot.sharedCount == 8)
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            #expect(try await settle { door.snapshot.sharedCount == 8 })
            #expect(await door.allShared().count == 8, "the all-N road reaches every row")
            #expect(await door.allPending().count == 7)
        }
    }

    @Test func approveFromThePaneGrantsInOneActAndRevokeDenies() async throws {
        try await withDoorWorld { (session: AppSession, db: AppDatabase) async throws in
            let operations = Operations()
            let request = try operations.recordMCPContact(name: "claude-code", version: nil)
            let book = try operations.createReading(name: "the lightning thief", kind: .book)
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            #expect(try await settle { door.snapshot.pendingCount == 1 })
            let choices = await door.choices()
            #expect(choices.books.map(\.id) == [book.id])
            #expect(choices.wings.first?.id == "" && choices.wings.first?.name == "Home")
            door.approve(request.id, granting: .init(rung: .read, scopeKind: .book, scopeID: book.id, duration: .connection))
            #expect(try await settle { door.snapshot.pendingCount == 0 && door.snapshot.sharedCount == 1 })
            #expect(door.snapshot.clients.first?.client.state == .approved)
            #expect(door.snapshot.shared.first?.targetTitle == "the lightning thief")
            door.deny(request.id)
            #expect(try await settle { door.snapshot.sharedCount == 0 })
            #expect(try await db.read { try Queries.mcpClient($0, id: request.id) }?.state == .denied)
        }
    }
}
