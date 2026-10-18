//
//  ProtectionWords.swift
//  Variorum (shared: Mac + Mobile — the phone reuses them at U3)
//
//  VX-306 — THE WORDS the rebuilt protection core's faces say, in ONE file (`notes/plans/vx-306-castle-open-road.md`
//  §7c; her no-shouty-caps rule: sentence case throughout). Every sentence here is checked against
//  `notes/CastleRules.md` (VX-379's standing item). Where §7c drafts a string it is used EXACTLY as drafted
//  (PROVISIONAL — hers at the bundle, QUESTIONS #233); the lobby's lines §7c does not draft are the U1b
//  implementer's drafts, PROVISIONAL P-VX306-U1b-4, each written from a rule's own words; U2's undrafted lines are
//  P-VX306-U2-2's. The notice's two sentences and the offer's are the MODEL's constants (`LibraryNotice`,
//  `KeyFileOffer` — hers) and are never restated here. `ProtectionWordsPlanTests` reads the plan file and pins
//  every §7c string here byte-equal to it.
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

    // MARK: - (2) The key-file offer — §7c (2), verbatim (rule 21; VX-306 U2)
    //
    // The offer's SENTENCE is the model's (`KeyFileOffer.words` / `sentence(date:)` — her strings,
    // `besideDoesNotOpenIt` + `keychainHoldsOne` / `backupHoldsOne`); never restated here.

    static let offerUseIt = "Use it"
    static let offerNotNow = "Not now"
    /// The receipt after *Use it* — the source named.
    static let offerRestoredFromKeychain = "Key file restored from this Mac's keychain."
    static func offerRestoredFromBackup(_ date: String) -> String {
        "Key file restored from the backup from \(date)."
    }
    /// The history-only split pair (`KeyFileSearch.besideOpensItOnlyThroughItsHistory`, P-VX378-U4-6 (a)) — a standing
    /// line on the open library.
    static let offerSplitPair = "The key file beside your library is an older one. It opens the library, but the quiet "
        + "roads can't be re-made from it — Restore from Backup puts the right one back."

    // MARK: - (3) Rule 27's refusal — §7c (3), verbatim (the lobby's moment + its doors; after a quiet-road open, the
    // standing banner in the same words, no doors)

    static let noKeyFileAnywhere = "No key file opens this library. Variorum looked beside the library, inside every "
        + "backup, and in this Mac's keychain, and found none that opens it. Without one, there is nothing left to open."
    static let noKeyFileAnywhereAccountRoad = "This library syncs with your account. Sign in and enter your passphrase "
        + "or twelve words to bring your writing back."
    static let noKeyFileRestoreDoor = "Restore from Backup\u{2026}"
    static let noKeyFileOpenDoor = "Open Library\u{2026}"
    static let noKeyFileStartDoor = "Start a New Library"

    // MARK: - (4) The notice — §7c (4) (rule 21): her two sentences are the MODEL's (`LibraryNotice.sentence(date:)`),
    // never restated; the face's one button.

    static let noticeOK = "OK"

    // MARK: - (6) Rule 1's restore receipt — §7c (6), verbatim (`Repair.restoreKeyFileFromMirror`)

    static let restoredFromMirror = "The key file beside your library was missing. This Mac's sealed copy was put back."

    // MARK: - (7) Rule 3's reminder + the set-passphrase sheet — §7c (7), verbatim

    static let reminderLine = "Your library is only secured through iCloud Keychain right now — please add a passphrase "
        + "and keep your twelve words to ensure continued access."
    static let reminderSetDoor = "Set a passphrase\u{2026}"
    static let reminderNotNow = "Not now"
    static let reminderDontShowAgain = "Don't show again"
    static let setPassphraseTitle = "Set a passphrase"
    static let setPassphraseLead = "A passphrase is a convenience over your twelve words — easier to type, and either one "
        + "can reset the other."
    static let setPassphraseField = "Passphrase"
    static let setPassphraseAgain = "Again"
    static let setPassphraseButton = "Set passphrase"
    static let passphraseSetReceipt = "Passphrase set. Your twelve words still open the library too."

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

    // MARK: - U2's lines §7c does not draft — PROVISIONAL P-VX306-U2-2 (from the rules' own words, sentence case)

    /// The set-passphrase sheet's way out.
    static let setPassphraseCancel = "Cancel"
    /// The two fields disagree.
    static let setPassphraseMismatch = "The two passphrases don't match."
    /// The sheet refuses when a passphrase exists (P-VX306-U2-0 (a): the sheet sets the FIRST passphrase only; a
    /// change is VX-308's key door).
    static let setPassphraseAlreadySet = "This library already has a passphrase."
    /// The act failed (nothing is claimed about what landed — the act runs on a plan and the next open settles it).
    static let setPassphraseFailed = "Variorum couldn't set the passphrase just now. Try again."
    /// *Use it* failed.
    static let offerUseFailed = "Variorum couldn't put that key file beside your library just now."
    /// A backup whose day the catalogue can't name (its place carries no stamp) — the offer's and the receipt's
    /// `<date>`.
    static let offerUnknownDay = "an earlier day"

    /// The day the notice and the offer write in for `<date>` — her example's form (*"The backup from August 3"*),
    /// the year added when it isn't this year's (PROVISIONAL P-VX306-U2-2).
    static func day(_ date: Date, now: Date = Date(), calendar: Calendar = .current) -> String {
        var style = Date.FormatStyle(date: .omitted, time: .omitted).month(.wide).day()
        if calendar.component(.year, from: date) != calendar.component(.year, from: now) { style = style.year() }
        return date.formatted(style)
    }

    // MARK: - The route's failures (the failure face, with Try Again)

    static let couldNotCreate = "Variorum couldn't create your library."
    static let keychainUnreadableNoLibrary = "Variorum couldn't check this Mac's keychain, so it didn't create a "
        + "library. Try again."
    /// A hosted test run (the test host IS the dev-store app) never writes the dev scope — it never creates.
    static let testRunNeverCreates = "A test run never creates a library."
}
