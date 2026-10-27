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

// MARK: - The opening ask (VX-326 — the ONE rule the box's opening ask obeys)

/// **The shell's opening ask for the caret, decided once** (VX-326). When a
/// shell opens on the Bookcase it asks for the caret in the quick entry (R102:
/// *"the shelf opens with the cursor already IN the bar"*), and at launch that
/// ask arrives BEFORE the box is in its window — the opening face is swapped
/// for the shell, and SwiftUI puts the box in its window a pass after the
/// bar's `.task` has asked (measured headlessly on the real module; the VX-282
/// record § U6). The counted request (`takeFocus`) drops an ask it cannot
/// serve; this one WAITS for the box's arrival, and then decides ONCE, on the
/// facts of the box's own window:
///
/// - the keyboard is free — the window itself is the first responder (or
///   nothing is) — and no sheet is on the window: **take** it;
/// - anything else holds this window's keyboard (a field, another text, a
///   sheet): **drop** the ask — never steal, never serve it later;
/// - the box already holds it: nothing to do.
///
/// Other windows are never consulted: taking this window's first responder
/// takes nothing from them (a key note window keeps its editor and stays key),
/// and the caret is live the moment this window is key.
nonisolated enum CaptureOpeningFocus {
    enum Holder: Equatable {
        /// The window itself, or nothing: the keyboard is free.
        case nobody
        case theBox
        case someoneElse
    }

    struct Facts: Equatable {
        var inWindow: Bool
        var keyboard: Holder
        var sheetOnWindow: Bool
    }

    enum Verdict: Equatable {
        /// Not in a window yet — the arrival decides.
        case wait
        case take
        /// Something else holds this window's keyboard: the ask is spent.
        case drop
        /// The box already holds the keyboard: the ask is spent, nothing done.
        case alreadyHeld
    }

    static func verdict(_ facts: Facts) -> Verdict {
        guard facts.inWindow else { return .wait }
        switch facts.keyboard {
        case .theBox: return .alreadyHeld
        case .someoneElse: return .drop
        case .nobody: return facts.sheetOnWindow ? .drop : .take
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
    /// A one-shot focus REQUEST, counted rather than flagged: 0 is "never
    /// asked", and any change puts the caret here. A counter rather than a
    /// Bool because the two askers are different in kind — the shelf asks
    /// once when the bar appears, and a click on the box's padding asks
    /// again later — and a Bool would have to be lowered by the host
    /// between them, which is a second piece of state to get wrong.
    var focusRequest = 0
    /// **The OPENING ask** (VX-326), counted like `focusRequest` but obeying
    /// `CaptureOpeningFocus`: it waits for the box to be in its window, then
    /// takes the caret only if this window's keyboard is free — never
    /// stealing, never served late. Raised by EVERY Bookcase mount of the
    /// quick entry since VX-332 (her "focus on every return" — VX-326 raised
    /// it once per shell); 0 everywhere else.
    var openingFocusRequest = 0
    /// Whether the caret is in this box, for the host's own chrome (the
    /// Terminal voice's blinking block cursor stands down when it is).
    /// Delivered on the next main-queue turn, never inside a view update
    /// (the B2 ladder's NIT-1 — the host may write `@State` here).
    var onFocusChange: ((Bool) -> Void)?
    /// Plain ⏎ — the host decides what filing means.
    let onFile: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    // MARK: The box's own text geometry (VX-179 U3, F-U3-1 ruling Q-2)

    /// **The box's text inset — OWNED here, and read by every host that draws
    /// something on the text's first line.** Both hosts draw their own
    /// placeholder behind the box (the box draws none), and a placeholder is
    /// only right if it sits exactly where her first typed line will. VX-179
    /// U3 measured the bar drifting by this very number: its `ZStack`
    /// placeholder sat at the box's top while the text sat 2 pt lower, so the
    /// words dropped 2 pt the moment she typed (baseline 26 vs 28 in
    /// Terminal, 29 vs 31 in Study). The pad derived the same 2 by hand. One
    /// named number, read by the box and by both placeholders, makes the
    /// agreement structural rather than remembered.
    nonisolated static let textInset = NSSize(width: 0, height: 2)
    /// The container's own padding: none (WALK FIND 1, in `makeNSView` — the
    /// host owns the box's insets).
    nonisolated static let lineFragmentPadding: CGFloat = 0
    /// Where the box's first line starts, inside the box — the point a host's
    /// placeholder must sit at. TK2 lays the first line fragment at the
    /// container's origin (`textContainerInset`) plus the padding.
    nonisolated static var firstLineOrigin: CGPoint {
        CGPoint(x: textInset.width + lineFragmentPadding, y: textInset.height)
    }

    func makeNSView(context: Context) -> NSScrollView {
        // TEXTKIT2 §4's first two defensive practices: opt into TK2
        // EXPLICITLY at init, and never touch a TK1 API afterwards.
        let view = CaptureNSTextView(usingTextLayoutManager: true)
        // Named before anything can ask the delegate for this view's undo
        // manager (VX-193 — `Coordinator.undoManager(for:)` answers only
        // for its own view).
        context.coordinator.view = view
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
        view.textContainerInset = Self.textInset
        // WALK FIND 1: `NSTextContainer` ships a 5 pt `lineFragmentPadding`,
        // so the typed text sat a few points right of the placeholder the
        // host draws behind it — the words moved sideways the moment she
        // started typing. The host owns this box's insets; the container
        // owns none.
        view.textContainer?.lineFragmentPadding = Self.lineFragmentPadding
        view.textContainer?.widthTracksTextView = true
        view.textContainer?.size = NSSize(
            width: 0, height: CGFloat.greatestFiniteMagnitude)
        view.drawsBackground = false
        // 17y B2 (m): where the CARET is, reported from the box's own
        // first-responder changes — the one truth (see `onCaretChange`).
        // Delivered ASYNC (the B2 ladder's NIT-1): a focus request serviced
        // during `updateNSView` (`takeFocus` → `makeFirstResponder` →
        // `becomeFirstResponder`) would otherwise write the host's `@State`
        // inside SwiftUI's view update (the state-during-update class). The
        // MEASURED roads are the bar's re-raises — the padding tap and the
        // title chip (`QuickEntryBar`). The Bookcase's `.task` raise reaches
        // `updateNSView` with the box still WINDOWLESS whenever the Bookcase
        // is mounted into a window already showing something (a launch's swap,
        // a navigation back) — F-FR-1, traced at VX-326 — so `takeFocus` would
        // drop it; every Bookcase mount's ask takes the waiting road instead
        // (`armOpeningFocus` — VX-326 at launch, VX-332 on every return). The main queue is FIFO, so the reports keep
        // their order and the last one delivered is the caret's latest truth.
        view.onCaretChange = { [weak coordinator = context.coordinator] inBox in
            DispatchQueue.main.async {
                coordinator?.parent.onFocusChange?(inBox)
            }
        }
        // A request already raised when the box is MADE (the pad's 1) is
        // served once, on its first arrival. A request raised later (a click
        // on the padding, the title chip) takes the `takeFocus` road in
        // `updateNSView` (VX-112's trace: the bar's request is always raised a
        // turn after this, so its flag is false); a Bookcase mount's ask takes
        // `armOpeningFocus` (VX-326; every mount since VX-332).
        view.wantsInitialFocus = focusRequest > 0
        context.coordinator.lastFocusRequest = focusRequest
        // A box MADE after an opening ask was raised does not inherit it: the
        // ask belonged to the box it was raised at (served once — VX-326).
        context.coordinator.lastOpeningFocusRequest = openingFocusRequest
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
        return scroll
    }

    func updateNSView(_ scroll: NSScrollView, context: Context) {
        guard let view = context.coordinator.view else { return }
        context.coordinator.parent = self
        if view.string != text {
            context.coordinator.adopt(text, into: view)
        }
        context.coordinator.apply(style, to: view)
        if focusRequest != context.coordinator.lastFocusRequest {
            context.coordinator.lastFocusRequest = focusRequest
            context.coordinator.takeFocus()
        }
        if openingFocusRequest != context.coordinator.lastOpeningFocusRequest {
            context.coordinator.lastOpeningFocusRequest = openingFocusRequest
            view.armOpeningFocus()
        }
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
        coordinator.stopObservingUndo()
    }

    @MainActor
    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: CaptureTextView
        weak var view: CaptureNSTextView?
        let canary = FallbackCanary()
        var lastFocusRequest = 0
        var lastOpeningFocusRequest = 0
        private var appliedStyle: CaptureTextStyle?

        /// **The box's own undo history** (VX-193 — VX-179 U3-g's mechanism,
        /// carried from the comments panel's `CommentTextArea`). The defect it
        /// fixes, real IN USE: while the box's typing history was the WINDOW's
        /// (the text view's default), a programmatic clear — a completed
        /// hand-off, or an EMPTY filing that leaves the box on screen with the
        /// caret in it — left that history standing, so ⌘Z then replayed
        /// ranges of the old text against the new one: `NSRangeException`
        /// from `NSUndoTyping undoRedo:`, reproduced on the pre-fix build at
        /// the VX-282 U4 walk (AppKit caught it; the box's undo was dead
        /// afterwards). Undo is PER BOX and a programmatic replacement ends it
        /// (P-VX179-U3-4, carried — PROVISIONAL here as P-U4-1): ⌘Z in the box
        /// undoes the box's own typing and nothing that other text left on the
        /// window's stack. ⌘Z still arrives by AppKit's road — `undo:` travels
        /// to the window, which undoes through the first responder's
        /// `undoManager`, answered here.
        let undoHistory = UndoManager()
        private var undoObservers: [NSObjectProtocol] = []

        init(_ parent: CaptureTextView) {
            self.parent = parent
            super.init()
            // **A BELT: an undo or a redo is an edit the binding must hear.**
            // In the running app a real ⌘Z / ⇧⌘Z already kept the binding in
            // step on the pre-fix build (the VX-282 U4 walk), but where undo
            // is driven outside the live event road — offscreen, in the test
            // host — AppKit posts no `textDidChange` for either (measured at
            // VX-179 U3-g and VX-193; why the live road differs did not
            // converge headlessly). VX-179's comments panel carries the same
            // pair on the same basis. This manager is the box's own, so its two
            // notifications are exactly "this box's text was undone or redone";
            // they arrive SYNCHRONOUSLY inside `undo()` (measured), so no view
            // update can run in between and re-adopt a stale binding over the
            // undo; and the write is guarded — when the binding already
            // follows, nothing is written.
            for name in [Notification.Name.NSUndoManagerDidUndoChange,
                         .NSUndoManagerDidRedoChange] {
                undoObservers.append(NotificationCenter.default.addObserver(
                    forName: name, object: undoHistory, queue: .main
                ) { [weak self] _ in
                    MainActor.assumeIsolated { self?.textChangedOutsideTyping() }
                })
            }
        }

        func stopObservingUndo() {
            for token in undoObservers { NotificationCenter.default.removeObserver(token) }
            undoObservers.removeAll()
        }

        func undoManager(for view: NSTextView) -> UndoManager? {
            view === self.view ? undoHistory : nil
        }

        /// The box's text moved without `textDidChange` (an undo or a
        /// redo): the binding follows it, exactly as after a keystroke.
        private func textChangedOutsideTyping() {
            guard let view, parent.text != view.string else { return }
            parent.text = view.string
        }

        /// **A programmatic adopt** — the host replaced the box's text (a
        /// completed hand-off clears it; the pad's park restores it; nothing
        /// else writes). The caret stays where it can, and the box's history
        /// ENDS: the words it described have left the box (VX-193).
        func adopt(_ text: String, into view: CaptureNSTextView) {
            let selected = view.selectedRange()
            view.string = text
            let end = (text as NSString).length
            view.setSelectedRange(
                NSRange(location: min(selected.location, end), length: 0))
            undoHistory.removeAllActions()
        }

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
            guard let view, let window = view.window else { return }
            // Re-asserting focus the box already holds is a no-op by guard,
            // not by trust (13u3 ladder round 1, R1-6's caution): the
            // resign/become cycle is the family where focus surprises live,
            // and the third asker — the title chip handing the caret back —
            // fires exactly when the box often still has it.
            guard window.firstResponder !== view else { return }
            window.makeFirstResponder(view)
        }

        func textDidChange(_ notification: Notification) {
            guard let view else { return }
            parent.text = view.string
        }

        // 17y B2 (m): `textDidBeginEditing` / `textDidEndEditing` no longer
        // report focus. AppKit posts begin-editing on the first EDIT, not
        // when the caret arrives, so the autofocused empty box blinked its
        // caret while the host still drew the Terminal block cursor — two
        // cursors (a 13u3 UNIT C regression: the bar's gate read
        // `@FocusState`, the first-responder truth, before this view).
        // `CaptureNSTextView.onCaretChange` is the one report now.
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

    /// The caret lands here when the box reaches a window (the pad's open —
    /// a box made with its request already raised). Asked ONCE, on the first
    /// arrival, and deferred by one turn so the window has become key first —
    /// the A2 walk's fourth find, one unit over: a caret that blinks in a
    /// non-key window swallows every keystroke, and a caret you cannot type
    /// into is worse than no caret.
    ///
    /// **Cleared when it is served** (VX-112): it used to be read on EVERY
    /// arrival and never lowered, so a box made with a request re-claimed
    /// the keyboard on every SwiftUI detach/re-attach — after a release (the
    /// tour's, say), and over whatever else held it. A re-attach now answers
    /// to `heldKeyboardWhenDetached` alone.
    var wantsInitialFocus = false

    /// **VX-112 — the keyboard survives a RE-PARENT, and only what was held
    /// comes back** (`PaneTextView`'s rule, 18l-c U7 — TEXTKIT2 §3: SwiftUI
    /// may detach and re-attach a representable's view within one layout
    /// pass, and AppKit drops a detached first responder to the WINDOW).
    /// True while the box is detached having held the keyboard; on
    /// re-attach it takes the keyboard back ONLY when the window itself
    /// holds it — never from a field, a sheet or anything else that took it
    /// meanwhile — and a box that did not hold it (released, by the tour or
    /// anyone) stays away. Her rule, recorded at VX-282's kickoff: *the
    /// shared capture box re-takes only focus it HELD, never steals.*
    private var heldKeyboardWhenDetached = false

    /// **VX-326 — the opening ask, waiting to be decided.** Raised by
    /// `armOpeningFocus()` (the representable's `openingFocusRequest`); decided
    /// ONCE by `CaptureOpeningFocus` as soon as the box is in its window, and
    /// lowered by that decision whatever it was. Read-only outside, for pins.
    private(set) var openingFocusPending = false

    /// The opening ask arrived. Decided on the next main-queue turn — never
    /// inside SwiftUI's update or layout pass that delivered it, so the
    /// window's keyboard is read after that pass settles (a swap removes the
    /// face it replaced in the same pass that brings the box in).
    func armOpeningFocus() {
        openingFocusPending = true
        decideOpeningFocusNextTurn()
    }

    private func decideOpeningFocusNextTurn() {
        DispatchQueue.main.async { [weak self] in
            self?.decideOpeningFocus()
        }
    }

    private func decideOpeningFocus() {
        guard openingFocusPending else { return }
        let responder = window?.firstResponder
        let keyboard: CaptureOpeningFocus.Holder =
            responder == nil || responder === window ? .nobody
            : responder === self ? .theBox
            : .someoneElse
        let verdict = CaptureOpeningFocus.verdict(.init(
            inWindow: window != nil, keyboard: keyboard,
            sheetOnWindow: window?.attachedSheet != nil))
        switch verdict {
        case .wait:
            return
        case .drop, .alreadyHeld:
            openingFocusPending = false
        case .take:
            openingFocusPending = false
            window?.makeFirstResponder(self)
        }
    }

    /// **Where the caret is** (17y B2, item (m)): true when this box becomes
    /// first responder, false when it resigns — reported the moment the
    /// caret ARRIVES, keystroke or none, so the host's Terminal block cursor
    /// stands down exactly while this caret is the one blinking (her rule:
    /// "if the terminal cursor is blinking open at the end, your cursor
    /// shouldn't be blinking as well" — one cursor at a time).
    var onCaretChange: ((Bool) -> Void)?

    override func becomeFirstResponder() -> Bool {
        let became = super.becomeFirstResponder()
        if became { onCaretChange?(true) }
        return became
    }

    override func resignFirstResponder() -> Bool {
        let resigned = super.resignFirstResponder()
        if resigned { onCaretChange?(false) }
        return resigned
    }

    override func viewWillMove(toWindow newWindow: NSWindow?) {
        if newWindow == nil, let window, window.firstResponder === self {
            heldKeyboardWhenDetached = true
        }
        super.viewWillMove(toWindow: newWindow)
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard let window else { return }
        if wantsInitialFocus {
            // The initial request, served once — an EXPLICIT ask, so its
            // guard is today's ("not already mine"), exactly as before.
            wantsInitialFocus = false
            heldKeyboardWhenDetached = false
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                guard let window = self.window else {
                    // Out of its window by the time the turn came: the ask
                    // waits for the next arrival rather than being lost.
                    self.wantsInitialFocus = true
                    return
                }
                guard window.firstResponder !== self else { return }
                window.makeFirstResponder(self)
            }
        } else if heldKeyboardWhenDetached {
            heldKeyboardWhenDetached = false
            if window.firstResponder == nil || window.firstResponder === window {
                window.makeFirstResponder(self)
            }
        }
        // VX-326: an opening ask that arrived before the box was in its
        // window is decided now that it is (next turn, as at the ask).
        if openingFocusPending {
            decideOpeningFocusNextTurn()
        }
    }

    override func keyDown(with event: NSEvent) {
        switch CaptureKeys.act(for: event) {
        case .file:
            onFile?()
        case .paragraph, nil:
            super.keyDown(with: event)
        }
    }
}
