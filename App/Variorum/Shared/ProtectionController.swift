//
//  ProtectionController.swift
//  Variorum (shared: Mac + Mobile — the custody choreography's one brain;
//  the Mac's pane composes it this batch, the phone's faces in Batch 4)
//
//  Phase 13p, Batch 2 — everything that CHANGES protection state: the
//  at-open mode transitions (with the custody law — see StoreKeyGuard's
//  header), the escrow dial's acts (R13p-6), the presets applied as
//  dial-setters (R13p-7), setting the passphrase + landing the recovery
//  wrap (knot 4's one-moment-two-artifacts), the R13p-9 RESET door
//  (biometric-confirmed re-wrap — red-pinned: the old wrap must stop
//  unwrapping), the launch reconcile (escrow consistency; foreign
//  sidecars set ASIDE, never deleted — they are some other library's
//  recovery legs), the reminder/nudge notice state, and — on the Mac —
//  the re-lock monitors (sleep · screen lock · idle).
//
//  ONE SECRET (R13p-4) is enforced here procedurally, in both directions:
//  the vault's passphrase changes FOLLOW into the store wrap
//  (`followVaultPassphrase`, wired to EncryptionSession's hook), and the
//  reset door runs the vault half FIRST where a vault is wired, refusing
//  whole when it cannot (a store and a vault under different passphrases
//  is exactly what "no second passphrase exists anywhere" forbids).
//

import Foundation
import Observation
import VariorumCore

@MainActor
@Observable
final class ProtectionController {
    nonisolated struct Configuration: Sendable {
        var scope: String
        var storeURL: URL?
        var gate: StoreLaunchGate
        /// The AUTOMATIC escrow reconcile runs only for the real store —
        /// PROVISIONAL (run record): a hosted test run boots the app host
        /// over the DEV store, and auto-writing dev keys into her iCloud
        /// Keychain on every test run is pollution; the escrow DIAL's
        /// deliberate acts still work on any variant.
        var isRealVariant: Bool
        /// The KDF parameters a fresh wrap mints (tests inject small ones;
        /// production takes the v1 default per set).
        var makeKDF: @Sendable () -> PassphraseKDF.Descriptor = {
            .v1(salt: PassphraseKDF.randomSalt())
        }
    }

    private let configuration: Configuration
    private let guardSeam: StoreKeyGuard
    private var gate: StoreLaunchGate { configuration.gate }
    private var scope: String { configuration.scope }

    /// The current dials, projected for the pane (writes persist).
    private(set) var dials: ProtectionDials
    /// The envelope's projected facts (the pane and the notices read these).
    private(set) var hasPassphraseWrap = false
    private(set) var hasRecoveryWrap = false
    private(set) var busy = false
    var lastError: String?

    /// The resident key under the DEMANDED modes (adopted at unlock,
    /// dropped at lock). Under Auto the Keychain releases on demand and
    /// nothing is cached here.
    @ObservationIgnored private var residentKey: StoreKey?

    /// Wired by AppBootstrap: the lock act (demanded modes only; the
    /// callee re-checks).
    @ObservationIgnored var performLock: (@MainActor () async -> Void)?
    /// Wired where a vault is enrolled (AppServices): re-wrap the VAULT
    /// master under a new passphrase using held material — the reset
    /// door's vault half. Throws = the reset refuses WHOLE (one secret).
    @ObservationIgnored var rewrapVaultPassphrase: ((String) async throws -> Void)?

    // MARK: - Notices (the nudge + the reminder)

    enum Notice: Equatable {
        /// Standard's two-offer nudge (knot 4's amendment).
        case nudge
        /// R13p-9's "do you still remember your passphrase?".
        case reminderDue
    }

    private(set) var notice: Notice?

    init(configuration: Configuration) {
        self.configuration = configuration
        self.guardSeam = configuration.gate.guardFor(configuration.scope)
        self.dials = configuration.gate.dials(configuration.scope)
        refreshEnvelopeFacts()
    }

    var biometryAvailable: Bool { guardSeam.biometryAvailable() }

    /// Which preset the dials currently read as (nil = hand-adjusted).
    var matchingPreset: ProtectionPreset? {
        ProtectionPreset.matching(dials, biometryAvailable: biometryAvailable)
    }

    // MARK: - Resident key custody (the bootstrap's two calls)

    func adoptResident(_ key: StoreKey?) {
        residentKey = key
    }

    func dropResident() {
        residentKey = nil
    }

