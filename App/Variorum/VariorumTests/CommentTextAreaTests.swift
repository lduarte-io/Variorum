//
//  CommentTextAreaTests.swift
//  VariorumTests
//
//  VX-179 U3 — THE COMMENTS PANEL'S CARET, AND ITS PRISTINE PASS (her items
//  1 + 4; the F-U3-1 ruling). The run record's "U3 RECORD" carries the trace.
//
//  THE DEFECT, measured offscreen on macOS 27 (the record's U3-b): the
//  panel's placeholder was a SwiftUI overlay padded by a GUESS at
//  `TextEditor`'s private insets (top 8 / leading 5) while the text view
//  under it had `textContainerInset` (0, 0) — so the placeholder sat 8 pt
//  below the caret's line in both voices (the caret "left of and taller
//  than" it), every comment row carried 16 pt of dead air under its text,
//  and Terminal's `// ` mark sat 8 pt below its line. Separately, the quick-
//  entry bar's placeholder sat 2 pt above its box's first line.
//
//  RED-ON-OLD, stated exactly: the old control's placeholder was a SwiftUI
//  `Text` (no NSView a mounted pin can find), so its +8 pt is the probe's
//  measurement of the VERBATIM old control (the record), and these mounted
//  pins are feature pins for the new control — they cannot compile on the
//  pre-fix tree, which is their red. Cells that ARE red on old by value are
//  marked: the bar's origin (old (0, 0)), and the panel's race refusals (old
//  `Refused: commentNotFound(id: "…")` and its siblings).
//
//  The mounted suites host the REAL control in an `NSHostingView` WITHOUT a
//  window (geometry, layout and bitmap rendering need none — measured by the
//  probe), except the one focus cell, whose window is never ordered in.
//

import AppKit
import Foundation
import Observation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The pure rules

@MainActor
@Suite("The comments panel's text geometry and focus rule (VX-179 U3)")
struct CommentPanelGeometryRuleTests {
    @Test func theAreasGeometryIsOwnedAndItsFirstLineIsTheInset() {
        #expect(CommentsPanelMetrics.textInset == NSSize(width: 0, height: 2))
        #expect(CommentsPanelMetrics.lineFragmentPadding == 0)
        #expect(CommentsPanelMetrics.firstLineOrigin == CGPoint(x: 0, y: 2),
                "the caret's, the first glyph's, the placeholder's and the mark's line all start here")
        #expect(CommentsPanelMetrics.writingInset
                == CommentsPanelMetrics.inset + CommentsPanelMetrics.composerPadding,
                "every word in the panel starts on ONE column: the composer's text column")
    }

    @Test func aRowIsItsMeasuredTextInWholePoints() {
        #expect(CommentsPanelMetrics.rowHeight(measured: 21) == 21)
        #expect(CommentsPanelMetrics.rowHeight(measured: 21.2) == 22, "never a fractional row")
        #expect(CommentsPanelMetrics.rowHeight(measured: -3) == 0)
        #expect(CommentsPanelMetrics.markColumn(measured: 25.96) == 26)
    }

    /// The F-U3-1 ruling's Q-2: the capture box OWNS its first-line origin,
    /// and both hosts' placeholders read it.
    @Test func theCaptureBoxOwnsItsOriginAndBothHostsReadIt() {
        #expect(CaptureTextView.textInset == NSSize(width: 0, height: 2))
        #expect(CaptureTextView.lineFragmentPadding == 0)
        #expect(CaptureTextView.firstLineOrigin == CGPoint(x: 0, y: 2))
        // RED ON OLD by value: the bar's placeholder sat at the ZStack's
        // origin, (0, 0) — 2 pt above the line her typing lands on.
        #expect(QuickEntryBar.placeholderOrigin == CaptureTextView.firstLineOrigin)
        // The parity proof: the pad derives exactly the (6, 6) it always drew.
        #expect(QuickNoteView.placeholderOrigin == CGPoint(x: 6, y: 6))
    }

    /// The reports replaced `@FocusState`: an arrival focuses its area; a
    /// departure clears the focus only if that area still holds it — so a
    /// click from A to B reads A → nil → B whichever way the reports meet.
    @Test func aCaretReportFocusesItsAreaAndALeavingOneClearsOnlyItsOwn() {
        let a = CommentPanelFocus.comment("a")
        let b = CommentPanelFocus.comment("b")
        #expect(CommentPanelFocus.after(report: .add, inArea: true, current: nil) == .add)
        #expect(CommentPanelFocus.after(report: .add, inArea: false, current: .add) == nil)
        #expect(CommentPanelFocus.after(report: a, inArea: true, current: .add) == a)
        // A → B, AppKit's order: A leaves, then B arrives.
        let afterLeave = CommentPanelFocus.after(report: a, inArea: false, current: a)
        #expect(afterLeave == nil)
        #expect(CommentPanelFocus.after(report: b, inArea: true, current: afterLeave) == b)
        // The other order: B's arrival first; A's late departure must not clear B.
        let afterArrive = CommentPanelFocus.after(report: b, inArea: true, current: a)
        #expect(CommentPanelFocus.after(report: a, inArea: false, current: afterArrive) == b)
        #expect(CommentPanelFocus.after(report: .add, inArea: false, current: nil) == nil)
    }
}

