import CryptoKit
import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// pre-13x batch 4b — HER ATTACKER SCENARIO in the two-user suite (the
/// postures design §14.29; §12 "Her attacker scenario"; ledger 19), plus the
/// no-ownership-change-on-the-wire pin.
///
/// THE SCENARIO, as she put it: a Standard user's iCloud-Drive backups + the
/// iCloud key + the account password, AFTER the switch to Castle. Here the
/// attacker holds MORE than that — the strongest arm the design names: the
/// OLD master M and the old corpus key C, unwrapped from the vault's
/// Apple-held copy while it existed (anyone inside her Apple account during
/// Standard could). Over `FakeSyncServer`'s per-account partitions LINKED to
/// a `ScriptedVaultServer` (one emulation of `key_vault_update`, the fence
/// and the proof), A's account is BORN Standard through the 3a road, A's
/// library is a real on-disk keyed store with a format-2 key file beside it,
/// a snapshot pair is taken, A enters Castle through the core road the runner
/// composes (§4 steps 2–4), writes AFTER the switch — and then the nine arms.
///
/// EMULATION CAVEAT (the two-user suite's standing one): the fake EMULATES
/// the mirror's Postgres semantics — partitions for the composite PK, Swift
/// guards for the RPCs' RAISEs; the REAL Postgres truth is the DDL pins +
/// the deploy's live probes. `PostureSwitchRunner` is app-layer and invisible
/// here: §4 steps 2–3 ARE `CorpusRotation.begin` → `reencryptRemainder` →
/// `complete` (what the runner calls), step 4 IS `StoreEncryptionMigration
/// .rekey` + a new key file with no `apple` copy (what the runner's
/// `writeNewKeyFile` + `swapLibrary` do) — composed in `enterCastle` below;
/// the runner's own composition is pinned in `PostureSwitchTests`.
extension MultiTenantSyncTests {
    // MARK: - The attacker world

    fileprivate static func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    /// The scenario's four revertible gates live on the fake server (the
    /// proof check, the fence, the owner guard) — and this one, in the
    /// scenario's own switch helper: whether entering Castle keeps the
    /// Apple-held copy. Production's runner passes `nil` when entering
    /// Castle (`PostureSwitch.swift`: `entersCastle ? nil : …`); the helper
    /// mirrors that decision so the ABSENCE arm has a revertible mechanism
    /// in test support (flip to `true` = the revert; arm 2 goes red).
    fileprivate static let switchKeepsAppleHeldCopy = false

