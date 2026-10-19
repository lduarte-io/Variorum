//
//  VaultRaceTests.swift
//  VariorumCoreTests — VX-307 U1 piece 5: VX-109's pin (the ONE-ROW CAS
//  write refuses the loser plainly — no rotation exists to resurrect a
//  posture) and VX-313's wire half (a tampered sync-keys custody value can
//  never steer an act — the executor verifies custody against the vault it
//  fetched, and the server's proof stands apart from custody entirely).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

/// A vault leaf whose FIRST update lands a competing write first — the true
/// write race (both devices read the same revision; one lands between the
/// other's read and its write; the CAS refuses the second).
private final class InterleavingVault: VaultLeaf {
    let inner: any VaultLeaf
    var beforeFirstUpdate: (() async throws -> Void)?

    init(inner: any VaultLeaf) {
        self.inner = inner
    }

    func fetchVault(accountID: String) async throws -> VaultSnapshot? {
        try await inner.fetchVault(accountID: accountID)
    }

    func createVault(_ vault: AccountVault, accountID: String, device: String) async throws -> VaultSnapshot {
        try await inner.createVault(vault, accountID: accountID, device: device)
    }

    func updateVault(
        _ vault: AccountVault, accountID: String, expectedRevision: Int, proofMaster: SymmetricKey,
        successorMaster: SymmetricKey?, device: String
    ) async throws -> VaultSnapshot {
        if let competing = beforeFirstUpdate {
            beforeFirstUpdate = nil
            try await competing()
        }
        return try await inner.updateVault(
            vault, accountID: accountID, expectedRevision: expectedRevision, proofMaster: proofMaster,
            successorMaster: successorMaster, device: device)
    }
}

@Suite("VX-307 U1 — VX-109: the one-row CAS refuses the loser plainly")
struct VaultCASRaceTests {
    /// Two devices of one Standard account press Use Castle together, the
    /// MAC's entry landing in the window between the phone's fresh vault read
    /// and its own write. The one-row CAS REFUSES the loser's write — nothing
    /// is silently overwritten (the VX-109 class: a concurrent crossing could
    /// silently return an account to its old posture through the rotation's
    /// re-fetch; the rotation is gone, so the single CAS write is the whole
    /// guard). The refusal surfaces (never silent); the vault stays the
    /// winner's whole; the loser's library is untouched, and it then FOLLOWS.
    @Test func twoConcurrentUseCastlesTheCASRefusesTheLoser() async throws {
        let mac = try EX(.standard, synced: true)
        let phone = try EX(.standard, synced: true, joining: mac)
        let phoneKey = phone.key
        // The phone's executor, its vault leaf interleaved: the MAC's entry
        // lands between the phone's fresh read and its own write.
        let interleaved = InterleavingVault(inner: phone.world)
        interleaved.beforeFirstUpdate = {
            let macExecutor = mac.executor()
            var macLibrary = try mac.unlocked(macExecutor)
            _ = try await macExecutor.useCastle(&macLibrary, typed: mac.typed, gate: .alwaysAsk)
        }
        var leaves = phone.world.leaves
        leaves.vault = interleaved
        let executor = ProtectionExecutor(
            leaves: leaves,
            configuration: ExecutorConfiguration(
                scope: EX.scope, libraryID: phone.libraryID, deviceName: "Mac A", floor: PF.floor,
                session: phone.session),
            guards: .all)
        var library = try executor.unlock(with: phone.key)
        // The loser's write REFUSES — surfaced, never a silent landing.
        await #expect(throws: (any Error).self) {
            _ = try await executor.useCastle(&library, typed: phone.typed, gate: .alwaysAsk)
        }
        // The phone's library is untouched: same key, still Standard.
        #expect(phone.world.live?.fingerprint == PF.fp(phoneKey))
        #expect(phone.liveRecord?.mode == .standard)
        // The vault is the WINNER's write, whole: Castle, one earlier key —
        // the loser's write never overwrote it.
        let vault = try #require(phone.world.server.snapshot(phone.account!))
        #expect(vault.mode == .castle)
        #expect(vault.vault.earlierRowKeys.count == 1)
        // The loser's failed write left an in-flight entry; the NEXT open
        // resumes it, finds the account moved, and ROLLS IT BACK — the
        // library is Standard still, untouched (the §3.6 resume road).
        let (_, resumed, _) = try await phone.relaunchAndSettle()
        #expect(phone.liveRecord?.mode == .standard)
        #expect(phone.world.live?.fingerprint == PF.fp(phoneKey))
        expectSettled(phone, resumed)
        // And the loser now FOLLOWS into Castle (rule 10): one secret in.
        let follower = phone.executor()
        var followed = try phone.unlocked(follower)
        _ = try await follower.follow(&followed, kind: .intoCastle, typed: TypedSecrets(words: phone.words))
        #expect(phone.liveRecord?.mode == .castle)
    }

    /// The leaf-level letter: a stale expected revision refuses typed, and
    /// the row is not moved.
    @Test func aStaleRevisionRefusesAtTheLeaf() async throws {
        let mac = try EX(.standard, synced: true)
        let snapshot = try #require(mac.world.server.snapshot(mac.account!))
        let master = try #require(mac.material).masterKey
        // Land one write so the revision moves past 1.
        _ = try mac.world.server.update(
            VaultModel.leavingCastle(snapshot.vault, device: "Mac A"), accountID: mac.account!,
            expectedRevision: snapshot.revision, proofMaster: master, successorMaster: nil)
        // A second write presenting the STALE revision refuses plainly.
        #expect(throws: VaultRefusal.revisionConflict) {
            _ = try mac.world.server.update(
                snapshot.vault, accountID: mac.account!,
                expectedRevision: snapshot.revision, proofMaster: master, successorMaster: nil)
        }
        #expect(mac.world.server.snapshot(mac.account!)?.revision == snapshot.revision + 1)
    }
}

