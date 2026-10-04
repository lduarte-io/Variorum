//
//  UpdateSettingsCopy.swift
//  Variorum (MAC ONLY — the phone's updates are the App Store's)
//
//  13r U3-A — Settings ▸ General's update row (THE CALM-ASKS CADENCE, rule 4:
//  "Check for updates automatically", mapped onto Sparkle's own setting).
//  Functional and honest; 13s re-voices.
//

import Foundation

nonisolated enum UpdateSettingsCopy {
    static let section = "Updates"
    /// The cadence's own words for the row.
    static let title = "Check for updates automatically"
    static let help =
        "About once a day Variorum asks stargazing.tech whether a newer version exists; "
        + "nothing of your writing goes with it. Check for Updates\u{2026} in the Variorum "
        + "menu works either way."
    /// Said only while the question is still open.
    static let unansweredNote =
        "You haven\u{2019}t chosen yet \u{2014} Variorum asks once, after a few days of use, "
        + "or you can decide here."
}
