//
//  Phase13pKeyedDrillTests.swift
//  VariorumTests
//
//  Phase 13p, cold-review ladder R1-M3(b) — THE SCRIPTED KEYED RESTORE
//  DRILL. The phase's VERIFICATION bullet (as amended at the R1-M3
//  adjudication) owes evidence for the SAME-MACHINE key legs, composed
//  end to end over REAL FILES rather than asserted piecewise:
//
//    ciphertext backup + the `variorum-keys.json` sidecar
//      → restore via the CUSTODY leg (the Keychain still holds the key);
//      → restore via the LOBBY-PASSPHRASE leg (demanded dials — the
//        envelope road the locked lobby runs);
//      → restore via the NEW `.failed`-surface ENVELOPE leg (custody
//        empty; the typed `keyUnavailable` refusal; the recovery words
//        unwrap through the same envelope road).
//
//  Every road uses the machinery the app ships — `AppDatabase.backup(to:)`
//  for the snapshot, `StoreBackup.copyKeyEnvelope` for the traveling
//  sidecar, `StoreLobby.envelopeRoad` for the unwraps, and
//  `AppDatabase.openStore` for every open. No new crypto road exists here,
//  which is the point. The full NEW-MACHINE adoption drill (the escrow
//  leg included) is 13x's named inheritance, deliberately not faked here.
//
//  No test touches the Keychain or biometrics: custody is the injected
//  in-memory seam, exactly as the standing rule requires.
//

import Dependencies
import Foundation
import GRDB
import Testing

@testable import Variorum
import VariorumCore

@MainActor
@Suite("13p — the keyed restore drill (ladder R1-M3)")
struct Phase13pKeyedDrillTests {
    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-13p-drill-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    /// The zero-plaintext scan (Batch 1's acceptance shape).
    private func fileContains(_ needle: String, at url: URL) throws -> Bool {
        let bytes = try Data(contentsOf: url)
        guard let probe = needle.data(using: .utf8) else { return false }
        return bytes.range(of: probe) != nil
    }

    /// The live-shaped gate over REAL sidecar files (the deferred-migration
    /// pin's pattern): dials scripted, envelope reads honest.
    private func fileGate(dials: ProtectionDials) -> StoreLaunchGate {
        StoreLaunchGate(
            dials: { _, _ in dials },
            saveDials: { _, _, _ in },
            legacyMode: { _, _ in nil },
            retireLegacyDials: { _, _ in },
            guardFor: { _ in StoreKeyGuard.inMemory(backing: InMemoryStoreKeyGuardBacking()) },
            appleKeyFor: { _ in AppleKeyLeaves.inMemory(backing: InMemoryAppleKeyBacking()) },
            loadEnvelope: { try StoreKeyEnvelope.loadCurrent(besideStore: $0) },
            saveEnvelope: { try $0.write(at: $0.preferredURL(besideStore: $1)) },
            setAsideEnvelope: { _ in },
            stamp: { _, _ in nil },
            setStamp: { _, _, _ in })
    }

    @Test func theKeyedRestoreDrillRunsEndToEndOnAllThreeSameMachineLegs() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let prose = "the variorum preserves its variant readings, encrypted"

