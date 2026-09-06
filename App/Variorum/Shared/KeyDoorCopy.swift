//
//  KeyDoorCopy.swift
//  Variorum (shared: Mac + Mobile — the key doors' strings)
//
//  pre-13x batch 3b — every sentence here is RENDERED from
//  `notes/plans/pre-13x-copy.md` §4 (Settings ▸ Account & Encryption: the
//  signup floor · change passphrase · regenerate twelve words · Replace All
//  Keys · sign out · sign out everywhere · delete account · the decrypted
//  export) and §5's retired-passphrase-at-a-key-door line, verbatim; the
//  device nouns ride the standing interpolation (`Mac` / `iPhone`,
//  `Touch ID` / `Face ID`). The FACTS in every line are the design's
//  (§1.10, §1.15, §1.16, §1.25, §5, decisions 30 · 33); 13s re-voices later.
//  Render, don't re-derive.
//

import Foundation

nonisolated extension ProtectionCopy {
    // MARK: - §4 The signup password floor (decision 25)

    static let signupPasswordFloorHint = "At least 12 characters."
    static let signupPasswordTooShort = "Your account password needs at least 12 characters."
    /// Rendered when the SERVER refuses (Supabase leaked-password protection —
    /// the orchestrator's setting; the client never checks a breach list).
    static let signupPasswordBreached =
        "That password has appeared in a known data breach — choose another."

    // MARK: - §4 Enrolled (the Encryption tab's line)

    static let enrolledLine =
        "Sync is on. This \(deviceName) keeps your sync keys in its own protected Keychain, "
        + "beside your library's key."

    // MARK: - §4 Change passphrase

    static let changePassphraseTitle = "Change your encryption passphrase."
    static let changePassphraseOffline =
        "Changing your passphrase updates your account's keys on the server, so it needs a connection."
    static let changePassphraseLead =
        "For when you've forgotten it or want a different one. Your devices keep syncing; the new "
        + "passphrase works on them right away when they're online, and each stops taking the old one "
        + "once you've used the new one there. Changing your passphrase isn't a security measure — if "
        + "someone else may have it, tick \"Also replace my keys\" below."
    static let currentPassphraseLabel = "Current passphrase"
    static let newPassphraseLabel = "New passphrase"
    static let confirmNewPassphraseLabel = "Confirm new"
    static let forgotCurrentPassphraseLink = "Forgot your current passphrase?"
    /// Standard's forgot road.
    static let forgotStandardBody = "This \(deviceName) holds your keys, so you can set a new passphrase now."
    static let forgotStandardDoor = "Set a New Passphrase"
    /// Castle's forgot road, Touch ID / Face ID mode.
    static let forgotCastleBiometricBody = "Confirm with \(biometryName) to set a new passphrase."
    /// Castle's forgot road, Always-ask mode (no link — the words instead).
    static let forgotUseWordsDoor = "Use your twelve words instead."
    static let alsoReplaceKeysAfterPassphrase =
        "Also replace my keys — choose this if someone may have USED the old passphrase, or had one "
        + "of your devices unlocked."
    static let changePassphraseDone =
        "Your passphrase is changed. Your other devices keep syncing and take the new passphrase right "
        + "away; each stops taking the old one once you've used the new one there."
    static let changePassphraseDoor = "Change Passphrase"

    // MARK: - §4 Regenerate twelve words

    static let regenerateWordsTitle = "New twelve words."
    static let regenerateWordsBody =
        "Your current words stop opening your account the moment the new ones are confirmed; a device "
        + "where you haven't used the new words yet still takes the old ones until you do. Write the new "
        + "ones down first."
    static let alsoReplaceKeysAfterWords =
        "Also replace my keys — choose this if someone may have USED the old words, or had one of your "
        + "devices unlocked."
    static let regenerateWordsDoor = "Regenerate Twelve Words…"
    static let regenerateWordsDone = "Your twelve words are replaced. The old ones no longer open your account."

    // MARK: - §4 Replace All Keys (decisions 30 · 32 · 33)

    static let replaceKeysTitle = "Replace all your keys."
    static let replaceKeysBody =
        "Use this if someone may have used your passphrase or twelve words, or had one of your devices "
        + "unlocked. A copy of your library or a backup holds no keys, so it is never the reason on its "
        + "own. Your sync gets a new master key and a new corpus key, everything on the server is "
        + "re-encrypted from this \(deviceName), and this library gets a new key. Your other devices "
        + "will each ask for your passphrase once, then give their own libraries new keys. Your "
        + "passphrase and twelve words stay the same unless you change them below. Old backups keep "
        + "their old keys: they still open with the passphrase you had when they were made, with your "
        + "twelve words (unless you regenerate them), and — if they were made in Standard — through your "
        + "Apple account; an enrolled device's master key no longer opens them, because that key is "
        + "replaced."
    static let replaceKeysStandardAddendum =
        "In Standard this doesn't shut out someone inside your Apple account — your Apple account holds "
        + "a key to the new keys too. For that, secure your Apple account with Apple's tools, or move to "
        + "Castle."
    static let alsoNewPassphraseCheckbox = "Also choose a new passphrase"
    /// The authorization screen's line (both postures).
    static let replaceKeysAuthorization =
        "Your passphrase typed (checked against your account's copy) and your twelve words typed or "
        + "regenerated — the new keys must be wrapped under both, and \(biometryName) can't do that. "
        + "(Forgot the passphrase? Change Passphrase first, with \(biometryName).)"
    static let replaceKeysDoor = "Replace Keys"
    static let replaceKeysOpenDoor = "Replace All Keys…"
    static let replaceKeysDone = "Done. Your other devices will ask for your passphrase the next time they open."
    /// The door's refusal when sync is not on for this library.
    static let replaceKeysNotEnrolled = "Sync isn't set up on this account."

    // MARK: - §4 Sign out · Sign out everywhere (decision 20)

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

    // MARK: - §4 Delete account (decision 16)

    static let deleteAccountTitle = "Delete your Stargazing account?"
    static let deleteAccountBody =
        "Your account, its sync copy on our server, and its keys are deleted. Nothing on this "
        + "\(deviceName) or your other devices is touched — every library stays, and still opens exactly "
        + "as it does today. You can set sync up again later under a new account; your library will "
        + "upload to it."
    static let deleteAccountReauthLine = "Enter your account password to continue."
    static let deleteAccountTypedPhrase = "DELETE MY ACCOUNT"
    static let deleteAccountTypedLine = "Type \(deleteAccountTypedPhrase) to confirm."
    static let deleteAccountDoor = "Delete Account"
    static let deleteAccountWrongPassword = "That isn't your account password — nothing was deleted."

    // MARK: - §4 Export a decrypted copy (decision 15)

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

    // MARK: - §5 A retired passphrase at a key door

    static let retiredPassphraseAtDoor =
        "That's a passphrase you've since changed. Enter the current one — or use \(biometryName), "
        + "or your twelve words."
}
