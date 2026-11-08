//
//  QuickEntryFileWithoutOpeningTests.swift
//  VariorumTests (Mac)
//
//  VX-911 (the VX-914 run, batch 4 — her ask, Nov 8, verbatim: *"it would be
//  nice to have a button + an enter chord … that lets you file a quicknote
//  without entering into the quicknote — sometimes i want to write a bunch and
//  file them in succession from that main page."*). The record, the chord's
//  collision table and the forks RULED (PROVISIONAL): `notes/plans/fixes/
//  vx-914-walkthrough-followups.md`, BATCH 4.
//
//  THE BUILD: the registry's new act `.fileWithoutOpening` (`.surface` — the
//  band's button, declared with the builder `QuickEntryBar`; its only key the
//  capture box's focus-scoped ⌘⏎, declared as the act's alternate). The note
//  is made through ⏎'s own road (`QuickEntryModel.submit`), nothing opens, the
//  band clears, and a quiet receipt says where it landed with a one-press
//  Open ›.
//
//  An IMPROVEMENT (her ask, not a defect): these pin the NEW contract. The one
//  red-on-old by construction is the chord itself — on the pre-fix tree the
//  box answered ⌘⏎ by `super` (nobody's key), so `performKeyEquivalent` claimed
//  nothing and no note was filed.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - Rig

@MainActor
private enum FileRig {
    static func pump() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
    }

    /// Main-queue turns PASS (the box defers its focus and caret reports by a
    /// turn; the bar files inside a `Task`) — `CaptureUndoAndFocusTests`' rig.
    static func settle(
        _ window: NSWindow, turns: Int = 12, until predicate: () -> Bool = { false }
    ) async {
        for _ in 0..<turns {
            window.contentView?.layoutSubtreeIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
            if predicate() { return }
        }
    }

    static func box(in view: NSView) -> CaptureNSTextView? {
        if let found = view as? CaptureNSTextView { return found }
        for sub in view.subviews {
            if let found = box(in: sub) { return found }
        }
        return nil
    }

    static func window(hosting: NSView, size: NSSize) -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: size.width, height: size.height),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        hosting.frame = NSRect(origin: .zero, size: size)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return window
    }

    static func close(_ window: NSWindow) {
        window.orderOut(nil)
        window.contentView = nil
        window.close()
    }

    static func key(
        _ modifiers: NSEvent.ModifierFlags, keypad: Bool = false, windowNumber: Int = 0
    ) -> NSEvent {
        let characters = keypad ? "\u{3}" : "\r"
        return NSEvent.keyEvent(
            with: .keyDown, location: .zero, modifierFlags: modifiers,
            timestamp: 0, windowNumber: windowNumber, context: nil,
            characters: characters, charactersIgnoringModifiers: characters,
            isARepeat: false, keyCode: keypad ? 76 : 36)!
    }

    static func livePostIDs(_ db: AppDatabase) async throws -> [String] {
        try await db.read {
            try String.fetchAll(
                $0, sql: "SELECT id FROM container WHERE kind = 'post' AND deleted_at IS NULL")
        }
    }

    static func blocks(_ db: AppDatabase, _ postID: String) async throws -> [String] {
        try await db.read { try Queries.renderPost($0, containerID: postID) }
            .compactMap(\.text)
    }
}

@MainActor
private final class Opened {
    var postIDs: [String] = []
}

@MainActor
private func withFileWorld<T>(
    seed: UInt64, _ body: @MainActor (AppSession, AppDatabase) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: seed))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
private func spoken(_ session: AppSession) -> StatusCenter.Item? {
    session.status.current ?? session.status.quietLine
}

/// The Mac app's source tree (`App/Variorum/`), for the face's source pins.
private func appSource(_ relative: String) throws -> String {
    let root = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent()
    return try String(contentsOf: root.appendingPathComponent(relative), encoding: .utf8)
}

// MARK: - The key and the declaration

