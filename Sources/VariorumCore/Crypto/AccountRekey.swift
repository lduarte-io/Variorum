import CryptoKit
import Dependencies
import Foundation
import GRDB

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
///  *(A former step 6 — the retired Fragments bridge's staged re-push
///     trigger — left with the bridge on 2026-09-04; the marker now clears
///     after step 5. The `journalBridge` class key is still minted in step
///     2: the vault format carries the class, dormant.)*
///
/// **The sequence is not atomic — the road back from any mid-run failure
/// is running the door again** (pinned): steps 1–2 re-run cleanly (the
/// passphrase unwraps the NEW vault; another fresh vault is minted —
/// harmless, everything re-encrypts from local truth at the repush), and
/// steps 4–5 are idempotent against an already-truncated account. The
/// surface speaks this road on every THROWN failure — and a CRASH is
/// covered by the persisted marker (`AccountRekeyMarker`, ladder R1-1):
/// written after authorization and BEFORE the vault write, cleared only
/// when the whole road completes, it survives relaunch, makes every
/// engine round refuse (`SyncError.accountRekeyIncomplete` — outbox
/// intact, cursor unmoved) and makes the surface re-speak the rerun
/// road. The three crash windows it closes, traced (ladder round 1):
///  - **2→3** (vault written, custody not adopted): visible anyway as
///    the CF-16 replaced state — but CF-16's re-enroll heals custody
///    ONLY, landing exactly in the 3→4 state below; the marker adds the
///    completing prompt.
///  - **3→4** (custody adopted, truncate not run): every round passes
///    the fence while the mirror keeps an old-key corpus whose wrapped
///    key the vault replacement destroyed — silent on this device (its
///    cursor sits at head, so it never decrypts those rows), permanent
///    payload-crypto refusals for any later-enrolling device.
///  - **4→5** (truncate returned, resyncReinitialize not committed):
///    clean rows never re-enqueue, dirty rows self-heal via the
///    nil-current rebase, and the sync row reads idle over a near-empty
///    mirror — the hosted copy silently gone.
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

    /// pre-13x 1a: this device's identity (the custody item's) — the
    /// re-initialization engine's provider carries it for the seam's shape;
    /// no round runs inside the brain.
    public let deviceID: String

    public init(
        client: KeyVaultClient,
        lifecycle: any AccountLifecycleProviding,
        transport: any SyncTransport,
        database: AppDatabase,
        deviceID: String,
        onNewVaultMaterial: (@Sendable (DeviceKeyMaterial) async -> Void)? = nil
    ) {
        self.client = client
        self.lifecycle = lifecycle
        self.transport = transport
        self.database = database
        self.deviceID = deviceID
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
        let oldMaster: SymmetricKey
        do {
            oldMaster = try fetched.format.unwrapMaster(withPassphraseKey: currentKey)
        } catch KeyVaultError.unwrapFailed {
            throw VaultEnrollmentError.wrongPassphrase
        }
        // pre-13x (decision 12): the OLD master's proof authorizes the ONE
        // vault write that installs the NEW hash; the old proof is refused
        // from then on. Nothing else of the old key world survives.
        let oldProof = KeyProof.wireToken(master: oldMaster)

        // 1½. THE MARKER (ladder R1-1): persist rekey-in-progress BEFORE
        // anything irreversible. From here until the whole road completes,
        // a crash OR a thrown failure leaves the marker set — rounds
        // refuse and the surface re-speaks the rerun road across
        // relaunches, so none of the crash windows can strand the hosted
        // copy unsignaled. (A step-2 failure keeps it set too, on
        // purpose: an updateVault network failure is AMBIGUOUS — the
        // write may have landed while the response was lost — and the
        // rerun is the universal heal either way, matching the pinned
        // doctrine above.)
        try await database.write { db in try AccountRekeyMarker.set(db) }

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
        try await client.updateVault(format, expectedRevision: fetched.revision, keyProof: oldProof)

        // 3. Custody adoption — before the truncate, so this device is
        // never stale against its own new vault.
        let material = DeviceKeyMaterial(
            masterKey: master.data, corpusKey: corpus.data, corpusKeyID: corpusID,
            journalBridgeKey: journal.data, journalBridgeKeyID: journalID)
        await onNewVaultMaterial?(material)

        // 4. The account-scoped truncate, fenced on the NEW key id and
        // authorized by the NEW proof (the right id without the proof
        // deletes nothing).
        let newProof = KeyProof.wireToken(master: master)
        _ = try await lifecycle.truncateAccountData(activeKeyID: corpusID, keyProof: newProof)

        // 5. resyncReinitialize — the proven R-2 client half; the app's
        // scheduler drains the re-enqueued corpus afterwards.
        try await withDependencies {
            $0.database = database
        } operation: {
            // pre-13x 1a: a `resyncReinitialize`-only engine — no round, no
            // identity use; the static world carries the caller's device id
            // for the seam's shape alone.
            let engine = SyncEngine(
                transport: transport, keyProvider: StaticSyncKeyProvider(
                    keys: SyncEncryptionKeys(
                        corpusKey: material.corpusSymmetricKey,
                        corpusKeyID: material.corpusKeyID,
                        keyProof: newProof),
                    deviceID: deviceID))
            try await engine.resyncReinitialize()
        }

        // The marker clears ONLY here — after the WHOLE road. Any earlier
        // exit leaves it set and the rerun road prompted.
        try await database.write { db in try AccountRekeyMarker.clear(db) }

        return material
    }
}

/// Phase 14c ladder R1-1 — the persisted rekey-in-progress MARKER: the
/// crash-window closure for the brain's non-atomic sequence. It lives in
/// the LOCAL-ONLY `sync_state` keyspace (never synced, no triggers watch
/// it — the local-only keyspace's precedent), so it is per-device by construction,
/// exactly the scope of the road it tracks.
///
/// Why `sync_state` and not the device Keychain: (i) local-only BY
/// DESIGN — SyncSpec §3's letter; (ii) `resyncReinitialize` deletes only
/// the cursor key, so the marker survives the brain's own step 5 by
/// construction; (iii) a Keychain marker would add synchronous SecItem
/// hops at composition/round cadence — the owned 13e windowless-launch
/// family — where a DB read is the engine's native cadence. The value is
/// a wall-clock stamp for support honesty (a plain `Date()`, the
/// `key_vault.updated_at` precedent — nothing orders by it).
///
/// Who touches it: `AccountRekey.run` sets it before the vault write and
/// clears it after the whole road; the engine refuses both round halves
/// while it is set (`SyncError.accountRekeyIncomplete`); the Encryption
/// surface projects it as the rerun prompt; account deletion clears it
/// (a purged account owes no completion).
public enum AccountRekeyMarker {
    public static let key = "rekey_in_progress"

    public static func set(_ db: Database) throws {
        try db.execute(
            sql: "INSERT OR REPLACE INTO sync_state (key, value) VALUES (?, ?)",
            arguments: [key, DateFormatter.variorumISO8601.string(from: Date())])
    }

    public static func clear(_ db: Database) throws {
        try db.execute(sql: "DELETE FROM sync_state WHERE key = ?", arguments: [key])
    }

    public static func isSet(_ db: Database) throws -> Bool {
        try String.fetchOne(
            db, sql: "SELECT value FROM sync_state WHERE key = ?", arguments: [key]) != nil
    }
}

