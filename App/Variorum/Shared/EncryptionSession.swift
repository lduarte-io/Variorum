//
//  EncryptionSession.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 14b, batch 3 (L9) — the E2EE flows' observable state, ONE seam
//  serving Mac AND phone (PL-6: identical UX both form factors, the 14a
//  AccountView precedent). The testable machinery lives in
//  `VaultEnrollment` (core); this type is the UI-facing composition: state
//  projection, custody hand-off to the Keychain, and the wording every
//  refusal speaks. No business rules live here.
//
//  Cadence (R-6): flows run at setup/enrollment/change moments only — the
//  one-time unwrap persists in the device Keychain and day-to-day sync
//  never touches this type.
//
//  Phase 14b COPY/FLOW ROUND: the forget door (CF-11 — clear custody, the
//  engine refuses visibly again), the biometric unlock policy (CF-12's
//  ruling — biometric or the passphrase, never the passcode; once per
//  launch; the `enrolledLocked` state), and the passphrase-authorized
//  phrase regenerate (CF-2 — the surface's rules made coherent).
//

import Foundation
import Observation
import os
import VariorumCore

@MainActor
@Observable
final class EncryptionSession {
    /// The account's vault + this device's custody, as one projected state.
    enum VaultState: Equatable {
        /// Not yet refreshed (or the last refresh failed — `lastError`).
        case unknown
        /// No Variorum session: the vault lives on the account (R-1), so
        /// every flow starts with sign-in.
        case signedOut
        /// Signed in, no vault row → SETUP is the offered flow.
        case noVault
        /// A vault exists; this device holds no keys → ENROLLMENT.
        case notEnrolled(hasRecoveryWrap: Bool)
        /// This device holds the unwrapped keys (Keychain custody).
        case enrolled(hasRecoveryWrap: Bool)
        /// CF-12: custody exists behind the biometric gate and this launch
        /// has not unlocked yet — sync waits; the surface offers the
        /// biometric unlock with the passphrase road beside it.
        case enrolledLocked(hasRecoveryWrap: Bool)
        /// The vault was written by a newer build — refuse by version.
        case newerFormat(Int)
    }

    private(set) var state: VaultState = .unknown
    private(set) var busy = false
    var lastError: String?
    /// L12: the last passphrase-KDF derivation's wall-clock seconds ON THIS
    /// DEVICE — surfaced on the flow (and os_log) so the gate reads the
    /// on-device number straight off the enrollment/setup surface.
    private(set) var lastKDFSeconds: Double?
    /// CF-12: the device-local unlock policy, projected for the toggle.
    /// Seeded at `refresh()` — deliberately NOT at init: a Keychain probe
    /// at construction is the GM-1 stall class (synchronous securityd wait
    /// inside `AppServices.init`), and every reader renders post-refresh.
    private(set) var biometricRequired = false

    /// Fired after key material lands, changes, or is FORGOTTEN on this
    /// device — the app triggers a sync round so the engine's keys-refusal
    /// heals immediately (or, after forget, surfaces the locked line
    /// immediately instead of a stale reading).
    var onKeysChanged: (() -> Void)?

    private let store: DeviceKeyStore
    /// nil = the project is unconfigured (ProjectConfig keys empty) — the
    /// flows stay dormant exactly like the sign-in surface.
    private let client: KeyVaultClient?
    private let signedIn: @Sendable () async -> Bool
    private let logger = Logger(subsystem: "io.lduarte.Variorum", category: "e2ee")

    init(
        store: DeviceKeyStore,
        client: KeyVaultClient?,
        signedIn: @escaping @Sendable () async -> Bool
    ) {
        self.store = store
        self.client = client
        self.signedIn = signedIn
    }

    var isEnrolled: Bool { store.load() != nil }
    /// CF-12: whether the biometric toggle is even offerable here.
    var biometryAvailable: Bool { store.biometryAvailable() }

    // MARK: - State refresh

    /// Projects the current vault + custody state. Network happens only
    /// here and in the flows — never at construction.
    func refresh() async {
        guard let client else { return }
        biometricRequired = store.isBiometricGateOn()
        guard await signedIn() else {
            state = .signedOut
            return
        }
        do {
            let vault = try await client.fetchVault()
            let unlocked = store.load() != nil
            switch vault {
            case nil:
                state = .noVault
            case let vault?:
                let hasRecovery = vault.format.masterWrappedByRecovery != nil
                if unlocked {
                    state = .enrolled(hasRecoveryWrap: hasRecovery)
                } else if biometricRequired {
                    state = .enrolledLocked(hasRecoveryWrap: hasRecovery)
                } else {
                    state = .notEnrolled(hasRecoveryWrap: hasRecovery)
                }
            }
        } catch KeyVaultClientError.unsupportedFormatVersion(let version) {
            state = .newerFormat(version)
        } catch {
            lastError = Self.message(for: error)
        }
    }

