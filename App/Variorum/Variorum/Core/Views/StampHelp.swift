//
//  StampHelp.swift
//  Variorum (Mac)
//
//  **VX-351 (the VX-348 run, U4) — a stamp's hover, only when there is one.**
//  Her ask: *"you should be able to see the actual time (with hours) that you
//  last edited something at even if it's in the past"*; her rulings at the
//  run's kickoff sitting, R-VX348-1 ("Hover everywhere") and R-VX348-3 ("All
//  speakers"): every face that says WHEN in glance words hovers the whole fact
//  (`TimeStampFace.tooltip` — the year always, the minute whenever the stamp
//  holds one).
//
//  Several speakers have a stamp only SOMETIMES (a book row's last edit, a
//  passage that is a commit, a picker row whose day is suppressed). This one
//  modifier is how each of them says "no hover" — by applying no tooltip at
//  all, never an empty one — so no face spells that choice its own way.
//  Words are always the brain's; this decides only whether there is a hover.
//

import SwiftUI

extension View {
    /// The whole fact on hover, or nothing (nil or empty text).
    @ViewBuilder
    func stampHelp(_ text: String?) -> some View {
        if let text, !text.isEmpty {
            help(text)
        } else {
            self
        }
    }
}
