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

    /// **THE TWO FACTS A NOTE ROW CAN SHOW** (17q — her ruling R-Q17 on
    /// QUESTIONS #103, 2026-09-13: *"in the library / pool there's enough
    /// room to show both. if the area is small, the same UI i mentioned
    /// earlier of clicking on the time should switch to show you the date
    /// created or the date associated with the note"*).
    ///
    /// ONE rule, both note renderers — the List row and the Notes card — so
    /// the two modes can no longer word one note's time differently (the 18h
    /// ladder's R3-2, which found the List row still printing the raw stored
    /// `entry_date` beside worded stamps, and the same day twice under the
    /// `date` sort).
    struct RowStamps: Equatable {
        /// **The day she stated** (`entry_date`) — the fact the Notes card's
        /// one slot carried from 13g until 18h, and the List row's
        /// beside-the-title slot. nil-stamped when she never stated one.
        let stated: RowStamp
        /// **The other fact worth the glance:** the SORT's own stamp — or,
        /// when the sort IS the stated day, the EDIT stamp, so one fact is
        /// never printed twice (R3-2's letter).
        let other: RowStamp
        /// True when the sort's own stamp IS the stated day (`.entryDate`).
        let sortIsTheStatedDay: Bool

        /// The one a SMALL card shows before she clicks: the SORT's own, so
        /// the stamp on screen always explains the order she is looking at.
        var sorted: RowStamp { sortIsTheStatedDay ? stated : other }
        /// The one her click reveals.
        var unsorted: RowStamp { sortIsTheStatedDay ? other : stated }

        /// **The List row's beside-the-title day** — the stated day, or
        /// NOTHING when the row's trailing stamp is already saying that same
        /// day (R3-2: one fact, never twice). The List row keeps its trailing
        /// stamp exactly as 18h shipped it, so this is the only slot 17q
        /// moves there.
        var listDay: String? { sortIsTheStatedDay ? nil : stated.stamp }
    }

    static func rowStamps(
        _ sort: Queries.LibrarySort, for hit: Queries.CatalogHit
    ) -> RowStamps {
        let sorted = rowStamp(sort, for: hit)
        let isTheStatedDay = sorted.subject == .dated
        return RowStamps(
            stated: isTheStatedDay ? sorted : rowStamp(.entryDate, for: hit),
            // When the sort IS the stated day the OTHER fact is the edit
            // stamp — the honest second, and the one she asked to see
            // "easily" in the first place.
            other: isTheStatedDay ? rowStamp(.lastTouched, for: hit) : sorted,
            sortIsTheStatedDay: isTheStatedDay)
    }

    /// The door's tooltip, COMPOSED from the offered cases and the one word
    /// table (the 18h ladder's R3-8 — the shipped literal re-spelled the four
    /// words, so a rename in `LibrarySortWords` left it lying).
    static var doorHelp: String {
        "Sort the notes \u{2014} " + offered.map(label).joined(separator: " \u{B7} ")
            + ", newest or oldest first"
    }

    /// What a click on a small card's one stamp is about to do — the
    /// masthead's own tooltip grammar (*"click to see when it was
    /// created"*), said here so no view body spells it.
    static func flipHint(to subject: TimeStampFace.Subject) -> String {
        switch subject {
        case .created: "click to see when it was created"
        case .edited: "click to see when it was last edited"
        case .dated: "click to see the day this note is about"
        }
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
        // The 18h ladder's R3-8: composed from the one word table, never
        // re-spelled here — a rename in `LibrarySortWords` used to leave this
        // sentence stale (the drift R1-7 closed one file over).
        .help(LibrarySortFace.doorHelp)
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
    /// Which slot of the row this stamp is — `note.stamp` by default (the
    /// trailing one 18h shipped); the List row's beside-the-title day passes
    /// `date`, so the shipped alignment pin's `note.stamp` keeps meaning what
    /// it measured.
    var baselineProbeName: String = "stamp"
    /// The DEBUG words oracle: the note this stamp is about, and which slot
    /// it fills. Both nil off the pinned surfaces (KnownIssues row 53: an
    /// oracle is keyed by its SUBJECT, never global).
    var oracleKey: String?
    var oracleSlot: String = ""
    /// One clause appended to the tooltip where a click does something (the
    /// small card's flipping stamp) — the words are `LibrarySortFace`'s.
    var helpSuffix: String?

    var body: some View {
        if let words = TimeStampFace.stamp(face.subject, iso: face.stamp, now: now) {
            let whole = TimeStampFace.tooltip(face.subject, iso: face.stamp) ?? words
            Text(tokens.chromeLabel(words))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
                .fixedSize()
                .help(helpSuffix.map { "\(whole) \u{2014} \($0)" } ?? whole)
                .baselineProbe(
                    baselineProbePrefix.map { "\($0).\(baselineProbeName)" },
                    in: baselineProbeSpace)
                .recordCatalogStamp(oracleKey, slot: oracleSlot, words: words)
        }
    }
}

