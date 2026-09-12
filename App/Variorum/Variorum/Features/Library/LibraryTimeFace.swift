//
//  LibraryTimeFace.swift
//  Variorum (Mac)
//
//  **18h batch 1 — TIME in the Library** (the 2026-09-12 use-report round,
//  her ledger rows 9 and 10; rulings R-Q7 and R-Q8's first half). Her words:
//  *"i need to be able to sort the library by time… the time alone is a
//  minimum"* and *"I need to be able to see the created time and last edited
//  time easily on the library."*
//
//  Three small things live here, one theme, and deliberately NOT inside
//  `LibraryCatalogView.swift` — that file is already 1,300 lines and a
//  feature bolted into it is exactly the god-file the constitution's P-9 and
//  this round's review focus F-0 name:
//
//  1. `LibrarySortFace` — the sort vocabulary's WORDS and the two rules that
//     go with them (each sort's natural direction; which stamp a row shows
//     under it). Pure, so no view spells a label or decides a subject.
//  2. `LibrarySortMenu` — the `sort ▾` door: one `VoicedMenu` (the chrome
//     vocabulary, P-8) the header composes in one line.
//  3. `CatalogRowStamp` — the muted trailing stamp BOTH row renderers wear,
//     so the List row and the Notes card can never say a note's time
//     differently.
//
//  The WORDS themselves are `TimeStampFace`'s (core `Domain`) — one brain
//  for the Library's rows, the note masthead's stamp and 18d's facts line.
//

import Foundation
import SwiftUI
import VariorumCore

// MARK: - The sort vocabulary's face

/// What the `sort ▾` door says, and the two rules that ride its words.
///
/// `Queries.LibrarySort` is the core vocabulary (five cases, one of them
/// unoffered here — `lastMajorRevision`, which the timeline uses); this is
/// the FACE over it. Keeping the four offered cases in one ordered constant
/// is what makes "her four, in her order" a claim a pin can hold instead of
/// a `ForEach` over an enum that would silently gain a row.
nonisolated enum LibrarySortFace {
    /// Her four, in her order (Q-8: *"edited (the default, as today) ·
    /// created · date (entry date) · title A–Z"*).
    static let offered: [Queries.LibrarySort] = [.lastTouched, .createdAt, .entryDate, .title]

    /// One lower-case word per sort — the menu's rows and half the door's
    /// own label.
    ///
    /// **A forwarder since the 18h ladder (R1-7):** the table itself is
    /// `LibrarySortWords` in `Shared/`, read by the phone's picker too, so
    /// one core vocabulary can no longer be called two different things on
    /// two surfaces. The name stays here so every call site and pin in this
    /// letter reads unchanged.
    static func label(_ sort: Queries.LibrarySort) -> String {
        LibrarySortWords.label(sort)
    }

    /// The direction, in the SORT'S own language: a stamp runs newest →
    /// oldest, a name runs A → Z. "Descending" is a database word.
    static func directionLabel(
        _ sort: Queries.LibrarySort, _ direction: SortDirection
    ) -> String {
        switch sort {
        case .title:
            return direction == .asc ? "A–Z" : "Z–A"
        case .lastTouched, .createdAt, .entryDate, .lastMajorRevision:
            return direction == .desc ? "newest first" : "oldest first"
        }
    }

    /// The door's own label — what the list is DOING, so she never has to
    /// open the menu to find out.
    static func doorLabel(
        _ sort: Queries.LibrarySort, _ direction: SortDirection
    ) -> String {
        "\(label(sort)) \u{B7} \(directionLabel(sort, direction))"
    }

    /// **Picking a sort takes its natural direction** (the batch's call,
    /// recorded in the round's record): newest-first for a stamp, A–Z for a
    /// name — the reading every list-sorting control in the OS gives. An
    /// explicit direction pick then stands until the next sort pick, which
    /// is the same control's convention: switching the column resets the
    /// arrow.
    static func naturalDirection(for sort: Queries.LibrarySort) -> SortDirection {
        sort == .title ? .asc : .desc
    }

    /// **Which stamp a ROW shows under this sort** (the brief's rule): the
    /// sort's own — edited under edited, created under created, the stated
    /// day under date. Under `title` the order says nothing about time, so
    /// the useful stamp is the edit (what she asked to see "easily" in the
    /// first place).
    static func stampSubject(_ sort: Queries.LibrarySort) -> TimeStampFace.Subject {
        switch sort {
        case .createdAt: .created
        case .entryDate: .dated
        case .lastTouched, .lastMajorRevision, .title: .edited
        }
    }

    /// What a row's trailing stamp IS: the subject and the stored value
    /// together, from the one hit the row is drawing.
    ///
    /// Handed out as a pair rather than as two calls so a renderer cannot
    /// pick the subject from one sort and the value from another — the
    /// mismatch would read as a confident lie ("created today" over an edit
    /// stamp), which is the worst failure a date face can have.
    struct RowStamp: Equatable {
        let subject: TimeStampFace.Subject
        /// nil ⇒ this row has no such stamp (a book or block hit), and the
        /// face draws nothing.
        let stamp: String?
    }

    static func rowStamp(
        _ sort: Queries.LibrarySort, for hit: Queries.CatalogHit
    ) -> RowStamp {
        let subject = stampSubject(sort)
        // NOTES only, said outright rather than left to the parse: a book
        // hit's `detail` is the word "book" and a block's is its home note's
        // title, and neither is a date. `TimeStampFace` would refuse both
        // anyway, but a face that relies on a parse failing is a face one
        // edit away from printing nonsense.
        guard hit.kind == .post else { return RowStamp(subject: subject, stamp: nil) }
        switch subject {
        case .created: return RowStamp(subject: subject, stamp: hit.createdAt)
        case .dated: return RowStamp(subject: subject, stamp: hit.detail)
        case .edited: return RowStamp(subject: subject, stamp: hit.lastTouchedAt)
        }
    }
}

