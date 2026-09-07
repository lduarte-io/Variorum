import CryptoKit
import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// pre-13x batch 2b — THE ROTATION'S SHARED DRIVER + the two engine
/// primitives (the postures design §4 steps 1–3; §12's "Entering Castle"
/// server half, "Any enrolled device can finish a rotation", "Version-
/// neutral re-encryption", "The rotation seq", "One rotation at a time";
/// the BATCH 2 brief's fact iv). The server semantics are 1b's
/// (`KeyProofGateTests`); every pin here reads as a sentence about the
/// CLIENT road over them: `SyncEngine.pullToHead` / `outboxCount`,
/// `CorpusRotation.begin` / `reencryptRemainder` / `complete` /
/// `materialFollowing`, the per-step `RotationMarker`, and the custody
/// material's rotation fields.
@Suite("The rotation driver + pullToHead (pre-13x 2b)", .serialized)
struct CorpusRotationTests {
    private static let passphrase = "orchard-lantern-13"

    private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    private func secrets(recoveryWords: [String]? = nil) throws -> RotationSecrets {
        try RotationSecrets.derive(
            passphrase: Self.passphrase, recoveryWords: recoveryWords, kdf: fastKDF())
    }

    /// The vault world: a scripted vault LINKED to the fake mirror (one
    /// row), the account set up under `old`, the clients keyed to it.
    private struct World {
        let vault: VaultTestWorld
        let server: FakeSyncServer
        let old: DeviceKeyMaterial
    }

    private func makeWorld(visibilityHorizon: Int64 = 0) async throws -> World {
        let vault = VaultTestWorld(syncServer: FakeSyncServer(visibilityHorizon: visibilityHorizon))
        let old = try await vault.enrollment.setUp(passphrase: Self.passphrase)
        return World(vault: vault, server: vault.syncServer, old: old)
    }

    private func client(
        _ name: String, prefix: String, world: World, material: DeviceKeyMaterial,
        clockOffset: TimeInterval = 0, seed: UInt64 = 1
    ) throws -> SyncClient {
        let client = try SyncClient(
            name: name, prefix: prefix, transport: world.server,
            clockOffset: clockOffset, seed: seed)
        client.keyProvider = FixedSyncKeyProvider(keys: material.syncKeys)
        return client
    }

    /// F1: the driver's wait past the A5 horizon, as the pins inject it —
    /// time passes on the FAKE's clock (production sleeps 2.5 s).
    private func timePasses(on server: FakeSyncServer) -> @Sendable () async throws -> Void {
        { await server.advanceClock(by: 2) }
    }

    private func conflictVariants(_ client: SyncClient) throws -> Int {
        try client.db.fetchInt(
            "SELECT COUNT(*) FROM variant WHERE label = 'conflict' AND deleted_at IS NULL") ?? 0
    }

    private func blockRow(id: String, lastContainer: String?) -> SyncRow {
        SyncRow(
            table: "block", rowID: id,
            columns: [
                "id": .text(id), "owner_id": .text(FakeSyncServer.defaultUserID),
                "default_variant_id": .null,
                "last_container_id": lastContainer.map { .text($0) } ?? .null,
                "name": .null, "presentation": .null,
                "created_at": .text(Fixture.now), "updated_at": .text(Fixture.now),
                "archived_at": .null, "deleted_at": .null,
            ],
            syncVersion: 0)
    }

    private func containerRow(id: String, title: String) throws -> SyncRow {
        try SyncTestKeys.sealedForWire(SyncRow(
            table: "container", rowID: id,
            columns: [
                "id": .text(id), "owner_id": .text(FakeSyncServer.defaultUserID),
                "kind": .text("post"), "title": .text(title), "profile": .null,
                "entry_date": .null, "locked": .integer(0), "locked_at": .null,
                "floating_notes": .null, "segmentation_default": .null,
                "last_touched_at": .null, "last_major_revision_at": .null,
                "word_target": .null, "churn_accumulator": .real(0),
                "baseline_length": .integer(0),
                "created_at": .text(Fixture.now), "updated_at": .text(Fixture.now),
                "archived_at": .null, "deleted_at": .null,
            ],
            syncVersion: 0))
    }

    // MARK: - §4 step 1: the named primitives