// MARK: - The Notes card's pair (17q — her ruling R-Q17)

/// **BOTH FACTS WHERE THERE IS ROOM; ONE, WITH THE CLICK-FLIP, WHERE THERE
/// IS NOT** (her R-Q17 on QUESTIONS #103, 2026-09-13: *"in the library /
/// pool there's enough room to show both. if the area is small, the same UI
/// i mentioned earlier of clicking on the time should switch to show you the
/// date created or the date associated with the note"*).
///
/// **ONE width-aware decision, not two layouts** — `ViewThatFits(in:
/// .horizontal)` picks the first arrangement whose IDEAL width fits the room
/// the card's title row leaves. Every member is `fixedSize` + `lineLimit(1)`
/// (`CatalogRowStamp` already is), which is what makes the judgement honest:
/// a compressible child makes `ViewThatFits` call every arrangement a fit
/// (the N15 gotcha, `CommitBar.boxPair`'s own doc).
///
/// **The small arrangement reuses the masthead's grammar** (`MastheadStamp`):
/// a quiet button, the flip as VIEW state per note defaulting to the sort's
/// own stamp, the tooltip saying the whole fact and what a click will show.
/// It is not the same TYPE: the masthead flips between two subjects of a
/// HELD `noteStamps` observation and carries the masthead's geometry probe,
/// while this flips between two already-computed `RowStamp`s a catalog hit
/// carries — so the shared thing is the WORDS (`TimeStampFace`, one brain)
/// and the tooltip grammar, and a `FlippingStamp` hoist is named for the next
/// touch rather than forced here (17q's record).
///
/// With only ONE fact to show (a note with no stated day) there is no flip
/// door at all — a door that could not act is not rendered (P-2).
struct CatalogCardStamps: View {
    let tokens: VoiceTokens
    /// The note this card draws — the DEBUG oracle's key.
    let postID: String
    let stamps: LibrarySortFace.RowStamps
    /// "now", for the relative rule (the `CatalogRowStamp` convention).
    var now: Date = Date()

    @State private var showsTheOther = false

