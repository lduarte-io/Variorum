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

/// Records the delegate edit-gate calls AppKit makes — on a PLAIN text view,
/// so what it characterizes is AppKit's own shape.
@MainActor
final class GateRecorder: NSObject, NSTextViewDelegate {
    var singleCalls: [NSRange] = []
    var multiCalls: [[NSRange]] = []

    func textView(
        _ textView: NSTextView,
        shouldChangeTextIn affectedCharRange: NSRange,
        replacementString: String?
    ) -> Bool {
        singleCalls.append(affectedCharRange)
        return true
    }

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

    // MARK: - M1 + M2 — the delivery shape, characterized on APPKIT ITSELF

    /// **CHARACTERIZATION OF APPKIT, deliberately on a PLAIN `NSTextView`.**
    ///
    /// These two facts are about what AppKit does, not about what Variorum
    /// does — and since the batch shipped, `EditorTextView` answers the
    /// finder's client question with NO, so the app's own surface never lets
    /// AppKit get this far. Instrumenting our subclass would therefore
    /// measure our interception, which is not the claim. A plain text view
    /// keeps the claim honest: *if these fail, AppKit changed.*
    ///
    /// M1 — Replace All asks ONE question about ALL its ranges. That is what
    /// forces the ruled ALL-OR-NOTHING shape: a single boolean cannot apply
    /// some matches and refuse others.
    /// M2 — the delegate IS consulted, which is why the SHIPPED editor's
    /// `count != 1` door silently refused every Replace All (the text below
    /// is unchanged after the gesture — Part 0.3, on the real find path).
    @Test func m1m2_appKitAsksOneBatchedQuestionAndOurDelegateAnswersIt() throws {
        try withFindPasteboard {
            let scrollView = NSScrollView()
            let textView = NSTextView(usingTextLayoutManager: true)
            textView.isEditable = true
            textView.string = "the foo sits here\nanother foo lives here\na third foo at the end"
            textView.usesFindBar = true
            scrollView.documentView = textView
            let recorder = GateRecorder()
            textView.delegate = recorder

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
            print("M1/M2 bar fields: \(fields.map { (type(of: $0), $0.placeholderString ?? "-") })")
            if fields.count >= 2 {
                fields[0].stringValue = "foo"
                fields[1].stringValue = "BAR"
                for field in fields.prefix(2) {
                    field.sendAction(field.action, to: field.target)
                }
                pump()
            }

            recorder.multiCalls.removeAll()
            recorder.singleCalls.removeAll()
            finderAction(.replaceAll, on: textView)
            pump()

            print("M1 multiCalls=\(recorder.multiCalls.count) "
                + "rangeCounts=\(recorder.multiCalls.map(\.count)) "
                + "singleCalls=\(recorder.singleCalls.count)")

            #expect(recorder.multiCalls.count == 1, "ONE question…")
            // …about ALL of its ranges.
            #expect(recorder.multiCalls.first?.count == 3)
            #expect(recorder.singleCalls.isEmpty, "never as per-match single-range calls")
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
            // CHARACTERIZATION: NSTextView answers the client selectors
            // privately (which is why our own implementation shadows rather
            // than overrides one), and implements NEITHER half of the
            // search-boundary pair — the rejected `stringAtIndex` alternative
            // would have meant writing both from scratch.
            #expect(h.textView.responds(
                to: NSSelectorFromString("shouldReplaceCharactersInRanges:withStrings:")))
            #expect(!h.textView.responds(
                to: NSSelectorFromString("stringAtIndex:effectiveRange:endsWithSearchBoundary:")))
            #expect(!h.textView.responds(to: NSSelectorFromString("stringLength")))
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
            let scrollView = NSScrollView()
            let textView = NSTextView(usingTextLayoutManager: true)
            textView.isEditable = true
            scrollView.documentView = textView
            textView.string = "the foo sits here\nanother foo lives here\na third foo at the end"
            let recorder = StorageEditRecorder()
            textView.textStorage?.delegate = recorder
            let permissive = GateRecorder()
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
            // **THE FACT THE WHOLE DESIGN TURNS ON.** An approved Replace All
            // reaches the storage as ONE transaction spanning every match —
            // across block seams — which our block-routed pipeline can only
            // read as a desync. If a future AppKit applies them separately,
            // this fails and the shadow in `EditorTextView` can be revisited.
            #expect(recorder.edits.count == 1,
                    "ONE coalesced storage transaction, not one per match")
            let edited = try #require(recorder.edits.first)
            #expect(edited.range.length > 40,
                    "spanning from the first match to the last — across seams")
            #expect(textView.string
                == "the BAR sits here\nanother BAR lives here\na third BAR at the end")
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
            // CHARACTERIZATION: NSTextView coalesces adjacent replacements
            // into ONE undo group. Recorded because it is why a Replace All
            // undoes as the single act she performed.
            #expect(h.textView.string == before, "one undo restored both")
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
            // CHARACTERIZATION + the cross-batch guard: the bar is real
            // (32 pt, visible) and yet the clip, the room and the document
            // frame are all untouched — batch 1's compounding hazard does not
            // materialize on this new re-tiling occasion.
            #expect(barVisible)
            #expect(frame1 == frame0)
            #expect(frame2 == frame0)
            #expect(room1 == room0)
        }
    }
}
