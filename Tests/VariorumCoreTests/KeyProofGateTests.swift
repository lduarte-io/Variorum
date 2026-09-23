import CryptoKit
import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// pre-13x batch 1b — THE KEY PROOF GATE + THE ROTATION SEQ against the
/// fake server (the design's §3.10, decisions 12 / 31 / 32; §12's "The key
/// proof", "The rotation seq", "One rotation at a time", "Version-neutral
/// re-encryption", "The read RPCs and the insert arm", "The vault's
/// table-level write road is CLOSED" pins). The fake enforces exactly what
/// `11_pre13x_postures.sql` enforces (the DDL pins hold the SQL's letter;
/// the live deploy's probes prove the mirror) — every pin below reads as a
/// sentence about the RPCs' behaviour.
///
/// RED-ON-OLD: the "without the proof" pins go red when the fake's proof
/// gate is reverted (the emulation of the SQL's `sync_key_proof_check`);
/// the seq-rule pins go red when `SyncPayloadCrypto.keyMaterial(forServerSeq:)`
/// is reverted to the current key (production code — the batch record
/// quotes both reverts' failing assertions).
///
/// REWORKED at 13y UNIT B to the CHALLENGE PROTOCOL (the ruled memo §3;
/// QUESTIONS #144(a)): the static bearer proof retires — every gated call
/// rides a single-use nonce + an HMAC under kp2 bound to the door's name;
/// enrollment replaces the migration arm; a rotation swaps the Vault-held
/// secret beside the hash. The UNIT B pins (replay · expiry · splice ·
/// the signer's retry road · enroll-once · the together rule) sit at the
/// end of the suite; the replay pin's red-on-old is a BEHAVIORAL REVERT
/// of the fake's atomic consume (never committed — the record quotes it).
@Suite("The key proof gate + the rotation seq (pre-13x 1b; challenge-reworked 13y UNIT B)")
struct KeyProofGateTests {
    private static let wrongMaterial = KeyProofMaterial(master: SymmetricKey(size: .bits256))

    private func containerRow(id: String, title: String, base: Int) -> SyncRow {
        SyncRow(
            table: "container", rowID: id,
            columns: [
                "id": .text(id), "kind": .text("post"),
                "owner_id": .text(FakeSyncServer.defaultUserID),
                "title": .text(title),
                "created_at": .text(Fixture.now), "updated_at": .text(Fixture.now),
                "deleted_at": .null,
            ],
            syncVersion: base)
    }

    // MARK: - Decision 12: a session alone can neither write the vault nor touch the mirror

