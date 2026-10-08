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
    /// pre-13x ladder round 1, F2 (MAJOR-3 d) — HEDGED, PROVISIONAL (copy
    /// §2d + §11; 13s re-voices): the client cannot tell a different Apple
    /// account from the same account under propagation lag (no iCloud
    /// identity is stored), so the sentence covers both.
    static let waitingDifferentAppleID =
        "This \(deviceName)'s Apple account doesn't hold the key that set up sync — "
        + "if it's the same Apple account, the key may still be arriving. Enter your "
        + "passphrase or twelve words once to continue now; after that this "
        + "\(deviceName) opens on its own."

    // MARK: - §2a Turning on sync (pre-13x 3a, verbatim)

    /// Copy §4: signed in, no sync yet.
    static let syncNotSetUpLine = "Sync isn't set up on this account."
    static let turnOnSyncDoor = "Turn On Sync…"
    // Screen 1 — what sync needs
    static let setupNeedsTitle = "Sync needs two things you keep."
    static let setupNeedsBody =
        "Sync is end-to-end encrypted: the Variorum server stores your writing in a form it can't "
        + "read. To make that true, your account needs a passphrase and twelve words that only you have."
    static let setupNeedsBullets: [String] = [
        "Your passphrase lets a new device into your sync.",
        "Your twelve words do the same, and are your way back if you forget the passphrase.",
    ]
    static let setupStandardAddendum =
        "You're in Standard, so day to day your Apple account handles this for you and you won't type "
        + "either one. Keep them anyway: if your Apple account is ever gone, they are the only way back "
        + "to your writing."
    static let setupCastleAddendum =
        "You're in Castle, so these two are the only ways into your writing besides your enrolled "
        + "devices. Nobody can reset them — not Apple, not us."
    static let setupContinue = "Continue"
    // Screen 2 — the passphrase (the field labels, sub-line and refusals are §2b's, shared)
    static let setupPassphraseTitle = "Choose your encryption passphrase."
    // Screen 4 — done
    static let setupDoneStandard =
        "Sync is on. Your Apple account holds a key, so your other Apple devices will join with nothing "
        + "typed. Your passphrase and twelve words are your way back if your Apple account is ever gone."
    static let setupDoneCastle =
        "Sync is on. Your other devices will ask for your passphrase or twelve words, once. Nothing "
        + "else opens your writing."
    static let setupDoneDoor = "Done"
    // If this library once synced under another account (before Screen 1)
    static let setupMoveSentence =
        "This library last synced under a different account. Turning on sync here moves it to this "
        + "account and uploads everything in it. Your other account isn't changed."
    static let setupMoveDoor = "Move It to This Account"

    // MARK: - §2d The new device joining — Castle (pre-13x 3a, verbatim)

    static let joinCastleTitle = "Enter your passphrase to join sync."
    static let joinWordsDoor = "Use my twelve words instead."
    /// Castle, and this library was in Standard (one sentence under the title).
    static let joinCastleRekeysSentence =
        "This account is in Castle, so this library gets a new key as it joins. Everything you wrote here stays."
    /// A Castle-born library joining a STANDARD account (decision 1 + corner
    /// 6 — consent at enrollment).
    ///
    /// **RUN A batch A2, row 10 — her ruling on QUESTIONS #90 (4), ledger
    /// 46, 2026-09-07:** *"good that it asks for consent, it should direct
    /// you to cancel, go put the standard account in castle mode and then
    /// rejoin if you don't want to leave castle."* The old sentence named
    /// the Castle door without saying it is the ACCOUNT that has to move,
    /// or in what order. PROVISIONAL; 13s re-voices (QUESTIONS #138).
    static let joinStandardConsent =
        "This account is in Standard, so this library will open silently from now on and your Apple "
        + "account will hold a key to it. If you'd rather not leave Castle: Cancel here, put the "
        + "ACCOUNT in Castle from a device already signed into it (Settings ▸ Protection ▸ Use "
        + "Castle…), then join again."
    static let joinDoor = "Join"
    static let joinCancelDoor = "Cancel"
    /// After Cancel: the library stays unenrolled and Castle-shaped; one
    /// door re-offers the consent (a reading — the copy file has no line).
    static let joinLaterLine = "Sync isn't joined on this \(deviceName)."
    static let joinReofferDoor = "Join This Account's Sync…"

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
    static let iCloudOfferUseDoor = "Use iCloud Drive"
    static let iCloudOfferChooseDoor = "Choose Another Folder…"
    static let iCloudOfferNotNowDoor = "Not Now"
    /// A cancelled picker (iCloud Drive not there, or the user backed out):
    /// the offer stays open; nothing changed — a chrome line the copy file
    /// has no sentence for (listed in copy §11 for 13s; the 5b record's
    /// QUESTIONS).
    static let iCloudOfferNoFolderPicked = "No folder was chosen, so nothing changed."
    /// Copy §6's why-not sentence — the FAQ's entry and, when 13x builds the
    /// picker's refusal of the live library's own folder (ledger 4), that
    /// refusal's words. A constant so the sentence has ONE home; rendered
    /// by no surface of this phase (recorded).
    static let liveLibraryNotInICloudDrive =
        "Your working library stays on this \(deviceName). iCloud Drive syncs files while "
        + "they're being written, which can corrupt a live database — backups are complete, "
        + "sealed copies, which is what a synced folder is good at. To have your writing on "
        + "every device, use sync."

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
    /// **RUN A batch A2, row 12 (17l item 6 — her observation).** Between
    /// the vault write and the first pulled window there is nothing to
    /// count, and the line said *(0 of 0)*, which reads like a corpus of
    /// nothing rather than a walk about to start. The gate is THE FIRST
    /// WINDOW, never "done is zero": `done == 0` is the honest count all
    /// through the first window, while `total == 0` means no window has
    /// reported yet. PROVISIONAL wording; 13s re-voices (QUESTIONS #138).
    static func reencryptingLine(done: Int, total: Int) -> String {
        guard total > 0 else { return "Re-encrypting your library on the server… (preparing)" }
        return "Re-encrypting your library on the server… (\(done) of \(total))"
    }

    /// **The ceremony/follow sheets' RUNNING LINE — one brain (row 12).**
    /// Four sheets (two Mac, two phone) carried byte-identical switches
    /// over the runner's phase, differing in exactly one arm, so row 12's
    /// fix would have had to be made four times to be true anywhere. The
    /// one arm that differs is kept as the parameter it always was: a
    /// CEREMONY mints the new keys, a FOLLOW picks up keys another device
    /// minted.
    static func runningLine(
        for phase: PostureSwitchRunner.Phase, minting: Bool
    ) -> String {
        switch phase {
        case .reencrypting(let done, let total):
            return reencryptingLine(done: done, total: total)
        case .rekeyingLibrary, .movingCustody, .snapshotting:
            return rekeyingLibraryLine
        case .rotatingKeys:
            return minting ? "Minting your new keys…" : "Picking up your new keys…"
        case .pullingToHead:
            return "Catching up with the server…"
        case .idle, .done:
            return "Working…"
        }
    }
    static let rekeyingLibraryLine = "Giving your library a new key…"
    /// **RUN A batch A2, row 13 (QUESTIONS #90 (11), MINOR-N4 (2)):** the
    /// tail on a ceremony that failed after *Generate New Ones* — the
    /// twelve words she has just written down never landed anywhere, and
    /// the failure sentence alone left her holding a set that opens
    /// nothing without saying so. The ruled ledger-61 family's shape ("the
    /// words ARE NOT …, the real ones are …"). PROVISIONAL; 13s re-voices
    /// (QUESTIONS #138).
    static let freshWordsNeverLanded =
        "The twelve words you just wrote down are NOT in use: nothing changed, and your "
        + "existing twelve words still open your account."
    static let insuranceTurnedOffNotice =
        "Your weekly unencrypted Markdown export is now off — it would have kept "
        + "writing readable copies of your library to disk. You can turn it back on "
        + "in Backups; Castle will warn you there."
    static let enteredCastleDone =
        "You're in Castle. Your library has a new key that your Apple account never "
        + "held. A fresh backup was made under it. This \(deviceName) asks for "
        + "\(biometryName) from now on; your other devices will ask the next time they open."
    /// pre-13x ladder round 1, F2 (MAJOR-2) — PROVISIONAL (copy §2b; §11;
    /// 13s re-voices): the Done when step 6's fresh snapshot could NOT be
    /// written — the ordinary line's "A fresh backup was made under it"
    /// would be untrue, and no offer is made over the earlier backups.
    /// F3 (the F2 adjudication's copy follow-up 1): the ordinary Done's
    /// Touch ID / other-devices tail RESTORED — it states a fact the user
    /// needs on every Castle Done (copy §2b, PROVISIONAL; 13s re-voices).
    static let enteredCastleWithoutFreshBackup =
        "You're in Castle. A fresh backup could not be made just now — check your "
        + "Backups folder; your earlier backups are untouched. This \(deviceName) asks for "
        + "\(biometryName) from now on; your other devices will ask the next time they open."
    /// F3 (the F2 adjudication's copy follow-up 2 — a condition-(vii)
    /// defect F2 found): the Done on a device that KEEPS NO BACKUPS (the
    /// phone — `FreshSnapshot.notKept`): the ordinary Done WITHOUT its
    /// backup sentence, which was untrue there (copy §2b, PROVISIONAL;
    /// 13s re-voices).
    static let enteredCastleWithoutBackupClaim =
        "You're in Castle. Your library has a new key that your Apple account never "
        + "held. This \(deviceName) asks for \(biometryName) from now on; your other "
        + "devices will ask the next time they open."
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

    /// pre-13x ladder round 1, F2 (MAJOR-3 b) — PROVISIONAL (copy §4 + §11;
    /// 13s re-voices): Replace All Keys under Standard refused because the
    /// iCloud key the vault's copy is under is not readable here (or the
    /// one read is another Apple account's) — decision 30 never re-mints it.
    /// F3 (the F2 adjudication's copy follow-up 3): RE-DRAFTED — the door
    /// already takes the passphrase, so "or enter your passphrase" pointed
    /// at no door, and waiting cannot help a different Apple ID's device
    /// (copy §4's re-draft, PROVISIONAL; 13s re-voices). Rendered at the
    /// DOOR since F3's MINOR-N4 (and by the runner's step-2 belt).
    static let replaceKeysAppleKeyUnreachable =
        "Your Apple account's key isn't reachable on this \(deviceName). If this "
        + "\(deviceName) is signed into the Apple account that set up sync, wait a "
        + "moment and try again; if it isn't, run Replace All Keys from "
        + "\(deviceNameWithArticle) that is."

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
    /// pre-13x ladder round 1, F1 (BLOCKER-1) — PROVISIONAL (copy §11): the
    /// server refused to clear the previous corpus key three times because a
    /// row written just before the switch was still hidden from this
    /// device's pulls; nothing is lost, the marker stays, the resume door
    /// re-walks. 13s re-voices.
    static let rotationRowsStillSettling =
        "The server is still settling a few rows written just before the switch. Nothing is lost — "
        + "sync stays paused; finish from Settings ▸ Protection in a moment, and it picks up exactly where it stopped."

    // MARK: - RUN A batch A3 (17m) — THE RE-LINK YOUR APPLE ACCOUNT DOOR
    //
    // Her ruling on QUESTIONS #90's item 10 (2026-09-07 ~02:05): *"I think we
    // do need a re-link your apple account door."* What it closes is MINOR-N1:
    // the heal fires only on a key READ (F3's option A — a mint proves
    // nothing), so after an iCloud Keychain RESET, or the establishing device
    // signing into another Apple ID, the account's Apple-held copy is ORPHANED
    // under a key nobody reads any more and new Apple devices lose Standard's
    // nothing-typed enroll. Standard only: in Castle no copy is owed.
    //
    // THE REGISTER (the copy file's head): Settings is an EVERYDAY surface, so
    // these sentences name no key by its technical name — *your Apple account ·
    // your account's key · your passphrase · your twelve words · sync*. The
    // Encryption book's Chapter 2 is where "the iCloud key" and "the master
    // key" are named, and it carries this door's sentence there.
    //
    // Every sentence here is PROVISIONAL; 13s re-voices (QUESTIONS #139).

    static let relinkSectionTitle = "Your Apple account"
    static let relinkDoor = "Re-link Your Apple Account…"
    static let relinkExplainer =
        "In Standard your Apple account holds a key, and that is what lets your other "
        + "Apple devices join your sync with nothing typed. If you reset iCloud Keychain, "
        + "or the Apple account that set sync up isn't the one on this \(deviceName) any "
        + "more, the key on file stops matching: your writing is safe and sync keeps "
        + "running, but a new device has to enter your passphrase or twelve words. "
        + "Re-linking puts the key your Apple account holds NOW on file instead."
    static let relinkTitle = "Re-link your Apple account"
    /// THE CONSENT SENTENCE — it names WHICH Apple account will hold the key.
    /// The client stores no iCloud-account identity (the MAJOR-3 REFINED
    /// paragraph: no identity is kept, and the ubiquity token needs an
    /// entitlement the app does not carry), so the only honest naming is *the
    /// Apple account signed into this device* plus the key it hands back —
    /// which is exactly what tells a different-Apple-ID device's door apart
    /// from the account on file.
    static func relinkConsent(appleKeyID: String) -> String {
        "From now on your account's key is held by the Apple account signed into this "
        + "\(deviceName) (the key it holds: \(shortAppleKeyID(appleKeyID))). Every device "
        + "signed into that same Apple account then joins your sync with nothing typed — "
        + "and so could anyone with full access to it. Nothing you have written changes, "
        + "and your passphrase and twelve words keep working exactly as they do now."
    }
    /// The second line when the account currently has a DIFFERENT key on file
    /// — what stops working the moment this lands (decision 30's honesty).
    static func relinkReplaces(recordedKeyID: String) -> String {
        "The key on file now (\(shortAppleKeyID(recordedKeyID))) stops opening your "
        + "account: a device that was joining through it asks for your passphrase or "
        + "twelve words instead. Copies and backups you already have are untouched."
    }
    /// The same door pressed when the key on file is already this Apple
    /// account's — it still acts (the write is the same key, re-landed), and
    /// says so rather than pretending something changed.
    static let relinkAlreadyThisAccount =
        "The key on file is already the one this \(deviceName)'s Apple account holds. "
        + "Re-linking writes that same key again and changes nothing."
    static let relinkAuthorizeLine = "Type your encryption passphrase to confirm."
    static let relinkConfirmDoor = "Re-link"
    /// The refusal when iCloud Keychain hands this \(deviceName) NO key at
    /// all: there is nothing to re-link to. **NIT-N8's WAITING vocabulary,
    /// reused whole rather than a sibling sentence** — and its second half is
    /// true here in its own right: while the account's key is orphaned, the
    /// passphrase and the twelve words ARE how a device joins. Refused AT THE
    /// DOOR, before any screen (MINOR-N4 (1)'s pattern).
    static let relinkAppleKeyUnreadable = waitingTitle + " " + waitingBody
    /// The key read at the act is not the key the consent named — consent was
    /// given for an account, so another key is not consented to.
    static let relinkAppleKeyChanged =
        "The key your Apple account holds changed while this was open, so nothing was "
        + "written. Open this door again to see what it holds now."
    /// The vault write did not land (offline; the keys not in hand here; the
    /// server refusing while a key replacement is still finishing). The road
    /// answers landed-or-not, so the sentence names what is true either way.
    static let relinkWriteRefused =
        "Your account's key couldn't be updated just now, and nothing was changed. This "
        + "needs to be online with your keys on this \(deviceName) — try again in a moment."
    static let relinkDone =
        "The Apple account signed into this \(deviceName) now holds your account's key. "
        + "Devices signed into it join your sync with nothing typed; your passphrase and "
        + "your twelve words are unchanged."
    /// A key id, shortened for a sentence (the log convention's eight).
    static func shortAppleKeyID(_ id: String) -> String {
        id.count > 8 ? String(id.prefix(8)) + "…" : id
    }
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
        "Until then this \(deviceName) opens and reads as before — what you write meanwhile "
        + "stays under the old key until you enter your passphrase."
    }
    /// 13x F1 (ladder R1-BLOCKER; words PROVISIONAL, 13s re-voices — the
    /// FACTS binding: the live key file holds an Apple-account wrap from
    /// before Castle; the follow mints a fresh key and retires that file).
    /// W-3: the cause is NOT always a restore — a Mac whose key file
    /// predates the account's Castle entry lands here on its own (her Pro,
    /// 2026-10-08), so the sentence states the fact and never a cause.
    static var followCastleKeyFileAppleOpenable: String {
        "Your account is in Castle, but this library's key file still holds a copy "
        + "under your Apple account from before Castle. Enter your passphrase once to "
        + "give your library a fresh key and retire that copy."
    }
    // Keys replaced elsewhere (a device that has not followed yet)
    static func followKeysReplaced(device: String, day: String) -> String {
        "Your keys were replaced on \(device) on \(day). Enter your passphrase once to pick up the new ones."
    }
    static let followEnterDoor = "Enter Passphrase…"
    /// **RUN A batch A2, row 10 — her ruling on QUESTIONS #90 (2), ledger 54,
    /// 2026-09-07 ~02:05: *"Pick Up New Keys is fine as a choice"*.** When
    /// the word was just typed to open, the follow runs at once from the
    /// held derived key and this door asks for nothing — so it must not say
    /// *Enter Passphrase…*, which promises a field that never comes.
    static let followPickUpKeysDoor = "Pick Up New Keys"
    /// The door's ONE label brain, for both platforms and every site that
    /// renders it (`asksNothing` = the follow will run from the held key).
    static func followEnterDoorLabel(asksNothing: Bool) -> String {
        asksNothing ? followPickUpKeysDoor : followEnterDoor
    }
    static let followWordsDoor = "Use Twelve Words…"
    static let followLaterDoor = "Later"
    /// pre-13x 4a (ledger 50(b), her ruling 2026-09-06): the sub-line names
    /// what happens to writing made after *Later* — it sits under the OLD
    /// library key until the follow (Apple-openable on a Standard-shaped
    /// device). Copy §5 as precised, verbatim.
    static let followLaterSubline =
        "Until then this \(deviceName) opens and reads, but doesn't sync — and what you write "
        + "meanwhile stays under the old key until you pick up the new ones."
    // Waiting for your passphrase (the persistent banner)
    static func followWaiting(device: String, day: String) -> String {
        "Sync is paused until you enter your passphrase once — your keys were replaced on "
        + "\(device) on \(day)."
    }
    static let followWaitingDoor = "Enter…"
    /// On every key door meanwhile.
    static let pickUpKeysFirst = "Pick up your new keys first — enter your passphrase."
    /// 13x F1 (ladder R1-M1 — P-R1-1; words PROVISIONAL, 13s re-voices):
    /// the restore hold's sentence at the two rotation ceremonies' door.
    static let resumeSyncFirst =
        "Resume sync first — this library was just restored from a copy, and sync "
        + "is waiting for your go."
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
    /// pre-13x 5b (ledger 66 — copy §4, precised 2026-09-06 at 5a's
    /// adjudication): THE UN-FOLLOWED DEVICE's headline on the Encryption
    /// tab — the account's keys were replaced elsewhere and this device has
    /// not picked them up; the one door beneath it is the FOLLOW. Copy §4's
    /// Standard addendum (*your Apple account can hand over the key*) is
    /// RETIRED and rendered nowhere: the Standard follow after Replace All
    /// Keys asks the passphrase once (her 2026-09-05 ruling).
    static let keysReplacedHeadline =
        "This account's keys changed since this \(deviceName) joined. Enter your passphrase "
        + "to pick up the new ones."
    // Copy §3 — after unlock, keys don't match the account (a different owner)
    static let keysDontMatchThisLibrary =
        "This account's keys don't match this library. Enter your passphrase to connect it — "
        + "everything in it will upload to this account."
    /// pre-13x 3a: the Connect door acts (the adopt road — decision 17).
    static let connectDoor = "Connect…"
    /// The Connect sheet's dismiss door (a plain chrome word — the copy
    /// file names only *Connect…* for this face; recorded in the 3a record).
    static let connectCancelDoor = "Cancel"
    // MARK: - pre-13x 4a — the change notices (copy §5's first two lines)

    /// Copy §5 — passphrase changed elsewhere (a dismissable banner at every
    /// open, until the new word has been used here).
    static func passphraseChangedElsewhere(device: String, day: String) -> String {
        "Your passphrase was changed on \(device) on \(day). Use the new one here when you can — "
        + "this \(deviceName) still takes the old one until you do."
    }
    /// Copy §5 — "The same for regenerated words (*Your twelve words were
    /// regenerated on [device] on [day]…*)": the tail is the passphrase
    /// line's, mirrored for the words (a reading of the copy's ellipsis —
    /// recorded; 13s re-voices).
    static func wordsRegeneratedElsewhere(device: String, day: String) -> String {
        "Your twelve words were regenerated on \(device) on \(day). Use the new ones here when you can — "
        + "this \(deviceName) still takes the old ones until you do."
    }
    /// The change notice's dismiss (copy §5 names *Enter It Now…* · dismiss;
    /// a chrome word — 13s re-voices).
    static let changeDismissDoor = "Dismiss"

    // MARK: - pre-13x 4a — the lobby's vault road (copy §3) + its chrome

    /// Copy §3 — the RETIRED passphrase (online, same account): the local
    /// copy refused, the vault refused, and the key file's recorded
    /// descriptor is no longer the vault's.
    static let lobbyRetiredPassphrase = "Your passphrase was changed on another device — enter the new one."
    /// Copy §3 — the offline note (shown small when the vault can't be
    /// reached), after a submit whose vault read failed.
    static let lobbyOfflineNote =
        "You're offline. If your passphrase was changed on another device recently, the one you had "
        + "before still works here until you're back online."
    /// The lobby's progress line per phase (chrome; 13s re-voices).
    static func lobbyPhaseLine(_ phase: StoreLobby.Phase) -> String {
        switch phase {
        case .idle, .unlocking: return "Unlocking…"
        case .checkingAccount: return "Checking your account…"
        }
    }

    static let followDoneBody =
        "Your new keys are in place on this \(deviceName), and sync is back on."
    /// pre-13x 4a — Connect's done line (copy §3, drafted at 3a's adjudication;
    /// the Connect kind rendered `followDoneBody` until now).
    static let connectDoneBody =
        "This library is connected to this account, and everything in it is uploading now."
}

