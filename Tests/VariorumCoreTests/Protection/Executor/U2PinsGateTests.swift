//
//  U2PinsGateTests.swift
//  VariorumCoreTests — VX-378 U2 piece D (the orchestrator's adjudication 3
//  after U1): Use Castle's press RECORDS its gate style — rule 9's "Touch ID on
//  this Mac is optional" is chosen at the press and remembered by it, so a
//  later Castle re-key makes its Touch ID item.
//

import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-378 U2 — Use Castle's press records the gate style it chose (rule 9)")
struct U2PinsGateTests {
    @Test(arguments: [GateStyle.touchID, .alwaysAsk])
    func useCastleRemembersTheGateItChose(_ gate: GateStyle) async throws {
        let fixture = try EX(.standard)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        #expect(library.section.settings.gateStyle == nil)
        _ = try await executor.useCastle(&library, typed: fixture.typed, gate: gate)
        #expect(library.section.settings.gateStyle == gate)
        let reopened = try fixture.executor().unlock(with: library.key)
        #expect(reopened.section.settings.gateStyle == gate, "the record's section forgot the press's choice")
    }

    /// The consequence the gap had: a Castle Replace All Keys after Use Castle
    /// with Touch ID minted its new key with no Touch ID item.
    @Test func aCastleReKeyAfterUseCastleWithTouchIDMakesItsTouchIDItem() async throws {
        let fixture = try EX(.standard, synced: true)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID)
        _ = try await executor.replaceAllKeys(&library, typed: fixture.typed)
        #expect(fixture.custody(.touchid, library.key), "the new Castle key has no Touch ID item")
    }
}
