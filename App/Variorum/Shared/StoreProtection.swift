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

// MARK: - The posture (pre-13x 2a — DERIVED, never a setting; design §3.1)

/// **Standard or Castle — who holds a key.** The postures design's one
/// user-facing fact (§2), DERIVED by `derive` from what exists and stored
/// nowhere (§3.1's posture row: "the ACCOUNT is Standard ⇔ the vault has
/// an iCloud copy; a LOCAL-ONLY library is Standard ⇔ its key file has
/// one"). Both postures are end-to-end encrypted (decision 2); they differ
/// only in whether an Apple-held key (A, in iCloud Keychain) can open a
/// wrapped copy of the library key and the master key.
nonisolated enum Posture: String, Sendable, Codable {
    case standard
    case castle

    /// THE ONE DERIVATION (pinned from both sources). In order — the
    /// precedence pre-13x 2d (decision 35) settled, superseding 2a's:
    ///
    /// 1. **The vault's word, when in hand** (decision 8: every device
    ///    follows the account): an Apple-held copy of the master ⇒
    ///    Standard, none ⇒ Castle. A vault word means the account exists,
    ///    so it outranks the legacy mode too. (Reconciled against the key
    ///    file and the custody SHAPE at every ready; a disagreement is the
    ///    follow — 2c's, widened at 2d to a POSTURE mismatch — or the adopt
    ///    road — batch 3's.)
    /// 2. **An ENROLLED library whose vault has not answered is
    ///    INDETERMINATE** (decision 35 — the window's finding): signed in
    ///    or holding sync custody, the vault's word is the ONLY thing that
    ///    can make it Standard, so while that word is out of reach (offline,
    ///    a session not yet restored, a slow ready) the reading carries the
    ///    posture the custody SHAPE reads as — the silent item ⇒ Standard,
    ///    the gated item or nowhere ⇒ Castle, an unreadable shape ⇒ the key
    ///    file's rule below — and that is what the routes and the gate ACT
    ///    on ("opens through the custody it has"); every posture-driven
    ///    WRITE waits for a determined reading. The legacy stored mode
    ///    NEVER overrides an enrolled library: it is a fact about the gate
    ///    the device had, already honored by the existing custody shape.
    /// 3. **The pre-2a read-through** for a library that is NOT enrolled
    ///    (`legacyMode` — the 13p-era stored at-open mode, present only
    ///    until §11's migration retires the dial keys for the store): Auto
    ///    ⇒ Standard, a demanded mode ⇒ Castle.
    /// 4. **A local-only library is its key file's**: an `apple` copy ⇒
    ///    Standard; none ⇒ Castle — EXCEPT a key file carrying no
    ///    passphrase wrap either, which is Standard: entering Castle
    ///    requires a passphrase and the twelve words (decision 5), so a
    ///    library that has never had a passphrase cannot have entered it;
    ///    what it is is a Standard library whose Apple copy has not landed
    ///    (the exposed nudge's state, §14.20), never a lock. THE SAFETY ARM
    ///    is reached only with NO session and NO custody (arm 2 catches an
    ///    enrolled secret-less library first — her phone at the window).
    /// 5. No key file at all ⇒ a fresh library, born Standard (§14.26).
    ///
    /// **Corner 45 (pre-13x 2b item (0); the 2a adjudication's ruling 2 —
    /// a refused Apple landing never makes Castle):** Castle is ENTERED,
    /// and entering moves the raw library key behind Touch ID or nowhere;
    /// so a local-only key file with NO `apple` copy derives Castle only
    /// when the raw key's custody is the gated item or nowhere
    /// (`rawKeyCustody == .gatedOrNone`) — with the raw key in the SILENT
    /// bound item it is Standard-waiting (the reconcile keeps trying to
    /// land A; the exposed nudge speaks), never a lock. The custody SHAPE
    /// tells the two apart by presence alone, no unlock. A caller that
    /// cannot read custody passes `.unknown` and gets arm 4's older
    /// reading (a passphrase wrap ⇒ Castle), so nothing regresses where
    /// the shape is not in view.
    ///
    /// `enrolled` is REQUIRED (the `legacyCleanup` precedent — every call
    /// site decides): at the ROUTE it is the per-store sync custody's
    /// PRESENCE; at ready it is signed-in OR sync custody held.
    static func derive(
        legacyMode: StoreAtOpenMode?,
        vaultHasAppleHeldCopy: Bool?,
        keyFile: StoreKeyEnvelope?,
        rawKeyCustody: RawKeyCustody = .unknown,
        enrolled: Bool
    ) -> PostureReading {
        if let vaultHasAppleHeldCopy { return .determined(vaultHasAppleHeldCopy ? .standard : .castle) }
        if enrolled {
            return .indeterminate(shape: shapeReading(keyFile: keyFile, rawKeyCustody: rawKeyCustody))
        }
        if let legacyMode { return .determined(legacyMode.isDemanded ? .castle : .standard) }
        return .determined(localReading(keyFile: keyFile, rawKeyCustody: rawKeyCustody))
    }

    /// Arms 4–5: the local-only rule, corner 45 included.
    private static func localReading(keyFile: StoreKeyEnvelope?, rawKeyCustody: RawKeyCustody) -> Posture {
        guard let keyFile else { return .standard }
        if keyFile.apple != nil { return .standard }
        guard keyFile.passphrase != nil else { return .standard }
        switch rawKeyCustody {
        case .silent: return .standard        // corner 45: Standard-waiting, never a lock
        case .gatedOrNone, .unknown: return .castle
        }
    }

    /// Arm 2's carried posture: what the custody SHAPE reads as — the
    /// device opens through the custody it HAS (decision 35).
    private static func shapeReading(keyFile: StoreKeyEnvelope?, rawKeyCustody: RawKeyCustody) -> Posture {
        switch rawKeyCustody {
        case .silent: return .standard
        case .gatedOrNone: return .castle
        case .unknown: return localReading(keyFile: keyFile, rawKeyCustody: .unknown)
        }
    }
}

