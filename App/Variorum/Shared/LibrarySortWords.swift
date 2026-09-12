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
    /// One lower-case word per sort — the Mac's `sort ▾` rows and the
    /// phone's picker, from the same line.
    ///
    /// `lastMajorRevision` is the case neither surface offers today (the
    /// timeline's own stamp); it answers so the vocabulary can never reach a
    /// surface with no word for it, which is exactly the hole the phone's
    /// exhaustive switch found when `.title` was minted.
    static func label(_ sort: Queries.LibrarySort) -> String {
        switch sort {
        case .lastTouched: "edited"
        case .createdAt: "created"
        case .entryDate: "date"
        case .title: "title"
        case .lastMajorRevision: "revised"
        }
    }
}