// MARK: - The control, mounted

/// The undo pin's draft — the panel model's `addDraft` road, an observed
/// value the area binds to and the "panel" clears.
@Observable private final class UndoPinDraft { var text = "" }

private struct UndoPinHost: View {
    @Bindable var draft: UndoPinDraft
    var body: some View {
        CommentTextArea(
            text: $draft.text,
            style: CommentTextStyle(tokens: .terminalLight, ink: VoiceTokens.terminalLight.ink),
            placeholder: "Write a comment…", growsWithText: false)
            .frame(width: 400, height: 200)
    }
}

@MainActor
@Suite("The comment writing area, mounted offscreen (VX-179 U3)", .serialized)
struct CommentTextAreaMountedTests {
    private struct Host: View {
        @State var text: String
        let style: CommentTextStyle
        var placeholder: String?
        var mark: String?
        var grows = false
        var focusRequest = 0
        var onFocusChange: (Bool) -> Void = { _ in }
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                CommentTextArea(
                    text: $text, style: style, placeholder: placeholder, mark: mark,
                    growsWithText: grows, focusRequest: focusRequest,
                    onFocusChange: onFocusChange)
                    .frame(height: grows ? nil : 200)
                Spacer(minLength: 0)
            }
            .frame(width: 400, height: 240, alignment: .topLeading)
        }
    }

    /// Both voices, light (the arguments are the core's `Sendable` voice
    /// enum; the tokens resolve inside each test, on the main actor).
    nonisolated private static let voices: [ThemeVoice] = [.terminal, .study]

    private func resolved(_ voice: ThemeVoice) -> VoiceTokens {
        VoiceTokens.resolve(voice: voice, dark: false)
    }

    private func settle(_ view: NSView) {
        for _ in 0..<6 {
            view.layoutSubtreeIfNeeded()
            RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        }
    }

    /// **A settle that lets MAIN-QUEUE TURNS pass** (the VX-179 U3 FIX LEG —
    /// the runner's red, traced): this suite's body runs as a job ON the main
    /// queue, and a nested `RunLoop.run` does not drain main-queue blocks while
    /// its caller is one — so work the control deliberately defers by one turn
    /// (serving a held focus request after the window arrives; delivering a
    /// first-responder report outside the view update) cannot happen inside
    /// `settle`. Suspending each turn releases the main actor and the queue
    /// drains: `CaptureFocusReportTests`' idiom, green in this runner.
    private func settleLettingTurnsPass(_ view: NSView) async {
        for _ in 0..<6 {
            settle(view)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
        }
    }

    private func mount(_ host: Host) -> (NSHostingView<Host>, CommentTextAreaView) {
        let hosting = NSHostingView(rootView: host)
        hosting.frame = NSRect(x: 0, y: 0, width: 400, height: 240)
        settle(hosting)
        let area = Self.areas(in: hosting).first!
        return (hosting, area)
    }

    private static func areas(in view: NSView) -> [CommentTextAreaView] {
        ((view as? CommentTextAreaView).map { [$0] } ?? [])
            + view.subviews.flatMap { areas(in: $0) }
    }

    /// The empty document's caret (TK2's `.standard` segment), in `space`.
    private func caret(_ textView: NSTextView, in space: NSView) -> CGRect? {
        guard let manager = textView.textLayoutManager else { return nil }
        manager.ensureLayout(for: manager.documentRange)
        let start = manager.documentRange.location
        guard let range = NSTextRange(location: start, end: start) else { return nil }
        var segment: CGRect?
        manager.enumerateTextSegments(in: range, type: .standard, options: [.rangeNotRequired]) {
            _, frame, _, _ in
            segment = frame
            return false
        }
        guard let segment else { return nil }
        let origin = textView.textContainerOrigin
        return textView.convert(segment.offsetBy(dx: origin.x, dy: origin.y), to: space)
    }

    /// The first line's frame and baseline, in `space`.
    private func firstLine(
        _ textView: NSTextView, in space: NSView
    ) -> (frame: CGRect, baseline: CGFloat)? {
        guard let manager = textView.textLayoutManager else { return nil }
        manager.ensureLayout(for: manager.documentRange)
        let origin = textView.textContainerOrigin
        var found: (CGRect, CGFloat)?
        manager.enumerateTextLayoutFragments(
            from: manager.documentRange.location, options: [.ensuresLayout]
        ) { fragment in
            if let line = fragment.textLineFragments.first {
                let local = CGRect(
                    x: fragment.layoutFragmentFrame.minX + origin.x,
                    y: fragment.layoutFragmentFrame.minY + origin.y,
                    width: fragment.layoutFragmentFrame.width,
                    height: line.typographicBounds.height)
                let frame = textView.convert(local, to: space)
                found = (frame, frame.minY + line.glyphOrigin.y)
            }
            return false
        }
        return found
    }

    private func inkBox(_ view: NSView, _ match: (NSColor) -> Bool) -> CGRect? {
        guard let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds) else { return nil }
        view.cacheDisplay(in: view.bounds, to: rep)
        var minX = Int.max, minY = Int.max, maxX = -1, maxY = -1
        for y in 0..<rep.pixelsHigh {
            for x in 0..<rep.pixelsWide {
                guard let colour = rep.colorAt(x: x, y: y)?.usingColorSpace(.sRGB),
                      match(colour) else { continue }
                minX = min(minX, x); maxX = max(maxX, x)
                minY = min(minY, y); maxY = max(maxY, y)
            }
        }
        guard maxX >= 0 else { return nil }
        let scale = CGFloat(rep.pixelsWide) / view.bounds.width
        return CGRect(
            x: CGFloat(minX) / scale, y: CGFloat(minY) / scale,
            width: CGFloat(maxX - minX + 1) / scale, height: CGFloat(maxY - minY + 1) / scale)
    }

    /// HER DEFECT, as geometry: the empty area's caret and the placeholder
    /// share ONE line — the same x, the same top, the same height — in both
    /// voices. (The old control: +8 pt, measured — the record's U3-b.)
    @Test(arguments: voices)
    func thePlaceholderLiesOnTheCaretsOwnLine(voice: ThemeVoice) throws {
        let tokens = resolved(voice)
        let (hosting, area) = mount(Host(
            text: "", style: CommentTextStyle(tokens: tokens, ink: tokens.ink),
            placeholder: "Write a comment…"))
        let twin = try #require(area.placeholderView)
        #expect(!twin.isHidden, "an empty area shows its placeholder")
        let caretLine = try #require(caret(area.textView, in: hosting))
        let placeholderLine = try #require(firstLine(twin, in: hosting))
        #expect(caretLine.minX == placeholderLine.frame.minX, "the caret sits at the placeholder's first glyph")
        #expect(caretLine.minY == placeholderLine.frame.minY, "…on the same line")
        #expect(caretLine.height == placeholderLine.frame.height, "…a line of the same height")
        #expect(caretLine.minY == CommentsPanelMetrics.firstLineOrigin.y,
                "the line starts at the area's OWN inset")
    }

    /// Stronger than geometry: the placeholder's PIXELS are the pixels her
    /// typed words would be (pure red vs pure blue, so the two inks never
    /// confuse the threshold).
    @Test(arguments: voices)
    func thePlaceholderInkIsExactlyTheTypedInk(voice: ThemeVoice) throws {
        let tokens = resolved(voice)
        let words = "Write a comment…"
        let (_, area) = mount(Host(
            text: "", style: CommentTextStyle(tokens: tokens, ink: tokens.ink),
            placeholder: words))
        let twin = try #require(area.placeholderView)
        twin.textStorage?.addAttribute(
            .foregroundColor, value: NSColor(srgbRed: 1, green: 0, blue: 0, alpha: 1),
            range: NSRange(location: 0, length: twin.textStorage?.length ?? 0))
        let (_, typed) = mount(Host(
            text: words,
            style: CommentTextStyle(tokens: tokens, ink: Color(.sRGB, red: 0, green: 0, blue: 1))))
        let placeholderInk = inkBox(area) {
            $0.redComponent > 0.6 && $0.greenComponent < 0.45 && $0.blueComponent < 0.45
        }
        let typedInk = inkBox(typed) {
            $0.blueComponent > 0.6 && $0.redComponent < 0.45 && $0.greenComponent < 0.45
        }
        #expect(placeholderInk != nil && placeholderInk == typedInk,
                "placeholder \(String(describing: placeholderInk)) vs typed \(String(describing: typedInk))")
    }

    /// The typing attributes are OURS (the style's), and stay ours through
    /// typing and emptying; the twin follows the text — and an input
    /// method's composition — exactly.
    @Test func theEmptyAreaTypesInTheStylesFontAndTheTwinFollowsTheText() throws {
        let style = CommentTextStyle(tokens: .studyLight, ink: VoiceTokens.studyLight.ink)
        let (hosting, area) = mount(Host(text: "", style: style, placeholder: "Write a comment…"))
        let textView = area.textView
        let twin = try #require(area.placeholderView)
        #expect((textView.typingAttributes[.font] as? NSFont) == style.font)
        textView.insertText("hello", replacementRange: NSRange(location: 0, length: 0))
        settle(hosting)
        #expect(twin.isHidden, "her words, not the placeholder")
        textView.selectAll(nil)
        textView.deleteBackward(nil)
        settle(hosting)
        #expect(!twin.isHidden, "emptied — the placeholder returns")
        #expect((textView.typingAttributes[.font] as? NSFont) == style.font,
                "and the empty area's caret is the style's line again")
        textView.setMarkedText(
            "か", selectedRange: NSRange(location: 1, length: 0),
            replacementRange: NSRange(location: NSNotFound, length: 0))
        #expect(twin.isHidden, "a composition in flight is text she is writing")
        textView.unmarkText()
        textView.selectAll(nil)
        textView.deleteBackward(nil)
        settle(hosting)
        #expect(!twin.isHidden)
    }

    /// A row is exactly its text plus the inset — the old ruler's 16 pt of
    /// dead air is gone — and grows by exactly a line.
    @Test(arguments: voices)
    func aRowIsItsTextWithNoDeadAir(voice: ThemeVoice) throws {
        let tokens = resolved(voice)
        let style = CommentTextStyle(tokens: tokens, ink: tokens.commentInk)
        let inset = CommentsPanelMetrics.textInset.height
        let (hosting, row) = mount(Host(
            text: "the ending is too loud", style: style, mark: tokens.commentPrefix, grows: true))
        let line = try #require(firstLine(row.textView, in: hosting))
        #expect(row.bounds.height == line.frame.height + 2 * inset)
        let (_, twoLines) = mount(Host(
            text: "one\ntwo", style: style, mark: tokens.commentPrefix, grows: true))
        #expect(twoLines.bounds.height == 2 * line.frame.height + 2 * inset)
    }

    /// Terminal's `// ` is a twin beside the text: its first BASELINE is the
    /// text's (the old SwiftUI label sat 8 pt below it — measured).
    @Test func theMarkSitsOnTheTextsFirstBaseline() throws {
        let tokens = VoiceTokens.terminalLight
        let (hosting, row) = mount(Host(
            text: "the ending is too loud",
            style: CommentTextStyle(tokens: tokens, ink: tokens.commentInk),
            mark: tokens.commentPrefix, grows: true))
        let mark = try #require(row.markView)
        let markLine = try #require(firstLine(mark, in: hosting))
        let textLine = try #require(firstLine(row.textView, in: hosting))
        #expect(markLine.baseline == textLine.baseline)
        #expect(markLine.frame.maxX <= textLine.frame.minX, "beside the text, never over it")
        #expect(Self.areas(in: hosting).count == 1)
        // Study has no mark: no twin at all.
        let (_, study) = mount(Host(
            text: "x", style: CommentTextStyle(tokens: .studyLight, ink: VoiceTokens.studyLight.ink),
            mark: VoiceTokens.studyLight.commentPrefix, grows: true))
        #expect(study.markView == nil)
    }

    /// The panel opens focused on the add area: its counted request, raised
    /// before the area has a window, is HELD and served on arrival — and the
    /// area REPORTS the caret's arrival and departure (the panel's `focus`).
    @Test func aFocusRequestBeforeAWindowIsHeldAndServedOnArrival() async throws {
        final class Log { var reports: [Bool] = [] }
        let log = Log()
        let (hosting, area) = mount(Host(
            text: "",
            style: CommentTextStyle(tokens: .terminalLight, ink: VoiceTokens.terminalLight.ink),
            placeholder: "Write a comment…", focusRequest: 1,
            onFocusChange: { log.reports.append($0) }))
        #expect(area.window == nil && log.reports.isEmpty, "no window yet — the request waits")
        let window = NSWindow(
            contentRect: NSRect(x: -20_000, y: -20_000, width: 400, height: 240),
            styleMask: [.borderless], backing: .buffered, defer: true)
        window.isReleasedWhenClosed = false
        defer {
            window.contentView = nil
            window.close()
        }
        window.contentView = hosting  // never ordered in
        await settleLettingTurnsPass(hosting)
        #expect(window.firstResponder === area.textView, "served on arrival")
        #expect(log.reports == [true])
        window.makeFirstResponder(nil)
        await settleLettingTurnsPass(hosting)
        #expect(log.reports == [true, false])
    }

    /// **RED ON OLD — a CRASH, in both the shipped `TextEditor` and this
    /// control before its fix** (measured offscreen, the record's U3-g; and
    /// the draft's desync below, red in both too): she
    /// files a comment (⌘⏎), the panel clears the add area PROGRAMMATICALLY,
    /// and ⌘Z then replayed typing-undo actions that name ranges of the OLD
    /// text against the now-empty string — `NSRangeException: Range {13, 9}
    /// out of bounds; string length 0`, an uncaught exception. The fix: each
    /// area owns its undo history (`undoManager(for:)`), and a programmatic
    /// replacement ends it. ⌘Z's road is `undo:` up the responder chain to
    /// the window, which undoes through the first responder's manager.
    @Test func undoAfterTheAreaIsClearedForHerCannotReplayTheOldText() async throws {
        let draft = UndoPinDraft()
        let hosting = NSHostingView(rootView: UndoPinHost(draft: draft))
        hosting.frame = NSRect(x: 0, y: 0, width: 400, height: 200)
        let window = NSWindow(
            contentRect: NSRect(x: -20_000, y: -20_000, width: 400, height: 200),
            styleMask: [.borderless], backing: .buffered, defer: true)
        window.isReleasedWhenClosed = false
        defer {
            window.contentView = nil
            window.close()
        }
        window.contentView = hosting  // never ordered in
        settle(hosting)
        let area = try #require(Self.areas(in: hosting).first)
        let textView = area.textView
        window.makeFirstResponder(textView)
        textView.insertText("first thought", replacementRange: textView.selectedRange())
        textView.breakUndoCoalescing()
        textView.insertText(" and more", replacementRange: textView.selectedRange())
        settle(hosting)
        #expect(draft.text == "first thought and more")
        #expect(textView.undoManager?.canUndo == true, "her typing is undoable while it is hers")

        // Filed: the panel's model clears the draft; the area adopts "".
        draft.text = ""
        settle(hosting)
        #expect(textView.string.isEmpty)
        #expect(textView.undoManager?.canUndo == false,
                "the words left the box — there is nothing in it to undo into")
        // ⌘Z's own road. On the old tree this line raised NSRangeException.
        _ = textView.tryToPerform(Selector(("undo:")), with: nil)
        settle(hosting)
        #expect(textView.string.isEmpty && draft.text.isEmpty)
        #expect(area.placeholderView?.isHidden == false)

        // Each area's history is its own: typing after the clear undoes alone
        // — and THE DRAFT FOLLOWS THE UNDO (the second half, RED ON OLD in
        // the shipped `TextEditor` too: AppKit sends no `textDidChange` for
        // an undo or a redo, so the box showed "" while the draft kept "new",
        // and ⌘⏎ would have filed the words she had undone).
        textView.insertText("new", replacementRange: textView.selectedRange())
        settle(hosting)
        _ = textView.tryToPerform(Selector(("undo:")), with: nil)
        settle(hosting)
        #expect(textView.string.isEmpty)
        #expect(draft.text.isEmpty, "the draft follows the undo")
        #expect(area.placeholderView?.isHidden == false)
        _ = textView.tryToPerform(Selector(("redo:")), with: nil)
        settle(hosting)
        #expect(textView.string == "new")
        #expect(draft.text == "new", "…and the redo")
        #expect(area.placeholderView?.isHidden == true)
    }

    /// ⎋ with nothing to undo is not the area's: `cancelOperation:` travels
    /// on to the host (the sheet's or popover's own close) — what SwiftUI's
    /// `PlatformTextView` did (measured: neither overrides it).
    @Test func escapeFallsThroughToTheHostsClose() {
        final class Catcher: NSResponder {
            var hits = 0
            override func cancelOperation(_ sender: Any?) { hits += 1 }
        }
        let (_, area) = mount(Host(
            text: "",
            style: CommentTextStyle(tokens: .terminalLight, ink: VoiceTokens.terminalLight.ink)))
        let catcher = Catcher()
        let saved = area.textView.nextResponder
        defer { area.textView.nextResponder = saved }
        area.textView.nextResponder = catcher
        area.textView.doCommand(by: #selector(NSResponder.cancelOperation(_:)))
        #expect(catcher.hits == 1)
    }

    /// Q-2, mounted: the REAL capture box lays its first line at its own
    /// named origin — the number both placeholders read.
    @Test(arguments: voices)
    func theCaptureBoxLaysItsFirstLineAtItsOwnOrigin(voice: ThemeVoice) throws {
        let tokens = resolved(voice)
        struct Box: View {
            let tokens: VoiceTokens
            @State var text = "x"
            var body: some View {
                CaptureTextView(
                    text: $text, style: CaptureTextStyle(tokens: tokens), maxHeight: 160,
                    onFile: {})
                    .frame(width: 300, alignment: .topLeading)
            }
        }
        let hosting = NSHostingView(rootView: Box(tokens: tokens))
        hosting.frame = NSRect(x: 0, y: 0, width: 300, height: 200)
        settle(hosting)
        func boxes(_ view: NSView) -> [CaptureNSTextView] {
            ((view as? CaptureNSTextView).map { [$0] } ?? []) + view.subviews.flatMap(boxes)
        }
        let box = try #require(boxes(hosting).first)
        let scroll = try #require(box.enclosingScrollView)
        let line = try #require(firstLine(box, in: scroll))
        #expect(line.frame.minY == CaptureTextView.firstLineOrigin.y)
        #expect(line.frame.minX == CaptureTextView.firstLineOrigin.x)
    }
}

