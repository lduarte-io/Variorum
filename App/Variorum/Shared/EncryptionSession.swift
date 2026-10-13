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

import CryptoKit
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
        /// This device holds the unwrapped keys (Keychain custody, or the
        /// session memory under Castle — pre-13x 1a: the E2EE custody is
        /// unlocked exactly when the library is, so no separate locked
        /// state exists).
        case enrolled(hasRecoveryWrap: Bool)
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
    /// Fired after key material lands, changes, or is FORGOTTEN on this
    /// device — the app triggers a sync round so the engine's keys-refusal
    /// heals immediately (or, after forget, surfaces the locked line
    /// immediately instead of a stale reading).
    var onKeysChanged: (() -> Void)?

    /// Phase 13p ladder R1-m3 (one secret — the PHRASE's following
    /// direction, `onPassphraseChanged`'s twin): fired with the twelve
    /// CONFIRMED words after the vault's recovery wrap lands. Wired by the
    /// composition root to `ProtectionController.landRecoveryWrap`, so the
    /// STORE envelope carries the SAME words — without it, a
    /// vault-enrolled user who generated their phrase through the vault
    /// flow held "the" twelve words that opened the account but not the
    /// library (the recorded Batch-2 phrase-divergence corner's mirror,
    /// closed).
    /// pre-13x 4a (ledger 53): the second argument is the VAULT's
    /// recovery-wrap digest as fetched after the land (nil = unreadable).
    var onRecoveryPhraseLanded: ((_ words: [String], _ recoveryWrapDigest: String?) async -> Void)?

    /// pre-13x 3a — the vault material's LANDING on the key file (the
    /// master copy + the vault's descriptor and corpus key id; the typed
    /// secret's copy): fired after setup, an enroll and a Connect, once M
    /// is in custody. Wired by `wireOneSecretHooks` to
    /// `ProtectionController.landVaultMaterial`.
    var onVaultMaterialLanded: ((VaultLanding) async -> Void)?

    /// pre-13x 3a (decision 17): the Connect door — opens the controller's
    /// adopt sheet; wired by the composition root (nil = not rendered, P-2).
    var connectDoor: (() -> Void)?
    /// pre-13x 3a — ENROLL's facts (the controller's reading at the last
    /// reconcile; nil = no face owed) and the two acts the tab's faces run:
    /// (c) a Standard-born library joining Castle RE-KEYS as it joins — the
    /// runner's follow with the typed secret (wired by the roots); (d) a
    /// Castle-born library joining Standard drops its gate after consent —
    /// the runner's follow into Standard (wired by the roots).
    var enrollFacts: (@MainActor () -> EnrollFacts?)?
    var joinCastleAct: (@MainActor (_ passphrase: String?, _ recoveryWords: [String]?) async throws -> Void)?
    var joinStandardAct: (@MainActor () async throws -> Void)?
    /// The iCloud key as this device reads it (the (d) join's silent road).
    var readAppleKey: (@Sendable () -> AppleKey?)?
    /// pre-13x 3a — SYNC SETUP's iCloud key: read, else MINTED and written
    /// (decision 3 — the first Standard library on this iCloud); nil = the
    /// Keychain refused (the setup refuses rather than birthing a vault
    /// without its Apple copy — a posture the user never chose).
    var readOrMintAppleKey: (@Sendable () -> AppleKey?)?
    /// pre-13x 3a — the STORE's facts and acts the setup ceremony composes
    /// (the library's passphrase and words, verified against the KEY FILE —
    /// corner 27; the descriptor the vault is born under — §3.6's
    /// derive-once). Wired by `wireOneSecretHooks`; nil = no store composed.
    var storeTie: StoreTie?
    /// The library's own posture (the key-file rule) — the setup ceremony
    /// speaks from it (corner 26).
    var libraryPosture: (@MainActor () -> Posture)?
    /// (d)'s *Cancel*: the consent declined for this process — the library
    /// stays unenrolled and Castle-shaped; the tab re-offers behind a door.
    var declinedStandardJoin = false
    /// pre-13x 3a: whether the rows' owner is another account (the
    /// controller's exact verdict) — the Encryption tab renders copy §3's
    /// sentence + the Connect door over every other arm while true.
    var libraryOwnerIsForeign: (@MainActor () -> Bool)?

    /// Phase 13p Batch 2 (one secret — the GUARDING direction): does this
    /// passphrase match the STORE's own wrap? Consulted before SETUP
    /// mints a vault: nil/absent = nothing to guard; false = refuse — a
    /// local-only user who set a store passphrase must not mint a
    /// DIFFERENT one for the account ("no second passphrase exists
    /// anywhere in the design").
    var storePassphraseGuard: ((String) async -> Bool?)?

    static let oneSecretMismatchMessage =
        "This library already has an encryption passphrase, and your account "
        + "must use the SAME one — one passphrase serves both. Type the "
        + "library's passphrase here (check it under Settings ▸ Protection "
        + "if you're unsure)."

    /// pre-13x 3b (copy §4; decisions 30 · 32 · 33): REPLACE ALL KEYS' door
    /// — opens the ceremony on the controller (`openSwitch(.replaceKeys)`,
    /// or the marker's resume when one is pending), wired by both roots;
    /// nil = not rendered (P-2). The 2c interim door (`rekeyRunner` /
    /// `rekeyAccount` — the passphrase alone, the words dropped) RETIRED
    /// with the runner's own guard (ledger 44). `passphraseInHand` /
    /// `wordsInHand`: the change and regenerate doors' checkbox hands the
    /// NEW secret over so the ceremony never asks for it again.
    var replaceKeysDoor: ((_ passphraseInHand: String?, _ wordsInHand: [String]?) -> Void)?
    /// pre-13x 3b: what the two re-wrap doors need from the library's
    /// controller (the posture and gate their forgot road reads, the
    /// presence confirm, the local-only roads, the key file's recorded
    /// descriptor) — wired by `wireOneSecretHooks`; nil = no doors (P-2).
    var keyDoorFacts: KeyDoorFacts?

    /// pre-13x 2c (§7): THE FOLLOW's door — the Encryption tab's
    /// keys-replaced section opens the follow (the controller's
    /// `openFollow`) instead of the 14c bare re-enroll, which would land M′
    /// WITHOUT the rotation, the re-key and the custody move the design
    /// requires. Wired by the composition root; nil = no runner (the old
    /// roads render, as in tests and unconfigured builds).
    var followDoor: (() -> Void)?
    /// RUN A batch A2, row 10 (ledger 54): whether that door will ASK for
    /// anything, so the Encryption tab's label can say what it will DO —
    /// the controller's one predicate, read through this leaf because this
    /// view has the session and not the controller. nil ⇒ the old label.
    var followDoorAsksNothing: (() -> Bool)?

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
    /// VX-110 (the ticket's item 2 — VX-99 round 3's NIT): the pending
    /// marker's ACT (`CeremonyAct(resuming:)`), so the banner and the sync
    /// row name what did not finish — entering Castle, a key replacement, a
    /// follow — never one act for every marker. Wired by `AppServices`
    /// beside `rekeyIncompleteCheck`; nil = no marker, an undecodable one,
    /// or no read wired (the faces keep their older words).
    var pendingCeremonyActCheck: (@Sendable () async -> CeremonyAct?)?
    /// The act as of the last refresh (nil while `rekeyIncomplete` is false).
    private(set) var rekeyIncompleteAct: CeremonyAct?

    /// The pending marker's act, read now (the sync row reads it on its own
    /// cadence — the Encryption tab's refresh may never have run).
    func readPendingCeremonyAct() async -> CeremonyAct? {
        await pendingCeremonyActCheck?() ?? nil
    }

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

    // MARK: - State refresh

    /// Projects the current vault + custody state. Network happens only
    /// here and in the flows — never at construction.
    func refresh() async {
        guard let client else { return }
        // Ladder R1-1: the persisted marker is re-projected on every
        // refresh — a crash mid-re-key must re-speak the rerun road on
        // the next launch, not stay silent behind an "enrolled" reading.
        rekeyIncomplete = await rekeyIncompleteCheck?() ?? false
        if rekeyIncomplete {
            rekeyIncompleteAct = await readPendingCeremonyAct()
        } else {
            rekeyIncompleteAct = nil
        }
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
                    // false "enrolled" whose rounds fail generically.
                    state = Self.custodyMatchesVault(custody, vault.format)
                        ? .enrolled(hasRecoveryWrap: hasRecovery)
                        : .keysReplaced(hasRecoveryWrap: hasRecovery)
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

    /// SETUP (the first device of an account — pre-13x 3a, copy §2a; the
    /// postures design decision 5): ONE core road — the vault BORN with the
    /// passphrase wrap, the recovery wrap (the twelve words REQUIRED — in
    /// hand from the ceremony: generated and confirmed, or the library's,
    /// typed) and, under a STANDARD library, the Apple-held copy of the
    /// master under the iCloud key (read, else minted; a refused Keychain
    /// refuses the setup — never a vault born Castle-shaped by accident);
    /// the vault's passphrase wrap under the KEY FILE's current descriptor
    /// (derive once); then custody and the key file through the landing.
    /// The 14b "passphrase wrap only, the wrap lands later" shape retires
    /// for this door.
    func setUp(passphrase: String, recoveryWords: [String]) async {
        guard !recoveryWords.isEmpty else {
            lastError = EncryptionSession.message(for: RecoveryPhraseError.invalidWordCount(0))
            return
        }
        // 13p one-secret guard: a store wrap that this passphrase does
        // NOT open refuses the setup before anything is minted.
        if let storePassphraseGuard,
           await storePassphraseGuard(passphrase) == false {
            lastError = Self.oneSecretMismatchMessage
            return
        }
        // The library's OWN posture gives the vault its shape (corner 26).
        // No posture in view (a store-less composition — no key file, no
        // Apple leaves wired) ⇒ no Apple road exists and the vault is born
        // without the copy; a STANDARD library whose A the Keychain will
        // not hold REFUSES the setup — never a vault born Castle-shaped for
        // a posture the user never chose.
        let posture = libraryPosture?()
        var appleHeld: (key: SymmetricKey, id: String)?
        if posture == .standard {
            guard let apple = readOrMintAppleKey?() else {
                lastError = Self.appleKeyRefusedAtSetup
                return
            }
            appleHeld = (apple.symmetricKey, apple.id)
        }
        let kdf = storeTie?.passphraseKDF() ?? .v1(salt: PassphraseKDF.randomSalt())
        await runFlow { enrollment in
            let material = try await enrollment.setUp(
                passphrase: passphrase, recoveryWords: recoveryWords, appleHeldCopy: appleHeld, kdf: kdf)
            // pre-13x 4a: the vault as born — its recovery-wrap digest rides
            // the key file's record (the words twin of the descriptor).
            let born = try await enrollment.client.fetchVault()
            _ = await self.adoptEnrolledMaterial(
                material, kdf: kdf, recoveryWrapDigest: born?.format.recoveryWrapDigest,
                typedPassphrase: passphrase, typedWords: recoveryWords, refreshing: false)
            self.state = .enrolled(hasRecoveryWrap: true)
        }
    }

    static let appleKeyRefusedAtSetup =
        "iCloud Keychain wouldn't hold the key on this \(ProtectionCopy.deviceName) — nothing was set up. "
        + "Turn on iCloud Keychain, or enter Castle first (Settings ▸ Protection) and set sync up there."

    /// ENROLLMENT (new device, R-4; copy §2d's Castle road — pre-13x 3a):
    /// passphrase → unwrap → custody under the current shape → the key
    /// file's master copy + the vault's descriptor, the P copy re-wrapped
    /// under the VAULT's descriptor (corner 27 — the account's passphrase
    /// becomes the library's; §3.6's derive-once) through the landing hook.
    /// A Standard-born library joining a CASTLE account takes (c)'s road
    /// instead — `joinCastle` — the tab routes by the facts.
    func enroll(passphrase: String) async {
        if enrollFacts?()?.standardBornJoinsCastle == true, joinCastleAct != nil {
            await joinCastle(passphrase: passphrase, recoveryWords: nil)
            return
        }
        await runFlow { enrollment in
            let material = try await enrollment.enroll(passphrase: passphrase)
            guard let fetched = try await enrollment.client.fetchVault() else { throw KeyVaultClientError.vaultAbsent }
            _ = await self.adoptEnrolledMaterial(
                material, kdf: fetched.format.kdf, recoveryWrapDigest: fetched.format.recoveryWrapDigest,
                typedPassphrase: passphrase, refreshing: false)
            let hasRecovery = fetched.format.masterWrappedByRecovery != nil
            self.state = .enrolled(hasRecoveryWrap: hasRecovery)
        }
    }

    /// The disaster road: the 12 written words alone unwrap this device
    /// (pre-13x 3a: the W copy lands on the key file beside the master copy).
    func enroll(recoveryWordsText: String) async {
        let words = Self.words(from: recoveryWordsText)
        if enrollFacts?()?.standardBornJoinsCastle == true, joinCastleAct != nil {
            do { _ = try RecoveryPhrase.recoveryWrapKey(words: words) } catch { lastError = Self.message(for: error); return }
            await joinCastle(passphrase: nil, recoveryWords: words)
            return
        }
        await runFlow { enrollment in
            let material = try await enrollment.enroll(recoveryWords: words)
            guard let fetched = try await enrollment.client.fetchVault() else { throw KeyVaultClientError.vaultAbsent }
            _ = await self.adoptEnrolledMaterial(
                material, kdf: fetched.format.kdf, recoveryWrapDigest: fetched.format.recoveryWrapDigest,
                typedWords: words, refreshing: false)
            self.state = .enrolled(hasRecoveryWrap: true)
        }
    }

    // MARK: - pre-13x 3a: the two directed joins (copy §2d; design §5's Enroll row)

    /// (c) A STANDARD-BORN library joining a CASTLE account: the follow's
    /// road with the secret just typed — M from the vault, custody, the
    /// library RE-KEYED (its old key file carried an iCloud copy), custody
    /// behind the gate, the old key file retired. Reuse, never a copy: the
    /// runner's `follow` IS this act.
    func joinCastle(passphrase: String?, recoveryWords: [String]?) async {
        guard let joinCastleAct else {
            lastError = "Project keys not configured (ProjectConfig.swift)"
            return
        }
        guard !busy else { return }
        busy = true
        lastError = nil
        defer { busy = false }
        do {
            try await joinCastleAct(passphrase, recoveryWords)
        } catch {
            lastError = Self.message(for: error)
        }
        await refresh()
    }

    /// (d) A CASTLE-BORN library joining a STANDARD account, after the
    /// consent sentence (decision 1 — never a stricter gate under a Standard
    /// account; corner 6): M by the iCloud key when it is the one the vault's
    /// copy is under (nothing typed), else by the typed secret; custody
    /// under the CURRENT shape + the key file's master copy; then the
    /// runner's follow into Standard (the key file's Apple copy under THIS
    /// device's A, custody → silent, re-lock off by derivation).
    func joinStandard(typedPassphrase: String? = nil, typedWords: [String]? = nil) async {
        guard let joinStandardAct else {
            lastError = "Project keys not configured (ProjectConfig.swift)"
            return
        }
        let joined = await runFlow { enrollment in
            guard let fetched = try await enrollment.client.fetchVault() else { throw KeyVaultClientError.vaultAbsent }
            let format = fetched.format
            let material: DeviceKeyMaterial
            if let apple = self.readAppleKey?(), apple.id == format.appleKeyID,
               let master = try? format.unwrapMaster(withAppleKey: apple.symmetricKey) {
                material = try CorpusRotation.materialFollowing(format, master: master)
            } else if let typedPassphrase, !typedPassphrase.isEmpty {
                material = try await enrollment.enroll(passphrase: typedPassphrase)
            } else if let typedWords, !typedWords.isEmpty {
                material = try await enrollment.enroll(recoveryWords: typedWords)
            } else {
                throw PostureSwitchError.secretRequired
            }
            _ = await self.adoptEnrolledMaterial(
                material, kdf: format.kdf, recoveryWrapDigest: format.recoveryWrapDigest,
                typedPassphrase: typedPassphrase, typedWords: typedWords, refreshing: false)
            try await joinStandardAct()
            self.declinedStandardJoin = false
        }
        _ = joined
        await refresh()
    }

    /// (d)'s *Cancel*: nothing moves; the tab re-offers behind a door.
    func declineStandardJoin() {
        declinedStandardJoin = true
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

    /// pre-13x ladder round 1, F2 (MAJOR-3 c — THE HEAL's write): re-land
    /// the vault's Apple-held copy of the master under `apple` in ONE
    /// proof-authorized write — `leaveCastle`'s shape: the master from this
    /// device's custody, `settingAppleHeldCopy`, the CAS on the fetched
    /// revision, the proof of the master this device holds. Called by the
    /// controller only on proof of a same-account duplicate (its rule);
    /// this method verifies nothing about the id — it writes what it is
    /// handed under the proof it holds. Returns whether the write landed.
    func relandAppleHeldCopy(under apple: AppleKey) async -> Bool {
        guard let client else { return false }
        guard let material = await store.offMain({ $0.load() }) else { return false }
        do {
            guard let fetched = try await client.fetchVault() else { return false }
            let updated = try fetched.format.settingAppleHeldCopy(
                masterKey: material.masterSymmetricKey, appleKey: apple.symmetricKey, appleKeyID: apple.id)
            try await client.updateVault(
                updated, expectedRevision: fetched.revision,
                keyProof: KeyProofMaterial(master: material.masterSymmetricKey))
            return true
        } catch {
            return false
        }
    }

    /// pre-13x 3b: the vault's facts a key door reads at its threshold —
    /// the descriptor (the retired-word classification) and the wrap; nil =
    /// no vault; a `URLError` is the offline refusal's (decision 9).
    func fetchVaultFacts() async throws -> (kdf: PassphraseKDF.Descriptor, hasRecoveryWrap: Bool)? {
        guard let client else { return nil }
        guard let fetched = try await client.fetchVault() else { return nil }
        return (fetched.format.kdf, fetched.format.masterWrappedByRecovery != nil)
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
        let landed: String?? = await runFlow { enrollment in
            try await enrollment.landRecoveryWrap(
                words: confirmedWords, material: material, allowReplace: allowReplace)
            self.state = .enrolled(hasRecoveryWrap: true)
            // pre-13x 4a (ledger 53): the vault's wrap as it now stands —
            // its digest rides the store's landing.
            return try? await enrollment.client.fetchVault()?.format.recoveryWrapDigest
        }
        // 13p ladder R1-m3 (one secret): the store wrap follows the SAME
        // words — only on a land that actually happened (`runFlow` returns
        // nil on refusal, so a rejected replace fires nothing).
        if let landed { await onRecoveryPhraseLanded?(confirmedWords, landed ?? nil) }
    }

    /// CHANGE PASSPHRASE (Round 7's scope addition): authorized by the
    /// current passphrase OR the recovery phrase; recovery words untouched.
    /// The recovery road also enrolls (the forgot-passphrase path on a
    /// fresh device).
    /// pre-13x 3b (copy §4; §3.6's derive-once): the key file's P copy
    /// follows under the SAME descriptor the vault's new wrap uses — the
    /// vault is re-fetched after the core act and the landing hook re-wraps
    /// the local copy under it (`reconcilePassphraseWrap`) and records the
    /// reconciliation; the 13p `onPassphraseChanged` road (a FRESH
    /// descriptor of the store's own — the lobby derived twice) is retired.
    func changePassphrase(authorization: VaultAuthorization, newPassphrase: String) async {
        await runFlow { enrollment in
            let material = try await enrollment.changePassphrase(
                authorizedBy: authorization, newPassphrase: newPassphrase)
            await self.adopt(material)
            guard let fetched = try await enrollment.client.fetchVault() else { throw KeyVaultClientError.vaultAbsent }
            self.state = .enrolled(hasRecoveryWrap: fetched.format.masterWrappedByRecovery != nil)
            await self.onVaultMaterialLanded?(VaultLanding(
                material: material, kdf: fetched.format.kdf, passphrase: newPassphrase,
                recoveryWrapDigest: fetched.format.recoveryWrapDigest))
        }
    }

    /// pre-13x 3b (copy §4's forgot roads; the 13p reset door MERGED here):
    /// re-wrap the vault's master under a NEW passphrase from this device's
    /// HELD material — no old passphrase; the authorization is the caller's
    /// (Touch ID / Face ID under Castle, the plain confirm under Standard).
    /// The key file's copy follows under the vault's new descriptor exactly
    /// as `changePassphrase` lands it. Returns the worded refusal.
    @discardableResult
    func rewrapPassphrase(newPassphrase: String) async -> String? {
        guard let material = await store.offMain({ $0.load() }) else {
            return VaultRewrapNeedsUnlockedKeys().description
        }
        await runFlow { enrollment in
            try await enrollment.rewrapPassphrase(material: material, newPassphrase: newPassphrase)
            guard let fetched = try await enrollment.client.fetchVault() else { throw KeyVaultClientError.vaultAbsent }
            self.state = .enrolled(hasRecoveryWrap: fetched.format.masterWrappedByRecovery != nil)
            await self.onVaultMaterialLanded?(VaultLanding(
                material: material, kdf: fetched.format.kdf, passphrase: newPassphrase,
                recoveryWrapDigest: fetched.format.recoveryWrapDigest))
        }
        return lastError
    }

    /// pre-13x 3a — the enroll/Connect landing: custody takes the material
    /// under the current shape, the state reads enrolled, and the key file
    /// follows through the landing hook (the master copy + the vault's
    /// descriptor and corpus key id; the typed secret's copy under the
    /// VAULT's descriptor — corner 27). Returns the worded refusal.
    /// pre-13x 4a (ledger 53): `recoveryWrapDigest` — the fetched vault's
    /// recovery-wrap digest, recorded on the key file beside the descriptor
    /// (REQUIRED: every landing site decides; nil = no wrap / no vault).
    @discardableResult
    func adoptEnrolledMaterial(
        _ material: DeviceKeyMaterial, kdf: PassphraseKDF.Descriptor,
        recoveryWrapDigest: String?,
        typedPassphrase: String? = nil, typedWords: [String]? = nil,
        refreshing: Bool = true
    ) async -> Bool {
        let took = await store.offMain { $0.save(material) }
        if !took {
            lastError = "The device Keychain refused to store the keys — sync will ask again next launch."
        }
        onKeysChanged?()
        let landing = VaultLanding(
            material: material, kdf: kdf, passphrase: typedPassphrase, recoveryWords: typedWords,
            recoveryWrapDigest: recoveryWrapDigest)
        await onVaultMaterialLanded?(landing)
        if refreshing { await refresh() }
        return took
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

    /// CF-11's act — pre-13x 3b (§13; decision 25): NO USER DOOR any more.
    /// The forget door FOLDED into Sign out (which keeps the keys in
    /// custody — copy §4's *Your library and its keys stay on this
    /// [device]*); account deletion keeps custody too (the keys sit dead
    /// server-side). The mechanism stays for the custody rule's pins: the
    /// MATERIAL goes from every item and the session, the identity stays.
    func forgetDeviceKeys() async {
        await store.offMain { $0.clear() }
        onKeysChanged?()
        await refresh()
    }

    /// pre-13x 1a: this device's identity for this library's sync (the
    /// custody record's; minted into custody when none exists) — off-main.
    func deviceIdentity() async -> String {
        await store.offMain { $0.deviceID() }
    }

    // MARK: - Plumbing

    /// 13p Batch 2: the enrolled device's held material, off-main (the
    /// reset door's vault half re-wraps from it — R13p-9's "any enrolled
    /// device"). nil = not enrolled, or locked behind the biometric gate.
    func heldMaterial() async -> DeviceKeyMaterial? {
        await store.offMain { $0.load() }
    }

    /// Split a typed-in phrase on any whitespace (the entry surface is one
    /// field; `RecoveryPhrase.validate` does the trimming/casefolding).
    /// Nonisolated since 13p Batch 2 — a pure function the locked lobby's
    /// off-main unwrap road also uses.
    nonisolated static func words(from text: String) -> [String] {
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

    static func message(for error: any Error) -> String {
        switch error {
        case VaultEnrollmentError.wrongPassphrase:
            return "Wrong encryption passphrase."
        case VaultEnrollmentError.wrongRecoveryPhrase:
            return "That recovery phrase doesn't unlock this account's vault."
        case VaultEnrollmentError.emptyPassphrase:
            return "The passphrase can't be empty."
        case RecoveryPhraseError.checksumMismatch:
            // pre-13x 5a: copy §2a's line, verbatim.
            return "That's not quite the phrase — one of the twelve words is off. Compare it with what you wrote down."
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

    /// pre-13x 2c — the key proof's refusal (`SyncError.keyProofRefused`):
    /// the SAME un-followed state as the fence's refusal (the server checks
    /// the fence first, so an un-followed device meets the fence; the proof
    /// refusal is a device presenting the current key id with a stale
    /// master) — both present as the replaced-keys row whose door is the
    /// follow.
    nonisolated static func isKeyProofRefusedError(_ text: String) -> Bool {
        text == SyncError.keyProofRefused.description
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

/// pre-13x 3a — THE STORE TIE: what the setup ceremony needs from the
/// library's key file and controller, as closures (the `VaultTie`
/// pattern from the other side): the passphrase and words on file, their
/// verification against the KEY FILE (one secret, corner 27), the set act,
/// and the passphrase wrap's descriptor (the vault is born under it —
/// §3.6's derive-once). Wired once by `wireOneSecretHooks`.
nonisolated struct StoreTie: Sendable {
    var libraryPosture: @MainActor () -> Posture
    var hasPassphrase: @MainActor () -> Bool
    var hasRecoveryWords: @MainActor () -> Bool
    /// nil = no wrap on file (nothing to verify against).
    var verifyPassphrase: @MainActor (String) async -> Bool?
    /// The set act; returns the worded refusal, nil = landed.
    var setPassphrase: @MainActor (String) async -> String?
    /// nil = no words on file.
    var verifyRecoveryWords: @MainActor (String) async -> Bool?
    var passphraseKDF: @MainActor () -> PassphraseKDF.Descriptor?
}
