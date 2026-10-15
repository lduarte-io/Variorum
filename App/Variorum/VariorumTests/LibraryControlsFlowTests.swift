//
//  LibraryControlsFlowTests.swift
//  VariorumTests (Mac)
//
//  VX-175 (the VX-283 run, U3 — P-U3-2 as RULED, 2026-10-15): at the app's
//  own 1240-pt default window with the info panel open, the Library's
//  controls row (search · scope · mode · sort ▾ · when ▾) was wider than the
//  list column — the search field squeezed to a sliver and the panel pushed
//  off the window's right edge (the 13n-c walk's F-R1-1: ≈92 pt Study, ≈136
//  pt Terminal at a 230-pt sidebar). THE MECHANISM: the row was one
//  `HStack(spacing: 10)` whose minimum width is the sum of its controls'
//  minimums (≈709 / ≈753 pt measured against a 617–631-pt room); an
//  overflowing HStack widens the column, and the column's HStack with the
//  panel overflows the window.
//
//  THE RULED FIX: `LibraryControlsFlow` — one line when it fits (placed
//  exactly as the HStack placed it), else search · scope over mode · sort ·
//  when, over ONE set of views; the wrap decision pure
//  (`LibraryControlsFlowRule`).
//
//  THE PINS: the rule, pure (guards — the HStack's own distribution, the
//  decision, both arrangements); and a GEOMETRY ORACLE — the real catalog
//  mounted at the default window's library width (1240 − the 210-pt sidebar
//  − its seam = 1029 pt) with the panel open, both voices: the panel stays
//  inside the window, the row inside the list column, the field at least
//  its own prompt's width. RED ON OLD by behavioural revert **R-L**
//  (`LibraryControlsFlow(spacing: 10, lineSpacing: 8) {` back to the old
//  `HStack(spacing: 10) {` in `LibraryCatalogView.header`): that cell. The
//  panel-closed and wide-window cells are GUARDS (one line, as before).
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The rule, pure

@Suite("VX-175 — the controls row's flow rule (pure)")
struct LibraryControlsFlowRuleTests {
    typealias Rule = LibraryControlsFlowRule

    /// A control that takes any width in `lo…hi` (a flexible frame), with a
    /// fixed height.
    static func child(_ lo: CGFloat, _ hi: CGFloat, ideal: CGFloat? = nil, height: CGFloat = 24) -> Rule.Child {
        Rule.Child(
            flexibility: hi - lo, ideal: ideal ?? hi,
            width: { max(lo, min(hi, $0)) }, height: { _ in height })
    }

    /// The row's five controls in their order, at the harness's Terminal
    /// numbers: the field (a sliver floor, 320 cap, its prompt 211 wide),
    /// scope (228…280), mode (180…230), sort and when (fixed).
    static var row: [Rule.Child] {
        [child(75, 320, ideal: 211, height: 22), child(228, 280), child(180, 230),
         child(174, 174, height: 18), child(53, 53, height: 18)]
    }

    @Test func aWideLineGivesEveryControlItsWidestAsTheHStackDid() {
        #expect(Rule.distribute(Self.row, in: 1181, spacing: 10) == [320, 280, 230, 174, 53])
    }

    /// The HStack's order — the least flexible first, each an equal share of
    /// what is left — squeezes the FIELD first and the fixed doors never.
    @Test func aNarrowLineSqueezesTheFieldFirst() {
        let widths = Rule.distribute(Self.row, in: 900, spacing: 10)
        #expect(widths[3] == 174 && widths[4] == 53, "the fixed doors keep their words")
        #expect(widths[0] < 211, "the field is the one squeezed (\(widths))")
    }