    /// `pullToHead` retries a STALLED pull and refuses typed when the
    /// straggler never clears (the owing device has not drained); once the
    /// parent lands it reaches head. `outboxCount` is the engine's own read.
    /// RED ON OLD (behavioural revert: `pullToHead` returning the first
    /// report whether or not it stalled): the stalled pull is answered as
    /// success and the refusal never comes.
    @Test func pullToHeadRetriesAStallAndRefusesTypedWhenItNeverClears() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        // Another device's block arrives BEFORE the container it names —
        // the §5 straggler: A's pull stops at it, cursor held.
        _ = try await server.push(
            [blockRow(id: "b-stray", lastContainer: "c-late")],
            activeKeyID: SyncTestKeys.corpusKeyID, keyProof: SyncTestKeys.keyProof)
        await #expect(throws: SyncError.pullStalled(cursor: 0), "a straggler that never clears refuses typed") {
            _ = try await a.pullToHead(maxAttempts: 3)
        }
        #expect(try a.cursor() == 0, "the cursor never moved past the stall")
        // The owing device drains: the parent lands, the next pullToHead
        // reads to head.
        _ = try await server.push(
            [try containerRow(id: "c-late", title: "the late parent")],
            activeKeyID: SyncTestKeys.corpusKeyID, keyProof: SyncTestKeys.keyProof)
        let report = try await a.pullToHead()
        #expect(!report.stalled)
        #expect(report.applied == 2)
        let head = await server.headSeq
        #expect(try a.cursor() == head)

        // The outbox count: A's own writing owed, then drained.
        try a.with { ops, _ in _ = try ops.createPost(title: "owed", profile: .blog) }
        #expect(try await a.engineOutboxCount() > 0)
        _ = try await a.push()
        #expect(try await a.engineOutboxCount() == 0)
    }

    /// `pullToHead` is deliberately NOT gated by the rotation marker
    /// (the runner calls it mid-road); `pull()` and `push()` are.
    @Test func pullToHeadRunsWithTheMarkerSetWhileRoundsRefuse() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        try await a.db.write { db in
            try RotationMarker.write(
                RotationMarker(step: .reencrypt, entersCastle: true, startedAt: Fixture.now), db)
        }
        await #expect(throws: SyncError.accountRekeyIncomplete) { _ = try await a.pull() }
        await #expect(throws: SyncError.accountRekeyIncomplete) { _ = try await a.push() }
        _ = try await a.pullToHead()
    }

    // MARK: - §4 step 2: BEGIN

    /// BEGIN writes the vault ONCE under the OLD proof: the new corpus key
    /// id (the fence advanced), the new proof hash, the previous key + its
    /// id carried, the seq taken — and the Apple-held copy ABSENT when none
    /// is kept (entering Castle — §12's pinned absence) or PRESENT when the
    /// caller keeps it (Standard's Replace All Keys — decision 30's pinned
    /// presence). The old proof is refused from then on. At the DOOR
    /// (decision 32) a second begin refuses while one stands, and (corner
    /// 30) a stale master refuses before any write.
    @Test func beginWritesTheVaultUnderTheOldProofCarryingThePreviousKey() async throws {
        let world = try await makeWorld()
        let words = try RecoveryPhrase.generate()
        let begun = try await CorpusRotation.begin(
            client: world.vault.client, current: world.old,
            secrets: try secrets(recoveryWords: words), appleHeldCopy: nil)
        let seq = try #require(begun.receipt.rotationStartedSeq)
        let fetched = try #require(try await world.vault.client.fetchVault())
        let vault = fetched.format
        #expect(vault.classKey(for: .corpus)?.keyID == begun.material.corpusKeyID)
        #expect(begun.material.corpusKeyID != world.old.corpusKeyID, "a genuinely fresh corpus key")
        #expect(vault.keyProofHash == KeyProof.hash(master: begun.material.masterSymmetricKey))
        #expect(vault.previousCorpusKey?.keyID == world.old.corpusKeyID, "the old corpus key's id in its own column")
        #expect(vault.rotationStartedSeq == seq)
        #expect(begun.material.rotation?.startedSeq == seq)
        #expect(begun.material.previousCorpusKey == world.old.corpusKey)
        #expect(vault.masterWrappedByAppleHeld == nil && vault.appleKeyID == nil,
                "entering Castle: NO Apple-held copy — the pinned absence")
        // M′ under P and W — the wraps the secrets were for (the vault's
        // descriptor is the fresh one the secrets were derived under).
        let recovered = try vault.unwrapMaster(
            withPassphraseKey: try PassphraseKDF.deriveKey(passphrase: Self.passphrase, descriptor: vault.kdf))
        #expect(recovered.data == begun.material.masterKey)
        #expect(try vault.unwrapMaster(withRecoveryKey: try RecoveryPhrase.recoveryWrapKey(words: words)).data
                == begun.material.masterKey, "M′ under the twelve words")
        #expect(try vault.unwrapPreviousCorpusKey(masterKey: begun.material.masterSymmetricKey).key.data
                == world.old.corpusKey, "the previous corpus key under M′")
        // The OLD proof is dead on every door.
        await #expect(throws: SyncError.keyProofRefused) {
            _ = try await world.server.pull(
                since: 0, limit: 1, activeKeyID: begun.material.corpusKeyID,
                keyProof: KeyProof.wireToken(master: world.old.masterSymmetricKey), deviceID: nil)
        }
        // A SECOND rotation while this one stands: refused at the door.
        await #expect(throws: CorpusRotationError.rotationInProgress(previousKeyID: world.old.corpusKeyID)) {
            _ = try await CorpusRotation.begin(
                client: world.vault.client, current: begun.material,
                secrets: try secrets(), appleHeldCopy: nil)
        }
        // Completion, then Standard's Replace All Keys: the Apple-held copy KEPT.
        let cleared = try await CorpusRotation.complete(client: world.vault.client, material: begun.material)
        #expect(cleared.rotation == nil)
        let apple = SymmetricKey(size: .bits256)
        let again = try await CorpusRotation.begin(
            client: world.vault.client, current: cleared, secrets: try secrets(),
            appleHeldCopy: (key: apple, id: "apple-1"))
        let standard = try #require(try await world.vault.client.fetchVault()).format
        #expect(standard.masterWrappedByAppleHeld != nil && standard.appleKeyID == "apple-1",
                "Standard's Replace All Keys keeps the Apple-held copy — decision 30's pinned PRESENCE")
        #expect(try standard.unwrapMaster(withAppleKey: apple).data == again.material.masterKey)
        _ = try await CorpusRotation.complete(client: world.vault.client, material: again.material)
        // A stale master (the vault moved past it) refuses BEFORE any write.
        let revisionBefore = try #require(try await world.vault.client.fetchVault()).revision
        await #expect(throws: CorpusRotationError.staleMaster(
            vaultKeyID: again.material.corpusKeyID, heldKeyID: world.old.corpusKeyID)) {
            _ = try await CorpusRotation.begin(
                client: world.vault.client, current: world.old, secrets: try secrets(), appleHeldCopy: nil)
        }
        #expect(try #require(try await world.vault.client.fetchVault()).revision == revisionBefore)
    }

    /// THE WHOLE-REPLACE PIN, ported from the retired 14c brain's suite
    /// (1b's settled-design note 4 — a real defect the RPC road fixed):
    /// BEGIN over a vault that HAD a recovery wrap, with no recovery key in
    /// the secrets, leaves NO stale wrap standing — the old words' wrap of
    /// the OLD master never survives beside the new class keys, and the
    /// old words open nothing. With the words in the secrets, the wrap is
    /// the NEW master under the SAME words.
    @Test func beginOverAVaultWithARecoveryWrapLeavesNoStaleWrap() async throws {
        let world = try await makeWorld()
        let words = try RecoveryPhrase.generate()
        try await world.vault.enrollment.landRecoveryWrap(words: words, material: world.old)
        #expect(try await world.vault.enrollment.hasRecoveryWrap() == true, "the pin isn't vacuous")

        let begun = try await CorpusRotation.begin(
            client: world.vault.client, current: world.old,
            secrets: try secrets(recoveryWords: nil), appleHeldCopy: nil)
        let vault = try #require(try await world.vault.client.fetchVault()).format
        #expect(vault.masterWrappedByRecovery == nil, "no recovery key in the secrets ⇒ NO wrap — never the old one")
        await #expect(throws: (any Error).self, "the old words open nothing") {
            _ = try await world.vault.enrollment.enroll(recoveryWords: words)
        }
        // Completion, then a rotation WITH the words: the wrap is M″ under them.
        let cleared = try await CorpusRotation.complete(client: world.vault.client, material: begun.material)
        let again = try await CorpusRotation.begin(
            client: world.vault.client, current: cleared,
            secrets: try secrets(recoveryWords: words), appleHeldCopy: nil)
        let rewrapped = try #require(try await world.vault.client.fetchVault()).format
        #expect(try rewrapped.unwrapMaster(withRecoveryKey: try RecoveryPhrase.recoveryWrapKey(words: words)).data
                == again.material.masterKey, "the same twelve words open the NEW master")
    }

    // MARK: - §4 step 3: THE WALK, and COMPLETION

    /// The driver re-encrypts every row below the seq (opened under the
    /// previous key by the seq rule), reports N of M, converges the fleet
    /// with ZERO conflict variants for a device that edited offline, and
    /// completion clears the previous key, its id AND the seq together —
    /// on the vault and in the material. RED ON OLD (behavioural revert:
    /// the walk making ONE pass and returning after it): a row the A5
    /// window hid from the first pull stays under the old key.
    @Test func theWalkReencryptsEveryRowBelowTheSeqAndCompletionClearsTheKeyAndTheSeqTogether() async throws {
        // The A5 visibility window is REAL here (`visibilityHorizon: 2`
        // ticks): a row written within the last two ticks is invisible to
        // a pull — the changefeed fix SyncSpec §5 documents.
        let world = try await makeWorld(visibilityHorizon: 2)
        let a = try client("A", prefix: "AA", world: world, material: world.old)
        let b = try client("B", prefix: "BB", world: world, material: world.old, clockOffset: 977, seed: 2)
        let (variantA, variantB): (String, String) = try a.with { ops, _ in
            let post = try ops.createPost(title: "before the rotation", profile: .blog)
            let first = try ops.newBlock(in: post.id, text: "Old-key prose, first block.", at: .end).variant.id
            let second = try ops.newBlock(in: post.id, text: "Old-key prose, second block.", at: .end).variant.id
            _ = try ops.newBlock(in: post.id, text: "Old-key prose, third block.", at: .end)
            return (first, second)
        }
        _ = try await a.push()
        await world.server.advanceClock(by: 2)  // the corpus becomes visible
        try await syncToQuiescence(a, b, server: world.server)
        try b.with { ops, _ in
            try ops.autosave(variantA, text: "Old-key prose, first block — B's offline edit.", charDelta: 20)
            try ops.autosave(variantB, text: "Old-key prose, second block — B's offline edit.", charDelta: 20)
        }
        // A LATE row under the OLD proof, committed just before the vault
        // write (its seq below the rotation seq) and still inside the
        // visibility window when the walk's FIRST pull runs — the pass the
        // second pull exists for.
        try a.with { ops, _ in _ = try ops.createPost(title: "typed a second before the switch", profile: .journal) }
        _ = try await a.push()

        // BEGIN on A (the ceremony's secrets), custody would land the material.
        let begun = try await CorpusRotation.begin(
            client: world.vault.client, current: world.old, secrets: try secrets(), appleHeldCopy: nil)
        let rotationSeq = try #require(begun.receipt.rotationStartedSeq)
        let rowsBelow = await world.server.storedRowsWithSeqs().filter { $0.serverSeq < rotationSeq }.count
        #expect(rowsBelow >= 6, "the whole pre-rotation corpus sits below the seq")

        // THE WALK, with the A5 window in play: the late row is invisible
        // to the first pull; the seam transport advances the server's clock
        // after the first batch lands (time passes), and the walk's NEXT
        // pass finds it — a walk that stopped after one pass would leave it
        // under the old key.
        let progress = LockIsolated<[CorpusRotation.Progress]>([])
        let driver = CorpusRotation(
            transport: SeamTransport(server: world.server, afterFirstReencrypt: .advanceClock(2)),
            batchSize: 4,
            progress: { p in progress.withValue { $0.append(p) } },
            horizonWait: timePasses(on: world.server))
        let report = try await driver.reencryptRemainder(material: begun.material)
        #expect(report.replaced == rowsBelow, "every row below the seq re-encrypted exactly once — the late one too")
        #expect(report.skipped == 0)
        #expect(report.passes >= 2, "the walk ends only at an EMPTY window — never after one pass")
        let seen = progress.value
        #expect(seen.first == CorpusRotation.Progress(reencrypted: 0, total: rowsBelow - 1),
                "M is the first pass's count (the late row was still invisible)")
        #expect(seen.last == CorpusRotation.Progress(reencrypted: rowsBelow, total: rowsBelow),
                "N reaches M, and M grows to what was found")
        #expect(seen.map(\.reencrypted) == seen.map(\.reencrypted).sorted(), "N never goes backwards")

        // Every stored row sits ABOVE the seq under the NEW key; the old key
        // opens nothing.
        let newSeam = SyncPayloadCrypto(keys: begun.material.clearingPreviousCorpusKey().syncKeys)
        let oldSeam = SyncPayloadCrypto(keys: world.old.syncKeys)
        for stored in await world.server.storedRowsWithSeqs() {
            #expect(stored.serverSeq > rotationSeq, "\(stored.row.table)/\(stored.row.rowID) above the seq")
            #expect((try? newSeam.decryptFromWire(stored)) != nil)
            guard let table = SyncSchema.table(named: stored.row.table),
                  table.encryptedColumns.contains(where: {
                      if case .text? = stored.row.columns[$0] { return true } else { return false }
                  })
            else { continue }
            #expect((try? oldSeam.decryptFromWire(stored)) == nil, "the OLD key opens nothing after the walk")
        }

        // COMPLETION under the CURRENT proof: key + id + seq cleared together.
        let completed = try await CorpusRotation.complete(client: world.vault.client, material: begun.material)
        #expect(completed.previousCorpusKey == nil && completed.previousCorpusKeyID == nil
                && completed.rotationStartedSeq == nil && completed.rotation == nil)
        let vaultRow = try #require(await world.server.vaultRow())
        #expect(vaultRow.previousCorpusKey == nil && vaultRow.previousCorpusKeyID == nil
                && vaultRow.rotationStartedSeq == nil)
        let after = try #require(try await world.vault.client.fetchVault()).format
        #expect(after.previousCorpusKey == nil && after.rotationStartedSeq == nil)
        // Idempotent: completing again writes nothing.
        let revision = try #require(try await world.vault.client.fetchVault()).revision
        _ = try await CorpusRotation.complete(client: world.vault.client, material: completed)
        #expect(try #require(try await world.vault.client.fetchVault()).revision == revision)

        // B FOLLOWS after completion (the passphrase → M′ → the class keys;
        // no previous key remains to carry) and pushes its OFFLINE edits:
        // versions UNBUMPED ⇒ a clean CAS ⇒ ZERO conflict variants.
        let followerMaster = try await world.vault.enrollment.enroll(passphrase: Self.passphrase).masterSymmetricKey
        let following = try CorpusRotation.materialFollowing(after, master: followerMaster)
        #expect(following.rotation == nil, "after completion a follower carries no previous key")
        b.keyProvider = FixedSyncKeyProvider(keys: following.syncKeys)
        a.keyProvider = FixedSyncKeyProvider(keys: completed.syncKeys)
        let pushed = try await b.push()
        #expect(pushed.accepted >= 2, "B's offline take edits CAS cleanly through the rotation")
        // (The fake's visibility window is real here: time passes before
        // the fleet reads what B just wrote.)
        await world.server.advanceClock(by: 2)
        _ = try await a.pull()
        _ = try await b.pull()
        #expect(try a.syncedDump() == b.syncedDump())
        #expect(try conflictVariants(a) == 0 && conflictVariants(b) == 0, "ZERO conflict variants")
        #expect(try a.db.fetchString("SELECT working_text FROM variant WHERE id = ?", [variantA])
                == "Old-key prose, first block — B's offline edit.")
    }

    /// pre-13x ladder round 1, F1 — BLOCKER-1, THE REVIEWER'S RED PIN: the
    /// walk world WITHOUT any clock advance between passes — a LATE row
    /// committed under the old proof just before the vault write (below
    /// the seq) and still inside the A5 visibility window while the walk
    /// runs; the transport is the PLAIN fake (no seam). Time passes ONCE,
    /// where production sleeps: the driver's injected `horizonWait`
    /// advances the fake's clock at the walk's first empty window, and the
    /// pull that follows finds the straggler. Then completion, and a
    /// sibling pulling to head after it OPENS EVERY ROW. RED ON OLD
    /// (behavioural revert: the wait removed — the walk returning at its
    /// first empty window — and the fake's completion guard removed): the
    /// straggler stays under the previous key, completion deletes that key
    /// everywhere, and the sibling's pull THROWS at decrypt — the wedged
    /// changefeed the reviewer traced.
    @Test func aRowHiddenByTheVisibilityWindowIsReencryptedBeforeCompletionAndEveryLaterPullOpens() async throws {
        let world = try await makeWorld(visibilityHorizon: 2)
        let a = try client("A", prefix: "AA", world: world, material: world.old)
        try a.with { ops, _ in
            let post = try ops.createPost(title: "before the rotation", profile: .blog)
            for i in 0..<3 {
                _ = try ops.newBlock(in: post.id, text: "Old-key prose, block \(i).", at: .end)
            }
        }
        _ = try await a.push()
        await world.server.advanceClock(by: 2)  // the corpus becomes visible
        // THE STRAGGLER: a note typed a second before the switch — pushed
        // under the OLD proof, so below the coming rotation seq, and inside
        // the visibility window for the whole of a fast walk.
        try a.with { ops, _ in _ = try ops.createPost(title: "typed a second before the switch", profile: .journal) }
        _ = try await a.push()
        let stragglerID = try #require(try a.db.fetchString(
            "SELECT id FROM container WHERE title = ?", ["typed a second before the switch"]))

        let begun = try await CorpusRotation.begin(
            client: world.vault.client, current: world.old, secrets: try secrets(), appleHeldCopy: nil)
        let rotationSeq = try #require(begun.receipt.rotationStartedSeq)
        let rowsBelow = await world.server.storedRowsWithSeqs().filter { $0.serverSeq < rotationSeq }.count
        #expect(rowsBelow >= 5)
        #expect(await world.server.ciphertextRowsBelow(rotationSeq) >= 5, "the straggler's row carries ciphertext (a title)")

        // THE WALK over the PLAIN transport: no seam advances the clock
        // between passes — only the wait past the horizon does, once.
        let waits = LockIsolated(0)
        let server = world.server
        let driver = CorpusRotation(
            transport: server, batchSize: 4,
            horizonWait: {
                waits.withValue { $0 += 1 }
                await server.advanceClock(by: 2)
            })
        let report = try await driver.reencryptRemainder(material: begun.material)
        #expect(waits.value == 1, "the wait past the horizon runs exactly once — at the first empty window")
        #expect(report.replaced == rowsBelow, "every row below the seq re-encrypted — the straggler too: \(report)")
        #expect(report.passes == 4, "a pass that re-encrypted · the first empty window (then the wait) · the pass that found the straggler · the empty window that ends the walk")
        #expect(await world.server.ciphertextRowsBelow(rotationSeq) == 0)
        #expect(try #require(await world.server.currentSeq(table: "container", rowID: stragglerID)) > rotationSeq,
                "the straggler was re-stamped above the seq")

        // COMPLETION — the guard finds nothing below the seq.
        let completed = try await CorpusRotation.complete(client: world.vault.client, material: begun.material)
        #expect(completed.rotation == nil)
        #expect(await world.server.vaultRow()?.previousCorpusKeyID == nil)

        // A SIBLING following AFTER completion (no previous key anywhere)
        // pulls to head — every row opens; the straggler is in the clear.
        await world.server.advanceClock(by: 2)
        let after = try #require(try await world.vault.client.fetchVault()).format
        let followerMaster = try await world.vault.enrollment.enroll(passphrase: Self.passphrase).masterSymmetricKey
        let following = try CorpusRotation.materialFollowing(after, master: followerMaster)
        #expect(following.rotation == nil)
        let b = try client("B", prefix: "BB", world: world, material: following, clockOffset: 977, seed: 2)
        let pulled = try await b.pull()
        #expect(pulled.applied > 0 && !pulled.stalled, "the sibling's pull opens every row — nothing is left under a key nobody holds")
        #expect(try b.db.fetchString("SELECT title FROM container WHERE id = ?", [stragglerID])
                == "typed a second before the switch", "the straggler reads in the clear on the sibling")
        a.keyProvider = FixedSyncKeyProvider(keys: completed.syncKeys)
        _ = try await a.pull()
        #expect(try a.syncedDump() == b.syncedDump())
    }

    /// pre-13x ladder round 2, F3 (NIT-N5) — RED ON OLD: the wait past the
    /// horizon CONSUMED a pass of the `maxPasses` budget — an empty window
    /// at exactly the last budgeted pass waited, continued, and the loop
    /// exited into `walkDidNotConverge(remaining: 0)`: an honest-sounding
    /// refusal over nothing remaining (the resume then re-walked). The
    /// smallest world that reaches it: a corpus done in ONE working pass
    /// under a budget of TWO — pass 2 is the first empty window. Now the
    /// budget counts working passes only; the report still counts pulls.
    @Test func theWaitPastTheHorizonSpendsNoPassOfTheBudget() async throws {
        let world = try await makeWorld()
        let a = try client("A", prefix: "AA", world: world, material: world.old)
        try a.with { ops, _ in
            let post = try ops.createPost(title: "before the rotation", profile: .blog)
            _ = try ops.newBlock(in: post.id, text: "Old-key prose.", at: .end)
        }
        _ = try await a.push()
        let begun = try await CorpusRotation.begin(
            client: world.vault.client, current: world.old, secrets: try secrets(), appleHeldCopy: nil)
        let rotationSeq = try #require(begun.receipt.rotationStartedSeq)
        let waits = LockIsolated(0)
        let driver = CorpusRotation(
            transport: world.server, batchSize: 100, maxPasses: 2,
            horizonWait: { waits.withValue { $0 += 1 } })
        let report = try await driver.reencryptRemainder(material: begun.material)
        #expect(waits.value == 1, "the wait ran once, at the first empty window")
        #expect(report.passes == 3, "the working pass · the first empty window (then the wait) · the empty window that ends the walk — three pulls, ONE pass of budget")
        #expect(report.replaced >= 3 && report.skipped == 0)
        #expect(await world.server.ciphertextRowsBelow(rotationSeq) == 0)
    }

    /// F1 — THE SERVER's COMPLETION GUARD (the structural half; the fake
    /// server's twin of the maintenance artifact): a walk whose wait does
    /// NOT let time pass (the straggler stays hidden) leaves one
    /// ciphertext row below the seq; the clearing write is REFUSED
    /// (`rotationRowsRemain`) and clears nothing; once time passes a
    /// re-walk finds the row and completion succeeds. RED ON OLD
    /// (behavioural revert: the fake's guard removed): the first completion
    /// SUCCEEDS with the ciphertext straggler orphaned.
    @Test func completionIsRefusedWhileACiphertextRowStillSitsBelowTheSeq() async throws {
        let world = try await makeWorld(visibilityHorizon: 2)
        let a = try client("A", prefix: "AA", world: world, material: world.old)
        try a.with { ops, _ in
            let post = try ops.createPost(title: "before the rotation", profile: .blog)
            _ = try ops.newBlock(in: post.id, text: "Old-key prose.", at: .end)
        }
        _ = try await a.push()
        await world.server.advanceClock(by: 2)
        // A CIPHERTEXT straggler (a note — its title is sealed), committed
        // just before the switch and hidden by the window during the walk.
        try a.with { ops, _ in _ = try ops.createPost(title: "the ciphertext straggler", profile: .journal) }
        _ = try await a.push()

        let begun = try await CorpusRotation.begin(
            client: world.vault.client, current: world.old, secrets: try secrets(), appleHeldCopy: nil)
        let rotationSeq = try #require(begun.receipt.rotationStartedSeq)
        let rowsBelow = await world.server.storedRowsWithSeqs().filter { $0.serverSeq < rotationSeq }.count
        #expect(await world.server.ciphertextRowsBelow(rotationSeq) >= 3)

        // A walk in which time does NOT pass: the straggler stays hidden.
        let server = world.server
        let frozen = CorpusRotation(transport: server, batchSize: 4, horizonWait: {})
        let first = try await frozen.reencryptRemainder(material: begun.material)
        #expect(first.replaced == rowsBelow - 1, "everything visible was re-encrypted; the hidden straggler was not")
        #expect(await world.server.ciphertextRowsBelow(rotationSeq) == 1, "one ciphertext row still below the seq")

        // COMPLETION REFUSED — and nothing cleared.
        let revisionBefore = try #require(try await world.vault.client.fetchVault()).revision
        await #expect(throws: KeyVaultClientError.rotationRowsRemain, "the server refuses to clear a key a row is still under") {
            _ = try await CorpusRotation.complete(client: world.vault.client, material: begun.material)
        }
        let still = try #require(try await world.vault.client.fetchVault())
        #expect(still.revision == revisionBefore, "a refused completion writes nothing")
        #expect(still.format.previousCorpusKey?.keyID == world.old.corpusKeyID && still.format.rotationStartedSeq == rotationSeq)
        let row = try #require(await world.server.vaultRow())
        #expect(row.previousCorpusKeyID == world.old.corpusKeyID && row.rotationStartedSeq == rotationSeq)

        // Time passes; the re-walk finds the straggler; completion succeeds.
        await world.server.advanceClock(by: 2)
        let again = try await frozen.reencryptRemainder(material: begun.material)
        #expect(again.replaced == 1, "the re-walk found exactly what the window had hidden: \(again)")
        #expect(await world.server.ciphertextRowsBelow(rotationSeq) == 0)
        let completed = try await CorpusRotation.complete(client: world.vault.client, material: begun.material)
        #expect(completed.rotation == nil)
        let clearedRow = try #require(await world.server.vaultRow())
        #expect(clearedRow.previousCorpusKeyID == nil && clearedRow.rotationStartedSeq == nil,
                "completion clears key + id + seq together once nothing ciphertext remains below")
    }

    /// F1 — THE ORCHESTRATOR'S QUALIFICATION, pinned: a straggler in an
    /// ALL-PLAIN table (no encrypted column — a row under no key) NEVER
    /// holds a completion. The walk that could not see it completes; the
    /// row sits below the seq through completion and still opens for every
    /// device (the seam returns a plain-table row untouched). Not a red-on-
    /// old pin — a fence on the guard's shape (counting every table would
    /// refuse THIS completion forever on a row with nothing at stake).
    @Test func aStragglerInAnAllPlainTableNeverHoldsACompletion() async throws {
        let world = try await makeWorld(visibilityHorizon: 2)
        let a = try client("A", prefix: "AA", world: world, material: world.old)
        try a.with { ops, _ in
            let post = try ops.createPost(title: "before the rotation", profile: .blog)
            _ = try ops.newBlock(in: post.id, text: "Old-key prose.", at: .end)
        }
        _ = try await a.push()
        await world.server.advanceClock(by: 2)
        // The PLAIN straggler: a purge intent — ids and enums only.
        let plainRow = SyncRow(
            table: "purge_intent", rowID: "pi-straggler",
            columns: [
                "id": .text("pi-straggler"), "owner_id": .text(FakeSyncServer.defaultUserID),
                "table_name": .text("container"), "row_id": .text("gone"),
                "requested_at": .text(Fixture.now), "created_at": .text(Fixture.now),
                "updated_at": .text(Fixture.now), "deleted_at": .null,
            ],
            syncVersion: 0)
        _ = try await world.server.push(
            [plainRow], activeKeyID: world.old.corpusKeyID, keyProof: world.old.syncKeys.keyProof)
        #expect(SyncSchema.table(named: "purge_intent")?.encryptedColumns.isEmpty == true, "the pin's premise")

        let begun = try await CorpusRotation.begin(
            client: world.vault.client, current: world.old, secrets: try secrets(), appleHeldCopy: nil)
        let rotationSeq = try #require(begun.receipt.rotationStartedSeq)
        let plainSeqBefore = try #require(await world.server.currentSeq(table: "purge_intent", rowID: "pi-straggler"))
        #expect(plainSeqBefore < rotationSeq)

        // The frozen walk cannot see the plain row; completion SUCCEEDS.
        let server = world.server
        let frozen = CorpusRotation(transport: server, batchSize: 4, horizonWait: {})
        _ = try await frozen.reencryptRemainder(material: begun.material)
        #expect(await world.server.ciphertextRowsBelow(rotationSeq) == 0, "nothing ciphertext is below the seq")
        let completed = try await CorpusRotation.complete(client: world.vault.client, material: begun.material)
        #expect(completed.rotation == nil)
        #expect(await world.server.vaultRow()?.previousCorpusKeyID == nil)
        #expect(try #require(await world.server.currentSeq(table: "purge_intent", rowID: "pi-straggler")) == plainSeqBefore,
                "the plain row sat below the seq through completion — it held nothing")

        // Every device opens it: a plain row is under no key.
        await world.server.advanceClock(by: 2)
        let seam = SyncPayloadCrypto(keys: completed.syncKeys)
        let stored = try #require(await world.server.storedRowsWithSeqs().first { $0.row.rowID == "pi-straggler" })
        #expect((try? seam.decryptFromWire(stored)) != nil)
        a.keyProvider = FixedSyncKeyProvider(keys: completed.syncKeys)
        let pulled = try await a.pull()
        #expect(!pulled.stalled)
        #expect(try a.db.fetchString("SELECT row_id FROM purge_intent WHERE id = 'pi-straggler'") == "gone",
                "the plain straggler reads on the device")
    }

    /// F1 — THE COORDINATOR'S REFINEMENT (a): a row of an ENCRYPTED table
    /// whose encrypted columns are ALL NULL (a block with no name and no
    /// presentation) carries no ciphertext — it is under no key — so a
    /// straggler of that shape, hidden from the walk, NEVER holds a
    /// completion (a guard that counted it could refuse forever over a row
    /// nothing needs to touch). The walk, when it does see such a row,
    /// re-stamps it like any other (the walk never skips) — the two halves
    /// agree by construction.
    @Test func aStragglerWithEveryEncryptedColumnNullNeverHoldsACompletion() async throws {
        let world = try await makeWorld(visibilityHorizon: 2)
        let a = try client("A", prefix: "AA", world: world, material: world.old)
        try a.with { ops, _ in
            let post = try ops.createPost(title: "before the rotation", profile: .blog)
            _ = try ops.newBlock(in: post.id, text: "Old-key prose.", at: .end)
        }
        _ = try await a.push()
        await world.server.advanceClock(by: 2)
        // The blank straggler: a `block` row — an encrypted TABLE — with
        // `name` and `presentation` NULL, pushed just before the switch.
        _ = try await world.server.push(
            [blockRow(id: "blank-block", lastContainer: nil)],
            activeKeyID: world.old.corpusKeyID, keyProof: world.old.syncKeys.keyProof)
        #expect(SyncSchema.table(named: "block")?.encryptedColumns.isEmpty == false, "the pin's premise: block is an encrypted table")
        let blankSeqBefore = try #require(await world.server.currentSeq(table: "block", rowID: "blank-block"))

        let begun = try await CorpusRotation.begin(
            client: world.vault.client, current: world.old, secrets: try secrets(), appleHeldCopy: nil)
        let rotationSeq = try #require(begun.receipt.rotationStartedSeq)
        #expect(blankSeqBefore < rotationSeq)

        // The frozen walk cannot see it; completion SUCCEEDS — the row
        // carries no ciphertext.
        let server = world.server
        let frozen = CorpusRotation(transport: server, batchSize: 4, horizonWait: {})
        _ = try await frozen.reencryptRemainder(material: begun.material)
        #expect(await world.server.ciphertextRowsBelow(rotationSeq) == 0, "an all-NULL row is not counted")
        let completed = try await CorpusRotation.complete(client: world.vault.client, material: begun.material)
        #expect(completed.rotation == nil)
        #expect(await world.server.vaultRow()?.previousCorpusKeyID == nil)
        #expect(try #require(await world.server.currentSeq(table: "block", rowID: "blank-block")) == blankSeqBefore,
                "the blank row sat below the seq through completion — it held nothing")
        // …and opens for a device under the completed keys.
        await world.server.advanceClock(by: 2)
        a.keyProvider = FixedSyncKeyProvider(keys: completed.syncKeys)
        let pulled = try await a.pull()
        #expect(!pulled.stalled)
        #expect(try a.db.fetchInt("SELECT COUNT(*) FROM block WHERE id = 'blank-block'") == 1, "the blank block reads on the device")
    }

    /// F1 — THE COORDINATOR'S REFINEMENT (b): A POISON ROW — ciphertext the
    /// client cannot open under EITHER key (sealed under a key this account
    /// never held; the Phase-12 poison-row class) — sits below the seq. The
    /// walk THROWS at it (nothing is re-sealed by guesswork); completion is
    /// REFUSED (the row carries ciphertext below the seq) and clears NOTHING:
    /// the previous key stays in the vault and in custody, every old-key
    /// row stays readable by the seq rule on every device (a follower picks
    /// the previous key up from the vault), and the second-rotation door
    /// refuses (decision 32) — the honest STILL-FINISHING state, never a
    /// cleared key. The release valve is the purge road: removing the
    /// unreadable row from the partition (`sync_purge_execute`) lets the
    /// next walk find nothing and completion clear.
    @Test func aPoisonRowLeavesTheRotationStillFinishingWithThePreviousKeyRetainedUntilItIsPurged() async throws {
        let world = try await makeWorld()
        let a = try client("A", prefix: "AA", world: world, material: world.old)
        try a.with { ops, _ in
            let post = try ops.createPost(title: "before the rotation", profile: .blog)
            _ = try ops.newBlock(in: post.id, text: "Old-key prose the fleet keeps reading.", at: .end)
        }
        _ = try await a.push()
        // THE POISON: a container whose title is sealed under the SUITE's
        // fixed test key (`SyncTestKeys`) — not this account's corpus key —
        // pushed under the account's old proof, so it sits below the seq.
        _ = try await world.server.push(
            [try containerRow(id: "poison", title: "sealed under a key nobody here holds")],
            activeKeyID: world.old.corpusKeyID, keyProof: world.old.syncKeys.keyProof)
        let oldSeam = SyncPayloadCrypto(keys: world.old.syncKeys)
        let poisonStored = try #require(await world.server.storedRowsWithSeqs().first { $0.row.rowID == "poison" })
        #expect((try? oldSeam.decryptFromWire(poisonStored)) == nil, "the pin's premise: the old key does not open it either")

        let begun = try await CorpusRotation.begin(
            client: world.vault.client, current: world.old, secrets: try secrets(), appleHeldCopy: nil)
        let rotationSeq = try #require(begun.receipt.rotationStartedSeq)
        let server = world.server
        let driver = CorpusRotation(transport: server, batchSize: 4, horizonWait: timePasses(on: server))
        // THE WALK THROWS at the poison row — nothing is re-sealed by guesswork.
        await #expect(throws: (any Error).self, "the walk refuses at a row it cannot open") {
            _ = try await driver.reencryptRemainder(material: begun.material)
        }
        #expect(await world.server.ciphertextRowsBelow(rotationSeq) >= 1, "the poison row (at least) is still below the seq")

        // COMPLETION REFUSED — the previous key RETAINED everywhere.
        await #expect(throws: KeyVaultClientError.rotationRowsRemain) {
            _ = try await CorpusRotation.complete(client: world.vault.client, material: begun.material)
        }
        let vault = try #require(try await world.vault.client.fetchVault()).format
        #expect(vault.previousCorpusKey?.keyID == world.old.corpusKeyID && vault.rotationStartedSeq == rotationSeq,
                "the vault still carries the previous key + the seq")
        #expect(begun.material.rotation != nil, "custody's material still carries the previous key")
        // Every OLD-key row stays readable by the seq rule — on the acting
        // device and on a follower that picks the previous key up from the vault.
        let followerMaster = try await world.vault.enrollment.enroll(passphrase: Self.passphrase).masterSymmetricKey
        let following = try CorpusRotation.materialFollowing(vault, master: followerMaster)
        #expect(following.rotation?.startedSeq == rotationSeq, "a follower carries the previous key + the seq")
        let followerSeam = SyncPayloadCrypto(keys: following.syncKeys)
        for stored in await world.server.storedRowsWithSeqs() where stored.row.rowID != "poison" && stored.serverSeq < rotationSeq {
            #expect((try? followerSeam.decryptFromWire(stored)) != nil, "\(stored.row.table)/\(stored.row.rowID) reads under the retained previous key")
        }
        // The second-rotation door refuses (decision 32) — never a cleared key.
        await #expect(throws: CorpusRotationError.rotationInProgress(previousKeyID: world.old.corpusKeyID)) {
            _ = try await CorpusRotation.begin(
                client: world.vault.client, current: begun.material, secrets: try secrets(), appleHeldCopy: nil)
        }

        // THE RELEASE VALVE: the purge road removes the unreadable row from
        // the partition; the next walk finds nothing and completion clears.
        let purged = try await world.server.executePurge(
            [SyncPurgeTarget(table: "container", rowID: "poison")],
            activeKeyID: begun.material.corpusKeyID, keyProof: begun.material.syncKeys.keyProof)
        #expect(purged > 0)
        let report = try await driver.reencryptRemainder(material: begun.material)
        #expect(report.replaced >= 0)
        #expect(await world.server.ciphertextRowsBelow(rotationSeq) == 0)
        let completed = try await CorpusRotation.complete(client: world.vault.client, material: begun.material)
        #expect(completed.rotation == nil)
        #expect(await world.server.vaultRow()?.previousCorpusKeyID == nil, "cleared once nothing unreadable remains")
    }

    /// ANY ENROLLED DEVICE CAN FINISH A ROTATION (decision 6; §12): the
    /// acting device is lost right after the vault write with every row
    /// still under the previous key; a FOLLOWER reads M′ by the passphrase,
    /// C′ and the previous key + the seq under it (`materialFollowing`),
    /// re-encrypts the remainder and clears the vault at head — and a NEW
    /// device enrolled mid-rotation opens the mixed corpus by the seq rule
    /// and pulls to an identical store.
    @Test func anyEnrolledDeviceCanFinishARotationAndANewDeviceEnrolledMidRotationReadsTheMixedCorpus() async throws {
        let world = try await makeWorld()
        let a = try client("A", prefix: "AA", world: world, material: world.old)
        try a.with { ops, _ in
            let post = try ops.createPost(title: "the acting device's corpus", profile: .blog)
            _ = try ops.newBlock(in: post.id, text: "written before the rotation", at: .end)
        }
        _ = try await a.push()
        // The acting device begins and DIES (never walks).
        let begun = try await CorpusRotation.begin(
            client: world.vault.client, current: world.old, secrets: try secrets(), appleHeldCopy: nil)
        let seq = try #require(begun.receipt.rotationStartedSeq)

        // A NEW device enrolled MID-rotation: the passphrase → M′; the mixed
        // corpus (every row still under the old key, below the seq) opens
        // by the seq rule, and it pulls to A's store.
        let vaultMid = try #require(try await world.vault.client.fetchVault()).format
        let newMaster = try await world.vault.enrollment.enroll(passphrase: Self.passphrase).masterSymmetricKey
        let newMaterial = try CorpusRotation.materialFollowing(vaultMid, master: newMaster)
        #expect(newMaterial.rotation?.startedSeq == seq, "a mid-rotation enrollee carries the previous key + the seq")
        let n = try client("N", prefix: "CC", world: world, material: newMaterial, clockOffset: 313, seed: 3)
        _ = try await n.pull()
        #expect(try n.syncedDump() == a.syncedDump(), "the new device reads the mixed corpus whole")

        // A FOLLOWER finishes: the walk + completion at head.
        let follower = try CorpusRotation.materialFollowing(vaultMid, master: newMaster)
        let report = try await CorpusRotation(transport: world.server, batchSize: 3, horizonWait: timePasses(on: world.server))
            .reencryptRemainder(material: follower)
        #expect(report.replaced > 0)
        let remaining = await world.server.storedRowsWithSeqs().filter { $0.serverSeq < seq }
        #expect(remaining.isEmpty, "nothing of the account is left under the previous key")
        let done = try await CorpusRotation.complete(client: world.vault.client, material: follower)
        let row = try #require(await world.server.vaultRow())
        #expect(row.previousCorpusKey == nil && row.previousCorpusKeyID == nil && row.rotationStartedSeq == nil,
                "the follower's completing write clears key + id + seq together")
        // Both devices read everything under the completed world.
        n.keyProvider = FixedSyncKeyProvider(keys: done.syncKeys)
        a.keyProvider = FixedSyncKeyProvider(keys: done.syncKeys)
        try n.with { ops, _ in _ = try ops.createPost(title: "after the follower finished", profile: .blog) }
        try await syncToQuiescence(a, n, server: world.server)
        #expect(try a.syncedDump() == n.syncedDump())
    }

    /// A CRASH MID-RE-ENCRYPTION (§12's second crash pin, the driver's
    /// half): the transport dies after the first batch landed; re-running
    /// the walk finishes — rows already replaced sit above the seq and are
    /// not found again, the rest are re-encrypted, and the union is the
    /// whole corpus exactly once.
    @Test func aCrashMidReencryptionReRunsToCompletion() async throws {
        let world = try await makeWorld()
        let a = try client("A", prefix: "AA", world: world, material: world.old)
        try a.with { ops, _ in
            let post = try ops.createPost(title: "a corpus of some size", profile: .blog)
            for i in 0..<9 {
                _ = try ops.newBlock(in: post.id, text: "Block \(i) under the old key.", at: .end)
            }
        }
        _ = try await a.push()
        let begun = try await CorpusRotation.begin(
            client: world.vault.client, current: world.old, secrets: try secrets(), appleHeldCopy: nil)
        let seq = try #require(begun.receipt.rotationStartedSeq)
        let total = await world.server.storedRowsWithSeqs().filter { $0.serverSeq < seq }.count

        // The crash: one batch lands, then the process dies.
        let crashing = SeamTransport(server: world.server, afterFirstReencrypt: .crash)
        let first = CorpusRotation(transport: crashing, batchSize: 4, horizonWait: timePasses(on: world.server))
        await #expect(throws: SeamTransport.SimulatedCrash.self) {
            _ = try await first.reencryptRemainder(material: begun.material)
        }
        let landedFirst = await crashing.landed
        #expect(landedFirst == 4, "the first batch landed before the crash")
        let stillBelow = await world.server.storedRowsWithSeqs().filter { $0.serverSeq < seq }.count
        #expect(stillBelow == total - landedFirst)

        // THE RESUME: the walk re-runs over the plain transport (the marker
        // says `.reencrypt`; the material is custody's) and finishes.
        let resumed = try await CorpusRotation(transport: world.server, batchSize: 4, horizonWait: timePasses(on: world.server))
            .reencryptRemainder(material: begun.material)
        #expect(resumed.replaced == total - landedFirst, "exactly what was left — nothing re-encrypted twice")
        #expect(await world.server.storedRowsWithSeqs().allSatisfy { $0.serverSeq > seq })
        _ = try await CorpusRotation.complete(client: world.vault.client, material: begun.material)
        #expect(await world.server.vaultRow()?.previousCorpusKeyID == nil)
    }

    // MARK: - The marker and the material

    /// The per-step marker: round-trips every step with its facts; a
    /// 14c-era value (a bare stamp) still counts as set and reads as the
    /// most conservative step; clearing is total. RED ON OLD (behavioural
    /// revert: the engine's marker guard removed): rounds proceed with
    /// the marker set.
    @Test func theMarkerRoundTripsItsStepAndRefusesRoundsWhileAnyStepIsSet() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        try a.with { ops, _ in _ = try ops.createPost(title: "typed", profile: .blog) }
        let outbox = try a.outboxCount()
        for step in RotationMarker.Step.allCases {
            let marker = RotationMarker(
                step: step, entersCastle: true,
                oldKeyFingerprint: "0011223344556677", newKeyFingerprint: "8899aabbccddeeff",
                newCorpusKeyID: "c-new", startedAt: Fixture.now)
            try await a.db.write { db in try RotationMarker.write(marker, db) }
            #expect(try await a.db.read { try RotationMarker.read($0) } == marker, "\(step) round-trips")
            #expect(try await a.db.read { try RotationMarker.isSet($0) })
            await #expect(throws: SyncError.accountRekeyIncomplete, "\(step): push refuses") { _ = try await a.push() }
            await #expect(throws: SyncError.accountRekeyIncomplete, "\(step): pull refuses") { _ = try await a.pull() }
            #expect(try a.outboxCount() == outbox, "outbox intact while paused")
        }
        #expect(try await a.db.read { try RotationMarker.read($0) }?.advanced(to: .offer).step == .offer)
        // The 14c-era value: a bare stamp.
        try await a.db.write { db in
            try db.execute(
                sql: "INSERT OR REPLACE INTO sync_state (key, value) VALUES (?, ?)",
                arguments: [RotationMarker.key, "2026-08-11T00:00:00.000Z"])
        }
        let legacy = try await a.db.read { try RotationMarker.read($0) }
        #expect(legacy?.step == .vaultWrite && legacy?.entersCastle == false)
        try await a.db.write { db in try RotationMarker.clear(db) }
        #expect(try await a.db.read { try RotationMarker.read($0) } == nil)
        #expect(try await a.db.read { try RotationMarker.isSet($0) } == false)
        _ = try await a.push()
        #expect(try a.outboxCount() == 0, "rounds drain again once the marker clears")
    }

    /// The custody material's rotation fields: present only all-three; a
    /// pre-2b blob (no fields) decodes with none; the seam reads them.
    @Test func theMaterialCarriesTheRotationAllThreeOrNoneAndOldBlobsDecodeWithNone() throws {
        let plain = DeviceKeyMaterial(
            masterKey: Data(repeating: 1, count: 32), corpusKey: Data(repeating: 2, count: 32),
            corpusKeyID: "c-new", journalBridgeKey: Data(repeating: 3, count: 32), journalBridgeKeyID: "j")
        #expect(plain.rotation == nil && plain.syncKeys.rotation == nil)
        let carried = plain.carryingPreviousCorpusKey(Data(repeating: 9, count: 32), keyID: "c-old", startedSeq: 42)
        #expect(carried.rotation?.previousCorpusKeyID == "c-old" && carried.rotation?.startedSeq == 42)
        #expect(carried.syncKeys.rotation?.startedSeq == 42, "the seam reads the rotation off the material")
        let decoded = try JSONDecoder().decode(DeviceKeyMaterial.self, from: try JSONEncoder().encode(carried))
        #expect(decoded == carried)
        #expect(carried.clearingPreviousCorpusKey() == plain)
        // A 14b/1a-era blob: the five fields only.
        let oldBlob = Data("""
            {"masterKey":"AQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQE=","corpusKey":"AgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgI=","corpusKeyID":"c-new","journalBridgeKey":"AwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwM=","journalBridgeKeyID":"j"}
            """.utf8)
        let legacy = try JSONDecoder().decode(DeviceKeyMaterial.self, from: oldBlob)
        #expect(legacy == plain, "an old custody blob decodes with no rotation")
        // Half a rotation is no rotation (both-or-neither by construction).
        var half = plain
        half.previousCorpusKey = Data(repeating: 9, count: 32)
        #expect(half.rotation == nil)
    }
}