@MainActor
@Suite("VX-911 — the band files without opening: the key and the declaration")
struct QuickEntryFileWithoutOpeningDeclarationTests {
    /// ⌘⏎ is the key — Return and the keypad's Enter, caps lock and the keypad
    /// flags not meaning (13d F-2's mask); no other modifier set is it, and
    /// the typing rule (`act`) still calls ⌘⏎ nobody's.
    @Test func commandReturnIsTheKeyAndOnlyIt() {
        #expect(CaptureKeys.filesWithoutOpening(FileRig.key(.command)))
        #expect(CaptureKeys.filesWithoutOpening(FileRig.key(.command, keypad: true)))
        #expect(CaptureKeys.filesWithoutOpening(FileRig.key([.command, .capsLock])))
        #expect(CaptureKeys.filesWithoutOpening(FileRig.key([.command, .numericPad, .function], keypad: true)))
        for other: NSEvent.ModifierFlags in [[], .shift, [.command, .shift], [.command, .option],
                                            [.command, .control], .option, .control] {
            #expect(!CaptureKeys.filesWithoutOpening(FileRig.key(other)), "\(other.rawValue) is not ⌘⏎")
        }
        let letter = NSEvent.keyEvent(
            with: .keyDown, location: .zero, modifierFlags: .command, timestamp: 0, windowNumber: 0,
            context: nil, characters: "a", charactersIgnoringModifiers: "a", isARepeat: false, keyCode: 0)!
        #expect(!CaptureKeys.filesWithoutOpening(letter))
        // The typing rule is untouched: ⏎ files, ⇧⏎ a paragraph, ⌘⏎ nobody's there.
        #expect(CaptureKeys.act(for: FileRig.key([])) == .file)
        #expect(CaptureKeys.act(for: FileRig.key(.shift)) == .paragraph)
        #expect(CaptureKeys.act(for: FileRig.key(.command)) == nil)
    }

