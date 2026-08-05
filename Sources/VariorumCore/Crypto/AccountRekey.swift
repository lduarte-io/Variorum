import CryptoKit
import Dependencies
import Foundation

/// Phase 14c batch 2 (ledger L4) — CF-8's user-facing re-key, the brain
/// (THE DESIGN item 3). In-app, no terminal; the app's Encryption surface
/// is the door and this type is the testable order of operations — WHICH
/// IS THE SAFETY DESIGN, pinned by test:
///
///  1. **Passphrase authorization** — the CURRENT vault's master unwraps
///     under the typed passphrase, or the act refuses (`wrongPassphrase`).
///     The old master is then discarded: nothing of the old key world
///     survives into the new one.
///  2. **The NEW vault is written FIRST** (fresh master, fresh corpus +
///     journal-bridge keys with fresh ids, a fresh KDF salt/descriptor,
///     wrapped under the SAME passphrase — changing the passphrase is the
///     separate standing door). From this instant every stale writer
///     everywhere is fenced by batch 1's vault-key-id fence: the server
///     compares each round's presented key id against the vault row this
///     step just replaced (cold pass C-3's poison-push window, closed
///     structurally). The write is CAS-guarded (`expectedRevision`, R1-2)
///     — a vault another device moved mid-flow refuses typed.
///     **The new vault carries NO recovery wrap**: the old phrase wrapped
///     the old master and dies with it; the surface lands in the standing
///     CF-5 mandatory-phrase step (`enrolled(hasRecoveryWrap: false)` IS
///     that step), so a new phrase is generated, written down, and
///     confirmed exactly as at setup — no new machinery.
///  3. `onNewVaultMaterial` is AWAITED here — the caller's custody
///     adoption point (the app saves to the Keychain), placed before the
///     truncate so this device is never stale against its own new vault.
///  4. **The account-scoped truncate** (09's `account_data_truncate`),
///     presenting the NEW corpus key id — which the fence now requires,
///     so only the device that just re-keyed can empty the account.
///  5. **`resyncReinitialize`** — the harness-proven R-2 client half:
///     every row's sync_version → 0, seq bookkeeping and cursor cleared,
///     EVERY row enqueued. The DRAIN is deliberately NOT driven here:
///     the app's ordinary scheduler pushes the outbox down round by round
///     with visible progress on the sync row (the headless drain shape
///     stays `vault-bootstrap`'s).
///  6. **The bridge's staged re-push trigger** — every agreed journal day
///     marked for re-push from Variorum truth (`BridgeEngine
///     .stageRepushFromTruth`). INERT while the bridge's structural pause
///     stands (no round runs); live from 14d, whose staged re-push
///     re-seals the satellite's bodies under the NEW journal-bridge key
///     (the contract's point 9: old-key bodies refuse until the re-push
///     overwrites them).
///
/// **The sequence is not atomic — the road back from any mid-run failure
/// is running the door again** (pinned): steps 1–2 re-run cleanly (the
/// passphrase unwraps the NEW vault; another fresh vault is minted —
/// harmless, everything re-encrypts from local truth at the repush), and
/// steps 4–6 are idempotent against an already-truncated account. The
/// surface speaks this road on every failure. A crash between 2 and 3
/// leaves THIS device in the CF-16 replaced state like any other stale
/// device — re-enrolling with the passphrase, then re-running the door,
/// heals it.
public struct AccountRekey: Sendable {
    public let client: KeyVaultClient
    public let lifecycle: any AccountLifecycleProviding
    /// Used ONLY to compose the engine for `resyncReinitialize` (which
    /// touches no network); the drain is the app scheduler's.
    public let transport: any SyncTransport
    public let database: AppDatabase
    /// Awaited right after the NEW vault lands and BEFORE the truncate —
    /// the caller's custody adoption point.
    public var onNewVaultMaterial: (@Sendable (DeviceKeyMaterial) async -> Void)?

