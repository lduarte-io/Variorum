//
//  FindReadoutTests.swift
//  VariorumTests
//
//  **VX-441 (the VX-439 run, A-439-13) — Write's find bar says where you are.**
//  Her ask (2026-10-18): *"a # of matches in find and replace within write as
//  you go down that count — so you can see if you're 2/3, 2/15, etc."*
//
//  The trace (the run record): AppKit's `NSTextFinder` bar shows no count and
//  takes none (no string for one in its tables, no public API but
//  `incrementalMatchRanges`, which lives only under the incremental searching
//  Write keeps OFF). So the readout is ours, on the bottom bar's trailing end.
//
//  Pins: the needle as the find pasteboard carries it (the finder's own
//  channel — its words and its options); the count under the Takes bar's
//  sameness rule and in its words ("2 of 15"); the cheap gates (an empty
//  selection — every keystroke — reads nothing, not even the pasteboard);
//  the real editor following a selection through its own delegate and the
//  bar's opening/closing through its container; the REAL finder stepping
//  (find-pasteboard discipline: saved and put back); the wiring, read.
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-441 — Write's find readout follows you: 2 of 15", .serialized)
struct FindReadoutTests {
    private typealias Readout = FindReadout

    private func pump(_ turns: Int = 6) {
        for _ in 0..<turns {
            RunLoop.main.run(until: Date().addingTimeInterval(0.03))
        }
    }

    // MARK: - The needle

