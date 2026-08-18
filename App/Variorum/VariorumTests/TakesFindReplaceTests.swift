//
//  TakesFindReplaceTests.swift
//  VariorumTests
//
//  Phase 13e, batch 7 — **E9: the takes-aware find & replace** (the
//  KnownIssues row *"Find & replace — the takes-aware half"*, owner 13e;
//  her QoL-round words, recorded at the L6 ruling: *"let's record that a
//  future phase will for sure need to handle takes find and replace and
//  whole library search"* — the LIBRARY half is the master plan's own
//  **Whole-library text search** row and is deliberately NOT here).
//
//  E9 IS A FEATURE, so its pins are FEATURE pins (the batch-2/3
//  convention: no red-on-old is owed for a door that did not exist). What
//  they hold is the shape the row RULED — the Delete-in-Every-Take
//  apply-and-report shape: matching takes edited in ONE transaction under
//  ONE undo entry, skipped takes named WITH their reason, never silently.
//
//  THE DRIVEN PINS GO THROUGH THE REAL FIND BAR (the QoL round's own
//  rule, kept: *"a pin for a feature reached by input must be driven
//  through an input path, or it is a pin on our arithmetic, not on her
//  experience"*): the bar is shown through `performTextFinderAction`, its
//  own two fields are filled, and the menu act is fired — nothing calls
//  `gateFindReplace` or the controller directly.
//
//  FIND-PASTEBOARD DISCIPLINE (ruled, QoL batch 3): the finder's search
//  string lives on the machine-global find pasteboard, shared with every
//  app on her Mac. Every test that touches it saves it and puts it back.
//

import AppKit
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The rule, pure

@Suite("13e E9 — the takes-aware replace rule (pure)")
struct TakesReplaceRuleTests {
    private func match(_ location: Int, _ length: Int, _ needle: String, _ replacement: String)
        -> TakesReplacePlan.Match {
        TakesReplacePlan.Match(
            range: NSRange(location: location, length: length),
            needle: needle, replacement: replacement)
    }

    @Test func matchesApplyLastFirstSoEarlierOffsetsStayValid() {
        let text = "cat and cat and cat"
        let result = TakesReplacePlan.applyMatches(
            [match(0, 3, "cat", "dog"), match(8, 3, "cat", "dog"), match(16, 3, "cat", "dog")],
            to: text)
        #expect(result.text == "dog and dog and dog")
        // Churn is inserted + deleted, equal weight (AppSpec §10).
        #expect(result.charDelta == 18)
    }

    @Test func aGestureThatCoveredEveryOccurrenceCarriesAllOfThem() {
        let visible = "cat and cat"
        let groups = TakesReplacePlan.groups(
            from: [match(0, 3, "cat", "dog"), match(8, 3, "cat", "dog")], visibleText: visible)
        #expect(groups.count == 1)
        #expect(groups[0].coversEveryOccurrence,
                "two matches, two occurrences — she asked for all of them")

