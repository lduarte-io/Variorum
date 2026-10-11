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

    /// **13f batch 5b — the KEY-WINDOW gate, on this same fork** (the
    /// architect's ruling (b)). The rule reads: *exactly one pane, in
    /// exactly one window, mounts a live surface.* A second window would
    /// otherwise give the app two live surfaces, and every consequence the
    /// pane-level audit relies on — ONE detail registration behind ⌘1–⌘6
    /// and the sidebar rail, ONE entry in the LIFO handler stack behind ⌘S
    /// and every structural act, ONE `EditorRouter.active` — would break at
    /// app scale in exactly the way `SpreadBookView` names.
    ///
    /// `windowIsKey` defaults to true so that this remains ONE fork rather
    /// than two: every batch-4 pin over the pane rule reads unchanged (the
    /// parity proof that the window gate is an addition, not an
    /// adjustment), and callers who know about windows pass the input.
    ///
    /// The key-ness handed in here is `WindowRegistry`'s **sticky**
    /// last-known-key, never a literal `keyWindow`-now — see that file.
    static func kind(of pane: PaneID, focused: PaneID, windowIsKey: Bool = true) -> Kind {
        windowIsKey && pane == focused ? .live : .readCheap
    }

    /// How many panes mount a live surface. **ONE**, for any pane
    /// collection and any focus — the invariant the split's safety rests
    /// on, stated as arithmetic so a pin can hold it. If this ever answers
    /// more than one, the flight latch must move to a post-keyed shared
    /// authority BEFORE that ships (the batch-4 gate ruling, condition c).
    static func liveCount(panes: [PaneID], focused: PaneID, windowIsKey: Bool = true) -> Int {
        panes.filter { kind(of: $0, focused: focused, windowIsKey: windowIsKey) == .live }.count
    }

    /// One window's state, for the app-scale count below. A struct rather
    /// than a tuple so the arithmetic reads the same way the pins do.
    struct WindowState: Equatable, Sendable {
        let panes: [PaneID]
        let focused: PaneID
        let isKey: Bool

        init(panes: [PaneID], focused: PaneID, isKey: Bool) {
            self.panes = panes
            self.focused = focused
            self.isKey = isKey
        }
    }

    /// **The app-scale invariant**: across every open window, exactly one
    /// pane mounts a live surface — because `WindowRegistry`'s key is
    /// sticky, so exactly one window is key whenever any window is open.
    static func liveCount(across windows: [WindowState]) -> Int {
        windows.reduce(0) { total, window in
            total + liveCount(
                panes: window.panes, focused: window.focused, windowIsKey: window.isKey)
        }
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

/// One pane's visit history — the ⌥⌘[ / ⌥⌘] stacks and the back chip's
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

    /// Where "→" leads — the mirror of `origin`, added by 13k K11 when the
    /// forward glyph became a real door. Same shape for the same reason:
    /// the bar names its destination in the tooltip, and a name needs a
    /// destination to read.
    var next: SidebarSelection? { forward.last }

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

    /// ⌥⌘[ — nil when there is nowhere back.
    mutating func goBack() -> SidebarSelection? {
        guard let destination = back.popLast() else { return nil }
        if let current { forward.append(current) }
        current = destination
        return destination
    }

    /// ⌥⌘] — nil when nothing was walked back from.
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
    /// The reach of ⌘⇧1…⌘⇧9 — the first nine rows in strip order. **Since
    /// Act 10 item 9 this is a KEY cap, not a visibility cap**: the strip
    /// shows EVERY open note (the section itself scrolls past ~7 — her
    /// ruled shape, the starred precedent), so nothing she opens can ever
    /// land hidden. The name changed with the meaning (`visibleCap` would
    /// now be a lie).
    static let ordinalCap = 9
    /// **The ruled auto-close cap (her word, the Act 10 sitting): total
    /// open tabs cap at 20** — opening the 21st quietly closes the
    /// least-recently-opened note. A tab is a pointer; nothing is lost —
    /// the note stays in the library.
    static let trackedCap = 20

    /// Container ids in STRIP ORDER — insertion order, moved only by an
    /// explicit manual reorder and never by navigation. IDs only; the
    /// titles are resolved for display and never stored here.
    private(set) var ids: [String] = []

    /// The same set, most-recently-opened first. It answers exactly ONE
    /// question — who leaves when the tracked list is full — and never
    /// touches what the strip shows or what ⌘⇧n addresses.
    private(set) var recency: [String] = []

    /// **VX-139 — a strip restored from a previous launch.** Built directly
    /// rather than by replaying `opened(_:)`, because a replay would order
    /// the strip by recency and the stored strip's own order — including any
    /// manual arrangement she left it in — is exactly what is being kept.
    /// Defensive against a torn store: ids deduped, dead ids dropped by the
    /// caller's `isLive`, the tracked cap honored, and an id the recency
    /// list lost re-joins at its back (least recent, so eviction prefers it).
    init(restoringIDs storedIDs: [String], recency storedRecency: [String],
         isLive: (String) -> Bool) {
        var seenID = Set<String>()
        let kept = Array(
            storedIDs.filter { isLive($0) && seenID.insert($0).inserted }
                .prefix(Self.trackedCap))
        let keptSet = Set(kept)
        var seenRecency = Set<String>()
        var restoredRecency = storedRecency.filter {
            keptSet.contains($0) && seenRecency.insert($0).inserted
        }
        for id in kept where !seenRecency.contains(id) { restoredRecency.append(id) }
        ids = kept
        recency = restoredRecency
    }

    init() {}

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
    /// Offsets are the strip's rows — since Act 10 item 9 that is ALL of
    /// `ids` (nothing is hidden), so there is no mapping table that could
    /// go stale. Recency is untouched: rearranging the strip is not using
    /// a note.
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

    /// **Every open note, in strip order** (Act 10 item 9 — her ruled
    /// shape). The old prefix window is GONE: a newly opened note joined
    /// at the END and the prefix hid it — the newcomer landed invisible,
    /// her reported defect. Now the strip shows everything and the SECTION
    /// scrolls (the starred precedent); the dead "…N more open" label dies
    /// with the hidden set. `OpenStripPins` holds the newcomer red-on-old.
    var shown: [String] { ids }

    /// ⌘⇧n — 1-based, over the first `ordinalCap` rows (the keys are
    /// ⌘⇧1…⌘⇧9; rows past nine are click/scroll rows). nil where no nth
    /// row exists.
    func id(atOrdinal ordinal: Int) -> String? {
        guard ordinal >= 1, ordinal <= min(Self.ordinalCap, ids.count) else { return nil }
        return ids[ordinal - 1]
    }

    /// **The Open strip's MENU, as a table** (18o U3 — KnownIssues row 73).
    /// View ▸ Open Note renders exactly these rows, one menu item per row, in
    /// strip order: the item's title reads `noteID`, its key reads `keyText`,
    /// its act reads the row. Held here, as data, so the rule "which rows
    /// carry a key" is answerable without mounting a menu — and without
    /// building a `Character` from the key's text, which is the one step
    /// that can trap.
    ///
    /// **Only the first `ordinalCap` rows carry a key** — the model's own key
    /// cap, which the sidebar's ordinal badges and the ⌘⇧n address already
    /// honoured. Since Act 10 item 9 the strip holds up to `trackedCap` (20)
    /// notes, and this menu alone used to key EVERY row: the tenth asked for
    /// `Character("10")`, two graphemes, which traps the Debug app
    /// (`_debugPrecondition`, compiled out at -O — the Release app most
    /// likely built a malformed two-grapheme key). Rows past nine render by
    /// name, keyless, and still open their note (`ShellRouter.openStripRow`).
    var menuRows: [OpenStripMenuRow] {
        shown.enumerated().map { offset, id in
            let ordinal = offset + 1
            return OpenStripMenuRow(
                noteID: id, ordinal: ordinal,
                keyText: ordinal <= Self.ordinalCap ? String(ordinal) : nil)
        }
    }
}