    @Test func theNeedleIsTheFindersWordsUnderItsOptionsAndNothingItCannotCount() {
        #expect(Readout.needle(string: nil, options: nil) == nil)
        #expect(Readout.needle(string: "", options: nil) == nil)
        let plain = Readout.needle(string: "the", options: nil)
        #expect(plain?.text == "the" && plain?.options == TakesFindPlan.compareOptions,
                "no options: the finder's defaults — Contains, Ignore Case (the Takes bar's measured rule)")
        let caseKey = NSPasteboard.PasteboardType.TextFinderOptionKey.textFinderCaseInsensitiveKey.rawValue
        let kindKey = NSPasteboard.PasteboardType.TextFinderOptionKey.textFinderMatchingTypeKey.rawValue
        let cased = Readout.needle(string: "The", options: [caseKey: NSNumber(value: false)])
        #expect(cased?.options.contains(.caseInsensitive) == false, "Ignore Case off is honoured")
        for kind in [NSTextFinder.MatchingType.startsWith, .fullWord, .endsWith] {
            #expect(Readout.needle(string: "the", options: [kindKey: NSNumber(value: kind.rawValue)]) == nil,
                    "\(kind.rawValue): a kind the readout cannot count exactly draws nothing")
        }
        #expect(Readout.needle(
            string: "the", options: [kindKey: NSNumber(value: NSTextFinder.MatchingType.contains.rawValue)]) != nil)
    }

    // MARK: - The count and its words

    @Test func theCountStepsAsTheFinderDoesAndSpeaksTheTakesBarsWords() throws {
        let text = "The cat and the hat and THE bat"
        let needle = try #require(Readout.needle(string: "the", options: nil))
        let matches = Readout.ranges(of: needle, in: text)
        #expect(matches.count == 3, "case folded: \(matches)")
        #expect(Readout.ranges(of: try #require(Readout.needle(string: "aa", options: nil)), in: "aaaa").count == 2,
                "non-overlapping — the finder resumes after the match it selected")
        let second = matches[1]
        #expect(Readout.face(barVisible: true, needle: { needle }, selection: second, text: text)
                == TakesFindCopy.position(2, of: 3, wrapped: false))
        #expect(TakesFindCopy.position(2, of: 3, wrapped: false) == "2 of 3", "the Takes bar's words")
        #expect(Readout.face(barVisible: true, needle: { needle }, selection: matches[2], text: text) == "3 of 3",
                "THE — the case-folded third")
    }

    /// The gates: the bar down, an empty selection (every keystroke), a
    /// selection that is not the finder's words, or one that is those words
    /// but not where the finder would step — nothing drawn; and the first two
    /// never even read the needle (P1: no pasteboard read, no scan).
    @Test func theCheapGatesComeFirstAndNothingWrongIsEverDrawn() throws {
        let text = "aaaa the cat"
        let needle = try #require(Readout.needle(string: "aa", options: nil))
        var reads = 0
        let counted: @MainActor () -> FindReadout.Needle? = {
            reads += 1
            return needle
        }
        #expect(Readout.face(barVisible: false, needle: counted, selection: NSRange(location: 0, length: 2), text: text) == nil)
        #expect(Readout.face(barVisible: true, needle: counted, selection: NSRange(location: 3, length: 0), text: text) == nil)
        #expect(reads == 0, "bar down or an empty selection: the needle is never read")
        #expect(Readout.face(barVisible: true, needle: counted, selection: NSRange(location: 5, length: 3), text: text) == nil,
                "a selection that is not the finder's words")
        #expect(Readout.face(barVisible: true, needle: counted, selection: NSRange(location: 1, length: 2), text: text) == nil,
                "the words, but not a match the finder steps to (inside aa|aa)")
        #expect(Readout.face(barVisible: true, needle: counted, selection: NSRange(location: 2, length: 2), text: text) == "2 of 2")
        #expect(Readout.face(barVisible: true, needle: { nil }, selection: NSRange(location: 0, length: 2), text: text) == nil,
                "nothing armed")
        #expect(Readout.face(barVisible: true, needle: counted, selection: NSRange(location: 40, length: 2), text: text) == nil,
                "a stale selection past the text")
    }

    // MARK: - The real editor

    /// **The editor follows** — a selection landing on a match (the delegate's
    /// own road) shows its place; typing (an empty selection) clears it; the
    /// bar closing through its container clears it.
    @Test func theEditorFollowsTheSelectionAndTheBarsOpeningAndClosing() async throws {
        try await withEditor(seedBlocks: ["the cat and the hat", "and the bat"]) { h in
            let scrollView = try #require(h.textView.enclosingScrollView as? TypewriterScrollView)
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 700, height: 400),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            scrollView.frame = NSRect(x: 0, y: 0, width: 700, height: 400)
            window.contentView = NSView(frame: NSRect(x: 0, y: 0, width: 700, height: 400))
            window.contentView?.addSubview(scrollView)
            window.makeKeyAndOrderFront(nil)
            defer { window.orderOut(nil) }
            pump()
            window.makeFirstResponder(h.textView)
            h.model.findReadoutNeedle = { FindReadout.needle(string: "the", options: nil) }

            let text = h.textView.string as NSString
            let first = text.range(of: "the")
            let second = text.range(of: "the", range: NSRange(location: first.upperBound, length: text.length - first.upperBound))
            h.textView.setSelectedRange(second)
            pump()
            #expect(h.model.findReadout == nil, "the bar is down: nothing")

            scrollView.isFindBarVisible = true
            pump()
            #expect(h.model.findReadout == "2 of 3", "the bar up, on the second match: \(String(describing: h.model.findReadout))")
            h.textView.setSelectedRange(first)
            pump()
            #expect(h.model.findReadout == "1 of 3", "it follows: \(String(describing: h.model.findReadout))")
            h.textView.setSelectedRange(NSRange(location: first.upperBound, length: 0))
            pump()
            #expect(h.model.findReadout == nil, "a caret, not a match: nothing")
            h.textView.setSelectedRange(second)
            pump()
            #expect(h.model.findReadout == "2 of 3")
            scrollView.isFindBarVisible = false
            pump()
            #expect(h.model.findReadout == nil, "the bar closed: the readout goes with it")
        }
    }

    /// **The REAL finder, stepping** — its own next-match action selects each
    /// match, and the readout follows from the find pasteboard's words (saved
    /// and put back — the machine-global board's discipline).
    @Test func theRealFindersStepsAreFollowed() async throws {
        let board = NSPasteboard(name: .find)
        let saved = board.string(forType: .string)
        defer {
            board.clearContents()
            if let saved { board.setString(saved, forType: .string) }
        }
        try await withEditor(seedBlocks: ["the cat and the hat", "and the bat"]) { h in
            let scrollView = try #require(h.textView.enclosingScrollView)
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 700, height: 400),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            scrollView.frame = NSRect(x: 0, y: 0, width: 700, height: 400)
            window.contentView = NSView(frame: NSRect(x: 0, y: 0, width: 700, height: 400))
            window.contentView?.addSubview(scrollView)
            window.makeKeyAndOrderFront(nil)
            defer { window.orderOut(nil) }
            pump()
            window.makeFirstResponder(h.textView)
            h.textView.setSelectedRange(NSRange(location: 0, length: 0))

            board.clearContents()
            board.setString("the", forType: .string)
            #expect(h.model.performFind(.show))
            pump()
            #expect(scrollView.isFindBarVisible)
            var seen: [String?] = []
            for _ in 0..<3 {
                #expect(h.model.performFind(.next))
                pump()
                seen.append(h.model.findReadout)
            }
            #expect(seen.compactMap { $0 }.count == 3, "every step showed its place: \(seen)")
            #expect(Set(seen.compactMap { $0 }) == ["1 of 3", "2 of 3", "3 of 3"], "each match once: \(seen)")
        }
    }

    // MARK: - The wiring, read

    @Test func theReadoutIsDrawnBesideTheStatusSeamAndFedOnlyByChrome() throws {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        func source(_ path: String) throws -> String {
            try String(contentsOf: root.appending(path: path), encoding: .utf8)
        }
        let bar = try source("Variorum/Features/Editor/CommitBar.swift")
        #expect(bar.components(separatedBy: "findReadoutFace\n                        quietReceipt").count - 1 == 3,
                "every arrangement draws it just before the quiet slot")
        #expect(bar.contains("if let readout = model.findReadout {"))
        let delegate = try source("Variorum/Features/Editor/EditorView.swift")
        #expect(delegate.contains("model.updateCaretContext()\n        // VX-441"),
                "the selection delegate's identity work runs first, unchanged")
        #expect(delegate.contains("model.refreshFindReadout()"))
        let editor = try source("Variorum/Features/Editor/EditorTextView.swift")
        #expect(editor.contains("super.isFindBarVisible = newValue"), "the container override calls super")
        #expect(editor.contains("textView.isIncrementalSearchingEnabled = false"),
                "incremental searching stays OFF (ruled — TEXTKIT2_NOTES §3)")
    }
}
