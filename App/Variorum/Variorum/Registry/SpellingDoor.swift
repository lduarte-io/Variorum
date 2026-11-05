//
//  SpellingDoor.swift
//  Variorum (Mac)
//
//  **VX-798 (the VX-828 run, batch E) — Edit ▸ Spelling and Grammar.** Her
//  ask (2026-11-04), verbatim: *"I'd also like a keyboard shortcut for
//  spellcheck — how am I supposed to even spellcheck, actually? I used to see
//  it in a menu but now I don't know where it is"*, and the same day: *"i also
//  want to be able to run a 'one time' spellcheck with a keyboard shortcut, not
//  just toggle it on or off."* She was right that it was an Apple thing: an
//  AppKit app's Edit menu template carries Spelling and Grammar; a
//  SwiftUI-lifecycle menu bar does not, and nothing here added it back.
//
//  The door is the macOS-standard pair, under AppKit's own titles and keys:
//  ⌘: Show Spelling and Grammar (`NSText.showGuessPanel(_:)`) and ⌘; Check
//  Document Now (`NSText.checkSpelling(_:)` — select the next misspelled word
//  from the selection on; again for the one after). Both are sent DOWN THE
//  RESPONDER CHAIN, so whichever text view holds the keyboard answers — every
//  writing surface in the app is an `NSTextView` (the record names them), and
//  `NSText` implements both acts. Where nothing in the chain takes the act, the
//  door speaks its declared note on the one status seam (P-2: a door that did
//  nothing speaks a refusal) — Paste Without Line Breaks' road, one menu over.
//
//  **One-shot, by construction.** Neither selector writes a text view's
//  checking flags: the A24 level (`SpellcheckLevel`, Settings ▸ Editor ▸
//  Spellchecking) stays the ONE writer of `isContinuousSpellCheckingEnabled`,
//  and its pairing — completion OFF whenever continuous checking is ON, the
//  TEXTKIT2 §3 crash pairing — stays whole. That is why AppKit's three toggle
//  items (Check Spelling While Typing, Check Grammar With Spelling, Correct
//  Spelling Automatically) are not in this menu: each writes a per-view flag
//  under the setting, and the first would switch continuous checking on with
//  completion still on. (Probed offscreen on macOS 27.0.1 before the build: a
//  TK2 text view in a window, `checkSpelling(nil)` twice — "brwn", then
//  "jumpd" selected; continuous checking stayed off, completion stayed on.)
//

import AppKit

/// The door's words, in one place so a pin reads the sentence rather than a
/// rendering of it. The two verbs are AppKit's own menu titles.
nonisolated enum SpellingDoorCopy {
    /// The Edit menu's submenu — AppKit's own name for it.
    static let menuTitle = "Spelling and Grammar"
    static let showPanelVerb = "Show Spelling and Grammar"
    static let checkDocumentVerb = "Check Document Now"
    /// The refusal both acts speak when nothing in the responder chain can
    /// check spelling (the keyboard is on a list, a button, the Bookcase…).
    /// PROVISIONAL words (VX-798), hers to tune.
    static let nothingToCheck =
        "Spelling checks the text you're writing in \u{2014} click into a note or a box first."
}

@MainActor
enum SpellingDoor {
    /// The pair — each one AppKit action, sent down the responder chain.
    enum Act: CaseIterable, Sendable {
        case showPanel
        case checkDocument

        /// The registry act each one is.
        var capability: CapabilityID {
            switch self {
            case .showPanel: .showSpellingPanel
            case .checkDocument: .checkSpelling
            }
        }

        /// The AppKit action. `NSText` implements both, so every `NSTextView`
        /// in the app answers them with no override of ours.
        var selector: Selector {
            switch self {
            case .showPanel: #selector(NSText.showGuessPanel(_:))
            case .checkDocument: #selector(NSText.checkSpelling(_:))
            }
        }
    }

    /// **The act.** Walks the responder chain for a taker and answers whether
    /// one took it. `responder` nil — the menu's road — starts where AppKit's
    /// nil-target actions start (`NSApp.sendAction(_:to: nil, from:)`: the key
    /// window's first responder upward, then the main window's); a responder
    /// given starts the walk THERE (`tryToPerform(_:with:)` — the same chain,
    /// from a known first responder), which is how a pin drives it without a
    /// key window. Never an explicit `to:` target: AppKit sends to one
    /// whether or not it answers, and a non-answering one throws.
    @discardableResult
    static func perform(_ act: Act, from responder: NSResponder? = nil) -> Bool {
        guard let responder else {
            return NSApp.sendAction(act.selector, to: nil, from: nil)
        }
        return responder.tryToPerform(act.selector, with: nil)
    }

    /// **The menu door**: the act, and — where nothing took it — the act's
    /// declared refusal, spoken (P-2). `refuse` is the one status seam's
    /// `refuse(_:)` (the menu passes the open session's; before a library is
    /// open nothing can speak, and nothing could be checked either).
    static func door(
        _ act: Act, from responder: NSResponder? = nil, refuse: @MainActor (String) -> Void
    ) {
        guard !perform(act, from: responder) else { return }
        refuse(CapabilityRegistry.capability(act.capability).unavailableNote)
    }
}
