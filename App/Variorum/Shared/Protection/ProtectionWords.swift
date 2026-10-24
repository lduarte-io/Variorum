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
    /// VX-329's phone fix leg (VX-306's walk W-15 — the phone's card said "on this Mac"): the device is the platform's
    /// noun, as every road sentence below names it; the Mac's text is byte-unchanged. PROVISIONAL P-VX329-PH-1.
    static let wordsCardLead = "Your library is encrypted. These twelve words open it — on this "
        + "\(ProtectionCopy.deviceName), on any copy of it, for as long as they are its words. Write them down now and keep "
        + "them somewhere safe. Variorum won't show them again."
    static let wordsCardFoot = "You can add a passphrase later, as a convenience over the words. Either one can reset "
        + "the other."
    static let wordsCardButton = "I've written them down"

    // MARK: - (2) The key-file offer — §7c (2), verbatim (rule 21; VX-306 U2)
    //
    // The offer's SENTENCE is the model's (`KeyFileOffer.words` / `sentence(date:)` — her strings,
    // `besideDoesNotOpenIt` + `keychainHoldsOne` / `backupHoldsOne`); never restated here.

    static let offerUseIt = "Use it"
    static let offerNotNow = "Not now"
    /// The receipt after *Use it* — the source named (the device by the platform's noun — P-VX329-PH-1).
    static let offerRestoredFromKeychain = "Key file restored from this \(ProtectionCopy.deviceName)'s keychain."
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

    /// (The device by the platform's noun — the phone's lobby says it too; P-VX329-PH-1, the Mac's text byte-unchanged.)
    static let noKeyFileAnywhere = "No key file opens this library. Variorum looked beside the library, inside every "
        + "backup, and in this \(ProtectionCopy.deviceName)'s keychain, and found none that opens it. Without one, there is "
        + "nothing left to open."
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

    // MARK: - (3b) The pre-design face — HER WORDS (VX-329 U4; approved at her 2026-10-22 morning sitting, the plan's
    // §6d, byte-faithful — `PreDesignFaceTests` pins each byte-equal to the plan file). Rule 26: a store from before this
    // design is detected by its key files' names and said; set aside whole at her word, never read.

    static let preDesignLead = "This library is from an older version of Variorum."
    static let preDesignBody = "This version can't open it. Open the previous version to copy anything out \u{2014} or if "
        + "it synced, your writing comes back when you sign in. Starting fresh sets this library aside, whole, in "
        + "Previous Libraries."
    static let preDesignStartFreshDoor = "Start fresh\u{2026}"
    /// Her second door is the standing one, by its own name (rule 27's face's — the same words).
    static var preDesignOpenDoor: String { noKeyFileOpenDoor }
    static let preDesignStartFreshConfirm = "Your old library will be set aside whole in Previous Libraries \u{2014} "
        + "nothing is deleted."
    /// The confirm's act button: her door's own words without its ellipsis (the macOS idiom — the ellipsis says a door
    /// asks more; the button that answers the ask does not). PROVISIONAL P-VX329-U4-2.
    static let preDesignStartFreshButton = "Start fresh"

    // MARK: - (4) The notice — §7c (4) (rule 21): her two sentences are the MODEL's (`LibraryNotice.sentence(date:)`),
    // never restated; the face's one button.

    static let noticeOK = "OK"

    // MARK: - (6) Rule 1's restore receipt — §7c (6), verbatim (`Repair.restoreKeyFileFromMirror`)

    /// (The device by the platform's noun — P-VX329-PH-1, the Mac's text byte-unchanged.)
    static let restoredFromMirror = "The key file beside your library was missing. This \(ProtectionCopy.deviceName)'s "
        + "sealed copy was put back."

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
    /// VX-309 U2 — VX-211 (her kickoff ruling, "Floor + quiet hint"): the ONE calm line beside a new passphrase field — the
    /// Domain estimator's advice (`PassphraseStrength`), never a block, never a meter, no colour; nothing at all for a long,
    /// varied phrase or an empty field. The short line is the brief's own example, sentence-cased (PROVISIONAL P-VX309-U2-7).
    static func passphraseHint(_ advice: PassphraseAdvice) -> String? {
        switch advice {
        case .none: return nil
        case .short: return "Short passphrases are easier to guess \u{2014} a longer phrase is stronger."
        case .repetitive:
            return "Repeated characters are easy to guess \u{2014} a phrase of a few different words is stronger."
        }
    }
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
    /// VX-309 U2 — VX-264 ITEM 7 (her #216 VX-209 ruling, "A: concrete" — "why would we not make it concrete? why are we
    /// telling the user to check? do we not know what happened?"): the lead COMPUTED per the open library's shape. The
    /// posture the copy lands in, said concretely (rule 17: "in the posture you are in now"; §7c's draft is the Standard,
    /// unsynced arm, byte for byte); in Castle, rule 17's own sentence, hers (`neverLeaveCastle`); synced, VX-209's synced
    /// arm — the new library carries no sync identity (P-VX378-U2-4), so it doesn't sync until she turns sync on for it
    /// (PROVISIONAL P-VX309-U2-5).
    static func makeMineLead(posture: ProtectionMode, passphraseSet: Bool, synced: Bool) -> String {
        var lead = makeMineLeadShown(passphraseSet: passphraseSet)
        if posture == .castle {
            lead = lead.replacingOccurrences(of: "a new library \u{2014} in Standard,", with: "a new library \u{2014} in Castle,")
                + " " + neverLeaveCastle
        }
        if synced { lead += " " + makeMineSyncedLine }
        return lead
    }
    /// RULE 17 — her sentence, verbatim (`notes/CastleRules.md`): Make this my library in Castle.
    static let neverLeaveCastle = "You never leave Castle by opening something."
    /// VX-209's synced arm (PROVISIONAL P-VX309-U2-5): the copy becomes a library of this Mac's until she turns sync on.
    static let makeMineSyncedLine = "The new library doesn't sync with your account until you turn on sync for it in "
        + "Settings \u{25B8} Protection."
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
    /// VX-309 U2 — VX-264 ITEM 5 in the listings: her "older libraries" words (#216), fitted to the rows' kind label
    /// (*Previous library* — rule 17's Previous Libraries), said where one is listed (PROVISIONAL — the fitting).
    static let olderLibrariesLine = "A previous library is an older library Variorum kept when you opened or restored a "
        + "different one \u{2014} your way back to what you had before."
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

    // MARK: - VX-309 U1b — T-5, Make this my library into the empty slot (P-VX309-U1b-3's lines, re-drafted at VX-309 U2's
    // words pass in §7c's voice — PROVISIONAL P-VX309-U2-10)

    /// The confirm's lead with no library open: the copy becomes the library under the secret typed for it (rule 14's
    /// precedent — a typed secret, never a quiet road alone). As built (`EmptySlotMakeMineProgram`): the copy's words typed
    /// become the library's words (no passphrase rides — rule 3's reminder asks for one); its passphrase typed becomes the
    /// library's passphrase beside twelve words made fresh, which the card above the quick entry offers. §7c (8)'s shape.
    static let makeMineEmptySlotLead = "This copy becomes your library \u{2014} a new library, in Standard, with a fresh "
        + "key of its own. Enter the copy's twelve words and they become your library's words, and you can set a "
        + "passphrase after; or enter its passphrase and it becomes your library's, with new twelve words offered once the "
        + "library opens. The copy itself is not changed."
    /// The receipt after the landing: §7c (9)'s own first sentence — nothing stepped aside, so nothing more to say.
    static let makeMineEmptySlotReceipt = "This is your library now."
    /// The copies list with no library open (the missing face's and rule 27's *Restore from Backup…* on the new road):
    /// `restoreListLead`'s own sentence without its step-aside clause (no library is open to step aside).
    static let emptySlotRestoreListLead = "Look inside a copy to read it without changing anything, or make it your library."
    /// Nothing in Variorum's own folders on this device (VX-210's line, beneath when copies stand elsewhere, says the rest).
    static let noCopiesOnThisMac = "Variorum isn't keeping any copies on this \(ProtectionCopy.deviceName)."

    // MARK: - VX-309 U1b — T-8, a plain-text copy brought in as a new library (P-VX309-U1b-3's lines, re-drafted at VX-309
    // U2's words pass in §7c's voice — PROVISIONAL P-VX309-U2-10)

    /// The picked plain-text copy's door — §7c (8)'s shape: what it becomes; what comes in and what does not, in ONE line
    /// (the ruling, §5b-R: content and its placement ride, configuration does not — and the document format carries no
    /// commits or comments, versions never ride); with a library open, where that one goes (§7c (8)'s own clause). VX-309
    /// ladder round 1, F-R2: the line names gatherings (configuration — ruling item 6) and entry dates (the format carries
    /// no date: a brought-in note is minted with none) among what doesn't come in.
    static func bringInLead(stepsALibraryAside: Bool) -> String {
        "This plain-text copy becomes a new library \u{2014} in Standard, with a fresh key of its own; its new twelve "
            + "words are offered once it opens. Its notes and their takes, books, chapters, snippets and tags come in, "
            + "written fresh; "
            + "its gatherings, entry dates, commits, comments, note versions, book settings, stars and shelves don't."
            + (stepsALibraryAside
                ? " Your current library steps aside whole into Previous Libraries, where you can look inside it or make "
                    + "it your library again."
                : "")
            + " The copy itself is not changed."
    }
    static let bringInButton = "Bring it in"
    static let bringInWorking = "Bringing the copy in\u{2026}"
    /// The export's schema is an earlier build's (this build reads its own only — PROVISIONAL P-VX309-U1b-7) — said in the
    /// newer build's refusal's own shape (`LibraryOpenCopy.newerSchemaRefusal`).
    static let exportFromAnEarlierBuild = "This plain-text copy was written by an earlier Variorum than this one, which "
        + "can't bring it in."
    /// A note the document format could not read back (never expected — the export's own projection), named. It refuses
    /// at the preflight, before anything moves.
    static func exportNoteUnreadable(_ title: String, line: Int?) -> String {
        "The note \u{201C}\(title)\u{201D} couldn't be read from this copy" + (line.map { " (line \($0))" } ?? "")
            + ", so nothing was brought in."
    }
    /// What landed (the ruling's requirement: a partial landing is visible against it) — §7c (9)'s receipt in its own
    /// shape: this is your library now, what it was made of, and — when one stepped aside — where the previous one is.
    static func bringInReceipt(_ landing: PlaintextExportLanding, stoppedEarly: Bool, steppedAside: Bool) -> String {
        func count(_ n: Int, _ one: String, _ many: String) -> String { "\(n) \(n == 1 ? one : many)" }
        var parts = [count(landing.books, "book", "books"), count(landing.notes, "note", "notes"),
                     count(landing.snippets, "snippet group", "snippet groups")]
        if landing.wings > 0 { parts.append(count(landing.wings, "wing", "wings")) }
        var text = "This is your library now, made from the plain-text copy: " + parts.joined(separator: " \u{00B7} ") + "."
        if !landing.emptyBooks.isEmpty {
            text += " Empty books were left out: " + landing.emptyBooks.joined(separator: ", ") + "."
        }
        if steppedAside { text += " The previous one is in Previous Libraries." }
        if stoppedEarly {
            text += " It stopped part of the way \u{2014} the copy is unchanged and can be brought in again."
        }
        return text
    }

    // MARK: - VX-309 U1c — VX-265's delete and VX-210's line (P-VX309-U1c-1's lines, read at VX-309 U2's words pass:
    // the door, title, button, working line and failure stand as drafted; the lead's opening, the receipt and VX-210's line
    // re-drafted — PROVISIONAL P-VX309-U2-10)

    /// A row's door (the brief's *Delete…*): one other library's copies.
    static let deleteCopiesDoor = "Delete\u{2026}"
    static let deleteCopiesTitle = "Delete this library's copies?"
    static let deleteCopiesButton = "Delete copies"
    static let deleteCopiesWorking = "Deleting the copies\u{2026}"
    /// What goes, counted — VX-309 U2 — VX-264 ITEM 5: HER WORDS (QUESTIONS #216, VX-203's ruled wording, verbatim:
    /// *"That's 27 backups, plus 2 older libraries Variorum kept when you opened or restored a different one."* — "set-aside"
    /// leaves every user-facing sentence), fitted to ONE library's copies: the backups, the copies she picked and opened here
    /// (the doors' filed copies), then her clause for the libraries that stepped aside (PROVISIONAL where fitting changed a
    /// word — the singular, the opened copies' phrase).
    static func deleteCopiesCounts(_ choice: CopyDeleteChoice) -> String {
        func count(_ n: Int, _ one: String, _ many: String) -> String? {
            n == 0 ? nil : "\(n) \(n == 1 ? one : many)"
        }
        let plain = [
            count(choice.backups, "backup", "backups"),
            count(choice.openedCopies, "copy you opened here", "copies you opened here"),
        ].compactMap { $0 }
        let older = count(
            choice.previousLibraries, "older library Variorum kept when you opened or restored a different one",
            "older libraries Variorum kept when you opened or restored a different one")
        switch (plain.count, older) {
        case (0, nil): return "That's nothing."
        case (0, let older?): return "That's \(older)."
        case (1, nil): return "That's \(plain[0])."
        case (_, nil): return "That's " + plain.dropLast().joined(separator: ", ") + " and \(plain[plain.count - 1])."
        case (_, let older?): return "That's " + plain.joined(separator: ", ") + ", plus \(older)."
        }
    }
    /// HER WAY-BACK SENTENCE (#216, verbatim: *"Those older libraries are your way back to what you had before — delete
    /// them only if you won't want them back."*), said where an older library is among what goes (the singular fitted —
    /// PROVISIONAL).
    static func deleteCopiesWayBack(_ olderLibraries: Int) -> String? {
        switch olderLibraries {
        case 0: return nil
        case 1: return "That older library is your way back to what you had before \u{2014} delete it only if you won't "
            + "want it back."
        default: return "Those older libraries are your way back to what you had before \u{2014} delete them only if "
            + "you won't want them back."
        }
    }
    /// The confirm's lead (rule 19: one library's copies, never silently): the library named by its day as the listing
    /// knows it, what goes counted in her words (item 5), her way-back sentence over an older library, what stays said, and
    /// that nothing else is touched.
    static func deleteCopiesLead(_ choice: CopyDeleteChoice, libraryOpen: Bool) -> String {
        let day = choice.newest.map { ProtectionWords.day($0) } ?? offerUnknownDay
        var text = "This deletes this \(ProtectionCopy.deviceName)'s copies of the library last copied \(day). "
            + deleteCopiesCounts(choice) + " They can't be brought back."
        if let wayBack = deleteCopiesWayBack(choice.previousLibraries) { text += " " + wayBack }
        // VX-309 ladder round 1, F-R1 (PROVISIONAL P-VX309-R1-1): what stays may be a far copy outside any Mac's subfolder,
        // whose maker is not knowable — the reviewer's "can't vouch for" clause keeps the sentence true of it.
        if choice.staying > 0 {
            let unvouched = "or that this \(ProtectionCopy.deviceName) can't vouch for"
            text += choice.staying == 1
                ? " One copy another Mac made, \(unvouched), stays."
                : " \(choice.staying) copies another Mac made, \(unvouched), stay."
        }
        text += libraryOpen ? " Your library isn't touched." : ""
        return text
    }
    /// The receipt naming what went.
    static func deleteCopiesReceipt(_ count: Int) -> String {
        count == 1 ? "Deleted 1 copy of another library from this \(ProtectionCopy.deviceName)."
            : "Deleted \(count) copies of another library from this \(ProtectionCopy.deviceName)."
    }
    static let deleteCopiesFailed = "Variorum couldn't delete those copies just now. Nothing more was deleted."
    /// VX-210 — her words: "if we have a line about 'this doesn't handle backups elsewhere', I don't think we need to do
    /// more." The listing's ONE honest line (rule 25's idiom), rendered only when such copies exist (P-2). VX-309 ladder
    /// round 1, F-R1 (PROVISIONAL P-VX309-R1-1): the line also counts another library's far copy no container twin
    /// vouches for — which sits INSIDE a folder Variorum writes — so its second clause keeps the line true of it (and of a
    /// far copy outside any Mac's subfolder, the count's older arm).
    static let copiesElsewhereLine = "Copies outside the folders Variorum keeps \u{2014} older backups, or a folder you "
        + "made \u{2014} are left as they are, and so are copies in your second folder that this "
        + "\(ProtectionCopy.deviceName) can't vouch for as its own. They're yours to manage in the Finder."

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
    /// P-VX306-U1a-3's road: a keychain that could not be listed stops the facts — the typed field, and why. (The device
    /// by the platform's noun — the phone's lobby says it too; P-VX329-PH-1, the Mac's text byte-unchanged.)
    static let keychainUnreadable = "Variorum couldn't check this \(ProtectionCopy.deviceName)'s keychain just now. Enter "
        + "your passphrase or your twelve words."

    // MARK: - The lobby's refusals (a typed attempt that opened nothing)

    static let passphraseDoesNotOpen = "That passphrase doesn't open this library."
    static let wordsDoNotOpen = "Those twelve words don't open this library."
    /// VX-464 (W-VX309-3) — the join's and Move's typed secret is the ACCOUNT's (rule 14: checked against the account's
    /// vault), so its refusal names the account; "this library" stays where the typed pair is the library's own (the
    /// lobby, Make this my library, set-up, the follow — rule 7). PROVISIONAL P-VX329-R1-1.
    static let passphraseDoesNotOpenAccount = "That passphrase doesn't open this account."
    static let wordsDoNotOpenAccount = "Those twelve words don't open this account."
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
    /// VX-469 (c) — her ruling at the 2026-10-22 sitting (QUESTIONS #237): Castle's promise is about LIVE libraries, so
    /// entering it leaves the quiet roads of the libraries in Previous Libraries on this Mac standing — said at the door,
    /// in the warning idiom of the backups sentence (rule 25's), on every confirm that says what entering does. Words
    /// PROVISIONAL P-VX329-R1-2.
    static let castleLeavesPreviousLibraries = "The libraries in Previous Libraries keep their own quiet roads on this "
        + "\(ProtectionCopy.deviceName) \u{2014} Castle protects the library you have open."
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
    /// VX-529 — VX-113's twin for the twelve words: words that still open this library but were replaced on another
    /// device (`ExecutorRefusal.wordsChangedElsewhere`). PROVISIONAL (P-VX529-3's class — drafted, her wordings pass).
    static func wordsChangedElsewhere(device: String?, day: String?) -> String {
        switch (device, day) {
        case let (device?, day?): return "Your twelve words were changed on \(device) on \(day)."
        case let (device?, nil): return "Your twelve words were changed on \(device)."
        case let (nil, day?): return "Your twelve words were changed on \(day)."
        case (nil, nil): return "Your twelve words were changed on another device."
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
    /// restore go; a concealed type, cleared at lock and at quit): the caption says the road's rule (PROVISIONAL
    /// P-VX308-U3-2; today's own sentence, `ProtectionCopy.wordsCopied`, left with today's road at VX-329 U1).
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
    /// VX-308 U2 — Move's one arm with no one-door face: the signed-in account has NO vault (moving there is a leave and a
    /// set-up, two acts — the core's `move` joins an account that already syncs; the one-door compose is VX-455, post-release
    /// at her word). VX-309 U2 — HER RULING (2026-10-19, "reword that line to name the road"): the line names the road, as
    /// the faces stand — This Mac Only renders only while signed out (`assess` refuses it with another account signed in),
    /// so the road is Sign out, Use this Mac only, sign back in to that account, Turn on sync (rule 16's leave, then rule
    /// 7's hand-up: the library's pair becomes that account's). PROVISIONAL P-VX309-U2-4 (the brief's two presses fitted to
    /// the sign-out the faces need).
    static let moveNotYet = "To move this library to that account, sign out, choose Use this "
        + "\(ProtectionCopy.deviceName) only, then sign back in to that account and turn on sync. This library's "
        + "passphrase and twelve words become that account's."

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
    /// THE WORDS MOMENT when the PASSPHRASE was the secret typed (P-VX378-U2-3 (a) — the words were replaced, and nothing
    /// here can show them). VX-309 U2 — HER REFINED DRAFT (the VX-308 handoff sitting, QUESTIONS #236), verbatim-faithful:
    /// the library ADOPTS the account's words, the account NAMED BY ITS EMAIL. The middle clause keeps its SENTENCE and
    /// drops only its conditional lead-in ("If this is your first time signing in, …") — her note's own reading (the
    /// F-U2-1 arbitration): with VX-456 the moment fires only on a real replacement, so the previous-words fact "applies
    /// unconditionally" — it is said plainly, un-hedged, exactly when it is true. PROVISIONAL (her bundle carries both
    /// texts beside her note). `email`: the account signed in at the join (nil, not known — "your account's", P-VX309-U2-2).
    static func joinWordsNotShown(_ email: String?) -> String {
        "Your twelve words are \(email.map { "\($0)'s" } ?? "your account's") twelve words. Your previous twelve words "
            + "still open backups you made before today. If you don't have your account's words written down, you can "
            + "make new ones at any time."
    }
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
        // VX-529 unit 1 (F-1): the core's third kind folds into the existing sentence so this compiles — no sentence
        // minted here; UNIT 2 (the faces) gives it the run record's drafted pair sentence.
        case .keysReplaced, .pairChanged: return "Your account's keys changed \(at)."
        }
    }
    /// What following asks — rule 10's "each typing a secret once" (and rule 15's catch-up); rule 12's "quietly" out.
    static func followAsk(_ kind: FollowKind) -> String {
        switch kind {
        case .intoCastle: return "Type your passphrase or your twelve words once to follow it here."
        // VX-529 unit 1 (F-1): the third kind folds in so this compiles — UNIT 2 words its own ask.
        case .keysReplaced, .pairChanged: return "Type your passphrase or your twelve words once to catch up."
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
        // VX-529 unit 1 (F-1): the third kind folds in so this compiles — UNIT 2 words its own Done.
        case .keysReplaced, .pairChanged:
            return "Your account's keys changed on another device, and this \(ProtectionCopy.deviceName) caught up."
        }
    }
    /// VX-309 U2 — VX-457 (her "I agree with B"): the Done above stands in the account section as a durable notice until
    /// this one button (the export notice's idiom — `exportNoticeOK`).
    static let followDoneOK = "OK"
    /// VX-529 unit 2 (scope 5, R-529-3) — a key door's refusal while the account's PAIR changed elsewhere: what changed (the
    /// follow's own notice — the half, the device, the day), then the road. PROVISIONAL (P-VX529-3's class).
    static func followFirstToCatchUp(_ kind: FollowKind, device: String?, day: String?) -> String {
        followNotice(kind, device: device, day: day) + " " + followFirstToCatchUpRoad
    }
    /// PROVISIONAL (P-VX529-3's class).
    static let followFirstToCatchUpRoad = "Follow your account to catch this \(ProtectionCopy.deviceName) up first."

    // MARK: - VX-510 — THE ACT'S FIRST ROUND (VX-507) AND THE JOIN'S DOOR (VX-506)
    //
    // PROVISIONAL, HERS — the run record's OPEN ITEMS (`notes/plans/fixes/vx-510-first-run-sync.md`), the first draft of
    // each built: P-VX510-1 (the sheet's first round), P-VX510-3 (a) (the join arm's door). The held line is the
    // implementer's fitting of the shipped hold idiom to a sheet over Settings (PROVISIONAL P-VX510-A1, the record's
    // LIVE STATUS).

    /// P-VX510-1 — the first round running (the sheet stays; Done is open throughout).
    static let firstRoundProgress = "Syncing your library with your account\u{2026}"
    static let firstRoundCloseNote = "You can close this \u{2014} sync keeps going, and the bar at the bottom of the "
        + "window says when it's done."
    /// P-VX510-1 — the round came back clean: the set-up handed the library up; a join (or Move) brought the account in.
    static let firstRoundSetUpLanded = "Synced. Your library is on your account now."
    static let firstRoundJoinLanded = "Synced. Your account's writing is in this library now."
    /// VX-510 D-B0 — the FOLLOW's clean first round, beside its durable Done (VX-457). PROVISIONAL P-VX510-B1-1, the
    /// implementer's draft (unit B1's record), hers to reword.
    static let firstRoundFollowLanded = "Synced. This library is up to date with your account again."
    /// P-VX510-1 — what blocks it, in the sync row's own sentence.
    static func firstRoundBlocked(_ rowSentence: String) -> String { "Sync hasn't run yet: \(rowSentence)." }
    /// P-VX510-A1 — held: the row's held refusal (`LibraryOpenCopy.syncNowHeldRefusal` — "…in the banner below") said from
    /// a sheet over Settings, so the banner is the main window's (the hold copy's own idiom, `restoreHoldRefusal`).
    static let firstRoundHeld = "Sync is waiting since the restore \u{2014} press Resume Sync in the main window's banner"
    /// The round phase's one door.
    static let firstRoundDone = "Done"
    /// P-VX510-3 (a) — Settings ▸ Protection's door over the JOIN arm (the account already syncs); the set-up arm keeps
    /// `turnOnSyncDoor`.
    static let joinSyncDoor = "Sync this library\u{2026}"

    // MARK: - VX-510 D-B7 — THE READ-ONLY CHECK (VX-513, her R-510-15)
    //
    // The door's name is the design's own (D-B7, the run record). Every other line here is PROVISIONAL P-VX510-B3-1 — the
    // implementer's draft (the record's unit B3), in the lobby's refusal idiom ("That passphrase doesn't open this library."),
    // sentence case, hers to reword. The "doesn't open" lines are the lobby's own (`passphraseDoesNotOpen`, `wordsDoNotOpen`);
    // the account's "couldn't be checked" reasons are the pane's (`doorRefusedSignedOut`, `doorRefusedOtherAccount`,
    // `doorRefusedNeedsVault`); a passphrase changed elsewhere is VX-113's (`passphraseChangedElsewhere`).

    /// Settings ▸ Protection's door, beside the key doors (D-B7's label).
    static let checkSecretsDoor = "Check my passphrase or twelve words\u{2026}"
    static let checkSecretsTitle = "Check my passphrase or twelve words"
    static let checkSecretsLead = "Type your passphrase or your twelve words to check them. Checking changes nothing."
    static let checkSecretsField = "Passphrase or twelve words"
    static let checkSecretsButton = "Check"
    static let checkSecretsWorking = "Checking\u{2026}"
    static let checkSecretsClose = "Close"
    /// They open the library (it doesn't sync — or its account could not be checked, said beneath).
    static func checkSecretsOpensLibrary(_ kind: SecretCheckOutcome.Kind) -> String {
        kind == .words ? "Those twelve words open this library." : "That passphrase opens this library."
    }
    /// They open the library and its account (rules 7, 14 — synced, the pair is the account's).
    static func checkSecretsOpensLibraryAndAccount(_ kind: SecretCheckOutcome.Kind) -> String {
        kind == .words
            ? "Those twelve words open this library and your account."
            : "That passphrase opens this library and your account."
    }
    /// The honest split: the library's, not the account's (changed elsewhere — VX-113's class).
    static func checkSecretsOpensLibraryNotAccount(_ kind: SecretCheckOutcome.Kind) -> String {
        kind == .words
            ? "Those twelve words open this library, but not your account."
            : "That passphrase opens this library, but not your account."
    }
    /// The account's, not this library's (PROVISIONAL P-VX510-B3-2 — the arm the design's three did not name).
    static func checkSecretsOpensAccountNotLibrary(_ kind: SecretCheckOutcome.Kind) -> String {
        kind == .words
            ? "Those twelve words don't open this library, but they open your account."
            : "That passphrase doesn't open this library, but it opens your account."
    }

    // MARK: - VX-308 U3 — THE KEY DOORS, VX-447, F-U2-3 (rules 2, 3, 6, 7, 27; the plan's §5c)
    //
    // VX-263's ONE line is the plan's (§2's ledger and §5c: *your current secrets open everything you've made of this
    // library* — rule 6's "the doors say so in one sentence"), the first letter capitalized and the period added;
    // `RoadKeyDoorWordsTests` reads the plan file and pins it as drafted. Her U2-7 (1) first sentence is reused, never
    // restated (the prefix of `noKeyFileAfterAQuietOpen`, pinned). Every other line here is PROVISIONAL P-VX308-U3-2 —
    // drafted from the rules' own words, sentence case, hers at the bundle.

    /// VX-263's one line — every key door says it (rule 6: "the doors say so in one sentence"). VX-309 U2: the route
    /// finder's ONE sentence as `notes/CastleRules.md` rewords it (the considered-and-not-pursued ledger — *your current
    /// passphrase or words; on this Mac, its quiet road if it still holds that key*), fitted to a sentence the key doors and
    /// the words section say (PROVISIONAL P-VX309-U2-6); it supersedes the VX-308 plan's draft (*your current secrets open
    /// everything you've made of this library*).
    static let keyDoorsLine = "Every copy of this library opens with your current passphrase or words; on this "
        + "\(ProtectionCopy.deviceName), its quiet road opens it too, if it still holds that copy's key."
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

    // MARK: - VX-309 U2 — THE FIELD GUIDE'S PROTECTION CHAPTER ON THE NEW ROAD (VX-379's acceptance; #235: "written here")
    //
    // Seeded on every store (VX-329: every store opens on the new road; copy §7's chapter went with today's road). Lesson 1 LEADS
    // with the readme's four Start Here passages, verbatim (`ReadmeSeeder.startHerePassages` — one text, two homes; the
    // seeder prepends them). Every paragraph here is drafted from `notes/CastleRules.md` and the lifecycle page as built —
    // her sentences verbatim where they exist (rule 9's promise, rule 12's leave sentence, rule 17's), PROVISIONAL
    // P-VX309-U2-8 the rest. The truth-check and the real store's re-seed ride VX-329's release.

    /// Lesson 1 (after the Start Here passages): what sync seals and what it can't (VX-204's approved sentences — the
    /// seeder adds `ProtectionCopy.privacyServerSeesShapeSentence` and `keystoneAccountPassword`, her approved words), and
    /// what an open library is.
    static let guideKeyLessonTitle = "Your key and your twelve words"
    static let guideSyncSentence = "Sync is end-to-end encrypted: your writing and everything you name \u{2014} titles, "
        + "tags, books \u{2014} are encrypted on your device before they leave, and the Variorum server can never read them."
    static let guideOpenMeansReadable = "And one thing no setting changes: while Variorum is open, everything in it is "
        + "readable \u{2014} that is what open means. In Castle, locking it \u{2014} Lock Library Now, or time away "
        + "\u{2014} is how you end that."

    /// Lesson 2 — one posture at a time (rules 8–13).
    static let guidePosturesLessonTitle = "Standard and Castle"
    static let guidePosturesLesson: [String] = [
        "Your library is in one of two postures, and only one at a time. Standard is the convenience: besides your "
            + "passphrase and your twelve words, Variorum keeps quiet roads to your key \u{2014} through your iCloud "
            + "Keychain and this \(ProtectionCopy.deviceName)'s login \u{2014} so most days you type nothing. If one stops "
            + "working, the next open uses whichever still works and quietly makes a fresh one; it asks for your passphrase "
            + "or words only when none is left.",
        castlePromise + " \(ProtectionCopy.biometryName) on this \(ProtectionCopy.deviceName) is optional; with Always "
            + "ask, no copy of the key stays here and you type every time.",
        "Entering Castle asks for your passphrase and your twelve words, gives your library a new key, and deletes its "
            + "Apple and on-device keychain items \u{2014} so your backups come into Castle with it. Leaving asks for both "
            + "again and hands everything back to Standard, and the leave screen says it plainly: " + leaveSentence,
        "With sync on, Castle is your whole account's: when one device enters, each of your other devices follows by "
            + "typing your passphrase or your twelve words once.",
        "What you must keep: your twelve words and your passphrase. Either one opens your library and every backup of "
            + "it, and either one can reset the other. In Standard the quiet roads mean you rarely type them \u{2014} keep "
            + "them anyway; in Castle they, and \(ProtectionCopy.biometryName) on this \(ProtectionCopy.deviceName) if you "
            + "chose it, are the only way in. A library whose every key file and every backup are gone is gone; a synced "
            + "library comes back from your account with your twelve words.",
        "Wherever you set a passphrase, it must be at least \(ProtectionCopy.passphraseFloor) characters \u{2014} it is "
            + "the one secret a stolen copy of the server could be guessed against \u{2014} and a quiet line beside the "
            + "field says when a longer phrase would be stronger. A passphrase you already have keeps working whatever its "
            + "length.",
    ]

    /// Lesson 3 — the copies as this phase built them (rules 5, 17–19; VX-309 U1a–U1c).
    static let guideCopiesLessonTitle = "Copies, backups and your way back"
    static let guideCopiesLesson: [String] = [
        "A backup is your library plus its key file \u{2014} a pair, written together and never rewritten. Once a day "
            + "while Variorum is open, a pair lands beside your library; if you picked a second folder in Settings "
            + "\u{25B8} Data Safety, a pair lands there too, once a day. Each place keeps this \(ProtectionCopy.deviceName)'s "
            + "pairs of this library: beside it, the newest 14; in your folder, the 14 most recent days that have one, "
            + "plus one from each of the 4 weeks before those.",
        dataSafetyWhatOpensABackup,
        "Settings \u{25B8} Data Safety \u{25B8} Restore from Backup lists the copies on this "
            + "\(ProtectionCopy.deviceName). Look inside opens one read-only: nothing is written, and closing it forgets "
            + "it. Make this my library turns a copy into a new library, with a fresh key of its own, in the posture "
            + "you're in now and under your current passphrase and twelve words \u{2014} and your current library steps "
            + "aside whole into Previous Libraries, where you can look inside it or bring it back the same way. "
            + neverLeaveCastle + " A library made this way doesn't sync until you turn on sync for it.",
        "Copies of other libraries on this \(ProtectionCopy.deviceName) are listed too \u{2014} an older library Variorum "
            + "kept when you opened or restored a different one, or a copy you opened here \u{2014} and each library's "
            + "copies can be deleted, one library at a time. " + copiesElsewhereLine,
        "Your writing can always leave as plain text: File \u{25B8} Export Library\u{2026} writes every note as Markdown, "
            + "and Settings \u{25B8} Data Safety can write an unencrypted copy of the whole library. An unencrypted copy "
            + "comes back in through File \u{25B8} Open Library\u{2026} as a new library \u{2014} its notes and their "
            + "takes, books, chapters, snippets and tags written fresh; its gatherings, entry dates, commits, comments, "
            + "note versions, book settings, stars and shelves stay behind.",
    ]

    /// The export lesson's two backup paragraphs on the new road (the seeder interpolates the pane's own names after the
    /// second's lead, exactly as today's do): a backup is a PAIR, and the second folder takes one a day (P-VX309-U1a-2).
    static let guideBackupsHappen = "Backups happen on their own. Once a day while Variorum is open, it writes a pair "
        + "\u{2014} your library and its key file \u{2014} into a backups folder right beside the library, on this "
        + "\(ProtectionCopy.deviceName). No button, nothing to remember. Those copies survive a mistake; they don\u{2019}t "
        + "survive losing the \(ProtectionCopy.deviceName)."
    static let guideSecondFolderLead = "So you can add a second folder of your own choosing (iCloud Drive, an external "
        + "drive, any folder your cloud service syncs) and a pair lands there too, once a day:"

    // MARK: - VX-309 U2 — DATA SAFETY ON THE NEW ROAD (F-U2c-4; F-U1a-3) — PROVISIONAL P-VX309-U2-9

    /// F-U2c-4 — RULE 5's sentence for the pane (the copies section; today's posture lines left with today's road): what opens a
    /// backup, with VX-263's quiet-road clause.
    static let dataSafetyWhatOpensABackup = "A backup is your library plus its key file. It opens with the passphrase and "
        + "twelve words you had when you made it, with your current ones too, or \u{2014} on this "
        + "\(ProtectionCopy.deviceName) \u{2014} by its quiet road while it still holds that backup's key."
    /// F-U1a-3 — what the counts are on the new road (VX-397: this Mac's pairs of this library).
    static let dataSafetyTheCountsAreThisMacs = "The counts are this \(ProtectionCopy.deviceName)'s copies of this "
        + "library, each a pair: the library and its key file."
    /// F-U1a-3 — the picked folder's caption on the new road (P-VX309-U1a-2: one pair a day there).
    static let dataSafetySecondFolderKept = "Kept there: the 14 most recent days that have a copy, plus one copy from "
        + "each of the 4 weeks before those. One copy a day goes there \u{2014} a second Back Up Now on the same day adds "
        + "one beside your library only."

    // MARK: - The route's failures (the failure face, with Try Again)

    static let couldNotCreate = "Variorum couldn't create your library."
    /// (The device by the platform's noun — the phone's failure face says it too; P-VX329-PH-1, the Mac's text
    /// byte-unchanged.)
    static let keychainUnreadableNoLibrary = "Variorum couldn't check this \(ProtectionCopy.deviceName)'s keychain, so it "
        + "didn't create a library. Try again."
    /// A hosted test run (the test host IS the dev-store app) never writes the dev scope — it never creates.
    static let testRunNeverCreates = "A test run never creates a library."
}
