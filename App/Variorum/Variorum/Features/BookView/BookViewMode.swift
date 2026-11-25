//
//  BookViewMode.swift
//  Variorum (Mac)
//
//  **The book's modes, the mode row's table, and the navigator's floor** —
//  hoisted out of `BookStructureModel` and `BookView` (the VX-1036 run, batch
//  3) so the pure facts the mode row is measured by compile on their own: a
//  headless pin can read the very words the row draws and the floor the
//  navigator is given, without the book's view or its models. Every pre-hoist
//  name stays a forward — `BookStructureModel.ViewMode`, `BookView.tabOrder`,
//  `BookView.tabLabel` — so no call site or pin moved.
//

import CoreGraphics

/// **The book's modes** (`BookStructureModel.ViewMode` is this type — the
/// case history and the why of each name are documented there).
///
/// `.list` — **the fifth mode, List** (VX-1084; her R-1036-29 "List as a fifth
/// mode", R-1036-38 "List is rows only; outline is the cards"): the Library's
/// own note row inside the book, scoped to it — the book's order, its chapters
/// (or a gathering's assembly) as headings, a note per row with its day, its
/// tags behind the book's switch and when it was edited (`BookListView`). Like
/// Read it has no live editor of its own.
nonisolated enum BookViewMode: Hashable, Sendable {
    case outline, list, spread, read, index
}

/// **The book's mode row, in order, and each tab's word** — named once so the
/// onboarding tour's step 11 quotes the views it teaches (VX-292 U3; 13u4
/// UNIT S3's rule — a door's name is its constant) and the mode row's stable
/// width measures exactly the words the row draws (VX-887).
nonisolated enum BookModeTabs {
    /// outline · list · index · book · read (R-1036-29). List has NO chord:
    /// the book's modes carry none (the note modes' ⌘1–⌘7 refuse on a book
    /// surface — QUESTIONS #253), and a mode-row chord family is not this
    /// run's to invent.
    static let order: [BookViewMode] = [.outline, .list, .index, .spread, .read]

    static func label(_ mode: BookViewMode) -> String {
        switch mode {
        case .outline: "Outline"
        case .list: "List"
        case .index: "Index"
        case .spread: "Book"
        case .read: "Read"
        }
    }
}

/// **VX-1091 — the book navigator's floor, in a voice.** The navigator's mode
/// row never compresses its tabs (VX-887/896: the tabs own their line, the
/// order dial wraps below), so a floor narrower than the tabs' stable width
/// plus the navigator's padding lays the navigator out WIDER than its column
/// and `SideColumn` centres it over both edges (VX-1082's measured read: 191 pt
/// in a 190-pt column, Terminal).
nonisolated enum BookNavigatorFloor {
    /// The navigator's least width: the shipped floor, or — where the tabs
    /// need more — exactly the tabs' stable width plus the padding on each
    /// side, at a whole point (the row decides at whole points). With the
    /// fifth mode the accepted cost of R-1036-29 ("five modes need about 222 pt
    /// of navigator"): measured, 229 pt in Terminal and 203 in Study.
    static func width(tabs: CGFloat, shipped: CGFloat, inset: CGFloat) -> CGFloat {
        max(shipped, (tabs + 2 * inset).rounded(.up))
    }
}