    /// A session holding the RIGHT key id but no proof (an absent, a wrong,
    /// a malformed token) cannot push, pull, read the horizon or the
    /// ledger, purge, truncate, or update the vault — and nothing lands.
    /// It CAN fetch the vault's wrapped copies and CAN delete the whole
    /// account (session-only by design: deletion is mandated and loud).
    @Test func aSessionWithoutTheProofGetsNothingFromTheMirrorButCanFetchTheVaultAndDeleteTheAccount() async throws {
        let world = VaultTestWorld()
        let server = world.syncServer
        let material = try await world.enrollment.setUp(passphrase: "orchard-lantern-13")
        let keyID = material.corpusKeyID
        let right = KeyProofMaterial(master: material.masterSymmetricKey)
        // The production first round's shape: the fresh account enrolls
        // (the old hash authorizes the successor), then pushes under a
        // minted single-use pair.
        try await server.enrollKeyProof(
            legacyProof: right.legacyWireToken, macKey: right.macKeyWire,
            activeKeyID: keyID, as: world.userID)
        _ = try await server.push(
            [containerRow(id: "c1", title: "e1:sealed", base: 0)],
            activeKeyID: keyID,
            keyProof: server.mintProof(rpc: "sync_push", for: world.userID, material: right))
        let rowsBefore = await server.rowCount(table: "container")
        let vaultBefore = world.server.storedRow(userID: world.userID)

        // A session WITHOUT the master mints real nonces (the mint is
        // session-gated only) but its HMACs are another kp2's — every
        // door refuses, and a garbage challenge refuses stale.
        func wrongPair(_ rpc: String) async -> SyncKeyProof {
            await server.mintProof(rpc: rpc, for: world.userID, material: Self.wrongMaterial)
        }
        await #expect(throws: SyncError.keyProofRefused, "push") {
            _ = try await server.push(
                [containerRow(id: "c2", title: "e1:x", base: 0)], activeKeyID: keyID,
                keyProof: await wrongPair("sync_push"))
        }
        await #expect(throws: SyncError.keyProofRefused, "pull") {
            _ = try await server.pull(since: 0, limit: 10, activeKeyID: keyID, keyProof: await wrongPair("sync_pull"), deviceID: "d")
        }
        await #expect(throws: SyncError.keyProofRefused, "horizon — a READ, gated too") {
            _ = try await server.syncHorizon(activeKeyID: keyID, keyProof: await wrongPair("sync_horizon"))
        }
        await #expect(throws: SyncError.keyProofRefused, "ledger — a READ, gated too") {
            _ = try await server.purgeLedger(since: 0, activeKeyID: keyID, keyProof: await wrongPair("sync_purge_ledger"))
        }
        await #expect(throws: SyncError.keyProofRefused, "purge") {
            _ = try await server.executePurge(
                [SyncPurgeTarget(table: "container", rowID: "c1")], activeKeyID: keyID,
                keyProof: await wrongPair("sync_purge_execute"))
        }
        await #expect(throws: SyncError.keyProofRefused, "truncate") {
            try await server.truncateAccount(world.userID, activeKeyID: keyID, keyProof: await wrongPair("account_data_truncate"))
        }
        await #expect(throws: SyncError.keyProofRefused, "re-encrypt") {
            _ = try await server.reencrypt(
                [containerRow(id: "c1", title: "e1:y", base: 1)], activeKeyID: keyID,
                keyProof: await wrongPair("sync_reencrypt"))
        }
        await #expect(throws: KeyVaultClientError.keyProofRefused, "the vault update") {
            try await world.client.updateVault(
                try #require(try await world.client.fetchVault()).format,
                expectedRevision: 1, keyProof: Self.wrongMaterial)
        }
        // A fabricated challenge — never minted — refuses STALE (fetch
        // fresh and retry once is the signer's road, not a bare door's).
        await #expect(throws: SyncError.keyProofChallengeStale, "an unminted challenge") {
            _ = try await server.push(
                [containerRow(id: "c2", title: "e1:x", base: 0)], activeKeyID: keyID,
                keyProof: right.proof(challenge: Data(repeating: 7, count: 32).base64EncodedString(), rpc: "sync_push"))
        }
        // Nothing landed, nothing moved.
        #expect(await server.rowCount(table: "container") == rowsBefore)
        #expect(await server.currentRow(table: "container", rowID: "c1") != nil, "the truncate deleted nothing")
        #expect(await server.purgedLedgerCount() == 0)
        #expect(await server.deviceCursor("d") == nil, "a refused pull records no cursor")
        #expect(world.server.storedRow(userID: world.userID) == vaultBefore, "the vault row is byte-identical")
        #expect(await server.vaultRow()?.revision == 1)

        // What a bare session CAN do: fetch the wrapped copies…
        let fetched = try #require(try await world.client.fetchVault())
        #expect(fetched.format.masterWrappedByPassphrase.isEmpty == false,
                "the wrapped copies read for any session — enrollment gates the mirror, not the vault read")
        // The gate's truth: the post-enroll hash is SHA-256(kp2). (The
        // direct-enroll road updated the sync fake's row; the scripted
        // PostgREST copy follows only through its own enroll route.)
        #expect(await server.vaultRow(for: world.userID)?.keyProofHash
                == KeyProof.macHash(master: material.masterSymmetricKey),
                "the post-enroll hash: SHA-256(kp2)")
        // …and delete the whole account — no proof asked (decision 12).
        await server.purgeAccount(world.userID)
        #expect(await server.vaultRow(for: world.userID) == nil)
        await #expect(throws: SyncError.encryptionKeysReplaced, "the missing-vault arm after deletion") {
            _ = try await server.push(
                [], activeKeyID: keyID,
                keyProof: server.mintProof(rpc: "sync_push", for: world.userID, material: right))
        }
    }

    /// THE CLOSED WRITE ROAD (ledger 41): a bare session's direct PostgREST
    /// PATCH on `key_vault` is `permission denied` — whatever it carries,
    /// the right proof included. The DDL pin holds the policy/grant set;
    /// the deploy's live probe proves it on the mirror; this is the fake's
    /// twin so no client road can grow back onto PATCH unnoticed.
    @Test func aBareSessionsDirectVaultPatchIsRefused() async throws {
        let world = VaultTestWorld()
        let material = try await world.enrollment.setUp(passphrase: "orchard-lantern-13")
        let before = world.server.storedRow(userID: world.userID)
        var row = try KeyVaultWireRow(
            format: try #require(try await world.client.fetchVault()).format, userID: world.userID)
        row.keyProofHash = "0000000000000000000000000000000000000000000000000000000000000000"
        var request = URLRequest(url: URL(
            string: "https://vault.test.invalid/rest/v1/key_vault?user_id=eq.\(world.userID)&revision=eq.1")!)
        request.httpMethod = "PATCH"
        request.setValue("Bearer token-1", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(row)
        let (body, response) = try await world.server.load(request)
        #expect((response as? HTTPURLResponse)?.statusCode == 403)
        #expect(String(data: body, encoding: .utf8)?.contains("42501") == true, "permission denied")
        #expect(world.server.storedRow(userID: world.userID) == before, "nothing written")
        #expect(world.server.patchCount == 1)
        // The proof machinery it tried to overwrite still gates the
        // mirror (13y UNIT B: enroll, then a minted pair).
        let rightMaterial = KeyProofMaterial(master: material.masterSymmetricKey)
        try await world.syncServer.enrollKeyProof(
            legacyProof: rightMaterial.legacyWireToken, macKey: rightMaterial.macKeyWire,
            activeKeyID: material.corpusKeyID, as: world.userID)
        _ = try await world.syncServer.push(
            [], activeKeyID: material.corpusKeyID,
            keyProof: world.syncServer.mintProof(
                rpc: "sync_push", for: world.userID, material: rightMaterial))
    }

    /// THE ENROLL ROAD (13y UNIT B — replacing the retired NULL-hash
    /// migration arm, hers and spent): the EXISTING hash authorizes the
    /// successor — a wrong kp1 refuses; the right one lands the secret
    /// and the post-enroll hash TOGETHER, once; a second enrollment
    /// refuses ALREADY_ENROLLED; gated calls pass only under the enrolled
    /// material. And THE INSERT ARM (unchanged): a vault CREATED without
    /// its hash is refused by the trigger's twin.
    @Test func theEnrollRoadLandsTheSecretOnceUnderTheOldHashesAuthorization() async throws {
        let server = FakeSyncServer()
        let uid = "00000000-aaaa-4bbb-8ccc-00000000a01d"
        let hers = KeyProofMaterial(master: SymmetricKey(size: .bits256))
        // A fresh account: created with its v1 hash, NOT yet enrolled.
        await server.provisionAccount(
            uid, vaultCorpusKeyID: "her-key",
            keyProofHash: KeyProof.hash(ofWireToken: hers.legacyWireToken))
        let her = server.connection(as: uid)

        // Un-enrolled: every gated call refuses ENROLL (before any nonce
        // is consumed — the retry's challenge survives, pinned at the DDL).
        await #expect(throws: SyncError.keyProofEnrollRequired) {
            _ = try await her.pull(
                since: 0, limit: 10, activeKeyID: "her-key",
                keyProof: server.mintProof(rpc: "sync_pull", for: uid, material: hers), deviceID: "mac")
        }
        // A WRONG kp1 cannot enroll — the old hash authorizes.
        await #expect(throws: SyncError.keyProofRefused, "a wrong kp1 refuses enrollment") {
            try await server.enrollKeyProof(
                legacyProof: Self.wrongMaterial.legacyWireToken,
                macKey: Self.wrongMaterial.macKeyWire, activeKeyID: "her-key", as: uid)
        }
        #expect(await server.vaultRow(for: uid)?.keyProofMacSecret == nil, "nothing landed")
        // The right kp1 enrolls: the secret and the post-enroll hash land
        // together.
        try await server.enrollKeyProof(
            legacyProof: hers.legacyWireToken, macKey: hers.macKeyWire,
            activeKeyID: "her-key", as: uid)
        #expect(await server.vaultRow(for: uid)?.keyProofMacSecret == hers.macKeyWire)
        #expect(await server.vaultRow(for: uid)?.keyProofHash
                == KeyProof.hash(ofToken: hers.macKey), "the hash is SHA-256(kp2) now")
        // ONCE: a second enrollment refuses — the racing loser's outcome,
        // which the signer treats as success (the same kp2 landed).
        await #expect(throws: SyncError.keyProofAlreadyEnrolled) {
            try await server.enrollKeyProof(
                legacyProof: hers.legacyWireToken, macKey: hers.macKeyWire,
                activeKeyID: "her-key", as: uid)
        }
        // Enrolled: her material passes; the wrong one refuses at the HMAC.
        _ = try await her.pull(
            since: 0, limit: 10, activeKeyID: "her-key",
            keyProof: server.mintProof(rpc: "sync_pull", for: uid, material: hers), deviceID: "mac")
        await #expect(throws: SyncError.keyProofRefused) {
            _ = try await her.pull(
                since: 0, limit: 10, activeKeyID: "her-key",
                keyProof: server.mintProof(rpc: "sync_pull", for: uid, material: Self.wrongMaterial), deviceID: "phone")
        }

        // The insert arm: a fresh vault without its hash is refused, and no
        // row (and no account) exists afterwards.
        let world = VaultTestWorld()
        let master = SymmetricKey(size: .bits256)
        var format = try KeyVaultFormat.create(
            masterKey: master, passphraseKey: SymmetricKey(size: .bits256), recoveryKey: nil,
            classKeys: [
                (keyClass: .corpus, keyID: "c", key: SymmetricKey(size: .bits256)),
                (keyClass: .journalBridge, keyID: "j", key: SymmetricKey(size: .bits256)),
            ],
            kdf: .v1(salt: PassphraseKDF.randomSalt()))
        #expect(format.keyProofHash != nil, "create lands the hash by construction")
        format.keyProofHash = nil
        await #expect(throws: KeyVaultClientError.keyProofRefused) {
            try await world.client.createVault(format)
        }
        #expect(world.server.isEmpty, "the refused insert wrote nothing")
    }

    /// ENROLLMENT UNDER A RACE (13y UNIT B; memo §7 edge 1 — replacing
    /// the retired first-proof race): two devices racing `key_proof_enroll`
    /// land EXACTLY ONE secret — the FOR UPDATE serializes (the fake's
    /// actor stands in) and the loser meets ALREADY_ENROLLED. Both derive
    /// kp2 from the SAME master, so the loser's material keeps working —
    /// the signer treats the refusal as success and proceeds.
    @Test func twoRacingEnrollmentsLandExactlyOneSecretAndTheLoserProceeds() async throws {
        let server = FakeSyncServer()
        let uid = "00000000-aaaa-4bbb-8ccc-00000000a01d"
        let master = SymmetricKey(size: .bits256)
        let material = KeyProofMaterial(master: master)
        await server.provisionAccount(
            uid, vaultCorpusKeyID: "her-key",
            keyProofHash: KeyProof.hash(ofWireToken: material.legacyWireToken))
        let her = server.connection(as: uid)
        let first = Task {
            try await her.enrollKeyProof(
                legacyProof: material.legacyWireToken, macKey: material.macKeyWire,
                activeKeyID: "her-key")
        }
        let second = Task {
            try await her.enrollKeyProof(
                legacyProof: material.legacyWireToken, macKey: material.macKeyWire,
                activeKeyID: "her-key")
        }
        let results = [await first.result, await second.result]
        let successes = results.filter { if case .success = $0 { return true } else { return false } }.count
        let losses = results.filter {
            if case .failure(let error) = $0, case SyncError.keyProofAlreadyEnrolled = error { return true }
            return false
        }.count
        #expect(successes == 1 && losses == 1,
                "exactly one enrollment lands; the loser meets ALREADY_ENROLLED")
        #expect(await server.vaultRow(for: uid)?.keyProofMacSecret == material.macKeyWire,
                "exactly one secret landed — the shared kp2")
        // The loser PROCEEDS: its identical material signs valid proofs.
        _ = try await her.pull(
            since: 0, limit: 1, activeKeyID: "her-key",
            keyProof: server.mintProof(rpc: "sync_pull", for: uid, material: material), deviceID: "phone")
    }

    /// The right `active_key_id` WITHOUT the proof deletes nothing (the
    /// truncate door — the design's §12 letter); with the proof it empties
    /// the partition, and the vault survives either way.
    @Test func theRightKeyIDWithoutTheProofDeletesNothing() async throws {
        let server = FakeSyncServer()
        _ = try await server.push(
            [containerRow(id: "c1", title: "e1:a", base: 0), containerRow(id: "c2", title: "e1:b", base: 0)],
            activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_push"))
        await #expect(throws: SyncError.keyProofRefused) {
            try await server.truncateAccount(
                FakeSyncServer.defaultUserID, activeKeyID: SyncTestKeys.corpusKeyID,
                keyProof: server.mintProof(rpc: "account_data_truncate", material: Self.wrongMaterial))
        }
        #expect(await server.rowCount(table: "container") == 2, "the right key id without the proof deleted NOTHING")
        try await server.truncateAccount(
            FakeSyncServer.defaultUserID, activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "account_data_truncate"))
        #expect(await server.rowCount(table: "container") == 0)
        #expect(await server.vaultRow()?.keyProofHash == SyncTestKeys.macKeyHash, "the vault row survives a truncate")
    }

    // MARK: - The rotation road

    /// A rotation installs the NEW hash under the OLD proof — and the old
    /// proof is refused from then on, on every door: a push with the old
    /// key id refuses at the fence (first), a push with the new id and the
    /// old proof refuses at the proof, the vault update refuses the old
    /// proof, and the new proof is accepted everywhere.
    @Test func theOldProofIsRefusedAfterARotationAndTheNewOneAccepted() async throws {
        let world = VaultTestWorld()
        let server = world.syncServer
        let old = try await world.enrollment.setUp(passphrase: "orchard-lantern-13")
        let oldMaterial = KeyProofMaterial(master: old.masterSymmetricKey)
        try await server.enrollKeyProof(
            legacyProof: oldMaterial.legacyWireToken, macKey: oldMaterial.macKeyWire,
            activeKeyID: old.corpusKeyID, as: world.userID)
        _ = try await server.push(
            [containerRow(id: "c1", title: "e1:old", base: 0)], activeKeyID: old.corpusKeyID,
            keyProof: server.mintProof(rpc: "sync_push", for: world.userID, material: oldMaterial))

        // The rotation's vault write: a fresh master + corpus key, the
        // POST-ENROLL hash (SHA-256(kp2′)) in the payload BESIDE kp2′
        // itself (13y UNIT B: hash and Vault secret land TOGETHER — the
        // memo's rotation road), authorized by the OLD proof.
        let newMaster = SymmetricKey(size: .bits256)
        let newMaterial = KeyProofMaterial(master: newMaster)
        let fetched = try #require(try await world.client.fetchVault())
        var rotated = try KeyVaultFormat.create(
            masterKey: newMaster, passphraseKey: SymmetricKey(size: .bits256), recoveryKey: nil,
            classKeys: [
                (keyClass: .corpus, keyID: "rotated-corpus", key: SymmetricKey(size: .bits256)),
                (keyClass: .journalBridge, keyID: "rotated-journal", key: SymmetricKey(size: .bits256)),
            ],
            kdf: .v1(salt: PassphraseKDF.randomSalt()))
        #expect(rotated.keyProofHash == KeyProof.hash(master: newMaster),
                "creation's own hash is the v1 enroll authorization…")
        rotated.keyProofHash = KeyProof.macHash(master: newMaster)
        let receipt = try await world.client.updateVault(
            rotated, expectedRevision: fetched.revision, keyProof: oldMaterial,
            successorMacKey: newMaterial.macKeyWire)
        #expect(receipt.revision == fetched.revision + 1)
        #expect(receipt.rotationStartedSeq == nil, "no previous key in this payload — a re-key, not a rotation with a remainder")
        #expect(await server.vaultRow(for: world.userID)?.keyProofMacSecret == newMaterial.macKeyWire,
                "THE ATOMIC SWAP: the Vault-held secret is kp2′ the moment the hash is")

        // The OLD proof, every door.
        await #expect(throws: SyncError.encryptionKeysReplaced, "the fence refuses the old key id FIRST") {
            _ = try await server.push(
                [], activeKeyID: old.corpusKeyID,
                keyProof: server.mintProof(rpc: "sync_push", for: world.userID, material: oldMaterial))
        }
        await #expect(throws: SyncError.keyProofRefused, "the new id with the old proof: the proof refuses") {
            _ = try await server.push(
                [], activeKeyID: "rotated-corpus",
                keyProof: server.mintProof(rpc: "sync_push", for: world.userID, material: oldMaterial))
        }
        await #expect(throws: SyncError.keyProofRefused) {
            _ = try await server.pull(
                since: 0, limit: 10, activeKeyID: "rotated-corpus",
                keyProof: server.mintProof(rpc: "sync_pull", for: world.userID, material: oldMaterial), deviceID: nil)
        }
        await #expect(throws: KeyVaultClientError.keyProofRefused, "the vault update refuses the old proof") {
            try await world.client.updateVault(rotated, expectedRevision: receipt.revision, keyProof: oldMaterial)
        }
        // The NEW proof, accepted.
        let outcomes = try await server.push(
            [containerRow(id: "c2", title: "e1:new", base: 0)], activeKeyID: "rotated-corpus",
            keyProof: server.mintProof(rpc: "sync_push", for: world.userID, material: newMaterial))
        guard case .accepted = outcomes[0] else { Issue.record("the new proof must be accepted"); return }
        _ = try await server.pull(
            since: 0, limit: 10, activeKeyID: "rotated-corpus",
            keyProof: server.mintProof(rpc: "sync_pull", for: world.userID, material: newMaterial), deviceID: nil)
        let again = try await world.client.updateVault(
            rotated, expectedRevision: receipt.revision, keyProof: newMaterial)
        #expect(again.revision == receipt.revision + 1)
        #expect(world.server.storedRow(userID: world.userID)?.keyProofHash == KeyProof.macHash(master: newMaster))
    }

    /// ONE ROTATION AT A TIME (decision 32): setting a previous corpus key
    /// where none stands begins a rotation (the seq assigned); a DIFFERENT
    /// previous key while one stands is refused; the SAME one carries
    /// through (a re-wrap mid-rotation keeps the seq); clearing the key
    /// clears the seq WITH it — the previous key and the seq are nil
    /// together outside a rotation, on the mirror's row and in the
    /// fetched format alike.
    @Test func aSecondRotationWhileOneIsOpenIsRefusedAndCompletionClearsTheKeyAndTheSeqTogether() async throws {
        let world = VaultTestWorld()
        let material = try await world.enrollment.setUp(passphrase: "orchard-lantern-13")
        // 13y UNIT B: the proof is the MATERIAL — the first update's dance
        // enrolls the fresh account transparently (the production shape).
        let proof = KeyProofMaterial(master: material.masterSymmetricKey)
        let fetched = try #require(try await world.client.fetchVault())
        #expect(fetched.format.previousCorpusKey == nil && fetched.format.rotationStartedSeq == nil,
                "nil together before any rotation")

        // A rotation begins.
        let carrying = try fetched.format.carryingPreviousCorpusKey(
            SymmetricKey(size: .bits256), keyID: "the-old-corpus-id", masterKey: material.masterSymmetricKey)
        let begun = try await world.client.updateVault(carrying, expectedRevision: fetched.revision, keyProof: proof)
        let seq = try #require(begun.rotationStartedSeq, "a rotation takes the next seq")
        let mid = try #require(try await world.client.fetchVault())
        #expect(mid.format.previousCorpusKey?.keyID == "the-old-corpus-id")
        #expect(await world.syncServer.vaultRow()?.previousCorpusKeyID == "the-old-corpus-id",
                "the id in its OWN column on the mirror's row")
        #expect(world.server.storedRow(userID: world.userID)?.corpusPreviousKeyID == "the-old-corpus-id")
        #expect(mid.format.rotationStartedSeq == seq, "the wire row carries the server's seq back")
        #expect(await world.syncServer.vaultRow()?.rotationStartedSeq == seq)

        // A SECOND rotation while this one is open: refused, nothing moves.
        let another = try mid.format.carryingPreviousCorpusKey(
            SymmetricKey(size: .bits256), keyID: "yet-another-old-id", masterKey: material.masterSymmetricKey)
        await #expect(throws: KeyVaultClientError.rotationInProgress) {
            try await world.client.updateVault(another, expectedRevision: mid.revision, keyProof: proof)
        }
        #expect(try await world.client.fetchVault() == mid, "the refusal wrote nothing")

        // A carry-through (a passphrase re-wrap mid-rotation): the SAME
        // previous key rides along and the seq is kept.
        let rewrapped = try mid.format.rewrappingPassphrase(
            masterKey: material.masterSymmetricKey, passphraseKey: SymmetricKey(size: .bits256),
            kdf: .v1(salt: PassphraseKDF.randomSalt()))
        let carried = try await world.client.updateVault(rewrapped, expectedRevision: mid.revision, keyProof: proof)
        #expect(carried.rotationStartedSeq == seq, "a carry-through keeps the rotation's seq")

        // Completion: the payload clears the key — the seq clears with it.
        let done = try #require(try await world.client.fetchVault()).format.clearingPreviousCorpusKey()
        let completed = try await world.client.updateVault(done, expectedRevision: carried.revision, keyProof: proof)
        #expect(completed.rotationStartedSeq == nil)
        let after = try #require(try await world.client.fetchVault())
        #expect(after.format.previousCorpusKey == nil && after.format.rotationStartedSeq == nil,
                "the previous key AND the seq are nil TOGETHER outside a rotation")
        let row = try #require(await world.syncServer.vaultRow())
        #expect(row.previousCorpusKey == nil && row.previousCorpusKeyID == nil && row.rotationStartedSeq == nil,
                "…on the mirror's row too: the key, its id and the seq")
        #expect(row.revision == completed.revision)
    }

    /// THE ROTATION SEQ (decision 31): a push that passed the OLD check
    /// commits — and takes its seqs — BELOW the rotation seq, never above
    /// it (the fake's serialization stands in for the SQL's FOR SHARE /
    /// FOR UPDATE locks); every row written under the NEW proof lands
    /// ABOVE it; the old proof cannot write anything after the seq exists.
    @Test func aPushThatPassedTheOldCheckLandsBelowTheRotationSeqAndNewWritesAbove() async throws {
        let server = FakeSyncServer()
        let old = SyncTestKeys.keys
        let pre = try await server.push(
            [containerRow(id: "c1", title: "e1:one", base: 0), containerRow(id: "c2", title: "e1:two", base: 0)],
            activeKeyID: old.corpusKeyID, keyProof: server.mintProof(rpc: "sync_push", material: old.keyProof))
        let preSeqs = pre.compactMap { outcome -> Int64? in
            if case .accepted(_, let seq) = outcome { return seq } else { return nil }
        }
        #expect(preSeqs.count == 2)

        let world = try await RotationDrill.beginRotation(
            on: server, previous: old, oldProof: old.keyProof)
        #expect(preSeqs.allSatisfy { $0 < world.rotationStartedSeq },
                "every row the old check accepted sits BELOW the rotation seq")

        await #expect(throws: SyncError.encryptionKeysReplaced, "the old world cannot write past the seq") {
            _ = try await server.push(
                [containerRow(id: "c3", title: "e1:late", base: 0)], activeKeyID: old.corpusKeyID, keyProof: server.mintProof(rpc: "sync_push", material: old.keyProof))
        }
        let post = try await server.push(
            [containerRow(id: "c3", title: "e1:three", base: 0)],
            activeKeyID: world.newCorpusKeyID, keyProof: server.mintProof(rpc: "sync_push", material: world.keyProof))
        guard case .accepted(_, let postSeq) = post[0] else { Issue.record("accepted"); return }
        #expect(postSeq > world.rotationStartedSeq, "a write under the NEW proof lands ABOVE the rotation seq")
        // Which key a row is under is told by its seq: the stored rows
        // agree with the rule the seam applies.
        for stored in await server.storedRowsWithSeqs() {
            let underPrevious = stored.serverSeq < world.rotationStartedSeq
            #expect(underPrevious == (stored.row.rowID != "c3"), "row \(stored.row.rowID) at seq \(stored.serverSeq)")
        }
    }

    /// THE SEQ RULE AT THE SEAM: a row below the rotation seq opens under
    /// the PREVIOUS key (its AAD bound to the previous key's id); one at or
    /// above it opens under the CURRENT key; outside a rotation there is
    /// one key and a previous-key row is a crypto refusal. RED-ON-OLD by
    /// behavioural revert of `keyMaterial(forServerSeq:)`.
    @Test func theSeamOpensARowBelowTheRotationSeqUnderThePreviousKeyAndAboveUnderTheCurrent() throws {
        let previous = SyncTestKeys.keys
        let current = SyncEncryptionKeys(
            corpusKey: SymmetricKey(data: Data((0..<32).map { UInt8($0 &+ 0x70) })),
            corpusKeyID: "test-corpus-key-CURRENT-000000002",
            keyProof: KeyProofMaterial(master: SymmetricKey(size: .bits256)),
            rotation: RotationInProgress(
                previousCorpusKey: previous.corpusKey, previousCorpusKeyID: previous.corpusKeyID,
                startedSeq: 10))
        let plain = SyncRow(
            table: "container", rowID: "c-rot",
            columns: ["id": .text("c-rot"), "title": .text("under which key?")], syncVersion: 1)
        let underPrevious = try SyncPayloadCrypto(keys: previous).encryptForWire(plain)
        let underCurrent = try SyncPayloadCrypto(keys: current).encryptForWire(plain)
        let seam = SyncPayloadCrypto(keys: current)

        // Below the seq: the previous key opens it.
        #expect(try seam.decryptFromWire(SyncPulledRow(row: underPrevious, serverSeq: 9)).row == plain)
        // At/above the seq: the current key.
        #expect(try seam.decryptFromWire(SyncPulledRow(row: underCurrent, serverSeq: 10)).row == plain)
        #expect(try seam.decryptFromWire(SyncPulledRow(row: underCurrent, serverSeq: 42)).row == plain)
        // The wrong pairing refuses — the seq decides, nothing guesses.
        #expect(throws: SyncError.self, "a previous-key row at/above the seq is not tried under the previous key") {
            _ = try seam.decryptFromWire(SyncPulledRow(row: underPrevious, serverSeq: 10))
        }
        #expect(throws: SyncError.self, "a current-key row below the seq is not tried under the current key") {
            _ = try seam.decryptFromWire(SyncPulledRow(row: underCurrent, serverSeq: 3))
        }
        // Outside a rotation: one key.
        let completed = SyncEncryptionKeys(
            corpusKey: current.corpusKey, corpusKeyID: current.corpusKeyID, keyProof: current.keyProof)
        #expect(try SyncPayloadCrypto(keys: completed).decryptFromWire(
            SyncPulledRow(row: underCurrent, serverSeq: 3)).row == plain)
        #expect(throws: SyncError.self) {
            _ = try SyncPayloadCrypto(keys: completed).decryptFromWire(SyncPulledRow(row: underPrevious, serverSeq: 3))
        }
        // The seal side never uses the previous key.
        #expect(throws: SyncError.self, "what the current world seals, the previous key cannot open") {
            _ = try SyncPayloadCrypto(keys: previous).decryptFromWire(
                SyncPulledRow(row: try seam.encryptForWire(plain), serverSeq: 3))
        }
    }

    /// VERSION-NEUTRAL RE-ENCRYPTION (decision 6) end to end: a corpus
    /// authored and synced under the old key; a device with OFFLINE edits;
    /// a rotation; the walk re-encrypts every row below the seq (the seam
    /// opening them under the previous key by the seq rule); every
    /// version is UNBUMPED, every re-encrypted row sits ABOVE the seq under
    /// the new key and the old key opens nothing; a row whose version MOVED
    /// is SKIPPED with the current version; the device that follows pushes
    /// its offline edits with a CLEAN CAS — ZERO conflict variants — and
    /// the fleet converges; a follower re-downloads the corpus and applies
    /// it seq-recorded; completion clears the key and the seq together.
    @Test func reencryptionIsVersionNeutralAndADeviceWithOfflineEditsConvergesWithZeroConflicts() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 977, seed: 2)
        let old = SyncTestKeys.keys

        // A corpus under the old key, both devices at head. Three rows: two
        // B edits offline; one A edits AFTER the rotation, between the
        // walk's pull and its send — the skip arm's exact window.
        let (postID, variantA, variantB, variantC): (String, String, String, String) = try a.with { ops, _ in
            let post = try ops.createPost(title: "before the rotation", profile: .blog)
            let first = try ops.newBlock(in: post.id, text: "Old-key prose, first block.", at: .end).variant.id
            let second = try ops.newBlock(in: post.id, text: "Old-key prose, second block.", at: .end).variant.id
            let third = try ops.newBlock(in: post.id, text: "Old-key prose, third block.", at: .end).variant.id
            return (post.id, first, second, third)
        }
        try await syncToQuiescence(a, b, server: server)

        // B edits OFFLINE (two rows), then loses the network.
        try b.with { ops, _ in
            try ops.autosave(variantA, text: "Old-key prose, first block — B's offline edit.", charDelta: 20)
            try ops.autosave(variantB, text: "Old-key prose, second block — B's offline edit.", charDelta: 20)
        }
        #expect(try b.outboxCount() >= 2)

        // THE ROTATION on A: the vault write (the old proof authorizes),
        // then the walk with the new keys + the previous key under the seq
        // rule — PULLED and re-sealed first…
        let world = try await RotationDrill.beginRotation(on: server, previous: old, oldProof: old.keyProof)
        a.keyProvider = FixedSyncKeyProvider(keys: world.keys)
        let resealed = try await RotationDrill.pullBelow(on: server, keys: world.keys)
        #expect(resealed.contains { $0.rowID == variantC })
        // …and in the window between the pull and the send, A edits ONE
        // row under the NEW keys: its version moves, so the walk's send
        // must SKIP it (it is already under the new key, above the seq).
        try a.with { ops, _ in
            try ops.autosave(variantC, text: "Third block, edited by A after the rotation.", charDelta: 10)
        }
        _ = try await a.push()
        let movedVersion = try #require(await server.currentRow(table: "variant", rowID: variantC)?.syncVersion)
        let versionsBeforeSend = Dictionary(uniqueKeysWithValues: await server.storedRowsWithSeqs().map {
            ("\($0.row.table)/\($0.row.rowID)", $0.row.syncVersion)
        })

        let outcomes = try await RotationDrill.send(resealed, on: server, keys: world.keys)
        #expect(outcomes.count == resealed.count)
        // The rows whose version MOVED between the pull and the send: the
        // edited take AND its note (the autosave touched the container's
        // `last_touched_at`) — exactly those are skipped, each with its
        // current version; every other row is replaced.
        let skipped = zip(resealed, outcomes).compactMap { row, outcome -> (String, Int)? in
            if case .skipped(let version) = outcome { return (row.rowID, version ?? -1) } else { return nil }
        }
        #expect(Set(skipped.map(\.0)) == [variantC, postID], "exactly the moved rows are skipped")
        #expect(skipped.allSatisfy { $0.1 == movedVersion }, "each with its CURRENT version — the caller pulls and retries")
        #expect(outcomes.filter { if case .replaced = $0 { return true } else { return false } }.count
                == outcomes.count - skipped.count)

        // Every row now sits ABOVE the seq, under the NEW key only, with
        // its version EXACTLY what it was before the send — the walk bumps
        // nothing.
        let seam = SyncPayloadCrypto(keys: world.completedKeys)
        let oldSeam = SyncPayloadCrypto(keys: old)
        for stored in await server.storedRowsWithSeqs() {
            let key = "\(stored.row.table)/\(stored.row.rowID)"
            #expect(stored.serverSeq > world.rotationStartedSeq, "\(key) re-stamped above the rotation seq")
            #expect(stored.row.syncVersion == versionsBeforeSend[key], "\(key): the version is UNBUMPED by re-encryption")
            #expect((try? seam.decryptFromWire(stored)) != nil, "\(key) opens under the NEW key")
            guard let table = SyncSchema.table(named: stored.row.table),
                  table.encryptedColumns.contains(where: {
                      if case .text? = stored.row.columns[$0] { return true } else { return false }
                  })
            else { continue }
            #expect((try? oldSeam.decryptFromWire(stored)) == nil, "\(key): the OLD key opens nothing after the walk")
        }
        // The walk's rows are the whole pre-rotation corpus: the walk did
        // re-encrypt (the pin isn't vacuous).
        #expect(resealed.count >= 6)

        // B FOLLOWS (types the passphrase once — here: adopts the new keys
        // with the previous key under the seq rule) and pushes its OFFLINE
        // edits: their rows' versions are UNBUMPED, so the CAS is CLEAN on
        // both — ZERO conflict variants; then the fleet converges. (The
        // container row's `last_touched_at` did move under A's edit — a
        // metadata CAS rebase, never a take.)
        b.keyProvider = FixedSyncKeyProvider(keys: world.keys)
        let pushed = try await b.push()
        #expect(pushed.accepted >= 2, "B's two offline take edits CAS cleanly")
        try await syncToQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == b.syncedDump(), "the fleet converges through the rotation")
        for client in [a, b] {
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE label = 'conflict' AND deleted_at IS NULL") == 0,
                "\(client.name): ZERO conflict variants — a rotation never rejects an offline edit")
        }
        #expect(try a.db.fetchString(
            "SELECT working_text FROM variant WHERE id = ?", [variantA])
            == "Old-key prose, first block — B's offline edit.", "B's offline edit landed, unclobbered")
        #expect(try b.db.fetchString(
            "SELECT working_text FROM variant WHERE id = ?", [variantC])
            == "Third block, edited by A after the rotation.", "A's post-rotation edit reached B")

        // A FOLLOWER (a third device, fresh, at cursor 0 — a new device
        // enrolled mid-rotation or a device that was away) re-downloads
        // the corpus once, seq-recorded, applying it whole under the new
        // key; its store equals the others'.
        let c = try SyncClient(name: "C", prefix: "CC", transport: server, clockOffset: 313, seed: 3)
        c.keyProvider = FixedSyncKeyProvider(keys: world.keys)
        let report = try await c.pull()
        #expect(report.applied > 0 && !report.stalled)
        try await syncToQuiescence(a, c, server: server)
        #expect(try c.syncedDump() == a.syncedDump())

        // COMPLETION: no row of the account remains below the seq — the
        // clearing write NULLs the previous key AND the seq together.
        let remaining = await server.storedRowsWithSeqs().filter { $0.serverSeq < world.rotationStartedSeq }
        #expect(remaining.isEmpty, "nothing of the account is left under the previous key")
        let revision = try #require(await server.vaultRow()?.revision)
        try await RotationDrill.complete(on: server, world: world, expectedRevision: revision)
        let row = try #require(await server.vaultRow())
        #expect(row.previousCorpusKey == nil && row.previousCorpusKeyID == nil && row.rotationStartedSeq == nil,
                "cleared together — the key, its id and the seq")
        // The completed world (no previous key) still reads everything.
        a.keyProvider = FixedSyncKeyProvider(keys: world.completedKeys)
        b.keyProvider = FixedSyncKeyProvider(keys: world.completedKeys)
        try a.with { ops, _ in _ = try ops.createPost(title: "after completion", profile: .blog) }
        try await syncToQuiescence(a, b, server: server)
    }

    /// The push-reject's `current` row opens by the SAME seq rule — a
    /// follower whose push CAS-rejects against a pre-rotation row (its seq
    /// below the rotation seq) merges the server row opened under the
    /// PREVIOUS key rather than refusing the round.
    @Test func aPushRejectsCurrentRowOpensByTheSeqRuleToo() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 977, seed: 2)
        let old = SyncTestKeys.keys
        let postID: String = try a.with { ops, _ in
            try ops.createPost(title: "shared", profile: .blog).id
        }
        try await syncToQuiescence(a, b, server: server)
        // A moves the row under the OLD world (its seq stays below the
        // coming rotation seq); B holds a stale base for the same row.
        try a.with { ops, _ in try ops.renameContainer(postID, title: "A's rename, old key") }
        _ = try await a.push()
        try b.with { ops, _ in try ops.renameContainer(postID, title: "B's rename, offline") }
        // The rotation; B follows and pushes its stale-base row: the CAS
        // rejects with A's row — sealed under the OLD key, seq below the
        // rotation seq — which the seam must open by the seq rule.
        let world = try await RotationDrill.beginRotation(on: server, previous: old, oldProof: old.keyProof)
        b.keyProvider = FixedSyncKeyProvider(keys: world.keys)
        let report = try await b.push()
        #expect(report.rejected == 1, "the stale base is CAS-rejected with the server's row")
        // The merge happened (metadata: server-version-wins) — nothing refused.
        #expect(try b.db.fetchString("SELECT title FROM container WHERE id = ?", [postID]) == "A's rename, old key")
    }
}
