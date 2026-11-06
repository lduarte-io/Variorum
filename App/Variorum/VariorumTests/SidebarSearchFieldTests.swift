//
//  SidebarSearchFieldTests.swift
//  VariorumTests
//
//  **VX-822 (the VX-819 run, batch 3) — search from the sidebar** (her
//  R-819-3 and R-819-4, `notes/plans/fixes/vx-819-search.md` § SITTING
//  RECORD). An Improvement: BUILD pins (the field did not exist). What they
//  hold:
//
//  - THE RULE (pure): typing asks the Library's one question, emptying the
//    words ends the search, ⏎ hands the words to the Library (the field
//    clears, the keyboard goes with them), esc clears and ends, the keyboard
//    leaving (or a click elsewhere) hands off without the keyboard; the field
//    asks while — and only while — it holds words (a door, never a mirror);
//  - THE CARRY, through the real shell (`RootView` mounted with the window's
//    Library model): typing lands the Library in the focused pane with the
//    question set, the sidebar field KEEPS the keyboard through the landing
//    and every later keystroke (VX-332's never-steal law, verified rather than
//    assumed); ⏎ moves the keyboard into the Library's own field, the words
//    carried with the caret at their end, the sidebar field cleared; esc and
//    an emptied field end the search and stay in the Library;
//  - THE PLACE (R-819-3 — "don't shift everything down for it"): the field
//    draws inside the column's empty top band, and the first section's top is
//    the SAME point with the field mounted as without it — with Starred and
//    without.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Observation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The rule

@Suite("VX-822 — the sidebar search field's rule")
struct SidebarSearchFieldRuleTests {
    @Test func typingAsksAndEmptyingTheWordsEndsTheSearch() {
        var rule = SidebarSearchFieldRule()
        #expect(rule.edit("h") == .ask("h"))
        #expect(rule.edit("harbour") == .ask("harbour"), "every keystroke refines the one question")
        #expect(rule.edit("") == .end, "clearing by hand ends the search")
        #expect(rule.edit("") == .none, "an empty field asks nothing and ends nothing twice")
    }

    @Test func returnHandsTheWordsAndTheKeyboardToTheLibrary() {
        var rule = SidebarSearchFieldRule()
        #expect(rule.submit() == .none, "⏎ on an empty field is not a handoff")
        _ = rule.edit("harbour")
        #expect(rule.submit() == .handOff(keyboardToLibrary: true))
        #expect(rule.text.isEmpty, "the field clears — the words are the Library's now")
        #expect(rule.leave() == .none, "the keyboard leaving after the handoff hands nothing twice")
    }

    @Test func escClearsTheFieldAndEndsItsSearch() {
        var rule = SidebarSearchFieldRule()
        #expect(rule.escape() == .none, "esc on an empty field: nothing — it asked nothing")
        _ = rule.edit("lamp")
        #expect(rule.escape() == .end)
        #expect(rule.text.isEmpty)
    }

    @Test func theKeyboardLeavingOrAClickElsewhereHandsOffWithoutTheKeyboard() {
        var rule = SidebarSearchFieldRule()
        #expect(rule.leave() == .none)
        _ = rule.edit("lamp")
        #expect(rule.leave() == .handOff(keyboardToLibrary: false),
                "a click into the results: the words stay the Library's, the field clears")
        #expect(rule.text.isEmpty)
        #expect(rule.edit("x") == .ask("x"), "and the door opens again on the next keystroke")
    }
}

// MARK: - The carry, through the shell

/// A window that says it is KEY (SwiftUI's focus answers a key window; this
/// host never makes one key — `QuickEntryLaunchFocusTests`' harness fact).
private final class KeyedTestWindow: NSWindow {
    override var isKeyWindow: Bool { true }
    override var canBecomeKey: Bool { true }
}

