//
//  PaneRenderRestoreClipTests.swift
//  VariorumTests
//
//  18l-b U3 — THE TK2 §3 RIDER: the macOS-27 `layoutViewport()` clip
//  displacement, examined at the pane surface's render restore — the OTHER
//  caller of that call (TEXTKIT2_NOTES §3: "`PaneSurface`'s render restore is
//  the other `layoutViewport()` caller and was NOT examined").
//
//  The finding being examined (18k C6, `JumpViewportLayoutTests`): on macOS 27
//  `NSTextViewportLayoutController.layoutViewport()` moves the CLIP by about
//  the height change its OWN pass causes — measured on the full-document
//  editor, whose frame follows its laid-out text — while the line stays put;
//  "the displacement lives only inside TK2's viewport layout, and only when
//  that pass changes the laid-out geometry".
//
//  The restore (`scheduleRenderRestore`, A47c) rebuilds a pane's rendering
//  surfaces with that same call, on a deferred turn after a convergence
//  occasion (a click, a scroll-end, a liveness flip) or a whole-storage
//  re-font (a voice or paragraph-gap switch). A pane is never a scroll view's
//  document: it rides INSIDE SwiftUI scroll views, and a clip moved under it
//  would slide the page she is reading. The pane records the clips' origins
//  on both sides of the call (`lastRenderRestoreClipShift`); these pins read
//  it on the production roads, on the rig where A47c's strand was traced (a
//  REAL `TakesBoardView`, a long take scrolled to its tail).
//

import AppKit
import Dependencies
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// Sync pump callable from async pins (`RunLoop.run(until:)` is barred in
/// async contexts; a sync hop is the suite-wide pattern).
@MainActor
private func pumpRider(_ seconds: TimeInterval = 0.05) {
    RunLoop.main.run(until: Date().addingTimeInterval(seconds))
}

/// A private defaults domain per mount (row 36: a board pin must not write
/// the dev store's `.standard`).
@MainActor
private func riderDefaults() -> UserDefaults {
    let suite = "PaneRenderRestoreClipTests.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suite)!
    defaults.removePersistentDomain(forName: suite)
    return defaults
}

@MainActor
@Suite("The render restore never moves a pane's clip (18l-b U3 — the TK2 §3 rider, macOS 27)", .serialized)
struct PaneRenderRestoreClipTests {
    private func turns(_ n: Int) async {
        for _ in 0..<n {
            pumpRider()
            await Task.yield()
        }
    }

    private func findPane(_ view: NSView, variant: String) -> PaneTextView? {
        if let pane = view as? PaneTextView,
           pane.identifier?.rawValue.contains(variant) == true { return pane }
        for sub in view.subviews {
            if let found = findPane(sub, variant: variant) { return found }
        }
        return nil
    }

    /// The document-space top of the first layout fragment inside the
    /// viewport TextKit last laid out.
    private static func firstViewportFragmentTop(_ layoutManager: NSTextLayoutManager) -> CGFloat? {
        guard let range = layoutManager.textViewportLayoutController.viewportRange else { return nil }
        var top: CGFloat?
        layoutManager.enumerateTextLayoutFragments(from: range.location, options: []) { fragment in
            top = fragment.layoutFragmentFrame.minY
            return false
        }
        return top
    }

    private var longText: String {
        (1...28).map { i in
            "Paragraph \(i). " + Array(
                repeating: "honest prose words keep flowing along the measured line and wrap",
                count: 4
            ).joined(separator: " ") + "."
        }.joined(separator: "\n\n")
    }