    @Test func oneLineOnlyWhileTheFieldKeepsItsPromptAndTheLineFits() {
        #expect(Rule.fitsOneLine(widths: [320, 280, 230, 174, 53], fieldIdeal: 211, width: 1181, spacing: 10))
        #expect(!Rule.fitsOneLine(widths: [194, 228, 211, 174, 53], fieldIdeal: 211, width: 900, spacing: 10),
                "the field below its prompt — two lines")
        #expect(!Rule.fitsOneLine(widths: [211, 228, 180, 174, 53], fieldIdeal: 211, width: 800, spacing: 10),
                "the line wider than the room — two lines")
    }

    /// The default window with the panel open (631 pt for the row): search ·
    /// scope over mode · sort · when, each line as the HStack places it.
    @Test func atTheDefaultWindowWithThePanelOpenTheRowWrapsAfterScope() {
        let arranged = Rule.arrange(Self.row, lineOneCount: 2, width: 631, spacing: 10, lineSpacing: 8)
        #expect(!arranged.oneLine)
        #expect(arranged.frames.map(\.minX) == [0, 330, 0, 240, 424])
        #expect(arranged.frames.map(\.width) == [320, 280, 230, 174, 53])
        #expect(arranged.frames[0].minY == 1 && arranged.frames[1].minY == 0, "line 1, centred on it")
        #expect(arranged.frames[2].minY == 32 && arranged.frames[3].minY == 35, "line 2, below the line spacing")
        #expect(arranged.size == CGSize(width: 610, height: 56))
        #expect(arranged.size.width <= 631, "the row fits the room")
    }

    /// A wide room: one line, every control where the HStack put it.
    @Test func aWideRoomIsOneLineExactlyAsBefore() {
        let arranged = Rule.arrange(Self.row, lineOneCount: 2, width: 1181, spacing: 10, lineSpacing: 8)
        #expect(arranged.oneLine)
        #expect(arranged.frames.map(\.minX) == [0, 330, 620, 860, 1044])
        #expect(arranged.size == CGSize(width: 1097, height: 24))
    }

    /// The default window with the panel CLOSED (981 pt): one line.
    @Test func theDefaultWindowWithThePanelClosedIsOneLine() {
        #expect(Rule.arrange(Self.row, lineOneCount: 2, width: 981, spacing: 10, lineSpacing: 8).oneLine)
    }

    /// The ideal query (no width offered) is one line at every control's
    /// widest; the minimum query (zero) is two lines at their narrowest — the
    /// row's honest minimum is its wider LINE, never the sum.
    @Test func theIdealIsOneLineAndTheMinimumIsTheWiderLine() {
        let ideal = Rule.arrange(Self.row, lineOneCount: 2, width: .infinity, spacing: 10, lineSpacing: 8)
        #expect(ideal.oneLine && ideal.size.width == 1097)
        let minimum = Rule.arrange(Self.row, lineOneCount: 2, width: 0, spacing: 10, lineSpacing: 8)
        #expect(!minimum.oneLine)
        // Typed CGFloat on purpose: left to itself, `max` of integer literals
        // is an `Int` inside `#expect`, and the macro's CGFloat-vs-Int
        // comparison answers false on equal values (the first window's red).
        let widerLine: CGFloat = max(75 + 10 + 228, 180 + 10 + 174 + 10 + 53)
        #expect(minimum.size.width == widerLine)
    }

    /// Timeline hides sort and when: line 2 is the mode alone.
    @Test func inTimelineLineTwoIsTheModeAlone() {
        let timeline = Array(Self.row.prefix(3))
        let arranged = Rule.arrange(timeline, lineOneCount: 2, width: 500, spacing: 10, lineSpacing: 8)
        #expect(!arranged.oneLine)
        #expect(arranged.frames[2].minX == 0 && arranged.frames[2].minY == 32)
        #expect(Rule.arrange(timeline, lineOneCount: 2, width: 900, spacing: 10, lineSpacing: 8).oneLine)
    }
}

// MARK: - The catalog, mounted (the geometry oracle)