        // ————— THE LIBRARY: born encrypted, wraps landed, backed up —————
        let storeURL = dir.appendingPathComponent("library/variorum.sqlite")
        let key = StoreKey.mint()
        let source = try AppDatabase.openStore(
            at: storeURL, custody: .inMemory(initial: key))
        try await source.write { db in
            try db.execute(
                sql: "INSERT OR REPLACE INTO setting (key, value) VALUES (?, ?)",
                arguments: ["drill_probe", prose])
        }
        // The wraps beside the store, exactly as the set-screen lands them
        // (one moment, two artifacts — knot 4).
        let words = try RecoveryPhrase.generate()
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: "sesame", kdf: fastKDF())
        try envelope.setRecoveryWrap(key: key, words: words)
        try envelope.write(at: envelope.preferredURL(besideStore: storeURL))
        let keyFileName = envelope.preferredURL(besideStore: storeURL).lastPathComponent

        // The backup folder: the app's own snapshot door + the traveling
        // sidecar (the Batch 2 finding's mechanism — the wraps ride).
        let backupFolder = dir.appendingPathComponent("backups", isDirectory: true)
        let backupURL = backupFolder.appendingPathComponent("variorum-backup-drill.sqlite")
        try source.backup(to: backupURL)
        StoreBackup.copyKeyEnvelope(
            StoreKeyEnvelope.locate(besideStore: storeURL), into: backupFolder)
        source.asRebindable().binding.lock()  // the "old machine" closes

        // The backup is CIPHERTEXT and carries no prose in the clear.
        #expect(StoreFilePresence.classify(at: backupURL) == .encryptedOrUnknown,
                "a keyed store's backup is ciphertext")
        #expect(try !fileContains(prose, at: backupURL),
                "zero plaintext in the backup file")
        #expect(FileManager.default.fileExists(
            atPath: backupFolder.appendingPathComponent(keyFileName).path),
            "the recovery legs travel WITH the copies, under the key's fingerprint name")

        // The restore (runbook §3's moves): the snapshot lands as the store,
        // the sidecar beside it. One fresh folder per leg — each leg is a
        // whole restore, not a warmed-over one.
        func restore(_ name: String) throws -> URL {
            let folder = dir.appendingPathComponent(name, isDirectory: true)
            try FileManager.default.createDirectory(
                at: folder, withIntermediateDirectories: true)
            let restored = folder.appendingPathComponent("variorum.sqlite")
            try FileManager.default.copyItem(at: backupURL, to: restored)
            try FileManager.default.copyItem(
                at: backupFolder.appendingPathComponent(keyFileName),
                to: restored.deletingLastPathComponent().appendingPathComponent(keyFileName))
            return restored
        }

        // ————— LEG 1: the CUSTODY road (the Keychain still holds it) —————
        let legOne = try restore("restore-custody")
        let openedOne = try AppDatabase.openStore(
            at: legOne, custody: .inMemory(initial: key))
        let readOne = try await openedOne.read { db in
            try String.fetchOne(db, sql: "SELECT value FROM setting WHERE key = 'drill_probe'")
        }
        #expect(readOne == prose, "custody leg: the restored library reads whole")
        openedOne.asRebindable().binding.lock()

        // ————— LEG 2: the LOBBY-PASSPHRASE road (demanded dials) —————
        // The route stops at the lobby; its envelope road unwraps the key
        // from the RESTORED sidecar; the same open that always runs opens
        // the store with it.
        let legTwo = try restore("restore-lobby")
        // pre-13x 2a: the restored key file (a passphrase wrap, no Apple
        // copy) DERIVES Castle; Always ask makes the gate the passphrase.
        let demandedGate = fileGate(dials: ProtectionDials(alwaysAsk: true))
        #expect(StoreLaunchRoute.resolve(
            gate: demandedGate.effectiveGate(scope: "drill", storeID: nil, storeURL: legTwo),
            presence: StoreFilePresence.classify(at: legTwo))
            == .lobby(demand: .passphrase))
        let lobbyRoad = StoreLobby.envelopeRoad(storeURL: legTwo, gate: demandedGate)
        guard case .success(let lobbyKey) = await lobbyRoad(.passphrase("sesame")) else {
            Issue.record("the lobby's passphrase road must unwrap the restored sidecar")
            return
        }
        #expect(lobbyKey == key)
        let openedTwo = try AppDatabase.openStore(
            at: legTwo, custody: .inMemory(initial: lobbyKey))
        let readTwo = try await openedTwo.read { db in
            try String.fetchOne(db, sql: "SELECT value FROM setting WHERE key = 'drill_probe'")
        }
        #expect(readTwo == prose, "lobby-passphrase leg: the restored library reads whole")
        openedTwo.asRebindable().binding.lock()

        // ————— LEG 3: the `.failed`-surface ENVELOPE road (R1-M3's new
        // door) — custody EMPTY, the typed refusal, then the recovery
        // WORDS unwrap through the same envelope machinery. —————
        let legThree = try restore("restore-failed-surface")
        do {
            _ = try AppDatabase.openStore(at: legThree, custody: .inMemory())
            Issue.record("an encrypted store with empty custody must refuse")
        } catch let error as AppDatabase.StoreOpenError {
            #expect(error.keyUnavailable,
                    "the refusal is TYPED — the failure surface keys its road on this")
        }
        let failedRoad = StoreLobby.envelopeRoad(
            storeURL: legThree, gate: fileGate(dials: ProtectionDials()))
        guard case .success(let recoveredKey) = await failedRoad(
            .recoveryText(words.joined(separator: " "))) else {
            Issue.record("the twelve words must unwrap the restored sidecar")
            return
        }
        #expect(recoveredKey == key)
        let openedThree = try AppDatabase.openStore(
            at: legThree, custody: .inMemory(initial: recoveredKey))
        let readThree = try await openedThree.read { db in
            try String.fetchOne(db, sql: "SELECT value FROM setting WHERE key = 'drill_probe'")
        }
        #expect(readThree == prose, "failed-surface envelope leg: the restored library reads whole")
        openedThree.asRebindable().binding.lock()
    }
}
