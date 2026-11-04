//
//  WriteWordCountFlipTests.swift
//  VariorumTests
//
//  VX-739 (Run VX-770, batch 5) — WRITE'S "IN NOTE" WORD COUNT STAYS TRUE
//  ACROSS TAKE FLIPS. The sighting (the VX-736 J3 walk): the short note
//  "You, I hope :)" (3) / "A second short block of prose." (6) / "A third."
//  (2) = 11; caret in block 1; Write's take panel ＋ blank & choose → 8 (right);
//  ✓ the original → "3w block · 12w in note" (one high); ✓ the blank again →
//  "9w in note" (one high) — wrong from the SECOND flip on, and it stays wrong.
//
//  The traced mechanism (`notes/plans/fixes/vx-770-takes-compare-window.md`,
//  BATCH 5 › B): the flip's differential rewrite writes block 1 through
//  `programmaticReplace`, and AppKit moves the caret and posts the selection
//  change INSIDE that storage write (measured on a bare TK2 rig: "" → 14
//  characters at the caret moves it 0 → 14). `updateCaretContext` runs there,
//  against the tiling of the text BEFORE the write, resolves the caret onto
//  block 2 and stores block 2's live count over a misaligned range (7 words for
//  its 6); the ledger's text-keyed cache then keeps the 7 through every later
//  adopt, because block 2's own text never changed.
//
//  The pins read the model's published total against an ORACLE — the store's
//  shown texts, counted by the same `TextMetrics.wordCount` — after every flip.
//  RED on the pre-fix tree from the second flip (12 for 11, then 9 for 8),
//  PREDICTED (this batch is headless); the guard (typing still keeps the total
//  live between projections) is green on both trees by design.
//

import AppKit
import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Write's word count stays true across take flips (VX-739)", .serialized)
struct WriteWordCountFlipTests {
    /// Her sighting's note (TakeChoiceBadgeTests' fixture — the same J3 walk).
    static let note = ["You, I hope :)", "A second short block of prose.", "A third."]

    /// The truth the bottom bar should say: the store's SHOWN text, slot by
    /// slot, counted by the app's own counter.
    private func trueTotal(_ h: EditorHarness) throws -> Int {
        try h.storeSlots().reduce(0) { $0 + TextMetrics.wordCount($1.text ?? "") }
    }

