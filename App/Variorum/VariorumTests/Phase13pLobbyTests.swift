//
//  Phase13pLobbyTests.swift
//  VariorumTests
//
//  Phase 13p, Batch 2 (commit 3) — THE LOCKED LOBBY (R13p-5, THE DESIGN's
//  keyed-stack paragraph). The load-bearing pins:
//
//  · THE DEFERRED-MIGRATION PIN: a pre-13p PLAINTEXT store behind a
//    demanded mode routes to the lobby with its bytes UNTOUCHED — the
//    one-time migration (and everything else) runs only after unlock.
//    This is "nothing runs before unlock" made falsifiable.
//  · The bootstrap choreography: demanded ⇒ `.locked` with the opener
//    never called; unlock ⇒ open; `lock()` ⇒ teardown callback, the
//    lobby, a CLOSED pool (typed refusals); unlock again ⇒ ready over
//    the same ambient view.
//  · The lobby's roads: wrong secrets refuse in words; biometric failure
//    names the passphrase fallback (R13p-5 — never the device password);
//    Lock Now is a real act only under the demanded modes (R13p-14).
//
//  No test here touches the real Keychain or LocalAuthentication — every
//  road runs through the scripted gate (`StoreLaunchGate.scripted`).
//

import Dependencies
import Foundation
import GRDB
import Observation
import Testing

@testable import Variorum
import VariorumCore

@Suite("13p — launch routing")
struct StoreLaunchRouteTests {
    @Test func autoAlwaysOpens() {
        let dials = ProtectionDials(mode: .auto)
        #expect(StoreLaunchRoute.resolve(dials: dials, presence: .plaintext) == .open)
        #expect(StoreLaunchRoute.resolve(dials: dials, presence: .encryptedOrUnknown) == .open)
        #expect(StoreLaunchRoute.resolve(dials: dials, presence: .absent) == .open)
    }

    @Test func demandedModesStopAtTheLobby() {
        #expect(StoreLaunchRoute.resolve(
            dials: ProtectionDials(mode: .biometric), presence: .encryptedOrUnknown)
            == .lobby(demand: .biometric))
        #expect(StoreLaunchRoute.resolve(
            dials: ProtectionDials(mode: .passphrase), presence: .plaintext)
            == .lobby(demand: .passphrase))
    }

    /// pre-13x 1a (§3.7 — RE-RULED from 13p's PROVISIONAL Auto reset): a
    /// demanded gate over an absent store is the LIBRARY-MISSING route —
    /// the lock stays. RED ON OLD: `.openResettingModeToAuto`.
    @Test func aDemandedGateOverAnAbsentStoreIsTheLibraryMissingRoute() {
        #expect(StoreLaunchRoute.resolve(
            dials: ProtectionDials(mode: .passphrase), presence: .absent)
            == .libraryMissing(demand: .passphrase))
        #expect(StoreLaunchRoute.resolve(
            dials: ProtectionDials(mode: .biometric), presence: .absent)
            == .libraryMissing(demand: .biometric))
    }
}

@MainActor
@Suite("13p — the locked lobby & the re-lock choreography")
struct Phase13pLobbyTests {
    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-13p-lobby-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    /// The `.ready` arm builds an `AppSession`, which reads the injected
    /// clock — the AppBootstrapOffMainTests scope pattern, reused.
    private func withDeps<T>(_ body: @MainActor () async throws -> T) async rethrows -> T {
        try await withDependencies {
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.uuid = .incrementing
        } operation: { @MainActor in
            try await body()
        }
    }

    private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    /// THE DEFERRED-MIGRATION PIN. A plaintext store sits behind a
    /// passphrase-every-open gate: routing stops at the lobby and the
    /// file's bytes do not move; the unlock road then yields the key and
    /// the SAME open that always ran migrates it — verified whole.
    @Test func theMigrationIsDeferredBehindTheLobbyAndRunsAfterUnlock() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("variorum.sqlite")

        // A pre-13p plaintext store with recognizable prose.
        let plaintext = try AppDatabase.onDisk(url: storeURL, key: nil)
        try await plaintext.write { db in
            try db.execute(
                sql: "INSERT OR REPLACE INTO setting (key, value) VALUES (?, ?)",
                arguments: ["lobby_probe", "the variorum preserves its variant readings"])
        }
        plaintext.asRebindable().binding.lock()  // close the fixture's pool
        #expect(StoreFilePresence.classify(at: storeURL) == .plaintext)
        let bytesBefore = try Data(contentsOf: storeURL)

