//
//  NoteRowSelection.swift
//  Variorum (Mac)
//
//  **P-0 — WHAT A CLICK ON A NOTE ROW MEANS** (13l, the end-of-phase ladder;
//  the architect's adjudication promoted it from the Act 7 walk's propose-only
//  list to a DEFECT: her third clause from the 13j close — *"allow for command
//  clicking to select multiple items and deleting all of them"* — had its act,
//  its confirm, its receipt and its pins, and the door was DEAD in the shipped
//  build).
//
//  ── THE MECHANISM, TRACED ────────────────────────────────────────────────
//  `LibraryCatalogView.postRow` carried `.onTapGesture { onOpen(…) }` over a
//  `.contentShape(Rectangle())` covering the whole row, inside
//  `List(selection: $selectedPosts)` with each row `.tag(hit.id)`. A SwiftUI
//  `onTapGesture` consumes the click before the List's own selection handling
//  ever sees it, and a bare `TapGesture` cannot tell one modifier from
//  another — so ⌘-click OPENED the note, `selectedPosts` never filled, and
//  the bulk bar ("Delete N notes…", "Tag N notes") could not appear. The
//  bulk TAG menu had been unreachable the same way since long before 13l.
//
//  ── WHY THE ROUTING LIVES HERE AND NOT IN THE VIEW ───────────────────────
//  Because the defect was a routing decision made inside a gesture closure,
//  which nothing could reach. The decision is now a pure function over the
//  modifiers, the current pick and the list's order, and the model owns the
//  state — so a pin drives the real answer ("does a ⌘-click open?") instead
//  of asserting that a button exists. What remains unpinnable is exactly two
//  lines: reading `NSEvent.modifierFlags`, and the `onTapGesture` that calls
//  in. Those were verified by driving the running app, not by a test that
//  pretends (the ladder record has the walk).
//

#if canImport(AppKit)
import AppKit
#endif
import Foundation

/// The modifiers a row click carried. A value of our own rather than
/// `NSEvent.ModifierFlags` so the rules below are pure and testable, with the
/// one impure read named and isolated in `current`.
nonisolated struct NoteRowClickModifiers: Equatable, Sendable {
    var command = false
    var shift = false

    static let none = NoteRowClickModifiers()
    static let command_ = NoteRowClickModifiers(command: true)
    static let shift_ = NoteRowClickModifiers(shift: true)

    #if canImport(AppKit)
    /// **THE ONE IMPURE LINE.** SwiftUI's `onTapGesture` never reports
    /// modifiers, and layering `TapGesture().modifiers(.command)` on top of an
    /// existing tap makes the answer depend on gesture-priority ordering — two
    /// mechanisms deciding one question. `NSEvent.modifierFlags` is the
    /// keyboard's current state, read synchronously inside the click's own
    /// handling, which is when it is true.
    @MainActor
    static var current: NoteRowClickModifiers {
        let flags = NSEvent.modifierFlags
        return NoteRowClickModifiers(
            command: flags.contains(.command), shift: flags.contains(.shift))
    }
    #endif
}

/// What the click means.
///
/// **Act 10 item 10 — HER CLICK MODEL, ruled at the sitting:** a click on
/// the ROW BODY selects and shows the info panel (it used to be a dead
/// highlight); a click on the TITLE TEXT still opens instantly, as today;
/// a DOUBLE-CLICK anywhere on the row opens. The title and double-click
/// roads call open directly at the view (no modifier logic to run), so the
/// intent vocabulary here is the modifier-bearing single click's.
nonisolated enum NoteRowIntent: Equatable, Sendable {
    /// Plain click on the row body — select this one row and show its info
    /// panel (her ruling; supersedes the shipped plain-click-opens and
    /// resolves QUESTIONS #79's PROVISIONAL: a plain click REPLACES the
    /// pick with this row, so the pick still has its exit).
    case select
    /// ⌘-click — add this row to the pick, or take it out again.
    case toggle
    /// ⇧-click — take everything from the anchor to here.
    case extendRange
}

/// The pick a click produces. **Pure**: it decides, the caller stores.
nonisolated enum NoteRowSelection {
    static func intent(for modifiers: NoteRowClickModifiers) -> NoteRowIntent {
        // ⌘ wins a ⌘⇧-click: it is the gesture she was told about, and
        // "toggle this one" is the outcome that cannot surprise.
        if modifiers.command { return .toggle }
        if modifiers.shift { return .extendRange }
        return .select
    }

    /// The pick and the anchor after a click on `row`.
    ///
    /// - `order`: the note ids **as the list is showing them**, which is what
    ///   makes a ⇧-range mean what she is pointing at (the same reason
    ///   `selectedNotesInListOrder` exists — a `Set` has no order, so every
    ///   ordered answer has to come from the list).
    /// - A ⇧-click with no anchor picks that one row: there is no range yet,
    ///   and refusing would be a door that does nothing.
    /// - A plain click REPLACES the pick with this one row (her Act 10
    ///   ruling — select + show info). Every Mac list behaves that way, and
    ///   the pick keeps its exit: click anywhere else and the three she
    ///   ⌘-picked collapse to the one she is looking at.
    static func apply(
        _ intent: NoteRowIntent,
        row: String,
        to selection: Set<String>,
        anchor: String?,
        order: [String]
    ) -> (selection: Set<String>, anchor: String?) {
        switch intent {
        case .select:
            return ([row], row)
        case .toggle:
            var next = selection
            if next.contains(row) { next.remove(row) } else { next.insert(row) }
            return (next, row)
        case .extendRange:
            guard let anchor,
                  let from = order.firstIndex(of: anchor),
                  let to = order.firstIndex(of: row)
            else { return (selection.union([row]), row) }
            let span = from <= to ? order[from...to] : order[to...from]
            return (selection.union(span), anchor)
        }
    }
}