    /// A's Standard account + library; the attacker's holdings gathered
    /// while Standard stood; the switch; A's post-switch writing.
    fileprivate final class AttackerWorld: @unchecked Sendable {
        static let userA = FakeSyncServer.defaultUserID
        static let userB = "00000000-bbbb-4bbb-8ccc-000000000002"
        static let passphrase = "orchard-lantern-13"

        let dir: URL
        let server: FakeSyncServer
        let vault: ScriptedVaultServer
        let aVaultClient: KeyVaultClient
        let storeURL: URL
        let words: [String]
        let appleKey: SymmetricKey
        let appleKeyID: String
        let deviceID: String
        /// L, then L′ after the switch.
        private(set) var libraryKey: StoreKey
        /// M/C, then M′/C′ after the switch.
        private(set) var material: DeviceKeyMaterial
        private(set) var kdf: PassphraseKDF.Descriptor
        /// A's device — rebuilt over the re-keyed file after the switch
        /// (the bootstrap's reopen), the same device identity.
        private(set) var client: SyncClient
        /// The pair made while Standard stood.
        private(set) var snapshotURL: URL!
        private(set) var snapshotKeyFileURL: URL!
        /// The attacker's holdings, captured while Standard stood.
        private(set) var oldMaterial: DeviceKeyMaterial!
        private(set) var oldLibraryKey: StoreKey!
        private(set) var oldKeyFileURL: URL!
        /// What A wrote before / after the switch (titles by container id).
        private(set) var preSwitchTitles: [String: String] = [:]
        private(set) var postSwitchTitles: [String: String] = [:]

        init() async throws {
            dir = FileManager.default.temporaryDirectory
                .appendingPathComponent("variorum-4b-attacker-\(UUID().uuidString)", isDirectory: true)
            try FileManager.default.createDirectory(
                at: dir.appendingPathComponent("library", isDirectory: true), withIntermediateDirectories: true)
            try FileManager.default.createDirectory(
                at: dir.appendingPathComponent("Backups", isDirectory: true), withIntermediateDirectories: true)
            storeURL = dir.appendingPathComponent("library/variorum.sqlite")
            server = FakeSyncServer()
            vault = ScriptedVaultServer(syncServer: server)
            aVaultClient = Self.vaultClient(for: Self.userA, over: vault)
            words = try RecoveryPhrase.generate()
            appleKey = SymmetricKey(size: .bits256)
            appleKeyID = UUID().uuidString.lowercased()
            deviceID = UUID().uuidString.lowercased()
            kdf = MultiTenantSyncTests.fastKDF()
            // THE ACCOUNT, BORN STANDARD (3a's one-row birth): P + W + the
            // Apple-held copy under A's iCloud key, the proof hash — the
            // linked fake's account provisioned by the create.
            material = try await VaultEnrollment(client: aVaultClient).setUp(
                passphrase: Self.passphrase, recoveryWords: words,
                appleHeldCopy: (key: appleKey, id: appleKeyID), kdf: kdf)
            // The attacker's own account B — its own vault row (the two-user
            // suite's stranger), its own key world.
            await server.provisionAccount(
                Self.userB, vaultCorpusKeyID: MultiTenantSyncTests.StrangerKeys.corpusKeyID,
                keyProofHash: MultiTenantSyncTests.StrangerKeys.keyProofHash)
            // THE LIBRARY: a keyed store on disk, its format-2 key file
            // beside it (L under P, W, M and — Standard — A).
            libraryKey = StoreKey.mint()
            client = try SyncClient(
                name: "A-mac", prefix: "AA", transport: server,
                storeURL: storeURL, custody: .inMemory(initial: libraryKey))
            client.deviceID = deviceID
            client.keyProvider = FixedSyncKeyProvider(keys: material.syncKeys)
            let fetched = try #require(try await aVaultClient.fetchVault())
            var keyFile = StoreKeyEnvelope()
            try keyFile.setPassphraseWrap(key: libraryKey, passphrase: Self.passphrase, kdf: kdf)
            try keyFile.setRecoveryWrap(key: libraryKey, words: words)
            try keyFile.masterBox(key: libraryKey, under: material.masterSymmetricKey)
            try keyFile.appleBox(key: libraryKey, under: appleKey, appleKeyID: appleKeyID)
            try keyFile.recordVaultReconciliation(
                kdf: kdf, corpusKeyID: material.corpusKeyID, recoveryWrapDigest: fetched.format.recoveryWrapDigest)
            try keyFile.write(at: keyFile.preferredURL(besideStore: storeURL))
            oldKeyFileURL = keyFile.preferredURL(besideStore: storeURL)
        }

        static func vaultClient(for userID: String, over vault: ScriptedVaultServer) -> KeyVaultClient {
            KeyVaultClient(
                configuration: KeyVaultClient.Configuration(
                    projectURL: URL(string: "https://vault.test.invalid")!,
                    apiKey: "publishable-test-key", deviceName: "test device"),
                sessionProvider: StaticSessionProvider(
                    session: UserSession(accessToken: "token-\(userID.suffix(4))", userID: userID)),
                load: vault.load)
        }

        func tearDown() { try? FileManager.default.removeItem(at: dir) }

        /// A authors and syncs while Standard stands.
        func writeStandardEra() async throws {
            let id: String = try client.with { ops, _ in
                let post = try ops.createPost(title: "Standard-era chapter", profile: .blog)
                _ = try ops.newBlock(in: post.id, text: "Written before Castle — a backup may hold this.", at: .end)
                return post.id
            }
            preSwitchTitles[id] = "Standard-era chapter"
            _ = try await client.push()
            _ = try await client.pull()
        }

        /// THE SNAPSHOT PAIR (§6): the library through the app's own backup
        /// door (keyed under L) + its key file, written with it, never
        /// rewritten. This is the copy the attacker holds.
        func takeSnapshotPair() throws {
            let fp8 = StoreKeyEnvelope.shortFingerprint(StoreKeyEnvelope.fingerprint(of: libraryKey))
            let snapshot = dir.appendingPathComponent("Backups/variorum-backup-20260906-\(fp8).sqlite")
            try client.db.backup(to: snapshot)
            let pairKeyFile = snapshot.deletingPathExtension().appendingPathExtension("keys.json")
            try FileManager.default.copyItem(at: oldKeyFileURL, to: pairKeyFile)
            snapshotURL = snapshot
            snapshotKeyFileURL = pairKeyFile
        }

        /// The attacker gathers what Standard let him: the vault's Apple-held
        /// copy unwraps the OLD master; M unwraps the class keys — the old C.
        func attackerGathersHoldings() async throws {
            let fetched = try #require(try await aVaultClient.fetchVault())
            let master = try fetched.format.unwrapMaster(withAppleKey: appleKey)
            #expect(master == material.masterSymmetricKey, "the Apple-held copy unwraps the OLD master while Standard stands")
            oldMaterial = try CorpusRotation.materialFollowing(fetched.format, master: master)
            #expect(oldMaterial.corpusKey == material.corpusKey, "…and the old corpus key under it")
            oldLibraryKey = libraryKey
        }

        /// A ENTERS CASTLE — §4 steps 1–4 through the core road the runner
        /// composes: pull to head; the vault rewritten under the OLD proof
        /// (M′ under P and W, NO Apple-held copy, C′ + the old C under M′);
        /// every row re-encrypted under C′; completion clears the previous
        /// key + the seq; the library re-keyed (export-and-swap behind a
        /// closed pool) with a NEW key file under the new fingerprint —
        /// L′ under P, W and M′, no `apple` copy; the old key file stays
        /// beside old snapshots (2b's letter). The device reopens under L′.
        @discardableResult
        func enterCastle() async throws -> (reencrypted: Int, receipt: KeyVaultClient.UpdateReceipt) {
            _ = try await client.pullToHead()
            #expect(try client.outboxCount() == 0, "step 1: nothing owed before the vault write")
            let secrets = try RotationSecrets.derive(
                passphrase: Self.passphrase, recoveryWords: words, kdf: MultiTenantSyncTests.fastKDF())
            let appleHeld: (key: SymmetricKey, id: String)? =
                MultiTenantSyncTests.switchKeepsAppleHeldCopy ? (appleKey, appleKeyID) : nil
            let begun = try await CorpusRotation.begin(
                client: aVaultClient, current: material, secrets: secrets, appleHeldCopy: appleHeld)
            let walk = try await CorpusRotation(transport: server).reencryptRemainder(material: begun.material)
            let completed = try await CorpusRotation.complete(client: aVaultClient, material: begun.material)
            // Step 4: the pool closed, the file re-keyed, a NEW key file.
            let (_, binding) = client.db.asRebindable()
            _ = binding.lock()
            let newKey = StoreKey.mint()
            try StoreEncryptionMigration.rekey(at: storeURL, from: libraryKey, to: newKey)
            let storeID = try #require(try StoreKeyEnvelope.load(at: oldKeyFileURL)).storeID
            let fetched = try #require(try await aVaultClient.fetchVault())
            var keyFile = StoreKeyEnvelope(storeID: storeID)
            try keyFile.setPassphraseWrap(key: newKey, passphrase: Self.passphrase, kdf: secrets.kdf)
            try keyFile.setRecoveryWrap(key: newKey, words: words)
            try keyFile.masterBox(key: newKey, under: completed.masterSymmetricKey)
            try keyFile.recordVaultReconciliation(
                kdf: secrets.kdf, corpusKeyID: completed.corpusKeyID, recoveryWrapDigest: fetched.format.recoveryWrapDigest)
            try keyFile.write(at: keyFile.preferredURL(besideStore: storeURL))
            libraryKey = newKey
            material = completed
            kdf = secrets.kdf
            client = try SyncClient(
                name: "A-mac-castle", prefix: "AB", transport: server,
                storeURL: storeURL, custody: .inMemory(initial: newKey))
            client.deviceID = deviceID
            client.keyProvider = FixedSyncKeyProvider(keys: completed.syncKeys)
            return (walk.replaced, begun.receipt)
        }

        /// A writes and syncs AFTER the switch — the writing the attacker
        /// must never read.
        func writeCastleEra() async throws {
            let id: String = try client.with { ops, _ in
                let post = try ops.createPost(title: "Castle-era chapter", profile: .blog)
                _ = try ops.newBlock(in: post.id, text: "Written after Castle — only she may read this.", at: .end)
                return post.id
            }
            postSwitchTitles[id] = "Castle-era chapter"
            _ = try await client.push()
            _ = try await client.pull()
        }
    }

