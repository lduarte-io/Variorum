//
//  KeychainTripwireTests.swift
//  VariorumTests
//
//  Pre-13u Act 9 (F4) — the structural guard between test code and the
//  author's live E2EE custody. The rule existed only as a plan-file
//  sentence and failed once (the 13p-fix R3-1 incident: a revert drill
//  removed a seam's use, fake-driven pins fell through to the real
//  fixed-account leaves, and her live custody was overwritten with test
//  material). Every fixed-account write/delete leaf now refuses from a
//  test process BEFORE any SecItem call.
//
//  RED-ON-OLD, verified by a SAFE behavioral drill (recorded in the Act 9
//  batch record): the detection is forced off AND the family's
//  service/account constants are redirected to a throwaway drill service
//  in the same temporary edit — the leaves then really write (drill
//  service only, never custody), and this suite's refusal assertions go
//  red; restore, green, drill litter deleted. Reverting the detection
//  ALONE against the real constants is exactly the R3-1 act and is never
//  performed.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

/// `.serialized` since 17h: the exact `tripCount == before + 5` below and
/// the new leaf-mapping pin both trip the wire — a global counter — so the
/// suite's own tests must not interleave with each other. (No OTHER suite
/// trips the wire; the leaf-mapping pin's delta assertions tolerate
/// cross-suite noise by construction anyway.)
@Suite("pre-13u — the keychain test-process tripwire (F4)", .serialized)
struct KeychainTripwireTests {
    private func material() -> DeviceKeyMaterial {
        DeviceKeyMaterial(
            masterKey: Data(repeating: 9, count: 32),
            corpusKey: Data(repeating: 8, count: 32), corpusKeyID: "tripwire-corpus",
            journalBridgeKey: Data(repeating: 7, count: 32), journalBridgeKeyID: "tripwire-bridge")
    }

    @Test func theTripwireIsArmedInThisTestProcess() {
        #expect(KeychainTestTripwire.armed,
                "a test process must be detected — this whole guard rides on it")
    }

    /// Every fixed-account WRITE/DELETE leaf refuses, is counted, and
    /// performs zero Keychain traffic (the guard is the first line, before
    /// any encode or SecItem call).
    @Test func fixedAccountMutationsRefuseFromATestProcess() {
        let before = KeychainTestTripwire.tripCount
        #expect(E2EEKeychainStorage.save(material()) == false,
                "the plain write refuses — this exact leaf carried the R3-1 sentinel")
        #expect(E2EEKeychainStorage.saveGated(material()) == false,
                "the gated write refuses")
        #expect(E2EEKeychainStorage.clear() == false, "the clear refuses")
        // 17h R3-5: a tripwire-refused delete answers false — the release
        // did not happen, and saying otherwise would be the dropped-status
        // class this entry closes.
        #expect(E2EEKeychainStorage.deletePlainItem() == false)
        #expect(E2EEKeychainStorage.deleteGatedItem() == false)
        #expect(KeychainTestTripwire.tripCount == before + 5,
                "all five mutation leaves tripped, none silently proceeded")
    }

    /// 17h R3-4's second half — the NAME→FUNCTION mapping of
    /// `E2EECustodyLeaves.live`, pinned with ZERO Keychain traffic: each
    /// live mutation leaf refuses from a test process AND records WHICH
    /// static function it reached, so a leaves struct wired to the wrong
    /// function (`deletePlain` reaching `deleteGatedItem`) records the
    /// wrong name: red. Containment over the per-call delta — a concurrent
    /// suite's trips could only ADD names, never remove the expected one.
    /// (The composition half — which leaf plays which handover role —
    /// is `CustodyHandoverTests`' wiring pins.)
    @Test func theLiveLeavesReachTheStaticFunctionsTheirNamesClaim() {
        func refusedNames(during act: () -> Void) -> [String] {
            let before = KeychainTestTripwire.refusedLeafNames.count
            act()
            return Array(KeychainTestTripwire.refusedLeafNames.dropFirst(before))
        }
        #expect(refusedNames { _ = E2EECustodyLeaves.live.deletePlain() }
            .contains("deletePlainItem"))
        #expect(refusedNames { _ = E2EECustodyLeaves.live.deleteGated() }
            .contains("deleteGatedItem"))
        #expect(refusedNames { _ = E2EECustodyLeaves.live.saveGated(material()) }
            .contains("saveGated"))
        #expect(refusedNames { _ = E2EECustodyLeaves.live.savePlain(material()) }
            .contains("save"))
    }
}
