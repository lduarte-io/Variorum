//
//  VX80CastleFollowRecoveryTests.swift
//  VariorumTests
//
//  VX-80 — the Castle-follow crash window's recovery door (the record:
//  notes/plans/fixes/vx-80-castle-follow-recovery-door.md; pulled into 13x
//  at the 2026-10-07 morning sitting).
//
//  THE STRANDED STATE (production, the author's Air, 2026-10-07): the
//  follow's re-key completed its export-verify-atomic-rename — the store
//  is whole under the NEW key B, the new sidecar wrapping B sits beside it
//  — and the app died BEFORE step 5 (`moveCustodyForSwitch`), so custody
//  still holds the OLD key A. Every relaunch then routes `.open` (the
//  silent item is present, so every lobby arm is skipped), opens with A,
//  hits SQLCipher's error 26 ("file is not a database"), and lands the
//  doorless `.failed` with `recovery: nil` — a dead end over a library the
//  sidecar beside it can still unlock. The resume road that is DESIGNED
//  for this window (`RotationMarker` → `PostureSwitchRunner.resume`) is
//  unreachable because the marker lives inside the store the app can no
//  longer open.
//
//  The pins here simulate that state exactly as the record instructs
//  (store under B · custody holding A · newest sidecar wrapping B); the
//  live stranded fixture stays on the Air, untouched.
//

import CryptoKit
import Dependencies
import Foundation
import GRDB
import Observation
import Testing

@testable import Variorum
import VariorumCore

@MainActor
@Suite("VX-80 — the Castle-follow recovery door")
struct VX80CastleFollowRecoveryTests {
    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-vx80-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    /// The `.ready` arm builds an `AppSession`, which reads the injected
    /// clock — the Phase13pLobbyTests scope pattern, reused.
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

    /// The stranded trio on disk + the scripted world around it: a real
    /// store under `storeKey`, custody holding `custodyKey` as the silent
    /// item, the (newest) sidecar wrapping `storeKey` Castle-shaped — a
    /// passphrase wrap, no Apple copy (`writeNewKeyFile` under
    /// `entersCastle: true` writes exactly that shape).
    private func strandedStore(
        in dir: URL, storeKey: StoreKey, passphrase: String
    ) throws -> (storeURL: URL, sidecar: StoreKeyEnvelope) {
        let storeURL = dir.appendingPathComponent("variorum.sqlite")
        do {
            // Create-and-release: the pool closes when the reference drops;
            // the file left behind is the follow's re-keyed store.
            let seeded = try AppDatabase.onDisk(url: storeURL, key: storeKey)
            _ = try seeded.read { db in
                try Int.fetchOne(db, sql: "SELECT count(*) FROM sqlite_master")
            }
        }
        var sidecar = StoreKeyEnvelope()
        try sidecar.setPassphraseWrap(key: storeKey, passphrase: passphrase, kdf: fastKDF())
        return (storeURL, sidecar)
    }

    /// A test opener that runs the PRODUCTION open road — `openStore`
    /// resolving the key from custody against the real file, so the
    /// failure that reaches `failedOutcome` is the real typed refusal,
    /// never a test's own construction. `custodyKey` is what the device's
    /// custody holds; the unlock leg flips it to the unlocked key (the
    /// init's note: the unlocked key reaches production's opener as
    /// custody and is deliberately not threaded into a test opener).
    private func productionOpener(
        storeURL: URL, custodyKey: LockIsolated<StoreKey>, openCount: LockIsolated<Int>
    ) -> @Sendable () -> Result<AppDatabase, AppDatabase.StoreOpenError> {
        {
            openCount.withValue { $0 += 1 }
            return Result {
                try AppDatabase.openStore(
                    at: storeURL, custody: .inMemory(initial: custodyKey.value))
            }.mapError { error in
                error as? AppDatabase.StoreOpenError
                    ?? AppDatabase.StoreOpenError(
                        storePath: storeURL.path, reason: String(describing: error))
            }
        }
    }

