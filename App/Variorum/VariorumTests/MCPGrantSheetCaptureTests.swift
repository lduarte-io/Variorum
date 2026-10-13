//
//  MCPGrantSheetCaptureTests.swift
//  VariorumTests (Mac)
//
//  13n-c U1 — A CAPTURE HARNESS (the VX-144 precedent), gated OFF: the REAL
//  grant sheet rendered offscreen in both voices, so VX-269's confirm can be
//  SEEN whole when no walk can run (the U1 pre-flight walk met a locked
//  session at 04:00 — unlocking is hers, never a session's). The images are
//  printed as base64 chunks into the run's log (the test host's container is
//  not read from outside) under `[13NC-U1-PNG <name> <part>]`.
//
//  To re-shoot: `TEST_RUNNER_VARIORUM_CAPTURE=13nc-u1 xcodebuild … test
//  -only-testing:VariorumTests/MCPGrantSheetCaptureTests` under a held stage.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite(
    "13n-c U1 — the grant sheet's confirm, captured (a harness)", .serialized,
    .enabled(if: ProcessInfo.processInfo.environment["VARIORUM_CAPTURE"] == "13nc-u1"))
struct MCPGrantSheetCaptureTests {
    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func withWorld(_ body: @MainActor (AppSession) async throws -> Void) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { Date(timeIntervalSince1970: 1_782_864_000) }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 163))
        } operation: { @MainActor in
            try await body(AppSession(database: db))
        }
    }

    private func startedTheme(_ session: AppSession, voice: ThemeVoice) async throws -> (ThemeStore, Task<Void, Never>) {
        try session.operations.setThemeVoice(voice)
        let theme = ThemeStore(session: session)
        let task = Task { await theme.start() }
        for _ in 0..<100 where theme.settings.voice != voice {
            pump(0.02)
            await Task.yield()
        }
        return (theme, task)
    }

    private func capture<V: View>(_ view: V, size: NSSize, name: String) async {
        let window = NSWindow(
            contentRect: NSRect(origin: NSPoint(x: 40, y: 40), size: size),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.appearance = NSAppearance(named: .aqua)
        defer {
            window.orderOut(nil)
            window.close()
        }
        let hosting = NSHostingView(rootView: view.environment(\.colorScheme, .light))
        hosting.appearance = window.appearance
        hosting.frame = NSRect(origin: .zero, size: size)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        for _ in 0..<40 {
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
            print("[13NC-U1-PNG \(name) \(part)] \(encoded[index..<end])")
            index = end
            part += 1
        }
        print("[13NC-U1-PNG-END \(name) \(part)]")
    }

    /// Settings ▸ MCP itself: a journal-TRAIT book granted (VX-163 — the op
    /// refused it before) listed under Shared, and the open book on with its
    /// re-keyed sentence.
    @Test func captureThePaneWithATraitBookSharedAndTheOpenBookOn() async throws {
        for voice in [ThemeVoice.study, .terminal] {
            try await withWorld { session in
                let ops = session.operations
                let trait = try ops.createReading(name: "dream journal", kind: .book, profile: "journal")
                let contact = try ops.recordMCPContact(name: "claude-code", version: "2")
                try ops.approveMCPClient(contact.id, granting: .init(
                    rung: .read, scopeKind: .book, scopeID: trait.id, duration: .always))
                try ops.setMCPSwitch(.openBook, on: true)
                let door = MCPDoor(serverAllowed: false)
                door.attach(session: session)
                defer { door.detach() }
                let (theme, task) = try await startedTheme(session, voice: voice)
                defer { task.cancel() }
                for _ in 0..<100 where !door.snapshot.openBook {
                    pump(0.02)
                    await Task.yield()
                }
                #expect(door.snapshot.openBook, "the snapshot the pane draws reads the open book ON")
                await capture(
                    MCPPane(door: door).environment(theme),
                    size: NSSize(width: 524, height: 980),
                    name: "u1-pane-\(voice == .study ? "study" : "terminal").png")
            }
        }
    }

    /// The sheet as Change… opens it on an approved, connected client: WHERE =
    /// a book (the first offered, a–z), read, always — so the confirm is her
    /// example ("dream journal") or a long name, whole or not.
    @Test func captureTheGrantSheetInBothVoices() async throws {
        for voice in [ThemeVoice.study, .terminal] {
            for first in ["dream journal", "the adventures of sherlock holmes"] {
                try await withWorld { session in
                    let ops = session.operations
                    // A journal-TRAIT book is offered since VX-163.
                    _ = try ops.createReading(
                        name: first, kind: .book, profile: first == "dream journal" ? "journal" : nil)
                    _ = try ops.createReading(name: "zz other", kind: .book)
                    let contact = try ops.recordMCPContact(name: "claude-code", version: "2")
                    try ops.approveMCPClient(contact.id, granting: nil)
                    let client = try #require(try await session.database.read { try Queries.mcpClient($0, id: contact.id) })
                    let door = MCPDoor(serverAllowed: false)
                    door.attach(session: session)
                    defer { door.detach() }
                    let (theme, task) = try await startedTheme(session, voice: voice)
                    defer { task.cancel() }
                    let tag = "\(voice == .study ? "study" : "terminal")-\(first == "dream journal" ? "dream" : "long")"
                    // 13n-c U2 (the opener API — `MCPGrantOpening`; "connected"
                    // is read from the door live, so the DEBUG seam marks it —
                    // after the snapshot lands, whose reconcile clears it).
                    for _ in 0..<100 where door.snapshot.clientCount < 1 {
                        pump(0.02)
                        await Task.yield()
                    }
                    door.previewConnected([client.name])
                    await capture(
                        MCPGrantSheet(door: door, opening: MCPGrantOpening(client: client), done: {})
                            .environment(theme),
                        size: NSSize(width: 600, height: 560), name: "u1-sheet-\(tag).png")
                }
            }
        }
    }
}
