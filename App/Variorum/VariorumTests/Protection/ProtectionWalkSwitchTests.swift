//
//  ProtectionWalkSwitchTests.swift
//  VariorumTests — VX-306 U1b: the DEBUG walk switch (P-VX306-U1b-9) over planted leaves — it parses only its
//  words, forgets exactly the scope's silent items, this library's Apple keys and (VX-306 U2) what this Mac remembers,
//  and never acts on a read-only road. (The production call sits behind the new road and `road.open == nil`, so no
//  test bootstrap reaches it.)
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-306 U1b — the walk switch (DEBUG walk machinery)")
@MainActor
struct ProtectionWalkSwitchTests {
    @Test func itParsesOnlyItsWords() {
        #expect(ProtectionWalkSwitch.parse("silent") == [.silent])
        #expect(ProtectionWalkSwitch.parse("apple, SILENT") == [.silent, .apple])
        #expect(ProtectionWalkSwitch.parse("memory,silent,apple") == [.silent, .apple, .memory])
        #expect(ProtectionWalkSwitch.parse("everything").isEmpty)
        #expect(ProtectionWalkSwitch.parse(nil).isEmpty)
    }

    @Test func itForgetsTheSilentItemsAndThisLibrarysAppleKeysAndTheRoadReMakesThem() async throws {
        let road = PlantedRoad()
        let (created, _) = try await road.created()
        let libraryID = try #require(created.library.record?.libraryID)
        // Another library's Apple key in the same scope stays.
        try road.apple.addAppleKey(AppleKeyMaterial.mint(), libraryID: "another-library")
        ProtectionWalkSwitch.forget([.silent, .apple], road.system())
        #expect(road.silentItems.isEmpty)
        #expect(try road.apple.appleKeyIDs(ofLibrary: libraryID).isEmpty)
        #expect(try road.apple.appleKeyIDs(ofLibrary: "another-library").count == 1)
        // The next open: no quiet road — the lobby (the walk's "both gone" row).
        guard case .lobby = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("both quiet roads forgotten — the lobby")
            return
        }
    }

    /// VX-306 U2: `memory` forgets what this Mac remembers — every memory item of the scope, nothing else.
    @Test func itForgetsWhatThisMacRemembers() async throws {
        let road = PlantedRoad()
        _ = try await road.created()
        #expect(road.memory.items.count == 1)
        ProtectionWalkSwitch.forget([.memory], road.system())
        #expect(road.memory.items.isEmpty)
        #expect(road.silentItems.count == 1, "only what was named")
    }

    @Test func aReadOnlyRoadNeverForgets() async throws {
        let road = PlantedRoad()
        _ = try await road.created()
        ProtectionWalkSwitch.forgetOnceIfAsked(
            road.context(writes: false), environment: [ProtectionWalkSwitch.environmentKey: "silent,apple"])
        #expect(road.silentItems.count == 1)
    }
}