    public init(
        client: KeyVaultClient,
        lifecycle: any AccountLifecycleProviding,
        transport: any SyncTransport,
        database: AppDatabase,
        onNewVaultMaterial: (@Sendable (DeviceKeyMaterial) async -> Void)? = nil
    ) {
        self.client = client
        self.lifecycle = lifecycle
        self.transport = transport
        self.database = database
        self.onNewVaultMaterial = onNewVaultMaterial
    }

    @discardableResult
    public func run(passphrase: String) async throws -> DeviceKeyMaterial {
        guard !passphrase.isEmpty else { throw VaultEnrollmentError.emptyPassphrase }

        // 1. Authorization: the CURRENT vault's master must unwrap under
        // the typed passphrase. The unwrapped master is discarded — a
        // re-key carries nothing over.
        guard let fetched = try await client.fetchVault() else {
            throw KeyVaultClientError.vaultAbsent
        }
        let currentKey = try PassphraseKDF.deriveKey(
            passphrase: passphrase, descriptor: fetched.format.kdf)
        do {
            _ = try fetched.format.unwrapMaster(withPassphraseKey: currentKey)
        } catch KeyVaultError.unwrapFailed {
            throw VaultEnrollmentError.wrongPassphrase
        }

        // 2. The NEW vault, written FIRST — the fence design's hinge.
        let master = SymmetricKey(size: .bits256)
        let corpus = SymmetricKey(size: .bits256)
        let journal = SymmetricKey(size: .bits256)
        let corpusID = UUID().uuidString.lowercased()
        let journalID = UUID().uuidString.lowercased()
        let descriptor = PassphraseKDF.Descriptor.v1(salt: PassphraseKDF.randomSalt())
        let passphraseKey = try PassphraseKDF.deriveKey(
            passphrase: passphrase, descriptor: descriptor)
        let format = try KeyVaultFormat.create(
            masterKey: master,
            passphraseKey: passphraseKey,
            recoveryKey: nil,  // the CF-5 mandatory step mints the new phrase
            classKeys: [
                (keyClass: .corpus, keyID: corpusID, key: corpus),
                (keyClass: .journalBridge, keyID: journalID, key: journal),
            ],
            kdf: descriptor)
        try await client.updateVault(format, expectedRevision: fetched.revision)

        // 3. Custody adoption — before the truncate, so this device is
        // never stale against its own new vault.
        let material = DeviceKeyMaterial(
            masterKey: master.data, corpusKey: corpus.data, corpusKeyID: corpusID,
            journalBridgeKey: journal.data, journalBridgeKeyID: journalID)
        await onNewVaultMaterial?(material)

        // 4. The account-scoped truncate, fenced on the NEW key id.
        _ = try await lifecycle.truncateAccountData(activeKeyID: corpusID)

        // 5. resyncReinitialize — the proven R-2 client half; the app's
        // scheduler drains the re-enqueued corpus afterwards.
        try await withDependencies {
            $0.database = database
        } operation: {
            let engine = SyncEngine(
                transport: transport, keyProvider: RekeyMaterialProvider(
                    keys: SyncEncryptionKeys(
                        corpusKey: material.corpusSymmetricKey,
                        corpusKeyID: material.corpusKeyID)))
            try await engine.resyncReinitialize()
        }

        // 6. The bridge's staged re-push trigger — inert while the
        // structural pause stands; live from 14d.
        try await database.write { db in
            _ = try BridgeEngine.stageRepushFromTruth(db)
        }

        return material
    }
}

/// The brain's in-run key world (the runner's `MaterialKeyProvider`
/// shape) — only `resyncReinitialize` composes over it, which never
/// touches the network.
private struct RekeyMaterialProvider: SyncKeyProviding {
    let keys: SyncEncryptionKeys
    func currentKeys() throws -> SyncEncryptionKeys { keys }
}
