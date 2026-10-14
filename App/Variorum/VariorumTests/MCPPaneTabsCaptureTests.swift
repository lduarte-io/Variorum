//
//  MCPPaneTabsCaptureTests.swift
//  VariorumTests (Mac)
//
//  VX-281 U1 — A CAPTURE HARNESS (13n-c's precedent), gated OFF: Settings ▸
//  MCP in tabs rendered offscreen-of-the-walk over a seeded in-memory library
//  — the WHOLE Settings content (748×520, VX-214's window) at the MCP pane,
//  each tab, both voices, light and dark; the code block with a receipt; the
//  grant sheet on the edit rung. NOT a walk and the record never calls it one:
//  no press, no hover, no popover — only what the faces draw. Images print as
//  base64 chunks under `[VX281-U1-PNG <name> <part>]`.
//
//  To re-shoot: `TEST_RUNNER_VARIORUM_CAPTURE=vx281-u1 xcodebuild … test
//  -only-testing:VariorumTests/MCPPaneTabsCaptureTests` under a held stage.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
import VariorumMCP
@testable import Variorum

@MainActor
@Suite(
    "VX-281 U1 — Settings ▸ MCP in tabs, captured (a harness)", .serialized,
    .enabled(if: ProcessInfo.processInfo.environment["VARIORUM_CAPTURE"] == "vx281-u1"))
