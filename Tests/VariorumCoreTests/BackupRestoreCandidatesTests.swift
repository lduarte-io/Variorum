import CryptoKit
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// Phase 13x U2 row 6 — the Restore surface's listing brain, pinned over
// REAL fixtures (real keyed stores, real key files — the U1 suites'
// shape): the strict name filter, the classifier-resolved serving key
// file, decision 11's credential facts, and the same-fingerprint second
// look.

@Suite("13x U2 — the restore surface's candidates")
struct BackupRestoreCandidatesTests {
    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-13x-restore-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    private func makeEncryptedLibrary(in dir: URL) throws -> (store: URL, key: StoreKey) {
        let store = dir.appendingPathComponent("library/variorum.sqlite")
        let key = StoreKey.mint()
        let database = try AppDatabase.openStore(at: store, custody: .inMemory(initial: key))
        _ = database.asRebindable().binding.lock()
        return (store, key)
    }

    @Test func theListingReadsPairsCredentialsAndTheSecondLook() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let fixture = try makeEncryptedLibrary(in: dir)
        let liveFingerprint = StoreKeyEnvelope.fingerprint(of: fixture.key)
        let fp8 = StoreKeyEnvelope.shortFingerprint(liveFingerprint)
        let folder = dir.appendingPathComponent("Backups", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        // 1. A row-42 pair under the LIVE key: passphrase + recovery +
        //    apple wraps — the second look lights.
        let paired = folder.appendingPathComponent(
            "variorum-backup-2027-01-02-030405-\(fp8).sqlite")
        try FileManager.default.copyItem(at: fixture.store, to: paired)
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: fixture.key, passphrase: "the day's word", kdf: fastKDF())
        let words = try RecoveryPhrase.generate()
        try envelope.setRecoveryWrap(key: fixture.key, words: words)
        try envelope.setAppleWrappedCopy(
            key: fixture.key, under: .init(size: .bits256), appleKeyID: "apple-id-1")
        try envelope.write(at: LibraryClassifier.pairedKeyFile(for: paired))

        // 2. An OLDER-KEY snapshot with its own pair: passphrase-only —
        //    the second look stays dark (a different key's copy).
        let oldKey = StoreKey.mint()
        let oldFP8 = StoreKeyEnvelope.shortFingerprint(StoreKeyEnvelope.fingerprint(of: oldKey))
        let older = folder.appendingPathComponent(
            "variorum-backup-2026-12-31-120000-\(oldFP8).sqlite")
        try FileManager.default.copyItem(at: fixture.store, to: older)
        var oldEnvelope = StoreKeyEnvelope()
        try oldEnvelope.setPassphraseWrap(key: oldKey, passphrase: "an older word", kdf: fastKDF())
        try oldEnvelope.write(at: LibraryClassifier.pairedKeyFile(for: older))

        // 3. A BARE snapshot (no key file anywhere serves its named key).
        let bare = folder.appendingPathComponent(
            "variorum-backup-2026-12-30-120000-00aa11bb.sqlite")
        try FileManager.default.copyItem(at: fixture.store, to: bare)

        // 4. Foreign names — never listed (the A1 rail's and a drill's).
        try FileManager.default.copyItem(at: fixture.store, to: folder.appendingPathComponent(
            "variorum-backup-a1-window-2026-12-29.sqlite"))
        try FileManager.default.copyItem(at: fixture.store, to: folder.appendingPathComponent(
            "variorum-backup-2026-12-28-999999-zz.sqlite"))

        let candidates = BackupRestoreCandidates.gather(
            in: folder, liveKeyFingerprint: liveFingerprint)
        #expect(candidates.count == 3)
        // Newest first.
        #expect(candidates.map(\.snapshot.lastPathComponent) == [
            paired.lastPathComponent, older.lastPathComponent, bare.lastPathComponent,
        ])

        let live = candidates[0]
        #expect(live.fingerprint8 == fp8)
        #expect(live.keyFile == LibraryClassifier.pairedKeyFile(for: paired))
        #expect(live.credentials == BackupRestoreCandidates.Credentials(
            passphrase: true, recovery: true, apple: true, master: false))
        #expect(live.opensWithLiveCustody)

        let olderKeyed = candidates[1]
        #expect(olderKeyed.credentials == BackupRestoreCandidates.Credentials(
            passphrase: true, recovery: false, apple: false, master: false))
        #expect(olderKeyed.opensWithLiveCustody == false)

        let bareRow = candidates[2]
        #expect(bareRow.keyFile == nil)
        #expect(bareRow.credentials == nil)
        #expect(bareRow.opensWithLiveCustody == false)
    }

    @Test func aLegacyStampOnlyNameIsServedByTheLegacyFolderFileAndSecondLooksByEnvelope() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let fixture = try makeEncryptedLibrary(in: dir)
        let liveFingerprint = StoreKeyEnvelope.fingerprint(of: fixture.key)
        let folder = dir.appendingPathComponent("Backups", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let legacy = folder.appendingPathComponent("variorum-backup-2026-11-01-080000.sqlite")
        try FileManager.default.copyItem(at: fixture.store, to: legacy)
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: fixture.key, passphrase: "legacy word", kdf: fastKDF())
        try envelope.write(at: StoreKeyEnvelope.legacyURL(besideStore: legacy))

        let candidates = BackupRestoreCandidates.gather(
            in: folder, liveKeyFingerprint: liveFingerprint)
        #expect(candidates.count == 1)
        #expect(candidates[0].fingerprint8 == nil)
        #expect(candidates[0].keyFile == StoreKeyEnvelope.legacyURL(besideStore: legacy))
        // The name carries no fp8, but the envelope's fingerprint says
        // this IS the live key — the second look still lights.
        #expect(candidates[0].opensWithLiveCustody)
    }

    @Test func noLiveKeyMeansTheSecondLookNeverLights() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let fixture = try makeEncryptedLibrary(in: dir)
        let fp8 = StoreKeyEnvelope.shortFingerprint(StoreKeyEnvelope.fingerprint(of: fixture.key))
        let folder = dir.appendingPathComponent("Backups", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let snapshot = folder.appendingPathComponent(
            "variorum-backup-2027-01-02-030405-\(fp8).sqlite")
        try FileManager.default.copyItem(at: fixture.store, to: snapshot)
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: fixture.key, passphrase: "a word", kdf: fastKDF())
        try envelope.write(at: LibraryClassifier.pairedKeyFile(for: snapshot))
        let candidates = BackupRestoreCandidates.gather(in: folder, liveKeyFingerprint: nil)
        #expect(candidates.count == 1)
        #expect(candidates[0].opensWithLiveCustody == false)
    }
}
