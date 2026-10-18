//
//  U4PromiseCheckTests.swift
//  VariorumCoreTests — VX-378 U4: EACH PROMISE CATCHES ITS OWN BREACH. A
//  promise that can never fire would bless whatever the model does; here each
//  of the nine is shown red on a world with its breach planted by hand (and
//  quiet on the same world without it), so a green soak means the model kept
//  it — never that the checker was blind.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-378 U4 — each promise catches a breach planted by hand")
struct U4PromiseCheckTests {
    static func promises(_ found: [Violation]) -> Set<Int> { Set(found.map(\.promise)) }

    /// 1 — a silent item for an EARLIER key of a Castle library (rule 11).
    @Test func onePostureCatchesAQuietRoadToAnEarlierKey() async throws {
        let world = try await scenarioWorld { try await $0.fresh(on: $0.macA) }
        await world.done([.launch("macA")])
        let k1 = try #require(world.macA.library?.key)
        await world.done([.useCastle("macA", .alwaysAsk, newWords: false)])
        #expect(world.onePosture(world.macA, settled: true).isEmpty)
        world.macA.keychain.local[KName.custody(SWorld.scope, PF.fp(k1), .silent)] = KItem(value: .key(k1))
        let found = world.onePosture(world.macA, settled: true)
        #expect(found.contains { $0.detail.contains("an earlier key") }, "\(found)")
    }

    /// 2 — Standard with its Apple road and its on-device item gone, unrepaired.
    @Test func standardCatchesALostQuietRoad() async throws {
        let world = try await scenarioWorld { try await $0.fresh(on: $0.macA) }
        await world.done([.launch("macA")])
        #expect(world.standardHandsEverythingOut(world.macA).isEmpty)
        world.macA.keychain.synced.removeAll()
        world.macA.keychain.local = world.macA.keychain.local.filter { $0.key.service != ProtectionNames.custodyService }
        #expect(world.standardHandsEverythingOut(world.macA).count == 2)
    }

    /// 3 — a silent sync-keys item holding a Castle account's current row key;
    /// an earlier row key gone from the vault.
    @Test func theAccountCatchesAQuietRowKeyAndALostEarlierKey() async throws {
        let (world, account) = try await syncedWorld(.standard, devices: ["macA"])
        await world.done([.launch("macA"), .useCastle("macA", .alwaysAsk, newWords: false)])
        #expect(world.accountOnePosture(settled: false).isEmpty)
        let keys = try #require(world.accountMaster(account).flatMap { try? world.server.snapshot(account)?.vault.keys(master: $0) })
        world.macA.keychain.local[KName.syncKeys(SWorld.scope, account, .silent)] = KItem(value: .syncKeys(keys))
        #expect(world.accountOnePosture(settled: false).contains { $0.detail.contains("silent sync-keys item") })
        world.macA.keychain.local[KName.syncKeys(SWorld.scope, account, .silent)] = nil
        world.server.accounts[account]?.vault.earlierRowKeys = [:]
        #expect(world.accountOnePosture(settled: false).contains { $0.detail.contains("gone from the vault") })
    }

    /// 4(a) — THE FLOOR (her ruling at the U4 stop): a copy whose own key
    /// file no longer opens with the secrets it was made with.
    @Test func theFloorCatchesACopyThatNoLongerOpensWithTheSecretsItWasMadeWith() async throws {
        let world = try await scenarioWorld { try await $0.fresh(on: $0.macA) }
        await world.done([.launch("macA"), .backup("macA")])
        #expect(world.coreSentence(world.macA).isEmpty)
        let (id, copy) = try #require(world.truth.copies.sorted { $0.key < $1.key }.first { $0.value.madeOn == "macA" })
        #expect(copy.madeWithPassphrase != nil || copy.madeWithWords != nil, "the write recorded no pair")
        let pairPath = SPath.pair(of: String(id.dropFirst("container:".count)))
        var file = try #require(world.macA.container.files[pairPath]?.keyFile)
        file.passphrase = nil
        file.words = nil
        file.masterWordsCopy = nil
        world.macA.container.files[pairPath] = .keyFile(file)
        let found = world.coreSentence(world.macA)
        #expect(found.contains { $0.detail.contains("the secrets it was made with") }, "\(found)")
    }

