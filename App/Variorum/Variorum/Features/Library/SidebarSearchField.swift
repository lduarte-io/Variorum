//
//  SidebarSearchField.swift
//  Variorum (Mac)
//
//  **VX-822 (the VX-819 run, batch 3) — search from the sidebar.** Her two
//  rulings (the run record's SITTING RECORD, `notes/plans/fixes/
//  vx-819-search.md`):
//
//  · R-819-3, the PLACE: *"under wing name is fine, there should be empty
//    space there when there are starred and without starred items. don't
//    shift everything down for it - there should be space for it without it
//    occupying it's "own" row, which i think would look weird"*. The column's
//    content opens with `SidebarLayout.topPadding` of empty room in every
//    state (it never compresses — only rows do), so the field lives THERE, an
//    overlay on the column's content: layout-free by construction, so nothing
//    below can move, and never a row of any list. A QUIET line — the 🔍 on
//    the rows' content edge and the prompt in the small face, no bezel, no
//    wash — because a bezelled field is taller than the band (PROVISIONAL
//    P-819-B3c, the face and its metrics; the walk is the eye).
//  · R-819-4, the HANDOFF: the field KEEPS the keyboard; typing shows the
//    Library with the live answer as she types; ⏎ or a click into the results
//    moves her into the Library (the words carried, the field cleared);
//    typing is never interrupted. ONE engine, one finder: the field holds no
//    search state of its own — its words go to the Library's one question
//    through ⌘K's road (`RootView.searchLibrary`), wing-scoped as the
//    Library's search already is.
//
//  Three pieces, one file: the RULE (pure — what each of her acts does), the
//  DOOR (the closures the composition root hands in: the sidebar never holds
//  the Library's model — CLAUDE.md's cross-feature rule), and the FACE (the
//  field, its keyboard, the window-scoped click monitor). Pinned in
//  `SidebarSearchFieldTests`.
//

import AppKit
import SwiftUI
import VariorumCore

// MARK: - The rule (pure)

/// **What each of her acts in the sidebar field does.** The field's words are
/// its own (a DOOR, never a mirror: it opens empty while the Library already
/// searches — PROVISIONAL P-819-B3d), and they are the Library's question
/// exactly while they are not empty — so "the field drives the search" is
/// `!text.isEmpty`, one fact, never a flag beside it.
nonisolated struct SidebarSearchFieldRule: Equatable, Sendable {
    /// The field's words.
    private(set) var text = ""

    enum Act: Equatable, Sendable {
        /// Nothing for the Library.
        case none
        /// A NEW search: the field went from empty to typed. The Library's
        /// question becomes these words (landing the Library where the
        /// focused pane is not already showing it) — a fresh hunt, never a
        /// refinement of whatever the Library was asking (the VX-819
        /// ladder's F3).
        case start(String)
        /// The field's own search, refined: the Library's question becomes
        /// these words.
        case ask(String)
        /// The question is cleared: the search ends, the Library stays
        /// (PROVISIONAL P-819-B3e — no navigation-history magic).
        case end
        /// The words are already the Library's question; the field lets them
        /// go (it clears). `keyboardToLibrary`: ⏎'s road — the Library's own
        /// field takes the keyboard, the words carried; a click's road leaves
        /// the keyboard to whatever the click gave it.
        case handOff(keyboardToLibrary: Bool)
    }

    /// Her typing (or a cut, a paste — any edit of the words).
    mutating func edit(_ words: String) -> Act {
        let wasAsking = !text.isEmpty
        text = words
        if !words.isEmpty { return wasAsking ? .ask(words) : .start(words) }
        return wasAsking ? .end : .none
    }

    /// ⏎ — into the Library, the words carried, the field cleared.
    mutating func submit() -> Act {
        guard !text.isEmpty else { return .none }
        text = ""
        return .handOff(keyboardToLibrary: true)
    }

    /// Esc — the field cleared, and with it the search it asked (clearing by
    /// any road ends the search).
    mutating func escape() -> Act {
        guard !text.isEmpty else { return .none }
        text = ""
        return .end
    }

    /// The field lost the keyboard, or a click landed anywhere else in the
    /// window (the results' lines are tap gestures — no keyboard moves): the
    /// words stay the Library's, the field clears.
    mutating func leave() -> Act {
        guard !text.isEmpty else { return .none }
        text = ""
        return .handOff(keyboardToLibrary: false)
    }
}