// MARK: - pre-13x 5a — THE TUTORIAL'S SHORT CHAPTER (copy §7, verbatim; the
// device nouns interpolated) + the encryption book's name. Both seeders
// render these; the spine's pins quote them (render, don't re-derive).

nonisolated extension ProtectionCopy {
    // (`encryptionBookName` — copy §7's quoted book name — retired with
    // the pointer paragraph at 13s-b U1b, R-13s-37.)

    /// Lesson 1 — What's true in every mode.
    static let privacyLessonOneTitle = "What's true in every mode"
    static let privacyLessonOneParagraphs: [String] = [
        "Your library is encrypted on disk: the file Variorum writes is unreadable without its key — "
        + "to Finder, to Terminal, to a backup drive, to anyone who copies it. Sync is end-to-end "
        + "encrypted: everything is encrypted on your device before it leaves, and the Variorum server "
        + "stores what it can never read. Both modes are like this. What differs between them is only "
        + "who holds a key.",
        keystoneAccountPassword,
        "And one thing no setting changes: while Variorum is open and unlocked, everything in it is "
        + "readable — that is what open means. Locking is how you end that.",
    ]

    /// Lesson 2 — Standard and Castle: what you must keep.
    static let privacyLessonTwoTitle = "Standard and Castle: what you must keep"
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
    /// The two floors, as the chapter states them (copy §7's parenthetical
    /// names them; the pins quote these, never a re-typed sentence).
    static let privacyStandardFloorSentence =
        "Keep: your Apple account, and — if you use sync — your passphrase and twelve words, in case "
        + "your Apple account is ever gone."
    static let privacyCastleFloorSentence =
        "Lose every enrolled device and both secrets, and your writing is gone — nobody can help."
}

