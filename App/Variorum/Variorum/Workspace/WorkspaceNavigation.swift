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

// MARK: - The mount rule (13f batch 4, item 2 — P-3 across panes)

/// WHAT A PANE MOUNTS — and the whole of P-3's extension to panes, as one
/// pure decision rather than a new mechanism.
///
/// **Why this is the entire extension** (traced at the batch-4 gate, ruled
/// approved): `PaneTextAuthority` already enforces exactly-one-live-ring,
/// and it enforces it INSIDE one authority. Every authority owner
/// (`TakesViewModel`, Compare's model, `CanvasViewModel`, `BlockTOCView`)
/// and every routed-command handler (`EditorView`, `TakesBoardView`,
/// `LensesBoardView`, `CompareBoardView`, `CanvasView`) is mounted by a
/// detail host. So two panes are safe exactly when at most ONE of them
/// mounts a live surface — at which point the app-scoped singletons that
/// assume one detail (`CommandRouter`'s single detail registration, its
/// LIFO handler stack, `EditorRouter.active`) keep being correct with no
/// change at all. That is `SpreadBookView`'s shape (13c 2B, where the
/// reasons are written out), generalized from two pages to N panes.
///
/// The alternative — both panes live, liveness suppressed by a third
/// disjunct beside `sealed || structuralInFlight` — was named and REJECTED
/// at the gate: it needs the flag threaded into five surfaces AND a
/// pane-keyed rewrite of all three singletons, which multiplies exactly
/// what P-3 exists to prevent.
nonisolated enum PaneMount {
    enum Kind: Equatable, Sendable {
        /// Mounts the full detail surface: authority owner, command
        /// handler, live editor.
        case live
        /// Renders read-cheap — no authority, no handler, no live editor.
        case readCheap
    }

    static func kind(of pane: PaneID, focused: PaneID) -> Kind {
        pane == focused ? .live : .readCheap
    }

    /// How many panes mount a live surface. **ONE**, for any pane
    /// collection and any focus — the invariant the split's safety rests
    /// on, stated as arithmetic so a pin can hold it. If this ever answers
    /// more than one, the flight latch must move to a post-keyed shared
    /// authority BEFORE that ships (the batch-4 gate ruling, condition c).
    static func liveCount(panes: [PaneID], focused: PaneID) -> Int {
        panes.filter { kind(of: $0, focused: focused) == .live }.count
    }
}

// MARK: - Pane layout (the divider's arithmetic)

