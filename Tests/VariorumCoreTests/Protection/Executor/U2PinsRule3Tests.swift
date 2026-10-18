//
//  U2PinsRule3Tests.swift
//  VariorumCoreTests — VX-378 U2 piece C: RULE 3 (`notes/CastleRules.md`:
//  "Every library is asked for a passphrase … always right before the first
//  backup and at the first launch after a quiet road has failed"). The facts
//  are read through their printed form so the pins compile on the tree before
//  the piece and the red-on-old run is honest.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-378 U2 — rule 3: the passphrase facts, and the two moments the model asks")
struct U2PinsRule3Tests {
    /// A library with no passphrase lock (its words only) and no backup yet.
    func noPassphraseWorld() throws -> AWorld {
        var world = try AWorld(.standard)
        world.liveFile = try KeyFile.building(
            libraryID: world.world.library, key: world.key, epoch: 1,
            locks: NewKeyLocks(words: world.world.w, apple: world.own))
        return world
    }

    @Test func noPassphraseIsAskedForBeforeTheFirstBackup() throws {
        let world = try noPassphraseWorld()
        let acts = "\(try world.assessed().acts)"
        #expect(acts.contains("askPassphrase(") && acts.contains("beforeFirstBackup"), "\(acts)")
    }

    @Test func noPassphraseIsAskedForAtTheLaunchAQuietRoadFailed() throws {
        var world = try noPassphraseWorld()
        // A backup exists, so only the quiet road's failure asks.
        let copyKey = world.key
        let folders = CF.macFolder(world.world.library, CF.macA)
        world.extraEntries = [
            CatalogEntry(place: .container, folders: folders, name: CF.snapshotName(CF.stamp(1), copyKey)),
            CatalogEntry(place: .container, folders: folders, name: CF.pairName(CF.stamp(1), copyKey),
                         bytes: try world.liveFile.encoded()),
        ]
        #expect(!"\(try world.assessed().acts)".contains("askPassphrase("), "asked with every quiet road working")
        world.appleKeys.readable = []
        let acts = "\(try world.assessed().acts)"
        #expect(acts.contains("askPassphrase(") && acts.contains("quietRoadFailed"), "\(acts)")
    }

    @Test func aLibraryWithAPassphraseIsNeverAsked() throws {
        var world = try AWorld(.standard)
        world.appleKeys.readable = []
        #expect(!"\(try world.assessed().acts)".contains("askPassphrase("))
    }

    /// The record carries the fact and the executor keeps it fresh: a library
    /// created with nothing typed records none; a passphrase set later is
    /// recorded at that act.
    @Test func theRecordCarriesThePassphraseFactAndTheActsKeepItFresh() async throws {
        let world = ExecutorWorld()
        let executor = ProtectionExecutor(
            leaves: world.leaves,
            configuration: ExecutorConfiguration(scope: EX.scope, libraryID: "", deviceName: "Mac A", floor: PF.floor))
        _ = try executor.createLibrary()
        #expect("\(try #require(world.live?.record))".contains("passphraseSet: false"))
        let fixture = try EX(.standard)
        fixture.world.liveKeyFile?.passphrase = nil
        let other = fixture.executor()
        var library = try fixture.unlocked(other)
        _ = try await other.resetPassphrase(&library, authorization: .plainConfirm, new: "a passphrase at last")
        #expect("\(try #require(fixture.liveRecord))".contains("passphraseSet: true"))
    }
}

@Suite("VX-378 U2 — rule 3: the dismissals are a recorded fact")
struct U2PassphraseFactTests {
    @Test func aDismissalIsCountedInTheRecord() throws {
        let fixture = try EX(.standard)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        try executor.recordPassphraseReminderDismissed(&library)
        try executor.recordPassphraseReminderDismissed(&library)
        #expect(fixture.liveRecord?.reminderDismissals == 2)
        #expect(fixture.liveRecord?.passphraseSet == true)
    }
}
