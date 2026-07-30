//
//  DivideCeremonyCostTests.swift
//  VariorumTests
//
//  QoL round 2026-07-29, batch 1 — **L1**, her words: *"the take divider isn't
//  working properly - on a long block, i get the spinning rainbow circle …
//  either way, it's not really working properly."*
//
//  The traced mechanism (re-verified in code before any fix): the ceremony
//  sheet's `strongSlots` was a COMPUTED property running a full
//  `BoundarySnapping.boundaries(.sentence)` scan, and it was read once PER SLOT
//  inside the flow's `ForEach` — so a 3,000-word take cost ~3,000 full scans of
//  its own 18k characters per body pass, per marked take, with ~1.3 GB of
//  transient allocation behind them. The drag path was worse per event:
//  `nearestSlot`'s `min(by:)` calls `score` twice per comparison and each
//  `score` re-derived the same set, i.e. ~6,000 scans per drag sample at
//  60–120 Hz.
//
//  These pins bound BOTH costs — the scans (`BoundaryScanCount`, thread-local)
//  and the per-slot view elements (`CutFlowRealization`) — because the
//  restructure has to fix both or the sheet is merely less catastrophic.
//

import AppKit
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The divide ceremony's cost on a long block (QoL L1)", .serialized)
struct DivideCeremonyCostTests {
    /// ASYNC-POLL, never sync RunLoop pumping (the environment traps' rule —
    /// and the first cut of this suite hung indefinitely on `RunLoop.main.run`
    /// with a hosted SwiftUI view, at every fixture size including a 20-word
    /// one, which is how the trap announced itself).
    private func settle(_ window: NSWindow, _ hosting: NSView, turns: Int = 6) async {
        for _ in 0..<turns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }

    /// ~3,000 words of ordinary prose, sentence-punctuated so the sentence
    /// scanner has real work — her scale, not a fan-scale toy.
    private func longTake(_ seed: Int, words: Int = 3000) -> String {
        var parts: [String] = []
        parts.reserveCapacity(words)
        for i in 0..<words {
            parts.append("word\(seed)x\(i % 211)")
            if i % 13 == 12 { parts.append("sentence end.") }
            if i % 137 == 136 { parts.append("\n") }
        }
        return parts.joined(separator: " ")
    }

    /// Opens the ceremony on a block with FOUR long takes, every take marked
    /// (so every flow renders — the state she is looking at), and hands back
    /// the mounted sheet.
    private func mountCeremony(
        _ h: EditorHarness, takes: Int = 4, words: Int = 3000
    ) async throws -> (NSWindow, DivideWCeremony, DivideWCeremony.State) {
        let slots = try h.storeSlots()
        let first = try #require(slots.first)
        for i in 1..<takes {
            let variant = try h.session.operations.branchVariant(
                first.blockID, from: try #require(first.variantID))
            try h.session.operations.autosave(
                variant.id, text: longTake(i, words: words), charDelta: 0)
        }
        try h.reload()

        h.textView.setSelectedRange(NSRange(location: 400, length: 0))
        h.model.updateCaretContext()
        await h.model.invokeGesture(.divideAtCursor)

        let state = try #require(h.model.divideWCeremony, "the ceremony opened")
        #expect(state.takes.count == takes, "all \(takes) takes are in the checklist")
        for take in state.takes where !take.marked {
            h.model.toggleWTake(take.id)
        }
        let live = try #require(h.model.divideWCeremony)
        let allMarked = !live.takes.contains { !$0.marked }
        #expect(allMarked, "every take marked: every flow renders")

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 700),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        return (window, h.model.divideWCeremonyController, live)
    }

    /// Mounts the sheet and lays it out — the FIRST render, which is the one
    /// that costs. Returns the hosting view so a pin can drive it further.
    @discardableResult
    private func mountSheet(
        _ window: NSWindow, _ ceremony: DivideWCeremony, _ state: DivideWCeremony.State
    ) async -> NSHostingView<DivideWSheet> {
        let hosting = NSHostingView(
            rootView: DivideWSheet(ceremony: ceremony, presented: state))
        hosting.frame = NSRect(x: 0, y: 0, width: 700, height: 700)
        window.contentView = hosting
        await settle(window, hosting)
        return hosting
    }

