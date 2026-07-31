//
//  WorkspaceNavigation.swift
//  Variorum (Mac)
//
//  Phase 13f, batch 3 — THE NAVIGATION CORE (her W3/A27 + W16 rulings):
//  the window's OPEN notes and its per-pane back/forward history, as small
//  PURE types (P-9) with an `@Observable` holder above them. Nothing here
//  touches the store, SwiftUI, or AppKit: what a pane has visited and which
//  notes are open is arithmetic over IDs, and it is pinned as arithmetic.
//
//  Two standing constraints shape the types more than anything else:
//
//  - **The free-tiling rider** (her sitting ruling, round 2: *"two panes is
//    the right choice for v1, but … make sure the architecture isn't going
//    down a road closed to [free tiling]"*). History is therefore a
//    DICTIONARY keyed by `PaneID` from day one — never a pair of stacks,
//    never "left/right". Today exactly one pane exists; a split, a third
//    pane, or free tiling adds keys and changes nothing else.
//  - **View state, and only view state.** IDs only — never a copy of
//    persisted text (the standing state rule); never persisted, never
//    synced. Closing an open-note row closes a ROW: nothing is deleted,
//    archived, or written.
//

import Foundation

// MARK: - The pane key

/// Which pane a history belongs to. A `String` box rather than an enum
/// because the set of panes is open by design (the free-tiling rider):
/// batch 4's split and any later tiling mint their own keys without this
/// type — or anything that stores it — changing shape.
nonisolated struct PaneID: Hashable, Sendable {
    let raw: String

    init(_ raw: String) { self.raw = raw }

    /// The detail pane the shell has today.
    static let primary = PaneID("primary")
}

// MARK: - Per-pane history (W16)

/// One pane's visit history — the ⌘[ / ⌘] stacks and the back chip's
/// origin. Pure and totally ordered: `back` is oldest-first, so `back.last`
/// is where "←" goes and whose name the chip wears.
nonisolated struct NavigationHistory: Equatable {
    /// The session memory's bound (the bounded-windows discipline: held
    /// state gets a bound, and a back stack is held state). Deep enough
    /// that a real working session never reaches it; bounded so a long
    /// session cannot grow one.
    static let cap = 50

    private(set) var back: [SidebarSelection] = []
    private(set) var current: SidebarSelection?
    private(set) var forward: [SidebarSelection] = []

    var canGoBack: Bool { !back.isEmpty }
    var canGoForward: Bool { !forward.isEmpty }

    /// Where "←" leads — and the name the chip wears. `nil` ⇒ the pane
    /// arrived from nowhere, and no chip renders (her "I like how clean the
    /// editor looks right now": at the shelf there is nothing to go back to
    /// and therefore nothing on screen).
    var origin: SidebarSelection? { back.last }

    /// Records an ordinary navigation, from ANY door.
    ///
    /// Re-visiting the current destination is a no-op, and that is what
    /// keeps back/forward free of a re-entrancy flag: they set `current`
    /// themselves, and the shell's resulting selection change lands here
    /// and finds nothing to do. A flag would have to be cleared on every
    /// path SwiftUI might or might not take.
    mutating func visit(_ destination: SidebarSelection) {
        guard destination != current else { return }
        if let current {
            back.append(current)
            if back.count > Self.cap { back.removeFirst(back.count - Self.cap) }
        }
        current = destination
        // A new navigation ends the forward future — the browser rule, and
        // the same rule structural redo follows (any new act clears it).
        forward.removeAll()
    }

    /// ⌘[ — nil when there is nowhere back.
    mutating func goBack() -> SidebarSelection? {
        guard let destination = back.popLast() else { return nil }
        if let current { forward.append(current) }
        current = destination
        return destination
    }

    /// ⌘] — nil when nothing was walked back from.
    mutating func goForward() -> SidebarSelection? {
        guard let destination = forward.popLast() else { return nil }
        if let current { back.append(current) }
        current = destination
        return destination
    }
}

