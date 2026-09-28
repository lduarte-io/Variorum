//
//  TakesFindPlanTests.swift
//  VariorumTests
//
//  18l-c UNIT U7 — SEARCH IN TAKES: the pure match brain (`TakesFindPlan`,
//  the design brief's decision 2) and the ONE RULE OF SAMENESS it shares with
//  Write's find bar, measured against the real `NSTextFinder`.
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("18l-c U7 — the Takes find brain (TakesFindPlan)", .serialized)
struct TakesFindPlanTests {
    // MARK: - The measurement: the two bars agree on what a match is

    private func pump(_ turns: Int = 4) {
        for _ in 0..<turns {
            RunLoop.main.run(until: Date().addingTimeInterval(0.03))
        }
    }

    /// Walks the REAL finder over the Write editor's text: from the start,
    /// Find Next until it comes round again — every selection it makes is a
    /// match by the Write bar's own rule.
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

    private func finderMatches(
        _ needle: String, in textView: NSTextView, scrollView: NSScrollView
    ) -> [NSRange] {
        let board = NSPasteboard(name: .find)
        board.clearContents()  // no options on the board ⇒ the finder's own defaults
        board.setString(needle, forType: .string)
        // The finder reads its search string through its BAR (the
        // `FindAndReplaceTests.replaceAll` road): show it, type the needle
        // into its own field, fire the field's own action.
        finderAction(.showFindInterface, on: textView)
        pump()
        if let field = editableFields(in: scrollView.findBarView).first {
            field.stringValue = needle
            field.sendAction(field.action, to: field.target)
            pump()
        }
        textView.setSelectedRange(NSRange(location: 0, length: 0))
        var seen: [NSRange] = []
        for _ in 0..<40 {
            finderAction(.nextMatch, on: textView)
            pump(1)
            let selection = textView.selectedRange()
            guard selection.length > 0, !seen.contains(selection) else { break }
            seen.append(selection)
        }
        finderAction(.hideFindInterface, on: textView)
        pump()
        return seen.sorted { $0.location < $1.location }
    }