// MARK: - The door (composed by the root)

/// The field's three roads, handed in by the composition root (`RootView`),
/// which owns the Library's model and the window's navigation.
struct SidebarSearchDoor {
    /// The Library's ONE question becomes `words`, the Library landed in the
    /// focused pane where it is not already showing (⌘K's road).
    /// `startsNewSearch`: the field went from empty to typed (the rule's
    /// `.start`) — a fresh hunt, not a refinement.
    let ask: @MainActor (_ words: String, _ startsNewSearch: Bool) -> Void
    /// The question cleared — the search ends; the Library stays.
    let end: @MainActor () -> Void
    /// The Library's own field takes the keyboard, its words carried, the
    /// caret at their end (⏎'s handoff).
    let keyboardToLibrary: @MainActor () -> Void
}

// MARK: - The words

enum SidebarSearchCopy {
    /// The prompt (PROVISIONAL P-819-B3c — her eye on the walk).
    static let prompt = "Search"
    static let help = "Search the Library in this wing \u{2014} \u{23CE} moves into the Library, esc clears"
    static let accessibilityLabel = "Search the Library"
}

// MARK: - The face

/// **The field**, at the column's content edge, one band tall. Its own words
/// and keyboard; every act through the rule, every effect through the door.
struct SidebarSearchField: View {
    let tokens: VoiceTokens
    let door: SidebarSearchDoor

    @State private var rule = SidebarSearchFieldRule()

    var body: some View {
        HStack(spacing: 6) {
            // On the five areas' icon column (`SidebarView.areasGroup`).
            Image(systemName: "magnifyingglass")
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .frame(width: 18)
                .accessibilityHidden(true)
            SidebarSearchTextField(
                text: rule.text,
                prompt: tokens.chromeLabel(SidebarSearchCopy.prompt),
                font: SidebarSearchFieldLayout.font(for: tokens.voice),
                ink: NSColor(tokens.ink),
                promptInk: NSColor(tokens.faint),
                onEdit: { apply(rule.edit($0)) },
                onSubmit: { apply(rule.submit()) },
                onEscape: { apply(rule.escape()) },
                // The keyboard leaving by any road (another field, a list
                // taking it): the words stay the Library's.
                onLeave: { apply(rule.leave()) })
            .help(SidebarSearchCopy.help)
        }
        .padding(.horizontal, SidebarLayout.contentInset)
        .frame(height: SidebarSearchFieldLayout.height)
        .frame(maxWidth: .infinity, alignment: .leading)
        // "A click into the results": a mouse-down anywhere else in this
        // window while the field holds words (never swallowed — the click
        // does what it does; the field only lets its words go).
        .background(SidebarSearchClickMonitor(armed: !rule.text.isEmpty) {
            apply(rule.leave())
        })
    }

    private func apply(_ act: SidebarSearchFieldRule.Act) {
        switch act {
        case .none: break
        case .start(let words): door.ask(words, true)
        case .ask(let words): door.ask(words, false)
        case .end: door.end()
        case .handOff(let keyboardToLibrary):
            if keyboardToLibrary { door.keyboardToLibrary() }
        }
    }
}

