//
//  MobileProtectionTests.swift
//  VariorumMobileTests
//
//  Phase 13p, Batch 4 — THE PHONE'S HALF OF WHOLE-STORE ENCRYPTION
//  (PL-15; the plan's MOBILE-ONLY-USER EXPANSION, items a–i). Her rider
//  at the Batch-1 GO is what these pins are for: *"some people will be
//  mobile only users"* — so every claim below is made about a library
//  whose only home is this phone, with no Mac anywhere in the road.
//
//  What is pinned here, and what deliberately is not:
//  · (a) FIRST LAUNCH ON THE PHONE mints the key and the store is born
//    ENCRYPTED — through the same `openStore` the app's bootstrap calls.
//  · (b) THE PHONE'S EXISTING STORE MIGRATES on its first keyed open,
//    content whole, zero plaintext afterwards.
//  · (c) THE LOCKED LOBBY on iOS: a demanded mode lands `.locked` with
//    NOTHING opened, unlock opens, Lock Now tears down and re-locks —
//    the Mac's own choreography, proven on the phone's compiled copy of
//    the shared brain (a hoist is only real if both sides run it).
//  · (g) THE RE-LOCK DIAL's phone reading — pure policy, the
//    coordinator's stamp, and the scene seam's ORDER (flush first, lock
//    last; a return that locks does not first wake a sync round).
//  · (h) the loss math's ONE brain and the one-device sentence.
//  · (i) capture over a LOCKED store refuses in words and KEEPS her text
//    — her ratification's reachable seam.
//  · The platform-aware copy actually reading as the phone's.
//
//  NO test here evaluates biometrics or touches the Keychain: every
//  custody road runs through the scripted `StoreLaunchGate`/
//  `InMemoryStoreKeyGuardBacking`, exactly as the Mac suite does. The
//  LIVE Face ID walk on her device is a morning act, recorded PENDING.
//

import CryptoKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - Helpers

@MainActor
private func temporaryDirectory() throws -> URL {
    let url = FileManager.default.temporaryDirectory
        .appendingPathComponent("variorum-13p-phone-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
}

private func fastKDF() -> PassphraseKDF.Descriptor {
    PassphraseKDF.Descriptor(
        algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
        memoryKiB: 256, iterations: 1, parallelism: 1,
        salt: PassphraseKDF.randomSalt(), outputBytes: 32)
}

/// Does the file hold this prose in the clear? (The zero-plaintext scan,
/// the same shape Batch 1's acceptance pin uses.)
private func fileContains(_ needle: String, at url: URL) throws -> Bool {
    let bytes = try Data(contentsOf: url)
    guard let probe = needle.data(using: .utf8) else { return false }
    return bytes.range(of: probe) != nil
}

// MARK: - (a) + (b): the phone as a birthplace, and as a migrator

@MainActor
@Suite("13p phone — the store is born encrypted, and an old one migrates")
struct MobilePhoneStoreEncryptionTests {
    /// **ITEM (a).** A phone with no Mac anywhere: the first open MINTS a
    /// key into this device's (scripted) custody and the store that
    /// appears is ciphertext from its first byte. Zero ceremony — the
    /// knot-4 ruled shape, on iOS.
    @Test func firstLaunchOnThePhoneMintsTheKeyAndTheStoreIsBornEncrypted() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("variorum.sqlite")
        let custody = StoreKeyCustody.inMemory()  // empty: nothing minted yet
        #expect(custody.load() == nil)
        #expect(StoreFilePresence.classify(at: storeURL) == .absent)

        let database = try AppDatabase.openStore(at: storeURL, custody: custody)
        try await database.write { db in
            try db.execute(
                sql: "INSERT OR REPLACE INTO setting (key, value) VALUES (?, ?)",
                arguments: ["phone_probe", "written on the phone, never on a Mac"])
        }
        // The key exists NOW and did not before — the phone minted it.
        let minted = try #require(custody.load())
        #expect(minted.data.count == 32)
        // …and nothing readable reached the disk.
        #expect(StoreFilePresence.classify(at: storeURL) == .encryptedOrUnknown)
        #expect(try !fileContains("written on the phone", at: storeURL))
        database.asRebindable().binding.lock()

        // Re-opening with that custody reads it back whole.
        let reopened = try AppDatabase.openStore(at: storeURL, custody: custody)
        let prose = try await reopened.read { db in
            try String.fetchOne(db, sql: "SELECT value FROM setting WHERE key = 'phone_probe'")
        }
        #expect(prose == "written on the phone, never on a Mac")
        reopened.asRebindable().binding.lock()
    }

    /// **ITEM (b).** Her phone's real store is a PRE-13p plaintext store;
    /// it migrates on the first keyed open through the same
    /// `sqlcipher_export` road the Mac drilled — the substrate reaches
    /// iOS by construction, and this is the pin that says so out loud.
    @Test func aPlaintextPhoneStoreMigratesOnItsFirstKeyedOpen() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("variorum.sqlite")

        let plaintext = try AppDatabase.onDisk(url: storeURL, key: nil)
        try await plaintext.write { db in
            try db.execute(
                sql: "INSERT OR REPLACE INTO setting (key, value) VALUES (?, ?)",
                arguments: ["phone_probe", "a journal entry typed in bed"])
        }
        plaintext.asRebindable().binding.lock()
        #expect(StoreFilePresence.classify(at: storeURL) == .plaintext)
        #expect(try fileContains("typed in bed", at: storeURL),
                "the control: before the migration it IS readable")

        let custody = StoreKeyCustody.inMemory(initial: .mint())
        let migrated = try AppDatabase.openStore(at: storeURL, custody: custody)
        #expect(StoreFilePresence.classify(at: storeURL) == .encryptedOrUnknown)
        #expect(try !fileContains("typed in bed", at: storeURL))
        let prose = try await migrated.read { db in
            try String.fetchOne(db, sql: "SELECT value FROM setting WHERE key = 'phone_probe'")
        }
        #expect(prose == "a journal entry typed in bed", "the content survived whole")
        migrated.asRebindable().binding.lock()
    }
}

// MARK: - (c): the locked lobby, on the phone's own compiled brain

@MainActor
@Suite("13p phone — the locked lobby & re-lock choreography")
struct MobilePhoneLobbyTests {
    private struct World {
        let bootstrap: AppBootstrap
        let backing: InMemoryStoreKeyGuardBacking
        let openCount: LockIsolated<Int>
    }

    private func withDeps<T>(_ body: @MainActor () async throws -> T) async rethrows -> T {
        try await withDependencies {
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.uuid = .incrementing
        } operation: { @MainActor in
            try await body()
        }
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
        // pre-13x 2a: the key file (a passphrase wrap, no Apple copy)
        // DERIVES Castle; the gate style is the dial.
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
        return World(bootstrap: bootstrap, backing: backing, openCount: openCount)
    }

