//
//  SharedKeychainGroupProbeTests.swift
//  VariorumTests
//
//  pre-13x batch 0 — Q2 and Q5 (design §17b): a synchronizable item written
//  under the SHARED access group is readable on this Mac, and the facts of
//  `kSecAttrSynchronizable` + `kSecAttrAccessGroup` on this macOS point
//  release, measured in the SIGNED test host.
//
//  DISABLED BY DEFAULT — the whole suite is gated on the environment. The
//  13p fact suite deliberately never writes a synchronizable item (test
//  bytes riding into the author's iCloud Keychain); this batch's brief
//  overrides that ONCE, on purpose, for a measurement — so the override is
//  opt-in per run, never a property of the ordinary suite:
//
//      TEST_RUNNER_VARIORUM_SHARED_GROUP_PROBE=1 xcodebuild test \
//        -project Variorum.xcodeproj -scheme Variorum -destination 'platform=macOS' \
//        -only-testing:VariorumTests/SharedKeychainGroupProbeTests
//
//  Everything rides `SharedKeychainGroupProbe`'s THROWAWAY service and a
//  timestamped account, deleted at the end; every status prints as a
//  `PRE13X-PROBE|` line so the memo can quote the run verbatim.
//

import Foundation
import Security
import Testing

@testable import Variorum

@Suite(
    "pre-13x batch 0 — the shared keychain access group (Q2/Q5); DISABLED unless VARIORUM_SHARED_GROUP_PROBE=1",
    .enabled(
        if: SharedKeychainGroupProbe.probeRequested,
        "writes one synchronizable throwaway item (it rides into iCloud Keychain and is deleted) — run deliberately with TEST_RUNNER_VARIORUM_SHARED_GROUP_PROBE=1"))
struct SharedKeychainGroupProbeTests {
    private func entitledGroups() -> [String] {
        guard let task = SecTaskCreateFromSelf(nil) else { return [] }
        return SecTaskCopyValueForEntitlement(task, "keychain-access-groups" as CFString, nil)
            as? [String] ?? []
    }

    /// Q1's runtime half: the signed host carries BOTH groups, the shared
    /// one SECOND, and an item written with no group lands in the FIRST —
    /// which is why the order in the entitlements file is load-bearing.
    @Test func theDefaultGroupIsTheFirstEntitledGroupAndTheSharedOneIsSecond() {
        let groups = entitledGroups()
        let (status, landed) = SharedKeychainGroupProbe.defaultAccessGroup()
        print("PRE13X-PROBE| Q1 entitled keychain-access-groups: \(groups)")
        print("PRE13X-PROBE| Q1 an item written with NO group landed in: \(landed ?? "nil") (add \(SharedKeychainGroupProbe.describe(status)))")
        #expect(groups.count == 2, "two groups: the target's own, then the shared one")
        #expect(groups.last == SharedKeychainGroupProbe.sharedGroup)
        #expect(status == errSecSuccess)
        #expect(landed == groups.first, "no group named ⇒ the FIRST entitled group")
    }

    /// Q2 + Q5: the whole round trip, every status recorded, the must-holds
    /// asserted through the report.
    @Test func aSynchronizableItemUnderTheSharedGroupRoundTripsOnThisMac() {
        let device = Host.current().localizedName ?? "this Mac"
        let report = SharedKeychainGroupProbe.runLocalRoundTrip(deviceName: device)
        for line in report.lines { print("PRE13X-PROBE| \(line)") }
        #expect(report.passed, "must-hold steps failed: \(report.failures)")
    }
}
