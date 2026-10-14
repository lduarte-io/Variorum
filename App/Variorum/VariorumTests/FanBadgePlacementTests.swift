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
//  **U4b (the inline editor's remainder) — the trace re-run by measurement**
//  (the run record's U4b UNIT RECORD; bare-rig probes 5–9, macOS 27.0). Two
//  facts the U4 fix did not know:
//  - **A layout that runs AHEAD of unlaid predecessors poisons the next whole
//    walk.** U4's own sparse mid-document `.ensuresLayout` badge read, or a
//    viewport pass over a mid-document window, places those fragments at
//    estimated offsets. The whole `.ensuresLayout` walk after it does not move
//    them: 996 pt off cold, 1,662 pt after 700 → 420. The next viewport pass
//    re-positions every fragment to the settled layout. (The poison
//    characterization below.)
//  - **The inline region is the frame SwiftUI last applied.** It starts at 24 pt
//    at mount, and the remeasure's report lands on SwiftUI's next pass, never
//    synchronously.
//  So the badges were read off a poisoned layout or clipped to a stale frame,
//  and nothing re-ran them after the settle net's heal. The mount pin and the
//  kept width pin are red on U4's tree (`DerivedData/vx246-u4b-red`). The
//  re-designed phantom pin is red on the tree before U4
//  (`DerivedData/vx246-u4b-red-pre-u4`).
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
    /// A long note, block 1 unfanned, one fanned block on screen and a BAND of
    /// fanned blocks just past the viewport. Opened in Write at its top: the
    /// on-screen fan wears its badge at its own line; a fan TK2 has not laid
    /// out wears NONE (the function's own contract — "until scrolled to") —
    /// never a badge at block 1's place. RED on the tree before U4's fix: every
    /// `.none` fan's `.zero` frame sits at the container origin, so they stack
    /// (duplicates) on block 1 (the phantom).
    ///
    /// **U4b's re-design (the pin was HOLLOW as first written).** Its fans were
    /// far below the fold (40/70/100/119). TK2 ESTIMATES fragments that far
    /// down, and an estimated fragment's guessed frame lies below the viewport,
    /// so it never intersected and the old tree was green too (U4's W1). The
    /// band (entries 5–30) is where TK2 leaves fragments in `.none` with a
    /// `.zero` frame, like `blockOnesBadgeIsItsOwnAlone`'s red entries 8–18 at
    /// W1. The premise names that trigger state, so if TK2 ever estimates the
    /// whole band, the premise goes RED loudly instead of the pin going hollow
    /// again.
    @Test func aBadgeNeverSitsAtAnotherBlocksPlace() async throws {
        try await withEditor(seedBlocks: longNote(120)) { h in
            let onScreen = 2
            let band = Array(5...30)
            try fan(h, entries: [onScreen] + band)
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
            // one fan of the band is in the defect's TRIGGER state — not laid
            // out, its frame `.zero` (an estimate would be hollow, see above).
            let truth = try #require(firstFragment(entry: onScreen, model: h.model, textView: h.textView))
            #expect(h.model.badges.contains { $0.blockID == onScreenID && abs($0.frame.minY - truth.frame.minY) < 1 },
                    "premise: the on-screen fanned block wears its badge at its own line")
            let zeroed = band.filter { i in
                guard let read = firstFragment(entry: i, model: h.model, textView: h.textView) else { return false }
                return !read.laidOut && read.frame.size == .zero
            }
            #expect(!zeroed.isEmpty,
                    "premise: a fanned block past the viewport reads TK2's unlaid `.zero` frame (the trigger state)")

            try expectEveryBadgeHome(h, fanned: Set([onScreen] + band), "Write, the note's top")
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

    // (U4b: `aWidthChangeInWriteKeepsEachBadgeHome` is RECORDED HOLLOW AND
    //  REMOVED. It pinned Write's width road, and that road has no old-tree
    //  defect to be red against: green on the tree before U4 at W1, its deep
    //  fans estimated and its end state clean. Re-designing it red would only
    //  borrow `aBadgeNeverSitsAtAnotherBlocksPlace`'s band mechanism, one red
    //  pinned twice. Write's width road is carried by the U4b window's walk
    //  row instead. The run record's U4b UNIT RECORD has the disposition.)

    /// **The book's live editor right after it MOUNTS** (her Terminal `d3`:
    /// only block 1 wore a ⑂ on the Outline's live editor; the spread's live
    /// page in both voices, `e2`). The inline editor mounts at the app's
    /// shape:
    /// - SwiftUI hands the wrapper its width (a width change, 600 → 700 here)
    ///   and the height `EditorView.inlineHeight` starts at, 24 pt.
    /// - The coordinator's height report writes SwiftUI's `@Binding`, and the
    ///   frame lands on the NEXT main-queue turn, never inside the report.
    /// After the hops, every fanned block wears its badge at its own line.
    ///
    /// **RED on U4's tree** (`vx246-u4b-red`): every badge pass ran while the
    /// frame was still 24 pt tall and clipped to it, so block 1 alone was
    /// badged. The frame then grew with no width change and no storage edit,
    /// so nothing re-ran the pass.
    ///
    /// The ASYNC report is load-bearing: a fix that re-ran the pass inside the
    /// remeasure but kept the frame's clip would still read the 24-pt frame
    /// here, as it would in the app.
    @Test func theBookEditorBadgesEveryFanRightAfterItMounts() async throws {
        try await withInlineEditor(seedBlocks: longNote(120)) { h in
            let fanned = (0..<120).filter { $0 % 3 != 2 }  // 80 of 120
            try fan(h, entries: fanned)
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 700, height: 300),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let container = NSView(frame: NSRect(x: 0, y: 0, width: 700, height: 300))
            window.contentView = container
            let textView = h.textView
            // THE MOUNT: SwiftUI's width, and the `@State` height it starts at.
            textView.frame = NSRect(x: 0, y: 0, width: 700, height: 24)
            container.addSubview(textView)
            let coordinator = InlineEditorSurface.Coordinator(model: h.model)
            coordinator.install(textView: textView) { [weak textView] height in
                // The binding's write; SwiftUI applies the frame on its next
                // pass, after the report has returned.
                DispatchQueue.main.async {
                    textView?.frame = NSRect(x: 0, y: 0, width: 700, height: height)
                }
            }
            window.orderFrontRegardless()
            defer {
                coordinator.uninstall()
                window.orderOut(nil)
                window.close()
            }
            let slots = try h.storeSlots()
            @MainActor func everyFanHome() -> Bool {
                h.model.badges.count == fanned.count && fanned.allSatisfy { i in
                    guard let badge = h.model.badges.first(where: { $0.blockID == slots[i].blockID }),
                          let truth = firstFragment(entry: i, model: h.model, textView: textView)
                    else { return false }
                    return truth.laidOut && abs(badge.frame.minY - truth.frame.minY) < 1
                }
            }
            await pumpUntil(window) { textView.frame.height > 24 && everyFanHome() }
            await pump(window)

            #expect(textView.frame.height > 300,
                    "premise: the frame took the reported height (the post stands far taller than the 24-pt mount frame)")
            #expect(h.model.badges.count == fanned.count,
                    "every fanned block wears its badge right after the mount — \(h.model.badges.count) of \(fanned.count), not block 1 alone")
            try expectEveryBadgeHome(h, fanned: Set(fanned), "the book editor, right after it mounts")
        }
    }

    /// **U4c — a fan adopted with NO text change, far off-screen, INSIDE the
    /// width transient** (the run record's U4c trace, item 4). A client's
    /// `add_take` (the MCP door's op) lands on a block far outside the clip
    /// (the container shows the frame's END) in the same turn as a width change: every fragment is unlaid, and the
    /// width door's remeasure is queued but has not run. The observation's
    /// delivery is adopted with no storage edit (`.adoptEcho`).
    /// - At the adoption the far fan has NO badge: its fragment is unlaid, so
    ///   it has no position. Not a badge at block 1's place (the tree before
    ///   U4), and not one laid out ahead of its predecessors (U4's forced read).
    /// - The remeasure ALREADY queued lays the post out, and U4b's call re-runs
    ///   the pass after it (and after the settle net's heal). So the badge
    ///   lands at its own line with nothing more from her: no keystroke, no
    ///   second width change.
    /// Green on U4b's tree by the trace. The tree before U4 and U4's are red
    /// here by the same trace (the origin badge; a poisoned place never
    /// re-read after the heal), NOT run: no product carries this pin with
    /// their code. In the STEADY state the inline post is laid out and a fan
    /// adopted with no text change badges at once
    /// (`InlineEditorWindowTests.inlineBadgesCoverTheWholePostNotJustTheClippedViewport`).
    @Test func aFanAddedFarOffScreenMidReflowIsBadgedByTheQueuedRemeasure() async throws {
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
            let top = 3
            let far = 100
            try fan(h, entries: [top])
            let slots = try h.storeSlots()

            // THE STEADY STATE (the premise, not the defect): the whole post
            // laid out, the top fan's badge delivered (the region is the whole post).
            coordinator.remeasure()
            window.layoutIfNeeded()
            window.display()
            await pump(window)
            #expect(h.model.badges.map(\.blockID) == [slots[top].blockID],
                    "premise: the steady state badges the fan near the top")

            // THE TRANSIENT: the width door fires (every fragment unlaid, the
            // remeasure hop queued) and, in the same turn, a client's take
            // lands on a block far outside the clip — adopted with no storage edit.
            wrapperWidth = 420
            textView.setFrameSize(NSSize(width: 420, height: textView.frame.height))
            #expect(firstFragment(entry: far, model: h.model, textView: textView)?.laidOut == false,
                    "premise: the width change left the far block's fragment unlaid (the transient)")
            _ = try h.session.operations.addTake(
                toBlock: slots[far].blockID, text: "A client's take.", label: nil, undoLabel: "Add Take")
            h.model.applyProjection(try h.storeSlots(), fromDelivery: true)
            #expect(!h.model.badges.contains { $0.blockID == slots[far].blockID },
                    "inside the transient the far fan has no badge — an unlaid fragment is no position")

            // The remeasure already queued lands, with nothing more from her.
            let fanned = [top, far]
            await pumpUntil(window) {
                h.model.badges.count == fanned.count && fanned.allSatisfy { i in
                    guard let badge = h.model.badges.first(where: { $0.blockID == slots[i].blockID }),
                          let truth = firstFragment(entry: i, model: h.model, textView: textView)
                    else { return false }
                    return truth.laidOut && abs(badge.frame.minY - truth.frame.minY) < 1
                }
            }
            await pump(window)

            #expect(h.model.badges.map(\.blockID) == fanned.map { slots[$0].blockID },
                    "the far fan wears its badge once the queued remeasure has laid the post out")
            let farBadge = try #require(h.model.badges.first { $0.blockID == slots[far].blockID })
            #expect(!textView.visibleRect.intersects(farBadge.frame),
                    "non-vacuity: the far fan really is outside the clipped viewport")
            try expectEveryBadgeHome(h, fanned: Set(fanned), "the book editor, a fan adopted mid-reflow")
        }
    }

    /// **The mechanism's TextKit 2 facts — a CHARACTERIZATION, green on both
    /// trees by design** (the U4 trace's two measured facts, and a
    /// point-release tripwire per TEXTKIT2_NOTES §5): (1) a fragment TK2 has
    /// not laid out reports a `.zero` frame and the `.none` state, and a width
    /// change returns a laid-out fragment to exactly that; (2) a `.zero` rect
    /// at the container origin `intersects` a viewport holding that point —
    /// so a geometry read that skips the state check places it there.
    ///
    /// **U4b's correction:** this pin also claimed that "a fragment far below
    /// the viewport is not laid out", read at the document's LAST fragment.
    /// That line failed on both trees at U4's window (its `:397`). The test
    /// host lays out the document's last fragment in the viewport pass, as U4's
    /// own probe output showed (`p159 state=3`). The line is removed, not
    /// re-aimed: the badge road depends on no fact about which fragments the
    /// viewport pass happens to lay out, and a fragment picked to sit just
    /// past the viewport would pin TextKit's overdraw guess, not a contract.
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
        let coldFirst = try #require(fragment(atOffset: 0))
        #expect(coldFirst.state == NSTextLayoutFragment.State.none && coldFirst.layoutFragmentFrame == .zero,
                "cold: an unlaid fragment reads .zero / .none")

        layoutManager.textViewportLayoutController.layoutViewport()
        let laidFirst = try #require(fragment(atOffset: 0))
        #expect(laidFirst.state == .layoutAvailable, "the viewport's first fragment is laid out")

        textView.setFrameSize(NSSize(width: 360, height: textView.frame.height))
        let afterWidth = try #require(fragment(atOffset: 0))
        #expect(afterWidth.state == NSTextLayoutFragment.State.none && afterWidth.layoutFragmentFrame == .zero,
                "a width change returns even the laid-out first fragment to .zero / .none")

        let origin = textView.textContainerOrigin
        #expect(CGRect.zero.offsetBy(dx: origin.x, dy: origin.y)
                    .intersects(scrollView.contentView.bounds),
                "a .zero rect at the container origin 'intersects' the viewport (CGRect's degenerate-rect rule)")
    }

    /// **U4b's mechanism — a CHARACTERIZATION, green on both trees by design**
    /// (no product code; the evidence behind removing U4's forcing read, and a
    /// point-release tripwire, TEXTKIT2_NOTES §5). The rig is probe 7/9's
    /// exactly (`notes/plans/vx246-screens/u4b/probes/`): an inline-shaped bare
    /// TK2 view with a 24-pt frame in an un-ordered window, the pins' own text.
    ///
    /// The facts:
    /// 1. A whole `.ensuresLayout` walk with nothing laid out ahead of it is
    ///    exact (cold: 11,570 pt measured).
    /// 2. A sparse mid-document `.ensuresLayout` read first lays those
    ///    fragments out ahead of their predecessors, at estimated offsets. This
    ///    is what U4's badge read did on the inline surface. The whole walk
    ///    after it does NOT re-position them: 10,574 pt, a deep fragment 996 pt
    ///    off.
    /// 3. ONE viewport pass re-positions every fragment to the clean walk's
    ///    place.
    ///
    /// This is TEXTKIT2_NOTES §3's 18l finding ("the first full measure after a
    /// reflow can be 1–5 % off the layout the next display pass settles to")
    /// with its mechanism identified, and it is why the inline badge pass must
    /// run AFTER the settle net's heal, never ahead of the whole walk.
    @Test func textKitPlacesAFragmentLaidOutAheadOfItsPredecessorsOffItsSettledPlace() throws {
        let blocks = longNote(120)
        let text = blocks.joined(separator: "\n")
        let style = NSMutableParagraphStyle()
        style.paragraphSpacing = 8
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 15), .paragraphStyle: style,
        ]
        var starts = [0]
        for block in blocks.dropLast() { starts.append(starts.last! + (block as NSString).length + 1) }
        let fans = (0..<120).filter { $0 % 3 != 2 }
        let deep = 118

        func rig() -> (NSWindow, NSTextView) {
            let textView = NSTextView(usingTextLayoutManager: true)
            textView.textContainerInset = NSSize(width: 8, height: 8)
            textView.isVerticallyResizable = false
            textView.isHorizontallyResizable = false
            textView.textContainer?.widthTracksTextView = true
            textView.textContainer?.size = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
            let container = NSView(frame: NSRect(x: 0, y: 0, width: 700, height: 300))
            let window = NSWindow(
                contentRect: NSRect(x: -5000, y: -5000, width: 700, height: 300),
                styleMask: [.borderless], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            window.contentView = container
            textView.frame = NSRect(x: 0, y: 0, width: 700, height: 24)
            container.addSubview(textView)
            textView.textStorage?.setAttributedString(NSAttributedString(string: text, attributes: attributes))
            return (window, textView)
        }
        func fragmentY(_ textView: NSTextView, paragraph p: Int, ensuring: Bool) -> CGFloat? {
            guard let layoutManager = textView.textLayoutManager,
                  let contentManager = layoutManager.textContentManager,
                  let location = contentManager.location(
                    contentManager.documentRange.location, offsetBy: starts[p])
            else { return nil }
            var y: CGFloat?
            layoutManager.enumerateTextLayoutFragments(
                from: location, options: ensuring ? [.ensuresLayout] : []
            ) {
                y = $0.layoutFragmentFrame.minY
                return false
            }
            return y
        }
        func wholeWalk(_ textView: NSTextView) -> CGFloat {
            var bottom: CGFloat = 0
            textView.textLayoutManager?.enumerateTextLayoutFragments(from: nil, options: [.ensuresLayout]) {
                bottom = max(bottom, $0.layoutFragmentFrame.maxY)
                return true
            }
            return bottom
        }

        let (cleanWindow, clean) = rig()
        let (poisonedWindow, poisoned) = rig()
        defer {
            cleanWindow.close()
            poisonedWindow.close()
        }
        let cleanBottom = wholeWalk(clean)
        let cleanDeep = try #require(fragmentY(clean, paragraph: deep, ensuring: false))

        for p in fans { _ = fragmentY(poisoned, paragraph: p, ensuring: true) }  // U4's read, ahead of the walk
        let poisonedBottom = wholeWalk(poisoned)
        let poisonedDeep = try #require(fragmentY(poisoned, paragraph: deep, ensuring: false))
        #expect(abs(poisonedBottom - cleanBottom) > 100,
                "a whole walk after a read ahead of unlaid predecessors stands off the clean walk (\(poisonedBottom) vs \(cleanBottom))")
        #expect(abs(poisonedDeep - cleanDeep) > 100,
                "and a deep fragment's place with it (\(poisonedDeep) vs \(cleanDeep))")

        poisoned.textLayoutManager?.textViewportLayoutController.layoutViewport()
        let settledDeep = try #require(fragmentY(poisoned, paragraph: deep, ensuring: false))
        #expect(abs(settledDeep - cleanDeep) < 1,
                "one viewport pass re-positions it to the clean walk's place (\(settledDeep) vs \(cleanDeep))")
        let worst = fans.map { p in
            abs((fragmentY(poisoned, paragraph: p, ensuring: false) ?? -1)
                - (fragmentY(clean, paragraph: p, ensuring: false) ?? -2))
        }.max() ?? 0
        #expect(worst < 1, "every fan's place, not only the deep one (worst \(worst) pt)")
    }
}
