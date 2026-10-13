//
//  NoteIndexColumnScrollCostTests.swift
//  VariorumTests
//
//  **17y B1 item (j) — THE NOTE INDEX'S SCROLL COST** (her walk-close report,
//  verbatim: "every scroll in this app works beautifully with no lag except
//  for index scroll within a long note… laggy, sometimes a quick scroll will
//  send you straight to the top, just bad performance").
//
//  The trace (the 17y B1 RECORD's § THE TRACE, measured on the dev-store
//  build): scrolling the `▸ 01` column of a 2,000-block note ran at ~5 fps,
//  and the whole cost was per REALIZED ROW — no body re-evaluation, no store
//  read — in two parts:
//
//  1. **A whole-note lookup per row** (P1's letter): `rowsByID` built a
//     `Dictionary` over EVERY row of the note each time a row was built (626
//     µs at 2,000 blocks, several times per row). The pin scrolls a mounted
//     column and counts: realizing rows must build NO whole-note lookup.
//  2. **Live AppKit controls on every row** (P3's shape): each row built its
//     `↑ ↓ ⋯` controls though they rest at 25 % until hovered. The pin
//     counts: with nothing hovered or selected, scrolling builds NO row's
//     live controls.
//
//  RED on the pre-fix tree for both claims (the counts are the shipped
//  probes', `NoteIndexColumnProbe`, which are behaviour-free). The scroll is
//  staged through the column's own `NSClipView` — the column binds no scroll
//  position, so a programmatic scroll is the column's scroll (TEXTKIT2 §3's
//  harness fact concerns BOUND positions only).
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("17y B1 (j) — the note index column's per-row scroll cost", .serialized)
struct NoteIndexColumnScrollCostTests {
    /// A note long enough that the column must realize rows as it scrolls.
    nonisolated static let blockCount = 320