    /// **NOTHING RUNS BEFORE UNLOCK on the phone either** — and, because
    /// the shell (and with it the quick-note box, the only capture
    /// surface the phone has) exists ONLY inside `.ready`, this is item
    /// (i)'s structural half: there is no box to type into while locked.
    @Test func aDemandedModeLandsLockedWithNothingOpened() async throws {
        let world = try demandedWorld(mode: .passphrase)
        await world.bootstrap.awaitOpen()
        guard case .locked(let lobby) = world.bootstrap.state else {
            Issue.record("expected .locked, got \(world.bootstrap.state)")
            return
        }
        #expect(world.openCount.value == 0)
        #expect(lobby.demand == .passphrase)
        #expect(lobby.passphraseOffered)
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
            await lobby.unlock(passphrase: "not it")
            #expect(lobby.lastError == "That passphrase doesn't unlock this library.")
            #expect(world.openCount.value == 0)

            await lobby.unlock(passphrase: "sesame")
            await world.bootstrap.awaitOpen()
            guard case .ready(let session) = world.bootstrap.state else {
                Issue.record("expected .ready after unlock")
                return
            }
            #expect(world.openCount.value == 1)
            #expect(world.bootstrap.canLock)
            try await session.database.write { db in
                try db.execute(
                    sql: "INSERT OR REPLACE INTO setting (key, value) "
                        + "VALUES ('relock', 'survives')")
            }

            await world.bootstrap.lock()
            guard case .locked(let secondLobby) = world.bootstrap.state else {
                Issue.record("expected .locked after Lock Now")
                return
            }
            #expect(throws: StoreLockedError()) {
                try session.database.read { db in
                    try String.fetchOne(
                        db, sql: "SELECT value FROM setting WHERE key = 'relock'")
                }
            }
            await secondLobby.unlock(passphrase: "sesame")
            await world.bootstrap.awaitOpen()
            guard case .ready(let reopened) = world.bootstrap.state else {
                Issue.record("expected .ready after the second unlock")
                return
            }
            let survived = try await reopened.database.read { db in
                try String.fetchOne(db, sql: "SELECT value FROM setting WHERE key = 'relock'")
            }
            #expect(survived == "survives")
        }
    }

    /// **Ladder R1-M2 — the phone's lock runs the ruled teardown.** Until
    /// this fix `onWillLock` was wired ONLY on the Mac: the phone's Lock
    /// Now flipped to `.locked` and closed the pool with NO flush or
    /// savepoint leg — a pending keystroke burst raced `StoreLockedError`
    /// and was lost from the store — and the mobile services were never
    /// stopped or released, so schedulers fired into typed refusals
    /// through the locked window and the stale services object survived
    /// past the next `.ready`'s `guard services == nil`.
    ///
    /// This pin drives the SAME factory production wires
    /// (`mobileWillLock`) over the scripted world: a registered editor
    /// with a pending edit → `lock()` → unlock → the edit SURVIVES, a
    /// leaving savepoint landed, and the services stop hook ran.
    ///
    /// RED ON OLD (behavioral revert executed): with the factory's body
    /// emptied — the pre-fix world, where nothing wires the teardown —
    /// the pending edit dies with the pool and the survival assertion
    /// goes red.
    @Test func aLockFlushesPendingEditsAndStopsServicesBeforeThePoolCloses() async throws {
        try await withDeps {
            let world = try demandedWorld(mode: .passphrase)
            await world.bootstrap.awaitOpen()
            guard case .locked(let lobby) = world.bootstrap.state else {
                Issue.record("expected .locked")
                return
            }
            await lobby.unlock(passphrase: "sesame")
            await world.bootstrap.awaitOpen()
            guard case .ready(let session) = world.bootstrap.state else {
                Issue.record("expected .ready after unlock")
                return
            }
            // The test-opener road skips the process-global install, so the
            // ambient database is bound here exactly where production's
            // install would have bound it (plus the jitter generator the
            // ops' fractional indexes read).
            try await withDependencies {
                $0.database = session.database
                $0.withRandomNumberGenerator =
                    WithRandomNumberGenerator(SeededGenerator(seed: 11))
            } operation: { @MainActor in
                let post = try await session.runner.run { ops in
                    try ops.createPost(title: "locked mid-thought", profile: .blog)
                }
                let minted = try await session.runner.run { ops in
                    try ops.newBlock(in: post.id, text: "A", at: .end)
                }

                // A registered editor with a PENDING edit (clocks off — the
                // burst sits in the coordinator, not the store).
                let editors = MobileLivenessAuthority()
                let (editor, storage) = makeEditor(session, postID: post.id)
                await editors.register(editor, tab: .shelf)
                await editor.loadOnce()
                typeEdit(
                    editor, storage,
                    range: NSRange(location: 1, length: 0), replacement: " typed")
                #expect(editor.autosave.isDirty, "the edit is pending, not landed")

                // Production's own wiring: the factory the app composes.
                let stops = LockIsolated(0)
                world.bootstrap.onWillLock = mobileWillLock(
                    session: session, editors: editors,
                    stopServices: { stops.withValue { $0 += 1 } })

                await world.bootstrap.lock()
                guard case .locked(let secondLobby) = world.bootstrap.state else {
                    Issue.record("expected .locked after Lock Now")
                    return
                }
                #expect(stops.value == 1,
                        "the services stop-and-release hook runs at lock")

                await secondLobby.unlock(passphrase: "sesame")
                await world.bootstrap.awaitOpen()
                guard case .ready(let reopened) = world.bootstrap.state else {
                    Issue.record("expected .ready after the second unlock")
                    return
                }
                let survived = try await reopened.database.read { db in
                    try String.fetchOne(
                        db, sql: "SELECT working_text FROM variant WHERE id = ?",
                        arguments: [minted.variant.id])
                }
                #expect(survived == "A typed",
                        "the pending keystrokes land BEFORE the pool closes — the ruled order")
                let savepoints = try await reopened.database.read { db in
                    try Int.fetchOne(
                        db, sql: "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?",
                        arguments: [minted.variant.id]) ?? 0
                }
                #expect(savepoints >= 1,
                        "the leaving savepoint landed (the ⌘Q registry's phone twin)")
            }
        }
    }

    /// pre-13x 1a (§3.7) ON THE PHONE — the same brain, the same law: a
    /// demanded gate over an absent store lands `.libraryMissing`, opens
    /// nothing, writes no dial; Start a New Library mints under a NEW store
    /// id with its own Auto dials while the old lock stays. RED ON OLD:
    /// 13p's route reset the mode to Auto and opened at once.
    @Test func anAbsentStoreUnderADemandedModeNeverResetsTheLockOnThePhone() async throws {
        try await withDeps {
            let dir = try temporaryDirectory()
            let storeURL = dir.appendingPathComponent("variorum.sqlite")
            let oldKey = StoreKey.mint()
            var oldEnvelope = StoreKeyEnvelope()
            try oldEnvelope.setPassphraseWrap(key: oldKey, passphrase: "sesame", kdf: fastKDF())
            try oldEnvelope.write(at: oldEnvelope.preferredURL(besideStore: storeURL))
            // pre-13x 2a: the old key file (a passphrase wrap, no Apple copy)
            // derives Castle — Face ID by the default style.
            let backing = InMemoryStoreKeyGuardBacking(biometryAvailable: true)
            let dialsBox = ScriptedDialsBox(ProtectionDials())
            let gate = StoreLaunchGate.scripted(
                dials: dialsBox, backing: backing, envelope: ScriptedEnvelopeBox(oldEnvelope))
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
            #expect(openCount.value == 0)
            #expect(dialsBox.perStoreDials(oldEnvelope.storeID) == nil, "the lock never resets: no dial write")
            #expect(lobby.demand == .biometric)
            await lobby.startNewLibrary()
            #expect(lobby.lastError == nil)
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state else {
                Issue.record("expected .ready, got \(bootstrap.state)")
                return
            }
            let fresh = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: storeURL))
            #expect(fresh.storeID != oldEnvelope.storeID, "a NEW store id")
            #expect(Posture.derive(legacyMode: nil, vaultHasAppleHeldCopy: nil, keyFile: fresh, enrolled: false) == .determined(.standard),
                    "the new library is born Standard")
            #expect(Posture.derive(legacyMode: nil, vaultHasAppleHeldCopy: nil, keyFile: oldEnvelope, enrolled: false) == .determined(.castle),
                    "the old library's lock is untouched")
        }
    }

    /// R13p-14 on the phone: a lock whose key auto-releases at the next
    /// open is theater, and no theater ships.
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
            #expect(!bootstrap.canLock)
            await bootstrap.lock()
            if case .locked = bootstrap.state {
                Issue.record("a lock under Auto must refuse silently")
            }
        }
    }
}

// MARK: - (g): the re-lock dial's phone reading

@Suite("13p phone — the re-lock policy (pure)")
struct MobileRelockPolicyTests {
    /// pre-13x 2a: Standard has no gate — leaving and returning lock
    /// nothing (a lock there would be theater, R13p-14).
    @Test func standardNeverLocksEitherWay() {
        let dials = ProtectionDials(relockAfterIdleMinutes: 5)
        #expect(!MobileRelockPolicy.locksOnLeaving(gate: .auto))
        #expect(!MobileRelockPolicy.locksOnReturn(gate: .auto, dials: dials, awayFor: 60 * 60))
    }

    /// Castle ALWAYS locks on leaving (decision 18 — re-lock on sleep /
    /// screen lock is always on; backgrounding IS the phone's leaving).
    @Test func leavingLocksUnderCastleAlways() {
        #expect(MobileRelockPolicy.locksOnLeaving(gate: .passphrase))
        #expect(MobileRelockPolicy.locksOnLeaving(gate: .biometric))
    }

    @Test func timeAwayIsAThresholdNotATrigger() {
        var dials = ProtectionDials(relockAfterIdleMinutes: 15)
        #expect(!MobileRelockPolicy.locksOnReturn(gate: .biometric, dials: dials, awayFor: 14 * 60))
        #expect(MobileRelockPolicy.locksOnReturn(gate: .biometric, dials: dials, awayFor: 15 * 60))
        dials.relockAfterIdleMinutes = nil
        #expect(!MobileRelockPolicy.locksOnReturn(gate: .biometric, dials: dials, awayFor: 24 * 60 * 60),
                "never means never")
    }

    /// The four values (decision 18: 5 · 10 · 30 · never), the SAME dial
    /// as the Mac's, in the copy's words.
    @Test func theAwayRowsAreTheDesignsFourValues() {
        #expect(MobileRelockPolicy.awayChoices == [5, 10, 30, nil])
        #expect(MobileRelockPolicy.awayLabel(nil) == "never")
        #expect(MobileRelockPolicy.awayLabel(10) == "10 minutes")
        #expect(ProtectionDials().relockAfterIdleMinutes == 10, "the default")
    }
}

@MainActor
@Suite("13p phone — the re-lock coordinator & the scene seam's order")
struct MobileRelockCoordinatorTests {
    private func coordinator(
        gate: StoreAtOpenMode, _ dials: ProtectionDials, clock: LockIsolatedBox<Date>,
        locks: LockIsolatedBox<Int>
    ) -> MobileRelockCoordinator {
        MobileRelockCoordinator(
            facts: { (gate, dials) },
            lock: { locks.value += 1 },
            now: { clock.value })
    }

    @Test func leavingLocksImmediatelyUnderCastle() async {
        let dials = ProtectionDials()
        let clock = LockIsolatedBox(Date(timeIntervalSince1970: 1_000))
        let locks = LockIsolatedBox(0)
        let subject = coordinator(gate: .passphrase, dials, clock: clock, locks: locks)
        await subject.didLeaveTheScreen()
        #expect(locks.value == 1)
        // A lock clears the stamp: the NEXT session must not be locked by
        // a leaving that already produced one.
        #expect(subject.leftAt == nil)
        #expect(await subject.didReturnToTheScreen() == false)
        #expect(locks.value == 1)
    }

    /// pre-13x 2a: under Castle leaving ALWAYS locks (decision 18), so the
    /// return road's threshold is exercised under Standard's silent gate
    /// (where it never fires) and directly through the policy under
    /// Castle (`MobileRelockPolicyTests`).
    @Test func aReturnUnderStandardNeverLocksWhateverTheTimeAway() async {
        let dials = ProtectionDials(relockAfterIdleMinutes: 5)
        let clock = LockIsolatedBox(Date(timeIntervalSince1970: 1_000))
        let locks = LockIsolatedBox(0)
        let subject = coordinator(gate: .auto, dials, clock: clock, locks: locks)

        await subject.didLeaveTheScreen()
        #expect(locks.value == 0, "Standard has no gate — leaving locks nothing")
        clock.value = clock.value.addingTimeInterval(6 * 60)
        #expect(await subject.didReturnToTheScreen() == false)
        #expect(locks.value == 0)
    }

    /// **THE ORDER IS THE LEG'S CORRECTNESS** (this file's own rule, and
    /// the flush's): on leaving, everything that lands her text runs to
    /// completion BEFORE the pool closes. The oracle is what the flush saw
    /// at the moment it ran — a lock that beat it would have been counted
    /// first.
    @Test func theLockLandsAfterTheWholeFlush() async {
        let order = LockIsolatedBox<[String]>([])
        let subject = MobileRelockCoordinator(
            facts: { (.passphrase, ProtectionDials()) },
            lock: { order.value.append("lock") })
        let editors = MobileLivenessAuthority()
        let work = mobileScenePhaseChanged(
            .background, editors: editors, sync: nil,
            savepoint: { _ in order.value.append("savepoint") },
            grant: .none, relock: subject)
        await work?.value
        #expect(order.value == ["lock"],
                "no editors registered here, so the flush is a no-op — but the lock still runs, and it runs at the END: \(order.value)")
    }

    /// A return that LOCKS must not first wake a sync round against the
    /// pool it is about to close.
    @Test func aReturnThatLocksDoesNotTriggerASyncRound() async {
        // Under Castle the leaving itself locks (decision 18); the return
        // then finds nothing to re-lock — the seam still awaits the
        // coordinator's answer, which is the pin's subject.
        let dials = ProtectionDials(relockAfterIdleMinutes: 5)
        let clock = LockIsolatedBox(Date(timeIntervalSince1970: 1_000))
        let locks = LockIsolatedBox(0)
        let subject = coordinator(gate: .passphrase, dials, clock: clock, locks: locks)
        await subject.didLeaveTheScreen()
        clock.value = clock.value.addingTimeInterval(10 * 60)

        // `sync` is nil here, so the pin's subject is the coordinator's
        // answer travelling through the seam at all: it locked, and the
        // seam awaited it before returning.
        let work = mobileScenePhaseChanged(
            .active, editors: MobileLivenessAuthority(), sync: nil,
            grant: .none, relock: subject)
        await work?.value
        #expect(locks.value == 1)
    }
}