    /// **THE AGREEMENT PIN** (decision 2: *"read EditorFind's options and
    /// MATCH them — one rule of sameness across the two bars"*). EditorFind
    /// sets no options, so the Write bar's rule is `NSTextFinder`'s default;
    /// this drives that finder over one text with case, precomposed and
    /// decomposed accents, and a repeated needle, and holds the Takes brain to
    /// exactly the finder's matches for every needle. A point release that
    /// moves the finder's rule reds here instead of splitting the two bars.
    /// The find pasteboard is machine-global (her Mac's); it is saved and put
    /// back, the `FindAndReplaceTests` discipline.
    @Test func theTwoBarsAgreeOnWhatAMatchIs() async throws {
        let text = "Hyde met HYDE and hyde; then Hyd\u{E9} and Hyde\u{301} came, "
            + "Hyde's cane and Mr Hydeish; a cafe, a caf\u{E9}, a CAF\u{C9}; aaaa."
        let board = NSPasteboard(name: .find)
        let savedString = board.string(forType: .string)
        defer {
            board.clearContents()
            if let savedString { board.setString(savedString, forType: .string) }
        }
        try await withEditor(seedBlocks: [text]) { h in
            let scrollView = try #require(h.textView.enclosingScrollView)
            scrollView.frame = NSRect(x: 0, y: 0, width: 700, height: 400)
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 700, height: 400),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            window.contentView = NSView(frame: NSRect(x: 0, y: 0, width: 700, height: 400))
            window.contentView?.addSubview(scrollView)
            window.makeKeyAndOrderFront(nil)
            defer { window.orderOut(nil) }
            pump()
            window.makeFirstResponder(h.textView)

            let document = h.textView.string
            for needle in ["hyde", "HYDE", "Hyd\u{E9}", "hyde\u{301}", "cafe", "CAF\u{C9}", "aa", "e"] {
                let finder = finderMatches(needle, in: h.textView, scrollView: scrollView)
                let brain = TakesFindPlan.ranges(of: needle, in: document)
                print("[18l-c U7 compare] needle \(needle.debugDescription) — finder "
                      + "\(finder.map { "\($0.location)+\($0.length)" }) · brain "
                      + "\(brain.map { "\($0.location)+\($0.length)" })")
                #expect(!finder.isEmpty, "non-vacuity: the finder found \(needle.debugDescription)")
                #expect(brain == finder,
                        "the Takes brain and the Write bar agree on \(needle.debugDescription)")
            }
        }
    }

    // MARK: - The brain

    private func slot(
        _ n: Int, shown: String?, others: [String] = []
    ) -> TakesFindPlan.Slot {
        TakesFindPlan.Slot(
            blockID: "b\(n)", placementID: "p\(n)",
            shown: shown.map { TakesFindPlan.Take(variantID: "v\(n)-0", text: $0) },
            others: others.enumerated().map {
                TakesFindPlan.Take(variantID: "v\(n)-\($0.offset + 1)", text: $0.element)
            })
    }

    private var note: [TakesFindPlan.Slot] {
        [
            slot(1, shown: "Mr Hyde, and Hyde again.", others: ["Hyde plain", "no match here"]),
            slot(2, shown: "Utterson alone.", others: ["only a hyde in the fan"]),
            slot(3, shown: nil),  // a gap slot has no text
            slot(4, shown: "HYDE at the end"),
        ]
    }

    @Test func shownTakesOnlySearchesWhatTheArticleShows() {
        let matches = TakesFindPlan.matches(query: "hyde", in: note, scope: .shownTakesOnly)
        let takes = matches.map(\.variantID)
        let locations = matches.map(\.range.location)
        let allShown = matches.allSatisfy(\.onShownTake)
        #expect(takes == ["v1-0", "v1-0", "v4-0"])
        #expect(allShown)
        #expect(locations == [3, 13, 0])
        #expect(TakesFindPlan.offScopeCounts(matches).isEmpty,
                "with the toggle ON nothing is off-scope")
    }

    @Test func everyLiveTakeReadsTheBoardInOrderShownFirstThenTheFan() {
        let matches = TakesFindPlan.matches(query: "hyde", in: note, scope: .everyLiveTake)
        let takes = matches.map(\.variantID)
        let shown = matches.map(\.onShownTake)
        let placements = matches.map(\.placementID)
        let ordered = zip(matches, matches.dropFirst()).allSatisfy { $0.order < $1.order }
        #expect(takes == ["v1-0", "v1-0", "v1-1", "v2-1", "v4-0"],
                "slot by slot; inside a slot the shown take, then the fan in order")
        #expect(shown == [true, true, false, false, true])
        #expect(placements == ["p1", "p1", "p1", "p2", "p4"])
        #expect(ordered, "the reading order is the order the list is in")
        #expect(TakesFindPlan.offScopeCounts(matches) == ["b1": 1, "b2": 1],
                "R-18l-10's marker counts: matches on takes the article is not showing")
    }

    @Test func anEmptyQueryFindsNothingAndLeavesNoResidue() {
        #expect(TakesFindPlan.matches(query: "", in: note, scope: .everyLiveTake).isEmpty)
        #expect(TakesFindPlan.ranges(of: "", in: "anything").isEmpty)
        #expect(TakesFindPlan.ranges(of: "x", in: "").isEmpty)
        #expect(TakesFindPlan.countFace(total: 0, current: nil, wrapped: false, query: "") == "")
    }

    @Test func matchesDoNotOverlapExactlyAsTheFinderSteps() {
        #expect(TakesFindPlan.ranges(of: "aa", in: "aaaa")
                == [NSRange(location: 0, length: 2), NSRange(location: 2, length: 2)])
        #expect(TakesFindPlan.ranges(of: "aa", in: "aaa") == [NSRange(location: 0, length: 2)])
    }

    @Test func rangesAreUTF16TheUnitEveryPaneSpeaks() {
        // An astral character before the match counts as TWO units.
        let text = "\u{1F600} Hyde"
        #expect(TakesFindPlan.ranges(of: "hyde", in: text) == [NSRange(location: 3, length: 4)])
    }

    @Test func steppingWrapsAtBothEndsAndSaysSo() throws {
        let matches = TakesFindPlan.matches(query: "hyde", in: note, scope: .everyLiveTake)
        // No origin: forward from the first, backward from the last.
        #expect(TakesFindPlan.step(from: nil, in: matches, forward: true)
                == .init(index: 0, wrapped: false))
        #expect(TakesFindPlan.step(from: nil, in: matches, forward: false)
                == .init(index: 4, wrapped: false))
        // Off the current match, strictly.
        #expect(TakesFindPlan.step(from: matches[1].order, in: matches, forward: true)
                == .init(index: 2, wrapped: false))
        #expect(TakesFindPlan.step(from: matches[1].order, in: matches, forward: false)
                == .init(index: 0, wrapped: false))
        // The ends wrap.
        #expect(TakesFindPlan.step(from: matches[4].order, in: matches, forward: true)
                == .init(index: 0, wrapped: true))
        #expect(TakesFindPlan.step(from: matches[0].order, in: matches, forward: false)
                == .init(index: 4, wrapped: true))
        // A CARET origin includes a match starting right there.
        let caret = TakesFindPlan.Order(slot: 0, take: 0, location: 13)
        #expect(TakesFindPlan.step(from: caret, in: matches, forward: true, strictly: false)
                == .init(index: 1, wrapped: false))
        #expect(TakesFindPlan.step(from: nil, in: [], forward: true) == nil)
    }

    @Test func aRecountKeepsTheCurrentMatchOrTheNextOneAndNeverAStaleOne() {
        let before = TakesFindPlan.matches(query: "hyde", in: note, scope: .everyLiveTake)
        // The same list: the same index.
        #expect(TakesFindPlan.reanchor(before[2], in: before) == 2)
        // The toggle back ON drops the fan's matches: the current fan match
        // re-anchors to the first shown-take match at or after it.
        let shownOnly = TakesFindPlan.matches(query: "hyde", in: note, scope: .shownTakesOnly)
        #expect(TakesFindPlan.reanchor(before[2], in: shownOnly) == 2,
                "v1-1 (slot 1, take 1) → the next shown match is slot 4's")
        #expect(shownOnly[2].variantID == "v4-0")
        // Nothing at or after it: no current (the count reads "M matches").
        #expect(TakesFindPlan.reanchor(before[4], in: Array(before.prefix(2))) == nil)
        #expect(TakesFindPlan.reanchor(nil, in: before) == nil)
    }

    @Test func theCountFaceIsTheBarsOwnQuietWords() {
        #expect(TakesFindPlan.countFace(total: 0, current: nil, wrapped: false, query: "x")
                == "No matches")
        #expect(TakesFindPlan.countFace(total: 1, current: nil, wrapped: false, query: "x")
                == "1 match")
        #expect(TakesFindPlan.countFace(total: 12, current: nil, wrapped: false, query: "x")
                == "12 matches")
        #expect(TakesFindPlan.countFace(total: 12, current: 2, wrapped: false, query: "x")
                == "3 of 12")
        #expect(TakesFindPlan.countFace(total: 12, current: 0, wrapped: true, query: "x")
                == "1 of 12 · wrapped")
        #expect(TakesFindCopy.offScopeMarker(1) == "1 in another take")
        #expect(TakesFindCopy.offScopeMarker(2) == "2 in other takes")
    }
}
