//
//  InlineHeightReportTests.swift
//  VariorumTests
//
//  18k C2 — the inline (book Outline / spread) editor's HEIGHT REPORT,
//  pinned on its timing and its delivery.
//
//  What was measured before these were written (the plan's UNIT C2 RECORD,
//  THE MEASUREMENT): `InlineEditorSurface` wrote its `@Binding height` from
//  inside `makeNSView` (via `install`) and from every `updateNSView`. Inside
//  a SwiftUI update such a write is the "Modifying state during view update"
//  class — measured as the source of 20 of 20 of those warnings in
//  `BookOutlineLandingTests`' run — and it can be IGNORED (measured in that
//  harness: an update-phase write of 16,134 pt that no body pass ever saw,
//  rescued ~29 ms later by the storage road). The double realization the
//  review blamed on it was DISPROVED (on TRACE B-1's own tree, deferring
//  every write took the warnings to zero and left the double standing).
//
//  So these pin exactly what the fix changes and nothing it does not claim:
//  every report leaves the mount and the update pass for the next turn, a
//  burst of triggers in one turn reports once, and — the delivery law — the
//  FIRST height still arrives, with nothing else to prompt it.
//

import AppKit
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Inline editor height report (18k C2)", .serialized)
struct InlineHeightReportTests {
    @MainActor private final class ReportLog {
        var reports: [CGFloat] = []
    }

    /// ~6k words over 30 blocks — tall enough that the measured height is
    /// nowhere near the 24-pt floor.
    private var corpus: [String] {
        (0..<30).map { p in
            (0..<200).map { "word\(($0 &+ p) % 977)" }.joined(separator: " ") + " ¶\(p)"
        }
    }

    private let chrome = EditorSurfaceChrome(tokens: Queries.ThemeSettings(), dark: false)

    /// One line of the inline editor's prose. TextKit's first full measure
    /// after an edit was measured one line (20 pt) from the layout a later
    /// display pass converges to, with no edit and no report in between —
    /// the measurement brain's class (TEXTKIT2 §2), on the old road and the
    /// new alike, so value arms that follow an edit allow one line.
    private let lineSlack: CGFloat = 24

    private func spin(_ seconds: TimeInterval) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func turn() async {
        spin(0.005)
        await Task.yield()
    }

    /// A few full turns WITH the window's layout and display passes, so a
    /// value compared afterwards is TextKit's converged layout, never a
    /// provisional one (the class `mounted` documents).
    private func converge(_ window: NSWindow) async {
        for _ in 0..<4 {
            window.layoutIfNeeded()
            window.displayIfNeeded()
            await turn()
        }
    }