// MARK: - (h) + copy: one brain, and the phone's own nouns

@Suite("13p phone — the honest copy reads as the phone's")
struct MobilePhoneProtectionCopyTests {
    /// The platform-aware interpolation, from the phone's side: the same
    /// sentences the Mac shows, with the phone's nouns.
    @Test func theSentencesNameThePhoneAndItsBiometry() {
        #expect(ProtectionCopy.deviceName == "iPhone")
        #expect(ProtectionCopy.biometryName == "Face ID")
        #expect(ProtectionCopy.postureOneLine(.castle).contains("Your iPhone's passcode can't open your library"))
        #expect(ProtectionCopy.modeLabel(.biometric) == "Ask for Face ID")
        #expect(ProtectionCopy.lobbyPrompt(.biometric) == "Unlock your library with Face ID.")
        // The one arm the Batch-4 sweep caught: it named Touch ID as a
        // LITERAL, so the phone offered a fingerprint it does not have.
        let unreadable = ProtectionCopy.message(
            for: StoreKeyEnvelopeError.unreadable("decode failed"))
        #expect(unreadable.contains("Face ID"))
        #expect(!unreadable.contains("Touch ID"))
    }

    /// pre-13x 2c: copy §5's follow notices on the phone — the SAME shared
    /// strings the Mac shows, with the phone's nouns (*this iPhone asks for
    /// Face ID*), and the Always-ask / leaving doors name Face ID.
    /// pre-13x 5a — the reconciliation's re-renders in the phone's nouns.
    @MainActor
    @Test func theReconciledStringsNameThePhone() {
        #expect(ProtectionCopy.lobbyBiometryFailed == "Face ID didn't go through — enter your encryption passphrase instead.")
        #expect(ProtectionCopy.lobbyWordsDoor == "Use your twelve words")
        #expect(ProtectionCopy.enteredCastleAfterAnotherDevice(device: "Lillian's Mac")
                .hasPrefix("Another device entered Castle first, so this iPhone picked up that device's keys instead."))
        #expect(ProtectionCopy.castleDoneBody(nil) == ProtectionCopy.enteredCastleDone)
        // pre-13x ladder round 1, F2: the three PROVISIONAL lines in the
        // phone's nouns — the hedged different-Apple-ID sentence (MAJOR-3 d),
        // Replace All Keys' Apple-key refusal (MAJOR-3 b), the could-not-back-up Done (MAJOR-2).
        #expect(ProtectionCopy.waitingDifferentAppleID
                == "This iPhone's Apple account doesn't hold the key that set up sync — if it's the same Apple account, the key may still be arriving. Enter your passphrase or twelve words once to continue now; after that this iPhone opens on its own.")
        // F3 (F2's adjudication, items 1–3): the re-drafted refusal (its
        // article rides the phone's noun), the could-not-back-up Done WITH
        // its Face ID tail, and the phone's own Castle Done on `.notKept` —
        // the phone keeps no backups, so its Done claims none.
        #expect(ProtectionCopy.replaceKeysAppleKeyUnreachable
                == "Your Apple account's key isn't reachable on this iPhone. If this iPhone is signed into the Apple account that set up sync, wait a moment and try again; if it isn't, run Replace All Keys from an iPhone that is.")
        #expect(ProtectionCopy.enteredCastleWithoutFreshBackup
                == "You're in Castle. A fresh backup could not be made just now — check your Backups folder; your earlier backups are untouched. This iPhone asks for Face ID from now on; your other devices will ask the next time they open.")
        let notKept = PostureSwitchRunner.Outcome(
            entersCastle: true, newKeyFingerprint: "fp", insuranceTurnedOff: false,
            preSwitchSnapshots: [], freshSnapshot: .notKept, reencrypted: 0, material: nil)
        #expect(ProtectionCopy.castleDoneBody(notKept)
                == "You're in Castle. Your library has a new key that your Apple account never held. This iPhone asks for Face ID from now on; your other devices will ask the next time they open.")
        #expect(!ProtectionCopy.castleDoneBody(notKept).contains("backup"), "the phone's Done claims no backup it never makes")
        // F3 (NIT-N8): the waiting tier's sentence, in the exposed nudge's place.
        #expect(ProtectionCopy.nudgeSentence(for: .waiting) == ProtectionCopy.waitingTitle + " " + ProtectionCopy.waitingBody)
        #expect(ProtectionCopy.nudgeSentence(for: .waiting).hasPrefix("Getting your key from iCloud Keychain…"))
        #expect(ProtectionCopy.message(for: RecoveryPhraseError.invalidWordCount(13))
                == "A recovery phrase is exactly 12 words — you entered 13.")
        // pre-13x 5b (ledger 66): the un-followed headline in the phone's nouns,
        // and the shared Encryption tab renders it through the one constant.
        #expect(ProtectionCopy.keysReplacedHeadline
                == "This account's keys changed since this iPhone joined. Enter your passphrase to pick up the new ones.")
        #expect(EncryptionView.keysReplacedExplanation == ProtectionCopy.keysReplacedHeadline)
    }

    @Test func theFollowNoticesNameThePhoneAndFaceID() {
        let day = ProtectionCopy.day(from: "2026-09-04T10:00:00Z")
        let moved = ProtectionCopy.followMovedToCastle(device: "Lillian's Mac", day: day)
        #expect(moved.contains("set on Lillian's Mac on \(day)"))
        #expect(moved.contains("this iPhone asks for Face ID to open your library"))
        #expect(!moved.contains("Touch ID") && !moved.contains("this Mac"))
        #expect(ProtectionCopy.followLaterSubline == "Until then this iPhone opens and reads, but doesn't sync — and what you write meanwhile stays under the old key until you pick up the new ones.")
        #expect(ProtectionCopy.connectDoneBody == "This library is connected to this account, and everything in it is uploading now.")
        // pre-13x 2d.4: the posture-mismatch follow's own sentence, in the phone's nouns.
        #expect(ProtectionCopy.followCastleStillOpensOldWay
                == "Your account is in Castle, but this iPhone still opens without asking. Enter your passphrase once to move this iPhone's key behind Face ID and give your library a fresh key.")
        #expect(ProtectionCopy.followCastleStillOpensLaterSubline == "Until then this iPhone opens and reads as before — what you write meanwhile stays under the old key until you enter your passphrase.")
        #expect(ProtectionCopy.followMovedToStandard(device: "Lillian's Mac", day: day)
                .contains("This iPhone opens silently again"))
        #expect(ProtectionCopy.alwaysAskRetiredWord(device: "Lillian's Mac", day: day)
                .contains("The old one still opens this iPhone"))
        // pre-13x 4a: the change notices in the phone's nouns.
        #expect(ProtectionCopy.passphraseChangedElsewhere(device: "Lillian's Mac", day: day)
                == "Your passphrase was changed on Lillian's Mac on \(day). Use the new one here when you can — this iPhone still takes the old one until you do.")
        #expect(ProtectionCopy.wordsRegeneratedElsewhere(device: "Lillian's Mac", day: day)
                == "Your twelve words were regenerated on Lillian's Mac on \(day). Use the new ones here when you can — this iPhone still takes the old ones until you do.")
        // pre-13x 3a: copy §2d's join face + the (d) consent in the phone's nouns.
        #expect(ProtectionCopy.joinCastleTitle == "Enter your passphrase to join sync.")
        #expect(ProtectionCopy.joinLaterLine == "Sync isn't joined on this iPhone.")
        #expect(!ProtectionCopy.joinStandardConsent.contains("Mac") && ProtectionCopy.joinStandardConsent.contains("Use Castle…"))
    }

    /// **RUN A batch A2, row 14 (17n) — the phone's twin of the floor.**
    /// The phone reaches `PassphraseSetModel` from TWO doors (the nudge's
    /// offer and the Protection sheet), so the shared model's floor is the
    /// phone's floor; the refusal sentence is the one both platforms speak.
    @MainActor
    @Test func theEncryptionPassphraseFloorAndItsSentenceAreThePhonesToo() {
        #expect(ProtectionCopy.passphraseFloor == 12)
        #expect(ProtectionCopy.passphraseTooShort
                == "Your passphrase needs at least 12 characters.")
        #expect(ProtectionCopy.passphraseSubline.hasPrefix("At least 12 characters."))
        // The tutorial's short chapter says the floor once, in the phone's
        // edition too (the same shared paragraphs).
        let saidTheFloor = ProtectionCopy.privacyLessonTwoParagraphs.filter {
            $0.contains("at least 12 characters")
        }
        #expect(saidTheFloor.count == 1, "said once: \(saidTheFloor.count)")
        #expect(try! #require(saidTheFloor.first).contains("keeps working whatever its length"),
                "and says the other half — an existing word is never refused at unlock")
    }

    /// **RUN A batch A2, row 12 (17l item 6) — the phone's twin:** the
    /// preparing line before the first pulled window, and the follow
    /// sheet's own *picking up* arm (the phone has both sheets too).
    @MainActor
    @Test func theReencryptingLinePreparesOnThePhoneToo() {
        #expect(ProtectionCopy.reencryptingLine(done: 0, total: 0)
                == "Re-encrypting your library on the server… (preparing)")
        #expect(ProtectionCopy.reencryptingLine(done: 2, total: 9)
                == "Re-encrypting your library on the server… (2 of 9)")
        #expect(ProtectionCopy.runningLine(for: .rotatingKeys, minting: false)
                == "Picking up your new keys…")
        #expect(ProtectionCopy.runningLine(for: .reencrypting(done: 0, total: 0), minting: false)
                == ProtectionCopy.reencryptingLine(done: 0, total: 0))
    }

    /// **RUN A batch A2, row 10 (17l item 3) — the phone's twin of her four
    /// ruled wordings (QUESTIONS #90's RULINGS block), in the phone's
    /// nouns.** The Mac's is `Phase13pProtectionBrainTests
    /// .herFourRuledWordingsAreWhatTheSurfacesSay`.
    @MainActor
    @Test func herFourRuledWordingsReadAsThePhones() {
        // (2) ledger 54 — the door that asks nothing says what it does.
        #expect(ProtectionCopy.followEnterDoorLabel(asksNothing: true) == "Pick Up New Keys")
        #expect(ProtectionCopy.followEnterDoorLabel(asksNothing: false) == "Enter Passphrase…")

        // (3) ledger 61 + 67 — the Done says WHY, in the phone's nouns.
        let done = ProtectionCopy.enteredCastleAfterAnotherDevice(device: "Lillian's Mac")
        #expect(done.hasPrefix("Another device entered Castle first, so this iPhone picked up that device's keys instead."))
        #expect(done.contains("Lillian's Mac showed when it entered Castle"))
        #expect(done.contains("the set to keep"))

        // (4) ledger 46 — cancel · put the account in Castle · rejoin, and
        // still never the word "Mac" on the phone (VX-110: de-capped).
        let consent = ProtectionCopy.joinStandardConsent
        #expect(consent.contains("Cancel here") && consent.contains("put the account itself in Castle")
                && consent.contains("then join again"))
        #expect(!consent.contains("ACCOUNT"))
        #expect(!consent.contains("Mac"))

        // (7) MINOR-6 — the book the phone seeds carries the website's road.
        let book = try! SampleLibrarySeeder.loadStories(for: .encryptionExplained)
        let text = try! #require(book.first { $0.title.hasPrefix("Chapter 7") }).text
        #expect(text.contains("stargazing.tech"))
    }

    /// (The 13p loss-math pins retired at pre-13x 5a with `lossLegs` /
    /// `lossMath` — §13; the posture cards' floors carry the loss story,
    /// pinned in `thePostureCopyReadsAsThePhones` and the tutorial spine.)

    /// **ITEM (h).** A phone-only library has ONE home; the copy says so
    /// rather than letting a list of same-device legs imply a second
    /// machine somewhere.
    @Test func theOneDeviceNoteNamesThePhoneAndTheSyncCaveat() {
        #expect(ProtectionCopy.oneDeviceNote.contains("this iPhone"))
        #expect(ProtectionCopy.oneDeviceNote.contains("Unless you sync"))
    }
}