// MARK: - The window's open notes (W3/A27)

/// The Open strip's list: the notes this window has open, most recent
/// first. A note enters by being OPENED — from any door (shelf, library,
/// pool, ⌘K, a book, Compare's click-through) — and leaves only when its
/// row is closed or it falls off the session bound.
nonisolated struct OpenNotes: Equatable {
    /// Rows the strip SHOWS — and exactly the reach of ⌘⇧1…⌘⇧9, chosen so
    /// the two numbers cannot drift: every visible row carries a key, and
    /// no key points at a row she cannot see.
    static let visibleCap = 9
    /// The session memory BEHIND the strip. Larger than what is shown so
    /// closing a row promotes the next most recent note instead of leaving
    /// a hole, and so the strip can say honestly that more are open (the
    /// bounded-windows discipline: a truncation marker, never a silent cut).
    static let trackedCap = 12

    /// Container ids, most recently opened first. IDs only — the titles
    /// are resolved for display and never stored here.
    private(set) var ids: [String] = []

    /// Insert-or-move-to-front (her brief's letter: opening "adds it /
    /// moves it to recency").
    mutating func opened(_ id: String) {
        ids.removeAll { $0 == id }
        ids.insert(id, at: 0)
        if ids.count > Self.trackedCap { ids.removeLast(ids.count - Self.trackedCap) }
    }

    /// Closing a row closes a ROW. Nothing is deleted.
    mutating func close(_ id: String) {
        ids.removeAll { $0 == id }
    }

    var shown: [String] { Array(ids.prefix(Self.visibleCap)) }

    /// What the truncation row reports — 0 ⇒ no row.
    var hiddenCount: Int { max(0, ids.count - Self.visibleCap) }

    /// ⌘⇧n — 1-based, over the SHOWN rows (a key never reaches past the
    /// strip). nil where no nth row exists.
    func id(atOrdinal ordinal: Int) -> String? {
        let shown = shown
        guard ordinal >= 1, ordinal <= shown.count else { return nil }
        return shown[ordinal - 1]
    }
}

// MARK: - Naming a destination (the chip's and the strip's words)

/// What a destination is CALLED on screen. Pure, so the chip's sentence is
/// pinnable without a window; ids resolve through a supplied title map so
/// no persisted text is ever held in navigation state.
nonisolated enum WorkspaceNaming {
    /// The Open section's header (a UI string; the K5 sweep batch owns
    /// every other word in the sidebar).
    static let openSectionHeader = "Open"

    /// The four standing areas name themselves; the rest read the map.
    /// Fallbacks are per-kind so an unresolved id still reads as what it
    /// IS — never as a bare identifier.
    static func label(for selection: SidebarSelection, titles: [String: String]) -> String {
        switch selection {
        case .shelf: return "Shelf"
        case .library: return "Library"
        case .poolPosts: return "Pool"
        case .blocks: return "Blocks"
        case .recovery: return RecoveryPath.menuLabel
        case .post(let id): return resolved(id, in: titles) ?? "Untitled"
        case .pool(let id): return resolved(id, in: titles) ?? "Blocks"
        case .reading(let id): return resolved(id, in: titles) ?? "Book"
        case .tag(let id): return resolved(id, in: titles) ?? "Tag"
        }
    }

    /// An empty stored title is not a name (the app's shipped reading —
    /// `PostTitleLabel` shows "Untitled" for it).
    private static func resolved(_ id: String, in titles: [String: String]) -> String? {
        guard let title = titles[id], !title.isEmpty else { return nil }
        return title
    }

    /// The chip's whole sentence — one place, so the help text and the
    /// label cannot disagree.
    static func backLabel(origin: String) -> String { "\u{2190} \(origin)" }

    static func backHelp(origin: String) -> String { "Back to \(origin) (\u{2318}[)" }
}
