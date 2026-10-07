//
//  LibraryPortabilityDoorTests.swift
//  VariorumTests
//
//  Phase 13x U2 — the doors' and the hold's Mac pins (rows 6/7/9/8's
//  Shared halves). WRITTEN AND COMPILED in the U2 pre-merge batch; their
//  RUN is PENDING-BEHIND-THE-STAGE (the 13o scheduler owns the stage —
//  the orchestrator files the slot). The red-on-old evidence for the two
//  guards here runs WITH that slot, by behavioural revert:
//    · the HOLD GATE — revert `SyncSession.triggerSync`/`flush`'s
//      `roundsHeld` guards and `heldRoundsNeverRun…` goes red (a held
//      session runs a round);
//    · the PICKER REFUSAL — revert `acceptPickedFolder`'s placement guard
//      and `thePickerRefusesTheLiveLibrarys…` goes red (the live folder
//      is remembered as a destination).
//

import CryptoKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore

@testable import Variorum

// MARK: - Fakes (this file's own; Phase8's are file-private there)

private actor CountingTransport: SyncTransport {
    private(set) var dataCalls = 0
    func fetchChallenges(_ count: Int) async throws -> [String] {
        (0..<max(count, 1)).map { _ in
            Data((0..<32).map { _ in UInt8.random(in: 0...255) }).base64EncodedString()
        }
    }
    func enrollKeyProof(legacyProof: String, macKey: String, activeKeyID: String) async throws {}
    func push(_ batch: [SyncRow], activeKeyID: String, keyProof: SyncKeyProof) async throws -> [SyncPushOutcome] {
        dataCalls += 1
        return batch.map { _ in .rejected(current: nil) }
    }
    func pull(since: Int64, limit: Int, activeKeyID: String, keyProof: SyncKeyProof, deviceID: String?) async throws -> [SyncPulledRow] {
        dataCalls += 1
        return []
    }
    func schemaVersion() async throws -> Int { SyncSchema.lockstepVersion }
}

private struct DoorTestKeyProvider: SyncKeyProviding {
    func currentKeys() throws -> SyncEncryptionKeys {
        SyncEncryptionKeys(
            corpusKey: SymmetricKey(data: Data((0..<32).map { UInt8($0 &+ 0x40) })),
            corpusKeyID: "door-test-corpus-key-00000000001",
            keyProof: KeyProofMaterial(
                master: SymmetricKey(data: Data((0..<32).map { UInt8($0 &+ 0x20) }))))
    }
    func deviceIdentity() throws -> String { "door-test-device" }
}

