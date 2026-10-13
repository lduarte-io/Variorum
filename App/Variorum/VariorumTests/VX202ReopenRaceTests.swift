//
//  VX202ReopenRaceTests.swift
//  VariorumTests
//
//  VX-202 — the re-key reopen's silent re-save (RUN VX-201, unit U1; the
//  trace: notes/plans/fixes/vx-191-encryption-audit.md §O.3; the brief and
//  the record: notes/plans/fixes/vx-201-castle-prelaunch-fixes.md §C and
//  "U1 RECORD (VX-202)").
//
//  THE DEFECT: entering Castle re-keys the library through
//  `AppBootstrap.rekeyLibrary`, whose reopen reaches `.ready` BEFORE the
//  custody move. There the 13p R1-M3 arm saw the unlocked L′ under a gate
//  not yet demanded and scheduled a utility save of L′ into the SILENT
//  item, unordered against the move's delete — a late save left the
//  current key readable with no Touch ID, and on a local-only library the
//  next launch's route wrapped it under the iCloud key: a silent, total
//  reversion to Standard.
//
//  THE PINS (each red on the pre-fix code by the behavioral revert the
//  record names):
//   (a) the race through the PRODUCTION reopen, the save HELD past the
//       custody move (the worst interleaving, made deterministic);
//   (b) the ordinary post-crash launch: a pending marker + the lobby's
//       typed key at ready ⇒ no re-save;
//   (c) the at-ready sweep (a lingering silent item beside the gated one on
//       a Castle library is removed) + its bounds and its inertness on the
//       custody shapes a 13x adoption deliberately lands;
//   (d) the route's Apple landing refuses while a switch is pending for the
//       store id, and the runner keeps that flag true exactly while custody
//       is still to move.
//
//  Everything runs through scripted Keychain backings — no Keychain, no
//  LocalAuthentication, no prompts.
//

import CryptoKit
import Dependencies
import Foundation
import GRDB
import Testing

@testable import Variorum
import VariorumCore

/// The held R1-M3 save: while holding, `saveAuto` records the key and
/// writes NOTHING (answering success, as the Keychain write would);
/// `release` lands every held save AFTER whatever the pin chose to run
/// first — §O.3's losing interleaving, made deterministic.
final class HeldSilentSaves: @unchecked Sendable {
    private let lock = NSLock()
    private var holding = false
    private var held: [StoreKey] = []

    func hold() {
        lock.lock(); defer { lock.unlock() }
        holding = true
    }

    /// true = held (the caller writes nothing).
    func capture(_ key: StoreKey) -> Bool {
        lock.lock(); defer { lock.unlock() }
        guard holding else { return false }
        held.append(key)
        return true
    }

    var heldCount: Int {
        lock.lock(); defer { lock.unlock() }
        return held.count
    }

    func release(into backing: InMemoryStoreKeyGuardBacking) {
        lock.lock()
        holding = false
        let keys = held
        held = []
        lock.unlock()
        for key in keys { backing.auto = key }
    }
}

@MainActor
@Suite("VX-202 — the re-key reopen never re-lands the silent item mid-switch", .serialized)
struct VX202ReopenRaceTests {
    private let passphrase = "orchard-lantern-202"

