//
//  MCPAskAndReceiptTests.swift
//  VariorumTests (Mac)
//
//  13n-b U2 — the app half of the write rungs: the just-in-time ask's queue
//  and durations (AF-6), the ask and receipt words (P-13n-1's boundary), the
//  grant sheet's rungs (mockup §3), the Private mark's faces (R-13nb-4) and
//  their registry declarations (P-1).
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 41))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

private func ask(
    _ client: String = "claude-code", id: String = "n1", rung: MCPGrantRule.Rung = .suggest,
    fence: MCPGrantRule.Fence? = nil, kind: MCPGrantRule.ScopeKind = .note, title: String = "ch 7"
) -> MCPAsk {
    MCPAsk(clientName: client, scopeKind: kind, scopeID: id, title: title, rung: rung, fence: fence)
}

private func receipt(
    _ act: Operations.MCPWriteAct, target: String = "n1", title: String? = "ch 1", detail: String? = nil,
    client: String = "claude-code", count: Int = 1
) -> MCPWriteReceipt {
    MCPWriteReceipt(clientName: client, act: act, targetID: target, targetTitle: title, detail: detail, count: count)
}

@MainActor
@Suite("13n-b U2 — the ask, the receipts, the rungs and the Private faces", .serialized)
struct MCPAskAndReceiptTests {
    // MARK: - The ask (AF-6)