/// THE DERIVATION's answer (pre-13x 2d, decision 35): a DETERMINED posture,
/// or — an enrolled library whose vault has not answered — INDETERMINATE,
/// carrying the posture its custody SHAPE reads as. The routes, the gate
/// and the faces act on `acting`; every posture-DRIVEN write (the Apple
/// arm, custody alignment, key-file changes, the legacy-key retirement)
/// requires `determined`, and an indeterminate reading writes NOTHING and
/// retries at the next ready.
nonisolated enum PostureReading: Equatable, Sendable {
    case determined(Posture)
    case indeterminate(shape: Posture)

    /// What the device ACTS as right now (the gate, the faces).
    var acting: Posture {
        switch self {
        case .determined(let posture): return posture
        case .indeterminate(let shape): return shape
        }
    }

    /// The posture a WRITE may act on; nil while indeterminate.
    var determined: Posture? {
        if case .determined(let posture) = self { return posture }
        return nil
    }

    var isIndeterminate: Bool { determined == nil }
}

/// WHERE THE RAW LIBRARY KEY SITS on this device (pre-13x 2b, corner 45) —
/// a presence reading, never an unlock: the silent bound item (Standard's
/// road), the gated item or nowhere (Castle was ENTERED — Touch ID or
/// Always ask), or unknown (the caller cannot read custody).
nonisolated enum RawKeyCustody: Equatable, Sendable {
    case silent
    case gatedOrNone
    case unknown
}

// MARK: - The effective gate (was the three stored at-open modes, R13p-5)