// MARK: - The panel's words and refusals

@MainActor
@Suite("The comments panel's words and refusals (VX-179 U3)", .serialized)
struct CommentPanelWordsTests {
    /// Her no-shouty-caps rule, read both ways: every word the panel shows
    /// starts as a sentence does and never shouts.
    @Test func everyPanelWordIsSentenceCase() {
        let words = [
            CommentsPanelCopy.title, CommentsPanelCopy.close, CommentsPanelCopy.save,
            CommentsPanelCopy.revert, CommentsPanelCopy.delete, CommentsPanelCopy.restore,
            CommentsPanelCopy.add, CommentsPanelCopy.cancel, CommentsPanelCopy.deletedWord,
            CommentsPanelCopy.unsavedMark, CommentsPanelCopy.addPlaceholder,
            CommentsPanelCopy.deleteForeverHelp, CommentsPanelCopy.observationFailed,
            CommentsPanelCopy.sealed, CommentsPanelCopy.needsText, CommentsPanelCopy.emptied,
            CommentsPanelCopy.deleted, CommentsPanelCopy.restored,
            CommentsPanelRefusalCopy.commentGone, CommentsPanelRefusalCopy.commentAlreadyBack,
            CommentsPanelRefusalCopy.nothingToDeleteForever, CommentsPanelRefusalCopy.blockGone,
        ]
        for text in words {
            if let first = text.first(where: \.isLetter) {
                #expect(first.isUppercase, "starts as a sentence: \(text)")
            }
            let shouted = text.split(whereSeparator: { !$0.isLetter })
                .filter { $0.count > 1 && $0.allSatisfy(\.isUppercase) }
            #expect(shouted.isEmpty, "no capitalised-for-emphasis word in \(text)")
        }
        #expect(CommentsPanelCopy.deletedFold(count: 2, open: false) == "▸ Deleted (2)")
        #expect(CommentsPanelCopy.deletedFold(count: 1, open: true) == "▾ Deleted (1)")
    }

