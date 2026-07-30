//
//  FindAndReplaceTests.swift
//  VariorumTests
//
//  QoL round 2026-07-29, batch 3 — **L6**, her words: *"i also realized that
//  we need to ship some kind of text find and replace — i'm open to thinking
//  a little on what that will look like given that there's takes also, but at
//  least of the chosen text, because i noticed myself reaching for that and
//  not having it."*
//
//  ── THE RULE THESE PINS ARE WRITTEN UNDER ────────────────────────────────
//
//  Batch 1's adopted rule binds here exactly: *"a pin for a feature reached
//  by input must be driven through an input path, or it is a pin on our
//  arithmetic, not on her experience."* So nothing here calls
//  `gateFindReplace` directly. Every replacement is driven the way she drives
//  it — the find bar is shown through `performTextFinderAction`, its own
//  fields are filled, and its own Replace/All action is fired — and what is
//  asserted is what the STORE and the SURFACE hold afterwards.
//
//  FIND-PASTEBOARD DISCIPLINE (ruled): NSTextFinder's search string lives on
//  the machine-global find pasteboard, shared with every app on her Mac.
//  Every test that touches it saves it and puts it back.
//

import AppKit
import Foundation
import GRDB
import SwiftUI  // the shortcut pin reads KeyEquivalent
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("L6 — in-post find & replace (QoL batch 3)", .serialized)
struct FindAndReplaceTests {
    // MARK: - Harness

    private func pump(_ turns: Int = 6) {
        for _ in 0..<turns {
            RunLoop.main.run(until: Date().addingTimeInterval(0.03))
        }
    }

    private func withFindPasteboard<T>(_ body: () async throws -> T) async rethrows -> T {
        let board = NSPasteboard(name: .find)
        let saved = board.string(forType: .string)
        defer {
            board.clearContents()
            if let saved { board.setString(saved, forType: .string) }
        }
        return try await body()
    }

    private func mount(
        _ h: EditorHarness, height: CGFloat = 400, width: CGFloat = 700
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
        window.makeFirstResponder(h.textView)
        return (scrollView, window)
    }

    private func finderAction(_ action: NSTextFinder.Action, on textView: NSTextView) {
        let item = NSMenuItem()
        item.tag = action.rawValue
        textView.performTextFinderAction(item)
    }

    private func editableFields(in view: NSView?) -> [NSTextField] {
        guard let view else { return [] }
        var out: [NSTextField] = []
        func walk(_ v: NSView) {
            if let field = v as? NSTextField, field.isEditable { out.append(field) }
            for sub in v.subviews { walk(sub) }
        }
        walk(view)
        return out
    }

    /// Drives the find bar exactly as she does: show the replace interface,
    /// fill its own two fields, fire its own action — then let the deferred
    /// application land.
    private func replaceAll(
        _ needle: String, with replacement: String,
        harness h: EditorHarness, scrollView: NSScrollView
    ) async {
        let board = NSPasteboard(name: .find)
        board.clearContents()
        board.setString(needle, forType: .string)
        finderAction(.showReplaceInterface, on: h.textView)
        pump()
        let fields = editableFields(in: scrollView.findBarView)
        if fields.count >= 2 {
            fields[0].stringValue = needle
            fields[1].stringValue = replacement
            for field in fields.prefix(2) {
                field.sendAction(field.action, to: field.target)
            }
            pump()
        }
        finderAction(.replaceAll, on: h.textView)
        pump()
        await h.model.findReplaceTask?.value
        pump()
        await h.flush()
    }

    // MARK: - Pin 1 — the bar exists, and only where it can