    /// **THE NAMED RED-ON-OLD PIN (the VX-80 record's shape).** Store under
    /// key B, custody holding key A, newest sidecar wrapping B: today's
    /// code lands the doorless `.failed` with `recovery: nil` — the Air's
    /// dead end. The fix must offer the SAME typed-secrets lobby the
    /// empty-custody arm (13p ladder R1-M3) offers, and the typed word must
    /// unlock through the sidecar into `.ready` — after which the standing
    /// machinery (the ready housekeeping's reconcile, the marker's resume
    /// door) completes the interrupted follow.
    ///
    /// RED ON OLD at the `#require(recovery…)` line: `failedOutcome` keys
    /// the lobby on `error.keyUnavailable` alone, and a wrong-key open is
    /// not that class.
    @Test func theStrandedStoreOffersTheRecoveryLobbyAndTheTypedWordOpensIt() async throws {
        try await withDeps {
            let dir = try temporaryDirectory()
            defer { try? FileManager.default.removeItem(at: dir) }
            let keyB = StoreKey.mint()  // the follow's new library key — the file is under it
            let keyA = StoreKey.mint()  // the stale custody key — the crash fell before the move
            let (storeURL, sidecar) = try strandedStore(
                in: dir, storeKey: keyB, passphrase: "sesame")

            // The Air's custody shape: the silent item holds A; the device
            // is enrolled (sync custody present), so the route's posture
            // reading is indeterminate and acts as the custody shape —
            // Standard — and the gate is `.auto`: route `.open`, every
            // lobby arm skipped.
            let backing = InMemoryStoreKeyGuardBacking(auto: keyA)
            let gate = StoreLaunchGate.scripted(
                dials: ProtectionDials(), backing: backing, envelope: sidecar,
                syncCustodyPresent: { _, _ in true })

            let custodyKey = LockIsolated(keyA)
            let openCount = LockIsolated(0)
            let bootstrap = AppBootstrap(
                testOpener: productionOpener(
                    storeURL: storeURL, custodyKey: custodyKey, openCount: openCount),
                gate: gate, testStoreURL: storeURL)
            await bootstrap.awaitOpen()

            guard case .failed(let error, let recovery) = bootstrap.state else {
                Issue.record("expected .failed over the stranded store, got \(bootstrap.state)")
                return
            }
            #expect(openCount.value == 1, "the route opened silently — no lobby arm fired")
            #expect(!error.keyUnavailable,
                    "this is the WRONG-KEY class (a key in hand that does not open the file), not R1-M3's empty-custody class")

            // THE PIN: the wraps-bearing sidecar beside the store must earn
            // the recovery lobby — nil is the doorless dead end her Air hit.
            let lobby = try #require(
                recovery,
                "VX-80: a wrong-key open with a wraps-bearing sidecar beside the store must offer the typed-secrets recovery lobby; recovery was nil")
            #expect(lobby.passphraseOffered, "the sidecar's passphrase wrap is the road")
            #expect(!lobby.biometryOffered, "typed secrets only — no gated item holds the key that opens this file")