/// **The field's text field — AppKit's, on purpose.** A SwiftUI `TextField`
/// is an `NSTextField` in the window's key-view loop, and the column's top is
/// the loop's FIRST stop: a window opening with the shell as its first
/// content (a new window on the Bookcase) would make THIS field its opening
/// first responder (AppKit's own pick — the harness fact
/// `QuickEntryLaunchFocusTests` records), robbing the Bookcase's quick entry
/// of VX-332's caret ("start typing" is literal there). This field is never a
/// key-view stop (`canBecomeKeyView` false — not the opening pick, not a Tab
/// stop; PROVISIONAL P-819-B3f): a click or her own road puts the caret
/// here. Its keys are the delegate's: ⏎ (`insertNewline:`) and esc
/// (`cancelOperation:`) are the rule's, and the editing ending is the
/// keyboard leaving.
struct SidebarSearchTextField: NSViewRepresentable {
    let text: String
    let prompt: String
    let font: NSFont
    let ink: NSColor
    let promptInk: NSColor
    let onEdit: (String) -> Void
    let onSubmit: () -> Void
    let onEscape: () -> Void
    let onLeave: () -> Void

    /// The one AppKit subclass: never a key-view stop.
    final class Field: NSTextField {
        override var canBecomeKeyView: Bool { false }
    }

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeNSView(context: Context) -> Field {
        let field = Field()
        field.isBordered = false
        field.isBezeled = false
        field.drawsBackground = false
        field.focusRingType = .none
        field.usesSingleLineMode = true
        field.lineBreakMode = .byClipping
        field.cell?.wraps = false
        field.cell?.isScrollable = true
        field.setContentHuggingPriority(.defaultLow, for: .horizontal)
        field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        field.setAccessibilityLabel(SidebarSearchCopy.accessibilityLabel)
        field.delegate = context.coordinator
        style(field)
        field.stringValue = text
        return field
    }

    func updateNSView(_ field: Field, context: Context) {
        context.coordinator.parent = self
        style(field)
        // The rule's words are the truth: a handoff or esc clears them here —
        // through the field EDITOR while she is in it, so the caret stays and
        // the editing session goes on (setting the control's own value can
        // end an edit in flight).
        if field.stringValue != text {
            if let editor = field.currentEditor() as? NSTextView {
                editor.string = text
            } else {
                field.stringValue = text
            }
        }
    }

    private func style(_ field: Field) {
        if field.font != font { field.font = font }
        if field.textColor != ink { field.textColor = ink }
        let placeholder = NSAttributedString(
            string: prompt, attributes: [.font: font, .foregroundColor: promptInk])
        if field.placeholderAttributedString != placeholder { field.placeholderAttributedString = placeholder }
    }

    final class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: SidebarSearchTextField

        init(parent: SidebarSearchTextField) { self.parent = parent }

        func controlTextDidChange(_ notification: Notification) {
            guard let field = notification.object as? NSTextField else { return }
            parent.onEdit(field.stringValue)
        }

        func control(_ control: NSControl, textView: NSTextView, doCommandBy selector: Selector) -> Bool {
            switch selector {
            case #selector(NSResponder.insertNewline(_:)):
                parent.onSubmit()
                return true
            case #selector(NSResponder.cancelOperation(_:)):
                parent.onEscape()
                return true
            default:
                return false
            }
        }

        func controlTextDidEndEditing(_ notification: Notification) {
            parent.onLeave()
        }
    }
}

/// **Where the field sits** — the column's empty top band, exactly
/// (`SidebarLayout.topPadding`): its own height IS the band's, so a first
/// section can never be pushed down by it.
nonisolated enum SidebarSearchFieldLayout {
    static var height: CGFloat { SidebarLayout.topPadding }

    /// The voice's SMALL face in AppKit (`VoiceTokens.small` — 11.5 pt, the
    /// system face in Study, monospaced in Terminal), the size the band holds
    /// (a line of it ≈ 14 pt). Pinned against SwiftUI's own measure of
    /// `tokens.small` (`SidebarSearchFieldPlaceTests`), so the two cannot drift.
    static let fontSize: CGFloat = 11.5

    static func font(for voice: ThemeVoice) -> NSFont {
        switch voice {
        case .terminal: .monospacedSystemFont(ofSize: fontSize, weight: .regular)
        case .study: .systemFont(ofSize: fontSize)
        }
    }
}

// MARK: - The click monitor (the window's own mouse-downs)

