//
//  ProtectionWords.swift
//  Variorum (shared: Mac + Mobile — the phone reuses them at U3)
//
//  VX-306 — THE WORDS the rebuilt protection core's faces say, in ONE file (`notes/plans/vx-306-castle-open-road.md`
//  §7c; her no-shouty-caps rule: sentence case throughout). Every sentence here is checked against
//  `notes/CastleRules.md` (VX-379's standing item). Where §7c drafts a string it is used EXACTLY as drafted
//  (PROVISIONAL — hers at the bundle, QUESTIONS #233); the lobby's lines §7c does not draft are the U1b
//  implementer's drafts, PROVISIONAL P-VX306-U1b-4, each written from a rule's own words. The notice's two
//  sentences are the MODEL's constants (`LibraryNotice`, hers) and are never restated here.
//

import Foundation
import VariorumCore

nonisolated enum ProtectionWords {
    // MARK: - (1) The once-shown words card — §7c (1), verbatim (rule 2; K7: one button, no Copy, no later)

    static let wordsCardTitle = "Your twelve words"
    static let wordsCardLead = "Your library is encrypted. These twelve words open it — on this Mac, on any copy of it, "
        + "for as long as they are its words. Write them down now and keep them somewhere safe. Variorum won't show "
        + "them again."
    static let wordsCardFoot = "You can add a passphrase later, as a convenience over the words. Either one can reset "
        + "the other."
    static let wordsCardButton = "I've written them down"

    // MARK: - (3) Rule 27's refusal — §7c (3), verbatim (the lobby's moment; its doors are U2's face)

    static let noKeyFileAnywhere = "No key file opens this library. Variorum looked beside the library, inside every "
        + "backup, and in this Mac's keychain, and found none that opens it. Without one, there is nothing left to open."
    static let noKeyFileAnywhereAccountRoad = "This library syncs with your account. Sign in and enter your passphrase "
        + "or twelve words to bring your writing back."

    // MARK: - The lobby (rule 8: it asks only when no quiet road remains) — PROVISIONAL P-VX306-U1b-4

    static let lobbyTitle = "Open your library"
    /// The lead, by the typed roads the library's key files carry (rule 3: the passphrase is a convenience over
    /// the words; rule 2: every library has its words).
    static func lobbyLead(passphrase: Bool, words: Bool) -> String {
        switch (passphrase, words) {
        case (true, true): return "Enter your passphrase or your twelve words to open your library."
        case (true, false): return "Enter your passphrase to open your library."
        case (false, _): return "Enter your twelve words to open your library."
        }
    }
    static let passphraseLabel = "Passphrase"
    static let openButton = "Open"
    static let wordsDoor = "Use your twelve words instead"
    static let wordsPlaceholder = "Your twelve words, separated by spaces"
    static let wordsButton = "Open with the words"
    static let opening = "Opening your library…"
    /// P-VX306-U1a-3's road: a keychain that could not be listed stops the facts — the typed field, and why.
    static let keychainUnreadable = "Variorum couldn't check this Mac's keychain just now. Enter your passphrase or "
        + "your twelve words."

    // MARK: - The lobby's refusals (a typed attempt that opened nothing)

    static let passphraseDoesNotOpen = "That passphrase doesn't open this library."
    static let wordsDoNotOpen = "Those twelve words don't open this library."
    static func wordsWrongCount(_ count: Int) -> String {
        "There are twelve words — you entered \(count)."
    }
    static func wordsUnknownWord(_ word: String) -> String {
        "\u{201C}\(word)\u{201D} isn't one of the words Variorum uses — check its spelling."
    }
    static let wordsChecksum = "One of the twelve words is off. Compare them with what you wrote down."
    /// P-VX306-U1a-2: a file sits in the live place that this build can't read as a key file (its face is U2's).
    static let liveKeyFileUnreadable = "The key file beside your library can't be read, so Variorum can't open the "
        + "library with it."
    static let somethingWentWrong = "Something went wrong opening your library. Try again."

    // MARK: - Touch ID (VX-310 — the design's §3.10, her words where it has them)

    static let touchIDButton = "Unlock with Touch ID"
    /// §3.10: "Touch ID isn't set up here, or isn't set up for this library."
    static let touchIDNotSetUpOnThisMac = "Touch ID isn't set up on this Mac."
    static let touchIDNotSetUpForThisLibrary = "Touch ID isn't set up for this library."
    /// §3.10, verbatim.
    static let touchIDChanged = "Touch ID changed since you set it up — unlock with the passphrase."
    /// §3.10: "Pressing it says why ('Open the lid…') and nothing changes."
    static func touchIDUnusableForNow(_ reason: TransientUnavailability) -> String {
        switch reason {
        case .lidClosed: return "Open the lid to use Touch ID."
        case .keyboardDisconnected: return "Connect your keyboard with Touch ID to use it."
        case .keyboardNotPaired: return "Pair your keyboard with Touch ID to use it."
        case .lockout: return "Touch ID is locked after too many tries. Enter your passphrase, or lock and unlock your Mac."
        }
    }

    // MARK: - The route's failures (the failure face, with Try Again)

    static let couldNotCreate = "Variorum couldn't create your library."
    static let keychainUnreadableNoLibrary = "Variorum couldn't check this Mac's keychain, so it didn't create a "
        + "library. Try again."
    /// A hosted test run (the test host IS the dev-store app) never writes the dev scope — it never creates.
    static let testRunNeverCreates = "A test run never creates a library."
}
