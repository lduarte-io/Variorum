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
