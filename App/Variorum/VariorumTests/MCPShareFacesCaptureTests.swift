//
//  MCPShareFacesCaptureTests.swift
//  VariorumTests (Mac)
//
//  13n-c U3 — A CAPTURE HARNESS (U1's and U2's precedent), gated OFF: the
//  REAL share faces rendered offscreen in both voices over a seeded in-memory
//  library — for when no walk can run (the session was LOCKED at U3's walk;
//  unlocking is hers). These are NOT a walk and the record never calls them
//  one. A popover is another window, so its CONTENT is drawn directly
//  (`MCPReachPopover`), as U2 drew its picker panel. The icon candidates
//  (R-AIR-6 — 2–3 proposed, the orchestrator picks) are drawn as a labelled
//  sheet of Bookcase-shaped rows. Images print as base64 chunks under
//  `[13NC-U3-PNG <name> <part>]`.
//
//  To re-shoot: `TEST_RUNNER_VARIORUM_CAPTURE=13nc-u3 xcodebuild … test
//  -only-testing:VariorumTests/MCPShareFacesCaptureTests` under a held stage.
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
    "13n-c U3 — the share faces, captured (a harness)", .serialized,
    .enabled(if: ProcessInfo.processInfo.environment["VARIORUM_CAPTURE"] == "13nc-u3"))