// MARK: - VX-139 — the strip remembered across launches

/// **VX-139 — keep tabs open across app close and open** (her ticket ask
/// verbatim: *"a keep tabs open setting would be super helpful for when the
/// app closes and opens"*; pulled into the VX-143 run at her word,
/// 2026-10-11: *"I want it fixed now"*).
///
/// A STICKY THIS-MAC preference — the `writeHoverHandles` class: local
/// `UserDefaults`, never the synced `setting` table. The strip is one
/// window's chrome on one machine, and its ids would mean nothing to
/// another device's windows. The round-7.1 "session only, not a setting"
/// ruling governed the strip's MANUAL REORDER; her VX-139 ask extends the
/// strip's LIFETIME, and the remembered strip carries whatever order she
/// left it in — the reading recorded in the run record.
///
/// Storage is two parallel string arrays (never titles — navigation state
/// holds ids only, this file's own rule). `remember` honors the off-switch
/// LIVE: with the setting off it clears the stored rows instead of writing,
/// so "off" means off at the very next launch, not two launches later.
nonisolated enum OpenNotesMemory {
    /// The off-switch (default ON — the remembered strip is what she asked
    /// for; the setting exists to turn it off). LOCAL, this Mac.
    static let settingKey = "keepOpenNotes"
    static let idsKey = "openNotes.remembered.ids"
    static let recencyKey = "openNotes.remembered.recency"

    static func isOn(_ defaults: UserDefaults) -> Bool {
        defaults.object(forKey: settingKey) == nil || defaults.bool(forKey: settingKey)
    }

    static func remember(_ notes: OpenNotes, in defaults: UserDefaults) {
        guard isOn(defaults) else { return forget(defaults) }
        defaults.set(notes.ids, forKey: idsKey)
        defaults.set(notes.recency, forKey: recencyKey)
    }

    static func forget(_ defaults: UserDefaults) {
        defaults.removeObject(forKey: idsKey)
        defaults.removeObject(forKey: recencyKey)
    }

    static func stored(_ defaults: UserDefaults) -> (ids: [String], recency: [String]) {
        (defaults.stringArray(forKey: idsKey) ?? [],
         defaults.stringArray(forKey: recencyKey) ?? [])
    }
}