    /// The A47c rig (`TakePaneMeasureTests.aStrandedRenderTierIsRebuiltByAConvergenceOccasion`):
    /// a REAL board, the long take's pane scrolled to its TAIL — the state in
    /// which a restore has the most above the viewport to disturb.
    private func onTheBoard(
        _ body: @MainActor (_ long: PaneTextView, _ window: NSWindow) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        let text = longText
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 47))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "u3 rider")
            let long = try session.operations.newBlock(in: post.id, text: text)
            _ = try session.operations.newBlock(in: post.id, text: "a short neighbor block of one line")
            let model = TakesViewModel(session: session, postID: post.id, defaults: riderDefaults())
            let observing = Task { await model.start() }
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 900, height: 760),
                styleMask: [.borderless], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                observing.cancel()
                model.teardown()
                window.orderOut(nil)
            }
            let hosting = NSHostingView(
                rootView: TakesBoardView(session: session, postID: post.id, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: 900, height: 760)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            for _ in 0..<40 where model.projection.slots.isEmpty {
                pumpRider()
                await Task.yield()
            }
            for _ in 0..<8 {
                window.layoutIfNeeded(); window.displayIfNeeded(); pumpRider(); await Task.yield()
            }
            let pane = try #require(findPane(hosting, variant: long.variant.id), "the long pane mounted")
            // Deterministic tail scroll (the A47c rig's loop).
            let paneH = pane.frame.height
            var attempts = 0
            while pane.visibleRect.minY < paneH - 800, attempts < 8 {
                attempts += 1
                _ = pane.scrollToVisible(NSRect(x: 0, y: paneH - 600, width: 10, height: 600))
                await turns(3)
                window.layoutIfNeeded(); window.displayIfNeeded()
                pumpRider()
            }
            try #require(pane.visibleRect.minY > paneH - 800,
                         "the long pane scrolled to its tail (after \(attempts) attempts)")
            #expect(!pane.enclosingClipOrigins().isEmpty, "the pane rides inside at least one clip")
            await turns(4)
            try await body(pane, window)
        }
    }

    /// **ROAD 1 — the A47c recipe: the kill, then the occasion.** A
    /// full-range attribute write (the traced production trigger — the
    /// voice ink's `textColor`) invalidates the tail-scrolled pane's layout;
    /// a convergence occasion (what a click, a scroll-end or a ring move
    /// fires) re-measures and schedules the restore; the restore's
    /// `layoutViewport()` runs. It must move no clip, and the page she was
    /// reading must be where it was.
    @Test func theOccasionsRestoreMovesNoClipOnATailScrolledPane() async throws {
        try await onTheBoard { pane, window in
            let clipsBefore = pane.enclosingClipOrigins()
            let visibleBefore = pane.visibleRect.minY
            let restoresBefore = pane.renderRestoresRun

            pane.textColor = pane.textColor ?? .labelColor  // THE KILL (A47c)
            await turns(4)
            pane.fireConvergenceOccasion()                    // THE OCCASION
            await turns(6)

            print("U3-RIDER road 1: clips \(clipsBefore) → \(pane.enclosingClipOrigins()) · visible top \(visibleBefore) → \(pane.visibleRect.minY) · frame \(pane.frame.height) · restores \(restoresBefore) → \(pane.renderRestoresRun) · last shift \(pane.lastRenderRestoreClipShift)")
            #expect(pane.renderRestoresRun > restoresBefore,
                    "non-vacuity: the render restore RAN (\(restoresBefore) → \(pane.renderRestoresRun))")
            #expect(pane.lastRenderRestoreClipShift == 0,
                    "the restore's layoutViewport() moved a clip by \(pane.lastRenderRestoreClipShift) pt")
            #expect(pane.enclosingClipOrigins() == clipsBefore,
                    "the page did not move under her (clips \(clipsBefore) → \(pane.enclosingClipOrigins()))")
            #expect(abs(pane.visibleRect.minY - visibleBefore) < 0.5,
                    "the text on screen is the text that was on screen (\(visibleBefore) → \(pane.visibleRect.minY))")
        }
    }

    /// **ROAD 2 — the whole-storage re-font with no user event** (13d batch
    /// 5, the memo's edge 3): a paragraph-gap switch re-attributes every
    /// paragraph, CHANGING the laid-out geometry, then re-measures and asks
    /// for the restore. The geometry change is real here (the pane grows), so
    /// the page may legitimately reflow — the subject is the restore's OWN
    /// call, which must move no clip.
    @Test func theReFontRestoreMovesNoClipThoughTheGeometryChanged() async throws {
        let saved = UserDefaults.standard.string(forKey: ParagraphGap.settingKey)
        defer {
            if let saved {
                UserDefaults.standard.set(saved, forKey: ParagraphGap.settingKey)
            } else {
                UserDefaults.standard.removeObject(forKey: ParagraphGap.settingKey)
            }
        }
        UserDefaults.standard.set(ParagraphGap.standard.rawValue, forKey: ParagraphGap.settingKey)
        try await onTheBoard { pane, window in
            let heightBefore = pane.frame.height
            let restoresBefore = pane.renderRestoresRun
            UserDefaults.standard.set(
                ParagraphGap.paragraphTall.rawValue, forKey: ParagraphGap.settingKey)
            await turns(8)
            window.layoutIfNeeded(); window.displayIfNeeded()
            await turns(6)
            print("U3-RIDER road 2: frame \(heightBefore) → \(pane.frame.height) · restores \(restoresBefore) → \(pane.renderRestoresRun) · largest shift \(pane.largestRenderRestoreClipShift) · clips \(pane.enclosingClipOrigins())")
            #expect(pane.frame.height > heightBefore + 20,
                    "non-vacuity: the re-font really changed the geometry (\(heightBefore) → \(pane.frame.height))")
            #expect(pane.renderRestoresRun > restoresBefore,
                    "non-vacuity: the re-font's render restore RAN (\(restoresBefore) → \(pane.renderRestoresRun))")
            #expect(pane.largestRenderRestoreClipShift == 0,
                    "no restore on this pane ever moved a clip (largest \(pane.largestRenderRestoreClipShift) pt)")
        }
    }

    /// **THE ADVERSARIAL ARM — NOT a production road; it asks TextKit
    /// itself.** Every production road into the restore re-measures the
    /// whole (pane-scale) document with `.ensuresLayout` first, so the
    /// restore's pass never meets geometry it has not already laid out. This
    /// arm removes that ordering on purpose: a font GROWTH written straight
    /// into the storage (no delegate, no remeasure — nothing lays it out),
    /// then the restore's own call, bare. Recorded either way: it says
    /// whether TK2's viewport layout can move a nested, non-resizable pane's
    /// clip at all on this OS — which decides whether the production safety
    /// rests on the ordering alone or on TextKit's own behaviour as well.
    @Test func textKitsViewportLayoutOverUnmeasuredGrowthOnANestedPane() async throws {
        try await onTheBoard { pane, window in
            let storage = try #require(pane.textStorage)
            let layoutManager = try #require(pane.textLayoutManager)
            let frameBefore = pane.frame
            let clipsBefore = pane.enclosingClipOrigins()
            // Where the viewport's first laid-out line sits in the document,
            // before — the geometry the pass is about to change.
            let viewportTopBefore = Self.firstViewportFragmentTop(layoutManager)
            storage.beginEditing()
            storage.addAttribute(
                .font, value: NSFont.systemFont(ofSize: 22),
                range: NSRange(location: 0, length: storage.length))
            storage.endEditing()
            layoutManager.textViewportLayoutController.layoutViewport()
            let viewportTopAfter = Self.firstViewportFragmentTop(layoutManager)
            let clipsAfter = pane.enclosingClipOrigins()
            // The seam's own loud-mismatch rule, mirrored (ladder round 1,
            // NIT-2): a clip-count change is a shift, never a silent 0.
            let shift = clipsBefore.count == clipsAfter.count
                ? (zip(clipsBefore, clipsAfter).map { abs($1 - $0) }.max() ?? 0)
                : CGFloat.infinity
            print("U3-RIDER adversarial: clips \(clipsBefore) → \(clipsAfter) · frame \(frameBefore.height) → \(pane.frame.height) · viewport's first fragment top \(viewportTopBefore.map { "\($0)" } ?? "nil") → \(viewportTopAfter.map { "\($0)" } ?? "nil")")
            #expect(viewportTopBefore != nil && viewportTopAfter != nil
                    && abs(viewportTopAfter! - viewportTopBefore!) > 20,
                    "non-vacuity: the pass REALLY changed the laid-out geometry around the viewport (\(String(describing: viewportTopBefore)) → \(String(describing: viewportTopAfter)))")
            #expect(pane.frame == frameBefore,
                    "a pane is not vertically resizable: the pass cannot resize it (\(frameBefore) → \(pane.frame))")
            #expect(shift == 0,
                    "TK2's viewport layout moved a nested pane's clip by \(shift) pt over unmeasured growth (clips \(clipsBefore) → \(clipsAfter))")
        }
    }
}
