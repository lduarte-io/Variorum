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

    /// 13p-fix ladder R2-2 (moved here at R3-2, so BOTH surfaces can say
    /// it — `ProtectionController` is MainActor-isolated and the E2EE
    /// road needed the same sentence): the honest wording for the arm
    /// where a write DID land somewhere the read path cannot reach.
    /// "Nothing was altered" is false there, in exactly the case the
    /// guard exists to surface.
    static let wroteButUnreadable =
        "The Keychain accepted the key but cannot find it again, so your "
        + "current way in was left exactly as it was. Nothing is lost — "
        + "your passphrase and recovery phrase still open your library."

    /// F6 (pre-13u Act 9): the E2EE SYNC-custody arm's OWN sentence. The
    /// store-key one above promises "still open your library" — true for
    /// the at-open family and non-responsive when the SYNC gate's write
    /// lands unreadable: that surface's road back is passphrase
    /// re-enrollment of sync custody, and the sentence must name it.
    /// (Functional copy; 13s re-voices.)
    static let syncKeysWroteButUnreadable =
        "The Keychain accepted the key but cannot find it again, so this "
        + "\(deviceName)'s sync keys were left exactly as they were. Nothing "
        + "is lost — entering your encryption passphrase re-enrolls sync on "
        + "this \(deviceName)."

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

    /// **THE WAYS BACK IN, AS A LIST — the ONE brain** (13p Batch 4,
    /// knot 6's letter: the tutorial chapter teaches the loss math and the
    /// settings pane states it, so the two must not be able to diverge).
    /// `lossMath` below composes its sentence from exactly these legs, and
    /// the tutorial spine asserts the chapter names every one of them.
    ///
    /// Read it as a chain: every leg listed is a way IN, so losing the
    /// writing means losing all of them at once. The demanded modes' lists
    /// are SHORTER by construction (no silently-releasing Keychain item
    /// exists there — the custody law), which is exactly her non-scary-
    /// but-serious point.
    static func lossLegs(_ mode: StoreAtOpenMode, escrowOn: Bool) -> [String] {
        var legs: [String]
        switch mode {
        case .auto:
            legs = ["this \(deviceName) (its Keychain holds the key)",
                    "your encryption passphrase (if you set one)",
                    "your recovery phrase (if you saved it)"]
        case .biometric:
            legs = ["this \(deviceName)'s fingerprint/face unlock",
                    "your encryption passphrase",
                    "your recovery phrase (if saved)"]
        case .passphrase:
            // NO device leg: passphrase mode leaves neither Keychain item
            // behind, so the typed secret and the twelve words are the
            // whole same-device story (the custody law, in words).
            legs = ["your encryption passphrase", "your recovery phrase (if saved)"]
        }
        if escrowOn { legs.append("the copy in your iCloud Keychain") }
        return legs
    }

    /// The per-mode loss math (knot 6, her example carried verbatim into
    /// the demanded modes' sentence: "forgetting the passphrase without
    /// the phrase written down IS enough"). Composed from `lossLegs`.
    static func lossMath(_ mode: StoreAtOpenMode, escrowOn: Bool) -> String {
        let legs = lossLegs(mode, escrowOn: escrowOn).joined(separator: " · ")
        switch mode {
        case .auto:
            return "To lose your writing, ALL of these have to go wrong at once: "
                + legs + ". Any one of them gets you back in."
        case .biometric:
            return "Your ways back in: " + legs
                + ". Lose every one of them and your writing is unrecoverable — by anyone."
        case .passphrase:
            if escrowOn {
                return "Your ways back in: " + legs + ". Forgetting the "
                    + "passphrase is not enough to lose your writing while the "
                    + "others stand — but it is the door you use every day."
            }
            return "In this mode, forgetting your passphrase without the recovery "
                + "phrase written down IS enough to lose your writing. Nothing on "
                + "this \(deviceName) opens the library silently — that is the "
                + "point, and that is the price. Keep the twelve words somewhere real."
        }
    }

    /// **THE NAMED NON-GOAL, said out loud where the reader is choosing**
    /// (13p Batch 4's honest-copy sweep). The plan names exactly one threat
    /// this design declines: shape B (column sealing, R13p-3) would have
    /// kept a note's plaintext out of reachable memory while the app is
    /// OPEN — and R13p-16 then declined the per-note curtain that would
    /// have LOOKED like that protection without being it (*"it makes users
    /// think privacy is in place that just isn't"*). A design that refuses
    /// theater on those grounds owes the sentence that says so.
    static let openAppIsReadable =
        "One thing no setting here changes: while Variorum is open and unlocked, "
        + "everything in your library is readable — that is what open means. "
        + "Locking is how you end that. There is deliberately no per-note lock: "
        + "over an already-open library it would look like protection without "
        + "being any."

    /// **The one-device honesty line** (13p Batch 4, the mobile-only-user
    /// expansion's item (h): *"a mobile-only user has ONE enrolled device,
    /// so their chain is shorter and the copy must say so"*). It reads
    /// true on either platform — what it names is that a library with no
    /// second home has no second home, which is the fact a list of
    /// same-device legs can quietly let a reader forget.
    static let oneDeviceNote =
        "Your library lives on this \(deviceName). Unless you sync it, there is no "
        + "copy of it anywhere else — so the ways back in above are the whole list."

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

    // MARK: - The doors' own words (13p Batch 4 — shared so the phone's
    // faces, the Mac's pane, and the tutorial chapter read ONE vocabulary;
    // every one is byte-identical on macOS to the literal it replaced).

    /// The at-open picker's rows. Platform-aware by the same interpolation
    /// as every sentence above (the Mac reads "Touch ID", the phone
    /// "Face ID").
    static func modeLabel(_ mode: StoreAtOpenMode) -> String {
        switch mode {
        case .auto: return "Open silently (Keychain)"
        case .biometric: return "Ask for \(biometryName)"
        case .passphrase: return "Ask for the passphrase"
        }
    }

    static func presetTitle(_ preset: ProtectionPreset) -> String {
        switch preset {
        case .standard: return "Standard"
        case .lockedDown: return "Locked-down"
        }
    }

    static func presetBlurb(_ preset: ProtectionPreset) -> String {
        switch preset {
        case .standard:
            return "Opens silently. The disk is protected; recovery is easy."
        case .lockedDown:
            return "Asks every time it opens. No silent copies anywhere."
        }
    }

    /// The manual lock act's word (demanded modes only — under Auto it
    /// would be theater, R13p-14, and the door is not rendered).
    static let lockNowLabel = "Lock Library Now"
    static let lockNowSentence =
        "Locking closes the library and forgets its key until you unlock it again."

    /// The phone's re-lock dial (Batch 4, item (g)): backgrounding IS the
    /// phone's leaving, and dropping the key there is a REAL boundary —
    /// the hand-someone-your-phone answer.
    static let relockOnBackgroundLabel = "Lock when Variorum leaves the screen"
    static let relockOnBackgroundSentence =
        "Whatever you were writing is saved first, then the library closes and its "
        + "key is forgotten. Coming back asks again."
    /// Its gentler sibling — the phone's reading of the idle dial: a short
    /// trip away costs nothing, a long one re-asks.
    static let relockAfterAwayLabel = "Lock after time away"

    /// The lobby's wording per demand.
    static func lobbyPrompt(_ mode: StoreAtOpenMode) -> String {
        switch mode {
        case .auto: return ""  // no lobby exists under auto
        case .biometric: return "Unlock your library with \(biometryName)."
        case .passphrase: return "Enter your encryption passphrase to unlock your library."
        }
    }

    /// **The lobby's dead end, worded PER DEMAND** (13p Batch 4 — caught by
    /// the acceptance walk, which drove a passphrase-demanding lobby with
    /// no wraps and read a sentence blaming *"its fingerprint item is
    /// gone"* — an item that never existed in that mode, and a false cause
    /// on the one screen whose entire job is to tell a locked-out user the
    /// truth about their own library).
    ///
    /// Practically unreachable through the app's own doors (the mode
    /// transitions refuse to enter a demanded mode without a wrap), which
    /// is exactly why it was wrong for so long — and exactly why it has to
    /// be right: whoever meets it got here by a road nobody planned, and a
    /// wrong cause sends them hunting for the wrong thing.
    static func deadEnd(_ demand: StoreAtOpenMode) -> String {
        let cause: String
        switch demand {
        case .biometric:
            cause = "its \(biometryName) item is gone from this \(deviceName), and no "
                + "passphrase or recovery phrase is on file beside the library"
        case .passphrase, .auto:
            cause = "no passphrase or recovery phrase is on file beside the library"
        }
        return "No way to unlock this library exists on this \(deviceName): \(cause). "
            + "Restore the \(StoreKeyEnvelope.filename) file from a backup folder, or "
            + "restore the whole library from a backup."
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
            // 13p Batch 4's copy sweep: this one arm still named Touch ID
            // as a literal, so on the phone it offered a fingerprint that
            // does not exist there. It rides the same interpolation as
            // every other sentence now.
            return "This library's key file exists but can't be read. Restore "
                + "\(StoreKeyEnvelope.filename) from a backup folder, or unlock "
                + "with \(biometryName) if it's offered."
        case RecoveryPhraseError.checksumMismatch:
            return "That's not quite the phrase — one of the twelve words is off. "
                + "Check them against what you wrote down."
        case let RecoveryPhraseError.unknownWord(word):
            return "“\(word)” isn't a recovery word — check that one."
        case RecoveryPhraseError.invalidWordCount(let count):
            return "A recovery phrase is exactly 12 words — that was \(count)."
        default:
            // R94's floor for the unforeseen (ladder R1-n2): the old
            // `String(describing:)` arm was a case-name dump — not a
            // sentence, and on the one class of error nobody predicted.
            // Generic and honest instead: it names what was being touched
            // and the one recovery road that is always true.
            return "Something unexpected went wrong with this library's key "
                + "file. Try again — and if it keeps happening, restore "
                + "\(StoreKeyEnvelope.filename) from a backup folder."
        }
    }
}