/// One row of View ▸ Open Note (18o U3 — KnownIssues row 73): the note it
/// names, its 1-based place in the strip, and the TEXT of its ⌘⇧ key — text,
/// not a `Character`, so the table can be read (and pinned) without ever
/// constructing one; the menu converts it at the one place it renders it.
nonisolated struct OpenStripMenuRow: Equatable, Sendable {
    let noteID: String
    let ordinal: Int
    /// The ⌘⇧ key's character, as text; nil where the row carries no key.
    let keyText: String?
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
        case .shelf: return "Bookcase"  // 13i-d U1 (§7: the section renamed)
        case .library: return "Library"
        case .poolPosts: return "Pool"
        case .blocks: return "Snippets"
        case .recovery: return RecoveryPath.menuLabel
        // Ledger row 8 (B2): the fifth area, named from the one home.
        case .archived: return RecoveryPath.archivedSurface
        case .post(let id): return resolved(id, in: titles) ?? "Untitled"
        case .pool(let id): return resolved(id, in: titles) ?? "Snippets"
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

    /// The back door's whole sentence — one place, so the tooltip and the
    /// registry's own note cannot disagree.
    ///
    /// **13k K11:** the spelled-out chip label retires with the bar's old
    /// presentation (the arrow is the door now), so `backLabel` is gone and
    /// the ORIGIN moved into this help — where a name is still worth
    /// having, because an arrow alone does not say where it lands. `nil` ⇒
    /// the door is grey, and it says why (the registry's `unavailableNote`,
    /// in the same words).
    ///
    /// **13u4 UNIT S1:** the chord is READ from the declaration rather than
    /// typed here. It was `⌘[` in this string and `⌥⌘[` in the registry the
    /// moment her item 5 moved the key — which is the same defect her item 7
    /// reports one menu over (a face typing a chord beside a registry that
    /// declares it). `shortcutLabel` is optional in the model, so the
    /// parenthesis simply drops if the act is ever un-keyed.
    static func backHelp(origin: String?) -> String {
        guard let origin else { return "Nothing to go back to \u{2014} this is where you started" }
        return "Back to \(origin)\(chordSuffix(.navigateBack))"
    }

    /// The declared chord in parentheses, or nothing at all.
    private static func chordSuffix(_ id: CapabilityID) -> String {
        guard let chord = CapabilityRegistry.capability(id).shortcutLabel else { return "" }
        return " (\(chord))"
    }

    /// 13k K11's second half — her words: *"after you just went back, i feel
    /// like you should be able to go forward"*. The forward act's face, and the
    /// mirror of `backHelp` down to its grey sentence.
    static func forwardHelp(destination: String?) -> String {
        guard let destination else {
            return "Nothing to go forward to \u{2014} you haven't gone back"
        }
        return "Forward to \(destination)\(chordSuffix(.navigateForward))"
    }

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

    // MARK: - The ascent + the bar's own fold (13f batch 5, W20)

    /// The book icon's help. **13k K11:** the icon IS the chooser now (the
    /// spelled-out "in <book>" sentence retired into it), so the help says
    /// what a click does at each of the three arities her ruling names —
    /// one book opens, several list, none is grey.
    ///
    /// Takes a NAME and a COUNT rather than the rows themselves: this
    /// vocabulary stays free of the core's model types, exactly as `label`
    /// takes a title map rather than containers.
    static func ascentHelp(topBook: String?, count: Int) -> String {
        guard count > 0, let topBook else { return "This note isn't in any book yet" }
        if count == 1 {
            return "Open \u{201c}\(topBook)\u{201d} at this note (\u{2318}-click to see it listed)"
        }
        return "This note is in \(count) books — click to pick one"
    }

    /// 13e E11 — the ascent's DECLARED refusal, the one thing the act was
    /// missing besides its catalog row (#55(i)'s "a formal availability rule
    /// and a written refusal"). It says the same thing the grey icon's tooltip
    /// says on a bookless note, in the registry's own register, so the
    /// declaration and the face cannot drift apart.
    static let ascentUnavailableNote =
        "This note isn't in any book yet — add it to one from the membership "
        + "chip above the note."

    /// The dropdown's own line, so the icon's help and the list it opens
    /// cannot disagree about how many books there are.
    static func ascentListHeader(count: Int) -> String {
        count == 1
            ? "This note is in 1 book — open it at this note:"
            : "This note is in \(count) books — open one at this note:"
    }

    /// 13k K12 — the ＃ door's two states. Her ruling made folding a
    /// deliberate, sticky choice, so the door must say which way it goes.
    /// **The tray badge's tooltip** (13j J2). The glyph alone cannot say
    /// what it opens, so the tooltip names the surface and the ONE number
    /// the badge shows — deleted blocks (sitting round 5).
    ///
    /// **The "plus N originals" clause is GONE (13j ladder B round-1
    /// residuals, item 1 — the batch-6 sanity pass's find):** its count
    /// came from `Queries.trayCounts`, which is fate-blind by design (the
    /// badge query must stay cheap — no family recursion), so a `.gone`
    /// original (family expired, or Delete Now named it) still counted —
    /// a number the panel truthfully does not show, under the exact
    /// "put any of them back" promise the B5 call ruled a `.gone` row
    /// must not carry. The panel's own sections name their rows ("kept —
    /// no clock", "goes with its deleted blocks"), so the extra rows
    /// explain themselves where the fates are actually known — the J8
    /// copy bar: a tooltip may not promise what a fate it cannot see.
    static func trayDoorHelp(deleted: Int) -> String {
        let deletedPhrase = deleted == 1
            ? "1 block deleted from this note"
            : "\(deleted) blocks deleted from this note"
        return "\(deletedPhrase) \u{2014} click to put any of them back"
    }

    /// The masthead's ONE tag door (the Act 10 correction round, row 15):
    /// the ＃ that slides the inline tag field out and back. ⌘⇧I is its
    /// keyboard twin (the retired fold's chord, re-pointed at the act).
    static func tagFieldHelp(open: Bool) -> String {
        open
            ? "Put the tag field away (\u{2318}\u{21e7}I or \u{238B})"
            : "Tag this note \u{2014} opens a field with the cursor in it (\u{2318}\u{21e7}I)"
    }

    /// The sidebar toggle's one name (menu item + toolbar tooltip) — the
    /// Act 10 correction round, batch A (row 2).
    static let toggleSidebarVerb = "Toggle Sidebar"

    // MARK: - The unfocused pane's own line (13g L5 — WT-5)

    /// What an UNFOCUSED pane calls itself. Her report: *"it's a bit
    /// confusing to see it return to read ? or write ? mode when you click
    /// away from it, if you were just in takes."*
    ///
    /// A pane that loses liveness renders read-cheap, and read-cheap looks
    /// like Write — so a pane she left in Takes read as a pane that had
    /// silently changed mode. It had not: the mode is remembered per note
    /// and comes straight back when the pane goes live again. This line is
    /// that fact, SAID: the pane names the mode it is holding, so the change
    /// on screen reads as "showing quietly" instead of "reset".
    ///
    /// `mode` is nil where a mode is not a thing the pane has (the shelf, a
    /// book, a tag folder, the scraps container), and then the pane wears
    /// its name alone, exactly as before.
    static func paneLine(_ name: String, mode: PostMode?) -> String {
        guard let mode else { return name }
        return "\(name) \u{00B7} \(mode.rawValue.lowercased())"
    }
}
