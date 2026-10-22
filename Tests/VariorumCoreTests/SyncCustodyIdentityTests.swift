import CryptoKit
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// pre-13x batch 1a (the postures design §3.3 / §12 "keys in custody, never
/// in the file"): the library file carries WRITING AND LOCAL BOOKKEEPING
/// ONLY — never a key and never an identity. The sync keys and the device
/// identity ride the custody items (the app layer's — today's
/// `E2EEKeychainStorage` until VX-329 U1, the protection road's custody leaves
/// since) and reach the engine through `SyncKeyProviding`;
/// the store's `sync_state` no longer holds `device_id`. Pinned by a BYTE
/// SCAN of an on-disk PLAINTEXT store (so the bytes are scannable) after
/// real rounds, of its `backup(to:)` copy, and again after
/// `resyncReinitialize` — no corpus key (raw, hex or base64) and no device
/// identity anywhere in the file. RED ON OLD: `sync_state.device_id` was
/// minted by the engine's first round and rode every backup.
@Suite("pre-13x 1a — nothing key-shaped, nothing identity-shaped in the file")
struct SyncCustodyIdentityTests {
    private func scratch() throws -> URL {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-1a-scan-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    /// Every shape a key or an identity could take inside a file.
    private func keyShapes(_ keys: SyncEncryptionKeys, deviceID: String) -> [Data] {
        let raw = keys.corpusKey.withUnsafeBytes { Data($0) }
        let hex = raw.map { String(format: "%02x", $0) }.joined()
        return [
            raw,
            Data(hex.utf8),
            Data(raw.base64EncodedString().utf8),
            Data(deviceID.utf8),
            Data("device_id".utf8),
        ]
    }

    @Test func aBackupAndTheStoreHoldNoKeyAndNoIdentityEvenAfterResync() async throws {
        let dir = try scratch()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("a.sqlite")
        let server = FakeSyncServer()
        // A PLAINTEXT on-disk store (key nil) so the scan sees real bytes.
        let a = try SyncClient(name: "A", prefix: "AA", transport: server, storeURL: storeURL)
        try a.with { ops, _ in
            let post = try ops.createPost(title: "scan me", profile: .generic)
            _ = try ops.newBlock(in: post.id, text: "Writing, never keys.")
        }
        try await a.push()
        try await a.pull()
        try await a.pull()
        #expect(try a.storedDeviceID() == nil, "no `device_id` row after rounds")
        #expect(await server.deviceCursor(a.deviceID) != nil, "…yet the server knows this device")

        let keys = try a.keyProvider.currentKeys()
        let shapes = keyShapes(keys, deviceID: a.deviceID)
        // The scan covers everything written: the main file AND its WAL
        // sidecar (a checkpoint would need the pool's readers to release —
        // the bytes on disk are what a copy would carry either way).
        func onDisk(_ url: URL) throws -> Data {
            var bytes = try Data(contentsOf: url)
            let wal = URL(fileURLWithPath: url.path + "-wal")
            if let tail = try? Data(contentsOf: wal) { bytes.append(tail) }
            return bytes
        }
        let storeBytes = try onDisk(storeURL)
        for shape in shapes {
            #expect(storeBytes.range(of: shape) == nil, "the store holds no key and no identity")
        }
        let backupURL = dir.appendingPathComponent("backup.sqlite")
        try a.db.backup(to: backupURL)
        let backupBytes = try Data(contentsOf: backupURL)
        for shape in shapes {
            #expect(backupBytes.range(of: shape) == nil, "a backup is writing, never a device")
        }

        // resyncReinitialize spares nothing key-shaped because nothing
        // key-shaped is in the file.
        try await a.withAsync { _ in try await a.engine().resyncReinitialize() }
        let afterBytes = try onDisk(storeURL)
        for shape in shapes {
            #expect(afterBytes.range(of: shape) == nil)
        }
        #expect(try a.storedDeviceID() == nil)
    }

    /// A restored copy on ANOTHER machine has no custody for its store id
    /// and therefore no identity — modelled by a client over the backup's
    /// bytes with its own provider: a fresh identity, never the source's.
    @Test func aCopyOfTheLibraryIsWritingNeverADevice() async throws {
        let dir = try scratch()
        defer { try? FileManager.default.removeItem(at: dir) }
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server, storeURL: dir.appendingPathComponent("a.sqlite"))
        try a.with { ops, _ in _ = try ops.createPost(title: "origin", profile: .generic) }
        try await a.push()
        try await a.pull()
        let backupURL = dir.appendingPathComponent("copy.sqlite")
        try a.db.backup(to: backupURL)
        let copy = try SyncClient(name: "COPY", prefix: "CC", transport: server, storeURL: backupURL)
        #expect(copy.deviceID != a.deviceID, "a fresh identity on the machine that holds the copy")
        #expect(try copy.storedDeviceID() == nil, "the copy carried none")
        // Locked (no custody) ⇒ no identity ⇒ the round refuses visibly.
        copy.keyProvider = LockedSyncKeyProvider()
        await #expect(throws: SyncError.encryptionKeysUnavailable) {
            try await copy.pull()
        }
    }
}
