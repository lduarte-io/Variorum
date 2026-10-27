//
//  WingPaletteDoorsTests.swift
//  VariorumTests (Mac)
//
//  VX-377 (the VX-620 run, batch 4) — MOVE / COPY TO WING FROM THE KEYBOARD.
//  Her words (2026-10-16): "hmm yeah go ahead and file a ticket for that."
//  (2026-10-21): "The keyboard shortcut for moving something to a wing I also
//  basically need NOW for my own use - it should pull up a selector that I can
//  also operate via keyboard to make it truly fast."
//
//  What is pinned here:
//  · the doors — `.palette` on the three acts, the target-less door's gate as
//    registry DATA (a pane showing a note / a book, and another wing);
//  · ⌘K's listing — the three rows only where they act, never on the daily
//    Journal, never the note's and the book's "Move to Wing" together; every
//    other palette row listed as before;
//  · the press — the row asks the window for the selector, or says why not;
//  · the selector — the submenu's own rows, the switcher's brain (type, ↑/↓, ⏎),
//    the shared acts and their confirms; MOUNTED: it arrives with the keyboard
//    in its field, typing filters, ⏎ chooses, Esc closes;
//  · the re-ask — a wing act from ANY door re-asks the window's one-shot wing
//    reads (the sidebar's, mounted; the note ▾ menu's load key).
//
//  RED ON OLD, BY CONSTRUCTION: before this batch none of the three acts had a
//  `.palette` door and their availability was `always` (every gate expectation
//  below fails), `ShellActions` had no listing, request or selector (the pins
//  that drive them do not compile against the old tree), and the window's wing
//  reads keyed on nothing a door outside their own surface could change — the
//  sidebar pin's premise is the VX-439 m-3 pin's own ("nothing else re-keys the
//  reads"), here with no `done()` to call.
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
@Suite("VX-377 — Move/Copy to Wing from ⌘K: the doors, their gates, the keyboard selector, the re-ask", .serialized)
struct WingPaletteDoorsTests {
    // MARK: - Harness

    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    private static func source(_ path: String) throws -> String {
        try String(contentsOf: appRoot.appending(path: path), encoding: .utf8)
    }

