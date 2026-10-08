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

    // MARK: F3 R3-2 — the gates read the MARKER, with no view alive

    /// 13x F3 (ladder R3-2): an adoption run from the Settings scene with
    /// no main window lands the marker on disk while the projection —
    /// refreshed only by a main window's `.task` — still says "not held".
    /// The composition root's ONE wiring (`wireGates`, what
    /// `VariorumApp` calls) points BOTH gates at the marker: consulted
    /// with no view alive over a standing marker, each answers HELD, and
    /// the round roads run nothing; Resume's clear opens both. RED ON
    /// OLD (behavioural revert: `markerGate` reads the projection, the
    /// old `{ hold.isHeld }`): both gates answer "not held" and a round
    /// runs.
    @Test func theHoldGatesReadTheMarkerWithNoViewAlive() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("home/variorum.sqlite")
        try FileManager.default.createDirectory(
            at: storeURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        let bootstrap = AppBootstrap(
            testOpener: { .failure(AppDatabase.StoreOpenError(storePath: "/x", reason: "unused")) },
            gate: .scripted(dials: ProtectionDials(), backing: InMemoryStoreKeyGuardBacking()),
            testStoreURL: storeURL)
        await bootstrap.awaitOpen()
        let db = try AppDatabase.inMemory()
        let session = SyncSession(database: db, allowsSync: true)
        let hold = RestoreHoldModel(storeURL: storeURL)
        #expect(!hold.isHeld, "premise: no marker yet")
        hold.wireGates(sync: session, protection: bootstrap.protection)

        // The Settings-scene adoption: the marker lands; nothing refreshes
        // the projection (no main window, no `.task`).
        try LibraryRestoreHold.set(besideStore: storeURL, asOf: nil, now: Date())
        #expect(!hold.isHeld, "premise: the projection is stale")
        #expect(session.roundsHeld?() == true, "the round gate reads the marker")
        #expect(bootstrap.protection.restoreHoldStands?() == true,
                "the rotation ceremonies' gate reads the marker")

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
            #expect(bootstrap.protection.restoreHoldStands?() == false)
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

    // MARK: F3 R3-1 (constraint 3) — the post-unlock refusal is TRUE per class

    /// 13x F3 (ladder R3-1, constraint 3 — the CLASS-SEPARATION GUARD):
    /// a key file of ANOTHER key beside the store (two folders mixed) —
    /// its passphrase opens its key, that key does not open the store —
    /// settles to the wrong-key sentence, the one place it is true. GREEN
    /// ON BOTH SIDES by design: the old single `.unreadable` arm said it
    /// too; this pin guards that the split never moves a genuine mismatch
    /// off its sentence. (Its twin below is the red-on-old one.)
    @Test func aGenuineKeyMismatchStillSettlesToTheWrongKeySentence() async throws {
        try await withDependencies {
            $0.date = .constant(Date(timeIntervalSince1970: 1_790_000_000))
            $0.uuid = .incrementing
        } operation: { @MainActor in
            let dir = try temporaryDirectory()
            defer { try? FileManager.default.removeItem(at: dir) }
            let pair = try makePair(in: dir, passphrase: "the travelling word")
            try FileManager.default.removeItem(at: pair.keyFile)
            var other = StoreKeyEnvelope()
            try other.setPassphraseWrap(
                key: StoreKey.mint(), passphrase: "the other word", kdf: fastKDF())
            try other.write(at: other.preferredURL(besideStore: pair.store))
            let model = try await unlockedModel(
                picked: pair.store, passphrase: "the other word", in: dir)
            #expect(model.phase == .refused(LibraryOpenCopy.wrongKeyRefusal, detail: nil),
                    "\(model.phase)")
        }
    }

    /// 13x F3 (ladder R3-1, constraint 3): a TORN copy (page 1 intact,
    /// the rest cut — an interrupted copy, a full disk) beside its RIGHT
    /// key file settles to the unreadable sentence with its reason —
    /// never "that key file doesn't open this library — it belongs to
    /// another copy", which is false on both facts. RED ON OLD: the
    /// single `.unreadable` arm wore the wrong-key sentence (measured at
    /// F3: the torn consult reads SQLITE_CORRUPT, "database disk image is
    /// malformed").
    @Test func aTornCopyUnderItsRightKeySettlesToTheUnreadableSentence() async throws {
        try await withDependencies {
            $0.date = .constant(Date(timeIntervalSince1970: 1_790_000_000))
            $0.uuid = .incrementing
        } operation: { @MainActor in
            let dir = try temporaryDirectory()
            defer { try? FileManager.default.removeItem(at: dir) }
            let pair = try makePair(in: dir, passphrase: "the travelling word")
            let whole = try Data(contentsOf: pair.store)
            #expect(whole.count > 4096 * 2, "premise: the library is longer than the cut")
            try whole.prefix(4096 * 2).write(to: pair.store)
            let model = try await unlockedModel(
                picked: pair.store, passphrase: "the travelling word", in: dir)
            guard case .refused(let lead, let detail) = model.phase else {
                Issue.record("a torn copy refuses, got \(model.phase)")
                return
            }
            #expect(lead == LibraryOpenCopy.unreadableRefusal, "got \(lead)")
            #expect(lead != LibraryOpenCopy.wrongKeyRefusal)
            #expect(detail?.contains("malformed") == true, "the reason rides the detail: \(detail ?? "nil")")
        }
    }

    /// The flow up to the post-unlock settle: classify → the typed road
    /// (no custody, no Apple copy — the passphrase is the one road) →
    /// `settle`'s verdict, waited on until the phase leaves `.unlock`.
    @MainActor
    private func unlockedModel(
        picked store: URL, passphrase: String, in dir: URL
    ) async throws -> LibraryOpenModel {
        let bootstrap = AppBootstrap(
            testOpener: { .success(try! AppDatabase.inMemory()) },
            gate: .scripted(dials: ProtectionDials(), backing: InMemoryStoreKeyGuardBacking()),
            testStoreURL: dir.appendingPathComponent("home/variorum.sqlite"))
        await bootstrap.awaitOpen()
        let model = LibraryOpenModel(bootstrap: bootstrap)
        model.begin(picked: store)
        try await waitUntil { if case .unlock = model.phase { return true }; return false }
        await model.unlock(passphrase: passphrase)
        try await waitUntil {
            switch model.phase {
            case .refused, .confirm: return true
            default: return false
            }
        }
        return model
    }

    // MARK: F1 R1-M3 — the failure words are true per arm

    /// 13x F1 (ladder R1-M3): the failure lead's FACTS are per arm — a
    /// pre-move refusal never claims the dated copy or the safety copy
    /// (neither exists on those arms), the mid-move arm names its two
    /// REAL nets, and the landing arm keeps the old lead (whose facts
    /// are true exactly there — by the landing, both nets exist; a
    /// post-work reopen failure is past the landing by construction).
    /// RED ON OLD: one lead for every arm — a user whose source was
    /// missing was pointed at recovery artifacts that were never made.
    @Test func theAdoptionFailureWordsAreTruePerArm() {
        let preMove: [LibraryAdoption.AdoptionError] = [
            .sourceMissing("x"), .sourceKeyFileMissing("x"), .sourceKeyFileUnreadable("x"),
            .libraryLooksOpen("x"), .safetyCopyFailed("x"), .holdWriteFailed("x"),
        ]
        for arm in preMove {
            let (lead, detail) = LibraryOpenModel.failureWording(for: arm)
            #expect(lead == LibraryOpenCopy.adoptionRefusedNothingMoved, "\(arm)")
            #expect(!lead.contains("dated copy") && !lead.contains("safety copy"),
                    "no false recovery facts on a pre-move arm: \(arm)")
            #expect(detail == "x")
        }
        let (mid, _) = LibraryOpenModel.failureWording(
            for: LibraryAdoption.AdoptionError.moveAsideFailed("m"))
        #expect(mid == LibraryOpenCopy.adoptionFailedMidMove)
        let (landing, _) = LibraryOpenModel.failureWording(
            for: LibraryAdoption.AdoptionError.landingFailed("l"))
        #expect(landing == LibraryOpenCopy.adoptionFailedLead)
        struct Odd: Error {}
        let (unknown, _) = LibraryOpenModel.failureWording(for: Odd())
        #expect(unknown == LibraryOpenCopy.adoptionFailedLead)
    }

    /// 13x round 4 (MINOR): on a FRESH slot no library stood — so no arm
    /// may name a current library, a dated copy or a safety copy.
    @Test func onAFreshSlotEveryFailureArmSaysOnlyWhatIsTrue() {
        struct Odd: Error {}
        let arms: [any Error] = [
            LibraryAdoption.AdoptionError.sourceMissing("x"),
            LibraryAdoption.AdoptionError.holdWriteFailed("x"),
            LibraryAdoption.AdoptionError.landingFailed("x"),
            Odd(),
        ]
        for arm in arms {
            let (lead, _) = LibraryOpenModel.failureWording(for: arm, nothingStood: true)
            #expect(lead == LibraryOpenCopy.adoptionFailedFreshSlot, "\(arm)")
            #expect(!lead.contains("dated copy") && !lead.contains("safety copy")
                    && !lead.contains("current library"),
                    "no recovery facts that do not exist: \(arm)")
        }
    }

    /// 13x round 4 (MINOR), the CALL SITE: the real flow on an empty slot
    /// whose folder refuses writes fails at its first write — and must
    /// render the fresh-slot sentence. RED ON OLD (and on a revert that
    /// passes `nothingStood: false`): "your current library stands as it
    /// was", naming a library that never existed.
    @Test func aFailedAdoptionOntoAFreshSlotNamesNoRecoveryThatDoesNotExist() async throws {
        try await withDependencies {
            $0.date = .constant(Date(timeIntervalSince1970: 1_790_000_000))
            $0.uuid = .incrementing
        } operation: { @MainActor in
            let dir = try temporaryDirectory()
            let slot = dir.appendingPathComponent("home", isDirectory: true)
            defer {
                try? FileManager.default.setAttributes(
                    [.posixPermissions: 0o755], ofItemAtPath: slot.path)
                try? FileManager.default.removeItem(at: dir)
            }
            let pair = try makePair(in: dir, passphrase: "the travelling word")
            try FileManager.default.createDirectory(at: slot, withIntermediateDirectories: true)
            let storeURL = slot.appendingPathComponent("variorum.sqlite")
            let bootstrap = AppBootstrap(
                testOpener: { .success(try! AppDatabase.inMemory()) },
                gate: .scripted(dials: ProtectionDials(), backing: InMemoryStoreKeyGuardBacking()),
                testStoreURL: storeURL)
            await bootstrap.awaitOpen()
            let model = LibraryOpenModel(bootstrap: bootstrap)
            model.begin(picked: pair.store)
            try await waitUntil { if case .unlock = model.phase { return true }; return false }
            await model.unlock(passphrase: "the travelling word")
            try await waitUntil { if case .confirm = model.phase { return true }; return false }
            #expect(model.willStepAside == false)  // the condition: nothing stands here

            try FileManager.default.setAttributes(
                [.posixPermissions: 0o555], ofItemAtPath: slot.path)
            await model.confirmAdoption()
            guard case .refused(let lead, _) = model.phase else {
                Issue.record("an adoption into an unwritable fresh slot must refuse: \(model.phase)")
                return
            }
            #expect(lead == LibraryOpenCopy.adoptionFailedFreshSlot,
                    "the fresh-slot failure names no library that never existed: \(lead)")
        }
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

    /// 13x F1 (ladder R1-MAJOR): deliverable 1's FACE — the one flow
    /// behind File ▸ Send Library to Another Mac… and Data Safety's twin.
    /// The producing arm lands `.done`, reveals the folder ONCE (the
    /// injected Finder seam; `revealAgain` is the done face's door), and
    /// the folder is QC's pair — it classifies as `.folderHoldingPair`,
    /// so the adoption door opens it with no new shape. The refusal arm:
    /// a library with NO key file beside it words corner 33's refusal
    /// (nothing made, nothing revealed). The old tree had NO door at all
    /// (the reviewer's zero-caller grep is the red); these pins guard the
    /// door now built.
    @Test func theHandOffDoorProducesThePairRevealsItAndWordsItsRefusal() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        // The open keyed library + its live key file (the producer's input).
        let store = dir.appendingPathComponent("home/variorum.sqlite")
        let key = StoreKey.mint()
        let database = try AppDatabase.openStore(at: store, custody: .inMemory(initial: key))
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: "the day's word", kdf: fastKDF())
        try envelope.write(at: envelope.preferredURL(besideStore: store))
        let destination = dir.appendingPathComponent("Chosen", isDirectory: true)
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)

        let revealed = LockIsolated<[URL]>([])
        let model = LibraryHandOffModel(reveal: { folder in
            revealed.withValue { $0.append(folder) }
        })
        await model.begin(database: database, storeURL: store, into: destination)
        guard case .done(let folder) = model.phase else {
            Issue.record("expected .done, got \(model.phase)")
            return
        }
        #expect(folder.lastPathComponent.hasPrefix(LibraryHandOff.folderPrefix))
        #expect(revealed.value == [folder], "revealed exactly once, at completion")
        // QC's pair: the folder classifies with no new shape — the
        // adoption door opens what this door produced.
        guard case .folderHoldingPair = LibraryClassifier.classify(at: folder) else {
            Issue.record("the produced folder did not classify as the pair")
            return
        }
        model.revealAgain()
        #expect(revealed.value.count == 2, "the done face's Show in Finder door")
        _ = database.asRebindable().binding.lock()

        // The refusal arm: no key file beside the library — corner 33's
        // refusal, worded; nothing lands in the destination.
        let bareStore = dir.appendingPathComponent("bare/variorum.sqlite")
        let bareKey = StoreKey.mint()
        let bareDatabase = try AppDatabase.openStore(
            at: bareStore, custody: .inMemory(initial: bareKey))
        let before = try FileManager.default.contentsOfDirectory(atPath: destination.path)
        let refusedReveals = LockIsolated<[URL]>([])
        let refused = LibraryHandOffModel(reveal: { folder in
            refusedReveals.withValue { $0.append(folder) }
        })
        await refused.begin(database: bareDatabase, storeURL: bareStore, into: destination)
        #expect(refused.phase == .refused(LibraryOpenCopy.handOffNoKeyFileRefusal, detail: nil))
        #expect(refusedReveals.value.isEmpty, "a refusal reveals nothing")
        let after = try FileManager.default.contentsOfDirectory(atPath: destination.path)
        #expect(after == before, "the refusal made nothing — not even an empty folder")
        _ = bareDatabase.asRebindable().binding.lock()
    }

    // MARK: F1 R1-M5 — no spurious Touch ID on a provably foreign pair

    /// 13x F1 (ladder R1-M5): picking an encrypted pair on a gated
    /// (Castle) Mac compares FINGERPRINTS promptless first — the pair's
    /// and the LIVE key file's are both on disk, and the gated item can
    /// only ever serve a SAME-key copy. A provably foreign pair skips
    /// the biometric ask entirely and falls straight to the typed
    /// roads; a same-key pair still takes exactly the one ask (the
    /// second look's gated arm, unchanged where it can help). RED ON
    /// OLD: `gatedItemExists` fired `unlockGated` before the envelope
    /// could say the key never fit — a spurious prompt that then
    /// "failed" into the typed roads on the exact older-key-restore
    /// road this phase ships.
    @Test func aProvablyForeignPairSkipsTheGatedAskAndASameKeyPairStillGetsIt() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let pair = try makePair(in: dir, passphrase: "the travelling word")
        let storeURL = dir.appendingPathComponent("home/variorum.sqlite")
        try FileManager.default.createDirectory(
            at: storeURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        // The LIVE library's key file on disk — a DIFFERENT key's.
        let liveKey = StoreKey.mint()
        var liveEnvelope = StoreKeyEnvelope()
        try liveEnvelope.setPassphraseWrap(
            key: liveKey, passphrase: "the live word", kdf: fastKDF())
        try liveEnvelope.write(at: liveEnvelope.preferredURL(besideStore: storeURL))

        // A gated (Castle) custody whose unlocks are COUNTED.
        let backing = InMemoryStoreKeyGuardBacking(
            gated: liveKey, biometryAvailable: true, biometricSucceeds: true)
        let prompts = LockIsolated(0)
        var gate = StoreLaunchGate.scripted(dials: ProtectionDials(), backing: backing)
        let baseGuardFor = gate.guardFor
        gate.guardFor = { scope in
            var seam = baseGuardFor(scope)
            let baseUnlock = seam.unlockGated
            seam.unlockGated = {
                prompts.withValue { $0 += 1 }
                return await baseUnlock()
            }
            return seam
        }
        let bootstrap = AppBootstrap(
            testOpener: { .failure(AppDatabase.StoreOpenError(storePath: "/x", reason: "unused")) },
            gate: gate, testStoreURL: storeURL)
        await bootstrap.awaitOpen()

        // FOREIGN fingerprints: the ask is SKIPPED — straight to the
        // typed roads, zero prompts.
        let model = LibraryOpenModel(bootstrap: bootstrap)
        model.begin(picked: pair.store)
        try await waitUntil { if case .unlock = model.phase { return true }; return false }
        #expect(prompts.value == 0, "a provably foreign pair fires no biometric prompt")

        // A SAME-key pair: the one ask still serves it into confirm.
        let sameStore = dir.appendingPathComponent("same/variorum.sqlite")
        let sameDatabase = try AppDatabase.openStore(
            at: sameStore, custody: .inMemory(initial: liveKey))
        _ = sameDatabase.asRebindable().binding.lock()
        var sameEnvelope = StoreKeyEnvelope()
        try sameEnvelope.setPassphraseWrap(
            key: liveKey, passphrase: "the live word", kdf: fastKDF())
        try sameEnvelope.write(at: sameEnvelope.preferredURL(besideStore: sameStore))
        let second = LibraryOpenModel(bootstrap: bootstrap)
        second.begin(picked: sameStore)
        try await waitUntil { if case .confirm = second.phase { return true }; return false }
        #expect(prompts.value == 1, "the same-key pair takes exactly the one gated ask")
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

    // MARK: F2 R2-1 — a press while the probe's won open is in flight
    // defers to the settled road (M4's residual closed)

    /// 13x F2 (ladder R2-1): the waiting lobby's probe completing BEFORE
    /// the Adopt press leaves the state at `.opening` for the pool
    /// open's whole duration — there the F1 suspension is a no-op (no
    /// lobby stands) and the old `.ready`-only re-check fell through to
    /// the detached work, which moved the live store aside WHILE the
    /// in-flight open held it (the wal gate reads a just-opened,
    /// not-yet-written pool as closed; the open then installed a
    /// session over the aside-moved inode — edits landing in Previous
    /// Libraries). The fix AWAITS the in-flight open and re-routes the
    /// settled state through the ready road, whose teardown closes the
    /// pool it opened. RED ON OLD: with the opener parked, the press
    /// lands `.done`, the slot's bytes become the source's and the hold
    /// stands — all while the open is still in flight.
    @Test func aPressWhileTheProbesWonOpenIsInFlightDefersToTheReadyRoad() async throws {
        try await withDependencies {
            $0.date = .constant(Date(timeIntervalSince1970: 1_790_000_000))
            $0.uuid = .incrementing
        } operation: { @MainActor in
            try await openingRaceBody()
        }
    }

    @MainActor
    private func openingRaceBody() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let pair = try makePair(in: dir, passphrase: "the travelling word")
        let sourceBytes = try Data(contentsOf: pair.store)

        // The LIVE library: a real closed encrypted store at the slot,
        // whose key file (the scripted box's) carries an Apple copy —
        // Standard's WAITING state routes while A has not arrived.
        let storeURL = dir.appendingPathComponent("home/variorum.sqlite")
        let liveKey = StoreKey.mint()
        let liveDatabase = try AppDatabase.openStore(
            at: storeURL, custody: .inMemory(initial: liveKey))
        _ = liveDatabase.asRebindable().binding.lock()
        let liveBytes = try Data(contentsOf: storeURL)
        let apple = AppleKey.mint()
        var liveEnvelope = StoreKeyEnvelope()
        try liveEnvelope.setAppleWrappedCopy(
            key: liveKey, under: apple.symmetricKey, appleKeyID: apple.id)
        let appleBacking = InMemoryAppleKeyBacking()  // A absent at launch

        // The opener PARKS its first call — the probe's open stays in
        // flight for exactly as long as the pin needs.
        let firstOpenGate = DispatchSemaphore(value: 0)
        let openCalls = LockIsolated(0)
        let bootstrap = AppBootstrap(
            testOpener: {
                let call = openCalls.withValue { (count: inout Int) -> Int in
                    count += 1
                    return count
                }
                if call == 1 { firstOpenGate.wait() }
                return .success(try! AppDatabase.inMemory())
            },
            gate: .scripted(
                dials: ProtectionDials(), backing: InMemoryStoreKeyGuardBacking(),
                envelope: liveEnvelope, appleKey: appleBacking),
            testStoreURL: storeURL)
        await bootstrap.awaitOpen()
        guard case .waitingForICloudKeychain(let lobby) = bootstrap.state else {
            Issue.record("expected the waiting state")
            return
        }

        // The sheet reaches confirm while the lobby still waits —
        // suspension lands only at the press (deliberate, recorded).
        let model = LibraryOpenModel(bootstrap: bootstrap)
        model.begin(picked: pair.store)
        try await waitUntil { if case .unlock = model.phase { return true }; return false }
        await model.unlock(passphrase: "the travelling word")
        try await waitUntil { if case .confirm = model.phase { return true }; return false }

        // A ARRIVES; the probe wins BEFORE the press — the state is
        // `.opening` with the open parked.
        appleBacking.key = apple
        #expect(await lobby.probeAppleRoad())
        guard case .opening = bootstrap.state else {
            Issue.record("the probe's win must leave the state opening")
            return
        }

        // THE PRESS, mid-open: nothing may move while the open is in
        // flight.
        let press = Task { await model.confirmAdoption() }
        try await Task.sleep(for: .seconds(2))
        #expect(model.phase == .adopting,
                "the press waits on the in-flight open — it never runs the work over it")
        #expect(try Data(contentsOf: storeURL) == liveBytes,
                "the live store is untouched while the open is in flight")
        #expect(!LibraryRestoreHold.isHeld(besideStore: storeURL),
                "no hold lands while the open is in flight")

        // The parked open completes; the press re-routes through the
        // READY road, whose teardown closes the pool it opened — the
        // adoption then lands whole.
        firstOpenGate.signal()
        _ = await press.value
        #expect(model.phase == .done)
        #expect(try Data(contentsOf: storeURL) == sourceBytes)
        #expect(LibraryRestoreHold.isHeld(besideStore: storeURL))
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
