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
//  VX-329 U1 — THE RELEASE SWITCH: today's road on the phone — the locked
//  lobby and its route (`StoreLaunchGate`, `StoreLobby`), the honest-copy
//  grammar of today's postures, the one-secret hooks, the follow, the
//  window's replay — was deleted with it, and its suites with it. What
//  stands, pinned here:
//  · (a) FIRST LAUNCH ON THE PHONE mints the key and the store is born
//    ENCRYPTED — through the same `openStore` the app's road opens with.
//  · (b) A PRE-13p PLAINTEXT STORE MIGRATES on its first keyed open
//    (the at-open migration — flagged in the U1 record, F-U1-10).
//  · THE LOCK'S TEARDOWN on the phone (`mobileWillLock` — the factory the
//    app composes): pending keystrokes land, the leaving savepoints land,
//    and only then do the services stop. (The bootstrap calling it once
//    before the pool closes is the Mac's `RoadLockRouteTests` pin — the
//    same shared bootstrap.)
//  · (g) THE RE-LOCK on the phone — pure policy over the open library's
//    `RoadRelockPolicy`, the coordinator's stamp, and the scene seam's
//    ORDER (flush first, lock last; a return that locks does not first
//    wake a sync round).
//  · (i) capture over a LOCKED store refuses in words and KEEPS her text.
//  · The passphrase floor, the phone's too.
//
//  NO test here evaluates biometrics or touches the Keychain.
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

// MARK: - The lock's teardown (the phone's onWillLock — ladder R1-M2)

@MainActor
@Suite("13p phone — the lock's teardown lands her text before the services stop")
struct MobileLockTeardownTests {
    /// The factory production composes (`mobileWillLock`), run as the bootstrap runs it before a lock closes the pool:
    /// a registered editor's PENDING edit lands in the store, the open note's leaving savepoint lands, and the services
    /// stop — in that order, the stop last.
    @Test func theTeardownLandsPendingEditsAndSavepointsThenStopsTheServices() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 11))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "locked mid-thought", profile: .blog)
            }
            let minted = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "A", at: .end)
            }
            // A registered editor with a PENDING edit (clocks off — the burst sits in the coordinator, not the store).
            let editors = MobileLivenessAuthority()
            let (editor, storage) = makeEditor(session, postID: post.id)
            await editors.register(editor, tab: .shelf)
            await editor.loadOnce()
            typeEdit(editor, storage, range: NSRange(location: 1, length: 0), replacement: " typed")
            #expect(editor.autosave.isDirty, "the edit is pending, not landed")

            let order = LockIsolated<[String]>([])
            let teardown = mobileWillLock(
                session: session, editors: editors,
                stopServices: {
                    let word = editor.autosave.isDirty ? "stop over a pending edit" : "stop after the flush"
                    order.withValue { $0.append(word) }
                })
            await teardown()

            #expect(order.value == ["stop after the flush"], "the services stop LAST — after her keystrokes landed")
            let landed = try await db.read { db in
                try String.fetchOne(db, sql: "SELECT working_text FROM variant WHERE id = ?", arguments: [minted.variant.id])
            }
            #expect(landed == "A typed", "the pending keystrokes landed")
            let savepoints = try await db.read { db in
                try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?",
                    arguments: [minted.variant.id]) ?? 0
            }
            #expect(savepoints >= 1, "the leaving savepoint landed (the ⌘Q registry's phone twin)")
        }
    }
}

// MARK: - (g): the re-lock, on the open library's policy

@Suite("13p phone — the re-lock policy (pure)")
struct MobileRelockPolicyTests {
    /// Standard has no lock — leaving and returning lock nothing (a lock there would be theater, R13p-14): no policy.
    @Test func standardNeverLocksEitherWay() {
        #expect(!MobileRelockPolicy.locksOnLeaving(policy: nil))
        #expect(!MobileRelockPolicy.locksOnReturn(policy: nil, awayFor: 60 * 60))
    }

    /// Castle ALWAYS locks on leaving (decision 18 — re-lock on sleep / screen lock is always on; backgrounding IS the
    /// phone's leaving), whatever its idle minutes.
    @Test func leavingLocksUnderCastleAlways() {
        #expect(MobileRelockPolicy.locksOnLeaving(policy: RoadRelockPolicy(idleMinutes: 10)))
        #expect(MobileRelockPolicy.locksOnLeaving(policy: RoadRelockPolicy(idleMinutes: nil)))
    }

