//
//  MCPAsksWaitTests.swift
//  VariorumTests (Mac)
//
//  13n-c U4 — ASKS WAIT QUIETLY + THE KEYBOARD (VX-156 items 4/5; R-AIR-6/15;
//  the brief §5/§6). The queue and its keyed projection (pure), ARRIVAL X's
//  promise that an ask never presents itself (state + source), the two
//  bug-class rows the trace found (T-U4-4 a denied client's dead ask; T-U4-5
//  one ask answered twice mints twice — each red-on-old by revert, the U4
//  record), ⌥⌘, landing at Waiting, the helper's MCP group, the chords'
//  declarations and the "until it disconnects" words.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
import VariorumMCP
@testable import Variorum

@MainActor
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 59))
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

private func ask(
    _ client: String = "claude-code", id: String = "n1", rung: MCPGrantRule.Rung = .suggest,
    kind: MCPGrantRule.ScopeKind = .note, title: String = "ch 7", fence: MCPGrantRule.Fence? = nil
) -> MCPAsk {
    MCPAsk(clientName: client, scopeKind: kind, scopeID: id, title: title, rung: rung, fence: fence)
}

private let t0 = Date(timeIntervalSince1970: 1_782_864_000)

@MainActor
@Suite("13n-c U4 — asks wait quietly: the queue, the board, arrival X, Waiting, ⌥⌘,", .serialized)
struct MCPAsksWaitTests {
    // MARK: - The queue (pure)

