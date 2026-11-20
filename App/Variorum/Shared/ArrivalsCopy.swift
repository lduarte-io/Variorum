//
//  ArrivalsCopy.swift
//  Variorum (shared: Mac + Mobile)
//
//  VM-78 batch A (VM-81) — THE ONE WORD, hoisted out of the Mac's
//  `Features/BookView/BookArrivals.swift` because the finish confirm's line
//  (`BookStateCopy.waitingLine`, now shared) says it. Only the word moved: the
//  door's, the review's and the receipts' sentences stay in the Mac's file,
//  which extends this enum, so every Mac call site reads exactly as before.
//

import Foundation

nonisolated enum ArrivalsCopy {
    /// **THE ONE WORD** (17y B3 item (h) — R-17y-2, her pick): the dial's
    /// "wait at Arrivals", the door, the popover, the refusals and the
    /// finish confirm all say it. 13s may re-voice sentences; the WORD is
    /// settled.
    static let word = "Arrivals"
}