// MARK: - pre-13x 5a — THE COPY RECONCILIATION's re-renders (copy §3 · §4 ·
// §2b's conflict-follow Done — ledger 61), verbatim; the device nouns
// interpolated.

nonisolated extension ProtectionCopy {
    // §3 The lobby — the roads beneath the prompt.
    /// Beneath the Touch ID / Face ID prompt: the passphrase road's word.
    static let lobbyPassphraseInsteadDoor = "Use your passphrase instead"
    /// Beneath either prompt: the twelve words' road.
    static let lobbyWordsDoor = "Use your twelve words"
    /// Touch ID failed (copy §3, the device's gate word).
    static let lobbyBiometryFailed =
        "\(biometryName) didn't go through — enter your encryption passphrase instead."

    // §4 Settings ▸ Account & Encryption — signed out.
    static let signedOutLine =
        "Sign in to sync your library across your devices. Sync is end-to-end encrypted."
    static let signInDoor = "Sign In…"

    // §2b Done, when another device entered Castle first (the conflict-follow —
    // ledger 61, PROVISIONAL; 13s re-voices): *[device]* from the vault's
    // self-reported device name, else *another device*.
    /// **RUN A batch A2, row 10 — her ruling on QUESTIONS #90 (3), ledger
    /// 61 + 67, 2026-09-07:** *"it's fine if it tells you the twelve words
    /// aren't your account's. should probably tell you why though (like look
    /// at what you just put into Castle)."* So the sentence now says WHERE
    /// the real ones came from — the words that device showed when IT
    /// entered Castle — instead of only naming the device. PROVISIONAL;
    /// 13s re-voices (QUESTIONS #138).
    static func enteredCastleAfterAnotherDevice(device: String?) -> String {
        "Another device entered Castle first, so this \(deviceName) picked up that device's keys "
        + "instead. The twelve words shown here are not your account's: your account's words are "
        + "the ones \(device ?? anotherDevice) showed when it entered Castle — those are the set "
        + "to keep."
    }

    /// ONE brain for the Castle ceremony's Done on both platforms: copy
    /// §2b's conflict-follow sentence when the runner's road became the
    /// follow (`Outcome.followedAnotherDevicesSwitch`), else the ordinary Done.
    /// F2 (MAJOR-2): a FAILED fresh snapshot renders the could-not-back-up
    /// line. F3 (F2's adjudication, item 2): `.notKept` — a device that
    /// keeps no backups, the phone — renders the ordinary Done WITHOUT its
    /// backup sentence; before F3 the phone claimed "A fresh backup was
    /// made under it" over a backup it never makes.
    static func castleDoneBody(_ outcome: PostureSwitchRunner.Outcome?) -> String {
        guard let outcome else { return enteredCastleDone }
        if outcome.followedAnotherDevicesSwitch {
            return enteredCastleAfterAnotherDevice(device: outcome.otherDeviceName)
        }
        switch outcome.freshSnapshot {
        case .failed: return enteredCastleWithoutFreshBackup
        case .notKept: return enteredCastleWithoutBackupClaim
        case .written: return enteredCastleDone
        }
    }

    // MARK: VX-99 round 2 (finding 1) — THE ONE SELECTOR over the act and the
    // outcome's road, for both platforms' ceremony faces. Before it the faces
    // asked `mode == .replaceKeys`, so a RESUME (any marker) spoke the Castle
    // ceremony: a resumed Replace All Keys was told "You're in Castle. Your
    // library has a new key that your Apple account never held" over a key
    // file the Apple account opens (decision 30's exact case), and a Replace
    // All Keys whose road became the follow into another device's switch lost
    // ledger 61's words sentence.

    /// The running screen's title, by the act (a follow's resume by the
    /// posture its marker records — the pane's door label's own rule).
    static func ceremonyRunningTitle(_ act: CeremonyAct) -> String {
        switch act {
        case .leaveCastle: return leaveCastleTitle
        case .replaceKeys: return replaceKeysTitle
        case .enterCastle: return enterCastleTitle
        case .follow(let entersCastle): return entersCastle ? enterCastleTitle : replaceKeysTitle
        }
    }

    /// The resume's passphrase screen title, by the act: copy §2b's
    /// `resumeBody` only where the act enters Castle; its PROVISIONAL
    /// sibling everywhere else.
    static func ceremonyResumeTitle(_ act: CeremonyAct) -> String {
        act.entersCastle ? resumeBody : resumeReplacingKeysBody
    }

    /// **VX-99 round 2 (finding 1) — PROVISIONAL (13s re-voices; QUESTIONS at
    /// the merge):** `resumeBody`'s sibling for a resumed Replace All Keys (or
    /// the resumed follow of one) — "Entering Castle didn't finish" is false
    /// there. The act swapped, nothing else.
    static let resumeReplacingKeysBody =
        "Replacing your keys didn't finish on this \(deviceName) — sync is paused until it "
        + "completes. Nothing is lost; finishing picks up exactly where it stopped."

    /// **VX-99 round 2 (finding 1, arm iv) — PROVISIONAL (ledger 61's family;
    /// 13s re-voices; QUESTIONS at the merge):** the conflict-follow's Done
    /// when the other device REPLACED the keys and the account did NOT enter
    /// Castle — `enteredCastleAfterAnotherDevice`'s "entered Castle first"
    /// would be false there. Ledger 61's words sentence kept (sentence case).
    static func keysReplacedAfterAnotherDevice(device: String?) -> String {
        "Another device replaced your keys first, so this \(deviceName) picked up that device's keys "
        + "instead. The twelve words shown here are not your account's: your account's words are "
        + "the ones \(device ?? anotherDevice) showed when it replaced your keys — those are the set "
        + "to keep."
    }

    /// The Done's body, by the act and the OUTCOME's road — the outcome
    /// first, because a road can end somewhere its act did not aim:
    /// 1. the road became the follow into another device's switch ⇒ ledger
    ///    61's sentence (into Castle) or its sibling (not into Castle);
    /// 2. a follow's own resume ⇒ the follow's Done;
    /// 3. the outcome entered Castle ⇒ the Castle Done by the snapshot's fate;
    /// 4. the act WAS entering Castle but the account is Standard now (finding
    ///    3, S1: another device left Castle after this device's own write) ⇒
    ///    copy §5's existing "back in Standard" line, naming that device;
    /// 5. otherwise ⇒ Replace All Keys' Done — never a Castle claim.
    /// (`.leaveCastle` never reaches a Done: its road ends at `.leftCastle`.)
    static func ceremonyDoneBody(act: CeremonyAct, outcome: PostureSwitchRunner.Outcome?) -> String {
        guard let outcome else {
            if act.isFollow { return followDoneBody }
            return act.entersCastle ? enteredCastleDone : replaceKeysDone
        }
        if outcome.followedAnotherDevicesSwitch {
            return outcome.entersCastle
                ? enteredCastleAfterAnotherDevice(device: outcome.otherDeviceName)
                : keysReplacedAfterAnotherDevice(device: outcome.otherDeviceName)
        }
        if act.isFollow { return followDoneBody }
        if outcome.entersCastle { return castleDoneBody(outcome) }
        if act == .enterCastle {
            return followMovedToStandard(
                device: outcome.otherDeviceName ?? anotherDevice, day: day(from: outcome.otherDeviceDay))
        }
        return replaceKeysDone
    }
}
