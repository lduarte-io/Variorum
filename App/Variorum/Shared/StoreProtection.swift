//
//  StoreProtection.swift
//  Variorum (shared: Mac + Mobile — the brains; the Mac's faces arrive in
//  this batch, the phone's in Batch 4, composing these same types)
//
//  Phase 13p, Batch 2 — the at-open modes (R13p-5), the presets as
//  dial-setters (R13p-7), the escrow dial's ruled copy (R13p-6 / knot 8),
//  the reminder-check and Standard-nudge policies (R13p-9 / knot 4's
//  amendment), and the honesty grammar every mode speaks in (knot 6's
//  loss-math instruction). Pure state + words: no Keychain, no store, no
//  UI — the custody acts live in `StoreKeyGuard`/`ProtectionController`,
//  and every sentence here is placeholder VOICE with honest CONTENT
//  (13s re-voices later, per the standing split).
//

import Foundation
import VariorumCore

// MARK: - The three at-open modes (R13p-5)

/// How the store key is released at open. The login password is NEVER in
/// any mode's chain (her threat model, verbatim in the plan: "a lot of
/// people have […] someone who knows their computer
/// password but might not know their passphrase").
nonisolated enum StoreAtOpenMode: String, CaseIterable, Sendable, Codable {
    /// The device Keychain releases the key silently (Batch 1's item).
    case auto
    /// A `.biometryCurrentSet`-gated Keychain item; fallback is the
    /// PASSPHRASE, never the device password — which is why picking this
    /// mode FORCES the passphrase-set screen.
    case biometric
    /// The passphrase is typed at every open; no silently-releasing
    /// custody item exists in this mode.
    case passphrase

    /// The demanded modes — the only ones where a locked lobby, a re-lock
    /// policy, or Lock Now mean anything. Under `.auto` every one of them
    /// would be theater (the key auto-releases at the next open), and
    /// R13p-14's whole point is that no theater ships.
    var isDemanded: Bool { self != .auto }
}

// MARK: - The dials (R13p-7: presets set dials; every dial stays adjustable)

nonisolated struct ProtectionDials: Equatable, Sendable {
    var mode: StoreAtOpenMode = .auto
    /// R13p-6: the iCloud Keychain escrow copy. ON in Standard, OFF in
    /// Locked-down.
    var escrowOn: Bool = true
    /// Re-lock when the Mac sleeps or the screen locks (demanded modes
    /// only — the dial's face renders only there).
    var relockOnSleepAndScreenLock: Bool = false
    /// Re-lock after this many idle minutes (nil = never; demanded only).
    var relockAfterIdleMinutes: Int?
    /// R13p-9: the periodic "do you still remember your passphrase?"
    /// check. OFF in Standard (the nudge covers the no-passphrase state),
    /// ON in Locked-down.
    var reminderChecksOn: Bool = false
}

/// The two presets (R13p-7), as PURE dial-setters — applying one is a
/// settings act plus custody choreography, both the controller's; this
/// type only answers "which dials does the preset set".
nonisolated enum ProtectionPreset: String, CaseIterable, Sendable {
    case standard
    case lockedDown

    /// `biometryAvailable` decides Locked-down's at-open demand: biometric
    /// where the hardware offers it, passphrase-every-open where not —
    /// "biometric or passphrase at open" (R13p-7's letter).
    func dials(biometryAvailable: Bool) -> ProtectionDials {
        switch self {
        case .standard:
            return ProtectionDials(
                mode: .auto, escrowOn: true,
                relockOnSleepAndScreenLock: false, relockAfterIdleMinutes: nil,
                reminderChecksOn: false)
        case .lockedDown:
            return ProtectionDials(
                mode: biometryAvailable ? .biometric : .passphrase,
                escrowOn: false,
                relockOnSleepAndScreenLock: true, relockAfterIdleMinutes: nil,
                reminderChecksOn: true)
        }
    }

    /// Which preset the current dials read as — nil when hand-adjusted
    /// dials match neither (the pane then highlights no preset; honest).
    static func matching(_ dials: ProtectionDials, biometryAvailable: Bool) -> ProtectionPreset? {
        allCases.first { $0.dials(biometryAvailable: biometryAvailable) == dials }
    }
}

// MARK: - Device-local storage (UserDefaults, per store scope)

