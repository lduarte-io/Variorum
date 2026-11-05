//
//  TagManagerCopy.swift
//  Variorum (Mac)
//
//  Settings ▸ Tags' own words, in one place so a pin reads the sentence
//  rather than a rendering of it — and (VX-840) the sweep sheet's linked
//  boxes, a pure rule beside the words that describe it.
//

import Foundation

nonisolated enum TagManagerCopy {
    /// **VX-838 (the VX-828 run, batch E — her pick R-828-2):** the pane NAMES
    /// its wing in its header. The vocabulary is per-wing (R-13ia-1), and a
    /// wing-scoped list that never said which wing it was is the bug's root.
    /// "in ‹wing›" is the window toolbar's own phrase for the wing you're in
    /// (VX-552's label beside New Note), so the two read as one sentence; the
    /// header voices it as chrome, the toolbar's way. Home is "Home".
    static func title(wingName: String) -> String {
        "Tags \u{2014} in \(wingName)"
    }

    // MARK: - VX-840 — the unused-tags sweep (PROVISIONAL words, hers to tune)

    /// The registry verb (`.deleteUnusedTags`) — the undo entry says the same
    /// ("Undo Delete Unused Tags", `Operations.deleteUnusedTagsUndoLabel`).
    static let sweepVerb = "Delete Unused Tags"

    /// The door, carrying the count it lists (batch D's "Delete 3 empty
    /// blocks…" shape — the ellipsis is the sheet it opens).
    static func doorLabel(count: Int) -> String {
        "Delete \(count) unused \(count == 1 ? "tag" : "tags")\u{2026}"
    }

    static let doorHelp =
        "Tags no note, snippet or thing in the Trash wears \u{2014} you choose which go"

    static func sheetTitle(wingName: String) -> String {
        "Unused tags in \(wingName)"
    }

    static let sheetLine = "No note or block wears these \u{2014} nothing in the Trash does either. "
        + "Uncheck any you want to keep; \u{2325}\u{2318}Z puts the rest back."

    /// The sheet's destructive button — the checked count.
    static func confirmVerb(count: Int) -> String {
        "Delete \(count) \(count == 1 ? "Tag" : "Tags")"
    }

    /// The receipt, in the pane's own message line (the Settings window has
    /// no status bar) — counting what really went, never what the sheet
    /// guessed (Empty Trash's rule).
    static func receipt(count: Int) -> String {
        count == 1
            ? "Deleted 1 unused tag \u{2014} \u{2325}\u{2318}Z puts it back."
            : "Deleted \(count) unused tags \u{2014} \u{2325}\u{2318}Z puts them back."
    }

    /// The race's refusal: everything she checked was worn (or gone) by the
    /// press — nothing was written.
    static let nothingLeftToDelete =
        "None of those tags are unused any more \u{2014} nothing was deleted."
}

/// **VX-840 — the sheet's LINKED BOXES** (the fork's ruling Q-E3 (i)): every
/// unused tag listed, all checked; the boxes encode `deleteTag`'s subtree
/// reality, so they never promise what the operation would not do —
/// unchecking a tag unchecks its listed ANCESTORS (deleting an ancestor would
/// take the kept child with it), checking a tag checks everything listed
/// UNDER it. So a checked tag's listed subtree is always wholly checked, and
/// the act deletes exactly the checked set. Pure: the pins drive it.
///
/// "Under" is `tagSubtree`'s own rule — the same stored wing and the path
/// prefix. UNUSED is closed downward (vx-809's brain is subtree-honest), so
/// the listed subtree of an unused tag IS its whole live subtree.
nonisolated struct UnusedTagSelection: Equatable, Sendable {
    nonisolated struct Row: Equatable, Sendable, Identifiable {
        let id: String
        let name: String
        let path: String
        let wingID: String
        /// Path components below its root — the manager's indent.
        var depth: Int { path.reduce(0) { $0 + ($1 == "/" ? 1 : 0) } }
    }

    /// The listed tags, in the listing's path order.
    let rows: [Row]
    private(set) var checked: Set<String>

    init(rows: [Row]) {
        self.rows = rows
        self.checked = Set(rows.map(\.id))
    }

    func isChecked(_ id: String) -> Bool { checked.contains(id) }

    /// The checked ids, in the list's order — what the act is handed.
    var checkedIDs: [String] { rows.map(\.id).filter(checked.contains) }

    var checkedCount: Int { checked.count }

    /// Flips one box, carrying the subtree rule (above).
    mutating func toggle(_ id: String) {
        guard let row = rows.first(where: { $0.id == id }) else { return }
        if checked.contains(id) {
            checked.remove(id)
            for other in rows where Self.isAncestor(other, of: row) { checked.remove(other.id) }
        } else {
            checked.insert(id)
            for other in rows where Self.isAncestor(row, of: other) { checked.insert(other.id) }
        }
    }

    /// `a` holds `b` under it: the same stored wing, and `b`'s path runs on
    /// past `a`'s at a "/".
    static func isAncestor(_ a: Row, of b: Row) -> Bool {
        a.wingID == b.wingID && b.path.hasPrefix(a.path + "/")
    }
}
