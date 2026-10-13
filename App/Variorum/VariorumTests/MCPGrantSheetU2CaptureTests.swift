//
//  MCPGrantSheetU2CaptureTests.swift
//  VariorumTests (Mac)
//
//  13n-c U2 — A CAPTURE HARNESS (U1's and VX-144's precedent), gated OFF: the
//  REAL rebuilt grant sheet, the open picker's panel (`SearchPickerPanel` — a
//  popover is another window, so the panel is drawn directly, with the query
//  and layout it would hold), the pane and the ask sheet, rendered offscreen
//  in both voices over a seeded in-memory library — for when no walk can run
//  (the session was LOCKED at U2's walk; unlocking is hers). These are NOT a
//  walk and the record never calls them one. Images print as base64 chunks
//  under `[13NC-U2-PNG <name> <part>]`.
//
//  To re-shoot: `TEST_RUNNER_VARIORUM_CAPTURE=13nc-u2 xcodebuild … test
//  -only-testing:VariorumTests/MCPGrantSheetU2CaptureTests` under a held stage.
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
    "13n-c U2 — the rebuilt grant road, captured (a harness)", .serialized,
    .enabled(if: ProcessInfo.processInfo.environment["VARIORUM_CAPTURE"] == "13nc-u2"))
struct MCPGrantSheetU2CaptureTests {
    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func withWorld(_ body: @MainActor (AppSession) async throws -> Void) async throws {
        let db = try AppDatabase.inMemory()
        // An hour per read, from 2026-10-01 — so made stamps differ by day
        // where the fixture says so and last-edited orders are real.
        let start = Date(timeIntervalSince1970: 1_790_812_800)
        let tick = LockIsolated(0)
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator {
                let hours = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(hours) * 600)
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 165))
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
        for _ in 0..<50 {
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
            print("[13NC-U2-PNG \(name) \(part)] \(encoded[index..<end])")
            index = end
            part += 1
        }
        print("[13NC-U2-PNG-END \(name) \(part)]")
    }

    /// The seeded library: four shelves and a second wing, two books called
    /// "the adventures of sherlock holmes" (made two days apart), starred
    /// books, a journal-TRAIT book, a Private note, a ⌘J-shaped day entry,
    /// two approved clients, and a grant made inert by a Private mark.
    private struct World {
        let claude: MCPClient
        let sherlockA: Reading
        let sherlockB: Reading
        let privateNote: Container
        let dayEntry: Container
    }

    private func seed(_ session: AppSession) throws -> World {
        let ops = session.operations
        let welcome = try ops.createShelf(name: "Welcome")
        try ops.setShelfGlyph(welcome.id, glyph: "\u{2726}")
        let research = try ops.createShelf(name: "research")
        let essays = try ops.createShelf(name: "essays")
        let translations = try ops.createShelf(name: "translations")
        func shelve(_ name: String, _ shelf: Shelf?, starred: Bool = false, profile: String? = nil,
                    notes: [String] = []) throws -> Reading {
            let book = try ops.createReading(name: name, kind: .book, profile: profile)
            if let shelf { try ops.setReadingShelf(book.id, shelf: shelf.id) }
            if starred { try ops.setStarred(.reading(book.id), starred: true) }
            for title in notes {
                let post = try ops.createPost(title: title)
                _ = try ops.newBlock(in: post.id, text: "\(title) — the opening lines.", registeringUndo: false)
                _ = try ops.addPostToReading(post.id, to: book.id)
            }
            return book
        }
        let sherlockA = try shelve("the adventures of sherlock holmes", welcome,
                                   notes: ["a scandal in bohemia", "the red-headed league"])
        _ = try ops.setReadingOwned(sherlockA.id, owned: true)
        _ = try shelve("a letter", research, starred: true, notes: ["dear m."])
        _ = try shelve("sherlock reading notes", research, notes: ["on deduction"])
        _ = try shelve("parser essays", essays, starred: true, notes: ["tokens", "grammar sketch"])
        _ = try shelve("o ladrão de raios", translations, notes: ["capítulo 1"])
        _ = try shelve("dream journal", nil, profile: "journal", notes: ["the lighthouse dream"])
        _ = try shelve("Book 9", essays)
        _ = try shelve("Book 10", essays)
        let gone = try shelve("old private", research, notes: ["kept close"])
        // Two days later: the second sherlock (the sample library restored again).
        let sherlockB = try withDependencies {
            $0.date = .constant(Date(timeIntervalSince1970: 1_790_812_800 + 2 * 86_400 + 3_600))
        } operation: {
            try Operations().createReading(name: "the adventures of sherlock holmes", kind: .book)
        }
        try ops.setReadingShelf(sherlockB.id, shelf: welcome.id)
        _ = try ops.setReadingOwned(sherlockB.id, owned: true)
        let wing = try ops.createWing(name: "variorum")
        let worksheets = try ops.createShelf(name: "worksheets", wingID: wing.id)
        let percy = try ops.createReading(name: "percy worksheets", kind: .book, wingId: wing.id)
        try ops.setReadingShelf(percy.id, shelf: worksheets.id)

        let privateNote = try ops.createPost(title: "parser secrets")
        _ = try ops.newBlock(in: privateNote.id, text: "the part I'm not ready to share.", registeringUndo: false)
        _ = try ops.setNotePrivate(privateNote.id, true)
        let dayEntry = try ops.createPost(title: "morning pages \u{2014} oct 9", profile: .journal)
        _ = try ops.newBlock(in: dayEntry.id, text: "woke early and thought about the parser again.", registeringUndo: false)

        let claude = try ops.recordMCPContact(name: "claude-code", version: "2")
        try ops.approveMCPClient(claude.id, granting: .init(
            rung: .read, scopeKind: .book, scopeID: sherlockA.id, duration: .always))
        _ = try ops.grantMCPAccess(claude.id, .init(rung: .suggest, scopeKind: .book, scopeID: sherlockB.id, duration: .connection))
        _ = try ops.grantMCPAccess(claude.id, .init(rung: .read, scopeKind: .book, scopeID: gone.id, duration: .always))
        _ = try ops.setBookPrivate(gone.id, true)   // R2-3: the grant is inert now
        let codex = try ops.recordMCPContact(name: "codex", version: "1")
        try ops.approveMCPClient(codex.id, granting: nil)
        let claudeNow = try #require(try session.database.read { try Queries.mcpClient($0, id: claude.id) })
        return World(claude: claudeNow, sherlockA: sherlockA, sherlockB: sherlockB,
                     privateNote: privateNote, dayEntry: dayEntry)
    }

    private func voiceName(_ voice: ThemeVoice) -> String { voice == .study ? "study" : "terminal" }

    @Test func captureTheSheetThePickerThePaneAndTheAsk() async throws {
        for voice in [ThemeVoice.study, .terminal] {
            try await withWorld { session in
                let world = try seed(session)
                let door = MCPDoor(serverAllowed: false)
                door.attach(session: session)
                defer { door.detach() }
                // The door's own reconcile clears `connected` whenever the
                // server is off — so the seam marks it AFTER the snapshot lands.
                for _ in 0..<100 where door.snapshot.sharedCount < 3 {
                    pump(0.02)
                    await Task.yield()
                }
                door.previewConnected(["claude-code"])
                let (theme, task) = try await startedTheme(session, voice: voice)
                defer { task.cancel() }
                let tokens = theme.tokens(for: .light)
                let v = voiceName(voice)

                // 1 — opened from a place (U3's road): WHO shown, a same-named
                // book pre-filled — its distinguisher in WHERE and the confirm.
                await capture(
                    MCPGrantSheet(door: door, opening: MCPGrantOpening(place: .book(world.sherlockB.id)), done: {})
                        .environment(theme),
                    size: NSSize(width: 600, height: 620), name: "u2-sheet-\(v)-who-book.png")

                // 2–4 — the open book picker: resting (Recently edited ·
                // Starred · shelves · Unshelved), typed "sherl", and a–z.
                let places = await door.grantPlaces()
                let layouts = MCPGrantPicker.bookArrangements(places, now: Date())
                for (query, layout, tag) in [("", "shelf", "resting"), ("sherl", "shelf", "typed"), ("", "az", "az")] {
                    await capture(
                        SearchPickerPanel(
                            tokens: tokens, prompt: MCPPaneCopy.bookPrompt, emptyText: MCPPaneCopy.noBooks,
                            arrangements: layouts, width: 480, initialQuery: query,
                            initialArrangementID: layout, onPick: { _ in }, onClose: {})
                            .environment(theme),
                        size: NSSize(width: 480, height: 420), name: "u2-picker-\(v)-books-\(tag).png")
                }

                // 5 — the note leg on a Private note: once · while connected,
                // and the one-line why.
                await capture(
                    MCPGrantSheet(
                        door: door, opening: MCPGrantOpening(client: world.claude, place: .note(world.privateNote.id)),
                        done: {})
                        .environment(theme),
                    size: NSSize(width: 600, height: 560), name: "u2-sheet-\(v)-fenced-note.png")

                // 6 — the note picker's resting feed (fence-marked rows).
                await capture(
                    SearchPickerPanel(
                        tokens: tokens, prompt: MCPPaneCopy.notePrompt, emptyText: MCPPaneCopy.noNotes,
                        source: { query in
                            MCPGrantPicker.noteSections(await door.grantNotes(query: query, wingID: ""), query: query)
                        },
                        width: 480, onPick: { _ in }, onClose: {})
                        .environment(theme),
                    size: NSSize(width: 480, height: 420), name: "u2-picker-\(v)-notes.png")

                // 7 — the pane: L1 under Clients, Shared places with the
                // distinguished rows and the INERT one (R2-3).
                for _ in 0..<100 where door.snapshot.sharedCount < 3 {
                    pump(0.02)
                    await Task.yield()
                }
                await capture(
                    MCPPane(door: door).environment(theme),
                    size: NSSize(width: 560, height: 1100), name: "u2-pane-\(v).png")

                // 8 — the ask for the second sherlock: its distinguisher and
                // VX-269's reach line (F2).
                let ask = MCPAsk(
                    clientName: "codex", scopeKind: .book, scopeID: world.sherlockB.id,
                    title: world.sherlockB.name, rung: .suggest, fence: nil)
                await capture(
                    MCPAskSheet(door: door, ask: ask).environment(theme),
                    size: NSSize(width: 480, height: 230), name: "u2-ask-\(v).png")
                _ = world.dayEntry
            }
        }
    }
}