@MainActor
@Suite("VX-175 — the Library's controls row fits the default window with the panel open", .serialized)
struct LibraryControlsGeometryTests {
    /// The library's width at the app's 1240-pt default window: the window −
    /// the sidebar's ideal − its seam (`LibraryBulkRowGeometryTests.room`'s
    /// arithmetic, one step earlier).
    static var defaultLibraryWidth: CGFloat {
        1240 - CGFloat(ShellSplit<EmptyView, EmptyView>.idealWidth)
            - ShellSplit<EmptyView, EmptyView>.dividerWidth
    }

    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    private func settle(_ window: NSWindow, _ hosting: NSView, _ seconds: TimeInterval) async {
        let deadline = Date().addingTimeInterval(seconds)
        while Date() < deadline {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            Self.pumpRunLoop(0.03)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }

    /// The field's own ideal — its prompt, in the voice's small face (the
    /// header's construction).
    private func promptWidth(_ tokens: VoiceTokens) -> CGFloat {
        let field = TextField(tokens.chromeLabel("Search books, notes, blocks…"), text: .constant(""))
            .textFieldStyle(.roundedBorder)
            .font(tokens.small)
            .frame(maxWidth: 320)
        return NSHostingController(rootView: field.fixedSize())
            .sizeThatFits(in: CGSize(width: 10_000, height: 10_000)).width
    }

    private struct Read {
        let root: CGRect
        let controls: CGRect
        let field: CGRect
        let panel: CGRect?
        let divider: CGRect?
        let prompt: CGFloat
    }

    private func mounted(
        voice: ThemeVoice, width: CGFloat, panelOpen: Bool, _ body: (Read) throws -> Void
    ) async throws {
        #if DEBUG
        let db = try AppDatabase.inMemory()
        let suite = "vx175-controls-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 175))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            for index in 0..<6 {
                let note = try session.operations.createPost(title: "A note to pick \(index)")
                _ = try session.operations.newBlock(in: note.id, text: "words of \(index)")
            }
            try session.operations.setThemeVoice(voice)
            let theme = ThemeStore(session: session)
            let observing = Task { await theme.start() }
            defer { observing.cancel() }
            let model = LibraryCatalogModel(session: session, defaults: defaults)
            await model.search()
            LibraryPanelOracle.reset()

            let window = NSWindow(
                contentRect: NSRect(x: 40, y: 40, width: width, height: 700),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(rootView: AnyView(
                LibraryCatalogView(
                    session: session, model: model, library: LibraryViewModel(session: session),
                    tags: TagsViewModel(session: session), onOpen: { _ in })
                .environment(theme)))
            hosting.frame = NSRect(x: 0, y: 0, width: width, height: 700)
            window.contentView = hosting
            window.orderFrontRegardless()
            defer {
                window.orderOut(nil)
                window.contentView = nil
                window.close()
            }
            await settle(window, hosting, 1.2)
            if panelOpen {
                let first = try #require(model.listedNoteIDs.first, "the notes listed")
                model.clickNoteRow(first, modifiers: .none)
                await settle(window, hosting, 1.0)
            }
            let tokens = theme.tokens(for: .light)
            let read = Read(
                root: try #require(LibraryPanelOracle.rootFrame, "the catalog reported its frame"),
                controls: try #require(LibraryPanelOracle.controlsFrame, "the controls row reported"),
                field: try #require(LibraryPanelOracle.searchFieldFrame, "the search field reported"),
                panel: LibraryPanelOracle.panelFrame,
                divider: LibraryPanelOracle.dividerFrame,
                prompt: promptWidth(tokens))
            print("[VX-175 controls] \(voice) · width \(width) · panel \(panelOpen) · root \(read.root) · controls \(read.controls) · field \(read.field) · panel \(String(describing: read.panel)) · prompt \(read.prompt)")
            try body(read)
        }
        #endif
    }

    /// **RED ON OLD (R-L).** The default window, the panel open: nothing is
    /// pushed off the window and the field is never a sliver.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func atTheDefaultWindowWithThePanelOpenNothingIsPushedOff(voice: ThemeVoice) async throws {
        let width = Self.defaultLibraryWidth
        try await mounted(voice: voice, width: width, panelOpen: true) { read in
            let panel = try #require(read.panel, "\(voice): the info panel opened")
            #expect(read.root.width <= width + 0.5,
                    "\(voice): the catalog fits the window (\(read.root.width) of \(width) pt)")
            #expect(panel.maxX <= width + 0.5,
                    "\(voice): the panel's right edge stays inside the window (\(panel.maxX) of \(width) pt)")
            if let divider = read.divider {
                #expect(read.controls.maxX <= divider.minX + 0.5,
                        "\(voice): the controls stay in the list column (\(read.controls.maxX) vs the divider at \(divider.minX))")
            }
            #expect(read.field.width >= read.prompt - 0.5,
                    "\(voice): the search field keeps its own prompt's width (\(read.field.width) of \(read.prompt) pt)")
        }
    }

    /// GUARD: the default window with the panel closed — one line, as before.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func atTheDefaultWindowWithThePanelClosedTheRowIsOneLine(voice: ThemeVoice) async throws {
        try await mounted(voice: voice, width: Self.defaultLibraryWidth, panelOpen: false) { read in
            #expect(read.controls.height < 40, "\(voice): one line (\(read.controls.height) pt tall)")
            #expect(read.field.width >= read.prompt - 0.5, "\(voice): the field whole (\(read.field.width))")
        }
    }

    /// GUARD: a wide window (1440 pt) — one line, the field at its 320 and the
    /// header's 24-pt inset, exactly as before.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func atAWideWindowTheRowIsOneLineAsBefore(voice: ThemeVoice) async throws {
        let width = 1440 - CGFloat(ShellSplit<EmptyView, EmptyView>.idealWidth)
            - ShellSplit<EmptyView, EmptyView>.dividerWidth
        try await mounted(voice: voice, width: width, panelOpen: false) { read in
            #expect(read.controls.height < 40, "\(voice): one line (\(read.controls.height) pt tall)")
            #expect(abs(read.field.width - 320) < 0.5, "\(voice): the field at its 320 (\(read.field.width))")
            #expect(abs(read.field.minX - 24) < 0.5, "\(voice): at the header's inset (\(read.field.minX))")
        }
    }
}
