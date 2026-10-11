//
//  SearchPickerPanelGeometryTests.swift
//  VariorumTests
//
//  13n-c — the HELD WALKS' two picker defects (the plan's HELD-WALKS RECORD,
//  rows D-W1 and D-W2), found walking the grant sheet on the dev store with
//  U2's scale seed. Both are bug-class; each pin was watched RED on the
//  pre-fix tree before the fix landed.
//
//  **D-W1 — the note leg never showed its rows.** A SwiftUI popover sizes
//  itself ONCE, from its content's first frame, and never follows a later
//  size change (walked: the BOOK picker opened at full height and kept it
//  when typing narrowed it to one row). A SOURCED `SearchPickerPanel` (the
//  grant sheet's note feed) has no rows in its first frame — the feed has
//  not answered yet — and its list was `ScrollView { LazyVStack }` with only
//  a MAX height, whose ideal height is its content's: ~0. So the popover
//  opened to the search field over a 2-pt list, and the rows that landed
//  after were clipped away. The pin: a sourced panel's FIRST frame — before
//  its feed answers — reserves the list's room.
//
//  **D-W2 — a book in two sections drew BLANK in the later one.** The panel
//  nested `ForEach(sections)` → `ForEach(section.options)` inside ONE
//  `LazyVStack`, identifying rows by the bare option id; the book picker's
//  quick sections (Recently edited, Starred) REPEAT rows whose home is a
//  shelf, so one identity sat in the lazy stack twice and the later slot
//  drew empty (walked: Fixture book 039, recently edited AND starred, left a
//  37-pt hole in Starred; a starred book left one in its shelf). The pin
//  renders a panel where one option sits in three sections beside a CONTROL
//  panel of the same shape whose repeats carry distinct ids, and counts the
//  inked text bands of each: a blank slot is one band fewer.
//

import AppKit
import SwiftUI
import Testing
@testable import Variorum

@MainActor
@Suite("The sectioned picker panel draws every row it is given (13n-c walk D-W1 · D-W2)", .serialized)
struct SearchPickerPanelGeometryTests {

    private func pump(_ seconds: TimeInterval = 0.02) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    // MARK: - D-W1