/// The dials are DEVICE-LOCAL custody/ceremony, never document semantics:
/// they gate the store BEFORE it can be read, so they cannot live in it —
/// and they must never sync (each device's ceremony is its own; the
/// pre-sleep record: per-device store keys, per-device gates). Scoped per
/// store variant so the dev store's dials never gate her real library
/// (the A4 fence extended, exactly as Batch 1 scoped the key items).
nonisolated enum ProtectionDefaults {
    static func key(_ leaf: String, scope: String) -> String {
        "variorum.protection.\(scope).\(leaf)"
    }

    static func dials(scope: String, in defaults: UserDefaults) -> ProtectionDials {
        var dials = ProtectionDials()
        if let raw = defaults.string(forKey: key("mode", scope: scope)),
           let mode = StoreAtOpenMode(rawValue: raw) {
            dials.mode = mode
        }
        // Escrow defaults ON (Standard) — stored as the OFF flag so the
        // absent-key default reads as the preset's ON.
        dials.escrowOn = !defaults.bool(forKey: key("escrowOff", scope: scope))
        dials.relockOnSleepAndScreenLock =
            defaults.bool(forKey: key("relockOnSleep", scope: scope))
        let idle = defaults.integer(forKey: key("relockIdleMinutes", scope: scope))
        dials.relockAfterIdleMinutes = idle > 0 ? idle : nil
        dials.reminderChecksOn = defaults.bool(forKey: key("reminders", scope: scope))
        return dials
    }

    static func save(_ dials: ProtectionDials, scope: String, in defaults: UserDefaults) {
        defaults.set(dials.mode.rawValue, forKey: key("mode", scope: scope))
        defaults.set(!dials.escrowOn, forKey: key("escrowOff", scope: scope))
        defaults.set(dials.relockOnSleepAndScreenLock, forKey: key("relockOnSleep", scope: scope))
        defaults.set(dials.relockAfterIdleMinutes ?? 0, forKey: key("relockIdleMinutes", scope: scope))
        defaults.set(dials.reminderChecksOn, forKey: key("reminders", scope: scope))
    }

    // Stamps (reminder + nudge bookkeeping; device-local like the dials).

    static func date(_ leaf: String, scope: String, in defaults: UserDefaults) -> Date? {
        let value = defaults.double(forKey: key(leaf, scope: scope))
        return value > 0 ? Date(timeIntervalSince1970: value) : nil
    }

    static func setDate(_ date: Date?, _ leaf: String, scope: String, in defaults: UserDefaults) {
        defaults.set(date?.timeIntervalSince1970 ?? 0, forKey: key(leaf, scope: scope))
    }
}

// MARK: - The reminder checks (R13p-9 — the 1Password pattern)

/// When is "do you still remember your passphrase?" due? Pure so the
/// cadence has tests; the stamps live in `ProtectionDefaults`.
nonisolated enum ReminderCheckPolicy {
    /// A month between rehearsals — long enough to not nag, short enough
    /// that a forgotten passphrase surfaces while the recovery legs are
    /// still warm. PROVISIONAL (a cadence taste call; dismiss snoozes a
    /// full cadence, deliberately — a reminder that re-nags tomorrow
    /// teaches dismissal, not rehearsal).
    static let cadence: TimeInterval = 30 * 24 * 60 * 60

    /// `anchor` facts: when the passphrase was set/reset, when a check
    /// last succeeded, when the reminder was last dismissed — the NEWEST
    /// wins, and no reminder exists before a passphrase does.
    static func isDue(
        now: Date, enabled: Bool, passphraseSetAt: Date?,
        lastConfirmedAt: Date?, lastDismissedAt: Date?,
        cadence: TimeInterval = cadence
    ) -> Bool {
        guard enabled, let setAt = passphraseSetAt else { return false }
        let anchor = [setAt, lastConfirmedAt ?? .distantPast, lastDismissedAt ?? .distantPast]
            .max() ?? setAt
        return now.timeIntervalSince(anchor) >= cadence
    }
}

// MARK: - The Standard nudge (knot 4, HER AMENDMENT: the two-offer shape)

