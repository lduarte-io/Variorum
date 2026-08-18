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
//  Phase 13e, batch 9 (ladder round B, B-1) — EVERY CUSTODY HOP LEAVES THE
//  MAIN THREAD. This type is `@MainActor` and used to call the store's
//  synchronous `SecItem*` closures inline on the four settings-cadence
//  paths the KnownIssues "Windowless launch" row names — refresh, adopt,
//  forget, toggle — so a stalled securityd (the row's captured
//  `ClientSession::decrypt` wait) would beachball the open sheet rather
//  than make it wait. Each of those calls now goes through
//  `DeviceKeyStore.offMain`, whose serial queue preserves the order they
//  always had; where two calls must stay ADJACENT (the toggle's
//  read-then-write) they travel inside ONE hop. Nothing about custody
//  semantics moves: same reads, same writes, same order, same wording.
//

import Foundation
import Observation
import os
import VariorumCore

/// 13e batch 9 (B-1): what the biometric toggle's ONE custody hop found —
/// carried out of the hop so the wording stays on the MainActor where it
/// belongs. File-scope (not nested) so it is plainly `Sendable`.
private enum BiometricGateOutcome: Sendable {
    case landed
    case noMaterial
    case refused
}

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
        /// CF-16 (crossover round): custody exists but holds keys the
        /// account no longer uses — the vault was RE-KEYED (deleted and set
        /// up fresh) after this device enrolled. Without this state the
        /// device reads "enrolled" while every round fails generically. The
        /// road is ordinary re-enrollment: the enroll save overwrites
        /// custody wholesale (the step-0 pin's proven class).
        case keysReplaced(hasRecoveryWrap: Bool)
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

    /// Phase 14c (CF-8): the re-key door's runner, injected by the
    /// composition root (AppServices wires the real `AccountRekey` brain
    /// with sync paused around it; nil = the door stays dormant, exactly
    /// like an unconfigured client). CONTRACT: the runner adopts custody
    /// mid-run through `adoptRekeyedMaterial` — before its truncate — and
    /// returns only when the whole road (new vault → truncate →
    /// resyncReinitialize → bridge staging) has run.
    var rekeyRunner: ((String) async throws -> DeviceKeyMaterial)?

    /// Ladder R1-1: the persisted rekey-in-progress read, injected by the
    /// composition root (a local `sync_state` read through the app's
    /// database — `AccountRekeyMarker`). nil = never set (unconfigured /
    /// tests that predate the marker).
    var rekeyIncompleteCheck: (@Sendable () async -> Bool)?
    /// Ladder R1-1: true when a re-key started on THIS device and never
    /// completed — the marker survives crash and relaunch, so the surface
    /// re-speaks the rerun road here (the banner + its direct Replace
    /// door) while the engine refuses rounds on the same fact.
    private(set) var rekeyIncomplete = false

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

    /// CF-12: whether the biometric toggle is even offerable here.
    ///
    /// 13e batch 9 (B-1), stated rather than silently left: this is the one
    /// store closure the fix does NOT move off the main thread. It is a
    /// `LAContext.canEvaluatePolicy` availability probe — not a `SecItem*`
    /// custody call, so it is outside the KnownIssues row's letter and
    /// outside the captured `ClientSession::decrypt` mechanism — and it is
    /// read from a view BODY, where an async value could only be served by
    /// seeding it at `refresh()` (the `biometricRequired` pattern), which
    /// would make the sheet's first pass claim "no biometrics on this Mac"
    /// until the refresh returned. Recorded for the architect to route.
    var biometryAvailable: Bool { store.biometryAvailable() }

    // MARK: - State refresh

    /// Projects the current vault + custody state. Network happens only
    /// here and in the flows — never at construction.
    func refresh() async {
        guard let client else { return }
        // Ladder R1-1: the persisted marker is re-projected on every
        // refresh — a crash mid-re-key must re-speak the rerun road on
        // the next launch, not stay silent behind an "enrolled" reading.
        rekeyIncomplete = await rekeyIncompleteCheck?() ?? false
        biometricRequired = await store.offMain { $0.isBiometricGateOn() }
        guard await signedIn() else {
            state = .signedOut
            return
        }
        do {
            let vault = try await client.fetchVault()
            let custody = await store.offMain { $0.load() }
            switch vault {
            case nil:
                state = .noVault
            case let vault?:
                let hasRecovery = vault.format.masterWrappedByRecovery != nil
                if let custody {
                    // CF-16 (the re-key blindness, closed): "enrolled" is no
                    // longer custody-exists alone — the custody must hold
                    // THIS vault's class keys. A device that slept through a
                    // re-key projects the honest REPLACED state instead of a
                    // false "enrolled" whose rounds fail generically. (A
                    // biometric-gated launch that hasn't unlocked cannot be
                    // compared — custody is unreadable — so it stays
                    // `enrolledLocked`; the mismatch surfaces at the first
                    // post-unlock refresh, and the sync row's classifier
                    // names the refusal meanwhile.)
                    state = Self.custodyMatchesVault(custody, vault.format)
                        ? .enrolled(hasRecoveryWrap: hasRecovery)
                        : .keysReplaced(hasRecoveryWrap: hasRecovery)
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
            await self.adopt(material)
            self.state = .enrolled(hasRecoveryWrap: false)
        }
    }

    /// ENROLLMENT (new device, R-4): passphrase → unwrap → Keychain. Under
    /// the biometric gate this is also the fallback road (CF-12): the save
    /// keeps the gate on and unlocks the launch.
    func enroll(passphrase: String) async {
        await runFlow { enrollment in
            let material = try await enrollment.enroll(passphrase: passphrase)
            await self.adopt(material)
            let hasRecovery = (try? await enrollment.hasRecoveryWrap()) ?? false
            self.state = .enrolled(hasRecoveryWrap: hasRecovery)
        }
    }

    /// The disaster road: the 12 written words alone unwrap this device.
    func enroll(recoveryWordsText: String) async {
        let words = Self.words(from: recoveryWordsText)
        await runFlow { enrollment in
            let material = try await enrollment.enroll(recoveryWords: words)
            await self.adopt(material)
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
        guard let material = await store.offMain({ $0.load() }) else {
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
            await self.adopt(material)
            let hasRecovery = (try? await enrollment.hasRecoveryWrap()) ?? false
            self.state = .enrolled(hasRecoveryWrap: hasRecovery)
        }
    }

    // MARK: - The re-key door (Phase 14c, CF-8 — THE DESIGN 3)

    /// CF-8: replace the account's encryption keys and re-upload the
    /// corpus. The heavy lifting and the ORDER OF OPERATIONS live in the
    /// injected runner (`AccountRekey`, pinned in core); this method is
    /// the flow's state machine: friction already passed (the surface's
    /// checkbox), busy handling, the refusal wording, and the landing —
    /// `enrolled(hasRecoveryWrap: false)`, which IS the standing CF-5
    /// mandatory-phrase step: the new 12 words are generated, written
    /// down, and confirmed exactly as at setup. The old phrase died with
    /// the old master, honestly.
    func rekeyAccount(passphrase: String) async {
        guard let rekeyRunner else {
            lastError = "Project keys not configured (ProjectConfig.swift)"
            return
        }
        guard !busy else { return }
        busy = true
        lastError = nil
        defer { busy = false }
        do {
            _ = try await rekeyRunner(passphrase)
            // Custody was adopted mid-run (the runner's contract); the
            // fresh vault has no recovery wrap yet — step 4 begins now.
            state = .enrolled(hasRecoveryWrap: false)
        } catch {
            // The brain's sequence is not atomic; the honest road back
            // from ANY mid-run failure is running the door again (the
            // rerun is pinned in core). Say so, plus the cause.
            lastError = "Key replacement didn't finish — nothing is lost; "
                + "run Replace Keys again to complete it. (\(Self.message(for: error)))"
        }
        // Ladder R1-1: re-read the persisted marker — a completed run
        // cleared it (the banner retires); a failed run left it set (the
        // banner joins the thrown-failure message and outlives it).
        rekeyIncomplete = await rekeyIncompleteCheck?() ?? false
    }

    /// The runner's custody adoption point (its contract: called after
    /// the NEW vault lands, before the truncate — this device must never
    /// be stale against its own new vault).
    ///
    /// 13e batch 9 (B-1): `async` now, because the custody save it performs
    /// hops off the main thread — and the runner AWAITS this call exactly
    /// as before, so the adopt-before-truncate contract is unchanged (it is
    /// in fact stronger: the await now covers the Keychain write itself).
    func adoptRekeyedMaterial(_ material: DeviceKeyMaterial) async {
        await adopt(material)
    }

    // MARK: - Device custody doors (CF-11 · CF-12)

    /// CF-11's act (behind the surface's confirmed destructive door):
    /// custody, the launch cache, and the biometric gate all go — the
    /// account vault is untouched, so re-enrolling by passphrase or
    /// recovery phrase restores this device. Fires the keys hook so the
    /// engine's next round refuses VISIBLY right away: the sync face
    /// returns to its locked line, never a stale "synced" reading.
    func forgetDeviceKeys() async {
        await store.offMain { $0.clear() }
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
    /// 13e batch 9 (B-1): `async` now, and the read and the re-persist ride
    /// ONE hop — inline on the MainActor nothing could interleave between
    /// them, and the single hop keeps exactly that. Every outcome's wording
    /// is byte-unchanged.
    func setBiometricRequirement(_ required: Bool) async {
        let outcome = await store.offMain { store -> BiometricGateOutcome in
            guard let material = store.load() else { return .noMaterial }
            return store.setBiometricGate(required, material) ? .landed : .refused
        }
        switch outcome {
        case .noMaterial:
            lastError = "Unlock this device's keys first."
        case .refused:
            lastError = "The device Keychain refused the change — nothing was altered."
        case .landed:
            biometricRequired = required
        }
    }

    // MARK: - Plumbing

    /// Split a typed-in phrase on any whitespace (the entry surface is one
    /// field; `RecoveryPhrase.validate` does the trimming/casefolding).
    static func words(from text: String) -> [String] {
        text.split(whereSeparator: \.isWhitespace).map(String.init)
    }

    /// CF-16: does this device's custody hold the FETCHED vault's class
    /// keys? A re-key (delete the vault, set up fresh) mints new key ids
    /// for both classes, so stale custody mismatches on the plaintext ids
    /// alone — no unwrap, no network beyond the fetch the caller already
    /// made. A vault missing either class entry counts as a mismatch too
    /// (custody claims keys the vault doesn't carry).
    nonisolated static func custodyMatchesVault(
        _ custody: DeviceKeyMaterial, _ vault: KeyVaultFormat
    ) -> Bool {
        vault.classKey(for: .corpus)?.keyID == custody.corpusKeyID
            && vault.classKey(for: .journalBridge)?.keyID == custody.journalBridgeKeyID
    }

    private func adopt(_ material: DeviceKeyMaterial) async {
        if !(await store.offMain { $0.save(material) }) {
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
        case SyncError.encryptionKeysReplaced:
            // Phase 14c: the server's fence refused an account act — the
            // vault moved under this device mid-step.
            return "This account's keys changed on another device — re-enroll with the current passphrase, then try again."
        case is URLError:
            return "Couldn't reach the server — check your connection and try again."
        default:
            return "Encryption step failed: \(String(describing: error))"
        }
    }

    /// The sync status row's locked-state classifier: true exactly for the
    /// engine's keys-refusal (`SyncError.encryptionKeysUnavailable`, which
    /// the scheduler surfaces verbatim via `String(describing:)`).
    /// (Nonisolated so the row's pure face model consults it directly.)
    nonisolated static func isKeysLockedError(_ text: String) -> Bool {
        text == SyncError.encryptionKeysUnavailable.description
    }

    /// CF-16's classifier arm (App-layer only — the engine is untouched):
    /// true for the engine's payload-crypto refusal
    /// (`SyncError.payloadCryptoFailure`) as the scheduler surfaces it —
    /// after a re-key, a stale device's rounds fail exactly here, so the
    /// row names the Encryption surface instead of a generic "Sync error".
    /// The case's description carries row coordinates (table/row/column/
    /// detail), so unlike `isKeysLockedError` this anchors on the
    /// description's two invariant segments; the conjunction excludes the
    /// other "Sync refused:"-family case (`unencryptedValueInEncryptedColumn`),
    /// which never means stale keys.
    nonisolated static func isPayloadCryptoError(_ text: String) -> Bool {
        text.hasPrefix("Sync refused: '")
            && text.contains("failed to encrypt/decrypt (")
    }

    /// Phase 14c — the fence's classifier arm: true exactly for the
    /// server's vault-key-id fence refusal (`SyncError.encryptionKeysReplaced`,
    /// which the transport classifies out of the VARIORUM_STALE_KEY_FENCE
    /// marker and the scheduler surfaces verbatim). The SAME CF-16
    /// replaced state as the payload-crypto arm above — the fence is that
    /// state's server-side trigger, catching a stale writer BEFORE any
    /// poison push instead of after a failed decrypt.
    nonisolated static func isKeysReplacedError(_ text: String) -> Bool {
        text == SyncError.encryptionKeysReplaced.description
    }

    /// Ladder R1-1 — the unfinished-re-key classifier: true exactly for
    /// the engine's persisted-marker refusal (`SyncError
    /// .accountRekeyIncomplete`), as the scheduler surfaces it verbatim.
    /// Deliberately its OWN row state, never the CF-16 replaced face:
    /// the replaced row's re-enroll prescription cannot complete a
    /// half-run re-key — only the door's rerun can.
    nonisolated static func isRekeyIncompleteError(_ text: String) -> Bool {
        text == SyncError.accountRekeyIncomplete.description
    }
}