    /// 4(b) — CAUGHT UP: a library of its own whose key file (and sealed copy)
    /// her current secrets no longer open.
    @Test func caughtUpCatchesALibraryTodaysSecretsDontOpen() async throws {
        let world = try await scenarioWorld { try await $0.fresh(on: $0.macA) }
        await world.done([.launch("macA"), .changePassphrase("macA")])
        #expect(world.coreSentence(world.macA).isEmpty)
        var live = try #require(world.liveKeyFile(world.macA))
        live.passphrase = nil
        live.words = nil
        live.masterWordsCopy = nil
        world.macA.container.files[SPath.liveKeyFile] = .keyFile(live)
        world.macA.keychain.local = world.macA.keychain.local.filter { $0.key.service != ProtectionNames.memoryService }
        let found = world.coreSentence(world.macA)
        #expect(found.contains { $0.detail.contains("it has caught up") }, "\(found)")
    }

    /// 4(c) — THE CARRY: the key file's history dropped: today's secrets no
    /// longer reach an older backup of the same library whose own file wants
    /// that day's secrets.
    @Test func theCoreSentenceCatchesADroppedHistory() async throws {
        let world = try await scenarioWorld { try await $0.fresh(on: $0.macA) }
        await world.done([.launch("macA"), .backup("macA"), .changePassphrase("macA"), .regenerateWords("macA"),
                          .useCastle("macA", .alwaysAsk, newWords: false)])
        #expect(world.coreSentence(world.macA).isEmpty)
        var live = try #require(world.liveKeyFile(world.macA))
        live.history = []
        world.macA.container.files[SPath.liveKeyFile] = .keyFile(live)
        world.macA.keychain.local = world.macA.keychain.local.filter { $0.key.service != ProtectionNames.memoryService }
        #expect(Self.promises(world.coreSentence(world.macA)) == [4])
    }

    /// 5 — a copy no road opens; a closed library no road opens while the
    /// lobby says nothing (rule 27).
    @Test func everyCopyOpensCatchesAStrandedCopyAndASilentLobby() async throws {
        let world = try await scenarioWorld { try await $0.fresh(on: $0.macA) }
        await world.done([.launch("macA"), .backup("macA")])
        #expect(world.everyCopyOpens().isEmpty)
        let (id, copy) = try #require(world.truth.copies.first)
        var image = try #require(world.macA.container.files[String(id.dropFirst("container:".count))]?.library)
        image.fingerprint = PF.fp(world.mintKey())
        world.macA.container.files[String(id.dropFirst("container:".count))] = .library(image)
        world.truth.copies[id] = CopyTruth(libraryID: copy.libraryID, fingerprint: image.fingerprint, madeAt: copy.madeAt,
                                           madeOn: copy.madeOn, mode: copy.mode, holder: copy.holder)
        #expect(world.everyCopyOpens().contains { $0.detail.contains("opens by no road") })
        world.lock(world.macA)
        var slot = try #require(world.macA.slot)
        slot.fingerprint = PF.fp(world.mintKey())
        world.macA.container.files[SPath.slot] = .library(slot)
        #expect(world.everyCopyOpens().contains { $0.detail.contains("the lobby doesn't say so") })
    }

    /// 6 — copies left paused, a plan left on disk.
    @Test func crashSafeCatchesAHalfDoneState() async throws {
        let world = try await scenarioWorld { try await $0.fresh(on: $0.macA) }
        await world.done([.launch("macA")])
        #expect(world.crashSafe(world.macA).isEmpty)
        world.macA.paused = true
        let plan = ProtectionPlan(libraryID: "x", deviceID: "y", sequence: 1, act: .deviceSettings,
                                  steps: [PlanStep(name: "settings")], createdAt: world.clock, parameters: nil)
        world.macA.container.files[SPath.plan] = .plan(try plan.sealed(under: world.mintKey()))
        #expect(world.crashSafe(world.macA).count == 2)
    }