            // The typed word unlocks through the NEWEST sidecar (which
            // wraps B), and the open proceeds under the unlocked key.
            custodyKey.setValue(keyB)
            await lobby.unlock(passphrase: "sesame")
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state else {
                Issue.record("expected .ready after the recovery unlock, got \(bootstrap.state)")
                return
            }
            #expect(openCount.value == 2, "one failed open, one unlocked open")
        }
    }

    /// **PIECE 3 — the saveAuto gate check (the record's own instruction):**
    /// on the recovery road under the CASTLE DEMANDED GATE, the R1-M3
    /// unlocked-key re-landing must NOT fire — the lobby law holds (the
    /// demanded modes never land a silent item; the marker's resume owns
    /// custody here). The shape: a Castle device's crash window — the GATED
    /// item holds the stale key A, the route's lobby biometric road
    /// releases A, the open fails typed (`keyRejected`), the recovery
    /// lobby's typed word yields B — and after `.ready` the silent item
    /// must still not exist.
    @Test func underTheDemandedGateTheRecoveryUnlockLandsNoSilentItem() async throws {
        try await withDeps {
            let dir = try temporaryDirectory()
            defer { try? FileManager.default.removeItem(at: dir) }
            let keyB = StoreKey.mint()
            let keyA = StoreKey.mint()
            let (storeURL, sidecar) = try strandedStore(
                in: dir, storeKey: keyB, passphrase: "sesame")

            // The gated custody shape: no silent item, the gated item holds
            // stale A, biometrics succeed (they release exactly the key
            // that no longer opens the file).
            let backing = InMemoryStoreKeyGuardBacking(
                gated: keyA, biometryAvailable: true, biometricSucceeds: true)
            let gate = StoreLaunchGate.scripted(
                dials: ProtectionDials(), backing: backing, envelope: sidecar,
                syncCustodyPresent: { _, _ in true })

            let custodyKey = LockIsolated(keyA)
            let openCount = LockIsolated(0)
            let bootstrap = AppBootstrap(
                testOpener: productionOpener(
                    storeURL: storeURL, custodyKey: custodyKey, openCount: openCount),
                gate: gate, testStoreURL: storeURL)
            await bootstrap.awaitOpen()

            // The demanded route stops at the REGULAR lobby first.
            guard case .locked(let lockedLobby) = bootstrap.state else {
                Issue.record("expected .locked under the demanded gate, got \(bootstrap.state)")
                return
            }
            #expect(lockedLobby.biometryOffered, "the gated item exists — the biometric road renders")
            await lockedLobby.unlockWithBiometrics()
            await bootstrap.awaitOpen()

            // The gated road released the STALE key; the open failed typed
            // into the recovery lobby — the new arm.
            guard case .failed(let error, let recovery) = bootstrap.state else {
                Issue.record("expected .failed after the stale gated unlock, got \(bootstrap.state)")
                return
            }
            #expect(error.keyRejected, "the wrong-key class, typed (VX-80)")
            #expect(!error.keyUnavailable)
            let lobby = try #require(recovery, "the recovery lobby renders on the wrong-key class")
            #expect(lobby.passphraseOffered)
            #expect(!lobby.biometryOffered,
                    "typed secrets only — the gated item holds exactly the key that failed")

            custodyKey.setValue(keyB)
            await lobby.unlock(passphrase: "sesame")
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state else {
                Issue.record("expected .ready after the recovery unlock, got \(bootstrap.state)")
                return
            }
            // THE CHECK: the effective gate derives DEMANDED (gated custody
            // shape, Castle-shaped key file), so the R1-M3 re-landing is
            // guarded off — no silent item may appear. A bounded settle
            // gives the (would-be) detached save every chance to fire.
            for _ in 0..<200 {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(backing.auto == nil,
                    "the demanded modes' lobby road never lands custody — the resume owns it")
        }
    }

    /// The SILENT custody shape's re-landing is the designed heal, pinned:
    /// on the Air's exact state (silent item holding stale A, gate `.auto`)
    /// the recovery unlock's proven key REPLACES the stale silent item
    /// (R1-M3's non-demanded re-landing), so the NEXT launch opens silently
    /// instead of re-stranding — the reconcile's posture-mismatch arm and
    /// the marker's resume door then complete the follow at their own
    /// cadence. Losing this heal would re-strand every relaunch until the
    /// resume runs.
    @Test func underTheSilentShapeTheProvenKeyReplacesTheStaleItem() async throws {
        try await withDeps {
            let dir = try temporaryDirectory()
            defer { try? FileManager.default.removeItem(at: dir) }
            let keyB = StoreKey.mint()
            let keyA = StoreKey.mint()
            let (storeURL, sidecar) = try strandedStore(
                in: dir, storeKey: keyB, passphrase: "sesame")
            let backing = InMemoryStoreKeyGuardBacking(auto: keyA)
            let gate = StoreLaunchGate.scripted(
                dials: ProtectionDials(), backing: backing, envelope: sidecar,
                syncCustodyPresent: { _, _ in true })
            let custodyKey = LockIsolated(keyA)
            let openCount = LockIsolated(0)
            let bootstrap = AppBootstrap(
                testOpener: productionOpener(
                    storeURL: storeURL, custodyKey: custodyKey, openCount: openCount),
                gate: gate, testStoreURL: storeURL)
            await bootstrap.awaitOpen()
            guard case .failed(_, let recovery) = bootstrap.state,
                  let lobby = recovery else {
                Issue.record("expected .failed with the recovery lobby, got \(bootstrap.state)")
                return
            }
            custodyKey.setValue(keyB)
            await lobby.unlock(passphrase: "sesame")
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state else {
                Issue.record("expected .ready after the recovery unlock, got \(bootstrap.state)")
                return
            }
            var healed = false
            for _ in 0..<400 where !healed {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
                healed = backing.auto == keyB
            }
            #expect(healed,
                    "the proven key replaces the stale silent item — the next launch opens silently instead of re-stranding")
        }
    }

    /// P11 PARITY on the new class: an UNREADABLE sidecar reads as no
    /// roads — the failure surface stays doorless for the wrong-key class
    /// exactly as it does for the empty-custody one (the lobby and the
    /// controller doors carry the unreadable honesty; widening would be
    /// new design, not a fix — the R1-M3 disposition, carried over).
    @Test func anUnreadableSidecarStaysDoorlessOnTheWrongKeyClass() async throws {
        try await withDeps {
            let dir = try temporaryDirectory()
            defer { try? FileManager.default.removeItem(at: dir) }
            let keyB = StoreKey.mint()
            let keyA = StoreKey.mint()
            let (storeURL, _) = try strandedStore(
                in: dir, storeKey: keyB, passphrase: "sesame")
            let backing = InMemoryStoreKeyGuardBacking(auto: keyA)
            let envelopeBox = ScriptedEnvelopeBox(nil)
            envelopeBox.unreadable = true
            let gate = StoreLaunchGate.scripted(
                dials: ScriptedDialsBox(ProtectionDials()), backing: backing,
                envelope: envelopeBox,
                syncCustodyPresent: { _, _ in true })
            let custodyKey = LockIsolated(keyA)
            let openCount = LockIsolated(0)
            let bootstrap = AppBootstrap(
                testOpener: productionOpener(
                    storeURL: storeURL, custodyKey: custodyKey, openCount: openCount),
                gate: gate, testStoreURL: storeURL)
            await bootstrap.awaitOpen()
            guard case .failed(let error, let recovery) = bootstrap.state else {
                Issue.record("expected .failed, got \(bootstrap.state)")
                return
            }
            #expect(error.keyRejected, "still the typed wrong-key refusal")
            #expect(recovery == nil,
                    "an unreadable sidecar offers no roads here — the true cause renders, never a lobby that cannot act")
        }
    }
}
