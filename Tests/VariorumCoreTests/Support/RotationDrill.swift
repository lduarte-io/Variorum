import CryptoKit
import Foundation
@testable import VariorumCore

/// pre-13x batch 1b — THE RE-ENCRYPTION WALK, in test support only: what
/// batch 2's rotation driver productizes (the design's §4 step 3 — "every
/// row still under the old key — every row of this account BELOW the
/// rotation seq — is rewritten under C′ through `sync_reencrypt`"), reduced
/// to the minimum that proves the SERVER semantics batch 1b ships:
///  - pull the account's rows (no device id — a walk is not a round),
///  - keep those BELOW the rotation seq (the seq rule: they are under the
///    PREVIOUS key — `SyncPayloadCrypto.decryptFromWire(_:)` opens them by
///    exactly that rule, so a seam that ignored the seq would throw here),
///  - re-seal them under the CURRENT key with the version they were pulled
///    at (`syncVersion` = `expected_version`, the CAS),
///  - hand them to `reencrypt`.
/// Re-encrypted rows take a FRESH seq (above the rotation seq) and move to
/// the feed's end, where the walk sees them again and leaves them alone;
/// the walk ends at an empty window. The marker, the pull-to-head road,
/// the completion write and the previous key's custody are batch 2's.
enum RotationDrill {
    enum DrillError: Error { case noRotationInProgress }

    /// Every rotation in the drills: the NEW key world beside the OLD, with
    /// the server-assigned seq between them.
    struct RotatedWorld {
        let newMaster: SymmetricKey
        let newCorpusKey: SymmetricKey
        let newCorpusKeyID: String
        let rotationStartedSeq: Int64
        /// The follower's keys: the current world + the previous key under
        /// the seq rule.
        let keys: SyncEncryptionKeys
        var keyProof: String { keys.keyProof }
        /// The current world WITHOUT the previous key — what a device holds
        /// once the rotation is complete.
        var completedKeys: SyncEncryptionKeys {
            SyncEncryptionKeys(
                corpusKey: newCorpusKey, corpusKeyID: newCorpusKeyID, keyProof: keys.keyProof)
        }
    }

    /// Begin a rotation on the fake's vault row (the `key_vault_update`
    /// twin, authorized by the OLD proof): a fresh master + corpus key, the
    /// new proof hash installed, the previous corpus key carried as its id
    /// + a bare wrap (the wrap's content is opaque to the server; any base64
    /// serves the fake).
    static func beginRotation(
        on server: FakeSyncServer, as userID: String = FakeSyncServer.defaultUserID,
        previous: SyncEncryptionKeys, oldProof: String, expectedRevision: Int = 1
    ) async throws -> RotatedWorld {
        let newMaster = SymmetricKey(size: .bits256)
        let newCorpus = SymmetricKey(size: .bits256)
        let newID = "test-corpus-key-ROTATED-" + UUID().uuidString.lowercased().prefix(8)
        let receipt = try await server.keyVaultUpdate(
            as: userID, expectedRevision: expectedRevision, keyProof: oldProof,
            newCorpusKeyID: newID, newKeyProofHash: KeyProof.hash(master: newMaster),
            previousCorpusKeyID: previous.corpusKeyID,
            previousCorpusKey: Data(repeating: 0x11, count: 40).base64EncodedString())
        guard let seq = receipt.rotationStartedSeq else { throw DrillError.noRotationInProgress }
        let keys = SyncEncryptionKeys(
            corpusKey: newCorpus, corpusKeyID: newID,
            keyProof: KeyProof.wireToken(master: newMaster),
            rotation: RotationInProgress(
                previousCorpusKey: previous.corpusKey,
                previousCorpusKeyID: previous.corpusKeyID,
                startedSeq: seq))
        return RotatedWorld(
            newMaster: newMaster, newCorpusKey: newCorpus, newCorpusKeyID: newID,
            rotationStartedSeq: seq, keys: keys)
    }

    /// The walk's first half: pull the account's rows and re-seal every
    /// one BELOW the rotation seq under the current key (the seq rule opens
    /// them under the previous key); the rows carry the version they were
    /// pulled at (`syncVersion` = `expected_version`, the CAS). Returned
    /// UNSENT so a scenario can interleave another device's edit between
    /// the pull and the send — the skip arm's exact window.
    static func pullBelow(
        on server: FakeSyncServer, as userID: String = FakeSyncServer.defaultUserID,
        keys: SyncEncryptionKeys, batchSize: Int = 50
    ) async throws -> [SyncRow] {
        guard let rotation = keys.rotation else { throw DrillError.noRotationInProgress }
        let crypto = SyncPayloadCrypto(keys: keys)
        var resealed: [SyncRow] = []
        var cursor: Int64 = 0
        while true {
            let window = try await server.pull(
                since: cursor, limit: batchSize, activeKeyID: keys.corpusKeyID,
                keyProof: keys.keyProof, deviceID: nil, as: userID)
            guard !window.isEmpty else { break }
            for pulled in window where pulled.serverSeq < rotation.startedSeq {
                // The seq rule opens it under the PREVIOUS key; re-sealed
                // under the CURRENT key with the pulled version kept.
                let opened = try crypto.decryptFromWire(pulled)
                resealed.append(try crypto.encryptForWire(opened.row))
            }
            cursor = window.last!.serverSeq
        }
        return resealed
    }

    /// The walk's second half: hand the re-sealed rows to `reencrypt`.
    static func send(
        _ rows: [SyncRow], on server: FakeSyncServer,
        as userID: String = FakeSyncServer.defaultUserID, keys: SyncEncryptionKeys
    ) async throws -> [SyncReencryptOutcome] {
        guard !rows.isEmpty else { return [] }
        return try await server.reencrypt(
            rows, activeKeyID: keys.corpusKeyID, keyProof: keys.keyProof, as: userID)
    }

    /// The whole walk — pull, re-seal, send — returning every outcome the
    /// server answered, in order.
    static func reencryptCorpus(
        on server: FakeSyncServer, as userID: String = FakeSyncServer.defaultUserID,
        keys: SyncEncryptionKeys, batchSize: Int = 50
    ) async throws -> [SyncReencryptOutcome] {
        try await send(
            try await pullBelow(on: server, as: userID, keys: keys, batchSize: batchSize),
            on: server, as: userID, keys: keys)
    }

    /// Completion (the design's §4 step 3, last sentence): the previous key
    /// AND the seq cleared together — one `key_vault_update` under the
    /// CURRENT proof with no previous key in the payload.
    static func complete(
        on server: FakeSyncServer, as userID: String = FakeSyncServer.defaultUserID,
        world: RotatedWorld, expectedRevision: Int
    ) async throws {
        _ = try await server.keyVaultUpdate(
            as: userID, expectedRevision: expectedRevision, keyProof: world.keyProof,
            newCorpusKeyID: world.newCorpusKeyID, newKeyProofHash: nil,
            previousCorpusKeyID: nil, previousCorpusKey: nil)
    }
}
