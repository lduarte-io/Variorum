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
import SwiftUI
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
            // Stage B R2-1 (A JUSTIFIED EDIT, the ritual): the asks name a REAL
            // note — the ask watch now re-validates every waiting ask, and an
            // ask on an id naming nothing (which the wire never raises — AF-6
            // asks only for targets the client knows exist) is forgotten as gone.
            let note = try ops.createPost(title: "ch 7")
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            door.enqueue(ask(id: note.id))
            door.enqueue(ask("cursor", id: note.id))
            door.deny(client.id)
            #expect(try await settle { door.asks.map(\.clientName) == ["cursor"] },
                    "the denied client's asks leave; another client's stay")
            #expect(door.askBoard.asks(.note(note.id)).map(\.clientName) == ["cursor"])
        }
    }

    // MARK: - 13n-c UX walk W-UX-1 — an answered ask never presents itself again

    /// **W-UX-1 (bug-class, the UX walk's finding 1; red-on-old):** she
    /// answered an ask (Don't allow / Esc, or Once from its mark); the client
    /// asked the SAME thing again (an `MCPAsk.id` is deterministic — client ·
    /// target · rung) and the sheet presented itself, unpressed: the host's
    /// state still held the answered id (SwiftUI closes a sheet whose item
    /// turns nil without calling the setter), so the equal re-raise made the
    /// item non-nil again. Driven through the very binding every host presents
    /// (`MCPAskSheetItem.item`) and the switcher's nested road (the board).
    @Test func anAnsweredAskNeverPresentsItselfWhenTheClientAsksAgain() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let ops = Operations()
            let client = try ops.recordMCPContact(name: "claude-code", version: nil)
            try ops.approveMCPClient(client.id, granting: nil)
            let note = try ops.createPost(title: "ch 7")
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            let asked = ask(id: note.id, rung: .read)
            for answer in [MCPDoor.AskAnswer.dontAllow, .grant(.once)] {
                door.enqueue(asked)
                // HER press — a window's road, the pane's Answer…, a mark in ⌘L.
                var held: MCPAskOpening? = door.opening(asked.id)
                let item = MCPAskSheetItem.item(
                    door: door, opening: Binding(get: { held }, set: { held = $0 }))
                let nested = door.askBoard.opening(asked.id)
                #expect(item.wrappedValue == asked, "her press presents the ask (\(answer))")
                #expect(nested.map { door.askBoard.waits($0) } == true)
                door.answer(asked, answer)
                #expect(item.wrappedValue == nil, "answered, the sheet closes (\(answer))")
                // The client asks the same thing again.
                door.enqueue(asked)
                #expect(door.ask(asked.id) != nil, "the re-raise WAITS — at its mark and in Waiting")
                #expect(item.wrappedValue == nil,
                        "an answered ask's sheet never presents itself again (\(answer)) — arrival X")
                #expect(nested.map { door.askBoard.waits($0) } == false,
                        "the switcher's nested host likewise (\(answer))")
                // A fresh press opens the new raise.
                held = door.opening(asked.id)
                #expect(item.wrappedValue == asked, "her next press opens it (\(answer))")
                door.answer(asked, .dontAllow)
            }
        }
    }

    // MARK: - Stage B R1 B2 — a waiting ask is answered on CURRENT facts

    /// A client's re-raise carries the picture its latest call saw: the
    /// waiting ask takes it (title, fence) and keeps its first stamp and its
    /// place in Waiting.
    @Test func aReRaiseRefreshesThePayloadAndKeepsItsStampAndPlace() throws {
        var queue = MCPAskQueue()
        queue.enqueue(ask(id: "n1", title: "ch 7"), at: t0)
        queue.enqueue(ask(id: "n2"), at: t0.addingTimeInterval(1))
        let changed = queue.enqueue(
            ask(id: "n1", title: "ch 7, retitled", fence: .privateMark), at: t0.addingTimeInterval(60))
        #expect(changed, "a re-raise with a new picture of its target refreshes the waiting ask")
        let entry = try #require(queue.entry(ask(id: "n1").id))
        #expect(entry.ask.fence == .privateMark && entry.ask.title == "ch 7, retitled")
        #expect(entry.askedAt == t0, "its first stamp stands")
        #expect(queue.entries.map(\.ask.scopeID) == ["n1", "n2"], "…and its place")
    }

    /// The trace: an ask that arrived on an UNFENCED note offered Always on
    /// its arrival snapshot; the note marked Private since, Always could only
    /// refuse (`mcpGrantScopeFenced`) — a dead door (P-2). Her open reads the
    /// note again: Always is gone; the mark lifted, it is back.
    @Test func herOpenReadsTheNoteAgainSoAlwaysIsNeverADeadDoor() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let ops = Operations()
            let note = try ops.createPost(title: "ch 7")
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            let asked = ask(id: note.id, rung: .suggest, title: "ch 7")
            door.enqueue(asked, now: t0)
            #expect(door.durations(for: asked).contains(.always), "it arrived unfenced")
            _ = try ops.setNotePrivate(note.id, true)
            let fresh = try #require(await door.refreshAsk(asked.id))
            #expect(fresh.fence == .privateMark, "marked Private since it asked")
            #expect(!door.durations(for: fresh).contains(.always),
                    "Always is never offered on a note fenced now — its press could only refuse")
            #expect(door.ask(asked.id)?.fence == .privateMark,
                    "the queue holds the fresh picture — Waiting, the glyph and every host read it")
            #expect(door.waiting.first?.askedAt == t0, "the stamp stands")
            _ = try ops.setNotePrivate(note.id, false)
            let lifted = try #require(await door.refreshAsk(asked.id))
            #expect(lifted.fence == nil && door.durations(for: lifted).contains(.always),
                    "the mark lifted, Always is offered again")
        }
    }

    /// A target deleted while its ask waited: the ask is forgotten at her
    /// open (its glyph leaves, the sheet closes — every host reads the queue).
    @Test func anAskWhoseTargetIsGoneIsForgotten() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let ops = Operations()
            let note = try ops.createPost(title: "ch 7")
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            let asked = ask(id: note.id, title: "ch 7")
            door.enqueue(asked, now: t0)
            try ops.deleteContainer(note.id)
            let after = await door.refreshAsk(asked.id)
            #expect(after == nil, "nothing left to answer")
            #expect(door.ask(asked.id) == nil && door.waiting.isEmpty, "Waiting no longer lists it")
            #expect(door.askBoard.asks(.note(note.id)).isEmpty, "its glyph leaves")
        }
    }

    /// A BOOK ask arrives only on an unfenced book; marked Private (or made
    /// the daily Journal) since, no grant can reach it — every duration would
    /// refuse. Read on current facts, the sheet offers no grant and says why.
    @Test func aBookFencedSinceSaysSoAndOffersNoGrant() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let ops = Operations()
            let book = try ops.createReading(name: "the lightning thief", kind: .book)
            let diary = try ops.createReading(name: "diary", kind: .book)
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            let asked = ask(id: book.id, rung: .writeNew, kind: .book, title: "the lightning thief")
            let daily = ask(id: diary.id, rung: .writeNew, kind: .book, title: "diary")
            door.enqueue(asked, now: t0)
            door.enqueue(daily, now: t0)
            #expect(door.durations(for: asked) == [.once, .always], "it arrived on an open book")
            _ = try ops.setBookPrivate(book.id, true)
            try ops.setDailyJournalBook(diary.id)
            let fresh = try #require(await door.refreshAsk(asked.id))
            #expect(fresh.fence == .privateMark)
            #expect(door.durations(for: fresh).isEmpty, "no answer that grants — each would refuse")
            #expect(MCPAskCopy.reachLine(fresh) == nil, "nothing here grants it, so no reach is said")
            #expect(MCPAskCopy.lead(fresh)
                    == "This book is marked Private now, which no grant reaches \u{2014} its notes are shared "
                    + "one ask at a time. \(MCPAskCopy.dontAllow) lets this ask go.")
            let journal = try #require(await door.refreshAsk(daily.id))
            #expect(journal.fence == .journal && door.durations(for: journal).isEmpty)
            #expect(MCPAskCopy.lead(journal).hasPrefix("This book is your daily Journal now"))
        }
    }

    // MARK: - Stage B R2-1 — a dead place's ask: said at her press, gone without one

    /// (a) Her press opened a sheet whose place is gone — the sheet closes, a
    /// door that did nothing — so it SAYS so, a refusal naming the place, on
    /// the seam she pressed in: a window's status line, or the pane's caption.
    @Test func herPressSaysSoWhenThePlaceIsGone() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let ops = Operations()
            let note = try ops.createPost(title: "ch 7")
            let book = try ops.createReading(name: "the lightning thief", kind: .book)
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            let noteAsk = ask(id: note.id, title: "ch 7")
            let bookAsk = ask(id: book.id, rung: .writeNew, kind: .book, title: "the lightning thief")
            door.enqueue(noteAsk, now: t0)
            door.enqueue(bookAsk, now: t0)
            try ops.deleteContainer(note.id)
            #expect(await door.refreshAsk(noteAsk.id) == nil, "nothing left to answer")
            let said = try #require(session.status.spoken, "a press that did nothing says why")
            #expect(said.text == "\u{201C}ch 7\u{201D} is gone, so claude-code's ask was let go.")
            #expect(said.kind == .refusal)
            #expect(said.text == MCPAskCopy.gone(noteAsk))
            // The pane (Settings has no status seam): its own caption. 13n-c UX
            // walk W-UX-8 (A JUSTIFIED EDIT, the ritual — T-15): BY WAITING,
            // where she pressed (it was `.top`, the pane's head inside the
            // server card — off-screen once ⌥⌘, had scrolled to Waiting).
            try ops.deleteReading(book.id)
            #expect(await door.refreshAsk(bookAsk.id, from: .pane) == nil)
            #expect(door.note == MCPDoor.Note(text: MCPAskCopy.gone(bookAsk), place: .waiting))
            #expect(MCPAskCopy.gone(ask(kind: .wing, title: "variorum"))
                    == "The variorum wing is gone, so claude-code's ask was let go.")
        }
    }

    /// **The UX-fix ladder's UXR1-6 (round 1, NIT):** Waiting's own caption
    /// (W-UX-8 — "“ch 7” is gone, so claude-code's ask was let go.") speaks
    /// about the rows she pressed among, and it outlived them: it sat over an
    /// empty Waiting, and stale above FRESH asks. It leaves when Waiting's rows
    /// change — an ask arriving, answered or forgotten — and stays while they
    /// stand as she left them. A caption at the pane's HEAD (a refusal) is
    /// never Waiting's to clear.
    @Test func waitingsCaptionLeavesWhenItsRowsChange() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let ops = Operations()
            let gone = try ops.createPost(title: "ch 7")
            let fresh = try ops.createPost(title: "a letter")
            let later = try ops.createPost(title: "the long table")
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            let goneAsk = ask(id: gone.id, title: "ch 7")
            door.enqueue(goneAsk, now: t0)
            try ops.deleteContainer(gone.id)
            #expect(await door.refreshAsk(goneAsk.id, from: .pane) == nil)
            let said = MCPDoor.Note(text: MCPAskCopy.gone(goneAsk), place: .waiting)
            #expect(door.note == said, "her press says so, by Waiting (W-UX-8)")
            await door.revalidateAsks()
            #expect(door.note == said, "nothing changed in Waiting: the line stays")
            // A fresh ask arrives — the line was about a list no longer shown.
            let freshAsk = ask(id: fresh.id, title: "a letter")
            door.enqueue(freshAsk, now: t0.addingTimeInterval(5))
            #expect(door.note == nil, "never stale above a FRESH ask")
            // An answer changes the rows too.
            door.note = said
            door.answer(freshAsk, .dontAllow)
            #expect(door.note == nil, "an ask answered: the line leaves with the rows it spoke of")
            // The pane's HEAD caption (a refusal) is not Waiting's.
            let refusal = MCPDoor.Note(text: "That didn't land.", place: .top)
            door.note = refusal
            door.enqueue(ask(id: later.id, title: "the long table"), now: t0.addingTimeInterval(9))
            #expect(door.note == refusal, "only Waiting's own caption follows Waiting's rows")
        }
    }

    /// (b) A place that dies while its ask waits takes the ask's mark with it
    /// — no press. A book's or a wing's death wakes the ask watch (the
    /// masthead's wing word wore that mark); a note's death is caught where its
    /// mark can still show, Waiting, whose render re-validates. Silent: nothing
    /// is said for a press she never made.
    @Test func aDeadPlacesMarkLeavesWithoutAPress() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let ops = Operations()
            let living = try ops.createPost(title: "a note that stays")
            let doomed = try ops.createPost(title: "a note for the Trash")
            let book = try ops.createReading(name: "the lightning thief", kind: .book)
            let wing = try ops.createWing(name: "variorum")
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            door.enqueue(ask(id: living.id, title: "a note that stays"), now: t0)
            door.enqueue(ask(id: doomed.id, title: "a note for the Trash"), now: t0)
            door.enqueue(ask(id: book.id, rung: .writeNew, kind: .book, title: "the lightning thief"), now: t0)
            door.enqueue(ask(id: wing.id, rung: .writeNew, kind: .wing, title: "variorum"), now: t0)
            try ops.deleteReading(book.id)
            try ops.deleteWing(wing.id)
            #expect(try await settle {
                door.askBoard.asks(.book(book.id)).isEmpty && door.askBoard.wingAsks.isEmpty
            }, "a book's and a wing's death take their marks — the masthead's included — with no press")
            #expect(!door.askBoard.asks(.note(living.id)).isEmpty, "a living place's ask stays")
            // The watch's restarts settle; then a note goes to the Trash. The
            // watch sleeps through it (a note's death is indistinguishable from
            // an autosave — RegionObservationTests' measured limit): its row
            // is gone everywhere, but Waiting still lists it…
            try await Task.sleep(for: .milliseconds(200))
            try ops.deleteContainer(doomed.id)
            try await Task.sleep(for: .milliseconds(200))
            #expect(door.ask(ask(id: doomed.id).id) != nil, "the watch is autosave-quiet, so it misses a note's death")
            // …until Waiting renders, which re-validates every waiting ask.
            await door.revalidateAsks()
            #expect(door.askBoard.asks(.note(doomed.id)).isEmpty, "Waiting's render: the dead note's row leaves")
            #expect(door.waiting.map(\.ask.scopeID) == [living.id])
            #expect(session.status.spoken == nil && door.note == nil, "silent — she pressed nothing")
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
        // 13n-c O-4 (A JUSTIFIED EDIT, the ritual — her ask: no provider
        // hardwired outside the setup): the client-named undo in the Edit
        // menu's own words, composed by the menu's own functions over a
        // PLACEHOLDER name, never one provider's client.
        let placeholder = EditorCommands.undoMenuTitle(
            for: Operations.MCPWriteAct.take.undoLabel(client: "\u{2039}name\u{203A}"))
        #expect(placeholder == "Undo \u{2039}name\u{203A}'s take")
        #expect(mcp?.items.contains { $0.does.contains("(\u{201C}\(placeholder)\u{201D})") } == true,
                "the client-named undo, in the words the Edit menu really says")
        #expect(mcp?.items.allSatisfy { !$0.does.localizedCaseInsensitiveContains("claude") } == true)
        let writing = HelperView.groups.first { $0.title == "Writing" }?.items.map(\.keys) ?? []
        #expect(!writing.contains("\u{2325}\u{2318}O") && !writing.contains("\u{2325}\u{2318}A"),
                "moved to the MCP group, not doubled")
        #expect(HelperView.shortcutKeysShown.isSuperset(of: ["\u{2318}L", "\u{2325}\u{2318},"]))
        // Stage B fix pass (O-3): the ask's mark is named by its ROLE, never
        // its shape — the glyph may change (O-1 did once); the row stays true.
        #expect(mcp?.items.contains { $0.keys == "a small mark beside a note, book or wing" } == true)
        #expect(mcp?.items.allSatisfy { !$0.keys.contains("filled") && !$0.does.contains("filled") } == true)
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