/// How the store key is released at open — since pre-13x 2a a DERIVED
/// value, a pure function of (posture, Castle's gate style), never stored
/// (the BATCH 2 brief's binding fact i; §13 deletes the setting). The
/// routes, the lobby and the custody law keep their shape: Standard ⇒
/// `.auto`; Castle ⇒ `.biometric` (Touch ID / Face ID, the passphrase as
/// the fallback), or `.passphrase` under Always ask. The login password is
/// NEVER in any gate's chain (her threat model, verbatim in the 13p plan:
/// "a lot of people have […] someone who knows their
/// computer password but might not know their passphrase").
nonisolated enum StoreAtOpenMode: String, CaseIterable, Sendable, Codable {
    /// The device Keychain releases the key silently — Standard's road.
    case auto
    /// A `.biometryCurrentSet`-gated Keychain item; fallback is the
    /// PASSPHRASE, never the device password.
    case biometric
    /// The passphrase is typed at every open; no silently-releasing
    /// custody item exists — Castle's Always ask.
    case passphrase

    /// The demanded gates — the only ones where a locked lobby, a re-lock
    /// policy, or Lock Now mean anything. Under `.auto` every one of them
    /// would be theater (the key auto-releases at the next open), and
    /// R13p-14's whole point is that no theater ships.
    var isDemanded: Bool { self != .auto }

    /// THE DERIVATION: the posture decides whether a gate exists; Castle's
    /// per-device dial decides its style.
    static func effective(posture: Posture, dials: ProtectionDials) -> StoreAtOpenMode {
        switch posture {
        case .standard: return .auto
        case .castle: return dials.alwaysAsk ? .passphrase : .biometric
        }
    }

    /// pre-13x 2d (decision 35): the gate acts on the reading's ACTING
    /// posture — under an indeterminate reading, the custody shape's.
    static func effective(reading: PostureReading, dials: ProtectionDials) -> StoreAtOpenMode {
        effective(posture: reading.acting, dials: dials)
    }
}

// MARK: - The dials (Castle's two switches — per device, per store id; §3.1)

/// **Castle's controls (decision 18), and nothing else.** Re-lock on
/// sleep / screen lock is ALWAYS ON in Castle (no dial); the reminder
/// check is always on in Castle (no dial); the iCloud spare, the presets
/// and the stored at-open mode are gone (§13). Standard has no dials at
/// all — the pane renders these only in Castle.
nonisolated struct ProtectionDials: Equatable, Sendable {
    /// *Always ask for the passphrase* — skip Touch ID and type the
    /// passphrase every time Variorum opens; with it on, NO copy of the
    /// key is kept on this device at all (copy §1).
    var alwaysAsk: Bool = false
    /// *Lock after time away* — minutes since Variorum was last USED
    /// (decision 18: the clock is time since Variorum was last used, never
    /// the system's idle clock); nil = never. Offered 5 · 10 · 30 · never;
    /// default 10.
    var relockAfterIdleMinutes: Int? = ProtectionDials.defaultIdleMinutes

    static let defaultIdleMinutes = 10
    /// The idle dial's four values (copy §1), in the order the pane offers
    /// them; nil renders as "never".
    static let idleChoices: [Int?] = [5, 10, 30, nil]
}

/// THE IDLE CLOCK (decision 18: "the clock = time since Variorum was last
/// used") — pure, so the cadence has pins. The Mac stamps `lastUsedAt`
/// from its own event stream (never the system's idle clock, which any
/// app's activity resets — "switching to another app doesn't lock it;
/// time away does"); the phone reads the same rule on RETURN from the
/// time it left the screen.
nonisolated enum IdleLockClock {
    static func isDue(idleSeconds: TimeInterval, minutes: Int?) -> Bool {
        guard let minutes, minutes > 0 else { return false }
        return idleSeconds >= Double(minutes) * 60
    }

    static func isDue(now: Date, lastUsedAt: Date?, minutes: Int?) -> Bool {
        guard let lastUsedAt else { return false }
        return isDue(idleSeconds: now.timeIntervalSince(lastUsedAt), minutes: minutes)
    }
}

