//
//  PostureCopy.swift
//  Variorum (shared: Mac + Mobile — the posture era's strings)
//
//  pre-13x batch 2a — every sentence here is RENDERED from
//  `notes/plans/pre-13x-copy.md` (§1 the Protection pane · §2d the waiting
//  state · §5 the nudge · §6 Backups · §9 her migration's one-time
//  messages), verbatim; the device nouns ride the standing interpolation
//  (`Mac` / `iPhone`, `Touch ID` / `Face ID`, `login password` /
//  `passcode`). The FACTS in every line are the design's (§2–§8); 13s
//  re-voices later. Render, don't re-derive.
//

import Foundation

nonisolated extension ProtectionCopy {
    // MARK: - The four keystone lines (verbatim everywhere they appear)

    static let keystoneOneMode =
        "Your library is encrypted on disk, and sync is end-to-end encrypted. The "
        + "Variorum server can never read your writing — in either mode. The only "
        + "difference is who holds a key."
    static let keystoneUnlockedDevice =
        "An unlocked, enrolled device is as powerful as your passphrase. "
        + "\(biometryName) guards this device — your passphrase is what lets a new "
        + "device in."
    static let keystoneAccountPassword =
        "Your account password signs you in and can delete your account. It never "
        + "touches your keys."
    static let keystoneOpenMeansReadable =
        "While Variorum is open and unlocked, everything in it is readable — that is "
        + "what open means. Locking is how you end that."

    // MARK: - §1 Settings ▸ Protection — the posture chooser

    static let protectionPaneTitle = "Protection"

    static func postureName(_ posture: Posture) -> String {
        switch posture {
        case .standard: return "Standard"
        case .castle: return "Castle"
        }
    }

    static func postureTag(_ posture: Posture) -> String {
        switch posture {
        case .standard: return "the default"
        case .castle: return "only you"
        }
    }

    /// The current-state line (top, always).
    static func currentStateLine(_ posture: Posture) -> String {
        switch posture {
        case .standard: return "You're in Standard. Your Apple account holds a key."
        case .castle: return "You're in Castle. Only you hold the keys."
        }
    }

    /// The card's one line.
    static func postureOneLine(_ posture: Posture) -> String {
        switch posture {
        case .standard:
            return "Your Apple account holds a key. Nothing to remember day to day."
        case .castle:
            return "Only you hold the keys. Your \(deviceName)'s \(credentialName) can't "
                + "open your library."
        }
    }

    /// The cards' facts, in the copy's order: (label, sentence).
    static func postureCard(_ posture: Posture) -> [(label: String, text: String)] {
        switch posture {
        case .standard:
            return [
                ("Who holds a key",
                 "your Apple account — iCloud Keychain, and Apple's ways of recovering "
                 + "it (your device passcode, a recovery contact, a recovery key). That "
                 + "key lives in iCloud Keychain: it travels with your Apple account to "
                 + "every device signed into it, and Apple's account recovery can reach "
                 + "it."),
                ("Opening", "silently, on any device signed into your iCloud."),
                ("A new device",
                 "sign into iCloud, sign into Variorum, and everything is there. "
                 + "Nothing typed."),
                ("Who it stops",
                 "the Variorum server — yes. Someone at your unlocked \(deviceName) — "
                 + "no: anyone who can open Variorum as you can read your writing, and "
                 + "can set a new passphrase. Someone fully in your Apple account — no."),
                ("If your \(deviceName) dies",
                 "with sync on, sign in on a new \(deviceName) and it all comes back. "
                 + "Without sync, your Apple account holds a key but not your writing — "
                 + "you need a copy of your library that survived the \(deviceName) "
                 + "(your backup folder in iCloud Drive, or Time Machine)."),
                ("The floor",
                 "you lose your writing only if you lose every Apple device, every way "
                 + "Apple offers to recover your account, AND your passphrase and twelve "
                 + "words. Keep the words: they are your way back if your Apple account "
                 + "is ever gone."),
            ]
        case .castle:
            return [
                ("Who holds a key",
                 "only you — your passphrase, your twelve words, and your enrolled "
                 + "devices behind \(biometryName). With \(biometryName) on, this "
                 + "\(deviceName)'s security chip holds a copy of the key. It is "
                 + "released only to your fingerprint — never to your \(credentialName), "
                 + "never to iCloud — and it never leaves this \(deviceName). Turn on "
                 + "Always ask, and no copy exists anywhere."),
                ("Opening",
                 "\(biometryName), with your passphrase as the fallback — or your "
                 + "passphrase every time, if you choose."),
                ("A new device",
                 "sign into Variorum and type your passphrase or your twelve words, "
                 + "once."),
                ("Who it stops",
                 "the Variorum server — yes. Your \(deviceName)'s \(credentialName) — "
                 + "yes: nothing on this \(deviceName) releases the key to it. Someone "
                 + "in your Apple account — yes. Someone holding your passphrase, your "
                 + "twelve words, or a fingerprint enrolled on your \(deviceName) — no."),
                ("If your \(deviceName) dies",
                 "with sync on, sign in and type your passphrase. Without sync, a "
                 + "surviving backup plus your passphrase or twelve words."),
                ("The floor",
                 "lose every enrolled device AND both your passphrase and your twelve "
                 + "words, and your writing is gone. Nobody can help — not Apple, not "
                 + "us. That is the point of Castle, and it's why we ask you to write "
                 + "the words down."),
            ]
        }
    }

    /// The choose buttons (the ellipsis: a ceremony follows). The DOORS
    /// themselves are batch 2b's; the words live here so both halves
    /// render one vocabulary.
    static let useStandardDoor = "Use Standard"
    static let useCastleDoor = "Use Castle…"

    // Castle's switches (shown only in Castle).
    static let alwaysAskLabel = "Always ask for the passphrase"
    static let alwaysAskSentence =
        "Skip \(biometryName) and type your passphrase every time Variorum opens. "
        + "Choose this if other people's fingerprints are enrolled on your "
        + "\(deviceName)."
    /// The enrolled-finger line (copy §5, under the switch).
    static let enrolledFingerLine =
        "Any fingerprint enrolled on your \(deviceName) account can unlock with "
        + "\(biometryName) — \(biometryName) guards the \(deviceName), not the person."
    static let alwaysAskNoCopyLine =
        "With this on, no copy of the key is kept on this \(deviceName) at all."

    static let idleLabel = "Lock after time away"
    static let idleSentence = "Lock your library after you haven't used Variorum for:"
    static func idleChoiceLabel(_ minutes: Int?) -> String {
        guard let minutes else { return "never" }
        return "\(minutes) minutes"
    }
    static let idleSubline =
        "Switching to another app doesn't lock it; time away does. Variorum always "
        + "locks when your \(deviceName) sleeps or its screen locks."

    // MARK: - §2d The new device joining — Standard, waiting for iCloud Keychain

    static let waitingTitle = "Getting your key from iCloud Keychain…"
    static let waitingBody =
        "This usually takes a moment and can take longer. You can also enter your "
        + "passphrase or twelve words instead."
    static let waitingPassphraseDoor = "Enter Passphrase…"
    static let waitingWordsDoor = "Enter Twelve Words…"
    /// Rendered when iCloud Keychain holds an Apple key that is NOT the
    /// one this library's key file was written under.
    static let waitingDifferentAppleID =
        "This \(deviceName)'s Apple account isn't the one that set up sync, so it "
        + "can't hand over the key. Enter your passphrase or twelve words once; "
        + "after that this \(deviceName) opens on its own."

    // MARK: - §6 Settings ▸ Backups

    static let backupsStandardSentence =
        "A backup opens through your Apple account — or with your passphrase or "
        + "twelve words."
    static let backupsCastleSentence =
        "A backup opens with your twelve words — always, unless you regenerated "
        + "them — or with the passphrase you had when it was made. Backups made "
        + "while you were in Standard also open through your Apple account. Backups "
        + "run while your library is open."
    static let backupsLockTimeCopyLine =
        "When you lock, Variorum also keeps a sealed copy of the library as it was "
        + "— checked the next time you unlock."

    // MARK: - §9 Her migration's one-time messages (Mac + phone, once each)

    /// pre-13x 2b item (0) — the CORRECTED sentence (the 2a adjudication's
    /// ruling 1): the sync keys live in this device's own protected
    /// Keychain beside the library's key — NEVER in the library file (the
    /// design's §3.3; the phrase `e499f5ca` corrected everywhere else).
    static let migrationConfirmBody =
        "Variorum now keeps your sync keys in this \(deviceName)'s own protected "
        + "Keychain, beside your library's key — never in the library file — and "
        + "your account is in Castle. Nothing else changed. Confirm your passphrase "
        + "once to finish."
    static let migrationConfirmDoor = "Confirm…"
    static let migrationLaterDoor = "Later"
    static let migrationDoneBody =
        "Done. This device opens with \(biometryName); your passphrase and twelve "
        + "words are your other ways in."
}