    private func withDeps<T>(_ body: @MainActor () async throws -> T) async rethrows -> T {
        try await withDependencies {
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.uuid = .incrementing
        } operation: { @MainActor in
            try await body()
        }
    }

    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-vx202-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    /// A real keyed store at `storeURL` with one note, its pool closed.
    private func seedStore(at storeURL: URL, key: StoreKey, marker: RotationMarker? = nil) async throws {
        try FileManager.default.createDirectory(
            at: storeURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        let store = try AppDatabase.onDisk(url: storeURL, key: key)
        try await store.write { db in
            try db.execute(
                sql: "INSERT INTO container (id, kind, title, created_at, updated_at) VALUES (?, 'post', ?, ?, ?)",
                arguments: ["vx202-note", "written before the switch", "2026-10-13T00:00:00Z", "2026-10-13T00:00:00Z"])
            if let marker { try RotationMarker.write(marker, db) }
        }
        store.asRebindable().binding.lock()
    }

    /// The in-memory guard with `saveAuto` routed through the hold.
    private func heldGuard(_ backing: InMemoryStoreKeyGuardBacking, _ holds: HeldSilentSaves) -> StoreKeyGuard {
        var seam = StoreKeyGuard.inMemory(backing: backing)
        let inner = seam.saveAuto
        seam.saveAuto = { key in holds.capture(key) ? true : inner(key) }
        return seam
    }

    /// A gate over the key files ON DISK beside the store (the runner and
    /// `landCustody` read and write them there), scripted custody, A, and
    /// the per-store switch-pending flag.
    private func diskGate(
        guardSeam: StoreKeyGuard, appleBacking: InMemoryAppleKeyBacking,
        pending: ScriptedSwitchPendingBox, enrolled: Bool = false
    ) -> StoreLaunchGate {
        let dials = ScriptedDialsBox(ProtectionDials())
        return StoreLaunchGate(
            dials: { _, id in dials.dials(for: id) },
            saveDials: { new, _, id in dials.save(new, for: id) },
            legacyMode: { _, _ in nil },
            retireLegacyDials: { _, _ in },
            guardFor: { _ in guardSeam },
            appleKeyFor: { _ in AppleKeyLeaves.inMemory(backing: appleBacking) },
            loadEnvelope: { try StoreKeyEnvelope.loadCurrent(besideStore: $0) },
            saveEnvelope: { try $0.write(at: $0.preferredURL(besideStore: $1)) },
            setAsideEnvelope: { _ in },
            stamp: { _, _ in nil },
            setStamp: { _, _, _ in },
            syncCustodyPresent: { _, _ in enrolled },
            switchPending: { _, id in pending.isPending(id) },
            setSwitchPending: { value, _, id in pending.set(value, for: id) })
    }

    /// The PRODUCTION open road (`openStore` resolving the key from custody
    /// against the real file — so a wrong key fails TYPED, as VX-80's pins
    /// read it) under whichever of `candidate` / `fallback` opens the file:
    /// the unlocked key reaches production's opener as custody, and a test
    /// opener stands in for it (the MobileWindowReplayTests shape).
    private func opener(
        storeURL: URL, candidate: LockIsolated<StoreKey>, fallback: StoreKey
    ) -> @Sendable () -> Result<AppDatabase, AppDatabase.StoreOpenError> {
        {
            let key = StoreEncryptionMigration.opens(storeURL, key: candidate.value) ? candidate.value : fallback
            return Result {
                try AppDatabase.openStore(at: storeURL, custody: .inMemory(initial: key))
            }.mapError { error in
                error as? AppDatabase.StoreOpenError
                    ?? AppDatabase.StoreOpenError(storePath: storeURL.path, reason: String(describing: error))
            }
        }
    }

    // MARK: - The race world (a local-only STANDARD library on the production reopen)

    @MainActor
    final class RaceWorld {
        let dir: URL
        let storeURL: URL
        let storeID: String
        let oldKey: StoreKey
        let backing: InMemoryStoreKeyGuardBacking
        let appleBacking: InMemoryAppleKeyBacking
        let holds: HeldSilentSaves
        let pending: ScriptedSwitchPendingBox
        let gate: StoreLaunchGate
        let currentKey: LockIsolated<StoreKey>
        let bootstrap: AppBootstrap
        var runner: PostureSwitchRunner!
        /// What the rekey leaf saw at the reopen's return (mid-switch).
        var flagAtReopen: Bool?
        var switchFlagAfterReopen: Bool?

        init(dir: URL, storeURL: URL, storeID: String, oldKey: StoreKey,
             backing: InMemoryStoreKeyGuardBacking, appleBacking: InMemoryAppleKeyBacking,
             holds: HeldSilentSaves, pending: ScriptedSwitchPendingBox, gate: StoreLaunchGate,
             currentKey: LockIsolated<StoreKey>, bootstrap: AppBootstrap) {
            self.dir = dir; self.storeURL = storeURL; self.storeID = storeID; self.oldKey = oldKey
            self.backing = backing; self.appleBacking = appleBacking; self.holds = holds
            self.pending = pending; self.gate = gate; self.currentKey = currentKey
            self.bootstrap = bootstrap
        }
    }

    /// Her library before the switch: Standard, local-only — the key file
    /// carries a passphrase copy and the Apple copy, the raw key sits in the
    /// silent item, A is readable, Touch ID exists. The runner rides the
    /// PRODUCTION re-key road (`bootstrap.rekeyLibrary` → `beginOpening` →
    /// `.ready`) and the PRODUCTION custody move (`protection.moveCustody`).
    private func makeRaceWorld() async throws -> RaceWorld {
        let dir = try temporaryDirectory()
        let storeURL = dir.appendingPathComponent("library/variorum.sqlite")
        let oldKey = StoreKey.mint()
        try await seedStore(at: storeURL, key: oldKey)
        let apple = AppleKey.mint()
        let storeID = "vx202-\(UUID().uuidString.prefix(8).lowercased())"
        var envelope = StoreKeyEnvelope(storeID: storeID)
        try envelope.setPassphraseWrap(key: oldKey, passphrase: passphrase, kdf: fastKDF())
        try envelope.setAppleWrappedCopy(key: oldKey, under: apple.symmetricKey, appleKeyID: apple.id)
        try envelope.write(at: envelope.preferredURL(besideStore: storeURL))

        let backing = InMemoryStoreKeyGuardBacking(auto: oldKey, biometryAvailable: true, biometricSucceeds: true)
        let appleBacking = InMemoryAppleKeyBacking(key: apple)
        let holds = HeldSilentSaves()
        let pending = ScriptedSwitchPendingBox()
        let gate = diskGate(guardSeam: heldGuard(backing, holds), appleBacking: appleBacking, pending: pending)
        let currentKey = LockIsolated(oldKey)
        let syncLeaves = RecordingSyncLeaves()
        let bootstrap = AppBootstrap(
            testOpener: opener(storeURL: storeURL, candidate: currentKey, fallback: oldKey),
            gate: gate, testPresence: .encryptedOrUnknown, testStoreURL: storeURL,
            syncCustodyLeaves: { _ in syncLeaves.leaves }, syncCustodySession: SyncCustodySession())
        await bootstrap.awaitOpen()
        guard case .ready(let session) = bootstrap.state else {
            throw CancellationError()
        }
        let world = RaceWorld(
            dir: dir, storeURL: storeURL, storeID: storeID, oldKey: oldKey, backing: backing,
            appleBacking: appleBacking, holds: holds, pending: pending, gate: gate,
            currentKey: currentKey, bootstrap: bootstrap)
        let protection = bootstrap.protection
        let keyStore = DeviceKeyStore.inMemory()
        let suiteName = "io.lduarte.variorum.tests.vx202.\(UUID().uuidString)"
        world.runner = PostureSwitchRunner(leaves: PostureSwitchRunner.Leaves(
            scope: AppDatabase.StoreVariant.dev.rawValue,
            storeURL: storeURL,
            database: session.database,
            gate: gate,
            keyStore: keyStore,
            keyProvider: DeviceKeySyncProvider(store: keyStore),
            vault: nil,
            transport: nil,
            signedIn: { false },
            appleKeys: AppleKeyLeaves.inMemory(backing: appleBacking),
            libraryKeyInHand: { protection.keyInHand() },
            posture: { protection.posture },
            alwaysAsk: { protection.dials.alwaysAsk },
            biometryAvailable: { protection.biometryAvailable },
            moveCustody: { target in await protection.moveCustody(to: target) },
            rekeyLibrary: { [weak world] old, new, work in
                currentKey.setValue(new)
                try await bootstrap.rekeyLibrary(from: old, to: new, work: work)
                world?.flagAtReopen = pending.isPending(storeID)
                world?.switchFlagAfterReopen = bootstrap.switchInProgress
            },
            pauseSync: {},
            resumeSync: {},
            takeSnapshot: { .notKept },
            preSwitchSnapshots: { _ in [] },
            deleteSnapshotPairs: { _ in 0 },
            defaults: { UserDefaults(suiteName: suiteName)! },
            reconcile: { await protection.reconcile() },
            now: { Date() },
            log: { _ in },
            endSwitch: { bootstrap.endSwitch() }))
        return world
    }

    /// Settle long enough for a scheduled save to have been CALLED (a held
    /// one is captured within milliseconds on the pre-fix road); returns
    /// early once one is.
    private func settle(_ holds: HeldSilentSaves) async {
        for _ in 0..<300 where holds.heldCount == 0 {
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(1))
        }
    }

