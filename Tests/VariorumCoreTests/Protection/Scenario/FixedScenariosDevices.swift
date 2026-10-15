//
//  FixedScenariosDevices.swift
//  VariorumCoreTests — VX-305 U4: the fixed scenarios about DEVICES — Touch
//  ID (an enrollment change, the lid, the moved hash), replacement and cloned
//  Macs, two macOS logins on one Mac, this Mac's facts in two homes and the
//  replays (§6's list).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-305 U4 fixed — devices: Touch ID, replacement and cloned Macs, two logins, replays")
struct DeviceScenarios {
    /// A crash at every write of this Mac's settings acts (the gate style, the
    /// re-arm), then a relaunch: each finishes or rolls back (promise 6) —
    /// the plan-less finish needs nothing only the press had.
    @Test func aCrashAtEveryWriteOfASettingsChangeSettles() async throws {
        for act in [Action.setGate("macA", .alwaysAsk), .setScheduledExport("macA", true), .setIdleLock("macA", minutes: 30)] {
            for n in 1...8 {
                let world = try scenarioWorld { w in try w.today(on: w.macA, TodaySpec(mode: .castle, gate: .touchID)) }
                await world.done([.launch("macA")])
                await world.step(.crash(act, afterWrites: n))
                await world.step(.launch("macA"))
                #expect(world.macA.library?.section.actInFlight == nil, "\(act) crashed after write \(n): still in flight")
                expectPromisesKept(world, "\(act) after write \(n)")
            }
        }
    }

    /// "the key file and memory item both deleted on a local-only Castle
    /// library: the lobby still opens it" — through the newest pair's key
    /// file; the live key file comes back from that pair (its Apple wraps
    /// never re-added), and the next act runs whole.
    @Test func theKeyFileAndTheMemoryItemBothDeleted() async throws {
        for gate in [GateStyle.touchID, .alwaysAsk] {
            let world = try scenarioWorld { w in try w.today(on: w.macA, TodaySpec(mode: .castle, gate: gate)) }
            await world.done([.launch("macA"), .backup("macA"), .tamper("macA", .deleteKeyFileAndMemory)])
            #expect(world.macA.isOpen, "\(gate): the lobby didn't open it")
            #expect(world.liveKeyFile(world.macA)?.fingerprint == world.macA.slot?.fingerprint, "\(gate): no live key file came back")
            await world.done([.useStandard("macA"), .settle])
            #expect(world.macA.slot?.record?.mode == .standard)
            expectPromisesKept(world, "\(gate)")
        }
    }

    /// "a replacement Mac's first open: it starts on Always ask, and Touch ID
    /// comes on only from Settings" — on new hardware, its memory item left
    /// behind (Migration Assistant reportedly doesn't carry Local Items — the
    /// Apple facts §3.7): it takes over the Apple key its live key file's wrap
    /// names as its own and every retired id (§3.5), so promise 3 settles and
    /// its Use Castle retires that key.
    @Test func aReplacementMacsFirstOpen() async throws {
        for carriesMemory in [false, true] {
            let world = try scenarioWorld { w in try w.today(on: w.macA, TodaySpec(mode: .standard)) }
            await world.done([.launch("macA"), .setGate("macA", .alwaysAsk), .settle])
            let own = try #require(world.liveKeyFile(world.macA)?.apple?.keyID)
            await world.done([.replaceMac("macA", carriesMemory: carriesMemory), .settle])
            let section = try #require(world.macA.library?.section)
            #expect(section.settings.gateStyle == .alwaysAsk, "carries memory: \(carriesMemory)")
            #expect(section.ownLibraryAppleKeyIDsToRetire.contains(own), "carries memory: \(carriesMemory): its predecessor's own key not taken over")
            // Touch ID comes on only from Settings (the passphrase typed there).
            #expect(world.macA.keychain.local.values.allSatisfy { !$0.touchID })
            await world.done([.useCastle("macA", .alwaysAsk, newWords: false), .settle])
            #expect(world.readableAppleKeys(world.macA)[own] == nil, "carries memory: \(carriesMemory): the predecessor's own key survived Use Castle")
            await world.done([.setGate("macA", .touchID)])
            #expect(world.macA.keychain.local.values.contains { $0.touchID })
            expectPromisesKept(world, "carries memory: \(carriesMemory)")
        }
    }
}
