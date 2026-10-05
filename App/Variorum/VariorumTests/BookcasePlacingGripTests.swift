//
//  BookcasePlacingGripTests.swift
//  VariorumTests
//
//  17y B2 — item (b): MY ORDER's hand placement and its AFFORDANCE.
//
//  The trace (the B2 RECORD): the row drop P-13id-U1-12 promised ("a book
//  dropped on a row lands right above it") WAS built — `ShelfView`'s
//  `bookcaseDropSite(enabled: placing)` → `ShelfViewModel.dropBook(_:before:)`,
//  pinned at the model by `BookcaseViewModelTests.myOrdersDoorsAndTheCross
//  ShelfDrop` — and was dead for the shared reason (the undeclared drag type,
//  `DragTypeDeclarationTests`). Her second ask — drag bars, or an equivalent,
//  VISIBLE while my order is active — was never built: no row drew anything.
//
//  The grip, the row's drop site and Send to Top / Bottom now read ONE value,
//  `BookcaseBoard.placesByHand`, so the handle is drawn exactly where a drag
//  can place (P-2 — her "a handle that cannot drag must not render").
//  Red by BEHAVIOURAL REVERT (a new value has no pre-fix shape): the gate
//  answering `true` for every order turns the first test red; answering
//  `false` turns both red. The face itself is the walk's capture.
//

import Foundation
import Testing
@testable import Variorum

@Suite("17y (b) — my order's grip and row drop read one value")
struct BookcasePlacingGripTests {
    @Test func onlyMyOrderPlacesByHand() {
        #expect(BookcaseBoard.placesByHand(.mine), "my order: rows take a book; the grip shows")
        #expect(!BookcaseBoard.placesByHand(.alphabetical),
                "A–Z: a hand position would not show — no grip, no row drop")
        #expect(!BookcaseBoard.placesByHand(.lastEdited),
                "last edited: a hand position would not show — no grip, no row drop")
    }

    @Test func theGripSaysWhatADropDoes() {
        #expect(BookcaseCopy.gripGlyph == "\u{283F}", "the app's one handle glyph")
        #expect(BookcaseCopy.gripHelp.contains("lands right above the row"),
                "the help names P-13id-U1-12's landing rule")
        // F-B2-5: the grip lives INSIDE the row, in a column the row is pulled
        // into the board's 28-pt gutter by — so the column must fit it.
        #expect(BookcaseCopy.gripColumn > 0 && BookcaseCopy.gripColumn < 28)
    }
}
