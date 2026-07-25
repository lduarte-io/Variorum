//
//  LongBlockLayoutTests.swift
//  VariorumTests
//
//  Phase 13c, Batch 1E — the PHANTOM FIX (memo option E, PROVISIONAL,
//  QUESTIONS #39). See `LongBlockLayout.swift`'s header for the mechanism
//  and `notes/plans/phase-13c-memo-block-extent.md` Part 2 for the
//  measurements this is built against.
//
//  ── What kind of pins these are, stated plainly (the hallucination
//  guard's honesty requirement) ────────────────────────────────────────
//  This batch ships a NEW CAPABILITY, not a bug fix, so most of what
//  follows is CHARACTERIZATION: `aPassCollapsesThePhantomOfALongBlock`
//  and its siblings assert behaviour that could not exist on the pre-batch
//  tree at all (the type does not compile there), which is a structural
//  red, not a behavioural one.
//
//  The pins that ARE red-on-old in the real sense are the GUARD pins —
//  every one of them fails on this tree with its own guard reverted, and
//  each revert was executed and observed (the batch record carries the
//  table). They are the ones that matter, because the brief's whole point
//  is that the cost is not the danger and the TRIGGER is:
//
//    · `theSameBlockIsNeverLaidOutTwice`     ← the `handled` insert
//    · `aBlockOverTheCapIsSkippedAndRecorded` ← the cap
//    · `anOrdinaryPostNeverLaysOutAnything`   ← the floor
//    · `theKillSwitchStopsItCompletely`       ← the setting guard
//    · `thePassAsksForTheRefreshItNeeds`      ← the nudge
//    · `theInlineEditorIsOutOfScope`          ← the scroll-view guard
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The pure planner (no window, no TK2)

@Suite("LongBlockLayout — the pure planner (13c 1E)")
struct LongBlockLayoutPlannerTests {
    private func candidate(
        _ index: Int, length: Int, laidOut: Bool = false
    ) -> LongBlockLayout.Candidate {
        LongBlockLayout.Candidate(
            entryIndex: index, blockID: "b\(index)",
            range: NSRange(location: index * 1000, length: length),
            laidOut: laidOut)
    }

    @Test func theNearestEligibleEstimatedBlockIsChosen() {
        let plan = LongBlockLayout.decide(
            candidates: [
                candidate(0, length: 40_000, laidOut: true),   // already laid out
                candidate(1, length: 10),                      // under the floor
                candidate(2, length: 20_000),                  // ← this one
                candidate(3, length: 30_000),
            ],
            handled: [])
        #expect(plan.layOut?.blockID == "b2")
        #expect(plan.skippedOverCap.isEmpty)
    }

    /// ONE per pass — the frame-budget bound. A pass can never cost more
    /// than one capped layout no matter how many candidates are eligible.
    @Test func onlyOneBlockIsPlannedPerPass() {
        let plan = LongBlockLayout.decide(
            candidates: (0..<8).map { candidate($0, length: 20_000) }, handled: [])
        #expect(plan.layOut?.blockID == "b0")
        #expect(plan.skippedOverCap.isEmpty)
    }

    /// The cap: over it, skip and RECORD — and keep looking, because a
    /// nearer block that cannot be helped must not hide a further one that
    /// can.
    @Test func aBlockOverTheCapIsPassedOverAndRecorded() {
        let plan = LongBlockLayout.decide(
            candidates: [
                candidate(0, length: LongBlockLayout.maxBlockUTF16Length + 1),
                candidate(1, length: 20_000),
            ],
            handled: [])
        #expect(plan.skippedOverCap.map(\.blockID) == ["b0"])
        #expect(plan.layOut?.blockID == "b1")
    }

    /// Exactly AT the cap is allowed — the boundary is inclusive, and the
    /// derivation below is what makes that safe.
    @Test func exactlyAtTheCapIsStillAllowed() {
        let plan = LongBlockLayout.decide(
            candidates: [candidate(0, length: LongBlockLayout.maxBlockUTF16Length)],
            handled: [])
        #expect(plan.layOut?.blockID == "b0")
    }

