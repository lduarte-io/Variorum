//
//  ProtectionRoadSwitchTests.swift
//  VariorumTests — VX-306 U1b piece 1: THE ONE SWITCH (`notes/plans/vx-306-castle-open-road.md` §2 U1b), FLIPPED at
//  VX-329 U1 (`notes/plans/vx-329-release-switch.md` §6a): the new open road is the ONLY road, in every build — Debug and
//  Release, the Mac and the phone. The pure rule and its pin stay, flipped; the value is still a compile-time fact
//  (the `#if DEBUG` arm is the rule's only input and it answers true for both), never a default or an environment key.
//  The Release leg of the check is `xcodebuild -configuration Release build` (the U1 record). Today's road — and the
//  test bootstrap that ran it unless a pin turned the new one on — was deleted with the switch.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-306 U1b — the one switch, flipped at VX-329: the new road in every build")
@MainActor
struct ProtectionRoadSwitchTests {
    /// VX-329 U1 supersedes VX-306's Debug-only rule (and U3's phone arm with it): every build takes the new road.
    @Test func theRuleIsTheNewRoadInEveryBuild() {
        #expect(ProtectionRoad.live(debug: true))
        #expect(ProtectionRoad.live(debug: false), "every Release build runs the new road — today's road is gone")
    }

    /// This test bundle is a Debug Mac build: the switch reads its rule over the compile-time fact.
    @Test func thisDebugMacBuildReadsTheSwitchOn() {
        #expect(ProtectionRoad.isDebugBuild)
        #expect(ProtectionRoad.isMac)
        #expect(ProtectionRoad.newRoadIsLive == ProtectionRoad.live(debug: ProtectionRoad.isDebugBuild))
        #expect(ProtectionRoad.newRoadIsLive)
    }

    /// The configuration input is COMPILE-TIME: `isDebugBuild` is `true` only inside `#if DEBUG`, `false` in its
    /// `#else`, and the switch has no other input — no defaults key, no environment, no launch argument — so nothing at
    /// run time can turn today's road back on (there is none to turn on).
    @Test func theReleaseArmIsTheCompileTimeElseAndNothingCanFlipIt() throws {
        let source = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
                .appendingPathComponent("Shared/Protection/ProtectionRoad.swift"),
            encoding: .utf8)
        #expect(source.contains(
            "static let isDebugBuild: Bool = {\n        #if DEBUG\n        return true\n        #else\n        return false\n        #endif\n    }()"))
        #expect(source.contains("static let newRoadIsLive: Bool = live(debug: isDebugBuild)"))
        // CODE lines only — the file's header comment may NAME the inputs it forbids (the orchestrator's fix at the
        // U1b batch, 2026-10-18: the first run matched "environment" inside that comment).
        let code = source.split(separator: "\n", omittingEmptySubsequences: false)
            .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("//") }
            .joined(separator: "\n")
        for input in ["UserDefaults", "ProcessInfo", "environment", "CommandLine"] {
            #expect(!code.contains(input), "the switch reads nothing at run time (\(input))")
        }
    }
}