/// Standard's calm, dismissible nudge — "after real use begins rather
/// than at first launch". It offers BOTH: create a passphrase (opening
/// the set-screen, phrase displayed alongside) AND the recovery phrase
/// either way (her amendment, verbatim in the run record).
nonisolated enum StandardNudgePolicy {
    /// A day of real use before the nudge may appear (PROVISIONAL — the
    /// ruled words are "after real use begins", not a number; a day keeps
    /// the first-launch experience ceremony-free per knot 4's letter).
    static let minimumAge: TimeInterval = 24 * 60 * 60
    /// "Later" snoozes two weeks (PROVISIONAL, same class).
    static let snooze: TimeInterval = 14 * 24 * 60 * 60

    static func isEligible(
        now: Date, firstUseAt: Date?, dismissedForever: Bool,
        snoozedUntil: Date?, hasPassphraseWrap: Bool, hasRecoveryWrap: Bool
    ) -> Bool {
        guard !dismissedForever else { return false }
        // Both artifacts in hand ⇒ nothing left to offer.
        guard !(hasPassphraseWrap && hasRecoveryWrap) else { return false }
        guard let firstUseAt else { return false }
        guard now.timeIntervalSince(firstUseAt) >= minimumAge else { return false }
        if let snoozedUntil, now < snoozedUntil { return false }
        return true
    }
}

// MARK: - The honesty grammar (placeholder voice, honest content; 13s re-voices)

