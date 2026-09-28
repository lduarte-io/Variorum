//
//  ArrivalFlashCopy.swift
//  Variorum (Mac)
//
//  18l-c U8 — the words of THE ARRIVAL FLASH's setting (her R-18l-7, from the
//  18l-c kickoff: *"it might be nice if we showed a temporary highlight (like
//  the index highlight) on the line your cursor is on after the transition.
//  lasting a brief instant … you should also be able to turn this flash where
//  your cursor is setting off, but it should default to on."*). PROVISIONAL
//  copy — hers to polish.
//
//  **The help copy's job is to not overclaim** (the `ReceiptStyleCopy` bar):
//  the flash marks a MODE SWITCH's landing only — a click, a find step and a
//  note opening never flash — and turning it off leaves where the switch lands
//  exactly as it is (the comfort band and the caret rule are not this switch).
//

import Foundation

nonisolated enum ArrivalFlashCopy {
    static let title = "Flash your place after switching modes"

    static let help =
        "When you switch between Write, Takes and Read, the line (or block) you were in "
        + "wears a brief highlight that fades in about a second, so your eye finds it. "
        + "Clicks, find steps and opening a note never flash. Off: no highlight — the switch "
        + "still lands you in the same place. With Reduce Motion on, it shows without fading. "
        + "Synced."
}
