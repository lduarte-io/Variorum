//
//  ProtectionCopy.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-329 U1 — THE PROTECTION COPY THE ONE ROAD STILL SPEAKS, relocated byte-for-byte when today's copy files were
//  deleted with today's road (`StoreProtection.swift`'s `ProtectionCopy`, `PostureCopy.swift`, `KeyDoorCopy.swift` —
//  pre-13x's copy §1–§9 renders). Only the members surviving code reads moved; every sentence is unchanged (the pins
//  quote these constants). The platform's own nouns ride interpolation, both arms kept: on macOS every sentence is
//  byte-identical to the ruled text.
//
//  FLAGGED for the truth-check (the U1 record): `privacyLessonOneParagraphs` / `privacyLessonTwoParagraphs` are copy §7's
//  chapter, which only the PHONE's pocket guide still seeds (the Mac's guide seeds the protection road's chapter —
//  `ProtectionWords`' guide section); lesson 2's posture lines describe today's road. Their rewrite is hers/VM-8's,
//  never this unit's.
//

import Foundation

nonisolated enum ProtectionCopy {
    // The device words (13p Batch 2 — the mobile no-redirect sweep's
    // catch, C5's principle): these sentences are SHARED and the phone
    // renders them, so the platform's own nouns ride interpolation.
    #if os(iOS)
    static let deviceName = "iPhone"
    static let biometryName = "Face ID"
    #else
    static let deviceName = "Mac"
    static let biometryName = "Touch ID"
    #endif

    /// VX-329 U1: the sentence today's `message(for: StoreKeyEnvelopeError.wrongPassphrase)` spoke, byte-for-byte (the
    /// decrypted export's mismatch line).
    static let wrongPassphraseRefusal = "That passphrase doesn't unlock this library."

    /// VX-329 U1: the sentence today's `message(for: StoreKeyEnvelopeError.emptyPassphrase)` spoke, byte-for-byte.
    static let emptyPassphraseRefusal = "Type the passphrase first."

    /// **RUN A batch A2, row 14 (17n — her ruling 2026-09-07 ~02:30: *"we
    /// can make the encryption passphrase requirement 12 characters as
    /// well"*).** The floor, named ONCE so every SETTING door reads the
    /// same number and a new door cannot quietly ship without one. It binds
    /// where a passphrase is SET and nowhere else: an existing shorter word
    /// still opens the library at unlock, and the change door is where a
    /// longer one is asked for (17n's letter). `passphraseTooShort` is its
    /// one refusal sentence on both platforms; 13s re-voices.
    static let passphraseFloor = 12

    static let passphraseTooShort = "Your passphrase needs at least 12 characters."

    static let passphraseFieldLabel = "Passphrase"

    /// Copy §6's why-not sentence — the FAQ's entry and, when 13x builds the
    /// picker's refusal of the live library's own folder (ledger 4), that
    /// refusal's words. A constant so the sentence has ONE home; rendered
    /// by no surface of this phase (recorded).
    static let liveLibraryNotInICloudDrive =
        "Your working library stays on this \(deviceName). iCloud Drive syncs files while "
        + "they're being written, which can corrupt a live database — backups are complete, "
        + "sealed copies, which is what a synced folder is good at. To have your writing on "
        + "every device, use sync."

    /// The absent-store route's face (the postures design §3.7 — "the lock
    /// STAYS"): rendered verbatim from `pre-13x-copy.md` §3.
    static let libraryMissingTitle = "Your library file is missing."

    static let libraryMissingBody =
        "Variorum's library isn't where it was. Your lock hasn't changed."

    static let libraryMissingStartDoor = "Start a New Library"

    static let libraryMissingStartSubline = "A new library starts empty and has its own key."

    static let libraryMissingRestoreDoor = "Restore from a Backup…"

    static let libraryMissingOpenDoor = "Open an Existing Library…"

    /// pre-13x 5b (ledger 64 — decision 24; copy §6): THE iCLOUD DRIVE OFFER,
    /// once, at the first backup run — the title, the body, the addendum by
    /// posture, the three doors. The Mac only (the phone has no picked-folder
    /// road).
    static let iCloudOfferTitle = "Keep a copy of your backups in iCloud Drive?"

    static let iCloudOfferBody =
        "Variorum keeps backups beside your library, on this \(deviceName). A copy in "
        + "iCloud Drive survives the \(deviceName)."

    static let iCloudOfferStandardAddendum = "Your Apple account then holds both the key and the writing."

    static let iCloudOfferCastleAddendum = "Backups are encrypted; the copy is safe anywhere."

    /// A cancelled picker (iCloud Drive not there, or the user backed out):
    /// the offer stays open; nothing changed — a chrome line the copy file
    /// has no sentence for (listed in copy §11 for 13s; the 5b record's
    /// QUESTIONS).
    static let iCloudOfferNoFolderPicked = "No folder was chosen, so nothing changed."

    static let iCloudOfferChooseDoor = "Choose Another Folder…"

    static let iCloudOfferUseDoor = "Use iCloud Drive"

    static let iCloudOfferNotNowDoor = "Not Now"

    static let signupPasswordTooShort = "Your account password needs at least 12 characters."

    static let signupPasswordFloorHint = "At least 12 characters."

    /// Rendered when the SERVER refuses (Supabase leaked-password protection —
    /// the orchestrator's setting; the client never checks a breach list).
    static let signupPasswordBreached =
        "That password has appeared in a known data breach — choose another."

    static let signOutTitle = "Sign out of this \(deviceName)?"

    static let signOutBody =
        "This \(deviceName) stays signed out of sync until you sign in again. Your library and its keys "
        + "stay on this \(deviceName). To stop another device from syncing, use Sign Out Everywhere from "
        + "a device you trust. To give this \(deviceName) away, delete the library too."

    static let signOutDoor = "Sign Out"

    static let signOutEverywhereTitle = "Sign out everywhere?"

    static let signOutEverywhereBody =
        "Every device signed into your account is signed out, including this one. Use this if you think "
        + "someone has your account password. Then change it. Your libraries and keys on your devices "
        + "aren't touched."

    static let signOutEverywhereDoor = "Sign Out Everywhere"

    static let deleteAccountTitle = "Delete your Stargazing account?"

    static let deleteAccountBody =
        "Your account, its sync copy on our server, and its keys are deleted. Nothing on this "
        + "\(deviceName) or your other devices is touched — every library stays, and still opens exactly "
        + "as it does today. You can set sync up again later under a new account; your library will "
        + "upload to it."

    static let deleteAccountDoor = "Delete Account"

    static let deleteAccountTypedPhrase = "DELETE MY ACCOUNT"

    static let deleteAccountTypedLine = "Type \(deleteAccountTypedPhrase) to confirm."

    static let deleteAccountReauthLine = "Enter your account password to continue."

    static let deleteAccountWrongPassword = "That isn't your account password — nothing was deleted."

    static let exportPlaintextTitle = "Export an unencrypted copy of your library."

    static let exportPlaintextBody =
        "This writes your whole library as a plain, unencrypted database file, readable by anyone who "
        + "has it, anywhere you put it. Variorum never does this on its own. Choose where it goes and "
        + "treat it like the writing itself."

    static let exportPlaintextAuthorize = "Enter your passphrase."

    static let exportPlaintextChooseDoor = "Choose Where…"

    static let exportPlaintextPlainDoor = "Export"

    /// The picker's own refusal (never into the backups folder).
    static let exportPlaintextNotIntoBackups =
        "Not into Variorum's backups folder — an unencrypted copy beside the sealed ones would be "
        + "the one anything in that folder could read. Choose somewhere else."

    /// R13p-8's rider wearing Locked-down's face: enabling the scheduled
    /// plain-text export under a locked-down posture warns that it
    /// re-opens the door the encryption closed.
    /// pre-13x 2b: the CASTLE warning (§8's Backups tab — a scheduled
    /// plaintext export re-enabled under Castle shows it; the switch turns
    /// the export OFF with copy §2b's notice). VX-307 U2c (VX-379's row; U2a's
    /// F-6): in RULE 11's language — "a plain copy on disk would undo the
    /// promise; it is your call" (`notes/CastleRules.md`; U2a's notice says
    /// the same); Data Safety shows it by the OPEN library's posture (VX-329 U1:
    /// the one road). PROVISIONAL P-VX307-U2c-7.
    static let plaintextExportUnderLockedDown =
        "You're in Castle — and a scheduled plain-text copy on disk would undo "
        + "Castle's promise: every note, readable, on a timer, in the folder you "
        + "picked. It's your call."

    static let protectionPaneTitle = "Protection"

    static let keystoneOpenMeansReadable =
        "While Variorum is open and unlocked, everything in it is readable — that is "
        + "what open means. Locking is how you end that."

    static let keystoneAccountPassword =
        "Your account password signs you in and can delete your account. It never "
        + "touches your keys."

    /// VX-204 — lesson 1's honest sentence: what sync does NOT seal (the
    /// privacy brief's operator-visible envelope, in the guide's words). The
    /// pins quote this constant, never a re-typed sentence. PROVISIONAL (#215).
    static let privacyServerSeesShapeSentence =
        "What the server can see is the shape around your words: dates, how your tags nest and "
        + "which notes carry them, which notes are in which books, flags like starred or finished, "
        + "and sizes."

    /// Lesson 1 — What's true in every mode.
    static let privacyLessonOneTitle = "What's true in every mode"

    static let privacyLessonOneParagraphs: [String] = [
        // VX-204 (auditor C's C-1): "everything is encrypted… the server
        // stores what it can never read" overstated — dates, the tag tree's
        // shape, memberships, flags and sizes travel outside the encryption
        // (the operator-visible envelope the privacy brief discloses). The
        // smallest edit that makes the paragraph true: what is sealed, then
        // the one sentence naming what is not. PROVISIONAL (#215).
        "Your library is encrypted on disk: the file Variorum writes is unreadable without its key — "
        + "to Finder, to Terminal, to a backup drive, to anyone who copies it. Sync is end-to-end "
        + "encrypted: your writing and everything you name — titles, tags, books — are encrypted on "
        + "your device before they leave, and the Variorum server can never read them. "
        + privacyServerSeesShapeSentence
        + " Both modes are like this. What differs between them is only who holds a key.",
        keystoneAccountPassword,
        "And one thing no setting changes: while Variorum is open and unlocked, everything in it is "
        + "readable — that is what open means. Locking is how you end that.",
    ]

    static let privacyLessonTwoParagraphs: [String] = [
        "Standard is the default. Your Apple account holds a key. Keep: your Apple account, and — if "
        + "you use sync — your passphrase and twelve words, in case your Apple account is ever gone. "
        + "Anyone who can open Variorum as you, at your unlocked \(deviceName) or fully inside your "
        + "Apple account, can read.",
        "Castle means only you hold the keys. Keep: your passphrase and your twelve words. "
        + "\(biometryName) opens this \(deviceName) for you; your passphrase is what lets a new device "
        + "in. Lose every enrolled device and both secrets, and your writing is gone — nobody can help. "
        + "That is the point.",
        // RUN A batch A2, row 14 (17n): the floor, said ONCE in the
        // tutorial — it is a rule she meets at a door, so the chapter names
        // it rather than letting the refusal be the first she hears of it.
        "Wherever you SET that passphrase, it must be at least "
        + "\(passphraseFloor) characters — it is the one secret a stolen copy of the server could be "
        + "guessed against. A passphrase you already have keeps working whatever its length; the "
        + "change-passphrase door is where a longer one is asked for.",
        // (The chapter's fourth paragraph — the door to the seeded book
        // *Encryption Explained* "on this shelf" — RETIRED at 13s-b U1b,
        // R-13s-37 + the U3 RECORD's disposition 1: the book is neither
        // seeded nor restorable, so the sentence is false at ship. It was
        // OUTSIDE copy §7's two never-soften sentences — the floors below
        // are byte-untouched. `privacyBookDoorSentence` retired with it.)
    ]

    /// The manual lock act's word (Castle only — under Standard it would
    /// be theater, R13p-14, and the door is not rendered). Copy §1's
    /// "Lock Library Now" line, verbatim.
    static let lockNowLabel = "Lock Library Now"

    static let lockNowSentence =
        "Locking closes the library and forgets its key until you unlock it again."

    static let idleLabel = "Lock after time away"

    static let idleSentence = "Lock your library after you haven't used Variorum for:"

    static let idleSubline =
        "Switching to another app doesn't lock it; time away does. Variorum always "
        + "locks when your \(deviceName) sleeps or its screen locks."

    static func idleChoiceLabel(_ minutes: Int?) -> String {
        guard let minutes else { return "never" }
        return "\(minutes) minutes"
    }
}