    /// P-1: declared ONCE — `.surface` (the band's button), no menu key, its
    /// key the ALTERNATE ⌘⏎ (VX-563's shape), always available, the verb its
    /// copy's — and the builder declares it, the helper shows it.
    @Test func theActIsDeclaredOnceAsTheBandsSurfaceDoorWithItsAlternateKey() {
        #expect(CapabilityRegistry.all.filter { $0.id == .fileWithoutOpening }.count == 1)
        let act = CapabilityRegistry.capability(.fileWithoutOpening)
        #expect(act.doors == [.surface])
        #expect(act.shortcutLabel == nil, "no menu item, so no menu key")
        #expect(act.alternateShortcutLabel == "\u{2318}\u{23CE}")
        #expect(act.verb == QuickEntryFileCopy.verb)
        #expect(EditorCommands.keyEquivalent(for: .fileWithoutOpening) == nil,
                "never a menu key — inside a note ⌘⏎ is Choose This Take")
        #expect(CapabilityRegistry.availability(.fileWithoutOpening, in: CapabilityContext()) == .act)
        #expect(QuickEntryBar.surfaceCapabilities == [.fileWithoutOpening],
                "the builder declares it, so both bands are covered")
        #expect(ShortcutCatalog.rows.contains {
            if case .alternates(let ids) = $0.keys { return ids == [.fileWithoutOpening] }
            return false
        }, "the helper (⌘/) shows the key")
        #expect(HelperView.shortcutKeysShown.contains("\u{2318}\u{23CE}"))
    }

    /// The collision table, as the record states it: the two take chords keep
    /// their keys and their contexts (inside a note only), so the band's
    /// focus-scoped ⌘⏎ takes nothing from them.
    @Test func theTakeChordsKeepTheirKeysInsideANote() {
        let choose = CapabilityRegistry.capability(.chooseTake)
        let takeToBlock = CapabilityRegistry.capability(.takeToBlockBelow)
        #expect(choose.shortcutLabel == "\u{2318}\u{23CE}")
        #expect(takeToBlock.shortcutLabel == "\u{2325}\u{2318}\u{23CE}")
        #expect(CapabilityRegistry.availability(.chooseTake, in: CapabilityContext()) == .unavailable,
                "with no note mounted (the Bookcase, the Library) Choose Take is grey")
        #expect(CapabilityRegistry.availability(.takeToBlockBelow, in: CapabilityContext()) == .unavailable)
    }

    /// The words (PROVISIONAL, her bundle): the pad's "Filed in …" grammar,
    /// the duplicate's landing read.
    @Test func theReceiptSaysWhereItLanded() {
        #expect(QuickEntryFileCopy.landed(books: []) == "Filed in the Pool.")
        #expect(QuickEntryFileCopy.landed(books: ["letters"]) == "Filed in \u{201C}letters\u{201D}.")
        #expect(QuickEntryFileCopy.landed(books: ["a", "b", "c"]) == "Filed in 3 books.")
        #expect(QuickEntryFileCopy.landed(books: nil) == "Filed.")
        #expect(QuickEntryFileCopy.openNote == DuplicateCopy.openCopy, "the duplicate's own door words")
        #expect(QuickEntryFileCopy.buttonLabel(chord: "\u{2318}\u{23CE}") == "File \u{2318}\u{23CE}")
        #expect(QuickEntryFileCopy.buttonLabel(chord: nil) == "File")
        #expect(!QuickEntryFileCopy.help.isEmpty)
    }

    /// The face, by source (a SwiftUI button has no AppKit view to find): the
    /// button reads its chord from the declaration, is grey while there is
    /// nothing to file, and is NEVER a key-view stop (the ruling's check — the
    /// opening-caret law stays whole); the bar hands the box the act, the pad
    /// does not.
    @Test func theButtonIsGreyWhileEmptyNeverAKeyViewStopAndOnlyTheBandHandsTheKey() throws {
        let bar = try appSource("Variorum/Features/Shelf/QuickEntryBar.swift")
        let button = try #require(bar.range(of: "private var fileButton: some View {"))
        let body = String(bar[button.upperBound...].prefix(1_400))
        #expect(body.contains("act.alternateShortcutLabel"), "the chord is read, never typed")
        #expect(body.contains(".disabled(!box.canFile)"))
        #expect(body.contains(".focusable(false)"), "never a key-view / Tab stop")
        #expect(bar.contains("onFileWithoutOpening: { fileWithoutOpening() }"), "the band hands the box ⌘⏎")
        let pad = try appSource("Variorum/Features/QuickNote/QuickNoteView.swift")
        #expect(!pad.contains("onFileWithoutOpening"), "the pad hands none — its File It keeps ⌘⏎")
        #expect(pad.contains(".keyboardShortcut(.return, modifiers: .command)"), "the pad's own key, unchanged")
    }
}

// MARK: - The model's road

@MainActor
@Suite("VX-911 — the band files without opening: the model's road", .serialized)
struct QuickEntryFileWithoutOpeningModelTests {
    /// THE CONTRACT: ⏎'s own road (the words filed exactly), nothing opens,
    /// the box clears, and the quiet receipt says the Pool — carrying Open ›,
    /// which opens THIS note through the host's road.
    @Test func itFilesClearsTheBoxSaysWhereAndOpensNothing() async throws {
        try await withFileWorld(seed: 911) { session, db in
            let box = QuickEntryModel(session: session)
            let opened = Opened()
            box.text = "a thought to keep"
            #expect(box.canFile)

            let filed = try #require(await box.fileWithoutOpening { opened.postIDs.append($0) })
            #expect(opened.postIDs.isEmpty, "nothing opens")
            #expect(box.text.isEmpty, "the band clears for the next note")
            #expect(!box.canFile)
            #expect(try await FileRig.blocks(db, filed) == ["a thought to keep"])

            let item = try #require(spoken(session))
            #expect(item.kind == .receipt)
            #expect(item.text == "Filed in the Pool.")
            #expect(item.action?.label == QuickEntryFileCopy.openNote)
            item.action?.perform()
            #expect(opened.postIDs == [filed], "Open › opens the note it filed")
        }
    }

