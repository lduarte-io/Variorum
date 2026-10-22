//
//  MobileKDFLatencyTests.swift
//  VariorumMobileTests
//
//  Phase 14b, batch 3 (L12) — the phone half of R-7's latency condition.
//

import CryptoKit
import Foundation
import Testing
import VariorumCore

@Suite("Phone KDF latency (Phase 14b, L12)")
struct MobileKDFLatencyTests {
    /// R-7's condition: KDF latency measured on BOTH form factors. This is
    /// the MOBILE-SUITE number — a SIMULATOR number, which is NOT the
    /// device number: the device number lands at the gate through the
    /// enrollment flow itself, which measures and shows its derivation
    /// duration on its own surface (today's `EncryptionSession.lastKDFSeconds` —
    /// deleted with today's road at VX-329 U1).
    /// The assertion is existence-and-sanity, never a latency budget — sim
    /// hardware is not the phone's.
    @Test func v1DescriptorDerivationMeasuresOnThisSimulator() throws {
        let descriptor = PassphraseKDF.Descriptor.v1(salt: Data(repeating: 7, count: 16))
        let clock = ContinuousClock()
        let start = clock.now
        _ = try PassphraseKDF.deriveKey(
            passphrase: "measure-me-simulator", descriptor: descriptor)
        let elapsed = clock.now - start
        let seconds = Double(elapsed.components.seconds)
            + Double(elapsed.components.attoseconds) / 1e18
        print(String(
            format: "Phase 14b L12 — KDF v1 derivation on the iOS SIMULATOR: %.3f s "
                + "(NOT the device number; the device number is read off the "
                + "enrollment flow's surface at the gate)", seconds))
        #expect(seconds > 0)
    }
}