    private func withColumn<T>(
        selected: String? = nil,
        _ body: @MainActor (BlockTOCViewModel, NSScrollView, NSWindow) async throws -> T
    ) async throws -> T {
        #if DEBUG
        NoteIndexColumnProbe.reset()
        #endif
        let db = try AppDatabase.inMemory()
        return try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 17))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "a long note")
            try await session.runner.run { ops in
                for i in 0..<Self.blockCount {
                    let text = i % 40 == 0 ? "# Part \(i / 40 + 1)" : "Line \(i) of the long note."
                    _ = try ops.newBlock(in: post.id, text: text, registeringUndo: false)
                }
            }
            let model = BlockTOCViewModel(session: session, postID: post.id)
            await model.primeRows()
            #expect(model.rows.count == Self.blockCount)
            // AWAY from the machine's pointer: a row the scroll carries under
            // a real pointer is HOVERED, and hover legitimately wakes a row's
            // doors — the claim here is about rows nothing is pointing at.
            let window = NSWindow(
                contentRect: Self.frameAwayFromThePointer(),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(rootView: AnyView(
                NoteIndexColumn(
                    session: session, model: model,
                    tokens: VoiceTokens.fallback(for: .light),
                    selectedBlockID: selected.flatMap { ordinal in
                        model.rows.first { $0.text == ordinal }?.blockID
                    },
                    showsCount: true,
                    columnTarget: .constant(nil),
                    onSelect: { _ in })))
            hosting.frame = NSRect(x: 0, y: 0, width: 340, height: 600)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            defer { window.orderOut(nil); window.close() }
            await pump(window, hosting)
            let scroll = try #require(
                Self.scrollViews(in: hosting).first { ($0.documentView?.frame.height ?? 0) > 2_000 },
                "the column's scroll view (a long note's column is taller than the window)")
            return try await body(model, scroll, window)
        }
    }

    /// A 340 × 600 frame on the far side of the screen from the pointer.
    private static func frameAwayFromThePointer() -> NSRect {
        let mouse = NSEvent.mouseLocation
        let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let x = mouse.x < screen.midX ? screen.maxX - 360 : screen.minX + 20
        let y = mouse.y < screen.midY ? screen.maxY - 620 : screen.minY + 20
        return NSRect(x: x, y: y, width: 340, height: 600)
    }

    private func pump(_ window: NSWindow, _ view: NSView, turns: Int = 6) async {
        for _ in 0..<turns {
            view.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(15))
        }
    }

    private static func scrollViews(in view: NSView) -> [NSScrollView] {
        var found: [NSScrollView] = []
        if let scroll = view as? NSScrollView { found.append(scroll) }
        for sub in view.subviews { found += scrollViews(in: sub) }
        return found
    }

    /// Scroll the column down through `distance` points in viewport-sized
    /// steps, letting each step lay out (the lazy column realizes rows).
    private func scrollDown(
        _ scroll: NSScrollView, _ window: NSWindow, distance: CGFloat
    ) async {
        let clip = scroll.contentView
        var y = clip.bounds.origin.y
        let target = y + distance
        while y < target {
            y = min(target, y + 400)
            clip.scroll(to: NSPoint(x: 0, y: y))
            scroll.reflectScrolledClipView(clip)
            await pump(window, scroll, turns: 3)
        }
    }

    /// **M1, part 1 — P1's letter.** Realizing rows while she scrolls builds
    /// no whole-note lookup. RED on the shipped column: every realized row
    /// rebuilt a `Dictionary` over all 320 rows (at 2,000 blocks: 626 µs each).
    @Test func scrollingTheColumnBuildsNoWholeNoteLookupPerRow() async throws {
        try await withColumn { _, scroll, window in
            #if DEBUG
            NoteIndexColumnProbe.reset()
            await scrollDown(scroll, window, distance: 6_000)
            let built = NoteIndexColumnProbe.rowsBuilt
            let lookups = NoteIndexColumnProbe.wholeNoteLookups
            #expect(built >= 40, "the scroll must realize rows for the claim to mean anything (built \(built))")
            #expect(lookups == 0,
                    "realizing \(built) rows built \(lookups) whole-note lookups — a row must cost what it shows, never the note")
            #endif
        }
    }

    /// **M1, part 2 — P3's shape.** With nothing hovered and nothing selected,
    /// scrolling builds no row's live (AppKit-backed) `↑ ↓ ⋯` controls. RED on
    /// the shipped column: every realized row built all three.
    @Test func restingRowsBuildNoLiveControlsWhileScrolling() async throws {
        try await withColumn { _, scroll, window in
            #if DEBUG
            NoteIndexColumnProbe.reset()
            await scrollDown(scroll, window, distance: 6_000)
            let built = NoteIndexColumnProbe.rowsBuilt
            let live = NoteIndexColumnProbe.liveControlRows
            #expect(built >= 40, "the scroll must realize rows (built \(built))")
            #expect(live == 0,
                    "\(live) of \(built) resting rows built live controls — only the hovered or selected row may")
            #endif
        }
    }

    /// The control: the SELECTED row keeps its live controls (her hover-
    /// waking design — "the controls wake on hover" and stand at full strength
    /// on the selected row). Green on both trees; it guards the fix from
    /// overshooting into "no controls anywhere".
    @Test func theSelectedRowStillBuildsItsLiveControls() async throws {
        try await withColumn(selected: "Line 3 of the long note.") { _, _, _ in
            #if DEBUG
            #expect(NoteIndexColumnProbe.liveControlRows >= 1,
                    "the selected row's ↑ ↓ ⋯ must be live")
            #endif
        }
    }

    /// **VX-223 — the row's ⋯ pops at menu size** (her report: "very small
    /// text on Read mode's three-dots dropdown"). The live controls' row
    /// carries `.controlSize(.mini)` for its ↑ ↓ keys, and the ⋯ menu beside
    /// them inherited it — its popped rows drew at the mini 9 pt. RED ON OLD
    /// by that mechanism; the class lives in `ChromeMenuRowSizeTests`.
    @Test func theRowMenuPopsAtMenuSize() async throws {
        try await withColumn(selected: "Line 3 of the long note.") { _, _, window in
            let host = try #require(window.contentView)
            let sizes = ChromeMenuProbe.rowSizes(in: host)
            #expect(!sizes.isEmpty, "the selected row's ⋯ is a pop-up underneath")
            #expect(sizes.allSatisfy { $0 >= ChromeMenuProbe.menuSize },
                    "every popped row reads at menu size, never mini: \(sizes)")
        }
    }

    /// **The resting hint is the live set's own footprint** (a geometry
    /// oracle — the fix's face). The live controls draw at their OWN size
    /// inside the hint's footprint; if the two differed, the eye would see the
    /// doors jump as a row wakes and the title would truncate somewhere new.
    @Test func theRestingHintIsTheLiveControlsFootprint() async throws {
        try await withColumn(selected: "Line 3 of the long note.") { _, _, _ in
            #if DEBUG
            let live = try #require(NoteIndexColumnProbe.liveSize)
            let hint = RestingRowControls.footprint
            #expect(abs(hint.width - live.width) <= 0.5,
                    "hint footprint \(hint) vs live controls \(live): widths differ")
            #expect(abs(hint.height - live.height) <= 0.5,
                    "hint footprint \(hint) vs live controls \(live): heights differ")
            #endif
            // …and the drawn hint itself fills exactly that footprint.
            let drawn = NSHostingView(rootView: RestingRowControls(
                tokens: VoiceTokens.fallback(for: .light))).fittingSize
            #expect(abs(drawn.width - RestingRowControls.footprint.width) <= 0.5
                    && abs(drawn.height - RestingRowControls.footprint.height) <= 0.5,
                    "the drawn hint is \(drawn), its footprint \(RestingRowControls.footprint)")
        }
    }

    /// **The wake rule** (pure): the selected row is always awake; a hovered
    /// row only while the column is still — a row the scroll carries under a
    /// resting pointer must not build its AppKit controls (measured ~20 ms a
    /// frame of churn on the 2,000-block note). No red-on-old form exists: the
    /// shipped column had no wake decision at all — every row was live.
    @Test func aHoveredRowWakesOnlyWhileTheColumnIsStill() {
        #expect(NoteIndexRowWake.isLive(selected: true, hovering: false, scrolling: true))
        #expect(NoteIndexRowWake.isLive(selected: false, hovering: true, scrolling: false))
        #expect(!NoteIndexRowWake.isLive(selected: false, hovering: true, scrolling: true))
        #expect(!NoteIndexRowWake.isLive(selected: false, hovering: false, scrolling: false))
    }
}
