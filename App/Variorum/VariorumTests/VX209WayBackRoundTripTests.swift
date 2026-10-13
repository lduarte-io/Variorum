//
//  VX209WayBackRoundTripTests.swift
//  VariorumTests
//
//  VX-209 — THE REPRODUCTION PIN of the VX-191 audit's §W.2 trace (RUN VX-201,
//  unit U5; the brief is §G of notes/plans/fixes/vx-201-castle-prelaunch-fixes.md,
//  the record its "U5 RECORD (VX-209)"). Her carried-forward reminder 2: the
//  claim that bringing a Castle library back ALSO lands it in Standard came
//  from reading the code, never running it — this file runs it, FIRST, before
//  any copy is written on it.
//
//  WHAT IT IS: a CHARACTERIZATION pin of a KNOWN HAZARD, not a fix's pin. It
//  asserts what the shipped adopt road DOES today, step by step, through the
//  production pieces — the classifier, `LibraryOpenModel`'s own roads (the
//  second look, the Apple road, the typed road, the confirm, the adoption
//  with its custody write), a production `AppBootstrap` (test opener) whose
//  ready road runs, and the gate's route read (`effectiveGate`). The deeper
//  fix — corner 45 must not read a previously-Castle store id as
//  Standard-waiting — is DELIBERATELY out of this run (§A's stranding
//  argument, recorded on VX-209's ticket). When that fix lands, this pin goes
//  red by design: FLIP its assertions to the fixed behavior, never delete it.
//
//  THE WORLD: a LOCAL-ONLY library on this Mac (never synced — the population
//  §W.2 traces; an enrolled library is the 13x R1-BLOCKER arm's, which owes
//  the follow instead). Standard era: the library under L_s, its key file
//  carrying the passphrase copy AND the Apple copy, a real backup pair made
//  by the app's own backup road. Then Castle, as the local road leaves it on
//  disk: the store re-keyed to L_c, a NEW key file (same store id, the
//  passphrase copy, no Apple copy), the Standard-era key file left beside it
//  (the audit's O.4), custody behind Touch ID (gated L_c, no silent item).
//  The iCloud key A stays readable throughout (decision 6 — it is never
//  deleted). The gate is the scripted custody + the in-memory A over the
//  REAL key files on disk (the live gate's own two disk leaves — the
//  adoption lands key files on disk, so a scripted envelope box cannot
//  serve).
//

import Dependencies
import Foundation
import Testing
import VariorumCore

@testable import Variorum

@MainActor
@Suite("VX-209 — §W.2's way-back round trip, run (the reproduction pin)", .serialized)
struct VX209WayBackRoundTripTests {
    @Test func aCastleLibraryOpenedOnAStandardEraBackupAndBroughtBackLandsStandardBothWays() async throws {
        try await withDependencies {
            $0.date = .constant(Date(timeIntervalSince1970: 1_790_000_000))
            $0.uuid = .incrementing
        } operation: { @MainActor in
            try await roundTripBody()
        }
    }