// MARK: - (i): capture over a locked library

@MainActor
@Suite("13p phone — quick capture demands unlock (her ratification)")
struct MobileQuickNoteUnderLockTests {
    /// **HER RATIFIED ITEM (i)**, at its one reachable seam. The lobby
    /// makes the ordinary case structural (no shell ⇒ no box), so what
    /// remains is a re-lock landing on a box that still holds text: the
    /// mint refuses, the refusal SAYS the library is locked and names the
    /// road, and — the load-bearing half — her text stays in the box
    /// rather than being written anywhere outside the encrypted store.
    @Test func aLockedLibraryRefusesTheQuickNoteInWordsAndKeepsTheText() async throws {
        let db = try AppDatabase.inMemory()
        let bound = db.asRebindable()
        try await withDependencies {
            $0.database = bound.view
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let session = AppSession(database: bound.view)
            let box = MobileQuickNoteModel(session: session)
            box.text = "a thought I had while the phone was locking"

            bound.binding.lock()
            await box.fileOnLeaving()

            #expect(box.postID == nil, "nothing was minted into a closed store")
            #expect(box.text == "a thought I had while the phone was locking",
                    "her text is STILL IN THE BOX — never dropped, never written outside the encrypted store")
            let refusal = try #require(box.lastError)
            #expect(refusal.contains("locked"))
            #expect(refusal.contains("unlock"), "the refusal names the road")
            #expect(refusal == MobileQuickNoteCopy.refusal(StoreLockedError()))
        }
    }

    /// The control the pin above rests on: with the library OPEN the same
    /// box mints and clears exactly as it always did (so the refusal is
    /// about the lock, not about the road being broken).
    @Test func anUnlockedLibraryStillTakesTheNote() async throws {
        let db = try AppDatabase.inMemory()
        let bound = db.asRebindable()
        try await withDependencies {
            $0.database = bound.view
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(
                SeededGenerator(seed: 13))
        } operation: { @MainActor in
            let session = AppSession(database: bound.view)
            let box = MobileQuickNoteModel(session: session)
            box.text = "a thought I had while the phone was open"
            await box.fileOnLeaving()
            // The oracle is the STORE, not the model: a completed hand-off
            // lets go of the note entirely (`reset()` clears the box AND
            // its pointer), which is exactly the road the locked case
            // above must NOT take.
            let landed = try await bound.view.read { db in
                try String.fetchAll(
                    db,
                    sql: """
                        SELECT v.working_text FROM variant v
                        JOIN container_block cb ON cb.block_id = v.block_id
                        WHERE cb.deleted_at IS NULL AND v.deleted_at IS NULL
                        """)
            }
            #expect(landed == ["a thought I had while the phone was open"])
            #expect(box.lastError == nil)
            #expect(box.text.isEmpty, "a completed hand-off clears the box")
        }
    }
}

// MARK: - The one-secret hooks on the phone's composition (ladder R2-M1)

/// A raw-JSON `key_vault` PostgREST responder — the Mac suite's
/// `ScriptedVault` shape, needed here because the phone's pins drive the
/// SAME vault flows over the same no-network discipline.
private final class ScriptedVaultResponder: @unchecked Sendable {
    private let lock = NSLock()
    private var row: Data?

    var hasRow: Bool {
        lock.lock()
        defer { lock.unlock() }
        return row != nil
    }

    var load: @Sendable (URLRequest) async throws -> (Data, URLResponse) {
        { [weak self] request in
            guard let self else { throw URLError(.cancelled) }
            return self.respond(to: request)
        }
    }