    /// O-3 as a table: every case the panel can meet is words — never the raw
    /// enum, never an id.
    @Test func aRefusalIsAlwaysWords() {
        let cases: [(OperationError, String)] = [
            (.lockedPost(id: "post-1"), CommentsPanelCopy.sealed),
            (.invalidCommentText, CommentsPanelCopy.needsText),
            (.commentNotFound(id: "c-1"), CommentsPanelRefusalCopy.commentGone),
            (.commentNotDeleted(id: "c-1"), CommentsPanelRefusalCopy.commentAlreadyBack),
            (.purgeTargetNotDeleted(table: "block_comment", id: "c-1"),
             CommentsPanelRefusalCopy.nothingToDeleteForever),
            (.blockNotFound(id: "b-1"), CommentsPanelRefusalCopy.blockGone),
        ]
        for (error, words) in cases {
            let spoken = CommentsPanelRefusalCopy.message(for: error)
            #expect(spoken == words)
            #expect(!spoken.contains("Refused:") && !spoken.contains("-1"), "\(spoken)")
        }
        // Everything else is the app's ONE vocabulary.
        let other = OperationError.archivedVariant(id: "v-1")
        #expect(CommentsPanelRefusalCopy.message(for: other) == OpsRefusalCopy.message(for: other))
    }