/// A zero-hit view the size of the field, owning a local mouse-down monitor
/// for its window while ARMED (the field holds words): a press outside the
/// field reports, and the event goes on untouched (`PageTurnKeyMonitor`'s
/// shape — scoped to its own window, never another's).
struct SidebarSearchClickMonitor: NSViewRepresentable {
    let armed: Bool
    let onClickElsewhere: () -> Void

    func makeNSView(context: Context) -> MonitorView {
        let view = MonitorView()
        view.armed = armed
        view.onClickElsewhere = onClickElsewhere
        return view
    }

    func updateNSView(_ nsView: MonitorView, context: Context) {
        nsView.armed = armed
        nsView.onClickElsewhere = onClickElsewhere
    }

    final class MonitorView: NSView {
        var armed = false
        var onClickElsewhere: (() -> Void)?
        private var monitor: Any?

        /// Never takes a click — the field above it does.
        override func hitTest(_ point: NSPoint) -> NSView? { nil }

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            if let monitor {
                NSEvent.removeMonitor(monitor)
                self.monitor = nil
            }
            guard window != nil else { return }
            monitor = NSEvent.addLocalMonitorForEvents(
                matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]
            ) { [weak self] event in
                guard let self, self.armed, let window = self.window, event.window === window else {
                    return event
                }
                let local = self.convert(event.locationInWindow, from: nil)
                if !self.bounds.contains(local) { self.onClickElsewhere?() }
                return event  // never swallowed
            }
        }
        // (No `deinit`: `viewDidMoveToWindow` with a nil window removes the
        // monitor — `PageTurnKeyMonitor`'s note.)
    }
}

// MARK: - The Library's field takes the keyboard (⏎'s handoff)

/// **After a programmatic focus, the caret at the END of the carried words.**
/// AppKit selects an `NSTextField`'s whole text when it is made first
/// responder by code, so without this her next key would REPLACE the question
/// the sidebar just handed over. The field's editor is found by the words it
/// shows — in the Library field's OWN window only (the VX-819 ladder's F2):
/// a walk over every app window stopped at the first editor showing the same
/// words, so another window editing them took the caret and the Library's
/// field kept its select-all. The window is reported by a zero-hit probe
/// beside the field (`Probe`, holding `Anchor`).
enum CarriedWordsCaret {
    /// Where the Library's field lives: the probe's view, held weakly; its
    /// window is the field's.
    @MainActor
    final class Anchor {
        fileprivate weak var view: NSView?
        var window: NSWindow? { view?.window }
    }

    /// The zero-hit probe the Library's field wears, reporting its window.
    struct Probe: NSViewRepresentable {
        let anchor: Anchor

        final class ProbeView: NSView {
            override func hitTest(_ point: NSPoint) -> NSView? { nil }
        }

        func makeNSView(context: Context) -> ProbeView {
            let view = ProbeView()
            anchor.view = view
            return view
        }

        func updateNSView(_ nsView: ProbeView, context: Context) {
            anchor.view = nsView
        }
    }

    @MainActor @discardableResult
    static func toEnd(of words: String, in window: NSWindow?) -> Bool {
        // The window's ONE field editor serves whichever field is being
        // edited: never the sidebar's own (the handoff's leaving field).
        guard !words.isEmpty, let window,
              let editor = window.firstResponder as? NSTextView, editor.isFieldEditor,
              editor.string == words,
              !((editor.delegate as AnyObject?) is SidebarSearchTextField.Field)
        else { return false }
        editor.setSelectedRange(NSRange(location: (editor.string as NSString).length, length: 0))
        return true
    }

    /// Tries over a few turns (the focus lands a pass after it is asked), in
    /// the anchor's window as it stands at each try.
    @MainActor
    static func toEndSoon(of words: String, near anchor: Anchor) {
        Task { @MainActor in
            for _ in 0..<20 {
                try? await Task.sleep(for: .milliseconds(15))
                if toEnd(of: words, in: anchor.window) { return }
            }
        }
    }
}