// MARK: - pre-13x 2b — the two switches' ceremonies (copy §2b · §2c · §4's
// still-finishing line), rendered VERBATIM; the device nouns interpolated.

nonisolated extension ProtectionCopy {
    // §2b Screen 1 — what changes
    static let enterCastleTitle = "Castle: only you hold the keys."
    static let enterCastleBody =
        "Your library gets a new key, and so does your sync. From now on your "
        + "\(deviceName)'s \(credentialName) can't open it, and your Apple account "
        + "holds no key to it. Opening takes \(biometryName) or your passphrase."
    static let enterCastleBullets: [String] = [
        "Your other devices will start asking too — Touch ID or Face ID, with your "
        + "passphrase as the fallback — and each gives its own library a new key the "
        + "same way. Each will ask for your passphrase once, to pick up your new sync keys.",
        "Backups made before today — Variorum's own, Time Machine, copies you made — "
        + "still open through your Apple account. Delete them, Time Machine included, "
        + "if you want Castle to cover everything you have ever written. Keep them if "
        + "you want a way back to what you wrote before today, should you ever lose "
        + "your passphrase and twelve words.",
        "If you think someone may already hold your keys — your Apple account, or an "
        + "unlocked device of yours together with your account password — also delete "
        + "your Stargazing account and set sync up again. That gives your sync fresh keys.",
    ]
    static let enterCastleContinue = "Continue"

    // §2b Screen 2 — the passphrase (2a's Screen 2 under this title)
    static let castleNeedsPassphraseTitle = "Castle needs a passphrase."
    static let passphraseFieldLabel = "Passphrase"
    static let passphraseConfirmLabel = "Confirm passphrase"
    static let passphraseSubline =
        "At least 12 characters. Four or more random words work well. This is the one "
        + "thing a stolen copy of the server could be guessed against, so make it long."
    static let passphraseTooShort = "Your passphrase needs at least 12 characters."
    static let passphraseMismatch = "The two entries don't match."
    static let passphraseAlreadyOnAccount =
        "Your library already has a passphrase — sync uses the same one. Type it here."
    static let passphraseNotTheLibrarys =
        "That isn't your library's passphrase. Check it under Settings ▸ Protection "
        + "if you're unsure."

    // §2b Screen 3 — the twelve words (2a's Screens 3 / 3b)
    static let wordsExistTitle = "Your library already has twelve words."
    static let wordsExistBody =
        "Type them to use the same twelve for sync, or generate new ones — the new "
        + "ones replace the old everywhere."
    static let wordsTypeMineDoor = "Type My Words…"
    static let wordsGenerateNewDoor = "Generate New Ones"
    static let wordsWriteDownTitle = "Write down your twelve words."
    static let wordsWriteDownBody =
        "These twelve words open your account and your library exactly as your "
        + "passphrase does. Write them on paper and keep the paper somewhere real. "
        + "They are shown once."
    static let wordsCopyAll = "Copy All"
    static let wordsCopied = "Copied. Your clipboard clears in 60 seconds."
    static let wordsWrittenDoor = "I've written them down"
    static let wordsConfirmTitle = "Type your twelve words to confirm."
    static let wordsConfirmBody = "This proves the paper is right before anything depends on it."
    static let wordsConfirmDoor = "Confirm"
    static let wordsMismatch =
        "That's not quite the phrase — one of the twelve words is off. Compare it "
        + "with what you wrote down."

    // §2b Screen 4 — the floor, said once
    static let floorTitle = "Read this once."
    static let floorBody =
        "In Castle, nobody can help you if you forget your passphrase and lose your "
        + "twelve words while no enrolled device is left. Not Apple. Not us. There is "
        + "no reset. That is what makes Castle real — and it's why the words go on paper."
    static let floorCheckbox = "I know my passphrase, and my twelve words are written down."
    static let enterCastleDoor = "Enter Castle"

    // §2b During / the notice / Done / the offer
    static func reencryptingLine(done: Int, total: Int) -> String {
        "Re-encrypting your library on the server… (\(done) of \(total))"
    }
    static let rekeyingLibraryLine = "Giving your library a new key…"
    static let insuranceTurnedOffNotice =
        "Your weekly unencrypted Markdown export is now off — it would have kept "
        + "writing readable copies of your library to disk. You can turn it back on "
        + "in Backups; Castle will warn you there."
    static let enteredCastleDone =
        "You're in Castle. Your library has a new key that your Apple account never "
        + "held. A fresh backup was made under it. This \(deviceName) asks for "
        + "\(biometryName) from now on; your other devices will ask the next time they open."
    static let deleteOldBackupsTitle = "Delete the backups Variorum made before today?"
    static let deleteOldBackupsBody =
        "They still open through your Apple account, and they always will. Deleting "
        + "them closes that door for what they hold. Variorum can only delete its own "
        + "backups — Time Machine, copies you made, and anything outside Variorum's "
        + "folders aren't touched and still open the old way. If your backups are in "
        + "iCloud Drive, iCloud keeps deleted files for 30 days in Recently Deleted."
    static let deleteOldBackupsDoor = "Delete Them"
    static let keepOldBackupsDoor = "Keep Them"

    // §2c Leaving Castle
    static let leaveCastleTitle = "Back to Standard?"
    static let leaveCastleBody =
        "Your Apple account will hold a key to your library again. Anyone fully in "
        + "your Apple account, or at your unlocked \(deviceName), can then read your "
        + "writing. Your other devices will open silently again the next time they open."
    static let leaveCastleDoor = "Use Standard"

    // §4 — still finishing (decision 32), at either door
    static func rotationStillFinishing(device: String, day: String) -> String {
        "A key replacement started on \(device) on \(day) is still finishing. Any "
        + "signed-in device that has picked up the new keys can finish it. Try again after."
    }
    /// The resume door's word (a switch that crashed mid-road on this device).
    static let finishEnteringCastleDoor = "Finish Entering Castle…"
    static let finishReplacingKeysDoor = "Finish Replacing Keys…"
    static let resumeBody =
        "Entering Castle didn't finish on this \(deviceName) — sync is paused until it "
        + "completes. Nothing is lost; finishing picks up exactly where it stopped."
    static let resumeNeedsPassphrase = "Enter your passphrase to finish."
}