/// A transport with ONE seam after the first re-encrypt batch lands: it
/// either DIES there (the crash mid-walk the resume must survive) or lets
/// time pass on the server (the A5 visibility window closing — what makes
/// a second pass find what the first could not).
private actor SeamTransport: SyncTransport, SyncRotationTransport {
    struct SimulatedCrash: Error {}
    enum Seam { case crash, advanceClock(Int64) }
    let server: FakeSyncServer
    let seam: Seam
    private(set) var landed = 0
    private var tripped = false

    init(server: FakeSyncServer, afterFirstReencrypt seam: Seam) {
        self.server = server
        self.seam = seam
    }

    func push(_ batch: [SyncRow], activeKeyID: String, keyProof: String) async throws -> [SyncPushOutcome] {
        try await server.push(batch, activeKeyID: activeKeyID, keyProof: keyProof)
    }

    func pull(since: Int64, limit: Int, activeKeyID: String, keyProof: String, deviceID: String?) async throws -> [SyncPulledRow] {
        try await server.pull(since: since, limit: limit, activeKeyID: activeKeyID, keyProof: keyProof, deviceID: deviceID)
    }

    func schemaVersion() async throws -> Int { await server.schemaVersion() }

    func reencrypt(_ rows: [SyncRow], activeKeyID: String, keyProof: String) async throws -> [SyncReencryptOutcome] {
        let outcomes = try await server.reencrypt(rows, activeKeyID: activeKeyID, keyProof: keyProof)
        landed += outcomes.filter { if case .replaced = $0 { return true } else { return false } }.count
        if !tripped {
            tripped = true
            switch seam {
            case .crash: throw SimulatedCrash()
            case .advanceClock(let ticks): await server.advanceClock(by: ticks)
            }
        }
        return outcomes
    }
}
