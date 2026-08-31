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

@Suite("pre-13u — the keychain test-process tripwire (F4)")
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
        E2EEKeychainStorage.deletePlainItem()
        E2EEKeychainStorage.deleteGatedItem()
        #expect(KeychainTestTripwire.tripCount == before + 5,
                "all five mutation leaves tripped, none silently proceeded")
    }
}
