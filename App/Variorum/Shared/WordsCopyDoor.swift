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