@MainActor
@Suite("VX-822 — the sidebar field drives the Library's one search, through the shell", .serialized)
struct SidebarSearchFieldShellTests {
    private func withShell(
        _ body: @MainActor (AppSession, ShellRouter, LibraryCatalogModel, NSWindow, NSView) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 822))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let note = try session.operations.createPost(title: "the harbour lamp")
            _ = try session.operations.newBlock(in: note.id, text: "the harbour lamp burned all night")
            let suite = "vx822-shell-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defer { defaults.removePersistentDomain(forName: suite) }
            let catalog = LibraryCatalogModel(session: session, defaults: defaults)
            let router = ShellRouter()
            let window = KeyedTestWindow(
                contentRect: NSRect(x: 40, y: 40, width: 1100, height: 720),
                styleMask: [.titled, .resizable], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(rootView: RootView(session: session, router: router, catalog: catalog))
            hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 720)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            defer {
                window.orderOut(nil)
                window.contentView = nil
                window.close()
            }
            try await body(session, router, catalog, window, hosting)
        }
    }

    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    @discardableResult
    private func settle(
        _ window: NSWindow, _ hosting: NSView, timeout: TimeInterval = 4,
        until predicate: () -> Bool = { false }
    ) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if predicate() { return true }
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            Self.pumpRunLoop(0.03)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
        return predicate()
    }

    private static func textFields(in view: NSView) -> [NSTextField] {
        ((view as? NSTextField).map { [$0] } ?? []) + view.subviews.flatMap(textFields)
    }

    private static func prompt(of field: NSTextField) -> String {
        (field.placeholderString ?? field.placeholderAttributedString?.string ?? "").lowercased()
    }

    /// The sidebar's field: the door's own AppKit field (its prompt the door's).
    private static func sidebarField(_ hosting: NSView) -> NSTextField? {
        textFields(in: hosting).first {
            $0 is SidebarSearchTextField.Field && prompt(of: $0) == SidebarSearchCopy.prompt.lowercased()
        }
    }

    /// The Library's own field: the editable field with the Library's prompt.
    private static func libraryField(_ hosting: NSView) -> NSTextField? {
        textFields(in: hosting).first {
            $0.isEditable && prompt(of: $0) == LibraryCatalogView.searchPrompt.lowercased()
        }
    }

    /// The field whose editor holds the window's keyboard, if any.
    private static func keyboardField(_ window: NSWindow) -> NSTextField? {
        (window.firstResponder as? NSTextView)?.delegate as? NSTextField
    }

    private static func key(_ keyCode: UInt16, _ characters: String, window: NSWindow) -> NSEvent? {
        NSEvent.keyEvent(
            with: .keyDown, location: .zero, modifierFlags: [],
            timestamp: ProcessInfo.processInfo.systemUptime,
            windowNumber: window.windowNumber, context: nil,
            characters: characters, charactersIgnoringModifiers: characters,
            isARepeat: false, keyCode: keyCode)
    }

    /// Typing into the field holding the keyboard, through its field editor.
    private static func type(_ chunk: String, _ window: NSWindow) -> Bool {
        guard let editor = window.firstResponder as? NSTextView else { return false }
        editor.insertText(chunk, replacementRange: editor.selectedRange())
        return true
    }

    @Test func typingLandsTheLibraryWithTheQuestionAndTheFieldKeepsTheKeyboard() async throws {
        try await withShell { _, router, catalog, window, hosting in
            await settle(window, hosting) { Self.sidebarField(hosting) != nil }
            let field = try #require(Self.sidebarField(hosting), "the sidebar's search field is drawn")
            #expect(router.workspace.focusedSelection == .shelf, "the shell opens on the Bookcase")
            // VX-332's guard: never a key-view stop, so a window opening on the
            // Bookcase never makes it the opening first responder.
            #expect(!field.canBecomeKeyView, "the field is not in the window's key-view loop")
            #expect(Self.keyboardField(window) !== field, "the shell's opening did not put the caret here")

            window.makeFirstResponder(field)
            await settle(window, hosting, timeout: 2) { Self.keyboardField(window) === field }
            try #require(Self.keyboardField(window) === field, "the sidebar field holds the keyboard")

            #expect(Self.type("harb", window))
            await settle(window, hosting) {
                router.workspace.focusedSelection == .library && catalog.query == "harb"
                    && Self.libraryField(hosting) != nil
            }
            #expect(router.workspace.focusedSelection == .library, "typing showed the Library beside it")
            #expect(catalog.query == "harb", "the field's words ARE the Library's one question")
            #expect(Self.libraryField(hosting)?.stringValue == "harb", "the Library's own field shows them")
            await settle(window, hosting, timeout: 0.6)
            #expect(Self.keyboardField(window) === field,
                    "the Library appearing never took the keyboard (\(String(describing: window.firstResponder)))")

            // Typing is never interrupted: the next keys land in the same field.
            #expect(Self.type("our", window))
            await settle(window, hosting) { catalog.query == "harbour" }
            #expect(catalog.query == "harbour")
            #expect(field.stringValue == "harbour")
            #expect(Self.keyboardField(window) === field)
            await settle(window, hosting) { catalog.searchState.asksAnything }
            #expect(catalog.searchState.asksAnything, "the Library is searching the words")
        }
    }

    @Test func returnMovesTheKeyboardIntoTheLibraryWithTheWordsCarried() async throws {
        try await withShell { _, router, catalog, window, hosting in
            await settle(window, hosting) { Self.sidebarField(hosting) != nil }
            let field = try #require(Self.sidebarField(hosting))
            window.makeFirstResponder(field)
            await settle(window, hosting, timeout: 2) { Self.keyboardField(window) === field }
            #expect(Self.type("harbour", window))
            await settle(window, hosting) { catalog.query == "harbour" && Self.libraryField(hosting) != nil }

            let enter = try #require(Self.key(36, "\r", window: window))
            NSApp.sendEvent(enter)
            await settle(window, hosting) {
                field.stringValue.isEmpty && Self.keyboardField(window) === Self.libraryField(hosting)
            }
            #expect(field.stringValue.isEmpty, "the sidebar field clears")
            #expect(catalog.query == "harbour", "the question is carried, not dropped")
            #expect(router.workspace.focusedSelection == .library)
            let library = try #require(Self.libraryField(hosting))
            #expect(Self.keyboardField(window) === library, "⏎ moved the keyboard into the Library's field")
            await settle(window, hosting, timeout: 1) {
                (window.firstResponder as? NSTextView)?.selectedRange() == NSRange(location: 7, length: 0)
            }
            #expect((window.firstResponder as? NSTextView)?.selectedRange() == NSRange(location: 7, length: 0),
                    "the caret after the carried words — her next key refines them, never replaces them")
        }
    }

    @Test func escAndAnEmptiedFieldEndTheSearchAndStayInTheLibrary() async throws {
        try await withShell { _, router, catalog, window, hosting in
            await settle(window, hosting) { Self.sidebarField(hosting) != nil }
            let field = try #require(Self.sidebarField(hosting))
            window.makeFirstResponder(field)
            await settle(window, hosting, timeout: 2) { Self.keyboardField(window) === field }
            #expect(Self.type("lamp", window))
            await settle(window, hosting) { catalog.query == "lamp" && router.workspace.focusedSelection == .library }

            let esc = try #require(Self.key(53, "\u{1B}", window: window))
            NSApp.sendEvent(esc)
            await settle(window, hosting) { field.stringValue.isEmpty && catalog.query.isEmpty }
            #expect(field.stringValue.isEmpty, "esc clears the field")
            #expect(catalog.query.isEmpty, "…and the search it asked ends")
            #expect(router.workspace.focusedSelection == .library, "she stays in the Library")

            // An emptied field (her backspaces) ends it too.
            window.makeFirstResponder(field)
            await settle(window, hosting, timeout: 2) { Self.keyboardField(window) === field }
            #expect(Self.type("x", window))
            await settle(window, hosting) { catalog.query == "x" }
            (window.firstResponder as? NSTextView)?.deleteBackward(nil)
            await settle(window, hosting) { catalog.query.isEmpty }
            #expect(catalog.query.isEmpty, "clearing by any road ends the search")
            #expect(router.workspace.focusedSelection == .library)
        }
    }

    // MARK: The ladder's round 1 (notes/plans/fixes/vx-819-ladder-round1.md)

    /// A window editing `words` in a plain field — the field editor holds
    /// them, AppKit's select-all on it (a focus by code).
    private static func decoy(_ words: String, at x: CGFloat) -> (window: NSWindow, field: NSTextField) {
        let window = KeyedTestWindow(
            contentRect: NSRect(x: x, y: 40, width: 320, height: 80),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let field = NSTextField(string: words)
        field.frame = NSRect(x: 12, y: 24, width: 260, height: 24)
        window.contentView?.addSubview(field)
        window.orderFrontRegardless()
        window.makeFirstResponder(field)
        return (window, field)
    }

    private static func dismiss(_ window: NSWindow) {
        window.makeFirstResponder(nil)
        window.orderOut(nil)
        window.close()
    }

    /// **F2 — ⏎'s caret lands in the Library field's OWN window.** Another
    /// window editing the same words must neither take the caret nor rob
    /// the Library's field of it: AppKit's select-all on a field focused by
    /// code would then stand, and her next key would REPLACE the carried
    /// question. Two decoys, one built before the shell's window and one
    /// ordered in front after it, so whichever order the app's window list
    /// is walked in, a decoy comes before the shell's window in it (the
    /// red-on-old tree walked `NSApp.windows` and stopped at the first match).
    @Test func theHandoffsCaretLandsInItsOwnWindowNeverAnotherEditingTheSameWords() async throws {
        let before = Self.decoy("harbour", at: 1180)
        defer { Self.dismiss(before.window) }
        try await withShell { _, router, catalog, window, hosting in
            let after = Self.decoy("harbour", at: 1520)
            defer { Self.dismiss(after.window) }
            await settle(window, hosting) { Self.sidebarField(hosting) != nil }
            let field = try #require(Self.sidebarField(hosting))
            window.makeFirstResponder(field)
            await settle(window, hosting, timeout: 2) { Self.keyboardField(window) === field }
            #expect(Self.type("harbour", window))
            await settle(window, hosting) { catalog.query == "harbour" && Self.libraryField(hosting) != nil }

            // Non-vacuity: each decoy's field editor holds the same words —
            // the walk the fix retired WOULD have stopped at it.
            var decoyRanges: [NSRange] = []
            for decoy in [before, after] {
                let editor = try #require(decoy.window.firstResponder as? NSTextView, "the decoy is editing")
                try #require(editor.isFieldEditor && editor.string == "harbour", "the decoy shows the same words")
                decoyRanges.append(editor.selectedRange())
            }

            let enter = try #require(Self.key(36, "\r", window: window))
            NSApp.sendEvent(enter)
            await settle(window, hosting) {
                field.stringValue.isEmpty && Self.keyboardField(window) === Self.libraryField(hosting)
            }
            #expect(router.workspace.focusedSelection == .library)
            #expect(Self.keyboardField(window) === Self.libraryField(hosting), "⏎ moved the keyboard into the Library's field")
            await settle(window, hosting, timeout: 1) {
                (window.firstResponder as? NSTextView)?.selectedRange() == NSRange(location: 7, length: 0)
            }
            await settle(window, hosting, timeout: 0.4)
            #expect((window.firstResponder as? NSTextView)?.selectedRange() == NSRange(location: 7, length: 0),
                    "the caret after the carried words in the Library's own window")
            for (decoy, range) in zip([before, after], decoyRanges) {
                #expect((decoy.window.firstResponder as? NSTextView)?.selectedRange() == range,
                        "another window's editor is never touched by the handoff")
            }
        }
    }

    /// **F1 — a Library standing in Timeline answers the sidebar's words.**
    /// R-819-4: typing shows the Library "with the live answer as you type".
    /// The catalog's mode is the window's session state, and the Timeline
    /// takes no question (it draws its own listing, no answer sheet, no
    /// band), so a sidebar search landing there changed nothing she could
    /// see. As the sidebar's words land, the Timeline yields to List — the
    /// Cards rule's precedent, a view that cannot show the answer yields
    /// (A-819-L1, PROVISIONAL). Both roads: the Library already shown, and
    /// landed by the first keystroke.
    @Test(arguments: [true, false])
    func aSidebarSearchMovesATimelineLibraryToTheAnswer(libraryShown: Bool) async throws {
        try await withShell { _, router, catalog, window, hosting in
            if libraryShown { router.adopt(.library, in: router.workspace.focusedPane) }
            catalog.pickMode(.timeline)
            await settle(window, hosting) {
                Self.sidebarField(hosting) != nil
                    && router.workspace.focusedSelection
                        == (libraryShown ? SidebarSelection.library : SidebarSelection.shelf)
            }
            await settle(window, hosting, timeout: 0.3)
            try #require(catalog.mode == .timeline, "premise: the Library stands in Timeline")

            let field = try #require(Self.sidebarField(hosting))
            window.makeFirstResponder(field)
            await settle(window, hosting, timeout: 2) { Self.keyboardField(window) === field }
            #expect(Self.type("harb", window))
            await settle(window, hosting) {
                catalog.query == "harb" && catalog.searchState.isAnswering && catalog.mode == .list
            }
            #expect(router.workspace.focusedSelection == .library)
            #expect(catalog.mode == .list, "the Timeline yields to List, the mode that shows the answer")
            #expect(catalog.isSearching, "the answer sheet answers the sidebar's words")
            #expect(Self.keyboardField(window) === field, "the field kept the keyboard through the move")
        }
    }

    /// **F3 — a sidebar search is a NEW search.** The sidebar field opens
    /// empty and clears after every handoff, so every question it starts is
    /// a fresh hunt from an empty field — a new search by R-819-2's own word:
    /// it starts at relevance with no facet carried over from the question it
    /// replaces (A-819-L1, amending P-819-B3d). The order and facets she
    /// picked for the old question never ride onto the new one.
    @Test func aSidebarSearchStartsNewAtRelevanceWithNoFacetCarriedOver() async throws {
        try await withShell { _, router, catalog, window, hosting in
            router.adopt(.library, in: router.workspace.focusedPane)
            await settle(window, hosting) { Self.libraryField(hosting) != nil && Self.sidebarField(hosting) != nil }
            catalog.query = "lamp"
            await catalog.search()
            catalog.pickSearchOrder(.createdAt)
            catalog.pickSearchOrderDirection(.asc)
            catalog.toggleArchivedFacet()
            catalog.toggleSavepointsFacet()
            await catalog.search()
            try #require(catalog.searchState.order == .home(.createdAt, .asc), "premise: her order for the standing question")
            try #require(catalog.searchState.visibility == .includingArchived && catalog.searchState.includesSavepoints,
                         "premise: two facets armed on the standing question")

            let field = try #require(Self.sidebarField(hosting))
            window.makeFirstResponder(field)
            await settle(window, hosting, timeout: 2) { Self.keyboardField(window) === field }
            #expect(Self.type("harb", window))
            await settle(window, hosting) { catalog.query == "harb" && catalog.searchState.isAnswering }
            await settle(window, hosting, timeout: 0.3)
            #expect(catalog.query == "harb", "the sidebar's words replaced the standing question")
            #expect(catalog.searchState.order == .relevance, "a new search starts at relevance")
            #expect(catalog.searchState.visibility == .living, "the archived facet does not ride over")
            #expect(!catalog.searchState.includesSavepoints, "the commits facet does not ride over")
            #expect(Self.keyboardField(window) === field)
        }
    }

    /// A door, never a mirror (PROVISIONAL P-819-B3d): while the Library is
    /// already searching its own words, the sidebar field stays empty.
    @Test func theFieldStaysEmptyWhileTheLibrarySearchesItsOwnWords() async throws {
        try await withShell { _, router, catalog, window, hosting in
            router.adopt(.library, in: router.workspace.focusedPane)
            await settle(window, hosting) { Self.libraryField(hosting) != nil && Self.sidebarField(hosting) != nil }
            catalog.query = "harbour"
            await catalog.search()
            await settle(window, hosting, timeout: 0.6)
            #expect(Self.sidebarField(hosting)?.stringValue == "", "the door does not mirror the Library's words")
            #expect(Self.libraryField(hosting)?.stringValue == "harbour")
        }
    }
}