    /// **RED ON SHIPPED, by orders of magnitude.** Mounting the sheet must not
    /// scan a take's text at all: every boundary set the sheet needs is derived
    /// ONCE per take when the ceremony opens, not per slot per body pass.
    @Test func mountingTheSheetPerformsNoBoundaryScans() async throws {
        try await withEditor(seedBlocks: [longTake(0)]) { h in
            let (window, ceremony, state) = try await mountCeremony(h)
            defer { window.orderOut(nil); window.close() }

            BoundaryScanCount.reset()
            CutFlowRealization.slotViews = 0
            await mountSheet(window, ceremony, state)
            let scans = BoundaryScanCount.current
            let slotViews = CutFlowRealization.slotViews
            print("L1 mount: \(scans) scans · \(slotViews) per-slot view elements")

            #expect(scans == 0,
                    """
                    rendering the sheet must perform NO full-text scans (\(scans)) — \
                    the shipped sheet ran one per slot per body pass, per marked take
                    """)
            #expect(slotViews == 0,
                    """
                    the flow must not realize a view element per legal cut position \
                    (\(slotViews)) — the shipped one built a Button + ZStack + \
                    GeometryReader + hover tracker for each, measured twice per pass
                    """)
        }
    }

    /// **RED ON SHIPPED.** Placing a cut — one click, one arrow key — re-runs
    /// the sheet's body. It must cost nothing but a redraw.
    @Test func placingACutPerformsNoBoundaryScans() async throws {
        try await withEditor(seedBlocks: [longTake(0)]) { h in
            let (window, ceremony, state) = try await mountCeremony(h)
            defer { window.orderOut(nil); window.close() }
            let hosting = await mountSheet(window, ceremony, state)
            let take = try #require(ceremony.state?.takes.first)
            let target = try #require(take.boundaries.dropFirst(20).first)

            BoundaryScanCount.reset()
            CutFlowRealization.slotViews = 0
            ceremony.placeCut(takeID: take.id, cut: target)
            hosting.needsLayout = true
            await settle(window, hosting)
            let scans = BoundaryScanCount.current
            print("L1 place: \(scans) scans · \(CutFlowRealization.slotViews) per-slot view elements")

            #expect(ceremony.state?.takes.first?.cut == target, "the cut really moved")
            #expect(scans == 0,
                    "a click or keystroke must perform NO full-text scans (\(scans))")
            #expect(CutFlowRealization.slotViews == 0)
        }
    }

    /// **RED ON SHIPPED.** ⌥←/→ stepped by sentence and re-derived the strong
    /// set on every keypress — one scan per key, on the keystroke path.
    @Test func aSentenceStepPerformsNoBoundaryScans() async throws {
        try await withEditor(seedBlocks: [longTake(0)]) { h in
            let (window, ceremony, _) = try await mountCeremony(h)
            defer { window.orderOut(nil); window.close() }
            let take = try #require(ceremony.state?.takes.first)

            BoundaryScanCount.reset()
            var cut: Int? = take.boundaries.first
            for _ in 0..<12 {
                cut = WCutPlacement.sentenceStep(
                    from: cut, strong: take.strongBoundaries,
                    boundaries: take.boundaries, forward: true)
            }
            let scans = BoundaryScanCount.current
            print("L1 sentence steps: \(scans) scans for 12 keypresses")

            #expect(cut != nil, "the steps went somewhere")
            #expect(scans == 0,
                    "a sentence step reads the take's cached strong set (\(scans) scans)")
        }
    }

    /// The drag path, which was the worst per event (~2 scans per candidate per
    /// sample). It resolves from the cached geometry now — a pure arithmetic
    /// query with no text in sight.
    @Test func resolvingDragTargetsPerformsNoBoundaryScans() async throws {
        try await withEditor(seedBlocks: [longTake(0)]) { h in
            let (window, ceremony, _) = try await mountCeremony(h)
            defer { window.orderOut(nil); window.close() }
            let take = try #require(ceremony.state?.takes.first)
            let geometry = CutFlowGeometry.make(
                flow: take.flow, strong: take.strongBoundaries,
                width: 600, font: .systemFont(ofSize: 13))

            BoundaryScanCount.reset()
            var hits = 0
            for step in 0..<120 {
                let point = CGPoint(
                    x: CGFloat(step % 40) * 15, y: CGFloat(step % 12) * 21 + 4)
                if geometry.nearestSlot(to: point) != nil { hits += 1 }
            }
            let scans = BoundaryScanCount.current
            print("L1 drag: \(scans) scans for 120 nearest-slot resolutions")

            #expect(hits > 100, "non-vacuity: the queries resolved")
            #expect(scans == 0,
                    "dragging consults cached geometry only (\(scans) scans)")
        }
    }

    /// **The open budget.** Deriving each take's boundaries, strong set and
    /// flow is real work and is done ONCE per take — off the main thread, so
    /// the gesture never blocks the UI on it.
    @Test func openingDerivesOncePerTakeAndNeverOnTheMainThread() async throws {
        try await withEditor(seedBlocks: [longTake(0)]) { h in
            let slots = try h.storeSlots()
            let first = try #require(slots.first)
            for i in 1..<4 {
                let variant = try h.session.operations.branchVariant(
                    first.blockID, from: try #require(first.variantID))
                try h.session.operations.autosave(
                    variant.id, text: longTake(i), charDelta: 0)
            }
            try h.reload()
            h.textView.setSelectedRange(NSRange(location: 400, length: 0))
            h.model.updateCaretContext()

            BoundaryScanCount.reset()
            let started = ContinuousClock.now
            await h.model.invokeGesture(.divideAtCursor)
            let elapsed = started.duration(to: .now)
            let mainThreadScans = BoundaryScanCount.current
            let ms = Double(elapsed.components.seconds) * 1000
                + Double(elapsed.components.attoseconds) / 1e15
            print("L1 open: \(String(format: "%.1f", ms)) ms · \(mainThreadScans) main-thread scans")

            let state = try #require(h.model.divideWCeremony)
            #expect(state.takes.count == 4)
            let derived = !state.takes.contains { $0.boundaries.isEmpty || $0.flow.isEmpty }
            #expect(derived, "every take's geometry inputs were derived once, at open")
            #expect(mainThreadScans <= 2,
                    """
                    opening must not scan the takes on the MAIN thread \
                    (\(mainThreadScans)) — the derivation is detached; what remains \
                    is the planner's own snap of the caret's take
                    """)
            #expect(ms < 250,
                    "opening the ceremony stays responsive (\(String(format: "%.1f", ms)) ms)")
        }
    }
}

