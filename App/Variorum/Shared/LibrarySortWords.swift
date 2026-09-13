//
//  LibrarySortWords.swift
//  Variorum (shared — Mac + phone)
//
//  **ONE TABLE FOR WHAT A SORT IS CALLED** (the 18h ladder, R1-5's sibling
//  R1-7; the arbitration's ruling of 2026-09-13).
//
//  `Queries.LibrarySort` is the core vocabulary. Until this file there were
//  TWO word tables over it that disagreed on half their shared cases — the
//  Mac's `edited · created · date · title` (18h batch 1) beside the phone's
//  `last touched · created · entry date · title` (the mobile parity round's
//  C3) — which is F-0's own line: *two copies of one rule anywhere are the
//  drift class* (MobileSoul §3). 18h minted the second wording and then added
//  `.title` to the first rather than hoisting, so the drift was this letter's
//  to retire.
//
//  **Her words win**, and that is a ruling rather than a preference: R-Q8
//  names these four herself — *"edited (the default, as today) · created ·
//  date (entry date) · title A–Z"*. So the phone's picker reads *edited*
//  where it read *last touched*, and *date* where it read *entry date*;
//  MobileSoul's PL-22 carries the note.
//
//  **The rule this file holds, and its limit:** each platform chooses which
//  cases it OFFERS — the Mac's `LibrarySortFace.offered` is her four, the
//  phone's `MobileLibraryViewModel.sortOptions` is its four stamps — but
//  neither chooses what they are CALLED. What stays platform-side is copy no
//  other platform says: the DIRECTION's wording and the Mac door's composed
//  label live in `LibrarySortFace`, because the phone has no direction
//  control to word. When it grows one, that table moves here beside this one
//  rather than being minted a second time.
//

import Foundation
import VariorumCore

nonisolated enum LibrarySortWords {
    /// **HER FOUR, and only hers** — the words R-Q8 names: *edited (the
    /// default, as today) · created · date (entry date) · title A–Z*. nil for
    /// any other case, because a word no ruling names is not this table's to
    /// give.
    ///
    /// This separation is the ladder's R2-4: the hoist's warrant was her
    /// ruling, and it was applied one case too far — `.lastMajorRevision`,
    /// which the Mac does not offer and the phone does, had its shipped
    /// string changed on nobody's word. The rule the hoist itself states
    /// four lines up ("what stays platform-side is copy no other platform
    /// says") is what forbids that.
    static func ruledLabel(_ sort: Queries.LibrarySort) -> String? {
        switch sort {
        case .lastTouched: "edited"
        case .createdAt: "created"
        case .entryDate: "date"
        case .title: "title"
        case .lastMajorRevision: nil
        }
    }

    /// The word for the one case no ruling names — **the phone's own, and
    /// unchanged since the mobile parity round's C3**. It is AppSpec §10's
    /// vocabulary for `last_major_revision_at` in her app's mouth
    /// (*"meaningful edits only"*), which is why it reads as a sentence
    /// where her four read as labels.
    ///
    /// It sits here rather than back in `MobileLibraryViewModel` for one
    /// reason: the Mac can still be ASKED for it — a remembered
    /// `libraryCatalogSort` of `last_major_revision` (a hand-edited plist)
    /// reads back and reaches the door's label — so both platforms need an
    /// answer, and two files each holding the same string is the drift R1-7
    /// just retired. One string, one place; what the ladder ruled out was
    /// CHANGING it, not keeping it findable.
    static let unruledLabel = "last meaningful edit"

    /// What a surface says for any case: her word where she has ruled one,
    /// the app's own otherwise.
    ///
    /// **An exhaustive switch, not a `??`** (the 18h ladder's R3-4).
    /// `ruledLabel`'s own switch does fail the build on a new `LibrarySort`
    /// case — but the cheapest way to satisfy it is `case .newThing: nil`,
    /// and the `??` then silently labelled the new sort *"last meaningful
    /// edit"*: a word about a DIFFERENT column, on both platforms. Naming the
    /// cases here too means a case that is in neither list fails the build in
    /// both places, so it has to be ANSWERED rather than inherit an answer.
    /// The four words themselves still live in exactly one table above; the
    /// `??` in the first arm is unreachable by that table's own shape and is
    /// there only so the arm needs no force-unwrap.
    static func label(_ sort: Queries.LibrarySort) -> String {
        switch sort {
        case .lastTouched, .createdAt, .entryDate, .title: ruledLabel(sort) ?? unruledLabel
        case .lastMajorRevision: unruledLabel
        }
    }
}