// MARK: - The place (R-819-3 — nothing below shifts)

@MainActor
@Observable
final class SidebarFieldSwitch {
    var mounted = false
}

private struct SidebarFieldHost: View {
    let session: AppSession
    let workspace: WorkspaceModel
    let stars: StarsModel
    let theme: ThemeStore
    let field: SidebarFieldSwitch

    var body: some View {
        SidebarView(
            session: session, model: LibraryViewModel(session: session),
            pool: PoolViewModel(session: session),
            workspace: workspace, stars: stars,
            searchDoor: field.mounted
                ? SidebarSearchDoor(ask: { _ in }, end: {}, keyboardToLibrary: {}) : nil,
            selection: .constant(.shelf),
            noteBox: nil)
            .frame(width: 240)
            .environment(theme)
    }
}

@MainActor
@Suite("VX-822 — the field takes the column's empty band and moves nothing", .serialized)
struct SidebarSearchFieldPlaceTests {
    /// The AppKit field draws the voice's SMALL face: its words measure what
    /// SwiftUI's `tokens.small` measures (within a point), in both voices.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func theFieldsFaceIsTheVoicesSmallFace(voice: ThemeVoice) throws {
        let tokens = VoiceTokens.resolve(voice: voice, dark: false)
        let sample = "Search the harbour lamp"
        let renderer = ImageRenderer(content: Text(sample).font(tokens.small).lineLimit(1).fixedSize())
        renderer.scale = 1
        let swiftUI = try #require(renderer.nsImage?.size.width, "SwiftUI measured the small face")
        let appKit = (sample as NSString).size(
            withAttributes: [.font: SidebarSearchFieldLayout.font(for: voice)]).width
        #expect(abs(swiftUI - appKit) < 1.5, "\(voice): SwiftUI \(swiftUI) vs AppKit \(appKit)")
    }

    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView, until predicate: () -> Bool = { false }, turns: Int = 60
    ) async {
        for _ in 0..<turns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            Self.pumpRunLoop(0.02)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
            if predicate() { return }
        }
    }

    /// With Starred and without: the first section's top — the Starred
    /// header's words, or the Bookcase row's box — is the SAME point with the
    /// field mounted as without it, and the field draws inside the band above
    /// it (its bottom at or above that top, its top inside the column).
    @Test(arguments: [false, true])
    func theFirstSectionsTopNeverMovesForTheField(starred: Bool) async throws {
        #if DEBUG
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 8221))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            if starred {
                let note = try session.operations.createPost(title: "a starred note")
                let json = String(decoding: try JSONEncoder().encode([StarTarget.post(note.id).key]), as: UTF8.self)
                try await db.write { db in
                    try db.execute(
                        sql: """
                            INSERT INTO setting (key, value) VALUES ('starred', ?)
                            ON CONFLICT(key) DO UPDATE SET value = excluded.value
                            """,
                        arguments: [json])
                }
            }
            let workspace = WorkspaceModel()
            let stars = StarsModel(session: session)
            let observing = Task { await stars.start() }
            defer { observing.cancel() }
            let theme = ThemeStore(session: session)
            let field = SidebarFieldSwitch()
            let key = SidebarGeometry.bodyKey(for: workspace)
            let headers = SidebarGeometry.headers(session.debugProbeScope)
            SidebarGeometry.forgetSections(for: workspace)
            headers.resetHeaders()

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 240, height: 760),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(rootView: SidebarFieldHost(
                session: session, workspace: workspace, stars: stars, theme: theme, field: field))
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            defer {
                window.orderOut(nil)
                window.contentView = nil
                SidebarGeometry.forgetSections(for: workspace)
                headers.resetHeaders()
            }

            /// The first section's top, as drawn: Starred's header words, else
            /// the Bookcase row's box.
            @MainActor func firstTop() -> CGRect? {
                starred ? headers.headerTextFrames[StarCopy.sectionHeader]
                    : SidebarGeometry.firstAreaRowFrames[key]
            }
            await settle(window, hosting) {
                firstTop() != nil && (!starred || stars.items.count == 1)
            }
            await settle(window, hosting, turns: 10)
            let without = try #require(firstTop(), "the first section drew (starred: \(starred))")
            #expect(SidebarGeometry.searchFieldFrames[key] == nil, "no door, no field")

            field.mounted = true
            await settle(window, hosting) { SidebarGeometry.searchFieldFrames[key] != nil }
            await settle(window, hosting, turns: 10)
            let drawn = try #require(SidebarGeometry.searchFieldFrames[key], "the field drew")
            let with = try #require(firstTop())
            #expect(with == without, "the first section's top never moved for the field: \(without) → \(with)")
            #expect(abs(drawn.height - SidebarLayout.topPadding) < 0.5,
                    "the field is exactly the band's height: \(drawn.height)")
            let column = try #require(SidebarGeometry.columnScrollFrames[key], "the column's scroll drew")
            #expect(drawn.minY >= column.minY - 0.5 && drawn.maxY <= column.maxY,
                    "the field draws inside the column: \(drawn) in \(column)")
            // SwiftUI's global space runs DOWN from the window's top: the
            // field opens the column and ends where the first section begins.
            #expect(abs(drawn.minY - column.minY) < 0.5, "the field opens the column: \(drawn) in \(column)")
            #expect(drawn.maxY <= with.minY + 0.5,
                    "the field ends at or before the first section begins: field \(drawn), section \(with)")
        }
        #endif
    }
}