    @Test func aBlockUnderTheFloorIsNeverConsidered() {
        let plan = LongBlockLayout.decide(
            candidates: [
                candidate(0, length: LongBlockLayout.minBlockUTF16Length - 1),
                candidate(1, length: 0),
            ],
            handled: [])
        #expect(plan.isEmpty)
    }

    @Test func anAlreadyHandledBlockIsNeverConsideredAgain() {
        let candidates = [candidate(0, length: 20_000), candidate(1, length: 20_000)]
        #expect(LongBlockLayout.decide(candidates: candidates, handled: ["b0"])
            .layOut?.blockID == "b1")
        #expect(LongBlockLayout.decide(candidates: candidates, handled: ["b0", "b1"])
            .isEmpty)
    }

    @Test func anAlreadyLaidOutBlockIsNeverConsidered() {
        let plan = LongBlockLayout.decide(
            candidates: [candidate(0, length: 40_000, laidOut: true)], handled: [])
        #expect(plan.isEmpty)
    }

    /// **The cap's own derivation, pinned** so it cannot be raised past the
    /// evidence without this failing. Batch 1C's worst measured rate is
    /// 0.117 ms per 1,000 UTF-16 units (the 1,000-word case; the rate
    /// IMPROVES with block size). The budget is half a 60 Hz frame in a
    /// DEBUG build — Release is faster, which is margin on top.
    @Test func theCapStaysUnderHalfAFrameAtTheWorstMeasuredRate() {
        let worstRateMsPer1kUnits = 0.117
        let predictedMs = Double(LongBlockLayout.maxBlockUTF16Length) / 1000
            * worstRateMsPer1kUnits
        #expect(predictedMs <= 8.34, "predicted worst case \(predictedMs) ms")
        #expect(LongBlockLayout.minBlockUTF16Length < LongBlockLayout.maxBlockUTF16Length)
        #expect(LongBlockLayout.minBlockUTF16Length > 0)
    }

    /// The tiling arithmetic (each entry followed by exactly one separator).
    @Test func theEntryContainingAnOffsetIsFoundByTheTilingArithmetic() {
        let entries = [3, 5, 2].map {
            BlockRangeIndex.Entry(blockID: "b\($0)", variantID: "v", length: $0, editable: true)
        }
        // "abc\ndefgh\nij" — 0…3 entry 0, 4…9 entry 1, 10…12 entry 2.
        #expect(LongBlockLayout.entryIndex(containingOffset: 0, entries: entries) == 0)
        #expect(LongBlockLayout.entryIndex(containingOffset: 3, entries: entries) == 0)
        #expect(LongBlockLayout.entryIndex(containingOffset: 4, entries: entries) == 1)
        #expect(LongBlockLayout.entryIndex(containingOffset: 9, entries: entries) == 1)
        #expect(LongBlockLayout.entryIndex(containingOffset: 10, entries: entries) == 2)
        #expect(LongBlockLayout.entryIndex(containingOffset: 999, entries: entries) == 2)
        #expect(LongBlockLayout.entryIndex(containingOffset: -1, entries: entries) == nil)
        #expect(LongBlockLayout.entryIndex(containingOffset: 0, entries: []) == nil)
    }
}

// MARK: - The driver, in a real window against real TK2 geometry

@MainActor
@Suite("LongBlockLayout — the phantom fix in a real window (13c 1E)", .serialized)
struct LongBlockLayoutHostedTests {
    private func pump(_ turns: Int = 3) {
        for _ in 0..<turns {
            RunLoop.main.run(until: Date().addingTimeInterval(0.03))
        }
    }

    /// The 1A/1C corpus: 60 short blocks (all far under the floor) with ONE
    /// long block in the middle — so "how many layouts ran" is unambiguous.
    private func corpus(longWords: Int, at index: Int = 30) -> [String] {
        var blocks = (0..<60).map { "short block \($0) of text here" }
        blocks[index] = (0..<longWords).map { "longword\($0 % 97)" }.joined(separator: " ")
        return blocks
    }

    private func mount(
        _ h: EditorHarness, height: CGFloat = 600, width: CGFloat = 760
    ) throws -> (NSScrollView, NSWindow) {
        let scrollView = try #require(h.textView.enclosingScrollView)
        scrollView.frame = NSRect(x: 0, y: 0, width: width, height: height)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = NSView(frame: NSRect(x: 0, y: 0, width: width, height: height))
        window.contentView?.addSubview(scrollView)
        window.makeKeyAndOrderFront(nil)
        window.layoutIfNeeded()
        window.display()
        pump()
        return (scrollView, window)
    }

