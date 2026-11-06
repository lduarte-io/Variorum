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
        /// The Library's question becomes these words (landing the Library
        /// where the focused pane is not already showing it).
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
        if !words.isEmpty { return .ask(words) }
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
    let ask: @MainActor (_ words: String) -> Void
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
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: 6) {
            // On the five areas' icon column (`SidebarView.areasGroup`).
            Image(systemName: "magnifyingglass")
                .font(tokens.small)
                .foregroundStyle(focused ? tokens.accent : tokens.muted)
                .frame(width: 18)
                .accessibilityHidden(true)
            TextField(
                text: Binding(get: { rule.text }, set: { apply(rule.edit($0)) }),
                prompt: Text(tokens.chromeLabel(SidebarSearchCopy.prompt)).foregroundStyle(tokens.faint)
            ) {
                Text(SidebarSearchCopy.accessibilityLabel)
            }
            .textFieldStyle(.plain)
            .font(tokens.small)
            .foregroundStyle(tokens.ink)
            .lineLimit(1)
            .focused($focused)
            .onSubmit { apply(rule.submit()) }
            .onExitCommand { apply(rule.escape()) }
            // The keyboard leaving by any road (a Tab, another field, a list
            // taking it): the words stay the Library's.
            .onChange(of: focused) { _, holds in
                if !holds { apply(rule.leave()) }
            }
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
        case .ask(let words): door.ask(words)
        case .end: door.end()
        case .handOff(let keyboardToLibrary):
            if keyboardToLibrary { door.keyboardToLibrary() }
        }
    }
}

/// **Where the field sits** — the column's empty top band, exactly
/// (`SidebarLayout.topPadding`): its own height IS the band's, so a first
/// section can never be pushed down by it.
nonisolated enum SidebarSearchFieldLayout {
    static var height: CGFloat { SidebarLayout.topPadding }
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
/// shows, in the given windows (the app's, by default).
enum CarriedWordsCaret {
    @MainActor @discardableResult
    static func toEnd(of words: String, in windows: [NSWindow] = NSApp.windows) -> Bool {
        guard !words.isEmpty else { return false }
        for window in windows {
            guard let editor = window.firstResponder as? NSTextView, editor.isFieldEditor,
                  editor.string == words
            else { continue }
            editor.setSelectedRange(NSRange(location: (editor.string as NSString).length, length: 0))
            return true
        }
        return false
    }

    /// Tries over a few turns (the focus lands a pass after it is asked).
    @MainActor
    static func toEndSoon(of words: String) {
        Task { @MainActor in
            for _ in 0..<20 {
                try? await Task.sleep(for: .milliseconds(15))
                if toEnd(of: words) { return }
            }
        }
    }
}
