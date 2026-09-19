//
//  CaptureTextView.swift
//  Variorum (Mac)
//
//  13u3 UNIT C — THE MAC'S ONE CAPTURE SURFACE (her ruling R-13u-4, the
//  13u1 sitting, verbatim: *"the capture surface holds MANY paragraphs; ⏎
//  FILES the note, ⇧⏎ adds a paragraph; the hand-off segments through
//  `importPost`'s bulk rule"*).
//
//  ── WHY THIS IS ONE COMPONENT AND NOT TWO KEY HANDLERS ──────────────────
//  The Mac has TWO capture doors — the shelf/Library quick-entry bar (R3)
//  and the floating quick-note pad (13f W5) — and before this unit they
//  disagreed about the Return key in the deepest possible way: the bar's ⏎
//  FILED (`.onSubmit`) and the pad's ⏎ TYPED A NEWLINE (its own header said
//  so). One ruling now governs both, and a rule that governs two surfaces
//  through two mechanisms is the forked-brains class this codebase keeps
//  paying for. So both hosts compose ONE view, whose `keyDown` asks ONE
//  pure rule (`CaptureKeys`).
//
//  ── WHY APPKIT, WHEN BOTH HOSTS USED SWIFTUI CONTROLS ───────────────────
//  Three reasons, in order of weight:
//
//  1. **⏎ and ⇧⏎ cannot be told apart anywhere else.** AppKit gives ⇧⏎ no
//     binding of its own — both keys dispatch `insertNewline:` and both type
//     a plain LF (measured and pinned in `ReturnKeyTraceTests`;
//     `EditorTextView.isSoftNewlineKey` carries the same lesson for the
//     editor's own gesture). The ONLY place the two differ is the key event,
//     and neither `TextEditor` nor `TextField` hands one over.
//  2. **The caret must not change what the keys mean.** The phone's
//     2026-08-23 lost-prose defect (master plan `### 13u` item (9); her
//     words: *"complete disaster, lost prose class of bug"*) was exactly
//     this: moving the caret into an earlier paragraph put the box in a
//     state where ⏎ stopped filing and started typing newlines, and the
//     hand-off then dropped the tail. Here the caret is AppKit's business
//     and the key rule never reads it — `CaptureKeys.act` takes an event and
//     nothing else — so the Mac twin of that state cannot be constructed.
//  3. **It is pinnable.** A hosted window plus a synthesized key event is a
//     road this repo already drives (`ReturnKeyTraceTests`), so the contract
//     is held by tests rather than by a walk alone.
//
//  **This is NOT a second text surface in P-3's sense.** SwiftUI's
//  `TextEditor` IS an `NSTextView`, so nothing is added that was not already
//  mounted; what changes is who owns `keyDown`. The capture box shows text
//  that is in no block and in no store: no identity attributes, no
//  `BlockRangeIndex`, no `PaneTextAuthority`, no `EditorRouter` claim, no
//  liveness ring. P-3's invariants are not extended here; they are still
//  simply not engaged (the quick-note pad's own header has said this since
//  13f W5, and it stays true).
//

import AppKit
import SwiftUI

// MARK: - The keys (the ONE rule both capture doors ask)

/// **⏎ FILES · ⇧⏎ ADDS A PARAGRAPH** — her R-13u-4, as a value.
///
/// Total and event-shaped: everything this does not claim returns nil and
/// reaches the text view untouched, which is how ⌥⏎, ⌃⏎ (AppKit's own
/// `insertLineBreak:`) and every ordinary character keep working.
nonisolated enum CaptureKeys {
    enum Act: Equatable {
        /// Plain ⏎ — hand the whole capture off. What "file" MEANS is the
        /// host's (the pad files and closes; the bar files and opens the
        /// note); this rule only says WHICH key.
        case file
        /// ⇧⏎ — a paragraph inside the capture. The act is AppKit's own
        /// `insertNewline:` at the caret: the surface lets the key through
        /// rather than inserting a newline itself, so the paragraph lands
        /// where her caret is and nowhere else.
        case paragraph
    }

    /// The four modifiers that DISTINGUISH gestures — never the whole
    /// device-independent word. AppKit sets `.capsLock` on every key event
    /// while caps lock is LATCHED and `.numericPad`/`.function` on every
    /// keypad key: state and hardware flags, not meaning. Testing against
    /// the whole word made the editor's own ⇧⏎ gesture silently dead with
    /// caps lock on (13d cold review, F-2) and its keypad arm unreachable
    /// from real hardware. `EditorTextView.isSoftNewlineKey` carries this
    /// same mask for the editor's soft newline; the two are pinned to agree
    /// (`CaptureKeysTests.theCaptureRuleAndTheEditorsSoftNewlineAgree`)
    /// rather than reaching across the layer into each other.
    static let meaningful: NSEvent.ModifierFlags = [.shift, .command, .control, .option]

    /// Return, and the full-size keyboard's Enter beside it.
    private static func isReturnKey(_ event: NSEvent) -> Bool {
        let characters = event.charactersIgnoringModifiers ?? ""
        return characters == "\r" || characters == "\u{3}"
    }

    static func act(for event: NSEvent) -> Act? {
        guard isReturnKey(event) else { return nil }
        switch event.modifierFlags.intersection(meaningful) {
        case []: return .file
        case [.shift]: return .paragraph
        default: return nil
        }
    }
}