    /// The key in hand right now: the resident (demanded modes, unlocked)
    /// or the Auto item's silent release. nil = no act that needs the key
    /// can run (worded by callers).
    private func currentKey() -> StoreKey? {
        residentKey ?? guardSeam.loadAuto()
    }

    private func refreshEnvelopeFacts() {
        let envelope = loadEnvelope()
        hasPassphraseWrap = envelope?.passphrase != nil
        hasRecoveryWrap = envelope?.recovery != nil
    }

    private func loadEnvelope() -> StoreKeyEnvelope? {
        guard let url = configuration.storeURL else { return scriptedLoad() }
        return (try? gate.loadEnvelope(url)) ?? nil
    }

    private func scriptedLoad() -> StoreKeyEnvelope? {
        (try? gate.loadEnvelope(URL(fileURLWithPath: "/dev/null"))) ?? nil
    }

    private func saveEnvelope(_ envelope: StoreKeyEnvelope) throws {
        try gate.saveEnvelope(
            envelope, configuration.storeURL ?? URL(fileURLWithPath: "/dev/null"))
    }

    /// Load-or-create the envelope FOR `key`. A sidecar whose fingerprint
    /// contradicts the key is FOREIGN (copied from another library, or
    /// left behind by a deleted store) — it is set ASIDE, never deleted:
    /// its wraps are somebody's recovery legs.
    private func ensuredEnvelope(for key: StoreKey) -> StoreKeyEnvelope {
        if let existing = loadEnvelope() {
            if existing.belongs(to: key) { return existing }
            gate.setAsideEnvelope(configuration.storeURL ?? URL(fileURLWithPath: "/dev/null"))
        }
        return StoreKeyEnvelope()
    }

    // MARK: - The passphrase (set · follow · reset)

    /// Land the passphrase wrap (the set-screen's act). The heavy KDF
    /// runs off the main actor. Returns the worded refusal, nil = landed.
    @discardableResult
    func setPassphrase(_ passphrase: String) async -> String? {
        guard !passphrase.isEmpty else { return "Type a passphrase first." }
        guard let key = currentKey() else { return Self.keyUnavailable }
        var envelope = ensuredEnvelope(for: key)
        let kdf = configuration.makeKDF()
        do {
            envelope = try await Task.detached(priority: .userInitiated) {
                [envelope] () throws -> StoreKeyEnvelope in
                var updated = envelope
                try updated.setPassphraseWrap(key: key, passphrase: passphrase, kdf: kdf)
                return updated
            }.value
            try saveEnvelope(envelope)
            gate.setStamp(Date(), Self.passphraseSetAtStamp, scope)
            refreshEnvelopeFacts()
            refreshNotices()
            return nil
        } catch {
            return ProtectionCopy.message(for: error)
        }
    }

    /// ONE SECRET, the following direction: the vault's passphrase was
    /// set/enrolled/changed with `passphrase` — the store wrap follows so
    /// the two can never diverge. Quiet (a hook, not a surface); a
    /// failure leaves the old wrap standing and the next hook retries.
    func followVaultPassphrase(_ passphrase: String) async {
        _ = await setPassphrase(passphrase)
    }

    /// ONE SECRET, the guarding direction: does `passphrase` unwrap the
    /// STORE wrap? nil = no wrap exists (nothing to guard); the vault
    /// setup uses this to refuse minting a SECOND passphrase.
    func verifyPassphraseAgainstStore(_ passphrase: String) async -> Bool? {
        guard let envelope = loadEnvelope(), envelope.passphrase != nil else { return nil }
        return await Task.detached(priority: .userInitiated) {
            (try? envelope.unwrapKey(passphrase: passphrase)) != nil
        }.value
    }

    /// THE RESET DOOR (R13p-9): forgot the passphrase — any enrolled
    /// device re-wraps under a new one after BIOMETRIC confirmation, no
    /// old passphrase needed (the envelope's whole point). The vault half
    /// runs FIRST where wired (one secret): a vault that cannot be
    /// re-wrapped refuses the WHOLE reset rather than diverging; a store
    /// half that then fails leaves the vault ahead — re-running the door
    /// heals (the vault re-wrap from held material is idempotent).
    /// Returns the worded refusal, nil = reset landed.
    @discardableResult
    func resetPassphrase(to newPassphrase: String) async -> String? {
        guard !newPassphrase.isEmpty else { return "Type the new passphrase first." }
        guard hasPassphraseWrap else {
            return "No passphrase is set yet — use Set a Passphrase instead."
        }
        guard biometryAvailable else {
            return "Resetting needs Touch ID to confirm it's you. Without it, use "
                + "your recovery phrase: checking it here proves it still works, and "
                + "the change-passphrase door accepts it."
        }
        guard await guardSeam.confirmPresence(
            "Confirm it's you to reset your encryption passphrase") else {
            return "Not confirmed — nothing was changed."
        }
        if let rewrapVaultPassphrase {
            do {
                try await rewrapVaultPassphrase(newPassphrase)
            } catch {
                return "Your account's vault couldn't be moved to the new passphrase "
                    + "(\(EncryptionSession.message(for: error))) — nothing was changed: "
                    + "one passphrase serves both, so the reset waits until it can do both."
            }
        }
        return await setPassphrase(newPassphrase)
    }