@MainActor
@Suite("13x U2 — the doors + the restore-hold (Mac pins)")
struct LibraryPortabilityDoorTests {
    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-13x-door-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    /// A closed encrypted library + passphrase-wrapped key file (the
    /// hand-off pair's shape).
    private func makePair(
        in dir: URL, passphrase: String
    ) throws -> (store: URL, key: StoreKey, keyFile: URL) {
        let store = dir.appendingPathComponent("arrival/variorum.sqlite")
        let key = StoreKey.mint()
        let database = try AppDatabase.openStore(at: store, custody: .inMemory(initial: key))
        _ = database.asRebindable().binding.lock()
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: passphrase, kdf: fastKDF())
        let keyFile = envelope.preferredURL(besideStore: store)
        try envelope.write(at: keyFile)
        return (store, key, keyFile)
    }

    // MARK: Row 7 — the hold gate (the round-trigger chokepoint)

    @Test func heldRoundsNeverRunAndTheResumedFlushRunsOne() async throws {
        let db = try AppDatabase.inMemory()
        let session = SyncSession(database: db, allowsSync: true)
        let transport = CountingTransport()
        let holdBox = LockIsolated(true)
        session.roundsHeld = { holdBox.value }
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_790_000_000))
        } operation: { @MainActor in
            await session.configure(transport: transport, keyProvider: DoorTestKeyProvider())
            // HELD: every road refuses to run a round — the one-press law.
            session.triggerSync()
            await session.flush()
            #expect(await transport.dataCalls == 0)
            // RESUMED: the same roads run one.
            holdBox.setValue(false)
            await session.flush()
            #expect(await transport.dataCalls > 0)
            session.stop()
        }
    }

    // MARK: Row 7 — the hold model (marker → banner state → Resume)

    @Test func theHoldModelProjectsTheMarkerAndResumeClearsItOnce() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let store = dir.appendingPathComponent("variorum.sqlite")
        try LibraryRestoreHold.set(
            besideStore: store, asOf: Date(timeIntervalSince1970: 1_780_000_000), now: Date())
        let model = RestoreHoldModel(storeURL: store)
        #expect(model.isHeld)
        #expect(model.asOfDay != nil)
        let resumed = LockIsolated(0)
        model.onResume = { resumed.withValue { $0 += 1 } }
        await model.resume()
        #expect(!model.isHeld)
        #expect(LibraryRestoreHold.isHeld(besideStore: store) == false)
        // A second press has nothing to do.
        await model.resume()
        #expect(resumed.value == 1)
    }

    // MARK: Row 9 — the picker refusal (copy §6's sentence, the ONE home)

    @Test func thePickerRefusesTheLiveLibrarysOwnFolderWithTheOneSentence() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let suite = "13x-door-picker-\(UUID().uuidString)"
        let defaults: @Sendable () -> UserDefaults = { UserDefaults(suiteName: suite)! }
        let db = try AppDatabase.inMemory()
        let backupsFolder = dir.appendingPathComponent("Library/Variorum/Backups", isDirectory: true)
        try FileManager.default.createDirectory(at: backupsFolder, withIntermediateDirectories: true)
        let backup = StoreBackup(database: db, directory: backupsFolder, defaults: defaults)
        let model = DataSafetyModel(backup: backup, defaults: defaults)

        // The live library's own folder: refused, the one sentence, no
        // destination remembered.
        await model.acceptPickedFolder(backupsFolder.deletingLastPathComponent())
        #expect(model.note == LibraryOpenCopy.pickedLiveLibraryFolderRefusal)
        #expect(model.note?.contains("corrupt a live database") == true)
        #expect(BackupDestination.isSet(in: defaults()) == false)

        // A folder of its own: accepted (the sibling proves the guard
        // refuses the library, not the act).
        let legal = dir.appendingPathComponent("Second Folder", isDirectory: true)
        try FileManager.default.createDirectory(at: legal, withIntermediateDirectories: true)
        await model.acceptPickedFolder(legal)
        #expect(BackupDestination.isSet(in: defaults()))
    }

    // MARK: Row 6 — the flow's refusal face (QC's remedy sentence)

    @Test func aBareOpaqueFileRefusesWithTheWholeFolderRemedy() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let bare = dir.appendingPathComponent("mystery.sqlite")
        try Data((0..<64).map { _ in UInt8.random(in: 0...255) }).write(to: bare)
        let bootstrap = AppBootstrap(
            testOpener: { .failure(AppDatabase.StoreOpenError(storePath: "/x", reason: "unused")) },
            gate: .scripted(
                dials: ProtectionDials(), backing: InMemoryStoreKeyGuardBacking()),
            testStoreURL: dir.appendingPathComponent("home/variorum.sqlite"))
        await bootstrap.awaitOpen()
        let model = LibraryOpenModel(bootstrap: bootstrap)
        model.begin(picked: bare)
        try await waitUntil { if case .refused = model.phase { return true }; return false }
        guard case .refused(let message, _) = model.phase else {
            Issue.record("expected the bare refusal")
            return
        }
        #expect(message == LibraryOpenCopy.bareStoreRefusal)
        #expect(message.contains("the key file travels with it"))
    }

    // MARK: Row 6 — the whole flow over a real pair (typed road → confirm
    // → adopt → hold + custody + reopen)

    @Test func theFlowAdoptsAPairWritesTheHoldAndLandsCustody() async throws {
        // The adoption's reopen lands `.ready`, whose AppSession reads
        // `\.date`/`\.uuid` — a test context must provide them (the
        // Phase8ServicesTests pattern; found by run 1 under the slot).
        try await withDependencies {
            $0.date = .constant(Date(timeIntervalSince1970: 1_790_000_000))
            $0.uuid = .incrementing
        } operation: { @MainActor in
            try await flowAdoptionBody()
        }
    }

    @MainActor
    private func flowAdoptionBody() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let pair = try makePair(in: dir, passphrase: "the travelling word")
        let sourceBytes = try Data(contentsOf: pair.store)
        let storeURL = dir.appendingPathComponent("home/variorum.sqlite")
        let backing = InMemoryStoreKeyGuardBacking()
        let bootstrap = AppBootstrap(
            testOpener: { .success(try! AppDatabase.inMemory()) },
            gate: .scripted(dials: ProtectionDials(), backing: backing),
            testStoreURL: storeURL)
        await bootstrap.awaitOpen()
        guard case .ready = bootstrap.state else {
            Issue.record("the scripted open should be ready")
            return
        }

        let model = LibraryOpenModel(bootstrap: bootstrap)
        model.begin(picked: pair.store)
        try await waitUntil { if case .unlock = model.phase { return true }; return false }
        #expect(model.passphraseOffered)

        // A wrong word refuses and the flow stays at unlock.
        await model.unlock(passphrase: "not the word")
        #expect(model.lastError != nil)
        if case .unlock = model.phase {} else {
            Issue.record("a refused word must keep the unlock phase")
        }

        await model.unlock(passphrase: "the travelling word")
        try await waitUntil { if case .confirm = model.phase { return true }; return false }
        #expect(model.willStepAside == false)  // nothing stands at the slot

        await model.confirmAdoption()
        #expect(model.phase == .done)
        // The landing: byte-identical store at the slot, the key file
        // canonical, the HOLD standing, custody carrying the opener (the
        // mint-fresh verdict, Standard shape — the scripted world's).
        #expect(try Data(contentsOf: storeURL) == sourceBytes)
        #expect(StoreKeyEnvelope.locate(besideStore: storeURL) != nil)
        #expect(LibraryRestoreHold.isHeld(besideStore: storeURL))
        #expect(backing.auto?.data == pair.key.data)
        guard case .ready = bootstrap.state else {
            Issue.record("the adoption must reopen into ready")
            return
        }
    }

    // MARK: - A tiny settle loop (foreground, bounded)

    private func waitUntil(
        _ condition: @MainActor () -> Bool, within seconds: Double = 10
    ) async throws {
        let deadline = Date().addingTimeInterval(seconds)
        while Date() < deadline {
            if condition() { return }
            try await Task.sleep(for: .milliseconds(20))
        }
        Issue.record("condition not met within \(seconds)s")
    }
}
