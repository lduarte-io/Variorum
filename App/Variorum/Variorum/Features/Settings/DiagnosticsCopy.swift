//
//  DiagnosticsCopy.swift
//  Variorum (MAC ONLY — the phone's crash-report face is a named mobile
//  candidate row)
//
//  13r U3-B — Settings ▸ Diagnostics' words (the architect's ruling, the plan's
//  LIVE STATUS: Option A, "the blurb and captions approved as FUNCTIONAL
//  copy; 13s re-voices"). The privacy story is stated plainly, in the order
//  the promise is kept (R-13r-5; the privacy-policy brief's "No analytics"
//  and "Crash reporting … will be opt-in").
//

import Foundation

nonisolated enum DiagnosticsCopy {
    static let section = "Crash reports"
    /// The toggle's label (also the catalog row's title, so search names it).
    static let toggleTitle = "Collect crash reports"

    /// The promise, under the toggle.
    static let promise =
        "Off unless you turn it on. When it\u{2019}s on, macOS hands Variorum a report "
        + "after Variorum crashes \u{2014} usually the next time you open it. Reports stay "
        + "on this Mac and appear below exactly as they arrived. Nothing is ever sent on "
        + "its own: Send Report\u{2026} offers an email draft to \(SupportDraft.address) "
        + "with the report attached, for you to read before you send it. This Mac only."

    /// The one other road, named in words (the act's door is the Help menu).
    static let feedbackPointer =
        "Variorum has no analytics. To write about anything else, there\u{2019}s Help "
        + "\u{25B8} Send Feedback\u{2026}"

    static let receivedSection = "Received"

    /// The calm empty states — one line each.
    static let emptyWhileOff = "None. Nothing is collected while this is off."
    static let emptyWhileOn = "None yet \u{2014} that\u{2019}s the usual state."

    static func received(_ date: Date) -> String {
        "Received \(date.formatted(date: .abbreviated, time: .shortened))"
    }

    /// A report whose bytes are not text is never shown as if it were — and
    /// so is never sendable from here (only what was shown verbatim leaves).
    static let notText =
        "This report isn\u{2019}t text Variorum can show, so it can\u{2019}t be sent from here."

    static let untitled = "Crash report"
}
