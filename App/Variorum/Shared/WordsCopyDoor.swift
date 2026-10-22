//
//  WordsCopyDoor.swift
//  Variorum (a shared-folder file whose whole body is the MAC arm — the
//  phone compiles it empty; its UIPasteboard arm is the mobile app row's)
//
//  18o U5 (17t item 2 — KnownIssues row 55) built ONE Copy All door for every Mac screen that showed the twelve words,
//  over pre-13x decision 23's 60-second clear. VX-448 (QUESTIONS #235, her ruling) replaced that rule on the protection
//  road: the words travel CONCEALED with no timer, cleared at lock and at quit. VX-329 U1 — THE RELEASE SWITCH: today's
//  words screens (sync setup, Regenerate Twelve Words, the set sheet, the nudge's phrase-only sheet) were deleted with
//  today's road, and with them their door (`WordsCopyDoor`) and the 60-second copy (`WordsClipboard.copy`); this file
//  keeps the one rule the road's looks ride (`copyConcealed` / `clearHeld` — the bootstrap's one `copyWords`). The file
//  keeps its name so the rule's source pins keep reading it.
//

#if os(macOS)
import AppKit
import SwiftUI

/// THE ONE clipboard rule for the twelve words (VX-448 — decision 23's timer retired).
@MainActor
enum WordsClipboard {
    /// The one line the words travel as — joined by single spaces, the
    /// separator every words field reads back.
    static func line(_ words: [String]) -> String {
        words.joined(separator: " ")
    }

    // MARK: - VX-448 — THE ROAD'S RULE (her ruling, QUESTIONS #235: "concealed pasteboard type + clear at lock/quit;
    // the 60-second timer and the restore-prior-contents go" — "60 seconds might not even be long enough … I'm sure it's
    // a bit surprising"). Every look rides `copyConcealed` (the bootstrap's one `copyWords`: the card above the quick
    // entry, Settings ▸ Protection's words door, the tour's last card, the no-key-file banner's door, U2's join moment).

    /// The nspasteboard.org marker for content a clipboard history must not keep (password managers set it) — written
    /// beside the words, its data empty.
    static let concealedType = NSPasteboard.PasteboardType("org.nspasteboard.ConcealedType")

    /// The one copy this rule holds: which board, and its `changeCount` right after the words landed.
    private static var held: (pasteboard: NSPasteboard, changeCount: Int)?

    /// Whether the words this rule put on a board are still the one copy it holds (a pin's question).
    static var holdsACopy: Bool { held != nil }

    /// Put the words on `pasteboard` as one line, marked CONCEALED; NO timer — the words stay until something else is
    /// copied, the library locks, or the app quits (`clearHeld`). Nothing is ever restored.
    static func copyConcealed(_ words: [String], to pasteboard: NSPasteboard = .general) {
        pasteboard.clearContents()
        pasteboard.setString(line(words), forType: .string)
        pasteboard.setData(Data(), forType: concealedType)
        held = (pasteboard, pasteboard.changeCount)
    }

    /// **The clear at lock and at quit**: the board emptied — ONLY if it still holds this rule's copy (its `changeCount`
    /// unmoved since), so her later copy is never erased; either way the rule holds nothing after. True when it cleared.
    @discardableResult
    static func clearHeld() -> Bool {
        guard let held else { return false }
        Self.held = nil
        guard held.pasteboard.changeCount == held.changeCount else { return false }
        held.pasteboard.clearContents()
        return true
    }
}
#endif