    /// A defaults domain of this test's own — the kill switch must never be
    /// read from (or written to) the real one.
    private func isolatedDefaults(enabled: Bool? = nil) -> UserDefaults {
        let name = "io.lduarte.variorum.tests.longBlockLayout.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        if let enabled { defaults.set(enabled, forKey: LongBlockLayout.settingKey) }
        return defaults
    }

    private func fragment(
        _ h: EditorHarness, entry: Int
    ) throws -> (height: CGFloat, laidOut: Bool) {
        let layoutManager = try #require(h.textView.textLayoutManager)
        let contentManager = try #require(layoutManager.textContentManager)
        let range = h.model.index.range(ofEntryAt: entry)
        let start = try #require(contentManager.location(
            contentManager.documentRange.location, offsetBy: range.location))
        var result: (CGFloat, Bool) = (0, false)
        layoutManager.enumerateTextLayoutFragments(from: start, options: []) { fragment in
            result = (fragment.layoutFragmentFrame.height,
                      fragment.state == .layoutAvailable)
            return false
        }
        return result
    }

    /// **The capability, characterized end to end.** A long block TK2 has
    /// only ESTIMATED, sitting within the look-ahead below the viewport,
    /// is laid out — its over-guess collapses, and the document shrinks by
    /// the same phantom on the next display pass (1C's measured caveat,
    /// handled).
    @Test func aPassCollapsesThePhantomOfALongBlock() async throws {
        try await withEditor(seedBlocks: corpus(longWords: 3000)) { h in
            let (_, window) = try mount(h)
            defer { window.orderOut(nil); window.close() }
            h.model.longBlockLayout.defaults = isolatedDefaults()

            let before = try fragment(h, entry: 30)
            #expect(!before.laidOut, "the reproduction needs an ESTIMATED long block")
            let documentBefore = h.textView.frame.height

            let plan = h.model.runLongBlockLayoutPass()
            #expect(plan.layOut?.blockID == h.model.index.entries[30].blockID,
                    "the pass must pick the one long block, not a short neighbour")
            #expect(h.model.longBlockLayout.layoutsRun == 1)

            let after = try fragment(h, entry: 30)
            #expect(after.laidOut)
            #expect(after.height < before.height,
                    "the over-estimate must collapse: \(before.height) → \(after.height)")

            // The nudge lands in the SAME turn — the phantom closes with
            // the layout, not a beat later (see the nudge's own pin).
            #expect(h.textView.frame.height < documentBefore,
                    "the document must give back the phantom: \(documentBefore) → \(h.textView.frame.height)")
            // The document gives back what the BLOCK gave back — to within
            // one uniform paragraph gap (measured 7 pt: a fragment's frame
            // carries its trailing gap, `usageBoundsForTextContainer`
            // accounts the last one differently — `BlockDecor.textBottom`'s
            // class, not a leak).
            let givenBack = documentBefore - h.textView.frame.height
            let blockGaveBack = before.height - after.height
            #expect(abs(givenBack - blockGaveBack) <= CGFloat(12),
                    "the document shrank by \(givenBack) pt; the block gave back \(blockGaveBack) pt")
        }
    }

    /// **THE GUARD PIN the brief names: at most ONCE per block per
    /// session** — and the leg that proves `handled` earns its keep.
    ///
    /// Repeated passes over an unchanged viewport, and a scroll to the far
    /// end and back, are held by TK2's own `layoutAvailable` state (1C
    /// measured that it does not discard the layout). **A WIDTH REFLOW is
    /// different, and this batch measured it: the block goes back to
    /// ESTIMATED** (7,300 pt laid out → 11,492 pt estimated at a narrower
    /// width). So after a sidebar toggle, a split-divider drag or a window
    /// resize, nothing but `handled` stands between this feature and a
    /// re-layout of every long block on every resize — which is exactly
    /// the trigger bug the brief exists to prevent. (Red with the
    /// `handled` insert reverted: the reflow leg re-lays it out.)
    @Test func theSameBlockIsNeverLaidOutTwice() async throws {
        try await withEditor(seedBlocks: corpus(longWords: 3000)) { h in
            let (scrollView, window) = try mount(h)
            defer { window.orderOut(nil); window.close() }
            h.model.longBlockLayout.defaults = isolatedDefaults()

            for _ in 0..<10 {
                h.model.runLongBlockLayoutPass()
                window.displayIfNeeded()
                pump(1)
            }
            #expect(h.model.longBlockLayout.layoutsRun == 1,
                    "\(h.model.longBlockLayout.layoutsRun) layout calls for one block")

            // …scrolling to the far end and back does not re-open the door
            // (TK2 keeps the layout — 1C measured it).
            let viewport = scrollView.frame.height
            scrollView.contentView.scroll(
                to: CGPoint(x: 0, y: max(0, h.textView.frame.height - viewport)))
            scrollView.reflectScrolledClipView(scrollView.contentView)
            window.displayIfNeeded()
            pump()
            scrollView.contentView.scroll(to: .zero)
            scrollView.reflectScrolledClipView(scrollView.contentView)
            window.displayIfNeeded()
            pump()
            h.model.runLongBlockLayoutPass()
            #expect(h.model.longBlockLayout.layoutsRun == 1)
            #expect(try fragment(h, entry: 30).laidOut)

            // …and a WIDTH REFLOW, which really does re-estimate, still
            // does not: this is the leg `handled` alone holds.
            scrollView.frame = NSRect(x: 0, y: 0, width: 520, height: viewport)
            window.setContentSize(NSSize(width: 520, height: viewport))
            window.layoutIfNeeded()
            window.display()
            pump()
            #expect(!(try fragment(h, entry: 30).laidOut),
                    "the premise of this leg: a width reflow re-estimates")
            for _ in 0..<5 {
                h.model.runLongBlockLayoutPass()
                window.displayIfNeeded()
                pump(1)
            }
            #expect(h.model.longBlockLayout.layoutsRun == 1,
                    "a resize must not re-run the layout: \(h.model.longBlockLayout.layoutsRun) calls")
        }
    }

    /// **THE CAP, in a real window.** A block past the measured ceiling is
    /// skipped and recorded — never a hitch she would feel — and it stays
    /// estimated. (Red with the cap comparison reverted.)
    @Test func aBlockOverTheCapIsSkippedAndRecorded() async throws {
        // ~76,000 UTF-16 units, comfortably past the 64,000 cap.
        try await withEditor(seedBlocks: corpus(longWords: 7000)) { h in
            let (_, window) = try mount(h)
            defer { window.orderOut(nil); window.close() }
            h.model.longBlockLayout.defaults = isolatedDefaults()

            let blockID = h.model.index.entries[30].blockID
            #expect(h.model.index.entries[30].length > LongBlockLayout.maxBlockUTF16Length)

            let plan = h.model.runLongBlockLayoutPass()
            #expect(plan.layOut == nil)
            #expect(plan.skippedOverCap.map(\.blockID) == [blockID])
            #expect(h.model.longBlockLayout.layoutsRun == 0)
            #expect(h.model.longBlockLayout.skippedOverCap == [blockID])
            #expect(!(try fragment(h, entry: 30).laidOut),
                    "an over-cap block is left exactly as TK2 had it")

            // …and it is recorded ONCE, not on every pass.
            h.model.runLongBlockLayoutPass()
            #expect(h.model.longBlockLayout.skippedOverCap == [blockID])
        }
    }

    /// **THE FLOOR — the calm default costs nothing.** An ordinary post of
    /// ordinary blocks performs zero layout calls for its whole life, which
    /// is the real work the floor does: it keeps the TRIGGER quiet.
    /// (Red with the floor comparison reverted.)
    @Test func anOrdinaryPostNeverLaysOutAnything() async throws {
        try await withEditor(
            seedBlocks: (0..<60).map { "short block \($0) of text here" }
        ) { h in
            let (_, window) = try mount(h)
            defer { window.orderOut(nil); window.close() }
            h.model.longBlockLayout.defaults = isolatedDefaults()

            for _ in 0..<5 {
                #expect(h.model.runLongBlockLayoutPass().isEmpty)
                window.displayIfNeeded()
                pump(1)
            }
            #expect(h.model.longBlockLayout.layoutsRun == 0)
            #expect(h.model.longBlockLayout.handled.isEmpty)
        }
    }

    /// **THE KILL SWITCH.** Off ⇒ nothing happens at all and the phantom
    /// stands, which is the whole point: she rules on Q3 having felt both.
    /// (Red with the setting guard reverted.)
    @Test func theKillSwitchStopsItCompletely() async throws {
        try await withEditor(seedBlocks: corpus(longWords: 3000)) { h in
            let (_, window) = try mount(h)
            defer { window.orderOut(nil); window.close() }
            h.model.longBlockLayout.defaults = isolatedDefaults(enabled: false)

            #expect(!h.model.longBlockLayoutEnabled)
            #expect(h.model.runLongBlockLayoutPass().isEmpty)
            #expect(h.model.longBlockLayout.layoutsRun == 0)
            #expect(!(try fragment(h, entry: 30).laidOut),
                    "with the switch off the estimate stands, phantom and all")

            // …and the trigger arms nothing either.
            h.model.considerLongBlockLayout()
            #expect(h.model.longBlockLayout.task == nil)

            // Turning it back on restores the behaviour with no relaunch.
            h.model.longBlockLayout.defaults.set(true, forKey: LongBlockLayout.settingKey)
            h.model.runLongBlockLayoutPass()
            #expect(h.model.longBlockLayout.layoutsRun == 1)
        }
    }

    /// **THE NUDGE.** 1C measured that the scroll extent does not shrink
    /// synchronously with the layout call, and this batch measured WHICH
    /// lever moves it: a display pass does nothing (9,063 pt before and
    /// after), a LAYOUT pass re-frames the text view from
    /// `usageBoundsForTextContainer` (9,063 → 8,533 pt). So the pass asks
    /// for layout and settles it in the same turn. Asserted with no
    /// display or runloop turn in between, so the pin is about our call
    /// rather than AppKit's timing. (Red with the nudge reverted: the
    /// frame stays at the estimate.)
    @Test func thePassAsksForTheRefreshItNeeds() async throws {
        try await withEditor(seedBlocks: corpus(longWords: 3000)) { h in
            let (_, window) = try mount(h)
            defer { window.orderOut(nil); window.close() }
            h.model.longBlockLayout.defaults = isolatedDefaults()

            let before = h.textView.frame.height
            h.model.runLongBlockLayoutPass()
            #expect(h.model.longBlockLayout.layoutsRun == 1)
            #expect(h.textView.frame.height < before,
                    "the scroll extent must close in the same turn: \(before) → \(h.textView.frame.height)")
        }
    }

    /// **SCOPE — the detail editor only.** The inline (book-view) editor is
    /// sized to CONTENT by its wrapper, so it has no viewport smaller than
    /// its document: "the block the viewport is looking at" would mean
    /// every block, which is exactly the document-scale work P1 forbids.
    /// The surface is framed at content scale here precisely so the claim
    /// is tested rather than asserted. (Red with the `scrollView` guard
    /// reverted to a whole-surface fallback: the long block becomes a
    /// candidate and gets laid out.)
    @Test func theInlineEditorIsOutOfScope() async throws {
        try await withEditor(seedBlocks: corpus(longWords: 3000)) { h in
            let inlineModel = EditorViewModel(session: h.session, postID: h.postID)
            inlineModel.tailIdleSleep = { _ in throw CancellationError() }
            inlineModel.longBlockLayout.sleep = { _ in throw CancellationError() }
            inlineModel.longBlockLayout.defaults = isolatedDefaults()
            let inlineView = EditorTextView.makeInlineEditor()
            // What the wrapper does: frame it at content scale, not at a
            // viewport's scale.
            inlineView.frame = NSRect(x: 0, y: 0, width: 760, height: 20_000)
            let delegate = EditorSurfaceDelegate(model: inlineModel)
            delegate.wire(to: inlineView)
            inlineModel.attach(textView: inlineView, scrollView: nil)
            let slots = try h.database.read { db in
                try Queries.renderPost(db, containerID: h.postID)
            }
            inlineModel.applyProjection(slots)

            #expect(inlineModel.index.entries.count == 60)
            #expect(inlineModel.runLongBlockLayoutPass().isEmpty)
            #expect(inlineModel.longBlockLayout.layoutsRun == 0)
            inlineModel.considerLongBlockLayout()
            #expect(inlineModel.longBlockLayout.task == nil)

            inlineModel.teardown()
            // The detail model stays the router's active surface.
            h.model.attach(textView: h.textView, scrollView: h.textView.enclosingScrollView)
        }
    }

    /// **THE TRIGGER SOAK — the whole feature's bound, over real
    /// scrolling.** A 100-block post with three long blocks, swept top to
    /// bottom a pass at a time: the total number of `ensureLayout` calls
    /// must never exceed the number of long blocks, no SHORT block may
    /// ever be touched, and a SECOND full sweep must add nothing at all.
    /// This is the pin that says the cost is bounded by the post's long
    /// blocks rather than by how much she scrolls.
    @Test func aScrollSweepTouchesEachLongBlockAtMostOnceAndNoShortOne() async throws {
        var blocks = (0..<100).map { "short block \($0) of text here" }
        let long = (0..<1500).map { "longword\($0 % 97)" }.joined(separator: " ")
        for i in [25, 50, 75] { blocks[i] = long }
        try await withEditor(seedBlocks: blocks) { h in
            let (scrollView, window) = try mount(h, height: 500)
            defer { window.orderOut(nil); window.close() }
            h.model.longBlockLayout.defaults = isolatedDefaults()
            let longIDs = Set([25, 50, 75].map { h.model.index.entries[$0].blockID })

            @MainActor func sweep() {
                var y: CGFloat = 0
                var steps = 0
                while y < h.textView.frame.height, steps < 400 {
                    scrollView.contentView.scroll(to: CGPoint(x: 0, y: y))
                    scrollView.reflectScrolledClipView(scrollView.contentView)
                    window.displayIfNeeded()
                    pump(1)
                    h.model.runLongBlockLayoutPass()
                    y += 400
                    steps += 1
                }
            }

            sweep()
            #expect(h.model.longBlockLayout.layoutsRun <= longIDs.count,
                    "\(h.model.longBlockLayout.layoutsRun) layout calls for \(longIDs.count) long blocks")
            #expect(h.model.longBlockLayout.handled.isSubset(of: longIDs),
                    "a short block was touched: \(h.model.longBlockLayout.handled.subtracting(longIDs))")
            for i in [25, 50, 75] {
                #expect(try fragment(h, entry: i).laidOut,
                        "block \(i) should be honest after a full read-through")
            }

            let afterFirst = h.model.longBlockLayout.layoutsRun
            sweep()
            #expect(h.model.longBlockLayout.layoutsRun == afterFirst,
                    "a second read-through must cost NOTHING")
        }
    }

    /// **THE REACH IS BOUNDED** — what keeps "the viewport is looking at
    /// it" from quietly meaning "the whole post". A long block far below
    /// the viewport plus one screenful is not this pass's business; it
    /// becomes eligible when she scrolls toward it.
    ///
    /// Two bounds hold this jointly, and the reverts showed which does the
    /// work where: at THIS distance (entry 150 of 200) the LOOKUP bound
    /// binds first — reverting the look-ahead alone leaves the test green,
    /// and reverting the lookup bound alone does too. Reverting BOTH is
    /// red (the pass reaches entry 150 and lays it out). Recorded rather
    /// than claimed the other way round.
    @Test func aLongBlockFarBelowTheLookAheadIsLeftAlone() async throws {
        var blocks = (0..<200).map { "short block \($0) of text here" }
        blocks[150] = (0..<1200).map { "longword\($0 % 97)" }.joined(separator: " ")
        try await withEditor(seedBlocks: blocks) { h in
            let (_, window) = try mount(h, height: 400)
            defer { window.orderOut(nil); window.close() }
            h.model.longBlockLayout.defaults = isolatedDefaults()

            #expect(h.model.runLongBlockLayoutPass().isEmpty)
            #expect(h.model.longBlockLayout.layoutsRun == 0)
        }
    }
}