// MARK: - The door

/// The Library header's `sort ▾` — the four sorts, then the two directions
/// in the current sort's language. A pick is handed up; the model owns the
/// value and its memory, and the view spawns the re-read (the catalog's own
/// convention: no hidden task inside a `didSet`, so a pin can drive the same
/// two steps the menu does).
struct LibrarySortMenu: View {
    let tokens: VoiceTokens
    let sort: Queries.LibrarySort
    let direction: SortDirection
    let onPick: (Queries.LibrarySort) -> Void
    let onDirection: (SortDirection) -> Void

    var body: some View {
        VoicedMenu(
            tokens: tokens, label: LibrarySortFace.doorLabel(sort, direction), role: .secondary
        ) {
            ForEach(LibrarySortFace.offered, id: \.self) { option in
                Button {
                    onPick(option)
                } label: {
                    // The tick is the ✓ grammar the rest of the chrome uses
                    // for "this is the one" (R12/R22's own mark).
                    Text(option == sort
                         ? "\u{2713} \(LibrarySortFace.label(option))"
                         : LibrarySortFace.label(option))
                }
            }
            Divider()
            ForEach([SortDirection.desc, .asc], id: \.self) { option in
                Button {
                    onDirection(option)
                } label: {
                    Text(option == direction
                         ? "\u{2713} \(LibrarySortFace.directionLabel(sort, option))"
                         : LibrarySortFace.directionLabel(sort, option))
                }
            }
        }
        .help("Sort the notes — edited · created · date · title, newest or oldest first")
    }
}

// MARK: - The row's stamp

/// A note row's muted trailing stamp: *edited today 1:33 AM* · *created
/// Sep 9* · *dated yesterday*, whichever the sort is about, with the whole
/// fact on hover.
///
/// Nothing is drawn when the row has no such stamp (a book or block hit, a
/// column that is not a stamp) — a face draws nothing rather than a lie.
/// `lineLimit(1)` beside `fixedSize` is load-bearing chrome law (P-8, the
/// wedged-window class).
struct CatalogRowStamp: View {
    let tokens: VoiceTokens
    /// The subject and its stored value, from `LibrarySortFace.rowStamp` —
    /// one value so the two can never disagree.
    let face: LibrarySortFace.RowStamp
    /// "now", for the relative rule (the `SidebarNoteBox` convention:
    /// defaulted here, injected by a pin so the pin holds the rule and not
    /// the machine's clock).
    var now: Date = Date()
    /// The DEBUG baseline probe, the `NoteTagsRow` convention: a prefix on
    /// the rows pinned for alignment (`LibraryRowAlignmentTests`), nil
    /// elsewhere — `baselineProbe` itself no-ops on a nil id.
    var baselineProbePrefix: String?
    var baselineProbeSpace: String = ""

    var body: some View {
        if let words = TimeStampFace.stamp(face.subject, iso: face.stamp, now: now) {
            Text(tokens.chromeLabel(words))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
                .fixedSize()
                .help(TimeStampFace.tooltip(face.subject, iso: face.stamp) ?? words)
                .baselineProbe(baselineProbePrefix.map { "\($0).stamp" }, in: baselineProbeSpace)
        }
    }
}