struct MCPPaneTabsCaptureTests {
    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func withWorld(_ body: @MainActor (AppSession, AppDatabase) async throws -> Void) async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_790_812_800)
        let tick = LockIsolated(0)
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator {
                let steps = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(steps) * 600)
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 281))
        } operation: { @MainActor in
            try await body(AppSession(database: db), db)
        }
    }

    private func startedTheme(_ session: AppSession) async -> (ThemeStore, Task<Void, Never>) {
        let theme = ThemeStore(session: session)
        let task = Task { await theme.start() }
        for _ in 0..<60 {
            pump(0.02)
            await Task.yield()
        }
        return (theme, task)
    }

    private func capture<V: View>(_ view: V, size: NSSize, dark: Bool, name: String, settle: Int = 60) async {
        let window = NSWindow(
            contentRect: NSRect(origin: NSPoint(x: 40, y: 40), size: size),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.appearance = NSAppearance(named: dark ? .darkAqua : .aqua)
        defer {
            window.orderOut(nil)
            window.close()
        }
        let hosting = NSHostingView(rootView: view.environment(\.colorScheme, dark ? .dark : .light))
        hosting.appearance = window.appearance
        hosting.frame = NSRect(origin: .zero, size: size)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        for _ in 0..<settle {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump(0.02)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
        guard let rep = hosting.bitmapImageRepForCachingDisplay(in: hosting.bounds) else {
            Issue.record("no bitmap for \(name)")
            return
        }
        hosting.cacheDisplay(in: hosting.bounds, to: rep)
        guard let png = rep.representation(using: .png, properties: [:]) else { return }
        let encoded = png.base64EncodedString()
        var index = encoded.startIndex
        var part = 0
        while index < encoded.endIndex {
            let end = encoded.index(index, offsetBy: 8_000, limitedBy: encoded.endIndex) ?? encoded.endIndex
            print("[VX281-U1-PNG \(name) \(part)] \(encoded[index..<end])")
            index = end
            part += 1
        }
        print("[VX281-U1-PNG-END \(name) \(part)]")
    }

    private struct World {
        let thief: Reading
        let parser: Container
        let claude: MCPClient
    }

    /// Two approved clients with grants of every kind, a pending request,
    /// activity lines, the server ON.
    private func seed(_ session: AppSession, _ db: AppDatabase) async throws -> World {
        let ops = session.operations
        let welcome = try ops.createShelf(name: "Welcome")
        let thief = try ops.createReading(name: "the lightning thief", kind: .book)
        try ops.setReadingShelf(thief.id, shelf: welcome.id)
        let parser = try ops.createPost(title: "parser notes")
        _ = try ops.newBlock(in: parser.id, text: "parser notes — the text.", registeringUndo: false)
        _ = try ops.addPostToReading(parser.id, to: thief.id)
        let letter = try ops.createPost(title: "a letter")
        _ = try ops.newBlock(in: letter.id, text: "a letter — the text.", registeringUndo: false)
        let claude = try ops.recordMCPContact(name: "claude-code", version: "2")
        try ops.approveMCPClient(claude.id, granting: .init(
            rung: .suggest, scopeKind: .book, scopeID: thief.id, duration: .always))
        _ = try ops.grantMCPAccess(claude.id, .init(rung: .edit, scopeKind: .note, scopeID: letter.id, duration: .once))
        let cursor = try ops.recordMCPContact(name: "cursor", version: "1")
        try ops.approveMCPClient(cursor.id, granting: .init(
            rung: .read, scopeKind: .wing, scopeID: "", duration: .always))
        _ = try ops.recordMCPContact(name: "codex", version: "0.4")
        try ops.setMCPSwitch(.server, on: true)
        let operations = Operations()
        try await db.write { db in
            for (act, title) in [("read_note", "parser notes"), ("add_take", "parser notes"),
                                 ("edit_take", "a letter"), ("list_books", nil)] {
                try operations.recordMCPActivity(
                    db, clientName: "claude-code", act: act, targetKind: title == nil ? nil : "note",
                    targetID: title, targetTitle: title, allowed: true)
            }
        }
        return World(thief: thief, parser: parser, claude: claude)
    }

    private func voiceName(_ voice: ThemeVoice) -> String { voice == .study ? "study" : "terminal" }

    @Test func captureThePaneInTabs() async throws {
        let size = AppSettingsView.contentSize
        for voice in [ThemeVoice.study, .terminal] {
            let v = voiceName(voice)

            // 1 — A FRESH PANE (no client approved): it opens on Connect.
            for dark in [false, true] {
                try await withWorld { session, _ in
                    try session.operations.setThemeVoice(voice)
                    let door = MCPDoor(serverAllowed: false)
                    door.attach(session: session)
                    defer { door.detach() }
                    door.requestSettings()
                    await capture(
                        AppSettingsView(session: session, mcp: door), size: size, dark: dark,
                        name: "u1-fresh-connect-\(v)\(dark ? "-dark" : "").png")
                }
            }

            // 2 — A PANE IN USE: each tab; a request and two asks above them.
            for tab in MCPPaneTab.allCases {
                try await withWorld { session, db in
                    try session.operations.setThemeVoice(voice)
                    let world = try await seed(session, db)
                    let door = MCPDoor(serverAllowed: false)
                    door.attach(session: session)
                    defer { door.detach() }
                    for _ in 0..<100 where door.snapshot.clientCount < 2 {
                        pump(0.02)
                        await Task.yield()
                    }
                    if tab == .connect {
                        // The Any MCP client's stanza, copied — its receipt.
                        let pasteboard = NSPasteboard(name: NSPasteboard.Name("vx281-capture-\(UUID().uuidString)"))
                        defer { pasteboard.releaseGlobally() }
                        await door.copySetupCommand(for: .anyClient, to: pasteboard)
                    }
                    door.paneTab = tab
                    door.enqueue(MCPAsk(clientName: "claude-code", scopeKind: .note, scopeID: world.parser.id,
                                        title: "parser notes", rung: .edit, fence: nil),
                                 now: Date().addingTimeInterval(-300))
                    door.enqueue(MCPAsk(clientName: "cursor", scopeKind: .book, scopeID: world.thief.id,
                                        title: "the lightning thief", rung: .suggest, fence: nil),
                                 now: Date().addingTimeInterval(-60))
                    await capture(
                        AppSettingsView(session: session, mcp: door), size: size, dark: false,
                        name: "u1-\(tab.rawValue)-\(v).png", settle: 80)
                    if tab == .clients {
                        // The same tab with nothing waiting (the common case).
                        let quiet = MCPDoor(serverAllowed: false)
                        quiet.attach(session: session)
                        defer { quiet.detach() }
                        quiet.paneTab = .clients
                        await capture(
                            AppSettingsView(session: session, mcp: quiet), size: size, dark: false,
                            name: "u1-clients-nothing-waiting-\(v).png", settle: 80)
                    }
                }
            }

            // 3 — THE GRANT SHEET on the edit rung (HOW MUCH's one line + (i)).
            try await withWorld { session, db in
                try session.operations.setThemeVoice(voice)
                let world = try await seed(session, db)
                let door = MCPDoor(serverAllowed: false)
                door.attach(session: session)
                defer { door.detach() }
                let (theme, task) = await startedTheme(session)
                defer { task.cancel() }
                await capture(
                    MCPGrantSheet(
                        door: door,
                        opening: MCPGrantOpening(client: world.claude, place: .book(world.thief.id), rung: .edit),
                        done: {})
                        .environment(theme),
                    size: NSSize(width: 600, height: 560), dark: false, name: "u1-grant-sheet-edit-\(v).png")
            }
        }
    }
}