    /// The harness's text view (holding the projection, attached to its
    /// model) in a short window, installed on a REAL coordinator whose report
    /// closure frames the view the way SwiftUI's `.frame(height:)` would —
    /// in `makeNSView`'s order: the chrome first, then the install.
    ///
    /// **The layout is settled BEFORE the install (measured, not assumed):**
    /// the first full layout after the view enters its window ran at a
    /// PROVISIONAL container width — a first measure read 11,182 pt and the
    /// next turn's 10,929 with no edit, no frame change and no inset change
    /// (StableSurface's "provisional-width first measure" class, old road and
    /// new alike). That is TextKit's, not this report's timing, so the pins
    /// measure a surface whose width has settled.
    private func mounted(
        _ h: EditorHarness, width: CGFloat = 700
    ) async -> (NSWindow, InlineEditorSurface.Coordinator, ReportLog) {
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: width, height: 300),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let container = NSView(frame: NSRect(x: 0, y: 0, width: width, height: 300))
        window.contentView = container
        h.textView.frame = NSRect(x: 0, y: 0, width: width, height: 24)
        container.addSubview(h.textView)
        window.orderFrontRegardless()
        let coordinator = InlineEditorSurface.Coordinator(model: h.model)
        coordinator.applyChrome(chrome, to: h.textView)
        for _ in 0..<3 {
            _ = PaneMeasurement.height(of: h.textView)
            await turn()
        }
        let log = ReportLog()
        let textView = h.textView
        coordinator.install(textView: textView) { height in
            log.reports.append(height)
            textView.frame.size.height = height
        }
        return (window, coordinator, log)
    }

    /// **THE MOUNT: no report inside it, and the first height still arrives.**
    /// `install` runs inside `makeNSView`. The text view here already holds
    /// its whole projection, so NO storage edit follows the install — the
    /// install's own report is the only road the first height has (the
    /// delivery law: wiring is the delivery; a mount that reports nothing
    /// leaves the 24-pt frame forever).
    ///
    /// RED ON OLD: `install` ended in a synchronous `remeasure()`, so the
    /// report landed inside the mount (`reports.count == 1` at once).
    @Test func theFirstHeightArrivesOnTheTurnAfterTheMountNeverInsideIt() async throws {
        try await withInlineEditor(seedBlocks: corpus) { h in
            let (window, coordinator, log) = await mounted(h)
            defer { coordinator.uninstall(); window.orderOut(nil); window.close() }
            #expect(log.reports.isEmpty,
                    "no height is reported inside the mount: \(log.reports)")

            for _ in 0..<20 where log.reports.isEmpty { await turn() }
            await converge(window)
            let measured = PaneMeasurement.height(of: h.textView)
            #expect(log.reports.count == 1, "the first height arrived exactly once: \(log.reports)")
            #expect(measured > 1000, "the harness measured the seeded post: \(measured)")
            #expect(abs((log.reports.first ?? 0) - measured) <= lineSlack,
                    "and it is the content's height: \(log.reports) vs \(measured)")
        }
    }

    /// **THE UPDATE PASS: no report inside it — and the height it reports
    /// is the one its own layout produced.** `viewUpdated` is `updateNSView`'s
    /// body. SwiftUI's order inside one pass is UPDATE, then LAYOUT (which is
    /// where a new width reaches the view), then the next turn — so the pin
    /// drives exactly that: the update, then the column narrowed and laid out
    /// (a reflow with no storage edit — nothing else will re-report it), then
    /// the turns.
    ///
    /// RED ON OLD, twice over: `updateNSView` re-measured synchronously, so
    /// the report landed INSIDE the pass (the measured warning generator, and
    /// the write SwiftUI was measured ignoring) — and it measured BEFORE the
    /// layout that pass was about to do, so it reported the WIDE height and
    /// nothing re-reported the narrow one: a stranded frame.
    @Test func anUpdatePassReportsOnTheTurnAfterItNeverInsideIt() async throws {
        try await withInlineEditor(seedBlocks: corpus) { h in
            let (window, coordinator, log) = await mounted(h)
            defer { coordinator.uninstall(); window.orderOut(nil); window.close() }
            for _ in 0..<20 where log.reports.isEmpty { await turn() }
            await converge(window)
            let wide = PaneMeasurement.height(of: h.textView)
            #expect(abs((log.reports.last ?? 0) - wide) < 0.5,
                    "steady state: reported \(log.reports), measured \(wide)")
            log.reports = []

            coordinator.viewUpdated(chrome: chrome, gutter: .contained, on: h.textView)
            #expect(log.reports.isEmpty,
                    "no height is reported inside the update pass: \(log.reports)")
            // …the same pass's layout: the new width reaches the view.
            h.textView.frame.size.width = 420
            window.layoutIfNeeded()
            window.displayIfNeeded()

            for _ in 0..<20 where log.reports.isEmpty { await turn() }
            await converge(window)
            let narrow = PaneMeasurement.height(of: h.textView)
            #expect(narrow > wide + 1000, "the narrower column is taller: \(narrow) vs \(wide)")
            #expect(log.reports.count == 1, "one report: \(log.reports)")
            // The report is the height the pass's OWN layout produced — on the
            // narrow side of the midpoint. The old road measured before that
            // layout and reported the WIDE height, which nothing re-reported.
            // (Not an equality: TextKit's first full measure after a reflow sat
            // 631 pt — 3.3% — from the layout a display pass converges to,
            // measured on both roads alike; TEXTKIT2 §2's documented class, the
            // measurement brain's and not this report's timing.)
            #expect((log.reports.first ?? 0) > (wide + narrow) / 2,
                    "carrying the reflowed height, not the stranded wide one: \(log.reports) — wide \(wide), narrow \(narrow)")
        }
    }

    /// **A BURST IN ONE TURN REPORTS ONCE** — three keystrokes through the
    /// real input path (each a storage edit, each a storage-road trigger) and
    /// two update passes, all before the run loop turns: ONE measurement,
    /// after the turn, carrying the final height.
    ///
    /// RED ON OLD: two synchronous update-pass reports plus one per
    /// keystroke's storage hop.
    @Test func aBurstOfEditsAndUpdatesInOneTurnReportsOnce() async throws {
        try await withInlineEditor(seedBlocks: corpus) { h in
            let (window, coordinator, log) = await mounted(h)
            defer { coordinator.uninstall(); window.orderOut(nil); window.close() }
            for _ in 0..<20 where log.reports.isEmpty { await turn() }
            await converge(window)
            log.reports = []

            let caret = h.model.index.range(ofEntryAt: 12).location + 3
            h.textView.setSelectedRange(NSRange(location: caret, length: 0))
            for _ in 0..<3 { h.type("q") }
            coordinator.viewUpdated(chrome: chrome, gutter: .contained, on: h.textView)
            coordinator.viewUpdated(chrome: chrome, gutter: .contained, on: h.textView)
            #expect(log.reports.isEmpty, "nothing reported inside the burst: \(log.reports)")

            for _ in 0..<20 where log.reports.isEmpty { await turn() }
            await converge(window)
            #expect(log.reports.count == 1, "the burst reported once: \(log.reports)")
            #expect(abs((log.reports.last ?? 0) - PaneMeasurement.height(of: h.textView)) <= lineSlack,
                    "with the height after the burst: \(log.reports) vs \(PaneMeasurement.height(of: h.textView))")
            await h.flush()
        }
    }

    /// **THE WHOLE ROAD: a freshly mounted long note reaches its measured
    /// height** — the real `EditorView(inline: true)` (the book Outline's and
    /// the spread's host), its own model, its own projection arriving after
    /// the mount, SwiftUI's own `@State inlineHeight`, in a window. The
    /// deferral must not strand the height at the 24-pt starting frame: the
    /// text view's SwiftUI-driven frame reaches the measured content height
    /// within a bounded number of turns.
    ///
    /// A GUARD, green on both sides by design (the old synchronous reports
    /// delivered too) — its teeth are the mutation that leaves the
    /// coalescing latch set after its first hop, recorded in the unit's
    /// record.
    @Test func aFreshlyMountedLongNoteReachesItsMeasuredHeight() async throws {
        try await withEditorWorld(posts: [corpus]) { w in
            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 760, height: 700),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(rootView: ScrollView {
                EditorView(session: w.session, postID: w.postIDs[0], inline: true)
                    .frame(width: 700)
            })
            hosting.frame = NSRect(x: 0, y: 0, width: 760, height: 700)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            defer { window.orderOut(nil); window.close() }

            @MainActor func editor() -> EditorTextView? {
                var found: EditorTextView?
                @MainActor func walk(_ v: NSView) {
                    if found == nil, let e = v as? EditorTextView { found = e }
                    v.subviews.forEach(walk)
                }
                walk(hosting)
                return found
            }
            @MainActor func settled() -> Bool {
                guard let e = editor(), e.string.count > 1000 else { return false }
                return abs(e.frame.height - PaneMeasurement.height(of: e)) < 1
            }
            for _ in 0..<120 where !settled() {
                hosting.layoutSubtreeIfNeeded()
                window.displayIfNeeded()
                spin(0.02)
                await Task.yield()
            }
            let e = try #require(editor(), "the inline editor mounted")
            let measured = PaneMeasurement.height(of: e)
            #expect(e.string.count > 1000, "its projection arrived: \(e.string.count) characters")
            #expect(measured > 1000, "a long note: \(measured)")
            #expect(abs(e.frame.height - measured) < 1,
                    "the frame reached the measured height, not the 24-pt start: \(e.frame.height) vs \(measured)")
        }
    }
}