nonisolated enum ProtectionCopy {
    // The device words (13p Batch 2 — the mobile no-redirect sweep's
    // catch, C5's principle): these sentences are SHARED and Batch 4
    // renders them on the phone, so the platform's own nouns ride
    // interpolation. On macOS every sentence below is BYTE-IDENTICAL to
    // the ruled/pinned text (the knot-8 verbatim pin compares results in
    // the Mac target). The one "Mac" literal here carries the sweep's
    // explicit, documented exemption (its own caveat's road).
    #if os(iOS)
    static let deviceName = "iPhone"
    static let biometryName = "Face ID"
    static let credentialName = "passcode"
    #else
    static let deviceName = "Mac"
    static let biometryName = "Touch ID"
    static let credentialName = "login password"
    #endif

    // The escrow dial's ruled plain-consequence pair — knot 8, VERBATIM
    // (direction ruled; 13s may re-voice the exact words).
    static let escrowOn =
        "A copy of your key is kept in your iCloud Keychain — if you lose this "
        + "\(deviceName) and forget your passphrase, signing into iCloud on a new "
        + "device can still unlock your library."
    static let escrowOff =
        "Your key stays only on your enrolled devices. Lose them, your passphrase, "
        + "and your recovery phrase, and your writing is unrecoverable — by anyone."

    /// The no-iCloud honesty consequence (the 2026-08-30 pre-sleep record:
    /// without iCloud Keychain the dial has nothing to ride — say so,
    /// never pretend). There is no supported API that answers "is iCloud
    /// Keychain on", so the sentence is conditional and always shown with
    /// the ON dial rather than guessed at.
    static let escrowNeedsICloudKeychain =
        "This rides iCloud Keychain. If iCloud Keychain is off on this \(deviceName), "
        + "there is nothing for it to ride — the copy stays only on this "
        + "\(deviceName) until it's turned on in System Settings."

    /// Honesty about the dial's interaction with a demanded gate: the
    /// escrow copy has no biometric gate on it (Apple does not sync
    /// access-controlled items — the spike's platform fact), so on THIS
    /// Mac it is a silently-readable copy beside the gate.
    static let escrowUnderDemandedMode =
        "Note: the iCloud copy has no fingerprint gate on it — someone using this "
        + "\(deviceName) as you could recover the key from iCloud Keychain without "
        + "passing the lock. Locked-down turns it off for exactly that reason."

    // What each mode does and does not protect (knot 6's non-scary-but-
    // serious instruction, per mode).

    static func modeSentence(_ mode: StoreAtOpenMode) -> String {
        switch mode {
        case .auto:
            return "Your library is encrypted on disk, and this \(deviceName)'s "
                + "Keychain opens it silently when Variorum opens. This protects the "
                + "disk — a stolen drive, a copied file — but anyone who can use this "
                + "\(deviceName) as you can open Variorum and read."
        case .biometric:
            return "Variorum asks for your fingerprint or face every time it opens, "
                + "and when it locks. Your \(deviceName)'s \(credentialName) can NOT "
                + "open it. If biometrics fail, the fallback is your encryption "
                + "passphrase — which is why this mode requires one."
        case .passphrase:
            return "Variorum asks for your encryption passphrase every time it opens, "
                + "and when it locks. Nothing opens it silently — not the Keychain, "
                + "not your login password."
        }
    }

    /// The per-mode loss math (knot 6, her example carried verbatim into
    /// the demanded modes' sentence: "forgetting the passphrase without
    /// the phrase written down IS enough").
    static func lossMath(_ mode: StoreAtOpenMode, escrowOn: Bool) -> String {
        switch mode {
        case .auto:
            var legs = ["this \(deviceName) (its Keychain holds the key)",
                        "your encryption passphrase (if you set one)",
                        "your recovery phrase (if you saved it)"]
            if escrowOn { legs.append("the copy in your iCloud Keychain") }
            return "To lose your writing, ALL of these have to go wrong at once: "
                + legs.joined(separator: " · ") + ". Any one of them gets you back in."
        case .biometric:
            var legs = ["this \(deviceName)'s fingerprint/face unlock",
                        "your encryption passphrase",
                        "your recovery phrase (if saved)"]
            if escrowOn { legs.append("the iCloud Keychain copy") }
            return "Your ways back in: " + legs.joined(separator: " · ")
                + ". Lose every one of them and your writing is unrecoverable — by anyone."
        case .passphrase:
            if escrowOn {
                return "Your ways back in: your passphrase · your recovery phrase "
                    + "(if saved) · the iCloud Keychain copy. Forgetting the "
                    + "passphrase is not enough to lose your writing while the "
                    + "others stand — but it is the door you use every day."
            }
            return "In this mode, forgetting your passphrase without the recovery "
                + "phrase written down IS enough to lose your writing. Nothing on "
                + "this \(deviceName) opens the library silently — that is the "
                + "point, and that is the price. Keep the twelve words somewhere real."
        }
    }

    /// R13p-8's rider wearing Locked-down's face: enabling the scheduled
    /// plain-text export under a locked-down posture warns that it
    /// re-opens the door the encryption closed.
    static let plaintextExportUnderLockedDown =
        "Your settings are locked down — and a scheduled plain-text export re-opens "
        + "the door they closed: every note, readable, on a timer, in the folder you "
        + "picked. Turn it on only if that trade is one you mean."

    // The Standard nudge (the two-offer shape, her amendment).
    static let nudgeHeadline = "Your library is encrypted. Two minutes makes it recoverable."
    static let nudgeBody =
        "Right now this \(deviceName)'s Keychain holds the only key. Set an "
        + "encryption passphrase (your recovery phrase appears on the same screen), "
        + "or just take the recovery phrase — either one means losing this "
        + "\(deviceName) doesn't mean losing your writing."
    static let nudgeOfferPassphrase = "Set a Passphrase…"
    static let nudgeOfferPhrase = "Show My Recovery Phrase…"
    static let nudgeLater = "Later"

    // The reminder check (R13p-9; the face composes SecretCheck).
    static let reminderHeadline = "Still remember your encryption passphrase?"
    static let reminderBody =
        "You never type it day to day, which is exactly how it slips away. Check it "
        + "here — nothing is changed or reset, this only answers yes or no."

    /// The lobby's wording per demand.
    static func lobbyPrompt(_ mode: StoreAtOpenMode) -> String {
        switch mode {
        case .auto: return ""  // no lobby exists under auto
        case .biometric: return "Unlock your library with \(biometryName)."
        case .passphrase: return "Enter your encryption passphrase to unlock your library."
        }
    }

    /// The at-open wording for envelope refusals (typed → sentence; the
    /// R94 doctrine — a refusal that dumps a case name is forbidden).
    static func message(for error: any Error) -> String {
        switch error {
        case StoreKeyEnvelopeError.wrongPassphrase:
            return "That passphrase doesn't unlock this library."
        case StoreKeyEnvelopeError.wrongRecoveryPhrase:
            return "Those twelve words don't unlock this library."
        case StoreKeyEnvelopeError.noPassphraseWrap:
            return "This library has no passphrase set — unlock it another way."
        case StoreKeyEnvelopeError.noRecoveryWrap:
            return "This library has no recovery phrase on file."
        case StoreKeyEnvelopeError.emptyPassphrase:
            return "Type the passphrase first."
        case StoreKeyEnvelopeError.newerFormat:
            return "This library's key file was written by a newer Variorum — "
                + "update the app to open it."
        case StoreKeyEnvelopeError.unreadable:
            return "This library's key file exists but can't be read. Restore "
                + "\(StoreKeyEnvelope.filename) from a backup folder, or unlock "
                + "with Touch ID if it's offered."
        case RecoveryPhraseError.checksumMismatch:
            return "That's not quite the phrase — one of the twelve words is off. "
                + "Check them against what you wrote down."
        case let RecoveryPhraseError.unknownWord(word):
            return "“\(word)” isn't a recovery word — check that one."
        case RecoveryPhraseError.invalidWordCount(let count):
            return "A recovery phrase is exactly 12 words — that was \(count)."
        default:
            return String(describing: error)
        }
    }
}