    /// The model pins' world (deterministic ids).
    private func withWorld<T>(
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 377))
        } operation: { @MainActor in
            try await body(AppSession(database: db), db)
        }
    }

    /// The mounted pins' world: the LIVE uuid generator (the DEBUG-oracle
    /// keying rule — `SidebarNoteRowMenuTests`' rig).
    private func withMountedWorld<T>(
        _ body: @MainActor (AppSession, AppDatabase) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        return try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 3770))
        } operation: { @MainActor in
            try await body(AppSession(database: db), db)
        }
    }

    private func pump() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.01))
    }

    private func poll(_ condition: () -> Bool) async -> Bool {
        for _ in 0..<300 {
            if condition() { return true }
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
        }
        return condition()
    }

    private func settle(_ window: NSWindow, _ hosting: NSView, turns: Int = 30) async {
        for _ in 0..<turns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }

    private func wing(of postID: String, _ db: AppDatabase) async throws -> String? {
        try await db.read { db in
            try String.fetchOne(db, sql: "SELECT wing_id FROM container WHERE id = ?", arguments: [postID])
        }
    }

    private func spoken(_ session: AppSession) -> String? { session.status.spoken?.text }

    private static let wingActs: [CapabilityID] = [.moveNoteToWing, .copyNoteToWing, .moveBookToWing]

    private static func reading(_ id: String, _ kind: ReadingKind = .book, profile: String? = nil) -> Reading {
        Reading(
            id: id, name: id, kind: kind, profile: profile,
            createdAt: Date(timeIntervalSince1970: 0), updatedAt: Date(timeIntervalSince1970: 0))
    }

    // MARK: - The doors (P-1) and the target-less door's gate (DATA)

    @Test func theThreeWingActsGainThePaletteDoorWithTheirGateAsData() {
        for id in Self.wingActs {
            #expect(CapabilityRegistry.capability(id).doors.contains(.palette), "\(id) is typeable from ⌘K")
            #expect(ShellActions.paletteActs.contains(id), "the palette renders \(id)")
            #expect(CapabilityRegistry.capability(id).shortcutLabel == nil, "no chord — RB-6 is her call")
        }
        func act(_ id: CapabilityID, note: Bool = false, book: Bool = false, wings: Int) -> Bool {
            CapabilityRegistry.isEnabled(id, in: CapabilityContext(
                focusedPaneShowsNote: note, focusedPaneShowsBook: book, wingCount: wings))
        }
        for id in [CapabilityID.moveNoteToWing, .copyNoteToWing] {
            #expect(act(id, note: true, wings: 2), "\(id): a note in the pane and another wing")
            #expect(act(id, note: true, wings: 5))
            #expect(!act(id, note: true, wings: 1), "\(id): one wing — nowhere to go (P-2)")
            #expect(!act(id, book: true, wings: 2), "\(id): a book pane is the BOOK's context")
            #expect(!act(id, wings: 2), "\(id): a place, the scraps — no note in the pane")
        }
        #expect(act(.moveBookToWing, book: true, wings: 2), "a book in the pane and another wing")
        #expect(!act(.moveBookToWing, book: true, wings: 1), "one wing")
        #expect(!act(.moveBookToWing, note: true, wings: 2), "a note pane is the NOTE's context")
        #expect(!act(.moveBookToWing, wings: 3))
        // The two acts wear ONE verb ("Move to Wing"): they never act together.
        #expect(CapabilityRegistry.capability(.moveNoteToWing).verb
                == CapabilityRegistry.capability(.moveBookToWing).verb)
        for note in [false, true] {
            for book in [false, true] where !(note && book) {
                for wings in [1, 2] {
                    #expect(!(act(.moveNoteToWing, note: note, book: book, wings: wings)
                              && act(.moveBookToWing, note: note, book: book, wings: wings)))
                }
            }
        }
    }

    // MARK: - ⌘K's listing (P-2: only where they act)

    @Test func thePaletteListsTheWingRowsExactlyUnderTheirGates() async throws {
        let book = Self.reading("Alpha")
        let gathering = Self.reading("Gathered", .gathering)
        let journal = Self.reading("journal", profile: Queries.dailyJournalBookProfile)
        typealias Facts = WingPaletteDoors.Facts
        let table: [(Facts, Set<CapabilityID>, String)] = [
            (Facts(focus: .note("n"), wingCount: 2), [.moveNoteToWing, .copyNoteToWing], "a note, two wings"),
            (Facts(focus: .note("n"), wingCount: 1), [], "a note, one wing"),
            (Facts(focus: .book(book), wingCount: 2), [.moveBookToWing], "a book, two wings"),
            (Facts(focus: .book(gathering), wingCount: 3), [.moveBookToWing], "a gathering moves too"),
            (Facts(focus: .book(journal), wingCount: 2), [], "never the daily Journal"),
            (Facts(focus: .book(book), wingCount: 1), [], "a book, one wing"),
            (Facts(focus: .other, wingCount: 3), [], "a place"),
        ]
        for (facts, expected, why) in table {
            let listed = Set(Self.wingActs.filter { WingPaletteDoors.lists($0, facts) })
            #expect(listed == expected, "\(why): \(listed)")
            for id in ShellActions.paletteActs where !Self.wingActs.contains(id) {
                #expect(WingPaletteDoors.lists(id, facts), "\(id) keeps the palette's standing grammar (\(why))")
            }
        }
        // The same answer, as the rows ⌘K draws.
        try await withWorld { session, _ in
            let actions = ShellActions(session: session, shell: ShellRouter())
            let move = WingCopy.moveToWingVerb
            let copy = WingCopy.copyToWingVerb
            @MainActor func titles(_ facts: Facts) -> [String] {
                actions.paletteEntries(listing: facts).map(\.title)
            }
            let onNote = titles(Facts(focus: .note("n"), wingCount: 2))
            #expect(onNote.filter { $0 == move }.count == 1 && onNote.filter { $0 == copy }.count == 1)
            let onBook = titles(Facts(focus: .book(book), wingCount: 2))
            #expect(onBook.filter { $0 == move }.count == 1 && !onBook.contains(copy))
            let elsewhere = titles(Facts(focus: .other, wingCount: 2))
            #expect(!elsewhere.contains(move) && !elsewhere.contains(copy))
            #expect(elsewhere.count == ShellActions.paletteActs.count - 3, "only the three leave")
            #expect(actions.paletteEntries().count == ShellActions.paletteActs.count,
                    "the unfiltered list (harnesses) keeps every act row")
        }
    }

    /// The facts are the FOCUSED pane's at the press — a note, a book read
    /// whole (its marker), a place — and the library's wing count.
    @Test func theListingFactsAreWhatTheFocusedPaneShows() async throws {
        try await withWorld { session, _ in
            let ops = session.operations
            let note = try ops.createPost(title: "moving note")
            let book = try ops.createReading(name: "Alpha", kind: .book)
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-10-02").container
            _ = ops.shelveInDailyJournalBook(entry.id)
            let journalID = try #require(try ops.dailyJournalBookID())
            let wings = WingsModel(session: session)
            _ = try ops.createWing(name: "Work")
            await wings.load()
            #expect(session.wing.wingCount == 2)
            let shell = ShellRouter()
            let actions = ShellActions(session: session, shell: shell)

            shell.workspace.select(.post(note.id))
            var facts = await actions.paletteListingFacts()
            #expect(facts == WingPaletteDoors.Facts(focus: .note(note.id), wingCount: 2))

            shell.workspace.select(.reading(book.id))
            facts = await actions.paletteListingFacts()
            guard case .book(let read) = facts.focus else {
                Issue.record("a book pane reads the book — got \(facts.focus)")
                return
            }
            #expect(read.id == book.id)
            #expect(WingPaletteDoors.lists(.moveBookToWing, facts))
            #expect(await actions.listedPaletteEntries().contains { $0.title == WingCopy.moveToWingVerb })

            shell.workspace.select(.reading(journalID))
            facts = await actions.paletteListingFacts()
            #expect(!WingPaletteDoors.lists(.moveBookToWing, facts), "the daily Journal never lists the row")
            #expect(!(await actions.listedPaletteEntries()).contains { $0.title == WingCopy.moveToWingVerb })

            shell.workspace.select(.library)
            facts = await actions.paletteListingFacts()
            #expect(facts.focus == .other)
        }
    }

    // MARK: - The press

    @Test func aRowAsksTheWindowForTheSelectorOrSaysWhyNot() async throws {
        try await withWorld { session, _ in
            let ops = session.operations
            let note = try ops.createPost(title: "moving note")
            let book = try ops.createReading(name: "Alpha", kind: .book)
            let wings = WingsModel(session: session)
            await wings.load()
            let shell = ShellRouter()
            let actions = ShellActions(session: session, shell: shell)

            // One wing: the press speaks the act's own note and asks nothing.
            shell.workspace.select(.post(note.id))
            actions.openWingDestination(.moveNoteToWing)
            #expect(shell.wingDestinationRequest == nil)
            #expect(spoken(session) == CapabilityRegistry.capability(.moveNoteToWing).unavailableNote)
            #expect(session.status.spoken?.kind == .refusal)
            session.status.clear()

            _ = try ops.createWing(name: "Work")
            await wings.load()
            actions.openWingDestination(.moveNoteToWing)
            let first = try #require(shell.wingDestinationRequest)
            #expect(first.act == .moveNote(note.id))
            #expect(spoken(session) == nil, "nothing to say — the selector opens")
            actions.openWingDestination(.copyNoteToWing)
            let second = try #require(shell.wingDestinationRequest)
            #expect(second.act == .copyNote(note.id))
            #expect(second.token != first.token, "every press is its own request")
            // The palette row runs exactly this.
            shell.wingDestinationRequest = nil
            let row = try #require(actions.paletteEntries(listing: WingPaletteDoors.Facts(
                focus: .note(note.id), wingCount: 2)).first { $0.title == WingCopy.copyToWingVerb })
            row.action()
            #expect(shell.wingDestinationRequest?.act == .copyNote(note.id))

            // A book pane: the book's row; the note's acts speak.
            shell.wingDestinationRequest = nil
            shell.workspace.select(.reading(book.id))
            actions.openWingDestination(.copyNoteToWing)
            #expect(shell.wingDestinationRequest == nil)
            #expect(spoken(session) == CapabilityRegistry.capability(.copyNoteToWing).unavailableNote)
            actions.openWingDestination(.moveBookToWing)
            #expect(shell.wingDestinationRequest?.act == .moveBook(book.id))
        }
    }

    // MARK: - The selector (model)

    /// The submenu's rows exactly (Home first, the note's own wing never
    /// listed); the switcher's keys: type filters (case- and diacritic-
    /// insensitive), ↑/↓ step and wrap, ⏎ chooses; the act is the shared one.
    @Test func theSelectorListsTheSubmenusRowsAndItsKeysChoose() async throws {
        try await withWorld { session, db in
            let ops = session.operations
            let work = try ops.createWing(name: "Work")
            let letters = try ops.createWing(name: "Letters")
            let note = try ops.createPost(title: "moving note")
            let wings = WingsModel(session: session)
            await wings.load()

            let model = try #require(await WingDestinationModel.open(
                .init(act: .moveNote(note.id), token: UUID()), wings: wings, session: session))
            #expect(model.brain.rows.map(\.id) == wings.destinations(from: "").map(\.id))
            #expect(model.brain.rows.map(\.id) == [work.id, letters.id], "every other wing, never its own")
            #expect(model.brain.highlight == work.id, "the first destination waits for ⏎")
            #expect(model.prompt == "Move to a wing")
            #expect(model.foot == "\u{201C}moving note\u{201D} is in Home \u{00B7} \u{23CE} chooses \u{00B7} esc closes")
            model.move(by: 1)
            #expect(model.brain.highlight == letters.id, "↓")
            model.move(by: 1)
            #expect(model.brain.highlight == work.id, "↓ wraps")
            model.move(by: -1)
            #expect(model.brain.highlight == letters.id, "↑ wraps")
            model.type("WOR")
            #expect(model.brain.visible.map(\.id) == [work.id] && model.brain.highlight == work.id)
            model.type("zzz")
            #expect(model.brain.visible.isEmpty)
            #expect(await model.choose(model.brain.returnPressed()) == false, "nothing listed — ⏎ stays")
            #expect(try await wing(of: note.id, db) == "")
            model.type("let")
            #expect(await model.choose(model.brain.returnPressed()), "a bookless note moves at once — it closes")
            #expect(try await wing(of: note.id, db) == letters.id)
            #expect(spoken(session) == WingCopy.moved("moving note", to: "Letters", left: 0), "the act's receipt")
            #expect(session.status.spoken?.kind == .receipt)

            // A note living in ANOTHER wing (an open note can be): its rows are
            // every wing but ITS wing — Home included.
            let away = try #require(await WingDestinationModel.open(
                .init(act: .moveNote(note.id), token: UUID()), wings: wings, session: session))
            #expect(away.brain.rows.map(\.id) == ["", work.id])
            #expect(away.foot.contains("is in Letters"))

            // Copy: the original stays; the copy lands in the chosen wing.
            let copier = try #require(await WingDestinationModel.open(
                .init(act: .copyNote(note.id), token: UUID()), wings: wings, session: session))
            #expect(copier.prompt == "Copy to a wing")
            #expect(await copier.choose(copier.brain.pick(work.id)), "a click chooses too")
            #expect(try await wing(of: note.id, db) == letters.id, "the original stays where it was")
            let copies = try await db.read { db in
                try Int.fetchOne(db, sql: """
                    SELECT COUNT(*) FROM container WHERE kind = 'post' AND wing_id = ? AND deleted_at IS NULL
                    """, arguments: [work.id]) ?? 0
            }
            #expect(copies == 1)
            #expect(spoken(session) == WingCopy.copied("moving note", to: "Work"))
        }
    }

    /// A note in books asks first (the books it leaves listed), and the
    /// confirm's Move is the act; a book always asks; the daily Journal and a
    /// lone wing never open a selector — each says why.
    @Test func aNoteInABookAndEveryBookAskFirstAndTheGatesHoldAtOpen() async throws {
        try await withWorld { session, db in
            let ops = session.operations
            let wings = WingsModel(session: session)
            let note = try ops.createPost(title: "membered note")
            let book = try ops.createReading(name: "Alpha", kind: .book)
            _ = try ops.addPostToReading(note.id, to: book.id)

            // One wing: nothing to choose — said, never an empty selector.
            await wings.load()
            #expect(await WingDestinationModel.open(
                .init(act: .moveNote(note.id), token: UUID()), wings: wings, session: session) == nil)
            #expect(spoken(session) == WingCopy.switchWingUnavailable)
            session.status.clear()

            let work = try ops.createWing(name: "Work")
            await wings.load()
            let model = try #require(await WingDestinationModel.open(
                .init(act: .moveNote(note.id), token: UUID()), wings: wings, session: session))
            #expect(await model.choose(.commit(work.id)) == false, "it asks — the selector stays under the confirm")
            let ask = try #require(model.pendingMove)
            #expect(ask.leaves == ["Alpha"] && ask.wingID == work.id)
            #expect(try await wing(of: note.id, db) == "", "nothing moved before the confirm")
            await wings.move(postID: ask.postID, title: ask.title, to: ask.wingID)  // the confirm's Move
            #expect(try await wing(of: note.id, db) == work.id)

            let shelf = try ops.createReading(name: "Beta", kind: .book)
            let bookModel = try #require(await WingDestinationModel.open(
                .init(act: .moveBook(shelf.id), token: UUID()), wings: wings, session: session))
            #expect(bookModel.subject == "Beta")
            #expect(await bookModel.choose(.commit(work.id)) == false)
            #expect(bookModel.pendingBookMove?.readingID == shelf.id, "a book always asks")

            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-10-02").container
            _ = ops.shelveInDailyJournalBook(entry.id)
            let journalID = try #require(try ops.dailyJournalBookID())
            session.status.clear()
            #expect(await WingDestinationModel.open(
                .init(act: .moveBook(journalID), token: UUID()), wings: wings, session: session) == nil)
            #expect(spoken(session) == OpsRefusalCopy.message(
                for: OperationError.dailyJournalIsHomeOnly(id: journalID)))
        }
    }

    // MARK: - The selector, MOUNTED — "a selector that I can also operate via keyboard"

    private final class Flag { var value = false }

    private func field(_ placeholder: String, in view: NSView) -> NSTextField? {
        if let field = view as? NSTextField, field.isEditable, field.placeholderString == placeholder {
            return field
        }
        for sub in view.subviews { if let found = field(placeholder, in: sub) { return found } }
        return nil
    }

    /// It ARRIVES with the keyboard in its field (no click), typing filters,
    /// ⏎ chooses and the act lands; Esc closes and nothing moves. (↑/↓ are the
    /// palette's and the switcher's `.onKeyPress` idiom — pinned at the model
    /// above, driven for real by the walk.)
    @Test func theSelectorArrivesFocusedAndAnswersTypingReturnAndEsc() async throws {
        try await withMountedWorld { session, db in
            let ops = session.operations
            _ = try ops.createWing(name: "Work")
            let letters = try ops.createWing(name: "Letters")
            let moving = try ops.createPost(title: "moving note")
            let staying = try ops.createPost(title: "staying note")
            let wings = WingsModel(session: session)
            await wings.load()
            let tokens = VoiceTokens.terminalLight

            @MainActor func mount(_ model: WingDestinationModel, closed: Flag) -> (NSWindow, NSView) {
                let window = NSWindow(
                    contentRect: NSRect(x: 80, y: 80, width: 440, height: 360),
                    styleMask: [.titled], backing: .buffered, defer: false)
                window.isReleasedWhenClosed = false
                let hosting = NSHostingView(rootView: WingDestinationSheet(
                    model: model, tokens: tokens, close: { closed.value = true }))
                hosting.frame = NSRect(x: 0, y: 0, width: 440, height: 360)
                window.contentView = hosting
                window.makeKeyAndOrderFront(nil)
                return (window, hosting)
            }

            // ⏎ — the move.
            let model = try #require(await WingDestinationModel.open(
                .init(act: .moveNote(moving.id), token: UUID()), wings: wings, session: session))
            let closed = Flag()
            let (window, hosting) = mount(model, closed: closed)
            defer { window.orderOut(nil); window.close() }
            await settle(window, hosting)
            let input = try #require(field(tokens.chromeLabel(model.prompt), in: hosting), "the field is drawn")
            let editor = try #require(input.currentEditor() as? NSTextView,
                                      "the field is EDITING on arrival — nobody clicked it")
            #expect(window.firstResponder === editor, "the keyboard is in the field: \(String(describing: window.firstResponder))")
            editor.insertText("let", replacementRange: editor.selectedRange())
            await settle(window, hosting, turns: 10)
            #expect(model.brain.query == "let", "typing reached the brain")
            #expect(model.brain.highlight == letters.id, "typing filters to the match")
            editor.doCommand(by: #selector(NSResponder.insertNewline(_:)))
            #expect(await poll { closed.value }, "⏎ chose — the selector closed")
            #expect(try await wing(of: moving.id, db) == letters.id, "⏎ ran the move")

            // Esc — closes, nothing moves.
            let other = try #require(await WingDestinationModel.open(
                .init(act: .moveNote(staying.id), token: UUID()), wings: wings, session: session))
            let dismissed = Flag()
            let (window2, hosting2) = mount(other, closed: dismissed)
            defer { window2.orderOut(nil); window2.close() }
            await settle(window2, hosting2)
            let esc = try #require(NSEvent.keyEvent(
                with: .keyDown, location: .zero, modifierFlags: [],
                timestamp: ProcessInfo.processInfo.systemUptime,
                windowNumber: window2.windowNumber, context: nil,
                characters: "\u{1B}", charactersIgnoringModifiers: "\u{1B}",
                isARepeat: false, keyCode: 53))
            NSApp.sendEvent(esc)
            #expect(await poll { dismissed.value }, "Esc closed the selector")
            #expect(try await wing(of: staying.id, db) == "", "and nothing moved")
        }
    }

    // MARK: - The re-ask (VX-425's rule, on every door)

    /// Every LANDED wing act bumps the window's signal; a refusal does not —
    /// and the note ▾ menu's context reloads on it (its load key).
    @Test func everyLandedWingActSignalsAndTheNoteMenusContextKeysOnIt() async throws {
        try await withWorld { session, _ in
            let ops = session.operations
            let work = try ops.createWing(name: "Work")
            let wings = WingsModel(session: session)
            await wings.load()
            let note = try ops.createPost(title: "a note")
            let before = NoteMenuWingContext.loadKey(postID: note.id, wings: wings)
            #expect(await wings.moveAsk(postID: note.id, title: "a note", to: work.id) == nil)
            #expect(wings.actGeneration == 1, "a move landed")
            #expect(NoteMenuWingContext.loadKey(postID: note.id, wings: wings) != before,
                    "the note ▾ menu re-loads its note's wing")
            await wings.copy(postID: note.id, title: "a note", to: "")
            #expect(wings.actGeneration == 2, "a copy landed")

            // A refusal changes nothing, so it signals nothing.
            let frozen = try ops.createPost(title: "in a finished book")
            let finished = try ops.createReading(name: "Done", kind: .book)
            _ = try ops.addPostToReading(frozen.id, to: finished.id)
            try ops.lockReading(finished.id)
            #expect(await wings.moveAsk(postID: frozen.id, title: "in a finished book", to: work.id) == nil)
            #expect(session.status.spoken?.kind == .refusal)
            #expect(wings.actGeneration == 2)

            let created = try ops.createReading(name: "Alpha", kind: .book)
            let read = try await session.database.read { db in try Queries.reading(db, id: created.id) }
            let book = try #require(read)
            let ask = try #require(await wings.bookMoveAsk(reading: book, to: work.id))
            await wings.moveBook(ask)
            #expect(wings.actGeneration == 3, "a book move landed")

            session.wing.switchTo(work.id)
            let everything = try #require(await wings.contentsMoveAsk(to: ""))
            await wings.moveContents(everything)
            #expect(wings.actGeneration == 4, "move everything landed")

            // The bar's modifier keys its load on it (both bars compose it).
            let source = try Self.source("Variorum/Core/Views/WingsModel.swift")
            #expect(source.contains(".task(id: NoteMenuWingContext.loadKey(postID: postID, wings: wings))"))
        }
    }

    /// **The sidebar's one-shot wing reads re-ask after a move from ANY door**
    /// — here the act ⌘K's selector runs (`WingsModel.moveAsk`), with NO call
    /// to the column's own after-act re-ask. The VX-439 m-3 pin needed that
    /// `done()` precisely because nothing else re-keyed the reads; on the old
    /// keys this pin stays stale (the row's doors read from Home, no indicator).
    @Test func aWingActFromAnyDoorReasksTheSidebarsReads() async throws {
        try await withMountedWorld { session, db in
            let ops = session.operations
            let work = try ops.createWing(name: "Work")
            let moving = try ops.createPost(title: "moving note")
            let staying = try ops.createPost(title: "staying note")
            let workspace = WorkspaceModel()
            workspace.visit(.post(moving.id))
            workspace.visit(.post(staying.id))
            workspace.select(.library)
            let stars = StarsModel(session: session)
            let observing = Task { await stars.start() }
            defer { observing.cancel() }
            let wings = WingsModel(session: session)
            await wings.load()
            let theme = ThemeStore(session: session)
            SidebarGeometry.forgetSections(for: workspace)
            defer { SidebarGeometry.forgetSections(for: workspace) }
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 230, height: 700),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            window.contentView = NSHostingView(rootView: SidebarView(
                session: session, model: LibraryViewModel(session: session),
                pool: PoolViewModel(session: session), workspace: workspace, stars: stars,
                selection: Binding(
                    get: { workspace.selections[workspace.focusedPane] },
                    set: { picked in if let picked { workspace.select(picked) } }),
                wings: wings)
                .frame(width: 230)
                .environment(theme))
            window.makeKeyAndOrderFront(nil)
            let key = SidebarGeometry.bodyKey(for: workspace)
            #expect(await poll { SidebarGeometry.noteRowFromWings[key] != nil && SidebarGeometry.openRowWingNames[key] != nil },
                    "the rows' wing reads ran")
            #expect(SidebarGeometry.noteRowFromWings[key]?[moving.id] == nil, "it lives in the current wing (Home)")
            #expect(SidebarGeometry.openRowWingNames[key]?[moving.id] == nil, "no indicator")

            // The selector's act — no row door, no `done()`.
            #expect(await wings.moveAsk(postID: moving.id, title: "moving note", to: work.id) == nil)
            #expect(try await wing(of: moving.id, db) == work.id, "the premise: the note moved")
            #expect(workspace.openNotes.shown.contains(moving.id) && wings.currentID == "",
                    "the premise: the row stayed and she stands in Home")
            #expect(await poll { SidebarGeometry.noteRowFromWings[key]?[moving.id] == work.id },
                    "re-asked: the row's doors read from Work — \(String(describing: SidebarGeometry.noteRowFromWings[key]))")
            let from = SidebarGeometry.noteRowFromWings[key]?[moving.id] ?? wings.currentID
            #expect(wings.destinations(from: from).map(\.id) == [""], "its Move/Copy ▸ now list Home, never Work")
            #expect(await poll { SidebarGeometry.openRowWingNames[key]?[moving.id] == "Work" },
                    "the row's indicator names its new wing — \(String(describing: SidebarGeometry.openRowWingNames[key]))")
        }
    }

    // MARK: - The window's wiring (read)

    /// The window presents the selector from the request, the palette asks the
    /// shell's source once per open, and executes the list its rows were built
    /// from.
    @Test func theWindowPresentsTheSelectorAndThePaletteListsPerOpen() throws {
        let root = try Self.source("Variorum/RootView.swift")
        #expect(root.contains(".sheet(item: $wingDestination)"))
        #expect(root.contains("WingDestinationModel.open(request, wings: wings, session: session)"))
        #expect(root.contains("palette.commandSource = { navigation + (await actions.listedPaletteEntries()) }"))
        let palette = try Self.source("Variorum/Features/CommandPalette/CommandPalette.swift")
        #expect(palette.contains("await model.prepare()\n            await model.refresh()"),
                "this open's rows are read before its first listing")
        #expect(palette.contains("listedCommands[index].action()"), "⏎ runs the command its row was listed as")
        let sheet = try Self.source("Variorum/Core/Views/WingDestinationSheet.swift")
        #expect(sheet.contains(".task { fieldFocused = true }"), "it arrives focused")
        #expect(sheet.contains(".onKeyPress(.downArrow)") && sheet.contains(".onKeyPress(.upArrow)"))
        #expect(sheet.contains("WingSwitcherKeyCatcher"), "Esc through the switcher's window-scoped monitor")
    }
}