    private func titles(in db: AppDatabase) async throws -> [String: String] {
        try await db.read { db in
            try Row.fetchAll(db, sql: "SELECT id, title FROM container").reduce(into: [String: String]()) { acc, row in
                let id: String = row["id"]; let title: String? = row["title"]; acc[id] = title
            }
        }
    }

    /// Every server-stored row of an account that carries an encrypted text
    /// column — the "server-compromise view" the old corpus key is tried on.
    private func sealedRows(_ server: FakeSyncServer, for userID: String) async -> [SyncPulledRow] {
        await server.storedRowsWithSeqs(for: userID).filter { stored in
            guard let table = SyncSchema.table(named: stored.row.table) else { return false }
            return table.encryptedColumns.contains { column in
                if case .text? = stored.row.columns[column] { return true } else { return false }
            }
        }
    }

    // MARK: - THE NINE ARMS

    /// HER ATTACKER SCENARIO (§14.29; §12; ledger 19) — the nine arms, each
    /// an assertion. What the attacker holds: the snapshot pair (an
    /// iCloud-Drive backup), A's iCloud key, a session for A (the account
    /// password), and — the strongest arm — the OLD master and the old
    /// corpus key from Standard's Apple-held copy. What he can do, and
    /// cannot, after A entered Castle. RED-ON-OLD: the fake's gates
    /// reverted one at a time (the proof check · the fence · the owner
    /// guard) and the scenario's switch helper keeping the Apple-held copy
    /// — the batch record quotes the assertion each revert reddens.
    @Test func herAttackerScenarioTheNineArmsAfterTheSwitchToCastle() async throws {
        let world = try await AttackerWorld()
        defer { world.tearDown() }
        let server = world.server
        let userA = AttackerWorld.userA
        let userB = AttackerWorld.userB

        // ————— Standard stands: A writes, the pair is taken, the attacker gathers —————
        try await world.writeStandardEra()
        try world.takeSnapshotPair()
        try await world.attackerGathersHoldings()
        let oldMaterial = try #require(world.oldMaterial)
        let oldProof = KeyProof.wireToken(master: oldMaterial.masterSymmetricKey)
        let oldKeyID = oldMaterial.corpusKeyID
        let oldLibraryKey = try #require(world.oldLibraryKey)
        let pairKeyFile = try #require(try StoreKeyEnvelope.load(at: world.snapshotKeyFileURL))
        #expect(pairKeyFile.apple != nil && pairKeyFile.appleKeyID == world.appleKeyID, "the pair's key file carries the Apple copy — Standard's")
        let vaultBefore = try #require(try await world.aVaultClient.fetchVault())
        #expect(vaultBefore.format.masterWrappedByAppleHeld != nil, "the vault carries the Apple-held copy while Standard stands")

        // ————— A ENTERS CASTLE, then writes after —————
        let switched = try await world.enterCastle()
        #expect(switched.reencrypted >= 1, "the walk re-encrypted A's rows")
        try await world.writeCastleEra()
        let vault = try #require(try await world.aVaultClient.fetchVault())
        let currentKeyID = try #require(vault.format.classKey(for: .corpus)?.keyID)
        #expect(currentKeyID != oldKeyID && vault.format.previousCorpusKey == nil && vault.format.rotationStartedSeq == nil)
        let aPartitionAfterSwitch = await server.storedRowsWithSeqs(for: userA)
        let aRowsAfterSwitch = await server.rowCount(table: "container", for: userA)
        #expect(aRowsAfterSwitch == 2, "both chapters are on the mirror under A")

        // ————— (1) The old snapshot OPENS through the Apple key — expected, stated —————
        let viaApple = try pairKeyFile.unwrapKey(apple: world.appleKey)
        #expect(viaApple == oldLibraryKey, "the pair's key file's `apple` copy unwraps L")
        #expect(StoreEncryptionMigration.opens(world.snapshotURL, key: viaApple), "…and L opens the snapshot")
        let snapshotView = try AppDatabase.openStore(at: world.snapshotURL, custody: .inMemory(initial: viaApple))
        let snapshotTitles = try await titles(in: snapshotView)
        for (id, title) in world.preSwitchTitles {
            #expect(snapshotTitles[id] == title, "ARM 1: pre-switch writing reads from the snapshot")
        }
        for id in world.postSwitchTitles.keys {
            #expect(snapshotTitles[id] == nil, "ARM 1: the snapshot holds nothing written after the switch")
        }
        // …and the same key opens NO page of the post-switch library.
        #expect(!StoreEncryptionMigration.opens(world.storeURL, key: viaApple),
                "§12: a Standard-era key file + A opens no page of the re-keyed library")
        #expect(StoreEncryptionMigration.opens(world.storeURL, key: world.libraryKey), "L′ does")