    private func respond(to request: URLRequest) -> (Data, URLResponse) {
        lock.lock()
        defer { lock.unlock() }
        func response(_ status: Int, _ body: Data = Data()) -> (Data, URLResponse) {
            (body, HTTPURLResponse(
                url: request.url!, statusCode: status,
                httpVersion: "HTTP/1.1", headerFields: nil)!)
        }
        // pre-13x: the ONE vault write road is the RPC; PATCH is refused;
        // a create carries its proof hash (VaultRPCEmulation — the
        // core suites' linked ScriptedVaultServer's minimal twin).
        if let served = VaultRPCEmulation.serveUpdate(request, row: &row) {
            return response(served.status, served.body)
        }
        guard request.url?.path.hasSuffix("/rest/v1/key_vault") == true else {
            return response(404)
        }
        switch request.httpMethod {
        case "GET":
            guard let row else { return response(200, Data("[]".utf8)) }
            return response(200, Data("[".utf8) + row + Data("]".utf8))
        case "POST":
            if let refusal = VaultRPCEmulation.insertRefusal(request.httpBody) {
                return response(refusal.status, refusal.body)
            }
            if let refusal = VaultRPCEmulation.insertRefusal(request.httpBody) {
                return response(refusal.status, refusal.body)
            }
            guard row == nil else { return response(409, Data(#"{"code":"23505"}"#.utf8)) }
            row = request.httpBody
            return response(201)
        case "PATCH":
            return response(VaultRPCEmulation.patchRefused.status, VaultRPCEmulation.patchRefused.body)
        default:
            return response(405)
        }
    }
}

/// **LADDER R2-M1 — THE PHONE WIRES THE FOUR ONE-SECRET HOOKS.** Until
/// this fix `VariorumMobileApp`'s `.task` wired NONE of them while the
/// phone presented the full shared vault flows (Settings ▸ Account ▸
/// Encryption) AND its own reset door — four silent divergences against
/// R13p-4's "no second passphrase exists anywhere":
///
/// · a phone user could mint a DIFFERENT vault passphrase over a store
///   wrap (no `storePassphraseGuard`);
/// · a vault passphrase change made on the phone left the store sidecar
///   holding the RETIRED passphrase (no `onPassphraseChanged`);
/// · vault-minted twelve words opened the account but not the library
///   (no `onRecoveryPhraseLanded`);
/// · the phone's reset door re-wrapped the store and silently SKIPPED
///   the vault (no `rewrapVaultPassphrase`).
///
/// Every pin below drives `wireOneSecretHooks` — the SAME shared factory
/// production wires in the phone's `.task` (the `mobileWillLock`
/// precedent) — over a scripted world: scripted gate/custody, a
/// raw-JSON vault, an in-memory signed-in session. No Keychain, no
/// network, no prompts.
///
/// RED ON OLD (behavioral revert executed): with the factory's body
/// emptied — the pre-fix world, where the phone wires nothing — each pin
/// fails on exactly its own mechanism.
@MainActor
@Suite("13p phone — the one-secret hooks ride the phone's composition")
struct MobileOneSecretHooksTests {
    private let vaultPassphrase = "orchard-lantern-13"

    private struct World {
        let controller: ProtectionController
        let encryption: EncryptionSession
        let vault: ScriptedVaultResponder
        let client: KeyVaultClient
        let envelopeBox: ScriptedEnvelopeBox
        let backing: InMemoryStoreKeyGuardBacking
        let key: StoreKey
    }

    /// The phone's composition, scripted: the same pieces
    /// `VariorumMobileApp.task` hands the factory, minus the real
    /// Keychain/network under each.
    private func world() -> World {
        let key = StoreKey.mint()
        let backing = InMemoryStoreKeyGuardBacking(
            auto: key, biometryAvailable: true, biometricSucceeds: true)
        let envelopeBox = ScriptedEnvelopeBox(nil)
        let gate = StoreLaunchGate.scripted(
            dials: ScriptedDialsBox(ProtectionDials()), backing: backing,
            envelope: envelopeBox)
        let controller = ProtectionController(configuration: .init(
            scope: "phone-one-secret", storeURL: nil, gate: gate,
            isRealVariant: false, makeKDF: { fastKDF() }))
        let vault = ScriptedVaultResponder()
        let client = KeyVaultClient(
            configuration: KeyVaultClient.Configuration(
                projectURL: URL(string: "https://vault.test.invalid")!,
                apiKey: "publishable-test-key", deviceName: "test device"),
            sessionProvider: StaticSessionProvider(
                session: UserSession(accessToken: "token-1", userID: "user-phone")),
            load: vault.load)
        let encryption = EncryptionSession(
            store: .inMemory(), client: client, signedIn: { true })
        let auth = AuthSession(
            configuration: AuthConfiguration(
                projectURL: URL(string: "https://auth.test.invalid")!,
                apiKey: "publishable-test-key"),
            store: .inMemory(initial: AuthTokens(
                accessToken: "token-1", refreshToken: "refresh-1",
                expiresAt: Date(timeIntervalSinceNow: 86_400),
                userID: "user-phone", email: "phone@test.invalid")),
            http: { _ in throw URLError(.notConnectedToInternet) })

        // Production's own wiring: the factory the phone's `.task` calls.
        wireOneSecretHooks(
            protection: controller, encryption: encryption,
            keyVault: client, auth: auth)
        return World(
            controller: controller, encryption: encryption, vault: vault,
            client: client, envelopeBox: envelopeBox, backing: backing, key: key)
    }

    /// pre-13x 3a: the factory wires the enroll/landing hooks on the phone
    /// too (`enrollFacts`, `readAppleKey`, `libraryPosture`,
    /// `onVaultMaterialLanded`, the controller's `landEnrollment`), and the
    /// shared session routes a Standard-born library's Castle join to the
    /// wired act — the phone's compiled copy of the ONE brain.
    @Test func theFactoryWiresTheEnrollHooksAndTheJoinRoutesOnThePhone() async throws {
        let w = world()
        #expect(w.encryption.enrollFacts != nil && w.encryption.readAppleKey != nil && w.encryption.libraryPosture != nil)
        #expect(w.encryption.storeTie != nil && w.encryption.readOrMintAppleKey != nil, "the setup ceremony's tie is wired on the phone too")
        #expect(w.encryption.onVaultMaterialLanded != nil && w.controller.landEnrollment != nil)
        #expect(w.encryption.libraryPosture?() == .standard, "a fresh silent library reads Standard by its own rule")
        let joins = LockIsolated<[String?]>([])
        w.encryption.enrollFacts = { EnrollFacts(accountPosture: .castle, libraryPosture: .standard, appleState: .notApplicable) }
        w.encryption.joinCastleAct = { passphrase, _ in joins.withValue { $0.append(passphrase) } }
        await w.encryption.enroll(passphrase: "orchard-lantern-13")
        #expect(joins.value == ["orchard-lantern-13"], "the Castle join's road, with the typed passphrase")
        w.encryption.declineStandardJoin()
        #expect(w.encryption.declinedStandardJoin)
    }

    /// **The GUARD (pin c):** a store-passphrase mismatch refuses vault
    /// setUp with the one-secret sentence, and mints NO vault row; the
    /// store's own passphrase sets up fine.
    @Test func vaultSetupRefusesAPassphraseTheStoreWrapDoesNotOpen() async throws {
        let w = world()
        #expect(await w.controller.setPassphrase("store-sesame") == nil)

        await w.encryption.setUp(passphrase: "a-different-one")
        #expect(w.encryption.lastError == EncryptionSession.oneSecretMismatchMessage,
                "the refusal is the one-secret sentence, on the phone too")
        #expect(!w.vault.hasRow, "nothing was minted under the refused passphrase")

        await w.encryption.setUp(passphrase: "store-sesame")
        #expect(w.encryption.lastError == nil)
        #expect(w.vault.hasRow, "the store's own passphrase is the one that serves both")
    }

    /// **The FOLLOW (pin a):** a vault passphrase change made on the
    /// phone re-wraps the store sidecar — the retired passphrase stops
    /// unwrapping, the new one takes over. Pre-fix, the sidecar kept the
    /// retired passphrase.
    @Test func aVaultPassphraseChangeOnThePhoneReWrapsTheStoreSidecar() async throws {
        let w = world()
        #expect(await w.controller.setPassphrase(vaultPassphrase) == nil)
        await w.encryption.setUp(passphrase: vaultPassphrase)
        #expect(w.encryption.lastError == nil)

        await w.encryption.changePassphrase(
            authorization: .passphrase(vaultPassphrase),
            newPassphrase: "winter-harbor-7")
        #expect(w.encryption.lastError == nil)

        let envelope = try #require(w.envelopeBox.value)
        #expect(try envelope.unwrapKey(passphrase: "winter-harbor-7") == w.key,
                "the store wrap FOLLOWED the vault's change — one secret, kept")
        // pre-13x 3b (§3.6): under the VAULT's new descriptor — one derivation.
        let vaultKDF = try #require(try await w.client.fetchVault()).format.kdf
        #expect(envelope.passphrase?.kdf == vaultKDF && envelope.vaultKDF == vaultKDF,
                "the store's copy follows under the vault's own descriptor — the lobby derives once")
        #expect(throws: StoreKeyEnvelopeError.wrongPassphrase) {
            _ = try envelope.unwrapKey(passphrase: self.vaultPassphrase)
        }
    }

    /// **The PHRASE (the fourth mechanism):** the vault's twelve words
    /// land on the store envelope too, so the one phrase opens the
    /// library as well as the account — on the phone's composition.
    /// (pre-13x 3a: the SETUP lands the words itself — a vault is never
    /// born without its recovery wrap — so the words the setup used are
    /// the ones proven here, and a second landing without `allowReplace`
    /// is refused as the deliberate step it is.)
    @Test func vaultMintedWordsOpenTheLibraryTooOnThePhone() async throws {
        let w = world()
        #expect(await w.controller.setPassphrase(vaultPassphrase) == nil)
        let words = await w.encryption.setUp(passphrase: vaultPassphrase)
        #expect(w.encryption.lastError == nil)
        #expect(words.count == 12)

        let envelope = try #require(w.envelopeBox.value)
        #expect(try envelope.unwrapKey(recoveryWords: words) == w.key,
                "the vault's twelve words unwrap the STORE key too")

        let second = try #require(w.encryption.generatePhrase())
        await w.encryption.landRecoveryWrap(confirmedWords: second, allowReplace: false)
        #expect(w.encryption.lastError != nil, "replacing the setup's words is a deliberate step (Regenerate), never a quiet overwrite")
    }

    /// **The RESET's vault half (pin b, positive arm):** a phone reset
    /// with a wired vault moves the VAULT to the new passphrase too —
    /// the old one stops opening the account. Pre-fix, the reset
    /// re-wrapped the store and skipped the vault entirely.
    @Test func aPhoneResetMovesTheVaultToTheNewPassphraseToo() async throws {
        let w = world()
        #expect(await w.controller.setPassphrase(vaultPassphrase) == nil)
        await w.encryption.setUp(passphrase: vaultPassphrase)
        #expect(w.encryption.lastError == nil)

        // pre-13x 3b: the reset door MERGED into change passphrase's forgot
        // road — the session's `rewrapPassphrase` from the HELD material is
        // the act (the phone's compiled copy of the shared road).
        let refusal = await w.encryption.rewrapPassphrase(newPassphrase: "fresh-north-22")
        #expect(refusal == nil, "the reset lands: \(refusal ?? "")")

        // The VAULT moved: the new passphrase unwraps it, the retired one
        // refuses — verified by the real enrollment unwrap.
        let enrollment = VaultEnrollment(client: w.client)
        _ = try await enrollment.enroll(passphrase: "fresh-north-22")
        await #expect(throws: VaultEnrollmentError.wrongPassphrase) {
            _ = try await enrollment.enroll(passphrase: self.vaultPassphrase)
        }
        // …and the STORE moved with it (the door's own half, unchanged).
        let envelope = try #require(w.envelopeBox.value)
        #expect(try envelope.unwrapKey(passphrase: "fresh-north-22") == w.key)
    }

    /// **The RESET's vault half (pin b, refuse-whole arm):** when the
    /// vault half CANNOT run (custody forgotten — no held material), the
    /// whole reset refuses and the store wrap stays untouched. Pre-fix,
    /// the store half ran anyway and the two secrets diverged.
    @Test func aPhoneResetRefusesWholeWhenTheVaultHalfCannotRun() async throws {
        let w = world()
        #expect(await w.controller.setPassphrase(vaultPassphrase) == nil)
        await w.encryption.setUp(passphrase: vaultPassphrase)
        #expect(w.encryption.lastError == nil)
        await w.encryption.forgetDeviceKeys()

        let refusal = await w.encryption.rewrapPassphrase(newPassphrase: "fresh-north-22")
        #expect(refusal?.contains("keys are locked") == true,
                "the reset refuses WHOLE rather than diverging: \(refusal ?? "nil")")

        let envelope = try #require(w.envelopeBox.value)
        #expect(try envelope.unwrapKey(passphrase: vaultPassphrase) == w.key,
                "the store wrap is untouched — the old passphrase still opens")
        #expect(throws: StoreKeyEnvelopeError.wrongPassphrase) {
            _ = try envelope.unwrapKey(passphrase: "fresh-north-22")
        }
    }
}

// MARK: - pre-13x 2c: THE FOLLOW's verdict on the phone (§7)