        let outcome = TakesReplacePlan.apply(groups, toOtherTake: "cat, cat, and a cat")
        guard case .edited(let text, _, let replacements) = outcome else {
            Issue.record("expected an edit, got \(outcome)")
            return
        }
        #expect(text == "dog, dog, and a dog")
        #expect(replacements == 3, "every occurrence there, not a count copied from the visible take")
    }

    /// The #10 discipline, exactly as `deleteInEveryTake` uses it: when the
    /// gesture did NOT cover every occurrence, only an unambiguous one may
    /// be carried — the rest is a guess, and a guess is what gets reported.
    @Test func aPartialGestureOnlyReachesAnUnambiguousOccurrence() {
        let visible = "cat and cat"
        let groups = TakesReplacePlan.groups(
            from: [match(0, 3, "cat", "dog")], visibleText: visible)
        #expect(!groups[0].coversEveryOccurrence, "one match of two occurrences")

        guard case .edited(let text, _, let replacements) =
            TakesReplacePlan.apply(groups, toOtherTake: "one cat here") else {
            Issue.record("a single occurrence is unambiguous")
            return
        }
        #expect(text == "one dog here")
        #expect(replacements == 1)

        #expect(TakesReplacePlan.apply(groups, toOtherTake: "cat and cat") == .ambiguous,
                "two occurrences and no instruction to take both — skipped, not guessed")
    }

    @Test func aTakeWithoutThePhraseIsNoMatch() {
        let groups = TakesReplacePlan.groups(
            from: [match(0, 3, "cat", "dog")], visibleText: "cat")
        #expect(TakesReplacePlan.apply(groups, toOtherTake: "nothing of the sort") == .noMatch)
    }

    /// Groups run in order against the EVOLVING text — what a person doing
    /// it by hand would get, and the reason the rule counts occurrences per
    /// group rather than once up front.
    @Test func groupsRunSequentiallyAgainstTheEvolvingText() {
        let groups = [
            TakesReplacePlan.Group(needle: "a", replacement: "b", coversEveryOccurrence: true),
            TakesReplacePlan.Group(needle: "b", replacement: "c", coversEveryOccurrence: true),
        ]
        guard case .edited(let text, _, _) =
            TakesReplacePlan.apply(groups, toOtherTake: "a b") else {
            Issue.record("expected an edit")
            return
        }
        #expect(text == "c c")
    }

    @Test func occurrencesCountsNonOverlappingLiterals() {
        #expect(TakesReplacePlan.occurrences(of: "aa", in: "aaaa") == 2)
        #expect(TakesReplacePlan.occurrences(of: "aa", in: "aaa") == 1)
        #expect(TakesReplacePlan.occurrences(of: "", in: "aaa") == 0)
        #expect(TakesReplacePlan.occurrences(of: "Cat", in: "cat Cat") == 1,
                "literal, case-sensitive — the needle is the text the finder MATCHED")
    }

    /// 13g F-1/F-2: the stored text IS the markdown, so a replacement is
    /// ordinary content. The rule neither invents syntax nor strips it, and
    /// a needle that lands inside a marker run is carried verbatim.
    @Test func markdownCarryingTextIsOrdinaryContentToThisRule() {
        let visible = "**bold cat** and `cat`"
        let groups = TakesReplacePlan.groups(
            from: [
                TakesReplacePlan.Match(
                    range: NSRange(location: 7, length: 3), needle: "cat", replacement: "dog"),
                TakesReplacePlan.Match(
                    range: NSRange(location: 18, length: 3), needle: "cat", replacement: "dog"),
            ],
            visibleText: visible)
        guard case .edited(let text, _, _) =
            TakesReplacePlan.apply(groups, toOtherTake: "**bold cat** and `cat`") else {
            Issue.record("expected an edit")
            return
        }
        #expect(text == "**bold dog** and `dog`",
                "markers survive byte-for-byte — display == stored is untouched")
    }
}

// MARK: - The act, driven through the shipped find bar

@MainActor
@Suite("13e E9 — Replace All in Every Take", .serialized)
struct TakesFindReplaceTests {
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

    private func mount(_ h: EditorHarness) throws -> (NSScrollView, NSWindow) {
        let scrollView = try #require(h.textView.enclosingScrollView)
        scrollView.frame = NSRect(x: 0, y: 0, width: 700, height: 400)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 400),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = NSView(frame: NSRect(x: 0, y: 0, width: 700, height: 400))
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

    /// Fills the SHIPPED bar's own two fields, then fires the given act —
    /// the takes act and the ordinary Replace All differ only in which menu
    /// item is pressed, which is exactly E9's claim about being a scope.
    private func fillBarThen(
        _ act: () -> Void, needle: String, replacement: String,
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
        act()
        pump()
        await h.model.findReplaceTask?.value
        pump()
        await h.flush()
    }

    /// The fan of the post's only block, by store order.
    private func fanTexts(_ h: EditorHarness) throws -> [String] {
        let blockID = try #require(try h.storeSlots().first?.blockID)
        return try h.database.read { db in
            try Queries.blockFan(db, blockID: blockID).map(\.workingText)
        }
    }

    private func seedFannedPost(_ h: EditorHarness, alternates: [String]) throws -> String {
        let blockID = try #require(try h.storeSlots().first?.blockID)
        let chosen = try #require(try h.storeSlots().first?.variantID)
        for text in alternates {
            let take = try h.session.operations.branchVariant(blockID, from: chosen)
            try h.session.operations.autosave(take.id, text: text, charDelta: text.count)
        }
        try h.reload()
        return blockID
    }

    // MARK: - The act

