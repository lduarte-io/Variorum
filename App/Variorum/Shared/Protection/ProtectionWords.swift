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
    // (The history-only split pair's line — `KeyFileSearch.besideOpensItOnlyThroughItsHistory` — is DROPPED: no state
    // reaches it, her ruling 2026-10-18 on P-VX306-U2-6: "sure we can drop the sentence" — VX-414.)

    /// VX-414 — HER U2-7 variant (2), verbatim from the ticket (her ruling 2026-10-18: "I agree with your suggested
    /// wording"): the offer's opening when the place beside the library is EMPTY and a backup holds the right key file
    /// (her offer sentence there began by saying the key file beside the library doesn't open it — over no key file at
    /// all; `KeyFileOffer`'s sentences are the model's and are never restated here).
    static let offerBesideEmptyFromABackup = "There is no key file beside your library. A backup holds one that opens it."
    /// Her offer sentence's remainder after its "where" sentences (`KeyFileOffer.backupHoldsOne`'s last sentence —
    /// pinned to it): the question.
    static let offerUseItQuestion = "Use it?"

    // MARK: - (3) Rule 27's refusal — §7c (3), verbatim (the lobby's moment + its doors; after a quiet-road open, the
    // standing banner in the same words, no doors)

    static let noKeyFileAnywhere = "No key file opens this library. Variorum looked beside the library, inside every "
        + "backup, and in this Mac's keychain, and found none that opens it. Without one, there is nothing left to open."
    /// VX-414 — HER U2-7 variant (1), verbatim from the ticket (her ruling 2026-10-18: "I agree with your suggested
    /// wording"): the STANDING BANNER after a quiet open with no key file found anywhere — replacing rule 27's refusal
    /// words in that one state (they ended *Without one, there is nothing left to open.* over a library that had just
    /// opened). The lobby's moment (nothing opened) keeps §7c (3)'s words above.
    static let noKeyFileAfterAQuietOpen = "Variorum opened your library, but found no key file for it anywhere. Make a "
        + "backup now, so a copy exists."
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
    // Look inside's sheet (P-VX306-U3-15 built — its lines §7c does not draft, PROVISIONAL P-VX306-U3-16):
    /// The sheet's title (the door's name).
    static let lookInsideTitle = "Look inside"
    /// The copy doesn't open by a quiet road on this Mac: its own secret is asked.
    static let lookInsideAsk = "This copy doesn't open by itself on this Mac. Enter its passphrase or twelve words."
    static let lookInsideOpening = "Opening the copy\u{2026}"
    static let lookInsideBooks = "Books"
    static let lookInsideNotes = "Notes"
    static let lookInsideNoBooks = "No books."
    static let lookInsideNoNotes = "No notes."
    static func lookInsideBookCount(_ count: Int) -> String { count == 1 ? "1 note" : "\(count) notes" }
    static let lookInsideMore = "Show more"
    static let lookInsideBack = "Back"
    static let lookInsideUntitled = "Untitled"
    static let lookInsideClose = "Close"
    // VX-307 U2c — VX-413, the note page's Copy door (her ruling: the Copy full text format): the door's name and its two
    // sentences are a live note's Copy full text's own (`CapabilityRegistry`'s `.copyForAI` verb, `CopyForAI`'s receipt
    // and refusal — pinned equal on the Mac); the one line it adds is PROVISIONAL P-VX307-U2c-2.
    static let lookInsideCopyFullText = "Copy full text"
    static let lookInsideCopied = "Copied full text."
    static let lookInsideNothingToCopy = "Nothing to copy \u{2014} this note has no text yet."
    static let lookInsideCopyFailed = "Variorum couldn't read this note's full text from the copy just now."
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

    //
    // VX-306 U3 (the phone opens): the biometry's name and the device's are the platform's (`ProtectionCopy
    // .biometryName` / `.deviceName` — "Touch ID" / "Mac" here, "Face ID" / "iPhone" on the phone), so the Mac's lines
    // read byte-for-byte as before and the phone's say its own (PROVISIONAL P-VX306-U3-8).

    static let touchIDButton = "Unlock with \(ProtectionCopy.biometryName)"
    /// §3.10: "Touch ID isn't set up here, or isn't set up for this library."
    static let touchIDNotSetUpOnThisMac = "\(ProtectionCopy.biometryName) isn't set up on this \(ProtectionCopy.deviceName)."
    static let touchIDNotSetUpForThisLibrary = "\(ProtectionCopy.biometryName) isn't set up for this library."
    /// §3.10, verbatim.
    static let touchIDChanged = "\(ProtectionCopy.biometryName) changed since you set it up — unlock with the passphrase."
    /// §3.10: "Pressing it says why ('Open the lid…') and nothing changes."
    static func touchIDUnusableForNow(_ reason: TransientUnavailability) -> String {
        switch reason {
        case .lidClosed: return "Open the lid to use Touch ID."
        case .keyboardDisconnected: return "Connect your keyboard with Touch ID to use it."
        case .keyboardNotPaired: return "Pair your keyboard with Touch ID to use it."
        case .lockout:
            return "\(ProtectionCopy.biometryName) is locked after too many tries. Enter your passphrase, or lock and "
                + "unlock your \(ProtectionCopy.deviceName)."
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

    // MARK: - VX-307 U2a — THE CROSSINGS (rules 9, 11, 12; Replace All Keys — P-VX378-U2-1; both secrets — P-VX378-U2-2)
    //
    // RULE 12's leave-screen sentence and RULE 9's promise are HER words, verbatim from `notes/CastleRules.md` (the first
    // letter capitalized; `RoadCrossingWordsTests` reads the rules file and pins them byte-equal). Every other line here
    // is PROVISIONAL P-VX307-U2a-1 — drafted from the rules' and the lifecycle page's own words, sentence case, hers at the
    // bundle (the doors' names are the canon's: Use Castle, Use Standard, Replace All Keys).

    /// The doors' names (an ellipsis: a confirm follows).
    static let useCastleDoor = "Use Castle\u{2026}"
    static let useStandardDoor = "Use Standard\u{2026}"
    static let replaceAllKeysDoor = "Replace All Keys\u{2026}"
    /// The confirms' titles and their one button each.
    static let useCastleTitle = "Use Castle"
    static let useStandardTitle = "Use Standard"
    static let replaceAllKeysTitle = "Replace All Keys"
    /// The posture line on the open library (the first sentence of today's current-state line, the record's mode).
    static func postureLine(_ mode: ProtectionMode) -> String {
        switch mode {
        case .standard: return "You're in Standard."
        case .castle: return "You're in Castle."
        }
    }

    /// RULE 9 — her sentence, verbatim (Use Castle's lead).
    static let castlePromise = "Castle is one promise: no quiet road through Apple, ever, on any device of the account."
    /// Use Castle — what entering does (rule 11; the lifecycle's stage 6).
    static let useCastleLead = "Your library gets a new key, and the Apple and on-device keychain items are deleted — the "
        + "Apple ones on every device of your Apple account — so your backups are Castle-protected along with your library."
    /// `Words.floorSentence` — Castle's floor (rule 9: no quiet road through Apple; the design's §3.1 (2)).
    static let castleFloor = "From now on your passphrase, your twelve words, or \(ProtectionCopy.biometryName) on this "
        + "\(ProtectionCopy.deviceName) open your library. Lose all three and it is gone."
    /// `Words.exportAPlainCopyFirst` — the plain copy is Data Safety's door.
    static let exportAPlainCopyFirst = "If you want a plain copy outside Castle, export one first from Settings \u{25B8} "
        + "Data Safety."
    /// `Words.copiesUnderAKeyThisMacCantDelete` — rule 25's sentence, said at the door; the copies are named beneath.
    static let copiesUnderAKeyThisMacCantDelete = "These backups are locked under an Apple account this "
        + "\(ProtectionCopy.deviceName) no longer uses. They keep that lock, which Variorum can't delete:"
    /// A copy named by its kind and day (rule 25's list).
    static func namedCopy(kind: CopyKind, day: String) -> String { "\(copyKind(kind)) from \(day)" }
    /// `Words.scheduledExportTurnsOff` — rule 11's parenthetical, at the door.
    static let scheduledExportTurnsOff = "Your scheduled plain-text export turns off — a plain copy on disk would undo the "
        + "promise. You can turn it back on; it's your call."
    /// The gate choice (rule 9: "Touch ID on this Mac is optional; 'Always ask' means no copy of the key on the device at
    /// all, and you type every time"; the lifecycle's stage 6).
    static let gateHeading = "On this \(ProtectionCopy.deviceName)"
    static let gateTouchID = ProtectionCopy.biometryName
    static let gateAlwaysAsk = "Always ask"
    static let gateTouchIDLine = "This \(ProtectionCopy.deviceName) keeps the new key behind your fingerprint."
    static let gateAlwaysAskLine = "No copy of the key stays on this \(ProtectionCopy.deviceName); you type every time."

    /// RULE 12 — her leave-screen sentence, verbatim (`Words.ruleFive`, on every road into Standard).
    static let leaveSentence = "Your library and all your backups will open through your Apple account and this Mac "
        + "again; if you want Castle-era writing to stay Castle-protected, don't leave."
    /// Use Standard — what leaving does (rule 12).
    static let useStandardLead = "Leaving Castle hands everything to Standard: your library gets a new key, with a fresh "
        + "Apple road and this \(ProtectionCopy.deviceName)'s on-device road back."
    /// Replace All Keys — the library re-keys; the account's sync key stays (P-VX378-U2-1; rules 4, 15).
    static let replaceAllKeysLead = "Your library gets a new key, locked under your passphrase and your twelve words. "
        + "Every earlier key stays in its history, so your backups still open. Your account's sync key stays as it is."

    /// The confirm's fields (both typed — P-VX378-U2-2).
    static let crossingPassphraseField = "Your passphrase"
    static let crossingWordsField = "Your twelve words"
    /// No passphrase yet: the door sets the one typed (rule 3 — "nothing … depends on it except entering Castle").
    static let crossingNewPassphraseLead = "This library has no passphrase yet. Choose one — Castle needs it."
    static let crossingNewPassphraseField = "New passphrase"
    static let crossingNewPassphraseAgain = "Again"
    static let crossingCancel = "Cancel"
    static let crossingWorking = "Changing your library's keys\u{2026}"
    /// What a crossing's typing came to before anything moved.
    static let crossingSecretsMissing = "Enter your passphrase and your twelve words."
    /// The door changed between the confirm and the press (VX-108: the press re-reads it).
    static let crossingDoorClosed = "This door isn't open any more. Nothing changed."
    /// The door is still open but says something new — re-shown, nothing done.
    static let crossingDoorChanged = "Something changed since this opened. Read it again before you go on."
    /// Anything else, with the library still under its old key (nothing swapped, or the act rolled back whole).
    static let crossingFailed = "Variorum couldn't make this change just now. Nothing changed."
    /// VX-113 — the passphrase changed elsewhere, named (the plan's §1 sentence).
    static func passphraseChangedElsewhere(device: String?, day: String?) -> String {
        switch (device, day) {
        case let (device?, day?): return "Your passphrase was changed on \(device) on \(day)."
        case let (device?, nil): return "Your passphrase was changed on \(device)."
        case let (nil, day?): return "Your passphrase was changed on \(day)."
        case (nil, nil): return "Your passphrase was changed on another device."
        }
    }

    /// The doors' refusals (a door that can't act now says why in its place; "not this posture's door" renders nothing).
    static let doorRefusedOtherAccount = "Another account is signed in on this \(ProtectionCopy.deviceName). Sign in to "
        + "this library's account first."
    static let doorRefusedSignedOut = "You're signed out of this library's account. Sign in first."
    static let doorRefusedNeedsVault = "Variorum couldn't reach your account just now. Try again in a moment."
    static let doorRefusedFollowOwed = "Your account changed on another device. Follow it first."
    static let doorRefusedNoAccount = "Sign in to your account first."

    /// The crossings' receipts (the status seam; `receipt_style` governs them).
    static let enteredCastleReceipt = "You're in Castle now."
    static let leftCastleReceipt = "You're in Standard now."
    static let replacedKeysReceipt = "Your library has a new key. Your passphrase and twelve words still open it."

    /// `ActNotice.scheduledExportTurnedOff` — rule 11's "one notice you may reverse".
    static let exportTurnedOffNotice = "Your scheduled plain-text export is off now — a plain copy on disk would undo "
        + "Castle's promise. It's your call."
    static let exportTurnBackOn = "Turn it back on"
    static let exportNoticeOK = "OK"
    static let exportTurnBackOnFailed = "Variorum couldn't turn the export back on just now."

    /// The gate-style row on the open library (Castle only — `changeSettings`; Touch ID on only with the passphrase).
    static let gateRowTouchID = "\(ProtectionCopy.biometryName) opens your library on this \(ProtectionCopy.deviceName)."
    static let gateRowAlwaysAsk = "Always ask: no copy of the key stays on this \(ProtectionCopy.deviceName), and you "
        + "type every time."
    static let gateRowUseAlwaysAsk = "Use Always ask"
    static let gateRowUseTouchID = "Use \(ProtectionCopy.biometryName)\u{2026}"
    static let gateRowTouchIDButton = "Use \(ProtectionCopy.biometryName)"
    static let gateRowFailed = "Variorum couldn't change this just now."

    /// VX-310 — the RE-ARM question after a press failed on an item that exists (the design's §3.10 sentence; the
    /// third sentence is the Mac's — a finger is Touch ID's word).
    static let rearmQuestion: String = {
        let head = "\(ProtectionCopy.biometryName) can't open Variorum on this \(ProtectionCopy.deviceName) any more. "
            + "Set it up again?"
        return ProtectionRoad.isMac
            ? head + " Every finger enrolled on this \(ProtectionCopy.deviceName) will open it." : head
    }()
    static let rearmYes = "Set it up again"
    static let rearmNo = "Always ask instead"
    static let rearmFailed = "Variorum couldn't set up \(ProtectionCopy.biometryName) just now."

    // MARK: - VX-307 U2b — THE TWELVE WORDS, HER WAY (rules 2, 3 and 6 as amended; her words in the plan's §3a)
    //
    // RULE 2's card sentence is HER words, verbatim from `notes/CastleRules.md` (the first letter capitalized, the
    // period added; `WordsBandTests` reads the rules file and pins it byte-equal), and so is the close's warning ("these
    // words won't be shown again"). Every other line here is PROVISIONAL P-VX307-U2b-2 — drafted from the rules' own
    // words, sentence case, hers at the bundle.

    /// RULE 2 — the card above the quick entry; the whole line is the door (her "click here").
    static let wordsCardLine = "Your library is encrypted \u{2014} click here to record the twelve words that are its key."
    /// The snooze (her "a snoozed card showing on next launch is fine").
    static let wordsCardLater = "Later"
    /// The ✕'s spoken name.
    static let wordsCardDismiss = "Dismiss"
    /// The ✕'s toast (her "look in settings, protection for this information"; rule 2: "dismissing it says where to
    /// find them in Settings").
    static let wordsCardDismissedToast = "You can record your twelve words any time in Settings \u{25B8} Protection."
    /// The look's ask where a passphrase exists (rule 6: new words ask the passphrase).
    static let wordsLookAsk = "Enter your passphrase to see your twelve words."
    static let wordsLookPassphraseField = "Your passphrase"
    static let wordsLookShow = "Show my twelve words"
    static let wordsLookCancel = "Cancel"
    static let wordsLookMinting = "Making your twelve words\u{2026}"
    /// The words on screen (rule 2: "the card says 'write these down now'").
    static let wordsLookLead = "Write these down now. They open your library \u{2014} on this "
        + "\(ProtectionCopy.deviceName) and on any copy of it \u{2014} for as long as they are its words."
    /// RULE 6's one sentence (with rules 4 and 5), said when she recorded words here before (never on the first look).
    static let wordsLookRuleSix = "Your library's key doesn't change: every backup opens with these words, and still "
        + "with the words you had when you made it."
    /// VX-412's Copy door and its caption. VX-308 U3 — VX-448 (her ruling, QUESTIONS #235: the 60-second timer and the
    /// restore go; a concealed type, cleared at lock and at quit): the caption says the new road's rule (PROVISIONAL
    /// P-VX308-U3-2 — today's road keeps its own sentence, `ProtectionCopy.wordsCopied`, with its own rule).
    static let wordsLookCopy = "Copy"
    static let wordsLookCopied = "Copied. Your clipboard keeps them until you copy something else, your library locks or "
        + "Variorum quits."
    static let wordsLookWrittenDown = "I've written them down"
    /// HER words — the warning before the look closes.
    static let wordsLookWarning = "These words won't be shown again."
    static let wordsLookGoBack = "Go back"
    static let wordsLookClose = "Close"
    /// The act failed, nothing changed.
    static let wordsLookFailed = "Variorum couldn't make your twelve words just now. Nothing changed."
    /// Another look already holds words on screen (one look at a time — a second would replace the words still shown).
    static let wordsLookElsewhere = "Your twelve words are already on screen \u{2014} finish with them there first."
    /// Settings ▸ Protection — the door the dismiss toast names (rule 7: "fresh words appear only at a library's own
    /// first look or its new-words door").
    static let wordsSectionTitle = "Your twelve words"
    static let wordsSectionLine = "Variorum doesn't keep your twelve words, so looking makes new ones for you to write "
        + "down. Your library's key doesn't change."
    static let wordsSectionDoor = "Record your twelve words\u{2026}"
    /// The tour's last card (rule 3: "asks, and shows the twelve words beside the ask"): the passphrase set there.
    static let tourEndPassphraseSet = "Passphrase set."

    // MARK: - VX-308 U1 — THE ACCOUNT SECTION (rules 7, 14, 16; the plan's U1 ARBITRATION)
    //
    // RULE 16's two sentences and RULE 7's are HER words, verbatim from `notes/CastleRules.md` (the first letter
    // capitalized, rule 16's own "(rule 7)" pointer dropped; `RoadAccountWordsTests` reads the rules file and pins them
    // byte-equal). The sign-out confirm byte-reuses today's shipped copy (`ProtectionCopy`, pinned equal). The signed-out
    // screens are drafted to the CURRENT rules — her word (2026-10-19): "10-13 is probably old and superseded by now" — so
    // the whole screen is PROVISIONAL and the bundle names what diverged from QUESTIONS #216's 10-13 block. Every other line
    // here is PROVISIONAL P-VX308-U1-1 — drafted from the rules' and the lifecycle page's own words, sentence case.

    /// RULE 16 — her first sentence, verbatim (every leave's confirm says it).
    static let ruleSixteen = "Leaving an account changes none of your library's keys or secrets \u{2014} it stops syncing, "
        + "and the server keeps what you pushed (removing it is the account-deletion road)."
    /// RULE 16 — her second sentence, verbatim (its "(rule 7)" pointer dropped).
    static let signingBackInIsAJoin = "Signing back in is a join."
    /// RULE 7 — her first sentence, verbatim (turning sync on).
    static let onePairAtATime = "A device holds one pair of secrets at a time."
    /// RULE 7 — her join sentence, verbatim (U2's words moment says it; kept here beside its rule).
    static let joinWordsSentence = "Your library's twelve words are now your account's twelve words; here they are; the "
        + "old ones still open backups you made before today."

    /// The section (Settings ▸ Protection on the new road).
    static let accountSectionTitle = "Sync"
    /// The situations (`AccountSituation`).
    static let accountLocalOnly = "This library doesn't sync."
    static let accountInSync = "This library syncs with your account."
    static func accountSignedInAs(_ email: String) -> String { "Signed in as \(email)." }
    /// Signed out: the library still names its account (the record names it; signing out never changes it).
    static let accountSignedOut = "You're signed out of sync."
    static let accountSignedOutLine = "This library still syncs with an account, but no one is signed in on this "
        + "\(ProtectionCopy.deviceName), so nothing syncs. Sign in to sync again, or use this library on this "
        + "\(ProtectionCopy.deviceName) only \u{2014} the account's copy on the server stays as it is."
    static let accountOtherAccount = "Another account is signed in on this \(ProtectionCopy.deviceName)."
    static let accountOtherAccountLine = "This library syncs with a different account. Sign out, or move this library to "
        + "the account that's signed in."
    /// `Words.sameEmailDifferentAccount`.
    static let accountSameEmailDifferentAccount = "The account signed in uses the same email, but it is a different "
        + "account."
    static let accountSignInToTurnOnSync = "Sign in to turn on sync."

    /// The doors (an ellipsis: a confirm or a sheet follows).
    static let turnOnSyncDoor = "Turn on sync\u{2026}"
    static let stopSyncingHereDoor = "Stop syncing here\u{2026}"
    static let deleteAccountHereDoor = "Delete the account from this \(ProtectionCopy.deviceName)\u{2026}"
    static let thisMacOnlyDoor = "Use this \(ProtectionCopy.deviceName) only\u{2026}"
    static let accountSignOutDoor = "Sign out\u{2026}"
    static let accountSignInDoor = "Sign in\u{2026}"
    /// VX-308 U2 — Move's one arm with no face yet: the signed-in account has NO vault (moving there would be a leave and
    /// a set-up, two acts — the core's `move` joins an account that already syncs). The honest not-yet line (the
    /// `plaintextCopyNotYet` precedent; PROVISIONAL P-VX308-U2-6).
    static let moveNotYet = "Moving this library to that account isn't ready in this build yet."

    /// Turn on sync — the first device hands its pair up (rule 7); the account takes the library's posture.
    static let turnOnSyncTitle = "Turn on sync"
    /// The lifecycle page's stage 12, verbatim ("Turning sync on first").
    static let turnOnSyncLead = "Your library's passphrase and twelve words become the account's. Nothing is replaced."
    static func turnOnSyncPosture(_ mode: ProtectionMode) -> String {
        switch mode {
        case .standard: return "Your account starts in Standard, like this library."
        case .castle: return "Your account starts in Castle, like this library."
        }
    }
    /// No passphrase yet (rule 14: the account's keys are wrapped by the passphrase and the twelve words only).
    static let turnOnSyncNewPassphraseLead = "This library has no passphrase yet. Choose one \u{2014} your account is "
        + "locked under your passphrase and your twelve words."
    static let turnOnSyncButton = "Turn on sync"
    static let turnOnSyncReceipt = "Sync is on. Your passphrase and twelve words are your account's now."

    /// Stop syncing here (rule 16 — the library's keys and secrets unchanged).
    static let stopSyncingTitle = "Stop syncing here"
    static let stopSyncingLead = "This \(ProtectionCopy.deviceName) stops syncing this library and forgets your account's "
        + "sync keys. Your other devices keep syncing."
    static let stopSyncingButton = "Stop syncing"
    static let stopSyncingReceipt = "This library doesn't sync on this \(ProtectionCopy.deviceName) any more."

    /// Delete the account from this Mac — the LOCAL leave (P-VX308-U1-F1, the U1 ARBITRATION's refined (b)), with ONE
    /// pointer to where the real deletion lives (the Account sheet's door, her ruled friction, unduplicated).
    static let deleteHereTitle = "Delete the account from this \(ProtectionCopy.deviceName)"
    static let deleteHereLead = "This \(ProtectionCopy.deviceName) forgets the account and its sync keys. The account "
        + "itself isn't deleted."
    static let deleteHerePointer = "To delete the account itself, and everything it keeps on the server, choose "
        + "Account\u{2026} in the sidebar's sync row, then Delete Account."
    static let deleteHereButton = "Delete from this \(ProtectionCopy.deviceName)"
    static let deleteHereReceipt = "This \(ProtectionCopy.deviceName) doesn't use that account any more."

    /// This Mac only — signed out, the one road (the 10-13 shape: Continue / Cancel, still true under rule 16).
    static let thisMacOnlyTitle = "Use this \(ProtectionCopy.deviceName) only"
    static let thisMacOnlyLead = "This \(ProtectionCopy.deviceName) stops using your sync account and forgets its sync "
        + "keys."
    static let accountContinue = "Continue"
    static let thisMacOnlyReceipt = "This library is on this \(ProtectionCopy.deviceName) only now."

    /// The sign-out confirm — today's shipped copy, byte-reused (decision 20's §4).
    static let accountSignOutTitle = ProtectionCopy.signOutTitle
    static let accountSignOutBody = ProtectionCopy.signOutBody
    static let accountSignOutButton = ProtectionCopy.signOutDoor

    static let accountCancel = "Cancel"
    static let accountWorking = "Working\u{2026}"
    /// An account act stopped mid-plan (its act stays in flight; the next open settles it — rule 20).
    static let accountActUnfinished = "Variorum couldn't finish this just now. It finishes the next time your library "
        + "opens."
    /// The sign-in sheet asked for where this window has no app services to sign in through — a composition hole the
    /// shipped composition never leaves (the ladder's round-1 NIT-1: said plainly, never another state's sentence).
    static let signInUnavailable = "Signing in isn't available in this window."
    static let signInUnavailableClose = "Close"

    /// USE CASTLE WHILE SIGNED OUT — the signed-out screen, drafted to the CURRENT rules (`assess`: the one plain road,
    /// This Mac Only, stands in Use Castle's place; rule 16: that leave changes no key or secret; P-VX378-U2-2: Use Castle's
    /// own confirm types both secrets). *Continue* runs the leave, then Use Castle's confirm; *Cancel* writes nothing.
    static let signedOutCastleTitle = accountSignedOut
    static let signedOutCastleLead = "Castle will apply to this library on this \(ProtectionCopy.deviceName) only. "
        + "First, this \(ProtectionCopy.deviceName) stops using your sync account \u{2014} none of your keys or secrets "
        + "change, and the account's copy on the server stays as it is. Then Use Castle asks for your passphrase and your "
        + "twelve words, as always."
    static let signedOutCastleWholeAccount = "To put your whole account in Castle instead, cancel, sign in, and choose Use "
        + "Castle again."
    /// The receipt's last sentence when Use Castle followed that road (true here: turning sync on hands the account the
    /// library's posture).
    static let bornCastleNote = "Set up sync again later with a new account and it starts in Castle."

    // MARK: - VX-308 U2 — THE JOIN AND THE FOLLOW (rules 7, 10, 12, 14, 16; P-VX378-U2-3; VX-107; VX-113)
    //
    // HER words, already pinned byte-equal to `notes/CastleRules.md` where they live above: rule 7's join sentence
    // (`joinWordsSentence` — the words moment says it) and its first (`onePairAtATime`), rule 12's leave sentence
    // (`leaveSentence` — the join that leaves Castle and the follow out say it: `Words.ruleFive`), rule 9's promise
    // (`castlePromise`), rule 16's (`ruleSixteen` — Move says it). VX-113's sentence is her #205 ruling (ii)'s
    // (`passphraseChangedElsewhere`, above). Every other line here is PROVISIONAL P-VX308-U2-1 — drafted from the rules' and
    // the lifecycle page's own words (stage 12), sentence case, hers at the bundle.

    /// THE JOIN's lead (the lifecycle page's stage 12, "Joining from another device": one of the account's secrets typed
    /// once; the library's own pair replaced by the account's — rules 7, 14).
    static let joinLead = "Your account already syncs. Type its passphrase or its twelve words once \u{2014} your "
        + "library's own passphrase and twelve words are replaced by your account's."
    /// What the join does to the library's posture (`JoinPlan`) — the consent says which (one posture at a time).
    static func joinPlanLine(_ plan: JoinPlan, library: ProtectionMode) -> String? {
        switch plan {
        case .entersCastle: return "Your account is in Castle, so this library goes into Castle too."
        case .leavesCastle: return "Your account is in Standard, so this library leaves Castle."
        case .sameMode:
            switch library {
            case .castle: return "Your account is in Castle, like this library."
            case .standard: return "Your account is in Standard, like this library."
            }
        case .setsUpInLibrarysMode: return nil
        }
    }
    /// The join's fields (rule 14: ONE of the account's secrets).
    static let joinPassphraseField = "Your account's passphrase"
    static let joinWordsField = "Or your account's twelve words"
    /// The join's receipt (the posture said when it changed). Move's head names "the signed-in account" — one "now" per
    /// receipt (the ladder's round-1 NIT-2: "…the account signed in now. … twelve words now." said it twice).
    static func joinedReceipt(_ plan: JoinPlan, moved: Bool) -> String {
        let head = moved ? "This library syncs with the signed-in account" : "Sync is on"
        switch plan {
        case .entersCastle: return head + ", and you're in Castle now, like your account."
        case .leavesCastle: return head + ", and you're in Standard now, like your account."
        case .sameMode, .setsUpInLibrarysMode:
            return head + ". Your library uses your account's passphrase and twelve words now."
        }
    }
    /// THE WORDS MOMENT when the PASSPHRASE was the secret typed (P-VX378-U2-3 (a) — "the face shows them when typed";
    /// otherwise it says the account's words now open the library): the words were replaced, and nothing here can show
    /// them. Her eye at the bundle — rule 7's "here they are" edge.
    static let joinWordsNotShown = "Your library's twelve words are now your account's twelve words \u{2014} the ones you "
        + "keep for your account. You joined with your passphrase, and Variorum never keeps the words, so they aren't shown "
        + "here. The old ones still open backups you made before today."
    static let joinWordsMomentOK = "OK"

    /// MOVE — leave the account the library syncs with (rule 16: no key or secret changes for that) and join the one
    /// signed in (rule 7). The door names the account signed in.
    static func moveDoor(_ email: String?) -> String {
        email.map { "Move this library to \($0)\u{2026}" } ?? "Move this library to this account\u{2026}"
    }
    static let moveTitle = "Move to this account"
    static let moveLead = "This library stops syncing with the account it syncs with now, and joins the account signed in "
        + "on this \(ProtectionCopy.deviceName)."
    static let moveButton = "Move"

    /// THE FOLLOW (rules 10, 12, 15) — the account changed on another device and this one follows.
    static let followDoor = "Follow your account\u{2026}"
    static let followTitle = "Follow your account"
    static let followButton = "Follow"
    /// The follow's notice in the account section, by kind — the vault's last writer and its day where the read has them
    /// (decision 34's names; VX-113's form).
    static func followNotice(_ kind: FollowKind, device: String?, day: String?) -> String {
        let at = "on \(device ?? "another device")" + (day.map { " on \($0)" } ?? "")
        switch kind {
        case .intoCastle: return "Your account entered Castle \(at)."
        case .intoStandard: return "Your account left Castle \(at)."
        case .keysReplaced: return "Your account's keys changed \(at)."
        }
    }
    /// What following asks — rule 10's "each typing a secret once" (and rule 15's catch-up); rule 12's "quietly" out.
    static func followAsk(_ kind: FollowKind) -> String {
        switch kind {
        case .intoCastle: return "Type your passphrase or your twelve words once to follow it here."
        case .keysReplaced: return "Type your passphrase or your twelve words once to catch up."
        case .intoStandard: return "This \(ProtectionCopy.deviceName) follows it out without asking you for anything."
        }
    }
    /// Rule 10's "accepted and said plainly": until a device follows into Castle, it reads what it already has.
    static let followUntilThen = "Until this \(ProtectionCopy.deviceName) follows, it can still read what it already has "
        + "\u{2014} its own copy of your library \u{2014} through its own quiet road."
    /// The follow's fields (one secret — the library's account's, which this library's pair already is: rule 7).
    static let followPassphraseField = "Your passphrase"
    static let followWordsField = "Or your twelve words"
    /// VX-107 — THE FOLLOW'S DONE, its other-device sentence, by kind: said once the follow has landed — at the press, or
    /// by the open whose settle finished it after a crash (re-said from the act in flight the record names, never from
    /// this process's memory).
    static func followDone(_ kind: FollowKind) -> String {
        switch kind {
        case .intoCastle:
            return "Your account entered Castle on another device, and this \(ProtectionCopy.deviceName) followed it."
        case .intoStandard:
            return "Your account left Castle on another device, and this \(ProtectionCopy.deviceName) followed it out."
        case .keysReplaced:
            return "Your account's keys changed on another device, and this \(ProtectionCopy.deviceName) caught up."
        }
    }

    // MARK: - VX-308 U3 — THE KEY DOORS, VX-447, F-U2-3 (rules 2, 3, 6, 7, 27; the plan's §5c)
    //
    // VX-263's ONE line is the plan's (§2's ledger and §5c: *your current secrets open everything you've made of this
    // library* — rule 6's "the doors say so in one sentence"), the first letter capitalized and the period added;
    // `RoadKeyDoorWordsTests` reads the plan file and pins it as drafted. Her U2-7 (1) first sentence is reused, never
    // restated (the prefix of `noKeyFileAfterAQuietOpen`, pinned). Every other line here is PROVISIONAL P-VX308-U3-2 —
    // drafted from the rules' own words, sentence case, hers at the bundle.

    /// VX-263's one line — every key door says it (rule 6: "the doors say so in one sentence").
    static let keyDoorsLine = "Your current secrets open everything you've made of this library."
    /// Synced, the key doors change the account's lock with the library's (rule 7: "the key doors change the library's
    /// and the account's locks together") — the face says so; the act does it.
    static let keyDoorsSyncedPassphraseLine = "This library syncs with your account, so your account's passphrase changes "
        + "with it, on every device."

    /// The passphrase's section on the open library (the doors where a passphrase exists; *Set a passphrase…* where none).
    static let passphraseSectionTitle = "Your passphrase"
    /// Change passphrase (the current one verified; a new one typed twice).
    static let changePassphraseDoor = "Change passphrase\u{2026}"
    static let changePassphraseTitle = "Change passphrase"
    static let changePassphraseCurrentField = "Current passphrase"
    static let changePassphraseButton = "Change passphrase"
    static let changePassphraseReceipt = "Your passphrase is changed."
    /// Reset a forgotten passphrase (the forgot road — Standard: a plain confirm; Castle: the words or Touch ID).
    static let resetPassphraseDoor = "Reset forgotten passphrase\u{2026}"
    static let resetPassphraseTitle = "Reset forgotten passphrase"
    /// Standard — this Mac holds the key (rule 8), so nothing else is asked.
    static let resetPassphraseStandardLead = "This \(ProtectionCopy.deviceName) holds your library's key, so you can "
        + "choose a new passphrase without the old one."
    /// Castle — the words, or Touch ID where this Mac has its item for the key.
    static let resetPassphraseCastleLead = "Confirm it's you with your twelve words, then choose a new passphrase."
    static let resetPassphraseCastleTouchIDLead = "Confirm it's you with your twelve words or "
        + "\(ProtectionCopy.biometryName), then choose a new passphrase."
    static let resetPassphraseWordsField = "Your twelve words"
    static let resetPassphraseButton = "Reset passphrase"
    static let resetPassphraseWithTouchID = "Reset with \(ProtectionCopy.biometryName)"
    static let resetPassphraseTouchIDNotConfirmed = "\(ProtectionCopy.biometryName) didn't confirm it's you. Nothing changed."
    static let resetPassphraseReceipt = "Your passphrase is reset."
    /// A key door's new passphrase fields (the crossings' own names).
    static let keyDoorNewPassphraseField = crossingNewPassphraseField
    static let keyDoorNewPassphraseAgain = crossingNewPassphraseAgain
    static let keyDoorCancel = "Cancel"
    static let keyDoorWorking = "Working\u{2026}"

    /// F-U2-3 (the architect's ruling): on a SYNCED library a look says this BEFORE minting — new words replace the
    /// account's words everywhere (rule 7: the key doors change both locks together); her *Show my twelve words* is the yes.
    static let wordsLookReplacesAccountWords = "This library syncs with your account, so new words also replace your "
        + "account's twelve words, on every device."

    /// VX-447 — THE BANNER BECOMES THE DOOR (her ruling): her U2-7 (1) first sentence, reused (the prefix of
    /// `noKeyFileAfterAQuietOpen` — pinned) …
    static let noKeyFileOpenedLead = noKeyFileAfterAQuietOpen.components(separatedBy: ". ").first.map { $0 + "." }
        ?? noKeyFileAfterAQuietOpen
    /// … then the door: record the words → a fresh key file → the backup follows (the whole line is the door — rule 2's
    /// card idiom, her "click here").
    static let noKeyFileDoor = "Click here to record your twelve words \u{2014} Variorum makes a new key file with them, "
        + "then a backup."
    /// F-U2c-5 folded (her ruling: "the synced flavor gains the open-library variant of the account sentence") — said
    /// over the library that just opened, in place of the lobby's *Sign in … to bring your writing back*.
    static let noKeyFileAccountRoadOpen = "This library syncs with your account, so your writing is kept there too "
        + "\u{2014} your passphrase or twelve words bring it back on any device."
    /// The receipt once the look minted the fresh file (and the pair followed, or not).
    static func keyFileRemadeReceipt(backedUp: Bool) -> String {
        backedUp
            ? "Your library has a key file again, and a backup holds a copy."
            : "Your library has a key file again."
    }

    // MARK: - VX-308 U4 — THE HOLD'S GATE (F-4: the 13x F1 R1-M1 rule on the new road's synced crossings)
    //
    // PROVISIONAL P-VX308-U4-1 — drafted in the shipped hold copy's idiom (`LibraryOpenCopy.syncNowHeldRefusal`'s
    // *Sync is waiting since the restore — press Resume Sync …*, and `confirmLeavesCastle`'s *press Resume Sync, then choose
    // Use Castle again*), sentence case, hers at the bundle.

    /// A synced Use Castle or Replace All Keys while the restore hold stands — said in place of the door, and by the press.
    static func restoreHoldRefusal(_ doorTitle: String) -> String {
        "Sync is waiting since the restore \u{2014} press Resume Sync in the main window's banner, then choose "
            + "\(doorTitle) again."
    }

    // MARK: - The route's failures (the failure face, with Try Again)

    static let couldNotCreate = "Variorum couldn't create your library."
    static let keychainUnreadableNoLibrary = "Variorum couldn't check this Mac's keychain, so it didn't create a "
        + "library. Try again."
    /// A hosted test run (the test host IS the dev-store app) never writes the dev scope — it never creates.
    static let testRunNeverCreates = "A test run never creates a library."
}
