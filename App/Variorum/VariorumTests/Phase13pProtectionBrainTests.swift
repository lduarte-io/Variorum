//
//  Phase13pProtectionBrainTests.swift
//  VariorumTests
//
//  Phase 13p, Batch 2 (commit 2) — the protection brains. pre-13x batch
//  2a: the POSTURE is derived (never a setting), the effective gate is a
//  pure function of (posture, Castle's gate style), the dials are Castle's
//  two switches with the 13p-era keys read through until §11 retires
//  them, and the presets / the escrow dial / its coupling copy are gone
//  (§13). The reminder-check cadence (R13p-9), the Standard nudge's
//  two-offer eligibility (knot 4's amendment) and the guard backing's
//  scripted custody world stand.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

// VX-329 U1 — THE RELEASE SWITCH: this file's suites pinned today's protection brain — the posture derivation, the
// effective gate and the dials (`Posture`, `StoreAtOpenMode`, `ProtectionDials`), today's copy grammar, the reminder and
// nudge cadence over today's wraps, the guard's scripted custody world, the dials per store id and the legacy
// read-through — all deleted with today's road, their pins with them. What the road still reads stays pinned here: the
// idle clock (`IdleLockClock`, moved byte-for-byte into `ProtectionRoadLock.swift` — the road's relock monitors read it)
// and the idle and keystone words the road's faces still speak.

@Suite("13p — the protection brain's survivors: the idle clock and its words")
struct ProtectionCadenceTests {
    /// pre-13x 2a — THE IDLE CLOCK (decision 18): time since Variorum was
    /// last USED; nil minutes = never; the threshold is inclusive.
    @Test func theIdleClockIsTimeSinceVariorumWasLastUsed() {
        let now = Date()
        #expect(IdleLockClock.isDue(now: now, lastUsedAt: now.addingTimeInterval(-10 * 60), minutes: 10))
        #expect(!IdleLockClock.isDue(now: now, lastUsedAt: now.addingTimeInterval(-9 * 60), minutes: 10))
        #expect(!IdleLockClock.isDue(now: now, lastUsedAt: now.addingTimeInterval(-24 * 3600), minutes: nil),
                "never means never")
        #expect(!IdleLockClock.isDue(now: now, lastUsedAt: nil, minutes: 5),
                "no activity stamp yet ⇒ nothing to measure against")
        #expect(IdleLockClock.isDue(idleSeconds: 5 * 60, minutes: 5))
    }

    /// The idle dial's words (decision 18) and keystone 4's lead, verbatim (copy §1's survivors).
    @Test func theIdleAndKeystoneWordsRenderVerbatim() {
        #expect(ProtectionCopy.idleChoiceLabel(nil) == "never")
        #expect(ProtectionCopy.idleChoiceLabel(30) == "30 minutes")
        #expect(ProtectionCopy.idleLabel == "Lock after time away")
        #expect(ProtectionCopy.keystoneOpenMeansReadable.hasPrefix(
            "While Variorum is open and unlocked, everything in it is readable"))
    }
}