    /// The whole point, end to end: the note shows one take, the block
    /// holds two, and the replacement reaches BOTH — in one transaction,
    /// under ONE undo entry, reported.
    @Test func replaceAllInEveryTakeReachesTheTakeTheNoteDoesNotShow() async throws {
        try await withEditor(seedBlocks: ["The cat sat."]) { h in
            _ = try seedFannedPost(h, alternates: ["A different cat entirely."])
            let (scrollView, window) = try mount(h)
            defer { window.orderOut(nil); window.close() }

            await withFindPasteboard {
                await fillBarThen(
                    { h.model.performFind(.replaceAllInEveryTake) },
                    needle: "cat", replacement: "dog", harness: h, scrollView: scrollView)
            }

            #expect(try fanTexts(h).sorted()
                    == ["A different dog entirely.", "The dog sat."],
                    "both takes carry the replacement — the unseen one included")
            #expect(h.model.statusMessage?.contains("Replaced 2 matches in 2 takes") == true,
                    "the apply-and-report line: \(h.model.statusMessage ?? "nil")")
            #expect(h.session.undoStack.depth == 1, "ONE entry for the act she performed")
            #expect(h.session.undoStack.topLabel == "Replace in Every Take")
        }
    }

    /// The attribution half, and the proof the scope is ONE-SHOT: the
    /// ordinary Replace All still touches only the take the note shows.
    @Test func theOrdinaryReplaceAllStillTouchesOnlyTheShownTake() async throws {
        try await withEditor(seedBlocks: ["The cat sat."]) { h in
            _ = try seedFannedPost(h, alternates: ["A different cat entirely."])
            let (scrollView, window) = try mount(h)
            defer { window.orderOut(nil); window.close() }

            await withFindPasteboard {
                await fillBarThen(
                    { self.finderAction(.replaceAll, on: h.textView) },
                    needle: "cat", replacement: "dog", harness: h, scrollView: scrollView)
            }

            #expect(try fanTexts(h).sorted()
                    == ["A different cat entirely.", "The dog sat."],
                    "the unseen take is untouched by the shipped act")
        }
    }

    /// Skipped AND NAMED, never silently — the row's ruled shape.
    @Test func aLockedTakeIsSkippedAndNamed() async throws {
        try await withEditor(seedBlocks: ["The cat sat."]) { h in
            let blockID = try seedFannedPost(h, alternates: ["Another cat."])
            let locked = try #require(try await h.database.read { db in
                try Queries.blockFan(db, blockID: blockID).last
            })
            try h.session.operations.setTakeLabel(locked.id, label: "the locked one")
            try h.session.operations.lockVariant(locked.id)
            let (scrollView, window) = try mount(h)
            defer { window.orderOut(nil); window.close() }

            await withFindPasteboard {
                await fillBarThen(
                    { h.model.performFind(.replaceAllInEveryTake) },
                    needle: "cat", replacement: "dog", harness: h, scrollView: scrollView)
            }

            #expect(try fanTexts(h).contains("Another cat."),
                    "a locked take is never edited around its lock")
            #expect(h.model.statusMessage?.contains("(locked)") == true,
                    "…and it is NAMED: \(h.model.statusMessage ?? "nil")")
            #expect(h.model.statusMessage?.contains("the locked one") == true)
        }
    }

    /// Archived takes are out of the fan and out of the act — and said so,
    /// because "it did nothing to that one" is exactly what she cannot see.
    @Test func anArchivedTakeIsSkippedAndNamed() async throws {
        try await withEditor(seedBlocks: ["The cat sat."]) { h in
            let blockID = try seedFannedPost(h, alternates: ["Archived cat."])
            let archived = try #require(try await h.database.read { db in
                try Queries.blockFan(db, blockID: blockID).last
            })
            try h.session.operations.archiveVariant(archived.id)
            let (scrollView, window) = try mount(h)
            defer { window.orderOut(nil); window.close() }

            await withFindPasteboard {
                await fillBarThen(
                    { h.model.performFind(.replaceAllInEveryTake) },
                    needle: "cat", replacement: "dog", harness: h, scrollView: scrollView)
            }

            #expect(try fanTexts(h).contains("Archived cat."))
            #expect(h.model.statusMessage?.contains("(archived)") == true,
                    "\(h.model.statusMessage ?? "nil")")
        }
    }

    /// A block with no other take is not a refusal — the act degrades to
    /// the ordinary replace and says what it did (fire-and-DO).
    @Test func aBlockWithNoOtherTakeStillReplacesAndSaysSo() async throws {
        try await withEditor(seedBlocks: ["The cat sat."]) { h in
            let (scrollView, window) = try mount(h)
            defer { window.orderOut(nil); window.close() }

            await withFindPasteboard {
                await fillBarThen(
                    { h.model.performFind(.replaceAllInEveryTake) },
                    needle: "cat", replacement: "dog", harness: h, scrollView: scrollView)
            }

            #expect(try fanTexts(h) == ["The dog sat."])
            #expect(h.model.statusMessage?.contains("Replaced 1 match in 1 take") == true,
                    "\(h.model.statusMessage ?? "nil")")
        }
    }

    /// Undo returns every take the act touched — one entry, both buffers.
    @Test func undoReturnsEveryTakeTheActTouched() async throws {
        try await withEditor(seedBlocks: ["The cat sat."]) { h in
            _ = try seedFannedPost(h, alternates: ["Another cat."])
            let (scrollView, window) = try mount(h)
            defer { window.orderOut(nil); window.close() }

            await withFindPasteboard {
                await fillBarThen(
                    { h.model.performFind(.replaceAllInEveryTake) },
                    needle: "cat", replacement: "dog", harness: h, scrollView: scrollView)
            }
            #expect(try fanTexts(h).sorted() == ["Another dog.", "The dog sat."])

            let stack = h.session.undoStack
            try await h.session.runner.run { ops in _ = try stack.undo(with: ops) }
            #expect(try fanTexts(h).sorted() == ["Another cat.", "The cat sat."],
                    "⌥⌘Z puts both buffers back")
        }
    }

    /// P-2: a door that cannot act SPEAKS. Fired with no search string,
    /// the finder replaces nothing and never reaches our client question —
    /// the act says what to do instead of failing silently.
    @Test func theActSpeaksWhenThereIsNothingToReplace() async throws {
        try await withEditor(seedBlocks: ["The cat sat."]) { h in
            let (scrollView, window) = try mount(h)
            defer { window.orderOut(nil); window.close() }
            await withFindPasteboard {
                // A search string the note genuinely does not contain — the
                // finder then hands its client an EMPTY range set, which is
                // the road this line travels (measured; see the gate).
                await fillBarThen(
                    { h.model.performFind(.replaceAllInEveryTake) },
                    needle: "zzzz-nowhere", replacement: "x",
                    harness: h, scrollView: scrollView)
                #expect(h.model.statusMessage == FindReplaceGate.noFindToReplace,
                        "\(h.model.statusMessage ?? "nil")")
                #expect(h.model.takesScopeArmed == false, "the arming is one-shot")
            }
            #expect(try fanTexts(h) == ["The cat sat."], "and nothing was touched")
        }
    }

    /// A sealed note refuses with the SEAL's reason, not the finder's —
    /// asked at the door because a sealed editor may never reach the gate.
    @Test func aSealedNoteRefusesWithTheSealsOwnReason() async throws {
        try await withEditor(seedBlocks: ["The cat sat."]) { h in
            try h.session.operations.lockPost(h.postID)
            try h.reload()
            let (_, window) = try mount(h)
            defer { window.orderOut(nil); window.close() }
            h.model.performFind(.replaceAllInEveryTake)
            pump()
            #expect(h.model.statusMessage?.contains("sealed") == true,
                    "\(h.model.statusMessage ?? "nil")")
            #expect(h.model.takesScopeArmed == false, "a refusal disarms too")
            #expect(try fanTexts(h) == ["The cat sat."])
        }
    }

    // MARK: - The declaration (P-1)

    @Test func theActIsDeclaredKeylessAndRenderedInTheFindMenu() {
        let capability = CapabilityRegistry.capability(.replaceAllInEveryTake)
        #expect(capability.verb == "Replace All in Every Take")
        #expect(capability.doors == [.menuBar])
        #expect(capability.shortcutLabel == nil,
                "keyless by the sweep's verdict — an act that edits unseen takes is chosen, not hit")
        #expect(EditorCommands.menuRendered.contains(.replaceAllInEveryTake),
                "declared ⇔ rendered (the walk asserts the set equality)")
        #expect(CapabilityRegistry.unhandledNote(
                    for: .find(.replaceAllInEveryTake),
                    context: CapabilityContext(mode: .takes))
                == capability.unavailableNote,
                "the routed act maps to its own declaration, not to a sibling's")
        // The family's availability, unchanged: only the editor that owns a
        // scroll view has a bar to read the two strings from.
        #expect(capability.availability(CapabilityContext(
            mode: .write, writeEditorAttached: true, writeEditorOwnsScrollView: true)) == .act)
        #expect(capability.availability(CapabilityContext(mode: .takes)) == .unavailable)
    }
}
