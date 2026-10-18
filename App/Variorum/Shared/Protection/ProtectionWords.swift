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

    // MARK: - (8) Make this my library's confirm — §7c (8), verbatim (rule 17; VX-306 U3)

    static let makeMineTitle = "Make this my library?"
    /// The lead as drafted — the library has a passphrase (the posture word is Standard by construction this phase:
    /// every library the new road opens is Standard until VX-307's crossings).
    static let makeMineLead = "This copy becomes a new library — in Standard, under your current twelve words and "
        + "passphrase — with a fresh key of its own. Your current library steps aside whole into Previous Libraries, "
        + "where you can look inside it or make it your library again. The copy itself is not changed."
    /// The lead the confirm shows: §7c (8) as drafted when a passphrase is set; with none, the same sentence without
    /// "and passphrase" (a library with no passphrase is not under one — PROVISIONAL P-VX306-U3-3, her taste call).
    static func makeMineLeadShown(passphraseSet: Bool) -> String {
        passphraseSet
            ? makeMineLead
            : makeMineLead.replacingOccurrences(of: "twelve words and passphrase", with: "twelve words")
    }
    static let makeMineCopySecretField = "The copy's passphrase or twelve words"
    static let makeMineWordsField = "Your twelve words"
    static let makeMinePassphraseField = "Your passphrase"
    static let makeMineButton = "Make this my library"

    // MARK: - (9) The receipt — §7c (9), verbatim

    static let makeMineReceipt = "This is your library now. The previous one is in Previous Libraries."

    // MARK: - (10) Look inside's frame line — §7c (10), verbatim (`<date>` written in by `day`)

    static func lookInsideFrame(_ date: String) -> String {
        "This is a copy from \(date). Nothing you do here changes it or your library."
    }

    // MARK: - The doors' names — the plan's U3 addendum ("each row with *Look inside…* and *Make this my library…*")

    static let lookInsideDoor = "Look inside\u{2026}"
    static let makeMineDoor = "Make this my library\u{2026}"

    // MARK: - U3's lines §7c does not draft — PROVISIONAL P-VX306-U3-2 (from the rules' own words, sentence case)

    /// The Restore list's lead (rule 17: "The app's Restore from Backup is this door").
    static let restoreListLead = "Look inside a copy to read it without changing anything, or make it your library — "
        + "your current one steps aside into Previous Libraries."
    /// The second group: copies of other libraries on this Mac (rule 19: "Copies of other libraries are listed"), the
    /// library that stepped aside among them (§7c (8): "where you can look inside it or make it your library again").
    static let otherLibrariesHeading = "Other libraries on this Mac"
    /// A row's kind.
    static func copyKind(_ kind: CopyKind) -> String {
        switch kind {
        case .backup: return "Backup"
        case .previousLibrary: return "Previous library"
        case .adoptionSafetyCopy: return "Opened copy"
        }
    }
    /// The copy field's quiet note (an empty field tries your own pair — rule 4: your current secrets open older
    /// backups of the same library).
    static let makeMineCopySecretNote = "Leave it empty if your own passphrase and words open it."
    static let makeMineCancel = "Cancel"
    static let makeMineWorking = "Making this copy your library\u{2026}"
    static let makeMineChecking = "Checking the copy\u{2026}"
    /// Nothing typed or quiet opens the copy (`ExecutorRefusal.copyDoesNotOpen`).
    static let copyDoesNotOpen = "That doesn't open this copy. Enter the copy's own passphrase or twelve words."
    /// The copy left its place between the list and the press.
    static let copyGone = "That copy isn't there any more."
    /// Another act on the library is running.
    static let copyDoorBusy = "Another change to your library is still running. Try again in a moment."
    /// The act refused before anything moved (or rolled back whole).
    static let makeMineFailed = "Variorum couldn't make this copy your library just now. Nothing changed."
    /// A picked plain-text export — its landing (T-8) is VX-309's, never today's adoption on the new road.
    static let plaintextCopyNotYet = "Opening a plain-text copy isn't ready in this build yet."
    /// A picked copy the new road can't read (rule 26 — a copy from before this design is not handled; no sentence
    /// names it): today's honest minimum.
    static let pickedCopyUnreadable = "This file couldn't be read as a library."
    static let filingLine = "Reading what you picked\u{2026}"
    /// The picked thing is the library open now (or its folder) — a copy of it is never filed over it.
    static let pickedLiveLibrary = "That's the library you have open now."
    /// The picked pair could not be copied into this Mac's safety copies (the picked thing was only read).
    static let filingFailed = "Variorum couldn't keep a copy of what you picked. Nothing you picked was changed."
    /// The picked copy, filed: what it is.
    static func pickedCopyLine(_ day: String) -> String { "A copy from \(day)." }

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
