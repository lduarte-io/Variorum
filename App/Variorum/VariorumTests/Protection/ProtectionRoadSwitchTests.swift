//
//  ProtectionRoadSwitchTests.swift
//  VariorumTests — VX-306 U1b piece 1: THE ONE SWITCH (`notes/plans/vx-306-castle-open-road.md` §2 U1b, the
//  Release check). The new open road is live only in a DEBUG build on the MAC; the value is a compile-time
//  fact (the `#if DEBUG` arm), never a default or an environment key; and a test bootstrap runs today's road
//  unless a pin turns the new one on — so the existing route suites are the evidence that the switch forced off
//  leaves today's road as it was. The third leg of the check is `xcodebuild -configuration Release build`
//  (the record).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-306 U1b — the one switch: the new road only in a Debug build on the Mac")
@MainActor
struct ProtectionRoadSwitchTests {
    @Test func theRuleIsDebugAndTheMacAndNothingElse() {
        #expect(ProtectionRoad.live(debug: true, mac: true))
        #expect(!ProtectionRoad.live(debug: false, mac: true), "a Release Mac build runs today's road")
        #expect(!ProtectionRoad.live(debug: true, mac: false), "the phone keeps today's road this unit (P-VX306-U1b-1)")
        #expect(!ProtectionRoad.live(debug: false, mac: false))
    }

    /// This test bundle is a Debug Mac build: the switch reads its rule over the compile-time facts.
    @Test func thisDebugMacBuildReadsTheSwitchOn() {
        #expect(ProtectionRoad.isDebugBuild)
        #expect(ProtectionRoad.isMac)
        #expect(ProtectionRoad.newRoadIsLive == ProtectionRoad.live(debug: ProtectionRoad.isDebugBuild, mac: ProtectionRoad.isMac))
        #expect(ProtectionRoad.newRoadIsLive)
    }

    /// The Release arm is COMPILE-TIME: `isDebugBuild` is `true` only inside `#if DEBUG`, `false` in its
    /// `#else`, and the switch has no other input — no defaults key, no environment, no launch argument.
    @Test func theReleaseArmIsTheCompileTimeElseAndNothingCanFlipIt() throws {
        let source = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
                .appendingPathComponent("Shared/Protection/ProtectionRoad.swift"),
            encoding: .utf8)
        #expect(source.contains(
            "static let isDebugBuild: Bool = {\n        #if DEBUG\n        return true\n        #else\n        return false\n        #endif\n    }()"))
        #expect(source.contains("static let newRoadIsLive: Bool = live(debug: isDebugBuild, mac: isMac)"))
        for input in ["UserDefaults", "ProcessInfo", "environment", "CommandLine"] {
            #expect(!source.contains(input), "the switch reads nothing at run time (\(input))")
        }
    }

    /// The test override: a bootstrap built under a test opener runs TODAY's road unless a pin turns the new
    /// road on — the existing route suites (`Phase13pLobbyTests`, `AppBootstrapOffMainTests`, …) run unchanged.
    @Test func aTestBootstrapRunsTodaysRoadUnlessAPinTurnsTheNewOneOn() async throws {
        let key = StoreKey.mint()
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(
            key: key, passphrase: "sesame",
            kdf: PassphraseKDF.Descriptor(
                algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13, memoryKiB: 256, iterations: 1,
                parallelism: 1, salt: PassphraseKDF.randomSalt(), outputBytes: 32))
        // Today's road: a passphrase wrap with no Apple copy derives Castle; always-ask is the passphrase gate.
        let gate = StoreLaunchGate.scripted(
            dials: ProtectionDials(alwaysAsk: true), backing: InMemoryStoreKeyGuardBacking(), envelope: envelope)
        let bootstrap = AppBootstrap(
            testOpener: { .failure(AppDatabase.StoreOpenError(storePath: "", reason: "never opened")) },
            gate: gate)
        #expect(!bootstrap.newRoad)
        await bootstrap.awaitOpen()
        guard case .locked(let lobby) = bootstrap.state else {
            Issue.record("today's road routes a demanded gate to today's lobby: \(bootstrap.state)")
            return
        }
        #expect(lobby.demand == .passphrase)
        #expect(lobby.passphraseOffered)
    }
}