// MARK: - The look (the voice, as AppKit values)

/// What a capture box wears, derived from the tokens its host already
/// resolved — never chosen here. One value so a host cannot half-dress it.
struct CaptureTextStyle: Equatable {
    let font: NSFont
    /// The ONE dynamic per-voice prose ink (18j): the same object answers
    /// light and dark, so an appearance change costs no write at all.
    let ink: NSColor
    let caret: NSColor

    /// The voice's writing font and ink, through the roads that already own
    /// them. `EditorTypography.resolve` returns exactly what `VoiceTokens`'
    /// `body` renders in both voices (Terminal: monospaced 14 · Study: Iowan
    /// Old Style 16), so this is the same face the capture boxes have always
    /// drawn — asked of the one brain instead of a second table.
    @MainActor
    init(tokens: VoiceTokens) {
        self.font = EditorTypography.resolve(voice: tokens.voice, inlineComments: false).font
        self.ink = EditorTypography.ink(for: tokens.voice)
        self.caret = NSColor(tokens.accent)
    }
}

// MARK: - The surface

/// A plain writing box for a CAPTURE: many paragraphs, ⏎ files, ⇧⏎ makes a
/// paragraph, and the host draws everything around it (its own placeholder,
/// its own frame, its own chip and its own refusal line).
///
/// `maxHeight` is the bound her ruling's "holds many paragraphs" needs on a
/// bar that lives in a busy window: the box grows with its paragraphs up to
/// that height and then scrolls. Nil means "take the space you are given"
/// — the pad, which is a window of its own.
struct CaptureTextView: NSViewRepresentable {
    @Binding var text: String
    let style: CaptureTextStyle
    /// Grows to this and then scrolls; nil fills the offered space.
    var maxHeight: CGFloat?
    /// The box is never shorter than this, so an empty capture still reads
    /// as somewhere to write.
    var minHeight: CGFloat = 22
    /// Raised by the host to put the caret here (the shelf's autofocus, a
    /// click on the box's padding). Lowering it never takes focus away.
    var wantsFocus = false
    /// Whether the caret is in this box, for the host's own chrome (the
    /// Terminal voice's blinking block cursor stands down when it is).
    var onFocusChange: ((Bool) -> Void)?
    /// Plain ⏎ — the host decides what filing means.
    let onFile: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeNSView(context: Context) -> NSScrollView {
        // TEXTKIT2 §4's first two defensive practices: opt into TK2
        // EXPLICITLY at init, and never touch a TK1 API afterwards.
        let view = CaptureNSTextView(usingTextLayoutManager: true)
        view.delegate = context.coordinator
        view.onFile = { [weak coordinator = context.coordinator] in
            coordinator?.parent.onFile()
        }
        view.isRichText = false
        view.allowsUndo = true
        view.isVerticallyResizable = true
        view.isHorizontallyResizable = false
        view.autoresizingMask = [.width]
        view.minSize = NSSize(width: 0, height: 0)
        view.maxSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude)
        view.textContainerInset = NSSize(width: 0, height: 2)
        view.textContainer?.widthTracksTextView = true
        view.textContainer?.size = NSSize(
            width: 0, height: CGFloat.greatestFiniteMagnitude)
        view.drawsBackground = false
        // Spelling follows the app's ONE this-Mac setting (default `off`,
        // the shipped behaviour) rather than a second answer invented here.
        SpellcheckLevel.current.apply(to: view)
        context.coordinator.apply(style, to: view)