    /// In succession — her use: three notes, three receipts, nothing opened.
    @Test func severalInSuccessionEachFileOnTheirOwn() async throws {
        try await withFileWorld(seed: 912) { session, db in
            let box = QuickEntryModel(session: session)
            let opened = Opened()
            for line in ["first", "second", "third"] {
                box.text = line
                _ = await box.fileWithoutOpening { opened.postIDs.append($0) }
                #expect(box.text.isEmpty)
            }
            #expect(opened.postIDs.isEmpty)
            let posts = try await FileRig.livePostIDs(db)
            #expect(posts.count == 3)
        }
    }

    /// The microsyntax rides the same road: a `{#tag}` a living book hears
    /// seats the note there and the receipt NAMES the book; a `{t:"…"}` titles.
    @Test func theMicrosyntaxRidesAndTheReceiptNamesTheBookItLandedIn() async throws {
        try await withFileWorld(seed: 913) { session, db in
            try await session.runner.run { ops in
                let draft = try ops.createTag(name: "draft")
                _ = try ops.createReading(
                    name: "drafts", kind: .book, querySpec: try RuleGrammar.encode(.tag(draft.id)))
            }
            let box = QuickEntryModel(session: session)
            box.text = "{#draft} {t:\"Morning\"} the lines"
            let filed = try #require(await box.fileWithoutOpening { _ in })
            let title = try await db.read { db in
                try String.fetchOne(db, sql: "SELECT title FROM container WHERE id = ?", arguments: [filed])
            }
            #expect(title == "Morning")
            #expect(try await FileRig.blocks(db, filed) == ["the lines"], "the tokens are gone from the text")
            #expect(spoken(session)?.text == "Filed in \u{201C}drafts\u{201D}.")
        }
    }

    /// An empty box — or nothing but tokens — files nothing and says nothing,
    /// exactly as ⏎ does (#127(f)); the button is grey there.
    @Test func anEmptyBoxFilesNothingAndSaysNothing() async throws {
        try await withFileWorld(seed: 914) { session, db in
            let box = QuickEntryModel(session: session)
            for text in ["", "   \n", "{#draft}"] {
                box.text = text
                #expect(!box.canFile, "grey for \(text.debugDescription)")
                #expect(await box.fileWithoutOpening { _ in } == nil)
            }
            let posts = try await FileRig.livePostIDs(db)
            #expect(posts.isEmpty)
            #expect(spoken(session) == nil)
        }
    }

    /// A refusal keeps her text and its words, and speaks no receipt — the
    /// submit road's own posture.
    @Test func aRefusalKeepsHerTextAndSpeaksNoReceipt() async throws {
        try await withFileWorld(seed: 915) { session, _ in
            let box = QuickEntryModel(session: session)
            box.mint = { _, _ in throw OperationError.lockedPost(id: "c1") }
            box.text = "kept words"
            #expect(await box.fileWithoutOpening { _ in } == nil)
            #expect(box.text == "kept words")
            #expect(box.lastError == QuickEntryCopy.refusal(for: OperationError.lockedPost(id: "c1")))
            #expect(spoken(session) == nil)
        }
    }

    /// Two presses inside one flight (a double click, ⌘⏎ held into a repeat)
    /// file ONCE — the second lands on the first's filing.
    @Test func twoPressesInOneFlightFileOnce() async throws {
        try await withFileWorld(seed: 916) { session, _ in
            let box = QuickEntryModel(session: session)
            let mints = Opened()
            box.mint = { text, _ in
                mints.postIDs.append(text)
                try await Task.sleep(for: .milliseconds(60))
                return "p-\(mints.postIDs.count)"
            }
            box.text = "once"
            async let first = box.fileWithoutOpening { _ in }
            async let second = box.fileWithoutOpening { _ in }
            let results = await [first, second]
            #expect(mints.postIDs == ["once"], "one mint")
            #expect(results.compactMap { $0 }.count == 1)
        }
    }
}

// MARK: - The key, mounted