@MainActor
@Suite("pre-13x 2c phone — the follow is owed from the vault's word, spoken with the phone's nouns")
struct MobileFollowDetectionTests {
    /// The SAME shared reconcile the Mac pins (`Phase13pControllerTests`),
    /// composed the phone's way: a Castle phone whose account replaced its
    /// keys elsewhere owes the follow; the notice carries *[device] on
    /// [day]* (decision 34) in the phone's words; *Later* leaves the
    /// persistent banner and the key doors' sentence; the landing clears it.
    @Test func aRotatedVaultOwesTheFollowOnThePhoneAndLaterLeavesTheBanner() async throws {
        let key = StoreKey.mint()
        let backing = InMemoryStoreKeyGuardBacking(
            gated: key, biometryAvailable: true, biometricSucceeds: true)
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: "sesame", kdf: fastKDF())
        let gate = StoreLaunchGate.scripted(
            dials: ScriptedDialsBox(ProtectionDials()), backing: backing,
            envelope: ScriptedEnvelopeBox(envelope))
        let session = SyncCustodySession()
        session.hold(SyncCustodyRecord(deviceID: "phone-1", material: DeviceKeyMaterial(
            masterKey: Data(repeating: 0, count: 32),
            corpusKey: Data(repeating: 1, count: 32), corpusKeyID: "corpus-old",
            journalBridgeKey: Data(repeating: 2, count: 32), journalBridgeKeyID: "bridge")))
        let controller = ProtectionController(configuration: .init(
            scope: "phone-follow", storeURL: nil, gate: gate,
            isRealVariant: false, makeKDF: { fastKDF() },
            syncCustodySession: session))
        controller.adoptResident(key)
        #expect(controller.posture == .castle)
        controller.foreignOwner = { _ in false }
        controller.readVaultPosture = {
            VaultPostureReading(
                hasAppleHeldCopy: false, appleKeyID: nil, passphraseKDF: fastKDF(), hasPassphraseWrap: true,
                corpusKeyID: "corpus-new", updatedAt: "2026-09-04T10:00:00Z",
                updatedByDevice: "Lillian's Mac", signedInUserID: "user-phone", hasRecoveryWrap: true)
        }
        await controller.reconcile()
        let owed = try #require(controller.followNotice)
        #expect(owed.kind == .keysReplaced, "a Castle-shaped phone whose keys were replaced elsewhere")
        #expect(owed.body == "Your keys were replaced on Lillian's Mac on \(owed.day). Enter your passphrase once to pick up the new ones.")
        #expect(controller.notice == .follow(owed))
        #expect(controller.followPending)
        controller.deferFollow()
        #expect(controller.notice == .followWaiting(owed))
        controller.followLanded()
        #expect(!controller.followPending)
    }

    /// pre-13x 4a (copy §5's first two lines; ledger 33 · 53): the SAME
    /// shared reconcile composed the phone's way — a Castle phone, material
    /// in hand, learns at ready that the passphrase was changed elsewhere
    /// (its key file's recorded descriptor ≠ the vault's) and speaks copy
    /// §5's sentence in the phone's nouns; never a follow (`followPending`
    /// false — sync keeps running); the dismiss is per open; the words twin
    /// rides the recovery-wrap digest; the landing clears it.
    @Test func aPassphraseChangeElsewhereSpeaksTheChangeNoticeOnThePhoneAndSyncKeepsRunning() async throws {
        let key = StoreKey.mint()
        let master = SymmetricKey(data: Data(repeating: 0, count: 32))
        let oldKDF = fastKDF()
        let newKDF = fastKDF()
        let backing = InMemoryStoreKeyGuardBacking(
            gated: key, biometryAvailable: true, biometricSucceeds: true)
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: "sesame", kdf: oldKDF)
        try envelope.setMasterWrappedCopy(key: key, under: master)
        try envelope.recordVaultReconciliation(kdf: oldKDF, corpusKeyID: "corpus-old", recoveryWrapDigest: "d1")
        let box = ScriptedEnvelopeBox(envelope)
        let gate = StoreLaunchGate.scripted(
            dials: ScriptedDialsBox(ProtectionDials()), backing: backing, envelope: box)
        let session = SyncCustodySession()
        session.hold(SyncCustodyRecord(deviceID: "phone-1", material: DeviceKeyMaterial(
            masterKey: master.withUnsafeBytes { Data($0) },
            corpusKey: Data(repeating: 1, count: 32), corpusKeyID: "corpus-old",
            journalBridgeKey: Data(repeating: 2, count: 32), journalBridgeKeyID: "bridge")))
        let controller = ProtectionController(configuration: .init(
            scope: "phone-change", storeURL: nil, gate: gate,
            isRealVariant: false, makeKDF: { fastKDF() },
            storeID: { [id = envelope.storeID] in id },
            syncCustodySession: session))
        controller.adoptResident(key)
        #expect(controller.posture == .castle)
        controller.foreignOwner = { _ in false }
        let reading: @Sendable (PassphraseKDF.Descriptor, String?) -> VaultPostureReading = { kdf, digest in
            VaultPostureReading(
                hasAppleHeldCopy: false, appleKeyID: nil, passphraseKDF: kdf, hasPassphraseWrap: true,
                corpusKeyID: "corpus-old", updatedAt: "2026-09-04T10:00:00Z",
                updatedByDevice: "Lillian's Mac", signedInUserID: "user-phone", hasRecoveryWrap: true,
                recoveryWrapDigest: digest)
        }
        controller.readVaultPosture = { reading(newKDF, "d1") }
        await controller.reconcile()
        let change = try #require(controller.changeNotice)
        #expect(change.kind == .passphraseChangedElsewhere)
        #expect(change.body == "Your passphrase was changed on Lillian's Mac on \(change.day). Use the new one here when you can — this iPhone still takes the old one until you do.")
        #expect(controller.notice == .changedElsewhere(change))
        #expect(!controller.followPending && controller.followNotice == nil, "sync keeps running — a convenience change")
        controller.dismissChangeNotice()
        #expect(controller.notice != .changedElsewhere(change))
        controller.resetPerOpenDeferrals()
        controller.refreshNotices()
        #expect(controller.notice == .changedElsewhere(change), "per open")
        // The landing under the vault's descriptor clears it.
        #expect(await controller.reconcilePassphraseWrap(
            passphrase: "the new word 12", vaultKDF: newKDF, corpusKeyID: "corpus-old", recoveryWrapDigest: "d1") == nil)
        controller.changeNoticeLanded()
        await controller.reconcile()
        #expect(controller.changeNotice == nil)
        #expect(box.value?.passphrase?.kdf == newKDF && box.value?.vaultKDF == newKDF)
        // The words twin.
        controller.readVaultPosture = { reading(newKDF, "d2") }
        await controller.reconcile()
        let regenerated = try #require(controller.changeNotice)
        #expect(regenerated.kind == .wordsRegeneratedElsewhere)
        #expect(regenerated.body == "Your twelve words were regenerated on Lillian's Mac on \(regenerated.day). Use the new ones here when you can — this iPhone still takes the old ones until you do.")
        #expect(await controller.landRecoveryWrap(words: try RecoveryPhrase.generate(), recoveryWrapDigest: "d2") == nil)
        controller.changeNoticeLanded()
        await controller.reconcile()
        #expect(controller.changeNotice == nil && box.value?.vaultRecoveryWrapDigest == "d2")
    }
}


// MARK: - pre-13x 2d: THE WINDOW's PHONE, REPLAYED (decision 35 + the posture-mismatch follow)

/// A transport that carries nothing — the no-rotation follow never touches
/// the mirror (the drill asserts it).
private actor InertTransport: SyncTransport, SyncRotationTransport {
    private(set) var touched = 0
    /// pre-13x 3a (ledger 43): the `for_device` every pull carried — the
    /// identity assertion reads it before and after the follow.
    private(set) var pulledDeviceIDs: [String?] = []
    /// 13y UNIT B: the challenge roads — this fake never verifies proofs,
    /// so the mint is a bare nonce and enrollment is a silent yes
    /// (uncounted round plumbing, like `schemaVersion`).
    func fetchChallenges(_ count: Int) async throws -> [String] {
        (0..<max(count, 1)).map { _ in Data((0..<32).map { _ in UInt8.random(in: 0...255) }).base64EncodedString() }
    }
    func enrollKeyProof(legacyProof: String, macKey: String, activeKeyID: String) async throws {}
    func push(_ batch: [SyncRow], activeKeyID: String, keyProof: SyncKeyProof) async throws -> [SyncPushOutcome] { touched += 1; return [] }
    func pull(since: Int64, limit: Int, activeKeyID: String, keyProof: SyncKeyProof, deviceID: String?) async throws -> [SyncPulledRow] {
        touched += 1
        pulledDeviceIDs.append(deviceID)
        return []
    }
    func schemaVersion() async throws -> Int { SyncSchema.lockstepVersion }
    func reencrypt(_ rows: [SyncRow], activeKeyID: String, keyProof: SyncKeyProof) async throws -> [SyncReencryptOutcome] { touched += 1; return [] }
    // 13y (`SyncRotationTransport`): the served horizon — counted as a
    // touch like every other door of this inert transport.
    func visibilityHorizonMillis() async throws -> Int64 { touched += 1; return 2000 }
}

/// The sync record's custody leaves, recorded — the Mac suite's
/// `RecordingSyncLeaves`, on the phone's compiled copy of the shared brain.
private final class PhoneSyncLeaves: @unchecked Sendable {
    private let lock = NSLock()
    private var plain: SyncCustodyRecord?
    private var gated: SyncCustodyRecord?
    var plainRecord: SyncCustodyRecord? { lock.lock(); defer { lock.unlock() }; return plain }
    var gatedRecord: SyncCustodyRecord? { lock.lock(); defer { lock.unlock() }; return gated }
    var leaves: E2EECustodyLeaves {
        E2EECustodyLeaves(
            saveGated: { [self] in lock.lock(); defer { lock.unlock() }; gated = $0; return true },
            savePlain: { [self] in lock.lock(); defer { lock.unlock() }; plain = $0; return true },
            loadPlain: { [self] in lock.lock(); defer { lock.unlock() }; return plain },
            gatedExists: { [self] in lock.lock(); defer { lock.unlock() }; return gated != nil },
            deletePlain: { [self] in lock.lock(); defer { lock.unlock() }; plain = nil; return true },
            deleteGated: { [self] in lock.lock(); defer { lock.unlock() }; gated = nil; return true })
    }
}

/// THE REPLAY DRILL (the BATCH 2d gate): her phone's EXACT state at the
/// window — a real keyed store, a format-1 key file holding ONLY
/// `formatVersion` + `storeID` (79 B on her phone), the raw key in the
/// SILENT item, a restored session, the migration undone, the vault
/// UNREACHABLE at ready — through the phone's own bootstrap (the test
/// opener over the real file; the migration leaves injected, recording;
/// the real controller). Pass 1, decision 35: the key file's bytes before
/// == after, no `apple` copy, no custody move, the migration stopped
/// undone, the library open. Then her phone as the WINDOW's build left it
/// (the pre-fix Apple arm's `apple` + `appleKeyID`, her passphrase copy,
/// the plain sync record, the migration marked done) with the vault
/// readable and CASTLE: the posture-mismatch follow is owed, she types the
/// passphrase once, and — through the real runner over the bootstrap's
/// re-key road and the controller's real custody move — the library is
/// re-keyed, custody sits behind Face ID (both items), a new key file
/// carries NO `apple` copy and the vault's descriptor, the old key file is
/// gone, the vault and the mirror untouched. RED ON OLD: pass 1 wrote the
/// Apple copy of the phone's library key into the key file (the window's
/// finding); pass 2 owed no follow (the key ids never changed).
@MainActor
@Suite("pre-13x 2d phone — the window's phone replayed: indeterminate writes nothing; the mismatch follow repairs it", .serialized)
struct MobileWindowReplayTests {
    /// The date/uuid dependencies the app session reads at the re-key's
    /// reopen (the shared suite's `withDeps`, restated: it is private).
    private func withDeps<T>(_ body: @MainActor () async throws -> T) async rethrows -> T {
        try await withDependencies {
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.uuid = .incrementing
        } operation: { @MainActor in
            try await body()
        }
    }

