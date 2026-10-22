//
//  KeychainTripwireTests.swift
//  VariorumTests
//
//  Pre-13u Act 9 (F4) — the structural guard between test code and the
//  author's live custody (VX-329 U1: today's E2EE custody, which this guard
//  was born for, left with today's road; the guard stands for the road's). The rule existed only as a plan-file
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
    @Test func theTripwireIsArmedInThisTestProcess() {
        #expect(KeychainTestTripwire.armed,
                "a test process must be detected — this whole guard rides on it")
        #expect(KeychainTestTripwire.realScopes.contains("Variorum"))
        #expect(KeychainTestTripwire.realScopes.contains("Variorum-dev"))
    }

    // (VX-329 U1: the leaf pins — every mutation leaf of today's E2EE sync custody refusing under a real scope, the live
    // leaves' mapping, a throwaway scope writing for real — drove `E2EEKeychainStorage`, deleted with today's custody.
    // The protection road's families refuse through the same tripwire (`ProtectionKeychain.refuseUnderTest`), pinned in
    // its own suites.)
}
