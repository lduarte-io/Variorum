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
            let backing = InMemoryStoreKeyGuardBacking(biometryAvailable: true)
            let dialsBox = ScriptedDialsBox(ProtectionDials(mode: .biometric))
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
            #expect(dialsBox.value.mode == .biometric, "the lock never resets")
            await lobby.startNewLibrary()
            #expect(lobby.lastError == nil)
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state else {
                Issue.record("expected .ready, got \(bootstrap.state)")
                return
            }
            let fresh = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: storeURL))
            #expect(fresh.storeID != oldEnvelope.storeID, "a NEW store id")
            #expect(dialsBox.perStoreDials(fresh.storeID)?.mode == .auto)
            #expect(dialsBox.value.mode == .biometric, "the old library's lock is untouched")
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
    @Test func autoNeverLocksEitherWay() {
        var dials = ProtectionDials(mode: .auto)
        dials.relockOnSleepAndScreenLock = true
        dials.relockAfterIdleMinutes = 5
        #expect(!MobileRelockPolicy.locksOnLeaving(dials))
        #expect(!MobileRelockPolicy.locksOnReturn(dials, awayFor: 60 * 60))
    }

    @Test func leavingLocksOnlyWhenTheDialSaysSo() {
        var dials = ProtectionDials(mode: .passphrase)
        #expect(!MobileRelockPolicy.locksOnLeaving(dials))
        dials.relockOnSleepAndScreenLock = true
        #expect(MobileRelockPolicy.locksOnLeaving(dials))
    }

    @Test func timeAwayIsAThresholdNotATrigger() {
        var dials = ProtectionDials(mode: .biometric)
        dials.relockAfterIdleMinutes = 15
        #expect(!MobileRelockPolicy.locksOnReturn(dials, awayFor: 14 * 60))
        #expect(MobileRelockPolicy.locksOnReturn(dials, awayFor: 15 * 60))
        dials.relockAfterIdleMinutes = nil
        #expect(!MobileRelockPolicy.locksOnReturn(dials, awayFor: 24 * 60 * 60),
                "never means never")
    }

    @Test func theAwayRowsReadAsTheyShould() {
        #expect(MobileRelockPolicy.awayChoices.first == 0)
        #expect(MobileRelockPolicy.awayLabel(0) == "Never")
        #expect(MobileRelockPolicy.awayLabel(60) == "After an hour")
        #expect(MobileRelockPolicy.awayLabel(15) == "After 15 minutes")
    }
}

@MainActor
@Suite("13p phone — the re-lock coordinator & the scene seam's order")
struct MobileRelockCoordinatorTests {
    private func coordinator(
        _ dials: ProtectionDials, clock: LockIsolatedBox<Date>,
        locks: LockIsolatedBox<Int>
    ) -> MobileRelockCoordinator {
        MobileRelockCoordinator(
            dials: { dials },
            lock: { locks.value += 1 },
            now: { clock.value })
    }

    @Test func leavingLocksImmediatelyWhenTheDialIsOn() async {
        var dials = ProtectionDials(mode: .passphrase)
        dials.relockOnSleepAndScreenLock = true
        let clock = LockIsolatedBox(Date(timeIntervalSince1970: 1_000))
        let locks = LockIsolatedBox(0)
        let subject = coordinator(dials, clock: clock, locks: locks)
        await subject.didLeaveTheScreen()
        #expect(locks.value == 1)
        // A lock clears the stamp: the NEXT session must not be locked by
        // a leaving that already produced one.
        #expect(subject.leftAt == nil)
        #expect(await subject.didReturnToTheScreen() == false)
        #expect(locks.value == 1)
    }

    @Test func aLongTripAwayLocksOnReturnAndAShortOneDoesNot() async {
        var dials = ProtectionDials(mode: .biometric)
        dials.relockAfterIdleMinutes = 5
        let clock = LockIsolatedBox(Date(timeIntervalSince1970: 1_000))
        let locks = LockIsolatedBox(0)
        let subject = coordinator(dials, clock: clock, locks: locks)

        await subject.didLeaveTheScreen()
        #expect(locks.value == 0, "the leaving dial is off — leaving alone locks nothing")
        clock.value = clock.value.addingTimeInterval(60)
        #expect(await subject.didReturnToTheScreen() == false)
        #expect(locks.value == 0)

        await subject.didLeaveTheScreen()
        clock.value = clock.value.addingTimeInterval(6 * 60)
        #expect(await subject.didReturnToTheScreen() == true)
        #expect(locks.value == 1)
    }

