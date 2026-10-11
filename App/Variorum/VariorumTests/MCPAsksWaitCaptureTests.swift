//
//  MCPAsksWaitCaptureTests.swift
//  VariorumTests (Mac)
//
//  13n-c U4 — A CAPTURE HARNESS (U1–U3's precedent), gated OFF: the REAL faces
//  of "asks wait quietly + the keyboard" rendered offscreen in both voices
//  over a seeded in-memory library with asks waiting — for when no walk can
//  run (the session was LOCKED at U4's walk; unlocking is hers). These are
//  NOT a walk and the record never calls them one: no press, no hover, no
//  held key, no menu, no sheet presentation is exercised here — only what the
//  faces draw. Images print as base64 chunks under `[13NC-U4-PNG <name>
//  <part>]`.
//
//  To re-shoot: `TEST_RUNNER_VARIORUM_CAPTURE=13nc-u4 xcodebuild … test
//  -only-testing:VariorumTests/MCPAsksWaitCaptureTests` under a held stage.
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
    "13n-c U4 — asks wait + the keyboard, captured (a harness)", .serialized,
    .enabled(if: ProcessInfo.processInfo.environment["VARIORUM_CAPTURE"] == "13nc-u4"))
struct MCPAsksWaitCaptureTests {
    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func withWorld(_ body: @MainActor (AppSession) async throws -> Void) async throws {
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 167))
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

    private func capture<V: View>(_ view: V, size: NSSize, name: String, settle: Int = 50) async {
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
            print("[13NC-U4-PNG \(name) \(part)] \(encoded[index..<end])")
            index = end
            part += 1
        }
        print("[13NC-U4-PNG-END \(name) \(part)]")
    }

    private struct World {
        let thief: Reading
        let parser: Container
        let variorum: Wing
    }

    /// Two wings (Home + "variorum"), books on two shelves, notes, one
    /// approved client with a grant, the server ON.
    private func seed(_ session: AppSession) throws -> World {
        let ops = session.operations
        let welcome = try ops.createShelf(name: "Welcome")
        let research = try ops.createShelf(name: "research")
        func shelve(_ name: String, _ shelf: Shelf) throws -> Reading {
            let book = try ops.createReading(name: name, kind: .book)
            try ops.setReadingShelf(book.id, shelf: shelf.id)
            return book
        }
        let thief = try shelve("the lightning thief", welcome)
        _ = try shelve("o ladrão de raios", welcome)
        _ = try shelve("dream journal", research)
        func note(_ title: String, in book: Reading? = nil) throws -> Container {
            let post = try ops.createPost(title: title)
            _ = try ops.newBlock(in: post.id, text: "\(title) — the text.", registeringUndo: false)
            if let book { _ = try ops.addPostToReading(post.id, to: book.id) }
            return post
        }
        let parser = try note("parser notes", in: thief)
        _ = try note("grammar sketch")
        _ = try note("a letter")
        let variorum = try ops.createWing(name: "variorum")
        let claude = try ops.recordMCPContact(name: "claude-code", version: "2")
        try ops.approveMCPClient(claude.id, granting: .init(
            rung: .read, scopeKind: .book, scopeID: thief.id, duration: .always))
        let cursor = try ops.recordMCPContact(name: "cursor", version: "1")
        try ops.approveMCPClient(cursor.id, granting: nil)
        try ops.setMCPSwitch(.server, on: true)
        return World(thief: thief, parser: parser, variorum: variorum)
    }

    private func road(_ door: MCPDoor, theme: ThemeStore) -> MCPShareRoad {
        MCPShareRoad(
            canShare: true, indicatorOn: true, open: { _ in },
            sheet: { opening, done in
                AnyView(MCPGrantSheet(door: door, opening: opening, done: done).environment(theme))
            },
            revoke: { _ in })
    }

    private func voiceName(_ voice: ThemeVoice) -> String { voice == .study ? "study" : "terminal" }

    @Test func captureTheAsksAndTheKeyboard() async throws {
        for voice in [ThemeVoice.study, .terminal] {
            try await withWorld { session in
                let world = try seed(session)
                let door = MCPDoor(serverAllowed: false)
                door.attach(session: session)
                defer { door.detach() }
                for _ in 0..<100 where !door.hasApprovedClient {
                    pump(0.02)
                    await Task.yield()
                }
                // FOUR ASKS WAIT (arrival X — nothing presented them): a note
                // ask from two clients, a book ask, a wing ask.
                let now = Date()
                door.enqueue(MCPAsk(clientName: "claude-code", scopeKind: .note, scopeID: world.parser.id,
                                    title: "parser notes", rung: .suggest, fence: nil),
                             now: now.addingTimeInterval(-300))
                door.enqueue(MCPAsk(clientName: "cursor", scopeKind: .note, scopeID: world.parser.id,
                                    title: "parser notes", rung: .read, fence: nil),
                             now: now.addingTimeInterval(-240))
                let bookAsk = MCPAsk(clientName: "claude-code", scopeKind: .book, scopeID: world.thief.id,
                                     title: "the lightning thief", rung: .writeNew, fence: nil)
                door.enqueue(bookAsk, now: now.addingTimeInterval(-120))
                door.enqueue(MCPAsk(clientName: "claude-code", scopeKind: .wing, scopeID: world.variorum.id,
                                    title: "variorum", rung: .writeNew, fence: nil),
                             now: now.addingTimeInterval(-10))
                let (theme, task) = try await startedTheme(session, voice: voice)
                defer { task.cancel() }
                let tokens = theme.tokens(for: .light)
                let v = voiceName(voice)
                let road = road(door, theme: theme)
                let board = door.askBoard
                let wings = WingsModel(session: session)
                await wings.load()

                // 1 — THE BOOKCASE: the masthead's wing word CYCLES (two wings —
                // "· Home" + its ▾), the wing ask's glyph beside it, the book
                // ask's glyph on its row.
                let shelf = ShelfViewModel(session: session)
                shelf.censusOpen = false
                await capture(
                    ShelfView(
                        session: session, model: shelf, readings: ReadingsViewModel(session: session),
                        onOpen: { _ in }, onTodaysEntry: {}, wings: wings)
                        .environment(theme)
                        .environment(\.mcpShareRoad, road)
                        .environment(\.mcpAskBoard, board),
                    size: NSSize(width: 900, height: 360), name: "u4-bookcase-\(v).png", settle: 80)

                // 2 — THE LIBRARY: its masthead now carries the switcher
                // ("Library · Home ▾", round 5) and the asked note's row its glyph.
                let catalog = LibraryCatalogModel(session: session)
                await catalog.search()
                await capture(
                    LibraryCatalogView(
                        session: session, model: catalog, library: LibraryViewModel(session: session),
                        tags: TagsViewModel(session: session), onOpen: { _ in }, wings: wings)
                        .environment(theme)
                        .environment(\.mcpShareRoad, road)
                        .environment(\.mcpAskBoard, board),
                    size: NSSize(width: 1000, height: 420), name: "u4-library-\(v).png", settle: 80)

                // 3 — THE IN-NOTE INDICATOR: the asked note's pending glyph
                // (R-AIR-7's third mark) beside its shared icon.
                await capture(
                    ContextBar(
                        tokens: tokens, originLabel: "Library", forwardLabel: nil, books: [],
                        isNote: true,
                        trailing: AnyView(MCPNoteIndicator(session: session, postID: world.parser.id, tokens: tokens)),
                        onBack: {}, onForward: {}, onOpenBook: { _ in })
                        .environment(theme)
                        .environment(\.mcpShareRoad, road)
                        .environment(\.mcpAskBoard, board),
                    size: NSSize(width: 640, height: 34), name: "u4-indicator-\(v).png", settle: 60)

                // 4 — SETTINGS ▸ MCP ▸ WAITING: newest first, three rows, all 4 ›.
                await capture(
                    MCPPane(door: door).environment(theme),
                    size: NSSize(width: 560, height: 640), name: "u4-pane-\(v).png")

                // 5 — THE ASK'S SHEET (what her press opens): the book ask.
                await capture(
                    MCPAskSheet(door: door, ask: bookAsk).environment(theme),
                    size: NSSize(width: 480, height: 220), name: "u4-ask-sheet-\(v).png")

                // 6 — ⌘L: the switcher, opened (the current wing highlighted),
                // after one held-⌘ L (the next wing), and typed.
                let opened = WingSwitcherModel(wings: wings)
                await capture(
                    WingSwitcherSheet(model: opened, tokens: tokens, close: {})
                        .environment(theme)
                        .environment(\.mcpShareRoad, road)
                        .environment(\.mcpAskBoard, board),
                    size: NSSize(width: 440, height: 260), name: "u4-switcher-open-\(v).png")
                let cycled = WingSwitcherModel(wings: wings)
                cycled.tapL()
                await capture(
                    WingSwitcherSheet(model: cycled, tokens: tokens, close: {})
                        .environment(theme)
                        .environment(\.mcpShareRoad, road)
                        .environment(\.mcpAskBoard, board),
                    size: NSSize(width: 440, height: 260), name: "u4-switcher-cycled-\(v).png")
                let typed = WingSwitcherModel(wings: wings)
                typed.type("vari")
                await capture(
                    WingSwitcherSheet(model: typed, tokens: tokens, close: {})
                        .environment(theme)
                        .environment(\.mcpShareRoad, road)
                        .environment(\.mcpAskBoard, board),
                    size: NSSize(width: 440, height: 260), name: "u4-switcher-typed-\(v).png")

                // 7 — ⌘/ — the helper's Shortcuts tab (the MCP group, ⌘L).
                await capture(
                    HelperView().environment(theme),
                    size: NSSize(width: 680, height: 980), name: "u4-helper-\(v).png", settle: 40)
            }
        }
    }
}
