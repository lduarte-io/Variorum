//
//  ContextBarDoors.swift
//  Variorum (Mac)
//
//  Phase 13k, batch 3 (K11/K12) — the context bar's DECISIONS, as pure
//  functions, plus the one sticky preference the bar carries.
//
//  Her ruling K11: the bar is ALWAYS the compact icon row —
//  **← · book · ＃ · →** — *"the collapsing and growing in that bar is a
//  little annoying to me"* and *"it should always look like this"*. So the
//  row's SHAPE is a constant, and every door in it is either live or
//  honestly grey; nothing appears, disappears, or spells itself out.
//
//  Why the shape is a LIST rather than four `if`s in the view: the whole
//  point of her ruling is that the row does not change with the state, and
//  a claim of that kind is only a claim if a test can hold it. `iconRow`
//  is what the view iterates, so a future edit that hides a door where it
//  cannot act fails a pin instead of quietly re-growing the bar.
//
//  Her ruling K12: the tag cards ride that same row, VISIBLE at rest
//  (*"tag cards should fold into the bar if you deliberately choose that
//  but it should default to visible"*), and the ＃ icon is the deliberate
//  fold door — whose choice STICKS (`TagChipsFold`, below).
//

import Foundation

// MARK: - The row's shape and its doors

nonisolated enum ContextBarDoors {
    /// The row, in her screenshot's order. `Hashable` because the bar
    /// iterates it.
    enum Icon: Hashable, Sendable, CaseIterable {
        case back, book, tags, forward
    }

    /// **R4-1 — the two navigation glyphs are a MIRRORED PAIR**, her
    /// round-4 ruling after flicking the batch's captures: the forward
    /// chevron *"kind of looks like it's expanding the tags. i think it
    /// should just be replaced with an arrow like the back one -> for
    /// better clarity and a clearer match"*.
    ///
    /// The chevron sat immediately beside the ＃, where a `›` is the
    /// universal "unfold this" glyph — so it read as the tag door's twin
    /// rather than as ←'s. They live here, together, precisely so the
    /// mirror is a fact a pin can hold rather than two literals in a view
    /// that could drift apart.
    static let backGlyph = "\u{2190}"
    static let forwardGlyph = "\u{2192}"

    /// **THE CONSTANT ROW.** A pane holding a NOTE wears all four; a pane
    /// holding a PLACE (the shelf, the library, a book, the recovery
    /// surface) wears the two that mean anything there.
    ///
    /// The two note-only doors are ABSENT rather than grey at a place for
    /// P-2's reason — a door that can never act in its context isn't
    /// rendered — and that is a different rule from the greys inside the
    /// note's own row, where a note with no books still HAS a book door
    /// (her ruling names that case explicitly: *"the icon sits honestly
    /// grey"*).
    static func iconRow(isNote: Bool) -> [Icon] {
        isNote ? [.back, .book, .tags, .forward] : [.back, .forward]
    }

    /// What a click on the book icon DOES — her ruling, exactly: *"click =
    /// the book when exactly one"*, *"command click lets you see the list
    /// of books (or there's a dropdown if there's several books it could be
    /// in)"*, and nothing at all when the note is in none.
    enum BookClick: Equatable, Sendable {
        /// The door is grey: there is no book to open.
        case none
        /// The one book, revealed at this note (the standing W21 ascent).
        case open
        /// The dropdown — several books, or ⌘-click on one.
        case list
    }

    static func bookClick(bookCount: Int, commandHeld: Bool) -> BookClick {
        guard bookCount > 0 else { return .none }
        return commandHeld || bookCount > 1 ? .list : .open
    }

    /// What the ＃ door SAYS. Folded it carries the count (the shipped
    /// folded grammar, kept); unfolded the chips are right there, so a
    /// number beside them would only repeat what she can see.
    static func tagsDoorCount(folded: Bool, tagCount: Int) -> Int? {
        folded && tagCount > 0 ? tagCount : nil
    }

    /// Whether the bar renders at all. A pane holding a note always has
    /// something to say (its tag door, 13g R6-1's widening); a pane at a
    /// PLACE says something once it has been somewhere.
    ///
    /// A cold launch at the shelf therefore still keeps exactly the chrome
    /// it had before any of this shipped — the one thing the always-visible
    /// row must not undo.
    static func hasContent(
        isNote: Bool, canBack: Bool, canForward: Bool, bookCount: Int
    ) -> Bool {
        isNote || canBack || canForward || bookCount > 0
    }
}

// MARK: - The fold, and its stickiness (K12)

/// Whether the tag cards are folded away — **this Mac's own choice, and it
/// sticks** (her K12: folding is *"deliberately"* chosen, so it must still
/// be chosen the next time she opens the app).
///
/// The local-view-memory class, exactly like the hover handles, the
/// paragraph gap and the spellcheck level (`EditorBehaviorSettings`): app
/// `UserDefaults`, stored NOWHERE in the schema, never synced — it
/// describes how one Mac's chrome looks, not what a document means.
///
/// **DEFAULT FALSE = VISIBLE**, which is the flip her ruling makes (13g
/// #52(d) shipped the cards folded with the rest of the bar).
///
/// Views read it through `@AppStorage`, so the ⌘⇧I door and the ＃ icon —
/// and any second window — move together without a shared observable
/// object: `UserDefaults` is the one state, and every reader observes it.
nonisolated enum TagChipsFold {
    static let settingKey = "contextBarTagsFolded"

    /// **K12's flip, in ONE place.** The views read the key through
    /// `@AppStorage`, which needs a literal default of its own — so it
    /// reads this one, and there is no second statement of "visible by
    /// default" that could drift from this.
    static let defaultFolded = false

    static func folded(in defaults: UserDefaults = .standard) -> Bool {
        defaults.object(forKey: settingKey) as? Bool ?? defaultFolded
    }

    /// The act behind both doors (⌘⇧I and ＃). Returns the new state so a
    /// caller can speak it; nothing here speaks.
    @discardableResult
    static func toggle(in defaults: UserDefaults = .standard) -> Bool {
        let next = !folded(in: defaults)
        defaults.set(next, forKey: settingKey)
        return next
    }
}