    @Test func timeAwayIsAThresholdNotATrigger() {
        let fifteen = RoadRelockPolicy(idleMinutes: 15)
        #expect(!MobileRelockPolicy.locksOnReturn(policy: fifteen, awayFor: 14 * 60))
        #expect(MobileRelockPolicy.locksOnReturn(policy: fifteen, awayFor: 15 * 60))
        #expect(!MobileRelockPolicy.locksOnReturn(policy: RoadRelockPolicy(idleMinutes: nil), awayFor: 24 * 60 * 60),
                "never means never")
    }
}

@MainActor
@Suite("13p phone — the re-lock coordinator & the scene seam's order")
struct MobileRelockCoordinatorTests {
    private func coordinator(
        _ policy: RoadRelockPolicy?, clock: LockIsolatedBox<Date>, locks: LockIsolatedBox<Int>
    ) -> MobileRelockCoordinator {
        MobileRelockCoordinator(
            policy: { policy },
            lock: { locks.value += 1 },
            now: { clock.value })
    }

    @Test func leavingLocksImmediatelyUnderCastle() async {
        let clock = LockIsolatedBox(Date(timeIntervalSince1970: 1_000))
        let locks = LockIsolatedBox(0)
        let subject = coordinator(RoadRelockPolicy(idleMinutes: 10), clock: clock, locks: locks)
        await subject.didLeaveTheScreen()
        #expect(locks.value == 1)
        // A lock clears the stamp: the NEXT session must not be locked by
        // a leaving that already produced one.
        #expect(subject.leftAt == nil)
        #expect(await subject.didReturnToTheScreen() == false)
        #expect(locks.value == 1)
    }

    /// Under Castle leaving ALWAYS locks (decision 18), so the return road's threshold is exercised under Standard (where
    /// it never fires) and directly through the policy under Castle (`MobileRelockPolicyTests`).
    @Test func aReturnUnderStandardNeverLocksWhateverTheTimeAway() async {
        let clock = LockIsolatedBox(Date(timeIntervalSince1970: 1_000))
        let locks = LockIsolatedBox(0)
        let subject = coordinator(nil, clock: clock, locks: locks)

        await subject.didLeaveTheScreen()
        #expect(locks.value == 0, "Standard has no lock — leaving locks nothing")
        clock.value = clock.value.addingTimeInterval(6 * 60)
        #expect(await subject.didReturnToTheScreen() == false)
        #expect(locks.value == 0)
    }

    /// **THE ORDER IS THE LEG'S CORRECTNESS**: on leaving, everything that lands her text runs to completion BEFORE the
    /// pool closes. The oracle is what the flush saw at the moment it ran — a lock that beat it would have been counted
    /// first.
    @Test func theLockLandsAfterTheWholeFlush() async {
        let order = LockIsolatedBox<[String]>([])
        let subject = MobileRelockCoordinator(
            policy: { RoadRelockPolicy(idleMinutes: 10) },
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

    /// A return that LOCKS must not first wake a sync round against the pool it is about to close.
    @Test func aReturnThatLocksDoesNotTriggerASyncRound() async {
        let clock = LockIsolatedBox(Date(timeIntervalSince1970: 1_000))
        let locks = LockIsolatedBox(0)
        let subject = coordinator(RoadRelockPolicy(idleMinutes: 5), clock: clock, locks: locks)
        await subject.didLeaveTheScreen()
        clock.value = clock.value.addingTimeInterval(10 * 60)
        // `sync` is nil here, so the pin's subject is the coordinator's answer travelling through the seam at all: it
        // locked, and the seam awaited it before returning.
        let work = mobileScenePhaseChanged(
            .active, editors: MobileLivenessAuthority(), sync: nil,
            grant: .none, relock: subject)
        await work?.value
        #expect(locks.value == 1)
    }
}

// MARK: - The floor, the phone's too

@Suite("13p phone — the passphrase floor reads as the phone's")
struct MobilePassphraseFloorTests {
    /// **RUN A batch A2, row 14 (17n) — the phone's twin of the floor.** The refusal sentence is the one both platforms
    /// speak, and the phone's guide says the floor once (copy §7's shared paragraphs — flagged in the U1 record, F-U1-5).
    @MainActor
    @Test func theEncryptionPassphraseFloorAndItsSentenceAreThePhonesToo() {
        #expect(ProtectionCopy.passphraseFloor == 12)
        #expect(ProtectionCopy.passphraseTooShort == "Your passphrase needs at least 12 characters.")
        let saidTheFloor = ProtectionCopy.privacyLessonTwoParagraphs.filter {
            $0.contains("at least 12 characters")
        }
        #expect(saidTheFloor.count == 1, "said once: \(saidTheFloor.count)")
        #expect(try! #require(saidTheFloor.first).contains("keeps working whatever its length"),
                "and says the other half — an existing word is never refused at unlock")
    }
}

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