/// Where the dividers sit. Fractions are DIVIDER POSITIONS in `0...1`,
/// ascending, one per divider — so a drag edits exactly one number and the
/// shape generalizes to N panes without becoming a left/right pair (the
/// free-tiling rider).
nonisolated enum PaneLayout {
    /// No pane may be dragged below this share of the row. A pane you
    /// cannot see is a pane you cannot click back out of.
    static let minimumFraction = 0.15

    /// Evenly-spaced dividers for a pane count — what a fresh split gets.
    static func evenFractions(paneCount: Int) -> [Double] {
        guard paneCount > 1 else { return [] }
        return (1..<paneCount).map { Double($0) / Double(paneCount) }
    }

    /// Pane widths across `total`, given the dividers' positions.
    static func widths(total: CGFloat, fractions: [Double]) -> [CGFloat] {
        let bounds = [0.0] + fractions + [1.0]
        guard total > 0 else { return Array(repeating: 0, count: bounds.count - 1) }
        return (0..<(bounds.count - 1)).map { CGFloat(bounds[$0 + 1] - bounds[$0]) * total }
    }

    /// Move one divider, clamped so its two neighbours both keep at least
    /// `minimumFraction` — the drag can never swallow a pane.
    static func moving(
        _ fractions: [Double], divider index: Int, to value: Double
    ) -> [Double] {
        guard fractions.indices.contains(index) else { return fractions }
        let lower = (index == 0 ? 0 : fractions[index - 1]) + minimumFraction
        let upper = (index == fractions.count - 1 ? 1 : fractions[index + 1]) - minimumFraction
        guard lower <= upper else { return fractions }
        var out = fractions
        out[index] = min(max(value, lower), upper)
        return out
    }
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

/// The Open strip's list: the notes this window has open, in the order
/// they were opened. A note enters by being OPENED — from any door (shelf,
/// library, pool, ⌘K, a book, Compare's click-through) — and leaves only
/// when its row is closed or it falls off the session bound.
///
/// **ORDER and MEMBERSHIP are two different questions** (her ruling, sitting
/// round 7.1: *"insertion order, maybe they're draggable / reorderable
/// manually like browser tabs as well though? session only, not a
/// setting"*). Batch 3 shipped recency for both, and the consequence was
/// flagged to her rather than decided: the ordinals shuffled as she moved,
/// so ⌘⇧1 was always the note she was already in. Since her ruling:
///
/// - **Order is INSERTION order** — a new note joins at the END, like a
///   browser tab, and re-opening one already in the strip leaves it exactly
///   where it sits. That is what makes ⌘⇧n a stable address instead of a
///   moving one, and it is the whole point of the flip.
/// - **Membership is still RECENCY's** — when the tracked list is full the
///   LEAST-RECENTLY-OPENED note leaves, never the oldest-inserted one. A
///   note she keeps returning to must not be evicted merely for having been
///   opened first.
/// - **Manual reorder is hers**, session-only and never a setting.
nonisolated struct OpenNotes: Equatable {
    /// Rows the strip SHOWS — and exactly the reach of ⌘⇧1…⌘⇧9, chosen so
    /// the two numbers cannot drift: every visible row carries a key, and
    /// no key points at a row she cannot see.
    static let visibleCap = 9
    /// The session memory BEHIND the strip. Larger than what is shown so
    /// closing a row promotes the next note instead of leaving a hole, and
    /// so the strip can say honestly that more are open (the bounded-windows
    /// discipline: a truncation marker, never a silent cut).
    static let trackedCap = 12

    /// Container ids in STRIP ORDER — insertion order, moved only by an
    /// explicit manual reorder and never by navigation. IDs only; the
    /// titles are resolved for display and never stored here.
    private(set) var ids: [String] = []

    /// The same set, most-recently-opened first. It answers exactly ONE
    /// question — who leaves when the tracked list is full — and never
    /// touches what the strip shows or what ⌘⇧n addresses.
    private(set) var recency: [String] = []

    /// Opening a note: it joins the END of the strip if it is new, and it
    /// becomes the most recent either way. An already-open note does NOT
    /// move — that is the ruled flip.
    mutating func opened(_ id: String) {
        recency.removeAll { $0 == id }
        recency.insert(id, at: 0)
        guard !ids.contains(id) else { return }
        ids.append(id)
        evictBeyondTheBound()
    }

    /// Closing a row closes a ROW. Nothing is deleted.
    mutating func close(_ id: String) {
        ids.removeAll { $0 == id }
        recency.removeAll { $0 == id }
    }

    /// The manual reorder (her ruling's second half), in the `onMove`
    /// convention: `destination` is an index in the PRE-move list.
    ///
    /// Offsets are the SHOWN rows' — and because `shown` is a prefix of
    /// `ids`, they are `ids`' own indices, so there is no mapping table
    /// that could go stale. Recency is untouched: rearranging the strip is
    /// not using a note.
    mutating func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        let limit = shown.count
        guard source.allSatisfy({ $0 >= 0 && $0 < limit }),
            destination >= 0, destination <= limit
        else { return }
        let moving = source.sorted().map { ids[$0] }
        guard !moving.isEmpty else { return }
        // The insertion point shifts left by however many moved rows sat
        // before it, because `destination` is stated in pre-move terms.
        let before = source.filter { $0 < destination }.count
        var out = ids
        out.removeAll { moving.contains($0) }
        out.insert(contentsOf: moving, at: min(max(destination - before, 0), out.count))
        ids = out
    }

    /// The bound, paid by the least-recently-opened note (never by the
    /// oldest-inserted one — membership is recency's question).
    private mutating func evictBeyondTheBound() {
        while ids.count > Self.trackedCap, let victim = recency.last {
            ids.removeAll { $0 == victim }
            recency.removeAll { $0 == victim }
        }
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

    // MARK: - The split (13f batch 4, W1/A25)

    /// **The same-note refusal** — her sitting ruling, round 7.3: *"opening
    /// a note already showing in the other pane could move you there …
    /// definitely not two live side by sides - we already offer that for
    /// one note."* The definite half binds, so the split never shows one
    /// note twice; the shipped shape is her first-listed reading (focus the
    /// pane that has it) and this is what it SAYS while doing so — naming
    /// the two surfaces that ARE the same-note side-by-side answer.
    static func sameNoteNote(_ name: String) -> String {
        "\u{201c}\(name)\u{201d} is already open in the other pane — a split never shows "
            + "one note twice. To see one note side by side, use Lenses or Compare."
    }

    /// What "Open Beside" is called, in one place, so the menu door, the
    /// row doors and the refusal all wear the same word.
    static let openBesideVerb = "Open Beside"
}