    // MARK: - The recovery phrase (knot 4: generated and shown at the set-screen)

    /// Mint the twelve words, wrap the store key under them, land the
    /// wrap, and hand the words back FOR DISPLAY — the one moment they
    /// exist outside the user's own writing-down. nil = refused (worded
    /// in `lastError`).
    func generateAndLandRecoveryPhrase() async -> [String]? {
        guard let key = currentKey() else {
            lastError = Self.keyUnavailable
            return nil
        }
        do {
            let words = try RecoveryPhrase.generate()
            var envelope = ensuredEnvelope(for: key)
            try envelope.setRecoveryWrap(key: key, words: words)
            try saveEnvelope(envelope)
            refreshEnvelopeFacts()
            refreshNotices()
            return words
        } catch {
            lastError = ProtectionCopy.message(for: error)
            return nil
        }
    }

    /// Land TYPED words as the store's recovery wrap — the road for a
    /// vault-enrolled user whose twelve words already exist (one secret:
    /// never a second phrase; the caller verifies them against the vault
    /// first where one exists). Returns the worded refusal, nil = landed.
    @discardableResult
    func landRecoveryWrap(words: [String]) async -> String? {
        guard let key = currentKey() else { return Self.keyUnavailable }
        do {
            var envelope = ensuredEnvelope(for: key)
            try envelope.setRecoveryWrap(key: key, words: words)
            try saveEnvelope(envelope)
            refreshEnvelopeFacts()
            refreshNotices()
            return nil
        } catch {
            return ProtectionCopy.message(for: error)
        }
    }

    // MARK: - The at-open mode (the custody law)

    enum ModeChangeOutcome: Equatable {
        case changed
        /// The demanded modes need a passphrase first (Biometric's
        /// fallback IS the passphrase; Passphrase-every-open obviously) —
        /// the pane summons the set-screen, then retries.
        case needsPassphrase
        case refused(String)
    }

    @discardableResult
    func setMode(_ newMode: StoreAtOpenMode) async -> ModeChangeOutcome {
        guard newMode != dials.mode else { return .changed }
        if newMode.isDemanded {
            guard hasPassphraseWrap else { return .needsPassphrase }
        }
        guard let key = currentKey() else { return .refused(Self.keyUnavailable) }
        switch newMode {
        case .auto:
            guard guardSeam.saveAuto(key) else {
                return .refused("The Keychain refused the change — nothing was altered.")
            }
            guardSeam.deleteGated()
        case .biometric:
            guard biometryAvailable else {
                return .refused("This Mac has no Touch ID to gate the key with — "
                    + "use Passphrase at every open instead.")
            }
            // The gated item lands FIRST; only then does the silent item
            // go (never a keyless moment, never a silent one either).
            guard guardSeam.saveGated(key) else {
                return .refused("The Keychain refused the gated item — nothing was altered.")
            }
            guardSeam.deleteAuto()
        case .passphrase:
            guardSeam.deleteAuto()
            guardSeam.deleteGated()
        }
        dials.mode = newMode
        persistDials()
        return .changed
    }

    // MARK: - The escrow dial (R13p-6)

    /// Returns false with `lastError` worded on refusal.
    @discardableResult
    func setEscrow(_ on: Bool) async -> Bool {
        if on {
            guard let key = currentKey() else {
                lastError = Self.keyUnavailable
                return false
            }
            var envelope = ensuredEnvelope(for: key)
            if loadEnvelope() != envelope {
                // A fresh envelope needs to exist on disk so its storeID
                // names the item durably.
                do { try saveEnvelope(envelope) } catch {
                    lastError = ProtectionCopy.message(for: error)
                    return false
                }
            }
            guard guardSeam.saveEscrow(key, envelope.storeID) else {
                lastError = "The Keychain refused the iCloud item — nothing was altered."
                return false
            }
        } else if let envelope = loadEnvelope() {
            guardSeam.deleteEscrow(envelope.storeID)
        }
        dials.escrowOn = on
        persistDials()
        return true
    }

