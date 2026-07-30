//
//  FindReplaceMeasurementTests.swift
//  VariorumTests
//
//  QoL round 2026-07-29, batch 3 — **STEP 1: the M1–M4 measurements the
//  ruling required, run BEFORE any fix code.** Nothing here asserts a
//  design; every test records what AppKit on macOS 26.5.2 actually does,
//  because two of the batch's design branches hang on facts the SDK header
//  does not settle:
//
//    M1  Replace All's delivery shape — ONE call with N ranges, or N calls
//        with one range each? (Decides all-or-nothing vs apply-and-report.)
//    M2  Does NSTextView's `shouldReplaceCharacters(inRanges:with:)` consult
//        OUR delegate at all? (Decides whether the gate can live in the
//        delegate or must live in the override.)
//    M3  Undo granularity for a multi-match Replace All (characterization).
//    M4  The find bar × typewriter room interaction — does showing and
//        hiding the bar leave the document frame where it started, or does
//        it compound (batch 1's `appliedHeight` hazard)?
//
//  FIND-PASTEBOARD DISCIPLINE (required by the ruling — batch 2's
//  real-defaults class): NSTextFinder's search string lives on the
//  MACHINE-GLOBAL find pasteboard, shared with every app on her Mac. Every
//  test here saves it and puts it back.
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

/// Records every delegate edit-gate call the real pipeline receives, then
/// forwards to the production delegate unchanged.
@MainActor
final class EditGateSpy: NSObject, NSTextViewDelegate {
    struct MultiCall { let ranges: [NSRange]; let strings: [String]? }

    let inner: EditorSurfaceDelegate
    private(set) var singleCalls: [(range: NSRange, replacement: String?)] = []
    private(set) var multiCalls: [MultiCall] = []

    init(inner: EditorSurfaceDelegate) {
        self.inner = inner
    }

    func textView(
        _ textView: NSTextView,
        shouldChangeTextIn affectedCharRange: NSRange,
        replacementString: String?
    ) -> Bool {
        singleCalls.append((affectedCharRange, replacementString))
        return inner.textView(
            textView, shouldChangeTextIn: affectedCharRange,
            replacementString: replacementString)
    }

    func textView(
        _ textView: NSTextView,
        shouldChangeTextInRanges affectedRanges: [NSValue],
        replacementStrings: [String]?
    ) -> Bool {
        multiCalls.append(MultiCall(
            ranges: affectedRanges.map(\.rangeValue), strings: replacementStrings))
        return inner.textView(
            textView, shouldChangeTextInRanges: affectedRanges,
            replacementStrings: replacementStrings)
    }

    func textViewDidChangeSelection(_ notification: Notification) {
        inner.textViewDidChangeSelection(notification)
    }
}

/// M1b's gate: says YES to everything, so the measurement sees what AppKit
/// does on the far side of an approval. Wired to a BARE text view — no model,
/// no index, nothing that can crash before the facts print.
@MainActor
final class AlwaysYesDelegate: NSObject, NSTextViewDelegate {
    var multiCalls: [[NSRange]] = []

    func textView(
        _ textView: NSTextView,
        shouldChangeTextInRanges affectedRanges: [NSValue],
        replacementStrings: [String]?
    ) -> Bool {
        multiCalls.append(affectedRanges.map(\.rangeValue))
        return true
    }
}

/// Records the EXACT storage transactions AppKit produces.
@MainActor
final class StorageEditRecorder: NSObject, NSTextStorageDelegate {
    var edits: [(range: NSRange, delta: Int)] = []

    nonisolated func textStorage(
        _ textStorage: NSTextStorage,
        didProcessEditing editedMask: NSTextStorageEditActions,
        range editedRange: NSRange,
        changeInLength delta: Int
    ) {
        guard editedMask.contains(.editedCharacters) else { return }
        MainActor.assumeIsolated { edits.append((editedRange, delta)) }
    }
}

