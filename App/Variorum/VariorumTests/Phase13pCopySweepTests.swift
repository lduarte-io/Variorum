//
//  Phase13pCopySweepTests.swift
//  VariorumTests
//
//  Phase 13p, Batch 4 — THE HONEST-COPY SWEEP, made structural.
//
//  Batch 2 shipped the Mac's disclosure sentences and pinned the ruled ones
//  byte-for-byte (the per-mode honesty grammar). What was missing is the
//  sweep's own guarantee: that EVERY gate has its sentences at all, that
//  they differ from each other, and that the ruled non-goal is stated
//  somewhere a reader choosing a posture will meet it. pre-13x 2a: the
//  presets and the escrow dial are gone (§13); the two POSTURES speak in
//  their place (copy §1).
//
//  Why that matters more here than in most panes: this is the one surface in
//  the app whose whole claim is that it says what is actually so. A future
//  gate added without its disclosure would not look broken — it would look
//  finished and say nothing, which is the failure R13p-16 refused in another
//  form (*"it makes users think privacy is in place that just isn't"*).
//  These pins fail the day such a gate appears.
//
//  Copy TASTE is 13s's; copy PRESENCE is a correctness property, and this is
//  where it is kept.
//
//  VX-329 U1 — THE RELEASE SWITCH: the per-gate and per-posture disclosures
//  (`StoreAtOpenMode`'s labels and sentences, the posture cards, the lobby's
//  dead end, the envelope-naming error line, `openAppIsReadable`) were today's
//  road's copy and were deleted with it — their pins with them. What the road
//  still speaks stays pinned here: keystone 4 (open means readable, locking
//  ends it) and the plain-text escape's warning in Castle. The road's own
//  disclosures are `ProtectionWords`' (its suites).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("13p — the honest-copy sweep (what the road still speaks)")
struct Phase13pCopySweepTests {
    /// **THE NAMED NON-GOAL IS NAMED.** The plan declines exactly one threat (shape B's — an attacker at an open,
    /// unlocked app); keystone 4 says it, with the honest answer beside it.
    @Test func theOpenAppIsReadableLineStatesTheDecline() {
        #expect(ProtectionCopy.keystoneOpenMeansReadable.contains("open and unlocked"))
        #expect(ProtectionCopy.keystoneOpenMeansReadable.contains("readable"))
        #expect(ProtectionCopy.keystoneOpenMeansReadable.contains("Locking is how you end that"))
    }

    @Test func thePlainTextEscapeWarnsUnderLockedDown() {
        // VX-307 U2c (VX-379's row — a justified edit: the warning speaks rule 11's words now, "a plain copy on disk
        // would undo the promise; it is your call"; the warning itself stands).
        #expect(ProtectionCopy.plaintextExportUnderLockedDown
            .contains("would undo Castle's promise"))
    }
}