/// **L2 — what the checkbox does, and her ruling about the row.** Her words:
/// *"it's not really clear to me what selecting the take button below is
/// supposed to do? just split that take as well?"* Yes: a checked take carries
/// its own cut and its halves become the two new blocks' takes; an unchecked
/// take is not cut and joins neither, staying whole on the preserved original.
/// The copy now says both halves on the surface; this pins the one BEHAVIOUR
/// her ruling changed.
@MainActor
@Suite("The divide ceremony's row click (QoL L2)", .serialized)
struct DivideCeremonyRowTapTests {
    private func openCeremony(_ h: EditorHarness) async throws -> DivideWCeremony {
        let slots = try h.storeSlots()
        let first = try #require(slots.first)
        let second = try h.session.operations.branchVariant(
            first.blockID, from: try #require(first.variantID))
        try h.session.operations.autosave(
            second.id, text: "A wholly different second take of this block.", charDelta: 0)
        try h.reload()
        h.textView.setSelectedRange(NSRange(location: 15, length: 0))
        h.model.updateCaretContext()
        await h.model.invokeGesture(.divideAtCursor)
        _ = try #require(h.model.divideWCeremony)
        return h.model.divideWCeremonyController
    }

    /// HER RULING: clicking an UNCHECKED take's row checks it. Reverting the
    /// rule restores the swallowed click — the shipped behaviour, where the
    /// gesture did nothing whatsoever.
    @Test func clickingAnUncheckedRowChecksIt() async throws {
        try await withEditor(seedBlocks: ["First alpha. First omega."]) { h in
            let ceremony = try await openCeremony(h)
            let unchecked = try #require(ceremony.state?.takes.first { !$0.marked })

            let aimed = ceremony.rowTapped(unchecked.id)
            let after = try #require(ceremony.state?.takes.first { $0.id == unchecked.id })
            #expect(after.marked, "a click on an unchecked row checks it — it never swallowed")
            #expect(aimed == unchecked.id, "…and aims the arrow keys there")
        }
    }

    /// …and a CHECKED row keeps its existing behaviour exactly: it aims the
    /// arrows and does not uncheck (unchecking stays the checkbox's own job,
    /// so a stray click can never drop a take out of the divide).
    @Test func clickingACheckedRowOnlyAimsTheArrows() async throws {
        try await withEditor(seedBlocks: ["First alpha. First omega."]) { h in
            let ceremony = try await openCeremony(h)
            let checked = try #require(ceremony.state?.takes.first { $0.marked })

            let aimed = ceremony.rowTapped(checked.id)
            let after = try #require(ceremony.state?.takes.first { $0.id == checked.id })
            #expect(after.marked, "still checked — a row click never unchecks")
            #expect(aimed == checked.id)
        }
    }

    /// The checkbox itself is untouched: it still toggles both ways.
    @Test func theCheckboxStillTogglesBothWays() async throws {
        try await withEditor(seedBlocks: ["First alpha. First omega."]) { h in
            let ceremony = try await openCeremony(h)
            let checked = try #require(ceremony.state?.takes.first { $0.marked })
            ceremony.toggleTake(checked.id)
            #expect(ceremony.state?.takes.first { $0.id == checked.id }?.marked == false)
            ceremony.toggleTake(checked.id)
            #expect(ceremony.state?.takes.first { $0.id == checked.id }?.marked == true)
        }
    }
}
