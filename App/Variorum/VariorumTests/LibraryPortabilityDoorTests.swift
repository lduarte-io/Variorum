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
//  VX-329 U1 — THE RELEASE SWITCH: 13x's adoption flow (`LibraryOpenModel`:
//  classify → unlock → settle → adopt, its refusal faces and failure words,
//  the second look's gated ask) was today's road and was deleted with it —
//  its pins with it. The hold (the round gate, the model, Resume), the
//  picker's refusal, the banner's words and the hand-off door's flow stand;
//  the hold's rotation-ceremony gate left with today's ceremonies, and the
//  hand-off door runs the road's own act (PROVISIONAL P-VX329-U1-1).
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

    // MARK: F3 R3-2 — the gates read the MARKER, with no view alive

    /// 13x F3 (ladder R3-2): an adoption run from the Settings scene with
    /// no main window lands the marker on disk while the projection —
    /// refreshed only by a main window's `.task` — still says "not held".
    /// The composition root's ONE wiring (`wireGates`, what
    /// `VariorumApp` calls) points the round gate at the marker: consulted
    /// with no view alive over a standing marker, it answers HELD, and
    /// the round roads run nothing; Resume's clear opens it. RED ON
    /// OLD (behavioural revert: `markerGate` reads the projection, the
    /// old `{ hold.isHeld }`): the gate answers "not held" and a round
    /// runs. (VX-329 U1: the rotation ceremonies' twin gate left with
    /// today's ceremonies.)
    @Test func theHoldGatesReadTheMarkerWithNoViewAlive() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("home/variorum.sqlite")
        try FileManager.default.createDirectory(
            at: storeURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        let db = try AppDatabase.inMemory()
        let session = SyncSession(database: db, allowsSync: true)
        let hold = RestoreHoldModel(storeURL: storeURL)
        #expect(!hold.isHeld, "premise: no marker yet")
        hold.wireGates(sync: session)

        // The Settings-scene adoption: the marker lands; nothing refreshes
        // the projection (no main window, no `.task`).
        try LibraryRestoreHold.set(besideStore: storeURL, asOf: nil, now: Date())
        #expect(!hold.isHeld, "premise: the projection is stale")
        #expect(session.roundsHeld?() == true, "the round gate reads the marker")

        let transport = CountingTransport()
        await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_790_000_000))
        } operation: { @MainActor in
            await session.configure(transport: transport, keyProvider: DoorTestKeyProvider())
            session.triggerSync()
            await session.flush()
            #expect(await transport.dataCalls == 0, "no round runs over a standing marker")
            // Resume's clear (the marker gone): both gates open, a round runs.
            LibraryRestoreHold.clear(besideStore: storeURL)
            #expect(session.roundsHeld?() == false)
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

    /// 13x round 4 (NIT): on a Mac with no account the banner must not
    /// promise to "catch up with your account".
    @Test func theHoldBannerNamesNoAccountWhereNoneExists() {
        let withAccount = LibraryOpenCopy.holdBanner(asOfDay: "October 7, 2026")
        #expect(withAccount.contains("your account"))
        let without = LibraryOpenCopy.holdBanner(asOfDay: "October 7, 2026", hasAccount: false)
        #expect(!without.contains("account"))
        #expect(without.contains("Resume"))
    }

    // MARK: F1 R1-MAJOR — the hand-off door's flow (the face over the U1
    // brains; the finding's evidence was the zero-caller grep)

    /// 13x F1 (ladder R1-MAJOR): deliverable 1's FACE — the one flow behind File ▸ Send Library to Another Mac… and
    /// Data Safety's twin. The producing arm lands `.done`, reveals the folder ONCE (the injected Finder seam;
    /// `revealAgain` is the done face's door), and the folder is the pair the road's open door reads (VX-329 U1: the
    /// road's own act, `PickedCopy`'s `.pair`). The refusal arms are worded per arm and reveal nothing. The old tree had
    /// NO door at all (the reviewer's zero-caller grep is the red); these pins guard the door now built.
    @Test func theHandOffDoorProducesThePairRevealsItAndWordsItsRefusal() async throws {
        try await withRoadDependencies {
            let dir = try temporaryDirectory()
            defer { try? FileManager.default.removeItem(at: dir) }
            let (bootstrap, _) = try await LockWorld.readyInStandard(PlantedRoad())
            let destination = dir.appendingPathComponent("Chosen", isDirectory: true)
            try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)

            let revealed = LockIsolated<[URL]>([])
            let model = LibraryHandOffModel(reveal: { folder in
                revealed.withValue { $0.append(folder) }
            })
            await model.begin(into: destination, produce: { await bootstrap.sendLibrary(into: $0) })
            guard case .done(let folder) = model.phase else {
                Issue.record("expected .done, got \(model.phase)")
                return
            }
            #expect(folder.lastPathComponent.hasPrefix(LibraryHandOff.folderPrefix))
            #expect(revealed.value == [folder], "revealed exactly once, at completion")
            guard case .pair = PickedCopy.classify(folder) else {
                Issue.record("the produced folder is the pair the open door reads")
                return
            }
            model.revealAgain()
            #expect(revealed.value.count == 2, "the done face's Show in Finder door")

            // The refusal arms: no key file of the library's key — corner 33's refusal; a failed write — its lead and
            // its facts. Nothing is revealed.
            let refusedReveals = LockIsolated<[URL]>([])
            let refused = LibraryHandOffModel(reveal: { folder in
                refusedReveals.withValue { $0.append(folder) }
            })
            await refused.begin(into: destination, produce: { _ in .failure(.noKeyFile) })
            #expect(refused.phase == .refused(LibraryOpenCopy.handOffNoKeyFileRefusal, detail: nil))
            await refused.begin(into: destination, produce: { _ in .failure(.failed("the disk is full")) })
            #expect(refused.phase == .refused(LibraryOpenCopy.handOffFailedLead, detail: "the disk is full"))
            #expect(refusedReveals.value.isEmpty, "a refusal reveals nothing")
        }
    }
}