    private func adopt(_ panel: CommentsPanelModel, _ h: EditorHarness) async throws {
        let blockID = panel.blockID
        let snapshot = try await h.database.read { db in
            CommentsPanelModel.Snapshot(
                live: try Queries.blockComments(db, blockID: blockID),
                deleted: try Queries.deletedBlockComments(db, blockID: blockID))
        }
        panel.adopt(snapshot)
    }

    /// RED ON OLD (O-3, through the real operations): the panel's race
    /// refusals spoke `Refused: commentNotDeleted(id: "…")`,
    /// `Refused: purgeTargetNotDeleted(…)` and `Refused: commentNotFound(…)`
    /// — a raw enum with an id in it, in the alarm register. Behavioural
    /// revert: restore the `default: "Refused: \(error)"` arm in `perform`.
    @Test func thePanelsRacesSpeakWordsNotTheEnum() async throws {
        try await withEditor(seedBlocks: ["First block."]) { h in
            let blockID = try h.storeSlots()[0].blockID
            let panel = CommentsPanelModel(session: h.session, blockID: blockID)
            await panel.add("a note")
            try await adopt(panel, h)
            let id = panel.comments[0].id

            // Restore of a comment that is already live (a second press, or
            // a restore elsewhere): `commentNotDeleted`.
            await panel.restore(id)
            #expect(panel.status?.isRefusal == true)
            #expect(panel.statusMessage == CommentsPanelRefusalCopy.commentAlreadyBack)

            // "Delete forever" on a comment restored between the listing and
            // the confirm: `purgeTargetNotDeleted`.
            await panel.delete(id)
            try await adopt(panel, h)
            panel.requestDeleteForever(id)
            try await h.session.runner.run { ops in try ops.restoreBlockComment(id) }
            await panel.deleteForever(id)
            #expect(panel.statusMessage == CommentsPanelRefusalCopy.nothingToDeleteForever)

            // A comment gone from the store entirely: `commentNotFound`.
            await panel.restore("no-such-comment")
            #expect(panel.statusMessage == CommentsPanelRefusalCopy.commentGone)
            #expect(!(panel.statusMessage ?? "").contains("Refused:"))
        }
    }
}

