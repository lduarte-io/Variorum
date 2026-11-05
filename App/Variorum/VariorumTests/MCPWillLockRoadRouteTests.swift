//
//  MCPWillLockRoadRouteTests.swift
//  VariorumTests
//
//  VX-818 (the VX-809 run, batch 4 — A-809-21, the coordinator's narrow clearance,
//  condition (3); the record `notes/plans/fixes/vx-809-mcp-door-ergonomics.md`
//  BATCH 4): the four roads that run `AppBootstrap.onWillLock`, each driven
//  THROUGH the bootstrap, each read the road it is — the value the Mac's lock
//  teardown decides on (`mcpServerSurvives`): the LOCK and a RE-KEYING REOPEN keep
//  the MCP server; Make this my library (adopt) and a plaintext export brought in
//  (swap) are the library CLOSING and tear it down exactly as before. The door's
//  half of each answer is `MCPStopRoadsDoorTests`'. Mac only (the lock and the
//  crossing on the planted road; adopt and swap on a throwaway keychain scope).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@MainActor
private final class RoadsSeen {
    var roads: [AppBootstrap.WillLockRoad?] = []
    func watch(_ bootstrap: AppBootstrap) {
        bootstrap.onWillLock = { [weak bootstrap, weak self] in self?.roads.append(bootstrap?.willLockRoad) }
    }
}

@Suite("VX-818 — the four onWillLock roads name themselves (A-809-21)", .serialized)
@MainActor
struct MCPWillLockRoadRouteTests {
    /// Lock Library Now — the LOCK road: it keeps the server.
    @Test func theLockNamesItselfAndKeepsTheServer() async throws {
        try await withRoadDependencies {
            let road = PlantedRoad()
            let (bootstrap, _) = try await LockWorld.readyInCastle(road)
            let seen = RoadsSeen()
            seen.watch(bootstrap)
            await bootstrap.lock()
            _ = try LockWorld.lobby(bootstrap)
            #expect(seen.roads == [.lock])
            #expect(mcpServerSurvives(seen.roads.last ?? nil))
        }
    }

    /// Use Castle… — the crossings' REOPENING seam (every re-keying act shares it):
    /// a re-key of the same library keeps the server (P-809-13).
    @Test func aReKeyingReopenNamesItselfAndKeepsTheServer() async throws {
        try await withRoadDependencies {
            let road = PlantedRoad()
            let (bootstrap, words) = try await LockWorld.readyInStandard(road)
            let seen = RoadsSeen()
            seen.watch(bootstrap)
            let crossings = try #require(bootstrap.roadCrossings)
            await crossings.refresh()
            crossings.open(.useCastle)
            let confirm = try #require(crossings.confirm)
            confirm.gate = .alwaysAsk
            await confirm.submit(
                passphrase: LockWorld.passphrase, again: LockWorld.passphrase, words: words.joined(separator: " "))
            #expect(crossings.confirm == nil, "the crossing landed: \(confirm.refusal ?? "-")")
            #expect(seen.roads == [.reKey])
            #expect(mcpServerSurvives(seen.roads.last ?? nil))
        }
    }

    /// Make this my library — the library CLOSING (adopt): a true stop, as before.
    @Test func adoptingACopyNamesTheClosingRoadAndTearsTheServerDown() async throws {
        try await withRoadDependencies {
            let world = RoadWorld()
            defer { world.scope.purge() }
            let (_, words) = try await world.created()
            let bootstrap = world.bootstrap()
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state, let session = bootstrap.roadSession else {
                Issue.record("the library opens: \(bootstrap.state)")
                return
            }
            #expect(ProtectionBackupHook.takePair(session, now: Date()) == .written)
            let roads = try #require(bootstrap.copyDoorsRoads())
            let row = try #require(await roads.listing().thisLibrary.first)
            let seen = RoadsSeen()
            seen.watch(bootstrap)
            let pair = TypedSecrets(words: words)
            #expect(await bootstrap.makeThisMyLibrary(row, copySecrets: pair, currentPair: pair) == .made)
            #expect(seen.roads == [.closing])
            #expect(!mcpServerSurvives(seen.roads.last ?? nil))
        }
    }

    /// A plaintext export brought in from an open library — the library CLOSING
    /// (swap): a true stop, as before.
    @Test func bringingInAnExportNamesTheClosingRoadAndTearsTheServerDown() async throws {
        try await withRoadDependencies {
            let world = RoadWorld()
            defer { world.scope.purge() }
            _ = try await world.created()
            let bootstrap = world.bootstrap()
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state, bootstrap.roadSession != nil else {
                Issue.record("the library opens: \(bootstrap.state)")
                return
            }
            let export = try ExportPlant.export(into: world.slot.root.appendingPathComponent("Downloads/vx818-export"))
            let roads = try #require(bootstrap.copyDoorsRoads())
            let bring = try #require(roads.bringInPlaintextExport)
            let seen = RoadsSeen()
            seen.watch(bootstrap)
            #expect(await bring(export) == .made)
            #expect(seen.roads == [.closing])
            #expect(!mcpServerSurvives(seen.roads.last ?? nil))
        }
    }
}