    // MARK: - Presets (R13p-7: dial-setters)

    @discardableResult
    func applyPreset(_ preset: ProtectionPreset) async -> ModeChangeOutcome {
        let target = preset.dials(biometryAvailable: biometryAvailable)
        if target.mode.isDemanded, !hasPassphraseWrap { return .needsPassphrase }
        let modeOutcome = await setMode(target.mode)
        guard modeOutcome == .changed else { return modeOutcome }
        _ = await setEscrow(target.escrowOn)
        dials.relockOnSleepAndScreenLock = target.relockOnSleepAndScreenLock
        dials.relockAfterIdleMinutes = target.relockAfterIdleMinutes
        dials.reminderChecksOn = target.reminderChecksOn
        persistDials()
        refreshNotices()
        return .changed
    }

    /// The re-lock dials' setters (demanded modes; the pane renders them
    /// only there).
    func setRelockOnSleep(_ on: Bool) {
        dials.relockOnSleepAndScreenLock = on
        persistDials()
    }

    func setRelockIdleMinutes(_ minutes: Int?) {
        dials.relockAfterIdleMinutes = minutes
        persistDials()
    }

    func setReminderChecks(_ on: Bool) {
        dials.reminderChecksOn = on
        persistDials()
        refreshNotices()
    }

    private func persistDials() {
        gate.saveDials(dials, scope)
    }

    // MARK: - The launch reconcile

    /// Idempotent launch housekeeping, called once the store is READY
    /// (never before unlock): stamp first use (the nudge's "real use
    /// begins" anchor), keep the escrow item consistent with its dial
    /// (real store only — see Configuration.isRealVariant), and refresh
    /// the notice state.
    func reconcile(now: Date = Date()) async {
        if gate.stamp(Self.firstUseStamp, scope) == nil {
            gate.setStamp(now, Self.firstUseStamp, scope)
        }
        refreshEnvelopeFacts()
        if configuration.isRealVariant {
            if dials.escrowOn {
                if let key = currentKey() {
                    let envelope = ensuredEnvelope(for: key)
                    if loadEnvelope() == nil || loadEnvelope() != envelope {
                        try? saveEnvelope(envelope)
                    }
                    if guardSeam.loadEscrow(envelope.storeID) != key {
                        _ = guardSeam.saveEscrow(key, envelope.storeID)
                    }
                }
            } else if let envelope = loadEnvelope() {
                // The dial is OFF: a leftover item (a crashed flip) goes.
                guardSeam.deleteEscrow(envelope.storeID)
            }
        }
        refreshNotices(now: now)
    }

    // MARK: - Notices

    func refreshNotices(now: Date = Date()) {
        if ReminderCheckPolicy.isDue(
            now: now,
            enabled: dials.reminderChecksOn,
            passphraseSetAt: gate.stamp(Self.passphraseSetAtStamp, scope),
            lastConfirmedAt: gate.stamp(Self.reminderConfirmedStamp, scope),
            lastDismissedAt: gate.stamp(Self.reminderDismissedStamp, scope)) {
            notice = .reminderDue
            return
        }
        if StandardNudgePolicy.isEligible(
            now: now,
            firstUseAt: gate.stamp(Self.firstUseStamp, scope),
            dismissedForever: gate.stamp(Self.nudgeDismissedStamp, scope) != nil,
            snoozedUntil: gate.stamp(Self.nudgeSnoozeStamp, scope),
            hasPassphraseWrap: hasPassphraseWrap,
            hasRecoveryWrap: hasRecoveryWrap) {
            notice = .nudge
            return
        }
        notice = nil
    }

    func snoozeNudge(now: Date = Date()) {
        gate.setStamp(now.addingTimeInterval(StandardNudgePolicy.snooze),
                      Self.nudgeSnoozeStamp, scope)
        refreshNotices(now: now)
    }

    func dismissNudgeForever(now: Date = Date()) {
        gate.setStamp(now, Self.nudgeDismissedStamp, scope)
        refreshNotices(now: now)
    }

    /// The reminder's outcomes: a CONFIRMED check (the SecretCheck face
    /// answered "correct") resets the cadence; a dismissal snoozes one
    /// full cadence (the policy's letter).
    func recordReminderConfirmed(now: Date = Date()) {
        gate.setStamp(now, Self.reminderConfirmedStamp, scope)
        refreshNotices(now: now)
    }