// MARK: - FIX LEG 2 (the walk's F-W-3/F-W-4, ladder R1-2)

/// **The walk's three panel findings, pinned through the REAL panel** (the
/// record's "U3 FIX LEG 2": traces, mechanisms, red-on-old). Each cell was
/// replayed offscreen against the pre-fix module first and is RED there by
/// behaviour, not only by compile.
///
/// Hosting: the panel windows are never ordered in; a popover needs a visible
/// anchor, so its anchor is ordered in OFF-DISPLAY at alpha 0 and the
/// popover's own window is set alpha 0 the turn it appears. Every wait lets
/// main-queue turns pass (the runner's body is a main-queue job — the first
/// fix leg's lesson): the control defers its reveal and its reports by one turn.
@MainActor
@Suite("The comments panel's fix leg 2 — F-W-3, F-W-4, R1-2 (VX-179)", .serialized)
struct CommentPanelFixLeg2Tests {
    private static let longComments = [
        "First note on the short block.",
        "A second, much longer note that will wrap across several lines inside the card, because "
            + "part of what the walk checks is that a long comment reads whole inside the stacked "
            + "entry rather than truncating at four lines the way the old joined label did.",
        "A third note, also of some length so the list is certainly capped.",
        "Last: short.",
    ]

    private static func areas(in view: NSView) -> [CommentTextAreaView] {
        ((view as? CommentTextAreaView).map { [$0] } ?? []) + view.subviews.flatMap { areas(in: $0) }
    }