@MainActor
@Suite("M1–M4 — find & replace, measured on 26.5.2 (QoL batch 3 step 1)", .serialized)
struct FindReplaceMeasurementTests {
    // MARK: - Harness

    private func pump(_ turns: Int = 6) {
        for _ in 0..<turns {
            RunLoop.main.run(until: Date().addingTimeInterval(0.03))
        }
    }

    /// Saves and restores the MACHINE-GLOBAL find pasteboard around `body`.
    private func withFindPasteboard<T>(_ body: () throws -> T) rethrows -> T {
        let board = NSPasteboard(name: .find)
        let saved = board.string(forType: .string)
        defer {
            board.clearContents()
            if let saved { board.setString(saved, forType: .string) }
        }
        return try body()
    }

    /// The async twin (the pipeline settles with `await`).
    private func withFindPasteboardAsync<T>(
        _ body: () async throws -> T
    ) async rethrows -> T {
        let board = NSPasteboard(name: .find)
        let saved = board.string(forType: .string)
        defer {
            board.clearContents()
            if let saved { board.setString(saved, forType: .string) }
        }
        return try await body()
    }

    private func setSearchString(_ text: String) {
        let board = NSPasteboard(name: .find)
        board.clearContents()
        board.setString(text, forType: .string)
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

    /// Every text-bearing control inside the find bar, so the measurement can
    /// report what is actually there rather than assuming.
    private func barControls(_ view: NSView?) -> [(cls: String, value: String)] {
        guard let view else { return [] }
        var out: [(String, String)] = []
        func walk(_ v: NSView) {
            if let field = v as? NSTextField {
                out.append((String(describing: type(of: field)), field.stringValue))
            }
            for sub in v.subviews { walk(sub) }
        }
        walk(view)
        return out
    }

    // MARK: - M1 + M2 — the delivery shape, and whether our delegate sees it

    @Test func m1m2_replaceAllDeliveryShapeAndDelegateReach() async throws {
        try await withEditor(seedBlocks: [
            "the foo sits here", "another foo lives here", "a third foo at the end",
        ]) { h in
            try withFindPasteboard {
                let (scrollView, window) = try mount(h)
                defer { window.orderOut(nil) }

                let spy = EditGateSpy(inner: h.surfaceDelegate)
                h.textView.delegate = spy
                h.textView.usesFindBar = true

                setSearchString("foo")
                finderAction(.showReplaceInterface, on: h.textView)
                pump()

                let bar = scrollView.findBarView
                let controls = barControls(bar)
                print("M1/M2 findBarView: \(bar.map { String(describing: type(of: $0)) } ?? "nil")")
                print("M1/M2 bar text controls: \(controls)")

                // Drive the bar's own fields, then fire Replace All the way a
                // click on its button does.
                for field in textFields(in: bar) {
                    print("M1/M2 field \(type(of: field)) placeholder=\(field.placeholderString ?? "-")")
                }
                let fields = textFields(in: bar)
                if fields.count >= 2 {
                    fields[0].stringValue = "foo"
                    fields[1].stringValue = "BAR"
                    // Let the finder observe the fields the way typing does.
                    for field in fields.prefix(2) {
                        field.sendAction(field.action, to: field.target)
                    }
                    pump()
                }

                let before = h.textView.string
                finderAction(.replaceAll, on: h.textView)
                pump()
                let after = h.textView.string

                print("M1 singleCalls=\(spy.singleCalls.count) "
                    + "multiCalls=\(spy.multiCalls.count) "
                    + "multiRangeCounts=\(spy.multiCalls.map(\.ranges.count))")
                print("M1 singleRanges=\(spy.singleCalls.map { NSStringFromRange($0.range) }) "
                    + "replacements=\(spy.singleCalls.map { $0.replacement ?? "nil" })")
                print("M1 text before=\(before.debugDescription)")
                print("M1 text  after=\(after.debugDescription)")
                print("M2 delegateSawTheReplace="
                    + "\(spy.singleCalls.count + spy.multiCalls.count > 0)")

                // A measurement, not an assertion: the run's PRINTED output is
                // the deliverable. This keeps the suite green while the facts
                // are recorded.
                #expect(Bool(true))
            }
        }
    }

    private func textFields(in view: NSView?) -> [NSTextField] {
        guard let view else { return [] }
        var out: [NSTextField] = []
        func walk(_ v: NSView) {
            if let field = v as? NSTextField, field.isEditable { out.append(field) }
            for sub in v.subviews { walk(sub) }
        }
        walk(view)
        return out
    }

    // MARK: - M2b — the client method, called directly

    /// M2's first half, already known at COMPILE time and recorded here so it
    /// is in the run's output too: `NSTextView` does not publicly declare
    /// `NSTextFinderClient`, so the client methods are invisible to Swift and
    /// there is nothing to `override`. What it RESPONDS to at runtime is the
    /// fact that decides whether a subclass implementation would shadow a real
    /// one (and therefore whether "call super" is even a question).
    @Test func m2b_whichClientSelectorsTheTextViewAnswers() async throws {
        try await withEditor(seedBlocks: ["the foo sits here"]) { h in
            let selectors = [
                "shouldReplaceCharactersInRanges:withStrings:",
                "replaceCharactersInRange:withString:",
                "didReplaceCharacters",
                "stringAtIndex:effectiveRange:endsWithSearchBoundary:",
                "stringLength",
                "firstSelectedRange",
                "isEditable",
            ]
            for name in selectors {
                print("M2b responds(\(name)) = "
                    + "\(h.textView.responds(to: NSSelectorFromString(name)))")
            }
            #expect(Bool(true))
        }
    }

    // MARK: - M1b — what AppKit does once the gate SAYS YES

    /// The shipped `count != 1` door refused M1's Replace All outright, so M1
    /// could not see the other half: once a gate approves N ranges, how do the
    /// replacements reach the TEXT STORAGE — N separate edits, or one coalesced
    /// transaction?
    ///
    /// **Deliberately PIPELINE-FREE.** The first cut of this measurement wired
    /// the real model in and the process died with
    /// `Fatal error: editor surface desynced from the block index`
    /// (`EditorViewModel.swift:815`) — which is itself a headline finding, and
    /// exactly why the storage shape has to be measured on a bare surface
    /// where nothing can crash before it prints.
    @Test func m1b_howTheApprovedReplacementsReachTheStorage() throws {
        try withFindPasteboard {
            let (scrollView, textView) = EditorTextView.makeEditor()
            textView.string = "the foo sits here\nanother foo lives here\na third foo at the end"
            let recorder = StorageEditRecorder()
            textView.textStorage?.delegate = recorder
            let permissive = AlwaysYesDelegate()
            textView.delegate = permissive
            textView.usesFindBar = true

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 700, height: 400),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            window.contentView = NSView(frame: NSRect(x: 0, y: 0, width: 700, height: 400))
            scrollView.frame = NSRect(x: 0, y: 0, width: 700, height: 400)
            window.contentView?.addSubview(scrollView)
            window.makeKeyAndOrderFront(nil)
            window.layoutIfNeeded()
            pump()
            window.makeFirstResponder(textView)
            defer { window.orderOut(nil) }

            setSearchString("foo")
            finderAction(.showReplaceInterface, on: textView)
            pump()
            let fields = textFields(in: scrollView.findBarView)
            if fields.count >= 2 {
                fields[0].stringValue = "foo"
                fields[1].stringValue = "BAR"
                for field in fields.prefix(2) {
                    field.sendAction(field.action, to: field.target)
                }
                pump()
            }

            recorder.edits.removeAll()
            permissive.multiCalls.removeAll()
            // M5: is the whole finder round-trip SYNCHRONOUS inside our own
            // `performTextFinderAction` call? The `isFindReplacing` flag can
            // only ride that call if it is.
            finderAction(.replaceAll, on: textView)
            let callsBeforeReturn = permissive.multiCalls.count
            let editsBeforeReturn = recorder.edits.count
            pump()
            print("M5 duringTheCall: gateCalls=\(callsBeforeReturn) "
                + "storageEdits=\(editsBeforeReturn); "
                + "afterPump: gateCalls=\(permissive.multiCalls.count) "
                + "storageEdits=\(recorder.edits.count)")

            print("M1b multiCalls=\(permissive.multiCalls.count) "
                + "ranges=\(permissive.multiCalls.map { $0.map(NSStringFromRange) })")
            print("M1b storageEdits(count=\(recorder.edits.count))="
                + "\(recorder.edits.map { (NSStringFromRange($0.range), $0.delta) })")
            print("M1b surface=\(textView.string.debugDescription)")
            #expect(Bool(true))
        }
    }