        // TEXTKIT2 §4's third practice: a silent TK1 downgrade must never
        // pass unnoticed. There is no room for a banner in a capture box, so
        // the canary logs and (in DEBUG) stops — the developer alarm the
        // note asks for.
        context.coordinator.canary.arm(for: view)

        let scroll = NSScrollView()
        scroll.documentView = view
        scroll.hasVerticalScroller = false
        scroll.drawsBackground = false
        scroll.autohidesScrollers = true
        context.coordinator.view = view
        return scroll
    }

    func updateNSView(_ scroll: NSScrollView, context: Context) {
        guard let view = context.coordinator.view else { return }
        context.coordinator.parent = self
        if view.string != text {
            // A programmatic adopt keeps the caret where it can (the host
            // clears the box on a completed hand-off; nothing else writes).
            let selected = view.selectedRange()
            view.string = text
            let end = (text as NSString).length
            view.setSelectedRange(
                NSRange(location: min(selected.location, end), length: 0))
        }
        context.coordinator.apply(style, to: view)
        if wantsFocus { context.coordinator.takeFocus() }
    }

    func sizeThatFits(
        _ proposal: ProposedViewSize, nsView: NSScrollView, context: Context
    ) -> CGSize? {
        guard let maxHeight, let view = context.coordinator.view else { return nil }
        let width = proposal.width ?? nsView.bounds.width
        guard width > 0 else { return nil }
        // The container tracks the view, so the measurement is honest only
        // once the width it is about to be laid out at is in place — the
        // width-gated remeasure `PaneSurface` established.
        view.frame.size.width = width
        view.textContainer?.size = NSSize(
            width: max(width - view.textContainerInset.width * 2, 1),
            height: .greatestFiniteMagnitude)
        let measured = PaneMeasurement.height(of: view)
        return CGSize(
            width: width,
            height: Self.height(measured: measured, min: minHeight, max: maxHeight))
    }

    /// The box's height from what its text measures — grow with the
    /// paragraphs, never below the floor, never past the bound. Pulled out
    /// of `sizeThatFits` because a capture box's whole growth rule is this
    /// one line and a rule inside a layout callback cannot be pinned.
    nonisolated static func height(
        measured: CGFloat, min floor: CGFloat, max ceiling: CGFloat
    ) -> CGFloat {
        Swift.min(Swift.max(measured, floor), Swift.max(floor, ceiling))
    }

    static func dismantleNSView(_ scroll: NSScrollView, coordinator: Coordinator) {
        coordinator.canary.disarm()
    }

    @MainActor
    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: CaptureTextView
        weak var view: CaptureNSTextView?
        let canary = FallbackCanary()
        private var appliedStyle: CaptureTextStyle?
        private var tookFocus = false

        init(_ parent: CaptureTextView) { self.parent = parent }

        /// WRITE-GATED, the A47c lesson: an unguarded property write on a
        /// live text view is never free, and `updateNSView` runs often.
        func apply(_ style: CaptureTextStyle, to view: CaptureNSTextView) {
            guard appliedStyle != style else { return }
            appliedStyle = style
            view.font = style.font
            view.textColor = style.ink
            view.insertionPointColor = style.caret
        }

        func takeFocus() {
            guard !tookFocus, let view, let window = view.window else { return }
            tookFocus = true
            window.makeFirstResponder(view)
        }

        func textDidChange(_ notification: Notification) {
            guard let view else { return }
            parent.text = view.string
        }

        func textDidBeginEditing(_ notification: Notification) {
            parent.onFocusChange?(true)
        }

        func textDidEndEditing(_ notification: Notification) {
            tookFocus = false
            parent.onFocusChange?(false)
        }
    }
}

/// The text view itself: ONE override, and it asks the pure rule.
///
/// `paragraph` and "not ours" take the SAME road deliberately — AppKit's own
/// `insertNewline:` at the caret. A surface that inserted the newline itself
/// would have to know where the caret is, and "where the caret is" is
/// precisely the state the phone's lost-prose defect was made of.
final class CaptureNSTextView: NSTextView {
    /// Plain ⏎ — what filing means belongs to the host.
    var onFile: (() -> Void)?

    override func keyDown(with event: NSEvent) {
        switch CaptureKeys.act(for: event) {
        case .file:
            onFile?()
        case .paragraph, nil:
            super.keyDown(with: event)
        }
    }
}
