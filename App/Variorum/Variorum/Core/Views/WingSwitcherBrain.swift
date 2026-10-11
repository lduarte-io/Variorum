//
//  WingSwitcherBrain.swift
//  Variorum (MAC ONLY) — Core/Views (the ⌘L switcher and the mastheads'
//  cycling word both read it)
//
//  13n-c U4 — ⌘L, THE WING SWITCHER (R-AIR-15, hers, ratified: "i like
//  Command L" — "press opens the switcher, typing filters, holding ⌘ and
//  tapping L cycles (the ⌘-tab idiom), release/return commits; the masthead
//  switcher clicked without typing also cycles"; R-AIR-5: "fast navigation is
//  important"). PURE, because the held-⌘ cycling cannot be walked while the
//  session is locked — its state transitions are pinned instead
//  (`WingSwitcherTests`).
//
//  THE STATE MACHINE, as ruled and as read where her words leave room:
//  · ⌘L OPENS it with the CURRENT wing highlighted (the press that opens is
//    not a cycle — so typing can follow);
//  · each further L while ⌘ is held moves the highlight to the next visible
//    wing, wrapping, and arms COMMIT-ON-RELEASE;
//  · releasing ⌘ commits the highlight ONLY when an L was tapped while held
//    (a plain ⌘L press-and-release leaves the field open for typing — the
//    reading that keeps "typing filters" possible at all);
//  · typing filters (the ONE picker brain's sameness — case- and
//    diacritic-insensitive contains) and highlights the first match; ⏎
//    commits the highlight; ↑/↓ step it; Esc closes;
//  · committing the CURRENT wing switches nothing — it closes.
//  The masthead's cycling click is `next(after:in:)`: the wing after the
//  current one, wrapping — nil with one wing (there is nothing to cycle to,
//  so the word is not a cycle door — P-2).
//

import Foundation

nonisolated struct WingSwitcherBrain: Equatable, Sendable {
    nonisolated struct Row: Equatable, Identifiable, Sendable {
        let id: String
        let name: String
    }

    nonisolated enum Outcome: Equatable, Sendable {
        /// Nothing to do yet — the switcher stays up.
        case stay
        /// Switch to this wing (never the current one) and close.
        case commit(String)
        /// Close without switching.
        case close
    }

    /// Every wing, Home first, in the switcher's order.
    let rows: [Row]
    let currentID: String
    private(set) var query = ""
    /// The highlighted row's id (nil only when nothing is visible).
    private(set) var highlight: String?
    /// An L was tapped while ⌘ was held — releasing ⌘ now commits.
    private(set) var cycling = false

    init(rows: [Row], currentID: String) {
        self.rows = rows
        self.currentID = currentID
        highlight = rows.contains { $0.id == currentID } ? currentID : rows.first?.id
    }

    /// The rows the query shows, in order.
    var visible: [Row] {
        let needle = SearchPickerBrain.normalized(query)
        guard !needle.isEmpty else { return rows }
        return rows.filter {
            $0.name.range(of: needle, options: [.caseInsensitive, .diacriticInsensitive]) != nil
        }
    }

    // MARK: - Events

    /// Typing filters; the first visible row takes the highlight. A typed
    /// change ends a held-⌘ cycle (she is choosing by name now).
    mutating func type(_ text: String) {
        query = text
        highlight = visible.first?.id
        cycling = false
    }

    /// ⌘ held, L tapped again: the next visible row, wrapping.
    mutating func tapL() {
        step(by: 1)
        if highlight != nil { cycling = true }
    }

    /// ↑/↓ — step the highlight (wrapping), no commit armed.
    mutating func move(by delta: Int) {
        step(by: delta)
    }

    private mutating func step(by delta: Int) {
        let shown = visible
        guard !shown.isEmpty else {
            highlight = nil
            return
        }
        let at = shown.firstIndex { $0.id == highlight } ?? (delta > 0 ? -1 : 0)
        let count = shown.count
        highlight = shown[((at + delta) % count + count) % count].id
    }

    /// ⌘ released.
    func commandReleased() -> Outcome {
        cycling ? commit() : .stay
    }

    /// ⏎.
    func returnPressed() -> Outcome {
        highlight == nil ? .stay : commit()
    }

    /// A row clicked.
    func pick(_ id: String) -> Outcome {
        id == currentID ? .close : .commit(id)
    }

    private func commit() -> Outcome {
        guard let highlight else { return .stay }
        return highlight == currentID ? .close : .commit(highlight)
    }

    // MARK: - The masthead's cycling click

    /// The wing after `current` in `rows`, wrapping — nil when there is no
    /// other wing to go to.
    static func next(after current: String, in rows: [Row]) -> Row? {
        guard rows.count > 1 else { return nil }
        let at = rows.firstIndex { $0.id == current } ?? -1
        let next = rows[(at + 1) % rows.count]
        return next.id == current ? nil : next
    }
}