        // ————— (2) The attacker cannot ENROLL: no Apple-held copy, no P, no W —————
        #expect(vault.format.masterWrappedByAppleHeld == nil && vault.format.appleKeyID == nil,
                "ARM 2: the vault after the switch carries NO Apple-held copy (pin the ABSENCE)")
        #expect(throws: KeyVaultError.appleHeldCopyAbsent) {
            _ = try vault.format.unwrapMaster(withAppleKey: world.appleKey)
        }
        let attackerVault = AttackerWorld.vaultClient(for: userA, over: world.vault)  // a session for A
        await #expect(throws: VaultEnrollmentError.wrongPassphrase, "ARM 2: a guessed passphrase") {
            _ = try await VaultEnrollment(client: attackerVault).enroll(passphrase: "a-guess-at-her-word-12")
        }
        await #expect(throws: VaultEnrollmentError.wrongRecoveryPhrase, "ARM 2: guessed twelve words") {
            _ = try await VaultEnrollment(client: attackerVault).enroll(recoveryWords: try RecoveryPhrase.generate())
        }
        // The old master (the strongest arm) does not unwrap the NEW class keys.
        #expect(throws: KeyVaultError.unwrapFailed, "ARM 2: the old master opens none of the vault's new class keys") {
            _ = try vault.format.unwrapClassKey(.corpus, masterKey: oldMaterial.masterSymmetricKey)
        }

        // ————— (3) Push and pull with the OLD custody: the FENCE first; with the CURRENT id, the PROOF —————
        // (A second copy of the backup for the stale device — an attacker
        // copies freely; the pair itself stays for arm 8.)
        let staleCopy = world.dir.appendingPathComponent("stale-copy.sqlite")
        try FileManager.default.copyItem(at: world.snapshotURL, to: staleCopy)
        let staleDevice = try SyncClient(
            name: "attacker-stale", prefix: "DD", transport: server,
            storeURL: staleCopy, custody: .inMemory(initial: viaApple))
        staleDevice.keyProvider = FixedSyncKeyProvider(keys: oldMaterial.syncKeys)
        try staleDevice.with { ops, _ in _ = try ops.createPost(title: "typed on the stale copy", profile: .blog) }
        let staleOutbox = try staleDevice.outboxCount()
        let staleCursor = try staleDevice.cursor()
        await #expect(throws: SyncError.encryptionKeysReplaced, "ARM 3: the fence refuses the old key id first — push") {
            _ = try await staleDevice.push()
        }
        await #expect(throws: SyncError.encryptionKeysReplaced, "ARM 3: …and pull") {
            _ = try await staleDevice.pull()
        }
        // The CURRENT key id is readable from the vault by any session — the
        // proof is the authorization.
        staleDevice.keyProvider = FixedSyncKeyProvider(keys: SyncEncryptionKeys(
            corpusKey: oldMaterial.corpusSymmetricKey, corpusKeyID: currentKeyID, keyProof: oldProof))
        await #expect(throws: SyncError.keyProofRefused, "ARM 3: the current id with the old master's proof — the proof refuses the push") {
            _ = try await staleDevice.push()
        }
        await #expect(throws: SyncError.keyProofRefused, "ARM 3: …and the pull") {
            _ = try await staleDevice.pull()
        }
        #expect(try staleDevice.outboxCount() == staleOutbox && staleDevice.cursor() == staleCursor,
                "nothing moved on the stale copy")
        #expect(await server.rowCount(table: "container", for: userA) == aRowsAfterSwitch, "ARM 3: nothing landed")
        #expect(await server.deviceCursor(staleDevice.deviceID, for: userA) == nil, "ARM 3: a refused pull records no cursor")

        // ————— (4) Replace All Keys refuses at the front check AND at the server —————
        let attackerSecrets = try RotationSecrets.derive(
            passphrase: "a-guess-at-her-word-12", recoveryWords: nil, kdf: MultiTenantSyncTests.fastKDF())
        await #expect(throws: CorpusRotationError.staleMaster(vaultKeyID: currentKeyID, heldKeyID: oldKeyID),
                      "ARM 4: the front check — the held master is stale") {
            _ = try await CorpusRotation.begin(
                client: attackerVault, current: oldMaterial, secrets: attackerSecrets, appleHeldCopy: nil)
        }
        let rotatedByHand = try KeyVaultFormat.create(
            masterKey: SymmetricKey(size: .bits256), passphraseKey: attackerSecrets.passphraseKey, recoveryKey: nil,
            classKeys: [
                (keyClass: .corpus, keyID: "attacker-corpus", key: SymmetricKey(size: .bits256)),
                (keyClass: .journalBridge, keyID: "attacker-journal", key: SymmetricKey(size: .bits256)),
            ],
            kdf: attackerSecrets.kdf)
        await #expect(throws: KeyVaultClientError.keyProofRefused, "ARM 4: the server — `key_vault_update` under the old proof") {
            try await attackerVault.updateVault(rotatedByHand, expectedRevision: vault.revision, keyProof: oldProof)
        }

        // ————— (5) A passphrase-change vault write refuses —————
        await #expect(throws: KeyVaultError.masterKeyMismatch, "ARM 5: the old master fails the format's verify before any write") {
            try await VaultEnrollment(client: attackerVault).rewrapPassphrase(
                material: oldMaterial, newPassphrase: "the-attackers-word-12")
        }
        var rewrappedByHand = vault.format
        rewrappedByHand.kdf = attackerSecrets.kdf
        rewrappedByHand.masterWrappedByPassphrase = Data(repeating: 0x5a, count: 40)
        await #expect(throws: KeyVaultClientError.keyProofRefused, "ARM 5: a hand-built re-wrap under the old proof — the proof refuses") {
            try await attackerVault.updateVault(rewrappedByHand, expectedRevision: vault.revision, keyProof: oldProof)
        }
        #expect(try await world.aVaultClient.fetchVault() == vault, "ARMS 4–5: the vault row is byte-identical")

        // ————— (6) Purge / truncate refuse; the read RPCs give nothing —————
        let target = SyncPurgeTarget(table: "container", rowID: try #require(world.preSwitchTitles.keys.first))
        await #expect(throws: SyncError.keyProofRefused, "ARM 6: sync_purge_execute") {
            _ = try await server.executePurge([target], activeKeyID: currentKeyID, keyProof: oldProof, as: userA)
        }
        await #expect(throws: SyncError.keyProofRefused, "ARM 6: account_data_truncate") {
            try await server.truncateAccount(userA, activeKeyID: currentKeyID, keyProof: oldProof)
        }
        await #expect(throws: SyncError.keyProofRefused, "ARM 6: sync_horizon gives nothing") {
            _ = try await server.syncHorizon(activeKeyID: currentKeyID, keyProof: oldProof, as: userA)
        }
        await #expect(throws: SyncError.keyProofRefused, "ARM 6: sync_purge_ledger gives nothing") {
            _ = try await server.purgeLedger(since: 0, activeKeyID: currentKeyID, keyProof: oldProof, as: userA)
        }
        let rowsAfterSix = await server.rowCount(table: "container", for: userA)
        let ledgerAfterSix = await server.purgedLedgerCount(for: userA)
        #expect(rowsAfterSix == aRowsAfterSwitch && ledgerAfterSix == 0, "ARM 6: nothing purged, nothing truncated")

        // ————— Nothing written AFTER the switch is readable by any holding —————
        let oldSeam = SyncPayloadCrypto(keys: oldMaterial.syncKeys)
        let sealed = await sealedRows(server, for: userA)
        #expect(sealed.count >= 4, "the pin isn't vacuous — sealed rows exist under A")
        for stored in sealed {
            #expect((try? oldSeam.decryptFromWire(stored)) == nil,
                    "the old corpus key opens NOTHING on the server after the walk — \(stored.row.table)/\(stored.row.rowID)")
        }
        let newSeam = SyncPayloadCrypto(keys: world.material.syncKeys)
        #expect(sealed.allSatisfy { (try? newSeam.decryptFromWire($0)) != nil }, "…while C′ opens every one (the rows are whole)")

        // ————— (8) An upload under the attacker's OWN account lands in B's partition only —————
        // The snapshot, Connected to B: a row still stamped A is refused
        // WHOLE by the owner guard; the adopt road re-stamps LOCALLY, and
        // the upload lands under B — A's partition byte-identical.
        let connected = try SyncClient(
            name: "attacker-B", prefix: "EE", transport: server.connection(as: userB),
            storeURL: world.snapshotURL, custody: .inMemory(initial: viaApple))
        connected.ownerID = userB
        connected.keyProvider = FixedSyncKeyProvider(keys: MultiTenantSyncTests.StrangerKeys.keys)
        let foreignToB = try await connected.db.read { try Queries.foreignOwnerExists($0, signedIn: userB) }
        #expect(foreignToB, "the snapshot's rows are A's")
        try connected.with { ops, _ in _ = try ops.createPost(title: "the attacker's own note", profile: .blog) }
        // The snapshot's outbox is empty (A had synced); a re-initialization
        // enqueues EVERY row — still stamped A — beside his own note.
        try await connected.withAsync { _ in
            try await SyncEngine(transport: server.connection(as: userB)).resyncReinitialize()
        }
        await #expect("ARM 8: a batch carrying rows stamped A is refused WHOLE under B") {
            _ = try await connected.push()
        } throws: { error in
            if case FakeSyncServerError.ownerMismatch = error { return true }
            return false
        }
        let bRowsAfterRefusal = await server.rowCount(table: "container", for: userB)
        #expect(bRowsAfterRefusal == 0, "ARM 8: the whole batch — B's own note landed nowhere either")
        let restamped = try connected.with { ops, _ in try ops.restampOwner(to: userB) }
        #expect(restamped.adoptedByTable.values.reduce(0, +) > 0, "the re-stamp is LOCAL — rows moved on the device")
        try await connected.withAsync { _ in
            try await SyncEngine(transport: server.connection(as: userB)).resyncReinitialize()
        }
        let uploaded = try await connected.push()
        #expect(uploaded.rejected == 0 && uploaded.accepted > 0)
        let bRowsAfterUpload = await server.rowCount(table: "container", for: userB)
        #expect(bRowsAfterUpload == 2, "ARM 8: the pre-switch chapter + his note, under B")
        let stillForeignToB = try await connected.db.read { try Queries.foreignOwnerExists($0, signedIn: userB) }
        #expect(!stillForeignToB)
        let aPartitionAfterUpload = await server.storedRowsWithSeqs(for: userA)
        #expect(aPartitionAfterUpload == aPartitionAfterSwitch, "ARM 8: A's partition is byte-identical — nothing moved between owners on the wire")
        #expect(await server.rowCount(table: "container", for: userA) == aRowsAfterSwitch)

        // ————— (7) The attacker CAN purge the whole account — loud, survivable — and A's re-setup ADOPTS —————
        await server.purgeAccount(userA)  // session-only by design (decision 12)
        #expect(await server.vaultRow(for: userA) == nil)
        await #expect(throws: SyncError.encryptionKeysReplaced, "ARM 7: A's device meets the missing-vault arm") {
            _ = try await world.client.pull()
        }
        // Every local copy survives.
        #expect(StoreEncryptionMigration.opens(world.storeURL, key: world.libraryKey), "ARM 7: the re-keyed library opens under L′")
        #expect(StoreEncryptionMigration.opens(world.snapshotURL, key: viaApple), "ARM 7: the pair opens through the Apple key")
        let newKeyFile = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: world.storeURL))
        #expect(try newKeyFile.unwrapKey(passphrase: AttackerWorld.passphrase) == world.libraryKey, "…and its key file's P copy")
        #expect(newKeyFile.apple == nil, "the post-switch key file carries no Apple copy")
        let onDevice = try await titles(in: world.client.db)
        for (id, title) in world.postSwitchTitles.merging(world.preSwitchTitles, uniquingKeysWith: { a, _ in a }) {
            #expect(onDevice[id] == title, "ARM 7: every chapter still on A's device")
        }
        // The re-setup: a fresh account (a fresh uid — the purge removed the
        // auth user), a fresh vault, and the library — stamped A — ADOPTED
        // (decision 17): re-stamped locally, sync re-initialized, everything
        // uploaded into the new partition.
        let aPrime = "00000000-aaaa-4bbb-8ccc-0000000000a2"
        let primeVault = AttackerWorld.vaultClient(for: aPrime, over: world.vault)
        let primeMaterial = try await VaultEnrollment(client: primeVault).setUp(
            passphrase: AttackerWorld.passphrase, recoveryWords: world.words,
            appleHeldCopy: nil, kdf: MultiTenantSyncTests.fastKDF())
        let resetup = try SyncClient(
            name: "A-mac-resetup", prefix: "AC", transport: server.connection(as: aPrime),
            storeURL: world.storeURL, custody: .inMemory(initial: world.libraryKey))
        resetup.deviceID = world.deviceID
        resetup.ownerID = aPrime
        resetup.keyProvider = FixedSyncKeyProvider(keys: primeMaterial.syncKeys)
        let foreignToPrime = try await resetup.db.read { try Queries.foreignOwnerExists($0, signedIn: aPrime) }
        #expect(foreignToPrime, "the library is foreign to the new account")
        _ = try resetup.with { ops, _ in try ops.restampOwner(to: aPrime) }
        try await resetup.withAsync { _ in
            try await SyncEngine(transport: server.connection(as: aPrime)).resyncReinitialize()
        }
        let reuploaded = try await resetup.push()
        #expect(reuploaded.rejected == 0 && reuploaded.accepted > 0)
        #expect(await server.rowCount(table: "container", for: aPrime) == 2, "ARM 7: both chapters under the new account")
        #expect(await server.rowCount(table: "container", for: userB) == 2, "…and B's partition untouched by A's re-setup")
        // (Sign out everywhere is the app layer's `AuthSession.signOut(scope:
        // .global)`, pinned at 3b — `AuthSessionTests.signOutEverywhereRides
        // TheGlobalScope…`; the core suite has no auth fake.)
    }

    // MARK: - (9) No ownership-change instruction on the wire

    /// ARM 9 — NO OWNERSHIP-CHANGE INSTRUCTION EXISTS ON THE WIRE: the
    /// client's RPC request set, the transport protocols' requirements and
    /// the deployed function set are asserted BY NAME — none moves rows
    /// between owners, none takes an owner parameter (the push/pull stamp
    /// `auth.uid()`); the only road between partitions is arm 8's LOCAL
    /// re-stamp + a push under the other account's own gate. A text pin over
    /// the sources (the `AuthRLSDDLTests` precedent), so a road that grew
    /// back would announce itself by name.
    @Test func noOwnershipChangeInstructionExistsOnTheWire() throws {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        func source(_ relative: String) throws -> String {
            try String(contentsOf: root.appendingPathComponent(relative), encoding: .utf8)
        }
        func names(_ pattern: String, in text: String) throws -> Set<String> {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(text.startIndex..., in: text)
            return Set(regex.matches(in: text, range: range).compactMap { match in
                Range(match.range(at: 1), in: text).map { String(text[$0]) }
            })
        }

        // THE CLIENT's request set, exactly.
        let transport = try source("Sources/VariorumCore/Sync/SupabaseTransport.swift")
        let vaultClient = try source("Sources/VariorumCore/Crypto/KeyVaultClient.swift")
        let lifecycle = try source("Sources/VariorumCore/Auth/AccountLifecycle.swift")
        // `rpc("name", body:)` for the bodied calls; `send("name", payload:)`
        // for the schema-version probe — both are the transport's one road.
        var clientRPCs = try names(#"(?:rpc|send)\(\s*"([a-z_]+)""#, in: transport)
        clientRPCs.formUnion(try names(#"rest/v1/rpc/([a-z_]+)"#, in: vaultClient + lifecycle + transport))
        #expect(clientRPCs == [
            "sync_push", "sync_pull", "sync_schema_version",
            "sync_horizon", "sync_purge_ledger", "sync_purge_execute", "sync_reencrypt",
            "key_vault_update", "account_data_truncate", "account_purge",
        ], "the client's RPC set, by name — \(clientRPCs.sorted())")

        // THE TRANSPORT PROTOCOLS' requirements, exactly.
        let protocols = try source("Sources/VariorumCore/Sync/SyncTransport.swift")
        #expect(try names(#"\n\s*func ([a-zA-Z]+)\("#, in: protocols)
                == ["push", "pull", "schemaVersion", "syncHorizon", "purgeLedger", "executePurge", "reencrypt"])
        let lifecycleProtocol = try #require(lifecycle.components(separatedBy: "public protocol AccountLifecycleProviding").dropFirst().first?
            .components(separatedBy: "\n}").first)
        #expect(try names(#"func ([a-zA-Z]+)\("#, in: lifecycleProtocol)
                == ["truncateAccountData", "purgeAccount", "fetchEntitlements"])

        // THE DEPLOYED function set: every client name exists server-side;
        // no function's NAME or PARAMETER LIST names an owner, a transfer,
        // a move, an adoption or a hand-over — the owner is `auth.uid()`.
        let sqlDir = root.appendingPathComponent("Server/supabase")
        let sqlFiles = try FileManager.default.contentsOfDirectory(at: sqlDir, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "sql" }.sorted { $0.lastPathComponent < $1.lastPathComponent }
        #expect(sqlFiles.count >= 11, "the numbered chain — the pin isn't vacuous")
        var deployed: [String: String] = [:]  // name → the LAST parameter list deployed
        let signature = try NSRegularExpression(pattern: #"create or replace function ([a-z_]+)\(([^)]*)\)"#)
        for file in sqlFiles {
            let text = try String(contentsOf: file, encoding: .utf8)
            for match in signature.matches(in: text, range: NSRange(text.startIndex..., in: text)) {
                guard let name = Range(match.range(at: 1), in: text).map({ String(text[$0]) }),
                      let params = Range(match.range(at: 2), in: text).map({ String(text[$0]) }) else { continue }
                deployed[name] = params
            }
        }
        for rpc in clientRPCs {
            #expect(deployed[rpc] != nil, "\(rpc) is a deployed function")
        }
        let forbidden = ["owner", "transfer", "reassign", "move", "adopt", "handover", "hand_over"]
        for (name, params) in deployed {
            for word in forbidden {
                #expect(!name.contains(word), "no deployed function is named for \(word): \(name)")
                #expect(!params.lowercased().contains(word), "no deployed function takes a \(word) parameter: \(name)(\(params))")
            }
        }
        // The row's owner is the CALLER's — stamped from `auth.uid()` in the
        // push and re-encrypt bodies, compared, never received.
        let sql11 = try source("Server/supabase/11_pre13x_postures.sql")
        #expect(sql11.contains("is distinct from") && sql11.contains("auth.uid()"),
                "the push guard reads the caller's uid — a payload never names another owner")
    }
}