    func dismissReminder(now: Date = Date()) {
        gate.setStamp(now, Self.reminderDismissedStamp, scope)
        refreshNotices(now: now)
    }

    /// The reminder face's local check road (SecretCheckModel's
    /// `storeCheck` — one face serves the sanity check AND the reminder,
    /// the plan's letter): the REAL unwrap against the sidecar, off-main,
    /// result discarded. Confirmations feed the cadence automatically.
    func makeStoreSecretCheck() -> @Sendable (SecretCheckModel.Secret, String) async
        -> SecretCheckModel.LocalOutcome {
        let gate = gate
        let storeURL = configuration.storeURL
        return { secret, entry in
            let outcome: SecretCheckModel.LocalOutcome = await Task.detached(
                priority: .userInitiated
            ) {
                do {
                    guard let envelope = try gate.loadEnvelope(
                        storeURL ?? URL(fileURLWithPath: "/dev/null")) else {
                        return .couldNotCheck(
                            "This library has no passphrase or recovery phrase on file yet.")
                    }
                    switch secret {
                    case .passphrase:
                        _ = try envelope.unwrapKey(passphrase: entry)
                    case .recoveryPhrase:
                        _ = try envelope.unwrapKey(
                            recoveryWords: EncryptionSession.words(from: entry))
                    }
                    return .correct
                } catch StoreKeyEnvelopeError.wrongPassphrase {
                    return .wrong
                } catch StoreKeyEnvelopeError.wrongRecoveryPhrase {
                    return .wrong
                } catch {
                    return .couldNotCheck(ProtectionCopy.message(for: error))
                }
            }.value
            return outcome
        }
    }

    // MARK: - Re-lock monitors (Mac — sleep · screen lock · idle)

    #if os(macOS)
    @ObservationIgnored private var monitorTokens: [NSObjectProtocol] = []
    @ObservationIgnored private var idleTask: Task<Void, Never>?

    /// Started by the production bootstrap only (never test instances):
    /// each trigger re-checks the dials at FIRE time, so the monitors are
    /// always-on listeners over always-current policy.
    func startRelockMonitors() {
        stopRelockMonitors()
        let workspace = NSWorkspace.shared.notificationCenter
        monitorTokens.append(workspace.addObserver(
            forName: NSWorkspace.willSleepNotification, object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in await self?.relockIfPolicySays() }
        })
        monitorTokens.append(DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name("com.apple.screenIsLocked"),
            object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in await self?.relockIfPolicySays() }
        })
        idleTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(30))
                await self?.relockIfIdle()
            }
        }
    }

    func stopRelockMonitors() {
        let workspace = NSWorkspace.shared.notificationCenter
        for token in monitorTokens {
            workspace.removeObserver(token)
            DistributedNotificationCenter.default().removeObserver(token)
        }
        monitorTokens = []
        idleTask?.cancel()
        idleTask = nil
    }

    private func relockIfPolicySays() async {
        guard dials.mode.isDemanded, dials.relockOnSleepAndScreenLock else { return }
        await performLock?()
    }

    private func relockIfIdle() async {
        guard dials.mode.isDemanded,
              let minutes = dials.relockAfterIdleMinutes, minutes > 0 else { return }
        let idle = CGEventSource.secondsSinceLastEventType(
            .combinedSessionState, eventType: CGEventType(rawValue: ~0)!)
        guard idle >= Double(minutes * 60) else { return }
        await performLock?()
    }
    #endif

    // MARK: - Stamps & wording

    static let firstUseStamp = "firstUseAt"
    static let passphraseSetAtStamp = "passphraseSetAt"
    static let reminderConfirmedStamp = "reminderConfirmedAt"
    static let reminderDismissedStamp = "reminderDismissedAt"
    static let nudgeSnoozeStamp = "nudgeSnoozedUntil"
    static let nudgeDismissedStamp = "nudgeDismissedForever"

    static let keyUnavailable =
        "This library's key isn't in hand right now — unlock the library first."
}

#if os(macOS)
import AppKit
import CoreGraphics
#endif

/// The reset door's vault half, refused because this device's key
/// material is locked or absent — worded through
/// `EncryptionSession.message(for:)`'s describing arm.
nonisolated struct VaultRewrapNeedsUnlockedKeys: Error, CustomStringConvertible {
    var description: String {
        "this device's keys are locked — unlock them under Settings ▸ Encryption "
        + "and try again"
    }
}