        // The key + its envelope beside the store (as the set-screen writes).
        let key = StoreKey.mint()
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: "open sesame", kdf: fastKDF())
        try envelope.write(at: envelope.preferredURL(besideStore: storeURL))

        // Route: demanded ⇒ lobby; the store file untouched.
        let route = StoreLaunchRoute.resolve(
            dials: ProtectionDials(mode: .passphrase),
            presence: StoreFilePresence.classify(at: storeURL))
        #expect(route == .lobby(demand: .passphrase))
        #expect(try Data(contentsOf: storeURL) == bytesBefore,
                "routing must not touch the store — no migration before unlock")
        #expect(!FileManager.default.fileExists(
            atPath: storeURL.deletingLastPathComponent()
                .appendingPathComponent("variorum.sqlite.encrypting").path))

        // The unlock road (the production builder over the live sidecar).
        let gate = StoreLaunchGate(
            dials: { _, _ in ProtectionDials(mode: .passphrase) },
            saveDials: { _, _, _ in },
            guardFor: { _ in StoreKeyGuard.inMemory(backing: InMemoryStoreKeyGuardBacking()) },
            loadEnvelope: { try StoreKeyEnvelope.loadCurrent(besideStore: $0) },
            saveEnvelope: { _, _ in },
            setAsideEnvelope: { _ in },
            stamp: { _, _ in nil },
            setStamp: { _, _, _ in })
        let road = StoreLobby.envelopeRoad(storeURL: storeURL, gate: gate)

        guard case .failure(let refusal) = await road(.passphrase("wrong")) else {
            Issue.record("a wrong passphrase must refuse")
            return
        }
        #expect(refusal.message == "That passphrase doesn't unlock this library.")
        #expect(StoreFilePresence.classify(at: storeURL) == .plaintext,
                "a refused unlock leaves the store untouched")

        guard case .success(let unlocked) = await road(.passphrase("open sesame")) else {
            Issue.record("the right passphrase must unwrap")
            return
        }
        #expect(unlocked == key)

        // The unlock's open: migration runs NOW, with the unwrapped key.
        let opened = try AppDatabase.openStore(
            at: storeURL, custody: .inMemory(initial: unlocked))
        #expect(StoreFilePresence.classify(at: storeURL) == .encryptedOrUnknown,
                "the deferred migration ran at unlock")
        let prose = try await opened.read { db in
            try String.fetchOne(db, sql: "SELECT value FROM setting WHERE key = 'lobby_probe'")
        }
        #expect(prose == "the variorum preserves its variant readings")
        opened.asRebindable().binding.lock()
    }

    // MARK: - The bootstrap choreography (scripted gate + test opener)

    private struct World {
        let bootstrap: AppBootstrap
        let backing: InMemoryStoreKeyGuardBacking
        let openCount: LockIsolated<Int>
        let key: StoreKey
    }

    private func demandedWorld(
        mode: StoreAtOpenMode, biometricSucceeds: Bool = false
    ) throws -> World {
        let dir = try temporaryDirectory()
        let storeURL = dir.appendingPathComponent("store.sqlite")
        let key = StoreKey.mint()
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: "sesame", kdf: fastKDF())
        let backing = InMemoryStoreKeyGuardBacking(
            gated: mode == .biometric ? key : nil,
            biometryAvailable: mode == .biometric,
            biometricSucceeds: biometricSucceeds)
        let gate = StoreLaunchGate.scripted(
            dials: ProtectionDials(mode: mode), backing: backing, envelope: envelope)
        let openCount = LockIsolated(0)
        let bootstrap = AppBootstrap(
            testOpener: {
                openCount.withValue { $0 += 1 }
                return Result { try AppDatabase.onDisk(url: storeURL, key: key) }
                    .mapError { AppDatabase.StoreOpenError(
                        storePath: storeURL.path, reason: String(describing: $0)) }
            },
            gate: gate)
        return World(bootstrap: bootstrap, backing: backing, openCount: openCount, key: key)
    }

    /// pre-13x 1a (§3.7 / decision 14) — THE ABSENT-STORE ROUTE NEVER RESETS
    /// THE LOCK, and "Start a New Library" mints under a NEW store id. RED
    /// ON OLD (13p's `openResettingModeToAuto`): the route PERSISTED
    /// `mode = .auto` through `saveDials` and OPENED a pullable library at
    /// once (`openCount == 1` on the first route, the dials box flipped to
    /// Auto). Now: the state is `.libraryMissing`, nothing opened, the
    /// legacy dials untouched; the deliberate act sets the old key file
    /// aside, writes a fresh one with a NEW store id, gives ONLY that id
    /// Auto dials, lands the key in the scripted guard, and opens — the old
    /// library's lock (its legacy dials) still reads demanded.
    @Test func aDemandedGateOverAnAbsentStoreNeverResetsTheLockAndStartNewMintsAFreshLibrary() async throws {
        try await withDeps {
            let dir = try temporaryDirectory()
            defer { try? FileManager.default.removeItem(at: dir) }
            let storeURL = dir.appendingPathComponent("variorum.sqlite")
            // The old library's key file beside the (absent) store.
            let oldKey = StoreKey.mint()
            var oldEnvelope = StoreKeyEnvelope()
            try oldEnvelope.setPassphraseWrap(key: oldKey, passphrase: "sesame", kdf: fastKDF())
            try oldEnvelope.write(at: oldEnvelope.preferredURL(besideStore: storeURL))
            let oldStoreID = oldEnvelope.storeID

            let backing = InMemoryStoreKeyGuardBacking()
            let dialsBox = ScriptedDialsBox(ProtectionDials(mode: .biometric))
            let envelopeBox = ScriptedEnvelopeBox(oldEnvelope)
            let gate = StoreLaunchGate.scripted(dials: dialsBox, backing: backing, envelope: envelopeBox)
            let openCount = LockIsolated(0)
            let bootstrap = AppBootstrap(
                testOpener: {
                    openCount.withValue { $0 += 1 }
                    return Result { try AppDatabase.onDisk(url: storeURL, key: StoreKey.mint()) }
                        .mapError { AppDatabase.StoreOpenError(
                            storePath: storeURL.path, reason: String(describing: $0)) }
                },
                gate: gate, testPresence: .absent, testStoreURL: storeURL)
            await bootstrap.awaitOpen()
            guard case .libraryMissing(let lobby) = bootstrap.state else {
                Issue.record("expected .libraryMissing, got \(bootstrap.state)")
                return
            }
            #expect(openCount.value == 0, "nothing opens — no pullable library exists")
            #expect(dialsBox.value.mode == .biometric, "the lock never resets: no dial write")
            #expect(dialsBox.perStoreDials(oldStoreID) == nil, "…and no per-store write either")
            #expect(lobby.demand == .biometric)
            #expect(backing.auto == nil, "no key was minted into custody")

            // THE DELIBERATE ACT.
            await lobby.startNewLibrary()
            #expect(lobby.lastError == nil)
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state else {
                Issue.record("expected .ready after Start a New Library, got \(bootstrap.state)")
                return
            }
            #expect(openCount.value == 1, "the fresh library opened once")
            let fresh = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: storeURL))
            #expect(fresh.storeID != oldStoreID, "a NEW store id")
            #expect(fresh.passphrase == nil, "born with no wraps")
            let minted = try #require(backing.auto)
            #expect(fresh.keyFingerprint == StoreKeyEnvelope.fingerprint(of: minted),
                    "the new key file names the minted key")
            #expect(dialsBox.perStoreDials(fresh.storeID)?.mode == .auto, "the new library is born silent")
            #expect(dialsBox.value.mode == .biometric,
                    "the OLD library's lock is untouched — restoring its file routes to its lobby")
            #expect(envelopeBox.setAsideCount == 1, "the old key file was set aside, never deleted")
            #expect(try StoreKeyEnvelope.load(at: oldEnvelope.preferredURL(besideStore: storeURL)) == nil
                    || fresh.storeID != oldStoreID)
        }
    }

    /// P11(a) (pre-13u Act 9), RED-ON-OLD: an UNREADABLE sidecar behind a
    /// demanded mode used to read as absent — no roads offered, and the
    /// dead end asserted the FALSE cause "no passphrase or recovery
    /// phrase is on file beside the library" over a file holding both.
    /// The lobby now carries the unreadable fact and its dead end speaks
    /// the sentence that always existed for it (restore the key file from
    /// a backup folder).
    @Test func anUnreadableSidecarLobbySaysTheTrueCauseNeverTheAbsentOne() async throws {
        let backing = InMemoryStoreKeyGuardBacking()
        let dialsBox = ScriptedDialsBox(ProtectionDials(mode: .passphrase))
        let envelopeBox = ScriptedEnvelopeBox(nil)
        envelopeBox.unreadable = true
        let gate = StoreLaunchGate.scripted(
            dials: dialsBox, backing: backing, envelope: envelopeBox)
        let openCount = LockIsolated(0)
        let bootstrap = AppBootstrap(
            testOpener: {
                openCount.withValue { $0 += 1 }
                return .failure(AppDatabase.StoreOpenError(
                    storePath: "", reason: "must not be reached"))
            },
            gate: gate)
        await bootstrap.awaitOpen()
        guard case .locked(let lobby) = bootstrap.state else {
            Issue.record("expected .locked, got \(bootstrap.state)")
            return
        }
        #expect(openCount.value == 0, "nothing opens before unlock, unreadable or not")
        #expect(lobby.envelopeUnreadable, "the lobby knows the sidecar exists-but-refused")
        #expect(lobby.noRoadExists, "no doors render — the facts are unknown")
        #expect(lobby.deadEndMessage == ProtectionCopy.message(
            for: StoreKeyEnvelopeError.unreadable("")),
                "the dead end names the TRUE cause (restore the key file), never the absent-wraps one")
        #expect(lobby.deadEndMessage != ProtectionCopy.deadEnd(.passphrase))
    }

    @Test func aDemandedModeLandsLockedWithoutOpeningAnything() async throws {
        let world = try demandedWorld(mode: .passphrase)
        await world.bootstrap.awaitOpen()
        guard case .locked(let lobby) = world.bootstrap.state else {
            Issue.record("expected .locked, got \(world.bootstrap.state)")
            return
        }
        #expect(world.openCount.value == 0, "NOTHING runs before unlock")
        #expect(lobby.demand == .passphrase)
        #expect(lobby.passphraseOffered)
        #expect(!lobby.biometryOffered)
        #expect(!world.bootstrap.canLock, "no Lock Now while already locked")
    }

    @Test func unlockOpensAndLockNowTearsDownAndUnlocksAgain() async throws {
        try await withDeps {
            let world = try demandedWorld(mode: .passphrase)
            await world.bootstrap.awaitOpen()
            guard case .locked(let lobby) = world.bootstrap.state else {
                Issue.record("expected .locked")
                return
            }

            // Wrong passphrase: refused in words, still locked, nothing opened.
            await lobby.unlock(passphrase: "not it")
            #expect(lobby.lastError == "That passphrase doesn't unlock this library.")
            #expect(world.openCount.value == 0)

            // The right passphrase: the open runs, the app is ready.
            await lobby.unlock(passphrase: "sesame")
            await world.bootstrap.awaitOpen()
            guard case .ready(let session) = world.bootstrap.state else {
                Issue.record("expected .ready after unlock")
                return
            }
            #expect(world.openCount.value == 1)
            #expect(world.bootstrap.canLock, "a demanded mode offers Lock Now while ready")
            try await session.database.write { db in
                try db.execute(
                    sql: "INSERT OR REPLACE INTO setting (key, value) VALUES ('relock', 'survives')")
            }

            // LOCK NOW: the teardown callback fires FIRST, the lobby lands,
            // and the pool is CLOSED — the session's database refuses typed.
            let toreDown = LockIsolated(false)
            world.bootstrap.onWillLock = { toreDown.setValue(true) }
            await world.bootstrap.lock()
            #expect(toreDown.value, "flush/stop runs before the state flips")
            guard case .locked(let secondLobby) = world.bootstrap.state else {
                Issue.record("expected .locked after Lock Now")
                return
            }
            #expect(throws: StoreLockedError()) {
                try session.database.read { db in
                    try String.fetchOne(db, sql: "SELECT value FROM setting WHERE key = 'relock'")
                }
            }

            // Unlock again: the SAME ambient plumbing reads the fresh pool.
            await secondLobby.unlock(passphrase: "sesame")
            await world.bootstrap.awaitOpen()
            guard case .ready(let reopened) = world.bootstrap.state else {
                Issue.record("expected .ready after the second unlock")
                return
            }
            #expect(world.openCount.value == 2)
            let survived = try await reopened.database.read { db in
                try String.fetchOne(db, sql: "SELECT value FROM setting WHERE key = 'relock'")
            }
            #expect(survived == "survives", "data written before the lock is there after")
        }
    }

    @Test func biometricFailureNamesThePassphraseFallback() async throws {
        try await withDeps {
            let world = try demandedWorld(mode: .biometric, biometricSucceeds: false)
            await world.bootstrap.awaitOpen()
            guard case .locked(let lobby) = world.bootstrap.state else {
                Issue.record("expected .locked")
                return
            }
            #expect(lobby.biometryOffered)
            #expect(lobby.passphraseOffered, "the fallback renders beside the gate")
            await lobby.unlockWithBiometrics()
            #expect(lobby.lastError ==
                "Biometric unlock didn't go through — enter your encryption passphrase instead.",
                "the fallback is the PASSPHRASE, never the device password (R13p-5)")

            // And the biometric road itself, scripted to succeed:
            world.backing.biometricSucceeds = true
            await lobby.unlockWithBiometrics()
            await world.bootstrap.awaitOpen()
            guard case .ready = world.bootstrap.state else {
                Issue.record("expected .ready after biometric unlock")
                return
            }
            #expect(world.openCount.value == 1)
        }
    }

    /// **Ladder R1-M3(a) — the sidecar-present unlock road on the `.failed`
    /// surface.** An encrypted store whose key custody is EMPTY lands in
    /// `.failed` (the typed `keyUnavailable` refusal) — and until this fix
    /// that state was DOORLESS even when a wraps-bearing
    /// `variorum-keys.json` sat beside the store, while the plan's own
    /// words claimed "Batch 2's recovery roads re-derive". Now the failure
    /// carries a recovery lobby (the SAME `StoreLobby` machinery, same
    /// envelope road — never a new crypto road), unlocking opens, and —
    /// under the Auto dials this state arises in — the proven key re-lands
    /// as the silent custody item so the NEXT launch opens normally.
    ///
    /// RED ON OLD (behavioral revert executed): with `failedOutcome`
    /// returning `recovery: nil` unconditionally — the pre-fix shape — the
    /// recovery guard below records the doorless state.
    @Test func aKeyGoneFailureWithASidecarOffersTheEnvelopeRoadAndUnlockOpens() async throws {
        try await withDeps {
            let dir = try temporaryDirectory()
            defer { try? FileManager.default.removeItem(at: dir) }
            let storeURL = dir.appendingPathComponent("store.sqlite")
            let key = StoreKey.mint()
            var envelope = StoreKeyEnvelope()
            try envelope.setPassphraseWrap(key: key, passphrase: "sesame", kdf: fastKDF())

            // AUTO dials + empty custody: the route opens, the open fails
            // with the typed key-gone refusal — scripted here; the drill
            // (`Phase13pKeyedDrillTests`) proves the production `openStore`
            // throws exactly this marker over real files.
            let backing = InMemoryStoreKeyGuardBacking()
            let gate = StoreLaunchGate.scripted(
                dials: ProtectionDials(mode: .auto), backing: backing, envelope: envelope)
            let openCount = LockIsolated(0)
            let bootstrap = AppBootstrap(
                testOpener: {
                    let n = openCount.withValue { value -> Int in
                        value += 1
                        return value
                    }
                    guard n > 1 else {
                        return .failure(AppDatabase.StoreOpenError(
                            storePath: storeURL.path,
                            reason: "This library is encrypted, and its key is not "
                                + "available on this device.",
                            keyUnavailable: true))
                    }
                    return Result { try AppDatabase.onDisk(url: storeURL, key: key) }
                        .mapError { AppDatabase.StoreOpenError(
                            storePath: storeURL.path, reason: String(describing: $0)) }
                },
                gate: gate)
            await bootstrap.awaitOpen()
            guard case .failed(let error, let recovery) = bootstrap.state else {
                Issue.record("expected .failed, got \(bootstrap.state)")
                return
            }
            #expect(error.keyUnavailable)
            guard let recovery else {
                Issue.record(
                    "a wraps-bearing sidecar must open the recovery road — the doorless state is the finding")
                return
            }
            #expect(recovery.passphraseOffered)
            #expect(!recovery.biometryOffered, "no gated item exists on this road")

            // A wrong secret refuses in words and stays failed.
            await recovery.unlock(passphrase: "not it")
            #expect(recovery.lastError == "That passphrase doesn't unlock this library.")
            #expect(openCount.value == 1)

            // The right passphrase unlocks THROUGH the failure surface.
            await recovery.unlock(passphrase: "sesame")
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state else {
                Issue.record("expected .ready after the recovery unlock")
                return
            }
            #expect(openCount.value == 2)

            // The custody HEAL: under Auto the custody law says a silent
            // item exists — the proven key re-lands (off-main; bounded wait,
            // the house pattern) so the next launch opens silently instead
            // of failing into the same surface.
            var healed = false
            for _ in 0..<400 where !healed {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
                healed = backing.auto == key
            }
            #expect(healed, "the proven key re-lands as the Auto custody item")
        }
    }

    /// **Ladder R1-m2 — the Lock Now door tracks the OBSERVABLE dials
    /// projection, both ways.** `canLock` used to read `gate.dials` — an
    /// un-observed defaults read — so the Mac menu (and the phone's sheet,
    /// which worse still captured a `let canLock: Bool` at construction)
    /// re-evaluated only when something ELSE changed: a mode flip through
    /// the pane left a Lock Now door rendered that `lock()` then silently
    /// refused, or a door missing that should have appeared.
    ///
    /// RED ON OLD (behavioral revert executed): with the un-observed read
    /// restored, the flips below mutate only `protection.dials`, no
    /// tracked access changes, and `onChange` never fires — both
    /// `#expect(fired…)` lines go red.
    @Test func canLockTracksAModeFlipBothWays() async throws {
        try await withDeps {
            let world = try demandedWorld(mode: .passphrase)
            await world.bootstrap.awaitOpen()
            guard case .locked(let lobby) = world.bootstrap.state else {
                Issue.record("expected .locked")
                return
            }
            await lobby.unlock(passphrase: "sesame")
            await world.bootstrap.awaitOpen()
            guard case .ready = world.bootstrap.state else {
                Issue.record("expected .ready after unlock")
                return
            }
            #expect(world.bootstrap.canLock)

            // Demanded → Auto: the door must withdraw, OBSERVABLY — a
            // renderer that read `canLock` must be invalidated by the flip.
            let firedDown = LockIsolated(false)
            withObservationTracking {
                _ = world.bootstrap.canLock
            } onChange: {
                firedDown.setValue(true)
            }
            #expect(await world.bootstrap.protection.setMode(.auto) == .changed)
            #expect(firedDown.value,
                    "the demanded→auto flip must invalidate whatever renders the door")
            #expect(!world.bootstrap.canLock)

            // Auto → demanded: the door must come BACK the same way.
            let firedUp = LockIsolated(false)
            withObservationTracking {
                _ = world.bootstrap.canLock
            } onChange: {
                firedUp.setValue(true)
            }
            #expect(await world.bootstrap.protection.setMode(.passphrase) == .changed)
            #expect(firedUp.value,
                    "the auto→demanded flip must invalidate it too")
            #expect(world.bootstrap.canLock)
        }
    }

    @Test func lockNowUnderAutoIsRefusedAsTheater() async throws {
        try await withDeps {
            let dir = try temporaryDirectory()
            let storeURL = dir.appendingPathComponent("store.sqlite")
            let key = StoreKey.mint()
            let gate = StoreLaunchGate.scripted(
                dials: ProtectionDials(mode: .auto),
                backing: InMemoryStoreKeyGuardBacking())
            let bootstrap = AppBootstrap(
                testOpener: {
                    Result { try AppDatabase.onDisk(url: storeURL, key: key) }
                        .mapError { AppDatabase.StoreOpenError(
                            storePath: storeURL.path, reason: String(describing: $0)) }
                },
                gate: gate)
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state else {
                Issue.record("auto opens straight to ready")
                return
            }
            #expect(!bootstrap.canLock, "R13p-14: no theater ships — Lock Now is not offered under Auto")
            await bootstrap.lock()
            if case .locked = bootstrap.state {
                Issue.record("a lock under Auto must refuse silently")
            }
        }
    }
}