    /// 7 — the oracle calls for an older copy's notice when the library file
    /// is replayed (and none when nothing is remembered); the open saying
    /// anything else is caught; a memory naming another device is caught.
    @Test func fourThingsCatchesAWrongNoticeAndAForeignMemory() async throws {
        let world = try await scenarioWorld { try await $0.fresh(on: $0.macA) }
        await world.done([.launch("macA")])
        let k1 = try #require(world.macA.library?.key)
        let oldSlot = world.macA.container.files[SPath.slot]
        await world.done([.useCastle("macA", .alwaysAsk, newWords: false)])
        let library = try #require(world.macA.library)
        let executor = try #require(world.macA.executor)
        #expect(world.expectedNotice(world.macA, key: library.key, also: [], executor: executor) == nil)
        #expect(world.fourThings(world.macA).isEmpty)
        let liveSlot = world.macA.container.files[SPath.slot]
        world.macA.container.files[SPath.slot] = oldSlot
        if case .olderCopy? = world.expectedNotice(world.macA, key: k1, also: [library.key], executor: executor) {} else {
            Issue.record("a replayed library file calls for no older copy's notice")
        }
        let memoryName = KName.memory(SWorld.scope, library.record!.libraryID)
        let memory = world.macA.keychain.local[memoryName]
        world.macA.keychain.local[memoryName] = nil
        #expect(world.expectedNotice(world.macA, key: k1, also: [library.key], executor: executor) == nil,
                "absence is never a notice")
        world.macA.keychain.local[memoryName] = memory
        world.macA.container.files[SPath.slot] = liveSlot
        // The open saying nothing where the oracle calls for a notice: caught
        // at the launch (`noticeMismatches`, promise 7).
        world.truth.noticeMismatches.append(("macA", "planted"))
        #expect(Self.promises(world.foundAtTheWrite()) == [7])
        var other = library
        other.section.deviceID = world.rng.uuid()
        world.macA.library = other
        #expect(Self.promises(world.fourThings(world.macA)) == [7])
    }

    /// 8 — a delete that leaves the library in the live place with no road.
    @Test func deletedOnlyAfterReplacementCatchesAStrandingDelete() async throws {
        let world = try await scenarioWorld { try await $0.fresh(on: $0.macA, mode: .castle, gate: .alwaysAsk) }
        try world.deleting(world.macA, "harmless") { world.macA.keychain.local[KName(service: "x", account: "y")] = nil }
        #expect(world.truth.strandings.isEmpty)
        // (Use Castle's closing backup carries the key too — a road the check is
        // right to count; the breach takes every key file.)
        try world.deleting(world.macA, "every key file") {
            world.macA.container.files = world.macA.container.files.filter { $0.value.keyFile == nil }
            world.macA.keychain.local = world.macA.keychain.local.filter { $0.key.service != ProtectionNames.memoryService }
        }
        #expect(world.foundAtTheWrite().contains { $0.promise == 8 })
    }

    /// 9 — the mode moved at a step that isn't a deliberate act; a tamper group
    /// that weakens Castle; Make this my library leaving Castle.
    @Test func nothingSilentCatchesAQuietPostureChange() async throws {
        let world = try await scenarioWorld { try await $0.fresh(on: $0.macA, mode: .castle, gate: .alwaysAsk) }
        await world.done([.launch("macA")])
        let before = ["macA": world.posture(world.macA)]
        #expect(world.noSilentChange(.lock("macA"), before: before, crashedBefore: []).isEmpty)
        var slot = try #require(world.macA.slot)
        slot.record?.mode = .standard
        world.macA.container.files[SPath.slot] = .library(slot)
        #expect(Self.promises(world.noSilentChange(.lock("macA"), before: before, crashedBefore: [])) == [9])
        #expect(Self.promises(world.sealed(world.macA, before: before["macA"]!, tampers: [.replayPlan, .deleteMemoryItem])) == [9])
        #expect(world.sealed(world.macA, before: before["macA"]!, tampers: [.replayBothHomes]).isEmpty, "L4 — the complete replay")
        slot.libraryID = world.rng.uuid()
        world.macA.container.files[SPath.slot] = .library(slot)
        #expect(Self.promises(world.noSilentChange(.makeMine("macA", pick: 0, typing: .itsDay), before: before, crashedBefore: [])) == [9])
    }
}
