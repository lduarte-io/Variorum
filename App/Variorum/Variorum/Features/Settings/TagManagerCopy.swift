//
//  TagManagerCopy.swift
//  Variorum (Mac)
//
//  Settings ▸ Tags' own words, in one place so a pin reads the sentence
//  rather than a rendering of it.
//

import Foundation

nonisolated enum TagManagerCopy {
    /// **VX-838 (the VX-828 run, batch E — her pick R-828-2):** the pane NAMES
    /// its wing in its header. The vocabulary is per-wing (R-13ia-1), and a
    /// wing-scoped list that never said which wing it was is the bug's root.
    /// "in ‹wing›" is the window toolbar's own phrase for the wing you're in
    /// (VX-552's label beside New Note), so the two read as one sentence; the
    /// header voices it as chrome, the toolbar's way. Home is "Home".
    static func title(wingName: String) -> String {
        "Tags \u{2014} in \(wingName)"
    }
}
