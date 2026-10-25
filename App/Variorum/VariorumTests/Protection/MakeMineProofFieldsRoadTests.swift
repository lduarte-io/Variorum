//
//  MakeMineProofFieldsRoadTests.swift
//  VariorumTests — VX-529 L2, VX-523 under her R-529-7 ("(A) in this run"): THE APP'S HALF — Make this my library's door
//  reads the signed-in account's vault ONCE, within the standing bound (`ProtectionOpenRoad.typedUnlockVaultBound`,
//  VX-501's race), and hands that read to the core act (`AccountsVaultRead.taken`), which writes the join's two proof
//  fields into the new library's key file only when the current pair's words open it. Over the new road's PLANTED leaves
//  (no keychain, no network — `ProtectionAccountSupport`'s vault and sync keys; also runs headless in the implementer's
//  SwiftPM harness).
//    - online: ONE read, the fields written (a design row — green on both sides: the core's door read the vault itself
//      before the app's read existed);
//    - A SLOW SERVER: the door waits at most its bound, then the act goes on with today's file (RED before the app's
//      bounded read — the core's own read in the door waited for the slow answer and wrote the fields from it);
//    - offline: today's file (a guard — green on both sides).
//

import CryptoKit
import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-529 L2 — VX-523: Make this my library's one bounded vault read (planted, no keychain)", .serialized)
@MainActor
struct MakeMineProofFieldsRoadTests {
    typealias Account = PlantedAccount

    struct World {
        let road: PlantedRoad
        let vault: PlantedVaultLeaf
        let session: ProtectionRoadSession
        let pair: TypedSecrets
        let row: CopyDoorRow
    }

    /// A Standard library turned on to sync (its pair handed up — the account's now), signed in, with one backup pair of
    /// itself: the restored copy's starting state (the VX-510 walk's W-6).
    static func syncedWithABackup() async throws -> World {
        let (road, vault, _) = Account.road()
        road.session = Account.signedIn
        let (session, words) = try await road.created()
        try CopyDoorsPlant.migrate(road, key: session.key)
        let turnOn = try #require(ProtectionPaneRead.accountFaces(try await Account.read(session, Account.signedIn))?
            .turnOnSync.openDoor)
        let turned = await ProtectionAccountRoad.press(
            session, request: RoadAccountRequest(
                door: .turnOnSync, shown: turnOn, typed: TypedSecrets(words: words, newPassphrase: Account.passphrase)),
            signIn: Account.signedIn, exportSwitch: nil)
        #expect(turned == .made(receipt: ProtectionWords.turnOnSyncReceipt), "the library syncs")
        session.executor.configuration.session = Account.signedIn
        let live = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        try session.system.backups.takeBackupPair(with: session.key, keyFile: live, deviceID: session.library.section.deviceID)
        let row = try #require(ProtectionCopyDoors.listing(session).thisLibrary.first)
        return World(
            road: road, vault: vault, session: session,
            pair: TypedSecrets(passphrase: Account.passphrase, words: words), row: row)
    }

    static func fetches(_ world: World) -> Int { world.vault.calls.filter { $0 == "fetch \(Account.account)" }.count }

    /// The press through the app's road: the preflight (all reads), then the act (`ProtectionCopyDoors.makeMine`).
    static func press(_ world: World, within bound: Duration? = nil) async throws -> ProtectionCopyDoors.MakeMineResult {
        guard case .ready(let copy, let catalog, let opened) = ProtectionCopyDoors.preflight(
            world.session, row: world.row, copySecrets: world.pair, currentPair: world.pair) else {
            Issue.record("the preflight passes for her own backup and her current pair")
            throw RoadWorld.RoadWorldError.notCreated
        }
        if let bound {
            return await ProtectionCopyDoors.makeMine(
                world.session, copy: copy, catalog: catalog, row: world.row, opened: opened, currentPair: world.pair,
                vaultWithin: bound)
        }
        return await ProtectionCopyDoors.makeMine(
            world.session, copy: copy, catalog: catalog, row: world.row, opened: opened, currentPair: world.pair)
    }

    static func liveKeyFile(_ world: World) throws -> KeyFile {
        try #require(try world.road.system().leaves.keyFiles.readLiveKeyFile())
    }

    /// The join's two fields as the vault holds them: no own words lock, the master's copy the vault's recovery wrap.
    static func carriesTheProof(_ file: KeyFile, _ world: World) throws -> Bool {
        let vault = try #require(world.vault.snapshot(Account.account)).vault
        return file.words == nil && file.master != nil && file.masterWordsCopy == vault.masterByWords
    }

    /// Today's shape: an own words lock, no master, no copy.
    static func isTodays(_ file: KeyFile) -> Bool { file.words != nil && file.master == nil && file.masterWordsCopy == nil }

    /// DESIGN ROW (green on both sides): signed in and online — ONE read of the account's vault, the fields written, the
    /// new library binding no account, the current pair opening it.
    @Test func onlineOneReadAndTheFieldsAreWritten() async throws {
        let world = try await Self.syncedWithABackup()
        let before = Self.fetches(world)
        let result = try await Self.press(world)
        #expect(result.outcome == .made)
        #expect(Self.fetches(world) == before + 1, "ONE read of the account's vault for the act")
        let live = try Self.liveKeyFile(world)
        #expect(try Self.carriesTheProof(live, world), "the join's two fields")
        let record = try #require(try ProtectionLibraryFiles.readRecord(at: world.road.slot.places.slot, key: result.reopenKey))
        #expect(record.account == nil, "the new library binds no account (rule 17)")
        #expect(try live.open(.words(try #require(world.pair.words)), floor: .relaxedForTests) == result.reopenKey)
        #expect(try live.open(passphrase: .passphrase(Account.passphrase), floor: .relaxedForTests) == result.reopenKey)
    }

    /// RED ON OLD — A SLOW SERVER: the door waits at most its bound, then the act goes on with TODAY'S file (no fields from
    /// an answer that came too late — the caller holds nothing it did not get in time).
    @Test func aSlowServerCostsTheBoundThenTodaysFile() async throws {
        let world = try await Self.syncedWithABackup()
        world.vault.fetchDelay = .seconds(2)
        let clock = ContinuousClock()
        let started = clock.now
        let result = try await Self.press(world, within: .milliseconds(200))
        #expect(clock.now - started < .milliseconds(1500), "the bound, never the slow read")
        #expect(result.outcome == .made)
        #expect(Self.isTodays(try Self.liveKeyFile(world)), "past the bound: today's file")
        try await Task.sleep(for: .milliseconds(2200))
    }

    /// GUARD (green on both sides): offline — the act goes on with today's file.
    @Test func offlineTodaysFile() async throws {
        let world = try await Self.syncedWithABackup()
        world.vault.reachable = false
        let result = try await Self.press(world)
        #expect(result.outcome == .made)
        #expect(Self.isTodays(try Self.liveKeyFile(world)), "offline: today's file")
    }
}