    // MARK: - M3 — undo granularity (characterization)

    @Test func m3_undoGranularityOfAMultiRangeReplace() async throws {
        try await withEditor(seedBlocks: ["the foo sits here", "another foo lives here"]) { h in
            let (_, window) = try mount(h)
            defer { window.orderOut(nil) }
            let manager = try #require(h.textView.undoManager)
            manager.removeAllActions()
            let before = h.textView.string

            // Two independent single-range replacements through the ordinary
            // gate — the shape a per-match Replace All would produce.
            h.textView.insertText("BAR", replacementRange: NSRange(location: 26, length: 3))
            h.textView.insertText("BAR", replacementRange: NSRange(location: 4, length: 3))
            await h.flush()

            print("M3 after two replaces: \(h.textView.string.debugDescription)")
            manager.undo()
            print("M3 after one undo:     \(h.textView.string.debugDescription)")
            manager.undo()
            print("M3 after two undos:    \(h.textView.string.debugDescription)")
            print("M3 original:           \(before.debugDescription)")
            #expect(Bool(true))
        }
    }

    // MARK: - M4 — the find bar × the typewriter room

    @Test func m4_findBarDoesNotCompoundTheDocumentFrame() async throws {
        let paragraphs = (0..<40).map { "Paragraph \($0) with a handful of ordinary words." }
        try await withEditor(seedBlocks: paragraphs) { h in
            let (scrollView, window) = try mount(h)
            defer { window.orderOut(nil) }
            h.textView.usesFindBar = true

            let frame0 = h.textView.frame.height
            let room0 = (scrollView as? TypewriterScrollView)?.typewriterRoom ?? -1
            let clip0 = scrollView.contentView.bounds.height

            finderAction(.showFindInterface, on: h.textView)
            pump()
            scrollView.tile()
            window.layoutIfNeeded()
            pump()
            let frame1 = h.textView.frame.height
            let room1 = (scrollView as? TypewriterScrollView)?.typewriterRoom ?? -1
            let clip1 = scrollView.contentView.bounds.height
            let barVisible = scrollView.isFindBarVisible

            finderAction(.hideFindInterface, on: h.textView)
            pump()
            scrollView.tile()
            window.layoutIfNeeded()
            pump()
            let frame2 = h.textView.frame.height
            let room2 = (scrollView as? TypewriterScrollView)?.typewriterRoom ?? -1
            let clip2 = scrollView.contentView.bounds.height

            print("M4 findBarVisible after show = \(barVisible)")
            print("M4 findBarView height = \(scrollView.findBarView?.frame.height ?? -1)")
            print("M4 scrollView frame = \(scrollView.frame.height)")
            print("M4 clip   \(clip0) -> \(clip1) -> \(clip2)")
            print("M4 room   \(room0) -> \(room1) -> \(room2)")
            print("M4 frame  \(frame0) -> \(frame1) -> \(frame2)")
            #expect(Bool(true))
        }
    }
}
