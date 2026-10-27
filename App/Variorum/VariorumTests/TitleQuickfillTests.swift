//
//  TitleQuickfillTests.swift
//  VariorumTests
//
//  **VX-569 (the VX-439 run, A-439-14) — the title field offers a name; Tab
//  takes it.** Her 10-20 note: *"auto fill in the first line of the post as
//  the title if you click into it, maybe just tab to complete it and enter."*
//  Her 10-21 note: *"in a fresh note with no words, going to the title and tab
//  should make the title fill-in-able with the date so that you can enter it."*
//
//  THE TRACE (the run record): the masthead's title field had no first-line
//  quickfill at all — it opened on the stored name ("") with the date drawn
//  faintly behind it, and Tab moved the keyboard on, filing the empty draft (a
//  no-op). So the 10-20 path was BROKEN, end to end; the mounted pin below is
//  red on the old tree for exactly that (Tab took nothing; the note stayed
//  untitled), and the date arm rides the same road.
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
@Suite("VX-569 — the title field offers the first line (or the date), and Tab takes it", .serialized)
struct TitleQuickfillTests {
    // MARK: - The rule

    @Test func anUntitledNoteIsOfferedItsFirstWordsElseItsDateAndATitledOneNothing() {
        #expect(TitleQuickfill.offer(storedTitle: nil, openingTexts: ["# Garden plans\nbeds by the fence"],
                                     shownName: "Oct 27, 2026") == "Garden plans",
                "the first line with words, its heading rendered — a name")
        #expect(TitleQuickfill.offer(storedTitle: "", openingTexts: ["", "  ", "Second block opens it"],
                                     shownName: "Oct 27, 2026") == "Second block opens it",
                "an empty stored title is no title; the first block WITH words leads")
        #expect(TitleQuickfill.offer(storedTitle: nil, openingTexts: [], shownName: "Oct 27, 2026") == "Oct 27, 2026",
                "no words: the date it already shows (her 10-21 arm)")
        #expect(TitleQuickfill.offer(storedTitle: nil, openingTexts: [""], shownName: " Oct 27, 2026 ") == "Oct 27, 2026")
        #expect(TitleQuickfill.offer(storedTitle: "Kept", openingTexts: ["words"], shownName: "Kept") == nil,
                "a titled note is offered nothing")
        #expect(TitleQuickfill.offer(storedTitle: nil, openingTexts: [], shownName: DisplayTitle.placeholder) == nil,
                "no words and no day: nothing to offer")
        let long = String(repeating: "lantern ", count: 20)
        let capped = TitleQuickfill.offer(storedTitle: nil, openingTexts: [long], shownName: "x")
        #expect(capped == NoteCardFace.suggestedTitle(forTypedText: long), "the capture chip's brain exactly: \(String(describing: capped))")
        #expect(capped.map { !$0.hasSuffix("\u{2026}") } == true, "a name, never a truncation mark")
    }

    @Test func theOpeningIsOneBoundedRead() async throws {
        try await withWorld { session, db in
            let post = try session.operations.createPost()
            for i in 1...6 { _ = try session.operations.newBlock(in: post.id, text: "block \(i)") }
            let opening = try await db.read { try TitleQuickfill.opening($0, postID: post.id) }
            #expect(opening == ["block 1", "block 2", "block 3"], "the first \(TitleQuickfill.openingBlocks) slots only")
        }
    }

    // MARK: - The field, as she uses it

    /// **RED ON OLD.** Click into an untitled note's title, press Tab, press
    /// ⏎: the note is named by its first line. (On the old tree Tab moved the
    /// keyboard on and the note stayed untitled.) And the 10-21 arm: a note
    /// with no words is named by its date the same way.
    @Test func tabTakesTheOfferedFirstLineAndEnterFilesIt() async throws {
        try await withMountedTitle(firstBlock: "# Garden plans\nbeds by the fence") { session, postID, window, hosting in
            let editor = try await openTitle(window, hosting)
            #expect(editor.string.isEmpty, "the field opens on the stored name — none")
            press(48, "\t", window: window)
            await settle(window, hosting, until: { editor.string == "Garden plans" })
            #expect(editor.string == "Garden plans", "Tab took the offered first line: \(editor.string)")
            press(36, "\r", window: window)
            await settle(window, hosting, until: { (try? Self.stored(session, postID)) == "Garden plans" })
            #expect(try Self.stored(session, postID) == "Garden plans", "⏎ filed it")
        }
    }

    @Test func aNoteWithNoWordsIsOfferedItsDate() async throws {
        try await withMountedTitle(firstBlock: "") { session, postID, window, hosting in
            let shown = try await session.database.read { try Queries.noteDisplayTitle($0, id: postID) } ?? ""
            #expect(!shown.isEmpty && shown != DisplayTitle.placeholder, "the note shows a date: \(shown)")
            let editor = try await openTitle(window, hosting)
            press(48, "\t", window: window)
            await settle(window, hosting, until: { editor.string == shown })
            #expect(editor.string == shown, "Tab took the date: \(editor.string)")
            press(36, "\r", window: window)
            await settle(window, hosting, until: { (try? Self.stored(session, postID)) == shown })
            #expect(try Self.stored(session, postID) == shown, "⏎ filed it — the date is now the name")
        }
    }

    /// A GUARD: typing first replaces the offer — her words are what files.
    @Test func typingFirstReplacesTheOffer() async throws {
        try await withMountedTitle(firstBlock: "Garden plans") { session, postID, window, hosting in
            let editor = try await openTitle(window, hosting)
            editor.insertText("Mine", replacementRange: editor.selectedRange())
            await settle(window, hosting, until: { editor.string == "Mine" })
            press(36, "\r", window: window)
            await settle(window, hosting, until: { (try? Self.stored(session, postID)) == "Mine" })
            #expect(try Self.stored(session, postID) == "Mine", "her words, never the offer")
        }
    }

    // MARK: - Rig

    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView, until predicate: () -> Bool, maxTurns: Int = 80
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    private static func stored(_ session: AppSession, _ postID: String) throws -> String? {
        try session.database.read { (db: Database) in try Queries.containerTitle(db, id: postID) }
    }

    /// Opens the title's field through its own door and returns the field
    /// editor that holds the keyboard.
    private func openTitle(_ window: NSWindow, _ hosting: NSView) async throws -> NSTextView {
        #if DEBUG
        PostDetailOracle.beginTitleEditing?()
        #endif
        await settle(window, hosting, until: { window.firstResponder is NSTextView
            && (window.firstResponder as? NSTextView)?.isFieldEditor == true })
        let editor = try #require(window.firstResponder as? NSTextView, "the title's field editor holds the keyboard")
        #expect(editor.isFieldEditor)
        // Let the offer's one read land.
        await settle(window, hosting, until: { false }, maxTurns: 6)
        return editor
    }

    /// A key, as the window receives it.
    private func press(_ keyCode: UInt16, _ character: String, window: NSWindow) {
        guard let event = NSEvent.keyEvent(
            with: .keyDown, location: .zero, modifierFlags: [],
            timestamp: ProcessInfo.processInfo.systemUptime,
            windowNumber: window.windowNumber, context: nil,
            characters: character, charactersIgnoringModifiers: character,
            isARepeat: false, keyCode: keyCode)
        else { return }
        NSApp.sendEvent(event)
        pump(0.05)
    }

    private func withWorld<T>(_ body: @MainActor (AppSession, AppDatabase) async throws -> T) async throws -> T {
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 569))
        } operation: { @MainActor in
            try await body(AppSession(database: db), db)
        }
    }

    /// An UNTITLED note mounted in its detail, in Write (`MastheadLayoutTests`'
    /// rig shape).
    private func withMountedTitle(
        firstBlock: String,
        _ body: @MainActor (AppSession, String, NSWindow, NSView) async throws -> Void
    ) async throws {
        try await withWorld { session, _ in
            let post = try session.operations.createPost()
            _ = try session.operations.newBlock(in: post.id, text: firstBlock)
            UserDefaults.standard.set(PostMode.write.rawValue, forKey: "postMode.\(post.id)")
            defer { UserDefaults.standard.removeObject(forKey: "postMode.\(post.id)") }
            try await withAdoptedTheme(session: session) { store in
                let window = NSWindow(
                    contentRect: NSRect(x: 80, y: 80, width: 1100, height: 750),
                    styleMask: [.titled], backing: .buffered, defer: false)
                window.isReleasedWhenClosed = false
                defer {
                    window.orderOut(nil)
                    window.close()
                }
                let hosting = NSHostingView(
                    rootView: PostDetailView(session: session, postID: post.id).environment(store))
                hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
                window.contentView = hosting
                window.makeKeyAndOrderFront(nil)
                await settle(window, hosting, until: { session.commandRouter.activePostID == post.id })
                try await body(session, post.id, window, hosting)
            }
        }
    }
}