    @MainActor
    private func roundTripBody() async throws {
        let world = try await VX209CastleWorld.make()
        defer { try? FileManager.default.removeItem(at: world.dir) }
        let bootstrap = world.bootstrap
        let scope = bootstrap.storeVariant.rawValue

        // PREMISE — Castle: the launch routes to the lobby (Touch ID), and
        // only the gated item opens it; nothing silent exists.
        guard case .locked(let lobby) = bootstrap.state else {
            Issue.record("premise: a Castle library launches into its lobby, got \(bootstrap.state)")
            return
        }
        #expect(lobby.demand == .biometric)
        await lobby.unlockWithBiometrics()
        await bootstrap.awaitOpen()
        guard case .ready = bootstrap.state else {
            Issue.record("premise: Touch ID opens the Castle library, got \(bootstrap.state)")
            return
        }
        #expect(world.backing.auto == nil && world.backing.gated == world.castleKey)
        #expect(bootstrap.currentEffectiveGate == .biometric)

        // ——— STEP 1: open the Standard-era backup pair of the SAME library
        // (Restore from Backup's row door = the one flow over the snapshot).
        guard case .snapshotPair = LibraryClassifier.classify(at: world.snapshot) else {
            Issue.record("premise: the app's own backup classifies as its pair")
            return
        }
        let first = LibraryOpenModel(bootstrap: bootstrap)
        first.begin(picked: world.snapshot)
        // No typing: the Apple road opens a Standard-era copy silently.
        try await waitUntil { first.phase == .confirm }
        #expect(first.willStepAside)
        await first.confirmAdoption()
        #expect(first.phase == .done)
        await bootstrap.relanding?.value

        // §W.2: "lands Standard silently" — and "opening the backup first had
        // already deleted the Castle library's gated item under the same rule".
        let afterStep1 = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: world.storeURL))
        #expect(afterStep1.storeID == world.storeID, "the backup is the SAME library (same store id)")
        #expect(afterStep1.belongs(to: world.standardKey))
        #expect(afterStep1.apple != nil, "the restored copy opens through the Apple account")
        #expect(world.backing.auto == world.standardKey, "its key now sits in the silent item")
        #expect(world.backing.gated == nil, "the Castle library's Touch ID item was deleted")
        #expect(world.gate.effectiveGate(scope: scope, storeID: world.storeID, storeURL: world.storeURL)
                == .auto, "the next launch opens with no lobby — Standard")

        // ——— STEP 2: bring the Castle copy BACK from Previous Libraries (her
        // proposed workaround — the trace says it does not avoid the revert).
        // Adoption stamps are whole seconds; the next must not share one.
        try await Task.sleep(for: .milliseconds(1100))
        let asideHome = LibraryAdoption.previousLibrariesHome(besideStore: world.storeURL)
        let asideFolders = try FileManager.default.contentsOfDirectory(
            at: asideHome, includingPropertiesForKeys: nil)
        #expect(asideFolders.count == 1, "one adoption, one stepped-aside library")
        let castleCopy = try #require(asideFolders.first)
        guard case .folderHoldingPair(let castleStore, let castleKeyFile)
                = LibraryClassifier.classify(at: castleCopy) else {
            Issue.record("premise: the stepped-aside Castle library classifies as a pair")
            return
        }
        #expect(castleKeyFile.lastPathComponent == world.castleKeyFileName,
                "the CASTLE key file serves it (the newest of the two beside it)")
        #expect(castleStore.lastPathComponent == world.storeURL.lastPathComponent)

        let second = LibraryOpenModel(bootstrap: bootstrap)
        second.begin(picked: castleCopy)
        // No silent road serves a Castle copy: the silent item holds the
        // backup's key, the copy carries no Apple copy, the gated item is gone.
        try await waitUntil { second.phase == .unlock }
        #expect(second.passphraseOffered)
        await second.unlock(passphrase: VX209CastleWorld.passphrase)
        try await waitUntil { second.phase == .confirm }
        await second.confirmAdoption()
        #expect(second.phase == .done)
        await bootstrap.relanding?.value

        // §W.2: the way back "ALSO lands Standard" — corner 45 reads the
        // backup's key in the silent item as Standard-waiting, so custody
        // adopts the Castle key SILENTLY (the gated item stays gone)…
        let afterStep2 = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: world.storeURL))
        #expect(afterStep2.storeID == world.storeID)
        #expect(afterStep2.belongs(to: world.castleKey), "the Castle copy's own key file is the live one")
        #expect(world.backing.auto == world.castleKey,
                "the CASTLE key sits in the silent item — no Touch ID, no passphrase")
        #expect(world.backing.gated == nil, "no Touch ID item exists for it")
        // …and the route's landing arm wraps the CASTLE key under the Apple
        // key. Observed WHEN (read before any route below runs): already by
        // the reopen's own ready — its R1-M3 condition reads the effective
        // gate, whose landing arm writes — so the revert is complete in the
        // same session, before any relaunch (§W.2 named only "the next
        // route"; the run found it one step earlier).
        let rightAfterTheReopen = try #require(
            try StoreKeyEnvelope.loadCurrent(besideStore: world.storeURL))
        #expect(rightAfterTheReopen.apple != nil,
                "the brought-back Castle copy's key file gained an Apple copy at the reopen")
        #expect(try rightAfterTheReopen.unwrapKey(apple: world.apple.symmetricKey) == world.castleKey,
                "the Apple account now opens the CASTLE key — the silent, total revert §W.2 traced")
        // The next launch's route: no lobby — Standard, opening silently.
        #expect(world.gate.effectiveGate(scope: scope, storeID: world.storeID, storeURL: world.storeURL)
                == .auto, "the next launch opens with no lobby — Standard")
        // The ready housekeeping's reconcile (production runs it at every
        // ready; a test opener skips it, so it is called here): VX-202's
        // sweep (belt b) has nothing to act on — no Touch ID item beside
        // the silent one — and the Apple arm VERIFIES the copy, determined
        // Standard. Nothing on the ready road heals the revert.
        await bootstrap.protection.reconcile()
        #expect(bootstrap.protection.postureReading == .determined(.standard))
        #expect(bootstrap.protection.appleKeyVerified == true)
        #expect(world.backing.auto == world.castleKey && world.backing.gated == nil)
    }

    private func waitUntil(
        _ condition: @MainActor () -> Bool, within seconds: Double = 10
    ) async throws {
        try await VX209CastleWorld.waitUntil(condition, within: seconds)
    }
}

