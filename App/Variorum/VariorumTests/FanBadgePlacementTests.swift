//
//  FanBadgePlacementTests.swift
//  VariorumTests
//
//  VX-230 (Run VX-246, U4) — THE FAN BADGE SITS AT ITS OWN BLOCK, OR NOWHERE.
//  Her report: in Write, block 1 of a 160-block note wore a fully black disc
//  where its ⑂2 should be, every other block its own muted ⑂2; in the book's
//  Outline the same disc sat at block 1 and NO other block was badged. VX-184
//  U1's live round: a darker ⑂2 at block 1 of a 300-block note whose block 1
//  held ONE take.
//
//  The traced mechanism (the run record's U4 trace; measured on macOS 27.0):
//  a fragment TextKit 2 has not laid out reports `layoutFragmentFrame ==
//  .zero` (state `.none`) — every fragment after a WIDTH change, until the
//  next layout — and a `.zero` rect at the container origin `intersects` any
//  viewport holding that point. `EditorViewModel.refreshBadges` read the frame
//  with no state check, so every fanned block TK2 had not laid out was badged
//  AT THE CONTAINER'S ORIGIN — block 1's place — and the translucent badge
//  bezels stacked into one dark disc. On the inline (book) editor a width
//  change queues the badge hop BEFORE the whole-post remeasure, so the hop
//  read nothing laid out and nothing re-ran it.
//
//  Each pin is red on the pre-fix tree on its DESIGNED line (W1 runs them
//  against `DerivedData/vx246-u4-red`), except the TK2-facts pin, which is a
//  characterization by design (green on both trees — the mechanism's evidence
//  and a point-release tripwire, TEXTKIT2_NOTES §5).
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

/// `count` blocks of ~45 words each — each wraps to several lines in the
/// windows below, so a 600-pt viewport shows the first handful and TextKit 2
/// never lays the rest out on its own (the long-note shape of both sightings).
private func longNote(_ count: Int) -> [String] {
    (0..<count).map { p in
        (0..<45).map { "word\(($0 &+ p &* 7) % 911)" }.joined(separator: " ") + " end\(p)"
    }
}

/// One entry's FIRST fragment as the surface holds it NOW, in view
/// coordinates — read with `options: []`, so the read itself lays nothing out.
@MainActor
private func firstFragment(
    entry i: Int, model: EditorViewModel, textView: NSTextView
) -> (frame: CGRect, laidOut: Bool)? {
    guard let layoutManager = textView.textLayoutManager,
          let contentManager = layoutManager.textContentManager
    else { return nil }
    let range = model.index.range(ofEntryAt: i)
    guard let location = contentManager.location(
        contentManager.documentRange.location, offsetBy: range.location)
    else { return nil }
    let origin = textView.textContainerOrigin
    var found: (frame: CGRect, laidOut: Bool)?
    layoutManager.enumerateTextLayoutFragments(from: location, options: []) { fragment in
        found = (fragment.layoutFragmentFrame.offsetBy(dx: origin.x, dy: origin.y),
                 fragment.state == .layoutAvailable)
        return false
    }
    return found
}

/// The ⑂ buttons the surface draws — her FACE, not the model's list.
@MainActor
private func badgeButtons(in textView: NSTextView) -> [NSButton] {
    textView.subviews.compactMap { $0 as? NSButton }.filter { $0.title.hasPrefix("⑂") }
}