struct MCPShareFacesCaptureTests {
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 166))
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
            print("[13NC-U3-PNG \(name) \(part)] \(encoded[index..<end])")
            index = end
            part += 1
        }
        print("[13NC-U3-PNG-END \(name) \(part)]")
    }

    private struct World {
        let claude: MCPClient
        let books: [Reading]
        let parser: Container
        let grammar: Container
        let pages: Container
        let privateNote: Container
        let wingGrant: String
    }

    /// Five books on two shelves (one shared by its own grant, one by the
    /// Home wing grant via codex, one Private), notes, a Private note, two
    /// approved clients, a bulk act of three notes, the server ON.
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
        let ladrao = try shelve("o ladrão de raios", welcome)
        let dream = try shelve("dream journal", research)
        let diary = try shelve("diary", research)
        _ = try ops.setBookPrivate(diary.id, true)
        func note(_ title: String, in book: Reading? = nil) throws -> Container {
            let post = try ops.createPost(title: title)
            _ = try ops.newBlock(in: post.id, text: "\(title) — the text.", registeringUndo: false)
            if let book { _ = try ops.addPostToReading(post.id, to: book.id) }
            return post
        }
        let parser = try note("parser notes", in: thief)
        let grammar = try note("grammar sketch")
        let pages = try note("morning pages \u{2014} oct 9")
        let secret = try note("parser secrets", in: dream)
        _ = try ops.setNotePrivate(secret.id, true)

        let claude = try ops.recordMCPContact(name: "claude-code", version: "2")
        try ops.approveMCPClient(claude.id, granting: .init(
            rung: .suggest, scopeKind: .book, scopeID: thief.id, duration: .always))
        let codex = try ops.recordMCPContact(name: "codex", version: "1")
        try ops.approveMCPClient(codex.id, granting: nil)
        let wingGrant = try ops.grantMCPAccess(
            codex.id, .init(rung: .read, scopeKind: .wing, scopeID: "", duration: .connection))
        _ = try ops.grantMCPAccess(claude.id, notes: [parser.id, grammar.id, pages.id], rung: .read, duration: .once)
        try ops.setMCPSwitch(.server, on: true)
        let claudeNow = try #require(try session.database.read { try Queries.mcpClient($0, id: claude.id) })
        return World(
            claude: claudeNow, books: [thief, ladrao, dream, diary], parser: parser, grammar: grammar,
            pages: pages, privateNote: secret, wingGrant: wingGrant)
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

    @Test func captureTheShareFaces() async throws {
        for voice in [ThemeVoice.study, .terminal] {
            try await withWorld { session in
                let world = try seed(session)
                let door = MCPDoor(serverAllowed: false)
                door.attach(session: session)
                defer { door.detach() }
                for _ in 0..<100 where !door.hasApprovedClient || door.snapshot.sharedCount < 3 {
                    pump(0.02)
                    await Task.yield()
                }
                let (theme, task) = try await startedTheme(session, voice: voice)
                defer { task.cancel() }
                let tokens = theme.tokens(for: .light)
                let v = voiceName(voice)
                let road = road(door, theme: theme)

                // 1 — THE BOOKCASE (the real ShelfView): the ONE icon on the
                // rows a client reaches (a book grant; the Home wing grant),
                // none on the Private book.
                let model = ShelfViewModel(session: session)
                model.censusOpen = false
                await capture(
                    ShelfView(
                        session: session, model: model, readings: ReadingsViewModel(session: session),
                        onOpen: { _ in }, onTodaysEntry: {})
                        .environment(theme)
                        .environment(\.mcpShareRoad, road),
                    size: NSSize(width: 900, height: 420), name: "u3-bookcase-\(v).png", settle: 80)

                // 2 — THE ICON CANDIDATES (R-AIR-6: the orchestrator picks;
                // PROVISIONAL, hers): Bookcase-shaped rows, one per glyph.
                await capture(
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach([
                            ("A (built) — point.3.connected.trianglepath.dotted", MCPSharedIcon.symbol),
                            ("B — eye", "eye"),
                            ("C — antenna.radiowaves.left.and.right", "antenna.radiowaves.left.and.right"),
                            ("A's pending-ask twin (U4)", MCPSharedIcon.pendingSymbol),
                        ], id: \.1) { label, symbol in
                            HStack(alignment: .firstTextBaseline, spacing: 5) {
                                Text(tokens.chromeLabel("the lightning thief"))
                                    .font(tokens.body.weight(.semibold))
                                    .foregroundStyle(tokens.ink)
                                Image(systemName: symbol)
                                    .font(tokens.small)
                                    .foregroundStyle(tokens.accent)
                                Spacer(minLength: 12)
                                Text(label).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(16)
                    .background(tokens.surface)
                    .environment(theme),
                    size: NSSize(width: 620, height: 170), name: "u3-icon-candidates-\(v).png")

                // 3 — THE PERMISSION POPOVER's content: a book reached by its
                // own grant, by the Home wing grant, and by the open book.
                let thiefReach = try await session.database.read {
                    try Queries.mcpBookReach($0, readingID: world.books[0].id)
                }
                let openReach = MCPPlaceReach(
                    client: MCPClient(id: "x", name: "cursor", version: nil, state: .approved,
                                      firstSeenAt: "", lastSeenAt: "", decidedAt: nil),
                    rung: .read, grant: nil, throughTitle: nil)
                await capture(
                    MCPReachPopover(reaches: thiefReach + [openReach], road: road) {}
                        .background(tokens.card)
                        .environment(theme),
                    size: NSSize(width: 340, height: 240), name: "u3-popover-\(v).png")

                // 4 — THE IN-NOTE INDICATOR at the context bar's trailing end:
                // a shared note (its why), and a Private note (the lock).
                for (tag, postID) in [("shared", world.parser.id), ("private", world.privateNote.id)] {
                    await capture(
                        ContextBar(
                            tokens: tokens, originLabel: "Library", forwardLabel: nil, books: [],
                            isNote: true,
                            trailing: AnyView(MCPNoteIndicator(session: session, postID: postID, tokens: tokens)),
                            onBack: {}, onForward: {}, onOpenBook: { _ in })
                            .environment(theme)
                            .environment(\.mcpShareRoad, road),
                        size: NSSize(width: 640, height: 34), name: "u3-indicator-\(tag)-\(v).png", settle: 60)
                }
                let noteReach = try await session.database.read {
                    try Queries.mcpNoteReach($0, noteID: world.parser.id)
                }
                await capture(
                    MCPReachPopover(reaches: noteReach, road: road) {}
                        .background(tokens.card)
                        .environment(theme),
                    size: NSSize(width: 340, height: 200), name: "u3-indicator-popover-\(v).png")

                // 5 — THE BULK SHEET ("Share 3 notes with AI…" → THE sheet,
                // WHERE said; a Private note among them withholds always).
                await capture(
                    MCPGrantSheet(
                        door: door,
                        opening: MCPGrantOpening(
                            place: .notes([world.parser.id, world.grammar.id, world.privateNote.id]),
                            origin: .place),
                        done: {})
                        .environment(theme),
                    size: NSSize(width: 600, height: 520), name: "u3-sheet-bulk-\(v).png")

                // 6 — CHANGE… (R-AIR-4): the sheet pre-filled on exactly a grant.
                let change = MCPReachPopover.changeOpening(
                    world.claude,
                    try #require(try await session.database.read {
                        try Queries.mcpGrants($0, clientID: world.claude.id).first { $0.scopeKind == .book }
                    }))
                await capture(
                    MCPGrantSheet(door: door, opening: change, done: {}).environment(theme),
                    size: NSSize(width: 600, height: 520), name: "u3-sheet-change-\(v).png")

                // 7 — THE PANE: Shared places, one row per act.
                await capture(
                    MCPPane(door: door).environment(theme),
                    size: NSSize(width: 560, height: 900), name: "u3-pane-\(v).png")

                // 8 — BOOK SETTINGS: the grant row (who reaches the book + Share…).
                if let target = await BookSettingsTarget.load(session: session, readingID: world.books[0].id) {
                    await capture(
                        BookSettingsHost(target: target)
                            .environment(theme)
                            .environment(\.mcpShareRoad, road),
                        size: NSSize(width: 520, height: 640), name: "u3-book-settings-\(v).png", settle: 80)
                }

                // 9 — ⌥⌘A's RECEIPT on the quiet slot, with its two doors.
                session.status.receiptStyle = .quiet
                door.speakShared(
                    client: world.claude, prefill: .note(world.grammar.id),
                    place: MCPShareCopy.quoted("grammar sketch"), rung: .suggest, duration: .connection,
                    grantIDs: ["g"], changed: false, change: { _ in })
                await capture(
                    HStack {
                        Spacer(minLength: 0)
                        QuietReceiptLine(status: session.status, tokens: tokens)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 28)
                    .background(tokens.surface)
                    .environment(theme),
                    size: NSSize(width: 720, height: 28), name: "u3-receipt-\(v).png", settle: 20)
                session.status.clear()
            }
        }
    }
}