    /// One turn: the queued app events this cell posted are dispatched, then
    /// the main actor is released so deferred main-queue work runs.
    private func turns(_ count: Int = 20) async {
        for _ in 0..<count {
            while let event = NSApp.nextEvent(
                matching: [.keyDown, .leftMouseDown, .leftMouseUp], until: nil,
                inMode: .default, dequeue: true)
            {
                NSApp.sendEvent(event)
            }
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
        }
    }

    private func key(_ characters: String, keyCode: UInt16, to window: NSWindow) async {
        NSApp.postEvent(NSEvent.keyEvent(
            with: .keyDown, location: .zero, modifierFlags: [],
            timestamp: ProcessInfo.processInfo.systemUptime, windowNumber: window.windowNumber,
            context: nil, characters: characters, charactersIgnoringModifiers: characters,
            isARepeat: false, keyCode: keyCode)!, atStart: false)
        await turns()
    }

    private func seed(_ h: EditorHarness, _ comments: [String]) async throws -> (String, CommentsPanelModel) {
        let blockID = try h.storeSlots()[0].blockID
        let model = CommentsPanelModel(session: h.session, blockID: blockID)
        for comment in comments { await model.add(comment) }
        return (blockID, model)
    }

    /// The panel in a REAL popover (AppKit's — the product's SwiftUI
    /// `.popover` is this same `NSPopover` underneath; both reproduced the
    /// two popover defects, the record's traces).
    @MainActor
    private struct PopoverHost {
        let popover: NSPopover
        let anchor: NSWindow
        let window: NSWindow
        let root: NSView
        func tearDown() {
            if popover.isShown { popover.close() }
            anchor.orderOut(nil)
        }
    }

    private func popover(_ h: EditorHarness, _ blockID: String, _ model: CommentsPanelModel) async throws
        -> PopoverHost
    {
        let anchor = NSWindow(
            contentRect: NSRect(x: -20_000, y: -20_000, width: 300, height: 200),
            styleMask: [.borderless], backing: .buffered, defer: false)
        anchor.isReleasedWhenClosed = false
        anchor.alphaValue = 0
        anchor.orderFront(nil)  // off every display
        let popover = NSPopover()
        popover.animates = false
        popover.behavior = .transient
        let controller = NSHostingController(
            rootView: CommentsPanel(session: h.session, blockID: blockID, model: model))
        popover.contentViewController = controller
        popover.show(
            relativeTo: NSRect(x: 100, y: 100, width: 10, height: 10), of: anchor.contentView!,
            preferredEdge: .minY)
        let window = try #require(controller.view.window)
        window.alphaValue = 0
        await turns(40)
        return PopoverHost(popover: popover, anchor: anchor, window: window, root: controller.view)
    }

