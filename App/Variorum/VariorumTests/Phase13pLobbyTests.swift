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

    @Test func aDemandedGateOverAnAbsentStoreResetsToAuto() {
        // PROVISIONAL (run record): the gate outlived its store.
        #expect(StoreLaunchRoute.resolve(
            dials: ProtectionDials(mode: .passphrase), presence: .absent)
            == .openResettingModeToAuto)
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
        try envelope.write(at: StoreKeyEnvelope.url(besideStore: storeURL))

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
            dials: { _ in ProtectionDials(mode: .passphrase) },
            saveDials: { _, _ in },
            guardFor: { _ in StoreKeyGuard.inMemory(backing: InMemoryStoreKeyGuardBacking()) },
            loadEnvelope: { try StoreKeyEnvelope.load(at: StoreKeyEnvelope.url(besideStore: $0)) },
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