    /// **THE ORDER IS THE LEG'S CORRECTNESS** (this file's own rule, and
    /// the flush's): on leaving, everything that lands her text runs to
    /// completion BEFORE the pool closes. The oracle is what the flush saw
    /// at the moment it ran — a lock that beat it would have been counted
    /// first.
    @Test func theLockLandsAfterTheWholeFlush() async {
        var dials = ProtectionDials(mode: .passphrase)
        dials.relockOnSleepAndScreenLock = true
        let order = LockIsolatedBox<[String]>([])
        let subject = MobileRelockCoordinator(
            dials: { dials },
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
        var dials = ProtectionDials(mode: .passphrase)
        dials.relockAfterIdleMinutes = 5
        let clock = LockIsolatedBox(Date(timeIntervalSince1970: 1_000))
        let locks = LockIsolatedBox(0)
        let subject = coordinator(dials, clock: clock, locks: locks)
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
        #expect(ProtectionCopy.escrowOn.contains("if you lose this iPhone"))
        #expect(ProtectionCopy.modeLabel(.biometric) == "Ask for Face ID")
        #expect(ProtectionCopy.lobbyPrompt(.biometric) == "Unlock your library with Face ID.")
        // The one arm the Batch-4 sweep caught: it named Touch ID as a
        // LITERAL, so the phone offered a fingerprint it does not have.
        let unreadable = ProtectionCopy.message(
            for: StoreKeyEnvelopeError.unreadable("decode failed"))
        #expect(unreadable.contains("Face ID"))
        #expect(!unreadable.contains("Touch ID"))
    }

    /// **ONE BRAIN** (knot 6): the settings sentence is composed from
    /// `lossLegs`, and the tutorial chapter is asserted against the same
    /// list — so the two cannot state different chains.
    @Test func theLossMathIsComposedFromTheLegsItNames() {
        for mode in StoreAtOpenMode.allCases {
            for escrow in [true, false] {
                let legs = ProtectionCopy.lossLegs(mode, escrowOn: escrow)
                let sentence = ProtectionCopy.lossMath(mode, escrowOn: escrow)
                if mode == .passphrase {
                    // The one arm that deliberately states the SHORT chain
                    // as prose (her own example, verbatim) rather than a
                    // list — and it must not claim an iCloud leg.
                    // SUPERSESSION (ninth wave, memo §4): this arm now
                    // covers BOTH escrow values — the escrow/posture
                    // coupling means a passphrase-at-every-open library
                    // carries no spare, whatever the stored Auto choice.
                    #expect(sentence.contains("IS enough"))
                    #expect(!sentence.contains("iCloud"))
                    continue
                }
                for leg in legs {
                    #expect(sentence.contains(leg),
                            "the sentence must name every way back in: \(leg)")
                }
                // SUPERSESSION (ninth wave, memo §4 — the coupling): an
                // iCloud leg is claimed only when the dial is on AND the
                // posture offers it (demanded modes never do).
                #expect((escrow && !mode.isDemanded) == sentence.contains("iCloud"),
                        "an iCloud leg is claimed only when the posture offers one")
            }
        }
    }

    /// The demanded modes' chains really are SHORTER — no silently-
    /// releasing custody item exists there (the custody law, in words).
    @Test func theDemandedModesHaveNoSilentDeviceLeg() {
        let auto = ProtectionCopy.lossLegs(.auto, escrowOn: false)
        let passphrase = ProtectionCopy.lossLegs(.passphrase, escrowOn: false)
        #expect(auto.contains { $0.contains("Keychain holds the key") })
        #expect(passphrase.count < auto.count)
        #expect(!passphrase.contains { $0.contains("Keychain") })
    }

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
                apiKey: "publishable-test-key"),
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
        #expect(throws: StoreKeyEnvelopeError.wrongPassphrase) {
            _ = try envelope.unwrapKey(passphrase: self.vaultPassphrase)
        }
    }

    /// **The PHRASE (the fourth mechanism):** vault-minted twelve words
    /// land on the store envelope too, so the one phrase opens the
    /// library as well as the account — on the phone's composition.
    @Test func vaultMintedWordsOpenTheLibraryTooOnThePhone() async throws {
        let w = world()
        #expect(await w.controller.setPassphrase(vaultPassphrase) == nil)
        await w.encryption.setUp(passphrase: vaultPassphrase)
        #expect(w.encryption.lastError == nil)

        let words = try #require(w.encryption.generatePhrase())
        await w.encryption.landRecoveryWrap(confirmedWords: words, allowReplace: false)
        #expect(w.encryption.lastError == nil)

        let envelope = try #require(w.envelopeBox.value)
        #expect(try envelope.unwrapKey(recoveryWords: words) == w.key,
                "the vault's twelve words unwrap the STORE key too")
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

        let refusal = await w.controller.resetPassphrase(to: "fresh-north-22")
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

        let refusal = await w.controller.resetPassphrase(to: "fresh-north-22")
        #expect(refusal?.contains("nothing was changed") == true,
                "the reset refuses WHOLE rather than diverging: \(refusal ?? "nil")")

        let envelope = try #require(w.envelopeBox.value)
        #expect(try envelope.unwrapKey(passphrase: vaultPassphrase) == w.key,
                "the store wrap is untouched — the old passphrase still opens")
        #expect(throws: StoreKeyEnvelopeError.wrongPassphrase) {
            _ = try envelope.unwrapKey(passphrase: "fresh-north-22")
        }
    }
}
