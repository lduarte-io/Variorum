//
//  U2PinsRule21Tests.swift
//  VariorumCoreTests — VX-378 U2 piece F: RULE 21 — the memory at exactly four
//  things, an absent memory never a disagreement, and an act stranded by a lost
//  memory item finishing from the plan on disk (the orchestrator's
//  adjudications 5, 7 after U1). (U2's detect-and-REFUSE pins — a replayed
//  library file, a replayed key file and another library refused, `assess`
//  closing every door — died with the refusal at her ruling at the U4 stop,
//  2026-10-17: the open goes on and says so once — `U4NoticeTests`; a key file
//  that doesn't open the library is the offer's — `U4KeyFileOfferTests`.)
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-378 U2 — rule 21: four remembered things; absence is no disagreement; a stranded act settles from its plan")
struct U2PinsRule21Tests {
    /// Adjudication 5: an ABSENT memory never refuses (rule 8's keychain reset).
    @Test func anAbsentMemoryIsNoDisagreement() throws {
        let fixture = try EX(.standard)
        fixture.world.memories = [:]
        let library = try fixture.executor().unlock(with: fixture.key)
        #expect(library.memory == nil)
    }

    /// Adjudication 5: the memory item lost mid-act — the act finishes (or rolls
    /// back) from the plan on disk, in the section that plan names; then this
    /// Mac takes its fresh device ID.
    @Test func anActStrandedByALostMemoryItemSettlesFromThePlan() async throws {
        let fixture = try EX(.standard)
        try await midUseCastle(fixture, stopAfter: 7)
        let original = fixture.deviceID
        fixture.world.memories = [:]
        let (_, library, _) = try await fixture.relaunchAndSettle()
        expectSettled(fixture, library)
        #expect(library.section.deviceID != original, "the plan's section kept after the act settled")
        #expect(library.section.actInFlight == nil)
    }

    /// Adjudication 7: what this Mac remembers is exactly rule 21's four things.
    @Test func theMemoryHoldsExactlyFourThings() async throws {
        let fixture = try EX(.castle)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        var settings = library.section.settings
        settings.idleLockMinutes = 30
        _ = try await executor.changeSettings(&library, to: settings)
        let sealed = try #require(fixture.world.memories[fixture.libraryID])
        let fields = try #require(try JSONSerialization.jsonObject(with: sealed.payload) as? [String: Any])
        #expect(Set(fields.keys) == ["format", "libraryID", "currentFingerprint", "deviceID", "keyFileMirror"],
                "\(fields.keys.sorted())")
    }
}