@MainActor
@Suite("Fan badge placement (VX-230)", .serialized)
struct FanBadgePlacementTests {
    /// The proven N14-pin wait: async polling drains the settle hops'
    /// main-queue turns; the display call gives each pass its chance.
    private func pumpUntil(_ window: NSWindow, _ condition: @MainActor () -> Bool) async {
        for _ in 0..<400 {
            if condition() { return }
            window.displayIfNeeded()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(5))
        }
    }

    /// A fixed number of turns — every hop queued so far has landed.
    private func pump(_ window: NSWindow, turns: Int = 24) async {
        for _ in 0..<turns {
            window.displayIfNeeded()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(5))
        }
    }

    /// The fanned entries' indexes in the store's order (= the tiling's).
    private func fan(_ h: EditorHarness, entries: [Int]) throws {
        let slots = try h.storeSlots()
        for i in entries {
            _ = try h.session.operations.branchVariant(
                slots[i].blockID, from: #require(slots[i].variantID))
        }
        try h.reload()
    }

    /// Write's surface in a real window with the APP's coordinator installed
    /// (the badge overlay, the decor overlay and the scroll-anchor controller
    /// `EditorSurface.makeNSView` installs), ordered in without becoming key.
    private func mountWrite(
        _ h: EditorHarness, width: CGFloat = 700, height: CGFloat = 600
    ) throws -> (window: NSWindow, coordinator: EditorSurface.Coordinator) {
        let scrollView = try #require(h.textView.enclosingScrollView)
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: width, height: height),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = scrollView
        let coordinator = EditorSurface.Coordinator(model: h.model)
        coordinator.install(scrollView: scrollView, textView: h.textView)
        window.orderFrontRegardless()
        window.layoutIfNeeded()
        window.display()
        return (window, coordinator)
    }

    /// The invariants every pin below reads off the FACE and the model:
    /// every badge belongs to a block TK2 has laid out and sits at that
    /// block's own first line; no two ⑂ buttons share a place (the stack —
    /// her black disc); and no ⑂ button sits at an UNFANNED block's place
    /// (U1's phantom ⑂2 on a one-take block 1).
    private func expectEveryBadgeHome(
        _ h: EditorHarness, fanned: Set<Int>, _ where_: String
    ) throws {
        let slots = try h.storeSlots()
        let entryOf = Dictionary(uniqueKeysWithValues: slots.enumerated().map { ($1.blockID, $0) })
        for badge in h.model.badges {
            let i = try #require(entryOf[badge.blockID])
            let truth = try #require(firstFragment(entry: i, model: h.model, textView: h.textView))
            #expect(truth.laidOut,
                    "\(where_): entry \(i)'s badge stands on a fragment TextKit 2 has NOT laid out — its frame is no position")
            #expect(abs(badge.frame.minY - truth.frame.minY) < 1,
                    "\(where_): entry \(i)'s badge at y=\(badge.frame.minY), its block's first line at y=\(truth.frame.minY)")
        }
        let ys = badgeButtons(in: h.textView).map { ($0.frame.minY * 2).rounded() / 2 }
        #expect(Set(ys).count == ys.count,
                "\(where_): \(ys.count - Set(ys).count) ⑂ buttons stacked on another's place (the dark disc) — ys \(ys.sorted())")
        if !fanned.contains(0), let first = firstFragment(entry: 0, model: h.model, textView: h.textView) {
            let atBlockOne = badgeButtons(in: h.textView).filter { abs($0.frame.minY - first.frame.minY) < 1 }
            #expect(atBlockOne.isEmpty,
                    "\(where_): \(atBlockOne.count) ⑂ button(s) at block 1's place, and block 1 has ONE take (U1's phantom)")
        }
    }

    /// **U1's sighting (VX-184 leg (d)) — the phantom on a ONE-take block 1.**
    /// A long note, block 1 unfanned, one fanned block on screen and four far
    /// below the fold. Opened in Write at its top: the on-screen fan wears its
    /// badge at its own line; the four TK2 has not laid out wear NONE (the
    /// function's own contract — "until scrolled to") — never four badges at
    /// block 1's place. RED on the pre-fix tree: the four sit at the container
    /// origin, so they stack (duplicates) and sit on block 1 (the phantom).
    @Test func aBadgeNeverSitsAtAnotherBlocksPlace() async throws {
        try await withEditor(seedBlocks: longNote(120)) { h in
            let onScreen = 2
            let deep = [40, 70, 100, 119]
            try fan(h, entries: [onScreen] + deep)
            let (window, coordinator) = try mountWrite(h)
            defer {
                coordinator.uninstall()
                window.orderOut(nil)
                window.close()
            }
            let onScreenID = try h.storeSlots()[onScreen].blockID
            await pumpUntil(window) {
                guard let badge = h.model.badges.first(where: { $0.blockID == onScreenID }),
                      let truth = firstFragment(entry: onScreen, model: h.model, textView: h.textView)
                else { return false }
                return truth.laidOut && abs(badge.frame.minY - truth.frame.minY) < 1
            }
            await pump(window)

            // Non-vacuity: the on-screen fan is badged at home, and at least
            // one deep fan is genuinely NOT laid out (the sightings' state).
            let truth = try #require(firstFragment(entry: onScreen, model: h.model, textView: h.textView))
            #expect(h.model.badges.contains { $0.blockID == onScreenID && abs($0.frame.minY - truth.frame.minY) < 1 },
                    "premise: the on-screen fanned block wears its badge at its own line")
            let unlaid = deep.filter { firstFragment(entry: $0, model: h.model, textView: h.textView)?.laidOut == false }
            #expect(!unlaid.isEmpty, "premise: fanned blocks below the fold that TK2 has not laid out exist")

            try expectEveryBadgeHome(h, fanned: Set([onScreen] + deep), "Write, the note's top")
        }
    }

    /// **Her shot (`shot-20261013-022301.png`) — block 1 FANNED, most of the
    /// note fanned.** Write at the top: block 1 wears exactly ONE badge (hers),
    /// at its own line, never the whole below-the-fold fan stacked on it. RED
    /// on the pre-fix tree: every unlaid fan's badge joins block 1's.
    @Test func blockOnesBadgeIsItsOwnAlone() async throws {
        try await withEditor(seedBlocks: longNote(120)) { h in
            let fanned = (0..<120).filter { $0 % 5 != 4 }  // 96 of 120 — "two takes on most blocks"
            try fan(h, entries: fanned)
            let (window, coordinator) = try mountWrite(h)
            defer {
                coordinator.uninstall()
                window.orderOut(nil)
                window.close()
            }
            let firstID = try h.storeSlots()[0].blockID
            await pumpUntil(window) {
                guard let badge = h.model.badges.first(where: { $0.blockID == firstID }),
                      let truth = firstFragment(entry: 0, model: h.model, textView: h.textView)
                else { return false }
                return truth.laidOut && abs(badge.frame.minY - truth.frame.minY) < 1
            }
            await pump(window)

            let first = try #require(firstFragment(entry: 0, model: h.model, textView: h.textView))
            let atBlockOne = badgeButtons(in: h.textView).filter { abs($0.frame.minY - first.frame.minY) < 1 }
            #expect(atBlockOne.count == 1,
                    "block 1 wears ONE ⑂ badge — its own — not \(atBlockOne.count) stacked into a disc")
            try expectEveryBadgeHome(h, fanned: Set(fanned), "Write, most blocks fanned")
        }
    }

    /// **The book's Outline (her `shot-20261013-174949.png`) — the INLINE
    /// editor after a WIDTH change.** The inline surface badges the whole
    /// post by design. A width change returns every fragment to "not laid
    /// out"; the app's own order then runs the badge hop BEFORE the
    /// whole-post remeasure (the coordinator's composed width door: the
    /// model's handler first, then `scheduleRemeasure`, and SwiftUI's update
    /// pass schedules another). After the hops: every fanned block wears its
    /// badge at its own line. RED on the pre-fix tree: the hop read every
    /// fragment at `.zero`, so every badge sat at the origin, and nothing
    /// re-ran it after the remeasure laid the post out — one disc, no block
    /// badged (her shot).
    @Test func theBookEditorPutsEveryBadgeHomeAfterAWidthChange() async throws {
        try await withInlineEditor(seedBlocks: longNote(120)) { h in
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 700, height: 300),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let container = NSView(frame: NSRect(x: 0, y: 0, width: 700, height: 300))
            window.contentView = container
            let textView = h.textView
            var wrapperWidth: CGFloat = 700
            // SwiftUI sets the wrapper's width before any height report (18k C2).
            textView.frame.size.width = wrapperWidth
            container.addSubview(textView)
            let coordinator = InlineEditorSurface.Coordinator(model: h.model)
            coordinator.install(textView: textView) { height in
                textView.frame = NSRect(x: 0, y: 0, width: wrapperWidth, height: height)
            }
            window.orderFrontRegardless()
            defer {
                coordinator.uninstall()
                window.orderOut(nil)
                window.close()
            }
            let fanned = (0..<120).filter { $0 % 3 != 2 }  // 80 of 120
            try fan(h, entries: fanned)
            let slots = try h.storeSlots()

            // THE STEADY STATE — established explicitly (the premise is not
            // the defect): the whole post laid out, the badges delivered.
            coordinator.remeasure()
            h.model.refreshBadges()
            window.layoutIfNeeded()
            window.display()
            await pump(window)
            #expect(h.model.badges.count == fanned.count,
                    "premise: the inline surface badges every fanned block (its whole-post region)")
            let lastFan = try #require(fanned.last)
            let before = try #require(firstFragment(entry: lastFan, model: h.model, textView: textView))

            // THE WIDTH CHANGE — the app's road: the frame narrows (the text
            // view's own width door fires: the model's overlay handler, then
            // the coordinator's remeasure hop), and SwiftUI's update pass
            // schedules the report again (`viewUpdated`'s scheduleRemeasure).
            // NO synchronous remeasure and NO explicit badge refresh.
            wrapperWidth = 420
            textView.setFrameSize(NSSize(width: 420, height: textView.frame.height))
            coordinator.scheduleRemeasure()
            await pumpUntil(window) {
                h.model.badges.count == fanned.count && fanned.allSatisfy { i in
                    guard let badge = h.model.badges.first(where: { $0.blockID == slots[i].blockID }),
                          let truth = firstFragment(entry: i, model: h.model, textView: textView)
                    else { return false }
                    return truth.laidOut && abs(badge.frame.minY - truth.frame.minY) < 1
                }
            }
            await pump(window)

            let after = try #require(firstFragment(entry: lastFan, model: h.model, textView: textView))
            #expect(after.frame.minY - before.frame.minY > 100,
                    "non-vacuity: the narrowing genuinely moved the last fan's block down")
            #expect(h.model.badges.count == fanned.count,
                    "every fanned block keeps a badge after the width change (the inline region is the whole post)")
            try expectEveryBadgeHome(h, fanned: Set(fanned), "the book editor, after a width change")
        }
    }

    /// **Write after a WIDTH change** (a window resize, the sidebar opening).
    /// The width change returns every fragment to "not laid out"; the badge
    /// hop it queues may run before the next layout. After the app's own
    /// roads (the hop, the scroll-anchor controller's width road, the display
    /// passes): the on-screen fan wears its badge at its NEW line, and no
    /// unlaid fan stands anywhere. RED on the pre-fix tree on the stack /
    /// phantom lines (the deep fans at the origin); on the fixed tree it is
    /// also the evidence that Write's width road ends with the on-screen
    /// badge home (the record's "not built, argued" item 3).
    @Test func aWidthChangeInWriteKeepsEachBadgeHome() async throws {
        try await withEditor(seedBlocks: longNote(120)) { h in
            let onScreen = 3
            let deep = [40, 70, 100, 119]
            try fan(h, entries: [onScreen] + deep)
            let (window, coordinator) = try mountWrite(h)
            defer {
                coordinator.uninstall()
                window.orderOut(nil)
                window.close()
            }
            let onScreenID = try h.storeSlots()[onScreen].blockID
            @MainActor func homeNow() -> Bool {
                guard let badge = h.model.badges.first(where: { $0.blockID == onScreenID }),
                      let truth = firstFragment(entry: onScreen, model: h.model, textView: h.textView)
                else { return false }
                return truth.laidOut && abs(badge.frame.minY - truth.frame.minY) < 1
            }
            await pumpUntil(window) { homeNow() }
            await pump(window)
            let before = try #require(firstFragment(entry: onScreen, model: h.model, textView: h.textView))

            window.setContentSize(NSSize(width: 480, height: 600))
            await pumpUntil(window) {
                guard let truth = firstFragment(entry: onScreen, model: h.model, textView: h.textView)
                else { return false }
                return abs(truth.frame.minY - before.frame.minY) > 1 && homeNow()
            }
            await pump(window)

            let after = try #require(firstFragment(entry: onScreen, model: h.model, textView: h.textView))
            #expect(abs(after.frame.minY - before.frame.minY) > 1,
                    "non-vacuity: the narrowing moved the on-screen fan's block")
            #expect(homeNow(), "the on-screen fan wears its badge at its NEW line after the width change")
            try expectEveryBadgeHome(h, fanned: Set([onScreen] + deep), "Write, after a width change")
        }
    }

    /// **The mechanism's TextKit 2 facts — a CHARACTERIZATION, green on both
    /// trees by design** (the U4 trace's two measured facts, and a
    /// point-release tripwire per TEXTKIT2_NOTES §5): (1) a fragment TK2 has
    /// not laid out reports a `.zero` frame and the `.none` state, and a width
    /// change returns a laid-out fragment to exactly that; (2) a `.zero` rect
    /// at the container origin `intersects` a viewport holding that point —
    /// so a geometry read that skips the state check places it there.
    @Test func textKitReportsAnUnlaidFragmentAsZeroAndAZeroRectIntersects() throws {
        let scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: 700, height: 500))
        let textView = NSTextView(usingTextLayoutManager: true)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.minSize = .zero
        textView.maxSize = NSSize(width: 1e7, height: 1e7)
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.size = NSSize(width: 0, height: 1e7)
        textView.frame = NSRect(x: 0, y: 0, width: 700, height: 500)
        scrollView.documentView = textView
        // An un-ordered window: viewport layout needs one, the screen does not.
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 700, height: 500),
            styleMask: [.borderless], backing: .buffered, defer: true)
        window.isReleasedWhenClosed = false
        window.contentView = scrollView
        defer { window.close() }
        textView.string = longNote(160).joined(separator: "\n")
        let layoutManager = try #require(textView.textLayoutManager)
        let contentManager = try #require(layoutManager.textContentManager)
        func fragment(atOffset offset: Int) -> NSTextLayoutFragment? {
            guard let location = contentManager.location(
                contentManager.documentRange.location, offsetBy: offset) else { return nil }
            var found: NSTextLayoutFragment?
            layoutManager.enumerateTextLayoutFragments(from: location, options: []) {
                found = $0
                return false
            }
            return found
        }
        let deepOffset = (textView.string as NSString).length - 40

        let coldFirst = try #require(fragment(atOffset: 0))
        #expect(coldFirst.state == NSTextLayoutFragment.State.none && coldFirst.layoutFragmentFrame == .zero,
                "cold: an unlaid fragment reads .zero / .none")

        layoutManager.textViewportLayoutController.layoutViewport()
        let laidFirst = try #require(fragment(atOffset: 0))
        #expect(laidFirst.state == .layoutAvailable, "the viewport's first fragment is laid out")
        let deep = try #require(fragment(atOffset: deepOffset))
        #expect(deep.state != .layoutAvailable, "a fragment far below the viewport is not laid out")

        textView.setFrameSize(NSSize(width: 360, height: textView.frame.height))
        let afterWidth = try #require(fragment(atOffset: 0))
        #expect(afterWidth.state == NSTextLayoutFragment.State.none && afterWidth.layoutFragmentFrame == .zero,
                "a width change returns even the laid-out first fragment to .zero / .none")

        let origin = textView.textContainerOrigin
        #expect(CGRect.zero.offsetBy(dx: origin.x, dy: origin.y)
                    .intersects(scrollView.contentView.bounds),
                "a .zero rect at the container origin 'intersects' the viewport (CGRect's degenerate-rect rule)")
    }
}
