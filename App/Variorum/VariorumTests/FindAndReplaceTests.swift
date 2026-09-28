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

    /// **THE STRONGER ARM (the standing rule: a revert that goes green earns
    /// one).** The first cut of R-A — deleting the `isFindReplacing` guard in
    /// `shouldChangeText` — left every pin GREEN, because the gate's
    /// pre-check refuses a cross-seam match before anything is applied, so
    /// nothing ever reached the guard. That made the guard look like
    /// unreachable defensive code (13d judgment call 1's drift class), and
    /// the honest choice was to either delete it or REACH it.
    ///
    /// It is reachable, and this is the race it exists for: the gate plans
    /// against the document as it stands, then defers (it is inside AppKit's
    /// finder call — rewriting storage there would be re-entrant). If the
    /// text moves in that window, a range checked as in-block can straddle a
    /// seam by the time it is applied. Without the guard, `shouldChangeText`
    /// hands that range to `planCrossBlockEdit` and MERGES her blocks.
    ///
    /// Deterministic by construction: a `Task { @MainActor }` created from
    /// main-actor code cannot run until the current synchronous work yields,
    /// so the edit below lands strictly between the plan and its application.
    ///
    /// **Layering since the cold review's fix pass (F-1):** the substring
    /// VALVE in `applyFindReplace` now catches an ordinary drift BEFORE this
    /// guard — the bytes at the drifted range no longer match what the finder
    /// approved, so the range is skipped-and-counted and the guard is never
    /// reached in this choreography. The guard remains the BELT for the one
    /// shape the valve cannot see: byte-identical text whose BLOCK membership
    /// moved (a structural change landing in the window). The discriminating
    /// reverts therefore changed with the valve: valve alone removed → the
    /// in-block drift pin below goes red while this one stays green; valve
    /// AND guard removed → THIS pin goes red (its original red state,
    /// re-verified at the fix pass).
    @Test func aPlannedMatchThatDriftsAcrossASeamRefusesInsteadOfMerging() async throws {
        try await withEditor(seedBlocks: ["aaaaaa foo", "bbb"]) { h in
            try await withFindPasteboard {
                let (scrollView, window) = try mount(h)
                defer { window.orderOut(nil) }

                // Plan the replacement of " foo" at {6,4} — the tail of block
                // 0. The leading space matters: after the shift below the range
                // has to cover TEXT ON BOTH SIDES of the seam, not just the
                // separator, or `planCrossBlockEdit` declines on its own
                // `touched.count >= 2` guard and the merge it would perform is
                // never even reached (the first sharpening of this arm).
                let board = NSPasteboard(name: .find)
                board.clearContents()
                board.setString(" foo", forType: .string)
                finderAction(.showReplaceInterface, on: h.textView)
                pump()
                let fields = editableFields(in: scrollView.findBarView)
                #expect(fields.count >= 2, "the bar's own two fields")
                fields[0].stringValue = " foo"
                fields[1].stringValue = "BAR"
                for field in fields.prefix(2) {
                    field.sendAction(field.action, to: field.target)
                }
                pump()
                finderAction(.replaceAll, on: h.textView)
                // NO pump: the deferred application has not run yet.

                // Shorten block 0 by exactly 3, so the planned {6,4} now
                // straddles the seam: "aaa foo\nbbb", where {6,4} covers
                // "o\nbb" — block 0's last character, the separator, and two
                // characters of block 1. That is the shape `planCrossBlockEdit`
                // accepts, and merges.
                h.replace(NSRange(location: 0, length: 3), with: "")

                await h.model.findReplaceTask?.value
                pump()
                await h.flush()

                let store = try h.storeSlots().map { $0.text ?? "" }
                #expect(store.count == 2,
                        "STILL TWO BLOCKS — the drifted range refused instead of merging")
                #expect(store == ["aaa foo", "bbb"], "and nothing was rewritten")
            }
        }
    }

    /// **Cold review F-1 (MAJOR) — RED ON THE PRE-FIX CODE, and the red state
    /// is silent text corruption.** The same deferred window as the drift pin
    /// above, but the drifted range stays INSIDE one block: on the pre-fix
    /// code the only re-check was the document-length bound, so the
    /// replacement applied to whatever characters sat at those offsets NOW —
    /// text that never matched the search, silently rewritten and autosaved.
    /// The substring valve skips it and the one final line counts it.
    @Test func aPlannedMatchThatDriftsInsideABlockIsSkippedNotMisapplied() async throws {
        try await withEditor(seedBlocks: ["aaaaaa foo bar"]) { h in
            try await withFindPasteboard {
                let (scrollView, window) = try mount(h)
                defer { window.orderOut(nil) }

                // Plan the replacement of " foo" at {6,4}.
                let board = NSPasteboard(name: .find)
                board.clearContents()
                board.setString(" foo", forType: .string)
                finderAction(.showReplaceInterface, on: h.textView)
                pump()
                let fields = editableFields(in: scrollView.findBarView)
                #expect(fields.count >= 2, "the bar's own two fields")
                fields[0].stringValue = " foo"
                fields[1].stringValue = "BAR"
                for field in fields.prefix(2) {
                    field.sendAction(field.action, to: field.target)
                }
                pump()
                finderAction(.replaceAll, on: h.textView)
                // NO pump: the deferred application has not run yet.

                // Shorten the block by exactly 3, so the planned {6,4} slides
                // to different IN-BLOCK text: "aaa foo bar", where {6,4}
                // covers "o ba" — a range the length bound accepts and the
                // seam guard never sees. The pre-fix code replaced it,
                // yielding "aaa foBARr".
                h.replace(NSRange(location: 0, length: 3), with: "")

                await h.model.findReplaceTask?.value
                pump()
                await h.flush()

                let store = try h.storeSlots().map { $0.text ?? "" }
                #expect(store == ["aaa foo bar"],
                        "the drifted range is SKIPPED — never applied to the text now there")
                #expect(h.model.statusMessage?.contains("moved before") == true,
                        "and the one final line counts what moved: \(h.model.statusMessage ?? "nil")")
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
            #expect(!CapabilityRegistry.isEnabled(id, in: CapabilityContext(mode: nil)),
                    "\(id): nothing open, honestly grey")
        }
        // **18l-c U7 — THE TAKES ARM, RE-ARMED AS HER RULING** (named in the
        // unit's record). This arm asserted *"v1 is the full-document surface
        // (13e owns the takes-aware act)"* for all five; her R-18l-6 made the
        // FIND itself a Takes act (the board's own bar), and her R-18l-9 kept
        // REPLACE Write's. So the find half acts in Takes — in the mode AND on
        // a board mounted with no detail around it (the book spread) — and
        // the replace half and ⌘E stay honestly grey there.
        let takesMode = CapabilityContext(mode: .takes)
        let spreadBoard = CapabilityContext(mode: nil, takesBoardAttached: true)
        for id in [CapabilityID.findInPost, .findNext, .findPrevious] {
            #expect(CapabilityRegistry.isEnabled(id, in: takesMode), "\(id): Takes finds (R-18l-6)")
            #expect(CapabilityRegistry.isEnabled(id, in: spreadBoard),
                    "\(id): a mounted board finds wherever it is mounted")
        }
        for id in [CapabilityID.findAndReplace, .useSelectionForFind, .replaceAllInEveryTake] {
            #expect(!CapabilityRegistry.isEnabled(id, in: takesMode),
                    "\(id): find-only v1 — replace stays Write's (R-18l-9)")
            #expect(!CapabilityRegistry.isEnabled(id, in: spreadBoard))
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
        #expect(CapabilityRegistry.capability(.findInPost).verb == "Find in Note…")
        #expect(CapabilityRegistry.capability(.findAnything).verb == "Find Anything…",
                "the two never read as rivals: one searches the library, one the post")
    }

    // MARK: - The Edit menu itself (cold review F-5 — the probe, kept as a pin)

    /// **F-5's decisive fact, measured in the test host — which IS the real
    /// app with its real SwiftUI-built main menu.** The finding: SwiftUI's
    /// standard `.textEditing` block may ship its own system Find submenu,
    /// which the batch's collision sweep (over the app's OWN
    /// `keyboardShortcut(` declarations) could never see; if present, Edit
    /// would carry TWO Find submenus with five duplicated keys, the system
    /// one bypassing the registry's gating. This walks the REAL Edit menu,
    /// prints it whole for the record, and pins exactly one Find submenu —
    /// so a future SwiftUI default change fails a test instead of quietly
    /// doubling her menu.
    @Test func theEditMenuCarriesExactlyOneFindSubmenu() throws {
        let mainMenu = try #require(NSApp.mainMenu,
                                    "the test host runs the real app, menu included")
        let edit = try #require(
            mainMenu.items.first { $0.title == "Edit" }?.submenu,
            "the Edit menu exists")
        for item in edit.items {
            let kids = item.submenu?.items
                .filter { !$0.isSeparatorItem }
                .map { "\($0.title)\($0.keyEquivalent.isEmpty ? "" : " ⌘\($0.keyEquivalent)")" }
                .joined(separator: " · ") ?? ""
            print("F-5 Edit ▸ \(item.isSeparatorItem ? "————" : item.title)"
                + (item.submenu == nil ? "" : "  [\(kids)]"))
        }
        let findSubmenus = edit.items.filter { $0.submenu != nil && $0.title == "Find" }
        #expect(findSubmenus.count == 1,
                """
                the Edit menu carries exactly ONE Find submenu \
                (saw \(findSubmenus.count)) — a second would be the system \
                .textEditing block's, with five duplicated key equivalents \
                routing performTextFinderAction: around the registry
                """)
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
        // Cold review F-6: a desync or a still-forming paragraph carries its
        // OWN cause — never the cross-boundary copy, never the ⌘⇧M advice
        // (merging is the wrong way out of either).
        #expect(FindReplaceGate.refusal(total: 3, blockers: [.editorResyncing, .stillFormingParagraph])
            == "Nothing was replaced — 2 of 3 matches can't be: "
            + "1 is in text still re-syncing, 1 touches the paragraph still being written.")
        #expect(!FindReplaceGate.refusal(single: .editorResyncing).contains("⌘⇧M"))
        #expect(!FindReplaceGate.refusal(single: .editorResyncing).contains("block boundary"))
        #expect(!FindReplaceGate.refusal(single: .stillFormingParagraph).contains("⌘⇧M"))
        #expect(FindReplaceGate.replaced(1) == "Replaced 1 match.")
        #expect(FindReplaceGate.replaced(4) == "Replaced 4 matches.")
        // F-1 + F-7: the ONE apply-time completion voice.
        #expect(FindReplaceGate.completion(applied: 3, moved: 0, blocked: 0)
            == "Replaced 3 matches.")
        #expect(FindReplaceGate.completion(applied: 2, moved: 1, blocked: 0)
            == "Replaced 2 of 3 — 1 moved before it could be.")
        #expect(FindReplaceGate.completion(applied: 1, moved: 2, blocked: 1)
            == "Replaced 1 of 4 — 2 moved before they could be, "
            + "1 can no longer be replaced where it landed.")
    }
}
