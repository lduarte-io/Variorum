//
//  NoteBox.swift
//  Variorum (Mac)
//
//  18d batch 1 — THE SIDEBAR'S NOTE BOX (her ruling U-10, verbatim: *"The
//  block menu should move to being where the 'this note, write, lenses,
//  compare, etc.' menu is, measured to take up the same amount of room, and
//  should show 'no note selected' when you haven't clicked into anything or
//  you've clicked out of something."*).
//
//  This file is the box's BRAINS ONLY — its state rule and its words, pure
//  and pinnable without a window. The face is `SidebarNoteBox`; the shell
//  composes them (`RootView`), the sidebar renders what it is handed.
//
//  Why a rule and not an `if` in a view body: the three states are the whole
//  feature, and the one thing her ruling names outright ("no note selected
//  when you haven't clicked into anything") is a claim about a pair of ids.
//  A claim about a pair of ids belongs in a function a test can call.
//

import Foundation
import VariorumCore  // the one stamp-wording brain (`TimeStampFace`)

// MARK: - The state

/// The box's three states (mockup figure C, left to right).
///
/// **LIVE WINS.** A note under the caret is also the book's selected note, so
/// the two ids are usually both filled; the box shows the bar, not the door.
nonisolated enum NoteBoxState: Equatable, Sendable {
    /// Nothing clicked, or clicked out of: *"no note selected"*.
    case empty
    /// A note the book points at, read-cheap — its identity, its facts, and
    /// ONE door into editing.
    case selected(String)
    /// The caret is in the note — the identity line, the editing mark, and
    /// the bar that used to ride the right gutter.
    case live(String)

    /// The rule, over the two ids the book publishes.
    static func from(selected: String?, live: String?) -> NoteBoxState {
        if let live { return .live(live) }
        if let selected { return .selected(selected) }
        return .empty
    }

    /// The note this state is about, if any.
    var postID: String? {
        switch self {
        case .empty: nil
        case .selected(let id), .live(let id): id
        }
    }

    var isLive: Bool {
        if case .live = self { return true }
        return false
    }
}

// MARK: - What the box knows about the note

/// The note's identity as the BOOK knows it — published by the book, never
/// re-derived by the sidebar (the book is the only thing that knows which
/// chapter a note is in and where it sits in the reading order).
nonisolated struct NoteBoxIdentity: Equatable, Sendable {
    var postID: String
    var title: String
    /// The chapter's name, when the book is sectioned; nil ⇒ unsectioned or
    /// a flat book, and the line simply omits it.
    var chapter: String?
    /// 1-based place among the book's notes (0 ⇒ unknown, and omitted).
    var index: Int
    var total: Int
    /// `total` is a FLOOR, not the count (the round-end Fable pass, NIT-3):
    /// the book's entries are windowed (`BookViewModel.entryWindow`), so a
    /// book longer than the window knows only that it has at least this
    /// many — and the line says `300+` rather than claiming a count it does
    /// not hold.
    var totalIsAtLeast: Bool

    init(
        postID: String, title: String, chapter: String? = nil,
        index: Int = 0, total: Int = 0, totalIsAtLeast: Bool = false
    ) {
        self.postID = postID
        self.title = title
        self.chapter = chapter
        self.index = index
        self.total = total
        self.totalIsAtLeast = totalIsAtLeast
    }
}

/// The note's FACTS, fetched once per selection (the retired gutter's own
/// cadence — never a per-frame query, and never a keystroke-rate observation:
/// `variant` is the table autosave writes, and a standing observation here
/// would re-run the whole read on every character, which P1 forbids).
nonisolated struct NoteBoxFacts: Equatable, Sendable {
    var words: Int
    var blocks: Int
    var fannedBlocks: Int
    var editedAt: Date?
    var savedAt: Date?

    init(
        words: Int = 0, blocks: Int = 0, fannedBlocks: Int = 0,
        editedAt: Date? = nil, savedAt: Date? = nil
    ) {
        self.words = words
        self.blocks = blocks
        self.fannedBlocks = fannedBlocks
        self.editedAt = editedAt
        self.savedAt = savedAt
    }
}

// MARK: - The words