    /// Async polling (TEXTKIT2_NOTES §3's harness fact — a nested run loop runs
    /// no main-queue hop; an `await` does). Bounded.
    private func pumpUntil(_ window: NSWindow?, _ condition: @MainActor () -> Bool) async {
        for _ in 0..<400 {
            if condition() { return }
            window?.displayIfNeeded()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(5))
        }
    }

    /// Write's surface in a real window with the APP's coordinator installed
    /// (TakeChoiceBadgeTests' mount — her J3 walk ran a mounted Write).
    private func mountWrite(
        _ h: EditorHarness
    ) throws -> (window: NSWindow, coordinator: EditorSurface.Coordinator) {
        let scrollView = try #require(h.textView.enclosingScrollView)
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 700, height: 600),
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

    /// **Her J3 shape, through the panel's own road** (`WriteTakesPanel`'s
    /// `TakesViewModel`: ＋ blank & choose = `newBlankTakeAsChosen`, ✓ =
    /// `choose`), Write hearing each store write as its observation does (a
    /// DELIVERY → the fresh re-read → the differential rewrite). After EVERY
    /// flip the published total must equal the oracle. RED (predicted) on the
    /// pre-fix tree at the second flip: 12 for 11 — and 9 for 8 at the third.
    @Test(arguments: [false, true])
    func flippingATakeTwiceKeepsTheNotesWordCountTrue(mounted: Bool) async throws {
        try await withEditor(seedBlocks: Self.note) { h in
            var mount: (window: NSWindow, coordinator: EditorSurface.Coordinator)?
            if mounted { mount = try mountWrite(h) }
            defer {
                if let mount {
                    mount.coordinator.uninstall()
                    mount.window.orderOut(nil)
                    mount.window.close()
                }
            }
            let window = mount?.window

            // The trace's own record: every selection change, and whether the
            // index still tiles a different text than the storage holds (the
            // mechanism's precondition). Printed, never asserted.
            let staleChanges = LockIsolated(0)
            let observer = NotificationCenter.default.addObserver(
                forName: NSTextView.didChangeSelectionNotification, object: h.textView, queue: nil
            ) { _ in
                MainActor.assumeIsolated {
                    let storage = h.textView.string.utf16.count
                    let tiled = h.model.index.documentLength
                    if storage != tiled { staleChanges.withValue { $0 += 1 } }
                    print("VX739-TRACE selection=\(NSStringFromRange(h.textView.selectedRange())) "
                        + "storage=\(storage) index=\(tiled)\(storage != tiled ? " STALE" : "") "
                        + "total=\(h.model.postWordCount.map(String.init) ?? "nil")")
                }
            }
            defer { NotificationCenter.default.removeObserver(observer) }

            let blockID = try h.storeSlots()[0].blockID
            let original = try #require(try h.storeSlots()[0].variantID)
            try #require(h.model.postWordCount == 11, "premise: 3 + 6 + 2 before any flip")
            // "click into block 1" — the caret at its end.
            h.textView.setSelectedRange(NSRange(location: Self.note[0].utf16.count, length: 0))
            try #require(h.model.caretBlockWordCount == 3, "premise: the caret is in block 1")

            let suite = "vx739-panel-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let panel = TakesViewModel(session: h.session, postID: h.postID, defaults: defaults)
            panel.writePanelBlockID = blockID
            defer { panel.teardown() }

            func deliver() throws {
                h.model.applyProjection(try h.storeSlots(), fromDelivery: true)
            }

            // Flip 1 — ＋ blank & choose: block 1 reads empty.
            await panel.newBlankTakeAsChosen(blockID: blockID)
            let blank = try #require(try h.storeSlots()[0].variantID)
            try #require(blank != original, "premise: the blank take is chosen")
            try deliver()
            await pumpUntil(window) { h.textView.string.hasPrefix("\n") }
            try #require(h.textView.string.hasPrefix("\n"), "premise: flip 1 landed on Write's surface")
            let truth1 = try trueTotal(h)
            print("VX739-SUMMARY flip=1 mounted=\(mounted) total=\(h.model.postWordCount ?? -1) truth=\(truth1) stale=\(staleChanges.value)")
            #expect(h.model.postWordCount == 8, "flip 1 (blank & choose): 0 + 6 + 2")
            #expect(h.model.postWordCount == truth1)

            // Flip 2 — ✓ the original: block 1 reads its words again.
            await panel.choose(blockID: blockID, variantID: original)
            try deliver()
            await pumpUntil(window) { h.textView.string.hasPrefix(Self.note[0]) }
            try #require(h.textView.string.hasPrefix(Self.note[0]), "premise: flip 2 landed on Write's surface")
            let truth2 = try trueTotal(h)
            print("VX739-SUMMARY flip=2 mounted=\(mounted) total=\(h.model.postWordCount ?? -1) truth=\(truth2) stale=\(staleChanges.value) block=\(h.model.caretBlockWordCount ?? -1)")
            #expect(h.model.postWordCount == 11,
                    "flip 2 (✓ the original): 3 + 6 + 2 — the sighting's \"12w in note\" is this line red")
            #expect(h.model.postWordCount == truth2)

            // Flip 3 — ✓ the blank again: the error, if any, would persist.
            await panel.choose(blockID: blockID, variantID: blank)
            try deliver()
            await pumpUntil(window) { h.textView.string.hasPrefix("\n") }
            try #require(h.textView.string.hasPrefix("\n"), "premise: flip 3 landed on Write's surface")
            let truth3 = try trueTotal(h)
            print("VX739-SUMMARY flip=3 mounted=\(mounted) total=\(h.model.postWordCount ?? -1) truth=\(truth3) stale=\(staleChanges.value)")
            #expect(h.model.postWordCount == 8,
                    "flip 3 (✓ the blank): 0 + 6 + 2 — the sighting's \"9w in note\" is this line red")
            #expect(h.model.postWordCount == truth3)
            #expect(panel.status == nil, "the panel's acts landed without a refusal")
        }
    }

    /// **The GUARD — typing still keeps the total live BETWEEN projections**
    /// (R11 — the live arm's whole reason to exist): a word typed at the end of
    /// block 2 moves the total at once, before any autosave or projection. The
    /// fix must not cost this. GREEN on both trees by design.
    @Test func aWordTypedIntoABlockMovesTheTotalAtOnce() async throws {
        try await withEditor(seedBlocks: Self.note) { h in
            try #require(h.model.postWordCount == 11, "premise: 3 + 6 + 2")
            let endOfBlock2 = Self.note[0].utf16.count + 1 + Self.note[1].utf16.count
            h.type(" Again", at: endOfBlock2)
            #expect(h.textView.string.contains("prose. Again"), "premise: the word landed in block 2")
            #expect(h.model.caretBlockWordCount == 7, "the caret block's own count")
            #expect(h.model.postWordCount == 12, "3 + 7 + 2, live, before any projection")
        }
    }
}
