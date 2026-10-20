//
//  RoadIdleDialTests.swift
//  VariorumTests — VX-309 U1c piece 4: VX-451 (F-U4-1's option (a)) — THE PANE'S IDLE DIAL AND LOCK NOW on the new road,
//  over planted keychain leaves and a temp slot with the real file leaves (`PlantedRoad` — no keychain; the suite also runs
//  headless in the implementer's SwiftPM harness). The Castle-only "On this Mac" row carries THIS MAC'S SEALED idle minutes
//  (`DeviceSettings.idleLockMinutes`, never UserDefaults); the dial writes them through the core's `changeSettings` and the
//  relock policy reads the new value at once; Standard has no row and its write refuses (Standard never locks — rule 8);
//  the model's Lock Now is the bootstrap's one lock. New API — red by construction on the pre-unit tree; the bootstrap's
//  own pins are `RoadIdleDialRouteTests` (Mac only).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-309 U1c — VX-451: the idle dial and Lock Now on the new road's pane (planted, no keychain)")
@MainActor
struct RoadIdleDialTests {
    static func row(_ session: ProtectionRoadSession) -> RoadGateRow? {
        ProtectionCrossings.readCrossings(session, exportSwitch: PlantedExportSwitch().road)?.gateRow
    }

    /// The row says the sealed minutes (10 by default); the dial seals 30, then never — each read back by the row AND by the
    /// relock policy (the monitors' one read); the dial's set is 5 · 10 · 30 · never.
    @Test func theCastleRowCarriesThisMacsSealedMinutesAndTheDialSealsThem() async throws {
        let road = PlantedRoad()
        let (session, _) = try await Crossing.inCastle(road)
        #expect(Self.row(session)?.idleMinutes == DeviceSettings.defaultIdleLockMinutes)
        #expect(RoadGateRow.idleChoices == [5, 10, 30, nil])
        #expect(await ProtectionCrossings.changeIdleLock(session, minutes: 30) == .changed)
        #expect(session.library.section.settings.idleLockMinutes == 30, "sealed in this Mac's section")
        #expect(Self.row(session)?.idleMinutes == 30)
        #expect(RoadRelockPolicy.of(session.library) == RoadRelockPolicy(idleMinutes: 30), "the monitors read it at once")
        // Read back from the library itself (a fresh unlock — the record, not this process's memory).
        let reread = try session.executor.unlock(with: session.key)
        #expect(reread.section.settings.idleLockMinutes == 30)
        #expect(await ProtectionCrossings.changeIdleLock(session, minutes: nil) == .changed)
        #expect(Self.row(session)?.idleMinutes == nil && RoadRelockPolicy.of(session.library)?.idleMinutes == nil,
                "never — and it still locks at sleep and screen lock")
        #expect(session.library.section.actInFlight == nil)
    }

    /// STANDARD: no row (the section exists only in Castle — P-2) and the dial's write refuses, nothing sealed.
    @Test func standardHasNoRowAndTheDialRefuses() async throws {
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        #expect(Self.row(session) == nil)
        #expect(await ProtectionCrossings.changeIdleLock(session, minutes: 30) == .refused(ProtectionWords.gateRowFailed))
        #expect(session.library.section.settings.idleLockMinutes == DeviceSettings.defaultIdleLockMinutes)
    }

    /// THE MODEL: the dial runs the road and re-reads (a refusal said in place); a same-value pick runs nothing; Lock Now is
    /// the road's — only where the Castle row stands.
    @Test func theModelsDialAndLockNowRunTheirRoads() async throws {
        let road = PlantedRoad()
        let (session, _) = try await Crossing.inCastle(road)
        final class Calls { var dial: [Int?] = []; var locks = 0; var answer: GateChangeOutcome = .changed }
        let calls = Calls()
        let exports = PlantedExportSwitch()
        let model = RoadCrossingsModel(roads: RoadCrossingRoads(
            read: { ProtectionCrossings.readCrossings(session, exportSwitch: exports.road) },
            cross: { _ in .refused("planted") },
            changeGate: { _, _ in .refused("planted") },
            turnExportBackOn: { false },
            exportNoticeOwed: { false },
            dismissExportNotice: {},
            changeIdleLock: { minutes in
                calls.dial.append(minutes)
                guard case .changed = calls.answer else { return calls.answer }
                return await ProtectionCrossings.changeIdleLock(session, minutes: minutes)
            },
            lockNow: { calls.locks += 1 }))
        await model.lockNow()
        #expect(calls.locks == 0, "no row read yet — no door")
        await model.refresh()
        await model.setIdleMinutes(10)
        #expect(calls.dial.isEmpty, "the value already sealed — nothing runs")
        await model.setIdleMinutes(5)
        #expect(calls.dial == [5] && model.faces?.gateRow?.idleMinutes == 5, "re-read after the write")
        calls.answer = .refused(ProtectionWords.gateRowFailed)
        await model.setIdleMinutes(nil)
        #expect(model.idleRefusal == ProtectionWords.gateRowFailed && model.faces?.gateRow?.idleMinutes == 5)
        await model.lockNow()
        #expect(calls.locks == 1)
    }
}
