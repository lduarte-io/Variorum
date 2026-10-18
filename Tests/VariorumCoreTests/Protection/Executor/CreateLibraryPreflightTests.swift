//
//  CreateLibraryPreflightTests.swift
//  VariorumCoreTests — VX-306 ladder round 2, m3: THE CREATION MEETS ITS NO-CLOBBER BELT BEFORE ITS FIRST WRITE.
//  Before the fix `ProtectionExecutor.createLibrary` minted a key and wrote, in order, the new key's silent item, this
//  Mac's own Apple key and THE LIVE KEY FILE (an atomic replace) — and only then met the library leaf's no-clobber belt
//  ("a library is already in the slot"). So a caller reaching it over a slot a library stands in wrote over that
//  library's key file (rule 1: "as essential as the library itself") and left two orphan keychain items behind the
//  refusal (the trace: the round-1 fix leg's m1, `notes/plans/vx-306-castle-open-road.md` §10). Unreachable from the
//  app after m1 (`.startFresh` is an empty slot by verdict; both faces set the slot aside first) — the act is honest on
//  its own now. Written against the API both trees share (the world's write log and its slot), so the red-on-old run
//  is honest.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-306 ladder r2 m3 — creating a library over a slot a library stands in writes nothing")
struct CreateLibraryPreflightTests {
    private static func executor(_ world: ExecutorWorld) -> ProtectionExecutor {
        ProtectionExecutor(
            leaves: world.leaves,
            configuration: ExecutorConfiguration(scope: EX.scope, libraryID: "", deviceName: "Mac A", floor: PF.floor))
    }

    /// What the refused creation must leave exactly as it stood: the slot, the live key file's bytes, every keychain
    /// item (custody and Apple), what this Mac remembers.
    private struct Standing: Equatable {
        var slotFingerprint: String?
        var slotRecord: ProtectionRecord?
        var liveKeyFile: Data?
        var custody: [CustodyItemFact: StoreKey]
        var appleKeys: Set<String>
        var appleStamps: [String: String]
        var memories: Set<String>

        init(_ world: ExecutorWorld) throws {
            slotFingerprint = world.live?.fingerprint
            slotRecord = world.live?.record
            liveKeyFile = try world.liveKeyFile?.encoded()
            custody = world.custody
            appleKeys = Set(world.icloud.keys.keys)
            appleStamps = world.icloud.stamps
            memories = Set(world.memories.keys)
        }
    }

    /// Runs the refused creation over `world` and checks it wrote nothing, changed nothing and said why.
    private static func expectRefusedWritingNothing(_ world: ExecutorWorld, _ standing: Standing) throws {
        world.writes.removeAll()
        let creating = executor(world)
        var refusal: (any Error)?
        do { _ = try creating.createLibrary(passphrase: "a second library") } catch { refusal = error }
        let error = try #require(refusal, "a creation over a slot a library stands in refuses")
        #expect(world.writes.isEmpty, "the refused creation wrote \(world.writes)")
        #expect(try Standing(world) == standing, "the refused creation changed what stood")
        #expect(creating.configuration.libraryID == "", "the refused creation re-named its executor's library")
        #expect("\(error)" == "libraryAlreadyInSlot", "the refusal names what stands in the slot: \(error)")
    }

    /// A library standing in the slot with its key file beside it (the act's own doc: "in an empty slot").
    @Test func aLibraryInTheSlotRefusesTheCreationBeforeAnyWrite() throws {
        let world = ExecutorWorld()
        _ = try Self.executor(world).createLibrary(passphrase: "the day I left")
        let standing = try Standing(world)
        #expect(standing.liveKeyFile != nil && standing.slotFingerprint != nil && !standing.custody.isEmpty)
        try Self.expectRefusedWritingNothing(world, standing)
    }

    /// The round-1 m1 shape: a RECORD-LESS store in the slot (a key opens it; no protection record inside), its key
    /// file beside it — the state the missing face showed and whose key file the old order wrote over.
    @Test func aRecordLessStoreInTheSlotRefusesTheCreationBeforeAnyWrite() throws {
        let world = ExecutorWorld()
        _ = try Self.executor(world).createLibrary()
        world.live?.record = nil
        let standing = try Standing(world)
        #expect(standing.slotRecord == nil && standing.liveKeyFile != nil)
        try Self.expectRefusedWritingNothing(world, standing)
    }

    /// The empty slot still creates — and a crash's leftovers there (a key file, keychain items, no library: the
    /// creation's own order) never stop the creation from running again (the act's doc: "a crash leaves the slot
    /// empty and the creation runs again").
    @Test func anEmptySlotStillCreatesAndACrashedCreationRunsAgain() throws {
        let world = ExecutorWorld()
        world.crashAfterWrites = 3  // the silent item, the Apple key, the live key file — then the process dies
        #expect(throws: SimulatedCrash.self) { _ = try Self.executor(world).createLibrary() }
        #expect(world.live == nil && world.liveKeyFile != nil, "the crash left the key file and an empty slot")
        world.relaunch()
        let created = try Self.executor(world).createLibrary()
        #expect(world.live?.fingerprint == PF.fp(created.library.key))
        #expect(world.liveKeyFile?.fingerprint == PF.fp(created.library.key))
    }
}