/// The box's copy, in one place (R93's legible-words rule; the app's own
/// mouth, never a coined term).
nonisolated enum NoteBoxCopy {
    /// The box wears the rail's own header — her ruling measures the box
    /// against *"the 'this note, write, lenses, compare, etc.' menu"*, and
    /// the header is half of what makes it read as the same thing.
    static let header = "this note"
    static let nothingSelected = "no note selected"
    static let nothingSelectedHint = "click a note in the book to see its controls here"
    /// The one door out of the read-cheap state.
    ///
    /// **The mockup labels it *"edit here ⏎"* and this one does not carry the
    /// glyph** (QUESTIONS #99, PROVISIONAL). A `keyboardShortcut` is a KEY
    /// EQUIVALENT, checked before the responder chain — a window-wide Return
    /// on a sidebar button steals Return from the masthead's title field, the
    /// tag field and the Index column's filter, which is the exact class
    /// `SpreadBookView`'s flip shortcut already guards against by refusing to
    /// exist while an editor is live. A glyph promising a key nothing binds
    /// is worse than no glyph, so the door is a button and says so.
    static let editDoor = "edit here"
    /// The live mark, in the ring colour at the box's corner.
    static let editingMark = "editing"

    static let emptyHelp =
        "This is where a note's controls live while a book is open. "
        + "Click a note in the book and they appear here."
    static let editDoorHelp =
        "Write in this note, at the block you were last in"
    /// **VX-304 — the box's way OUT of the book** (P-U1b-1, PROVISIONAL): the
    /// book's own words for the act — the "open ↗" by each note's title,
    /// which a long note scrolls out of sight (her report). One act, one face.
    static let openDoor = "open ↗"
    /// While LIVE the door carries her caret's block (VX-303's road).
    static let openDoorHelpLive = "Open in Write at this block"
    /// While SELECTED there is no caret: the note opens in Write with the
    /// plain open's place (R-U1a-2).
    static let openDoorHelpSelected = "Open this note in Write"
    /// The Index-live box's takes door — the bar's own word for it.
    static let takesDoor = "Takes"
    static let takesDoorHelp = "This block's takes, right here in the book"

    /// *"chapter 2 · 5 of 12 in this book"* — and, while live, the caret's
    /// block joins it: *"chapter 2 · 5 of 12 · block 3/41"*.
    ///
    /// The block half is the BAR's own label (`BlockLineLabel`), handed in
    /// rather than re-derived: 13g R5-4's rule — one shared label, so no two
    /// surfaces can disagree about where the caret is.
    ///
    /// `totalIsAtLeast` (NIT-3): a windowed book's total is a floor, said as
    /// *"5 of 300+ in this book"* — never a count the book does not hold.
    static func whereLine(
        chapter: String?, index: Int, total: Int, totalIsAtLeast: Bool = false, block: String?
    ) -> String {
        var pieces: [String] = []
        if let chapter = chapterPiece(chapter) { pieces.append(chapter) }
        if let place = placePiece(index: index, total: total, totalIsAtLeast: totalIsAtLeast) {
            pieces.append(block == nil ? "\(place) in this book" : place)
        }
        if let block { pieces.append(block) }
        return pieces.joined(separator: " \u{B7} ")
    }

    /// **VX-562 — the book Outline's pinned line, its POSITION half:**
    /// *"note 5 of 12 · chapter 2"* — what she is looking at as she scrolls
    /// (her words: *"show during scroll what # note you're in, maybe what
    /// chapter you're in"*). The note first, because the number is the half
    /// that moves; the chapter after it.
    ///
    /// **The same brain as `whereLine`, two readers** (the record's §DESIGN
    /// piece 3): the place ("5 of 12", a windowed book's floor "5 of 300+",
    /// an unknown place omitted) and the chapter (a blank name omitted) are
    /// the two pieces below, which `whereLine` speaks too — so the box and
    /// the pin can never disagree about how a place or a chapter is SAID.
    /// The facts handed in differ by reader: the box hands the membership
    /// index; the pin hands the note's place on the page
    /// (`BookOutlineViewed.positionLine`, PROVISIONAL P-562-5).
    static func viewedLine(
        chapter: String?, index: Int, total: Int, totalIsAtLeast: Bool = false
    ) -> String {
        var pieces: [String] = []
        if let place = placePiece(index: index, total: total, totalIsAtLeast: totalIsAtLeast) {
            pieces.append("note \(place)")
        }
        if let chapter = chapterPiece(chapter) { pieces.append(chapter) }
        return pieces.joined(separator: " \u{B7} ")
    }

    /// *"5 of 12"* — or *"5 of 300+"* where the total is a floor; nil when
    /// the place is unknown (index 0: the in-book filter, a note not in the
    /// book's rows) or the book holds nothing.
    private static func placePiece(index: Int, total: Int, totalIsAtLeast: Bool) -> String? {
        guard index > 0, total > 0 else { return nil }
        return "\(index) of \(totalIsAtLeast ? "\(total)+" : "\(total)")"
    }

    /// The chapter's name, or nil for none or a blank one.
    private static func chapterPiece(_ chapter: String?) -> String? {
        guard let chapter, !chapter.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
        return chapter
    }

    /// *"3,214 words · 41 blocks"*.
    static func countsLine(words: Int, blocks: Int) -> String {
        "\(words.formatted()) word\(words == 1 ? "" : "s") \u{B7} "
            + "\(blocks) block\(blocks == 1 ? "" : "s")"
    }

    /// *"⑂ takes on 2 blocks"* — nil ⇒ nothing to say, and the line is not
    /// drawn.
    ///
    /// **Hoisted from `BookOutlineRows.gutterLine` (18d batch 1).** It was
    /// the details gutter's one fact; U-17 retires the gutter and state 2 of
    /// this box carries the facts now, so the function moves to its only
    /// remaining consumer rather than being called across a feature boundary
    /// (the hoist-at-next-touch rule). Its claim and its pin are unchanged.
    static func takesLine(fannedBlocks: Int) -> String? {
        guard fannedBlocks > 0 else { return nil }
        return "\u{2442} takes on \(fannedBlocks) block\(fannedBlocks == 1 ? "" : "s")"
    }

    /// *"edited today 1:33 AM · saved Sep 2"* — in the ONE stamp rule's
    /// glance words (`TimeStampFace.relative`: the time for today, the day
    /// past it). nil ⇒ neither stamp is known.
    ///
    /// **VX-351 (the VX-348 run, U4 — her R-VX348-1/3, PROVISIONAL
    /// P-VX351-3):** this line was DATE-ONLY (`TimeStampFace.day`, 18d's
    /// shape), so a note edited four minutes ago read "edited Oct 18" here
    /// while the Library's row and the masthead said "edited today 1:33 AM"
    /// — two glances for one fact. It speaks the glance rule now, and its
    /// hover (`stampsHelp`) says both facts whole.
    static func stampsLine(
        edited: Date?, saved: Date?, now: Date,
        calendar: Calendar = JournalDay.storeCalendar, locale: Locale = .current
    ) -> String? {
        var pieces: [String] = []
        if let edited {
            pieces.append(TimeStampFace.stamp(
                .edited, date: edited, now: now, calendar: calendar, locale: locale))
        }
        if let saved {
            pieces.append("\(savedVerb) "
                + TimeStampFace.relative(saved, now: now, calendar: calendar, locale: locale))
        }
        return pieces.isEmpty ? nil : pieces.joined(separator: " \u{B7} ")
    }

    /// The stamps line's second fact's word — the note's last commit, said
    /// as this box has always said it.
    static let savedVerb = "saved"

    /// **The stamps line's hover — both facts whole** (VX-351): *Edited Oct
    /// 18, 2026 at 1:33 AM · Saved Sep 2, 2026 at 9:14 AM*, in the line's own
    /// order. nil ⇒ the line is not drawn.
    static func stampsHelp(
        edited: Date?, saved: Date?,
        calendar: Calendar = JournalDay.storeCalendar, locale: Locale = .current
    ) -> String? {
        var pieces: [String] = []
        if let edited {
            pieces.append(TimeStampFace.tooltip(.edited, date: edited, calendar: calendar, locale: locale))
        }
        if let saved {
            pieces.append(TimeStampFace.tooltip(
                labelled: savedVerb.capitalized, date: saved, calendar: calendar, locale: locale))
        }
        return pieces.isEmpty ? nil : pieces.joined(separator: " \u{B7} ")
    }

    /// A day, short: *"Sep 4"* — with the YEAR when the stamp is not from
    /// this one, because "Sep 4" for something written two years ago is a
    /// lie told by omission. Pure over an injected `now`, so a pin can hold
    /// the rule rather than the machine's clock.
    ///
    /// **A FORWARDER since 18h batch 1.** The rule it used to implement here
    /// is now `TimeStampFace.day` in core `Domain` — the one stamp-wording
    /// brain the Library's rows and the note masthead's stamp also read
    /// (review focus F-5). The name stays so every 18d pin and call site is
    /// untouched, which is the parity proof; what left is the second copy of
    /// the rule (MobileSoul §3's drift class).
    ///
    /// Its calendar default moved with the 18h ladder's calendar ruling
    /// (`JournalDay.storeCalendar` — Gregorian in her zone, one calendar per
    /// letter), so this line and the Library's day filter cannot name
    /// different days on one screen. A caller that means something else
    /// still passes it.
    static func day(
        _ date: Date, now: Date, calendar: Calendar = JournalDay.storeCalendar, locale: Locale = .current
    ) -> String {
        TimeStampFace.day(date, now: now, calendar: calendar, locale: locale)
    }
}
