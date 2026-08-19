//
//  EditorWindowSmokeTests.swift
//  VariorumTests
//
//  Phase 7 Step 8 — the automatable slice of the TEXTKIT2_NOTES §5 matrix
//  on a REAL window with a 10k-word post: (a) canary silent through a real
//  editing session; (b) the hybrid jump lands its target block at the
//  viewport top; content-anchored restore across a width reflow (the
//  spike's −79-paragraph hazard); typing cost stays inside the frame budget
//  at 10k words. The interactive checks (live resize drag, visual draw
//  correctness, selection feel) remain the author's manual pass.
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("10k-word window smoke (Step 8)", .serialized)
struct EditorWindowSmokeTests {
    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// ~10k words: 50 paragraph-blocks × 200 words.
    private var corpus: [String] {
        (0..<50).map { p in
            (0..<200).map { "word\(($0 &+ p) % 977)" }.joined(separator: " ") + " ¶\(p)"
        }
    }

    @Test func tenThousandWordPostStaysSnappyAndAnchored() async throws {
        try await withEditor(seedBlocks: corpus) { h in
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 900, height: 600),
                styleMask: [.titled, .resizable], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let scrollView = try #require(h.textView.enclosingScrollView)
            window.contentView = scrollView
            window.orderFrontRegardless()
            pump()

            // (a) A real editing session with the canary armed: typing at
            // the start, middle, and end of the document.
            h.type("Start. ", at: 0)
            let middle = h.model.index.range(ofEntryAt: 25).location + 10
            h.type(" mid ", at: middle)
            h.type(" End.", at: (h.documentText as NSString).length)
            #expect(h.model.canaryMessage == nil)

            // (b) The bounded hybrid jump lands block 40 at the viewport top.
            let target = h.model.index.range(ofEntryAt: 40).location
            JumpPrimitive.jump(toOffset: target, textView: h.textView, scrollView: scrollView)
            pump()
            #expect(h.model.topVisibleOffset() == target)

            // Content-anchored restore across a width reflow (never
            // px-anchored — the memo's obligation; the notification wiring
            // is ScrollAnchorController's, driven manually here).
            let anchor = try #require(h.model.topVisibleOffset())
            window.setContentSize(NSSize(width: 600, height: 600))
            pump()
            h.model.restoreTopVisibleOffset(anchor)
            pump()
            #expect(h.model.topVisibleOffset() == anchor)

            // Typing cost at 10k words: 60 keystrokes mid-document through
            // the full pipeline (routing, index, attribute fix, autosave
            // record). Debug build, generous bound — the spike owns the
            // precise numbers; this guards against a pipeline regression
            // that scales with document size.
            let caret = h.model.index.range(ofEntryAt: 25).location + 4
            h.textView.setSelectedRange(NSRange(location: caret, length: 0))
            let t0 = ContinuousClock.now
            for _ in 0..<60 {
                h.textView.insertText("q", replacementRange: h.textView.selectedRange())
            }
            let elapsed = t0.duration(to: .now)
            let msPerKeystroke = Double(elapsed.components.attoseconds) / 1e15 / 60
                + Double(elapsed.components.seconds) * 1000 / 60
            #expect(msPerKeystroke < 16.7, "keystroke pipeline cost \(msPerKeystroke) ms")

            // And the store still matches the surface exactly.
            await h.flush()
            try expectStoreMatchesView(h)
            #expect(h.model.canaryMessage == nil)
        }
    }

    /// Phase 9 Step 8(ii)+(v): the structural slice of the §5 matrix on the
    /// same 10k-word windowed post — scroll/height stability THROUGH a
    /// structural rewrite, decorations (fan data) updating as fans are born
    /// by the W and die by merge, boundary selections resolving through the
    /// planner, and the full-re-render latency number for the PROVISIONAL
    /// full-re-render reading (QUESTIONS #8).
    @Test func structuralGesturesOnTheTenThousandWordWindowedPost() async throws {
        try await withEditor(seedBlocks: corpus) { h in
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 900, height: 600),
                styleMask: [.titled, .resizable], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let scrollView = try #require(h.textView.enclosingScrollView)
            window.contentView = scrollView
            window.orderFrontRegardless()
            pump()

            // Jump deep into the document, then divide mid-viewport: the
            // full-re-render latency is the PROVISIONAL reading's number.
            let block25 = h.model.index.range(ofEntryAt: 25)
            JumpPrimitive.jump(
                toOffset: block25.location, textView: h.textView, scrollView: scrollView)
            pump()
            // A legal mid-block sentence cut exists: each corpus paragraph
            // is one long sentence, so mint one first by typing a terminator.
            h.type("Insert. ", at: block25.location + 0)
            await h.flush()
            h.textView.setSelectedRange(NSRange(location: block25.location + 4, length: 0))
            h.model.updateCaretContext()
            // NIT 6 (review round 1): the window has what headless tests
            // lack — a real undoManager — so pin the text-undo clearing on
            // structural rewrites here (the KnownIssues row's part 2).
            #expect(h.textView.undoManager?.canUndo == true,
                    "typing above must have registered text-undo entries")
            let t0 = ContinuousClock.now
            await h.model.invokeGesture(.divideAtCursor)
            let elapsed = t0.duration(to: .now)
            let ms = Double(elapsed.components.seconds) * 1000
                + Double(elapsed.components.attoseconds) / 1e15
            print("Phase 9 Step 8(v): full gesture (divide op + full re-render + caret) on 10k words: \(ms) ms")
            #expect(ms < 100, "gesture-time full re-render must stay deliberate-act cheap: \(ms) ms")
            #expect(h.textView.undoManager?.canUndo == false,
                    "structural rewrites clear text-undo — stale-offset replays are the corruption class")
            try expectStoreMatchesView(h)
            pump()

            // (c) decorations: a fan born by the W ceremony badges its
            // blocks; a merge's fresh block carries none. The corpus
            // paragraphs are single run-on sentences, so give the target a
            // legal interior cut first (a divide with no legal cut refuses
            // BEFORE the W routing — the ceremony needs an active cut seed).
            h.type("Insert. ", at: h.model.index.range(ofEntryAt: 10).location)
            await h.flush()
            let slots = try h.storeSlots()
            let target = slots[10]
            _ = try h.session.operations.branchVariant(target.blockID, from: target.variantID!)
            try h.reload()
            #expect(try h.storeSlots()[10].hasFan, "fan data feeds the badge predicate")
            h.textView.setSelectedRange(NSRange(
                location: h.model.index.range(ofEntryAt: 10).location + 4, length: 0))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.divideAtCursor, ceremony: true)  // 13j J4: the ceremony DOOR
            #expect(h.model.divideWCeremony != nil)
            await h.model.confirmDivideWCeremony()            // active take marked → single-take fans
            let afterW = try h.storeSlots()
            #expect(afterW[10].blockID != target.blockID, "the W released the source")
            // Merge two plain neighbors: the fresh block has NO fan.
            h.textView.setSelectedRange(NSRange(
                location: h.model.index.range(ofEntryAt: 30).upperBound, length: 0))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.mergeBlocks)
            let merged = try h.storeSlots()
            #expect(!merged[30].hasFan, "a merged block starts with one take")
            pump()

            // (d) boundary selection resolves through the planner: the seam
            // caret between blocks 5 and 6 plans a merge of exactly (5, 6).
            let seam = h.model.index.range(ofEntryAt: 5).upperBound
            h.textView.setSelectedRange(NSRange(location: seam, length: 0))
            h.model.updateCaretContext()
            #expect(h.model.gestureAvailability.merge)
            let plan = StructuralGesturePlanner.plan(
                .mergeBlocks, selection: NSRange(location: seam, length: 0),
                world: h.model.gestureWorld())
            guard case .merge(let leading, let trailing, _, _) = plan else {
                Issue.record("expected a merge plan at the seam, got \(plan)")
                return
            }
            #expect(leading == 5 && trailing == 6)

            // (b) scroll/height stayed sane through the rewrites: the
            // content anchor still resolves and the canary never fired.
            #expect(h.model.topVisibleOffset() != nil)
            #expect(h.model.canaryMessage == nil)
            #expect(h.model.desyncRecoveryCount == 0)
            #expect(h.model.differentialOracleMisses == 0)
            await h.flush()
            try expectStoreMatchesView(h)
        }
    }

    /// Phase 9 Step 8(v), re-run per the author's mid-phase differential
    /// directive: BOTH rewrite strategies measured at 10k AND 50k words —
    /// the differential per-gesture cost (must stay flat: it edits the
    /// seam, never the document) and the full path's cost (the W ceremony /
    /// undo shape; document-proportional by design, recorded for the
    /// record). Numbers print for the closeout.
    @Test(arguments: [50, 250]) func rewriteStrategyLatencies(paragraphs: Int) async throws {
        let corpus = (0..<paragraphs).map { p in
            (0..<200).map { "word\(($0 &+ p) % 977)" }.joined(separator: " ") + " ¶\(p)"
        }
        try await withEditor(seedBlocks: corpus) { h in
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 900, height: 600),
                styleMask: [.titled, .resizable], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let scrollView = try #require(h.textView.enclosingScrollView)
            window.contentView = scrollView
            window.orderFrontRegardless()
            pump()
            let words = paragraphs * 200

            func ms(_ elapsed: Duration) -> Double {
                Double(elapsed.components.seconds) * 1000
                    + Double(elapsed.components.attoseconds) / 1e15
            }

            // Differential divide, mid-document (mint a legal cut first).
            let target = paragraphs / 2
            JumpPrimitive.jump(
                toOffset: h.model.index.range(ofEntryAt: target).location,
                textView: h.textView, scrollView: scrollView)
            pump()
            h.type("Insert. ", at: h.model.index.range(ofEntryAt: target).location)
            await h.flush()
            h.textView.setSelectedRange(NSRange(
                location: h.model.index.range(ofEntryAt: target).location + 4, length: 0))
            h.model.updateCaretContext()
            var t0 = ContinuousClock.now
            await h.model.invokeGesture(.divideAtCursor)
            let differential = ms(t0.duration(to: .now))
            print("Phase 9 Step 8(v) [\(words)w]: DIFFERENTIAL divide (op + seam edit + caret): \(differential) ms")
            #expect(differential < 50,
                    "the differential gesture must stay flat in document size: \(differential) ms at \(words) words")
            try expectStoreMatchesView(h)

            // The full path (the W ceremony's confirm), same document.
            let slots = try h.storeSlots()
            let fanned = slots[target + 2]
            h.type("Insert. ", at: h.model.index.range(ofEntryAt: target + 2).location)
            await h.flush()
            _ = try h.session.operations.branchVariant(fanned.blockID, from: fanned.variantID!)
            try h.reload()
            h.textView.setSelectedRange(NSRange(
                location: h.model.index.range(ofEntryAt: target + 2).location + 4, length: 0))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.divideAtCursor, ceremony: true)  // 13j J4: the ceremony DOOR
            #expect(h.model.divideWCeremony != nil)
            t0 = ContinuousClock.now
            await h.model.confirmDivideWCeremony()
            let full = ms(t0.duration(to: .now))
            print("Phase 9 Step 8(v) [\(words)w]: FULL W-confirm (op + full re-render + caret): \(full) ms")
            try expectStoreMatchesView(h)
            #expect(h.model.differentialOracleMisses == 0)
            #expect(h.model.canaryMessage == nil)
        }
    }
}