// MARK: - The world (shared with `VX209LeavesCastleConfirmTests`)

/// A LOCAL-ONLY Castle library on this Mac that had a Standard era — see the
/// file header. Built through the production pieces; temp dirs, in-memory
/// custody and an in-memory iCloud key only.
@MainActor
struct VX209CastleWorld {
    static let passphrase = "the castle passphrase"

    var dir: URL
    var storeURL: URL
    var storeID: String
    var standardKey: StoreKey
    var castleKey: StoreKey
    var castleKeyFileName: String
    var apple: AppleKey
    /// The Standard-era backup pair's snapshot (the app's own backup road).
    var snapshot: URL
    /// A plaintext export of the library, made in its Standard era.
    var plaintextExport: URL
    var backing: InMemoryStoreKeyGuardBacking
    var gate: StoreLaunchGate
    var bootstrap: AppBootstrap

    static func make() async throws -> VX209CastleWorld {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-vx209-\(UUID().uuidString)", isDirectory: true)
        let storeURL = dir.appendingPathComponent("home/variorum.sqlite")
        let kdf = fastKDF()
        let apple = AppleKey.mint()

        // The Standard era: the library under L_s; its key file carries the
        // passphrase copy and the Apple copy.
        let standardKey = StoreKey.mint()
        let standardDatabase = try AppDatabase.openStore(
            at: storeURL, custody: .inMemory(initial: standardKey))
        var standardFile = StoreKeyEnvelope()
        try standardFile.setPassphraseWrap(key: standardKey, passphrase: passphrase, kdf: kdf)
        try standardFile.setAppleWrappedCopy(
            key: standardKey, under: apple.symmetricKey, appleKeyID: apple.id)
        let storeID = standardFile.storeID
        let standardFileURL = standardFile.preferredURL(besideStore: storeURL)
        try standardFile.write(at: standardFileURL)
        // The Standard-era backup PAIR, made by the app's own backup road
        // (the snapshot + its own key file — decision 11's shape).
        let backups = storeURL.deletingLastPathComponent()
            .appendingPathComponent("Backups", isDirectory: true)
        try FileManager.default.createDirectory(at: backups, withIntermediateDirectories: true)
        let written = try await Task.detached(priority: .userInitiated) {
            try StoreBackup.performPrimaryLeg(
                database: standardDatabase, directory: backups,
                configuration: .init(keyEnvelopeStoreURL: storeURL),
                now: Date(timeIntervalSince1970: 1_789_000_000), force: true)
        }.value
        guard case .written(let snapshot) = written else {
            throw WorldError("the backup road wrote no snapshot")
        }
        // A plaintext export of the same library (decision 15's door).
        let exports = dir.appendingPathComponent("exports", isDirectory: true)
        try FileManager.default.createDirectory(at: exports, withIntermediateDirectories: true)
        let plaintextExport = exports.appendingPathComponent("variorum-export.sqlite")
        try StorePlaintextExport.export(from: standardDatabase, to: plaintextExport)
        _ = standardDatabase.asRebindable().binding.lock()

        // Castle, entered on this Mac by the local road (its on-disk shape):
        // the store re-keyed to L_c; a NEW key file under the SAME store id
        // with the passphrase copy and no Apple copy; the Standard-era key
        // file left beside it (O.4), an hour older.
        let castleKey = StoreKey.mint()
        try StoreEncryptionMigration.rekey(at: storeURL, from: standardKey, to: castleKey)
        var castleFile = StoreKeyEnvelope(storeID: storeID)
        try castleFile.setPassphraseWrap(key: castleKey, passphrase: passphrase, kdf: kdf)
        let castleFileURL = castleFile.preferredURL(besideStore: storeURL)
        try castleFile.write(at: castleFileURL)
        try FileManager.default.setAttributes(
            [.modificationDate: Date().addingTimeInterval(-3600)], ofItemAtPath: standardFileURL.path)

        // Custody behind Touch ID (Castle's custody law: gated present,
        // silent deleted); A stays in iCloud Keychain.
        let backing = InMemoryStoreKeyGuardBacking(
            gated: castleKey, biometryAvailable: true, biometricSucceeds: true)
        var gate = StoreLaunchGate.scripted(
            dials: ProtectionDials(), backing: backing,
            appleKey: InMemoryAppleKeyBacking(key: apple))
        gate.loadEnvelope = { try StoreKeyEnvelope.loadCurrent(besideStore: $0) }
        gate.saveEnvelope = { try $0.write(at: $0.preferredURL(besideStore: $1)) }
        let bootstrap = AppBootstrap(
            testOpener: { .success(try! AppDatabase.inMemory()) },
            gate: gate,
            testStoreURL: storeURL,
            // Local-only: no sync custody, ever (never the live Keychain's).
            syncCustodyLeaves: { _ in noSyncCustody })
        await bootstrap.awaitOpen()
        return VX209CastleWorld(
            dir: dir, storeURL: storeURL, storeID: storeID,
            standardKey: standardKey, castleKey: castleKey,
            castleKeyFileName: castleFileURL.lastPathComponent, apple: apple,
            snapshot: snapshot, plaintextExport: plaintextExport,
            backing: backing, gate: gate, bootstrap: bootstrap)
    }

    /// The launch's lobby, unlocked by Touch ID — the Castle library at ready.
    func unlockIntoReady() async throws {
        guard case .locked(let lobby) = bootstrap.state else {
            throw WorldError("a Castle library launches into its lobby, got \(bootstrap.state)")
        }
        await lobby.unlockWithBiometrics()
        await bootstrap.awaitOpen()
        guard case .ready = bootstrap.state else {
            throw WorldError("Touch ID opens the Castle library, got \(bootstrap.state)")
        }
    }

    struct WorldError: Error, CustomStringConvertible {
        var description: String
        init(_ description: String) { self.description = description }
    }

    nonisolated static let noSyncCustody = E2EECustodyLeaves(
        saveGated: { _ in true }, savePlain: { _ in true }, loadPlain: { nil },
        gatedExists: { false }, deletePlain: { true }, deleteGated: { true })

    static func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    static func waitUntil(
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
