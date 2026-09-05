//
//  KeychainTripwireTests.swift
//  VariorumTests
//
//  Pre-13u Act 9 (F4) — the structural guard between test code and the
//  author's live E2EE custody. The rule existed only as a plan-file
//  sentence and failed once (the 13p-fix R3-1 incident: a revert drill
//  removed a seam's use, fake-driven pins fell through to the real
//  fixed-account leaves, and her live custody was overwritten with test
//  material). Every write/delete leaf refuses from a test process BEFORE
//  any SecItem call.
//
//  pre-13x 1a: the family is PER STORE (`<scope>-<storeID>-…`), so the guard
//  names the REAL scopes (the store variants' raw values, and the legacy
//  fixed accounts) rather than fixed account names — a throwaway scope
//  writes for real (the store-key family's precedent), which is what lets
//  the per-store custody be pinned against the real Keychain.
//
//  RED-ON-OLD (the original F4 drill, recorded in the Act 9 batch record):
//  the detection forced off AND the constants redirected to a throwaway
//  service in one temporary edit; the refusal assertions went red;
//  restored. Reverting the detection ALONE against the real constants is
//  exactly the R3-1 act and is never performed.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

/// `.serialized` since 17h: the exact trip-count deltas below trip a global
/// counter, so the suite's own tests must not interleave.
@Suite("pre-13u — the keychain test-process tripwire (F4)", .serialized)
struct KeychainTripwireTests {
    private func record() -> SyncCustodyRecord {
        SyncCustodyRecord(
            deviceID: "tripwire-device",
            material: DeviceKeyMaterial(
                masterKey: Data(repeating: 9, count: 32),
                corpusKey: Data(repeating: 8, count: 32), corpusKeyID: "tripwire-corpus",
                journalBridgeKey: Data(repeating: 7, count: 32), journalBridgeKeyID: "tripwire-bridge"))
    }

    private var realScope: SyncCustodyScope {
        SyncCustodyScope(scope: AppDatabase.StoreVariant.real.rawValue, storeID: "tripwire-store")
    }

    @Test func theTripwireIsArmedInThisTestProcess() {
        #expect(KeychainTestTripwire.armed,
                "a test process must be detected — this whole guard rides on it")
        #expect(KeychainTestTripwire.realScopes.contains("Variorum"))
        #expect(KeychainTestTripwire.realScopes.contains("Variorum-dev"))
    }

    /// Every WRITE/DELETE leaf under a REAL scope refuses, is counted, and
    /// performs zero Keychain traffic (the guard is the first line, before
    /// any encode or SecItem call).
    @Test func realScopeMutationsRefuseFromATestProcess() {
        let before = KeychainTestTripwire.tripCount
        #expect(E2EEKeychainStorage.save(record(), scope: realScope) == false,
                "the bound write refuses — this exact leaf carried the R3-1 sentinel")
        #expect(E2EEKeychainStorage.saveGated(record(), scope: realScope) == false,
                "the gated write refuses")
        // 17h R3-5: a tripwire-refused delete answers false — the release
        // did not happen.
        #expect(E2EEKeychainStorage.deletePlainItem(scope: realScope) == false)
        #expect(E2EEKeychainStorage.deleteGatedItem(scope: realScope) == false)
        #expect(E2EEKeychainStorage.legacyDelete() == false, "the legacy fixed accounts are guarded too")
        #expect(KeychainTestTripwire.tripCount == before + 5,
                "all five mutation leaves tripped, none silently proceeded")
    }

    /// The leaf-mapping pin (17h R3-4): `E2EECustodyLeaves.live(scope:)`
    /// reaches the static function its name claims — under a real scope
    /// each refuses and records WHICH function it reached.
    @Test func theLiveLeavesReachTheStaticFunctionsTheirNamesClaim() {
        func refusedNames(during act: () -> Void) -> [String] {
            let before = KeychainTestTripwire.refusedLeafNames.count
            act()
            return Array(KeychainTestTripwire.refusedLeafNames.dropFirst(before))
        }
        let leaves = E2EECustodyLeaves.live(scope: realScope)
        #expect(refusedNames { _ = leaves.deletePlain() }.contains("deletePlainItem"))
        #expect(refusedNames { _ = leaves.deleteGated() }.contains("deleteGatedItem"))
        #expect(refusedNames { _ = leaves.saveGated(record()) }.contains("saveGated"))
        #expect(refusedNames { _ = leaves.savePlain(record()) }.contains("save"))
    }

    /// A THROWAWAY scope is not guarded — it writes for real, under its own
    /// account, and cleans up: the per-store pins' road (never a real scope).
    @Test func aThrowawayScopeWritesForRealAndNeverTrips() {
        let scope = SyncCustodyScope(scope: "1a-tripwire-\(UUID().uuidString)", storeID: "s")
        let before = KeychainTestTripwire.tripCount
        let saved = E2EEKeychainStorage.save(record(), scope: scope)
        defer { _ = E2EEKeychainStorage.deletePlainItem(scope: scope) }
        #expect(saved, "a throwaway scope lands (the signed host has the keychain identity)")
        #expect(E2EEKeychainStorage.load(scope: scope) == record())
        #expect(KeychainTestTripwire.tripCount == before, "nothing tripped")
    }
}