@Suite("VX-307 U1 — VX-313's wire half: a tampered custody value never steers an act")
struct CustodyCannotSteerTests {
    /// The sealed-plan letter on the wire: the sync-keys custody item is
    /// LOCAL and tamperable, but it never decides an act. `material(for:)`
    /// uses a held value only when it IS the vault's current sync key under
    /// the vault's master; a planted bogus value is ignored and the act
    /// derives the true master from the typed secret — and the server's
    /// proof is the vault's, which a custody edit cannot forge. So a tampered
    /// custody value cannot make an act write under the wrong key or steer
    /// the posture.
    @Test func aPlantedBogusSyncKeysValueIsIgnoredAndTheActUsesTheTypedSecret() async throws {
        let mac = try EX(.castle, synced: true)
        let before = try #require(mac.world.server.snapshot(mac.account!))
        // Tamper: overwrite every held sync-keys item with a stranger's keys.
        let bogus = AccountKeys(
            master: SymmetricKey(size: .bits256).withUnsafeBytes { Data($0) },
            rowKeyID: "stranger-key-id",
            rowKey: SymmetricKey(size: .bits256).withUnsafeBytes { Data($0) })
        for fact in mac.world.syncItems.keys {
            mac.world.syncItems[fact] = bogus
        }
        mac.world.session.removeAll()
        // Use Standard runs: it reads the vault, and derives the master from
        // the typed secret (the bogus custody fails `material`'s guard), so
        // the one CAS write lands under the TRUE proof.
        let executor = mac.executor()
        var library = try mac.unlocked(executor)
        _ = try await executor.useStandard(&library, typed: mac.typed)
        let after = try #require(mac.world.server.snapshot(mac.account!))
        #expect(after.mode == .standard, "the act landed under the true master, not the planted one")
        #expect(after.revision == before.revision + 1)
        expectSettled(mac, library)
    }

    /// And a bogus custody value cannot forge the proof at the leaf: an
    /// update presenting the stranger's master refuses, whatever custody
    /// held.
    @Test func aStrangersMasterCannotWriteTheVault() async throws {
        let mac = try EX(.standard, synced: true)
        let snapshot = try #require(mac.world.server.snapshot(mac.account!))
        #expect(throws: VaultRefusal.keyProofRefused) {
            _ = try mac.world.server.update(
                VaultModel.leavingCastle(snapshot.vault, device: "Mac A"), accountID: mac.account!,
                expectedRevision: snapshot.revision, proofMaster: SymmetricKey(size: .bits256),
                successorMaster: nil)
        }
        #expect(mac.world.server.snapshot(mac.account!)?.revision == snapshot.revision, "nothing landed")
    }
}