    /// RED ON SHIPPED: `usesFindBar` appeared nowhere in the app before this
    /// batch (zero hits for `usesFindBar`/`NSTextFinder`/
    /// `performTextFinderAction` — the batch's own trace).
    @Test func theFindBarMountsInWritesScrollViewAndNowhereElse() async throws {
        try await withEditor(seedBlocks: ["the foo sits here"]) { h in
            try await withFindPasteboard {
                let (scrollView, window) = try mount(h)
                defer { window.orderOut(nil) }

                #expect(h.textView.usesFindBar, "Write's editor carries the bar")
                #expect(!h.textView.isIncrementalSearchingEnabled,
                        "incremental searching stays off in v1 (ruled — TEXTKIT2 §3)")

                finderAction(.showFindInterface, on: h.textView)
                pump()
                #expect(scrollView.isFindBarVisible)
                #expect(scrollView.findBarView != nil)

                // The inline editor — the book/spread/pool surface — never
                // grows one, which is what keeps a bar off a page of posts.
                let inline = EditorTextView.makeInlineEditor()
                #expect(!inline.usesFindBar)

                finderAction(.hideFindInterface, on: h.textView)
                pump()
            }
        }
    }

    // MARK: - Pin 2 — the canary, across the WHOLE family (26.5.2)

    /// The Phase 6 spike proved bar SHOW/HIDE only — it never set a search
    /// string, never matched, never replaced. This exercises the whole family
    /// on the current point release. A guard pin: no revert owns it.
    @Test func theCanaryStaysSilentAcrossTheWholeFindFamily() async throws {
        let saved = FallbackCanary.assertionHandler
        FallbackCanary.assertionHandler = { _ in }  // debug stops the world by design
        defer { FallbackCanary.assertionHandler = saved }

        try await withEditor(seedBlocks: [
            "the foo sits here", "another foo lives here", "a third foo at the end",
        ]) { h in
            try await withFindPasteboard {
                let (scrollView, window) = try mount(h)
                defer { window.orderOut(nil) }

                await replaceAll("foo", with: "BAR", harness: h, scrollView: scrollView)
                h.textView.setSelectedRange(NSRange(location: 0, length: 0))
                for action: NSTextFinder.Action in [
                    .showFindInterface, .setSearchString, .nextMatch, .previousMatch,
                    .showReplaceInterface, .replace, .hideFindInterface,
                ] {
                    finderAction(action, on: h.textView)
                    pump(2)
                }
                await h.model.findReplaceTask?.value
                pump()

                #expect(h.model.canaryMessage == nil, "no TK2→TK1 fallback message")
                #expect(h.textView.textLayoutManager != nil,
                        "still TextKit 2 — a downgrade nils this, notification or not")
            }
        }
    }

    // MARK: - Pin 3 — find, through the input path

    @Test func findNextSelectsTheNextMatch() async throws {
        try await withEditor(seedBlocks: [
            "the foo sits here", "another foo lives here",
        ]) { h in
            try await withFindPasteboard {
                let (_, window) = try mount(h)
                defer { window.orderOut(nil) }

                // Use Selection for Find (⌘E) — her own door — then step.
                let first = (h.textView.string as NSString).range(of: "foo")
                h.textView.setSelectedRange(first)
                finderAction(.setSearchString, on: h.textView)
                pump()
                h.textView.setSelectedRange(NSRange(location: first.upperBound, length: 0))
                finderAction(.nextMatch, on: h.textView)
                pump()

                let second = (h.textView.string as NSString)
                    .range(of: "foo", options: [], range: NSRange(
                        location: first.upperBound,
                        length: (h.textView.string as NSString).length - first.upperBound))
                #expect(h.textView.selectedRange() == second,
                        "⌘G landed on the next occurrence")
            }
        }
    }

    // MARK: - Pin 4 — a replace is an ORDINARY edit

    /// The L6 ruling's letter: replacements are autosaved, churn-accumulating,
    /// text-undoable edits — never a bulk write. RED ON SHIPPED (no replace
    /// path existed at all).
    @Test func aReplaceIsAnOrdinaryEdit() async throws {
        try await withEditor(seedBlocks: ["the foo sits here"]) { h in
            try await withFindPasteboard {
                let (scrollView, window) = try mount(h)
                defer { window.orderOut(nil) }

                let churnBefore = try await h.database.read { db in
                    try Double.fetchOne(
                        db, sql: "SELECT churn_accumulator FROM container WHERE id = ?",
                        arguments: [h.postID]) ?? 0
                }
                await replaceAll("foo", with: "BAR", harness: h, scrollView: scrollView)

                #expect(h.textView.string == "the BAR sits here", "the surface")
                let store = try h.storeSlots().map { $0.text ?? "" }
                #expect(store == ["the BAR sits here"], "and the STORE — autosave ran")
                let churnAfter = try await h.database.read { db in
                    try Double.fetchOne(
                        db, sql: "SELECT churn_accumulator FROM container WHERE id = ?",
                        arguments: [h.postID]) ?? 0
                }
                #expect(churnAfter > churnBefore, "churn accumulated, exactly as typing does")

                h.textView.undoManager?.undo()
                pump()
                #expect(h.textView.string == "the foo sits here",
                        "⌘Z undoes it — the ordinary text-undo stack")
            }
        }
    }

    // MARK: - Pin 5 — Replace All

    /// RED ON SHIPPED, and MEASURED so: on the pre-batch code the multi-range
    /// delegate door refused the whole gesture (`"Multi-range edits aren't
    /// supported yet."`) and the text did not change — M1/M2, this batch's
    /// step-1 run, on the real find path.
    @Test func replaceAllReplacesEveryMatchAcrossBlocks() async throws {
        try await withEditor(seedBlocks: [
            "the foo sits here", "another foo lives here", "a third foo at the end",
        ]) { h in
            try await withFindPasteboard {
                let (scrollView, window) = try mount(h)
                defer { window.orderOut(nil) }

                await replaceAll("foo", with: "BAR", harness: h, scrollView: scrollView)

                let store = try h.storeSlots().map { $0.text ?? "" }
                #expect(store == [
                    "the BAR sits here", "another BAR lives here", "a third BAR at the end",
                ], "every match, in every block, in the STORE")
                #expect(h.model.statusMessage == "Replaced 3 matches.", "and it says so")
                // The block structure is untouched: three blocks in, three out.
                #expect(store.count == 3)
            }
        }
    }

    /// A Replace All is ONE act, so it undoes as one.
    @Test func replaceAllUndoesAsOneAction() async throws {
        try await withEditor(seedBlocks: [
            "the foo sits here", "another foo lives here", "a third foo at the end",
        ]) { h in
            try await withFindPasteboard {
                let (scrollView, window) = try mount(h)
                defer { window.orderOut(nil) }
                await replaceAll("foo", with: "BAR", harness: h, scrollView: scrollView)

                h.textView.undoManager?.undo()
                pump()
                #expect(h.textView.string
                    == "the foo sits here\nanother foo lives here\na third foo at the end",
                    "one ⌘Z restores all three")
            }
        }
    }

    // MARK: - Pin 6 — THE SAFETY CORE

    /// **RED ON SHIPPED for the reason that matters.** A match spanning an
    /// inter-block separator does not refuse on the shipped editor: it routes
    /// to `planCrossBlockEdit`, which MERGES the blocks and applies the edit
    /// to the merged buffer. That contract (2026-07-09) was ratified for a
    /// deliberate hand-made selection; a find-driven sweep must never
    /// restructure her post. The block COUNT is the assertion.
    @Test func aMatchAcrossABlockSeamRefusesInsteadOfMerging() async throws {
        try await withEditor(seedBlocks: ["ends here", "starts there"]) { h in
            try await withFindPasteboard {
                let (scrollView, window) = try mount(h)
                defer { window.orderOut(nil) }

                // "here\nstarts" spans the separator — the one shape that
                // could restructure the post.
                await replaceAll("here\nstarts", with: "X", harness: h, scrollView: scrollView)

                let store = try h.storeSlots().map { $0.text ?? "" }
                #expect(store == ["ends here", "starts there"],
                        "nothing replaced, nothing merged")
                #expect(store.count == 2, "STILL TWO BLOCKS — the safety core")
                #expect(h.model.statusMessage?.contains("crosses a block boundary") == true,
                        "and it says why, naming the way out")
            }
        }
    }

    // MARK: - Pin 7 — CHARACTERIZATION (green on both sides): the flag does not leak

    /// The proof that pin 6 changed find-replace and NOTHING else: a TYPED
    /// cross-block edit still takes the ratified merge-then-edit path
    /// (2026-07-09, single×single). Green before this batch and after it —
    /// that is the point.
    @Test func aTypedCrossBlockEditStillMergesThenEdits() async throws {
        try await withEditor(seedBlocks: ["ends here", "starts there"]) { h in
            #expect(h.textView.isFindReplacing == false, "no find in sight")
            let span = (h.textView.string as NSString).range(of: "here\nstarts")
            h.replace(span, with: "X")
            await h.flush()

            let store = try h.storeSlots().map { $0.text ?? "" }
            #expect(store.count == 1, "typed: the halves JOIN — merge-then-edit")
            #expect(store == ["ends X there"])
        }
    }

    // MARK: - Pin 8 — the seal (CHARACTERIZATION of two PRE-EXISTING doors)

    /// Neither door is built by this batch, and the pin says so: AppKit
    /// validates replace off through `isEditable` (`NSTextFinderClient`), and
    /// `shouldChangeText` refuses at the seal. Find still WORKS under seal —
    /// viewing is not authoring, the Show Takes posture.
    @Test func aSealedPostFindsButNeverReplaces() async throws {
        try await withEditor(seedBlocks: ["the foo sits here"]) { h in
            try await withFindPasteboard {
                let (scrollView, window) = try mount(h)
                defer { window.orderOut(nil) }

                try h.session.operations.lockPost(h.postID)
                try h.reload()
                pump()
                #expect(h.textView.isEditable == false,
                        "the seal disarms replace at AppKit's own validation")

                await replaceAll("foo", with: "BAR", harness: h, scrollView: scrollView)
                let store = try h.storeSlots().map { $0.text ?? "" }
                #expect(store == ["the foo sits here"], "not one byte")

                // …and finding still works.
                h.textView.setSelectedRange(NSRange(location: 0, length: 0))
                let match = (h.textView.string as NSString).range(of: "foo")
                finderAction(.nextMatch, on: h.textView)
                pump()
                #expect(h.textView.selectedRange() == match, "find is not authoring")
            }
        }
    }

    // MARK: - Pin 9 — a locked take blocks the gesture and says why

    @Test func aLockedTakeBlocksTheReplaceAndSaysWhy() async throws {
        try await withEditor(seedBlocks: [
            "the foo sits here", "another foo lives here",
        ]) { h in
            try await withFindPasteboard {
                let (scrollView, window) = try mount(h)
                defer { window.orderOut(nil) }

                let slots = try h.storeSlots()
                try h.session.operations.lockVariant(try #require(slots[0].variantID))
                try h.reload()
                pump()

                await replaceAll("foo", with: "BAR", harness: h, scrollView: scrollView)

                let store = try h.storeSlots().map { $0.text ?? "" }
                #expect(store == ["the foo sits here", "another foo lives here"],
                        "ALL-OR-NOTHING: the unlocked match is not replaced either")
                #expect(h.model.statusMessage?.contains("locked take") == true,
                        "and the refusal names the cause")
                #expect(h.model.statusMessage?.contains("1 of 2") == true,
                        "and counts")
            }
        }
    }

    // MARK: - Pin 11 — the find bar and the typewriter room

    /// Batch 1 grew the DOCUMENT to carry the room, with an `appliedHeight`
    /// gate because AppKit hands our own output back to `setFrameSize` (a
    /// two-line post reached 1,007 pt instead of 548 before that gate
    /// existed). The find bar is a new re-tiling occasion on exactly that
    /// path — this is the cross-batch tripwire.
    @Test func showingTheFindBarDoesNotCompoundTheDocumentFrame() async throws {
        let paragraphs = (0..<40).map { "Paragraph \($0) with a handful of ordinary words." }
        try await withEditor(seedBlocks: paragraphs) { h in
            try await withFindPasteboard {
                let (scrollView, window) = try mount(h)
                defer { window.orderOut(nil) }

                let frame0 = h.textView.frame.height
                for _ in 0..<3 {
                    finderAction(.showFindInterface, on: h.textView)
                    pump()
                    scrollView.tile()
                    window.layoutIfNeeded()
                    pump()
                    finderAction(.hideFindInterface, on: h.textView)
                    pump()
                    scrollView.tile()
                    window.layoutIfNeeded()
                    pump()
                }
                #expect(h.textView.frame.height == frame0,
                        "three show/hide cycles leave the document exactly where it was")
            }
        }
    }

    // MARK: - Pin 13 — the door is grey where it cannot act

    @Test func theFindDoorIsGreyWhereverNoScrollingEditorIsAttached() {
        let detail = CapabilityContext(
            mode: .write, writeEditorAttached: true, writeEditorOwnsScrollView: true)
        // The book/spread/pool inline editor: ATTACHED, but with no scroll
        // view of its own — and it sits inside the BOOK's scroll view, which
        // is `NSTextFinderBarContainer`-conforming, so an ungated door would
        // hang a bar above every post on the page.
        let inlineBook = CapabilityContext(mode: nil, writeEditorAttached: true)
        for id in [CapabilityID.findInPost, .findAndReplace, .findNext,
                   .findPrevious, .useSelectionForFind] {
            #expect(CapabilityRegistry.isEnabled(id, in: detail), "\(id) acts in the post editor")
            #expect(!CapabilityRegistry.isEnabled(id, in: inlineBook),
                    "\(id): honestly grey on the book's inline editor")
            #expect(!CapabilityRegistry.isEnabled(id, in: CapabilityContext(mode: .takes)),
                    "\(id): v1 is the full-document surface (13e owns the takes-aware act)")
            #expect(!CapabilityRegistry.isEnabled(id, in: CapabilityContext(mode: nil)),
                    "\(id): nothing open, honestly grey")
        }
    }

    /// The keys are declared where keys are declared (P-1), and the family is
    /// distinguishable from ⌘K by its words.
    @Test func theFindFamilyDeclaresItsKeysAndItsWords() {
        #expect(CapabilityRegistry.capability(.findInPost).shortcutLabel == "⌘F")
        #expect(CapabilityRegistry.capability(.findAndReplace).shortcutLabel == "⌥⌘F")
        #expect(CapabilityRegistry.capability(.findNext).shortcutLabel == "⌘G")
        #expect(CapabilityRegistry.capability(.findPrevious).shortcutLabel == "⇧⌘G")
        #expect(CapabilityRegistry.capability(.useSelectionForFind).shortcutLabel == "⌘E")
        #expect(EditorCommands.keyEquivalent(for: .findInPost)?.0 == "f")
        #expect(EditorCommands.keyEquivalent(for: .findNext)?.0 == "g")
        #expect(CapabilityRegistry.capability(.findInPost).verb == "Find in Post…")
        #expect(CapabilityRegistry.capability(.findAnything).verb == "Find Anything…",
                "the two never read as rivals: one searches the library, one the post")
    }

    // MARK: - The gate's pure half

    @Test func theCountingRefusalNamesEveryCause() {
        #expect(FindReplaceGate.refusal(
            total: 12, blockers: [.crossesBlockBoundary, .crossesBlockBoundary, .lockedTake])
            == "Nothing was replaced — 3 of 12 matches can't be: "
            + "2 cross a block boundary, 1 is in a locked take.")
        #expect(FindReplaceGate.refusal(total: 2, blockers: [.unsyncedBlock])
            == "Nothing was replaced — 1 of 2 matches can't be: 1 is in an unsynced block.")
        #expect(FindReplaceGate.refusal(single: .crossesBlockBoundary).contains("⌘⇧M"))
        #expect(FindReplaceGate.replaced(1) == "Replaced 1 match.")
        #expect(FindReplaceGate.replaced(4) == "Replaced 4 matches.")
    }
}