    // MARK: - The flows (each hands custody to the Keychain, then heals sync)

    /// SETUP (first device): create the vault — passphrase wrap ONLY
    /// (Round 5); the recovery phrase is the flow's own MANDATORY next step
    /// (CF-5): the resulting `enrolled(hasRecoveryWrap: false)` state IS
    /// step 4, and the surface cannot complete setup without landing it.
    func setUp(passphrase: String) async {
        await runFlow { enrollment in
            let material = try await enrollment.setUp(passphrase: passphrase)
            self.adopt(material)
            self.state = .enrolled(hasRecoveryWrap: false)
        }
    }

    /// ENROLLMENT (new device, R-4): passphrase → unwrap → Keychain. Under
    /// the biometric gate this is also the fallback road (CF-12): the save
    /// keeps the gate on and unlocks the launch.
    func enroll(passphrase: String) async {
        await runFlow { enrollment in
            let material = try await enrollment.enroll(passphrase: passphrase)
            self.adopt(material)
            let hasRecovery = (try? await enrollment.hasRecoveryWrap()) ?? false
            self.state = .enrolled(hasRecoveryWrap: hasRecovery)
        }
    }

    /// The disaster road: the 12 written words alone unwrap this device.
    func enroll(recoveryWordsText: String) async {
        let words = Self.words(from: recoveryWordsText)
        await runFlow { enrollment in
            let material = try await enrollment.enroll(recoveryWords: words)
            self.adopt(material)
            self.state = .enrolled(hasRecoveryWrap: true)
        }
    }

    /// Mint 12 fresh words (pure — nothing lands until the CONFIRMED
    /// re-entry passes through `landRecoveryWrap`; Round 5 item 3's order).
    /// This ungated form serves the MANDATORY first generation only (the
    /// setup flow's step 4 — CF-5); REPLACING an existing phrase goes
    /// through `generatePhraseAuthorized` (CF-2).
    func generatePhrase() -> [String]? {
        do {
            return try RecoveryPhrase.generate()
        } catch {
            lastError = Self.message(for: error)
            return nil
        }
    }

    /// CF-2: REGENERATING the phrase is authorized by the passphrase — the
    /// same deliberateness class as changing it (an enrolled device already
    /// holds the keys, so the gate is about deliberateness, and the
    /// surface's rules read coherent only if replacing the disaster secret
    /// costs the same proof as the other vault-changing doors). Verifies by
    /// actually unwrapping master from the vault — never a local compare.
    func generatePhraseAuthorized(passphrase: String) async -> [String]? {
        await runFlow { enrollment in
            _ = try await enrollment.enroll(passphrase: passphrase)
            return try RecoveryPhrase.generate()
        }
    }

    /// Land the CONFIRMED words as the vault's recovery wrap. `allowReplace`
    /// is passed true only from the regenerate flow, which sits behind the
    /// CF-2 passphrase gate (Round 7: replacing the disaster road is a
    /// deliberate ceremony).
    func landRecoveryWrap(confirmedWords: [String], allowReplace: Bool) async {
        guard let material = store.load() else {
            lastError = "This device holds no keys — unlock with your passphrase first."
            return
        }
        await runFlow { enrollment in
            try await enrollment.landRecoveryWrap(
                words: confirmedWords, material: material, allowReplace: allowReplace)
            self.state = .enrolled(hasRecoveryWrap: true)
        }
    }

    /// CHANGE PASSPHRASE (Round 7's scope addition): authorized by the
    /// current passphrase OR the recovery phrase; recovery words untouched.
    /// The recovery road also enrolls (the forgot-passphrase path on a
    /// fresh device).
    func changePassphrase(authorization: VaultAuthorization, newPassphrase: String) async {
        await runFlow { enrollment in
            let material = try await enrollment.changePassphrase(
                authorizedBy: authorization, newPassphrase: newPassphrase)
            self.adopt(material)
            let hasRecovery = (try? await enrollment.hasRecoveryWrap()) ?? false
            self.state = .enrolled(hasRecoveryWrap: hasRecovery)
        }
    }

    // MARK: - Device custody doors (CF-11 · CF-12)

    /// CF-11's act (behind the surface's confirmed destructive door):
    /// custody, the launch cache, and the biometric gate all go — the
    /// account vault is untouched, so re-enrolling by passphrase or
    /// recovery phrase restores this device. Fires the keys hook so the
    /// engine's next round refuses VISIBLY right away: the sync face
    /// returns to its locked line, never a stale "synced" reading.
    func forgetDeviceKeys() async {
        store.clear()
        biometricRequired = false
        onKeysChanged?()
        await refresh()
    }