    @Test func herPhonesExactStateWritesNothingWhileTheVaultIsUnreachableAndThenFollowsIntoCastle() async throws {
        try await withDeps { try await replay() }
    }

    private func replay() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("Variorum/variorum.sqlite")
        try FileManager.default.createDirectory(at: storeURL.deletingLastPathComponent(), withIntermediateDirectories: true)

        // ————— HER PHONE AT THE WINDOW —————
        let phoneKey = StoreKey.mint()
        let seededDeviceID = "4D871175-CFBA-4E6A-9D3B-0000ABCDEF01"
        do {
            let store = try AppDatabase.onDisk(url: storeURL, key: phoneKey)
            try await store.write { db in
                try db.execute(
                    sql: "INSERT INTO container (id, kind, title, created_at, updated_at) VALUES (?, 'post', ?, ?, ?)",
                    arguments: ["phone-note", "typed in bed", "2026-09-05T00:00:00Z", "2026-09-05T00:00:00Z"])
                // pre-13x 3a (ledger 43): the 13j engine's identity row — the
                // UPPERCASE `UUID().uuidString` mint the mirror's
                // `device_cursor` knows her phone by.
                try db.execute(
                    sql: "INSERT INTO sync_state (key, value) VALUES ('device_id', ?)",
                    arguments: [seededDeviceID])
            }
            store.asRebindable().binding.lock()
        }
        // The 13p key file: format 1, ONLY formatVersion + storeID.
        let storeID = "e6194a17-c198-3ca5-b0d5-2d2d2d2d2d2d"
        let legacyURL = StoreKeyEnvelope.legacyURL(besideStore: storeURL)
        let stubBytes = Data("{\n  \"formatVersion\" : 1,\n  \"storeID\" : \"\(storeID)\"\n}".utf8)
        try stubBytes.write(to: legacyURL)
        let stub = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: storeURL))
        #expect(stub.formatVersion == 1 && stub.passphrase == nil && stub.recovery == nil && stub.apple == nil && stub.master == nil)
        // The raw key in the SILENT item; Face ID exists; A readable — the
        // pre-fix arm WOULD land.
        let backing = InMemoryStoreKeyGuardBacking(auto: phoneKey, biometryAvailable: true, biometricSucceeds: true)
        let apple = AppleKey.mint()
        let appleBacking = InMemoryAppleKeyBacking(key: apple)
        let dials = ScriptedDialsBox(ProtectionDials())
        let syncLeaves = PhoneSyncLeaves()
        let session = SyncCustodySession()
        let syncPresent = LockIsolated(false)
        let gate = StoreLaunchGate(
            dials: { _, id in dials.dials(for: id) },
            saveDials: { new, _, id in dials.save(new, for: id) },
            legacyMode: { _, _ in nil },
            retireLegacyDials: { _, id in dials.retireLegacy(for: id) },
            guardFor: { _ in StoreKeyGuard.inMemory(backing: backing) },
            appleKeyFor: { _ in AppleKeyLeaves.inMemory(backing: appleBacking) },
            loadEnvelope: { try StoreKeyEnvelope.loadCurrent(besideStore: $0) },
            saveEnvelope: { try $0.write(at: $0.preferredURL(besideStore: $1)) },
            setAsideEnvelope: { _ in },
            stamp: { _, _ in nil },
            setStamp: { _, _, _ in },
            syncCustodyPresent: { _, _ in syncPresent.value })
        let currentKey = LockIsolated(phoneKey)
        let bootstrap = AppBootstrap(
            testOpener: {
                let candidate = currentKey.value
                let key = StoreEncryptionMigration.opens(storeURL, key: candidate) ? candidate : phoneKey
                return Result { try AppDatabase.onDisk(url: storeURL, key: key) }
                    .mapError { AppDatabase.StoreOpenError(storePath: storeURL.path, reason: String(describing: $0)) }
            },
            gate: gate, testPresence: .encryptedOrUnknown, testStoreURL: storeURL,
            syncCustodyLeaves: { _ in syncLeaves.leaves }, syncCustodySession: session)
        let protection = bootstrap.protection
        protection.isSignedIn = { true }              // the restored session
        protection.readVaultPosture = { nil }          // the vault UNREACHABLE at this ready
        let done = LockIsolated(false)
        let confirmPending = LockIsolated(false)
        let migrationLog = LockIsolated<[String]>([])
        bootstrap.makeMigrationLeaves = { database, id in
            ProtectionMigration.Leaves(
                isDone: { done.value }, markDone: { done.setValue(true) },
                isConfirmPending: { confirmPending.value }, setConfirmPending: { confirmPending.setValue($0) },
                legacyPlainMaterial: { nil }, legacyGatedMaterial: { nil },
                deleteLegacyItems: { false }, retireOptIn: {},
                syncLeaves: syncLeaves.leaves, session: session,
                // pre-13x 3a: the REAL row — leg 1's carry reads and deletes it.
                readDeviceIDRow: {
                    try? await database.read { db in
                        try String.fetchOne(db, sql: "SELECT value FROM sync_state WHERE key = 'device_id'")
                    }
                },
                deleteDeviceIDRow: {
                    _ = try? await database.write { db in
                        try db.execute(sql: "DELETE FROM sync_state WHERE key = 'device_id'")
                    }
                },
                loadLegacyEscrow: { _ in nil }, removeLegacyEscrow: { _ in false },
                retireDialKeys: { dials.retireLegacy(for: id) },
                setAlwaysAsk: { on in var d = dials.dials(for: id); d.alwaysAsk = on; dials.save(d, for: id) },
                alignCustody: { target in await protection.moveCustodyChanged(to: target) },
                readEnvelope: { gate.readEnvelope(storeURL).envelope },
                saveEnvelope: { try gate.saveEnvelope($0, storeURL) },
                log: { line in migrationLog.withValue { $0.append(line) } })
        }
        await bootstrap.awaitOpen()
        guard case .ready(let appSession) = bootstrap.state else {
            Issue.record("expected .ready, got \(bootstrap.state)")
            return
        }
        await bootstrap.awaitReadyHousekeeping()

        // ————— PASS 1: indeterminate writes NOTHING —————
        let report = try #require(bootstrap.lastMigrationReport)
        #expect(try Data(contentsOf: legacyURL) == stubBytes, "the key file's bytes before == after")
        #expect(StoreKeyEnvelope.keyFileURLs(besideStore: storeURL) == [legacyURL], "no fingerprint-named file appeared — no Apple copy")
        #expect(!report.dialsRetired && report.custodyAligned == nil && !report.masterCopyWritten && !done.value,
                "the migration stopped before leg 3, UNDONE: \(report.lines)")
        #expect(report.lines.contains { $0.contains("indeterminate") })
        #expect(protection.postureIndeterminate && protection.effectiveGate == .auto, "opens through the custody it has")
        #expect(backing.auto == phoneKey && backing.gated == nil, "no custody move")
        #expect(protection.appleKeyVerified == nil, "the Apple arm never ran")
        #expect(protection.notice == nil, "no nudge, no confirm, no follow")
        // pre-13x 3a (ledger 43): leg 1 carried the 13j identity into the
        // identity-only item and deleted the row — BEFORE the indeterminate
        // stop (the carry is leg 1's; legs 3–6 are what wait).
        #expect(syncLeaves.plainRecord == SyncCustodyRecord(deviceID: seededDeviceID, material: nil),
                "the identity-only item carries the seeded uppercase id: \(String(describing: syncLeaves.plainRecord))")
        let rowAfterPass1 = try await appSession.database.read { db in
            try String.fetchOne(db, sql: "SELECT value FROM sync_state WHERE key = 'device_id'")
        }
        #expect(rowAfterPass1 == nil, "the row is gone")
        #expect(report.lines.contains { $0.contains("identity carried from sync_state") }, "\(report.lines)")
        let names1 = StoreKeyEnvelope.keyFileURLs(besideStore: storeURL).map(\.lastPathComponent)
        print("2d REPLAY| PASS 1 (a session, no custody, the vault unreachable): key file \(stubBytes.count) B before == after; files beside the store: \(names1); custody silent, unmoved; migration: \(report.lines.last ?? "?")")

        // ————— HER PHONE AS THE WINDOW's BUILD LEFT IT —————
        // She typed the passphrase (the Encryption tab's enroll): the vault's
        // material in the SILENT sync item, her passphrase copy in the key
        // file; the pre-fix Apple arm's `apple` + `appleKeyID`; the migration
        // marked done by that build.
        let vault = ScriptedVaultResponder()
        let client = KeyVaultClient(
            configuration: KeyVaultClient.Configuration(
                projectURL: URL(string: "https://vault.2d.invalid")!, apiKey: "publishable-test-key", deviceName: "test device"),
            sessionProvider: StaticSessionProvider(session: UserSession(accessToken: "token-2d", userID: "user-phone")),
            load: vault.load)
        let passphrase = "orchard-lantern-13"
        let material = try await VaultEnrollment(client: client).setUp(passphrase: passphrase)
        let vaultBefore = try #require(try await client.fetchVault())
        #expect(vaultBefore.format.masterWrappedByAppleHeld == nil, "her account: CASTLE-shaped")
        // pre-13x 3a: her Encryption-tab enroll saved through the custody
        // RULE (`DeviceKeyStore.custody` — what `keychain` composes over the
        // real Keychain), which keeps the carried identity; the drill's
        // custody store is THAT rule over the recording leaves, and the
        // runner below rides the same store.
        let keyStore = DeviceKeyStore.custody(
            leaves: { syncLeaves.leaves },
            shape: { syncLeaves.gatedRecord != nil ? .biometric : .silent },
            session: session)
        #expect(keyStore.save(material))
        #expect(syncLeaves.plainRecord?.deviceID == seededDeviceID, "the enroll KEPT the carried id — no fresh mint")
        #expect(try DeviceKeySyncProvider(store: keyStore).deviceIdentity() == seededDeviceID)
        syncPresent.setValue(true)
        #expect(await protection.setPassphrase(passphrase) == nil)
        var asLeft = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: storeURL))
        try asLeft.setAppleWrappedCopy(key: phoneKey, under: apple.symmetricKey, appleKeyID: apple.id)
        try asLeft.write(at: asLeft.preferredURL(besideStore: storeURL))
        let oldURL = asLeft.preferredURL(besideStore: storeURL)
        #expect(asLeft.apple != nil && asLeft.passphrase != nil && asLeft.master == nil && asLeft.vaultCorpusKeyID == nil,
                "the window's phone key file: apple + appleKeyID + passphrase, no master, no descriptor")
        #expect(StoreEncryptionMigration.opens(storeURL, key: try asLeft.unwrapKey(apple: apple.symmetricKey)),
                "the exposure: A opens her phone's library through the copy the pre-fix arm wrote")
        done.setValue(true)
        protection.readVaultPosture = { [client] in
            guard let fetched = try? await client.fetchVault() else { return nil }
            return VaultPostureReading(
                hasAppleHeldCopy: fetched.format.masterWrappedByAppleHeld != nil,
                appleKeyID: fetched.format.appleKeyID, passphraseKDF: fetched.format.kdf,
                hasPassphraseWrap: true, corpusKeyID: fetched.format.classKey(for: .corpus)?.keyID,
                updatedAt: fetched.updatedAt, updatedByDevice: fetched.format.updatedByDevice,
                signedInUserID: "user-phone", hasRecoveryWrap: false, format: fetched.format)
        }
        protection.foreignOwner = { _ in false }
        // The runner at the phone's root — the SAME shared composition,
        // over the bootstrap's real re-key road and the controller's real
        // custody move; an inert mirror (nothing to re-encrypt).
        let transport = InertTransport()
        // One pull BEFORE the follow: the `for_device` it carries is the seeded id.
        try await withDependencies { $0.database = appSession.database } operation: {
            _ = try await SyncEngine(transport: transport, keyProvider: DeviceKeySyncProvider(store: keyStore)).pull()
        }
        let pulledBefore = await transport.pulledDeviceIDs
        #expect(pulledBefore == [seededDeviceID])
        let runnerLog = LockIsolated<[String]>([])
        let syncCalls = LockIsolated<[String]>([])
        let runner = PostureSwitchRunner(leaves: PostureSwitchRunner.Leaves(
            scope: AppDatabase.StoreVariant.dev.rawValue, storeURL: storeURL, database: appSession.database, gate: gate,
            keyStore: keyStore, keyProvider: DeviceKeySyncProvider(store: keyStore),
            vault: client, transport: transport, signedIn: { true },
            appleKeys: AppleKeyLeaves.inMemory(backing: appleBacking),
            libraryKeyInHand: { protection.keyInHand() },
            posture: { protection.posture },
            alwaysAsk: { protection.dials.alwaysAsk },
            biometryAvailable: { protection.biometryAvailable },
            moveCustody: { target in await protection.moveCustody(to: target) },
            rekeyLibrary: { old, new, work in
                currentKey.setValue(new)
                try await bootstrap.rekeyLibrary(from: old, to: new, work: work)
            },
            pauseSync: { syncCalls.withValue { $0.append("pause") } },
            resumeSync: { syncCalls.withValue { $0.append("resume") } },
            takeSnapshot: { .notKept },
            preSwitchSnapshots: { _ in [] },
            deleteSnapshotPairs: { _ in 0 },
            defaults: { UserDefaults(suiteName: "io.lduarte.variorum.tests.2d.\(UUID().uuidString)")! },
            reconcile: { await protection.reconcile() },
            now: { Date() },
            log: { line in runnerLog.withValue { $0.append(line) } }))
        protection.switchRunner = runner

        // ————— PASS 2: the next ready with the vault readable — the follow —————
        await bootstrap.runReadyHousekeeping()
        let owed = try #require(protection.followNotice)
        #expect(owed.kind == .castleStillOpensOldWay, "Castle in the vault, silent custody — the posture mismatch")
        #expect(owed.body == "Your account is in Castle, but this iPhone still opens without asking. Enter your passphrase once to move this iPhone's key behind Face ID and give your library a fresh key.")
        #expect(owed.corpusKeyID == material.corpusKeyID, "the keys unchanged")
        #expect(owed.device == "test device")
        #expect(protection.notice == .follow(owed) && protection.followPending)
        #expect(protection.posture == .castle && !protection.postureIndeterminate)
        #expect(try Data(contentsOf: oldURL) == (try Data(contentsOf: oldURL)), "the verdict writes nothing")
        #expect(backing.auto == phoneKey && backing.gated == nil, "custody untouched until she types")
        print("2d REPLAY| PASS 2 (the vault readable, CASTLE): the follow owed — \(owed.body)")

        protection.openFollow()
        let model = try #require(protection.activeFollow)
        model.choosePassphrase()
        await model.enter(passphrase: "not-her-passphrase")
        #expect(model.lastError == ProtectionCopy.passphraseNotTheLibrarys && model.phase == .askPassphrase,
                "a wrong word writes nothing and asks again")
        #expect(FileManager.default.fileExists(atPath: oldURL.path) && backing.gated == nil)

        await model.enter(passphrase: passphrase)
        #expect(model.phase == .done(insuranceOff: false, hasOffer: false), "\(model.phase) — \(runnerLog.value)")
        await bootstrap.awaitReadyHousekeeping()
        guard case .ready(let reopened) = bootstrap.state else {
            Issue.record("expected .ready after the re-key, got \(bootstrap.state)")
            return
        }

        // Face ID custody, both items.
        let newKey = try #require(backing.gated)
        #expect(newKey != phoneKey, "a NEW library key")
        #expect(backing.auto == nil, "the silent item is gone")
        #expect(syncLeaves.gatedRecord?.material?.corpusKeyID == material.corpusKeyID, "the sync record behind Face ID — the keys unchanged")
        #expect(syncLeaves.plainRecord?.material == nil && syncLeaves.plainRecord?.deviceID == seededDeviceID, "the plain item keeps only the identity — the CARRIED one")
        #expect(syncLeaves.gatedRecord?.deviceID == seededDeviceID, "the gated record carries the same identity (the follow's own carry)")
        #expect(try DeviceKeySyncProvider(store: keyStore).deviceIdentity() == seededDeviceID)
        #expect(protection.effectiveGate == .biometric && protection.posture == .castle)
        #expect(!protection.followPending && protection.notice != .follow(owed))
        // The new key file: no Apple copy; the vault's descriptor; the old one gone.
        let newFile = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: storeURL))
        #expect(newFile.keyFingerprint == StoreKeyEnvelope.fingerprint(of: newKey))
        #expect(newFile.apple == nil && newFile.appleKeyID == nil, "NO Apple copy")
        #expect(newFile.vaultKDF == vaultBefore.format.kdf && newFile.passphrase?.kdf == vaultBefore.format.kdf,
                "the passphrase copy under the VAULT's descriptor, recorded — no confirm owed")
        #expect(newFile.vaultCorpusKeyID == material.corpusKeyID)
        #expect(try newFile.unwrapKey(passphrase: passphrase) == newKey)
        #expect(try newFile.unwrapKey(master: material.masterSymmetricKey) == newKey)
        #expect(!FileManager.default.fileExists(atPath: oldURL.path), "the OLD key file gone from the live folder")
        #expect(!FileManager.default.fileExists(atPath: legacyURL.path), "the wrap-less 79 B stub gone too (2d.4, ruling 5)")
        #expect(StoreKeyEnvelope.keyFileURLs(besideStore: storeURL).map(\.lastPathComponent) == [newFile.preferredURL(besideStore: storeURL).lastPathComponent],
                "exactly ONE key file beside her library")
        #expect(!protection.migrationConfirmOwedByDerivation)
        // The library: under L′, readable, the old key and A open nothing.
        #expect(StoreEncryptionMigration.opens(storeURL, key: newKey) && !StoreEncryptionMigration.opens(storeURL, key: phoneKey))
        #expect(!StoreEncryptionMigration.opens(storeURL, key: try asLeft.unwrapKey(apple: apple.symmetricKey)), "A opens NO page of the re-keyed library")
        let title = try await reopened.database.read { db in
            try String.fetchOne(db, sql: "SELECT title FROM container WHERE id = 'phone-note'")
        }
        #expect(title == "typed in bed", "her note, whole, under the new key")
        // Nothing rotated: the vault and the mirror untouched; no marker.
        #expect(try await client.fetchVault()?.revision == vaultBefore.revision, "no vault write")
        #expect(await transport.touched == 1, "the mirror untouched by the follow (the one touch is the drill's own pull before it)")
        #expect(keyStore.load()?.corpusKeyID == material.corpusKeyID)
        // One pull AFTER the follow: the same `for_device` — before == after == the seeded value.
        try await withDependencies { $0.database = reopened.database } operation: {
            _ = try await SyncEngine(transport: transport, keyProvider: DeviceKeySyncProvider(store: keyStore)).pull()
        }
        let pulledAfter = await transport.pulledDeviceIDs
        #expect(pulledAfter == [seededDeviceID, seededDeviceID],
                "the pulled for_device before == after == the seeded uppercase sync_state value: \(pulledAfter)")
        #expect(try await PostureSwitchRunner.pendingMarker(database: reopened.database) == nil)
        #expect(syncCalls.value.contains("resume"))
        let names2 = StoreKeyEnvelope.keyFileURLs(besideStore: storeURL).map(\.lastPathComponent)
        print("2d REPLAY| THE FOLLOW: \(runnerLog.value.joined(separator: " · ")); custody: gated=\(backing.gated != nil) auto=\(backing.auto != nil) sync-gated=\(syncLeaves.gatedRecord?.material != nil); files beside the store: \(names2); vault revision \(vaultBefore.revision) unchanged; mirror touched by the follow 0")
        print("3a REPLAY| IDENTITY: seeded sync_state.device_id \(seededDeviceID) → carried at leg 1 (row deleted) → kept by the enroll → kept by the follow; pulled for_device before/after: \(pulledAfter.map { $0 ?? "nil" })")
    }
}