@MainActor
@Suite("VX-911 — the band files without opening: ⌘⏎ in the mounted box", .serialized)
struct QuickEntryFileWithoutOpeningKeyTests {
    private func mountBar(_ session: AppSession, opened: Opened) async throws -> (NSWindow, CaptureNSTextView) {
        let hosting = NSHostingView(rootView: QuickEntryBar(
            session: session,
            onOpen: { selection in
                if case .post(let id) = selection { opened.postIDs.append(id) }
            }))
        let window = FileRig.window(hosting: hosting, size: NSSize(width: 640, height: 160))
        await FileRig.settle(window, turns: 15) { FileRig.box(in: hosting) != nil }
        let box = try #require(FileRig.box(in: hosting), "the box mounted")
        return (window, box)
    }

    /// RED ON OLD BY CONSTRUCTION: the window's key-equivalent pass reaches the
    /// box (the hosting view forwards it — measured headlessly offscreen at this
    /// batch, the record), the box claims ⌘⏎ while it holds the keyboard, the
    /// note files, nothing opens, the box clears.
    @Test func commandReturnInTheBandFilesWithoutOpening() async throws {
        try await withFileWorld(seed: 921) { session, db in
            let opened = Opened()
            let (window, box) = try await mountBar(session, opened: opened)
            defer { FileRig.close(window) }
            window.makeFirstResponder(box)
            box.insertText("from the main page", replacementRange: box.selectedRange())
            await FileRig.settle(window, turns: 3)

            let claimed = window.performKeyEquivalent(
                with: FileRig.key(.command, windowNumber: window.windowNumber))
            #expect(claimed, "the box claims ⌘⏎ while it holds the keyboard")
            var posts: [String] = []
            for _ in 0..<100 {
                posts = try await FileRig.livePostIDs(db)
                if !posts.isEmpty, box.string.isEmpty { break }
                await FileRig.settle(window, turns: 1)
            }
            let postID = try #require(posts.first, "⌘⏎ filed a note")
            #expect(try await FileRig.blocks(db, postID) == ["from the main page"])
            #expect(opened.postIDs.isEmpty, "…and opened nothing")
            #expect(box.string.isEmpty, "the band cleared for the next note")
            #expect(window.firstResponder === box, "the caret stays in the band")
            #expect(spoken(session)?.text == "Filed in the Pool.")
        }
    }

    /// Focus-scoped: with the keyboard elsewhere the box claims nothing (a
    /// split window's note pane keeps Choose This Take); ⏎ still files AND opens.
    @Test func theBoxClaimsTheKeyOnlyWhileItHoldsTheKeyboardAndReturnStillOpens() async throws {
        try await withFileWorld(seed: 922) { session, db in
            let opened = Opened()
            let (window, box) = try await mountBar(session, opened: opened)
            defer { FileRig.close(window) }
            window.makeFirstResponder(box)
            box.insertText("words", replacementRange: box.selectedRange())
            await FileRig.settle(window, turns: 3)
            window.makeFirstResponder(nil)
            #expect(!box.performKeyEquivalent(with: FileRig.key(.command, windowNumber: window.windowNumber)),
                    "not holding the keyboard: the key goes on its way")
            #expect(try await FileRig.livePostIDs(db).isEmpty)

            window.makeFirstResponder(box)
            box.keyDown(with: FileRig.key([], windowNumber: window.windowNumber))
            await FileRig.settle(window, turns: 100) { !opened.postIDs.isEmpty }
            #expect(opened.postIDs.count == 1, "⏎ files AND opens, as it always has")
        }
    }

    /// The pad's box is handed no act: it never claims ⌘⏎ (the pad's own File
    /// It button keeps the key).
    @Test func thePadsBoxNeverClaimsTheKey() async throws {
        try await withFileWorld(seed: 923) { session, db in
            let hosting = NSHostingView(rootView: QuickNoteView(session: session, windows: WindowRegistry()))
            let window = FileRig.window(hosting: hosting, size: NSSize(width: 360, height: 260))
            defer { FileRig.close(window) }
            await FileRig.settle(window, turns: 15) { FileRig.box(in: hosting) != nil }
            let box = try #require(FileRig.box(in: hosting))
            window.makeFirstResponder(box)
            #expect(box.onFileWithoutOpening == nil)
            #expect(!box.performKeyEquivalent(with: FileRig.key(.command, windowNumber: window.windowNumber)))
            _ = db
        }
    }
}