// MARK: - Device-local storage (UserDefaults, per store scope + store id)

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

    /// pre-13x 1a: the dials are PER STORE ID (the postures design §3.1 —
    /// "Castle's two switches + the idle dial: per device, UserDefaults per
    /// store ID"). nil = the pre-1a per-scope key (the LEGACY shape).
    static func key(_ leaf: String, scope: String, storeID: String?) -> String {
        guard let storeID else { return key(leaf, scope: scope) }
        return "variorum.protection.\(scope).\(storeID).\(leaf)"
    }

    /// The 13p-era leaves — the stored at-open mode and the three dials
    /// the design deletes (§13). Read ONLY by the legacy read-through and
    /// retired by §11's migration (`retireLegacyKeys`).
    static let legacyLeaves = ["mode", "escrowOff", "relockOnSleep", "reminders"]

    static func dials(scope: String, in defaults: UserDefaults) -> ProtectionDials {
        dials(scope: scope, storeID: nil, in: defaults)
    }

    /// The per-store read WITH THE LEGACY READ-THROUGH (pre-13x 1a, kept
    /// through 2a): a store id whose own 2a keys have never been written
    /// reads the 13p-era keys — per store id where 1a wrote them ("Start a
    /// New Library"), else the scope's — so her existing library keeps
    /// reading the gate style it always had: a stored `passphrase` mode
    /// reads as Always ask, `biometric` as Touch ID. A store that has
    /// written its 2a keys reads only those. §11's migration retires the
    /// legacy keys for the store (`retireLegacyKeys`).
    static func dials(scope: String, storeID: String?, in defaults: UserDefaults) -> ProtectionDials {
        var dials = ProtectionDials()
        if let own = defaults.object(forKey: key("alwaysAsk", scope: scope, storeID: storeID)) as? Bool {
            dials.alwaysAsk = own
        } else if let mode = legacyMode(scope: scope, storeID: storeID, in: defaults) {
            dials.alwaysAsk = mode == .passphrase
        }
        // The idle dial: an ABSENT key is the design's default (10); a
        // stored 0 is "never" (the 13p encoding, kept so her existing
        // choice reads exactly as she left it).
        let idleKey = idleKey(scope: scope, storeID: storeID, in: defaults)
        if let stored = defaults.object(forKey: idleKey) as? Int {
            dials.relockAfterIdleMinutes = stored > 0 ? stored : nil
        }
        return dials
    }

    /// The 13p-era stored at-open mode for the store, if any survives —
    /// the posture derivation's read-through (`Posture.derive`), and the
    /// gate-style seed above. Per store id where 1a wrote one, else the
    /// scope's legacy key; nil once §11 retired them (or never written).
    static func legacyMode(scope: String, storeID: String?, in defaults: UserDefaults) -> StoreAtOpenMode? {
        if let storeID {
            if let raw = defaults.string(forKey: key("mode", scope: scope, storeID: storeID)),
               let mode = StoreAtOpenMode(rawValue: raw) {
                return mode
            }
            // A store that has written its OWN 2a keys reads only those
            // (1a's rule): the scope's legacy mode is another library's —
            // a NEW library started over an absent store must be born
            // Standard, never inherit the old library's Castle.
            if defaults.object(forKey: key("alwaysAsk", scope: scope, storeID: storeID)) != nil {
                return nil
            }
        }
        if let raw = defaults.string(forKey: key("mode", scope: scope)),
           let mode = StoreAtOpenMode(rawValue: raw) {
            return mode
        }
        return nil
    }

    /// The idle key that applies: the store's own when it has ever been
    /// written, else the scope's legacy one (the read-through's shape).
    private static func idleKey(scope: String, storeID: String?, in defaults: UserDefaults) -> String {
        let own = key("relockIdleMinutes", scope: scope, storeID: storeID)
        if storeID != nil, defaults.object(forKey: own) != nil { return own }
        return key("relockIdleMinutes", scope: scope)
    }

    static func save(_ dials: ProtectionDials, scope: String, in defaults: UserDefaults) {
        save(dials, scope: scope, storeID: nil, in: defaults)
    }

    /// Writes the store's OWN keys (the legacy keys are never written for
    /// a known store id — the read-through ends for it at its first save).
    static func save(_ dials: ProtectionDials, scope: String, storeID: String?, in defaults: UserDefaults) {
        defaults.set(dials.alwaysAsk, forKey: key("alwaysAsk", scope: scope, storeID: storeID))
        defaults.set(dials.relockAfterIdleMinutes ?? 0, forKey: key("relockIdleMinutes", scope: scope, storeID: storeID))
    }

    /// §11 — "retire the dial keys": the store's 2a keys are written from
    /// what the read-through reads NOW (so the gate style she had survives
    /// as `alwaysAsk`), then every 13p-era leaf goes — the store's own AND
    /// the scope's. From here the posture reads from the key file / the
    /// vault alone (`Posture.derive`'s arms 2–4). Idempotent.
    static func retireLegacyKeys(scope: String, storeID: String, in defaults: UserDefaults) {
        let current = dials(scope: scope, storeID: storeID, in: defaults)
        save(current, scope: scope, storeID: storeID, in: defaults)
        for leaf in legacyLeaves {
            defaults.removeObject(forKey: key(leaf, scope: scope, storeID: storeID))
            defaults.removeObject(forKey: key(leaf, scope: scope))
        }
        defaults.removeObject(forKey: key("relockIdleMinutes", scope: scope))
    }

    /// Whether any 13p-era key survives for the store (the migration's
    /// "already retired" read).
    static func hasLegacyKeys(scope: String, storeID: String, in defaults: UserDefaults) -> Bool {
        for leaf in legacyLeaves {
            if defaults.object(forKey: key(leaf, scope: scope, storeID: storeID)) != nil { return true }
            if defaults.object(forKey: key(leaf, scope: scope)) != nil { return true }
        }
        return defaults.object(forKey: key("relockIdleMinutes", scope: scope)) != nil
    }

    /// VX-202 (belt c): a posture switch's custody move is PENDING for the
    /// store — device-local beside the dials because the route that reads
    /// it runs before the store (and its `RotationMarker`) can be opened.
    static func switchPending(scope: String, storeID: String, in defaults: UserDefaults) -> Bool {
        defaults.bool(forKey: key("switchPending", scope: scope, storeID: storeID))
    }

    static func setSwitchPending(_ pending: Bool, scope: String, storeID: String, in defaults: UserDefaults) {
        let key = key("switchPending", scope: scope, storeID: storeID)
        if pending {
            defaults.set(true, forKey: key)
        } else {
            defaults.removeObject(forKey: key)
        }
    }

    /// VX-110: the store's Use Castle is the THIS-MAC-ONLY road (the sync
    /// account's keys forgotten here, the account untouched) — set before
    /// the forget, cleared with the switch's marker; a crashed road's resume
    /// reads it to speak the honest Done. Device-local beside the dials (the
    /// marker that names the steps cannot carry it).
    static func thisDeviceOnlySwitch(scope: String, storeID: String, in defaults: UserDefaults) -> Bool {
        defaults.bool(forKey: key("thisDeviceOnlySwitch", scope: scope, storeID: storeID))
    }

    static func setThisDeviceOnlySwitch(_ on: Bool, scope: String, storeID: String, in defaults: UserDefaults) {
        let key = key("thisDeviceOnlySwitch", scope: scope, storeID: storeID)
        if on {
            defaults.set(true, forKey: key)
        } else {
            defaults.removeObject(forKey: key)
        }
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

// MARK: - The ways back in, as FACTS (R-pre13u-4's detection half)

/// **THE ONE NUDGE BRAIN — R-pre13u-4 (pre-13u Act 9), her ruling:
/// "state aware nudge, but keep in mind that the phone has to invoke the
/// same nudge and the language maybe should be 'this device'."** Which
/// recovery legs actually exist, and the tier that follows. DETECTION
/// only — the faces are Act 10's (Mac) and the mobile parity line's
/// (phone); both platforms consult THIS brain so the tier can never
/// diverge (her rider: "Both platforms invoke the same nudge brain").
///
/// The Apple-key leg is VERIFIED, never assumed (pre-13x 2a — re-based
/// from the 13p escrow item onto the iCloud key A, design §3.8): it reads
/// true only when the launch reconcile read A back from iCloud Keychain
/// AND the key file's `apple` copy unwrapped to the key in hand
/// (`ProtectionController.appleKeyVerified`) — a write that merely
/// returned success counts for nothing (the 13p-fix lesson, applied to
/// the safety net). Recorded limit (the batch's external lookup): a
/// synchronizable item ADDS and reads back locally even with iCloud
/// Keychain OFF, and no public API reports that toggle — so "verified"
/// means A is on THIS device; whether it has left it cannot be told.
nonisolated struct ProtectionLegs: Equatable, Sendable {
    var hasPassphraseWrap: Bool
    var hasRecoveryWrap: Bool
    /// nil = not verified this launch (no reconcile with the key in hand
    /// has run yet) — treated as NOT a leg, because an unverified net is
    /// exactly what must never count as one. Always false in Castle (no
    /// current copy opens with A — §3.2).
    var appleKeyVerified: Bool?
    /// The at-open mode's own same-device leg (informational for the
    /// ways-back-in listing; a demanded mode implies a passphrase wrap,
    /// so the TIER never rides on this alone).
    var storeCustodyGated: Bool
    /// True while the sidecar is present-but-unreadable (P1/P11): the
    /// wrap facts are UNKNOWN, and no tier may be claimed from unknowns.
    var factsUnknown: Bool = false
    /// pre-13x ladder round 2, F3 (NIT-N8): the Apple arm is WAITING — the
    /// account's vault names an iCloud key this device cannot read yet and
    /// it holds no master, so nothing is minted (F2's MAJOR-3 (a)); the
    /// next ready re-reads. A device merely waiting is NOT exposed: it must
    /// not be told to write its words down as if its key were unguarded.
    var appleKeyWaiting: Bool = false

    enum Tier: Equatable, Sendable {
        /// Any real leg exists — today's gentle nudge and cadence stand.
        case covered
        /// Auto + no secrets + escrow not verifiably landing: ONLY this
        /// device opens the work. The hardened plain-truth copy renders
        /// (never a modal, never a gate; cadence unchanged — her ruling).
        case exposed
        /// The sidecar is unreadable — nothing honest can be claimed;
        /// the nudge stays quiet (the P1/P11 suppression).
        case unknown
        /// F3 (NIT-N8): no leg yet, but the account's iCloud key is on its
        /// way (propagation lag; the same Apple account) — copy §2d's
        /// *Standard, waiting* sentence renders in the exposed nudge's
        /// place; its doors (the passphrase, the twelve words) act.
        case waiting
    }

    var tier: Tier {
        if factsUnknown { return .unknown }
        if hasPassphraseWrap || hasRecoveryWrap || appleKeyVerified == true { return .covered }
        return appleKeyWaiting ? .waiting : .exposed
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
    /// F3 (the F2 adjudication's copy follow-up 3): the device word with
    /// its article, for a sentence that names ANOTHER device of the kind
    /// ("from an iPhone that is" / "from a Mac that is").
    static let deviceNameWithArticle = "an iPhone"
    #else
    static let deviceName = "Mac"
    static let biometryName = "Touch ID"

    static let credentialName = "login password"
    static let deviceNameWithArticle = "a Mac"
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

    /// 17h (13p-fix ladder R3-5): the arm where the INCOMING custody is
    /// fine but the OUTGOING item would not go — `SecItemDelete`'s status
    /// was dropped at the leaves for two phases, so a transition promising
    /// "the old item is deleted" completed on no evidence. The change is
    /// backed out instead of left half-made. (Functional copy; 13s
    /// re-voices.)
    static let outgoingCustodyNotReleased =
        "The Keychain could not remove the key's previous item, so your "
        + "current way in was left exactly as it was. Nothing changed — "
        + "you can try the switch again."

    /// The sync-custody family's own sentence for the same arm (the F6
    /// precedent: the store-key wording promises "your current way in",
    /// which is non-responsive on the sync-gate surface).
    static let syncKeysOutgoingNotReleased =
        "The device Keychain could not remove the previous sync-key item, "
        + "so the setting was left exactly as it was. Nothing changed — "
        + "you can try again."

    // (The 13p escrow dial's sentence pair, the no-iCloud consequence and
    // the ninth wave's escrow/posture coupling copy left at pre-13x 2a
    // with the dial and the item they described — §13; the Apple key's
    // sentences are `PostureCopy`'s, rendered from `pre-13x-copy.md`.)

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

    // MARK: - pre-13x 5a — the survivors of the retired shapes model (§13)
    //
    // The pre-13u shapes brain (the recipes, the need-states, the shapes
    // tables) and the Settings explainer that rendered it are DELETED; the
    // 13p per-mode loss chains with them — the book *Encryption Explained*
    // and the posture cards are the story now. What survives is ONE brain for the nudge's three
    // sentences by tier (copy §5, verbatim) and the pane's live "ways back
    // in" checklist (R-pre13u-4's counting of the actual legs — the rows'
    // key-naming names are 13s's, listed in copy §11).

    /// Copy §5's three nudge lines by tier — the nudge's ONE brain, both
    /// platforms. "Can't tell" is never dressed as comfort or alarm.
    static func nudgeSentence(for tier: ProtectionLegs.Tier) -> String {
        switch tier {
        case .covered: return coveredNudgeLine
        case .exposed: return exposedNudgeHeadline + " " + exposedNudgeBody
        case .unknown: return unknownNudgeLine
        // F3 (NIT-N8): copy §2d's *Standard, waiting* title + body — the
        // lobby's own waiting sentence, in the exposed nudge's place.
        case .waiting: return waitingTitle + " " + waitingBody
        }
    }

    /// The Apple-key LEG's own three-value truth (T2 applied per leg —
    /// pre-13x 2a, re-based onto the iCloud key A): a verified copy, a copy
    /// that is verifiably not landing, a copy this launch hasn't checked.
    static func appleKeyLegSentence(_ verified: Bool?) -> String {
        switch verified {
        case true: return "verified this launch — the iCloud key opens the key file's copy"
        case false: return "not landing — no copy verifiably opens with the iCloud key"
        case nil: return "not checked yet this launch"
        }
    }

    struct ChecklistRow: Equatable, Sendable {
        let name: String
        /// nil = UNKNOWN (T2's three-value truth — never dressed as
        /// present or absent).
        let present: Bool?
        let note: String
    }

    /// ONE brain for the live checklist (R-pre13u-4's "counting the actual
    /// legs"). Under `factsUnknown` the caller renders `nudgeSentence(for:
    /// .unknown)` instead of claiming wrap rows it cannot read — only the
    /// device row (whose truth is the gate's, not the key file's) survives.
    static func checklistRows(
        _ legs: ProtectionLegs, mode: StoreAtOpenMode
    ) -> [ChecklistRow] {
        var rows: [ChecklistRow] = []
        switch mode {
        case .auto:
            rows.append(ChecklistRow(
                name: "This \(deviceName)", present: true,
                note: "its Keychain opens the library silently"))
        case .biometric:
            rows.append(ChecklistRow(
                name: "This \(deviceName)", present: true,
                note: "\(biometryName) unlocks it — the "
                    + "computer password never does"))
        case .passphrase:
            rows.append(ChecklistRow(
                name: "This \(deviceName)", present: false,
                note: "nothing here opens the library silently — that is "
                    + "this mode's point"))
        }
        guard !legs.factsUnknown else { return rows }
        rows.append(ChecklistRow(
            name: "Encryption passphrase", present: legs.hasPassphraseWrap,
            note: legs.hasPassphraseWrap
                ? "opens any copy, and lets a new device into sync"
                : "not set"))
        rows.append(ChecklistRow(
            name: "Recovery phrase", present: legs.hasRecoveryWrap,
            note: legs.hasRecoveryWrap
                ? "the twelve words — the passphrase's twin, on paper"
                : "not saved"))
        if mode.isDemanded {
            rows.append(ChecklistRow(
                name: "iCloud key", present: false,
                note: "no copy opens with it in Castle"))
        } else {
            rows.append(ChecklistRow(
                name: "iCloud key",
                present: legs.appleKeyVerified,
                note: appleKeyLegSentence(legs.appleKeyVerified)))
        }
        return rows
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
    /// pre-13x 2b: the CASTLE warning (§8's Backups tab — a scheduled
    /// plaintext export re-enabled under Castle shows it; the switch turns
    /// the export OFF with copy §2b's notice).
    static let plaintextExportUnderLockedDown =
        "You're in Castle — and a scheduled plain-text export re-opens the door "
        + "Castle closed: every note, readable, on a timer, in the folder you "
        + "picked. Turn it on only if that trade is one you mean."

    // The EXPOSED tier's copy — pre-13x 2a: copy §5's nudge, VERBATIM
    // (re-based on the Apple key: "Standard, no Apple key landed, no
    // secrets"); the device noun rides the standing interpolation. Never
    // a modal, never a gate — the cadence numbers are untouched.
    static let exposedNudgeHeadline =
        "Right now, only this \(deviceName) can open your work."
    static let exposedNudgeBody =
        "Your Apple account hasn't been able to take a key yet, no passphrase is "
        + "set and no twelve words are written down — so if this \(deviceName) is "
        + "lost or broken, your writing goes with it. Two minutes fixes that: turn "
        + "on iCloud Keychain, or set a passphrase (your twelve words appear on "
        + "the same screen)."
    /// Copy §5 — the nudge, covered.
    static let coveredNudgeLine =
        "At least one real way back into your writing exists beyond this \(deviceName)."
    /// Copy §5 — the nudge, unknown (an unreadable key file).
    static let unknownNudgeLine =
        "Whether a spare way in exists can't be told right now — this library's "
        + "key file exists but can't be read. That is a fact about this check, "
        + "not about your writing: whatever opened the library still does."
    /// The Encryption pane's standing "Ways back in" line (R-pre13u-4:
    /// "counting the actual legs") — composed from the SAME brain, so the
    /// pane and the nudge can never disagree about what exists.
    static func waysBackInLine(_ legs: ProtectionLegs) -> String {
        if legs.factsUnknown {
            return "Ways back in: unknown — this library's key file exists "
                + "but can't be read right now."
        }
        var existing: [String] = []
        if legs.storeCustodyGated { existing.append("this device's \(biometryName) unlock") }
        if legs.hasPassphraseWrap { existing.append("your encryption passphrase") }
        if legs.hasRecoveryWrap { existing.append("your recovery phrase") }
        if legs.appleKeyVerified == true {
            existing.append("the key in your iCloud Keychain")
        }
        guard !existing.isEmpty else {
            return "Ways back in: none beyond this device — see above."
        }
        return "Ways back in: " + existing.joined(separator: " · ") + "."
    }

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

    /// The manual lock act's word (Castle only — under Standard it would
    /// be theater, R13p-14, and the door is not rendered). Copy §1's
    /// "Lock Library Now" line, verbatim.
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
    // MARK: - Library file missing (pre-13x 1a — copy §3, verbatim)

    /// The absent-store route's face (the postures design §3.7 — "the lock
    /// STAYS"): rendered verbatim from `pre-13x-copy.md` §3.
    static let libraryMissingTitle = "Your library file is missing."
    static let libraryMissingBody =
        "Variorum's library isn't where it was. Your lock hasn't changed."
    static let libraryMissingRestoreDoor = "Restore from a Backup…"
    static let libraryMissingOpenDoor = "Open an Existing Library…"
    static let libraryMissingStartDoor = "Start a New Library"
    static let libraryMissingStartSubline = "A new library starts empty and has its own key."

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
        // pre-13x 5a: copy §2a's three lines, verbatim (one wording for the
        // twelve words' three refusals, at the lobby as at the ceremony).
        case RecoveryPhraseError.checksumMismatch:
            return "That's not quite the phrase — one of the twelve words is off. "
                + "Compare it with what you wrote down."
        case let RecoveryPhraseError.unknownWord(word):
            return "\u{201C}\(word)\u{201D} isn't a recovery-phrase word — check its spelling."
        case RecoveryPhraseError.invalidWordCount(let count):
            return "A recovery phrase is exactly 12 words — you entered \(count)."
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