// MARK: - pre-13x 2c — THE FOLLOW'S NOTICES (copy §5, verbatim; the device
// nouns interpolated; *[device] on [day]* from the vault's
// `updated_by_device` + `updated_at`) and copy §3's keys-don't-match line.

nonisolated extension ProtectionCopy {
    /// ISO-8601 stamp → "Sep 5, 2026"; nil in ⇒ the honest fallback.
    static func day(from stamp: String?) -> String {
        guard let stamp, stamp.count >= 10 else { return "an earlier day" }
        let parser = DateFormatter()
        parser.locale = Locale(identifier: "en_US_POSIX")
        parser.dateFormat = "yyyy-MM-dd"
        guard let day = parser.date(from: String(stamp.prefix(10))) else { return String(stamp.prefix(10)) }
        let display = DateFormatter()
        display.dateStyle = .medium
        display.timeStyle = .none
        return display.string(from: day)
    }

    /// The device word when the vault carries no name (a pre-2c writer).
    static let anotherDevice = "another device"

    // Account moved to Castle (a device that was Standard)
    static func followMovedToCastle(device: String, day: String) -> String {
        "Your account is now in Castle — set on \(device) on \(day). From now on this "
        + "\(deviceName) asks for \(biometryName) to open your library, with your passphrase as "
        + "the fallback. Enter your passphrase once to pick up your new sync keys: they were "
        + "replaced when Castle was entered, and only your passphrase or twelve words open them."
    }
    // Account in Castle, this device still opens the old way (the
    // posture-mismatch follow, decision 35 — no keys were replaced; 2d.4,
    // the orchestrator's ruling 1: its OWN sentence, copy §5)
    static var followCastleStillOpensOldWay: String {
        "Your account is in Castle, but this \(deviceName) still opens without asking. Enter your "
        + "passphrase once to move this \(deviceName)'s key behind \(biometryName) and give your "
        + "library a fresh key."
    }
    static var followCastleStillOpensLaterSubline: String {
        "Until then this \(deviceName) opens and reads as before."
    }
    // Keys replaced elsewhere (a device that has not followed yet)
    static func followKeysReplaced(device: String, day: String) -> String {
        "Your keys were replaced on \(device) on \(day). Enter your passphrase once to pick up the new ones."
    }
    static let followEnterDoor = "Enter Passphrase…"
    static let followWordsDoor = "Use Twelve Words…"
    static let followLaterDoor = "Later"
    static let followLaterSubline = "Until then this \(deviceName) opens and reads, but doesn't sync."
    // Waiting for your passphrase (the persistent banner)
    static func followWaiting(device: String, day: String) -> String {
        "Sync is paused until you enter your passphrase once — your keys were replaced on "
        + "\(device) on \(day)."
    }
    static let followWaitingDoor = "Enter…"
    /// On every key door meanwhile.
    static let pickUpKeysFirst = "Pick up your new keys first — enter your passphrase."
    // Account moved to Standard (a device that was Castle)
    static func followMovedToStandard(device: String, day: String) -> String {
        "Your account is back in Standard — set on \(device) on \(day). This \(deviceName) "
        + "opens silently again; your Apple account holds a key."
    }
    static let followMovedToStandardDoor = "OK"
    // The Always-ask variant (decision 10's exception)
    static func alwaysAskRetiredWord(device: String, day: String) -> String {
        "Your passphrase was changed on \(device) on \(day). The old one still opens this "
        + "\(deviceName), but sync waits until you enter the new one here."
    }
    static let enterItNowDoor = "Enter It Now…"
    // Copy §3 — after unlock, keys don't match the account (a different owner)
    static let keysDontMatchThisLibrary =
        "This account's keys don't match this library. Enter your passphrase to connect it — "
        + "everything in it will upload to this account."
    /// The Connect door is batch 3's (P-2: not rendered until it acts).
    static let connectDoor = "Connect…"
    static let followDoneBody =
        "Your new keys are in place on this \(deviceName), and sync is back on."
}
