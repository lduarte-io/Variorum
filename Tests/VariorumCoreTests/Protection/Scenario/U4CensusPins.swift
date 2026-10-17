//
//  U4CensusPins.swift
//  VariorumCoreTests — VX-378 U4 resumption, piece 4: THE CENSUS CLASSES' MODEL
//  FIXES, each pinned red-first (the stopped U4's census, re-read under her
//  rulings at the U4 stop — the plan's §8 U4 RESUMPTION RECORD, piece 4).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-378 U4 — the census classes' model fixes (red on the tree before each)")
struct U4CensusPins {
    /// CLASS (G) — rule 20: a crashed Make this my library on a SYNCED Standard
    /// library never stays in flight. Before the swap a resume holds no copy key
    /// and rolls back; the resume used to run the steps before the stage first
    /// and stop at the own Apple key's fresh-vault check (decision 35 — the act
    /// isn't marked synced, so the resume reads no vault), leaving the act in
    /// flight (census seed 21 sequence 471).
    @Test func aCrashedMakeThisMyLibraryOnASyncedLibraryNeverStaysInFlight() async throws {
        for crashAt in 1...12 {
            let (world, _) = try await syncedWorld(.standard, devices: ["macA", "macB"])
            await world.done([.launch("macA"), .backup("macA"), .lock("macA")])
            await world.step(.crash(.makeMine("macA", pick: 0, typing: .current), afterWrites: crashAt))
            await world.step(.launch("macA"))
            #expect(world.macA.library?.section.actInFlight == nil, "crash after write \(crashAt): an act is still in flight")
            expectPromisesKept(world, "crash after write \(crashAt)")
        }
    }

    /// CLASS (E) — rule 11 ("the Apple and on-device keychain items deleted …
    /// so your Standard-era backups' quiet locks die with it"): after a keychain
    /// wipe (this Mac remembers nothing, so it takes a fresh device ID — and a
    /// fresh section listing none of the Apple keys it made before), entering
    /// Castle still retires the Apple key the earlier section lists — the one
    /// an older backup's key file is locked under (census seed 21 sequence 756).
    @Test func enteringCastleAfterAKeychainWipeRetiresTheAppleKeysMadeBeforeIt() async throws {
        let world = try await scenarioWorld { try await $0.fresh(on: $0.macA) }
        await world.done([.createLibrary("macB", passphrase: true), .settle, .backup("macB")])
        let before = try #require(world.liveKeyFile(world.macB)?.apple?.keyID)
        await world.step(.iCloudOff("macB"))
        await world.step(.wipeKeychain("macB"))
        await world.step(.crash(.useCastle("macB", .touchID, newWords: false), afterWrites: 8))
        await world.step(.sendLibrary(from: "macB", to: "macA"))
        await world.step(.launch("macB"))
        #expect(world.macB.library?.section.retiredAppleKeyIDs.contains(before) == true,
                "the Apple key made before the wipe wasn't retired at Use Castle")
        expectPromisesKept(world)
    }

    /// CLASS (D) — rule 27 ("A library whose every key-file copy and every
    /// backup are gone is gone"): a memory item that carries NO copy of the key
    /// file can't open anything, so it no longer silences the lobby's honest
    /// refusal (census seed 21 sequence 789: every key file and the memory item
    /// gone, the next open re-writes a memory item with no copy in it, and a
    /// new Mac carries that item along).
    @Test func aMemoryItemWithNoKeyFileCopyDoesntSilenceRule27() async throws {
        let world = try await scenarioWorld { try await $0.fresh(on: $0.macA, passphrase: false) }
        await world.step(.tamperSequence("macA", [.dropWordsLock, .replayMemory, .deleteKeyFileAndMemory]))
        await world.step(.replaceMac("macA", carriesMemory: true))
        expectPromisesKept(world)
    }
}