    @Test func theQueueDedupesAndKeepsTheFirstArrival() {
        var queue = MCPAskQueue()
        let first = queue.enqueue(ask(id: "a"), at: t0)
        #expect(first)
        let again = queue.enqueue(ask(id: "a"), at: t0.addingTimeInterval(60))
        #expect(!again, "a re-raise of a waiting ask changes nothing")
        #expect(queue.entry(ask(id: "a").id)?.askedAt == t0, "it keeps its FIRST stamp")
        let rung = queue.enqueue(ask(id: "a", rung: .writeNew), at: t0.addingTimeInterval(1))
        #expect(rung, "another rung is another ask")
        let other = queue.enqueue(ask("cursor", id: "a"), at: t0.addingTimeInterval(2))
        #expect(other, "another client is another ask")
        #expect(queue.count == 3)
        #expect(queue.newestFirst.map(\.ask.clientName) == ["cursor", "claude-code", "claude-code"],
                "Waiting's order: newest first")
    }

    @Test func theCapForgetsTheOldestNotBeingAnswered() {
        var queue = MCPAskQueue()
        for index in 0..<MCPAskQueue.cap { queue.enqueue(ask(id: "n\(index)"), at: t0) }
        // She has the OLDEST one's sheet open.
        let open: Set<String> = [ask(id: "n0").id]
        queue.enqueue(ask(id: "late"), at: t0.addingTimeInterval(9), answering: open)
        #expect(queue.count == MCPAskQueue.cap)
        #expect(queue.contains(ask(id: "n0").id), "the ask she is answering is never the one forgotten")
        #expect(!queue.contains(ask(id: "n1").id), "the oldest WAITING one goes")
        #expect(queue.contains(ask(id: "late").id))
        // Nobody answering: the plain oldest goes.
        queue.enqueue(ask(id: "later"), at: t0.addingTimeInterval(10))
        #expect(!queue.contains(ask(id: "n0").id))
    }

    @Test func aClientsAsksAreForgottenWhole() {
        var queue = MCPAskQueue()
        queue.enqueue(ask(id: "a"), at: t0)
        queue.enqueue(ask("cursor", id: "b"), at: t0)
        queue.enqueue(ask(id: "c", kind: .book), at: t0)
        let forgotten = queue.forget(client: "claude-code")
        #expect(forgotten == 2)
        #expect(queue.entries.map(\.ask.clientName) == ["cursor"])
        let removed = queue.remove(ask("cursor", id: "b").id)
        #expect(removed != nil)
        let twice = queue.remove(ask("cursor", id: "b").id)
        #expect(twice == nil, "an ask no longer waiting is nothing")
    }

    // MARK: - The board (the ONE projection every face reads)

    @Test func theBoardKeysEveryAskByItsTarget() {
        var queue = MCPAskQueue()
        queue.enqueue(ask(id: "n1", rung: .suggest), at: t0)
        queue.enqueue(ask("cursor", id: "n1", rung: .read), at: t0.addingTimeInterval(1))
        queue.enqueue(ask(id: "b1", rung: .writeNew, kind: .book, title: "the lightning thief"), at: t0)
        queue.enqueue(ask(id: "w2", rung: .writeNew, kind: .wing, title: "variorum"), at: t0)
        let board = queue.board
        #expect(board.asks(.note("n1")).map(\.clientName) == ["claude-code", "cursor"], "arrival order")
        #expect(board.asks(.book("b1")).count == 1)
        #expect(board.asks(.wing("w2")).count == 1)
        #expect(board.asks(.note("elsewhere")).isEmpty, "a calm target has nothing")
        #expect(board.wingAsks.map(\.target) == [.wing("w2")])
        #expect(board.contains(ask(id: "b1", rung: .writeNew, kind: .book).id))
        #expect(board.asks(.note("n1")).first?.here == "claude-code asks to suggest here", "mockup §4's hover")
        #expect(board.wingAsks.first?.named == "claude-code asks to write new in the variorum wing")
        #expect(MCPAskQueue().board == .empty)
    }

    @Test func theGlyphSaysWhoAsksAndPressesTheOldest() {
        var queue = MCPAskQueue()
        queue.enqueue(ask(id: "n1", rung: .suggest), at: t0)
        let one = MCPAskGlyph.asks(.target(.note("n1")), on: queue.board)
        #expect(MCPAskGlyph.help(.target(.note("n1")), one)
                == "claude-code asks to suggest here \u{2014} press to answer.")
        queue.enqueue(ask("cursor", id: "n1", rung: .read), at: t0)
        let two = MCPAskGlyph.asks(.target(.note("n1")), on: queue.board)
        #expect(two.first?.clientName == "claude-code", "a press answers the one that waited longest")
        #expect(MCPAskGlyph.help(.target(.note("n1")), two)
                == "claude-code asks to suggest here \u{00B7} cursor asks to read here \u{2014} press to answer the first.")
        queue.enqueue(ask(id: "w2", rung: .writeNew, kind: .wing, title: "variorum"), at: t0)
        let wing = MCPAskGlyph.asks(.anyWing, on: queue.board)
        #expect(MCPAskGlyph.help(.anyWing, wing)
                == "claude-code asks to write new in the variorum wing \u{2014} press to answer.",
                "the masthead word names the wing (it is the door to every wing)")
        #expect(MCPAskGlyph.asks(.target(.book("none")), on: queue.board).isEmpty, "calm ⇒ no glyph")
        #expect(CapabilityRegistry.capability(.mcpOpenAsk).doors == [.surface])
    }

    // MARK: - ARRIVAL X — an ask never presents itself

    /// The promise, as state: an arrival changes the queue and its board and
    /// NOTHING else the door exposes; the only road to an ask's sheet is a
    /// request (`answerAsk`) — and her Settings request is untouched.
    @Test func anArrivalOnlyWaits() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            let before = door.settingsRequest
            door.enqueue(ask(id: "n1"), now: t0)
            #expect(door.waiting.map(\.ask.scopeID) == ["n1"])
            #expect(door.askBoard.asks(.note("n1")).count == 1, "its glyph appears")
            #expect(door.settingsRequest == before, "an arrival never opens Settings")
            #expect(session.status.spoken == nil, "never a toast, never a receipt")
            #expect(door.ask(ask(id: "n1").id) != nil, "it waits — answerable by her press")
        }
    }

    /// The promise, as source: no SCENE hosts the ask sheet any more (13n-b's
    /// `.sheet(item:)` on the main `WindowGroup`, bound to `presentedAsk`, is
    /// retired), and the window request is set ONLY by a road's `answerAsk`
    /// (her press) — every other write clears it.
    @Test func noSceneHostsTheAskSheet() throws {
        let app = try Self.code("VariorumApp.swift")
        #expect(!app.contains("MCPAskSheet("), "no scene presents an ask")
        #expect(!app.contains("presentedAsk"))
        for file in try Self.swiftFiles() {
            let code = try Self.code(file)
            for line in code.split(separator: "\n") where line.contains("mcpAskRequest =") {
                #expect(line.contains("answerAsk") || line.contains("= nil"),
                        "\(file): the ask's window request is set only by her press — \(line)")
            }
        }
    }

    // MARK: - The two bug-class rows (red-on-old by revert — the U4 record)

    /// T-U4-5: two sheets on ONE ask (two main windows each presented it under
    /// 13n-b; under arrival X a window and the pane) — answering both minted
    /// two grants. Now only an ask still waiting is answered.
    @Test func oneAskAnsweredTwiceMintsOneGrant() async throws {
        try await withSession { (session: AppSession, db: AppDatabase) async throws in
            let ops = Operations()
            let client = try ops.recordMCPContact(name: "claude-code", version: nil)
            try ops.approveMCPClient(client.id, granting: nil)
            let note = try ops.createPost(title: "ch 7")
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            let asked = ask(id: note.id, rung: .suggest)
            door.enqueue(asked)
            door.answer(asked, .grant(.once))
            door.answer(asked, .grant(.always))
            var grants: [MCPGrantRow] = []
            for _ in 0..<100 {
                grants = try await db.read { try Queries.mcpGrants($0, clientID: client.id) }
                if !grants.isEmpty { break }
                try await Task.sleep(for: .milliseconds(10))
            }
            try await Task.sleep(for: .milliseconds(200))
            grants = try await db.read { try Queries.mcpGrants($0, clientID: client.id) }
            #expect(grants.count == 1, "one ask, one grant")
            #expect(grants.first?.duration == .once, "the first answer stands")
        }
    }

    /// T-U4-4: a denied (or revoked) client's waiting ask could only ever
    /// refuse — its glyph would be a dead door (P-2). Denying forgets them.
    @Test func denyingAClientForgetsItsAsks() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let ops = Operations()
            let client = try ops.recordMCPContact(name: "claude-code", version: nil)
            try ops.approveMCPClient(client.id, granting: nil)
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            door.enqueue(ask(id: "n1"))
            door.enqueue(ask("cursor", id: "n1"))
            door.deny(client.id)
            #expect(try await settle { door.asks.map(\.clientName) == ["cursor"] },
                    "the denied client's asks leave; another client's stay")
            #expect(door.askBoard.asks(.note("n1")).map(\.clientName) == ["cursor"])
        }
    }

    // MARK: - The door's queue

    @Test func anOpenSheetsAskSurvivesTheCapAndDetachForgetsAll() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            door.enqueue(ask(id: "first"))
            door.beginAnswering(ask(id: "first").id)
            for index in 0..<20 { door.enqueue(ask(id: "spam-\(index)")) }
            #expect(door.asks.count == MCPDoor.askCap)
            #expect(door.ask(ask(id: "first").id) != nil, "the ask she is reading is never forgotten")
            door.endAnswering(ask(id: "first").id)
            door.answer(ask(id: "first"), .dontAllow)
            #expect(door.ask(ask(id: "first").id) == nil && door.asks.count == MCPDoor.askCap - 1)
            door.detach()
            #expect(door.asks.isEmpty && door.askBoard == .empty, "a closed library's asks die with it")
            door.enqueue(ask(id: "after"))
            #expect(door.asks.isEmpty, "no library, no ask")
        }
    }

    // MARK: - ⌥⌘, — MCP Settings…, at Waiting

    @Test func theMCPSettingsChordLandsOnceAtWaiting() {
        let door = MCPDoor(serverAllowed: false)
        #expect(door.settingsRequest == 0)
        door.requestSettings()
        #expect(door.settingsRequest == 1)
        #expect(AppSettingsView.adopts(request: 1, adopted: 0), "a fresh request opens the MCP pane")
        #expect(!AppSettingsView.adopts(request: 1, adopted: 1), "once")
        #expect(MCPPane.scrollsToWaiting(request: 1, scrolled: 0, waitingCount: 2), "scrolled when asks wait")
        #expect(!MCPPane.scrollsToWaiting(request: 1, scrolled: 0, waitingCount: 0), "no ask, no scroll")
        #expect(!MCPPane.scrollsToWaiting(request: 1, scrolled: 1, waitingCount: 2), "once per request")
        let cap = CapabilityRegistry.capability(.mcpSettings)
        #expect(cap.doors == [.menuBar] && cap.shortcutLabel == "\u{2325}\u{2318}," && cap.verb == "MCP Settings\u{2026}")
        #expect(EditorCommands.menuRendered.contains(.mcpSettings))
    }

    @Test func waitingIsCappedSaidAndFindable() {
        #expect(MCPDoor.waitingCap == 3, "mockup §4 draws three, then all N ›")
        #expect(MCPPaneCopy.waitingSection == "Waiting")
        #expect(MCPAskCopy.title(ask(rung: .suggest, kind: .book, title: "the lightning thief"), distinguisher: nil)
                == "claude-code asks to suggest in \u{201C}the lightning thief\u{201D}", "mockup §4's row")
        #expect(MCPPane.relative(t0, now: t0.addingTimeInterval(120)).contains("2 minutes"))
        // The Settings search finds it ("ask", "waiting").
        #expect(SettingsCatalog.rows.contains { $0.id == "mcpWaiting" && $0.pane == .mcp })
        #expect(AppSettingsView.rowIDsRendered[.mcp]?.contains("mcpWaiting") == true)
        // The registry's own note no longer says the sheet "arrives".
        #expect(!CapabilityRegistry.capability(.mcpAnswerAsk).unavailableNote.contains("arrives"))
    }

    // MARK: - The helper (⌘/ and Settings ▸ Shortcuts — one list)

    @Test func theHelpersMCPGroupHoldsEveryMCPChord() {
        let mcp = try? #require(HelperView.groups.first { $0.title == "MCP" })
        let keys = Set(mcp?.items.map(\.keys) ?? [])
        #expect(keys.isSuperset(of: ["\u{2325}\u{2318},", "\u{2325}\u{2318}A", "\u{2325}\u{2318}O", "\u{2325}\u{2318}Z"]))
        #expect(mcp?.items.contains { $0.does.contains("Undo claude-code's take") } == true,
                "the client-named undo, in the words the Edit menu really says")
        let writing = HelperView.groups.first { $0.title == "Writing" }?.items.map(\.keys) ?? []
        #expect(!writing.contains("\u{2325}\u{2318}O") && !writing.contains("\u{2325}\u{2318}A"),
                "moved to the MCP group, not doubled")
        #expect(HelperView.shortcutKeysShown.isSuperset(of: ["\u{2318}L", "\u{2325}\u{2318},"]))
    }

    // MARK: - "Until it disconnects" (her round-2 ask; PROVISIONAL P-13nc-U4-1)

    @Test func theBoundedDurationSaysWhenItEnds() {
        #expect(MCPPaneCopy.durationWord(.connection) == "until it disconnects")
        #expect(MCPAskCopy.button(.connection) == "Until it disconnects")
        #expect(MCPPaneCopy.whileConnectedNote.hasPrefix("\u{201C}Until it disconnects\u{201D}"))
        #expect(MCPPaneCopy.confirm(
            verb: "Grant", rung: .suggest, scope: .book, place: "the lightning thief", duration: .connection)
                == "Grant suggest in \u{201C}the lightning thief\u{201D} until it disconnects, including to future entries")
        #expect(MCPShareCopy.shared(place: "\u{201C}parser notes\u{201D}", client: "claude-code",
                                    rung: .suggest, duration: .connection)
                == "Shared \u{201C}parser notes\u{201D} with claude-code \u{2014} read and suggest, until it disconnects.")
    }

    // MARK: - Source helpers

    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
    }

    /// A source file under `Variorum/`, comments stripped.
    private static func code(_ relative: String) throws -> String {
        let text = try String(contentsOf: appRoot.appending(path: "Variorum/\(relative)"), encoding: .utf8)
        return text.split(separator: "\n", omittingEmptySubsequences: false)
            .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("//") }
            .joined(separator: "\n")
    }

    /// Every Swift file under `Variorum/`, relative.
    private static func swiftFiles() throws -> [String] {
        let root = appRoot.appending(path: "Variorum")
        let walker = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil)
        var files: [String] = []
        while let url = walker?.nextObject() as? URL {
            guard url.pathExtension == "swift" else { continue }
            files.append(String(url.path.dropFirst(root.path.count + 1)))
        }
        return files
    }
}