    // MARK: - (a) THE RACE, through the production reopen

    /// **THE NAMED RED-ON-OLD PIN (§O.3).** Standard → Castle on a local-only
    /// library through `AppBootstrap.rekeyLibrary`'s real reopen, with every
    /// silent save HELD until after the custody move and then landed — the
    /// interleaving §O.3 says nothing orders against. The end: the silent
    /// item ABSENT, and the next launch ASKS (the Castle lobby) instead of
    /// wrapping L′ under the iCloud key and opening silently.
    /// RED ON OLD (the record's revert R-a1 — the arm's pre-fix detached
    /// save): the reopen scheduled `saveAuto(L′)`; released after the move's
    /// delete it leaves L′ silent, and the relaunch's route lands the Apple
    /// copy and opens without asking. Revert R-a2 (gate i alone removed):
    /// the reopen SCHEDULES the re-landing (`relanding` non-nil).
    @Test func theReopensSilentSaveHeldPastTheCustodyMoveLeavesNoSilentItem() async throws {
        try await withDeps {
            let world = try await makeRaceWorld()
            defer { try? FileManager.default.removeItem(at: world.dir) }
            let protection = world.bootstrap.protection
            #expect(protection.posture == .standard, "her library starts Standard")
            #expect(world.bootstrap.relanding == nil, "a silent open schedules no re-landing")

            world.holds.hold()
            let words = try RecoveryPhrase.generate()
            let outcome = try await world.runner.enterCastle(passphrase: passphrase, recoveryWords: words)
            #expect(outcome.entersCastle)

            // Gate i: the switch's own reopen scheduled nothing.
            #expect(world.switchFlagAfterReopen == true, "the reopen ran with the switch flag set")
            #expect(world.bootstrap.relanding == nil,
                    "the switch's reopen schedules NO silent re-landing (gate i)")
            #expect(!world.bootstrap.switchInProgress, "the runner cleared the flag once custody landed")

            // Custody landed: L′ behind Touch ID, the silent item released.
            let newKey = try #require(world.backing.gated)
            #expect(newKey != world.oldKey && StoreKeyEnvelope.fingerprint(of: newKey) == outcome.newKeyFingerprint)
            #expect(world.backing.auto == nil, "the custody move released the silent item")

            // THE RACE, forced: any save the reopen scheduled lands NOW,
            // after the move's delete.
            await settle(world.holds)
            world.holds.release(into: world.backing)
            #expect(world.backing.auto == nil,
                    "no silent copy of the library key survives the switch — the race's outcome")

