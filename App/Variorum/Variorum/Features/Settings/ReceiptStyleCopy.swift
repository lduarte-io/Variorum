//
//  ReceiptStyleCopy.swift
//  Variorum (Mac)
//
//  18i — the words of THE CONFIRMATIONS SETTING (her ruling R-Q5, from the
//  2026-09-12 report: *"there's these little text confirmation popups that
//  are always appearing… i either need them off, more subtle in the bottom
//  bar in more muted text, or a setting if i can turn it on or off. maybe
//  the setting is the best option?… i don't always need it less noticable
//  because for some operations it's the right confirmation text to show."*
//  Her default: *"Quiet should be the default, but toast should still be an
//  option"*).
//
//  **The help copy's job is to not overclaim** — the `SavepointCadenceCopy`
//  bar, one setting over. This one governs CONFIRMATIONS of acts that
//  landed, and nothing else: a refusal and an offer always show, under every
//  value, because a door that could not act must say why (P-2) and a
//  question with a button is not asked if she cannot see it. A setting
//  called "Off" that left that unsaid would read as "the app stops talking",
//  which is the J8 copy-truth defect exactly.
//

import Foundation
import VariorumCore

nonisolated enum ReceiptStyleCopy {
    static let title = "Confirmations after an act"

    static func label(_ style: ReceiptStyle) -> String {
        switch style {
        case .quiet: return "A quiet line in the bottom bar (recommended)"
        case .toast: return "A note at the bottom of the window"
        case .off: return "Nothing"
        }
    }

    // Her General-pane rulings, 2026-10-13 (the VX-214 sitting record).
    // Final form, her floated option taken at the orchestrator's
    // recommendation: NO what-acts explanation — no word honestly names
    // the class (receipts confirm acts whose effect doesn't show at the
    // cursor, and "structural" overclaims) and the option labels already
    // say what the setting does. What remains is the ONE sentence the
    // labels can't carry — her refusal sentence, the copy-truth line the
    // setting must never leave out (the header's doctrine).
    static let help =
        "Actions that were refused will still show a note regardless of "
        + "this setting."
}