    @Test func theAskQueueDedupesCapsAndNeverDropsTheOneOnScreen() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            door.enqueue(ask(id: "first"))
            door.enqueue(ask(id: "first"))
            #expect(door.asks.count == 1, "one ask per client · target · rung")
            door.enqueue(ask(id: "first", rung: .writeNew))
            #expect(door.asks.count == 2, "another rung is another ask")
            for index in 0..<20 { door.enqueue(ask(id: "spam-\(index)")) }
            #expect(door.asks.count == MCPDoor.askCap)
            #expect(door.presentedAsk?.scopeID == "first", "the ask on screen is never the one forgotten")
            door.answer(ask(id: "first"), .dontAllow)
            #expect(door.presentedAsk?.scopeID != "first" && door.asks.count == MCPDoor.askCap - 1)
            door.detach()
            #expect(door.asks.isEmpty, "a closed library's asks die with it")
        }
    }

    @Test func anAskOffersOnlyTheDurationsThatCanActAsNamed() {
        let door = MCPDoor(serverAllowed: false)
        #expect(door.durations(for: ask()) == [.once, .always], "while connected only to a connected client")
        #expect(door.durations(for: ask(fence: .journal)) == [.once], "a fenced target never offers always")
        #expect(door.durations(for: ask(fence: .privateMark)) == [.once])
    }

    @Test func herAnswerMintsTheGrantTheAskNamed() async throws {
        try await withSession { (session: AppSession, db: AppDatabase) async throws in
            let operations = Operations()
            let client = try operations.recordMCPContact(name: "claude-code", version: nil)
            try operations.approveMCPClient(client.id, granting: nil)
            let note = try operations.createPost(title: "ch 7")
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            let asked = ask(id: note.id, rung: .suggest)
            door.enqueue(asked)
            door.answer(asked, .grant(.once))
            #expect(door.asks.isEmpty)
            var grants: [MCPGrantRow] = []
            for _ in 0..<200 {
                grants = try await db.read { try Queries.mcpGrants($0, clientID: client.id) }
                if !grants.isEmpty { break }
                try await Task.sleep(for: .milliseconds(10))
            }
            #expect(grants.map(\.rung) == [.suggest] && grants.first?.scopeID == note.id
                    && grants.first?.duration == .once && grants.first?.scopeKind == .note)
        }
    }

    @Test func theAsksWordsAreTheMockupsAndTheFencesSayWhy() {
        #expect(MCPAskCopy.title(ask(rung: .read, title: "morning pages — oct 9"))
                == "claude-code asks to read “morning pages — oct 9”")
        #expect(MCPAskCopy.title(ask(rung: .writeNew, kind: .wing, title: "Home"))
                == "claude-code asks to write new in the Home wing")
        // 13n-c U1 (justified edit, the ritual — R-AIR-1, J8): the fence keys
        // on THE daily Journal now; the VX-156 mockup §8's words verbatim.
        #expect(MCPAskCopy.lead(ask(fence: .journal))
                == "A daily Journal entry. Your daily Journal is only ever shared one ask at a time.",
                "mockup §8 verbatim")
        #expect(MCPAskCopy.lead(ask(fence: .privateMark)).hasPrefix("Marked Private."), "the journal line's twin")
        #expect(MCPAskCopy.lead(ask(rung: .suggest)).contains("it cannot touch a word you wrote"))
        #expect(CapabilityRegistry.capability(.mcpAnswerAsk).doors == [.surface])
    }

    // MARK: - Receipts (the app's voice — P-13n-1)

    @Test func aRunOfActsSpeaksAsTheMockupsOneLine() {
        #expect(MCPReceiptCopy.line([receipt(.take), receipt(.take), receipt(.lens, detail: "fact check")])
                == "claude-code added 2 takes and saved the lens “fact check” · ⌥⌘Z undoes",
                "the mockup §5 line's shape")
        #expect(MCPReceiptCopy.line([receipt(.take)]) == "claude-code added a take · ⌥⌘Z undoes")
        // U2 walk W-2: a run too long for the bar speaks as a count, so the
        // undo is never truncated away.
        let long = [receipt(.take), receipt(.take), receipt(.lens, detail: "english readings"),
                    receipt(.comment), receipt(.take)]
        #expect(MCPReceiptCopy.line(long) == "claude-code made 5 changes · ⌥⌘Z undoes")
        #expect(MCPReceiptCopy.line(long).count <= MCPReceiptCopy.budget)
        #expect(MCPReceiptCopy.line([receipt(.importBook, title: "worksheets", count: 3)])
                == "claude-code imported the book “worksheets” (3 notes) · ⌥⌘Z undoes")
        #expect(MCPReceiptCopy.line([receipt(.bookAdd, title: "lesson 2", detail: "lessons")])
                == "claude-code added “lesson 2” to “lessons” · ⌥⌘Z undoes")
    }

    @Test func theDoorCoalescesOneClientsRunOnOneTargetAndStartsAfreshElsewhere() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            session.status.receiptStyle = .quiet
            let now = Date(timeIntervalSince1970: 1_800_000_000)
            door.landReceipt(receipt(.take), now: now)
            door.landReceipt(receipt(.take), now: now.addingTimeInterval(5))
            #expect(session.status.spoken?.text == "claude-code added 2 takes · ⌥⌘Z undoes")
            door.landReceipt(receipt(.take, target: "n2", title: "ch 2"), now: now.addingTimeInterval(6))
            #expect(session.status.spoken?.text == "claude-code added a take · ⌥⌘Z undoes",
                    "another target starts a fresh run")
            door.landReceipt(receipt(.take, target: "n2", title: "ch 2"), now: now.addingTimeInterval(7))
            #expect(session.status.spoken?.text == "claude-code added 2 takes · ⌥⌘Z undoes")
            door.landReceipt(receipt(.take, target: "n2", title: "ch 2"),
                       now: now.addingTimeInterval(7 + MCPDoor.receiptWindow + 1))
            #expect(session.status.spoken?.text == "claude-code added a take · ⌥⌘Z undoes",
                    "past the window a run starts afresh")
        }
    }

    // MARK: - The grant sheet's rungs (mockup §3)

    /// 13n-c U1 (R-AIR-1, J8): the six shipped sentences R-AIR-1 made false,
    /// each in the VX-156 mockup §8's recommended words — only THE daily
    /// Journal and anything Private still ask; no sentence says "journals".
    @Test func theFenceSentencesNameTheDailyJournalNotEveryJournal() {
        #expect(MCPPaneCopy.wingDetail("Home")
                == "everything in Home except your daily Journal and anything Private, which always ask")
        #expect(MCPPaneCopy.openBookDetail == "your daily Journal and anything Private still ask every time")
        #expect(MCPPaneCopy.noBooks
                == "No book can be shared yet (your daily Journal and Private books are shared one ask at a time).")
        #expect(MCPPaneCopy.refusal(OperationError.mcpGrantScopeFenced(kind: "book", id: "x"))
                == "Your daily Journal and Private notes are shared one ask at a time, never by a standing grant.")
        #expect(MCPAskCopy.lead(ask(fence: .journal))
                == "A daily Journal entry. Your daily Journal is only ever shared one ask at a time.")
        let blurb = SettingsCatalog.rows.first { $0.id == "mcpOpenBook" }?.blurb ?? ""
        #expect(blurb.hasSuffix("your daily Journal and anything Private still ask every time."))
        for sentence in [MCPPaneCopy.wingDetail("Home"), MCPPaneCopy.openBookDetail, MCPPaneCopy.noBooks,
                         MCPPaneCopy.refusal(OperationError.mcpGrantScopeFenced(kind: "book", id: "x")), blurb] {
            #expect(!sentence.lowercased().contains("journals"), "\(sentence)")
        }
    }

    @Test func theGrantSheetOffersTheServedRungsWithTheMockupsSentences() {
        // U3 (justified edit, the ritual): the server serves edit now, so the
        // sheet offers it (U2's pin: "never offered before it serves").
        #expect(MCPPaneCopy.offeredRungs == [.read, .suggest, .writeNew, .edit])
        #expect(MCPPaneCopy.rungDetail(.edit)
                == "it can also edit takes — with a commit before and after every change, so you can always compare and come back",
                "mockup §3's edit sentence")
        #expect(MCPPaneCopy.rungDetail(.suggest)
                == "it can add new takes and comments beside your text, and save a lens of its takes — it cannot touch a word you wrote")
        #expect(MCPPaneCopy.rungDetail(.writeNew) == "it can also make new notes, apply tags and build books")
        #expect(MCPPaneCopy.confirm(verb: "Grant", rung: .suggest, place: "the lightning thief", duration: .connection)
                == "Grant suggest in “the lightning thief” while connected", "mockup §3's confirm")
        // U3 walk W-2 (justified edit, the ritual): the mockup's words stay,
        // and the sentence stays TRUE now that edit can be granted.
        #expect(MCPPaneCopy.enableBlurb.contains("AI work lands as takes beside your own"))
        #expect(MCPPaneCopy.enableBlurb.contains("only where you grant it edit"))
        #expect(!MCPPaneCopy.enableBlurb.contains("no client can overwrite your text"))
        #expect(MCPPaneCopy.rungWord(.suggest) == "read and suggest")
    }

    // MARK: - The Private mark's faces (R-13nb-4)

    @Test func thePrivateRowsAreDeclaredWhereTheyRenderInTheAppsWords() {
        #expect(PrivateMarkCopy.rowWords == "Private — never shared with AI", "her word, R-13nb-4 (iv)")
        #expect(CapabilityRegistry.capability(.markNotePrivate).verb == PrivateMarkCopy.rowWords)
        #expect(CapabilityRegistry.capability(.markNotePrivate).doors == [.bottomBar])
        #expect(CommitBar.renderedCapabilities.contains(.markNotePrivate))
        #expect(TakesBottomBar.renderedCapabilities.contains(.markNotePrivate))
        #expect(CapabilityRegistry.capability(.markBookPrivate).doors == [.surface])
        #expect(BookSettingsSheet.surfaceCapabilities.contains(.markBookPrivate))
        #expect(PrivateMarkCopy.throughBooks(["a", "b", "c"]) == "Private through “a”, “b” and 1 more")
        #expect(PrivateMarkCopy.sharedLine([MCPNoteSharing(clientName: "claude-code", rung: .suggest)])
                == "Shared with AI: claude-code (read and suggest)")
        #expect(PrivateMarkCopy.sharedLine([]) == nil)
    }

    @Test func theNoteRowsStateIsReadPerNoteAndActsThroughTheOp() async throws {
        try await withSession { (session: AppSession, db: AppDatabase) async throws in
            let operations = Operations()
            let book = try operations.createReading(name: "mine", kind: .book)
            let note = try operations.createPost(title: "ch 1")
            _ = try operations.addPostToReading(note.id, to: book.id)
            try operations.setBookPrivate(book.id, true)
            let state = try await db.read { try NotePrivacyState.read($0, postID: note.id) }
            #expect(state.own == false && state.throughBooks == ["mine"])
            #expect(NotePrivacyState.matching(state, postID: "another") == nil, "a stale load never draws")
            await NotePrivacyAct.set(true, postID: note.id, session: session)
            #expect(try await db.read { try Queries.isNotePrivate($0, postID: note.id) })
            #expect(session.status.spoken?.text == PrivateMarkCopy.markedNote)
        }
    }
}