            // The next launch: the Castle lobby — never the silent Apple landing.
            let relaunch = AppBootstrap(
                testOpener: opener(storeURL: world.storeURL, candidate: world.currentKey, fallback: world.oldKey),
                gate: world.gate, testPresence: .encryptedOrUnknown, testStoreURL: world.storeURL,
                syncCustodyLeaves: { _ in RecordingSyncLeaves().leaves }, syncCustodySession: SyncCustodySession())
            await relaunch.awaitOpen()
            guard case .locked(let lobby) = relaunch.state else {
                Issue.record("the relaunch must ask — got \(relaunch.state)")
                return
            }
            #expect(lobby.demand == .biometric)
            let keyFile = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: world.storeURL))
            #expect(keyFile.belongs(to: newKey) && keyFile.apple == nil,
                    "no Apple copy landed on the re-keyed library's key file")
        }
    }

    // MARK: - (d) the store-id flag's life on the same road

    /// The runner keeps the store-id flag true exactly while custody is still
    /// to move: set before the first marker, true at the reopen, cleared once
    /// custody landed; a refused custody move leaves it (and the bootstrap's
    /// in-flight flag) SET — the switch is pending — and the resume clears
    /// both. RED ON OLD (revert R-d2 — the runner writes no flag): the flag
    /// is never set.
    @Test func theSwitchPendingFlagSpansExactlyTheCustodyPendingStepsAndTheResumeClearsIt() async throws {
        try await withDeps {
            let world = try await makeRaceWorld()
            defer { try? FileManager.default.removeItem(at: world.dir) }
            world.backing.savesSucceed = false  // the gated write refuses: custody cannot move
            let words = try RecoveryPhrase.generate()
            do {
                _ = try await world.runner.enterCastle(passphrase: passphrase, recoveryWords: words)
                Issue.record("expected the custody refusal")
            } catch PostureSwitchError.custodyRefused {
                // expected
            }
            #expect(world.flagAtReopen == true, "pending at the reopen")
            #expect(world.pending.isPending(world.storeID), "a refused custody move leaves the switch pending")
            #expect(world.bootstrap.switchInProgress, "and the reopen's flag stays set")
            #expect(world.pending.writes.first?.pending == true, "set before anything else")
            #expect(world.backing.auto == world.oldKey && world.backing.gated == nil, "custody unmoved")

            world.backing.savesSucceed = true
            _ = try await world.runner.resume(passphrase: nil)
            #expect(!world.pending.isPending(world.storeID), "the resume cleared the flag")
            #expect(!world.bootstrap.switchInProgress, "and the reopen's flag")
            #expect(world.backing.auto == nil && world.backing.gated != nil, "custody landed behind Touch ID")
            let marker = await world.runner.pendingMarker()
            #expect(marker == nil, "the switch finished")
        }
    }

    /// **(d) THE ROUTE'S LANDING ARM.** A Standard-waiting key file (no
    /// Apple copy, a passphrase copy), the raw key silent, A readable: the
    /// route lands the Apple copy — unless a switch is pending for the store
    /// id, when it lands NOTHING. RED ON OLD (revert R-d1 — the pending
    /// check removed from `effectiveGate`): the copy lands.
    @Test func theRoutesAppleLandingRefusesWhileASwitchIsPending() async throws {
        let key = StoreKey.mint()
        let apple = AppleKey.mint()
        var envelope = StoreKeyEnvelope(storeID: "vx202-route")
        try envelope.setPassphraseWrap(key: key, passphrase: passphrase, kdf: fastKDF())
        let box = ScriptedEnvelopeBox(envelope)
        let pending = ScriptedSwitchPendingBox(pending: ["vx202-route"])
        let gate = StoreLaunchGate.scripted(
            dials: ScriptedDialsBox(ProtectionDials()),
            backing: InMemoryStoreKeyGuardBacking(auto: key),
            envelope: box,
            appleKey: InMemoryAppleKeyBacking(key: apple),
            switchPending: pending)
        let storeURL = FileManager.default.temporaryDirectory.appendingPathComponent("vx202-route.sqlite")

        _ = gate.effectiveGate(scope: "Variorum-dev", storeID: "vx202-route", storeURL: storeURL)
        #expect(box.value?.apple == nil, "a pending switch: the route lands no Apple copy")

        pending.set(false, for: "vx202-route")
        _ = gate.effectiveGate(scope: "Variorum-dev", storeID: "vx202-route", storeURL: storeURL)
        #expect(box.value?.apple != nil, "no switch pending: the Standard-waiting landing stands (corner 45)")
    }

    // MARK: - (b) the ordinary post-crash launch

    /// The VX-80 stranded state WITH its marker: the store re-keyed to B,
    /// the newest key file Castle-shaped for B, the silent item still A (the
    /// crash fell before custody), `RotationMarker` at `.custody`. The
    /// silent open fails, the recovery lobby's typed word yields B — and the
    /// ready must NOT re-land B silently (a half-switched library would then
    /// open with no gate; the resume owns custody). RED ON OLD (revert R-b —
    /// the marker read removed from the arm): B lands in the silent item.
    @Test func aPendingSwitchMarkerKeepsTheRecoveryUnlockFromReLandingTheSilentItem() async throws {
        try await withDeps {
            let outcome = try await recoveryUnlock(withMarker: true)
            #expect(outcome.scheduled, "the ordinary road still SCHEDULES the re-landing — the marker refuses it")
            #expect(outcome.backing.auto == outcome.staleKey,
                    "a pending switch: the silent item is left as it was (the resume moves custody)")
        }
    }

    /// The control: the same stranded state with NO marker re-lands the
    /// proven key (VX-80's designed heal, unchanged), now awaited rather
    /// than polled.
    @Test func withoutAMarkerTheRecoveryUnlockStillReLandsTheProvenKey() async throws {
        try await withDeps {
            let outcome = try await recoveryUnlock(withMarker: false)
            #expect(outcome.scheduled)
            #expect(outcome.backing.auto == outcome.unlockedKey, "the proven key replaces the stale silent item")
        }
    }

    private struct RecoveryOutcome {
        var backing: InMemoryStoreKeyGuardBacking
        var staleKey: StoreKey
        var unlockedKey: StoreKey
        var scheduled: Bool
    }

    private func recoveryUnlock(withMarker: Bool) async throws -> RecoveryOutcome {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("variorum.sqlite")
        let keyB = StoreKey.mint()
        let keyA = StoreKey.mint()
        let marker = RotationMarker(
            step: .custody, entersCastle: true,
            oldKeyFingerprint: StoreKeyEnvelope.fingerprint(of: keyA),
            newKeyFingerprint: StoreKeyEnvelope.fingerprint(of: keyB),
            startedAt: "2026-10-13T00:00:00.000Z")
        try await seedStore(at: storeURL, key: keyB, marker: withMarker ? marker : nil)
        var sidecar = StoreKeyEnvelope(storeID: "vx202-crash")
        try sidecar.setPassphraseWrap(key: keyB, passphrase: passphrase, kdf: fastKDF())
        let backing = InMemoryStoreKeyGuardBacking(auto: keyA)
        let gate = StoreLaunchGate.scripted(
            dials: ProtectionDials(), backing: backing, envelope: sidecar,
            appleKey: InMemoryAppleKeyBacking(key: AppleKey.mint()))
        let custodyKey = LockIsolated(keyA)
        let bootstrap = AppBootstrap(
            testOpener: opener(storeURL: storeURL, candidate: custodyKey, fallback: keyA),
            gate: gate, testStoreURL: storeURL, syncCustodySession: SyncCustodySession())
        await bootstrap.awaitOpen()
        guard case .failed(_, let recovery) = bootstrap.state, let lobby = recovery else {
            Issue.record("expected the recovery lobby over the stranded store, got \(bootstrap.state)")
            throw CancellationError()
        }
        custodyKey.setValue(keyB)
        await lobby.unlock(passphrase: passphrase)
        await bootstrap.awaitOpen()
        guard case .ready = bootstrap.state else {
            Issue.record("expected .ready after the recovery unlock, got \(bootstrap.state)")
            throw CancellationError()
        }
        let scheduled = bootstrap.relanding != nil
        await bootstrap.relanding?.value
        return RecoveryOutcome(backing: backing, staleKey: keyA, unlockedKey: keyB, scheduled: scheduled)
    }

    // MARK: - (c) THE AT-READY SWEEP

    /// A world for the sweep: a real store under `key`, a scripted key file,
    /// scripted custody, opened silently through the bootstrap (the ready's
    /// adoption done), its reconcile driven by the pin. The route reads the
    /// custody SHAPE it is given (a lingering silent item ⇒ Standard), so
    /// every world here opens without a lobby — exactly the lingering
    /// item's harm; `appleBacking` empty keeps the route's landing out.
    private func sweepWorld(
        key: StoreKey, envelope: StoreKeyEnvelope, backing: InMemoryStoreKeyGuardBacking,
        appleBacking: InMemoryAppleKeyBacking = InMemoryAppleKeyBacking()
    ) async throws -> (bootstrap: AppBootstrap, box: ScriptedEnvelopeBox, dir: URL) {
        let dir = try temporaryDirectory()
        let storeURL = dir.appendingPathComponent("variorum.sqlite")
        try await seedStore(at: storeURL, key: key)
        let box = ScriptedEnvelopeBox(envelope)
        let gate = StoreLaunchGate.scripted(
            dials: ScriptedDialsBox(ProtectionDials()), backing: backing, envelope: box,
            appleKey: appleBacking)
        let bootstrap = AppBootstrap(
            testOpener: opener(storeURL: storeURL, candidate: LockIsolated(key), fallback: key),
            gate: gate, testStoreURL: storeURL, syncCustodySession: SyncCustodySession())
        await bootstrap.awaitOpen()
        guard case .ready = bootstrap.state else {
            Issue.record("expected .ready (the silent open), got \(bootstrap.state)")
            throw CancellationError()
        }
        return (bootstrap, box, dir)
    }

    /// **(c) RED ON OLD — a LOCAL-ONLY Castle library carrying a lingering
    /// silent copy** (the race's outcome where the route's landing could not
    /// run — A unreadable at the route) reads as Standard at the ready; the
    /// sweep removes the silent item BEFORE the posture is derived, the key
    /// stays in hand, and the Apple arm lands nothing once A is readable.
    /// RED ON OLD (revert R-c — the sweep's call removed from the reconcile):
    /// the silent item stays, the posture reads Standard and the Apple arm
    /// wraps L′ under A.
    @Test func theSweepRemovesASilentItemBesideTheGatedOneOnALocalCastleLibrary() async throws {
        try await withDeps {
            let key = StoreKey.mint()
            var envelope = StoreKeyEnvelope(storeID: "vx202-sweep-local")
            try envelope.setPassphraseWrap(key: key, passphrase: passphrase, kdf: fastKDF())
            let backing = InMemoryStoreKeyGuardBacking(auto: key, gated: key, biometryAvailable: true)
            let appleBacking = InMemoryAppleKeyBacking()  // A not readable at the route
            let world = try await sweepWorld(key: key, envelope: envelope, backing: backing, appleBacking: appleBacking)
            defer { try? FileManager.default.removeItem(at: world.dir) }
            let protection = world.bootstrap.protection
            #expect(protection.posture == .standard, "the lingering item reads as Standard before the sweep — the trap")

            appleBacking.key = AppleKey.mint()  // …A arrives
            await protection.reconcile()

            #expect(backing.auto == nil, "the lingering silent item is removed")
            #expect(backing.gated == key, "the gated item stands")
            #expect(protection.keyInHand() == key, "the key stays in hand as the resident")
            #expect(protection.posture == .castle && protection.effectiveGate == .biometric)
            #expect(world.box.value?.apple == nil, "the Apple arm lands nothing on a Castle library")
            #expect(world.bootstrap.canLock, "Lock Now acts again")
        }
    }

    /// **(c) RED ON OLD — an ENROLLED library whose vault says Castle** opened
    /// silently through a lingering item (§O.3 step 5's enrolled bullet): the
    /// vault's word makes the reading determined Castle; the sweep removes
    /// the silent item and keeps the key in hand. RED ON OLD (revert R-c):
    /// the silent item stays — the library keeps opening with no gate.
    @Test func theSweepRemovesTheLingeringSilentItemOnAnEnrolledCastleAccount() async throws {
        try await withDeps {
            let key = StoreKey.mint()
            var envelope = StoreKeyEnvelope(storeID: "vx202-sweep-enrolled")
            try envelope.setPassphraseWrap(key: key, passphrase: passphrase, kdf: fastKDF())
            let backing = InMemoryStoreKeyGuardBacking(auto: key, gated: key, biometryAvailable: true)
            let world = try await sweepWorld(key: key, envelope: envelope, backing: backing)
            defer { try? FileManager.default.removeItem(at: world.dir) }
            let protection = world.bootstrap.protection
            protection.isSignedIn = { true }
            protection.readVaultPosture = { VaultPostureReading(hasAppleHeldCopy: false, corpusKeyID: "corpus-1") }

            await protection.reconcile()

            #expect(backing.auto == nil, "the lingering silent item is removed")
            #expect(backing.gated == key)
            #expect(protection.keyInHand() == key)
            #expect(protection.posture == .castle && !protection.postureIndeterminate)
        }
    }

    /// (c) SAFETY — never the only road in: the same enrolled Castle state,
    /// but the live key file carries NO passphrase or twelve-words copy of
    /// the key (a hand-damaged file): the silent item opened this ready and
    /// may be the only road — it stays.
    @Test func theSweepLeavesASilentItemThatMayBeTheOnlyRoadIn() async throws {
        try await withDeps {
            let key = StoreKey.mint()
            var envelope = StoreKeyEnvelope(storeID: "vx202-sweep-damaged")
            try envelope.setMasterWrappedCopy(key: key, under: SymmetricKey(size: .bits256))
            #expect(envelope.passphrase == nil && envelope.recovery == nil)
            let backing = InMemoryStoreKeyGuardBacking(auto: key, gated: key, biometryAvailable: true)
            let world = try await sweepWorld(key: key, envelope: envelope, backing: backing)
            defer { try? FileManager.default.removeItem(at: world.dir) }
            let protection = world.bootstrap.protection
            protection.isSignedIn = { true }
            protection.readVaultPosture = { VaultPostureReading(hasAppleHeldCopy: false, corpusKeyID: "corpus-1") }

            await protection.reconcile()

            #expect(protection.posture == .castle, "the vault's word: a demanded gate")
            #expect(backing.auto == key, "no typed copy of the key is on file — the silent item stays")
        }
    }

    /// (c) INERT on corner 45's Standard-waiting library (no gated item: the
    /// silent item IS the custody shape) — nothing is touched.
    @Test func theSweepLeavesAStandardWaitingLibraryAlone() async throws {
        try await withDeps {
            let key = StoreKey.mint()
            var envelope = StoreKeyEnvelope(storeID: "vx202-sweep-waiting")
            try envelope.setPassphraseWrap(key: key, passphrase: passphrase, kdf: fastKDF())
            let backing = InMemoryStoreKeyGuardBacking(auto: key, biometryAvailable: true)
            let world = try await sweepWorld(key: key, envelope: envelope, backing: backing)
            defer { try? FileManager.default.removeItem(at: world.dir) }
            await world.bootstrap.protection.reconcile()
            #expect(backing.auto == key, "Standard-waiting keeps its silent item (corner 45)")
        }
    }

    // MARK: - (c) inert in the 13x adoption's deliberate landCustody window

    /// The three custody shapes a 13x adoption deliberately lands, each
    /// followed by the adopted library's ready (the key in hand adopted, the
    /// reconcile run): the sweep touches none of them. Verified, not assumed
    /// (§A refinement 2) — and the inertness comes from the custody SHAPE and
    /// the key file, not the dials (since 2a the dials carry only Castle's
    /// gate style; the plaintext road's `ProtectionDials()` reset never makes
    /// a gate undemanded).
    @Test func theSweepIsInertOnEveryShapeTheAdoptionLandsCustodyIn() async throws {
        try await withDeps {
            // (i) a Castle-era pair adopted over a STANDARD library (the
            // VX-209 shape): landCustody reads Standard-waiting → silent K_in,
            // the gated item released.
            do {
                let outcome = try await adopt(outgoing: .standard, incoming: .castleEraPair)
                #expect(outcome.backing.auto == outcome.landedKey && outcome.backing.gated == nil,
                        "landCustody's silent shape stands after the ready")
            }
            // (ii) a Castle-era pair adopted over a CASTLE library:
            // landCustody → the gated item, the silent one released.
            do {
                let outcome = try await adopt(outgoing: .castle, incoming: .castleEraPair)
                #expect(outcome.backing.gated == outcome.landedKey && outcome.backing.auto == nil)
            }
            // (iii) a PLAINTEXT export adopted over a CASTLE library: a fresh
            // key silent, a wrap-less key file, Auto dials — and the outgoing
            // library's gated item still standing beside it (the plaintext
            // road deletes none). Silent + gated coexist, yet the wrap-less
            // file is Standard (decision 5) and the silent item is the only
            // road in: the sweep stays out.
            do {
                let outcome = try await adopt(outgoing: .castle, incoming: .plaintextExport)
                #expect(outcome.backing.auto == outcome.landedKey, "the fresh key's silent item stands")
                #expect(outcome.backing.gated != nil, "(the outgoing library's gated item — not the sweep's to touch)")
            }
        }
    }

    private enum Outgoing { case standard, castle }
    private enum Incoming { case castleEraPair, plaintextExport }

    private struct AdoptionOutcome {
        var backing: InMemoryStoreKeyGuardBacking
        var landedKey: StoreKey
    }

    private func adopt(outgoing: Outgoing, incoming: Incoming) async throws -> AdoptionOutcome {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("library/variorum.sqlite")
        let outgoingKey = StoreKey.mint()
        let backing = InMemoryStoreKeyGuardBacking(
            auto: outgoing == .standard ? outgoingKey : nil,
            gated: outgoing == .castle ? outgoingKey : nil,
            biometryAvailable: true, biometricSucceeds: true)
        let appleBacking = InMemoryAppleKeyBacking()  // keep VX-209's Apple landing out of this pin's view
        let gate = diskGate(
            guardSeam: StoreKeyGuard.inMemory(backing: backing), appleBacking: appleBacking,
            pending: ScriptedSwitchPendingBox())
        let scope = AppDatabase.StoreVariant.dev.rawValue
        let landedKey = StoreKey.mint()
        try await seedStore(at: storeURL, key: landedKey)
        switch incoming {
        case .castleEraPair:
            // The adopted pair's key file, landed beside the store; then the
            // collision rule's write exactly as the adoption runs it.
            var keyFile = StoreKeyEnvelope(storeID: "vx202-adopted")
            try keyFile.setPassphraseWrap(key: landedKey, passphrase: passphrase, kdf: fastKDF())
            try keyFile.write(at: keyFile.preferredURL(besideStore: storeURL))
            LibraryOpenModel.landCustody(openingKey: landedKey, scope: scope, storeURL: storeURL, gate: gate)
        case .plaintextExport:
            // The plaintext road's three writes (`LibraryOpenModel`'s work).
            let storeID = try StoreIdentity.establish(besideStore: storeURL, key: landedKey)
            gate.saveDials(ProtectionDials(), scope, storeID)
            _ = gate.guardFor(scope).saveAuto(landedKey)
        }
        // The adopted library's ready: the opener's key in hand, the reconcile.
        let controller = ProtectionController(configuration: .init(
            scope: scope, storeURL: storeURL, gate: gate, isRealVariant: false,
            syncCustodyLeaves: { _ in RecordingSyncLeaves().leaves },
            syncCustodySession: SyncCustodySession()))
        controller.adoptResident(landedKey)
        await controller.reconcile()
        return AdoptionOutcome(backing: backing, landedKey: landedKey)
    }
}
