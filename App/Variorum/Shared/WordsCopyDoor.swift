//
//  WordsCopyDoor.swift
//  Variorum (a shared-folder file whose whole body is the MAC arm — the
//  phone compiles it empty; its UIPasteboard arm is the mobile app row's)
//
//  18o U5 (17t item 2 — KnownIssues row 55): **COPY ALL ON THE TWELVE WORDS,
//  ONE RULE.** Pre-13x decision 23 ("The recovery phrase's COPY ALL clears the
//  clipboard after 60 s") and copy §2a Screen 3 ("[the words, numbered] ·
//  *Copy All* (sub-line after copying: *Copied. Your clipboard clears in 60
//  seconds.*)") were built in ONE place — the Castle / Replace All Keys
//  ceremony's words screen, as an inline closure in `ProtectionPane` — while
//  the Mac shows the words on four more surfaces: sync setup
//  (`SyncEnrollmentView`, the copy's own Screen 3), Regenerate Twelve Words
//  (`KeyDoorView` — copy §4: "Then 2a's Screens 3/3b"), the set sheet
//  (`PassphraseSetSheet`) and the nudge's phrase-only sheet. Her need, at the
//  13u2 roster: *"we NEED a copy all button on the recovery phrase - i had to
//  copy them one by one."*
//
//  This file is that closure HOISTED, so every words screen composes the SAME
//  door and there is never a second copy of the clear-after timer:
//  `WordsClipboard.copy` is the closure's four statements verbatim (write the
//  words as one line, note the pasteboard's `changeCount`, and 60 s later
//  clear it ONLY if nothing else has written since); `WordsCopyDoor` is the
//  door, rendered through the page family's `PageDoor`, whose nil arm (the
//  Mac, always) is byte-for-byte the `Button(title, action:)` the ceremony
//  sheet carried. The pasteboard and the interval are parameters so a pin can
//  drive the door against a PRIVATE pasteboard — her clipboard is never a
//  test's.
//
//  THE PHONE: `SyncEnrollmentView` and `KeyDoorView` are shared faces the
//  phone renders too (Settings ▸ Sync ▸ the Account sheet); their door is
//  `#if os(macOS)` at the call site, so the phone's rendering stays as it was.
//  The phone's word-screen doors — five screens, their UIPasteboard semantics
//  (an expiration date, local-only) a call of their own — are the mobile app
//  project row's, beside PL-23.
//

#if os(macOS)
import AppKit
import SwiftUI

/// THE ONE clipboard rule for the twelve words (decision 23).
@MainActor
enum WordsClipboard {
    /// How long the words may sit on the clipboard (decision 23; copy §2a's
    /// sub-line says the number).
    static let clearAfter: Duration = .seconds(60)

    /// The one line the words travel as — joined by single spaces, the
    /// separator every words field reads back.
    static func line(_ words: [String]) -> String {
        words.joined(separator: " ")
    }

    /// Put the words on `pasteboard` as one line; after `clearAfter`, clear
    /// it — but ONLY if nothing else has written to it since (its
    /// `changeCount` unmoved), so a later copy of hers is never erased.
    /// Returns the clearing task (production discards it; a pin awaits it).
    @discardableResult
    static func copy(
        _ words: [String],
        to pasteboard: NSPasteboard = .general,
        clearAfter: Duration = WordsClipboard.clearAfter
    ) -> Task<Void, Never> {
        pasteboard.clearContents()
        pasteboard.setString(line(words), forType: .string)
        let count = pasteboard.changeCount
        return Task {
            try? await Task.sleep(for: clearAfter)
            if pasteboard.changeCount == count {
                pasteboard.clearContents()
            }
        }
    }

    // MARK: - VX-448 — THE NEW ROAD'S RULE (her ruling, QUESTIONS #235: "concealed pasteboard type + clear at lock/quit;
    // the 60-second timer and the restore-prior-contents go" — "60 seconds might not even be long enough … I'm sure it's
    // a bit surprising"). `copy` above stays today's road's, byte-unchanged (its screens retire with it at VX-329); every
    // new-road look rides `copyConcealed` (the bootstrap's one `copyWords`: the card above the quick entry, Settings ▸
    // Protection's words door, the tour's last card, the no-key-file banner's door, U2's join moment).

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

/// The *Copy All* door every words screen composes (copy §2a Screen 3). The
/// caption beside it — *Copied. Your clipboard clears in 60 seconds.* — is
/// the owning face's, read from the flag `onCopied` sets (the model's
/// `markWordsCopied()`, or a presenter's own).
struct WordsCopyDoor: View {
    let words: [String]
    let pageStyle: SharedPageStyle?
    let onCopied: () -> Void

    var body: some View {
        PageDoor(ProtectionCopy.wordsCopyAll, style: pageStyle) { copy() }
    }

    /// The door's one act — what a click runs. A pin drives it against a
    /// private pasteboard and a short interval.
    @discardableResult
    func copy(
        to pasteboard: NSPasteboard = .general,
        clearAfter: Duration = WordsClipboard.clearAfter
    ) -> Task<Void, Never> {
        let clearing = WordsClipboard.copy(words, to: pasteboard, clearAfter: clearAfter)
        onCopied()
        return clearing
    }
}
#endif
