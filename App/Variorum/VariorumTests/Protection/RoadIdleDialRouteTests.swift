//
//  RoadIdleDialRouteTests.swift
//  VariorumTests — VX-309 U1c piece 4: VX-451 THROUGH `AppBootstrap` (a new-road bootstrap over the PLANTED road — no
//  keychain, a temp slot; Mac only) and BY SOURCE. The pane's Castle-only row: the idle dial seals THIS MAC'S minutes
//  through the bootstrap's crossings roads (`changeSettings` on the open session) and the bootstrap's relock policy — what
//  the monitors read — follows at once; Lock Library Now from the pane is the bootstrap's one lock (the lobby). Standard has
//  no row. Lock Library Now is ONE capability: the registry declares it once, with the menu's and the pane's doors, its verb
//  the one constant. Red by construction on the pre-unit tree (no dial road, no declaration).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-309 U1c — VX-451: the pane's idle dial and Lock Now, through AppBootstrap (planted, no keychain)", .serialized)
@MainActor
struct RoadIdleDialRouteTests {
    @Test func theDialSealsThisMacsMinutesAndThePanesLockNowLocks() async throws {
        try await withRoadDependencies {
            let road = PlantedRoad()
            let (standard, _) = try await LockWorld.readyInStandard(road)
            let standardCrossings = try #require(standard.roadCrossings)
            await standardCrossings.refresh()
            #expect(standardCrossings.faces?.gateRow == nil, "Standard — no row, no dial, no Lock Now (P-2)")

            let castleRoad = PlantedRoad()
            let (bootstrap, _) = try await LockWorld.readyInCastle(castleRoad)
            let crossings = try #require(bootstrap.roadCrossings)
            await crossings.refresh()
            #expect(crossings.faces?.gateRow?.idleMinutes == DeviceSettings.defaultIdleLockMinutes)
            await crossings.setIdleMinutes(30)
            #expect(crossings.faces?.gateRow?.idleMinutes == 30 && crossings.idleRefusal == nil)
            #expect(bootstrap.roadRelockPolicy == RoadRelockPolicy(idleMinutes: 30), "the monitors' read, at once")
            #expect(bootstrap.roadSession?.library.section.settings.idleLockMinutes == 30, "sealed — never UserDefaults")
            await crossings.lockNow()
            guard case .roadLobby = bootstrap.state else {
                Issue.record("the pane's Lock Now is the one lock — the lobby: \(bootstrap.state)")
                return
            }
            try await LockWorld.unlock(bootstrap)
            #expect(bootstrap.roadRelockPolicy == RoadRelockPolicy(idleMinutes: 30), "sealed in the record — read back")
        }
    }

    /// ONE capability, two doors (P-1): the declaration, its verb the one constant, the menu item and the pane's button
    /// rendering it; the dial in the Castle-only section over the sealed minutes and the honest set.
    @Test func lockLibraryNowIsOneDeclarationTheMenuAndThePaneRender() throws {
        let capability = CapabilityRegistry.capability(.lockLibraryNow)
        #expect(capability.verb == ProtectionCopy.lockNowLabel)
        #expect(capability.doors == [.menuBar, .surface])
        // VX-309 ladder round 1, F-R4: `always`, reached by no router dispatch — no dead note (the registry's idiom).
        #expect(capability.unavailableNote.isEmpty)
        #expect(EditorCommands.menuRendered.contains(.lockLibraryNow))
        #expect(RoadCrossingsSection.surfaceCapabilities == [.lockLibraryNow])
        let menu = try CopyListingFacesSurfaceTests.code("Variorum/EditorCommands.swift")
        #expect(menu.contains("Button(verb(.lockLibraryNow)) {"))
        #expect(menu.contains(".keyboardShortcut(\"l\", modifiers: [.command, .control])"), "the chord, unchanged")
        let section = try CopyListingFacesSurfaceTests.code("Variorum/Features/Protection/RoadCrossingSheet.swift")
        #expect(section.contains("Button(CapabilityRegistry.capability(.lockLibraryNow).verb) { Task { await model.lockNow() } }"))
        #expect(section.contains("get: { row.idleMinutes ?? 0 },"))
        #expect(section.contains("ForEach(RoadGateRow.idleChoices, id: \\.self) { minutes in"))
        #expect(section.contains("set: { minutes in Task { await model.setIdleMinutes(minutes == 0 ? nil : minutes) } })"))
    }
}