    @Test("a sourced panel's first frame reserves its list's room, because the popover sizes once from it")
    func aSourcedPanelsFirstFrameReservesItsList() async {
        for tokens in [VoiceTokens.studyLight, .terminalLight] {
            // A feed that has not answered yet — the state every sourced
            // panel's FIRST frame is in, which is the frame the popover
            // sizes itself from.
            let panel = SearchPickerPanel(
                tokens: tokens, prompt: "Find a note", emptyText: "No notes yet.",
                source: { _ in
                    try? await Task.sleep(for: .seconds(30))
                    return []
                },
                width: 480, onPick: { _ in }, onClose: {})
            let hosting = NSHostingView(rootView: panel)
            hosting.layoutSubtreeIfNeeded()
            let first = hosting.fittingSize.height
            #expect(first >= SearchPickerPanel.listHeight,
                    "the first frame is \(first) pt tall — the popover would open over a list too short to show the rows the feed sends after")
        }
    }

    @Test("a panel given its rows up front still sizes to them (the book picker's road is unchanged)")
    func anArrangedPanelStillSizesToItsRows() async {
        let few = SearchPickerArrangement(id: "a", label: "a–z", sections: [
            SearchPickerSection(id: "s", title: nil, options: [
                SearchPickerOption(id: "one", label: "one"),
                SearchPickerOption(id: "two", label: "two"),
            ]),
        ])
        let panel = SearchPickerPanel(
            tokens: .studyLight, prompt: "Find a book", emptyText: "No books.",
            arrangements: [few], width: 480, onPick: { _ in }, onClose: {})
        let hosting = NSHostingView(rootView: panel)
        hosting.layoutSubtreeIfNeeded()
        #expect(hosting.fittingSize.height < SearchPickerPanel.listHeight,
                "two rows given up front keep a short panel — only a feed that answers later reserves the list")
    }

    // MARK: - D-W2

    /// The book picker's shape in small: one book recently edited, starred
    /// and on its shelf.
    private func sections(repeatsShareAnID: Bool) -> [SearchPickerSection] {
        func book(_ suffix: String) -> SearchPickerOption {
            SearchPickerOption(id: repeatsShareAnID ? "book-039" : "book-039-\(suffix)",
                               label: "Fixture book 039 — notes toward a chapter")
        }
        return [
            SearchPickerSection(id: "recent", title: "Recently edited", options: [
                book("recent"), SearchPickerOption(id: "book-041", label: "Fixture book 041 — what the garden knew"),
            ], isQuick: true),
            SearchPickerSection(id: "starred", title: "Starred", options: [
                SearchPickerOption(id: "book-010", label: "Fixture book 010 — field notes, late"), book("starred"),
            ], isQuick: true),
            SearchPickerSection(id: "shelf-letters", title: "letters", options: [
                book("home"), SearchPickerOption(id: "book-086", label: "Fixture book 086 — a letter never sent"),
            ]),
        ]
    }

    /// The panel rendered in a window and its inked text bands counted — a
    /// row that drew nothing is one band fewer.
    private func inkedBands(_ sections: [SearchPickerSection], tokens: VoiceTokens) async -> Int {
        let size = NSSize(width: 480, height: 520)
        let window = NSWindow(
            contentRect: NSRect(origin: NSPoint(x: -4_000, y: -4_000), size: size),
            styleMask: [.borderless], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.appearance = NSAppearance(named: .aqua)
        defer {
            window.orderOut(nil)
            window.close()
        }
        let panel = SearchPickerPanel(
            tokens: tokens, prompt: "Find a book", emptyText: "No books.",
            arrangements: [SearchPickerArrangement(id: "shelf", label: "by shelf", sections: sections)],
            width: 480, onPick: { _ in }, onClose: {})
        let hosting = NSHostingView(rootView: panel.environment(\.colorScheme, .light))
        hosting.appearance = window.appearance
        hosting.frame = NSRect(origin: .zero, size: size)
        window.contentView = hosting
        window.orderFront(nil)
        for _ in 0..<30 {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
        }
        guard let rep = hosting.bitmapImageRepForCachingDisplay(in: hosting.bounds) else {
            Issue.record("no bitmap")
            return -1
        }
        hosting.cacheDisplay(in: hosting.bounds, to: rep)
        // A pixel row is inked when any pixel in the text column is clearly
        // darker than the panel's ground; consecutive inked rows are a band.
        var bands = 0
        var inBand = false
        for y in 0..<rep.pixelsHigh {
            var inked = false
            var x = rep.pixelsWide / 20
            while x < rep.pixelsWide * 19 / 20 {
                if let color = rep.colorAt(x: x, y: y)?.usingColorSpace(.deviceRGB),
                   color.alphaComponent > 0.5,
                   (color.redComponent + color.greenComponent + color.blueComponent) / 3 < 0.6 {
                    inked = true
                    break
                }
                x += 1
            }
            if inked && !inBand { bands += 1 }
            inBand = inked
        }
        return bands
    }

    @Test("a row repeated across sections draws in EVERY section it is listed in — never a blank slot")
    func aRepeatedRowDrawsInEverySection() async {
        for tokens in [VoiceTokens.studyLight, .terminalLight] {
            let control = await inkedBands(sections(repeatsShareAnID: false), tokens: tokens)
            let repeated = await inkedBands(sections(repeatsShareAnID: true), tokens: tokens)
            #expect(control > 6, "the control drew its titles and rows (\(control) bands)")
            #expect(repeated == control,
                    "the book listed in three sections drew \(repeated) bands where the same shape with distinct ids draws \(control) — a repeated row left a blank slot")
        }
    }
}
