//
//  MCPSharedRowsTests.swift
//  VariorumTests (Mac)
//
//  VX-268 (RUN VX-281, U2) — THE ONE SHARED ICON WHEREVER THE ASK GLYPH MARKS A
//  PLACE. Her report, on the ticket: "claude-code reaches two books, the Bookcase
//  wears the icon on both, and the Library shows nothing on those books or on their
//  notes." Her kickoff calls: the Pool's rows and the Book Panel's rows IN; the wing
//  switcher's rows IN by the same parity; Blocks-scope rows OUT; the open book
//  matches the Bookcase.
//
//  THE BUG'S PINS, red-first. Each host's road, end to end on a real session:
//  the host's model HOLDS the reach of the rows it shows (the Library's near-window
//  row slices and its listed books, the Pool's drawn rows, the Book Panel's entries,
//  the Timeline's loaded rows, the wings), a grant made while the rows show reaches
//  them at once and a revoke takes it off (held, never one-shot), the open book
//  reaches every row, and with no approved client nothing does (VX-272). And the
//  two List lines DRAW the icon on the title's own baseline (the DEBUG
//  `BaselineProbe`, both voices) — nothing at all when nobody reaches the row.
//
//  RED-ON-OLD, stated: the strict pre-fix tree cannot compile these (the rows had
//  no reach to hold or to draw — the absent capability's honest shape, the 18h
//  stamp pin's precedent), so the run's red tree is the SEAM commit: this API
//  with the PRE-FIX BEHAVIOUR behind it — no host reads reach, the core reads
//  answer nothing, no line draws the icon — exactly what the old tree did for
//  these rows. Every positive leg below times out or reads nil there.
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
@Suite("VX-268 — the shared icon on every row the ask glyph marks (the Library, the Pool, the Book Panel, the Timeline, the wings)", .serialized)
struct MCPSharedRowsTests {
    private func withSession<T>(_ body: @MainActor (AppSession, AppDatabase) async throws -> T) async throws -> T {
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 268))
        } operation: { @MainActor in
            try await body(AppSession(database: db), db)
        }
    }

    private func defaults(_ name: String) throws -> UserDefaults {
        let suite = "vx268-shared-rows-\(name)-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    /// Wait (bounded, ~3 s) for a condition a held observation settles.
    private func settle(_ condition: @MainActor () -> Bool) async throws -> Bool {
        for _ in 0..<300 {
            if condition() { return true }
            try await Task.sleep(for: .milliseconds(10))
        }
        return condition()
    }

    @discardableResult
    private func approved(_ ops: Operations, _ name: String = "claude-code") throws -> MCPClient {
        let client = try ops.recordMCPContact(name: name, version: "2")
        try ops.approveMCPClient(client.id, granting: nil)
        return client
    }

    private func note(_ ops: Operations, _ title: String) throws -> Container {
        let post = try ops.createPost(title: title)
        _ = try ops.newBlock(in: post.id, text: "\(title) — words", registeringUndo: false)
        return post
    }

    private func grant(
        _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
        _ duration: MCPGrantRule.Duration = .always
    ) -> Operations.MCPGrantSpec {
        .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
    }

    // MARK: - The Library: note rows (List, Cards, the answer sheet — one slice) and book rows

    @Test func theLibrarysNoteAndBookRowsHoldTheirReachAndTheGatheringsByTheWingGrant() async throws {
        try await withSession { session, _ in
            let ops = session.operations
            let claude = try approved(ops)
            let codex = try approved(ops, "codex")
            let alpha = try note(ops, "alpha")
            let beta = try note(ops, "beta")
            let gamma = try note(ops, "gamma")
            let book = try ops.createReading(name: "the lightning thief", kind: .book)
            _ = try ops.addPostToReading(beta.id, to: book.id)
            let bare = try ops.createReading(name: "a bare book", kind: .book)
            let gathering = try ops.createReading(
                name: "every star", kind: .gathering, querySpec: try RuleGrammar.encode(.star))
            let noteGrant = try ops.grantMCPAccess(claude.id, grant(.suggest, .note, alpha.id, .connection))
            _ = try ops.grantMCPAccess(claude.id, grant(.read, .book, book.id))

            let model = LibraryCatalogModel(session: session, defaults: try defaults("library"))
            await model.search()
            defer { model.stopHoldingFacts() }
            let books = Task { await model.holdBookReach(model.listedBookIDs) }
            defer { books.cancel() }
            #expect(model.listedBookIDs.contains(book.id) && model.listedBookIDs.contains(gathering.id))

            // A note's own grant, and a note reached THROUGH its book (the why).
            #expect(try await settle { !model.rowExtras(for: alpha.id).reach.isEmpty },
                    "alpha's row holds claude-code's note grant")
            #expect(model.rowExtras(for: alpha.id).reach.first?.grant?.id == noteGrant)
            #expect(try await settle { model.rowExtras(for: beta.id).reach.first?.throughTitle == "the lightning thief" },
                    "beta's row holds the reach through its book")
            #expect(model.rowExtras(for: gamma.id).reach.isEmpty, "an unshared note's row: nothing")
            // The book row; the bare book and the gathering bare (no wing grant yet).
            #expect(try await settle { model.bookReach[book.id]?.first?.clientName == "claude-code" })
            #expect(model.bookReach[bare.id] == nil && model.bookReach[gathering.id] == nil)

            // HELD: a wing grant made now reaches the gathering's row and gamma's (VX-185's truth).
            let wing = try ops.grantMCPAccess(codex.id, grant(.read, .wing, ""))
            #expect(try await settle { model.bookReach[gathering.id]?.first?.throughTitle == "Home" },
                    "a gathering's row wears it under the wing grant, the wing named")
            #expect(try await settle { model.rowExtras(for: gamma.id).reach.map(\.clientName) == ["codex"] })
            #expect(model.bookReach[bare.id]?.map(\.clientName) == ["codex"])

            // HELD: a revoke takes it off.
            try ops.revokeMCPGrant(noteGrant)
            try ops.revokeMCPGrant(wing)
            #expect(try await settle { model.rowExtras(for: alpha.id).reach.isEmpty })
            #expect(try await settle { model.bookReach[gathering.id] == nil })
            #expect(model.bookReach[book.id] != nil, "the book's own grant still stands")
        }
    }

    // MARK: - The open book matches the Bookcase: every row it reaches wears it

    @Test func theOpenBookReachesEveryLibraryRowAsItDoesTheBookcase() async throws {
        try await withSession { session, _ in
            let ops = session.operations
            try approved(ops)
            let notes = try (0..<4).map { try note(ops, "note \($0)") }
            let secret = try note(ops, "a secret")
            _ = try ops.setNotePrivate(secret.id, true)
            let book = try ops.createReading(name: "a book", kind: .book)
            let gathering = try ops.createReading(
                name: "every star", kind: .gathering, querySpec: try RuleGrammar.encode(.star))
            try ops.setMCPSwitch(.openBook, on: true)

            let model = LibraryCatalogModel(session: session, defaults: try defaults("open"))
            await model.search()
            defer { model.stopHoldingFacts() }
            let books = Task { await model.holdBookReach(model.listedBookIDs) }
            defer { books.cancel() }
            for post in notes {
                #expect(try await settle { model.rowExtras(for: post.id).reach.first?.viaOpenBook == true },
                        "\(post.title ?? "") — the open book reaches it")
            }
            #expect(model.rowExtras(for: secret.id).reach.isEmpty, "never a fenced note")
            #expect(try await settle { model.bookReach[book.id]?.first?.viaOpenBook == true })
            #expect(try await settle { model.bookReach[gathering.id]?.first?.viaOpenBook == true })

            // …and the Bookcase says the same about the same book (one rule).
            let bookcase = try await session.database.read { try Queries.mcpBookReaches($0) }
            #expect(model.bookReach[book.id] == bookcase[book.id])
            #expect(model.bookReach[gathering.id] == bookcase[gathering.id])
        }
    }

    // MARK: - The Pool's rows

    @Test func thePoolsDrawnRowsHoldTheirReach() async throws {
        try await withSession { session, _ in
            let ops = session.operations
            let claude = try approved(ops)
            let shared = try note(ops, "a shared pool note")
            let loose = try note(ops, "a loose pool note")
            let model = PoolPostsModel(session: session)
            let listing = Task { await model.start() }
            defer { listing.cancel() }
            #expect(try await settle { Set(model.drawnIDs).isSuperset(of: [shared.id, loose.id]) })
            let hold = Task { await model.holdReach(model.drawnIDs) }
            defer { hold.cancel() }

            let granted = try ops.grantMCPAccess(claude.id, grant(.read, .note, shared.id))
            #expect(try await settle { model.reach[shared.id]?.first?.grant?.id == granted },
                    "the Pool's row holds its reach (held — a grant made now shows)")
            #expect(model.reach[loose.id] == nil)
            try ops.revokeMCPGrant(granted)
            #expect(try await settle { model.reach[shared.id] == nil })
        }
    }

    // MARK: - The Book Panel's rows

    @Test func theBookPanelsRowsHoldTheirReach() async throws {
        try await withSession { session, _ in
            let ops = session.operations
            let claude = try approved(ops)
            let open = try note(ops, "the open note")
            let sibling = try note(ops, "its sibling")
            let book = try ops.createReading(name: "the lightning thief", kind: .book)
            _ = try ops.addPostToReading(open.id, to: book.id)
            _ = try ops.addPostToReading(sibling.id, to: book.id)

            let model = BookPanelModel(session: session, postID: open.id)
            let contents = Task { await model.observe(bookID: book.id) }
            defer { contents.cancel() }
            #expect(try await settle { model.entryIDs(for: book.id).count == 2 })
            let hold = Task { await model.holdReach(model.entryIDs(for: book.id)) }
            defer { hold.cancel() }

            let granted = try ops.grantMCPAccess(claude.id, grant(.edit, .note, sibling.id))
            #expect(try await settle { model.reach[sibling.id]?.first?.grant?.id == granted },
                    "the panel's row holds its reach")
            #expect(model.reach[open.id] == nil)
            // A book grant reaches both rows, the why naming the book.
            _ = try ops.grantMCPAccess(claude.id, grant(.read, .book, book.id))
            #expect(try await settle { model.reach[open.id]?.first?.throughTitle == "the lightning thief" })
        }
    }

    // MARK: - The Timeline's rows

    @Test func theTimelinesLoadedRowsHoldTheirReach() async throws {
        try await withSession { session, _ in
            let ops = session.operations
            let claude = try approved(ops)
            let first = try note(ops, "first")
            let second = try note(ops, "second")
            let model = TimelineViewModel(session: session)
            await model.setLens(.library)   // the total surface: every note, whatever its stamps
            let ids = model.items.map(\.postID)
            #expect(Set(ids).isSuperset(of: [first.id, second.id]))
            let hold = Task { await model.holdReach(ids) }
            defer { hold.cancel() }

            let granted = try ops.grantMCPAccess(claude.id, grant(.read, .note, second.id, .once))
            #expect(try await settle { model.reach[second.id]?.first?.grant?.id == granted },
                    "the Timeline's row holds its reach")
            #expect(model.reach[first.id] == nil)
        }
    }

    // MARK: - The wings (⌘L's rows and the ▾ menu read the one map)

    @Test func theWingsHoldTheirReachAWingGrantOrTheOpenBookNeverANoteGrant() async throws {
        try await withSession { session, _ in
            let ops = session.operations
            let claude = try approved(ops)
            let variorum = try ops.createWing(name: "variorum")
            let inside = try ops.createPost(title: "inside", wingId: variorum.id)
            let wings = WingsModel(session: session)
            let watch = Task { await wings.watchSharing() }
            defer { watch.cancel() }

            // A note grant inside a wing never shares the wing (P-VX281-U2-4).
            _ = try ops.grantMCPAccess(claude.id, grant(.edit, .note, inside.id))
            let home = try ops.grantMCPAccess(claude.id, grant(.writeNew, .wing, ""))
            #expect(try await settle { wings.reach[""]?.first?.grant?.id == home },
                    "Home's row holds the Home wing grant")
            let reach = try #require(wings.reach[""]?.first)
            #expect(reach.rung == .writeNew && reach.throughTitle == nil, "its own grant — no why")
            #expect(wings.reach[variorum.id] == nil, "a note grant inside a wing: the wing stays bare")

            try ops.setMCPSwitch(.openBook, on: true)
            #expect(try await settle { wings.reach[variorum.id]?.first?.viaOpenBook == true },
                    "the open book reaches every wing")
            try ops.revokeMCPGrant(home)
            #expect(try await settle { wings.reach[""]?.first?.viaOpenBook == true })
        }
    }

    // MARK: - VX-272: no approved client, no icon anywhere — then one approved, and they come

    @Test func noApprovedClientMeansNoRowWearsItThenApprovalBringsIt() async throws {
        try await withSession { session, _ in
            let ops = session.operations
            let denied = try approved(ops, "denied")
            _ = try ops.grantMCPAccess(denied.id, grant(.edit, .wing, ""))
            try ops.denyMCPClient(denied.id)
            _ = try ops.recordMCPContact(name: "asking", version: nil)
            try ops.setMCPSwitch(.openBook, on: true)
            let post = try note(ops, "a note")
            let book = try ops.createReading(name: "a book", kind: .book)

            let library = LibraryCatalogModel(session: session, defaults: try defaults("vx272"))
            await library.search()
            defer { library.stopHoldingFacts() }
            let books = Task { await library.holdBookReach(library.listedBookIDs) }
            defer { books.cancel() }
            let wings = WingsModel(session: session)
            let watch = Task { await wings.watchSharing() }
            defer { watch.cancel() }
            try await Task.sleep(for: .milliseconds(300))
            // GUARD (green on the seam by nature) …
            #expect(library.rowExtras(for: post.id).reach.isEmpty, "VX-272: no approved client, no icon")
            #expect(library.bookReach.isEmpty && wings.reach.isEmpty)

            // … paired with its positive control (red on the seam): one approved client.
            try approved(ops)
            #expect(try await settle { library.rowExtras(for: post.id).reach.map(\.clientName) == ["claude-code"] })
            #expect(try await settle { library.bookReach[book.id] != nil })
            #expect(try await settle { wings.reach[""] != nil })
        }
    }

    // MARK: - The faces: the List lines draw the ONE icon on the title's baseline, or nothing

    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func mount<V: View>(_ content: V) -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 700, height: 80),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(
            rootView: content.padding(12).frame(width: 700, height: 80, alignment: .leading))
        hosting.frame = NSRect(x: 0, y: 0, width: 700, height: 80)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        for _ in 0..<12 {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
        }
        return window
    }

    private func close(_ window: NSWindow) {
        window.orderOut(nil)
        window.close()
    }

    private var openBookReach: [MCPPlaceReach] {
        [MCPPlaceReach(
            client: MCPClient(
                id: "c1", name: "claude-code", version: "2", state: .approved,
                firstSeenAt: "2026-07-01T00:00:00.000Z", lastSeenAt: "2026-07-01T00:00:00.000Z",
                decidedAt: nil),
            rung: .read, grant: nil, throughTitle: nil)]
    }

    @Test func aReachedNoteRowDrawsTheIconOnItsTitlesBaselineAndACalmOneDrawsNothing() throws {
        for tokens in [VoiceTokens.terminalLight, VoiceTokens.studyLight] {
            #if DEBUG
            BaselineProbe.reset()
            #endif
            let reached = mount(CatalogNoteLine(
                tokens: tokens, title: "three ways of working", date: nil, tags: [], allTags: [],
                onTitleTap: {}, onApply: { _ in }, onRemove: { _ in }, reach: openBookReach))
            #if DEBUG
            let title = try #require(BaselineProbe.baseline("note.title"), "the title reported")
            let shared = try #require(BaselineProbe.baseline("note.shared"), "the shared icon drew (red on the seam)")
            #expect(abs(title - shared) <= 1, "the icon (\(shared)) sits on the title's baseline (\(title))")
            #endif
            close(reached)

            #if DEBUG
            BaselineProbe.reset()
            #endif
            let calm = mount(CatalogNoteLine(
                tokens: tokens, title: "three ways of working", date: nil, tags: [], allTags: [],
                onTitleTap: {}, onApply: { _ in }, onRemove: { _ in }))
            #if DEBUG
            #expect(BaselineProbe.baseline("note.title") != nil)
            #expect(BaselineProbe.baseline("note.shared") == nil, "nobody reaches it: no icon at all")
            #endif
            close(calm)
        }
    }

    @Test func aReachedBookRowDrawsTheIconOnItsTitlesBaselineAndACalmOneDrawsNothing() throws {
        for tokens in [VoiceTokens.terminalLight, VoiceTokens.studyLight] {
            #if DEBUG
            BaselineProbe.reset()
            #endif
            let reached = mount(CatalogBookLine(
                tokens: tokens, title: "the field guide", detail: "gathering", onTitleTap: {},
                reach: openBookReach))
            #if DEBUG
            let title = try #require(BaselineProbe.baseline("book.title"), "the title reported")
            let shared = try #require(BaselineProbe.baseline("book.shared"), "the shared icon drew (red on the seam)")
            #expect(abs(title - shared) <= 1, "the icon (\(shared)) sits on the title's baseline (\(title))")
            #endif
            close(reached)

            #if DEBUG
            BaselineProbe.reset()
            #endif
            let calm = mount(CatalogBookLine(
                tokens: tokens, title: "the field guide", detail: "book", onTitleTap: {}))
            #if DEBUG
            #expect(BaselineProbe.baseline("book.shared") == nil, "nobody reaches it: no icon at all")
            #endif
            close(calm)
        }
    }
}