    /// CF-12: the once-per-launch biometric unlock. Failure is never a dead
    /// end — the surface offers the passphrase road beside this door.
    func unlockWithBiometrics() async {
        guard !busy else { return }
        busy = true
        lastError = nil
        defer { busy = false }
        guard await store.unlockWithBiometrics() != nil else {
            lastError = Self.biometricUnlockFailedMessage
            return
        }
        if case .enrolledLocked(let hasRecovery) = state {
            state = .enrolled(hasRecoveryWrap: hasRecovery)
        }
        onKeysChanged?()
    }

    /// CF-12: the device-local policy toggle's act. Needs the unlocked
    /// material (the toggle lives on the enrolled surface); re-persists
    /// custody under the new policy. Never touches the vault, the format,
    /// or the protocol — R-6's device-local promise, kept.
    func setBiometricRequirement(_ required: Bool) {
        guard let material = store.load() else {
            lastError = "Unlock this device's keys first."
            return
        }
        guard store.setBiometricGate(required, material) else {
            lastError = "The device Keychain refused the change — nothing was altered."
            return
        }
        biometricRequired = required
    }

    // MARK: - Plumbing

    /// Split a typed-in phrase on any whitespace (the entry surface is one
    /// field; `RecoveryPhrase.validate` does the trimming/casefolding).
    static func words(from text: String) -> [String] {
        text.split(whereSeparator: \.isWhitespace).map(String.init)
    }

    private func adopt(_ material: DeviceKeyMaterial) {
        if !store.save(material) {
            // Keychain refusal is exceptional; the keys still work for this
            // process' healing round, but custody must be visible.
            lastError = "The device Keychain refused to store the keys — sync will ask again next launch."
        }
        onKeysChanged?()
    }

    @discardableResult
    private func runFlow<T>(_ body: (VaultEnrollment) async throws -> T) async -> T? {
        guard let client else {
            lastError = "Project keys not configured (ProjectConfig.swift)"
            return nil
        }
        guard !busy else { return nil }  // the account form's double-tap belt
        busy = true
        lastError = nil
        defer { busy = false }
        let enrollment = VaultEnrollment(client: client, kdfMeasurement: { seconds in
            Task { @MainActor [weak self] in
                self?.lastKDFSeconds = seconds
                self?.logger.info("Passphrase KDF derivation: \(seconds, format: .fixed(precision: 3)) s on this device")
            }
        })
        do {
            return try await body(enrollment)
        } catch {
            lastError = Self.message(for: error)
            return nil
        }
    }

    // MARK: - Wording (every refusal speaks — the R94 doctrine)

    /// CF-12: the biometric-failed line — names the fallback, which the
    /// surface offers right beneath it.
    static let biometricUnlockFailedMessage =
        "Biometric unlock didn't go through — enter your encryption passphrase instead."

    static func message(for error: any Error) -> String {
        switch error {
        case VaultEnrollmentError.wrongPassphrase:
            return "Wrong encryption passphrase."
        case VaultEnrollmentError.wrongRecoveryPhrase:
            return "That recovery phrase doesn't unlock this account's vault."
        case VaultEnrollmentError.emptyPassphrase:
            return "The passphrase can't be empty."
        case RecoveryPhraseError.checksumMismatch:
            return "That phrase has a typo somewhere — its built-in check failed. Compare it word by word with what you wrote down."
        case RecoveryPhraseError.unknownWord(let word):
            return "“\(word)” isn't a recovery-phrase word — check its spelling."
        case RecoveryPhraseError.invalidWordCount(let count):
            return "A recovery phrase is exactly 12 words — you entered \(count)."
        case KeyVaultClientError.vaultAbsent:
            return "No encryption vault exists for this account yet — run setup first."
        case KeyVaultClientError.vaultAlreadyExists:
            return "This account already has an encryption vault — enroll with its passphrase instead."
        case KeyVaultClientError.unsupportedFormatVersion:
            return "This account's encryption was set up by a newer version of Variorum — update the app first."
        case KeyVaultClientError.vaultRevisionConflict:
            // R1-2's CAS refusal: the caller must go back to CURRENT state.
            return "The vault just changed on another device — nothing was overwritten. Try again from the current state."
        case KeyVaultError.recoveryWrapAlreadyPresent:
            return "A recovery phrase already exists — replacing it is a deliberate step (use Regenerate)."
        case is URLError:
            return "Couldn't reach the server — check your connection and try again."
        default:
            return "Encryption step failed: \(String(describing: error))"
        }
    }

    /// The sync status row's locked-state classifier: true exactly for the
    /// engine's keys-refusal (`SyncError.encryptionKeysUnavailable`, which
    /// the scheduler surfaces verbatim via `String(describing:)`).
    static func isKeysLockedError(_ text: String) -> Bool {
        text == SyncError.encryptionKeysUnavailable.description
    }
}
