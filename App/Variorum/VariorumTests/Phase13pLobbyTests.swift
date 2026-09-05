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
    /// pre-13x 2a: the route reads the EFFECTIVE gate (derived), never a
    /// stored mode.
    @Test func autoAlwaysOpens() {
        #expect(StoreLaunchRoute.resolve(gate: .auto, presence: .plaintext) == .open)
        #expect(StoreLaunchRoute.resolve(gate: .auto, presence: .encryptedOrUnknown) == .open)
        #expect(StoreLaunchRoute.resolve(gate: .auto, presence: .absent) == .open)
    }

    @Test func demandedGatesStopAtTheLobby() {
        #expect(StoreLaunchRoute.resolve(gate: .biometric, presence: .encryptedOrUnknown)
            == .lobby(demand: .biometric))
        #expect(StoreLaunchRoute.resolve(gate: .passphrase, presence: .plaintext)
            == .lobby(demand: .passphrase))
    }

    /// pre-13x 1a (§3.7 — RE-RULED from 13p's PROVISIONAL Auto reset): a
    /// demanded gate over an absent store is the LIBRARY-MISSING route —
    /// the lock stays. RED ON OLD: `.openResettingModeToAuto`.
    @Test func aDemandedGateOverAnAbsentStoreIsTheLibraryMissingRoute() {
        #expect(StoreLaunchRoute.resolve(gate: .passphrase, presence: .absent)
            == .libraryMissing(demand: .passphrase))
        #expect(StoreLaunchRoute.resolve(gate: .biometric, presence: .absent)
            == .libraryMissing(demand: .biometric))
    }

    /// pre-13x 2a — THE GATE AT THE ROUTE derives from the key file beside
    /// the store (Castle: a passphrase wrap, no Apple copy; Standard: an
    /// Apple copy) and Castle's style; the 13p-era stored mode reads
    /// through until §11 retires it. RED ON OLD: the route read a stored
    /// three-way mode.
    @Test func theRouteDerivesTheGateFromTheKeyFileAndTheStyle() throws {
        let key = StoreKey.mint()
        let kdf = PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
        var castle = StoreKeyEnvelope()
        try castle.setPassphraseWrap(key: key, passphrase: "sesame", kdf: kdf)
        var standard = castle
        try standard.appleBox(key: key, under: AppleKey.mint().symmetricKey, appleKeyID: "a")
        func gate(_ envelope: StoreKeyEnvelope?, dials: ProtectionDials, legacy: StoreAtOpenMode? = nil) -> StoreAtOpenMode {
            StoreLaunchGate.scripted(
                dials: dials, backing: InMemoryStoreKeyGuardBacking(), envelope: envelope,
                legacyMode: legacy
            ).effectiveGate(scope: "route", storeID: envelope?.storeID, storeURL: nil)
        }
        #expect(gate(standard, dials: ProtectionDials()) == .auto)
        #expect(gate(castle, dials: ProtectionDials()) == .biometric)
        #expect(gate(castle, dials: ProtectionDials(alwaysAsk: true)) == .passphrase)
        #expect(gate(nil, dials: ProtectionDials(alwaysAsk: true)) == .auto, "a fresh library is born Standard")
        #expect(gate(standard, dials: ProtectionDials(), legacy: .biometric) == .biometric,
                "the 13p-era stored mode reads through until the migration retires it")
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
            gate: .passphrase,
            presence: StoreFilePresence.classify(at: storeURL))
        #expect(route == .lobby(demand: .passphrase))
        #expect(try Data(contentsOf: storeURL) == bytesBefore,
                "routing must not touch the store — no migration before unlock")
        #expect(!FileManager.default.fileExists(
            atPath: storeURL.deletingLastPathComponent()
                .appendingPathComponent("variorum.sqlite.encrypting").path))

        // The unlock road (the production builder over the live sidecar).
        let gate = StoreLaunchGate(
            dials: { _, _ in ProtectionDials(alwaysAsk: true) },
            saveDials: { _, _, _ in },
            legacyMode: { _, _ in nil },
            retireLegacyDials: { _, _ in },
            guardFor: { _ in StoreKeyGuard.inMemory(backing: InMemoryStoreKeyGuardBacking()) },
            appleKeyFor: { _ in AppleKeyLeaves.inMemory(backing: InMemoryAppleKeyBacking()) },
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
        // pre-13x 2a: the key file (a passphrase wrap, no Apple copy) DERIVES
        // Castle; the gate style is the dial.
        let gate = StoreLaunchGate.scripted(
            dials: ProtectionDials(alwaysAsk: mode == .passphrase), backing: backing, envelope: envelope)
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

            // pre-13x 2a: the OLD library's key file (a passphrase wrap, no
            // Apple copy) derives Castle — Touch ID by the default style.
            let backing = InMemoryStoreKeyGuardBacking()
            let dialsBox = ScriptedDialsBox(ProtectionDials())
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
            #expect(dialsBox.perStoreDials(oldStoreID) == nil, "the lock never resets: no dial write")
            #expect(dialsBox.retiredStoreIDs.isEmpty, "…and nothing retired")
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
            #expect(dialsBox.perStoreDials(fresh.storeID) != nil, "the new library writes its own dials")
            #expect(Posture.derive(legacyMode: nil, vaultHasAppleHeldCopy: nil, keyFile: fresh) == .standard,
                    "the new library is born Standard (silent)")
            #expect(Posture.derive(legacyMode: nil, vaultHasAppleHeldCopy: nil, keyFile: oldEnvelope) == .castle,
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
        // pre-13x 2a: an unreadable key file cannot say the posture; the
        // 13p-era stored mode (the read-through, until §11) still routes a
        // demanded library to its lobby.
        let backing = InMemoryStoreKeyGuardBacking()
        let dialsBox = ScriptedDialsBox(ProtectionDials(alwaysAsk: true), legacyMode: .passphrase)
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

    /// **pre-13x 2a — STANDARD'S OPEN ROAD (§3.8).** A Standard library
    /// whose bound item is MISSING (a restored copy on a fresh device; a
    /// wiped Keychain) opens SILENTLY through the key file's Apple copy when
    /// A is in iCloud Keychain, and the proven key RE-LANDS as the bound
    /// item (R1-M3's heal) so the next launch opens normally.
    /// RED ON OLD (13p's road): the open failed `keyUnavailable` into the
    /// `.failed` surface — no Apple road existed.
    @Test func aStandardLibraryWithAMissingBoundItemOpensThroughTheAppleKey() async throws {
        try await withDeps {
            let dir = try temporaryDirectory()
            defer { try? FileManager.default.removeItem(at: dir) }
            let storeURL = dir.appendingPathComponent("store.sqlite")
            let key = StoreKey.mint()
            let apple = AppleKey.mint()
            var envelope = StoreKeyEnvelope()
            try envelope.setPassphraseWrap(key: key, passphrase: "sesame", kdf: fastKDF())
            try envelope.appleBox(key: key, under: apple.symmetricKey, appleKeyID: apple.id)
            let backing = InMemoryStoreKeyGuardBacking()  // NO bound item
            let gate = StoreLaunchGate.scripted(
                dials: ProtectionDials(), backing: backing, envelope: envelope,
                appleKey: InMemoryAppleKeyBacking(key: apple))  // A is here
            let openCount = LockIsolated(0)
            let bootstrap = AppBootstrap(
                testOpener: {
                    openCount.withValue { $0 += 1 }
                    return Result { try AppDatabase.onDisk(url: storeURL, key: key) }
                        .mapError { AppDatabase.StoreOpenError(
                            storePath: storeURL.path, reason: String(describing: $0)) }
                },
                gate: gate, testStoreURL: storeURL)
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state else {
                Issue.record("expected .ready through the Apple road, got \(bootstrap.state)")
                return
            }
            #expect(openCount.value == 1, "opened silently — nothing typed")
            var healed = false
            for _ in 0..<400 where !healed {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
                healed = backing.auto == key
            }
            #expect(healed, "the proven key re-lands as the bound item — the next launch opens normally")
        }
    }

    /// **THE WAITING STATE (§3.8; copy §2d).** A absent ⇒ no silent mint
    /// (nothing opens, nothing lands in custody), a real state whose
    /// doors ACT: the passphrase unlocks and the key re-lands; the Apple
    /// road is RE-PROBED and opens the moment A lands.
    /// RED ON OLD: the pre-2a road failed into `.failed(recovery:)`; no
    /// waiting state, no re-probe.
    @Test func anAbsentAppleKeyIsTheWaitingStateWhoseDoorsActAndWhoseProbeOpensWhenALands() async throws {
        try await withDeps {
            let dir = try temporaryDirectory()
            defer { try? FileManager.default.removeItem(at: dir) }
            let storeURL = dir.appendingPathComponent("store.sqlite")
            let key = StoreKey.mint()
            let apple = AppleKey.mint()
            var envelope = StoreKeyEnvelope()
            try envelope.setPassphraseWrap(key: key, passphrase: "sesame", kdf: fastKDF())
            try envelope.appleBox(key: key, under: apple.symmetricKey, appleKeyID: apple.id)
            let backing = InMemoryStoreKeyGuardBacking()
            let appleKeys = InMemoryAppleKeyBacking()  // A NOT here yet
            let gate = StoreLaunchGate.scripted(
                dials: ProtectionDials(), backing: backing, envelope: envelope, appleKey: appleKeys)
            let openCount = LockIsolated(0)
            let bootstrap = AppBootstrap(
                testOpener: {
                    openCount.withValue { $0 += 1 }
                    return Result { try AppDatabase.onDisk(url: storeURL, key: key) }
                        .mapError { AppDatabase.StoreOpenError(
                            storePath: storeURL.path, reason: String(describing: $0)) }
                },
                gate: gate, testStoreURL: storeURL)
            await bootstrap.awaitOpen()
            guard case .waitingForICloudKeychain(let lobby) = bootstrap.state else {
                Issue.record("expected the waiting state, got \(bootstrap.state)")
                return
            }
            #expect(openCount.value == 0, "NOTHING opens — never a silent mint over an existing store")
            #expect(backing.auto == nil, "no key minted into custody")
            #expect(lobby.isWaitingForICloudKeychain)
            #expect(!lobby.differentAppleID)
            #expect(lobby.passphraseOffered, "the door that acts (no twelve words on file here — that door renders when they exist)")
            #expect(!lobby.recoveryOffered)
            #expect(lobby.demand == .auto, "no gate — the library is Standard")
            #expect(!bootstrap.canLock)

            // The doors act: a wrong secret refuses in words; the right one
            // opens THROUGH the waiting state, and the key re-lands.
            await lobby.unlock(passphrase: "not it")
            #expect(lobby.lastError == "That passphrase doesn't unlock this library.")
            #expect(openCount.value == 0)
            await lobby.unlock(passphrase: "sesame")
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state else {
                Issue.record("expected .ready after the passphrase door")
                return
            }
            #expect(openCount.value == 1)
            var healed = false
            for _ in 0..<400 where !healed {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
                healed = backing.auto == key
            }
            #expect(healed, "the proven key re-lands as the bound item")

            // THE RE-PROBE: a second launch with the bound item gone again
            // waits — and opens the moment A lands in iCloud Keychain.
            backing.auto = nil
            let again = AppBootstrap(
                testOpener: {
                    openCount.withValue { $0 += 1 }
                    return Result { try AppDatabase.onDisk(url: storeURL, key: key) }
                        .mapError { AppDatabase.StoreOpenError(
                            storePath: storeURL.path, reason: String(describing: $0)) }
                },
                gate: gate, testStoreURL: storeURL)
            await again.awaitOpen()
            guard case .waitingForICloudKeychain(let waiting) = again.state else {
                Issue.record("expected the waiting state again, got \(again.state)")
                return
            }
            waiting.stopWaiting()
            waiting.beginWaiting(every: .milliseconds(5))
            appleKeys.key = apple  // …A arrives
            var opened = false
            for _ in 0..<800 where !opened {
                try? await Task.sleep(for: .milliseconds(2))
                await again.awaitOpen()
                if case .ready = again.state { opened = true }
            }
            #expect(opened, "the waiting state's probe opened the library when A landed")
            #expect(waiting.appleProbes >= 1, "the Apple road was polled")
        }
    }

    /// A DIFFERENT Apple ID's A (the key file's copy is under another id):
    /// the waiting state says so (copy §2d's third sentence) — the
    /// passphrase road answers once; nothing is adopted from the wire.
    @Test func anotherAppleIDsKeyRendersTheDifferentAppleIDSentence() async throws {
        try await withDeps {
            let dir = try temporaryDirectory()
            defer { try? FileManager.default.removeItem(at: dir) }
            let storeURL = dir.appendingPathComponent("store.sqlite")
            let key = StoreKey.mint()
            var envelope = StoreKeyEnvelope()
            try envelope.setPassphraseWrap(key: key, passphrase: "sesame", kdf: fastKDF())
            try envelope.appleBox(key: key, under: AppleKey.mint().symmetricKey, appleKeyID: "the-other-mac")
            let backing = InMemoryStoreKeyGuardBacking()
            let gate = StoreLaunchGate.scripted(
                dials: ProtectionDials(), backing: backing, envelope: envelope,
                appleKey: InMemoryAppleKeyBacking(key: AppleKey.mint()))  // THIS iCloud's A
            let bootstrap = AppBootstrap(
                testOpener: { .failure(AppDatabase.StoreOpenError(storePath: "", reason: "must not open")) },
                gate: gate, testStoreURL: storeURL)
            await bootstrap.awaitOpen()
            guard case .waitingForICloudKeychain(let lobby) = bootstrap.state else {
                Issue.record("expected the waiting state, got \(bootstrap.state)")
                return
            }
            #expect(lobby.differentAppleID, "iCloud Keychain holds an A that is not this library's")
            #expect(backing.auto == nil, "nothing adopted from a key that does not open the copy")
        }
    }

    /// **Ladder R1-m2 — the Lock Now door tracks the OBSERVABLE projection,
    /// both ways.** `canLock` used to read `gate.dials` — an un-observed
    /// defaults read — so a change never re-rendered the door. pre-13x 2a:
    /// the door follows the DERIVED posture — a key file that gains its
    /// Apple copy (Standard) withdraws Lock Now at the next reconcile, and
    /// one that loses it (Castle) brings it back, each OBSERVABLY.
    ///
    /// RED ON OLD (behavioral revert executed at 13p): with the un-observed
    /// read restored, no tracked access changes and `onChange` never fires.
    @Test func canLockTracksTheDerivedPostureBothWays() async throws {
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
            let protection = world.bootstrap.protection

            // Castle → Standard: the key file gains an Apple copy (the
            // switch's key-file act, 2b's) — the derived posture follows at
            // the reconcile, and the door withdraws, OBSERVABLY.
            let firedDown = LockIsolated(false)
            withObservationTracking {
                _ = world.bootstrap.canLock
            } onChange: {
                firedDown.setValue(true)
            }
            var standardFile = try #require(world.bootstrap.gate.readEnvelope(nil).envelope)
            try standardFile.appleBox(key: world.key, under: AppleKey.mint().symmetricKey, appleKeyID: "a")
            try world.bootstrap.gate.saveEnvelope(standardFile, URL(fileURLWithPath: "/dev/null"))
            await protection.reconcile()
            #expect(protection.posture == .standard)
            #expect(firedDown.value,
                    "the Castle→Standard derivation must invalidate whatever renders the door")
            #expect(!world.bootstrap.canLock)

            // Standard → Castle: the Apple copy goes; the door comes BACK.
            let firedUp = LockIsolated(false)
            withObservationTracking {
                _ = world.bootstrap.canLock
            } onChange: {
                firedUp.setValue(true)
            }
            var castleFile = try #require(world.bootstrap.gate.readEnvelope(nil).envelope)
            try castleFile.removeAppleBox()
            try world.bootstrap.gate.saveEnvelope(castleFile, URL(fileURLWithPath: "/dev/null"))
            await protection.reconcile()
            #expect(protection.posture == .castle)
            #expect(firedUp.value, "the Standard→Castle derivation must invalidate it too")
            #expect(world.bootstrap.canLock)
        }
    }

    @Test func lockNowUnderAutoIsRefusedAsTheater() async throws {
        try await withDeps {
            let dir = try temporaryDirectory()
            let storeURL = dir.appendingPathComponent("store.sqlite")
            let key = StoreKey.mint()
            let gate = StoreLaunchGate.scripted(
                dials: ProtectionDials(),
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