    /// **F-W-3 — RED ON OLD.** The capped list never revealed the row being
    /// edited, so the dirty face under its text — "Unsaved · ⌘⏎", Save,
    /// Revert — sat below the list's visible edge (the walk's `u34-dirty`).
    /// The edited row now stays WHOLLY visible: when its caret arrives, and
    /// while it is typed into and grows.
    @Test func theEditedRowAndItsStampLineStayInViewInACappedList() async throws {
        try await withEditor(seedBlocks: ["A block."]) { h in
            let (blockID, model) = try await seed(h, Self.longComments)
            let hosting = NSHostingView(
                rootView: CommentsPanel(session: h.session, blockID: blockID, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: 470, height: 440)
            let window = NSWindow(
                contentRect: NSRect(x: -30_000, y: -30_000, width: 470, height: 440),
                styleMask: [.borderless], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.contentView = nil
                window.close()
            }
            window.contentView = hosting  // never ordered in
            await turns(40)
            let last = try #require(Self.areas(in: hosting).filter { $0.placeholderView == nil }.last)
            let list = try #require(last.textView.enclosingScrollView)
            let document = try #require(list.documentView)
            @MainActor func stampLineInView() -> Bool {
                let visible = list.documentVisibleRect
                let row = last.convert(last.bounds, to: document)
                // the stamp line sits stampGap under the area and is at least 12 pt tall
                return row.minY >= visible.minY - 0.5
                    && row.maxY + CommentsPanelMetrics.stampGap + 12 <= visible.maxY + 0.5
            }
            #expect(document.frame.height > list.contentView.bounds.height, "premise: the list is capped")
            #expect(!stampLineInView(), "premise: at rest the last row's stamp line is out of view")

            window.makeFirstResponder(last.textView)
            await turns()
            #expect(stampLineInView(), "the caret arriving reveals the row and its stamp line")

            last.textView.setSelectedRange(
                NSRange(location: (last.textView.string as NSString).length, length: 0))
            last.textView.insertText(
                " — edited, and grown by a long tail that wraps onto a second line inside the row",
                replacementRange: last.textView.selectedRange())
            last.textView.scrollRangeToVisible(last.textView.selectedRange())  // typing's own call
            await turns()
            let lastID = try #require(model.comments.last?.id)
            #expect(model.isDirty(lastID), "premise: the row is dirty")
            #expect(stampLineInView(), "dirty and grown, its stamp line stays in view")
        }
    }

    /// **F-W-4 — RED ON OLD.** In a popover the keyboard's events are
    /// addressed to the PARENT window and AppKit delivers them into the
    /// popover; the panel's monitor claimed only its own window's, so ⎋ went
    /// to `cancelOperation:` and closed the popover with the draft in it. The
    /// ladder holds now: the first ⎋ clears the draft, the second closes.
    @Test func escapeInAPopoverClearsTheDraftFirstThenCloses() async throws {
        try await withEditor(seedBlocks: ["A block."]) { h in
            let (blockID, model) = try await seed(h, ["First note."])
            let host = try await popover(h, blockID, model)
            defer { host.tearDown() }
            let composer = try #require(Self.areas(in: host.root).first { $0.placeholderView != nil })
            if host.window.firstResponder !== composer.textView {
                host.window.makeFirstResponder(composer.textView)
                await turns()
            }
            await key("x", keyCode: 7, to: host.anchor)
            #expect(model.addDraft == "x", "premise: a key addressed to the parent lands in the composer")
            await key("\u{1b}", keyCode: 53, to: host.anchor)
            #expect(model.addDraft.isEmpty, "the first ⎋ clears the draft")
            #expect(host.popover.isShown, "…and the popover stays")
            await key("\u{1b}", keyCode: 53, to: host.anchor)
            #expect(!host.popover.isShown, "with nothing to clear, ⎋ closes it")
        }
    }

    /// The rule behind F-W-4, as a table: a key event is the panel's to
    /// claim when it is addressed to the panel's window or to that window's
    /// parent (a popover's — AppKit delivers those into the popover).
    @Test func thePanelClaimsKeysAddressedToItsWindowOrItsParent() {
        let panel = NSWindow(), parent = NSWindow(), other = NSWindow()
        #expect(CommentPanelKeys.claims(eventWindow: panel, panelWindow: panel))
        #expect(!CommentPanelKeys.claims(eventWindow: parent, panelWindow: panel),
                "no parent relationship, no claim")
        parent.addChildWindow(panel, ordered: .above)
        defer { parent.removeChildWindow(panel) }
        #expect(CommentPanelKeys.claims(eventWindow: parent, panelWindow: panel))
        #expect(!CommentPanelKeys.claims(eventWindow: other, panelWindow: panel))
        #expect(!CommentPanelKeys.claims(eventWindow: nil, panelWindow: panel))
    }

    /// **R1-2 — RED ON OLD (the ladder's finding, AGREED).** Dismissing a
    /// popover never tore the panel down — no `.onDisappear`, no resign — so a
    /// dirty in-place edit died with the model. The popover's closing now
    /// saves it, exactly as the panel's leaving was always meant to.
    @Test func closingThePopoverSavesADirtyInPlaceEdit() async throws {
        try await withEditor(seedBlocks: ["A block."]) { h in
            let (blockID, model) = try await seed(h, ["First note."])
            let host = try await popover(h, blockID, model)
            defer { host.tearDown() }
            let row = try #require(Self.areas(in: host.root).first { $0.placeholderView == nil })
            host.window.makeFirstResponder(row.textView)
            await turns()
            row.textView.setSelectedRange(
                NSRange(location: (row.textView.string as NSString).length, length: 0))
            row.textView.insertText(" — edited in the popover", replacementRange: row.textView.selectedRange())
            await turns()
            #expect(model.dirtyCommentIDs.count == 1, "premise: one dirty edit")
            host.popover.close()
            await turns(60)
            let stored = try await h.database.read { db in
                try Queries.blockComments(db, blockID: blockID).map(\.text)
            }
            #expect(stored == ["First note. — edited in the popover"], "the popover's closing saved it")
        }
    }
}