    var body: some View {
        Group {
            if stamps.stated.stamp != nil, stamps.other.stamp != nil {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        stamp(stamps.stated, slot: "card.wide.stated")
                        stamp(stamps.other, slot: "card.wide.other")
                    }
                    flipping
                }
            } else {
                stamp(stamps.stated.stamp != nil ? stamps.stated : stamps.other, slot: "card.only")
            }
        }
        // The 17q ladder's R1-8: the flip is a glance at THIS pair. When the
        // fact the small card opens on changes identity — a sort change
        // (`edited` → `created` moves `other`'s subject; `date` makes the
        // stated day the sorted one) — the glance is over, or a flipped card
        // would silently show a different fact without a click. Keyed on the
        // SUBJECT, never the whole pair: an autosave moving the edit stamp
        // must not cancel a glance (the masthead's own rule — per note, not
        // per keystroke).
        .onChange(of: stamps.sorted.subject) { _, _ in showsTheOther = false }
    }

    private func stamp(_ face: LibrarySortFace.RowStamp, slot: String) -> some View {
        CatalogRowStamp(
            tokens: tokens, face: face, now: now, oracleKey: postID, oracleSlot: slot)
    }

    private var shown: LibrarySortFace.RowStamp {
        showsTheOther ? stamps.unsorted : stamps.sorted
    }

    private var flipping: some View {
        Button {
            showsTheOther.toggle()
        } label: {
            CatalogRowStamp(
                tokens: tokens, face: shown, now: now,
                oracleKey: postID, oracleSlot: "card.small",
                helpSuffix: LibrarySortFace.flipHint(
                    to: showsTheOther ? stamps.sorted.subject : stamps.unsorted.subject))
        }
        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
        .fixedSize()
        .catalogStampFlipDoor(postID) { showsTheOther.toggle() }
    }
}

// MARK: - The DEBUG words oracle (the `TakesCellChrome` pattern)

#if DEBUG
/// What a note row's time slots actually DREW, keyed by the note (row 53's
/// rule: an oracle keyed by its subject, never a global singleton), and what
/// a click on a small card's one stamp does. Idempotent across re-renders —
/// a slot writes its own words, so a body that runs twice records once.
@MainActor enum CatalogStampOracle {
    static var shown: [String: [String: String]] = [:]
    static var flip: [String: @MainActor () -> Void] = [:]

    static func record(_ key: String?, slot: String, words: String) {
        guard let key, !slot.isEmpty else { return }
        shown[key, default: [:]][slot] = words
    }

    /// Forget this note's slots — called before a pin's mount so a stale
    /// report cannot satisfy it. (The 17q ladder's R1-4: this used to claim
    /// the card called it on its way out; nothing did, and `shown` grew a
    /// row per note ever rendered. Each STAMP now forgets its own slot on
    /// `onDisappear` — `forget(_:slot:)` — and the flip door tears itself
    /// down the same way, so the oracle holds exactly what is on screen.)
    static func reset(_ key: String) {
        shown[key] = nil
        flip[key] = nil
    }

    /// One stamp leaving the screen forgets its own slot — an arrangement
    /// swap or a slot standing down clears exactly its words and leaves the
    /// others (the 18h ladder's R3-10 hygiene, the half 17q missed).
    static func forget(_ key: String?, slot: String) {
        guard let key, !slot.isEmpty else { return }
        shown[key]?[slot] = nil
        if shown[key]?.isEmpty == true { shown[key] = nil }
    }
}
#endif

extension View {
    /// The DEBUG words-oracle write (a no-op outside DEBUG, and on any stamp
    /// that was given no key).
    @ViewBuilder
    func recordCatalogStamp(_ key: String?, slot: String, words: String) -> some View {
        #if DEBUG
        self
            .onAppear { CatalogStampOracle.record(key, slot: slot, words: words) }
            .onChange(of: words) { _, new in
                CatalogStampOracle.record(key, slot: slot, words: new)
            }
            .onDisappear { CatalogStampOracle.forget(key, slot: slot) }
        #else
        self
        #endif
    }

    /// The DEBUG flip door (a no-op outside DEBUG): a pin clicks the small
    /// card's stamp the way `MastheadStamp`'s pin clicks the masthead's.
    @ViewBuilder
    func catalogStampFlipDoor(
        _ postID: String, _ flip: @escaping @MainActor () -> Void
    ) -> some View {
        #if DEBUG
        self
            .onAppear { CatalogStampOracle.flip[postID] = flip }
            .onDisappear { CatalogStampOracle.flip[postID] = nil }
        #else
        self
        #endif
    }
}
